import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Platzi Store',
      home: const ProductListPage(),
    );
  }
}

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final List images;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      images: json['images'],
    );
  }
}


class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late Future<List<Product>> products;

  @override
  void initState() {
    super.initState();
    products = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/products?offset=0&limit=10'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Ошибка загрузки списка');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Products'),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      backgroundColor: Colors.grey,
      ),
      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final items = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.65,
            ),
            
            itemBuilder: (context, index) {
              final product = items[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(productId: product.id),
                    ),
                  );
                },

                child: Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          product.images.isNotEmpty ? product.images[0] : '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 50),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '\$${product.price}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                    ],
                  ),
                ),
              );
            },
          );

        },
      ),
    );
  }
}


class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  Future<Product> fetchProduct() async {
    final response = await http.get(
      Uri.parse('https://api.escuelajs.co/api/v1/products/$productId'),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ошибка загрузки продукта');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Product Detail'),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      backgroundColor: Colors.grey,
      iconTheme: const IconThemeData(
      color: Colors.white,
      ),
      ),
      body: FutureBuilder<Product>(
        future: fetchProduct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final product = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Image.network(
                  product.images.isNotEmpty ? product.images[0] : '',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, size: 100),
                ),

                const SizedBox(height: 16),

                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),

                Text(product.description),

              ],
            ),
          );
        },
      ),
    );
  }
}
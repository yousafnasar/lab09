import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<dynamic> _todos = [];
  final String _url = 'https://jsonplaceholder.typicode.com/todos';

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final response = await http.get(Uri.parse(_url));
    if (response.statusCode == 200) {
      setState(() {
        _todos = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<void> _createTodo(String title) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'completed': false,
        'userId': 1,
      }),
    );

    if (response.statusCode == 201) {
      _fetchTodos(); // Refresh the list after adding a new todo
    } else {
      throw Exception('Failed to create todo');
    }
  }

  Future<void> _updateTodo(int id, String title) async {
    final response = await http.put(
      Uri.parse('$_url/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'completed': false,
        'userId': 1,
      }),
    );

    if (response.statusCode == 200) {
      _fetchTodos(); // Refresh the list after updating a todo
    } else {
      throw Exception('Failed to update todo');
    }
  }

  Future<void> _deleteTodo(int id) async {
    final response = await http.delete(Uri.parse('$_url/$id'));

    if (response.statusCode == 200) {
      _fetchTodos(); // Refresh the list after deleting a todo
    } else {
      throw Exception('Failed to delete todo');
    }
  }

  void _showCreateTodoDialog() {
    String title = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Todo'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Title'),
            onChanged: (value) => title = value,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _createTodo(title);
                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTodoDialog(int id, String currentTitle) {
    String title = currentTitle;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Todo'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Title'),
            controller: TextEditingController(text: currentTitle),
            onChanged: (value) => title = value,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateTodo(id, title);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return Card(
            child: ListTile(
              title: Text(todo['title']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () =>
                        _showEditTodoDialog(todo['id'], todo['title']),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTodo(todo['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTodoDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

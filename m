Subject: [PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
Message-Id: <E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 02 Aug 2007 13:31:56 +0200
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

The linux kernel doesn't have a type safe object allocator a-la new()
in C++ or g_new() in glib.

Introduce two helpers for this purpose:

   alloc_struct(type, gfp_flags);

   zalloc_struct(type, gfp_flags);

These macros take a type name (usually a 'struct foo') as first
argument and the usual gfp-flags as second argument.  They return a
pointer cast to 'type *'.

The traditional forms of allocating a structure are:

  fooptr = kmalloc(sizeof(*fooptr), ...);

  fooptr = kmalloc(sizeof(struct foo), ...);

The new form is preferred over these, because of it's type safety and
more descriptive nature.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux-2.6.22/include/linux/slab.h
===================================================================
--- linux-2.6.22.orig/include/linux/slab.h	2007-08-01 16:47:41.000000000 +0200
+++ linux-2.6.22/include/linux/slab.h	2007-08-02 12:55:20.000000000 +0200
@@ -110,6 +110,20 @@ static inline void *kcalloc(size_t n, si
 	return __kzalloc(n * size, flags);
 }
 
+/**
+ * alloc_struct - allocate given type object
+ * @type: the type of the object to allocate
+ * @flags: the type of memory to allocate.
+ */
+#define alloc_struct(type, flags) ((type *) kmalloc(sizeof(type), flags))
+
+/**
+ * zalloc_struct - allocate given type object, zero out the contents
+ * @type: the type of the object to allocate
+ * @flags: the type of memory to allocate.
+ */
+#define zalloc_struct(type, flags) ((type *) kzalloc(sizeof(type), flags))
+
 /*
  * Allocator specific definitions. These are mainly used to establish optimized
  * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by selecting
Index: linux-2.6.22/Documentation/CodingStyle
===================================================================
--- linux-2.6.22.orig/Documentation/CodingStyle	2007-07-09 01:32:17.000000000 +0200
+++ linux-2.6.22/Documentation/CodingStyle	2007-08-02 13:03:48.000000000 +0200
@@ -631,21 +631,20 @@ Printing numbers in parentheses (%d) add
 		Chapter 14: Allocating memory
 
 The kernel provides the following general purpose memory allocators:
-kmalloc(), kzalloc(), kcalloc(), and vmalloc().  Please refer to the API
+kmalloc(), kzalloc(), kcalloc(), and vmalloc(), and the following
+helpers: alloc_struct() and zalloc_struct().  Please refer to the API
 documentation for further information about them.
 
-The preferred form for passing a size of a struct is the following:
+The preferred form for allocating a structure is the following:
 
-	p = kmalloc(sizeof(*p), ...);
+	p = alloc_struct(struct name, ...);
 
-The alternative form where struct name is spelled out hurts readability and
-introduces an opportunity for a bug when the pointer variable type is changed
-but the corresponding sizeof that is passed to a memory allocator is not.
-
-Casting the return value which is a void pointer is redundant. The conversion
-from void pointer to any other pointer type is guaranteed by the C programming
-language.
+The alternatives are less readable or introduce an opportunity for a bug
+when the pointer variable type is changed but the corresponding sizeof that
+is passed to a memory allocator is not.
 
+The return value of alloc_struct() and zalloc_struct() have the right type,
+so the compiler will warn if it is assigned to a pointer of different type.
 
 		Chapter 15: The inline disease
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

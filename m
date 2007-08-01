Subject: [RFC PATCH] type safe allocator
Message-Id: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 01 Aug 2007 11:06:46 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

I wonder why we don't have type safe object allocators a-la new() in
C++ or g_new() in glib?

  fooptr = k_new(struct foo, GFP_KERNEL);

is nicer and more descriptive than

  fooptr = kmalloc(sizeof(*fooptr), GFP_KERNEL);

and more safe than

  fooptr = kmalloc(sizeof(struct foo), GFP_KERNEL);

And we have zillions of both variants.

Note, I'm not advocating mass replacement, but using this in new code,
and gradually converting old ones whenever they need touching anyway.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux-2.6.22/include/linux/slab.h
===================================================================
--- linux-2.6.22.orig/include/linux/slab.h	2007-07-09 01:32:17.000000000 +0200
+++ linux-2.6.22/include/linux/slab.h	2007-08-01 10:42:45.000000000 +0200
@@ -110,6 +110,38 @@ static inline void *kcalloc(size_t n, si
 	return __kzalloc(n * size, flags);
 }
 
+/**
+ * k_new - allocate given type object
+ * @type: the type of the object to allocate
+ * @flags: the type of memory to allocate.
+ */
+#define k_new(type, flags) ((type *) kmalloc(sizeof(type), flags))
+
+/**
+ * k_new0 - allocate given type object, zero out allocated space
+ * @type: the type of the object to allocate
+ * @flags: the type of memory to allocate.
+ */
+#define k_new0(type, flags) ((type *) kzalloc(sizeof(type), flags))
+
+/**
+ * k_new_array - allocate array of given type object
+ * @type: the type of the object to allocate
+ * @len: the length of the array
+ * @flags: the type of memory to allocate.
+ */
+#define k_new_array(type, len, flags) \
+	((type *) kmalloc(sizeof(type) * (len), flags))
+
+/**
+ * k_new0_array - allocate array of given type object, zero out allocated space
+ * @type: the type of the object to allocate
+ * @len: the length of the array
+ * @flags: the type of memory to allocate.
+ */
+#define k_new0_array(type, len, flags) \
+	((type *) kzalloc(sizeof(type) * (len), flags))
+
 /*
  * Allocator specific definitions. These are mainly used to establish optimized
  * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by selecting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

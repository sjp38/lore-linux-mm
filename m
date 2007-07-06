Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-4.corp.sgi.com (Postfix) with ESMTP id 80C9261B92
	for <linux-mm@kvack.org>; Fri,  6 Jul 2007 12:50:41 -0700 (PDT)
Received: from clameter (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1I6tpB-0006KP-00
	for <linux-mm@kvack.org>; Fri, 06 Jul 2007 12:50:41 -0700
Date: Fri, 6 Jul 2007 12:50:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Slab allocators: Cleanup zeroing allocations (fwd)
Message-ID: <Pine.LNX.4.64.0707061250230.24321@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


---------- Forwarded message ----------
Date: Fri, 6 Jul 2007 12:48:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
To: akpm@linux-foundation.org
Cc: linux-mm@vger.kernel.org
Subject: Slab allocators: Cleanup zeroing allocations

It becomes now easy to support the zeroing allocs with generic inline functions
in slab.h. Provide inline definitions to allow the continued use of
kzalloc, kmem_cache_zalloc etc but remove other definitions of zeroing functions
from the slab allocators and util.c.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slab.h     |   77 ++++++++++++++++++++++++++++-------------------
 include/linux/slab_def.h |   30 ------------------
 include/linux/slub_def.h |   13 -------
 mm/slab.c                |   17 ----------
 mm/slob.c                |   10 ------
 mm/slub.c                |   11 ------
 mm/util.c                |   14 --------
 7 files changed, 46 insertions(+), 126 deletions(-)

Index: linux-2.6.22-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/slab.h	2007-07-04 13:32:41.000000000 -0700
+++ linux-2.6.22-rc6-mm1/include/linux/slab.h	2007-07-04 13:37:15.000000000 -0700
@@ -57,7 +57,6 @@ struct kmem_cache *kmem_cache_create(con
 			void (*)(void *, struct kmem_cache *, unsigned long));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
-void *kmem_cache_zalloc(struct kmem_cache *, gfp_t);
 void kmem_cache_free(struct kmem_cache *, void *);
 unsigned int kmem_cache_size(struct kmem_cache *);
 const char *kmem_cache_name(struct kmem_cache *);
@@ -93,11 +92,37 @@ int kmem_ptr_validate(struct kmem_cache 
 /*
  * Common kmalloc functions provided by all allocators
  */
-void *__kzalloc(size_t, gfp_t);
 void * __must_check krealloc(const void *, size_t, gfp_t);
 void kfree(const void *);
 size_t ksize(const void *);
 
+/*
+ * Allocator specific definitions. These are mainly used to establish optimized
+ * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by
+ * selecting the appropriate general cache at compile time.
+ *
+ * Allocators must define at least:
+ *
+ *	kmem_cache_alloc()
+ *	__kmalloc()
+ *	kmalloc()
+ *
+ * Those wishing to support NUMA must also define:
+ *
+ *	kmem_cache_alloc_node()
+ *	kmalloc_node()
+ *
+ * See each allocator definition file for additional comments and
+ * implementation notes.
+ */
+#ifdef CONFIG_SLUB
+#include <linux/slub_def.h>
+#elif defined(CONFIG_SLOB)
+#include <linux/slob_def.h>
+#else
+#include <linux/slab_def.h>
+#endif
+
 /**
  * kcalloc - allocate memory for an array. The memory is set to zero.
  * @n: number of elements.
@@ -153,37 +178,9 @@ static inline void *kcalloc(size_t n, si
 {
 	if (n != 0 && size > ULONG_MAX / n)
 		return NULL;
-	return __kzalloc(n * size, flags);
+	return __kmalloc(n * size, flags | __GFP_ZERO);
 }
 
-/*
- * Allocator specific definitions. These are mainly used to establish optimized
- * ways to convert kmalloc() calls to kmem_cache_alloc() invocations by
- * selecting the appropriate general cache at compile time.
- *
- * Allocators must define at least:
- *
- *	kmem_cache_alloc()
- *	__kmalloc()
- *	kmalloc()
- *	kzalloc()
- *
- * Those wishing to support NUMA must also define:
- *
- *	kmem_cache_alloc_node()
- *	kmalloc_node()
- *
- * See each allocator definition file for additional comments and
- * implementation notes.
- */
-#ifdef CONFIG_SLUB
-#include <linux/slub_def.h>
-#elif defined(CONFIG_SLOB)
-#include <linux/slob_def.h>
-#else
-#include <linux/slab_def.h>
-#endif
-
 #if !defined(CONFIG_NUMA) && !defined(CONFIG_SLOB)
 /**
  * kmalloc_node - allocate memory from a specific node
@@ -257,5 +254,23 @@ extern void *__kmalloc_node_track_caller
 
 #endif /* DEBUG_SLAB */
 
+/*
+ * Shortcuts
+ */
+static inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
+{
+	return kmem_cache_alloc(k, flags | __GFP_ZERO);
+}
+
+/**
+ * kzalloc - allocate memory. The memory is set to zero.
+ * @size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate (see kmalloc).
+ */
+static inline void *kzalloc(size_t size, gfp_t flags)
+{
+	return kmalloc(size, flags | __GFP_ZERO);
+}
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SLAB_H */
Index: linux-2.6.22-rc6-mm1/include/linux/slab_def.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/slab_def.h	2007-07-04 13:32:41.000000000 -0700
+++ linux-2.6.22-rc6-mm1/include/linux/slab_def.h	2007-07-04 13:37:15.000000000 -0700
@@ -58,36 +58,6 @@ found:
 	return __kmalloc(size, flags);
 }
 
-static inline void *kzalloc(size_t size, gfp_t flags)
-{
-	if (__builtin_constant_p(size)) {
-		int i = 0;
-
-		if (!size)
-			return ZERO_SIZE_PTR;
-
-#define CACHE(x) \
-		if (size <= x) \
-			goto found; \
-		else \
-			i++;
-#include "kmalloc_sizes.h"
-#undef CACHE
-		{
-			extern void __you_cannot_kzalloc_that_much(void);
-			__you_cannot_kzalloc_that_much();
-		}
-found:
-#ifdef CONFIG_ZONE_DMA
-		if (flags & GFP_DMA)
-			return kmem_cache_zalloc(malloc_sizes[i].cs_dmacachep,
-						flags);
-#endif
-		return kmem_cache_zalloc(malloc_sizes[i].cs_cachep, flags);
-	}
-	return __kzalloc(size, flags);
-}
-
 #ifdef CONFIG_NUMA
 extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
 extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
Index: linux-2.6.22-rc6-mm1/include/linux/slub_def.h
===================================================================
--- linux-2.6.22-rc6-mm1.orig/include/linux/slub_def.h	2007-07-04 13:32:41.000000000 -0700
+++ linux-2.6.22-rc6-mm1/include/linux/slub_def.h	2007-07-04 13:37:15.000000000 -0700
@@ -179,19 +179,6 @@ static inline void *kmalloc(size_t size,
 		return __kmalloc(size, flags);
 }
 
-static inline void *kzalloc(size_t size, gfp_t flags)
-{
-	if (__builtin_constant_p(size) && !(flags & SLUB_DMA)) {
-		struct kmem_cache *s = kmalloc_slab(size);
-
-		if (!s)
-			return ZERO_SIZE_PTR;
-
-		return kmem_cache_zalloc(s, flags);
-	} else
-		return __kzalloc(size, flags);
-}
-
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node);
 void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
Index: linux-2.6.22-rc6-mm1/mm/slab.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slab.c	2007-07-04 13:32:41.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slab.c	2007-07-04 13:37:15.000000000 -0700
@@ -3578,23 +3578,6 @@ void *kmem_cache_alloc(struct kmem_cache
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 /**
- * kmem_cache_zalloc - Allocate an object. The memory is set to zero.
- * @cache: The cache to allocate from.
- * @flags: See kmalloc().
- *
- * Allocate an object from this cache and set the allocated memory to zero.
- * The flags are only relevant if the cache has no available objects.
- */
-void *kmem_cache_zalloc(struct kmem_cache *cache, gfp_t flags)
-{
-	void *ret = __cache_alloc(cache, flags, __builtin_return_address(0));
-	if (ret)
-		memset(ret, 0, obj_size(cache));
-	return ret;
-}
-EXPORT_SYMBOL(kmem_cache_zalloc);
-
-/**
  * kmem_ptr_validate - check if an untrusted pointer might
  *	be a slab entry.
  * @cachep: the cache we're checking against
Index: linux-2.6.22-rc6-mm1/mm/slob.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slob.c	2007-07-04 13:32:41.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slob.c	2007-07-04 13:37:15.000000000 -0700
@@ -543,16 +543,6 @@ void *kmem_cache_alloc_node(struct kmem_
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
-void *kmem_cache_zalloc(struct kmem_cache *c, gfp_t flags)
-{
-	void *ret = kmem_cache_alloc(c, flags);
-	if (ret)
-		memset(ret, 0, c->size);
-
-	return ret;
-}
-EXPORT_SYMBOL(kmem_cache_zalloc);
-
 static void __kmem_cache_free(void *b, int size)
 {
 	if (size < PAGE_SIZE)
Index: linux-2.6.22-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-04 13:36:54.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-04 13:37:41.000000000 -0700
@@ -2726,17 +2726,6 @@ err:
 }
 EXPORT_SYMBOL(kmem_cache_create);
 
-void *kmem_cache_zalloc(struct kmem_cache *s, gfp_t flags)
-{
-	void *x;
-
-	x = slab_alloc(s, flags, -1, __builtin_return_address(0));
-	if (x)
-		memset(x, 0, s->objsize);
-	return x;
-}
-EXPORT_SYMBOL(kmem_cache_zalloc);
-
 #ifdef CONFIG_SMP
 /*
  * Use the cpu notifier to insure that the cpu slabs are flushed when
Index: linux-2.6.22-rc6-mm1/mm/util.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/util.c	2007-07-04 13:32:41.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/util.c	2007-07-04 13:37:15.000000000 -0700
@@ -5,20 +5,6 @@
 #include <asm/uaccess.h>
 
 /**
- * __kzalloc - allocate memory. The memory is set to zero.
- * @size: how many bytes of memory are required.
- * @flags: the type of memory to allocate.
- */
-void *__kzalloc(size_t size, gfp_t flags)
-{
-	void *ret = kmalloc_track_caller(size, flags);
-	if (ret)
-		memset(ret, 0, size);
-	return ret;
-}
-EXPORT_SYMBOL(__kzalloc);
-
-/**
  * kstrdup - allocate space for and copy an existing string
  * @s: the string to duplicate
  * @gfp: the GFP mask used in the kmalloc() call when allocating memory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

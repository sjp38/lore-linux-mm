Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 8E3CE6B0034
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 17:15:00 -0400 (EDT)
Message-ID: <0000013fee7c6bb3-013979a6-eaf2-48b2-b6bf-5af5456d62bc-000000@email.amazonses.com>
Date: Wed, 17 Jul 2013 21:14:59 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C1 [2/2] Move kmalloc definitions to slab.h
References: <20130717211502.352973513@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

All the kmallocs are mostly doing the same. Unify them.

slob_def.h becomes empty. So remove it.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2013-07-15 09:38:40.853127741 -0500
+++ linux/include/linux/slab.h	2013-07-15 09:39:49.026313739 -0500
@@ -4,6 +4,8 @@
  * (C) SGI 2006, Christoph Lameter
  * 	Cleaned up and restructured to ease the addition of alternative
  * 	implementations of SLAB allocators.
+ * (C) Linux Foundation 2008-2013
+ *      Unified interface for all slab allocators
  */
 
 #ifndef _LINUX_SLAB_H
@@ -94,6 +96,7 @@
 #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
 				(unsigned long)ZERO_SIZE_PTR)
 
+#include <linux/kmemleak.h>
 
 struct mem_cgroup;
 /*
@@ -308,6 +311,7 @@ static __always_inline void *kmem_cache_
 #endif
 
 #ifdef CONFIG_TRACING
+extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t);
 
 #ifdef CONFIG_NUMA
 extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
@@ -316,14 +320,20 @@ extern void *kmem_cache_alloc_node_trace
 #else
 static __always_inline void *
 kmem_cache_alloc_node_trace(struct kmem_cache *s,
-				gfp_t gfpflags,
-				int node, size_t size)
+			      gfp_t gfpflags,
+			      int node, size_t size)
 {
 	return kmem_cache_alloc_trace(s, gfpflags, size);
 }
 #endif /* CONFIG_NUMA */
 
-#else
+#else /* CONFIG_TRACING */
+static __always_inline void *kmem_cache_alloc_trace(struct kmem_cache *s,
+		gfp_t flags, size_t size)
+{
+	return kmem_cache_alloc(s, flags);
+}
+
 static __always_inline void *
 kmem_cache_alloc_node_trace(struct kmem_cache *s,
 			      gfp_t gfpflags,
@@ -341,10 +351,61 @@ kmem_cache_alloc_node_trace(struct kmem_
 #include <linux/slub_def.h>
 #endif
 
-#ifdef CONFIG_SLOB
-#include <linux/slob_def.h>
+static __always_inline void *
+kmalloc_order(size_t size, gfp_t flags, unsigned int order)
+{
+	void *ret;
+
+	flags |= (__GFP_COMP | __GFP_KMEMCG);
+	ret = (void *) __get_free_pages(flags, order);
+	kmemleak_alloc(ret, size, 1, flags);
+	return ret;
+}
+
+#ifdef CONFIG_TRACING
+extern void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order);
+#else
+static __always_inline void *
+kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
+{
+	return kmalloc_order(size, flags, order);
+}
 #endif
 
+static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
+{
+	unsigned int order = get_order(size);
+	return kmalloc_order_trace(size, flags, order);
+}
+
+/**
+ * kmalloc - allocate memory
+ * @size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate (see kcalloc).
+ *
+ * kmalloc is the normal method of allocating memory
+ * for objects smaller than page size in the kernel.
+ */
+static __always_inline void *kmalloc(size_t size, gfp_t flags)
+{
+	if (__builtin_constant_p(size)) {
+		if (size > KMALLOC_MAX_CACHE_SIZE)
+			return kmalloc_large(size, flags);
+#ifndef CONFIG_SLOB
+		if (!(flags & GFP_DMA)) {
+			int index = kmalloc_index(size);
+
+			if (!index)
+				return ZERO_SIZE_PTR;
+
+			return kmem_cache_alloc_trace(kmalloc_caches[index],
+					flags, size);
+		}
+#endif
+	}
+	return __kmalloc(size, flags);
+}
+
 /*
  * Determine size used for the nth kmalloc cache.
  * return size or 0 if a kmalloc cache for that
Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h	2013-07-15 09:38:40.853127741 -0500
+++ linux/include/linux/slab_def.h	2013-07-15 09:38:40.853127741 -0500
@@ -102,44 +102,4 @@ struct kmem_cache {
 	 */
 };
 
-#ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t);
-#else
-static __always_inline void *
-kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
-{
-	return kmem_cache_alloc(cachep, flags);
-}
-#endif
-
-static __always_inline void *kmalloc(size_t size, gfp_t flags)
-{
-	struct kmem_cache *cachep;
-	void *ret;
-
-	if (__builtin_constant_p(size)) {
-		int i;
-
-		if (!size)
-			return ZERO_SIZE_PTR;
-
-		if (WARN_ON_ONCE(size > KMALLOC_MAX_SIZE))
-			return NULL;
-
-		i = kmalloc_index(size);
-
-#ifdef CONFIG_ZONE_DMA
-		if (flags & GFP_DMA)
-			cachep = kmalloc_dma_caches[i];
-		else
-#endif
-			cachep = kmalloc_caches[i];
-
-		ret = kmem_cache_alloc_trace(cachep, flags, size);
-
-		return ret;
-	}
-	return __kmalloc(size, flags);
-}
-
 #endif	/* _LINUX_SLAB_DEF_H */
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2013-07-15 09:38:40.853127741 -0500
+++ linux/include/linux/slub_def.h	2013-07-15 09:38:40.853127741 -0500
@@ -12,8 +12,6 @@
 #include <linux/workqueue.h>
 #include <linux/kobject.h>
 
-#include <linux/kmemleak.h>
-
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu slab */
 	ALLOC_SLOWPATH,		/* Allocation by getting a new cpu slab */
@@ -104,17 +102,6 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
-static __always_inline void *
-kmalloc_order(size_t size, gfp_t flags, unsigned int order)
-{
-	void *ret;
-
-	flags |= (__GFP_COMP | __GFP_KMEMCG);
-	ret = (void *) __get_free_pages(flags, order);
-	kmemleak_alloc(ret, size, 1, flags);
-	return ret;
-}
-
 /**
  * Calling this on allocated memory will check that the memory
  * is expected to be in use, and print warnings if not.
@@ -128,47 +115,4 @@ static inline bool verify_mem_not_delete
 }
 #endif
 
-#ifdef CONFIG_TRACING
-extern void *
-kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size);
-extern void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order);
-#else
-static __always_inline void *
-kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
-{
-	return kmem_cache_alloc(s, gfpflags);
-}
-
-static __always_inline void *
-kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
-{
-	return kmalloc_order(size, flags, order);
-}
-#endif
-
-static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
-{
-	unsigned int order = get_order(size);
-	return kmalloc_order_trace(size, flags, order);
-}
-
-static __always_inline void *kmalloc(size_t size, gfp_t flags)
-{
-	if (__builtin_constant_p(size)) {
-		if (size > KMALLOC_MAX_CACHE_SIZE)
-			return kmalloc_large(size, flags);
-
-		if (!(flags & GFP_DMA)) {
-			int index = kmalloc_index(size);
-
-			if (!index)
-				return ZERO_SIZE_PTR;
-
-			return kmem_cache_alloc_trace(kmalloc_caches[index],
-					flags, size);
-		}
-	}
-	return __kmalloc(size, flags);
-}
-
 #endif /* _LINUX_SLUB_DEF_H */
Index: linux/include/linux/slob_def.h
===================================================================
--- linux.orig/include/linux/slob_def.h	2013-07-15 09:38:40.853127741 -0500
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,9 +0,0 @@
-#ifndef __LINUX_SLOB_DEF_H
-#define __LINUX_SLOB_DEF_H
-
-static __always_inline void *kmalloc(size_t size, gfp_t flags)
-{
-	return __kmalloc_node(size, flags, NUMA_NO_NODE);
-}
-
-#endif /* __LINUX_SLOB_DEF_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id DB56B6B0033
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 11:49:27 -0400 (EDT)
Message-ID: <00000140785e1062-89326db9-3999-43c1-b081-284dd49b3d9b-000000@email.amazonses.com>
Date: Tue, 13 Aug 2013 15:49:26 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.12 1/3] Move kmallocXXX functions to common code
References: <20130813154940.741769876@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

The kmalloc* functions of all slab allcoators are similar now so
lets move them into slab.h. This requires some function naming changes
in slob.

As a results of this patch there is a common set of functions for
all allocators. Also means that kmalloc_large() is now available
in general to perform large order allocations that go directly
via the page allocator. kmalloc_large() can be substituted if
kmalloc() throws warnings because of too large allocations.

kmalloc_large() has exactly the same semantics as kmalloc but
can only used for allocations > PAGE_SIZE.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2013-08-12 13:54:45.038554317 -0500
+++ linux/include/linux/slab.h	2013-08-12 14:46:28.670426453 -0500
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
@@ -289,6 +292,57 @@ static __always_inline int kmalloc_index
 }
 #endif /* !CONFIG_SLOB */
 
+void *__kmalloc(size_t size, gfp_t flags);
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags);
+
+#ifdef CONFIG_NUMA
+void *__kmalloc_node(size_t size, gfp_t flags, int node);
+void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
+#else
+static __always_inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __kmalloc(size, flags);
+}
+
+static __always_inline void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t flags, int node)
+{
+	return kmem_cache_alloc(s, flags);
+}
+#endif
+
+#ifdef CONFIG_TRACING
+extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t);
+
+#ifdef CONFIG_NUMA
+extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
+					   gfp_t gfpflags,
+					   int node, size_t size);
+#else
+static __always_inline void *
+kmem_cache_alloc_node_trace(struct kmem_cache *s,
+			      gfp_t gfpflags,
+			      int node, size_t size)
+{
+	return kmem_cache_alloc_trace(s, gfpflags, size);
+}
+#endif /* CONFIG_NUMA */
+
+#else /* CONFIG_TRACING */
+static __always_inline void *kmem_cache_alloc_trace(struct kmem_cache *s,
+		gfp_t flags, size_t size)
+{
+	return kmem_cache_alloc(s, flags);
+}
+
+static __always_inline void *
+kmem_cache_alloc_node_trace(struct kmem_cache *s,
+			      gfp_t gfpflags,
+			      int node, size_t size)
+{
+	return kmem_cache_alloc_node(s, gfpflags, node);
+}
+#endif /* CONFIG_TRACING */
+
 #ifdef CONFIG_SLAB
 #include <linux/slab_def.h>
 #endif
@@ -297,10 +351,61 @@ static __always_inline int kmalloc_index
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
@@ -321,6 +426,23 @@ static __always_inline int kmalloc_size(
 	return 0;
 }
 
+static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+#ifndef CONFIG_SLOB
+	if (__builtin_constant_p(size) &&
+		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & SLAB_CACHE_DMA)) {
+		int i = kmalloc_index(size);
+
+		if (!i)
+			return ZERO_SIZE_PTR;
+
+		return kmem_cache_alloc_node_trace(kmalloc_caches[i],
+			       			flags, node, size);
+	}
+#endif
+	return __kmalloc_node(size, flags, node);
+}
+
 /*
  * Setting ARCH_SLAB_MINALIGN in arch headers allows a different alignment.
  * Intended for arches that get misalignment faults even for 64 bit integer
@@ -451,36 +573,6 @@ static inline void *kcalloc(size_t n, si
 	return kmalloc_array(n, size, flags | __GFP_ZERO);
 }
 
-#if !defined(CONFIG_NUMA) && !defined(CONFIG_SLOB)
-/**
- * kmalloc_node - allocate memory from a specific node
- * @size: how many bytes of memory are required.
- * @flags: the type of memory to allocate (see kmalloc).
- * @node: node to allocate from.
- *
- * kmalloc() for non-local nodes, used to allocate from a specific node
- * if available. Equivalent to kmalloc() in the non-NUMA single-node
- * case.
- */
-static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
-{
-	return kmalloc(size, flags);
-}
-
-static inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
-{
-	return __kmalloc(size, flags);
-}
-
-void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
-
-static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
-					gfp_t flags, int node)
-{
-	return kmem_cache_alloc(cachep, flags);
-}
-#endif /* !CONFIG_NUMA && !CONFIG_SLOB */
-
 /*
  * kmalloc_track_caller is a special version of kmalloc that records the
  * calling function of the routine calling it for slab leak tracking instead
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2013-08-12 13:54:45.038554317 -0500
+++ linux/include/linux/slub_def.h	2013-08-12 14:52:36.698704692 -0500
@@ -6,14 +6,8 @@
  *
  * (C) 2007 SGI, Christoph Lameter
  */
-#include <linux/types.h>
-#include <linux/gfp.h>
-#include <linux/bug.h>
-#include <linux/workqueue.h>
 #include <linux/kobject.h>
 
-#include <linux/kmemleak.h>
-
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu slab */
 	ALLOC_SLOWPATH,		/* Allocation by getting a new cpu slab */
@@ -104,20 +98,6 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
-void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
-void *__kmalloc(size_t size, gfp_t flags);
-
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
@@ -131,81 +111,4 @@ static inline bool verify_mem_not_delete
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
-#ifdef CONFIG_NUMA
-void *__kmalloc_node(size_t size, gfp_t flags, int node);
-void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
-
-#ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
-					   gfp_t gfpflags,
-					   int node, size_t size);
-#else
-static __always_inline void *
-kmem_cache_alloc_node_trace(struct kmem_cache *s,
-			      gfp_t gfpflags,
-			      int node, size_t size)
-{
-	return kmem_cache_alloc_node(s, gfpflags, node);
-}
-#endif
-
-static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
-{
-	if (__builtin_constant_p(size) &&
-		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
-		int index = kmalloc_index(size);
-
-		if (!index)
-			return ZERO_SIZE_PTR;
-
-		return kmem_cache_alloc_node_trace(kmalloc_caches[index],
-			       flags, node, size);
-	}
-	return __kmalloc_node(size, flags, node);
-}
-#endif
-
 #endif /* _LINUX_SLUB_DEF_H */
Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h	2013-08-12 13:54:45.038554317 -0500
+++ linux/include/linux/slab_def.h	2013-08-12 14:52:36.698704692 -0500
@@ -3,20 +3,6 @@
 
 /*
  * Definitions unique to the original Linux SLAB allocator.
- *
- * What we provide here is a way to optimize the frequent kmalloc
- * calls in the kernel by selecting the appropriate general cache
- * if kmalloc was called with a size that can be established at
- * compile time.
- */
-
-#include <linux/init.h>
-#include <linux/compiler.h>
-
-/*
- * struct kmem_cache
- *
- * manages a cache.
  */
 
 struct kmem_cache {
@@ -102,96 +88,4 @@ struct kmem_cache {
 	 */
 };
 
-void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
-void *__kmalloc(size_t size, gfp_t flags);
-
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
-#ifdef CONFIG_NUMA
-extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
-extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
-
-#ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
-					 gfp_t flags,
-					 int nodeid,
-					 size_t size);
-#else
-static __always_inline void *
-kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
-			    gfp_t flags,
-			    int nodeid,
-			    size_t size)
-{
-	return kmem_cache_alloc_node(cachep, flags, nodeid);
-}
-#endif
-
-static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
-{
-	struct kmem_cache *cachep;
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
-		return kmem_cache_alloc_node_trace(cachep, flags, node, size);
-	}
-	return __kmalloc_node(size, flags, node);
-}
-
-#endif	/* CONFIG_NUMA */
-
 #endif	/* _LINUX_SLAB_DEF_H */
Index: linux/include/linux/slob_def.h
===================================================================
--- linux.orig/include/linux/slob_def.h	2013-08-12 13:54:45.038554317 -0500
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,31 +0,0 @@
-#ifndef __LINUX_SLOB_DEF_H
-#define __LINUX_SLOB_DEF_H
-
-#include <linux/numa.h>
-
-void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
-
-static __always_inline void *kmem_cache_alloc(struct kmem_cache *cachep,
-					      gfp_t flags)
-{
-	return kmem_cache_alloc_node(cachep, flags, NUMA_NO_NODE);
-}
-
-void *__kmalloc_node(size_t size, gfp_t flags, int node);
-
-static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
-{
-	return __kmalloc_node(size, flags, node);
-}
-
-static __always_inline void *kmalloc(size_t size, gfp_t flags)
-{
-	return __kmalloc_node(size, flags, NUMA_NO_NODE);
-}
-
-static __always_inline void *__kmalloc(size_t size, gfp_t flags)
-{
-	return kmalloc(size, flags);
-}
-
-#endif /* __LINUX_SLOB_DEF_H */
Index: linux/mm/slob.c
===================================================================
--- linux.orig/mm/slob.c	2013-08-12 13:54:45.038554317 -0500
+++ linux/mm/slob.c	2013-08-12 13:54:45.030554383 -0500
@@ -462,11 +462,11 @@ __do_kmalloc_node(size_t size, gfp_t gfp
 	return ret;
 }
 
-void *__kmalloc_node(size_t size, gfp_t gfp, int node)
+void *__kmalloc(size_t size, gfp_t gfp)
 {
-	return __do_kmalloc_node(size, gfp, node, _RET_IP_);
+	return __do_kmalloc_node(size, gfp, NUMA_NO_NODE, _RET_IP_);
 }
-EXPORT_SYMBOL(__kmalloc_node);
+EXPORT_SYMBOL(__kmalloc);
 
 #ifdef CONFIG_TRACING
 void *__kmalloc_track_caller(size_t size, gfp_t gfp, unsigned long caller)
@@ -534,7 +534,7 @@ int __kmem_cache_create(struct kmem_cach
 	return 0;
 }
 
-void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
+void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
 	void *b;
 
@@ -560,7 +560,27 @@ void *kmem_cache_alloc_node(struct kmem_
 	kmemleak_alloc_recursive(b, c->size, 1, c->flags, flags);
 	return b;
 }
+EXPORT_SYMBOL(slob_alloc_node);
+
+void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
+{
+	return slob_alloc_node(cachep, flags, NUMA_NO_NODE);
+}
+EXPORT_SYMBOL(kmem_cache_alloc);
+
+#ifdef CONFIG_NUMA
+void *__kmalloc_node(size_t size, gfp_t gfp, int node)
+{
+	return __do_kmalloc_node(size, gfp, node, _RET_IP_);
+}
+EXPORT_SYMBOL(__kmalloc_node);
+
+void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t gfp, int node)
+{
+	return slob_alloc_node(cachep, gfp, node);
+}
 EXPORT_SYMBOL(kmem_cache_alloc_node);
+#endif
 
 static void __kmem_cache_free(void *b, int size)
 {
Index: linux/mm/slab_common.c
===================================================================
--- linux.orig/mm/slab_common.c	2013-08-12 14:45:06.000000000 -0500
+++ linux/mm/slab_common.c	2013-08-12 14:46:30.874403051 -0500
@@ -19,6 +19,7 @@
 #include <asm/tlbflush.h>
 #include <asm/page.h>
 #include <linux/memcontrol.h>
+#include <trace/events/kmem.h>
 
 #include "slab.h"
 
@@ -495,6 +496,15 @@ void __init create_kmalloc_caches(unsign
 }
 #endif /* !CONFIG_SLOB */
 
+#ifdef CONFIG_TRACING
+void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
+{
+	void *ret = kmalloc_order(size, flags, order);
+	trace_kmalloc(_RET_IP_, ret, size, PAGE_SIZE << order, flags);
+	return ret;
+}
+EXPORT_SYMBOL(kmalloc_order_trace);
+#endif
 
 #ifdef CONFIG_SLABINFO
 
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2013-08-12 14:45:06.000000000 -0500
+++ linux/mm/slub.c	2013-08-12 14:46:30.874403051 -0500
@@ -2434,14 +2434,6 @@ void *kmem_cache_alloc_trace(struct kmem
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
-
-void *kmalloc_order_trace(size_t size, gfp_t flags, unsigned int order)
-{
-	void *ret = kmalloc_order(size, flags, order);
-	trace_kmalloc(_RET_IP_, ret, size, PAGE_SIZE << order, flags);
-	return ret;
-}
-EXPORT_SYMBOL(kmalloc_order_trace);
 #endif
 
 #ifdef CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

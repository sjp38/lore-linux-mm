Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id A4FAB6B0037
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 13:12:53 -0400 (EDT)
Message-ID: <0000014035b7cac4-0f34cc54-f026-4654-9976-cee87e1fca98-000000@email.amazonses.com>
Date: Wed, 31 Jul 2013 17:12:52 +0000
From: Christoph Lameter <cl@linux.com>
Subject: [3.12 1/5] Move kmalloc_node functions to common code
References: <20130731171257.629155011@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

The kmalloc_node functions of all slab allcoators are similar now so
lets move them into slab.h. This requires some function naming changes
in slob.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2013-07-15 09:25:30.055679733 -0500
+++ linux/include/linux/slab.h	2013-07-15 09:38:34.633019260 -0500
@@ -289,6 +289,50 @@ static __always_inline int kmalloc_index
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
+
+#ifdef CONFIG_NUMA
+extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
+					   gfp_t gfpflags,
+					   int node, size_t size);
+#else
+static __always_inline void *
+kmem_cache_alloc_node_trace(struct kmem_cache *s,
+				gfp_t gfpflags,
+				int node, size_t size)
+{
+	return kmem_cache_alloc_trace(s, gfpflags, size);
+}
+#endif /* CONFIG_NUMA */
+
+#else
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
@@ -321,6 +365,23 @@ static __always_inline int kmalloc_size(
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
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2013-07-15 09:25:30.055679733 -0500
+++ linux/include/linux/slub_def.h	2013-07-15 09:37:59.000000000 -0500
@@ -104,9 +104,6 @@ struct kmem_cache {
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
 
-void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
-void *__kmalloc(size_t size, gfp_t flags);
-
 static __always_inline void *
 kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 {
@@ -174,38 +171,4 @@ static __always_inline void *kmalloc(siz
 	return __kmalloc(size, flags);
 }
 
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
--- linux.orig/include/linux/slab_def.h	2013-07-15 09:25:30.055679733 -0500
+++ linux/include/linux/slab_def.h	2013-07-15 09:37:59.000000000 -0500
@@ -102,9 +102,6 @@ struct kmem_cache {
 	 */
 };
 
-void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
-void *__kmalloc(size_t size, gfp_t flags);
-
 #ifdef CONFIG_TRACING
 extern void *kmem_cache_alloc_trace(struct kmem_cache *, gfp_t, size_t);
 #else
@@ -145,53 +142,4 @@ static __always_inline void *kmalloc(siz
 	return __kmalloc(size, flags);
 }
 
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
--- linux.orig/include/linux/slob_def.h	2013-07-15 09:25:30.055679733 -0500
+++ linux/include/linux/slob_def.h	2013-07-15 09:37:59.000000000 -0500
@@ -1,31 +1,9 @@
 #ifndef __LINUX_SLOB_DEF_H
 #define __LINUX_SLOB_DEF_H
 
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
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
 	return __kmalloc_node(size, flags, NUMA_NO_NODE);
 }
 
-static __always_inline void *__kmalloc(size_t size, gfp_t flags)
-{
-	return kmalloc(size, flags);
-}
-
 #endif /* __LINUX_SLOB_DEF_H */
Index: linux/mm/slob.c
===================================================================
--- linux.orig/mm/slob.c	2013-07-15 09:25:30.055679733 -0500
+++ linux/mm/slob.c	2013-07-15 09:25:30.051679666 -0500
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

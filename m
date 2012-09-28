Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id B3E106B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:23:56 -0400 (EDT)
Message-Id: <0000013a0e55c74b-04e82728-332d-48cb-be5c-95c769f5ba4d-000000@email.amazonses.com>
Date: Fri, 28 Sep 2012 19:23:55 +0000
From: Christoph Lameter <cl@linux.com>
Subject: CK2 [15/15] Move kmalloc_node functions to common code
References: <20120928191715.368450474@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

Kmalloc_node functions are rather similar now so lets move them
into slab.h.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h	2012-09-28 13:41:04.541431894 -0500
+++ linux/include/linux/slab.h	2012-09-28 13:41:14.677643504 -0500
@@ -262,6 +262,41 @@ static __always_inline int kmalloc_size(
 
 	return 0;
 }
+
+#ifdef CONFIG_NUMA
+void *__kmalloc_node(size_t size, gfp_t flags, int node);
+void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
+
+#ifdef CONFIG_TRACING
+extern void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
+					   gfp_t gfpflags,
+					   int node);
+#else
+static __always_inline void *
+kmem_cache_alloc_node_trace(struct kmem_cache *s,
+			      gfp_t gfpflags,
+			      int node)
+{
+	return kmem_cache_alloc_node(s, gfpflags, node);
+}
+#endif
+
+static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	if (__builtin_constant_p(size) &&
+		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & SLAB_CACHE_DMA)) {
+		int i = kmalloc_index(size);
+
+		if (!i)
+			return ZERO_SIZE_PTR;
+
+		return kmem_cache_alloc_node_trace(kmalloc_caches[i],
+			       			flags, node);
+	}
+	return __kmalloc_node(size, flags, node);
+}
+#endif
+
 #endif /* !CONFIG_SLOB */
 
 /*
Index: linux/include/linux/slub_def.h
===================================================================
--- linux.orig/include/linux/slub_def.h	2012-09-28 13:41:13.073610015 -0500
+++ linux/include/linux/slub_def.h	2012-09-28 13:41:14.677643504 -0500
@@ -200,37 +200,4 @@ static __always_inline void *kmalloc(siz
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
-		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & SLUB_DMA)) {
-			struct kmem_cache *s = kmalloc_slab_inline(size);
-
-		if (!s)
-			return ZERO_SIZE_PTR;
-
-		return kmem_cache_alloc_node_trace(s, flags, node, size);
-	}
-	return __kmalloc_node(size, flags, node);
-}
-#endif
-
 #endif /* _LINUX_SLUB_DEF_H */
Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c	2012-09-28 13:41:13.069609936 -0500
+++ linux/mm/slab.c	2012-09-28 13:41:14.677643504 -0500
@@ -3673,8 +3673,7 @@ void *kmem_cache_alloc_node(struct kmem_
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
 #ifdef CONFIG_TRACING
-void *kmem_cache_alloc_node_trace(size_t size,
-				  struct kmem_cache *cachep,
+void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
 				  gfp_t flags,
 				  int nodeid)
 {
@@ -3683,7 +3682,7 @@ void *kmem_cache_alloc_node_trace(size_t
 	ret = __cache_alloc_node(cachep, flags, nodeid,
 				  __builtin_return_address(0));
 	trace_kmalloc_node(_RET_IP_, ret,
-			   size, slab_buffer_size(cachep),
+			   s->size, slab_buffer_size(cachep),
 			   flags, nodeid);
 	return ret;
 }
@@ -3698,7 +3697,7 @@ __do_kmalloc_node(size_t size, gfp_t fla
 	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	return kmem_cache_alloc_node_trace(size, cachep, flags, node);
+	return kmem_cache_alloc_node_trace(cachep, flags, node);
 }
 
 #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
Index: linux/include/linux/slab_def.h
===================================================================
--- linux.orig/include/linux/slab_def.h	2012-09-28 13:41:00.493347386 -0500
+++ linux/include/linux/slab_def.h	2012-09-28 13:41:14.681643583 -0500
@@ -144,50 +144,4 @@ static __always_inline void *kmalloc(siz
 	return __kmalloc(size, flags);
 }
 
-#ifdef CONFIG_NUMA
-extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
-extern void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
-
-#ifdef CONFIG_TRACING
-extern void *kmem_cache_alloc_node_trace(size_t size,
-					 struct kmem_cache *cachep,
-					 gfp_t flags,
-					 int nodeid);
-#else
-static __always_inline void *
-kmem_cache_alloc_node_trace(size_t size,
-			    struct kmem_cache *cachep,
-			    gfp_t flags,
-			    int nodeid)
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
-		i = kmalloc_index(size);
-
-#ifdef CONFIG_ZONE_DMA
-		if (flags & GFP_DMA)
-			cachep = kmalloc_dma_caches[i];
-		else
-#endif
-			cachep = kmalloc_caches[i];
-
-		return kmem_cache_alloc_node_trace(size, cachep, flags, node);
-	}
-	return __kmalloc_node(size, flags, node);
-}
-
-#endif	/* CONFIG_NUMA */
-
 #endif	/* _LINUX_SLAB_DEF_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

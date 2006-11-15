Date: Wed, 15 Nov 2006 18:36:56 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/3] leak tracking for kmalloc_node
Message-ID: <20061115173656.GA18244@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, davem@davemloft.net
Cc: netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We have variants of kmalloc and kmem_cache_alloc that leave leak
tracking to the caller.  This is used for subsystem-specific allocators
like skb_alloc.

To make skb_alloc node-aware we need similar routines for the node-aware
slab allocator, which this patch adds.

Note that the code is rather ugly, but it mirrors the non-node-aware
code 1:1:

Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2006-10-23 17:20:14.000000000 +0200
+++ linux-2.6/include/linux/slab.h	2006-10-30 13:13:52.000000000 +0100
@@ -236,7 +236,25 @@
 	}
 	return __kmalloc_node(size, flags, node);
 }
+
+/*
+ * kmalloc_node_track_caller is a special version of kmalloc_node that
+ * records the calling function of the routine calling it for slab leak
+ * tracking instead of just the calling function (confusing, eh?).
+ * It's useful when the call to kmalloc_node comes from a widely-used
+ * standard allocator where we care about the real place the memory
+ * allocation request comes from.
+ */
+#ifndef CONFIG_DEBUG_SLAB
+#define kmalloc_node_track_caller(size, flags, node) \
+	__kmalloc_node(size, flags, node)
 #else
+extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, void *);
+#define kmalloc_node_track_caller(size, flags, node) \
+	__kmalloc_node_track_caller(size, flags, node, \
+			__builtin_return_address(0))
+#endif
+#else /* CONFIG_NUMA */
 static inline void *kmem_cache_alloc_node(kmem_cache_t *cachep, gfp_t flags, int node)
 {
 	return kmem_cache_alloc(cachep, flags);
@@ -245,6 +263,9 @@
 {
 	return kmalloc(size, flags);
 }
+
+#define kmalloc_node_track_caller(size, flags, node) \
+	kmalloc_track_caller(size, flags)
 #endif
 
 extern int FASTCALL(kmem_cache_reap(int));
@@ -283,6 +304,8 @@
 #define kzalloc(s, f) __kzalloc(s, f)
 #define kmalloc_track_caller kmalloc
 
+#define kmalloc_node_track_caller kmalloc_node
+
 #endif /* CONFIG_SLOB */
 
 /* System wide caches */
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2006-10-23 17:21:47.000000000 +0200
+++ linux-2.6/mm/slab.c	2006-10-30 13:14:20.000000000 +0100
@@ -996,7 +996,7 @@
 	return NULL;
 }
 
-static inline void *__cache_alloc_node(struct kmem_cache *cachep,
+static inline void *____cache_alloc_node(struct kmem_cache *cachep,
 		 gfp_t flags, int nodeid)
 {
 	return NULL;
@@ -1004,7 +1004,7 @@
 
 #else	/* CONFIG_NUMA */
 
-static void *__cache_alloc_node(struct kmem_cache *, gfp_t, int);
+static void *____cache_alloc_node(struct kmem_cache *, gfp_t, int);
 static void *alternate_node_alloc(struct kmem_cache *, gfp_t);
 
 static struct array_cache **alloc_alien_cache(int node, int limit)
@@ -3105,10 +3105,10 @@
 		objp = ____cache_alloc(cachep, flags);
 	/*
 	 * We may just have run out of memory on the local node.
-	 * __cache_alloc_node() knows how to locate memory on other nodes
+	 * ____cache_alloc_node() knows how to locate memory on other nodes
 	 */
  	if (NUMA_BUILD && !objp)
- 		objp = __cache_alloc_node(cachep, flags, numa_node_id());
+ 		objp = ____cache_alloc_node(cachep, flags, numa_node_id());
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp,
 					    caller);
@@ -3135,7 +3135,7 @@
 	else if (current->mempolicy)
 		nid_alloc = slab_node(current->mempolicy);
 	if (nid_alloc != nid_here)
-		return __cache_alloc_node(cachep, flags, nid_alloc);
+		return ____cache_alloc_node(cachep, flags, nid_alloc);
 	return NULL;
 }
 
@@ -3158,7 +3158,7 @@
 		if (zone_idx(*z) <= ZONE_NORMAL &&
 				cpuset_zone_allowed(*z, flags) &&
 				cache->nodelists[nid])
-			obj = __cache_alloc_node(cache,
+			obj = ____cache_alloc_node(cache,
 					flags | __GFP_THISNODE, nid);
 	}
 	return obj;
@@ -3167,7 +3167,7 @@
 /*
  * A interface to enable slab creation on nodeid
  */
-static void *__cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
+static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 				int nodeid)
 {
 	struct list_head *entry;
@@ -3440,7 +3440,9 @@
  * New and improved: it will now make sure that the object gets
  * put on the correct node list so that there is no false sharing.
  */
-void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
+static __always_inline void *
+__cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
+		int nodeid, void *caller)
 {
 	unsigned long save_flags;
 	void *ptr;
@@ -3452,17 +3454,22 @@
 			!cachep->nodelists[nodeid])
 		ptr = ____cache_alloc(cachep, flags);
 	else
-		ptr = __cache_alloc_node(cachep, flags, nodeid);
+		ptr = ____cache_alloc_node(cachep, flags, nodeid);
 	local_irq_restore(save_flags);
 
-	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr,
-					   __builtin_return_address(0));
+	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
 
 	return ptr;
 }
-EXPORT_SYMBOL(kmem_cache_alloc_node);
 
-void *__kmalloc_node(size_t size, gfp_t flags, int node)
+void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
+{
+	return __cache_alloc_node(cachep, flags, nodeid,
+			__builtin_return_address(0));
+}
+
+static __always_inline void *
+__do_kmalloc_node(size_t size, gfp_t flags, int node, void *caller)
 {
 	struct kmem_cache *cachep;
 
@@ -3471,8 +3478,29 @@
 		return NULL;
 	return kmem_cache_alloc_node(cachep, flags, node);
 }
+
+#ifdef CONFIG_DEBUG_SLAB
+void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __do_kmalloc_node(size, flags, node,
+			__builtin_return_address(0));
+}
 EXPORT_SYMBOL(__kmalloc_node);
-#endif
+
+void *__kmalloc_node_track_caller(size_t size, gfp_t flags,
+		int node, void *caller)
+{
+	return __do_kmalloc_node(size, flags, node, caller);
+}
+EXPORT_SYMBOL(__kmalloc_node_track_caller);
+#else
+void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __do_kmalloc_node(size, flags, node, NULL);
+}
+EXPORT_SYMBOL(__kmalloc_node);
+#endif /* CONFIG_DEBUG_SLAB */
+#endif /* CONFIG_NUMA */
 
 /**
  * __do_kmalloc - allocate memory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

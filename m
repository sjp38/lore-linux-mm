Date: Fri, 4 Aug 2006 17:15:54 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 3/3] slab: account leaks to caller version of kmalloc_node
Message-ID: <20060804151554.GC29422@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, viro@zeniv.linux.org.uk
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Implement a kmalloc_track_caller equivalent for kmalloc_node.  It's
needed for the the slab-aware alloc_skb patch that I posted to
linux-netdev to not break slab leak tracking.  The code is ugly but
that's because it's a cut & paste of the already ugly kmalloc version.

And no, that one can't be made much cleaner either without slowing
kmalloc down.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2006-08-03 18:03:42.000000000 +0200
+++ linux-2.6/include/linux/slab.h	2006-08-04 17:12:47.000000000 +0200
@@ -237,6 +237,25 @@
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
+#else
+extern void *__kmalloc_track_caller(size_t, gfp_t, void*);
+#define kmalloc_node_track_caller(size, flags, node) \
+	__kmalloc_node_track_caller(size, flags, node, \
+			__builtin_return_address(0))
+#endif
+
 #else
 static inline void *kmem_cache_alloc_node(kmem_cache_t *cachep, gfp_t flags, int node)
 {
@@ -246,7 +265,9 @@
 {
 	return kmalloc(size, flags);
 }
-#endif
+#define kmalloc_node_track_caller(size, flags, node) \
+	kmalloc_track_caller(size, flags)
+#endif /* CONFIG_NUMA */
 
 extern int FASTCALL(kmem_cache_reap(int));
 extern int FASTCALL(kmem_ptr_validate(kmem_cache_t *cachep, void *ptr));
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2006-08-03 18:03:42.000000000 +0200
+++ linux-2.6/mm/slab.c	2006-08-03 18:03:43.000000000 +0200
@@ -956,7 +956,7 @@
 }
 
 #ifdef CONFIG_NUMA
-static void *__cache_alloc_node(struct kmem_cache *, gfp_t, int);
+static void *____cache_alloc_node(struct kmem_cache *, gfp_t, int);
 static void *alternate_node_alloc(struct kmem_cache *, gfp_t);
 
 static struct array_cache **alloc_alien_cache(int node, int limit)
@@ -3025,14 +3025,14 @@
 	else if (current->mempolicy)
 		nid_alloc = slab_node(current->mempolicy);
 	if (nid_alloc != nid_here)
-		return __cache_alloc_node(cachep, flags, nid_alloc);
+		return ____cache_alloc_node(cachep, flags, nid_alloc);
 	return NULL;
 }
 
 /*
  * A interface to enable slab creation on nodeid
  */
-static void *__cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
+static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 				int nodeid)
 {
 	struct list_head *entry;
@@ -3295,7 +3295,9 @@
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
@@ -3307,17 +3309,23 @@
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
+
+void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
+{
+	return __cache_alloc_node(cachep, flags, nodeid,
+			__builtin_return_address(0));
+}
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
-void *__kmalloc_node(size_t size, gfp_t flags, int node)
+static __always_inline void *
+__do_kmalloc_node(size_t size, gfp_t flags, int node, void *caller)
 {
 	struct kmem_cache *cachep;
 
@@ -3326,8 +3334,29 @@
 		return NULL;
 	return kmem_cache_alloc_node(cachep, flags, node);
 }
-EXPORT_SYMBOL(kmalloc_node);
+
+#ifndef CONFIG_DEBUG_SLAB
+void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return __do_kmalloc_node(size, flags, node,
+			__builtin_return_address(0));
+}
+EXPORT_SYMBOL(__kmalloc_node);
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
 #endif
+#endif /* CONFIG_NUMA */
 
 /**
  * __do_kmalloc - allocate memory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

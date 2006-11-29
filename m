Date: Wed, 29 Nov 2006 15:01:59 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Slab: Fixup two issues in kmalloc_node / __cache_alloc_node
Message-ID: <Pine.LNX.4.64.0611291500190.17858@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This addresses two issues:

1. Kmalloc_node() may intermittently return NULL if
we are allocating from the current node and are unable to obtain
memory for the current node from the page allocator it. This is
because we call ___cache_alloc() if nodeid == numa_node_id() and
____cache_alloc is not able to fallback to other nodes.

This was introduced in the 2.6.19 development cycle. <= 2.6.18
in that case does not do a restricted allocation and blindly
trusts the page allocator to have given us memory from the
indicated node. It inserts the page regardless of the node it
came from into the queues for the current node.

2. If kmalloc_node() is used on a node that has not been bootstrapped
yet then we may try to pass an invalid node number to ____cache_alloc_node()
triggering a BUG().

Change the function to call fallback_alloc() instead. Only call
fallback_alloc() if we are allowed to fallback at all. The need
to handle a node not bootstrapped yet also first surfaced in the 2.6.19
cycle.

Update the comments since they were still describing the old kmalloc_node
from 2.6.12.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/mm/slab.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/mm/slab.c	2006-11-29 15:44:04.482245706 -0600
+++ linux-2.6.19-rc6-mm1/mm/slab.c	2006-11-29 15:57:49.773012380 -0600
@@ -3539,29 +3539,46 @@ out:
  * @flags: See kmalloc().
  * @nodeid: node number of the target node.
  *
- * Identical to kmem_cache_alloc, except that this function is slow
- * and can sleep. And it will allocate memory on the given node, which
- * can improve the performance for cpu bound structures.
- * New and improved: it will now make sure that the object gets
- * put on the correct node list so that there is no false sharing.
+ * Identical to kmem_cache_alloc but it will allocate memory on the given
+ * node, which can improve the performance for cpu bound structures.
+ *
+ * Fallback to other node is possible if __GFP_THISNODE is not set.
  */
 static __always_inline void *
 __cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 		int nodeid, void *caller)
 {
 	unsigned long save_flags;
-	void *ptr;
+	void *ptr = NULL;
 
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
 
-	if (nodeid == -1 || nodeid == numa_node_id() ||
-			!cachep->nodelists[nodeid])
-		ptr = ____cache_alloc(cachep, flags);
-	else
-		ptr = ____cache_alloc_node(cachep, flags, nodeid);
-	local_irq_restore(save_flags);
+	if (unlikely(nodeid == -1))
+		nodeid = numa_node_id();
+
+	if (likely(cachep->nodelists[nodeid])) {
+
+		if (nodeid == numa_node_id())
+			/*
+			 * Use the locally cached objects if possible.
+			 * However ____cache_alloc does not allow fallback
+			 * to other nodes. It may fail while we still have
+			 * objects on other nodes available.
+			 */
+			ptr = ____cache_alloc(cachep, flags);
+
+		if (!ptr)
+			/* ___cache_alloc_node can fall back to other nodes */
+			ptr = ____cache_alloc_node(cachep, flags, nodeid);
 
+	} else {
+		/* Node not bootstrapped yet */
+		if (!(flags & __GFP_THISNODE))
+			ptr = fallback_alloc(cachep, flags);
+	}
+
+	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
 
 	return ptr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

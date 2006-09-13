Date: Wed, 13 Sep 2006 16:50:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] GFP_THISNODE for the slab allocator
Message-ID: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch insures that the slab node lists in the NUMA case only contain
slabs that belong to that specific node. All slab allocations use
GFP_THISNODE when calling into the page allocator. If an allocation fails
then we fall back in the slab allocator according to the zonelists
appropriate for a certain context.

This allows a replication of the behavior of alloc_pages and alloc_pages
node in the slab layer.

Currently allocations requested from the page allocator may be redirected
via cpusets to other nodes. This results in remote pages on nodelists and
that in turn results in interrupt latency issues during cache draining.
Plus the slab is handing out memory as local when it is really remote.

Fallback for slab memory allocations will occur within the slab
allocator and not in the page allocator. This is necessary in order
to be able to use the existing pools of objects on the nodes that
we fall back to before adding more pages to a slab.

The fallback function insures that the nodes we fall back to obey
cpuset restrictions of the current context. We do not allocate
objects from outside of the current cpuset context like before.

Note that the implementation of locality constraints within the slab
allocator requires importing logic from the page allocator. This is a
mischmash that is not that great. Other allocators (uncached allocator,
vmalloc, huge pages) face similar problems and have similar minimal
reimplementations of the basic fallback logic of the page allocator.
There is another way of implementing a slab by avoiding per node lists
(see modular slab) but this wont work within the existing slab.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/mm/slab.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/slab.c	2006-09-13 18:04:57.000000000 -0500
+++ linux-2.6.18-rc6-mm2/mm/slab.c	2006-09-13 18:20:41.356901622 -0500
@@ -1566,6 +1566,14 @@ static void *kmem_getpages(struct kmem_c
 	 */
 	flags |= __GFP_COMP;
 #endif
+#ifdef CONFIG_NUMA
+	/*
+	 * Under NUMA we want memory on the indicated node. We will handle
+	 * the needed fallback ourselves since we want to serve from our
+	 * per node object lists first for other nodes.
+	 */
+	flags |= GFP_THISNODE;
+#endif
 	flags |= cachep->gfpflags;
 
 	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
@@ -3085,6 +3093,15 @@ static __always_inline void *__cache_all
 
 	objp = ____cache_alloc(cachep, flags);
 out:
+
+#ifdef CONFIG_NUMA
+	/*
+	 * We may just have run out of memory on the local know.
+	 * __cache_alloc_node knows how to locate memory on other nodes
+	 */
+ 	if (!objp)
+ 		objp = __cache_alloc_node(cachep, flags, numa_node_id());
+#endif
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp,
 					    caller);
@@ -3103,7 +3120,7 @@ static void *alternate_node_alloc(struct
 {
 	int nid_alloc, nid_here;
 
-	if (in_interrupt())
+	if (in_interrupt() || (flags & __GFP_THISNODE))
 		return NULL;
 	nid_alloc = nid_here = numa_node_id();
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
@@ -3116,6 +3133,28 @@ static void *alternate_node_alloc(struct
 }
 
 /*
+ * Fallback function if there was no memory available and no objects on a
+ * certain node and we are allowed to fall back. We mimick the behavior of
+ * the page allocator. We fall back according to a zonelist determined by
+ * the policy layer while obeying cpuset constraints.
+ */
+void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
+{
+	struct zonelist *zonelist = &NODE_DATA(slab_node(current->mempolicy))
+					->node_zonelists[gfp_zone(flags)];
+	struct zone **z;
+	void *obj = NULL;
+
+	for (z = zonelist->zones; *z && !obj; z++)
+		if (zone_idx(*z) <= ZONE_NORMAL &&
+				cpuset_zone_allowed(*z, flags))
+			obj = __cache_alloc_node(cache,
+					flags | __GFP_THISNODE,
+					zone_to_nid(*z));
+	return obj;
+}
+
+/*
  * A interface to enable slab creation on nodeid
  */
 static void *__cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
@@ -3168,11 +3207,15 @@ retry:
 must_grow:
 	spin_unlock(&l3->list_lock);
 	x = cache_grow(cachep, flags, nodeid);
+	if (x)
+		goto retry;
 
-	if (!x)
-		return NULL;
+	if (!(flags & __GFP_THISNODE))
+		/* Unable to grow the cache. Fall back to other nodes. */
+		return fallback_alloc(cachep, flags);
+
+	return NULL;
 
-	goto retry;
 done:
 	return obj;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

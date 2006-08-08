Date: Tue, 8 Aug 2006 09:56:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] Slab: Enforce clean node lists per zone, add policy support
 and fallback
Message-ID: <Pine.LNX.4.64.0608080951240.27620@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, kiran@scalex86.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

There are certainly issues for non-NUMA at this point and also we need to 
check how the slab behavior changes when memory gets low.


This patch insures that the slab node lists only contain slabs that
belong to that specific node. All slab allocations use __GFP_THISNODE
when calling into the page allocator. If an allocation fails then
we fall back in the slab allocator according to the zonelists
appropriate for a certain context.

Currently the allocations may be redirected via cpusets to other nodes. 
This results in remote pages on nodelists and that in turn results in 
interrupt latency issues during cache draining. Plus the slab is handing 
out memory as local when it is really remote.

Fallback for slab memory allocations therefore occurs within the slab
allocator and not in the page allocator. This is necessary in order
to be able to use the existing pools of objects on the nodes that
we fall back to before adding more pages to a slab.

The fallback function insures that the nodes we fall back to obey
cpuset restrictions of the current context. We do not allocate
slabs outside of the current cpuset context like before.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc3-mm2/mm/slab.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/mm/slab.c	2006-08-08 09:45:56.472181039 -0700
+++ linux-2.6.18-rc3-mm2/mm/slab.c	2006-08-08 09:47:43.582735013 -0700
@@ -2226,7 +2226,7 @@ kmem_cache_create (const char *name, siz
 	cachep->colour = left_over / cachep->colour_off;
 	cachep->slab_size = slab_size;
 	cachep->flags = flags;
-	cachep->gfpflags = 0;
+	cachep->gfpflags = __GFP_THISNODE | __GFP_NORETRY | __GFP_NOWARN;
 	if (flags & SLAB_CACHE_DMA)
 		cachep->gfpflags |= GFP_DMA;
 	cachep->buffer_size = size;
@@ -3049,6 +3049,11 @@ static __always_inline void *__cache_all
 
 	local_irq_save(save_flags);
 	objp = ____cache_alloc(cachep, flags);
+#ifdef CONFIG_NUMA
+	/* __cache_alloc_node knows how to locate memory on other nodes */
+	if (!objp)
+		objp = __cache_alloc_node(cachep, flags, numa_node_id());
+#endif
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp,
 					    caller);
@@ -3067,7 +3072,7 @@ static void *alternate_node_alloc(struct
 {
 	int nid_alloc, nid_here;
 
-	if (in_interrupt())
+	if (in_interrupt() || (flags & __GFP_THISNODE))
 		return NULL;
 	nid_alloc = nid_here = numa_node_id();
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
@@ -3083,6 +3088,27 @@ static void *alternate_node_alloc(struct
 }
 
 /*
+ * Fall back function if there was no memory availabel and no objects on a
+ * certain node and we are allowed to fall back. We mimick the behavior of
+ * the page allocator. We fall back according to a zonelist determined by
+ * the policy layer while obeying cpuset constraints.
+ */
+void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
+{
+	struct zonelist *zonelist = mpol_zonelist(flags, 0, NULL, 0);
+	struct zone **z;
+	void *obj = NULL;
+
+	for (z = zonelist->zones; *z && !obj; z++)
+		if (zone_idx(*z) == ZONE_NORMAL &&
+				cpuset_zone_allowed(*z, flags))
+			obj = __cache_alloc_node(cache,
+					flags | __GFP_THISNODE,
+					(*z)->zone_pgdat->node_id);
+	return obj;
+}
+
+/*
  * A interface to enable slab creation on nodeid
  */
 static void *__cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
@@ -3135,11 +3161,15 @@ retry:
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

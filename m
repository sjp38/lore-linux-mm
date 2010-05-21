Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D9A3F6B01B7
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:19:03 -0400 (EDT)
Message-Id: <20100521211544.756019063@quilx.com>
Date: Fri, 21 May 2010 16:15:05 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC V2 SLEB 13/14] SLEB: Enhanced NUMA support
References: <20100521211452.659982351@quilx.com>
Content-Disposition: inline; filename=sled_numa
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Before this patch all queues in SLEB may contain mixed objects (from any node).
This will continue even with this patch unless the SLAB has SLAB_MEM_SPREAD set.

For SLAB_MEM_SPREAD slabs an ordering by locality is enforced and objects are
managed per NUMA node (like SLAB). Cpu queues only contain
objects from the local node. Alien Objects (from non local nodes)
are freed into the shared cache of the remote node (avoids alien caches
but introduces cold cache objects into the shared cache).

This also adds object level NUMA functionality like in SLAB that can be
managed via cpusets or memory policies.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   70 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 70 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-05-20 16:57:14.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-05-20 16:57:37.000000000 -0500
@@ -1718,6 +1718,24 @@ void retrieve_objects(struct kmem_cache 
 	}
 }
 
+static inline int find_numa_node(struct kmem_cache *s, int selected_node)
+{
+#ifdef CONFIG_NUMA
+	if (s->flags & SLAB_MEM_SPREAD &&
+			!in_interrupt() &&
+			selected_node == SLAB_NODE_UNSPECIFIED) {
+
+		if (cpuset_do_slab_mem_spread())
+			return cpuset_mem_spread_node();
+
+		if (current->mempolicy)
+			return slab_node(current->mempolicy);
+	}
+#endif
+	return selected_node;
+}
+
+
 static void *slab_alloc(struct kmem_cache *s,
 		gfp_t gfpflags, int node, unsigned long addr)
 {
@@ -1732,6 +1750,7 @@ static void *slab_alloc(struct kmem_cach
 		return NULL;
 
 redo:
+	node = find_numa_node(s, node);
 	local_irq_save(flags);
 	c = __this_cpu_ptr(s->cpu_slab);
 	if (unlikely(!c->objects || !node_match(c, node))) {
@@ -1877,6 +1896,54 @@ void *kmem_cache_alloc_node_notrace(stru
 EXPORT_SYMBOL(kmem_cache_alloc_node_notrace);
 #endif
 
+int numa_off_node_free(struct kmem_cache *s, void *x)
+{
+#ifdef CONFIG_NUMA
+	if (s->flags & SLAB_MEM_SPREAD) {
+		int node = page_to_nid(virt_to_page(x));
+		/*
+		 * Slab requires object level control of locality. We can only
+		 * keep objects from the local node in the per cpu queue other
+		 * foreign object must not be freed to the queue.
+		 *
+		 * If we enconter a free of an off node object then we free
+		 * it to the shared cache of that node. This places a cache
+		 * cold object into that queue though. But using the queue
+		 * is much more effective than going directly into the slab.
+		 *
+		 * Alternate approach: Call drain_objects directly for a single
+		 * object. (Drain objects would have to be fixed to not save
+		 * to the local shared mem cache by default).
+		 */
+		if (node != numa_node_id()) {
+			struct kmem_cache_node *n = get_node(s, node);
+redo:
+			if (n->objects >= s->shared) {
+				int t = min(s->batch, n->objects);
+
+				drain_objects(s, n->object, t);
+
+				n->objects -= t;
+				if (n->objects)
+					memcpy(n->object, n->object + t,
+						n->objects * sizeof(void *));
+			}
+			spin_lock(&n->shared_lock);
+			if (n->objects < s->shared) {
+				n->object[n->objects++] = x;
+				x = NULL;
+			}
+			spin_unlock(&n->shared_lock);
+			if (x)
+				goto redo;
+			return 1;
+		}
+	}
+#endif
+	return 0;
+}
+
+
 static void slab_free(struct kmem_cache *s,
 			void *x, unsigned long addr)
 {
@@ -1895,6 +1962,9 @@ static void slab_free(struct kmem_cache 
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(object, s->objsize);
 
+	if (numa_off_node_free(s, x))
+		goto out;
+
 	if (unlikely(c->objects >= s->queue)) {
 
 		int t = min(s->batch, c->objects);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

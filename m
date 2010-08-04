Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9E4F1660026
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:35 -0400 (EDT)
Message-Id: <20100804024534.772679940@linux.com>
Date: Tue, 03 Aug 2010 21:45:33 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 19/23] slub: Object based NUMA policies
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=unified_object_based_policies
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Slub applies policies and cpuset restriction currently only on the page
level. The patch here changes that to apply policies to individual allocations
(like SLAB). This comes with a cost of increased complexiy in the allocator.

The allocation does not build alien queues (later patch) and is a bit
ineffective since a slab has to be taken from the partial lists (via lock
and unlock) and possibly shifted back after taking one object out of it.

Memory policies and cpuset redirection is only applied to slabs marked with
SLAB_MEM_SPREAD (also like SLAB).

Use Lee Schermerhorns new *_mem functionality to always find the nearest
node in case we are on a memoryless node.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |    3 +
 mm/slub.c                |   94 +++++++++++++++++++++++++++++++++++------------
 2 files changed, 73 insertions(+), 24 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-31 18:27:10.913898557 -0500
+++ linux-2.6/mm/slub.c	2010-07-31 18:27:15.733994218 -0500
@@ -1451,7 +1451,7 @@
 static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
 {
 	struct page *page;
-	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
+	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
 
 	page = get_partial_node(get_node(s, searchnode));
 	if (page || (flags & __GFP_THISNODE))
@@ -1622,6 +1622,7 @@
 		struct kmem_cache_cpu *c = per_cpu_ptr(k, cpu);
 
 		c->q.max = max;
+		c->node = cpu_to_mem(cpu);
 	}
 
 	s->cpu_queue = max;
@@ -1680,19 +1681,6 @@
 		free_percpu(f.c);
 }
 
-/*
- * Check if the objects in a per cpu structure fit numa
- * locality expectations.
- */
-static inline int node_match(struct kmem_cache_cpu *c, int node)
-{
-#ifdef CONFIG_NUMA
-	if (node != NUMA_NO_NODE && c->node != node)
-		return 0;
-#endif
-	return 1;
-}
-
 static unsigned long count_partial(struct kmem_cache_node *n,
 					int (*get_count)(struct page *))
 {
@@ -1752,6 +1740,26 @@
 }
 
 /*
+ * Determine the final numa node from which the allocation will
+ * be occurring. Allocations can be redirected for slabs marked
+ * with SLAB_MEM_SPREAD by memory policies and cpusets options.
+ */
+static inline int find_numa_node(struct kmem_cache *s, int node)
+{
+#ifdef CONFIG_NUMA
+	if (unlikely(s->flags & SLAB_MEM_SPREAD)) {
+		if (node == NUMA_NO_NODE && !in_interrupt()) {
+			if (cpuset_do_slab_mem_spread())
+				node = cpuset_mem_spread_node();
+			else if (current->mempolicy)
+				node = slab_node(current->mempolicy);
+		}
+	}
+#endif
+	return node;
+}
+
+/*
  * Retrieve pointers to nr objects from a slab into the object array.
  * Slab must be locked.
  */
@@ -1802,6 +1810,42 @@
 
 /* Handling of objects from other nodes */
 
+static void *slab_alloc_node(struct kmem_cache *s, struct kmem_cache_cpu *c,
+						gfp_t gfpflags, int node)
+{
+#ifdef CONFIG_NUMA
+	struct kmem_cache_node *n = get_node(s, node);
+	struct page *page;
+	void *object;
+
+	page = get_partial_node(n);
+	if (!page) {
+		gfpflags &= gfp_allowed_mask;
+
+		if (gfpflags & __GFP_WAIT)
+			local_irq_enable();
+
+		page = new_slab(s, gfpflags | GFP_THISNODE, node);
+
+		if (gfpflags & __GFP_WAIT)
+			local_irq_disable();
+
+ 		if (!page)
+			return NULL;
+
+		slab_lock(page);
+ 	}
+
+	retrieve_objects(s, page, &object, 1);
+
+	to_lists(s, page, 0);
+	slab_unlock(page);
+	return object;
+#else
+	return NULL;
+#endif
+}
+
 static void slab_free_alien(struct kmem_cache *s,
 	struct kmem_cache_cpu *c, struct page *page, void *object, int node)
 {
@@ -1827,13 +1871,20 @@
 redo:
 	local_irq_save(flags);
 	c = __this_cpu_ptr(s->cpu);
-	q = &c->q;
-	if (unlikely(queue_empty(q) || !node_match(c, node))) {
 
-		if (unlikely(!node_match(c, node))) {
-			flush_cpu_objects(s, c);
-			c->node = node;
+	node = find_numa_node(s, node);
+
+	if (NUMA_BUILD && node != NUMA_NO_NODE) {
+		if (unlikely(node != c->node)) {
+			object = slab_alloc_node(s, c, gfpflags, node);
+			if (!object)
+				goto oom;
+			stat(s, ALLOC_REMOTE);
+			goto got_it;
 		}
+	}
+	q = &c->q;
+	if (unlikely(queue_empty(q))) {
 
 		while (q->objects < s->batch) {
 			struct page *new;
@@ -1877,6 +1928,7 @@
 
 	object = queue_get(q);
 
+got_it:
 	if (kmem_cache_debug(s)) {
 		if (!alloc_debug_processing(s, object, addr))
 			goto redo;
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-07-31 18:26:09.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-07-31 18:27:15.733994218 -0500
@@ -23,6 +23,7 @@
 	FREE_REMOVE_PARTIAL,	/* Freeing removed from partial list */
 	ALLOC_FROM_PARTIAL,	/* slab with objects acquired from partial */
 	ALLOC_SLAB,		/* New slab acquired from page allocator */
+	ALLOC_REMOTE,		/* Allocation from remote slab */
 	FREE_ALIEN,		/* Free to alien node */
 	FREE_SLAB,		/* Slab freed to the page allocator */
 	QUEUE_FLUSH,		/* Flushing of the per cpu queue */
@@ -40,7 +41,7 @@
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
-	int node;		/* objects only from this numa node */
+	int node;		/* The memory node local to the cpu */
 	struct kmem_cache_queue q;
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

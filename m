Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 01AC060000B
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:02:39 -0400 (EDT)
Message-Id: <20100820190237.309997335@linux.com>
Date: Fri, 20 Aug 2010 14:01:57 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [S+Q Core 6/6] slub: Object based NUMA policies
References: <20100820190151.493325014@linux.com>
Content-Disposition: inline; filename=unified_object_based_policies
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
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

Note that the handling of queues is significantly different from SLAB.
SLAB has pure queues that only contain objects from the respective nodes
and therefore has to undergo fallback functions if nodes are exhausted.

The approach here has queues that usually contain objects from the
corresponding NUMA nodes. If nodes are exhausted then objects from
foreign nodes may appear in queues as the page allocator falls back
to other nodes. The foreign objects will be freed back to the
correct queues though so that these conditions are temporary.

The caching effect of the queues will degrade in situations when memory
on nodes is no longer available.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |   24 ++++-
 mm/slub.c                |  200 +++++++++++++++++------------------------------
 2 files changed, 93 insertions(+), 131 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-20 10:31:43.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-20 10:32:36.000000000 -0500
@@ -1140,10 +1140,7 @@ static inline struct page *alloc_slab_pa
 
 	flags |= __GFP_NOTRACK;
 
-	if (node == NUMA_NO_NODE)
-		return alloc_pages(flags, order);
-	else
-		return alloc_pages_exact_node(node, flags, order);
+	return alloc_pages_exact_node(node, flags, order);
 }
 
 static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
@@ -1360,14 +1357,15 @@ static inline int lock_and_freeze_slab(s
 /*
  * Try to allocate a partial slab from a specific node.
  */
-static struct page *get_partial_node(struct kmem_cache_node *n)
+static struct page *get_partial(struct kmem_cache *s, int node)
 {
 	struct page *page;
+	struct kmem_cache_node *n = get_node(s, node);
 
 	/*
 	 * Racy check. If we mistakenly see no partial slabs then we
 	 * just allocate an empty slab. If we mistakenly try to get a
-	 * partial slab and there is none available then get_partials()
+	 * partial slab and there is none available then get_partial()
 	 * will return NULL.
 	 */
 	if (!n || !n->nr_partial)
@@ -1384,76 +1382,6 @@ out:
 }
 
 /*
- * Get a page from somewhere. Search in increasing NUMA distances.
- */
-static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
-{
-#ifdef CONFIG_NUMA
-	struct zonelist *zonelist;
-	struct zoneref *z;
-	struct zone *zone;
-	enum zone_type high_zoneidx = gfp_zone(flags);
-	struct page *page;
-
-	/*
-	 * The defrag ratio allows a configuration of the tradeoffs between
-	 * inter node defragmentation and node local allocations. A lower
-	 * defrag_ratio increases the tendency to do local allocations
-	 * instead of attempting to obtain partial slabs from other nodes.
-	 *
-	 * If the defrag_ratio is set to 0 then kmalloc() always
-	 * returns node local objects. If the ratio is higher then kmalloc()
-	 * may return off node objects because partial slabs are obtained
-	 * from other nodes and filled up.
-	 *
-	 * If /sys/kernel/slab/xx/defrag_ratio is set to 100 (which makes
-	 * defrag_ratio = 1000) then every (well almost) allocation will
-	 * first attempt to defrag slab caches on other nodes. This means
-	 * scanning over all nodes to look for partial slabs which may be
-	 * expensive if we do it every time we are trying to find a slab
-	 * with available objects.
-	 */
-	if (!s->remote_node_defrag_ratio ||
-			get_cycles() % 1024 > s->remote_node_defrag_ratio)
-		return NULL;
-
-	get_mems_allowed();
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
-		struct kmem_cache_node *n;
-
-		n = get_node(s, zone_to_nid(zone));
-
-		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
-				n->nr_partial > s->min_partial) {
-			page = get_partial_node(n);
-			if (page) {
-				put_mems_allowed();
-				return page;
-			}
-		}
-	}
-	put_mems_allowed();
-#endif
-	return NULL;
-}
-
-/*
- * Get a partial page, lock it and return it.
- */
-static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
-{
-	struct page *page;
-	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
-
-	page = get_partial_node(get_node(s, searchnode));
-	if (page || node != -1)
-		return page;
-
-	return get_any_partial(s, flags);
-}
-
-/*
  * Move the vector of objects back to the slab pages they came from
  */
 void drain_objects(struct kmem_cache *s, void **object, int nr)
@@ -1617,6 +1545,7 @@ struct kmem_cache_cpu *alloc_kmem_cache_
 		struct kmem_cache_cpu *c = per_cpu_ptr(k, cpu);
 
 		c->q.max = max;
+		c->node = cpu_to_mem(cpu);
 	}
 
 	s->cpu_queue = max;
@@ -1675,19 +1604,6 @@ static void resize_cpu_queue(struct kmem
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
@@ -1747,6 +1663,27 @@ slab_out_of_memory(struct kmem_cache *s,
 }
 
 /*
+ * Determine the final numa node from which the allocation will
+ * be occurring. Allocations can be redirected for slabs marked
+ * with SLAB_MEM_SPREAD by memory policies and cpusets options.
+ */
+static inline int find_numa_node(struct kmem_cache *s,
+				 int node, int local_node)
+{
+#ifdef CONFIG_NUMA
+	if (unlikely(s->flags & SLAB_MEM_SPREAD)) {
+		if (node == NUMA_NO_NODE && !in_interrupt()) {
+			if (cpuset_do_slab_mem_spread())
+				return cpuset_mem_spread_node();
+			else if (current->mempolicy)
+				return slab_node(current->mempolicy);
+		}
+	}
+#endif
+	return local_node;
+}
+
+/*
  * Retrieve pointers to nr objects from a slab into the object array.
  * Slab must be locked.
  */
@@ -1797,6 +1734,41 @@ void to_lists(struct kmem_cache *s, stru
 
 /* Handling of objects from other nodes */
 
+static void *slab_alloc_node(struct kmem_cache *s, struct kmem_cache_cpu *c,
+						gfp_t gfpflags, int node)
+{
+#ifdef CONFIG_NUMA
+	struct page *page;
+	void *object;
+
+	page = get_partial(s, node);
+	if (!page) {
+		gfpflags &= gfp_allowed_mask;
+
+		if (gfpflags & __GFP_WAIT)
+			local_irq_enable();
+
+		page = new_slab(s, gfpflags, node);
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
@@ -1822,18 +1794,25 @@ static void *slab_alloc(struct kmem_cach
 redo:
 	local_irq_save(flags);
 	c = __this_cpu_ptr(s->cpu);
-	q = &c->q;
-	if (unlikely(queue_empty(q) || !node_match(c, node))) {
 
-		if (unlikely(!node_match(c, node))) {
-			flush_cpu_objects(s, c);
-			c->node = node;
+	if (NUMA_BUILD) {
+		node = find_numa_node(s, node, c->node);
+
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
 
-			new = get_partial(s, gfpflags & ~__GFP_ZERO, node);
+			new = get_partial(s, node);
 			if (unlikely(!new)) {
 
 				gfpflags &= gfp_allowed_mask;
@@ -1872,6 +1851,7 @@ redo:
 
 	object = queue_get(q);
 
+got_it:
 	if (kmem_cache_debug(s)) {
 		if (!alloc_debug_processing(s, object, addr))
 			goto redo;
@@ -2432,9 +2412,6 @@ static int kmem_cache_open(struct kmem_c
 	 */
 	set_min_partial(s, ilog2(s->size));
 	s->refcount = 1;
-#ifdef CONFIG_NUMA
-	s->remote_node_defrag_ratio = 1000;
-#endif
 	if (!init_kmem_cache_nodes(s))
 		goto error;
 
@@ -4305,30 +4282,6 @@ static ssize_t free_calls_show(struct km
 }
 SLAB_ATTR_RO(free_calls);
 
-#ifdef CONFIG_NUMA
-static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
-{
-	return sprintf(buf, "%d\n", s->remote_node_defrag_ratio / 10);
-}
-
-static ssize_t remote_node_defrag_ratio_store(struct kmem_cache *s,
-				const char *buf, size_t length)
-{
-	unsigned long ratio;
-	int err;
-
-	err = strict_strtoul(buf, 10, &ratio);
-	if (err)
-		return err;
-
-	if (ratio <= 100)
-		s->remote_node_defrag_ratio = ratio * 10;
-
-	return length;
-}
-SLAB_ATTR(remote_node_defrag_ratio);
-#endif
-
 #ifdef CONFIG_SLUB_STATS
 static int show_stat(struct kmem_cache *s, char *buf, enum stat_item si)
 {
@@ -4431,9 +4384,6 @@ static struct attribute *slab_attrs[] = 
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif
-#ifdef CONFIG_NUMA
-	&remote_node_defrag_ratio_attr.attr,
-#endif
 #ifdef CONFIG_SLUB_STATS
 	&alloc_fastpath_attr.attr,
 	&alloc_slowpath_attr.attr,
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-08-20 10:31:41.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-08-20 10:31:45.000000000 -0500
@@ -24,13 +24,29 @@ enum stat_item {
 	FREE_REMOVE_PARTIAL,	/* Freeing removed from partial list */
 	ALLOC_FROM_PARTIAL,	/* slab with objects acquired from partial */
 	ALLOC_SLAB,		/* New slab acquired from page allocator */
+	ALLOC_REMOTE,		/* Allocation from remote slab */
 	FREE_ALIEN,		/* Free to alien node */
 	FREE_SLAB,		/* Slab freed to the page allocator */
 	QUEUE_FLUSH,		/* Flushing of the per cpu queue */
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
 	NR_SLUB_STAT_ITEMS };
 
-/* Queueing structure used for per cpu, l3 cache and alien queueing */
+/*
+ * Queueing structure used for per cpu, l3 cache and alien queueing.
+ *
+ * Queues contain objects from a particular node.
+ *	Per cpu and shared queues from kmem_cache_cpu->node
+ *	alien caches from other nodes.
+ *
+ * However, this is not strictly enforced if the page allocator redirects
+ * allocation to other nodes because f.e. there is no memory on the node.
+ * Foreign objects will then be on the queue until memory becomes available
+ * again on the node. Freeing objects always occurs to the correct node.
+ *
+ * Which means that queueing is no longer effective since
+ * objects are freed to the alien caches after having been dequeued from
+ * the per cpu queue.
+ */
 struct kmem_cache_queue {
 	int objects;		/* Available objects */
 	int max;		/* Queue capacity */
@@ -41,7 +57,7 @@ struct kmem_cache_cpu {
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
-	int node;		/* objects only from this numa node */
+	int node;		/* The memory node local to the cpu */
 	struct kmem_cache_queue q;
 };
 
@@ -95,10 +111,6 @@ struct kmem_cache {
 #endif
 
 #ifdef CONFIG_NUMA
-	/*
-	 * Defragmentation by allocating from a remote node.
-	 */
-	int remote_node_defrag_ratio;
 	struct kmem_cache_node *node[MAX_NUMNODES];
 #else
 	/* Avoid an extra cache line for UP */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BB83A6B0092
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:58:28 -0400 (EDT)
Message-Id: <20101005185815.859324753@linux.com>
Date: Tue, 05 Oct 2010 13:57:32 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 07/16] slub: Object based NUMA policies
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=unified_object_based_policies
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
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
on some nodes is no longer available.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |   22 ++++
 mm/slub.c                |  208 ++++++++++++++++++-----------------------------
 2 files changed, 100 insertions(+), 130 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-04 08:26:09.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-04 08:26:27.000000000 -0500
@@ -1148,10 +1148,7 @@ static inline struct page *alloc_slab_pa
 
 	flags |= __GFP_NOTRACK;
 
-	if (node == NUMA_NO_NODE)
-		return alloc_pages(flags, order);
-	else
-		return alloc_pages_exact_node(node, flags, order);
+	return alloc_pages_exact_node(node, flags, order);
 }
 
 static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
@@ -1376,14 +1373,15 @@ static inline int lock_and_freeze_slab(s
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
@@ -1400,76 +1398,6 @@ out:
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
@@ -1650,6 +1578,7 @@ struct kmem_cache_cpu *alloc_kmem_cache_
 		struct kmem_cache_cpu *c = per_cpu_ptr(k, cpu);
 
 		c->q.max = max;
+		c->node = cpu_to_mem(cpu);
 	}
 
 	s->cpu_queue = max;
@@ -1710,19 +1639,6 @@ static void resize_cpu_queue(struct kmem
 }
 #endif
 
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
@@ -1782,6 +1698,30 @@ slab_out_of_memory(struct kmem_cache *s,
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
+
+			get_mems_allowed();
+			if (current->mempolicy)
+				local_node = slab_node(current->mempolicy);
+			put_mems_allowed();
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
@@ -1839,12 +1779,49 @@ void to_lists(struct kmem_cache *s, stru
 
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
+		if (!page)
+			return NULL;
+
+		slab_lock(page);
+	}
+
+	retrieve_objects(s, page, &object, 1);
+	stat(s, ALLOC_DIRECT);
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
 #ifdef CONFIG_NUMA
 	/* Direct free to the slab */
 	drain_objects(s, &object, 1);
+	stat(s, FREE_DIRECT);
 #endif
 }
 
@@ -1864,18 +1841,21 @@ static void *slab_alloc(struct kmem_cach
 redo:
 	local_irq_save(flags);
 	c = __this_cpu_ptr(s->cpu);
-	q = &c->q;
-	if (unlikely(queue_empty(q) || !node_match(c, node))) {
 
-		if (unlikely(!node_match(c, node))) {
-			flush_cpu_objects(s, c);
-			c->node = node;
-		}
+	node = find_numa_node(s, node, c->node);
+	if (unlikely(node != c->node)) {
+		object = slab_alloc_node(s, c, gfpflags, node);
+		if (!object)
+			goto oom;
+		goto got_it;
+	}
+	q = &c->q;
+	if (unlikely(queue_empty(q))) {
 
 		while (q->objects < s->batch) {
 			struct page *new;
 
-			new = get_partial(s, gfpflags & ~__GFP_ZERO, node);
+			new = get_partial(s, node);
 			if (unlikely(!new)) {
 
 				gfpflags &= gfp_allowed_mask;
@@ -1914,6 +1894,7 @@ redo:
 
 	object = queue_get(q);
 
+got_it:
 	if (kmem_cache_debug(s)) {
 		if (!alloc_debug_processing(s, object, addr))
 			goto redo;
@@ -1998,7 +1979,6 @@ static void slab_free(struct kmem_cache 
 
 		if (unlikely(node != c->node)) {
 			slab_free_alien(s, c, page, x, node);
-			stat(s, FREE_ALIEN);
 			goto out;
 		}
 	}
@@ -2462,9 +2442,6 @@ static int kmem_cache_open(struct kmem_c
 	 */
 	set_min_partial(s, ilog2(s->size));
 	s->refcount = 1;
-#ifdef CONFIG_NUMA
-	s->remote_node_defrag_ratio = 1000;
-#endif
 	if (!init_kmem_cache_nodes(s))
 		goto error;
 
@@ -4362,30 +4339,6 @@ static ssize_t shrink_store(struct kmem_
 }
 SLAB_ATTR(shrink);
 
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
@@ -4444,8 +4397,10 @@ static ssize_t text##_store(struct kmem_
 SLAB_ATTR(text);						\
 
 STAT_ATTR(ALLOC_FASTPATH, alloc_fastpath);
+STAT_ATTR(ALLOC_DIRECT, alloc_direct);
 STAT_ATTR(ALLOC_SLOWPATH, alloc_slowpath);
 STAT_ATTR(FREE_FASTPATH, free_fastpath);
+STAT_ATTR(FREE_DIRECT, free_direct);
 STAT_ATTR(FREE_SLOWPATH, free_slowpath);
 STAT_ATTR(FREE_ADD_PARTIAL, free_add_partial);
 STAT_ATTR(FREE_REMOVE_PARTIAL, free_remove_partial);
@@ -4490,13 +4445,12 @@ static struct attribute *slab_attrs[] = 
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif
-#ifdef CONFIG_NUMA
-	&remote_node_defrag_ratio_attr.attr,
-#endif
 #ifdef CONFIG_SLUB_STATS
 	&alloc_fastpath_attr.attr,
+	&alloc_direct_attr.attr,
 	&alloc_slowpath_attr.attr,
 	&free_fastpath_attr.attr,
+	&free_direct_attr.attr,
 	&free_slowpath_attr.attr,
 	&free_add_partial_attr.attr,
 	&free_remove_partial_attr.attr,
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-10-04 08:26:02.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-10-04 08:26:27.000000000 -0500
@@ -17,20 +17,36 @@
 
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu queue */
+	ALLOC_DIRECT,		/* Allocation bypassing queueing */
 	ALLOC_SLOWPATH,		/* Allocation required refilling of queue */
 	FREE_FASTPATH,		/* Free to cpu queue */
+	FREE_DIRECT,		/* Free bypassing queues */
 	FREE_SLOWPATH,		/* Required pushing objects out of the queue */
 	FREE_ADD_PARTIAL,	/* Freeing moved slab to partial list */
 	FREE_REMOVE_PARTIAL,	/* Freeing removed from partial list */
 	ALLOC_FROM_PARTIAL,	/* slab with objects acquired from partial */
 	ALLOC_SLAB,		/* New slab acquired from page allocator */
-	FREE_ALIEN,		/* Free to alien node */
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

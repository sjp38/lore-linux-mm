Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 96F6C6B0092
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:58:49 -0400 (EDT)
Message-Id: <20101005185817.624050513@linux.com>
Date: Tue, 05 Oct 2010 13:57:35 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 10/16] slub: Support Alien Caches
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=unified_alien_cache
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Alien caches are essential to track cachelines from a foreign node that are
present in a local cpu cache. They are therefore a form of the prior
introduced shared cache. Alien caches of the number of nodes minus one are
allocated for *each* lowest level shared cpu cache.

SLABs problem in this area is that the cpu caches are not properly tracked.
If there are multiple cpu caches on the same node then SLAB may not
properly track cache hotness of objects.

Alien caches are sizes differently than shared caches but are allocated
in the same contiguous memory area. The shared cache pointer is used
to reach the alien caches too. At positive offsets we fine shared cache
objects. At negative objects the alien caches are placed.

Alien caches can be switched off and configured on a cache by cache
basis using files in /sys/kernel/slab/<cache>/alien_queue_size.

Alien status is available in /sys/kernel/slab/<cache>/alien_caches.

/sys/kernel/slab/TCP$ cat alien_caches
9 C0,4,8,12,16,20,24,28=9[N1=3/30:N2=1/30:N3=5/30]
  C1,5,9,13,17,21,25,29=5[N0=1/30:N2=3/30:N3=1/30]
  C2,6,10,14,18,22,26,30=2[N0=0/30:N1=1/30:N3=1/30]
  C3,7,11,15,19,23,27,31=5[N0=2/30:N1=1/30:N2=2/30]

Alien caches are displayed for a 4 node machine for each of the l3 caching
domains. For each domain we have the foreign nodes listed with the number
of objects queued for each node within the l3 caching domain.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    6 
 mm/slub.c                |  403 ++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 387 insertions(+), 22 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-05 13:36:14.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-05 13:39:26.000000000 -0500
@@ -38,6 +38,9 @@
  * The slub_lock semaphore protects against configuration modifications like
  *   adding new queues, reconfiguring queues and removing queues.
  *
+ * Nesting:
+ *   The per node lock nests inside of the alien lock.
+ *
  *   Interrupts are disabled during allocation and deallocation in order to
  *   make the slab allocator safe to use in the context of an irq. In addition
  *   interrupts are disabled to ensure that the processor does not change
@@ -118,6 +121,16 @@ static inline int kmem_cache_debug(struc
 
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
+#define __ALIEN_CACHE		0x20000000UL /* Slab has alien caches */
+
+static inline int aliens(struct kmem_cache *s)
+{
+#ifdef CONFIG_NUMA
+	return (s->flags & __ALIEN_CACHE) != 0;
+#else
+	return 0;
+#endif
+}
 
 static int kmem_size = sizeof(struct kmem_cache);
 
@@ -1455,6 +1468,9 @@ static inline int drain_shared_cache(str
 	return n;
 }
 
+static void drain_alien_caches(struct kmem_cache *s,
+				struct kmem_cache_cpu *c);
+
 /*
  * Drain all objects from a per cpu queue
  */
@@ -1464,6 +1480,7 @@ static void flush_cpu_objects(struct kme
 
 	drain_queue(s, q, q->objects);
 	drain_shared_cache(s, q->shared);
+	drain_alien_caches(s, c);
 	stat(s, QUEUE_FLUSH);
 }
 
@@ -1539,6 +1556,13 @@ static inline void init_shared_cache(str
 	q->objects =0;
 }
 
+static inline void init_alien_cache(struct kmem_cache_queue *q, int max)
+{
+	spin_lock_init(&q->alien_lock);
+	q->max = max;
+	q->objects =0;
+}
+
 
 /* Determine a list of the active shared caches */
 struct kmem_cache_queue **shared_caches(struct kmem_cache *s)
@@ -1580,6 +1604,50 @@ struct kmem_cache_queue **shared_caches(
 	return caches;
 }
 
+/*
+ * Alien caches which are also shared caches
+ */
+
+#ifdef CONFIG_NUMA
+/* Given an allocation context determine the alien queue to use */
+static inline struct kmem_cache_queue *alien_cache(struct kmem_cache *s,
+		struct kmem_cache_cpu *c, int node)
+{
+	void *p = c->q.shared;
+
+	/* If the cache does not have any alien caches return NULL */
+	if (!aliens(s) || !p || node == c->node)
+		return NULL;
+
+	/*
+	 * Map [0..(c->node - 1)] -> [1..c->node].
+	 *
+	 * This effectively removes the current node (which is serviced by
+	 * the shared cachei) from the list and avoids hitting 0 (which would
+	 * result in accessing the shared queue used for the cpu cache).
+	 */
+	if (node < c->node)
+		node++;
+
+	p -= (node << s->alien_shift);
+
+	return (struct kmem_cache_queue *)p;
+}
+
+static inline void drain_alien_caches(struct kmem_cache *s,
+					 struct kmem_cache_cpu *c)
+{
+	int node;
+
+	for_each_node_state(node, N_NORMAL_MEMORY)
+		drain_shared_cache(s, alien_cache(s, c, node));
+}
+
+#else
+static inline void drain_alien_caches(struct kmem_cache *s,
+				 struct kmem_cache_cpu *c) {}
+#endif
+
 static struct kmem_cache *get_slab(size_t size, gfp_t flags);
 
 /* Map of cpus that have no siblings or where we have broken topolocy info */
@@ -1593,6 +1661,13 @@ struct kmem_cache_queue *alloc_shared_ca
 	int size;
 	void *p;
 	int cpu;
+	int alien_max = 0;
+	int alien_size = 0;
+
+	if (aliens(s)) {
+		alien_size = (nr_node_ids - 1) << s->alien_shift;
+		alien_max = shared_cache_capacity(1 << s->alien_shift);
+	}
 
 	/*
 	 * Determine the size. Round it up to the size that a kmalloc cache
@@ -1600,20 +1675,34 @@ struct kmem_cache_queue *alloc_shared_ca
 	 * power of 2 especially on machines that have large kmalloc
 	 * alignment requirements.
 	 */
-	size = shared_cache_size(s->shared_queue_sysfs);
-	if (size < PAGE_SIZE / 2)
+	size = shared_cache_size(s->shared_queue_sysfs) + alien_size;
+	if (size <= PAGE_SIZE / 2)
 		size = get_slab(size, GFP_KERNEL)->objsize;
 	else
 		size = PAGE_SIZE << get_order(size);
 
-	max = shared_cache_capacity(size);
+	max = shared_cache_capacity(size - alien_size);
 
 	/* Allocate shared cache */
 	p = kmalloc_node(size, GFP_KERNEL | __GFP_ZERO, node);
 	if (!p)
 		return NULL;
-	l = p;
+
+	l = p + alien_size;
 	init_shared_cache(l, max);
+#ifdef CONFIG_NUMA
+	/* And initialize the alien caches now */
+	if (aliens(s)) {
+		int node;
+
+		for (node = 0; node < nr_node_ids - 1; node++) {
+			struct kmem_cache_queue *a =
+				p + (node << s->alien_shift);
+
+			init_alien_cache(a, alien_max);
+		}
+	}
+#endif
 
 	/* Link all cpus in this group to the shared cache */
 	for_each_cpu(cpu, map)
@@ -1675,6 +1764,7 @@ static void __remove_shared_cache(void *
 
 	c->q.shared = NULL;
 	drain_shared_cache(s, q);
+	drain_alien_caches(s, c);
 }
 
 static int remove_shared_caches(struct kmem_cache *s)
@@ -1694,6 +1784,9 @@ static int remove_shared_caches(struct k
 	for(i = 0; i < s->nr_shared; i++) {
 		void *p = caches[i];
 
+		if (aliens(s))
+			p -= (nr_node_ids - 1) << s->alien_shift;
+
 		kfree(p);
 	}
 
@@ -1897,14 +1990,35 @@ static void *slab_alloc_node(struct kmem
 						gfp_t gfpflags, int node)
 {
 #ifdef CONFIG_NUMA
+	struct kmem_cache_queue *a = alien_cache(s, c, node);
 	struct page *page;
 	void *object;
 	struct kmem_cache_node *n = get_node(s, node);
 
+	if (a) {
+redo:
+		spin_lock(&a->lock);
+		if (likely(!queue_empty(a))) {
+			object = queue_get(a);
+			spin_unlock(&a->lock);
+			stat(s, ALLOC_ALIEN);
+			return object;
+		}
+	}
+
 	spin_lock(&n->lock);
-	if (list_empty(&n->partial)) {
+	if (!list_empty(&n->partial)) {
+
+		page = list_entry(n->partial.prev, struct page, lru);
+		stat(s, ALLOC_FROM_PARTIAL);
+
+	} else {
 
 		spin_unlock(&n->lock);
+
+		if (a)
+			spin_unlock(&a->lock);
+
 		gfpflags &= gfp_allowed_mask;
 
 		if (gfpflags & __GFP_WAIT)
@@ -1918,13 +2032,26 @@ static void *slab_alloc_node(struct kmem
 		if (!page)
 			return NULL;
 
+		if (a)
+			spin_lock(&a->lock);
+
+		/* Node and alien cache may have changed ! */
+		node = page_to_nid(page);
+		n = get_node(s, node);
+
 		spin_lock(&n->lock);
+		stat(s, ALLOC_SLAB);
+	}
 
-	} else
-		page = list_entry(n->partial.prev, struct page, lru);
+	if (a) {
 
-	retrieve_objects(s, page, &object, 1);
-	stat(s, ALLOC_DIRECT);
+		refill_queue(s, a, page, available(page));
+		spin_unlock(&a->lock);
+
+	} else {
+		retrieve_objects(s, page, &object, 1);
+		stat(s, ALLOC_DIRECT);
+	}
 
 	if (!all_objects_used(page)) {
 
@@ -1935,6 +2062,10 @@ static void *slab_alloc_node(struct kmem
 		partial_to_full(s, n, page);
 
 	spin_unlock(&n->lock);
+
+	if (a)
+		goto redo;
+
 	return object;
 #else
 	return NULL;
@@ -1945,9 +2076,29 @@ static void slab_free_alien(struct kmem_
 	struct kmem_cache_cpu *c, struct page *page, void *object, int node)
 {
 #ifdef CONFIG_NUMA
-	/* Direct free to the slab */
-	drain_objects(s, &object, 1);
-	stat(s, FREE_DIRECT);
+	struct kmem_cache_queue *a = alien_cache(s, c, node);
+
+	if (a) {
+		int slow = 0;
+
+		spin_lock(&a->lock);
+		while (unlikely(queue_full(a))) {
+			drain_queue(s, a, s->batch);
+			slow = 1;
+		}
+		queue_put(a, object);
+		spin_unlock(&a->lock);
+
+		if (slow)
+			stat(s, FREE_SLOWPATH);
+		else
+			stat(s, FREE_ALIEN);
+
+	} else {
+		/* Direct free to the slab */
+		drain_objects(s, &object, 1);
+		stat(s, FREE_DIRECT);
+	}
 #endif
 }
 
@@ -2038,12 +2189,13 @@ got_object:
 		if (all_objects_used(page))
 			partial_to_full(s, n, page);
 
-		stat(s, ALLOC_FROM_PARTIAL);
 	}
 	spin_unlock(&n->lock);
 
-	if (!queue_empty(q))
+	if (!queue_empty(q)) {
+		stat(s, ALLOC_FROM_PARTIAL);
 		goto get_object;
+	}
 
 	gfpflags &= gfp_allowed_mask;
 	/* Refill from free pages */
@@ -2294,7 +2446,6 @@ static inline int slab_order(int size, i
 			continue;
 
 		rem = slab_size % size;
-
 		if (rem <= slab_size / fract_leftover)
 			break;
 
@@ -2659,9 +2810,52 @@ static int kmem_cache_open(struct kmem_c
 	s->queue = initial_queue_size(s->size);
 	s->batch = (s->queue + 1) / 2;
 
+#ifdef CONFIG_NUMA
+	if (nr_node_ids > 1) {
+		/*
+		 * Alien cache configuration. The more NUMA nodes we have the
+		 * smaller the alien caches become since the penalties in terms
+		 * of space and latency increase. The user will have code for
+		 * locality on these boxes anyways since a large portion of
+		 * memory will be distant to the processor.
+		 *
+		 * A set of alien caches is allocated for each lowest level
+		 * cpu cache. The alien set covers all nodes except the node
+		 * that is nearest to the processor.
+		 *
+		 * Create large alien cache for small node configuration so
+		 * that these can work like shared caches do to preserve the
+		 * cpu cache hot state of objects.
+		 */
+		int lines = fls(ALIGN(shared_cache_size(s->queue),
+						cache_line_size()) -1);
+		int min = fls(cache_line_size() - 1);
+
+		/* Limit the sizes of the alien caches to some sane values */
+		if (nr_node_ids <= 4)
+			/*
+			 * Keep the sizes roughly the same as the shared cache
+			 * unless it gets too huge.
+			 */
+			s->alien_shift = min(PAGE_SHIFT - 1, lines);
+
+		else if (nr_node_ids <= 32)
+			/* Maximum of 4 cachelines */
+			s->alien_shift = min(2 + min, lines);
+		else
+			/* Clamp down to one cacheline */
+			s->alien_shift = min;
+
+		s->flags |= __ALIEN_CACHE;
+	}
+#endif
+
 	if (alloc_kmem_cache_cpus(s)) {
-		s->shared_queue_sysfs = s->queue;
-		alloc_shared_caches(s);
+		s->shared_queue_sysfs = 0;
+		if (nr_cpu_ids > 1 && s->size < PAGE_SIZE) {
+			s->shared_queue_sysfs = 10 * s->batch;
+			alloc_shared_caches(s);
+		}
 		return 1;
 	}
 
@@ -4295,14 +4489,12 @@ static ssize_t shared_queue_size_store(s
 	if (err)
 		return err;
 
-	if (queue > 10000 || queue < 4)
+	if (queue && (queue > 10000 || queue < 4 || queue < s->batch))
 		return -EINVAL;
 
 	down_write(&slub_lock);
 	err = remove_shared_caches(s);
 	if (!err) {
-		if (s->batch > queue)
-			s->batch = queue;
 
 		s->shared_queue_sysfs = queue;
 		if (queue)
@@ -4431,6 +4623,166 @@ static ssize_t objects_partial_show(stru
 }
 SLAB_ATTR_RO(objects_partial);
 
+#ifdef CONFIG_NUMA
+static ssize_t alien_queue_size_show(struct kmem_cache *s, char *buf)
+{
+	if (aliens(s))
+		return sprintf(buf, "%tu %u\n",
+			((1 << s->alien_shift)
+				- sizeof(struct kmem_cache_queue)) /
+				sizeof(void *), s->alien_shift);
+	else
+		return sprintf(buf, "0\n");
+}
+
+static ssize_t alien_queue_size_store(struct kmem_cache *s,
+			 const char *buf, size_t length)
+{
+	unsigned long queue;
+	int err;
+	int oldshift;
+
+	if (nr_node_ids == 1)
+		return -ENOSYS;
+
+	err = strict_strtoul(buf, 10, &queue);
+	if (err)
+		return err;
+
+	if (queue < 0 || queue > 1000)
+		return -EINVAL;
+
+	down_write(&slub_lock);
+	oldshift = s->alien_shift;
+
+	err = remove_shared_caches(s);
+	if (!err) {
+		if (queue == 0) {
+			s->flags &= ~__ALIEN_CACHE;
+			s->alien_shift = 0;
+		} else {
+			unsigned long size;
+
+			s->flags |= __ALIEN_CACHE;
+
+			size = max_t(unsigned long, cache_line_size(),
+				 sizeof(struct kmem_cache_queue)
+					+ queue * sizeof(void *));
+			size = ALIGN(size, cache_line_size());
+			s->alien_shift = fls(size + (size -1)) - 1;
+		}
+
+		if (oldshift != s->alien_shift)
+			alloc_shared_caches(s);
+	}
+
+	up_write(&slub_lock);
+	return err ? err : length;
+}
+SLAB_ATTR(alien_queue_size);
+
+static ssize_t alien_caches_show(struct kmem_cache *s, char *buf)
+{
+	unsigned long total;
+	int x;
+	int n;
+	int i;
+	int cpu, node;
+	struct kmem_cache_queue **caches;
+
+	if (!(s->flags & __ALIEN_CACHE) || s->alien_shift == 0)
+		return -ENOSYS;
+
+	down_read(&slub_lock);
+	caches = shared_caches(s);
+	if (!caches) {
+		up_read(&slub_lock);
+		return -ENOENT;
+	}
+
+	if (IS_ERR(caches)) {
+		up_read(&slub_lock);
+		return PTR_ERR(caches);
+	}
+
+	total = 0;
+	for (i = 0; i < s->nr_shared; i++) {
+		struct kmem_cache_queue *q = caches[i];
+
+		for (n = 1; n < nr_node_ids; n++) {
+			struct kmem_cache_queue *a =
+				(void *)q - (n << s->alien_shift);
+
+			total += a->objects;
+		}
+	}
+	x = sprintf(buf, "%lu", total);
+
+	for (n = 0; n < s->nr_shared; n++) {
+		struct kmem_cache_queue *q = caches[n];
+		struct kmem_cache_queue *a;
+		struct kmem_cache_cpu *c = NULL;
+		int first;
+
+		x += sprintf(buf + x, " C");
+		first = 1;
+		/* Find cpus using the shared cache */
+		for_each_online_cpu(cpu) {
+			struct kmem_cache_cpu *z = per_cpu_ptr(s->cpu, cpu);
+
+			if (q != z->q.shared)
+				continue;
+
+			if (z)
+				c = z;
+
+			if (first)
+				first = 0;
+			else
+				x += sprintf(buf + x, ",");
+
+			x += sprintf(buf + x, "%d", cpu);
+		}
+
+		if (!c) {
+			x += sprintf(buf +x, "=<none>");
+			continue;
+		}
+
+		/* The total of objects for a particular shared cache */
+		total = 0;
+		for_each_online_node(node) {
+			struct kmem_cache_queue *a =
+				alien_cache(s, c, node);
+
+			if (a)
+				total += a->objects;
+		}
+		x += sprintf(buf +x, "=%lu[", total);
+
+		first = 1;
+		for_each_online_node(node) {
+			a = alien_cache(s, c, node);
+
+			if (a) {
+				if (first)
+					first = 0;
+				else
+					x += sprintf(buf + x, ":");
+
+				x += sprintf(buf + x, "N%d=%d/%d",
+						node, a->objects, a->max);
+			}
+		}
+		x += sprintf(buf + x, "]");
+	}
+	up_read(&slub_lock);
+	kfree(caches);
+	return x + sprintf(buf + x, "\n");
+}
+SLAB_ATTR_RO(alien_caches);
+#endif
+
 static ssize_t reclaim_account_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%d\n", !!(s->flags & SLAB_RECLAIM_ACCOUNT));
@@ -4697,10 +5049,12 @@ SLAB_ATTR(text);						\
 
 STAT_ATTR(ALLOC_FASTPATH, alloc_fastpath);
 STAT_ATTR(ALLOC_SHARED, alloc_shared);
+STAT_ATTR(ALLOC_ALIEN, alloc_alien);
 STAT_ATTR(ALLOC_DIRECT, alloc_direct);
 STAT_ATTR(ALLOC_SLOWPATH, alloc_slowpath);
 STAT_ATTR(FREE_FASTPATH, free_fastpath);
 STAT_ATTR(FREE_SHARED, free_shared);
+STAT_ATTR(FREE_ALIEN, free_alien);
 STAT_ATTR(FREE_DIRECT, free_direct);
 STAT_ATTR(FREE_SLOWPATH, free_slowpath);
 STAT_ATTR(FREE_ADD_PARTIAL, free_add_partial);
@@ -4749,13 +5103,19 @@ static struct attribute *slab_attrs[] = 
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif
+#ifdef CONFIG_NUMA
+	&alien_caches_attr.attr,
+	&alien_queue_size_attr.attr,
+#endif
 #ifdef CONFIG_SLUB_STATS
 	&alloc_fastpath_attr.attr,
 	&alloc_shared_attr.attr,
+	&alloc_alien_attr.attr,
 	&alloc_direct_attr.attr,
 	&alloc_slowpath_attr.attr,
 	&free_fastpath_attr.attr,
 	&free_shared_attr.attr,
+	&free_alien_attr.attr,
 	&free_direct_attr.attr,
 	&free_slowpath_attr.attr,
 	&free_add_partial_attr.attr,
@@ -5108,7 +5468,8 @@ static int s_show(struct seq_file *m, vo
 	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d", s->name, nr_inuse,
 		   nr_objs, s->size, oo_objects(s->oo),
 		   (1 << oo_order(s->oo)));
-	seq_printf(m, " : tunables %4u %4u %4u", s->cpu_queue, s->batch, s->shared_queue);
+	seq_printf(m, " : tunables %4u %4u %4u", s->cpu_queue, s->batch,
+			(s->shared_queue + s->batch / 2 ) / s->batch);
 
 	seq_printf(m, " : slabdata %6lu %6lu %6lu", nr_slabs, nr_slabs,
 		   shared_objects(s));
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-10-05 13:36:14.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-10-05 13:36:33.000000000 -0500
@@ -18,11 +18,13 @@
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu queue */
 	ALLOC_SHARED,		/* Allocation caused a shared cache transaction */
+	ALLOC_ALIEN,		/* Allocation from alien cache */
 	ALLOC_DIRECT,		/* Allocation bypassing queueing */
 	ALLOC_SLOWPATH,		/* Allocation required refilling of queue */
 	FREE_FASTPATH,		/* Free to cpu queue */
 	FREE_SHARED,		/* Free caused a shared cache transaction */
 	FREE_DIRECT,		/* Free bypassing queues */
+	FREE_ALIEN,		/* Free to alien node */
 	FREE_SLOWPATH,		/* Required pushing objects out of the queue */
 	FREE_ADD_PARTIAL,	/* Freeing moved slab to partial list */
 	FREE_REMOVE_PARTIAL,	/* Freeing removed from partial list */
@@ -55,6 +57,7 @@ struct kmem_cache_queue {
 	union {
 		struct kmem_cache_queue *shared; /* cpu q -> shared q */
 		spinlock_t lock;	  /* shared queue: lock */
+		spinlock_t alien_lock;	/* alien cache lock */
 	};
 	void *object[];
 };
@@ -97,7 +100,8 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
 	struct kmem_cache_order_objects oo;
-	int batch;
+	int batch;		/* batch size */
+	int alien_shift;	/* Shift to size alien caches */
 
 	/* Allocation and freeing of slabs */
 	struct kmem_cache_order_objects max;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

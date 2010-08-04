Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 11FF6660030
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:39 -0400 (EDT)
Message-Id: <20100804024535.909930848@linux.com>
Date: Tue, 03 Aug 2010 21:45:35 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 21/23] slub: Support Alien Caches
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=unified_alien_cache
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
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

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    1 
 mm/slub.c                |  339 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 327 insertions(+), 13 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-03 15:58:51.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-03 15:58:53.000000000 -0500
@@ -31,8 +31,10 @@
 
 /*
  * Lock order:
- *   1. slab_lock(page)
- *   2. slab->list_lock
+ *
+ *   1. alien kmem_cache_cpu->lock lock
+ *   2. slab_lock(page)
+ *   3. kmem_cache_node->list_lock
  *
  *   The slab_lock protects operations on the object of a particular
  *   slab and its metadata in the page struct. If the slab lock
@@ -148,6 +150,16 @@ static inline int kmem_cache_debug(struc
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
 #define __SYSFS_ADD_DEFERRED	0x40000000UL /* Not yet visible via sysfs */
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
 
@@ -1587,6 +1599,9 @@ static inline int drain_shared_cache(str
 	return n;
 }
 
+static void drain_alien_caches(struct kmem_cache *s,
+				struct kmem_cache_cpu *c);
+
 /*
  * Drain all objects from a per cpu queue
  */
@@ -1596,6 +1611,7 @@ static void flush_cpu_objects(struct kme
 
 	drain_queue(s, q, q->objects);
 	drain_shared_cache(s, q->shared);
+	drain_alien_caches(s, c);
  	stat(s, QUEUE_FLUSH);
 }
 
@@ -1739,6 +1755,53 @@ struct kmem_cache_queue **shared_caches(
 }
 
 /*
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
+	for_each_node(node)
+		if (node != c->node);
+			drain_shared_cache(s, alien_cache(s, c, node));
+}
+
+#else
+static inline void drain_alien_caches(struct kmem_cache *s,
+				 struct kmem_cache_cpu *c) {}
+#endif
+
+static struct kmem_cache *get_slab(size_t size, gfp_t flags);
+
+/*
  * Allocate shared cpu caches.
  * A shared cache is allocated for each series of cpus sharing a single cache
  */
@@ -1748,23 +1811,30 @@ static void alloc_shared_caches(struct k
 	int max;
 	int size;
 	void *p;
+	int alien_max = 0;
+	int alien_size = 0;
 
 	if (slab_state < SYSFS || s->shared_queue_sysfs == 0)
 		return;
 
+	if (aliens(s)) {
+		alien_size = (nr_node_ids - 1) << s->alien_shift;
+		alien_max = shared_cache_capacity(1 << s->alien_shift);
+	}
+
 	/*
 	 * Determine the size. Round it up to the size that a kmalloc cache
 	 * supporting that size has. This will often align the size to a
 	 * power of 2 especially on machines that have large kmalloc
 	 * alignment requirements.
 	 */
-	size = shared_cache_size(s->shared_queue_sysfs);
+	size = shared_cache_size(s->shared_queue_sysfs) + alien_size;
 	if (size < PAGE_SIZE / 2)
 		size = get_slab(size, GFP_KERNEL)->objsize;
 	else
 		size = PAGE_SHIFT << get_order(size);
 
-	max = shared_cache_capacity(size);
+	max = shared_cache_capacity(size - alien_size);
 
 	for_each_online_cpu(cpu) {
 		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
@@ -1786,8 +1856,26 @@ static void alloc_shared_caches(struct k
 			continue;
 		}
 
-		l = p;
+		l = p + alien_size;
 		init_shared_cache(l, max);
+#ifdef CONFIG_NUMA
+		/* And initialize the alien caches now */
+		if (aliens(s)) {
+			int node;
+
+			for (node = 0; node < nr_node_ids - 1; node++) {
+				struct kmem_cache_queue *a =
+					p + (node << s->alien_shift);
+
+				init_shared_cache(a, alien_max);
+			}
+		}
+		if (cpumask_weight(map) < 2)  {
+			printk_once(KERN_WARNING "SLUB: Unusable processor"
+				" cache topology. Shared cache per numa node.\n");
+			map = cpumask_of_node(c->node);
+		}
+#endif
 
 		if (cpumask_weight(map) < 2) {
 
@@ -1827,6 +1915,7 @@ static void __remove_shared_cache(void *
 
 	c->q.shared = NULL;
 	drain_shared_cache(s, q);
+	drain_alien_caches(s, c);
 }
 
 
@@ -1845,6 +1934,9 @@ static int remove_shared_caches(struct k
 	for(i = 0; i < s->nr_shared; i++) {
 		void *p = caches[i];
 
+		if (aliens(s))
+			p -= (nr_node_ids - 1) << s->alien_shift;
+
 		kfree(p);
 	}
 
@@ -2039,11 +2131,23 @@ static void *slab_alloc_node(struct kmem
 						gfp_t gfpflags, int node)
 {
 #ifdef CONFIG_NUMA
-	struct kmem_cache_node *n = get_node(s, node);
+	struct kmem_cache_queue *a = alien_cache(s, c, node);
 	struct page *page;
 	void *object;
 
-	page = get_partial_node(n);
+	if (a) {
+redo:
+		spin_lock(&a->lock);
+		if (likely(!queue_empty(a))) {
+			object = queue_get(a);
+			spin_unlock(&a->lock);
+			return object;
+		}
+		spin_unlock(&a->lock);
+	}
+
+	/* Cross node allocation and lock taking ! */
+	page = get_partial_node(s->node[node]);
 	if (!page) {
 		gfpflags &= gfp_allowed_mask;
 
@@ -2061,10 +2165,19 @@ static void *slab_alloc_node(struct kmem
 		slab_lock(page);
  	}
 
-	retrieve_objects(s, page, &object, 1);
+	if (a) {
+		spin_lock(&a->lock);
+		refill_queue(s, a, page, available(page));
+		spin_unlock(&a->lock);
+	} else
+		retrieve_objects(s, page, &object, 1);
 
 	to_lists(s, page, 0);
 	slab_unlock(page);
+
+	if (a)
+		goto redo;
+
 	return object;
 #else
 	return NULL;
@@ -2075,8 +2188,17 @@ static void slab_free_alien(struct kmem_
 	struct kmem_cache_cpu *c, struct page *page, void *object, int node)
 {
 #ifdef CONFIG_NUMA
-	/* Direct free to the slab */
-	drain_objects(s, &object, 1);
+	struct kmem_cache_queue *a = alien_cache(s, c, node);
+
+	if (a) {
+		spin_lock(&a->lock);
+		while (unlikely(queue_full(a)))
+			drain_queue(s, a, s->batch);
+		queue_put(a, object);
+		spin_unlock(&a->lock);
+	} else
+		/* Direct free to the slab */
+		drain_objects(s, &object, 1);
 #endif
 }
 
@@ -2741,15 +2863,53 @@ static int kmem_cache_open(struct kmem_c
 	 */
 	set_min_partial(s, ilog2(s->size));
 	s->refcount = 1;
-#ifdef CONFIG_NUMA
-	s->remote_node_defrag_ratio = 1000;
-#endif
 	if (!init_kmem_cache_nodes(s))
 		goto error;
 
 	s->queue = initial_queue_size(s->size);
 	s->batch = (s->queue + 1) / 2;
 
+#ifdef CONFIG_NUMA
+	s->remote_node_defrag_ratio = 1000;
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
 		s->shared_queue_sysfs = s->queue;
 		alloc_shared_caches(s);
@@ -4745,6 +4905,157 @@ static ssize_t remote_node_defrag_ratio_
 	return length;
 }
 SLAB_ATTR(remote_node_defrag_ratio);
+
+static ssize_t alien_queue_size_show(struct kmem_cache *s, char *buf)
+{
+	if (aliens(s))
+		return sprintf(buf, "%lu %u\n",
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
+	oldshift = s->alien_shift;
+
+	err = strict_strtoul(buf, 10, &queue);
+	if (err)
+		return err;
+
+	if (queue < 0 && queue > 65535)
+		return -EINVAL;
+
+	if (queue == 0) {
+		s->flags &= ~__ALIEN_CACHE;
+		s->alien_shift = 0;
+	} else {
+		unsigned long size;
+
+		s->flags |= __ALIEN_CACHE;
+
+		size = max_t(unsigned long, cache_line_size(),
+			 sizeof(struct kmem_cache_queue)
+				+ queue * sizeof(void *));
+		size = ALIGN(size, cache_line_size());
+		s->alien_shift = fls(size + (size -1)) - 1;
+	}
+
+	if (oldshift != s->alien_shift) {
+		down_write(&slub_lock);
+		err = remove_shared_caches(s);
+		if (!err)
+			alloc_shared_caches(s);
+		up_write(&slub_lock);
+	}
+	return err ? err : length;
+}
+SLAB_ATTR(alien_queue_size);
+
+static ssize_t alien_caches_show(struct kmem_cache *s, char *buf)
+{
+	unsigned long total;
+	int x;
+	int n;
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
+		return -ENOMEM;
+	}
+
+	total = 0;
+	for (n = 0; n < s->nr_shared; n++) {
+		struct kmem_cache_queue *q = caches[n];
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
 #endif
 
 #ifdef CONFIG_SLUB_STATS
@@ -4854,6 +5165,8 @@ static struct attribute *slab_attrs[] = 
 #endif
 #ifdef CONFIG_NUMA
 	&remote_node_defrag_ratio_attr.attr,
+	&alien_caches_attr.attr,
+	&alien_queue_size_attr.attr,
 #endif
 #ifdef CONFIG_SLUB_STATS
 	&alloc_fastpath_attr.attr,
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-08-03 15:58:51.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-08-03 15:58:52.000000000 -0500
@@ -82,6 +82,7 @@ struct kmem_cache {
 	int objsize;		/* The size of an object without meta data */
 	struct kmem_cache_order_objects oo;
 	int batch;		/* batch size */
+	int alien_shift;	/* Shift to size alien caches */
 
 	/* Allocation and freeing of slabs */
 	struct kmem_cache_order_objects max;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

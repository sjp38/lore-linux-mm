Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 91C08660029
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:37 -0400 (EDT)
Message-Id: <20100804024535.338543724@linux.com>
Date: Tue, 03 Aug 2010 21:45:34 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 20/23] slub: Shared cache to exploit cross cpu caching abilities.
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=unified_shared_cache
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Strictly a performance enhancement by better tracking of objects
that are likely in the lowest cpu caches of processors.

SLAB uses one shared cache per NUMA node or one globally. However, that
is not satifactory for contemporary cpus. Those may have multiple
independent cpu caches per node. SLAB in these situation treats
cache cold objects like cache hot objects.

The shared caches of slub are per physical cpu cache for all cpus using
that cache. Shared cache content will not cross physical caches.

The shared cache can be dynamically configured via
/sys/kernel/slab/<cache>/shared_queue

The current shared cache state is available via
cat /sys/kernel/slab/<cache/<shared_caches>

Shared caches are always allocated in the sizes available in the kmalloc
array. Cache sizes are rounded up to the sizes available.

F.e. on my Dell with 8 cpus in 2 packages in which each 2 cpus shared
an l2 cache I get:

christoph@:/sys/kernel/slab$ cat kmalloc-64/shared_caches
384 C0,2=66/126 C1,3=126/126 C4,6=126/126 C5,7=66/126
christoph@:/sys/kernel/slab$ cat kmalloc-64/per_cpu_caches
617 C0=54/125 C1=37/125 C2=102/125 C3=76/125 C4=81/125 C5=108/125 C6=72/125 C7=87/125

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    9 +
 mm/slub.c                |  423 ++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 405 insertions(+), 27 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-08-03 13:04:49.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-08-03 15:52:01.000000000 -0500
@@ -24,6 +24,8 @@ enum stat_item {
 	ALLOC_FROM_PARTIAL,	/* slab with objects acquired from partial */
 	ALLOC_SLAB,		/* New slab acquired from page allocator */
 	ALLOC_REMOTE,		/* Allocation from remote slab */
+	ALLOC_SHARED,		/* Allocation caused a shared cache transaction */
+	FREE_SHARED,		/* Free caused a shared cache transaction */
 	FREE_ALIEN,		/* Free to alien node */
 	FREE_SLAB,		/* Slab freed to the page allocator */
 	QUEUE_FLUSH,		/* Flushing of the per cpu queue */
@@ -34,6 +36,10 @@ enum stat_item {
 struct kmem_cache_queue {
 	int objects;		/* Available objects */
 	int max;		/* Queue capacity */
+	union {
+		struct kmem_cache_queue *shared; /* cpu q -> shared q */
+		spinlock_t lock;	  /* shared queue: lock */
+	};
 	void *object[];
 };
 
@@ -87,12 +93,15 @@ struct kmem_cache {
 	int align;		/* Alignment */
 	int queue;		/* specified queue size */
 	int cpu_queue;		/* cpu queue size */
+	int shared_queue;	/* Actual shared queue size */
+	int nr_shared;		/* Total # of shared caches */
 	unsigned long min_partial;
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
 #ifdef CONFIG_SLUB_DEBUG
 	struct kobject kobj;	/* For sysfs */
 #endif
+	int shared_queue_sysfs;	/* Desired shared queue size */
 
 #ifdef CONFIG_NUMA
 	/*
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-08-03 13:04:49.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-08-03 15:52:01.000000000 -0500
@@ -1556,7 +1556,8 @@ void drain_objects(struct kmem_cache *s,
 	}
 }
 
-static inline void drain_queue(struct kmem_cache *s, struct kmem_cache_queue *q, int nr)
+static inline int drain_queue(struct kmem_cache *s,
+		struct kmem_cache_queue *q, int nr)
 {
 	int t = min(nr, q->objects);
 
@@ -1566,13 +1567,35 @@ static inline void drain_queue(struct km
 	if (q->objects)
 		memcpy(q->object, q->object + t,
 					q->objects * sizeof(void *));
+	return t;
 }
+
+static inline int drain_shared_cache(struct kmem_cache *s,
+				 struct kmem_cache_queue *q)
+{
+	int n = 0;
+
+	if (!q)
+		return n;
+
+	if (!queue_empty(q)) {
+		spin_lock(&q->lock);
+		if (q->objects)
+			n = drain_queue(s, q, q->objects);
+		spin_unlock(&q->lock);
+	}
+	return n;
+}
+
 /*
  * Drain all objects from a per cpu queue
  */
 static void flush_cpu_objects(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
-	drain_queue(s, &c->q, c->q.objects);
+	struct kmem_cache_queue *q = &c->q;
+
+	drain_queue(s, q, q->objects);
+	drain_shared_cache(s, q->shared);
  	stat(s, QUEUE_FLUSH);
 }
 
@@ -1629,6 +1652,207 @@ struct kmem_cache_cpu *alloc_kmem_cache_
 	return k;
 }
 
+/* Shared cache management */
+
+static inline int get_shared_objects(struct kmem_cache_queue *q,
+		void **l, int nr)
+{
+	int d;
+
+	spin_lock(&q->lock);
+	d = min(nr, q->objects);
+	q->objects -= d;
+	memcpy(l, q->object + q->objects, d * sizeof(void *));
+	spin_unlock(&q->lock);
+
+	return d;
+}
+
+static inline int put_shared_objects(struct kmem_cache_queue *q,
+				void **l, int nr)
+{
+	int d;
+
+	spin_lock(&q->lock);
+	d = min(nr, q->max - q->objects);
+	memcpy(q->object + q->objects, l,  d * sizeof(void *));
+	q->objects += d;
+	spin_unlock(&q->lock);
+
+	return d;
+}
+
+static struct kmem_cache *get_slab(size_t size, gfp_t flags);
+
+static inline unsigned long shared_cache_size(int n)
+{
+	return n * sizeof(void *) + sizeof(struct kmem_cache_queue);
+}
+
+static inline unsigned long shared_cache_capacity(unsigned long size)
+{
+	return (size - sizeof(struct kmem_cache_queue)) / sizeof(void *);
+}
+
+static inline void init_shared_cache(struct kmem_cache_queue *q, int max)
+{
+	q->max = max;
+	spin_lock_init(&q->lock);
+}
+
+
+/* Determine a list of the active shared caches */
+struct kmem_cache_queue **shared_caches(struct kmem_cache *s)
+{
+	int cpu;
+	struct kmem_cache_queue **caches;
+	int nr;
+	int n;
+
+	caches = kmalloc(sizeof(struct kmem_cache_queue *)
+				* (s->nr_shared + 1), GFP_KERNEL);
+	if (!caches)
+		return NULL;
+
+	nr = 0;
+
+	/* Build list of shared caches */
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
+		struct kmem_cache_queue *q = c->q.shared;
+
+		if (!q)
+			continue;
+
+		for (n = 0; n < nr; n++)
+			if (caches[n] == q)
+				break;
+
+		if (n < nr)
+			continue;
+
+		caches[nr++] = q;
+	}
+	caches[nr] = NULL;
+	BUG_ON(nr != s->nr_shared);
+	return caches;
+}
+
+/*
+ * Allocate shared cpu caches.
+ * A shared cache is allocated for each series of cpus sharing a single cache
+ */
+static void alloc_shared_caches(struct kmem_cache *s)
+{
+	int cpu;
+	int max;
+	int size;
+	void *p;
+
+	if (slab_state < SYSFS || s->shared_queue_sysfs == 0)
+		return;
+
+	/*
+	 * Determine the size. Round it up to the size that a kmalloc cache
+	 * supporting that size has. This will often align the size to a
+	 * power of 2 especially on machines that have large kmalloc
+	 * alignment requirements.
+	 */
+	size = shared_cache_size(s->shared_queue_sysfs);
+	if (size < PAGE_SIZE / 2)
+		size = get_slab(size, GFP_KERNEL)->objsize;
+	else
+		size = PAGE_SHIFT << get_order(size);
+
+	max = shared_cache_capacity(size);
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
+		struct kmem_cache_queue *l;
+		int x;
+		const struct cpumask *map =
+				per_cpu(cpu_info.llc_shared_map, cpu) ;
+
+		/* Skip cpus that already have assigned shared caches */
+		if (c->q.shared)
+			continue;
+
+		/* Allocate shared cache */
+		p = kmalloc_node(size, GFP_KERNEL | __GFP_ZERO, c->node);
+		if (!p) {
+			printk(KERN_WARNING "SLUB: Out of memory allocating"
+				" shared cache for %s cpu %d node %d\n",
+				s->name, cpu, c->node);
+			continue;
+		}
+
+		l = p;
+		init_shared_cache(l, max);
+
+		if (cpumask_weight(map) < 2) {
+
+			/*
+			 * No information available on how to setup the shared
+			 * caches. Cpu will not have shared or alien caches.
+			 */
+			printk_once(KERN_WARNING "SLUB: Cache topology"
+				" information unusable. No shared caches\n");
+
+			kfree(p);
+			continue;
+		}
+
+		/* Link all cpus in this group to the shared cache */
+		for_each_cpu(x, map) {
+			struct kmem_cache_cpu *z = per_cpu_ptr(s->cpu, x);
+
+			if (z->node == c->node)
+				z->q.shared = l;
+		}
+		s->nr_shared++;
+	}
+	s->shared_queue = max;
+}
+
+/*
+ * Flush shared caches.
+ *
+ * Called from IPI handler with interrupts disabled.
+ */
+static void __remove_shared_cache(void *d)
+{
+	struct kmem_cache *s = d;
+	struct kmem_cache_cpu *c = __this_cpu_ptr(s->cpu);
+	struct kmem_cache_queue *q = c->q.shared;
+
+	c->q.shared = NULL;
+	drain_shared_cache(s, q);
+}
+
+
+static int remove_shared_caches(struct kmem_cache *s)
+{
+	struct kmem_cache_queue **caches;
+	int i;
+
+	caches = shared_caches(s);
+	if (!caches)
+		return -ENOMEM;
+
+	/* Go through a transaction on each cpu removing the pointers to the shared caches */
+	on_each_cpu(__remove_shared_cache, s, 1);
+
+	for(i = 0; i < s->nr_shared; i++) {
+		void *p = caches[i];
+
+		kfree(p);
+	}
+
+	kfree(caches);
+	s->nr_shared = 0;
+	s->shared_queue = 0;
+	return 0;
+}
 
 static void resize_cpu_queue(struct kmem_cache *s, int queue)
 {
@@ -1792,8 +2016,9 @@ static inline void refill_queue(struct k
 		struct kmem_cache_queue *q, struct page *page, int nr)
 {
 	int d;
+	int batch = min_t(int, q->max, s->batch);
 
-	d = min(s->batch - q->objects, nr);
+	d = min(batch - q->objects, nr);
 	retrieve_objects(s, page, q->object + q->objects, d);
 	q->objects += d;
 }
@@ -1886,6 +2111,20 @@ redo:
 	q = &c->q;
 	if (unlikely(queue_empty(q))) {
 
+		struct kmem_cache_queue *l = q->shared;
+
+		if (l && !queue_empty(l)) {
+
+			/*
+			 * Refill the cpu queue with the hottest objects
+			 * from the shared cache queue
+			 */
+			q->objects = get_shared_objects(l,
+						q->object, s->batch);
+			stat(s, ALLOC_SHARED);
+
+		}
+		else
 		while (q->objects < s->batch) {
 			struct page *new;
 
@@ -2022,9 +2261,22 @@ static void slab_free(struct kmem_cache 
 
 	if (unlikely(queue_full(q))) {
 
-		drain_queue(s, q, s->batch);
-		stat(s, FREE_SLOWPATH);
+		struct kmem_cache_queue *l = q->shared;
 
+		/* Shared queue available and has space ? */
+		if (l && !queue_full(l)) {
+			/* Push coldest objects into the shared queue */
+			int d = put_shared_objects(l, q->object, s->batch);
+
+			q->objects -=  d;
+			memcpy(q->object, q->object + d,
+					q->objects  * sizeof(void *));
+			stat(s, FREE_SHARED);
+		}
+		if (queue_full(q))
+			drain_queue(s, q, s->batch);
+
+		stat(s, FREE_SLOWPATH);
 	} else
 		stat(s, FREE_FASTPATH);
 
@@ -2498,8 +2750,11 @@ static int kmem_cache_open(struct kmem_c
 	s->queue = initial_queue_size(s->size);
 	s->batch = (s->queue + 1) / 2;
 
-	if (alloc_kmem_cache_cpus(s))
+	if (alloc_kmem_cache_cpus(s)) {
+		s->shared_queue_sysfs = s->queue;
+		alloc_shared_caches(s);
 		return 1;
+	}
 
 	free_kmem_cache_nodes(s);
 error:
@@ -3270,12 +3525,21 @@ void __init kmem_cache_init(void)
 	/* Now the kmalloc array is fully functional (*not* the dma array) */
 	slab_state = UP;
 
-	/* Provide the correct kmalloc names now that the caches are up */
-	for (i = KMALLOC_SHIFT_LOW; i < SLUB_PAGE_SHIFT; i++) {
-		char *s = kasprintf(GFP_NOWAIT, "kmalloc-%d", 1 << i);
+	/*
+	 * Provide the correct kmalloc names and enable the shared caches
+	 * now that the kmalloc array is functional
+	 */
+	for (i = 0; i < SLUB_PAGE_SHIFT; i++) {
+		struct kmem_cache *s = kmalloc_caches[i];
 
-		BUG_ON(!s);
-		kmalloc_caches[i]->name = s;
+		if (!s)
+			continue;
+
+		if (strcmp(s->name, "kmalloc") == 0)
+			s->name = kasprintf(GFP_NOWAIT,
+				"kmalloc-%d", s->objsize);
+
+		BUG_ON(!s->name);
 	}
 
 #ifdef CONFIG_SMP
@@ -3298,6 +3562,9 @@ void __init kmem_cache_init_late(void)
 
 			create_kmalloc_cache(&kmalloc_dma_caches[i],
 				name, s->objsize, SLAB_CACHE_DMA);
+
+			/* DMA caches are rarely used. Reduce memory consumption */
+			kmalloc_dma_caches[i]->shared_queue_sysfs = 0;
 		}
 	}
 #endif
@@ -4047,10 +4314,40 @@ static ssize_t min_partial_store(struct 
 }
 SLAB_ATTR(min_partial);
 
-static ssize_t cpu_queue_size_show(struct kmem_cache *s, char *buf)
+static ssize_t queue_size_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%u\n", s->queue);
 }
+SLAB_ATTR_RO(queue_size);
+
+
+static ssize_t batch_size_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%u\n", s->batch);
+}
+
+static ssize_t batch_size_store(struct kmem_cache *s,
+			 const char *buf, size_t length)
+{
+	unsigned long batch;
+	int err;
+
+	err = strict_strtoul(buf, 10, &batch);
+	if (err)
+		return err;
+
+	if (batch < s->queue || batch < 4)
+		return -EINVAL;
+
+	s->batch = batch;
+	return length;
+}
+SLAB_ATTR(batch_size);
+
+static ssize_t cpu_queue_size_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%u\n", s->cpu_queue);
+}
 
 static ssize_t cpu_queue_size_store(struct kmem_cache *s,
 			 const char *buf, size_t length)
@@ -4075,28 +4372,82 @@ static ssize_t cpu_queue_size_store(stru
 }
 SLAB_ATTR(cpu_queue_size);
 
-static ssize_t cpu_batch_size_show(struct kmem_cache *s, char *buf)
+static ssize_t shared_queue_size_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%u\n", s->batch);
+	return sprintf(buf, "%u %u\n", s->shared_queue, s->shared_queue_sysfs);
 }
 
-static ssize_t cpu_batch_size_store(struct kmem_cache *s,
+static ssize_t shared_queue_size_store(struct kmem_cache *s,
 			 const char *buf, size_t length)
 {
-	unsigned long batch;
+	unsigned long queue;
 	int err;
 
-	err = strict_strtoul(buf, 10, &batch);
+	err = strict_strtoul(buf, 10, &queue);
 	if (err)
 		return err;
 
-	if (batch < s->queue || batch < 4)
+	if (queue > 10000 || queue < 4)
 		return -EINVAL;
 
-	s->batch = batch;
-	return length;
+	if (s->batch > queue)
+		s->batch = queue;
+
+	down_write(&slub_lock);
+	s->shared_queue_sysfs = queue;
+	err = remove_shared_caches(s);
+	if (!err)
+		alloc_shared_caches(s);
+	up_write(&slub_lock);
+	return err ? err : length;
+}
+SLAB_ATTR(shared_queue_size);
+
+static ssize_t shared_caches_show(struct kmem_cache *s, char *buf)
+{
+	unsigned long total = 0;
+	int x, n;
+	int cpu;
+	struct kmem_cache_queue **caches;
+
+	down_read(&slub_lock);
+	caches = shared_caches(s);
+	if (!caches) {
+		up_read(&slub_lock);
+		return -ENOMEM;
+	}
+
+	for (n = 0; n < s->nr_shared; n++)
+		total += caches[n]->objects;
+
+	x = sprintf(buf, "%lu", total);
+
+	for (n = 0; n < s->nr_shared; n++) {
+		int first = 1;
+		struct kmem_cache_queue *q = caches[n];
+
+		x += sprintf(buf + x, " C");
+
+		/* Find cpus using the shared cache */
+		for_each_online_cpu(cpu) {
+			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
+
+			if (q != c->q.shared)
+				continue;
+
+			if (first)
+				first = 0;
+			else
+				x += sprintf(buf + x, ",");
+			x += sprintf(buf + x, "%d", cpu);
+		}
+		x += sprintf(buf +x, "=%d/%d", q->objects, q->max);
+	}
+	up_read(&slub_lock);
+	kfree(caches);
+	return x + sprintf(buf + x, "\n");
 }
-SLAB_ATTR(cpu_batch_size);
+SLAB_ATTR_RO(shared_caches);
 
 static ssize_t ctor_show(struct kmem_cache *s, char *buf)
 {
@@ -4127,7 +4478,7 @@ static ssize_t partial_show(struct kmem_
 }
 SLAB_ATTR_RO(partial);
 
-static ssize_t cpu_queues_show(struct kmem_cache *s, char *buf)
+static ssize_t per_cpu_caches_show(struct kmem_cache *s, char *buf)
 {
 	unsigned long total = 0;
 	int x;
@@ -4159,7 +4510,7 @@ static ssize_t cpu_queues_show(struct km
 	kfree(cpus);
 	return x + sprintf(buf + x, "\n");
 }
-SLAB_ATTR_RO(cpu_queues);
+SLAB_ATTR_RO(per_cpu_caches);
 
 static ssize_t objects_show(struct kmem_cache *s, char *buf)
 {
@@ -4472,14 +4823,17 @@ static struct attribute *slab_attrs[] = 
 	&objs_per_slab_attr.attr,
 	&order_attr.attr,
 	&min_partial_attr.attr,
+	&queue_size_attr.attr,
+	&batch_size_attr.attr,
 	&cpu_queue_size_attr.attr,
-	&cpu_batch_size_attr.attr,
+	&shared_queue_size_attr.attr,
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
 	&total_objects_attr.attr,
 	&slabs_attr.attr,
 	&partial_attr.attr,
-	&cpu_queues_attr.attr,
+	&per_cpu_caches_attr.attr,
+	&shared_caches_attr.attr,
 	&ctor_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
@@ -4750,6 +5104,7 @@ static int __init slab_sysfs_init(void)
 		if (err)
 			printk(KERN_ERR "SLUB: Unable to add boot slab %s"
 						" to sysfs\n", s->name);
+		alloc_shared_caches(s);
 	}
 
 	while (alias_list) {
@@ -4806,6 +5161,19 @@ static void s_stop(struct seq_file *m, v
 	up_read(&slub_lock);
 }
 
+static unsigned long shared_objects(struct kmem_cache *s)
+{
+	unsigned long shared;
+	int n;
+	struct kmem_cache_queue **caches;
+
+	caches = shared_caches(s);
+	for(n = 0; n < s->nr_shared; n++)
+		shared += caches[n]->objects;
+
+	kfree(caches);
+	return shared;
+}
 static int s_show(struct seq_file *m, void *p)
 {
 	unsigned long nr_partials = 0;
@@ -4835,9 +5203,10 @@ static int s_show(struct seq_file *m, vo
 	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d", s->name, nr_inuse,
 		   nr_objs, s->size, oo_objects(s->oo),
 		   (1 << oo_order(s->oo)));
-	seq_printf(m, " : tunables %4u %4u %4u", s->queue, s->batch, 0);
+	seq_printf(m, " : tunables %4u %4u %4u", s->cpu_queue, s->batch, s->shared_queue);
+
 	seq_printf(m, " : slabdata %6lu %6lu %6lu", nr_slabs, nr_slabs,
-		   0UL);
+		   shared_objects(s));
 	seq_putc(m, '\n');
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

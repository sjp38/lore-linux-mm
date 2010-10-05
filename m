Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F3BF86B0085
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:58:21 -0400 (EDT)
Message-Id: <20101005185817.034224729@linux.com>
Date: Tue, 05 Oct 2010 13:57:34 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 09/16] slub: Shared cache to exploit cross cpu caching abilities.
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=unified_shared_cache
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
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
 mm/slub.c                |  406 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 398 insertions(+), 17 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-10-05 13:19:37.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-10-05 13:26:32.000000000 -0500
@@ -17,9 +17,11 @@
 
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu queue */
+	ALLOC_SHARED,		/* Allocation caused a shared cache transaction */
 	ALLOC_DIRECT,		/* Allocation bypassing queueing */
 	ALLOC_SLOWPATH,		/* Allocation required refilling of queue */
 	FREE_FASTPATH,		/* Free to cpu queue */
+	FREE_SHARED,		/* Free caused a shared cache transaction */
 	FREE_DIRECT,		/* Free bypassing queues */
 	FREE_SLOWPATH,		/* Required pushing objects out of the queue */
 	FREE_ADD_PARTIAL,	/* Freeing moved slab to partial list */
@@ -50,6 +52,10 @@ enum stat_item {
 struct kmem_cache_queue {
 	int objects;		/* Available objects */
 	int max;		/* Queue capacity */
+	union {
+		struct kmem_cache_queue *shared; /* cpu q -> shared q */
+		spinlock_t lock;	  /* shared queue: lock */
+	};
 	void *object[];
 };
 
@@ -103,12 +109,15 @@ struct kmem_cache {
 	int align;		/* Alignment */
 	int queue;		/* specified queue size */
 	int cpu_queue;		/* cpu queue size */
+	int shared_queue;	/* Actual shared queue size */
+	int nr_shared;		/* Total # of shared caches */
 	unsigned long min_partial;
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
 #endif
+	int shared_queue_sysfs;	/* Desired shared queue size */
 
 #ifdef CONFIG_NUMA
 	/*
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-05 13:19:37.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-05 13:30:50.000000000 -0500
@@ -1438,6 +1438,23 @@ static inline int drain_queue(struct kme
 	return t;
 }
 
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
@@ -1446,6 +1463,7 @@ static void flush_cpu_objects(struct kme
 	struct kmem_cache_queue *q = &c->q;
 
 	drain_queue(s, q, q->objects);
+	drain_shared_cache(s, q->shared);
 	stat(s, QUEUE_FLUSH);
 }
 
@@ -1502,6 +1520,188 @@ struct kmem_cache_cpu *alloc_kmem_cache_
 	return k;
 }
 
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
+	spin_lock_init(&q->lock);
+	q->max = max;
+	q->objects =0;
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
+	if (!s->nr_shared)
+		return NULL;
+
+	caches = kzalloc(sizeof(struct kmem_cache_queue *)
+				* (s->nr_shared + 1), GFP_KERNEL);
+	if (!caches)
+		return ERR_PTR(-ENOMEM);
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
+static struct kmem_cache *get_slab(size_t size, gfp_t flags);
+
+/* Map of cpus that have no siblings or where we have broken topolocy info */
+static cpumask_t isolated_cpus;
+
+struct kmem_cache_queue *alloc_shared_cache_node(struct kmem_cache *s,
+					int node, const struct cpumask *map)
+{
+	struct kmem_cache_queue *l;
+	int max;
+	int size;
+	void *p;
+	int cpu;
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
+		size = PAGE_SIZE << get_order(size);
+
+	max = shared_cache_capacity(size);
+
+	/* Allocate shared cache */
+	p = kmalloc_node(size, GFP_KERNEL | __GFP_ZERO, node);
+	if (!p)
+		return NULL;
+	l = p;
+	init_shared_cache(l, max);
+
+	/* Link all cpus in this group to the shared cache */
+	for_each_cpu(cpu, map)
+		per_cpu_ptr(s->cpu, cpu)->q.shared = l;
+
+	s->shared_queue = max;
+	s->nr_shared++;
+
+	return l;
+}
+
+/*
+ * Allocate shared cpu caches.
+ * A shared cache is allocated for each series of cpus sharing a single cache
+ */
+static void alloc_shared_caches(struct kmem_cache *s)
+{
+	int cpu;
+	struct kmem_cache_queue *l;
+
+	if (slab_state < SYSFS || s->shared_queue_sysfs == 0)
+		return;
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
+		const struct cpumask *map =
+				per_cpu(cpu_info.llc_shared_map, cpu);
+
+		/* Skip cpus that already have assigned shared caches */
+		if (c->q.shared || cpu_isset(cpu, isolated_cpus))
+			continue;
+
+		if (cpumask_weight(map) < 2)
+			cpu_set(cpu, isolated_cpus);
+		else {
+			l = alloc_shared_cache_node(s, c->node, map);
+			if (!l)
+				printk(KERN_WARNING "SLUB: Out of memory allocating"
+					" shared cache for %s cpu %d node %d\n",
+					s->name, cpu, c->node);
+		}
+	}
+
+	/* Put all the isolated processor into their own shared cache */
+	if (!cpumask_empty(&isolated_cpus))
+		alloc_shared_cache_node(s, NUMA_NO_NODE, &isolated_cpus);
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
+static int remove_shared_caches(struct kmem_cache *s)
+{
+	struct kmem_cache_queue **caches;
+	int i;
+
+	caches = shared_caches(s);
+	if (!caches)
+		return 0;
+	if (IS_ERR(caches))
+		return PTR_ERR(caches);
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
 
 #ifdef CONFIG_SYSFS
 static void resize_cpu_queue(struct kmem_cache *s, int queue)
@@ -1509,6 +1709,9 @@ static void resize_cpu_queue(struct kmem
 	struct kmem_cache_cpu *n = alloc_kmem_cache_cpu(s, queue);
 	struct flush_control f;
 
+	/* Drop the shared caches if they exist */
+	remove_shared_caches(s);
+
 	/* Create the new cpu queue and then free the old one */
 	f.s = s;
 	f.c = s->cpu;
@@ -1553,6 +1756,9 @@ static void resize_cpu_queue(struct kmem
 
 	if (slab_state > UP)
 		free_percpu(f.c);
+
+	/* Get the shared caches back */
+	alloc_shared_caches(s);
 }
 #endif
 
@@ -1775,7 +1981,6 @@ redo:
 	q = &c->q;
 
 	if (likely(!queue_empty(q))) {
-
 		stat(s, ALLOC_FASTPATH);
 
 get_object:
@@ -1796,6 +2001,28 @@ got_object:
 		return object;
 	}
 
+	if (q->shared) {
+		/*
+		 * Refill the cpu queue with the hottest objects
+		 * from the shared cache queue
+		 */
+		struct kmem_cache_queue *l = q->shared;
+		int d = 0;
+
+		spin_lock(&l->lock);
+		d = min(l->objects, s->batch);
+
+		l->objects -= d;
+		memcpy(q->object, l->object + l->objects,
+						d * sizeof(void *));
+		spin_unlock(&l->lock);
+		q->objects = d;
+		if (d) {
+			stat(s, ALLOC_SHARED);
+			goto get_object;
+		}
+	}
+
 	stat(s, ALLOC_SLOWPATH);
 
 	n = get_node(s, node);
@@ -1950,9 +2177,30 @@ static void slab_free(struct kmem_cache 
 
 	if (unlikely(queue_full(q))) {
 
-		drain_queue(s, q, s->batch);
-		stat(s, FREE_SLOWPATH);
-
+		/* Shared queue available and has space ? */
+		if (q->shared) {
+			struct kmem_cache_queue *l = q->shared;
+			int d;
+
+			spin_lock(&l->lock);
+			d = min(s->batch, l->max - l->objects);
+			memcpy(l->object + l->objects, q->object,
+						d * sizeof(void *));
+			l->objects += d;
+			spin_unlock(&l->lock);
+
+			q->objects -= d;
+			memcpy(q->object, q->object + d,
+					q->objects  * sizeof(void *));
+
+			if (d)
+				stat(s, FREE_SHARED);
+		}
+
+		if (queue_full(q)) {
+			drain_queue(s, q, s->batch);
+			stat(s, FREE_SLOWPATH);
+		}
 	} else
 		stat(s, FREE_FASTPATH);
 
@@ -2411,8 +2659,11 @@ static int kmem_cache_open(struct kmem_c
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
@@ -2519,6 +2770,7 @@ static inline int kmem_cache_close(struc
 	int node;
 
 	down_read(&slub_lock);
+	remove_shared_caches(s);
 	flush_all(s);
 	free_percpu(s->cpu);
 	/* Attempt to free all objects */
@@ -3182,6 +3434,8 @@ void __init kmem_cache_init(void)
 			BUG_ON(!name);
 			kmalloc_dma_caches[i] = create_kmalloc_cache(name,
 				s->objsize, SLAB_CACHE_DMA);
+			 /* DMA caches are rarely used. Reduce memory consumption */
+			kmalloc_dma_caches[i]->shared_queue_sysfs = 0;
 		}
 	}
 #endif
@@ -3968,10 +4222,40 @@ static ssize_t min_partial_store(struct 
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
@@ -3996,28 +4280,89 @@ static ssize_t cpu_queue_size_store(stru
 }
 SLAB_ATTR(cpu_queue_size);
 
-static ssize_t batch_size_show(struct kmem_cache *s, char *buf)
+static ssize_t shared_queue_size_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%u\n", s->batch);
+	return sprintf(buf, "%u %u\n", s->shared_queue, s->shared_queue_sysfs);
 }
 
-static ssize_t batch_size_store(struct kmem_cache *s,
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
+	down_write(&slub_lock);
+	err = remove_shared_caches(s);
+	if (!err) {
+		if (s->batch > queue)
+			s->batch = queue;
+
+		s->shared_queue_sysfs = queue;
+		if (queue)
+			alloc_shared_caches(s);
+	}
+	up_write(&slub_lock);
+	return err ? err : length;
 }
-SLAB_ATTR(batch_size);
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
+		return -ENOENT;
+	}
+
+	if (IS_ERR(caches)) {
+		up_read(&slub_lock);
+		return PTR_ERR(caches);
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
+}
+SLAB_ATTR_RO(shared_caches);
 
 static ssize_t ctor_show(struct kmem_cache *s, char *buf)
 {
@@ -4351,9 +4696,11 @@ static ssize_t text##_store(struct kmem_
 SLAB_ATTR(text);						\
 
 STAT_ATTR(ALLOC_FASTPATH, alloc_fastpath);
+STAT_ATTR(ALLOC_SHARED, alloc_shared);
 STAT_ATTR(ALLOC_DIRECT, alloc_direct);
 STAT_ATTR(ALLOC_SLOWPATH, alloc_slowpath);
 STAT_ATTR(FREE_FASTPATH, free_fastpath);
+STAT_ATTR(FREE_SHARED, free_shared);
 STAT_ATTR(FREE_DIRECT, free_direct);
 STAT_ATTR(FREE_SLOWPATH, free_slowpath);
 STAT_ATTR(FREE_ADD_PARTIAL, free_add_partial);
@@ -4371,12 +4718,15 @@ static struct attribute *slab_attrs[] = 
 	&objs_per_slab_attr.attr,
 	&order_attr.attr,
 	&min_partial_attr.attr,
+	&queue_size_attr.attr,
 	&batch_size_attr.attr,
+	&shared_queue_size_attr.attr,
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
 	&partial_attr.attr,
 	&per_cpu_caches_attr.attr,
 	&cpu_queue_size_attr.attr,
+	&shared_caches_attr.attr,
 	&ctor_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
@@ -4401,9 +4751,11 @@ static struct attribute *slab_attrs[] = 
 #endif
 #ifdef CONFIG_SLUB_STATS
 	&alloc_fastpath_attr.attr,
+	&alloc_shared_attr.attr,
 	&alloc_direct_attr.attr,
 	&alloc_slowpath_attr.attr,
 	&free_fastpath_attr.attr,
+	&free_shared_attr.attr,
 	&free_direct_attr.attr,
 	&free_slowpath_attr.attr,
 	&free_add_partial_attr.attr,
@@ -4652,6 +5004,7 @@ static int __init slab_sysfs_init(void)
 		if (err)
 			printk(KERN_ERR "SLUB: Unable to add boot slab %s"
 						" to sysfs\n", s->name);
+		alloc_shared_caches(s);
 	}
 
 	while (alias_list) {
@@ -4708,6 +5061,24 @@ static void s_stop(struct seq_file *m, v
 	up_read(&slub_lock);
 }
 
+static unsigned long shared_objects(struct kmem_cache *s)
+{
+	unsigned long shared = 0;
+	int n;
+	struct kmem_cache_queue **caches;
+
+	caches = shared_caches(s);
+	if (IS_ERR(caches))
+		return PTR_ERR(caches);
+
+	if (caches) {
+		for(n = 0; n < s->nr_shared; n++)
+			shared += caches[n]->objects;
+
+		kfree(caches);
+	}
+	return shared;
+}
 static int s_show(struct seq_file *m, void *p)
 {
 	unsigned long nr_partials = 0;
@@ -4737,9 +5108,10 @@ static int s_show(struct seq_file *m, vo
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

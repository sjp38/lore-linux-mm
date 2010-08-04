Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4A166660020
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:34 -0400 (EDT)
Message-Id: <20100804024532.510006548@linux.com>
Date: Tue, 03 Aug 2010 21:45:29 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 15/23] slub: Allow resizing of per cpu queues
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=unified_resize
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Allow resizing of cpu queue and batch size. This is done in the
basic steps that are also followed by SLAB.

Careful: The ->cpu pointer is becoming volatile. References
to the ->cpu pointer either

A. Occur with interrupts disabled. This guarantees that nothing on the
   processor itself interferes. This only serializes access to a single
   processor specific area.

B. Occur with slub_lock taken for operations on all per cpu areas.
   Taking the slub_lock guarantees that no resizing operation will occur
   while accessing the percpu areas. The data in the percpu areas
   is volatile even with slub_lock since the alloc and free functions
   do not take slub_lock and will operate on fields of kmem_cache_cpu.

C. Are racy: Tolerable for statistics. The ->cpu pointer must always
   point to a valid kmem_cache_cpu area.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |    9 -
 mm/slub.c                |  218 +++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 197 insertions(+), 30 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-31 18:25:53.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-07-31 19:02:05.003563067 -0500
@@ -195,10 +195,19 @@
 
 #endif
 
+/*
+ * We allow stat calls while slub_lock is taken or while interrupts
+ * are enabled for simplicities sake.
+ *
+ * This results in potential inaccuracies. If the platform does not
+ * support per cpu atomic operations vs. interrupts then the counters
+ * may be updated in a racy manner due to slab processing in
+ * interrupts.
+ */
 static inline void stat(struct kmem_cache *s, enum stat_item si)
 {
 #ifdef CONFIG_SLUB_STATS
-	__this_cpu_inc(s->cpu_slab->stat[si]);
+	__this_cpu_inc(s->cpu->stat[si]);
 #endif
 }
 
@@ -303,7 +312,7 @@
 
 static inline int queue_full(struct kmem_cache_queue *q)
 {
-	return q->objects == QUEUE_SIZE;
+	return q->objects == q->max;
 }
 
 static inline int queue_empty(struct kmem_cache_queue *q)
@@ -1571,6 +1580,11 @@
  	stat(s, QUEUE_FLUSH);
 }
 
+struct flush_control {
+	struct kmem_cache *s;
+	struct kmem_cache_cpu *c;
+};
+
 /*
  * Flush cpu objects.
  *
@@ -1578,22 +1592,96 @@
  */
 static void __flush_cpu_objects(void *d)
 {
-	struct kmem_cache *s = d;
-	struct kmem_cache_cpu *c = __this_cpu_ptr(s->cpu_slab);
+	struct flush_control *f = d;
+	struct kmem_cache_cpu *c = __this_cpu_ptr(f->c);
 
 	if (c->q.objects)
-		flush_cpu_objects(s, c);
+		flush_cpu_objects(f->s, c);
 }
 
 static void flush_all(struct kmem_cache *s)
 {
-	on_each_cpu(__flush_cpu_objects, s, 1);
+	struct flush_control f = { s, s->cpu };
+
+	on_each_cpu(__flush_cpu_objects, &f, 1);
 }
 
 struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s, int n)
 {
-	return __alloc_percpu(sizeof(struct kmem_cache_cpu),
-		__alignof__(struct kmem_cache_cpu));
+	struct kmem_cache_cpu *k;
+	int cpu;
+	int size;
+	int max;
+
+	/* Size the queue and the allocation to cacheline sizes */
+	size = ALIGN(n * sizeof(void *) + sizeof(struct kmem_cache_cpu), cache_line_size());
+
+	k = __alloc_percpu(size, cache_line_size());
+	if (!k)
+		return NULL;
+
+	max = (size - sizeof(struct kmem_cache_cpu)) / sizeof(void *);
+
+	for_each_possible_cpu(cpu) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(k, cpu);
+
+		c->q.max = max;
+	}
+
+	s->cpu_queue = max;
+	return k;
+}
+
+
+static void resize_cpu_queue(struct kmem_cache *s, int queue)
+{
+	struct kmem_cache_cpu *n = alloc_kmem_cache_cpu(s, queue);
+	struct flush_control f;
+
+	/* Create the new cpu queue and then free the old one */
+	f.s = s;
+	f.c = s->cpu;
+
+	/* We can only shrink the queue here since the new
+	 * queue size may be smaller and there may be concurrent
+	 * slab operations. The update of the queue must be seen
+	 * before the change of the location of the percpu queue.
+	 *
+	 * Note that the queue may contain more object than the
+	 * queue size after this operation.
+	 */
+	if (queue < s->queue) {
+		s->queue = queue;
+		s->batch = (s->queue + 1) / 2;
+		barrier();
+	}
+
+	/* This is critical since allocation and free runs
+	 * concurrently without taking the slub_lock!
+	 * We point the cpu pointer to a different per cpu
+	 * segment to redirect current processing and then
+	 * flush the cpu objects on the old cpu structure.
+	 *
+	 * The old percpu structure is no longer reachable
+	 * since slab_alloc/free must have terminated in order
+	 * to execute __flush_cpu_objects. Both require
+	 * interrupts to be disabled.
+	 */
+	s->cpu = n;
+	on_each_cpu(__flush_cpu_objects, &f, 1);
+
+	/*
+	 * If the queue needs to be extended then we deferred
+	 * the update until now when the larger sized queue
+	 * has been allocated and is working.
+	 */
+	if (queue > s->queue) {
+		s->queue = queue;
+		s->batch = (s->queue + 1) / 2;
+	}
+
+	if (slab_state > UP)
+		free_percpu(f.c);
 }
 
 /*
@@ -1706,7 +1794,7 @@
 {
 	int d;
 
-	d = min(BATCH_SIZE - q->objects, nr);
+	d = min(s->batch - q->objects, nr);
 	retrieve_objects(s, page, q->object + q->objects, d);
 	q->objects += d;
 }
@@ -1747,7 +1835,7 @@
 
 redo:
 	local_irq_save(flags);
-	c = __this_cpu_ptr(s->cpu_slab);
+	c = __this_cpu_ptr(s->cpu);
 	q = &c->q;
 	if (unlikely(queue_empty(q) || !node_match(c, node))) {
 
@@ -1756,7 +1844,7 @@
 			c->node = node;
 		}
 
-		while (q->objects < BATCH_SIZE) {
+		while (q->objects < s->batch) {
 			struct page *new;
 
 			new = get_partial(s, gfpflags & ~__GFP_ZERO, node);
@@ -1773,7 +1861,7 @@
 					local_irq_disable();
 
 				/* process may have moved to different cpu */
-				c = __this_cpu_ptr(s->cpu_slab);
+				c = __this_cpu_ptr(s->cpu);
 				q = &c->q;
 
  				if (!new) {
@@ -1875,7 +1963,7 @@
 
 	slab_free_hook_irq(s, x);
 
-	c = __this_cpu_ptr(s->cpu_slab);
+	c = __this_cpu_ptr(s->cpu);
 
 	if (NUMA_BUILD) {
 		int node = page_to_nid(page);
@@ -1891,7 +1979,7 @@
 
 	if (unlikely(queue_full(q))) {
 
-		drain_queue(s, q, BATCH_SIZE);
+		drain_queue(s, q, s->batch);
 		stat(s, FREE_SLOWPATH);
 
 	} else
@@ -2093,9 +2181,9 @@
 	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
 			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache));
 
-	s->cpu_slab = alloc_percpu(struct kmem_cache_cpu);
+	s->cpu = alloc_kmem_cache_cpu(s, s->queue);
 
-	return s->cpu_slab != NULL;
+	return s->cpu != NULL;
 }
 
 #ifdef CONFIG_NUMA
@@ -2317,6 +2405,18 @@
 
 }
 
+static int initial_queue_size(int size)
+{
+	if (size > PAGE_SIZE)
+		return 8;
+	else if (size > 1024)
+		return 24;
+	else if (size > 256)
+		return 54;
+	else
+		return 120;
+}
+
 static int kmem_cache_open(struct kmem_cache *s,
 		const char *name, size_t size,
 		size_t align, unsigned long flags,
@@ -2355,6 +2455,9 @@
 	if (!init_kmem_cache_nodes(s))
 		goto error;
 
+	s->queue = initial_queue_size(s->size);
+	s->batch = (s->queue + 1) / 2;
+
 	if (alloc_kmem_cache_cpus(s))
 		return 1;
 
@@ -2465,8 +2568,9 @@
 {
 	int node;
 
+	down_read(&slub_lock);
 	flush_all(s);
-	free_percpu(s->cpu_slab);
+	free_percpu(s->cpu);
 	/* Attempt to free all objects */
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
@@ -2476,6 +2580,7 @@
 			return 1;
 	}
 	free_kmem_cache_nodes(s);
+	up_read(&slub_lock);
 	return 0;
 }
 
@@ -3122,6 +3227,7 @@
 		caches++;
 	}
 
+	/* Now the kmalloc array is fully functional (*not* the dma array) */
 	slab_state = UP;
 
 	/* Provide the correct kmalloc names now that the caches are up */
@@ -3149,6 +3255,7 @@
 #ifdef CONFIG_ZONE_DMA
 	int i;
 
+	/* Create the dma kmalloc array and make it operational */
 	for (i = 0; i < SLUB_PAGE_SHIFT; i++) {
 		struct kmem_cache *s = kmalloc_caches[i];
 
@@ -3297,7 +3404,7 @@
 		down_read(&slub_lock);
 		list_for_each_entry(s, &slab_caches, list) {
 			local_irq_save(flags);
-			flush_cpu_objects(s, per_cpu_ptr(s->cpu_slab ,cpu));
+			flush_cpu_objects(s, per_cpu_ptr(s->cpu, cpu));
 			local_irq_restore(flags);
 		}
 		up_read(&slub_lock);
@@ -3764,6 +3871,7 @@
 		return -ENOMEM;
 	per_cpu = nodes + nr_node_ids;
 
+	down_read(&slub_lock);
 	if (flags & SO_ALL) {
 		for_each_node_state(node, N_NORMAL_MEMORY) {
 			struct kmem_cache_node *n = get_node(s, node);
@@ -3794,6 +3902,7 @@
 			nodes[node] += x;
 		}
 	}
+
 	x = sprintf(buf, "%lu", total);
 #ifdef CONFIG_NUMA
 	for_each_node_state(node, N_NORMAL_MEMORY)
@@ -3801,6 +3910,7 @@
 			x += sprintf(buf + x, " N%d=%lu",
 					node, nodes[node]);
 #endif
+	up_read(&slub_lock);
 	kfree(nodes);
 	return x + sprintf(buf + x, "\n");
 }
@@ -3904,6 +4014,57 @@
 }
 SLAB_ATTR(min_partial);
 
+static ssize_t cpu_queue_size_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%u\n", s->queue);
+}
+
+static ssize_t cpu_queue_size_store(struct kmem_cache *s,
+			 const char *buf, size_t length)
+{
+	unsigned long queue;
+	int err;
+
+	err = strict_strtoul(buf, 10, &queue);
+	if (err)
+		return err;
+
+	if (queue > 10000 || queue < 4)
+		return -EINVAL;
+
+	if (s->batch > queue)
+		s->batch = queue;
+
+	down_write(&slub_lock);
+	resize_cpu_queue(s, queue);
+	up_write(&slub_lock);
+	return length;
+}
+SLAB_ATTR(cpu_queue_size);
+
+static ssize_t cpu_batch_size_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%u\n", s->batch);
+}
+
+static ssize_t cpu_batch_size_store(struct kmem_cache *s,
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
+SLAB_ATTR(cpu_batch_size);
+
 static ssize_t ctor_show(struct kmem_cache *s, char *buf)
 {
 	if (s->ctor) {
@@ -3944,8 +4105,9 @@
 	if (!cpus)
 		return -ENOMEM;
 
+	down_read(&slub_lock);
 	for_each_online_cpu(cpu) {
-		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
 
 		total += c->q.objects;
 	}
@@ -3953,11 +4115,14 @@
 	x = sprintf(buf, "%lu", total);
 
 	for_each_online_cpu(cpu) {
-		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
+		struct kmem_cache_queue *q = &c->q;
 
-		if (c->q.objects)
-			x += sprintf(buf + x, " C%d=%u", cpu, c->q.objects);
+		if (!queue_empty(q))
+			x += sprintf(buf + x, " C%d=%u/%u",
+				cpu, q->objects, q->max);
 	}
+	up_read(&slub_lock);
 	kfree(cpus);
 	return x + sprintf(buf + x, "\n");
 }
@@ -4209,12 +4374,14 @@
 	if (!data)
 		return -ENOMEM;
 
+	down_read(&slub_lock);
 	for_each_online_cpu(cpu) {
-		unsigned x = per_cpu_ptr(s->cpu_slab, cpu)->stat[si];
+		unsigned x = per_cpu_ptr(s->cpu, cpu)->stat[si];
 
 		data[cpu] = x;
 		sum += x;
 	}
+	up_read(&slub_lock);
 
 	len = sprintf(buf, "%lu", sum);
 
@@ -4232,8 +4399,10 @@
 {
 	int cpu;
 
+	down_write(&slub_lock);
 	for_each_online_cpu(cpu)
-		per_cpu_ptr(s->cpu_slab, cpu)->stat[si] = 0;
+		per_cpu_ptr(s->cpu, cpu)->stat[si] = 0;
+	up_write(&slub_lock);
 }
 
 #define STAT_ATTR(si, text) 					\
@@ -4270,6 +4439,8 @@
 	&objs_per_slab_attr.attr,
 	&order_attr.attr,
 	&min_partial_attr.attr,
+	&cpu_queue_size_attr.attr,
+	&cpu_batch_size_attr.attr,
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
 	&total_objects_attr.attr,
@@ -4631,7 +4802,7 @@
 	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d", s->name, nr_inuse,
 		   nr_objs, s->size, oo_objects(s->oo),
 		   (1 << oo_order(s->oo)));
-	seq_printf(m, " : tunables %4u %4u %4u", 0, 0, 0);
+	seq_printf(m, " : tunables %4u %4u %4u", s->queue, s->batch, 0);
 	seq_printf(m, " : slabdata %6lu %6lu %6lu", nr_slabs, nr_slabs,
 		   0UL);
 	seq_putc(m, '\n');
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-07-31 18:25:28.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-07-31 19:00:58.738236361 -0500
@@ -29,14 +29,11 @@
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
 	NR_SLUB_STAT_ITEMS };
 
-#define QUEUE_SIZE 50
-#define BATCH_SIZE 25
-
 /* Queueing structure used for per cpu, l3 cache and alien queueing */
 struct kmem_cache_queue {
 	int objects;		/* Available objects */
 	int max;		/* Queue capacity */
-	void *object[QUEUE_SIZE];
+	void *object[];
 };
 
 struct kmem_cache_cpu {
@@ -71,7 +68,7 @@
  * Slab cache management.
  */
 struct kmem_cache {
-	struct kmem_cache_cpu *cpu_slab;
+	struct kmem_cache_cpu *cpu;
 	/* Used for retriving partial slabs etc */
 	unsigned long flags;
 	int size;		/* The size of an object including meta data */
@@ -87,6 +84,8 @@
 	void (*ctor)(void *);
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
+	int queue;		/* specified queue size */
+	int cpu_queue;		/* cpu queue size */
 	unsigned long min_partial;
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

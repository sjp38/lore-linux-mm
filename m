Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 51EBF6B01B9
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 17:24:30 -0400 (EDT)
Message-Id: <20100625212108.709719896@quilx.com>
Date: Fri, 25 Jun 2010 16:20:39 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q 13/16] SLUB: Resize the new cpu queues
References: <20100625212026.810557229@quilx.com>
Content-Disposition: inline; filename=sled_resize
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

Allow resizing of cpu queue and batch size. This is done in the
basic steps that are also followed by SLAB.

The statically allocated per cpu areas are removed since the per cpu
allocator is already available when kmem_cache_init is called. We can
dynamically size the per cpu data during bootstrap.

Careful: This means that the ->cpu pointer is becoming volatile. References
to the ->cpu pointer either

A. Occur with interrupts disabled. This guarantees that nothing on the
   processor itself interferes. This only serializes access to a single
   processor specific area.

B. Occur with slub_lock taken for operations on all per cpu areas.
   Taking the slub_lock guarantees that no resizing operation will occur
   while accessing the percpu areas. The data in the percpu areas
   is volatile even with slub_lock since the alloc and free functions
   do not take slub_lock and will operate on fields of kmem_cache_cpu.

C. Are racy: This is true for the statistics. The ->cpu pointer must always
   point to a valid kmem_cache_cpu area.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |    9 --
 mm/slub.c                |  199 +++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 178 insertions(+), 30 deletions(-)

Index: linux-2.6.34/include/linux/slub_def.h
===================================================================
--- linux-2.6.34.orig/include/linux/slub_def.h	2010-06-23 10:05:03.000000000 -0500
+++ linux-2.6.34/include/linux/slub_def.h	2010-06-23 10:05:16.000000000 -0500
@@ -34,16 +34,13 @@ enum stat_item {
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
 	NR_SLUB_STAT_ITEMS };
 
-#define QUEUE_SIZE 50
-#define BATCH_SIZE 25
-
 struct kmem_cache_cpu {
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
 	int objects;		/* Number of objects available */
 	int node;		/* The node of the page (or -1 for debug) */
-	void *object[QUEUE_SIZE];		/* List of objects */
+	void *object[];		/* Dynamic alloc will allow larger sizes  */
 };
 
 struct kmem_cache_node {
@@ -70,12 +67,14 @@ struct kmem_cache_order_objects {
  * Slab cache management.
  */
 struct kmem_cache {
-	struct kmem_cache_cpu *cpu_slab;
+	struct kmem_cache_cpu *cpu;
 	/* Used for retriving partial slabs etc */
 	unsigned long flags;
 	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
 	struct kmem_cache_order_objects oo;
+	int queue;		/* per cpu queue size */
+	int batch;		/* batch size */
 
 	/* Allocation and freeing of slabs */
 	struct kmem_cache_order_objects max;
Index: linux-2.6.34/mm/slub.c
===================================================================
--- linux-2.6.34.orig/mm/slub.c	2010-06-23 10:05:03.000000000 -0500
+++ linux-2.6.34/mm/slub.c	2010-06-23 10:06:13.000000000 -0500
@@ -195,10 +195,19 @@ static inline void sysfs_slab_remove(str
 
 #endif
 
+/*
+ * We allow stat calls while slub_lock is taken or while interrupts
+ * are enabled for simplicities sake.
+ *
+ * This results in potential inaccuracies. If the platform does not
+ * support per cpu atomic operations vs. interrupts thent he counts
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
 
@@ -1511,6 +1520,11 @@ static void flush_cpu_objects(struct kme
  	stat(s, CPUSLAB_FLUSH);
 }
 
+struct flush_control {
+	struct kmem_cache *s;
+	struct kmem_cache_cpu *c;
+};
+
 /*
  * Flush cpu objects.
  *
@@ -1518,24 +1532,78 @@ static void flush_cpu_objects(struct kme
  */
 static void __flush_cpu_objects(void *d)
 {
-	struct kmem_cache *s = d;
-	struct kmem_cache_cpu *c = __this_cpu_ptr(s->cpu_slab);
+	struct flush_control *f = d;
+	struct kmem_cache_cpu *c = __this_cpu_ptr(f->c);
 
 	if (c->objects)
-		flush_cpu_objects(s, c);
+		flush_cpu_objects(f->s, c);
 }
 
 static void flush_all(struct kmem_cache *s)
 {
-	on_each_cpu(__flush_cpu_objects, s, 1);
+	struct flush_control f = { s, s->cpu};
+
+	on_each_cpu(__flush_cpu_objects, &f, 1);
 }
 
 struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s, int n)
 {
-	return __alloc_percpu(sizeof(struct kmem_cache_cpu),
+	return __alloc_percpu(sizeof(struct kmem_cache_cpu) +
+	                       	sizeof(void *) * n,
 		__alignof__(struct kmem_cache_cpu));
 }
 
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
+}
+
 /*
  * Check if the objects in a per cpu structure fit numa
  * locality expectations.
@@ -1657,7 +1725,7 @@ static void *slab_alloc(struct kmem_cach
 
 redo:
 	local_irq_save(flags);
-	c = __this_cpu_ptr(s->cpu_slab);
+	c = __this_cpu_ptr(s->cpu);
 	if (unlikely(!c->objects || !node_match(c, node))) {
 
 		gfpflags &= gfp_allowed_mask;
@@ -1667,7 +1735,7 @@ redo:
 			c->node = node;
 		}
 
-		while (c->objects < BATCH_SIZE) {
+		while (c->objects < s->batch) {
 			struct page *new;
 			int d;
 
@@ -1683,7 +1751,7 @@ redo:
 					local_irq_disable();
 
 				/* process may have moved to different cpu */
-				c = __this_cpu_ptr(s->cpu_slab);
+				c = __this_cpu_ptr(s->cpu);
 
  				if (!new) {
 					if (!c->objects)
@@ -1695,7 +1763,7 @@ redo:
 			} else
 				stat(s, ALLOC_FROM_PARTIAL);
 
-			d = min(BATCH_SIZE - c->objects, available(new));
+			d = min(s->batch - c->objects, available(new));
 			retrieve_objects(s, new, c->object + c->objects, d);
 			c->objects += d;
 
@@ -1787,7 +1855,7 @@ static void slab_free(struct kmem_cache 
 	kmemleak_free_recursive(x, s->flags);
 
 	local_irq_save(flags);
-	c = __this_cpu_ptr(s->cpu_slab);
+	c = __this_cpu_ptr(s->cpu);
 
 	kmemcheck_slab_free(s, object, s->objsize);
 	debug_check_no_locks_freed(object, s->objsize);
@@ -1795,9 +1863,9 @@ static void slab_free(struct kmem_cache 
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(object, s->objsize);
 
-	if (unlikely(c->objects >= QUEUE_SIZE)) {
+	if (unlikely(c->objects >= s->queue)) {
 
-		int t = min(BATCH_SIZE, c->objects);
+		int t = min(s->batch, c->objects);
 
 		drain_objects(s, c->object, t);
 
@@ -2011,9 +2079,9 @@ static inline int alloc_kmem_cache_cpus(
 	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
 			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache));
 
-	s->cpu_slab = alloc_percpu(struct kmem_cache_cpu);
+	s->cpu = alloc_kmem_cache_cpu(s, s->queue);
 
-	return s->cpu_slab != NULL;
+	return s->cpu != NULL;
 }
 
 #ifdef CONFIG_NUMA
@@ -2235,6 +2303,18 @@ static int calculate_sizes(struct kmem_c
 
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
@@ -2273,6 +2353,9 @@ static int kmem_cache_open(struct kmem_c
 	if (!init_kmem_cache_nodes(s))
 		goto error;
 
+	s->queue = initial_queue_size(s->size);
+	s->batch = (s->queue + 1) / 2;
+
 	if (alloc_kmem_cache_cpus(s))
 		return 1;
 
@@ -2383,8 +2466,9 @@ static inline int kmem_cache_close(struc
 {
 	int node;
 
+	down_read(&slub_lock);
 	flush_all(s);
-	free_percpu(s->cpu_slab);
+	free_percpu(s->cpu);
 	/* Attempt to free all objects */
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
@@ -2394,6 +2478,7 @@ static inline int kmem_cache_close(struc
 			return 1;
 	}
 	free_kmem_cache_nodes(s);
+	up_read(&slub_lock);
 	return 0;
 }
 
@@ -3040,6 +3125,7 @@ void __init kmem_cache_init(void)
 		caches++;
 	}
 
+	/* Now the kmalloc array is fully functional (*not* the dma array) */
 	slab_state = UP;
 
 	/* Provide the correct kmalloc names now that the caches are up */
@@ -3056,6 +3142,7 @@ void __init kmem_cache_init(void)
 		caches, cache_line_size(),
 		slub_min_order, slub_max_order, slub_min_objects,
 		nr_cpu_ids, nr_node_ids);
+
 }
 
 void __init kmem_cache_init_late(void)
@@ -3063,6 +3150,7 @@ void __init kmem_cache_init_late(void)
 #ifdef CONFIG_ZONE_DMA
 	int i;
 
+	/* Create the dma kmalloc array and make it operational */
 	for (i = 0; i < SLUB_PAGE_SHIFT; i++) {
 		struct kmem_cache *s = kmalloc_caches[i];
 
@@ -3167,7 +3255,7 @@ struct kmem_cache *kmem_cache_create(con
 		return s;
 	}
 
-	s = kmalloc(kmem_size, GFP_KERNEL);
+	s = kmalloc(kmem_size, irqs_disabled() ? GFP_NOWAIT : GFP_KERNEL);
 	if (s) {
 		if (kmem_cache_open(s, name,
 				size, align, flags, ctor)) {
@@ -3215,7 +3303,7 @@ static int __cpuinit slab_cpuup_callback
 		down_read(&slub_lock);
 		list_for_each_entry(s, &slab_caches, list) {
 			local_irq_save(flags);
-			flush_cpu_objects(s, per_cpu_ptr(s->cpu_slab ,cpu));
+			flush_cpu_objects(s, per_cpu_ptr(s->cpu, cpu));
 			local_irq_restore(flags);
 		}
 		up_read(&slub_lock);
@@ -3681,13 +3769,15 @@ static ssize_t show_slab_objects(struct 
 	nodes = kzalloc(2 * sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
 	if (!nodes)
 		return -ENOMEM;
+
+	down_read(&slub_lock);
 	per_cpu = nodes + nr_node_ids;
 
 	if (flags & SO_CPU) {
 		int cpu;
 
 		for_each_possible_cpu(cpu) {
-			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu, cpu);
 
 			if (!c || c->node < 0)
 				continue;
@@ -3737,6 +3827,8 @@ static ssize_t show_slab_objects(struct 
 			nodes[node] += x;
 		}
 	}
+
+	up_read(&slub_lock);
 	x = sprintf(buf, "%lu", total);
 #ifdef CONFIG_NUMA
 	for_each_node_state(node, N_NORMAL_MEMORY)
@@ -3847,6 +3939,57 @@ static ssize_t min_partial_store(struct 
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
@@ -3876,11 +4019,11 @@ static ssize_t partial_show(struct kmem_
 }
 SLAB_ATTR_RO(partial);
 
-static ssize_t cpu_slabs_show(struct kmem_cache *s, char *buf)
+static ssize_t cpu_show(struct kmem_cache *s, char *buf)
 {
 	return show_slab_objects(s, buf, SO_CPU);
 }
-SLAB_ATTR_RO(cpu_slabs);
+SLAB_ATTR_RO(cpu);
 
 static ssize_t objects_show(struct kmem_cache *s, char *buf)
 {
@@ -4128,12 +4271,14 @@ static int show_stat(struct kmem_cache *
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
 
@@ -4151,8 +4296,10 @@ static void clear_stat(struct kmem_cache
 {
 	int cpu;
 
+	down_write(&slub_lock);
 	for_each_online_cpu(cpu)
-		per_cpu_ptr(s->cpu_slab, cpu)->stat[si] = 0;
+		per_cpu_ptr(s->cpu, cpu)->stat[si] = 0;
+	up_write(&slub_lock);
 }
 
 #define STAT_ATTR(si, text) 					\
@@ -4196,12 +4343,14 @@ static struct attribute *slab_attrs[] = 
 	&objs_per_slab_attr.attr,
 	&order_attr.attr,
 	&min_partial_attr.attr,
+	&cpu_queue_size_attr.attr,
+	&cpu_batch_size_attr.attr,
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
 	&total_objects_attr.attr,
 	&slabs_attr.attr,
 	&partial_attr.attr,
-	&cpu_slabs_attr.attr,
+	&cpu_attr.attr,
 	&ctor_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
@@ -4553,7 +4702,7 @@ static int s_show(struct seq_file *m, vo
 	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d", s->name, nr_inuse,
 		   nr_objs, s->size, oo_objects(s->oo),
 		   (1 << oo_order(s->oo)));
-	seq_printf(m, " : tunables %4u %4u %4u", 0, 0, 0);
+	seq_printf(m, " : tunables %4u %4u %4u", s->queue, s->batch, 0);
 	seq_printf(m, " : slabdata %6lu %6lu %6lu", nr_slabs, nr_slabs,
 		   0UL);
 	seq_putc(m, '\n');

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C68E8600422
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:19:00 -0400 (EDT)
Message-Id: <20100521211541.570468678@quilx.com>
Date: Fri, 21 May 2010 16:15:00 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC V2 SLEB 08/14] SLEB: Resize cpu queue
References: <20100521211452.659982351@quilx.com>
Content-Disposition: inline; filename=sled_resize
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Allow resizing of cpu queue and batch sizes. Resizing queues is only
possible for non kmalloc slabs since kmalloc slabs have statically
allocated per cpu queues (avoid bootstap issues) and involves
reallocating the per cpu structures. This is done by replicating
the basic steps of how SLAB does it.

Careful: This means that the ->cpu_slab pointer is only
guaranteed to be stable if interrupts are disabled.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |    2 
 mm/slub.c                |  152 +++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 143 insertions(+), 11 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-05-20 14:40:08.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-05-20 14:40:17.000000000 -0500
@@ -1521,6 +1521,11 @@ static void flush_cpu_objects(struct kme
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
@@ -1528,24 +1533,77 @@ static void flush_cpu_objects(struct kme
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
+	struct flush_control f = { s, s->cpu_slab};
+
+	on_each_cpu(__flush_cpu_objects, &f, 1);
 }
 
 struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s, int n)
 {
-	return __alloc_percpu(sizeof(struct kmem_cache_cpu),
+	return __alloc_percpu(
+			sizeof(struct kmem_cache_cpu) + sizeof(void *) * (n - BOOT_QUEUE_SIZE),
 			__alignof__(struct kmem_cache_cpu));
 }
 
+static void resize_cpu_queue(struct kmem_cache *s, int queue)
+{
+
+	if (is_kmalloc_cache(s)) {
+		if (queue < BOOT_QUEUE_SIZE) {
+			s->queue = queue;
+			if (s->batch > queue)
+				s->batch = queue;
+		} else {
+			/* More than max. Go to max allowed */
+			s->queue = BOOT_QUEUE_SIZE;
+			s->batch = BOOT_BATCH_SIZE;
+		}
+	} else {
+		struct kmem_cache_cpu *n = alloc_kmem_cache_cpu(s, queue);
+		struct flush_control f;
+
+		/* Create the new cpu queue and then free the old one */
+		down_write(&slub_lock);
+		f.s = s;
+		f.c = s->cpu_slab;
+
+		/* We can only shrink the queue here since the new
+		 * queue size may be smaller and there may be concurrent
+		 * slab operations. The upate of the queue must be seen
+		 * before the change of the location of the percpu queue.
+		 *
+		 * Note that the queue may contain more object than the
+		 * queue size after this operation.
+		 */
+		if (queue < s->queue) {
+			s->queue = queue;
+			barrier();
+		}
+		s->cpu_slab = n;
+		on_each_cpu(__flush_cpu_objects, &f, 1);
+
+		/*
+		 * If the queue needs to be extended then we deferred
+		 * the update until now when the larger sized queue
+		 * has been allocated and is working.
+		 */
+		if (queue > s->queue)
+			s->queue = queue;
+
+		up_write(&slub_lock);
+		free_percpu(f.c);
+	}
+}
+
 /*
  * Check if the objects in a per cpu structure fit numa
  * locality expectations.
@@ -1678,7 +1736,7 @@ redo:
 			c->node = node;
 		}
 
-		while (c->objects < BOOT_BATCH_SIZE) {
+		while (c->objects < s->batch) {
 			struct page *new;
 			int d;
 
@@ -1706,7 +1764,7 @@ redo:
 			} else
 				stat(s, ALLOC_FROM_PARTIAL);
 
-			d = min(BOOT_BATCH_SIZE - c->objects, available(new));
+			d = min(s->batch - c->objects, available(new));
 			retrieve_objects(s, new, c->object + c->objects, d);
 			c->objects += d;
 
@@ -1806,9 +1864,9 @@ static void slab_free(struct kmem_cache 
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(object, s->objsize);
 
-	if (unlikely(c->objects >= BOOT_QUEUE_SIZE)) {
+	if (unlikely(c->objects >= s->queue)) {
 
-		int t = min(BOOT_BATCH_SIZE, c->objects);
+		int t = min(s->batch, c->objects);
 
 		drain_objects(s, c->object, t);
 
@@ -2028,7 +2086,7 @@ static inline int alloc_kmem_cache_cpus(
 		s->cpu_slab = kmalloc_percpu + (s - kmalloc_caches);
 	else
 
-		s->cpu_slab =  alloc_kmem_cache_cpu(s, BOOT_QUEUE_SIZE);
+		s->cpu_slab =  alloc_kmem_cache_cpu(s, s->queue);
 
 	if (!s->cpu_slab)
 		return 0;
@@ -2263,6 +2321,26 @@ static int calculate_sizes(struct kmem_c
 
 }
 
+/* Autotuning of the per cpu queueing */
+void initial_cpu_queue_setup(struct kmem_cache *s)
+{
+	if (s->size > PAGE_SIZE)
+		s->queue = 8;
+	else if (s->size > 1024)
+		s->queue = 24;
+	else if (s->size > 256)
+		s->queue = 54;
+	else
+		s->queue = 120;
+
+	if (is_kmalloc_cache(s) && s->queue > BOOT_QUEUE_SIZE) {
+		/* static so cap it */
+		s->queue = BOOT_QUEUE_SIZE;
+	}
+
+	s->batch = (s->queue + 1) / 2;
+}
+
 static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
 		const char *name, size_t size,
 		size_t align, unsigned long flags,
@@ -2298,6 +2376,7 @@ static int kmem_cache_open(struct kmem_c
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
+	initial_cpu_queue_setup(s);
 	if (!init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		goto error;
 
@@ -3855,6 +3934,55 @@ static ssize_t min_partial_store(struct 
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
+	resize_cpu_queue(s, queue);
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
@@ -4204,6 +4332,8 @@ static struct attribute *slab_attrs[] = 
 	&objs_per_slab_attr.attr,
 	&order_attr.attr,
 	&min_partial_attr.attr,
+	&cpu_queue_size_attr.attr,
+	&cpu_batch_size_attr.attr,
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
 	&total_objects_attr.attr,
@@ -4561,7 +4691,7 @@ static int s_show(struct seq_file *m, vo
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
--- linux-2.6.orig/include/linux/slub_def.h	2010-05-20 14:39:20.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-05-20 14:40:17.000000000 -0500
@@ -76,6 +76,8 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
 	struct kmem_cache_order_objects oo;
+	int queue;		/* per cpu queue size */
+	int batch;		/* batch size */
 	/*
 	 * Avoid an extra cache line for UP, SMP and for the node local to
 	 * struct kmem_cache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

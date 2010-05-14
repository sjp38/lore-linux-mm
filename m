Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2B87A6B01F0
	for <linux-mm@kvack.org>; Fri, 14 May 2010 14:43:08 -0400 (EDT)
Message-Id: <20100514183946.102058238@quilx.com>
References: <20100514183908.118952419@quilx.com>
Date: Fri, 14 May 2010 13:39:15 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC SLEB 07/10] SLEB: Resize cpu queue
Content-Disposition: inline; filename=sled_resize
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Allow resizing of cpu queue and batch sizes

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |    2 
 mm/slub.c                |  116 ++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 111 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-04-29 16:18:17.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-04-29 16:18:22.000000000 -0500
@@ -1542,10 +1542,40 @@ static void flush_all(struct kmem_cache 
 
 struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s, int n)
 {
-	return __alloc_percpu(sizeof(struct kmem_cache_cpu),
+	return __alloc_percpu(
+			sizeof(struct kmem_cache_cpu) + sizeof(void *) * (n - BOOT_QUEUE_SIZE),
 			__alignof__(struct kmem_cache_cpu));
 }
 
+static int is_kmalloc_cache(struct kmem_cache *s);
+
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
+		struct kmem_cache_cpu *o = s->cpu_slab;
+
+		/* Some serialization issues are remaining here since we cannot lock the slab */
+		down_write(&slub_lock);
+		flush_all(s);
+		s->cpu_slab = n;
+		s->queue = queue;
+		up_write(&slub_lock);
+		free_percpu(o);
+	}
+}
+
 /*
  * Check if the objects in a per cpu structure fit numa
  * locality expectations.
@@ -1678,7 +1708,7 @@ redo:
 			c->node = node;
 		}
 
-		while (c->objects < BOOT_BATCH_SIZE) {
+		while (c->objects < s->batch) {
 			struct page *new;
 			int d;
 
@@ -1706,7 +1736,7 @@ redo:
 			} else
 				stat(s, ALLOC_FROM_PARTIAL);
 
-			d = min(BOOT_BATCH_SIZE - c->objects, available(new));
+			d = min(s->batch - c->objects, available(new));
 			retrieve_objects(s, new, c->object + c->objects, d);
 			c->objects += d;
 
@@ -1806,9 +1836,9 @@ static void slab_free(struct kmem_cache 
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(object, s->objsize);
 
-	if (unlikely(c->objects >= BOOT_QUEUE_SIZE)) {
+	if (unlikely(c->objects >= s->queue)) {
 
-		int t = min(BOOT_BATCH_SIZE, c->objects);
+		int t = min(s->batch, c->objects);
 
 		drain_objects(s, c->object, t);
 
@@ -2028,7 +2058,7 @@ static inline int alloc_kmem_cache_cpus(
 		s->cpu_slab = kmalloc_percpu + (s - kmalloc_caches);
 	else
 
-		s->cpu_slab =  alloc_kmem_cache_cpu(s, BOOT_QUEUE_SIZE);
+		s->cpu_slab =  alloc_kmem_cache_cpu(s, s->queue);
 
 	if (!s->cpu_slab)
 		return 0;
@@ -2261,6 +2291,26 @@ static int calculate_sizes(struct kmem_c
 
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
@@ -2296,6 +2346,7 @@ static int kmem_cache_open(struct kmem_c
 #ifdef CONFIG_NUMA
 	s->remote_node_defrag_ratio = 1000;
 #endif
+	initial_cpu_queue_setup(s);
 	if (!init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		goto error;
 
@@ -3846,6 +3897,55 @@ static ssize_t min_partial_store(struct 
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
@@ -4195,6 +4295,8 @@ static struct attribute *slab_attrs[] = 
 	&objs_per_slab_attr.attr,
 	&order_attr.attr,
 	&min_partial_attr.attr,
+	&cpu_queue_size_attr.attr,
+	&cpu_batch_size_attr.attr,
 	&objects_attr.attr,
 	&objects_partial_attr.attr,
 	&total_objects_attr.attr,
@@ -4552,7 +4654,7 @@ static int s_show(struct seq_file *m, vo
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
--- linux-2.6.orig/include/linux/slub_def.h	2010-04-29 12:35:03.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-04-29 16:18:22.000000000 -0500
@@ -76,6 +76,8 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
 	struct kmem_cache_order_objects oo;
+	int queue;		/* per cpu queue size */
+	int batch;		/* Batch size */
 	/*
 	 * Avoid an extra cache line for UP, SMP and for the node local to
 	 * struct kmem_cache.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

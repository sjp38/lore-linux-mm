Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D871C6008F3
	for <linux-mm@kvack.org>; Fri, 21 May 2010 17:19:02 -0400 (EDT)
Message-Id: <20100521211544.174575855@quilx.com>
Date: Fri, 21 May 2010 16:15:04 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC V2 SLEB 12/14] SLEB: Make the size of the shared cache configurable
References: <20100521211452.659982351@quilx.com>
Content-Disposition: inline; filename=sled_shared_dynamic
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This makes the size of the shared array configurable. Not that this is a bit
problematic and there are likely unresolved race conditions. The kmem_cache->node[x]
pointers become unstable if interrupts are allowed.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |    3 +
 mm/slub.c                |  133 +++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 116 insertions(+), 20 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-05-21 13:17:14.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-05-21 13:47:41.000000000 -0500
@@ -81,11 +81,14 @@ struct kmem_cache {
 	struct kmem_cache_order_objects oo;
 	int queue;		/* per cpu queue size */
 	int batch;		/* batch size */
+	int shared;		/* Shared queue size */
+#ifndef CONFIG_NUMA
 	/*
 	 * Avoid an extra cache line for UP, SMP and for the node local to
 	 * struct kmem_cache.
 	 */
 	struct kmem_cache_node local_node;
+#endif
 
 	/* Allocation and freeing of slabs */
 	struct kmem_cache_order_objects max;
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-05-21 13:17:14.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-05-21 13:48:01.000000000 -0500
@@ -1754,7 +1754,7 @@ redo:
 				int d;
 
 				spin_lock(&n->shared_lock);
-				d = min(min(s->batch, BOOT_QUEUE_SIZE), n->objects);
+				d = min(min(s->batch, s->shared), n->objects);
 				if (d > 0) {
 					memcpy(c->object + c->objects,
 						n->object + n->objects - d,
@@ -1864,6 +1864,7 @@ void *kmem_cache_alloc_node(struct kmem_
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
+
 #endif
 
 #ifdef CONFIG_TRACING
@@ -2176,10 +2177,7 @@ static void free_kmem_cache_nodes(struct
 	int node;
 
 	for_each_node_state(node, N_NORMAL_MEMORY) {
-		struct kmem_cache_node *n = s->node[node];
-
-		if (n && n != &s->local_node)
-			kfree(n);
+		kfree(s->node[node]);
 		s->node[node] = NULL;
 	}
 }
@@ -2197,27 +2195,96 @@ static int init_kmem_cache_nodes(struct 
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n;
 
-		if (local_node == node)
-			n = &s->local_node;
-		else {
-			if (slab_state == DOWN) {
-				early_kmem_cache_node_alloc(gfpflags, node);
-				continue;
-			}
-			n = kmalloc_node(sizeof(struct kmem_cache_node), gfpflags,
-				node);
-
-			if (!n) {
-				free_kmem_cache_nodes(s);
-				return 0;
-			}
+		if (slab_state == DOWN) {
+			early_kmem_cache_node_alloc(gfpflags, node);
+			continue;
+		}
+		n = kmalloc_node(sizeof(struct kmem_cache_node), gfpflags,
+			node);
 
+		if (!n) {
+			free_kmem_cache_nodes(s);
+			return 0;
 		}
 		s->node[node] = n;
 		init_kmem_cache_node(n, s);
 	}
 	return 1;
 }
+
+static void resize_shared_queue(struct kmem_cache *s, int shared)
+{
+
+	if (is_kmalloc_cache(s)) {
+		if (shared < BOOT_QUEUE_SIZE) {
+			s->shared = shared;
+		} else {
+			/* More than max. Go to max allowed */
+			s->queue = BOOT_QUEUE_SIZE;
+			s->batch = BOOT_BATCH_SIZE;
+		}
+	} else {
+		int node;
+
+		/* Create the new cpu queue and then free the old one */
+		down_write(&slub_lock);
+
+		/* We can only shrink the queue here since the new
+		 * queue size may be smaller and there may be concurrent
+		 * slab operations. The upate of the queue must be seen
+		 * before the change of the location of the percpu queue.
+		 *
+		 * Note that the queue may contain more object than the
+		 * queue size after this operation.
+		 */
+		if (shared < s->shared) {
+			s->shared = shared;
+			barrier();
+		}
+
+
+		/* Serialization has not been worked out yet */
+		for_each_online_node(node) {
+			struct kmem_cache_node *n = get_node(s, node);
+			struct kmem_cache_node *nn =
+				kmalloc_node(sizeof(struct kmem_cache_node),
+					GFP_KERNEL, node);
+
+			init_kmem_cache_node(nn, s);
+			s->node[node] = nn;
+
+			spin_lock(&nn->list_lock);
+			list_move(&n->partial, &nn->partial);
+#ifdef CONFIG_SLUB_DEBUG
+			list_move(&n->full, &nn->full);
+#endif
+			spin_unlock(&nn->list_lock);
+
+			nn->nr_partial = n->nr_partial;
+#ifdef CONFIG_SLUB_DEBUG
+			nn->nr_slabs = n->nr_slabs;
+			nn->total_objects = n->total_objects;
+#endif
+
+			spin_lock(&nn->shared_lock);
+			nn->objects = n->objects;
+			memcpy(&nn->object, n->object, nn->objects * sizeof(void *));
+			spin_unlock(&nn->shared_lock);
+
+			kfree(n);
+		}
+		/*
+		 * If the queue needs to be extended then we deferred
+		 * the update until now when the larger sized queue
+		 * has been allocated and is working.
+		 */
+		if (shared > s->shared)
+			s->shared = shared;
+
+		up_write(&slub_lock);
+	}
+}
+
 #else
 static void free_kmem_cache_nodes(struct kmem_cache *s)
 {
@@ -3989,6 +4056,31 @@ static ssize_t cpu_queue_size_store(stru
 }
 SLAB_ATTR(cpu_queue_size);
 
+#ifdef CONFIG_NUMA
+static ssize_t shared_queue_size_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%u\n", s->shared);
+}
+
+static ssize_t shared_queue_size_store(struct kmem_cache *s,
+			 const char *buf, size_t length)
+{
+	unsigned long queue;
+	int err;
+
+	err = strict_strtoul(buf, 10, &queue);
+	if (err)
+		return err;
+
+	if (queue > 10000 || queue < s->batch)
+		return -EINVAL;
+
+	resize_shared_queue(s, queue);
+	return length;
+}
+SLAB_ATTR(shared_queue_size);
+#endif
+
 static ssize_t cpu_batch_size_show(struct kmem_cache *s, char *buf)
 {
 	return sprintf(buf, "%u\n", s->batch);
@@ -4388,6 +4480,7 @@ static struct attribute *slab_attrs[] = 
 	&cache_dma_attr.attr,
 #endif
 #ifdef CONFIG_NUMA
+	&shared_queue_size_attr.attr,
 	&remote_node_defrag_ratio_attr.attr,
 #endif
 #ifdef CONFIG_SLUB_STATS
@@ -4720,7 +4813,7 @@ static int s_show(struct seq_file *m, vo
 	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d", s->name, nr_inuse,
 		   nr_objs, s->size, oo_objects(s->oo),
 		   (1 << oo_order(s->oo)));
-	seq_printf(m, " : tunables %4u %4u %4u", s->queue, s->batch, 0);
+	seq_printf(m, " : tunables %4u %4u %4u", s->queue, s->batch, s->shared);
 	seq_printf(m, " : slabdata %6lu %6lu %6lu", nr_slabs, nr_slabs,
 		   0UL);
 	seq_putc(m, '\n');

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

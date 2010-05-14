Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0C1066B01F1
	for <linux-mm@kvack.org>; Fri, 14 May 2010 14:43:07 -0400 (EDT)
Message-Id: <20100514183947.800937046@quilx.com>
References: <20100514183908.118952419@quilx.com>
Date: Fri, 14 May 2010 13:39:18 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC SLEB 10/10] SLEB: Add shared cache
Content-Disposition: inline; filename=sled_shared_static
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add support for a shared cache like SLAB

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |    3 +++
 mm/slub.c                |   41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-04-29 16:18:22.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-04-29 16:18:54.000000000 -0500
@@ -55,6 +55,9 @@ struct kmem_cache_node {
 	atomic_long_t total_objects;
 	struct list_head full;
 #endif
+	int objects;
+	spinlock_t shared_lock;
+	void *object[BOOT_QUEUE_SIZE];
 };
 
 /*
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-04-29 16:18:43.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-04-29 16:18:54.000000000 -0500
@@ -1418,6 +1418,22 @@ static struct page *get_partial(struct k
 void drain_objects(struct kmem_cache *s, void **object, int nr)
 {
 	int i;
+	struct kmem_cache_node *n = get_node(s, numa_node_id());
+
+	/* First drain to shared cache if its there */
+	if (n->objects < BOOT_QUEUE_SIZE) {
+		int d;
+
+		spin_lock(&n->shared_lock);
+		d = min(nr, BOOT_QUEUE_SIZE - n->objects);
+		if (d > 0) {
+			memcpy(n->object + n->objects, object, d * sizeof(void *));
+			n->objects += d;
+			nr -= d;
+			object += d;
+		}
+		spin_unlock(&n->shared_lock);
+	}
 
 	for (i = 0 ; i < nr; ) {
 
@@ -1697,6 +1713,29 @@ redo:
 		if (unlikely(!node_match(c, node))) {
 			flush_cpu_objects(s, c);
 			c->node = node;
+		} else {
+			struct kmem_cache_node *n = get_node(s, c->node);
+
+			/*
+			 * Node specified is matching the stuff that we cache,
+			 * so we could retrieve objects from the shared cache
+			 * of the indicated node if there would be anything
+			 * there.
+			 */
+			if (n->objects) {
+				int d;
+
+				spin_lock(&n->shared_lock);
+				d = min(min(s->batch, BOOT_QUEUE_SIZE), n->objects);
+				if (d > 0) {
+					memcpy(c->object + c->objects,
+						n->object + n->objects - d,
+						d * sizeof(void *));
+					n->objects -= d;
+					c->objects += d;
+				}
+				spin_unlock(&n->shared_lock);
+			}
 		}
 
 		while (c->objects < s->batch) {
@@ -2033,6 +2072,8 @@ init_kmem_cache_node(struct kmem_cache_n
 	atomic_long_set(&n->total_objects, 0);
 	INIT_LIST_HEAD(&n->full);
 #endif
+	spin_lock_init(&n->shared_lock);
+	n->objects = 0;
 }
 
 static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

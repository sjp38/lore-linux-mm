Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 582536B0088
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:58:21 -0400 (EDT)
Message-Id: <20101005185818.197815472@linux.com>
Date: Tue, 05 Oct 2010 13:57:36 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 11/16] slub: Add a "touched" state to queues and partial lists
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=unified_touched
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

Add a "touched" state in preparation for the implementation of cache
expiration.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |   10 +++++----
 mm/slub.c                |   51 ++++++++++++++++++++++++++++++++++-------------
 2 files changed, 43 insertions(+), 18 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-10-05 13:36:33.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-10-05 13:39:59.000000000 -0500
@@ -52,11 +52,12 @@ enum stat_item {
  * the per cpu queue.
  */
 struct kmem_cache_queue {
-	int objects;		/* Available objects */
-	int max;		/* Queue capacity */
+	int objects;			/* Available objects */
+	unsigned short max;		/* Queue capacity */
+	unsigned short touched;		/* Cache was touched */
 	union {
 		struct kmem_cache_queue *shared; /* cpu q -> shared q */
-		spinlock_t lock;	  /* shared queue: lock */
+		spinlock_t lock;	/* shared queue: lock */
 		spinlock_t alien_lock;	/* alien cache lock */
 	};
 	void *object[];
@@ -72,7 +73,8 @@ struct kmem_cache_cpu {
 
 struct kmem_cache_node {
 	spinlock_t lock;	/* Protocts slab metadata on a node */
-	unsigned long nr_partial;
+	unsigned touched;
+	unsigned nr_partial;
 	struct list_head partial;
 #ifdef CONFIG_SLUB_DEBUG
 	atomic_long_t nr_slabs;
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-05 13:39:26.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-05 13:39:59.000000000 -0500
@@ -1291,12 +1291,14 @@ static void add_partial(struct kmem_cach
 	else
 		list_add(&page->lru, &n->partial);
 	__SetPageSlubPartial(page);
+	n->touched = 1;
 }
 
 static inline void remove_partial(struct kmem_cache_node *n,
 					struct page *page)
 {
 	n->nr_partial--;
+	n->touched = 1;
 	list_del(&page->lru);
 	__ClearPageSlubPartial(page);
 }
@@ -1445,6 +1447,7 @@ static inline int drain_queue(struct kme
 	drain_objects(s, q->object, t);
 
 	q->objects -= t;
+	q->touched = 0;
 	if (q->objects)
 		memcpy(q->object, q->object + t,
 					q->objects * sizeof(void *));
@@ -1553,17 +1556,18 @@ static inline void init_shared_cache(str
 {
 	spin_lock_init(&q->lock);
 	q->max = max;
-	q->objects =0;
+	q->objects = 0;
+	q->touched = 0;
 }
 
 static inline void init_alien_cache(struct kmem_cache_queue *q, int max)
 {
 	spin_lock_init(&q->alien_lock);
 	q->max = max;
-	q->objects =0;
+	q->objects = 0;
+	q->touched = 0;
 }
 
-
 /* Determine a list of the active shared caches */
 struct kmem_cache_queue **shared_caches(struct kmem_cache *s)
 {
@@ -2000,6 +2004,7 @@ redo:
 		spin_lock(&a->lock);
 		if (likely(!queue_empty(a))) {
 			object = queue_get(a);
+			a->touched = 1;
 			spin_unlock(&a->lock);
 			stat(s, ALLOC_ALIEN);
 			return object;
@@ -2079,20 +2084,21 @@ static void slab_free_alien(struct kmem_
 	struct kmem_cache_queue *a = alien_cache(s, c, node);
 
 	if (a) {
-		int slow = 0;
+		int touched = 1;
 
 		spin_lock(&a->lock);
 		while (unlikely(queue_full(a))) {
 			drain_queue(s, a, s->batch);
-			slow = 1;
+			touched = 0;
 		}
 		queue_put(a, object);
 		spin_unlock(&a->lock);
 
-		if (slow)
-			stat(s, FREE_SLOWPATH);
-		else
+		a->touched = touched;
+		if (touched)
 			stat(s, FREE_ALIEN);
+		else
+			stat(s, FREE_SLOWPATH);
 
 	} else {
 		/* Direct free to the slab */
@@ -2112,6 +2118,7 @@ static void *slab_alloc(struct kmem_cach
 	struct kmem_cache_queue *q;
 	struct kmem_cache_node *n;
 	struct page *page;
+	int batch;
 	unsigned long flags;
 
 	if (slab_pre_alloc_hook(s, gfpflags))
@@ -2136,6 +2143,7 @@ redo:
 
 get_object:
 		object = queue_get(q);
+		q->touched = 1;
 
 got_object:
 		if (kmem_cache_debug(s)) {
@@ -2152,6 +2160,10 @@ got_object:
 		return object;
 	}
 
+	batch = s->batch;
+	if (!q->touched && batch > 16)
+		batch = 16;
+
 	if (q->shared) {
 		/*
 		 * Refill the cpu queue with the hottest objects
@@ -2161,9 +2173,10 @@ got_object:
 		int d = 0;
 
 		spin_lock(&l->lock);
-		d = min(l->objects, s->batch);
+		d = min(l->objects, batch);
 
 		l->objects -= d;
+		l->touched = 1;
 		memcpy(q->object, l->object + l->objects,
 						d * sizeof(void *));
 		spin_unlock(&l->lock);
@@ -2180,11 +2193,11 @@ got_object:
 
 	/* Refill from partial lists */
 	spin_lock(&n->lock);
-	while (q->objects < s->batch && !list_empty(&n->partial)) {
+	while (q->objects < batch && !list_empty(&n->partial)) {
 		page = list_entry(n->partial.next, struct page, lru);
 
 		refill_queue(s, q, page, min(available(page),
-					s->batch - q->objects));
+					batch - q->objects));
 
 		if (all_objects_used(page))
 			partial_to_full(s, n, page);
@@ -2199,7 +2212,7 @@ got_object:
 
 	gfpflags &= gfp_allowed_mask;
 	/* Refill from free pages */
-	while (q->objects < s->batch) {
+	while (q->objects < batch) {
 		int tail = 0;
 
 		if (gfpflags & __GFP_WAIT)
@@ -2226,7 +2239,7 @@ got_object:
 		 * the partial list if so.
 		 */
 		if (q->objects < s->batch)
-			refill_queue(s, q, page, min_t(int, page->objects, s->batch));
+			refill_queue(s, q, page, min_t(int, page->objects, batch));
 		else
 			tail = 1;
 
@@ -2304,6 +2317,7 @@ static void slab_free(struct kmem_cache 
 	struct kmem_cache_cpu *c;
 	struct kmem_cache_queue *q;
 	unsigned long flags;
+	int touched = 1;
 
 	slab_free_hook(s, x);
 
@@ -2339,6 +2353,7 @@ static void slab_free(struct kmem_cache 
 			memcpy(l->object + l->objects, q->object,
 						d * sizeof(void *));
 			l->objects += d;
+			l->touched = 1;
 			spin_unlock(&l->lock);
 
 			q->objects -= d;
@@ -2353,10 +2368,12 @@ static void slab_free(struct kmem_cache 
 			drain_queue(s, q, s->batch);
 			stat(s, FREE_SLOWPATH);
 		}
+		touched = 0;
 	} else
 		stat(s, FREE_FASTPATH);
 
 	queue_put(q, x);
+	q->touched = touched;
 out:
 	local_irq_restore(flags);
 }
@@ -3924,7 +3941,7 @@ static int validate_slab_node(struct kme
 	}
 	if (count != n->nr_partial)
 		printk(KERN_ERR "SLUB %s: %ld partial slabs counted but "
-			"counter=%ld\n", s->name, count, n->nr_partial);
+			"counter=%d\n", s->name, count, n->nr_partial);
 
 	if (!(s->flags & SLAB_STORE_USER))
 		goto out;
@@ -4549,6 +4566,8 @@ static ssize_t shared_caches_show(struct
 			x += sprintf(buf + x, "%d", cpu);
 		}
 		x += sprintf(buf +x, "=%d/%d", q->objects, q->max);
+		if (!q->touched)
+			x += sprintf(buf + x,"*");
 	}
 	up_read(&slub_lock);
 	kfree(caches);
@@ -4604,6 +4623,8 @@ static ssize_t per_cpu_caches_show(struc
 		struct kmem_cache_queue *q = &c->q;
 
 		x += sprintf(buf + x, " C%d=%u/%u", cpu, q->objects, q->max);
+		if (!q->touched)
+			x += sprintf(buf + x,"*");
 	}
 	up_read(&slub_lock);
 	kfree(cpus);
@@ -4772,6 +4793,8 @@ static ssize_t alien_caches_show(struct 
 
 				x += sprintf(buf + x, "N%d=%d/%d",
 						node, a->objects, a->max);
+				if (!a->touched)
+					x += sprintf(buf + x,"*");
 			}
 		}
 		x += sprintf(buf + x, "]");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id AD7A390010C
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:38 -0400 (EDT)
Message-Id: <20110516202635.739312612@linux.com>
Date: Mon, 16 May 2011 15:26:30 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 25/25] slub: Remove gotos from __slab_alloc()
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=degotofy_slab_alloc
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |  155 ++++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 87 insertions(+), 68 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-16 15:00:46.511449498 -0500
+++ linux-2.6/mm/slub.c	2011-05-16 15:07:01.241449060 -0500
@@ -1942,6 +1942,64 @@ static inline void *new_slab_objects(str
 	return object;
 }
 
+/* Check if the current slab page is matching NUMA requirements. If not deactivate slab */
+static inline int node_is_matching(struct kmem_cache *s, struct kmem_cache_cpu *c, int node)
+{
+	if (!c->page)
+		return 0;
+
+	if (!node_match(c, node)) {
+		stat(s, ALLOC_NODE_MISMATCH);
+		deactivate_slab(s, c);
+		return 0;
+	} else
+		return 1;
+}
+
+/*
+ * Retrieve the page freelist locklessly.
+ *
+ * Return NULL and deactivate the current slab if no objects are available.
+ */
+static inline void *get_freelist(struct kmem_cache *s, struct kmem_cache_cpu *c)
+{
+	struct page new;
+	unsigned long counters;
+	void *object;
+
+	do {
+		object = c->page->freelist;
+		counters = c->page->counters;
+		new.counters = counters;
+		VM_BUG_ON(!new.frozen);
+
+		/*
+		 * If there is no object left then we use this loop to
+		 * deactivate the slab which is simple since no objects
+		 * are left in the slab and therefore we do not need to
+		 * put the page back onto the partial list.
+		 *
+		 * If there are objects left then we retrieve them
+		 * and use them to refill the per cpu queue.
+		 */
+
+		new.inuse = c->page->objects;
+		new.frozen = object != NULL;
+
+	} while (!cmpxchg_double_slab(s, c->page,
+			object, counters,
+			NULL, new.counters,
+			"__slab_alloc"));
+
+	if (unlikely(!object)) {
+		c->page = NULL;
+		stat(s, DEACTIVATE_BYPASS);
+	} else
+		stat(s, ALLOC_REFILL);
+
+	return object;
+}
+
 /*
  * Slow path. The lockless freelist is empty or we need to perform
  * debugging duties.
@@ -1963,10 +2021,8 @@ static inline void *new_slab_objects(str
 static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 			  unsigned long addr, struct kmem_cache_cpu *c)
 {
-	void **object;
+	void *object;
 	unsigned long flags;
-	struct page new;
-	unsigned long counters;
 
 	local_irq_save(flags);
 #ifdef CONFIG_PREEMPT
@@ -1981,81 +2037,44 @@ static void *__slab_alloc(struct kmem_ca
 	/* We handle __GFP_ZERO in the caller */
 	gfpflags &= ~__GFP_ZERO;
 
-	if (!c->page)
-		goto new_slab;
-
-	if (unlikely(!node_match(c, node))) {
-		stat(s, ALLOC_NODE_MISMATCH);
-		deactivate_slab(s, c);
-		goto new_slab;
-	}
-
-	stat(s, ALLOC_SLOWPATH);
-
-	do {
-		object = c->page->freelist;
-		counters = c->page->counters;
-		new.counters = counters;
-		VM_BUG_ON(!new.frozen);
-
-		/*
-		 * If there is no object left then we use this loop to
-		 * deactivate the slab which is simple since no objects
-		 * are left in the slab and therefore we do not need to
-		 * put the page back onto the partial list.
-		 *
-		 * If there are objects left then we retrieve them
-		 * and use them to refill the per cpu queue.
-		 */
-
-		new.inuse = c->page->objects;
-		new.frozen = object != NULL;
-
-	} while (!cmpxchg_double_slab(s, c->page,
-			object, counters,
-			NULL, new.counters,
-			"__slab_alloc"));
-
-	if (unlikely(!object)) {
-		c->page = NULL;
-		stat(s, DEACTIVATE_BYPASS);
-		goto new_slab;
-	}
+	if (node_is_matching(s, c, node) && (object = get_freelist(s, c))) {
 
-	stat(s, ALLOC_REFILL);
+		c->freelist = get_freepointer(s, object);
+		c->tid = next_tid(c->tid);
 
-load_freelist:
-	c->freelist = get_freepointer(s, object);
-	c->tid = next_tid(c->tid);
-	local_irq_restore(flags);
-	return object;
+	} else
+	while (1) {
+		object = get_partial(s, gfpflags, node, c);
 
-new_slab:
-	object = get_partial(s, gfpflags, node, c);
+		if (unlikely(!object)) {
 
-	if (unlikely(!object)) {
+			object = new_slab_objects(s, gfpflags, node, &c);
 
-		object = new_slab_objects(s, gfpflags, node, &c);
+			if (unlikely(!object)) {
+				if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
+					slab_out_of_memory(s, gfpflags, node);
+				break;
+			}
+		}
 
-		if (unlikely(!object)) {
-			if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
-				slab_out_of_memory(s, gfpflags, node);
+		if (likely(!kmem_cache_debug(s))) {
 
-			local_irq_restore(flags);
-			return NULL;
+			c->freelist = get_freepointer(s, object);
+			c->tid = next_tid(c->tid);
+			break;
+
+		} else {
+			/* Only entered in the debug case */
+			if (alloc_debug_processing(s, c->page, object, addr)) {
+
+				c->freelist = get_freepointer(s, object);
+				deactivate_slab(s, c);
+				c->node = NUMA_NO_NODE;
+				break;
+			}
 		}
 	}
 
-	if (likely(!kmem_cache_debug(s)))
-		goto load_freelist;
-
-	/* Only entered in the debug case */
-	if (!alloc_debug_processing(s, c->page, object, addr))
-		goto new_slab;	/* Slab failed checks. Next slab needed */
-
-	c->freelist = get_freepointer(s, object);
-	deactivate_slab(s, c);
-	c->node = NUMA_NO_NODE;
 	local_irq_restore(flags);
 	return object;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

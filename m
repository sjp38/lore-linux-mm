Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7CEF96B0032
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:37 -0400 (EDT)
Message-Id: <20110516202634.597471664@linux.com>
Date: Mon, 16 May 2011 15:26:28 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 23/25] slub: return object pointer from get_partial() / new_slab().
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=object_instead_of_page_return
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

There is no need anymore to return the pointer to a slab page from get_partial()
since it can be assigned to the kmem_cache_cpu structures "page" field.

Instead return an object pointer.

That in turn allows a simplification of the spaghetti code in __slab_alloc().

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |  130 ++++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 73 insertions(+), 57 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-16 14:11:37.531452935 -0500
+++ linux-2.6/mm/slub.c	2011-05-16 14:24:19.781452046 -0500
@@ -1434,9 +1434,11 @@ static inline void remove_partial(struct
  * Lock slab, remove from the partial list and put the object into the
  * per cpu freelist.
  *
+ * Returns a list of objects or NULL if it fails.
+ *
  * Must hold list_lock.
  */
-static inline int acquire_slab(struct kmem_cache *s,
+static inline void *acquire_slab(struct kmem_cache *s,
 		struct kmem_cache_node *n, struct page *page,
 		struct kmem_cache_cpu *c)
 {
@@ -1467,10 +1469,11 @@ static inline int acquire_slab(struct km
 
 	if (freelist) {
 		/* Populate the per cpu freelist */
-		c->freelist = freelist;
 		c->page = page;
 		c->node = page_to_nid(page);
-		return 1;
+		stat(s, ALLOC_FROM_PARTIAL);
+
+		return freelist;
 	} else {
 		/*
 		 * Slab page came from the wrong list. No object to allocate
@@ -1479,17 +1482,18 @@ static inline int acquire_slab(struct km
 		 */
 		printk(KERN_ERR "SLUB: %s : Page without available objects on"
 			" partial list\n", s->name);
-		return 0;
+		return NULL;
 	}
 }
 
 /*
  * Try to allocate a partial slab from a specific node.
  */
-static struct page *get_partial_node(struct kmem_cache *s,
+static void *get_partial_node(struct kmem_cache *s,
 		struct kmem_cache_node *n, struct kmem_cache_cpu *c)
 {
 	struct page *page;
+	void *object;
 
 	/*
 	 * Racy check. If we mistakenly see no partial slabs then we
@@ -1501,13 +1505,15 @@ static struct page *get_partial_node(str
 		return NULL;
 
 	spin_lock(&n->list_lock);
-	list_for_each_entry(page, &n->partial, lru)
-		if (acquire_slab(s, n, page, c))
+	list_for_each_entry(page, &n->partial, lru) {
+		object = acquire_slab(s, n, page, c);
+		if (object)
 			goto out;
-	page = NULL;
+	}
+	object = NULL;
 out:
 	spin_unlock(&n->list_lock);
-	return page;
+	return object;
 }
 
 /*
@@ -1521,7 +1527,7 @@ static struct page *get_any_partial(stru
 	struct zoneref *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
-	struct page *page;
+	void *object;
 
 	/*
 	 * The defrag ratio allows a configuration of the tradeoffs between
@@ -1554,10 +1560,10 @@ static struct page *get_any_partial(stru
 
 		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 				n->nr_partial > s->min_partial) {
-			page = get_partial_node(s, n, c);
-			if (page) {
+			object = get_partial_node(s, n, c);
+			if (object) {
 				put_mems_allowed();
-				return page;
+				return object;
 			}
 		}
 	}
@@ -1569,15 +1575,15 @@ static struct page *get_any_partial(stru
 /*
  * Get a partial page, lock it and return it.
  */
-static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node,
+static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
 		struct kmem_cache_cpu *c)
 {
-	struct page *page;
+	void *object;
 	int searchnode = (node == NUMA_NO_NODE) ? numa_node_id() : node;
 
-	page = get_partial_node(s, get_node(s, searchnode), c);
-	if (page || node != NUMA_NO_NODE)
-		return page;
+	object = get_partial_node(s, get_node(s, searchnode), c);
+	if (object || node != NUMA_NO_NODE)
+		return object;
 
 	return get_any_partial(s, flags, c);
 }
@@ -1907,6 +1913,35 @@ slab_out_of_memory(struct kmem_cache *s,
 	}
 }
 
+static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
+			int node, struct kmem_cache_cpu **pc)
+{
+	void *object;
+	struct kmem_cache_cpu *c;
+	struct page *page = new_slab(s, flags, node);
+
+	if (page) {
+		c = __this_cpu_ptr(s->cpu_slab);
+		if (c->page)
+			flush_slab(s, c);
+
+		/*
+		 * No other reference to the page yet so we can
+		 * muck around with it freely without cmpxchg
+		 */
+		object = page->freelist;
+		page->freelist = NULL;
+
+		stat(s, ALLOC_SLAB);
+		c->node = page_to_nid(page);
+		c->page = page;
+		*pc = c;
+	} else
+		object = NULL;
+
+	return object;
+}
+
 /*
  * Slow path. The lockless freelist is empty or we need to perform
  * debugging duties.
@@ -1929,7 +1964,6 @@ static void *__slab_alloc(struct kmem_ca
 			  unsigned long addr, struct kmem_cache_cpu *c)
 {
 	void **object;
-	struct page *page;
 	unsigned long flags;
 	struct page new;
 	unsigned long counters;
@@ -1947,8 +1981,7 @@ static void *__slab_alloc(struct kmem_ca
 	/* We handle __GFP_ZERO in the caller */
 	gfpflags &= ~__GFP_ZERO;
 
-	page = c->page;
-	if (!page)
+	if (!c->page)
 		goto new_slab;
 
 	if (unlikely(!node_match(c, node))) {
@@ -1960,8 +1993,8 @@ static void *__slab_alloc(struct kmem_ca
 	stat(s, ALLOC_SLOWPATH);
 
 	do {
-		object = page->freelist;
-		counters = page->counters;
+		object = c->page->freelist;
+		counters = c->page->counters;
 		new.counters = counters;
 		VM_BUG_ON(!new.frozen);
 
@@ -1973,12 +2006,12 @@ static void *__slab_alloc(struct kmem_ca
 		 *
 		 * If there are objects left then we retrieve them
 		 * and use them to refill the per cpu queue.
-		*/
+		 */
 
-		new.inuse = page->objects;
+		new.inuse = c->page->objects;
 		new.frozen = object != NULL;
 
-	} while (!cmpxchg_double_slab(s, page,
+	} while (!cmpxchg_double_slab(s, c->page,
 			object, counters,
 			NULL, new.counters,
 			"__slab_alloc"));
@@ -1992,50 +2025,33 @@ static void *__slab_alloc(struct kmem_ca
 	stat(s, ALLOC_REFILL);
 
 load_freelist:
-	VM_BUG_ON(!page->frozen);
 	c->freelist = get_freepointer(s, object);
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);
 	return object;
 
 new_slab:
-	page = get_partial(s, gfpflags, node, c);
-	if (page) {
-		stat(s, ALLOC_FROM_PARTIAL);
-		object = c->freelist;
+	object = get_partial(s, gfpflags, node, c);
 
-		if (kmem_cache_debug(s))
-			goto debug;
-		goto load_freelist;
-	}
+	if (unlikely(!object)) {
 
-	page = new_slab(s, gfpflags, node);
+		object = new_slab_objects(s, gfpflags, node, &c);
 
-	if (page) {
-		c = __this_cpu_ptr(s->cpu_slab);
-		if (c->page)
-			flush_slab(s, c);
+		if (unlikely(!object)) {
+			if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
+				slab_out_of_memory(s, gfpflags, node);
 
-		/*
-		 * No other reference to the page yet so we can
-		 * muck around with it freely without cmpxchg
-		 */
-		object = page->freelist;
-		page->freelist = NULL;
+			local_irq_restore(flags);
+			return NULL;
+		}
+	}
 
-		stat(s, ALLOC_SLAB);
-		c->node = page_to_nid(page);
-		c->page = page;
+	if (likely(!kmem_cache_debug(s)))
 		goto load_freelist;
-	}
-	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
-		slab_out_of_memory(s, gfpflags, node);
-	local_irq_restore(flags);
-	return NULL;
 
-debug:
-	if (!object || !alloc_debug_processing(s, page, object, addr))
-		goto new_slab;
+	/* Only entered in the debug case */
+	if (!alloc_debug_processing(s, c->page, object, addr))
+		goto new_slab;	/* Slab failed checks. Next slab needed */
 
 	c->freelist = get_freepointer(s, object);
 	deactivate_slab(s, c);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

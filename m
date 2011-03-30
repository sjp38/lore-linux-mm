Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C995B8D004C
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:24:26 -0400 (EDT)
Message-Id: <20110330202423.327243730@linux.com>
Date: Wed, 30 Mar 2011 15:23:55 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubll1 13/19] slub: Rework allocator fastpaths
References: <20110330202342.669400887@linux.com>
Content-Disposition: inline; filename=rework_fastpaths
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

Rework the allocation paths so that updates of the page freelist, frozen state
and number of objects use cmpxchg_double_slab().

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |  422 ++++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 292 insertions(+), 130 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-03-30 14:42:58.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-03-30 14:43:01.000000000 -0500
@@ -974,11 +974,6 @@ static noinline int alloc_debug_processi
 	if (!check_slab(s, page))
 		goto bad;
 
-	if (!on_freelist(s, page, object)) {
-		object_err(s, page, object, "Object already allocated");
-		goto bad;
-	}
-
 	if (!check_valid_pointer(s, page, object)) {
 		object_err(s, page, object, "Freelist Pointer check fails");
 		goto bad;
@@ -1042,14 +1037,6 @@ static noinline int free_debug_processin
 		goto fail;
 	}
 
-	/* Special debug activities for freeing objects */
-	if (!page->frozen && !page->freelist) {
-		struct kmem_cache_node *n = get_node(s, page_to_nid(page));
-
-		spin_lock(&n->list_lock);
-		remove_full(s, page);
-		spin_unlock(&n->list_lock);
-	}
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_FREE, addr);
 	trace(s, page, object, 0);
@@ -1426,11 +1413,52 @@ static inline void remove_partial(struct
 static inline int lock_and_freeze_slab(struct kmem_cache *s,
 		struct kmem_cache_node *n, struct page *page)
 {
-	if (slab_trylock(page)) {
-		remove_partial(n, page);
+	void *freelist;
+	unsigned long counters;
+	struct page new;
+
+
+	if (!slab_trylock(page))
+		return 0;
+
+	/*
+	 * Zap the freelist and set the frozen bit.
+	 * The old freelist is the list of objects for the
+	 * per cpu allocation list.
+	 */
+	do {
+		freelist = page->freelist;
+		counters = page->counters;
+		new.counters = counters;
+		new.inuse = page->objects;
+
+		VM_BUG_ON(new.frozen);
+		new.frozen = 1;
+
+	} while (!cmpxchg_double_slab(s, page,
+			freelist, counters,
+			NULL, new.counters,
+			"lock and freeze"));
+
+	remove_partial(n, page);
+
+	if (freelist) {
+		/* Populate the per cpu freelist */
+		this_cpu_write(s->cpu_slab->freelist, freelist);
+		this_cpu_write(s->cpu_slab->page, page);
+		this_cpu_write(s->cpu_slab->node, page_to_nid(page));
 		return 1;
+	} else {
+		/*
+		 * Slab page came from the wrong list. No object to allocate
+		 * from. Put it onto the correct list and continue partial
+		 * scan.
+		 */
+		printk(KERN_ERR "SLUB: %s : Page without available objects on"
+			" partial list\n", s->name);
+		slab_unlock(page);
+		return 0;
 	}
-	return 0;
 }
 
 /*
@@ -1530,59 +1558,6 @@ static struct page *get_partial(struct k
 	return get_any_partial(s, flags);
 }
 
-/*
- * Move a page back to the lists.
- *
- * Must be called with the slab lock held.
- *
- * On exit the slab lock will have been dropped.
- */
-static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
-	__releases(bitlock)
-{
-	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
-
-	if (page->inuse) {
-
-		if (page->freelist) {
-			spin_lock(&n->list_lock);
-			add_partial(n, page, tail);
-			spin_unlock(&n->list_lock);
-			stat(s, tail ? DEACTIVATE_TO_TAIL : DEACTIVATE_TO_HEAD);
-		} else {
-			stat(s, DEACTIVATE_FULL);
-			if (kmem_cache_debug(s) && (s->flags & SLAB_STORE_USER)) {
-				spin_lock(&n->list_lock);
-				add_full(s, n, page);
-				spin_unlock(&n->list_lock);
-			}
-		}
-		slab_unlock(page);
-	} else {
-		stat(s, DEACTIVATE_EMPTY);
-		if (n->nr_partial < s->min_partial) {
-			/*
-			 * Adding an empty slab to the partial slabs in order
-			 * to avoid page allocator overhead. This slab needs
-			 * to come after the other slabs with objects in
-			 * so that the others get filled first. That way the
-			 * size of the partial list stays small.
-			 *
-			 * kmem_cache_shrink can reclaim any empty slabs from
-			 * the partial list.
-			 */
-			spin_lock(&n->list_lock);
-			add_partial(n, page, 1);
-			spin_unlock(&n->list_lock);
-			slab_unlock(page);
-		} else {
-			slab_unlock(page);
-			stat(s, FREE_SLAB);
-			discard_slab(s, page);
-		}
-	}
-}
-
 #ifdef CONFIG_CMPXCHG_LOCAL
 #ifdef CONFIG_PREEMPT
 /*
@@ -1658,39 +1633,161 @@ void init_kmem_cache_cpus(struct kmem_ca
 /*
  * Remove the cpu slab
  */
+
+/*
+ * Remove the cpu slab
+ */
 static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
-	__releases(bitlock)
 {
+	enum slab_modes { M_NONE, M_PARTIAL, M_FULL, M_FREE };
 	struct page *page = c->page;
-	int tail = 1;
+	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+	int lock = 0;
+	enum slab_modes l = M_NONE, m;
+	void *freelist;
+	void *nextfree;
+	int tail = 0;
+	struct page new;
+	struct page old;
 
-	if (page->freelist)
+	if (page->freelist) {
 		stat(s, DEACTIVATE_REMOTE_FREES);
+		tail = 1;
+	}
+
+#ifdef CONFIG_CMPXCHG_LOCAL
+	c->tid = next_tid(c->tid);
+#endif
+	c->page = NULL;
+	freelist = c->freelist;
+	c->freelist = NULL;
+
+	/*
+	 * Stage one: Free all available per cpu objects back
+	 * to the page freelist while it is still frozen. Leave the
+	 * last one.
+	 *
+	 * There is no need to take the list->lock because the page
+	 * is still frozen.
+	 */
+	while (freelist && (nextfree = get_freepointer(s, freelist))) {
+		void *prior;
+		unsigned long counters;
+
+		do {
+			prior = page->freelist;
+			counters = page->counters;
+			set_freepointer(s, freelist, prior);
+			new.counters = counters;
+			new.inuse--;
+			VM_BUG_ON(!new.frozen);
+
+		} while (!cmpxchg_double_slab(s, page,
+			prior, counters,
+			freelist, new.counters,
+			"drain percpu freelist"));
+
+		freelist = nextfree;
+	}
+
 	/*
-	 * Merge cpu freelist into slab freelist. Typically we get here
-	 * because both freelists are empty. So this is unlikely
-	 * to occur.
+	 * Stage two: Ensure that the page is unfrozen while the
+	 * list presence reflects the actual number of objects
+	 * during unfreeze.
+	 *
+	 * We setup the list membership and then perform a cmpxchg
+	 * with the count. If there is a mismatch then the page
+	 * is not unfrozen but the page is on the wrong list.
+	 *
+	 * Then we restart the process which may have to remove
+	 * the page from the list that we just put it on again
+	 * because the number of objects in the slab may have
+	 * changed.
 	 */
-	while (unlikely(c->freelist)) {
-		void **object;
+redo:
 
-		tail = 0;	/* Hot objects. Put the slab first */
+	old.freelist = page->freelist;
+	old.counters = page->counters;
+	VM_BUG_ON(!old.frozen);
+
+	/* Determine target state of the slab */
+	new.counters = old.counters;
+	if (freelist) {
+		new.inuse--;
+		set_freepointer(s, freelist, old.freelist);
+		new.freelist = freelist;
+	} else
+		new.freelist = old.freelist;
 
-		/* Retrieve object from cpu_freelist */
-		object = c->freelist;
-		c->freelist = get_freepointer(s, c->freelist);
+	new.frozen = 0;
+
+	m = M_NONE;
+
+	if (!new.inuse && n->nr_partial < s->min_partial)
+		m = M_FREE;
+	else if (new.freelist) {
+		m = M_PARTIAL;
+		if (!lock) {
+			lock = 1;
+			/*
+			 * Taking the spinlock removes the possiblity
+			 * that acquire_slab() will see a slab page that
+			 * is frozen
+			 */
+			spin_lock(&n->list_lock);
+		}
+	} else {
+		m = M_FULL;
+		if (kmem_cache_debug(s) && !lock) {
+			lock = 1;
+			/*
+			 * This also ensures that the scanning of full
+			 * slabs from diagnostic functions will not see
+			 * any frozen slabs.
+			 */
+			spin_lock(&n->list_lock);
+		}
+	}
+
+	if (l != m) {
+
+		if (l == M_PARTIAL)
+
+			remove_partial(n, page);
+
+		else if (l == M_FULL)
+
+			remove_full(s, page);
+
+		if (m == M_PARTIAL) {
+
+			add_partial(n, page, tail);
+			stat(s, tail ? DEACTIVATE_TO_TAIL : DEACTIVATE_TO_HEAD);
+
+		} else if (m == M_FULL) {
+
+			stat(s, DEACTIVATE_FULL);
+			add_full(s, n, page);
 
-		/* And put onto the regular freelist */
-		set_freepointer(s, object, page->freelist);
-		page->freelist = object;
-		page->inuse--;
+		}
+	}
+
+	l = m;
+	if (!cmpxchg_double_slab(s, page,
+				old.freelist, old.counters,
+				new.freelist, new.counters,
+				"unfreezing slab"))
+		goto redo;
+
+	slab_unlock(page);
+
+	if (lock)
+		spin_unlock(&n->list_lock);
+
+	if (m == M_FREE) {
+		discard_slab(s, page);
+		stat(s, FREE_SLAB);
 	}
-	c->page = NULL;
-#ifdef CONFIG_CMPXCHG_LOCAL
-	c->tid = next_tid(c->tid);
-#endif
-	page->frozen = 0;
-	unfreeze_slab(s, page, tail);
 }
 
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
@@ -1851,21 +1948,33 @@ static void *__slab_alloc(struct kmem_ca
 
 	stat(s, ALLOC_REFILL);
 
+	{
+		struct page new;
+		unsigned long counters;
+
+		do {
+			object = page->freelist;
+			counters = page->counters;
+			new.counters = counters;
+			new.inuse = page->objects;
+			VM_BUG_ON(!new.frozen);
+
+		} while (!cmpxchg_double_slab(s, page,
+				object, counters,
+				NULL, new.counters,
+				"__slab_alloc"));
+	}
+
 load_freelist:
 	VM_BUG_ON(!page->frozen);
 
-	object = page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
-	if (kmem_cache_debug(s))
-		goto debug;
+
+	slab_unlock(page);
 
 	c->freelist = get_freepointer(s, object);
-	page->inuse = page->objects;
-	page->freelist = NULL;
 
-unlock_out:
-	slab_unlock(page);
 #ifdef CONFIG_CMPXCHG_LOCAL
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);
@@ -1880,10 +1989,11 @@ new_slab:
 	page = get_partial(s, gfpflags, node);
 	if (page) {
 		stat(s, ALLOC_FROM_PARTIAL);
-		page->frozen = 1;
 load_from_page:
-		c->node = page_to_nid(page);
-		c->page = page;
+		object = c->freelist;
+
+		if (kmem_cache_debug(s))
+			goto debug;
 		goto load_freelist;
 	}
 
@@ -1898,10 +2008,21 @@ load_from_page:
 
 	if (page) {
 		c = __this_cpu_ptr(s->cpu_slab);
-		stat(s, ALLOC_SLAB);
 		if (c->page)
 			flush_slab(s, c);
 
+		/*
+		 * No other reference to the page yet so we can
+		 * muck around with it freely without cmpxchg
+		 */
+		c->freelist = page->freelist;
+		page->freelist = NULL;
+		page->inuse = page->objects;
+
+		c->node = page_to_nid(page);
+		c->page = page;
+
+		stat(s, ALLOC_SLAB);
 		slab_lock(page);
 
 		goto load_from_page;
@@ -1912,14 +2033,19 @@ load_from_page:
 	local_irq_restore(flags);
 #endif
 	return NULL;
+
 debug:
-	if (!alloc_debug_processing(s, page, object, addr))
-		goto another_slab;
+	if (!object || !alloc_debug_processing(s, page, object, addr))
+		goto new_slab;
 
-	page->inuse++;
-	page->freelist = get_freepointer(s, object);
+	c->freelist = get_freepointer(s, object);
+	deactivate_slab(s, c);
 	c->node = NUMA_NO_NODE;
-	goto unlock_out;
+
+#ifdef CONFIG_CMPXCHG_LOCAL
+	local_irq_restore(flags);
+#endif
+	return object;
 }
 
 /*
@@ -2084,6 +2210,11 @@ static void __slab_free(struct kmem_cach
 {
 	void *prior;
 	void **object = (void *)x;
+	int was_frozen;
+	int inuse;
+	struct page new;
+	unsigned long counters;
+	struct kmem_cache_node *n = NULL;
 #ifdef CONFIG_CMPXCHG_LOCAL
 	unsigned long flags;
 
@@ -2095,32 +2226,65 @@ static void __slab_free(struct kmem_cach
 	if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
 		goto out_unlock;
 
-	prior = page->freelist;
-	set_freepointer(s, object, prior);
-	page->freelist = object;
-	page->inuse--;
-
-	if (unlikely(page->frozen)) {
-		stat(s, FREE_FROZEN);
-		goto out_unlock;
-	}
+	do {
+		prior = page->freelist;
+		counters = page->counters;
+		set_freepointer(s, object, prior);
+		new.counters = counters;
+		was_frozen = new.frozen;
+		new.inuse--;
+		if ((!new.inuse || !prior) && !was_frozen && !n) {
+                        n = get_node(s, page_to_nid(page));
+			/*
+			 * Speculatively acquire the list_lock.
+			 * If the cmpxchg does not succeed then we may
+			 * drop the list_lock without any processing.
+			 *
+			 * Otherwise the list_lock will synchronize with
+			 * other processors updating the list of slabs.
+			 */
+                        spin_lock(&n->list_lock);
+		}
+		inuse = new.inuse;
 
-	if (unlikely(!page->inuse))
-		goto slab_empty;
+	} while (!cmpxchg_double_slab(s, page,
+		prior, counters,
+		object, new.counters,
+		"__slab_free"));
+
+	if (likely(!n)) {
+                /*
+		 * The list lock was not taken therefore no list
+		 * activity can be necessary.
+		 */
+                if (was_frozen)
+                        stat(s, FREE_FROZEN);
+                goto out_unlock;
+        }
 
 	/*
-	 * Objects left in the slab. If it was not on the partial list before
-	 * then add it.
+	 * was_frozen may have been set after we acquired the list_lock in
+	 * an earlier loop. So we need to check it here again.
 	 */
-	if (unlikely(!prior)) {
-		struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+	if (was_frozen)
+		stat(s, FREE_FROZEN);
+	else {
+		if (unlikely(!inuse && n->nr_partial > s->min_partial))
+                        goto slab_empty;
 
-		spin_lock(&n->list_lock);
-		add_partial(get_node(s, page_to_nid(page)), page, 1);
-		spin_unlock(&n->list_lock);
-		stat(s, FREE_ADD_PARTIAL);
+		/*
+		 * Objects left in the slab. If it was not on the partial list before
+		 * then add it.
+		 */
+		if (unlikely(!prior)) {
+			remove_full(s, page);
+			add_partial(n, page, 0);
+			stat(s, FREE_ADD_PARTIAL);
+		}
 	}
 
+	spin_unlock(&n->list_lock);
+
 out_unlock:
 	slab_unlock(page);
 #ifdef CONFIG_CMPXCHG_LOCAL
@@ -2133,13 +2297,11 @@ slab_empty:
 		/*
 		 * Slab still on the partial list.
 		 */
-		struct kmem_cache_node *n = get_node(s, page_to_nid(page));
-
-		spin_lock(&n->list_lock);
 		remove_partial(n, page);
-		spin_unlock(&n->list_lock);
 		stat(s, FREE_REMOVE_PARTIAL);
 	}
+
+	spin_unlock(&n->list_lock);
 	slab_unlock(page);
 #ifdef CONFIG_CMPXCHG_LOCAL
 	local_irq_restore(flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

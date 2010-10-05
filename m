Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 292186B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 15:00:12 -0400 (EDT)
Message-Id: <20101005185816.462847264@linux.com>
Date: Tue, 05 Oct 2010 13:57:33 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 08/16] slub: Get rid of page lock and rely on per node lock
References: <20101005185725.088808842@linux.com>
Content-Disposition: inline; filename=unified_remove_page_lock
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

With queueing slub will have to free and allocate lots of objects in one go.
Taking the page lock for each free or taking the per node lock for each page
can cause a lot of atomic operations. Change locking conventions so that
page strut metadata is stable under the node lock only. Then the page lock
can be dropped.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slub_def.h |    2 
 mm/slub.c                |  377 ++++++++++++++++++++---------------------------
 2 files changed, 167 insertions(+), 212 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-10-04 08:26:27.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-10-04 08:47:21.000000000 -0500
@@ -29,41 +29,14 @@
 #include <linux/fault-inject.h>
 
 /*
- * Lock order:
- *   1. slab_lock(page)
- *   2. slab->list_lock
+ * Locking:
+ *   All slab metadata (aside from queues and percpu data) is protected
+ *   by a per node lock in struct kmem_cache_node.
+ *   Shared and alien caches have a lock protecting their queue alone
+ *   Per cpu queues are protected by only allowing access from a single cpu.
  *
- *   The slab_lock protects operations on the object of a particular
- *   slab and its metadata in the page struct. If the slab lock
- *   has been taken then no allocations nor frees can be performed
- *   on the objects in the slab nor can the slab be added or removed
- *   from the partial or full lists since this would mean modifying
- *   the page_struct of the slab.
- *
- *   The list_lock protects the partial and full list on each node and
- *   the partial slab counter. If taken then no new slabs may be added or
- *   removed from the lists nor make the number of partial slabs be modified.
- *   (Note that the total number of slabs is an atomic value that may be
- *   modified without taking the list lock).
- *
- *   The list_lock is a centralized lock and thus we avoid taking it as
- *   much as possible. As long as SLUB does not have to handle partial
- *   slabs, operations can continue without any centralized lock. F.e.
- *   allocating a long series of objects that fill up slabs does not require
- *   the list lock.
- *
- *   The lock order is sometimes inverted when we are trying to get a slab
- *   off a list. We take the list_lock and then look for a page on the list
- *   to use. While we do that objects in the slabs may be freed. We can
- *   only operate on the slab if we have also taken the slab_lock. So we use
- *   a slab_trylock() on the slab. If trylock was successful then no frees
- *   can occur anymore and we can use the slab for allocations etc. If the
- *   slab_trylock() does not succeed then frees are in progress in the slab and
- *   we must stay away from it for a while since we may cause a bouncing
- *   cacheline if we try to acquire the lock. So go onto the next slab.
- *   If all pages are busy then we may allocate a new slab instead of reusing
- *   a partial slab. A new slab has noone operating on it and thus there is
- *   no danger of cacheline contention.
+ * The slub_lock semaphore protects against configuration modifications like
+ *   adding new queues, reconfiguring queues and removing queues.
  *
  *   Interrupts are disabled during allocation and deallocation in order to
  *   make the slab allocator safe to use in the context of an irq. In addition
@@ -82,7 +55,6 @@
  * Slabs are freed when they become empty. Teardown and setup is
  * minimal so we rely on the page allocators per cpu caches for
  * fast frees and allocs.
- *
  */
 
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
@@ -845,16 +817,9 @@ static inline void slab_free_hook_irq(st
 /*
  * Tracking of fully allocated slabs for debugging purposes.
  */
-static inline void add_full(struct kmem_cache *s,
-		struct kmem_cache_node *n, struct page *page)
+static inline void add_full(struct kmem_cache_node *n, struct page *page)
 {
-
-	if (!(s->flags & SLAB_STORE_USER))
-		return;
-
-	spin_lock(&n->list_lock);
 	list_add(&page->lru, &n->full);
-	spin_unlock(&n->list_lock);
 }
 
 static inline void remove_full(struct kmem_cache *s,
@@ -863,9 +828,7 @@ static inline void remove_full(struct km
 	if (!(s->flags & SLAB_STORE_USER))
 		return;
 
-	spin_lock(&n->list_lock);
 	list_del(&page->lru);
-	spin_unlock(&n->list_lock);
 }
 
 /* Tracking of the number of slabs for debugging purposes */
@@ -1102,7 +1065,7 @@ static inline int slab_pad_check(struct 
 			{ return 1; }
 static inline int check_object(struct kmem_cache *s, struct page *page,
 			void *object, u8 val) { return 1; }
-static inline void add_full(struct kmem_cache *s, struct kmem_cache_node *n,
+static inline void add_full(struct kmem_cache_node *n,
 						struct page *page) {}
 static inline void remove_full(struct kmem_cache *s,
 			struct kmem_cache_node *n, struct page *page) {}
@@ -1304,97 +1267,37 @@ static void discard_slab(struct kmem_cac
 }
 
 /*
- * Per slab locking using the pagelock
- */
-static __always_inline void slab_lock(struct page *page)
-{
-	bit_spin_lock(PG_locked, &page->flags);
-}
-
-static __always_inline void slab_unlock(struct page *page)
-{
-	__bit_spin_unlock(PG_locked, &page->flags);
-}
-
-static __always_inline int slab_trylock(struct page *page)
-{
-	int rc = 1;
-
-	rc = bit_spin_trylock(PG_locked, &page->flags);
-	return rc;
-}
-
-/*
  * Management of partially allocated slabs
  */
 static void add_partial(struct kmem_cache_node *n,
 				struct page *page, int tail)
 {
-	spin_lock(&n->list_lock);
 	n->nr_partial++;
 	if (tail)
 		list_add_tail(&page->lru, &n->partial);
 	else
 		list_add(&page->lru, &n->partial);
 	__SetPageSlubPartial(page);
-	spin_unlock(&n->list_lock);
 }
 
-static inline void __remove_partial(struct kmem_cache_node *n,
+static inline void remove_partial(struct kmem_cache_node *n,
 					struct page *page)
 {
-	list_del(&page->lru);
 	n->nr_partial--;
+	list_del(&page->lru);
 	__ClearPageSlubPartial(page);
 }
 
-static void remove_partial(struct kmem_cache_node *n, struct page *page)
-{
-	spin_lock(&n->list_lock);
-	__remove_partial(n, page);
-	spin_unlock(&n->list_lock);
-}
-
-/*
- * Lock slab and remove from the partial list.
- *
- * Must hold list_lock.
- */
-static inline int lock_and_freeze_slab(struct kmem_cache_node *n,
-							struct page *page)
-{
-	if (slab_trylock(page)) {
-		__remove_partial(n, page);
-		return 1;
-	}
-	return 0;
-}
-
-/*
- * Try to allocate a partial slab from a specific node.
- */
-static struct page *get_partial(struct kmem_cache *s, int node)
+static inline void partial_to_full(struct kmem_cache *s,
+		struct kmem_cache_node *n, struct page *page)
 {
-	struct page *page;
-	struct kmem_cache_node *n = get_node(s, node);
+	if (PageSlubPartial(page))
+		remove_partial(n, page);
 
-	/*
-	 * Racy check. If we mistakenly see no partial slabs then we
-	 * just allocate an empty slab. If we mistakenly try to get a
-	 * partial slab and there is none available then get_partial()
-	 * will return NULL.
-	 */
-	if (!n || !n->nr_partial)
-		return NULL;
-
-	spin_lock(&n->list_lock);
-	list_for_each_entry(page, &n->partial, lru)
-		if (lock_and_freeze_slab(n, page))
-			goto out;
-	page = NULL;
-out:
-	spin_unlock(&n->list_lock);
-	return page;
+#ifdef CONFIG_SLAB_DEBUG
+	if (s->flags & SLAB_STORE_USER)
+		list_add(&page->lru, &n->full);
+#endif
 }
 
 /*
@@ -1403,16 +1306,31 @@ out:
 void drain_objects(struct kmem_cache *s, void **object, int nr)
 {
 	int i;
+	struct kmem_cache_node *n = NULL;
+	struct page *page = NULL;
+	void *addr = 0;
+	unsigned long size = 0;
 
 	for (i = 0 ; i < nr; ) {
-
 		void *p = object[i];
-		struct page *page = virt_to_head_page(p);
-		void *addr = page_address(page);
-		unsigned long size = PAGE_SIZE << compound_order(page);
+		struct page *npage = virt_to_head_page(p);
 		unsigned long *m;
 		unsigned long offset;
-		struct kmem_cache_node *n;
+
+		if (npage != page) {
+			struct kmem_cache_node *n2 = get_node(s, page_to_nid(npage));
+
+			page = npage;
+			addr = page_address(page);
+			size = PAGE_SIZE << compound_order(page);
+
+			if (n != n2) {
+				if (n)
+					spin_unlock(&n->lock);
+				n = n2;
+				spin_lock(&n->lock);
+			}
+		}
 
 #ifdef CONFIG_SLUB_DEBUG
 		if (kmem_cache_debug(s) && !PageSlab(page)) {
@@ -1421,7 +1339,6 @@ void drain_objects(struct kmem_cache *s,
 			continue;
 		}
 #endif
-		slab_lock(page);
 		m = map(page);
 
 		offset = p - addr;
@@ -1478,7 +1395,7 @@ void drain_objects(struct kmem_cache *s,
 
 			offset = new_offset;
 		}
-		n = get_node(s, page_to_nid(page));
+
 		if (bitmap_full(m, page->objects) && n->nr_partial > s->min_partial) {
 
 			/* All objects are available now */
@@ -1489,7 +1406,6 @@ void drain_objects(struct kmem_cache *s,
 			} else
 				remove_full(s, n, page);
 
-			slab_unlock(page);
 			discard_slab(s, page);
 
 		} else {
@@ -1502,9 +1418,10 @@ void drain_objects(struct kmem_cache *s,
 				add_partial(n, page, 0);
 				stat(s, FREE_ADD_PARTIAL);
 			}
-			slab_unlock(page);
 		}
 	}
+	if (n)
+		spin_unlock(&n->lock);
 }
 
 static inline int drain_queue(struct kmem_cache *s,
@@ -1646,10 +1563,10 @@ static unsigned long count_partial(struc
 	unsigned long x = 0;
 	struct page *page;
 
-	spin_lock_irqsave(&n->list_lock, flags);
+	spin_lock_irqsave(&n->lock, flags);
 	list_for_each_entry(page, &n->partial, lru)
 		x += get_count(page);
-	spin_unlock_irqrestore(&n->list_lock, flags);
+	spin_unlock_irqrestore(&n->lock, flags);
 	return x;
 }
 
@@ -1734,6 +1651,7 @@ void retrieve_objects(struct kmem_cache 
 		int i = find_first_bit(m, page->objects);
 		void *a;
 
+		VM_BUG_ON(i >= page->objects);
 		__clear_bit(i, m);
 		a = addr + i * s->size;
 
@@ -1767,16 +1685,6 @@ static inline void refill_queue(struct k
 	q->objects += d;
 }
 
-void to_lists(struct kmem_cache *s, struct page *page, int tail)
-{
-	if (!all_objects_used(page))
-
-		add_partial(get_node(s, page_to_nid(page)), page, tail);
-
-	else
-		add_full(s, get_node(s, page_to_nid(page)), page);
-}
-
 /* Handling of objects from other nodes */
 
 static void *slab_alloc_node(struct kmem_cache *s, struct kmem_cache_cpu *c,
@@ -1785,9 +1693,12 @@ static void *slab_alloc_node(struct kmem
 #ifdef CONFIG_NUMA
 	struct page *page;
 	void *object;
+	struct kmem_cache_node *n = get_node(s, node);
 
-	page = get_partial(s, node);
-	if (!page) {
+	spin_lock(&n->lock);
+	if (list_empty(&n->partial)) {
+
+		spin_unlock(&n->lock);
 		gfpflags &= gfp_allowed_mask;
 
 		if (gfpflags & __GFP_WAIT)
@@ -1801,14 +1712,23 @@ static void *slab_alloc_node(struct kmem
 		if (!page)
 			return NULL;
 
-		slab_lock(page);
-	}
+		spin_lock(&n->lock);
+
+	} else
+		page = list_entry(n->partial.prev, struct page, lru);
 
 	retrieve_objects(s, page, &object, 1);
 	stat(s, ALLOC_DIRECT);
 
-	to_lists(s, page, 0);
-	slab_unlock(page);
+	if (!all_objects_used(page)) {
+
+		if (!PageSlubPartial(page))
+			add_partial(n, page, 1);
+
+	} else
+		partial_to_full(s, n, page);
+
+	spin_unlock(&n->lock);
 	return object;
 #else
 	return NULL;
@@ -1833,13 +1753,15 @@ static void *slab_alloc(struct kmem_cach
 	void *object;
 	struct kmem_cache_cpu *c;
 	struct kmem_cache_queue *q;
+	struct kmem_cache_node *n;
+	struct page *page;
 	unsigned long flags;
 
 	if (slab_pre_alloc_hook(s, gfpflags))
 		return NULL;
 
-redo:
 	local_irq_save(flags);
+redo:
 	c = __this_cpu_ptr(s->cpu);
 
 	node = find_numa_node(s, node, c->node);
@@ -1847,66 +1769,107 @@ redo:
 		object = slab_alloc_node(s, c, gfpflags, node);
 		if (!object)
 			goto oom;
-		goto got_it;
+		goto got_object;
 	}
+
 	q = &c->q;
-	if (unlikely(queue_empty(q))) {
 
-		while (q->objects < s->batch) {
-			struct page *new;
+	if (likely(!queue_empty(q))) {
 
-			new = get_partial(s, node);
-			if (unlikely(!new)) {
+		stat(s, ALLOC_FASTPATH);
 
-				gfpflags &= gfp_allowed_mask;
+get_object:
+		object = queue_get(q);
 
-				if (gfpflags & __GFP_WAIT)
-					local_irq_enable();
+got_object:
+		if (kmem_cache_debug(s)) {
+			if (!alloc_debug_processing(s, object, addr))
+				goto redo;
+		}
+		local_irq_restore(flags);
 
-				new = new_slab(s, gfpflags, node);
+		if (unlikely(gfpflags & __GFP_ZERO))
+			memset(object, 0, s->objsize);
 
-				if (gfpflags & __GFP_WAIT)
-					local_irq_disable();
+		slab_post_alloc_hook(s, gfpflags, object);
 
-				/* process may have moved to different cpu */
-				c = __this_cpu_ptr(s->cpu);
-				q = &c->q;
+		return object;
+	}
 
-				if (!new) {
-					if (queue_empty(q))
-						goto oom;
-					break;
-				}
-				stat(s, ALLOC_SLAB);
-				slab_lock(new);
-			} else
-				stat(s, ALLOC_FROM_PARTIAL);
+	stat(s, ALLOC_SLOWPATH);
 
-			refill_queue(s, q, new, available(new));
-			to_lists(s, new, 0);
+	n = get_node(s, node);
 
-			slab_unlock(new);
-		}
-		stat(s, ALLOC_SLOWPATH);
+	/* Refill from partial lists */
+	spin_lock(&n->lock);
+	while (q->objects < s->batch && !list_empty(&n->partial)) {
+		page = list_entry(n->partial.next, struct page, lru);
 
-	} else
-		stat(s, ALLOC_FASTPATH);
+		refill_queue(s, q, page, min(available(page),
+					s->batch - q->objects));
 
-	object = queue_get(q);
+		if (all_objects_used(page))
+			partial_to_full(s, n, page);
 
-got_it:
-	if (kmem_cache_debug(s)) {
-		if (!alloc_debug_processing(s, object, addr))
-			goto redo;
+		stat(s, ALLOC_FROM_PARTIAL);
 	}
-	local_irq_restore(flags);
+	spin_unlock(&n->lock);
 
-	if (unlikely(gfpflags & __GFP_ZERO))
-		memset(object, 0, s->objsize);
+	if (!queue_empty(q))
+		goto get_object;
 
-	slab_post_alloc_hook(s, gfpflags, object);
+	gfpflags &= gfp_allowed_mask;
+	/* Refill from free pages */
+	while (q->objects < s->batch) {
+		int tail = 0;
 
-	return object;
+		if (gfpflags & __GFP_WAIT)
+			local_irq_enable();
+
+		page = new_slab(s, gfpflags, node);
+
+		if (gfpflags & __GFP_WAIT)
+			local_irq_disable();
+
+		node = page_to_nid(page);
+		n = get_node(s, node);
+
+		/* process may have moved to different cpu */
+		c = __this_cpu_ptr(s->cpu);
+		q = &c->q;
+
+		if (!page)
+			goto oom;
+
+		/*
+		 * Cpu may have switched and the local queue may have
+		 * enough objects. Just push the unused objects  into
+		 * the partial list if so.
+		 */
+		if (q->objects < s->batch)
+			refill_queue(s, q, page, min_t(int, page->objects, s->batch));
+		else
+			tail = 1;
+
+		stat(s, ALLOC_SLAB);
+		if (!all_objects_used(page)) {
+
+			spin_lock(&n->lock);
+			add_partial(n, page, tail);
+			spin_unlock(&n->lock);
+
+		}
+#ifdef CONFIG_SLUB_DEBUG
+		 else if (s->flags & SLAB_STORE_USER) {
+
+			spin_lock(&n->lock);
+			add_full(n, page);
+			spin_unlock(&n->lock);
+
+		}
+#endif
+	}
+	goto get_object;
 
 oom:
 	local_irq_restore(flags);
@@ -2172,7 +2135,7 @@ static void
 init_kmem_cache_node(struct kmem_cache_node *n, struct kmem_cache *s)
 {
 	n->nr_partial = 0;
-	spin_lock_init(&n->list_lock);
+	spin_lock_init(&n->lock);
 	INIT_LIST_HEAD(&n->partial);
 #ifdef CONFIG_SLUB_DEBUG
 	atomic_long_set(&n->nr_slabs, 0);
@@ -2514,7 +2477,6 @@ static void list_slab_objects(struct kme
 	long *m = map(page);
 
 	slab_err(s, page, "%s", text);
-	slab_lock(page);
 
 	for_each_object(p, s, addr, page->objects) {
 
@@ -2524,7 +2486,6 @@ static void list_slab_objects(struct kme
 			print_tracking(s, p);
 		}
 	}
-	slab_unlock(page);
 	kfree(map);
 #endif
 }
@@ -2537,17 +2498,17 @@ static void free_partial(struct kmem_cac
 	unsigned long flags;
 	struct page *page, *h;
 
-	spin_lock_irqsave(&n->list_lock, flags);
+	spin_lock_irqsave(&n->lock, flags);
 	list_for_each_entry_safe(page, h, &n->partial, lru) {
 		if (all_objects_available(page)) {
-			__remove_partial(n, page);
+			remove_partial(n, page);
 			discard_slab(s, page);
 		} else {
 			list_slab_objects(s, page,
 				"Objects remaining on kmem_cache_close()");
 		}
 	}
-	spin_unlock_irqrestore(&n->list_lock, flags);
+	spin_unlock_irqrestore(&n->lock, flags);
 }
 
 /*
@@ -2886,23 +2847,22 @@ int kmem_cache_shrink(struct kmem_cache 
 		for (i = 0; i < objects; i++)
 			INIT_LIST_HEAD(slabs_by_inuse + i);
 
-		spin_lock_irqsave(&n->list_lock, flags);
+		spin_lock_irqsave(&n->lock, flags);
 
 		/*
 		 * Build lists indexed by the items in use in each slab.
 		 *
 		 * Note that concurrent frees may occur while we hold the
-		 * list_lock. page->inuse here is the upper limit.
+		 * lock. page->inuse here is the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			if (all_objects_available(page) && slab_trylock(page)) {
+			if (all_objects_available(page)) {
 				/*
 				 * Must hold slab lock here because slab_free
 				 * may have freed the last object and be
 				 * waiting to release the slab.
 				 */
-				__remove_partial(n, page);
-				slab_unlock(page);
+				remove_partial(n, page);
 				discard_slab(s, page);
 			} else {
 				list_move(&page->lru,
@@ -2917,7 +2877,7 @@ int kmem_cache_shrink(struct kmem_cache 
 		for (i = objects - 1; i >= 0; i--)
 			list_splice(slabs_by_inuse + i, n->partial.prev);
 
-		spin_unlock_irqrestore(&n->list_lock, flags);
+		spin_unlock_irqrestore(&n->lock, flags);
 	}
 
 	kfree(slabs_by_inuse);
@@ -3495,15 +3455,7 @@ static int validate_slab(struct kmem_cac
 
 static unsigned long validate_slab_slab(struct kmem_cache *s, struct page *page)
 {
-	unsigned long errors = 0;
-
-	if (slab_trylock(page)) {
-		errors = validate_slab(s, page);
-		slab_unlock(page);
-	} else
-		printk(KERN_INFO "SLUB %s: Skipped busy slab 0x%p\n",
-			s->name, page);
-	return errors;
+	return validate_slab(s, page);
 }
 
 static int validate_slab_node(struct kmem_cache *s,
@@ -3514,10 +3466,13 @@ static int validate_slab_node(struct kme
 	unsigned long flags;
 	unsigned long errors;
 
-	spin_lock_irqsave(&n->list_lock, flags);
+	spin_lock_irqsave(&n->lock, flags);
 
 	list_for_each_entry(page, &n->partial, lru) {
-		errors += validate_slab_slab(s, page);
+		if (get_node(s, page_to_nid(page)) == n)
+			errors += validate_slab_slab(s, page);
+		else
+			printk(KERN_ERR "SLUB %s: Partial list page from wrong node\n", s->name);
 		count++;
 	}
 	if (count != n->nr_partial)
@@ -3537,7 +3492,7 @@ static int validate_slab_node(struct kme
 			atomic_long_read(&n->nr_slabs));
 
 out:
-	spin_unlock_irqrestore(&n->list_lock, flags);
+	spin_unlock_irqrestore(&n->lock, flags);
 	return errors;
 }
 
@@ -3715,12 +3670,12 @@ static int list_locations(struct kmem_ca
 		if (!atomic_long_read(&n->nr_slabs))
 			continue;
 
-		spin_lock_irqsave(&n->list_lock, flags);
+		spin_lock_irqsave(&n->lock, flags);
 		list_for_each_entry(page, &n->partial, lru)
 			process_slab(&t, s, page, alloc);
 		list_for_each_entry(page, &n->full, lru)
 			process_slab(&t, s, page, alloc);
-		spin_unlock_irqrestore(&n->list_lock, flags);
+		spin_unlock_irqrestore(&n->lock, flags);
 	}
 
 	for (i = 0; i < t.count; i++) {
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-10-04 08:26:27.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-10-04 08:41:48.000000000 -0500
@@ -62,7 +62,7 @@ struct kmem_cache_cpu {
 };
 
 struct kmem_cache_node {
-	spinlock_t list_lock;	/* Protect partial list and nr_partial */
+	spinlock_t lock;	/* Protocts slab metadata on a node */
 	unsigned long nr_partial;
 	struct list_head partial;
 #ifdef CONFIG_SLUB_DEBUG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

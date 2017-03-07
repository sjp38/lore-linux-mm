Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB9826B0390
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 16:24:49 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id z13so16782514iof.7
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 13:24:49 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id 185si1666318iou.232.2017.03.07.13.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 13:24:49 -0800 (PST)
Message-Id: <20170307212438.294581405@linux.com>
Date: Tue, 07 Mar 2017 15:24:34 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 5/6] slub: Slab defrag core
References: <20170307212429.044249411@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=defrag_core
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>

Slab defragmentation may occur:

1. Unconditionally when kmem_cache_shrink is called on a slab cache by the
   kernel calling kmem_cache_shrink.

2. Through the use of the slabinfo command.

3. Per node defrag conditionally when kmem_cache_defrag(<node>) is called
   (can be called from reclaim code with a later patch).

   Defragmentation is only performed if the fragmentation of the slab
   is lower than the specified percentage. Fragmentation ratios are measured
   by calculating the percentage of objects in use compared to the total
   number of objects that the slab page can accomodate.

   The scanning of slab caches is optimized because the
   defragmentable slabs come first on the list. Thus we can terminate scans
   on the first slab encountered that does not support defragmentation.

   kmem_cache_defrag() takes a node parameter. This can either be -1 if
   defragmentation should be performed on all nodes, or a node number.

A couple of functions must be setup via a call to kmem_cache_setup_defrag()
in order for a slabcache to support defragmentation. These are

kmem_defrag_get_func (void *get(struct kmem_cache *s, int nr, void **objects))

	Must obtain a reference to the listed objects. SLUB guarantees that
	the objects are still allocated. However, other threads may be blocked
	in slab_free() attempting to free objects in the slab. These may succeed
	as soon as get() returns to the slab allocator. The function must
	be able to detect such situations and void the attempts to free such
	objects (by for example voiding the corresponding entry in the objects
	array).

	No slab operations may be performed in get(). Interrupts
	are disabled. What can be done is very limited. The slab lock
	for the page that contains the object is taken. Any attempt to perform
	a slab operation may lead to a deadlock.

	kmem_defrag_get_func returns a private pointer that is passed to
	kmem_defrag_kick_func(). Should we be unable to obtain all references
	then that pointer may indicate to the kick() function that it should
	not attempt any object removal or move but simply remove the
	reference counts.

kmem_defrag_kick_func (void kick(struct kmem_cache *, int nr, void **objects,
							void *get_result))

	After SLUB has established references to the objects in a
	slab it will then drop all locks and use kick() to move objects out
	of the slab. The existence of the object is guaranteed by virtue of
	the earlier obtained references via kmem_defrag_get_func(). The
	callback may perform any slab operation since no locks are held at
	the time of call.

	The callback should remove the object from the slab in some way. This
	may be accomplished by reclaiming the object and then running
	kmem_cache_free() or reallocating it and then running
	kmem_cache_free(). Reallocation is advantageous because the partial
	slabs were just sorted to have the partial slabs with the most objects
	first. Reallocation is likely to result in filling up a slab in
	addition to freeing up one slab. A filled up slab can also be removed
	from the partial list. So there could be a double effect.

	kmem_defrag_kick_func() does not return a result. SLUB will check
	the number of remaining objects in the slab. If all objects were
	removed then the slab is freed and we have reduced the overall
	fragmentation of the slab cache.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/slab.h |    3 
 mm/slub.c            |  265 ++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 215 insertions(+), 53 deletions(-)

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -318,6 +318,12 @@ static __always_inline void slab_lock(st
 	bit_spin_lock(PG_locked, &page->flags);
 }
 
+static __always_inline int slab_trylock(struct page *page)
+{
+	VM_BUG_ON_PAGE(PageTail(page), page);
+	return bit_spin_trylock(PG_locked, &page->flags);
+}
+
 static __always_inline void slab_unlock(struct page *page)
 {
 	VM_BUG_ON_PAGE(PageTail(page), page);
@@ -4276,6 +4282,228 @@ static inline void *alloc_scratch(void)
 		GFP_KERNEL);
 }
 
+/*
+ * Vacate all objects in the given slab.
+ *
+ * The scratch area passed to list function is sufficient to hold
+ * struct listhead times objects per slab. We use it to hold void ** times
+ * objects per slab plus a bitmap for each object.
+ */
+static void kmem_cache_vacate(struct page *page, void *scratch)
+{
+	void **vector = scratch;
+	void *p;
+	void *addr = page_address(page);
+	struct kmem_cache *s;
+	unsigned long *map;
+	int count;
+	void *private;
+	unsigned long flags;
+	unsigned long objects;
+
+	local_irq_save(flags);
+	slab_lock(page);
+
+	BUG_ON(!PageSlab(page));	/* Must be s slab page */
+	BUG_ON(!page->frozen);	/* Slab must have been frozen earlier */
+
+	s = page->slab_cache;
+	objects = page->objects;
+	map = scratch + objects * sizeof(void **);
+
+	/* Determine used objects */
+	bitmap_fill(map, objects);
+	for (p = page->freelist; p; p = get_freepointer(s, p))
+		__clear_bit(slab_index(p, s, addr), map);
+
+	/* Build vector of pointers to objects */
+	count = 0;
+	memset(vector, 0, objects * sizeof(void **));
+	for_each_object(p, s, addr, objects)
+		if (test_bit(slab_index(p, s, addr), map))
+			vector[count++] = p;
+
+	private = s->get(s, count, vector);
+
+	/*
+	 * Got references. Now we can drop the slab lock. The slab
+	 * is frozen so it cannot vanish from under us nor will
+	 * allocations be performed on the slab. However, unlocking the
+	 * slab will allow concurrent slab_frees to proceed.
+	 */
+	slab_unlock(page);
+	local_irq_restore(flags);
+
+	/*
+	 * Perform the KICK callbacks to remove the objects.
+	 */
+	s->kick(s, count, vector, private);
+}
+
+/*
+ * Shrink the slab cache on a particular node of the cache
+ * by releasing slabs with zero objects and trying to reclaim
+ * slabs with less than the configured percentage of objects allocated.
+ */
+static unsigned long __shrink(struct kmem_cache *s, int node,
+							unsigned long limit)
+{
+	unsigned long flags;
+	struct page *page, *page2;
+	LIST_HEAD(zaplist);
+	int freed = 0;
+	struct kmem_cache_node *n = get_node(s, node);
+
+	if (n->nr_partial <= limit)
+		return 0;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry_safe(page, page2, &n->partial, lru) {
+		if (!slab_trylock(page))
+			/* Busy slab. Get out of the way */
+			continue;
+
+		if (page->inuse) {
+			if (page->inuse * 100 >=
+					s->defrag_ratio * page->objects) {
+				slab_unlock(page);
+				/* Slab contains enough objects */
+				continue;
+			}
+
+			list_move(&page->lru, &zaplist);
+			if (s->kick) {
+				/* Remove page from being considered for allocations */
+				n->nr_partial--;
+				page->frozen = 1;
+			}
+			slab_unlock(page);
+		} else {
+			/* Empty slab page */
+			list_del(&page->lru);
+			n->nr_partial--;
+			slab_unlock(page);
+			discard_slab(s, page);
+			freed++;
+		}
+	}
+
+	if (!s->kick)
+		/*
+		 * No defrag method. By simply putting the zaplist at the
+		 * end of the partial list we can let them simmer longer
+		 * and thus increase the chance of all objects being
+		 * reclaimed.
+		 *
+		 * We have effectively sorted the partial list and put
+		 * the slabs with more objects first. As soon as they
+		 * are allocated they are going to be removed from the
+		 * partial list.
+		 */
+		list_splice(&zaplist, n->partial.prev);
+
+
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	if (s->kick && !list_empty(&zaplist)) {
+		void **scratch = alloc_scratch();
+		struct page *page;
+		struct page *page2;
+
+		if (scratch) {
+			/* Try to remove / move the objects left */
+			list_for_each_entry(page, &zaplist, lru) {
+				if (page->inuse)
+					kmem_cache_vacate(page, scratch);
+			}
+			kfree(scratch);
+		}
+
+		/* Inspect results and dispose of pages */
+		spin_lock_irqsave(&n->list_lock, flags);
+		list_for_each_entry_safe(page, page2, &zaplist, lru) {
+			slab_lock(page);
+			page->frozen = 0;
+
+			if (page->inuse) {
+
+				/* Still objects left */
+				n->nr_partial++;
+				list_add_tail(&n->partial, &page->lru);
+				slab_unlock(page);
+
+			} else {
+
+				/* Success */
+				slab_unlock(page);
+				discard_slab(s, page);
+				freed++;
+			}
+		}
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+	return freed;
+}
+
+/*
+ * Defrag slabs conditional on the amount of fragmentation in a page.
+ */
+int kmem_cache_defrag(int node)
+{
+	struct kmem_cache *s;
+	unsigned long slabs = 0;
+
+	/*
+	 * kmem_cache_defrag may be called from the reclaim path which may be
+	 * called for any page allocator alloc. So there is the danger that we
+	 * get called in a situation where slub already acquired the slub_lock
+	 * for other purposes.
+	 */
+	if (!mutex_trylock(&slab_mutex))
+		return 0;
+
+	list_for_each_entry(s, &slab_caches, list) {
+		unsigned long reclaimed = 0;
+
+		/*
+		 * Defragmentable caches come first. If the slab cache is not
+		 * defragmentable then we can stop traversing the list.
+		 */
+		if (!s->kick)
+			break;
+
+		if (node == -1) {
+			int nid;
+
+			for_each_node_state(nid, N_NORMAL_MEMORY)
+				reclaimed += __shrink(s, nid, MAX_PARTIAL);
+		} else
+			reclaimed = __shrink(s, node, MAX_PARTIAL);
+
+		slabs += reclaimed;
+	}
+	mutex_unlock(&slab_mutex);
+	return slabs;
+}
+EXPORT_SYMBOL(kmem_cache_defrag);
+
+/*
+ * kmem_cache_shrink removes empty slabs from the partial lists.
+ * If the slab cache supports defragmentation then objects are
+ * reclaimed.
+ */
+int kmem_cache_shrink(struct kmem_cache *s)
+{
+	int node;
+
+	flush_all(s);
+	for_each_node_state(node, N_NORMAL_MEMORY)
+		__shrink(s, node, 0);
+
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_shrink);
+
 void kmem_cache_setup_defrag(struct kmem_cache *s,
 	kmem_defrag_get_func get, kmem_defrag_kick_func kick)
 {
Index: linux/include/linux/slab.h
===================================================================
--- linux.orig/include/linux/slab.h
+++ linux/include/linux/slab.h
@@ -175,13 +175,16 @@ typedef void kmem_defrag_kick_func(struc
 
 /*
  * kmem_cache_setup_defrag() is used to setup callbacks for a slab cache.
+ * kmem_cache_defrag() performs the actual defragmentation.
  */
 #ifdef CONFIG_SLUB
 void kmem_cache_setup_defrag(struct kmem_cache *, kmem_defrag_get_func,
 						kmem_defrag_kick_func);
+int kmem_cache_defrag(int node);
 #else
 static inline void kmem_cache_setup_defrag(struct kmem_cache *s,
 	kmem_defrag_get_func get, kmem_defrag_kick_func kiok) {}
+static inline int kmem_cache_defrag(int node) { return 0; }
 #endif
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

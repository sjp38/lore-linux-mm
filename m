From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 09/26] SLUB: Slab defrag core
Date: Fri, 31 Aug 2007 18:41:16 -0700
Message-ID: <20070901014221.388656209@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0009-slab_defrag_core.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Slab defragmentation (aside from Lumpy Reclaim) may occur:

1. Unconditionally when kmem_cache_shrink is called on a slab cache by the
   kernel calling kmem_cache_shrink.

2. Use of the slabinfo command line to trigger slab shrinking.

3. Per node defrag conditionally when kmem_cache_defrag(<node>) is called.

   Defragmentation is only performed if the fragmentation of the slab
   is lower than the specified percentage. Fragmentation ratios are measured
   by calculating the percentage of objects in use compared to the total
   number of objects that the slab cache could hold.

   kmem_cache_defrag takes a node parameter. This can either be -1 if
   defragmentation should be performed on all nodes, or a node number.
   If a node number was specified then defragmentation is only performed
   on a specific node.

   Slab defragmentation is a memory intensive operation that can be
   sped up in a NUMA system if mostly node local memory is accessed. That
   is the case if we just have reclaimed reclaim on a node.

In order for a slabcache to support defragmentation a couple of functions
must be setup via a call to kmem_cache_setup_defrag(). These are

void *get(struct kmem_cache *s, int nr, void **objects)

	Must obtain a reference to the listed objects. SLUB guarantees that
	the objects are still allocated. However, other threads may be blocked
	in slab_free attempting to free objects in the slab. These may succeed
	as soon as get() returns to the slab allocator. The function must
	be able to detect such situations and void the attempts to free such
	objects (by for example voiding the corresponding entry in the objects
	array).

	No slab operations may be performed in get(). Interrupts
	are disabled. What can be done is very limited. The slab lock
	for the page with the object is taken. Any attempt to perform a slab
	operation may lead to a deadlock.

	get() returns a private pointer that is passed to kick. Should we
	be unable to obtain all references then that pointer may indicate
	to the kick() function that it should not attempt any object removal
	or move but simply remove the reference counts.

void kick(struct kmem_cache *, int nr, void **objects, void *get_result)

	After SLUB has established references to the objects in a
	slab it will then drop all locks and use kick() to move objects out
	of the slab. The existence of the object is guaranteed by virtue of
	the earlier obtained references via get(). The callback may perform
	any slab operation since no locks are held at the time of call.

	The callback should remove the object from the slab in some way. This
	may be accomplished by reclaiming the object and then running
	kmem_cache_free() or reallocating it and then running
	kmem_cache_free(). Reallocation is advantageous because the partial
	slabs were just sorted to have the partial slabs with the most objects
	first. Reallocation is likely to result in filling up a slab in
	addition to freeing up one slab so that it also can be removed from
	the partial list.

	Kick() does not return a result. SLUB will check the number of
	remaining objects in the slab. If all objects were removed then
	we know that the operation was successful.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slab.c |    5 +
 mm/slub.c |  265 ++++++++++++++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 222 insertions(+), 48 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2007-08-28 20:04:05.000000000 -0700
+++ linux-2.6/mm/slab.c	2007-08-28 20:04:54.000000000 -0700
@@ -2527,6 +2527,11 @@ int kmem_cache_shrink(struct kmem_cache 
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+int kmem_cache_defrag(int node)
+{
+	return 0;
+}
+
 /**
  * kmem_cache_destroy - delete a cache
  * @cachep: the cache to destroy
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-08-28 20:04:10.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-08-28 20:04:54.000000000 -0700
@@ -2639,75 +2639,244 @@ static unsigned long count_partial(struc
 }
 
 /*
- * kmem_cache_shrink removes empty slabs from the partial lists and sorts
- * the remaining slabs by the number of items in use. The slabs with the
- * most items in use come first. New allocations will then fill those up
- * and thus they can be removed from the partial lists.
+ * Vacate all objects in the given slab.
  *
- * The slabs with the least items are placed last. This results in them
- * being allocated from last increasing the chance that the last objects
- * are freed in them.
+ * The scratch aread passed to list function is sufficient to hold
+ * struct listhead times objects per slab. We use it to hold void ** times
+ * objects per slab plus a bitmap for each object.
  */
-int kmem_cache_shrink(struct kmem_cache *s)
+static int kmem_cache_vacate(struct page *page, void *scratch)
 {
-	int node;
-	int i;
-	struct kmem_cache_node *n;
+	void **vector = scratch;
+	void *p;
+	void *addr = page_address(page);
+	struct kmem_cache *s;
+	unsigned long *map;
+	int leftover;
+	int objects;
+	void *private;
+	unsigned long flags;
+	int tail = 1;
+
+	BUG_ON(!PageSlab(page) || !SlabFrozen(page));
+	local_irq_save(flags);
+	slab_lock(page);
+
+	s = page->slab;
+	map = scratch + s->objects * sizeof(void **);
+	if (!page->inuse || !s->kick)
+		goto out;
+
+	/* Determine used objects */
+	bitmap_fill(map, s->objects);
+	for_each_free_object(p, s, page->freelist)
+		__clear_bit(slab_index(p, s, addr), map);
+
+	objects = 0;
+	memset(vector, 0, s->objects * sizeof(void **));
+	for_each_object(p, s, addr)
+		if (test_bit(slab_index(p, s, addr), map))
+			vector[objects++] = p;
+
+	private = s->get(s, objects, vector);
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
+	s->kick(s, objects, vector, private);
+
+	local_irq_save(flags);
+	slab_lock(page);
+	tail = 0;
+out:
+	/*
+	 * Check the result and unfreeze the slab
+	 */
+	leftover = page->inuse;
+	unfreeze_slab(s, page, tail);
+	local_irq_restore(flags);
+	return leftover;
+}
+
+/*
+ * Reclaim objects from a list of slab pages that have been gathered.
+ * Must be called with slabs that have been isolated before.
+ */
+int kmem_cache_reclaim(struct list_head *zaplist)
+{
+	int freed = 0;
+	void **scratch;
 	struct page *page;
-	struct page *t;
-	struct list_head *slabs_by_inuse =
-		kmalloc(sizeof(struct list_head) * s->objects, GFP_KERNEL);
+	struct page *page2;
+
+	if (list_empty(zaplist))
+		return 0;
+
+	scratch = alloc_scratch();
+	if (!scratch)
+		return 0;
+
+	list_for_each_entry_safe(page, page2, zaplist, lru) {
+		list_del(&page->lru);
+		if (kmem_cache_vacate(page, scratch) == 0)
+				freed++;
+	}
+	kfree(scratch);
+	return freed;
+}
+
+/*
+ * Shrink the slab cache on a particular node of the cache
+ * by releasing slabs with zero objects and trying to reclaim
+ * slabs with less than a quarter of objects allocated.
+ */
+static unsigned long __kmem_cache_shrink(struct kmem_cache *s,
+	struct kmem_cache_node *n)
+{
 	unsigned long flags;
+	struct page *page, *page2;
+	LIST_HEAD(zaplist);
+	int freed = 0;
+	int inuse;
 
-	if (!slabs_by_inuse)
-		return -ENOMEM;
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry_safe(page, page2, &n->partial, lru) {
+		inuse = page->inuse;
 
-	flush_all(s);
-	for_each_online_node(node) {
-		n = get_node(s, node);
+		if (inuse > s->objects / 4)
+			continue;
 
-		if (!n->nr_partial)
+		if (!slab_trylock(page))
 			continue;
 
-		for (i = 0; i < s->objects; i++)
-			INIT_LIST_HEAD(slabs_by_inuse + i);
+		if (inuse) {
 
-		spin_lock_irqsave(&n->list_lock, flags);
+			list_move(&page->lru, &zaplist);
 
-		/*
-		 * Build lists indexed by the items in use in each slab.
-		 *
-		 * Note that concurrent frees may occur while we hold the
-		 * list_lock. page->inuse here is the upper limit.
-		 */
-		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			if (!page->inuse && slab_trylock(page)) {
-				/*
-				 * Must hold slab lock here because slab_free
-				 * may have freed the last object and be
-				 * waiting to release the slab.
-				 */
-				list_del(&page->lru);
+			if (s->kick) {
 				n->nr_partial--;
-				slab_unlock(page);
-				discard_slab(s, page);
-			} else {
-				list_move(&page->lru,
-				slabs_by_inuse + page->inuse);
+				SetSlabFrozen(page);
 			}
+			slab_unlock(page);
+
+		} else {
+			list_del(&page->lru);
+			slab_unlock(page);
+			discard_slab(s, page);
+			freed++;
 		}
+	}
+
+	if (!s->kick)
+		/* Simply put the zaplist at the end */
+		list_splice(&zaplist, n->partial.prev);
 
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	if (s->kick)
 		/*
-		 * Rebuild the partial list with the slabs filled up most
-		 * first and the least used slabs at the end.
+		 * Now we can free objects in the slabs on the zaplist
+		 * (or we simply reorder the list
 		 */
-		for (i = s->objects - 1; i >= 0; i--)
-			list_splice(slabs_by_inuse + i, n->partial.prev);
+		freed += kmem_cache_reclaim(&zaplist);
 
-		spin_unlock_irqrestore(&n->list_lock, flags);
+	return freed;
+}
+
+
+static unsigned long __kmem_cache_defrag(struct kmem_cache *s, int node)
+{
+	unsigned long capacity;
+	unsigned long objects_in_full_slabs;
+	unsigned long ratio;
+	struct kmem_cache_node *n = get_node(s, node);
+
+	/*
+	 * An insignificant number of partial slabs makes
+	 * the slab not interesting.
+	 */
+	if (n->nr_partial <= MAX_PARTIAL)
+		return 0;
+
+	capacity = atomic_long_read(&n->nr_slabs) * s->objects;
+	objects_in_full_slabs =
+			(atomic_long_read(&n->nr_slabs) - n->nr_partial)
+							* s->objects;
+	/*
+	 * Worst case calculation: If we would be over the ratio
+	 * even if all partial slabs would only have one object
+	 * then we can skip the further test that would require a scan
+	 * through all the partial page structs to sum up the actual
+	 * number of objects in the partial slabs.
+	 */
+	ratio = (objects_in_full_slabs + 1 * n->nr_partial) * 100 / capacity;
+	if (ratio > s->defrag_ratio)
+		return 0;
+
+	/*
+	 * Now for the real calculation. If usage ratio is more than required
+	 * then no defragmentation
+	 */
+	ratio = (objects_in_full_slabs + count_partial(n)) * 100 / capacity;
+	if (ratio > s->defrag_ratio)
+		return 0;
+
+	return __kmem_cache_shrink(s, n) << s->order;
+}
+
+/*
+ * Defrag slabs conditional on the fragmentation ratio on each node.
+ */
+int kmem_cache_defrag(int node)
+{
+	struct kmem_cache *s;
+	unsigned long pages = 0;
+
+	/*
+	 * kmem_cache_defrag may be called from the reclaim path which may be
+	 * called for any page allocator alloc. So there is the danger that we
+	 * get called in a situation where slub already acquired the slub_lock
+	 * for other purposes.
+	 */
+	if (!down_read_trylock(&slub_lock))
+		return 0;
+
+	list_for_each_entry(s, &slab_caches, list) {
+		if (node == -1) {
+			int nid;
+
+			for_each_online_node(nid)
+				pages += __kmem_cache_defrag(s, nid);
+		} else
+			pages += __kmem_cache_defrag(s, node);
 	}
+	up_read(&slub_lock);
+	return pages;
+}
+EXPORT_SYMBOL(kmem_cache_defrag);
+
+/*
+ * kmem_cache_shrink removes empty slabs from the partial lists.
+ * If the slab cache support defragmentation then objects are
+ * reclaimed.
+ */
+int kmem_cache_shrink(struct kmem_cache *s)
+{
+	int node;
+
+	flush_all(s);
+	for_each_online_node(node)
+		__kmem_cache_shrink(s, get_node(s, node));
 
-	kfree(slabs_by_inuse);
 	return 0;
 }
 EXPORT_SYMBOL(kmem_cache_shrink);

-- 

Message-Id: <20070618095916.297690463@sgi.com>
References: <20070618095838.238615343@sgi.com>
Date: Mon, 18 Jun 2007 02:58:50 -0700
From: clameter@sgi.com
Subject: [patch 12/26] SLUB: Slab defragmentation core
Content-Disposition: inline; filename=slab_defrag_core
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

Slab defragmentation occurs either

1. Unconditionally when kmem_cache_shrink is called on slab by the kernel
   calling kmem_cache_shrink or slabinfo triggering slab shrinking. This
   form performs defragmentation on all nodes of a NUMA system.

2. Conditionally when kmem_cache_defrag(<percentage>, <node>) is called.

   The defragmentation is only performed if the fragmentation of the slab
   is higher then the specified percentage. Fragmentation ratios are measured
   by calculating the percentage of objects in use compared to the total
   number of objects that the slab cache could hold.

   kmem_cache_defrag takes a node parameter. This can either be -1 if
   defragmentation should be performed on all nodes, or a node number.
   If a node number was specified then defragmentation is only performed
   on a specific node.

   Slab defragmentation is a memory intensive operation that can be
   sped up in a NUMA system if mostly node local memory is accessed. That
   is the case if we just have reclaimed reclaim on a node.

For defragmentation SLUB first generates a sorted list of partial slabs.
Sorting is performed according to the number of objects allocated.
Thus the slabs with the least objects will be at the end.

We extract slabs off the tail of that list until we have either reached a
mininum number of slabs or until we encounter a slab that has more than a
quarter of its objects allocated. Then we attempt to remove the objects
from each of the slabs taken.

In order for a slabcache to support defragmentation a couple of functions
must be defined via kmem_cache_ops. These are

void *get(struct kmem_cache *s, int nr, void **objects)

	Must obtain a reference to the listed objects. SLUB guarantees that
	the objects are still allocated. However, other threads may be blocked
	in slab_free attempting to free objects in the slab. These may succeed
	as soon as get() returns to the slab allocator. The function must
	be able to detect the situation and void the attempts to handle such
	objects (by for example voiding the corresponding entry in the objects
	array).

	No slab operations may be performed in get_reference(). Interrupts
	are disabled. What can be done is very limited. The slab lock
	for the page with the object is taken. Any attempt to perform a slab
	operation may lead to a deadlock.

	get() returns a private pointer that is passed to kick. Should we
	be unable to obtain all references then that pointer may indicate
	to the kick() function that it should not attempt any object removal
	or move but simply remove the reference counts.

void kick(struct kmem_cache *, int nr, void **objects, void *get_result)

	After SLUB has established references to the objects in a
	slab it will drop all locks and then use kick() to move objects out
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
 include/linux/slab.h |   32 ++++
 mm/slab.c            |    5 
 mm/slob.c            |    5 
 mm/slub.c            |  344 +++++++++++++++++++++++++++++++++++++++++----------
 4 files changed, 322 insertions(+), 64 deletions(-)

Index: linux-2.6.22-rc4-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.22-rc4-mm2.orig/include/linux/slab.h	2007-06-17 18:12:19.000000000 -0700
+++ linux-2.6.22-rc4-mm2/include/linux/slab.h	2007-06-17 18:12:22.000000000 -0700
@@ -51,7 +51,39 @@
 void __init kmem_cache_init(void);
 int slab_is_available(void);
 
+struct kmem_cache;
+
 struct kmem_cache_ops {
+	/*
+	 * Called with slab lock held and interrupts disabled.
+	 * No slab operation may be performed.
+	 *
+	 * Parameters passed are the number of objects to process
+	 * and an array of pointers to objects for which we
+	 * need references.
+	 *
+	 * Returns a pointer that is passed to the kick function.
+	 * If all objects cannot be moved then the pointer may
+	 * indicate that this wont work and then kick can simply
+	 * remove the references that were already obtained.
+	 *
+	 * The array passed to get() is also passed to kick(). The
+	 * function may remove objects by setting array elements to NULL.
+	 */
+	void *(*get)(struct kmem_cache *, int nr, void **);
+
+	/*
+	 * Called with no locks held and interrupts enabled.
+	 * Any operation may be performed in kick().
+	 *
+	 * Parameters passed are the number of objects in the array,
+	 * the array of pointers to the objects and the pointer
+	 * returned by get().
+	 *
+	 * Success is checked by examining the number of remaining
+	 * objects in the slab.
+	 */
+	void (*kick)(struct kmem_cache *, int nr, void **, void *private);
 };
 
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-17 18:12:19.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-17 18:12:22.000000000 -0700
@@ -2464,6 +2464,195 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);
 
+static unsigned long count_partial(struct kmem_cache_node *n)
+{
+	unsigned long flags;
+	unsigned long x = 0;
+	struct page *page;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry(page, &n->partial, lru)
+		x += page->inuse;
+	spin_unlock_irqrestore(&n->list_lock, flags);
+	return x;
+}
+
+/*
+ * Vacate all objects in the given slab.
+ *
+ * Slab must be locked and frozen. Interrupts are disabled (flags must
+ * be passed).
+ *
+ * Will drop and regain and drop the slab lock. At the end the slab will
+ * either be freed or returned to the partial lists.
+ *
+ * Returns the number of remaining objects
+ */
+static int __kmem_cache_vacate(struct kmem_cache *s,
+		struct page *page, unsigned long flags, void *scratch)
+{
+	void **vector = scratch;
+	void *p;
+	void *addr = page_address(page);
+	DECLARE_BITMAP(map, s->objects);
+	int leftover;
+	int objects;
+	void *private;
+
+	if (!page->inuse)
+		goto out;
+
+	/* Determine used objects */
+	bitmap_fill(map, s->objects);
+	for_each_free_object(p, s, page->freelist)
+		__clear_bit(slab_index(p, s, addr), map);
+
+	objects = 0;
+	memset(vector, 0, s->objects * sizeof(void **));
+	for_each_object(p, s, addr) {
+		if (test_bit(slab_index(p, s, addr), map))
+			vector[objects++] = p;
+	}
+
+	private = s->ops->get(s, objects, vector);
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
+	s->ops->kick(s, objects, vector, private);
+
+	local_irq_save(flags);
+	slab_lock(page);
+out:
+	/*
+	 * Check the result and unfreeze the slab
+	 */
+	leftover = page->inuse;
+	unfreeze_slab(s, page);
+	local_irq_restore(flags);
+	return leftover;
+}
+
+/*
+ * Sort the partial slabs by the number of items allocated.
+ * The slabs with the least objects come last.
+ */
+static unsigned long sort_partial_list(struct kmem_cache *s,
+	struct kmem_cache_node *n, void *scratch)
+{
+	struct list_head *slabs_by_inuse = scratch;
+	int i;
+	struct page *page;
+	struct page *t;
+	unsigned long freed = 0;
+
+	for (i = 0; i < s->objects; i++)
+		INIT_LIST_HEAD(slabs_by_inuse + i);
+
+	/*
+	 * Build lists indexed by the items in use in each slab.
+	 *
+	 * Note that concurrent frees may occur while we hold the
+	 * list_lock. page->inuse here is the upper limit.
+	 */
+	list_for_each_entry_safe(page, t, &n->partial, lru) {
+		if (!page->inuse && slab_trylock(page)) {
+			/*
+			 * Must hold slab lock here because slab_free
+			 * may have freed the last object and be
+			 * waiting to release the slab.
+			 */
+			list_del(&page->lru);
+			n->nr_partial--;
+			slab_unlock(page);
+			discard_slab(s, page);
+			freed++;
+		} else {
+			list_move(&page->lru,
+			slabs_by_inuse + page->inuse);
+		}
+	}
+
+	/*
+	 * Rebuild the partial list with the slabs filled up most
+	 * first and the least used slabs at the end.
+	 */
+	for (i = s->objects - 1; i >= 0; i--)
+		list_splice(slabs_by_inuse + i, n->partial.prev);
+
+	return freed;
+}
+
+/*
+ * Shrink the slab cache on a particular node of the cache
+ */
+static unsigned long __kmem_cache_shrink(struct kmem_cache *s,
+	struct kmem_cache_node *n, void *scratch)
+{
+	unsigned long flags;
+	struct page *page, *page2;
+	LIST_HEAD(zaplist);
+	int freed;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	freed = sort_partial_list(s, n, scratch);
+
+	/*
+	 * If we have no functions available to defragment the slabs
+	 * then we are done.
+	*/
+	if (!s->ops->get || !s->ops->kick) {
+		spin_unlock_irqrestore(&n->list_lock, flags);
+		return freed;
+	}
+
+	/*
+	 * Take slabs with just a few objects off the tail of the now
+	 * ordered list. These are the slabs with the least objects
+	 * and those are likely easy to reclaim.
+	 */
+	while (n->nr_partial > MAX_PARTIAL) {
+		page = container_of(n->partial.prev, struct page, lru);
+
+		/*
+		 * We are holding the list_lock so we can only
+		 * trylock the slab
+		 */
+		if (page->inuse > s->objects / 4)
+			break;
+
+		if (!slab_trylock(page))
+			break;
+
+		list_move_tail(&page->lru, &zaplist);
+		n->nr_partial--;
+		SetSlabFrozen(page);
+		slab_unlock(page);
+	}
+
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	/* Now we can free objects in the slabs on the zaplist */
+	list_for_each_entry_safe(page, page2, &zaplist, lru) {
+		unsigned long flags;
+
+		local_irq_save(flags);
+		slab_lock(page);
+		if (__kmem_cache_vacate(s, page, flags, scratch) == 0)
+			freed++;
+	}
+	return freed;
+}
+
 /*
  * kmem_cache_shrink removes empty slabs from the partial lists and sorts
  * the remaining slabs by the number of items in use. The slabs with the
@@ -2477,71 +2666,97 @@ EXPORT_SYMBOL(kfree);
 int kmem_cache_shrink(struct kmem_cache *s)
 {
 	int node;
-	int i;
-	struct kmem_cache_node *n;
-	struct page *page;
-	struct page *t;
-	struct list_head *slabs_by_inuse =
-		kmalloc(sizeof(struct list_head) * s->objects, GFP_KERNEL);
-	unsigned long flags;
+	void *scratch;
+
+	flush_all(s);
 
-	if (!slabs_by_inuse)
+	scratch = kmalloc(sizeof(struct list_head) * s->objects,
+							GFP_KERNEL);
+	if (!scratch)
 		return -ENOMEM;
 
-	flush_all(s);
-	for_each_online_node(node) {
-		n = get_node(s, node);
+	for_each_online_node(node)
+		__kmem_cache_shrink(s, get_node(s, node), scratch);
 
-		if (!n->nr_partial)
-			continue;
+	kfree(scratch);
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_shrink);
 
-		for (i = 0; i < s->objects; i++)
-			INIT_LIST_HEAD(slabs_by_inuse + i);
+static unsigned long __kmem_cache_defrag(struct kmem_cache *s,
+				int percent, int node, void *scratch)
+{
+	unsigned long capacity;
+	unsigned long objects;
+	unsigned long ratio;
+	struct kmem_cache_node *n = get_node(s, node);
 
-		spin_lock_irqsave(&n->list_lock, flags);
+	/*
+	 * An insignificant number of partial slabs makes
+	 * the slab not interesting.
+	 */
+	if (n->nr_partial <= MAX_PARTIAL)
+		return 0;
 
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
-				n->nr_partial--;
-				slab_unlock(page);
-				discard_slab(s, page);
-			} else {
-				if (n->nr_partial > MAX_PARTIAL)
-					list_move(&page->lru,
-					slabs_by_inuse + page->inuse);
-			}
-		}
+	/*
+	 * Calculate usage ratio
+	 */
+	capacity = atomic_long_read(&n->nr_slabs) * s->objects;
+	objects = capacity - n->nr_partial * s->objects + count_partial(n);
+	ratio = objects * 100 / capacity;
 
-		if (n->nr_partial <= MAX_PARTIAL)
-			goto out;
+	/*
+	 * If usage ratio is more than required then no
+	 * defragmentation
+	 */
+	if (ratio > percent)
+		return 0;
+
+	return __kmem_cache_shrink(s, n, scratch) << s->order;
+}
+
+/*
+ * Defrag slabs on the local node if fragmentation is higher
+ * than the given percentage. This is called from the memory reclaim
+ * path.
+ */
+int kmem_cache_defrag(int percent, int node)
+{
+	struct kmem_cache *s;
+	unsigned long pages = 0;
+	void *scratch;
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
 
 		/*
-		 * Rebuild the partial list with the slabs filled up most
-		 * first and the least used slabs at the end.
+		 * The slab cache must have defrag methods.
 		 */
-		for (i = s->objects - 1; i >= 0; i--)
-			list_splice(slabs_by_inuse + i, n->partial.prev);
+		if (!s->ops || !s->ops->kick)
+			continue;
 
-	out:
-		spin_unlock_irqrestore(&n->list_lock, flags);
+		scratch = kmalloc(sizeof(struct list_head) * s->objects,
+								GFP_KERNEL);
+		if (node == -1) {
+			for_each_online_node(node)
+				pages += __kmem_cache_defrag(s, percent,
+							node, scratch);
+		} else
+			pages += __kmem_cache_defrag(s, percent, node, scratch);
+		kfree(scratch);
 	}
-
-	kfree(slabs_by_inuse);
-	return 0;
+	up_read(&slub_lock);
+	return pages;
 }
-EXPORT_SYMBOL(kmem_cache_shrink);
+EXPORT_SYMBOL(kmem_cache_defrag);
 
 /********************************************************************
  *			Basic setup of slabs
@@ -3178,19 +3393,6 @@ static int list_locations(struct kmem_ca
 	return n;
 }
 
-static unsigned long count_partial(struct kmem_cache_node *n)
-{
-	unsigned long flags;
-	unsigned long x = 0;
-	struct page *page;
-
-	spin_lock_irqsave(&n->list_lock, flags);
-	list_for_each_entry(page, &n->partial, lru)
-		x += page->inuse;
-	spin_unlock_irqrestore(&n->list_lock, flags);
-	return x;
-}
-
 enum slab_stat_type {
 	SL_FULL,
 	SL_PARTIAL,
@@ -3346,6 +3548,20 @@ static ssize_t ops_show(struct kmem_cach
 		x += sprint_symbol(buf + x, (unsigned long)s->ctor);
 		x += sprintf(buf + x, "\n");
 	}
+
+	if (s->ops->get) {
+		x += sprintf(buf + x, "get : ");
+		x += sprint_symbol(buf + x,
+				(unsigned long)s->ops->get);
+		x += sprintf(buf + x, "\n");
+	}
+
+	if (s->ops->kick) {
+		x += sprintf(buf + x, "kick : ");
+		x += sprint_symbol(buf + x,
+				(unsigned long)s->ops->kick);
+		x += sprintf(buf + x, "\n");
+	}
 	return x;
 }
 SLAB_ATTR_RO(ops);
Index: linux-2.6.22-rc4-mm2/mm/slab.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slab.c	2007-06-17 18:12:19.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slab.c	2007-06-17 18:12:22.000000000 -0700
@@ -2518,6 +2518,11 @@ int kmem_cache_shrink(struct kmem_cache 
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+int kmem_cache_defrag(int percent, int node)
+{
+	return 0;
+}
+
 /**
  * kmem_cache_destroy - delete a cache
  * @cachep: the cache to destroy
Index: linux-2.6.22-rc4-mm2/mm/slob.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slob.c	2007-06-17 18:12:19.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slob.c	2007-06-17 18:12:22.000000000 -0700
@@ -553,6 +553,11 @@ int kmem_cache_shrink(struct kmem_cache 
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
+int kmem_cache_defrag(int percentage, int node)
+{
+	return 0;
+}
+
 int kmem_ptr_validate(struct kmem_cache *a, const void *b)
 {
 	return 0;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

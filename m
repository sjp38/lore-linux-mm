Message-Id: <20070507212409.425323872@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:49 -0700
From: clameter@sgi.com
Subject: [patch 09/17] SLUB: Update comments
Content-Disposition: inline; filename=comments
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Update comments throughout SLUB to reflect the new developments. Fix up
various awkward sentences.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |  246 ++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 121 insertions(+), 125 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 14:00:33.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 14:00:34.000000000 -0700
@@ -66,11 +66,11 @@
  * SLUB assigns one slab for allocation to each processor.
  * Allocations only occur from these slabs called cpu slabs.
  *
- * Slabs with free elements are kept on a partial list.
- * There is no list for full slabs. If an object in a full slab is
+ * Slabs with free elements are kept on a partial list and during regular
+ * operations no list for full slabs is used. If an object in a full slab is
  * freed then the slab will show up again on the partial lists.
- * Otherwise there is no need to track full slabs unless we have to
- * track full slabs for debugging purposes.
+ * We track full slabs for debugging purposes though because otherwise we
+ * cannot scan all objects.
  *
  * Slabs are freed when they become empty. Teardown and setup is
  * minimal so we rely on the page allocators per cpu caches for
@@ -92,8 +92,8 @@
  *
  * - The per cpu array is updated for each new slab and and is a remote
  *   cacheline for most nodes. This could become a bouncing cacheline given
- *   enough frequent updates. There are 16 pointers in a cacheline.so at
- *   max 16 cpus could compete. Likely okay.
+ *   enough frequent updates. There are 16 pointers in a cacheline, so at
+ *   max 16 cpus could compete for the cacheline which may be okay.
  *
  * - Support PAGE_ALLOC_DEBUG. Should be easy to do.
  *
@@ -144,6 +144,7 @@
 
 #define DEBUG_DEFAULT_FLAGS (SLAB_DEBUG_FREE | SLAB_RED_ZONE | \
 				SLAB_POISON | SLAB_STORE_USER)
+
 /*
  * Set of flags that will prevent slab merging
  */
@@ -173,7 +174,7 @@ static struct notifier_block slab_notifi
 static enum {
 	DOWN,		/* No slab functionality available */
 	PARTIAL,	/* kmem_cache_open() works but kmalloc does not */
-	UP,		/* Everything works */
+	UP,		/* Everything works but does not show up in sysfs */
 	SYSFS		/* Sysfs up */
 } slab_state = DOWN;
 
@@ -247,9 +248,9 @@ static void print_section(char *text, u8
 /*
  * Slow version of get and set free pointer.
  *
- * This requires touching the cache lines of kmem_cache.
- * The offset can also be obtained from the page. In that
- * case it is in the cacheline that we already need to touch.
+ * This version requires touching the cache lines of kmem_cache which
+ * we avoid to do in the fast alloc free paths. There we obtain the offset
+ * from the page struct.
  */
 static void *get_freepointer(struct kmem_cache *s, void *object)
 {
@@ -431,26 +432,34 @@ static inline int check_valid_pointer(st
  * 	Bytes of the object to be managed.
  * 	If the freepointer may overlay the object then the free
  * 	pointer is the first word of the object.
+ *
  * 	Poisoning uses 0x6b (POISON_FREE) and the last byte is
  * 	0xa5 (POISON_END)
  *
  * object + s->objsize
  * 	Padding to reach word boundary. This is also used for Redzoning.
- * 	Padding is extended to word size if Redzoning is enabled
- * 	and objsize == inuse.
+ * 	Padding is extended by another word if Redzoning is enabled and
+ * 	objsize == inuse.
+ *
  * 	We fill with 0xbb (RED_INACTIVE) for inactive objects and with
  * 	0xcc (RED_ACTIVE) for objects in use.
  *
  * object + s->inuse
+ * 	Meta data starts here.
+ *
  * 	A. Free pointer (if we cannot overwrite object on free)
  * 	B. Tracking data for SLAB_STORE_USER
- * 	C. Padding to reach required alignment boundary
- * 		Padding is done using 0x5a (POISON_INUSE)
+ * 	C. Padding to reach required alignment boundary or at mininum
+ * 		one word if debuggin is on to be able to detect writes
+ * 		before the word boundary.
+ *
+ *	Padding is done using 0x5a (POISON_INUSE)
  *
  * object + s->size
+ * 	Nothing is used beyond s->size.
  *
- * If slabcaches are merged then the objsize and inuse boundaries are to
- * be ignored. And therefore no slab options that rely on these boundaries
+ * If slabcaches are merged then the objsize and inuse boundaries are mostly
+ * ignored. And therefore no slab options that rely on these boundaries
  * may be used with merged slabcaches.
  */
 
@@ -576,8 +585,7 @@ static int check_object(struct kmem_cach
 		/*
 		 * No choice but to zap it and thus loose the remainder
 		 * of the free objects in this slab. May cause
-		 * another error because the object count maybe
-		 * wrong now.
+		 * another error because the object count is now wrong.
 		 */
 		set_freepointer(s, p, NULL);
 		return 0;
@@ -617,9 +625,8 @@ static int check_slab(struct kmem_cache 
 }
 
 /*
- * Determine if a certain object on a page is on the freelist and
- * therefore free. Must hold the slab lock for cpu slabs to
- * guarantee that the chains are consistent.
+ * Determine if a certain object on a page is on the freelist. Must hold the
+ * slab lock to guarantee that the chains are in a consistent state.
  */
 static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
 {
@@ -665,7 +672,7 @@ static int on_freelist(struct kmem_cache
 }
 
 /*
- * Tracking of fully allocated slabs for debugging
+ * Tracking of fully allocated slabs for debugging purposes.
  */
 static void add_full(struct kmem_cache_node *n, struct page *page)
 {
@@ -716,7 +723,7 @@ bad:
 		/*
 		 * If this is a slab page then lets do the best we can
 		 * to avoid issues in the future. Marking all objects
-		 * as used avoids touching the remainder.
+		 * as used avoids touching the remaining objects.
 		 */
 		printk(KERN_ERR "@@@ SLUB: %s slab 0x%p. Marking all objects used.\n",
 			s->name, page);
@@ -972,9 +979,9 @@ static void remove_partial(struct kmem_c
 }
 
 /*
- * Lock page and remove it from the partial list
+ * Lock slab and remove from the partial list.
  *
- * Must hold list_lock
+ * Must hold list_lock.
  */
 static int lock_and_del_slab(struct kmem_cache_node *n, struct page *page)
 {
@@ -987,7 +994,7 @@ static int lock_and_del_slab(struct kmem
 }
 
 /*
- * Try to get a partial slab from a specific node
+ * Try to allocate a partial slab from a specific node.
  */
 static struct page *get_partial_node(struct kmem_cache_node *n)
 {
@@ -996,7 +1003,8 @@ static struct page *get_partial_node(str
 	/*
 	 * Racy check. If we mistakenly see no partial slabs then we
 	 * just allocate an empty slab. If we mistakenly try to get a
-	 * partial slab then get_partials() will return NULL.
+	 * partial slab and there is none available then get_partials()
+	 * will return NULL.
 	 */
 	if (!n || !n->nr_partial)
 		return NULL;
@@ -1012,8 +1020,7 @@ out:
 }
 
 /*
- * Get a page from somewhere. Search in increasing NUMA
- * distances.
+ * Get a page from somewhere. Search in increasing NUMA distances.
  */
 static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 {
@@ -1023,24 +1030,22 @@ static struct page *get_any_partial(stru
 	struct page *page;
 
 	/*
-	 * The defrag ratio allows to configure the tradeoffs between
-	 * inter node defragmentation and node local allocations.
-	 * A lower defrag_ratio increases the tendency to do local
-	 * allocations instead of scanning throught the partial
-	 * lists on other nodes.
-	 *
-	 * If defrag_ratio is set to 0 then kmalloc() always
-	 * returns node local objects. If its higher then kmalloc()
-	 * may return off node objects in order to avoid fragmentation.
+	 * The defrag ratio allows a configuration of the tradeoffs between
+	 * inter node defragmentation and node local allocations. A lower
+	 * defrag_ratio increases the tendency to do local allocations
+	 * instead of attempting to obtain partial slabs from other nodes.
 	 *
-	 * A higher ratio means slabs may be taken from other nodes
-	 * thus reducing the number of partial slabs on those nodes.
+	 * If the defrag_ratio is set to 0 then kmalloc() always
+	 * returns node local objects. If the ratio is higher then kmalloc()
+	 * may return off node objects because partial slabs are obtained
+	 * from other nodes and filled up.
 	 *
 	 * If /sys/slab/xx/defrag_ratio is set to 100 (which makes
-	 * defrag_ratio = 1000) then every (well almost) allocation
-	 * will first attempt to defrag slab caches on other nodes. This
-	 * means scanning over all nodes to look for partial slabs which
-	 * may be a bit expensive to do on every slab allocation.
+	 * defrag_ratio = 1000) then every (well almost) allocation will
+	 * first attempt to defrag slab caches on other nodes. This means
+	 * scanning over all nodes to look for partial slabs which may be
+	 * expensive if we do it every time we are trying to find a slab
+	 * with available objects.
 	 */
 	if (!s->defrag_ratio || get_cycles() % 1024 > s->defrag_ratio)
 		return NULL;
@@ -1100,11 +1105,12 @@ static void putback_slab(struct kmem_cac
 	} else {
 		if (n->nr_partial < MIN_PARTIAL) {
 			/*
-			 * Adding an empty page to the partial slabs in order
-			 * to avoid page allocator overhead. This page needs to
-			 * come after all the others that are not fully empty
-			 * in order to make sure that we do maximum
-			 * defragmentation.
+			 * Adding an empty slab to the partial slabs in order
+			 * to avoid page allocator overhead. This slab needs
+			 * to come after the other slabs with objects in
+			 * order to fill them up. That way the size of the
+			 * partial list stays small. kmem_cache_shrink can
+			 * reclaim empty slabs from the partial list.
 			 */
 			add_partial_tail(n, page);
 			slab_unlock(page);
@@ -1172,7 +1178,7 @@ static void flush_all(struct kmem_cache 
  * 1. The page struct
  * 2. The first cacheline of the object to be allocated.
  *
- * The only cache lines that are read (apart from code) is the
+ * The only other cache lines that are read (apart from code) is the
  * per cpu array in the kmem_cache struct.
  *
  * Fastpath is not possible if we need to get a new slab or have
@@ -1226,9 +1232,11 @@ have_slab:
 		cpu = smp_processor_id();
 		if (s->cpu_slab[cpu]) {
 			/*
-			 * Someone else populated the cpu_slab while we enabled
-			 * interrupts, or we have got scheduled on another cpu.
-			 * The page may not be on the requested node.
+			 * Someone else populated the cpu_slab while we
+			 * enabled interrupts, or we have gotten scheduled
+			 * on another cpu. The page may not be on the
+			 * requested node even if __GFP_THISNODE was
+			 * specified. So we need to recheck.
 			 */
 			if (node == -1 ||
 				page_to_nid(s->cpu_slab[cpu]) == node) {
@@ -1241,7 +1249,7 @@ have_slab:
 				slab_lock(page);
 				goto redo;
 			}
-			/* Dump the current slab */
+			/* New slab does not fit our expectations */
 			flush_slab(s, s->cpu_slab[cpu], cpu);
 		}
 		slab_lock(page);
@@ -1282,7 +1290,8 @@ EXPORT_SYMBOL(kmem_cache_alloc_node);
  * The fastpath only writes the cacheline of the page struct and the first
  * cacheline of the object.
  *
- * No special cachelines need to be read
+ * We read the cpu_slab cacheline to check if the slab is the per cpu
+ * slab for this processor.
  */
 static void slab_free(struct kmem_cache *s, struct page *page,
 					void *x, void *addr)
@@ -1327,7 +1336,7 @@ out_unlock:
 slab_empty:
 	if (prior)
 		/*
-		 * Slab on the partial list.
+		 * Slab still on the partial list.
 		 */
 		remove_partial(s, page);
 
@@ -1376,22 +1385,16 @@ static struct page *get_object_page(cons
 }
 
 /*
- * kmem_cache_open produces objects aligned at "size" and the first object
- * is placed at offset 0 in the slab (We have no metainformation on the
- * slab, all slabs are in essence "off slab").
- *
- * In order to get the desired alignment one just needs to align the
- * size.
+ * Object placement in a slab is made very easy because we always start at
+ * offset 0. If we tune the size of the object to the alignment then we can
+ * get the required alignment by putting one properly sized object after
+ * another.
  *
  * Notice that the allocation order determines the sizes of the per cpu
  * caches. Each processor has always one slab available for allocations.
  * Increasing the allocation order reduces the number of times that slabs
- * must be moved on and off the partial lists and therefore may influence
+ * must be moved on and off the partial lists and is therefore a factor in
  * locking overhead.
- *
- * The offset is used to relocate the free list link in each object. It is
- * therefore possible to move the free list link behind the object. This
- * is necessary for RCU to work properly and also useful for debugging.
  */
 
 /*
@@ -1407,15 +1410,11 @@ static int user_override;
  */
 static int slub_min_order;
 static int slub_max_order = DEFAULT_MAX_ORDER;
-
-/*
- * Minimum number of objects per slab. This is necessary in order to
- * reduce locking overhead. Similar to the queue size in SLAB.
- */
 static int slub_min_objects = DEFAULT_MIN_OBJECTS;
 
 /*
  * Merge control. If this is set then no merging of slab caches will occur.
+ * (Could be removed. This was introduced to pacify the merge skeptics.)
  */
 static int slub_nomerge;
 
@@ -1429,23 +1428,27 @@ static char *slub_debug_slabs;
 /*
  * Calculate the order of allocation given an slab object size.
  *
- * The order of allocation has significant impact on other elements
- * of the system. Generally order 0 allocations should be preferred
- * since they do not cause fragmentation in the page allocator. Larger
- * objects may have problems with order 0 because there may be too much
- * space left unused in a slab. We go to a higher order if more than 1/8th
- * of the slab would be wasted.
- *
- * In order to reach satisfactory performance we must ensure that
- * a minimum number of objects is in one slab. Otherwise we may
- * generate too much activity on the partial lists. This is less a
- * concern for large slabs though. slub_max_order specifies the order
- * where we begin to stop considering the number of objects in a slab.
- *
- * Higher order allocations also allow the placement of more objects
- * in a slab and thereby reduce object handling overhead. If the user
- * has requested a higher mininum order then we start with that one
- * instead of zero.
+ * The order of allocation has significant impact on performance and other
+ * system components. Generally order 0 allocations should be preferred since
+ * order 0 does not cause fragmentation in the page allocator. Larger objects
+ * be problematic to put into order 0 slabs because there may be too much
+ * unused space left. We go to a higher order if more than 1/8th of the slab
+ * would be wasted.
+ *
+ * In order to reach satisfactory performance we must ensure that a minimum
+ * number of objects is in one slab. Otherwise we may generate too much
+ * activity on the partial lists which requires taking the list_lock. This is
+ * less a concern for large slabs though which are rarely used.
+ *
+ * slub_max_order specifies the order where we begin to stop considering the
+ * number of objects in a slab as critical. If we reach slub_max_order then
+ * we try to keep the page order as low as possible. So we accept more waste
+ * of space in favor of a small page order.
+ *
+ * Higher order allocations also allow the placement of more objects in a
+ * slab and thereby reduce object handling overhead. If the user has
+ * requested a higher mininum order then we start with that one instead of
+ * the smallest order which will fit the object.
  */
 static int calculate_order(int size)
 {
@@ -1465,18 +1468,18 @@ static int calculate_order(int size)
 
 		rem = slab_size % size;
 
-		if (rem <= (PAGE_SIZE << order) / 8)
+		if (rem <= slab_size / 8)
 			break;
 
 	}
 	if (order >= MAX_ORDER)
 		return -E2BIG;
+
 	return order;
 }
 
 /*
- * Function to figure out which alignment to use from the
- * various ways of specifying it.
+ * Figure out what the alignment of the objects will be.
  */
 static unsigned long calculate_alignment(unsigned long flags,
 		unsigned long align, unsigned long size)
@@ -1631,18 +1634,16 @@ static int calculate_sizes(struct kmem_c
 	size = ALIGN(size, sizeof(void *));
 
 	/*
-	 * If we are redzoning then check if there is some space between the
+	 * If we are Redzoning then check if there is some space between the
 	 * end of the object and the free pointer. If not then add an
-	 * additional word, so that we can establish a redzone between
-	 * the object and the freepointer to be able to check for overwrites.
+	 * additional word to have some bytes to store Redzone information.
 	 */
 	if ((flags & SLAB_RED_ZONE) && size == s->objsize)
 		size += sizeof(void *);
 
 	/*
-	 * With that we have determined how much of the slab is in actual
-	 * use by the object. This is the potential offset to the free
-	 * pointer.
+	 * With that we have determined the number of bytes in actual use
+	 * by the object. This is the potential offset to the free pointer.
 	 */
 	s->inuse = size;
 
@@ -1676,6 +1677,7 @@ static int calculate_sizes(struct kmem_c
 		 * of the object.
 		 */
 		size += sizeof(void *);
+
 	/*
 	 * Determine the alignment based on various parameters that the
 	 * user specified and the dynamic determination of cache line size
@@ -1777,7 +1779,6 @@ EXPORT_SYMBOL(kmem_cache_open);
 int kmem_ptr_validate(struct kmem_cache *s, const void *object)
 {
 	struct page * page;
-	void *addr;
 
 	page = get_object_page(object);
 
@@ -1814,7 +1815,8 @@ const char *kmem_cache_name(struct kmem_
 EXPORT_SYMBOL(kmem_cache_name);
 
 /*
- * Attempt to free all slabs on a node
+ * Attempt to free all slabs on a node. Return the number of slabs we
+ * were unable to free.
  */
 static int free_list(struct kmem_cache *s, struct kmem_cache_node *n,
 			struct list_head *list)
@@ -1835,7 +1837,7 @@ static int free_list(struct kmem_cache *
 }
 
 /*
- * Release all resources used by slab cache
+ * Release all resources used by a slab cache.
  */
 static int kmem_cache_close(struct kmem_cache *s)
 {
@@ -2096,13 +2098,14 @@ void kfree(const void *x)
 EXPORT_SYMBOL(kfree);
 
 /*
- *  kmem_cache_shrink removes empty slabs from the partial lists
- *  and then sorts the partially allocated slabs by the number
- *  of items in use. The slabs with the most items in use
- *  come first. New allocations will remove these from the
- *  partial list because they are full. The slabs with the
- *  least items are placed last. If it happens that the objects
- *  are freed then the page can be returned to the page allocator.
+ * kmem_cache_shrink removes empty slabs from the partial lists and sorts
+ * the remaining slabs by the number of items in use. The slabs with the
+ * most items in use come first. New allocations will then fill those up
+ * and thus they can be removed from the partial lists.
+ *
+ * The slabs with the least items are placed last. This results in them
+ * being allocated from last increasing the chance that the last objects
+ * are freed in them.
  */
 int kmem_cache_shrink(struct kmem_cache *s)
 {
@@ -2131,12 +2134,10 @@ int kmem_cache_shrink(struct kmem_cache 
 		spin_lock_irqsave(&n->list_lock, flags);
 
 		/*
-		 * Build lists indexed by the items in use in
-		 * each slab or free slabs if empty.
+		 * Build lists indexed by the items in use in each slab.
 		 *
-		 * Note that concurrent frees may occur while
-		 * we hold the list_lock. page->inuse here is
-		 * the upper limit.
+		 * Note that concurrent frees may occur while we hold the
+		 * list_lock. page->inuse here is the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
 			if (!page->inuse && slab_trylock(page)) {
@@ -2160,8 +2161,8 @@ int kmem_cache_shrink(struct kmem_cache 
 			goto out;
 
 		/*
-		 * Rebuild the partial list with the slabs filled up
-		 * most first and the least used slabs at the end.
+		 * Rebuild the partial list with the slabs filled up most
+		 * first and the least used slabs at the end.
 		 */
 		for (i = s->objects - 1; i >= 0; i--)
 			list_splice(slabs_by_inuse + i, n->partial.prev);
@@ -2233,7 +2234,7 @@ void __init kmem_cache_init(void)
 #ifdef CONFIG_NUMA
 	/*
 	 * Must first have the slab cache available for the allocations of the
-	 * struct kmalloc_cache_node's. There is special bootstrap code in
+	 * struct kmem_cache_node's. There is special bootstrap code in
 	 * kmem_cache_open for slab_state == DOWN.
 	 */
 	create_kmalloc_cache(&kmalloc_caches[0], "kmem_cache_node",
@@ -2405,8 +2406,8 @@ static void for_all_slabs(void (*func)(s
 }
 
 /*
- * Use the cpu notifier to insure that the slab are flushed
- * when necessary.
+ * Use the cpu notifier to insure that the cpu slabs are flushed when
+ * necessary.
  */
 static int __cpuinit slab_cpuup_callback(struct notifier_block *nfb,
 		unsigned long action, void *hcpu)
@@ -2488,11 +2489,6 @@ static void resiliency_test(void)
 static void resiliency_test(void) {};
 #endif
 
-/*
- * These are not as efficient as kmalloc for the non debug case.
- * We do not have the page struct available so we have to touch one
- * cacheline in struct kmem_cache to check slab flags.
- */
 void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, void *caller)
 {
 	struct kmem_cache *s = get_slab(size, gfpflags);
@@ -2610,7 +2606,7 @@ static unsigned long validate_slab_cache
 }
 
 /*
- * Generate lists of locations where slabcache objects are allocated
+ * Generate lists of code addresses where slabcache objects are allocated
  * and freed.
  */
 
@@ -2689,7 +2685,7 @@ static int add_location(struct loc_track
 	}
 
 	/*
-	 * Not found. Insert new tracking element
+	 * Not found. Insert new tracking element.
 	 */
 	if (t->count >= t->max && !alloc_loc_track(t, 2 * t->max))
 		return 0;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

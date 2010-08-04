Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6D6F166002D
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 22:45:35 -0400 (EDT)
Message-Id: <20100804024531.914852850@linux.com>
Date: Tue, 03 Aug 2010 21:45:28 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q3 14/23] slub: Add SLAB style per cpu queueing
References: <20100804024514.139976032@linux.com>
Content-Disposition: inline; filename=unified_core
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

This patch adds SLAB style cpu queueing and uses a new way for
managing objects in the slabs using bitmaps. It uses a percpu queue so that
free operations can be properly buffered and a bitmap for managing the
free/allocated state in the slabs. The approach uses slightly more memory
(due to the need to place large bitmaps --sized a few words--in some
slab pages) but in general does compete well in terms of space use.
The storage format using bitmaps avoids the SLAB management structure that
SLAB needs for each slab page and therefore metadata is more compact
and easily fits into a cacheline.

The SLAB scheme of not touching the object during management is adopted.
SLUB can now efficiently free and allocate cache cold objects.

The queueing scheme addresses also the issue that the free slowpath
was taken too frequently.

This patch only implements staticallly sized per cpu queues and does
not deal with NUMA queueing and shared queuing. Frees to remote nodes
are simply directly freed to the slab taking the per page slab lock.
(A later patch introduces the infamous alien caches to SLUB.)

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/page-flags.h |    5 
 include/linux/slub_def.h   |   47 +-
 init/Kconfig               |   14 
 mm/slub.c                  |  990 ++++++++++++++++++++-------------------------
 4 files changed, 488 insertions(+), 568 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-07-31 17:44:35.111063054 -0500
+++ linux-2.6/mm/slub.c	2010-07-31 18:25:53.244357184 -0500
@@ -1,11 +1,11 @@
 /*
- * SLUB: A slab allocator that limits cache line use instead of queuing
- * objects in per cpu and per node lists.
+ * SLUB: The unified slab allocator.
  *
  * The allocator synchronizes using per slab locks and only
  * uses a centralized lock to manage a pool of partial slabs.
  *
  * (C) 2007 SGI, Christoph Lameter
+ * (C) 2010 Linux Foundation, Christoph Lameter
  */
 
 #include <linux/mm.h>
@@ -84,27 +84,6 @@
  * minimal so we rely on the page allocators per cpu caches for
  * fast frees and allocs.
  *
- * Overloading of page flags that are otherwise used for LRU management.
- *
- * PageActive 		The slab is frozen and exempt from list processing.
- * 			This means that the slab is dedicated to a purpose
- * 			such as satisfying allocations for a specific
- * 			processor. Objects may be freed in the slab while
- * 			it is frozen but slab_free will then skip the usual
- * 			list operations. It is up to the processor holding
- * 			the slab to integrate the slab into the slab lists
- * 			when the slab is no longer needed.
- *
- * 			One use of this flag is to mark slabs that are
- * 			used for allocations. Then such a slab becomes a cpu
- * 			slab. The cpu slab may be equipped with an additional
- * 			freelist that allows lockless access to
- * 			free objects in addition to the regular freelist
- * 			that requires the slab lock.
- *
- * PageError		Slab requires special handling due to debug
- * 			options set. This moves	slab handling out of
- * 			the fast path and disables lockless freelists.
  */
 
 #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
@@ -259,38 +238,95 @@
 	return 1;
 }
 
-static inline void *get_freepointer(struct kmem_cache *s, void *object)
-{
-	return *(void **)(object + s->offset);
-}
-
-static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
-{
-	*(void **)(object + s->offset) = fp;
-}
-
 /* Loop over all objects in a slab */
 #define for_each_object(__p, __s, __addr, __objects) \
 	for (__p = (__addr); __p < (__addr) + (__objects) * (__s)->size;\
 			__p += (__s)->size)
 
-/* Scan freelist */
-#define for_each_free_object(__p, __s, __free) \
-	for (__p = (__free); __p; __p = get_freepointer((__s), __p))
-
 /* Determine object index from a given position */
 static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
 {
 	return (p - addr) / s->size;
 }
 
+static inline int map_in_page_struct(struct page *page)
+{
+	return page->objects <= BITS_PER_LONG;
+}
+
+static inline unsigned long *map(struct page *page)
+{
+	if (map_in_page_struct(page))
+		return (unsigned long *)&page->freelist;
+	else
+		return page->freelist;
+}
+
+static inline int map_size(struct page *page)
+{
+	return BITS_TO_LONGS(page->objects) * sizeof(unsigned long);
+}
+
+static inline int available(struct page *page)
+{
+	return bitmap_weight(map(page), page->objects);
+}
+
+static inline int all_objects_available(struct page *page)
+{
+	return bitmap_full(map(page), page->objects);
+}
+
+static inline int all_objects_used(struct page *page)
+{
+	return bitmap_empty(map(page), page->objects);
+}
+
+static inline int inuse(struct page *page)
+{
+	return page->objects - available(page);
+}
+
+/*
+ * Basic queue functions
+ */
+
+static inline void *queue_get(struct kmem_cache_queue *q)
+{
+	return q->object[--q->objects];
+}
+
+static inline void queue_put(struct kmem_cache_queue *q, void *object)
+{
+	q->object[q->objects++] = object;
+}
+
+static inline int queue_full(struct kmem_cache_queue *q)
+{
+	return q->objects == QUEUE_SIZE;
+}
+
+static inline int queue_empty(struct kmem_cache_queue *q)
+{
+	return q->objects == 0;
+}
+
 static inline struct kmem_cache_order_objects oo_make(int order,
 						unsigned long size)
 {
-	struct kmem_cache_order_objects x = {
-		(order << OO_SHIFT) + (PAGE_SIZE << order) / size
-	};
+	struct kmem_cache_order_objects x;
+	unsigned long objects;
+	unsigned long page_size = PAGE_SIZE << order;
+	unsigned long ws = sizeof(unsigned long);
+
+	objects = page_size / size;
+
+	if (objects > BITS_PER_LONG)
+		/* Bitmap must fit into the slab as well */
+		objects = ((page_size / ws) * BITS_PER_LONG) /
+			((size / ws) * BITS_PER_LONG + 1);
 
+	x.x = (order << OO_SHIFT) + objects;
 	return x;
 }
 
@@ -357,10 +393,7 @@
 {
 	struct track *p;
 
-	if (s->offset)
-		p = object + s->offset + sizeof(void *);
-	else
-		p = object + s->inuse;
+	p = object + s->inuse;
 
 	return p + alloc;
 }
@@ -408,8 +441,8 @@
 
 static void print_page_info(struct page *page)
 {
-	printk(KERN_ERR "INFO: Slab 0x%p objects=%u used=%u fp=0x%p flags=0x%04lx\n",
-		page, page->objects, page->inuse, page->freelist, page->flags);
+	printk(KERN_ERR "INFO: Slab 0x%p objects=%u new=%u fp=0x%p flags=0x%04lx\n",
+		page, page->objects, available(page), page->freelist, page->flags);
 
 }
 
@@ -448,8 +481,8 @@
 
 	print_page_info(page);
 
-	printk(KERN_ERR "INFO: Object 0x%p @offset=%tu fp=0x%p\n\n",
-			p, p - addr, get_freepointer(s, p));
+	printk(KERN_ERR "INFO: Object 0x%p @offset=%tu\n\n",
+			p, p - addr);
 
 	if (p > addr + 16)
 		print_section("Bytes b4", p - 16, 16);
@@ -460,10 +493,7 @@
 		print_section("Redzone", p + s->objsize,
 			s->inuse - s->objsize);
 
-	if (s->offset)
-		off = s->offset + sizeof(void *);
-	else
-		off = s->inuse;
+	off = s->inuse;
 
 	if (s->flags & SLAB_STORE_USER)
 		off += 2 * sizeof(struct track);
@@ -557,8 +587,6 @@
  *
  * object address
  * 	Bytes of the object to be managed.
- * 	If the freepointer may overlay the object then the free
- * 	pointer is the first word of the object.
  *
  * 	Poisoning uses 0x6b (POISON_FREE) and the last byte is
  * 	0xa5 (POISON_END)
@@ -574,9 +602,8 @@
  * object + s->inuse
  * 	Meta data starts here.
  *
- * 	A. Free pointer (if we cannot overwrite object on free)
- * 	B. Tracking data for SLAB_STORE_USER
- * 	C. Padding to reach required alignment boundary or at mininum
+ * 	A. Tracking data for SLAB_STORE_USER
+ * 	B. Padding to reach required alignment boundary or at mininum
  * 		one word if debugging is on to be able to detect writes
  * 		before the word boundary.
  *
@@ -594,10 +621,6 @@
 {
 	unsigned long off = s->inuse;	/* The end of info */
 
-	if (s->offset)
-		/* Freepointer is placed after the object. */
-		off += sizeof(void *);
-
 	if (s->flags & SLAB_STORE_USER)
 		/* We also have user information there */
 		off += 2 * sizeof(struct track);
@@ -622,15 +645,42 @@
 		return 1;
 
 	start = page_address(page);
-	length = (PAGE_SIZE << compound_order(page));
-	end = start + length;
-	remainder = length % s->size;
+	end = start + (PAGE_SIZE << compound_order(page));
+
+	/* Check for special case of bitmap at the end of the page */
+	if (!map_in_page_struct(page)) {
+		if ((u8 *)page->freelist > start && (u8 *)page->freelist < end)
+			end = page->freelist;
+		else
+			slab_err(s, page, "pagemap pointer invalid =%p start=%p end=%p objects=%d",
+				page->freelist, start, end, page->objects);
+	}
+
+	length = end - start;
+	remainder = length - page->objects * s->size;
 	if (!remainder)
 		return 1;
 
 	fault = check_bytes(end - remainder, POISON_INUSE, remainder);
-	if (!fault)
-		return 1;
+	if (!fault) {
+		u8 *freelist_end;
+
+		if (map_in_page_struct(page))
+			return 1;
+
+		end = start + (PAGE_SIZE << compound_order(page));
+		freelist_end = page->freelist + map_size(page);
+		remainder = end - freelist_end;
+
+		if (!remainder)
+			return 1;
+
+		fault = check_bytes(freelist_end, POISON_INUSE,
+				remainder);
+		if (!fault)
+			return 1;
+	}
+
 	while (end > fault && end[-1] == POISON_INUSE)
 		end--;
 
@@ -673,25 +723,6 @@
 		 */
 		check_pad_bytes(s, page, p);
 	}
-
-	if (!s->offset && active)
-		/*
-		 * Object and freepointer overlap. Cannot check
-		 * freepointer while object is allocated.
-		 */
-		return 1;
-
-	/* Check free pointer validity */
-	if (!check_valid_pointer(s, page, get_freepointer(s, p))) {
-		object_err(s, page, p, "Freepointer corrupt");
-		/*
-		 * No choice but to zap it and thus lose the remainder
-		 * of the free objects in this slab. May cause
-		 * another error because the object count is now wrong.
-		 */
-		set_freepointer(s, p, NULL);
-		return 0;
-	}
 	return 1;
 }
 
@@ -712,51 +743,45 @@
 			s->name, page->objects, maxobj);
 		return 0;
 	}
-	if (page->inuse > page->objects) {
-		slab_err(s, page, "inuse %u > max %u",
-			s->name, page->inuse, page->objects);
-		return 0;
-	}
+
 	/* Slab_pad_check fixes things up after itself */
 	slab_pad_check(s, page);
 	return 1;
 }
 
 /*
- * Determine if a certain object on a page is on the freelist. Must hold the
- * slab lock to guarantee that the chains are in a consistent state.
+ * Determine if a certain object on a page is on the free map.
  */
-static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
+static int object_marked_free(struct kmem_cache *s, struct page *page, void *search)
+{
+	return test_bit(slab_index(search, s, page_address(page)), map(page));
+}
+
+/* Verify the integrity of the metadata in a slab page */
+static int verify_slab(struct kmem_cache *s, struct page *page)
 {
 	int nr = 0;
-	void *fp = page->freelist;
-	void *object = NULL;
 	unsigned long max_objects;
+	void *start = page_address(page);
+	unsigned long size = PAGE_SIZE << compound_order(page);
 
-	while (fp && nr <= page->objects) {
-		if (fp == search)
-			return 1;
-		if (!check_valid_pointer(s, page, fp)) {
-			if (object) {
-				object_err(s, page, object,
-					"Freechain corrupt");
-				set_freepointer(s, object, NULL);
-				break;
-			} else {
-				slab_err(s, page, "Freepointer corrupt");
-				page->freelist = NULL;
-				page->inuse = page->objects;
-				slab_fix(s, "Freelist cleared");
-				return 0;
-			}
-			break;
-		}
-		object = fp;
-		fp = get_freepointer(s, object);
-		nr++;
+	nr = available(page);
+
+	if (map_in_page_struct(page))
+		max_objects = size / s->size;
+	else {
+		if (page->freelist <= start || page->freelist >= start + size) {
+			slab_err(s, page, "Invalid pointer to bitmap of free objects max_objects=%d!",
+				page->objects);
+			/* Switch to bitmap in page struct */
+			page->objects = max_objects = BITS_PER_LONG;
+			page->freelist = 0L;
+			slab_fix(s, "Slab sized for %d objects. ALl objects marked in use.",
+				BITS_PER_LONG);
+		} else
+			max_objects = ((void *)page->freelist - start) / s->size;
 	}
 
-	max_objects = (PAGE_SIZE << compound_order(page)) / s->size;
 	if (max_objects > MAX_OBJS_PER_PAGE)
 		max_objects = MAX_OBJS_PER_PAGE;
 
@@ -765,24 +790,19 @@
 			"should be %d", page->objects, max_objects);
 		page->objects = max_objects;
 		slab_fix(s, "Number of objects adjusted.");
+		return 0;
 	}
-	if (page->inuse != page->objects - nr) {
-		slab_err(s, page, "Wrong object count. Counter is %d but "
-			"counted were %d", page->inuse, page->objects - nr);
-		page->inuse = page->objects - nr;
-		slab_fix(s, "Object count adjusted.");
-	}
-	return search == NULL;
+	return 1;
 }
 
 static void trace(struct kmem_cache *s, struct page *page, void *object,
 								int alloc)
 {
 	if (s->flags & SLAB_TRACE) {
-		printk(KERN_INFO "TRACE %s %s 0x%p inuse=%d fp=0x%p\n",
+		printk(KERN_INFO "TRACE %s %s 0x%p free=%d fp=0x%p\n",
 			s->name,
 			alloc ? "alloc" : "free",
-			object, page->inuse,
+			object, available(page),
 			page->freelist);
 
 		if (!alloc)
@@ -828,14 +848,19 @@
 /*
  * Tracking of fully allocated slabs for debugging purposes.
  */
-static void add_full(struct kmem_cache_node *n, struct page *page)
+static inline void add_full(struct kmem_cache *s,
+		struct kmem_cache_node *n, struct page *page)
 {
+
+	if (!(s->flags & SLAB_STORE_USER))
+		return;
+
 	spin_lock(&n->list_lock);
 	list_add(&page->lru, &n->full);
 	spin_unlock(&n->list_lock);
 }
 
-static void remove_full(struct kmem_cache *s, struct page *page)
+static inline void remove_full(struct kmem_cache *s, struct page *page)
 {
 	struct kmem_cache_node *n;
 
@@ -896,25 +921,30 @@
 	init_tracking(s, object);
 }
 
-static noinline int alloc_debug_processing(struct kmem_cache *s, struct page *page,
-					void *object, unsigned long addr)
+static noinline int alloc_debug_processing(struct kmem_cache *s,
+		 		void *object, unsigned long addr)
 {
+	struct page *page = virt_to_head_page(object);
+
 	if (!check_slab(s, page))
 		goto bad;
 
-	if (!on_freelist(s, page, object)) {
-		object_err(s, page, object, "Object already allocated");
+	if (!check_valid_pointer(s, page, object)) {
+		object_err(s, page, object, "Pointer check fails");
 		goto bad;
 	}
 
-	if (!check_valid_pointer(s, page, object)) {
-		object_err(s, page, object, "Freelist Pointer check fails");
+	if (object_marked_free(s, page, object)) {
+		object_err(s, page, object, "Allocated object still marked free in slab");
 		goto bad;
 	}
 
 	if (!check_object(s, page, object, 0))
 		goto bad;
 
+	if (!verify_slab(s, page))
+		goto bad;
+
 	/* Success perform special debug activities for allocs */
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_ALLOC, addr);
@@ -930,8 +960,7 @@
 		 * as used avoids touching the remaining objects.
 		 */
 		slab_fix(s, "Marking all objects used");
-		page->inuse = page->objects;
-		page->freelist = NULL;
+		bitmap_zero(map(page), page->objects);
 	}
 	return 0;
 }
@@ -947,7 +976,7 @@
 		goto fail;
 	}
 
-	if (on_freelist(s, page, object)) {
+	if (object_marked_free(s, page, object)) {
 		object_err(s, page, object, "Object already free");
 		goto fail;
 	}
@@ -970,13 +999,11 @@
 		goto fail;
 	}
 
-	/* Special debug activities for freeing objects */
-	if (!PageSlubFrozen(page) && !page->freelist)
-		remove_full(s, page);
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_FREE, addr);
 	trace(s, page, object, 0);
 	init_object(s, object, 0);
+	verify_slab(s, page);
 	return 1;
 
 fail:
@@ -1081,7 +1108,8 @@
 			{ return 1; }
 static inline int check_object(struct kmem_cache *s, struct page *page,
 			void *object, int active) { return 1; }
-static inline void add_full(struct kmem_cache_node *n, struct page *page) {}
+static inline void add_full(struct kmem_cache *s,
+		struct kmem_cache_node *n, struct page *page) {}
 static inline unsigned long kmem_cache_flags(unsigned long objsize,
 	unsigned long flags, const char *name,
 	void (*ctor)(void *))
@@ -1183,8 +1211,8 @@
 {
 	struct page *page;
 	void *start;
-	void *last;
 	void *p;
+	unsigned long size;
 
 	BUG_ON(flags & GFP_SLAB_BUG_MASK);
 
@@ -1196,23 +1224,20 @@
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab = s;
 	page->flags |= 1 << PG_slab;
-
 	start = page_address(page);
+	size = PAGE_SIZE << compound_order(page);
 
 	if (unlikely(s->flags & SLAB_POISON))
-		memset(start, POISON_INUSE, PAGE_SIZE << compound_order(page));
+		memset(start, POISON_INUSE, size);
 
-	last = start;
-	for_each_object(p, s, start, page->objects) {
-		setup_object(s, page, last);
-		set_freepointer(s, last, p);
-		last = p;
-	}
-	setup_object(s, page, last);
-	set_freepointer(s, last, NULL);
+	if (!map_in_page_struct(page))
+		page->freelist = start + page->objects * s->size;
+
+	bitmap_fill(map(page), page->objects);
+
+	for_each_object(p, s, start, page->objects)
+		setup_object(s, page, p);
 
-	page->freelist = start;
-	page->inuse = 0;
 out:
 	return page;
 }
@@ -1329,7 +1354,6 @@
 	if (slab_trylock(page)) {
 		list_del(&page->lru);
 		n->nr_partial--;
-		__SetPageSlubFrozen(page);
 		return 1;
 	}
 	return 0;
@@ -1432,114 +1456,144 @@
 }
 
 /*
- * Move a page back to the lists.
- *
- * Must be called with the slab lock held.
- *
- * On exit the slab lock will have been dropped.
+ * Move the vector of objects back to the slab pages they came from
  */
-static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
+void drain_objects(struct kmem_cache *s, void **object, int nr)
 {
-	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+	int i;
 
-	__ClearPageSlubFrozen(page);
-	if (page->inuse) {
+	for (i = 0 ; i < nr; ) {
 
-		if (page->freelist) {
-			add_partial(n, page, tail);
-			stat(s, tail ? DEACTIVATE_TO_TAIL : DEACTIVATE_TO_HEAD);
-		} else {
-			stat(s, DEACTIVATE_FULL);
-			if (kmem_cache_debug(s) && (s->flags & SLAB_STORE_USER))
-				add_full(n, page);
+		void *p = object[i];
+		struct page *page = virt_to_head_page(p);
+		void *addr = page_address(page);
+		unsigned long size = PAGE_SIZE << compound_order(page);
+		int was_fully_allocated;
+		unsigned long *m;
+		unsigned long offset;
+
+		if (kmem_cache_debug(s) && !PageSlab(page)) {
+			object_err(s, page, object[i], "Object from non-slab page");
+			i++;
+			continue;
 		}
-		slab_unlock(page);
-	} else {
-		stat(s, DEACTIVATE_EMPTY);
-		if (n->nr_partial < s->min_partial) {
+
+		slab_lock(page);
+		m = map(page);
+		was_fully_allocated = bitmap_empty(m, page->objects);
+
+		offset = p - addr;
+
+
+		while (i < nr) {
+
+			int bit;
+			unsigned long new_offset;
+
+			if (offset >= size)
+				break;
+
+			if (kmem_cache_debug(s) && offset % s->size) {
+				object_err(s, page, object[i], "Misaligned object");
+				i++;
+				new_offset = object[i] - addr;
+				continue;
+			}
+
+			bit = offset / s->size;
+
 			/*
-			 * Adding an empty slab to the partial slabs in order
-			 * to avoid page allocator overhead. This slab needs
-			 * to come after the other slabs with objects in
-			 * so that the others get filled first. That way the
-			 * size of the partial list stays small.
-			 *
-			 * kmem_cache_shrink can reclaim any empty slabs from
-			 * the partial list.
-			 */
-			add_partial(n, page, 1);
-			slab_unlock(page);
-		} else {
+			 * Fast loop to fold a sequence of objects into the slab
+			 * avoiding division and virt_to_head_page()
+ 			 */
+			do {
+
+				if (kmem_cache_debug(s)) {
+					if (unlikely(__test_and_set_bit(bit, m)))
+						object_err(s, page, object[i], "Double free");
+				} else
+					__set_bit(bit, m);
+
+				i++;
+				bit++;
+				offset += s->size;
+				new_offset = object[i] - addr;
+
+			} while (new_offset ==  offset && i < nr && new_offset < size);
+
+			offset = new_offset;
+		}
+		if (bitmap_full(m, page->objects)) {
+
+			/* All objects are available now */
+			if (!was_fully_allocated) {
+
+				remove_partial(s, page);
+				stat(s, FREE_REMOVE_PARTIAL);
+			} else
+				remove_full(s, page);
+
 			slab_unlock(page);
-			stat(s, FREE_SLAB);
 			discard_slab(s, page);
+
+  		} else {
+
+			/* Some object are available now */
+			if (was_fully_allocated) {
+
+				/* Slab was had no free objects but has them now */
+				remove_full(s, page);
+				add_partial(get_node(s, page_to_nid(page)), page, 1);
+				stat(s, FREE_ADD_PARTIAL);
+			}
+			slab_unlock(page);
 		}
 	}
 }
 
-/*
- * Remove the cpu slab
- */
-static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
+static inline void drain_queue(struct kmem_cache *s, struct kmem_cache_queue *q, int nr)
 {
-	struct page *page = c->page;
-	int tail = 1;
-
-	if (page->freelist)
-		stat(s, DEACTIVATE_REMOTE_FREES);
-	/*
-	 * Merge cpu freelist into slab freelist. Typically we get here
-	 * because both freelists are empty. So this is unlikely
-	 * to occur.
-	 */
-	while (unlikely(c->freelist)) {
-		void **object;
+	int t = min(nr, q->objects);
 
-		tail = 0;	/* Hot objects. Put the slab first */
+	drain_objects(s, q->object, t);
 
-		/* Retrieve object from cpu_freelist */
-		object = c->freelist;
-		c->freelist = get_freepointer(s, c->freelist);
-
-		/* And put onto the regular freelist */
-		set_freepointer(s, object, page->freelist);
-		page->freelist = object;
-		page->inuse--;
-	}
-	c->page = NULL;
-	unfreeze_slab(s, page, tail);
+	q->objects -= t;
+	if (q->objects)
+		memcpy(q->object, q->object + t,
+					q->objects * sizeof(void *));
 }
-
-static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
+/*
+ * Drain all objects from a per cpu queue
+ */
+static void flush_cpu_objects(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
-	stat(s, CPUSLAB_FLUSH);
-	slab_lock(c->page);
-	deactivate_slab(s, c);
+	drain_queue(s, &c->q, c->q.objects);
+ 	stat(s, QUEUE_FLUSH);
 }
 
 /*
- * Flush cpu slab.
+ * Flush cpu objects.
  *
  * Called from IPI handler with interrupts disabled.
  */
-static inline void __flush_cpu_slab(struct kmem_cache *s, int cpu)
+static void __flush_cpu_objects(void *d)
 {
-	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+	struct kmem_cache *s = d;
+	struct kmem_cache_cpu *c = __this_cpu_ptr(s->cpu_slab);
 
-	if (likely(c && c->page))
-		flush_slab(s, c);
+	if (c->q.objects)
+		flush_cpu_objects(s, c);
 }
 
-static void flush_cpu_slab(void *d)
+static void flush_all(struct kmem_cache *s)
 {
-	struct kmem_cache *s = d;
-
-	__flush_cpu_slab(s, smp_processor_id());
+	on_each_cpu(__flush_cpu_objects, s, 1);
 }
 
-static void flush_all(struct kmem_cache *s)
+struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s, int n)
 {
-	on_each_cpu(flush_cpu_slab, s, 1);
+	return __alloc_percpu(sizeof(struct kmem_cache_cpu),
+		__alignof__(struct kmem_cache_cpu));
 }
 
 /*
@@ -1557,7 +1611,7 @@
 
 static int count_free(struct page *page)
 {
-	return page->objects - page->inuse;
+	return available(page);
 }
 
 static unsigned long count_partial(struct kmem_cache_node *n,
@@ -1619,139 +1673,149 @@
 }
 
 /*
- * Slow path. The lockless freelist is empty or we need to perform
- * debugging duties.
- *
- * Interrupts are disabled.
- *
- * Processing is still very fast if new objects have been freed to the
- * regular freelist. In that case we simply take over the regular freelist
- * as the lockless freelist and zap the regular freelist.
- *
- * If that is not working then we fall back to the partial lists. We take the
- * first element of the freelist as the object to allocate now and move the
- * rest of the freelist to the lockless freelist.
- *
- * And if we were unable to get a new slab from the partial slab lists then
- * we need to allocate a new slab. This is the slowest path since it involves
- * a call to the page allocator and the setup of a new slab.
- */
-static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
-			  unsigned long addr, struct kmem_cache_cpu *c)
-{
-	void **object;
-	struct page *new;
-
-	/* We handle __GFP_ZERO in the caller */
-	gfpflags &= ~__GFP_ZERO;
-
-	if (!c->page)
-		goto new_slab;
-
-	slab_lock(c->page);
-	if (unlikely(!node_match(c, node)))
-		goto another_slab;
-
-	stat(s, ALLOC_REFILL);
-
-load_freelist:
-	object = c->page->freelist;
-	if (unlikely(!object))
-		goto another_slab;
-	if (kmem_cache_debug(s))
-		goto debug;
-
-	c->freelist = get_freepointer(s, object);
-	c->page->inuse = c->page->objects;
-	c->page->freelist = NULL;
-	c->node = page_to_nid(c->page);
-unlock_out:
-	slab_unlock(c->page);
-	stat(s, ALLOC_SLOWPATH);
-	return object;
+ * Retrieve pointers to nr objects from a slab into the object array.
+ * Slab must be locked.
+ */
+void retrieve_objects(struct kmem_cache *s, struct page *page, void **object, int nr)
+{
+	void *addr = page_address(page);
+	unsigned long *m = map(page);
+
+	while (nr > 0) {
+		int i = find_first_bit(m, page->objects);
+		void *a;
 
-another_slab:
-	deactivate_slab(s, c);
+		__clear_bit(i, m);
+		a = addr + i * s->size;
 
-new_slab:
-	new = get_partial(s, gfpflags, node);
-	if (new) {
-		c->page = new;
-		stat(s, ALLOC_FROM_PARTIAL);
-		goto load_freelist;
-	}
-
-	gfpflags &= gfp_allowed_mask;
-	if (gfpflags & __GFP_WAIT)
-		local_irq_enable();
-
-	new = new_slab(s, gfpflags, node);
-
-	if (gfpflags & __GFP_WAIT)
-		local_irq_disable();
-
-	if (new) {
-		c = __this_cpu_ptr(s->cpu_slab);
-		stat(s, ALLOC_SLAB);
-		if (c->page)
-			flush_slab(s, c);
-		slab_lock(new);
-		__SetPageSlubFrozen(new);
-		c->page = new;
-		goto load_freelist;
+		/*
+		 * Fast loop to get a sequence of objects out of the slab
+		 * without find_first_bit() and multiplication
+		 */
+		do {
+			nr--;
+			object[nr] = a;
+			a += s->size;
+			i++;
+		} while (nr > 0 && i < page->objects && __test_and_clear_bit(i, m));
 	}
-	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
-		slab_out_of_memory(s, gfpflags, node);
-	return NULL;
-debug:
-	if (!alloc_debug_processing(s, c->page, object, addr))
-		goto another_slab;
+}
+
+static inline void refill_queue(struct kmem_cache *s,
+		struct kmem_cache_queue *q, struct page *page, int nr)
+{
+	int d;
 
-	c->page->inuse++;
-	c->page->freelist = get_freepointer(s, object);
-	c->node = -1;
-	goto unlock_out;
+	d = min(BATCH_SIZE - q->objects, nr);
+	retrieve_objects(s, page, q->object + q->objects, d);
+	q->objects += d;
 }
 
-/*
- * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
- * have the fastpath folded into their functions. So no function call
- * overhead for requests that can be satisfied on the fastpath.
- *
- * The fastpath works by first checking if the lockless freelist can be used.
- * If not then __slab_alloc is called for slow processing.
- *
- * Otherwise we can simply pick the next object from the lockless free list.
- */
-static __always_inline void *slab_alloc(struct kmem_cache *s,
+void to_lists(struct kmem_cache *s, struct page *page, int tail)
+{
+	if (!all_objects_used(page))
+
+		add_partial(get_node(s, page_to_nid(page)), page, tail);
+
+	else
+		add_full(s, get_node(s, page_to_nid(page)), page);
+}
+
+/* Handling of objects from other nodes */
+
+static void slab_free_alien(struct kmem_cache *s,
+	struct kmem_cache_cpu *c, struct page *page, void *object, int node)
+{
+#ifdef CONFIG_NUMA
+	/* Direct free to the slab */
+	drain_objects(s, &object, 1);
+#endif
+}
+
+/* Generic allocation */
+
+static void *slab_alloc(struct kmem_cache *s,
 		gfp_t gfpflags, int node, unsigned long addr)
 {
-	void **object;
+	void *object;
 	struct kmem_cache_cpu *c;
+	struct kmem_cache_queue *q;
 	unsigned long flags;
 
-	if (!slab_pre_alloc_hook(s, gfpflags))
+	if (slab_pre_alloc_hook(s, gfpflags))
 		return NULL;
 
+redo:
 	local_irq_save(flags);
 	c = __this_cpu_ptr(s->cpu_slab);
-	object = c->freelist;
-	if (unlikely(!object || !node_match(c, node)))
+	q = &c->q;
+	if (unlikely(queue_empty(q) || !node_match(c, node))) {
 
-		object = __slab_alloc(s, gfpflags, node, addr, c);
+		if (unlikely(!node_match(c, node))) {
+			flush_cpu_objects(s, c);
+			c->node = node;
+		}
 
-	else {
-		c->freelist = get_freepointer(s, object);
+		while (q->objects < BATCH_SIZE) {
+			struct page *new;
+
+			new = get_partial(s, gfpflags & ~__GFP_ZERO, node);
+			if (unlikely(!new)) {
+
+				gfpflags &= gfp_allowed_mask;
+
+				if (gfpflags & __GFP_WAIT)
+					local_irq_enable();
+
+				new = new_slab(s, gfpflags, node);
+
+				if (gfpflags & __GFP_WAIT)
+					local_irq_disable();
+
+				/* process may have moved to different cpu */
+				c = __this_cpu_ptr(s->cpu_slab);
+				q = &c->q;
+
+ 				if (!new) {
+					if (queue_empty(q))
+						goto oom;
+					break;
+				}
+				stat(s, ALLOC_SLAB);
+				slab_lock(new);
+			} else
+				stat(s, ALLOC_FROM_PARTIAL);
+
+			refill_queue(s, q, new, available(new));
+			to_lists(s, new, 1);
+
+			slab_unlock(new);
+		}
+		stat(s, ALLOC_SLOWPATH);
+
+	} else
 		stat(s, ALLOC_FASTPATH);
+
+	object = queue_get(q);
+
+	if (kmem_cache_debug(s)) {
+		if (!alloc_debug_processing(s, object, addr))
+			goto redo;
 	}
 	local_irq_restore(flags);
 
-	if (unlikely(gfpflags & __GFP_ZERO) && object)
+	if (unlikely(gfpflags & __GFP_ZERO))
 		memset(object, 0, s->objsize);
 
 	slab_post_alloc_hook(s, gfpflags, object);
 
 	return object;
+
+oom:
+	local_irq_restore(flags);
+	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
+		slab_out_of_memory(s, gfpflags, node);
+	return NULL;
 }
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
@@ -1795,114 +1859,52 @@
 EXPORT_SYMBOL(kmem_cache_alloc_node_notrace);
 #endif
 
-/*
- * Slow patch handling. This may still be called frequently since objects
- * have a longer lifetime than the cpu slabs in most processing loads.
- *
- * So we still attempt to reduce cache line usage. Just take the slab
- * lock and free the item. If there is no additional partial page
- * handling required then we can return immediately.
- */
-static void __slab_free(struct kmem_cache *s, struct page *page,
+static void slab_free(struct kmem_cache *s, struct page *page,
 			void *x, unsigned long addr)
 {
-	void *prior;
-	void **object = (void *)x;
-
-	stat(s, FREE_SLOWPATH);
-	slab_lock(page);
+	struct kmem_cache_cpu *c;
+	struct kmem_cache_queue *q;
+	unsigned long flags;
 
-	if (kmem_cache_debug(s))
-		goto debug;
+	slab_free_hook(s, x);
 
-checks_ok:
-	prior = page->freelist;
-	set_freepointer(s, object, prior);
-	page->freelist = object;
-	page->inuse--;
-
-	if (unlikely(PageSlubFrozen(page))) {
-		stat(s, FREE_FROZEN);
-		goto out_unlock;
-	}
+	local_irq_save(flags);
+	if (kmem_cache_debug(s)
+			&& !free_debug_processing(s, page, x, addr))
+		goto out;
 
-	if (unlikely(!page->inuse))
-		goto slab_empty;
+	slab_free_hook_irq(s, x);
 
-	/*
-	 * Objects left in the slab. If it was not on the partial list before
-	 * then add it.
-	 */
-	if (unlikely(!prior)) {
-		add_partial(get_node(s, page_to_nid(page)), page, 1);
-		stat(s, FREE_ADD_PARTIAL);
-	}
+	c = __this_cpu_ptr(s->cpu_slab);
 
-out_unlock:
-	slab_unlock(page);
-	return;
+	if (NUMA_BUILD) {
+		int node = page_to_nid(page);
 
-slab_empty:
-	if (prior) {
-		/*
-		 * Slab still on the partial list.
-		 */
-		remove_partial(s, page);
-		stat(s, FREE_REMOVE_PARTIAL);
+		if (unlikely(node != c->node)) {
+			slab_free_alien(s, c, page, x, node);
+			stat(s, FREE_ALIEN);
+			goto out;
+		}
 	}
-	slab_unlock(page);
-	stat(s, FREE_SLAB);
-	discard_slab(s, page);
-	return;
-
-debug:
-	if (!free_debug_processing(s, page, x, addr))
-		goto out_unlock;
-	goto checks_ok;
-}
-
-/*
- * Fastpath with forced inlining to produce a kfree and kmem_cache_free that
- * can perform fastpath freeing without additional function calls.
- *
- * The fastpath is only possible if we are freeing to the current cpu slab
- * of this processor. This typically the case if we have just allocated
- * the item before.
- *
- * If fastpath is not possible then fall back to __slab_free where we deal
- * with all sorts of special processing.
- */
-static __always_inline void slab_free(struct kmem_cache *s,
-			struct page *page, void *x, unsigned long addr)
-{
-	void **object = (void *)x;
-	struct kmem_cache_cpu *c;
-	unsigned long flags;
 
-	slab_free_hook(s, x);
+	q = &c->q;
 
-	local_irq_save(flags);
-	c = __this_cpu_ptr(s->cpu_slab);
+	if (unlikely(queue_full(q))) {
 
-	slab_free_hook_irq(s, x);
+		drain_queue(s, q, BATCH_SIZE);
+		stat(s, FREE_SLOWPATH);
 
-	if (likely(page == c->page && c->node >= 0)) {
-		set_freepointer(s, object, c->freelist);
-		c->freelist = object;
-		stat(s, FREE_FASTPATH);
 	} else
-		__slab_free(s, page, x, addr);
+		stat(s, FREE_FASTPATH);
 
+	queue_put(q, x);
+out:
 	local_irq_restore(flags);
 }
 
 void kmem_cache_free(struct kmem_cache *s, void *x)
 {
-	struct page *page;
-
-	page = virt_to_head_page(x);
-
-	slab_free(s, page, x, _RET_IP_);
+	slab_free(s, virt_to_head_page(x), x, _RET_IP_);
 
 	trace_kmem_cache_free(_RET_IP_, x);
 }
@@ -1920,11 +1922,6 @@
 }
 
 /*
- * Object placement in a slab is made very easy because we always start at
- * offset 0. If we tune the size of the object to the alignment then we can
- * get the required alignment by putting one properly sized object after
- * another.
- *
  * Notice that the allocation order determines the sizes of the per cpu
  * caches. Each processor has always one slab available for allocations.
  * Increasing the allocation order reduces the number of times that slabs
@@ -2019,7 +2016,7 @@
 	 */
 	min_objects = slub_min_objects;
 	if (!min_objects)
-		min_objects = 4 * (fls(nr_cpu_ids) + 1);
+		min_objects = min(BITS_PER_LONG, 4 * (fls(nr_cpu_ids) + 1));
 	max_objects = (PAGE_SIZE << slub_max_order)/size;
 	min_objects = min(min_objects, max_objects);
 
@@ -2131,10 +2128,7 @@
 				"in order to be able to continue\n");
 	}
 
-	n = page->freelist;
-	BUG_ON(!n);
-	page->freelist = get_freepointer(kmem_cache_node, n);
-	page->inuse++;
+	retrieve_objects(kmem_cache_node, page, (void **)&n, 1);
 	kmem_cache_node->node[node] = n;
 #ifdef CONFIG_SLUB_DEBUG
 	init_object(kmem_cache_node, n, 1);
@@ -2219,10 +2213,11 @@
 static int calculate_sizes(struct kmem_cache *s, int forced_order)
 {
 	unsigned long flags = s->flags;
-	unsigned long size = s->objsize;
+	unsigned long size;
 	unsigned long align = s->align;
 	int order;
 
+	size = s->objsize;
 	/*
 	 * Round up object size to the next word boundary. We can only
 	 * place the free pointer at word boundaries and this determines
@@ -2254,24 +2249,10 @@
 
 	/*
 	 * With that we have determined the number of bytes in actual use
-	 * by the object. This is the potential offset to the free pointer.
+	 * by the object.
 	 */
 	s->inuse = size;
 
-	if (((flags & (SLAB_DESTROY_BY_RCU | SLAB_POISON)) ||
-		s->ctor)) {
-		/*
-		 * Relocate free pointer after the object if it is not
-		 * permitted to overwrite the first word of the object on
-		 * kmem_cache_free.
-		 *
-		 * This is the case if we do RCU, have a constructor or
-		 * destructor or are poisoning the objects.
-		 */
-		s->offset = size;
-		size += sizeof(void *);
-	}
-
 #ifdef CONFIG_SLUB_DEBUG
 	if (flags & SLAB_STORE_USER)
 		/*
@@ -2357,7 +2338,6 @@
 		 */
 		if (get_order(s->size) > get_order(s->objsize)) {
 			s->flags &= ~DEBUG_METADATA_FLAGS;
-			s->offset = 0;
 			if (!calculate_sizes(s, -1))
 				goto error;
 		}
@@ -2382,9 +2362,9 @@
 error:
 	if (flags & SLAB_PANIC)
 		panic("Cannot create slab %s size=%lu realsize=%u "
-			"order=%u offset=%u flags=%lx\n",
+			"order=%u flags=%lx\n",
 			s->name, (unsigned long)size, s->size, oo_order(s->oo),
-			s->offset, flags);
+			flags);
 	return 0;
 }
 
@@ -2438,19 +2418,14 @@
 #ifdef CONFIG_SLUB_DEBUG
 	void *addr = page_address(page);
 	void *p;
-	long *map = kzalloc(BITS_TO_LONGS(page->objects) * sizeof(long),
-			    GFP_ATOMIC);
+	long *m = map(page);
 
-	if (!map)
-		return;
 	slab_err(s, page, "%s", text);
 	slab_lock(page);
-	for_each_free_object(p, s, page->freelist)
-		set_bit(slab_index(p, s, addr), map);
 
 	for_each_object(p, s, addr, page->objects) {
 
-		if (!test_bit(slab_index(p, s, addr), map)) {
+		if (!test_bit(slab_index(p, s, addr), m)) {
 			printk(KERN_ERR "INFO: Object 0x%p @offset=%tu\n",
 							p, p - addr);
 			print_tracking(s, p);
@@ -2471,7 +2446,7 @@
 
 	spin_lock_irqsave(&n->list_lock, flags);
 	list_for_each_entry_safe(page, h, &n->partial, lru) {
-		if (!page->inuse) {
+		if (all_objects_available(page)) {
 			list_del(&page->lru);
 			discard_slab(s, page);
 			n->nr_partial--;
@@ -2829,7 +2804,7 @@
 		 * list_lock. page->inuse here is the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			if (!page->inuse && slab_trylock(page)) {
+			if (all_objects_available(page) && slab_trylock(page)) {
 				/*
 				 * Must hold slab lock here because slab_free
 				 * may have freed the last object and be
@@ -2841,7 +2816,7 @@
 				discard_slab(s, page);
 			} else {
 				list_move(&page->lru,
-				slabs_by_inuse + page->inuse);
+				slabs_by_inuse + inuse(page));
 			}
 		}
 
@@ -3322,7 +3297,7 @@
 		down_read(&slub_lock);
 		list_for_each_entry(s, &slab_caches, list) {
 			local_irq_save(flags);
-			__flush_cpu_slab(s, cpu);
+			flush_cpu_objects(s, per_cpu_ptr(s->cpu_slab ,cpu));
 			local_irq_restore(flags);
 		}
 		up_read(&slub_lock);
@@ -3392,7 +3367,7 @@
 #ifdef CONFIG_SLUB_DEBUG
 static int count_inuse(struct page *page)
 {
-	return page->inuse;
+	return inuse(page);
 }
 
 static int count_total(struct page *page)
@@ -3400,54 +3375,52 @@
 	return page->objects;
 }
 
-static int validate_slab(struct kmem_cache *s, struct page *page,
-						unsigned long *map)
+static int validate_slab(struct kmem_cache *s, struct page *page)
 {
 	void *p;
 	void *addr = page_address(page);
+	unsigned long *m = map(page);
+	unsigned long errors = 0;
 
-	if (!check_slab(s, page) ||
-			!on_freelist(s, page, NULL))
+	if (!check_slab(s, page) || !verify_slab(s, page))
 		return 0;
 
-	/* Now we know that a valid freelist exists */
-	bitmap_zero(map, page->objects);
+	for_each_object(p, s, addr, page->objects) {
+		int bit = slab_index(p, s, addr);
+		int used = !test_bit(bit, m);
 
-	for_each_free_object(p, s, page->freelist) {
-		set_bit(slab_index(p, s, addr), map);
-		if (!check_object(s, page, p, 0))
-			return 0;
+		if (!check_object(s, page, p, used))
+			errors++;
 	}
 
-	for_each_object(p, s, addr, page->objects)
-		if (!test_bit(slab_index(p, s, addr), map))
-			if (!check_object(s, page, p, 1))
-				return 0;
-	return 1;
+	return errors;
 }
 
-static void validate_slab_slab(struct kmem_cache *s, struct page *page,
-						unsigned long *map)
+static unsigned long validate_slab_slab(struct kmem_cache *s, struct page *page)
 {
+	unsigned long errors = 0;
+
 	if (slab_trylock(page)) {
-		validate_slab(s, page, map);
+		errors = validate_slab(s, page);
 		slab_unlock(page);
 	} else
 		printk(KERN_INFO "SLUB %s: Skipped busy slab 0x%p\n",
 			s->name, page);
+	return errors;
 }
 
 static int validate_slab_node(struct kmem_cache *s,
-		struct kmem_cache_node *n, unsigned long *map)
+		struct kmem_cache_node *n)
 {
 	unsigned long count = 0;
 	struct page *page;
 	unsigned long flags;
+	unsigned long errors;
 
 	spin_lock_irqsave(&n->list_lock, flags);
 
 	list_for_each_entry(page, &n->partial, lru) {
-		validate_slab_slab(s, page, map);
+		errors += validate_slab_slab(s, page);
 		count++;
 	}
 	if (count != n->nr_partial)
@@ -3458,7 +3431,7 @@
 		goto out;
 
 	list_for_each_entry(page, &n->full, lru) {
-		validate_slab_slab(s, page, map);
+		validate_slab_slab(s, page);
 		count++;
 	}
 	if (count != atomic_long_read(&n->nr_slabs))
@@ -3468,26 +3441,20 @@
 
 out:
 	spin_unlock_irqrestore(&n->list_lock, flags);
-	return count;
+	return errors;
 }
 
 static long validate_slab_cache(struct kmem_cache *s)
 {
 	int node;
 	unsigned long count = 0;
-	unsigned long *map = kmalloc(BITS_TO_LONGS(oo_objects(s->max)) *
-				sizeof(unsigned long), GFP_KERNEL);
-
-	if (!map)
-		return -ENOMEM;
 
 	flush_all(s);
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
-		count += validate_slab_node(s, n, map);
+		count += validate_slab_node(s, n);
 	}
-	kfree(map);
 	return count;
 }
 
@@ -3676,18 +3643,14 @@
 }
 
 static void process_slab(struct loc_track *t, struct kmem_cache *s,
-		struct page *page, enum track_item alloc,
-		long *map)
+		struct page *page, enum track_item alloc)
 {
 	void *addr = page_address(page);
+	unsigned long *m = map(page);
 	void *p;
 
-	bitmap_zero(map, page->objects);
-	for_each_free_object(p, s, page->freelist)
-		set_bit(slab_index(p, s, addr), map);
-
 	for_each_object(p, s, addr, page->objects)
-		if (!test_bit(slab_index(p, s, addr), map))
+		if (!test_bit(slab_index(p, s, addr), m))
 			add_location(t, s, get_track(s, p, alloc));
 }
 
@@ -3698,12 +3661,9 @@
 	unsigned long i;
 	struct loc_track t = { 0, 0, NULL };
 	int node;
-	unsigned long *map = kmalloc(BITS_TO_LONGS(oo_objects(s->max)) *
-				     sizeof(unsigned long), GFP_KERNEL);
 
-	if (!map || !alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
+	if (!alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
 				     GFP_TEMPORARY)) {
-		kfree(map);
 		return sprintf(buf, "Out of memory\n");
 	}
 	/* Push back cpu slabs */
@@ -3719,9 +3679,9 @@
 
 		spin_lock_irqsave(&n->list_lock, flags);
 		list_for_each_entry(page, &n->partial, lru)
-			process_slab(&t, s, page, alloc, map);
+			process_slab(&t, s, page, alloc);
 		list_for_each_entry(page, &n->full, lru)
-			process_slab(&t, s, page, alloc, map);
+			process_slab(&t, s, page, alloc);
 		spin_unlock_irqrestore(&n->list_lock, flags);
 	}
 
@@ -3772,7 +3732,6 @@
 	}
 
 	free_loc_track(&t);
-	kfree(map);
 	if (!t.count)
 		len += sprintf(buf, "No data\n");
 	return len;
@@ -3788,7 +3747,6 @@
 
 #define SO_ALL		(1 << SL_ALL)
 #define SO_PARTIAL	(1 << SL_PARTIAL)
-#define SO_CPU		(1 << SL_CPU)
 #define SO_OBJECTS	(1 << SL_OBJECTS)
 #define SO_TOTAL	(1 << SL_TOTAL)
 
@@ -3806,30 +3764,6 @@
 		return -ENOMEM;
 	per_cpu = nodes + nr_node_ids;
 
-	if (flags & SO_CPU) {
-		int cpu;
-
-		for_each_possible_cpu(cpu) {
-			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
-
-			if (!c || c->node < 0)
-				continue;
-
-			if (c->page) {
-					if (flags & SO_TOTAL)
-						x = c->page->objects;
-				else if (flags & SO_OBJECTS)
-					x = c->page->inuse;
-				else
-					x = 1;
-
-				total += x;
-				nodes[c->node] += x;
-			}
-			per_cpu[c->node]++;
-		}
-	}
-
 	if (flags & SO_ALL) {
 		for_each_node_state(node, N_NORMAL_MEMORY) {
 			struct kmem_cache_node *n = get_node(s, node);
@@ -3999,11 +3933,35 @@
 }
 SLAB_ATTR_RO(partial);
 
-static ssize_t cpu_slabs_show(struct kmem_cache *s, char *buf)
+static ssize_t cpu_queues_show(struct kmem_cache *s, char *buf)
 {
-	return show_slab_objects(s, buf, SO_CPU);
+	unsigned long total = 0;
+	int x;
+	int cpu;
+	unsigned long *cpus;
+
+	cpus = kzalloc(1 * sizeof(unsigned long) * nr_cpu_ids, GFP_KERNEL);
+	if (!cpus)
+		return -ENOMEM;
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+
+		total += c->q.objects;
+	}
+
+	x = sprintf(buf, "%lu", total);
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+
+		if (c->q.objects)
+			x += sprintf(buf + x, " C%d=%u", cpu, c->q.objects);
+	}
+	kfree(cpus);
+	return x + sprintf(buf + x, "\n");
 }
-SLAB_ATTR_RO(cpu_slabs);
+SLAB_ATTR_RO(cpu_queues);
 
 static ssize_t objects_show(struct kmem_cache *s, char *buf)
 {
@@ -4297,19 +4255,12 @@
 STAT_ATTR(ALLOC_SLOWPATH, alloc_slowpath);
 STAT_ATTR(FREE_FASTPATH, free_fastpath);
 STAT_ATTR(FREE_SLOWPATH, free_slowpath);
-STAT_ATTR(FREE_FROZEN, free_frozen);
 STAT_ATTR(FREE_ADD_PARTIAL, free_add_partial);
 STAT_ATTR(FREE_REMOVE_PARTIAL, free_remove_partial);
 STAT_ATTR(ALLOC_FROM_PARTIAL, alloc_from_partial);
 STAT_ATTR(ALLOC_SLAB, alloc_slab);
-STAT_ATTR(ALLOC_REFILL, alloc_refill);
 STAT_ATTR(FREE_SLAB, free_slab);
-STAT_ATTR(CPUSLAB_FLUSH, cpuslab_flush);
-STAT_ATTR(DEACTIVATE_FULL, deactivate_full);
-STAT_ATTR(DEACTIVATE_EMPTY, deactivate_empty);
-STAT_ATTR(DEACTIVATE_TO_HEAD, deactivate_to_head);
-STAT_ATTR(DEACTIVATE_TO_TAIL, deactivate_to_tail);
-STAT_ATTR(DEACTIVATE_REMOTE_FREES, deactivate_remote_frees);
+STAT_ATTR(QUEUE_FLUSH, queue_flush);
 STAT_ATTR(ORDER_FALLBACK, order_fallback);
 #endif
 
@@ -4324,7 +4275,7 @@
 	&total_objects_attr.attr,
 	&slabs_attr.attr,
 	&partial_attr.attr,
-	&cpu_slabs_attr.attr,
+	&cpu_queues_attr.attr,
 	&ctor_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
@@ -4351,19 +4302,12 @@
 	&alloc_slowpath_attr.attr,
 	&free_fastpath_attr.attr,
 	&free_slowpath_attr.attr,
-	&free_frozen_attr.attr,
 	&free_add_partial_attr.attr,
 	&free_remove_partial_attr.attr,
 	&alloc_from_partial_attr.attr,
 	&alloc_slab_attr.attr,
-	&alloc_refill_attr.attr,
 	&free_slab_attr.attr,
-	&cpuslab_flush_attr.attr,
-	&deactivate_full_attr.attr,
-	&deactivate_empty_attr.attr,
-	&deactivate_to_head_attr.attr,
-	&deactivate_to_tail_attr.attr,
-	&deactivate_remote_frees_attr.attr,
+	&queue_flush_attr.attr,
 	&order_fallback_attr.attr,
 #endif
 #ifdef CONFIG_FAILSLAB
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2010-07-31 17:44:35.159064006 -0500
+++ linux-2.6/include/linux/page-flags.h	2010-07-31 17:44:36.775096062 -0500
@@ -125,9 +125,6 @@
 
 	/* SLOB */
 	PG_slob_free = PG_private,
-
-	/* SLUB */
-	PG_slub_frozen = PG_active,
 };
 
 #ifndef __GENERATING_BOUNDS_H
@@ -213,8 +210,6 @@
 
 __PAGEFLAG(SlobFree, slob_free)
 
-__PAGEFLAG(SlubFrozen, slub_frozen)
-
 /*
  * Private page markings that may be used by the filesystem that owns the page
  * for its own purposes.
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-07-31 17:44:35.131063451 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-07-31 18:25:28.827872663 -0500
@@ -2,9 +2,10 @@
 #define _LINUX_SLUB_DEF_H
 
 /*
- * SLUB : A Slab allocator without object queues.
+ * SLUB : The Unified Slab allocator.
  *
- * (C) 2007 SGI, Christoph Lameter
+ * (C) 2007-2008 SGI, Christoph Lameter
+ * (C) 2008-2010 Linux Foundation, Christoph Lameter
  */
 #include <linux/types.h>
 #include <linux/gfp.h>
@@ -14,33 +15,36 @@
 #include <linux/kmemleak.h>
 
 enum stat_item {
-	ALLOC_FASTPATH,		/* Allocation from cpu slab */
-	ALLOC_SLOWPATH,		/* Allocation by getting a new cpu slab */
-	FREE_FASTPATH,		/* Free to cpu slub */
-	FREE_SLOWPATH,		/* Freeing not to cpu slab */
-	FREE_FROZEN,		/* Freeing to frozen slab */
-	FREE_ADD_PARTIAL,	/* Freeing moves slab to partial list */
-	FREE_REMOVE_PARTIAL,	/* Freeing removes last object */
-	ALLOC_FROM_PARTIAL,	/* Cpu slab acquired from partial list */
-	ALLOC_SLAB,		/* Cpu slab acquired from page allocator */
-	ALLOC_REFILL,		/* Refill cpu slab from slab freelist */
+	ALLOC_FASTPATH,		/* Allocation from cpu queue */
+	ALLOC_SLOWPATH,		/* Allocation required refilling of queue */
+	FREE_FASTPATH,		/* Free to cpu queue */
+	FREE_SLOWPATH,		/* Required pushing objects out of the queue */
+	FREE_ADD_PARTIAL,	/* Freeing moved slab to partial list */
+	FREE_REMOVE_PARTIAL,	/* Freeing removed from partial list */
+	ALLOC_FROM_PARTIAL,	/* slab with objects acquired from partial */
+	ALLOC_SLAB,		/* New slab acquired from page allocator */
+	FREE_ALIEN,		/* Free to alien node */
 	FREE_SLAB,		/* Slab freed to the page allocator */
-	CPUSLAB_FLUSH,		/* Abandoning of the cpu slab */
-	DEACTIVATE_FULL,	/* Cpu slab was full when deactivated */
-	DEACTIVATE_EMPTY,	/* Cpu slab was empty when deactivated */
-	DEACTIVATE_TO_HEAD,	/* Cpu slab was moved to the head of partials */
-	DEACTIVATE_TO_TAIL,	/* Cpu slab was moved to the tail of partials */
-	DEACTIVATE_REMOTE_FREES,/* Slab contained remotely freed objects */
+	QUEUE_FLUSH,		/* Flushing of the per cpu queue */
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
 	NR_SLUB_STAT_ITEMS };
 
+#define QUEUE_SIZE 50
+#define BATCH_SIZE 25
+
+/* Queueing structure used for per cpu, l3 cache and alien queueing */
+struct kmem_cache_queue {
+	int objects;		/* Available objects */
+	int max;		/* Queue capacity */
+	void *object[QUEUE_SIZE];
+};
+
 struct kmem_cache_cpu {
-	void **freelist;	/* Pointer to first free per cpu object */
-	struct page *page;	/* The slab from which we are allocating */
-	int node;		/* The node of the page (or -1 for debug) */
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
+	int node;		/* objects only from this numa node */
+	struct kmem_cache_queue q;
 };
 
 struct kmem_cache_node {
@@ -72,8 +76,8 @@
 	unsigned long flags;
 	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
-	int offset;		/* Free pointer offset. */
 	struct kmem_cache_order_objects oo;
+	int batch;		/* batch size */
 
 	/* Allocation and freeing of slabs */
 	struct kmem_cache_order_objects max;
Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig	2010-07-31 17:44:35.091062658 -0500
+++ linux-2.6/init/Kconfig	2010-07-31 17:44:36.779096141 -0500
@@ -1087,14 +1087,14 @@
 	  per cpu and per node queues.
 
 config SLUB
-	bool "SLUB (Unqueued Allocator)"
+	bool "SLUB (Unified allocator)"
 	help
-	   SLUB is a slab allocator that minimizes cache line usage
-	   instead of managing queues of cached objects (SLAB approach).
-	   Per cpu caching is realized using slabs of objects instead
-	   of queues of objects. SLUB can use memory efficiently
-	   and has enhanced diagnostics. SLUB is the default choice for
-	   a slab allocator.
+	   SLUB is a slab allocator that minimizes metadata and provides
+	   a clean implementation that is faster than SLAB. SLUB has many
+	   of the queueing characteristic of the original SLAB allocator
+	   but uses a bit map to manage objects in slabs. SLUB can use
+	   memory more efficiently and has enhanced diagnostic and
+	   resiliency features compared with SLAB.
 
 config SLOB
 	depends on EMBEDDED

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

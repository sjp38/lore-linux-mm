Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9E0706B01BA
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 17:24:30 -0400 (EDT)
Message-Id: <20100625212108.124809375@quilx.com>
Date: Fri, 25 Jun 2010 16:20:38 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q 12/16] SLUB: Add SLAB style per cpu queueing
References: <20100625212026.810557229@quilx.com>
Content-Disposition: inline; filename=sled_core
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

This patch adds SLAB style cpu queueing and uses a new way for
 managing objects in the slabs using bitmaps. It uses a percpu queue so that
free operations can be properly buffered and a bitmap for managing the
free/allocated state in the slabs. It uses slightly more memory
(due to the need to place large bitmaps --sized a few words--in some
slab pages) but in general does compete well in terms of space use.
The storage format using bitmaps avoids the SLAB management structure that
SLAB needs for each slab page and therefore the metadata is more compact
and easily fits into a cacheline.

The SLAB scheme of not touching the object during management is adopted.
SLUB can now efficiently free and allocate cache cold objects.

The queueing scheme addresses also the issue that the free slowpath
was taken too frequently.

This patch only implements staticallly sized per cpu queues.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |   10 
 mm/slub.c                |  920 ++++++++++++++++++++---------------------------
 2 files changed, 416 insertions(+), 514 deletions(-)

Index: linux-2.6.34/include/linux/slub_def.h
===================================================================
--- linux-2.6.34.orig/include/linux/slub_def.h	2010-06-23 10:03:01.000000000 -0500
+++ linux-2.6.34/include/linux/slub_def.h	2010-06-23 10:22:30.000000000 -0500
@@ -34,13 +34,16 @@ enum stat_item {
 	ORDER_FALLBACK,		/* Number of times fallback was necessary */
 	NR_SLUB_STAT_ITEMS };
 
+#define QUEUE_SIZE 50
+#define BATCH_SIZE 25
+
 struct kmem_cache_cpu {
-	void **freelist;	/* Pointer to first free per cpu object */
-	struct page *page;	/* The slab from which we are allocating */
-	int node;		/* The node of the page (or -1 for debug) */
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
+	int objects;		/* Number of objects available */
+	int node;		/* The node of the page (or -1 for debug) */
+	void *object[QUEUE_SIZE];		/* List of objects */
 };
 
 struct kmem_cache_node {
@@ -72,7 +75,6 @@ struct kmem_cache {
 	unsigned long flags;
 	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
-	int offset;		/* Free pointer offset. */
 	struct kmem_cache_order_objects oo;
 
 	/* Allocation and freeing of slabs */
Index: linux-2.6.34/mm/slub.c
===================================================================
--- linux-2.6.34.orig/mm/slub.c	2010-06-23 10:04:56.000000000 -0500
+++ linux-2.6.34/mm/slub.c	2010-06-23 10:24:11.000000000 -0500
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
@@ -259,38 +238,71 @@ static inline int check_valid_pointer(st
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
 
@@ -357,10 +369,7 @@ static struct track *get_track(struct km
 {
 	struct track *p;
 
-	if (s->offset)
-		p = object + s->offset + sizeof(void *);
-	else
-		p = object + s->inuse;
+	p = object + s->inuse;
 
 	return p + alloc;
 }
@@ -408,8 +417,8 @@ static void print_tracking(struct kmem_c
 
 static void print_page_info(struct page *page)
 {
-	printk(KERN_ERR "INFO: Slab 0x%p objects=%u used=%u fp=0x%p flags=0x%04lx\n",
-		page, page->objects, page->inuse, page->freelist, page->flags);
+	printk(KERN_ERR "INFO: Slab 0x%p objects=%u new=%u fp=0x%p flags=0x%04lx\n",
+		page, page->objects, available(page), page->freelist, page->flags);
 
 }
 
@@ -448,8 +457,8 @@ static void print_trailer(struct kmem_ca
 
 	print_page_info(page);
 
-	printk(KERN_ERR "INFO: Object 0x%p @offset=%tu fp=0x%p\n\n",
-			p, p - addr, get_freepointer(s, p));
+	printk(KERN_ERR "INFO: Object 0x%p @offset=%tu\n\n",
+			p, p - addr);
 
 	if (p > addr + 16)
 		print_section("Bytes b4", p - 16, 16);
@@ -460,10 +469,7 @@ static void print_trailer(struct kmem_ca
 		print_section("Redzone", p + s->objsize,
 			s->inuse - s->objsize);
 
-	if (s->offset)
-		off = s->offset + sizeof(void *);
-	else
-		off = s->inuse;
+	off = s->inuse;
 
 	if (s->flags & SLAB_STORE_USER)
 		off += 2 * sizeof(struct track);
@@ -557,8 +563,6 @@ static int check_bytes_and_report(struct
  *
  * object address
  * 	Bytes of the object to be managed.
- * 	If the freepointer may overlay the object then the free
- * 	pointer is the first word of the object.
  *
  * 	Poisoning uses 0x6b (POISON_FREE) and the last byte is
  * 	0xa5 (POISON_END)
@@ -574,9 +578,8 @@ static int check_bytes_and_report(struct
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
@@ -594,10 +597,6 @@ static int check_pad_bytes(struct kmem_c
 {
 	unsigned long off = s->inuse;	/* The end of info */
 
-	if (s->offset)
-		/* Freepointer is placed after the object. */
-		off += sizeof(void *);
-
 	if (s->flags & SLAB_STORE_USER)
 		/* We also have user information there */
 		off += 2 * sizeof(struct track);
@@ -622,15 +621,42 @@ static int slab_pad_check(struct kmem_ca
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
 
@@ -673,25 +699,6 @@ static int check_object(struct kmem_cach
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
 
@@ -712,51 +719,45 @@ static int check_slab(struct kmem_cache 
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
 
@@ -765,24 +766,19 @@ static int on_freelist(struct kmem_cache
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
@@ -795,14 +791,19 @@ static void trace(struct kmem_cache *s, 
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
 
@@ -863,25 +864,30 @@ static void setup_object_debug(struct km
 	init_tracking(s, object);
 }
 
-static int alloc_debug_processing(struct kmem_cache *s, struct page *page,
+static int alloc_debug_processing(struct kmem_cache *s,
 					void *object, unsigned long addr)
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
@@ -897,15 +903,16 @@ bad:
 		 * as used avoids touching the remaining objects.
 		 */
 		slab_fix(s, "Marking all objects used");
-		page->inuse = page->objects;
-		page->freelist = NULL;
+		bitmap_zero(map(page), page->objects);
 	}
 	return 0;
 }
 
-static int free_debug_processing(struct kmem_cache *s, struct page *page,
+static int free_debug_processing(struct kmem_cache *s,
 					void *object, unsigned long addr)
 {
+	struct page *page = virt_to_head_page(object);
+
 	if (!check_slab(s, page))
 		goto fail;
 
@@ -914,7 +921,7 @@ static int free_debug_processing(struct 
 		goto fail;
 	}
 
-	if (on_freelist(s, page, object)) {
+	if (object_marked_free(s, page, object)) {
 		object_err(s, page, object, "Object already free");
 		goto fail;
 	}
@@ -937,13 +944,11 @@ static int free_debug_processing(struct 
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
@@ -1048,7 +1053,8 @@ static inline int slab_pad_check(struct 
 			{ return 1; }
 static inline int check_object(struct kmem_cache *s, struct page *page,
 			void *object, int active) { return 1; }
-static inline void add_full(struct kmem_cache_node *n, struct page *page) {}
+static inline void add_full(struct kmem_cache *s,
+		struct kmem_cache_node *n, struct page *page) {}
 static inline unsigned long kmem_cache_flags(unsigned long objsize,
 	unsigned long flags, const char *name,
 	void (*ctor)(void *))
@@ -1150,8 +1156,8 @@ static struct page *new_slab(struct kmem
 {
 	struct page *page;
 	void *start;
-	void *last;
 	void *p;
+	unsigned long size;
 
 	BUG_ON(flags & GFP_SLAB_BUG_MASK);
 
@@ -1163,23 +1169,20 @@ static struct page *new_slab(struct kmem
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
@@ -1303,7 +1306,6 @@ static inline int lock_and_freeze_slab(s
 	if (slab_trylock(page)) {
 		list_del(&page->lru);
 		n->nr_partial--;
-		__SetPageSlubFrozen(page);
 		return 1;
 	}
 	return 0;
@@ -1406,113 +1408,132 @@ static struct page *get_partial(struct k
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
-			stat(s, FREE_SLAB);
-			discard_slab_unlock(s, page);
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
 		}
-	}
-}
+		if (bitmap_full(m, page->objects)) {
 
-/*
- * Remove the cpu slab
- */
-static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
-{
-	struct page *page = c->page;
-	int tail = 1;
+			/* All objects are available now */
+			if (!was_fully_allocated)
 
-	if (page->freelist)
-		stat(s, DEACTIVATE_REMOTE_FREES);
-	/*
-	 * Merge cpu freelist into slab freelist. Typically we get here
-	 * because both freelists are empty. So this is unlikely
-	 * to occur.
-	 */
-	while (unlikely(c->freelist)) {
-		void **object;
+				remove_partial(s, page);
+			else
+				remove_full(s, page);
+
+			discard_slab_unlock(s, page);
 
-		tail = 0;	/* Hot objects. Put the slab first */
+  		} else {
 
-		/* Retrieve object from cpu_freelist */
-		object = c->freelist;
-		c->freelist = get_freepointer(s, c->freelist);
+			/* Some object are available now */
+			if (was_fully_allocated) {
 
-		/* And put onto the regular freelist */
-		set_freepointer(s, object, page->freelist);
-		page->freelist = object;
-		page->inuse--;
+				/* Slab was had no free objects but has them now */
+				remove_full(s, page);
+				add_partial(get_node(s, page_to_nid(page)), page, 1);
+				stat(s, FREE_REMOVE_PARTIAL);
+			}
+			slab_unlock(page);
+		}
 	}
-	c->page = NULL;
-	unfreeze_slab(s, page, tail);
 }
 
-static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
+/*
+ * Drain all objects from a per cpu queue
+ */
+static void flush_cpu_objects(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
-	stat(s, CPUSLAB_FLUSH);
-	slab_lock(c->page);
-	deactivate_slab(s, c);
+	drain_objects(s, c->object, c->objects);
+	c->objects = 0;
+ 	stat(s, CPUSLAB_FLUSH);
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
+	if (c->objects)
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
@@ -1530,7 +1551,7 @@ static inline int node_match(struct kmem
 
 static int count_free(struct page *page)
 {
-	return page->objects - page->inuse;
+	return available(page);
 }
 
 static unsigned long count_partial(struct kmem_cache_node *n,
@@ -1592,144 +1613,127 @@ slab_out_of_memory(struct kmem_cache *s,
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
+ * Retrieve pointers to nr objects from a slab into the object array.
+ * Slab must be locked.
  */
-static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
-			  unsigned long addr, struct kmem_cache_cpu *c)
+void retrieve_objects(struct kmem_cache *s, struct page *page, void **object, int nr)
 {
-	void **object;
-	struct page *new;
-
-	/* We handle __GFP_ZERO in the caller */
-	gfpflags &= ~__GFP_ZERO;
+	void *addr = page_address(page);
+	unsigned long *m = map(page);
 
-	if (!c->page)
-		goto new_slab;
+	while (nr > 0) {
+		int i = find_first_bit(m, page->objects);
+		void *a;
 
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
-
-	c->page->inuse++;
-	c->page->freelist = get_freepointer(s, object);
-	c->node = -1;
-	goto unlock_out;
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
+static void *slab_alloc(struct kmem_cache *s,
 		gfp_t gfpflags, int node, unsigned long addr)
 {
 	void **object;
 	struct kmem_cache_cpu *c;
 	unsigned long flags;
 
-	gfpflags &= gfp_allowed_mask;
-
 	lockdep_trace_alloc(gfpflags);
 	might_sleep_if(gfpflags & __GFP_WAIT);
 
 	if (should_failslab(s->objsize, gfpflags, s->flags))
 		return NULL;
 
+redo:
 	local_irq_save(flags);
 	c = __this_cpu_ptr(s->cpu_slab);
-	object = c->freelist;
-	if (unlikely(!object || !node_match(c, node)))
+	if (unlikely(!c->objects || !node_match(c, node))) {
 
-		object = __slab_alloc(s, gfpflags, node, addr, c);
+		gfpflags &= gfp_allowed_mask;
 
-	else {
-		c->freelist = get_freepointer(s, object);
+		if (unlikely(!node_match(c, node))) {
+			flush_cpu_objects(s, c);
+			c->node = node;
+		}
+
+		while (c->objects < BATCH_SIZE) {
+			struct page *new;
+			int d;
+
+			new = get_partial(s, gfpflags & ~__GFP_ZERO, node);
+			if (unlikely(!new)) {
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
+
+ 				if (!new) {
+					if (!c->objects)
+						goto oom;
+					break;
+				}
+				stat(s, ALLOC_SLAB);
+				slab_lock(new);
+			} else
+				stat(s, ALLOC_FROM_PARTIAL);
+
+			d = min(BATCH_SIZE - c->objects, available(new));
+			retrieve_objects(s, new, c->object + c->objects, d);
+			c->objects += d;
+
+			if (!all_objects_used(new))
+
+				add_partial(get_node(s, page_to_nid(new)), new, 1);
+
+			else
+				add_full(s, get_node(s, page_to_nid(new)), new);
+
+			slab_unlock(new);
+		}
+		stat(s, ALLOC_SLOWPATH);
+
+	} else
 		stat(s, ALLOC_FASTPATH);
+
+	object = c->object[--c->objects];
+
+	if (kmem_cache_debug(s)) {
+		if (!alloc_debug_processing(s, object, addr))
+			goto redo;
 	}
 	local_irq_restore(flags);
 
-	if (unlikely(gfpflags & __GFP_ZERO) && object)
+	if (unlikely(gfpflags & __GFP_ZERO))
 		memset(object, 0, s->objsize);
 
 	kmemcheck_slab_alloc(s, gfpflags, object, s->objsize);
 	kmemleak_alloc_recursive(object, s->objsize, 1, s->flags, gfpflags);
 
 	return object;
+
+oom:
+	local_irq_restore(flags);
+	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
+		slab_out_of_memory(s, gfpflags, node);
+	return NULL;
 }
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
@@ -1773,113 +1777,52 @@ void *kmem_cache_alloc_node_notrace(stru
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
+static void slab_free(struct kmem_cache *s,
 			void *x, unsigned long addr)
 {
-	void *prior;
-	void **object = (void *)x;
-
-	stat(s, FREE_SLOWPATH);
-	slab_lock(page);
-
-	if (kmem_cache_debug(s))
-		goto debug;
-
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
-
-	if (unlikely(!page->inuse))
-		goto slab_empty;
-
-	/*
-	 * Objects left in the slab. If it was not on the partial list before
-	 * then add it.
-	 */
-	if (unlikely(!prior)) {
-		add_partial(get_node(s, page_to_nid(page)), page, 1);
-		stat(s, FREE_ADD_PARTIAL);
-	}
-
-out_unlock:
-	slab_unlock(page);
-	return;
-
-slab_empty:
-	if (prior) {
-		/*
-		 * Slab still on the partial list.
-		 */
-		remove_partial(s, page);
-		stat(s, FREE_REMOVE_PARTIAL);
-	}
-	stat(s, FREE_SLAB);
-	discard_slab_unlock(s, page);
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
 	void **object = (void *)x;
 	struct kmem_cache_cpu *c;
 	unsigned long flags;
 
 	kmemleak_free_recursive(x, s->flags);
+
 	local_irq_save(flags);
 	c = __this_cpu_ptr(s->cpu_slab);
+
 	kmemcheck_slab_free(s, object, s->objsize);
 	debug_check_no_locks_freed(object, s->objsize);
+
 	if (!(s->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(object, s->objsize);
-	if (likely(page == c->page && c->node >= 0)) {
-		set_freepointer(s, object, c->freelist);
-		c->freelist = object;
-		stat(s, FREE_FASTPATH);
+
+	if (unlikely(c->objects >= QUEUE_SIZE)) {
+
+		int t = min(BATCH_SIZE, c->objects);
+
+		drain_objects(s, c->object, t);
+
+		c->objects -= t;
+		if (c->objects)
+			memcpy(c->object, c->object + t,
+					c->objects * sizeof(void *));
+
+		stat(s, FREE_SLOWPATH);
 	} else
-		__slab_free(s, page, x, addr);
+		stat(s, FREE_FASTPATH);
 
+	if (kmem_cache_debug(s)
+			&& !free_debug_processing(s, x, addr))
+		goto out;
+
+	c->object[c->objects++] = object;
+
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
+	slab_free(s, x, _RET_IP_);
 
 	trace_kmem_cache_free(_RET_IP_, x);
 }
@@ -1897,11 +1840,6 @@ static struct page *get_object_page(cons
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
@@ -1996,7 +1934,7 @@ static inline int calculate_order(int si
 	 */
 	min_objects = slub_min_objects;
 	if (!min_objects)
-		min_objects = 4 * (fls(nr_cpu_ids) + 1);
+		min_objects = min(BITS_PER_LONG, 4 * (fls(nr_cpu_ids) + 1));
 	max_objects = (PAGE_SIZE << slub_max_order)/size;
 	min_objects = min(min_objects, max_objects);
 
@@ -2108,10 +2046,7 @@ static void early_kmem_cache_node_alloc(
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
@@ -2196,10 +2131,11 @@ static void set_min_partial(struct kmem_
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
@@ -2231,24 +2167,10 @@ static int calculate_sizes(struct kmem_c
 
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
@@ -2334,7 +2256,6 @@ static int kmem_cache_open(struct kmem_c
 		 */
 		if (get_order(s->size) > get_order(s->objsize)) {
 			s->flags &= ~DEBUG_METADATA_FLAGS;
-			s->offset = 0;
 			if (!calculate_sizes(s, -1))
 				goto error;
 		}
@@ -2359,9 +2280,9 @@ static int kmem_cache_open(struct kmem_c
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
 
@@ -2415,19 +2336,14 @@ static void list_slab_objects(struct kme
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
@@ -2448,7 +2364,7 @@ static void free_partial(struct kmem_cac
 
 	spin_lock_irqsave(&n->list_lock, flags);
 	list_for_each_entry_safe(page, h, &n->partial, lru) {
-		if (!page->inuse) {
+		if (all_objects_available(page)) {
 			list_del(&page->lru);
 			discard_slab(s, page);
 			n->nr_partial--;
@@ -2759,7 +2675,7 @@ void kfree(const void *x)
 		put_page(page);
 		return;
 	}
-	slab_free(page->slab, page, object, _RET_IP_);
+	slab_free(page->slab, object, _RET_IP_);
 }
 EXPORT_SYMBOL(kfree);
 
@@ -2807,7 +2723,7 @@ int kmem_cache_shrink(struct kmem_cache 
 		 * list_lock. page->inuse here is the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			if (!page->inuse && slab_trylock(page)) {
+			if (all_objects_available(page) && slab_trylock(page)) {
 				/*
 				 * Must hold slab lock here because slab_free
 				 * may have freed the last object and be
@@ -2818,7 +2734,7 @@ int kmem_cache_shrink(struct kmem_cache 
 				discard_slab_unlock(s, page);
 			} else {
 				list_move(&page->lru,
-				slabs_by_inuse + page->inuse);
+				slabs_by_inuse + inuse(page));
 			}
 		}
 
@@ -3299,7 +3215,7 @@ static int __cpuinit slab_cpuup_callback
 		down_read(&slub_lock);
 		list_for_each_entry(s, &slab_caches, list) {
 			local_irq_save(flags);
-			__flush_cpu_slab(s, cpu);
+			flush_cpu_objects(s, per_cpu_ptr(s->cpu_slab ,cpu));
 			local_irq_restore(flags);
 		}
 		up_read(&slub_lock);
@@ -3369,7 +3285,7 @@ void *__kmalloc_node_track_caller(size_t
 #ifdef CONFIG_SLUB_DEBUG
 static int count_inuse(struct page *page)
 {
-	return page->inuse;
+	return inuse(page);
 }
 
 static int count_total(struct page *page)
@@ -3377,54 +3293,52 @@ static int count_total(struct page *page
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
@@ -3435,7 +3349,7 @@ static int validate_slab_node(struct kme
 		goto out;
 
 	list_for_each_entry(page, &n->full, lru) {
-		validate_slab_slab(s, page, map);
+		validate_slab_slab(s, page);
 		count++;
 	}
 	if (count != atomic_long_read(&n->nr_slabs))
@@ -3445,26 +3359,20 @@ static int validate_slab_node(struct kme
 
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
 
@@ -3653,18 +3561,14 @@ static int add_location(struct loc_track
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
 
@@ -3675,12 +3579,9 @@ static int list_locations(struct kmem_ca
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
@@ -3696,9 +3597,9 @@ static int list_locations(struct kmem_ca
 
 		spin_lock_irqsave(&n->list_lock, flags);
 		list_for_each_entry(page, &n->partial, lru)
-			process_slab(&t, s, page, alloc, map);
+			process_slab(&t, s, page, alloc);
 		list_for_each_entry(page, &n->full, lru)
-			process_slab(&t, s, page, alloc, map);
+			process_slab(&t, s, page, alloc);
 		spin_unlock_irqrestore(&n->list_lock, flags);
 	}
 
@@ -3749,7 +3650,6 @@ static int list_locations(struct kmem_ca
 	}
 
 	free_loc_track(&t);
-	kfree(map);
 	if (!t.count)
 		len += sprintf(buf, "No data\n");
 	return len;
@@ -3792,11 +3692,11 @@ static ssize_t show_slab_objects(struct 
 			if (!c || c->node < 0)
 				continue;
 
-			if (c->page) {
-					if (flags & SO_TOTAL)
-						x = c->page->objects;
+			if (c->objects) {
+				if (flags & SO_TOTAL)
+					x = 0;
 				else if (flags & SO_OBJECTS)
-					x = c->page->inuse;
+					x = c->objects;
 				else
 					x = 1;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

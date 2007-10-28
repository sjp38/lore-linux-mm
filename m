From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 06/10] SLUB: Provide unique end marker for each slab
Date: Sat, 27 Oct 2007 20:32:02 -0700
Message-ID: <20071028033259.748206144@sgi.com>
References: <20071028033156.022983073@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757377AbXJ1DfB@vger.kernel.org>
Content-Disposition: inline; filename=slub_end_marker
Sender: linux-kernel-owner@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-Id: linux-mm.kvack.org

Currently we use the NULL pointer to signal that there are no more objects.
However the NULL pointers of all slabs match in contrast to the
pointers to the real objects which are distinctive for each slab page.

Change the end pointer to be simply a pointer to the first object with
bit 0 set. That way all end pointers are different for each slab. This
is necessary to allow reliable end marker identification for the
next patch that implements a fast path without the need to disable interrupts.

Bring back the use of the mapping field by SLUB since we would otherwise
have to call a relatively expensive function page_address() in __slab_alloc().
Use of the mapping field allows avoiding calling page_address() in various
other functions as well.

There is no need to change the page_mapping() function since bit 0 is
set on the mapping as also for anonymous pages. page_mapping(slab_page)
will therefore still return NULL although the mapping field is overloaded.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm_types.h |    5 ++-
 mm/slub.c                |   72 ++++++++++++++++++++++++++++++-----------------
 2 files changed, 51 insertions(+), 26 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-10-26 19:09:03.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-10-27 07:52:12.000000000 -0700
@@ -277,15 +277,32 @@ static inline struct kmem_cache_cpu *get
 #endif
 }
 
+/*
+ * The end pointer in a slab is special. It points to the first object in the
+ * slab but has bit 0 set to mark it.
+ *
+ * Note that SLUB relies on page_mapping returning NULL for pages with bit 0
+ * in the mapping set.
+ */
+static inline int is_end(void *addr)
+{
+	return (unsigned long)addr & PAGE_MAPPING_ANON;
+}
+
+void *slab_address(struct page *page)
+{
+	return page->end - PAGE_MAPPING_ANON;
+}
+
 static inline int check_valid_pointer(struct kmem_cache *s,
 				struct page *page, const void *object)
 {
 	void *base;
 
-	if (!object)
+	if (object == page->end)
 		return 1;
 
-	base = page_address(page);
+	base = slab_address(page);
 	if (object < base || object >= base + s->objects * s->size ||
 		(object - base) % s->size) {
 		return 0;
@@ -318,7 +335,8 @@ static inline void set_freepointer(struc
 
 /* Scan freelist */
 #define for_each_free_object(__p, __s, __free) \
-	for (__p = (__free); __p; __p = get_freepointer((__s), __p))
+	for (__p = (__free); (__p) != page->end; __p = get_freepointer((__s),\
+		__p))
 
 /* Determine object index from a given position */
 static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
@@ -470,7 +488,7 @@ static void slab_fix(struct kmem_cache *
 static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 {
 	unsigned int off;	/* Offset of last byte */
-	u8 *addr = page_address(page);
+	u8 *addr = slab_address(page);
 
 	print_tracking(s, p);
 
@@ -648,7 +666,7 @@ static int slab_pad_check(struct kmem_ca
 	if (!(s->flags & SLAB_POISON))
 		return 1;
 
-	start = page_address(page);
+	start = slab_address(page);
 	end = start + (PAGE_SIZE << s->order);
 	length = s->objects * s->size;
 	remainder = end - (start + length);
@@ -715,7 +733,7 @@ static int check_object(struct kmem_cach
 		 * of the free objects in this slab. May cause
 		 * another error because the object count is now wrong.
 		 */
-		set_freepointer(s, p, NULL);
+		set_freepointer(s, p, page->end);
 		return 0;
 	}
 	return 1;
@@ -749,18 +767,18 @@ static int on_freelist(struct kmem_cache
 	void *fp = page->freelist;
 	void *object = NULL;
 
-	while (fp && nr <= s->objects) {
+	while (fp != page->end && nr <= s->objects) {
 		if (fp == search)
 			return 1;
 		if (!check_valid_pointer(s, page, fp)) {
 			if (object) {
 				object_err(s, page, object,
 					"Freechain corrupt");
-				set_freepointer(s, object, NULL);
+				set_freepointer(s, object, page->end);
 				break;
 			} else {
 				slab_err(s, page, "Freepointer corrupt");
-				page->freelist = NULL;
+				page->freelist = page->end;
 				page->inuse = s->objects;
 				slab_fix(s, "Freelist cleared");
 				return 0;
@@ -870,7 +888,7 @@ bad:
 		 */
 		slab_fix(s, "Marking all objects used");
 		page->inuse = s->objects;
-		page->freelist = NULL;
+		page->freelist = page->end;
 	}
 	return 0;
 }
@@ -912,7 +930,7 @@ static noinline int free_debug_processin
 	}
 
 	/* Special debug activities for freeing objects */
-	if (!SlabFrozen(page) && !page->freelist)
+	if (!SlabFrozen(page) && page->freelist == page->end)
 		remove_full(s, page);
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_FREE, addr);
@@ -1085,7 +1103,6 @@ static noinline struct page *new_slab(st
 	struct page *page;
 	struct kmem_cache_node *n;
 	void *start;
-	void *end;
 	void *last;
 	void *p;
 
@@ -1106,7 +1123,7 @@ static noinline struct page *new_slab(st
 		SetSlabDebug(page);
 
 	start = page_address(page);
-	end = start + s->objects * s->size;
+	page->end = start + 1;
 
 	if (unlikely(s->flags & SLAB_POISON))
 		memset(start, POISON_INUSE, PAGE_SIZE << s->order);
@@ -1118,7 +1135,7 @@ static noinline struct page *new_slab(st
 		last = p;
 	}
 	setup_object(s, page, last);
-	set_freepointer(s, last, NULL);
+	set_freepointer(s, last, page->end);
 
 	page->freelist = start;
 	page->inuse = 0;
@@ -1134,7 +1151,7 @@ static void __free_slab(struct kmem_cach
 		void *p;
 
 		slab_pad_check(s, page);
-		for_each_object(p, s, page_address(page))
+		for_each_object(p, s, slab_address(page))
 			check_object(s, page, p, 0);
 		ClearSlabDebug(page);
 	}
@@ -1144,6 +1161,7 @@ static void __free_slab(struct kmem_cach
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		- pages);
 
+	page->mapping = NULL;
 	__free_pages(page, s->order);
 }
 
@@ -1345,7 +1363,7 @@ static void unfreeze_slab(struct kmem_ca
 	ClearSlabFrozen(page);
 	if (page->inuse) {
 
-		if (page->freelist)
+		if (page->freelist != page->end)
 			add_partial(s, page, tail);
 		else
 			add_full(s, page);
@@ -1382,8 +1400,12 @@ static void deactivate_slab(struct kmem_
 	 * Merge cpu freelist into freelist. Typically we get here
 	 * because both freelists are empty. So this is unlikely
 	 * to occur.
+	 *
+	 * We need to use _is_end here because deactivate slab may
+	 * be called for a debug slab. Then c->freelist may contain
+	 * a dummy pointer.
 	 */
-	while (unlikely(c->freelist)) {
+	while (unlikely(!is_end(c->freelist))) {
 		void **object;
 
 		tail = 0;	/* Hot objects. Put the slab first */
@@ -1483,7 +1505,7 @@ static void *__slab_alloc(struct kmem_ca
 		goto another_slab;
 load_freelist:
 	object = c->page->freelist;
-	if (unlikely(!object))
+	if (unlikely(object == c->page->end))
 		goto another_slab;
 	if (unlikely(SlabDebug(c->page)))
 		goto debug;
@@ -1491,7 +1513,7 @@ load_freelist:
 	object = c->page->freelist;
 	c->freelist = object[c->offset];
 	c->page->inuse = s->objects;
-	c->page->freelist = NULL;
+	c->page->freelist = c->page->end;
 	c->node = page_to_nid(c->page);
 unlock_out:
 	slab_unlock(c->page);
@@ -1575,7 +1597,7 @@ static void __always_inline *slab_alloc(
 
 	local_irq_save(flags);
 	c = get_cpu_slab(s, smp_processor_id());
-	if (unlikely(!c->freelist || !node_match(c, node))) {
+	if (unlikely((is_end(c->freelist)) || !node_match(c, node))) {
 
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 		if (unlikely(!object)) {
@@ -1642,7 +1664,7 @@ checks_ok:
 	 * was not on the partial list before
 	 * then add it.
 	 */
-	if (unlikely(!prior))
+	if (unlikely(prior == page->end))
 		add_partial(s, page, 0);
 
 out_unlock:
@@ -1650,7 +1672,7 @@ out_unlock:
 	return;
 
 slab_empty:
-	if (prior)
+	if (prior != page->end)
 		/*
 		 * Slab still on the partial list.
 		 */
@@ -1870,7 +1892,7 @@ static void init_kmem_cache_cpu(struct k
 			struct kmem_cache_cpu *c)
 {
 	c->page = NULL;
-	c->freelist = NULL;
+	c->freelist = (void *)PAGE_MAPPING_ANON;
 	c->node = 0;
 	c->offset = s->offset / sizeof(void *);
 	c->objsize = s->objsize;
@@ -3107,7 +3129,7 @@ static int validate_slab(struct kmem_cac
 						unsigned long *map)
 {
 	void *p;
-	void *addr = page_address(page);
+	void *addr = slab_address(page);
 
 	if (!check_slab(s, page) ||
 			!on_freelist(s, page, NULL))
@@ -3387,7 +3409,7 @@ static int add_location(struct loc_track
 static void process_slab(struct loc_track *t, struct kmem_cache *s,
 		struct page *page, enum track_item alloc)
 {
-	void *addr = page_address(page);
+	void *addr = slab_address(page);
 	DECLARE_BITMAP(map, s->objects);
 	void *p;
 
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2007-10-26 19:06:30.000000000 -0700
+++ linux-2.6/include/linux/mm_types.h	2007-10-26 19:09:04.000000000 -0700
@@ -64,7 +64,10 @@ struct page {
 #if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
 	    spinlock_t ptl;
 #endif
-	    struct kmem_cache *slab;	/* SLUB: Pointer to slab */
+		struct {
+		   struct kmem_cache *slab;	/* SLUB: Pointer to slab */
+		   void *end;			/* SLUB: end marker */
+	    };
 	    struct page *first_page;	/* Compound tail pages */
 	};
 	union {

-- 

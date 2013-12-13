Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id E61046B0037
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 18:59:15 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so3232801pbc.13
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 15:59:15 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id uj8si2652232pac.61.2013.12.13.15.59.13
        for <linux-mm@kvack.org>;
        Fri, 13 Dec 2013 15:59:14 -0800 (PST)
Subject: [RFC][PATCH 4/7] mm: rearrange struct page
From: Dave Hansen <dave@sr71.net>
Date: Fri, 13 Dec 2013 15:59:08 -0800
References: <20131213235903.8236C539@viggo.jf.intel.com>
In-Reply-To: <20131213235903.8236C539@viggo.jf.intel.com>
Message-Id: <20131213235908.6FC0C339@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, Christoph Lameter <cl@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@sr71.net>


To make the layout of 'struct page' look nicer, I broke
up a few of the unions.  But, this has a cost: things that
were guaranteed to line up before might not any more.  To make up
for that, some BUILD_BUG_ON()s are added to manually check for
the alignment dependencies.

This makes it *MUCH* more clear how the first few fields of
'struct page' get used by the slab allocators.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/include/linux/mm_types.h |  101 ++++++++++++++--------------
 linux.git-davehans/mm/slab.c                |    6 -
 linux.git-davehans/mm/slab_common.c         |   17 ++++
 linux.git-davehans/mm/slob.c                |   24 +++---
 linux.git-davehans/mm/slub.c                |   76 ++++++++++-----------
 5 files changed, 121 insertions(+), 103 deletions(-)

diff -puN include/linux/mm_types.h~rearrange-struct-page include/linux/mm_types.h
--- linux.git/include/linux/mm_types.h~rearrange-struct-page	2013-12-13 15:51:48.055244798 -0800
+++ linux.git-davehans/include/linux/mm_types.h	2013-12-13 15:51:48.061245062 -0800
@@ -45,27 +45,60 @@ struct page {
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	union {
-		struct address_space *mapping;	/* If low bit clear, points to
-						 * inode address_space, or NULL.
-						 * If page mapped as anonymous
-						 * memory, low bit is set, and
-						 * it points to anon_vma object:
-						 * see PAGE_MAPPING_ANON below.
-						 */
-		void *s_mem;			/* slab first object */
-	};
-
-	/* Second double word */
-	struct {
-		union {
+		struct /* the normal uses */ {
 			pgoff_t index;		/* Our offset within mapping. */
-			void *freelist;		/* sl[aou]b first free object */
+			/*
+			 * mapping: If low bit clear, points to
+			 * inode address_space, or NULL.  If page
+			 * mapped as anonymous memory, low bit is
+			 * set, and it points to anon_vma object:
+			 * see PAGE_MAPPING_ANON below.
+			 */
+			struct address_space *mapping;
+			/*
+			 * Count of ptes mapped in mms, to show when page
+			 * is mapped & limit reverse map searches.
+			 *
+			 * Used also for tail pages refcounting instead
+			 * of _count. Tail pages cannot be mapped and
+			 * keeping the tail page _count zero at all times
+			 * guarantees get_page_unless_zero() will never
+			 * succeed on tail pages.
+			 */
+			atomic_t _mapcount;
+			atomic_t _count;
+		}; /* end of the "normal" use */
+
+		struct { /* SLUB */
+			void *unused;
+			void *slub_freelist;
+			unsigned inuse:16;
+			unsigned objects:15;
+			unsigned frozen:1;
+			atomic_t dontuse_slub_count;
 		};
-
-		union {
+		struct { /* SLAB */
+			void *s_mem;
+			void *slab_freelist;
+			unsigned int active;
+			atomic_t dontuse_slab_count;
+		};
+		struct { /* SLOB */
+			void *slob_unused;
+			void *slob_freelist;
+			unsigned int units;
+			atomic_t dontuse_slob_count;
+		};
+		/*
+		 * This is here to help the slub code deal with
+		 * its inuse/objects/frozen bitfields as a single
+		 * blob.
+		 */
+		struct { /* slub helpers */
+			void *slubhelp_unused;
+			void *slubhelp_freelist;
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-	defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-			/* Used for cmpxchg_double in slub */
+    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 			unsigned long counters;
 #else
 			/*
@@ -75,38 +108,6 @@ struct page {
 			 */
 			unsigned counters;
 #endif
-
-			struct {
-
-				union {
-					/*
-					 * Count of ptes mapped in
-					 * mms, to show when page is
-					 * mapped & limit reverse map
-					 * searches.
-					 *
-					 * Used also for tail pages
-					 * refcounting instead of
-					 * _count. Tail pages cannot
-					 * be mapped and keeping the
-					 * tail page _count zero at
-					 * all times guarantees
-					 * get_page_unless_zero() will
-					 * never succeed on tail
-					 * pages.
-					 */
-					atomic_t _mapcount;
-
-					struct { /* SLUB */
-						unsigned inuse:16;
-						unsigned objects:15;
-						unsigned frozen:1;
-					};
-					int units;	/* SLOB */
-				};
-				atomic_t _count;		/* Usage count, see below. */
-			};
-			unsigned int active;	/* SLAB */
 		};
 	};
 
diff -puN mm/slab.c~rearrange-struct-page mm/slab.c
--- linux.git/mm/slab.c~rearrange-struct-page	2013-12-13 15:51:48.056244842 -0800
+++ linux.git-davehans/mm/slab.c	2013-12-13 15:51:48.062245106 -0800
@@ -1955,7 +1955,7 @@ static void slab_destroy(struct kmem_cac
 {
 	void *freelist;
 
-	freelist = page->freelist;
+	freelist = page->slab_freelist;
 	slab_destroy_debugcheck(cachep, page);
 	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {
 		struct rcu_head *head;
@@ -2543,7 +2543,7 @@ static void *alloc_slabmgmt(struct kmem_
 
 static inline unsigned int *slab_freelist(struct page *page)
 {
-	return (unsigned int *)(page->freelist);
+	return (unsigned int *)(page->slab_freelist);
 }
 
 static void cache_init_objs(struct kmem_cache *cachep,
@@ -2648,7 +2648,7 @@ static void slab_map_pages(struct kmem_c
 			   void *freelist)
 {
 	page->slab_cache = cache;
-	page->freelist = freelist;
+	page->slab_freelist = freelist;
 }
 
 /*
diff -puN mm/slab_common.c~rearrange-struct-page mm/slab_common.c
--- linux.git/mm/slab_common.c~rearrange-struct-page	2013-12-13 15:51:48.057244886 -0800
+++ linux.git-davehans/mm/slab_common.c	2013-12-13 15:51:48.062245106 -0800
@@ -658,3 +658,20 @@ static int __init slab_proc_init(void)
 }
 module_init(slab_proc_init);
 #endif /* CONFIG_SLABINFO */
+#define SLAB_PAGE_CHECK(field1, field2)        \
+	BUILD_BUG_ON(offsetof(struct page, field1) !=   \
+		     offsetof(struct page, field2))
+/*
+ * To make the layout of 'struct page' look nicer, we've broken
+ * up a few of the unions.  Folks declaring their own use of the
+ * first few fields need to make sure that their use does not
+ * interfere with page->_count.  This ensures that the individual
+ * users' use actually lines up with the real ->_count.
+ */
+void slab_build_checks(void)
+{
+	SLAB_PAGE_CHECK(_count, dontuse_slab_count);
+	SLAB_PAGE_CHECK(_count, dontuse_slub_count);
+	SLAB_PAGE_CHECK(_count, dontuse_slob_count);
+}
+
diff -puN mm/slob.c~rearrange-struct-page mm/slob.c
--- linux.git/mm/slob.c~rearrange-struct-page	2013-12-13 15:51:48.058244930 -0800
+++ linux.git-davehans/mm/slob.c	2013-12-13 15:51:48.062245106 -0800
@@ -219,7 +219,7 @@ static void *slob_page_alloc(struct page
 	slob_t *prev, *cur, *aligned = NULL;
 	int delta = 0, units = SLOB_UNITS(size);
 
-	for (prev = NULL, cur = sp->freelist; ; prev = cur, cur = slob_next(cur)) {
+	for (prev = NULL, cur = sp->slob_freelist; ; prev = cur, cur = slob_next(cur)) {
 		slobidx_t avail = slob_units(cur);
 
 		if (align) {
@@ -243,12 +243,12 @@ static void *slob_page_alloc(struct page
 				if (prev)
 					set_slob(prev, slob_units(prev), next);
 				else
-					sp->freelist = next;
+					sp->slob_freelist = next;
 			} else { /* fragment */
 				if (prev)
 					set_slob(prev, slob_units(prev), cur + units);
 				else
-					sp->freelist = cur + units;
+					sp->slob_freelist = cur + units;
 				set_slob(cur + units, avail - units, next);
 			}
 
@@ -321,7 +321,7 @@ static void *slob_alloc(size_t size, gfp
 
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
-		sp->freelist = b;
+		sp->slob_freelist = b;
 		INIT_LIST_HEAD(&sp->list);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
@@ -368,7 +368,7 @@ static void slob_free(void *block, int s
 	if (!slob_page_free(sp)) {
 		/* This slob page is about to become partially free. Easy! */
 		sp->units = units;
-		sp->freelist = b;
+		sp->slob_freelist = b;
 		set_slob(b, units,
 			(void *)((unsigned long)(b +
 					SLOB_UNITS(PAGE_SIZE)) & PAGE_MASK));
@@ -388,15 +388,15 @@ static void slob_free(void *block, int s
 	 */
 	sp->units += units;
 
-	if (b < (slob_t *)sp->freelist) {
-		if (b + units == sp->freelist) {
-			units += slob_units(sp->freelist);
-			sp->freelist = slob_next(sp->freelist);
+	if (b < (slob_t *)sp->slob_freelist) {
+		if (b + units == sp->slob_freelist) {
+			units += slob_units(sp->slob_freelist);
+			sp->slob_freelist = slob_next(sp->slob_freelist);
 		}
-		set_slob(b, units, sp->freelist);
-		sp->freelist = b;
+		set_slob(b, units, sp->slob_freelist);
+		sp->slob_freelist = b;
 	} else {
-		prev = sp->freelist;
+		prev = sp->slob_freelist;
 		next = slob_next(prev);
 		while (b > next) {
 			prev = next;
diff -puN mm/slub.c~rearrange-struct-page mm/slub.c
--- linux.git/mm/slub.c~rearrange-struct-page	2013-12-13 15:51:48.059244974 -0800
+++ linux.git-davehans/mm/slub.c	2013-12-13 15:51:48.063245150 -0800
@@ -52,7 +52,7 @@
  *   The slab_lock is only used for debugging and on arches that do not
  *   have the ability to do a cmpxchg_double. It only protects the second
  *   double word in the page struct. Meaning
- *	A. page->freelist	-> List of object free in a page
+ *	A. page->slub_freelist	-> List of object free in a page
  *	B. page->counters	-> Counters of objects
  *	C. page->frozen		-> frozen state
  *
@@ -365,7 +365,7 @@ static inline bool __cmpxchg_double_slab
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
+		if (cmpxchg_double(&page->slub_freelist, &page->counters,
 			freelist_old, counters_old,
 			freelist_new, counters_new))
 		return 1;
@@ -373,9 +373,9 @@ static inline bool __cmpxchg_double_slab
 #endif
 	{
 		slab_lock(page);
-		if (page->freelist == freelist_old &&
+		if (page->slub_freelist == freelist_old &&
 					page->counters == counters_old) {
-			page->freelist = freelist_new;
+			page->slub_freelist = freelist_new;
 			page->counters = counters_new;
 			slab_unlock(page);
 			return 1;
@@ -401,7 +401,7 @@ static inline bool cmpxchg_double_slab(s
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
+		if (cmpxchg_double(&page->slub_freelist, &page->counters,
 			freelist_old, counters_old,
 			freelist_new, counters_new))
 		return 1;
@@ -412,9 +412,9 @@ static inline bool cmpxchg_double_slab(s
 
 		local_irq_save(flags);
 		slab_lock(page);
-		if (page->freelist == freelist_old &&
+		if (page->slub_freelist == freelist_old &&
 					page->counters == counters_old) {
-			page->freelist = freelist_new;
+			page->slub_freelist = freelist_new;
 			page->counters = counters_new;
 			slab_unlock(page);
 			local_irq_restore(flags);
@@ -446,7 +446,7 @@ static void get_map(struct kmem_cache *s
 	void *p;
 	void *addr = page_address(page);
 
-	for (p = page->freelist; p; p = get_freepointer(s, p))
+	for (p = page->slub_freelist; p; p = get_freepointer(s, p))
 		set_bit(slab_index(p, s, addr), map);
 }
 
@@ -557,7 +557,7 @@ static void print_page_info(struct page
 {
 	printk(KERN_ERR
 	       "INFO: Slab 0x%p objects=%u used=%u fp=0x%p flags=0x%04lx\n",
-	       page, page->objects, page->inuse, page->freelist, page->flags);
+	       page, page->objects, page->inuse, page->slub_freelist, page->flags);
 
 }
 
@@ -869,7 +869,7 @@ static int on_freelist(struct kmem_cache
 	void *object = NULL;
 	unsigned long max_objects;
 
-	fp = page->freelist;
+	fp = page->slub_freelist;
 	while (fp && nr <= page->objects) {
 		if (fp == search)
 			return 1;
@@ -880,7 +880,7 @@ static int on_freelist(struct kmem_cache
 				set_freepointer(s, object, NULL);
 			} else {
 				slab_err(s, page, "Freepointer corrupt");
-				page->freelist = NULL;
+				page->slub_freelist = NULL;
 				page->inuse = page->objects;
 				slab_fix(s, "Freelist cleared");
 				return 0;
@@ -919,7 +919,7 @@ static void trace(struct kmem_cache *s,
 			s->name,
 			alloc ? "alloc" : "free",
 			object, page->inuse,
-			page->freelist);
+			page->slub_freelist);
 
 		if (!alloc)
 			print_section("Object ", (void *)object,
@@ -1086,7 +1086,7 @@ bad:
 		 */
 		slab_fix(s, "Marking all objects used");
 		page->inuse = page->objects;
-		page->freelist = NULL;
+		page->slub_freelist = NULL;
 	}
 	return 0;
 }
@@ -1420,7 +1420,7 @@ static struct page *new_slab(struct kmem
 	setup_object(s, page, last);
 	set_freepointer(s, last, NULL);
 
-	page->freelist = start;
+	page->slub_freelist = start;
 	page->inuse = page->objects;
 	page->frozen = 1;
 out:
@@ -1548,15 +1548,15 @@ static inline void *acquire_slab(struct
 	 * The old freelist is the list of objects for the
 	 * per cpu allocation list.
 	 */
-	freelist = page->freelist;
+	freelist = page->slub_freelist;
 	counters = page->counters;
 	new.counters = counters;
 	*objects = new.objects - new.inuse;
 	if (mode) {
 		new.inuse = page->objects;
-		new.freelist = NULL;
+		new.slub_freelist = NULL;
 	} else {
-		new.freelist = freelist;
+		new.slub_freelist = freelist;
 	}
 
 	VM_BUG_ON(new.frozen);
@@ -1564,7 +1564,7 @@ static inline void *acquire_slab(struct
 
 	if (!__cmpxchg_double_slab(s, page,
 			freelist, counters,
-			new.freelist, new.counters,
+			new.slub_freelist, new.counters,
 			"acquire_slab"))
 		return NULL;
 
@@ -1789,7 +1789,7 @@ static void deactivate_slab(struct kmem_
 	struct page new;
 	struct page old;
 
-	if (page->freelist) {
+	if (page->slub_freelist) {
 		stat(s, DEACTIVATE_REMOTE_FREES);
 		tail = DEACTIVATE_TO_TAIL;
 	}
@@ -1807,7 +1807,7 @@ static void deactivate_slab(struct kmem_
 		unsigned long counters;
 
 		do {
-			prior = page->freelist;
+			prior = page->slub_freelist;
 			counters = page->counters;
 			set_freepointer(s, freelist, prior);
 			new.counters = counters;
@@ -1838,7 +1838,7 @@ static void deactivate_slab(struct kmem_
 	 */
 redo:
 
-	old.freelist = page->freelist;
+	old.slub_freelist = page->slub_freelist;
 	old.counters = page->counters;
 	VM_BUG_ON(!old.frozen);
 
@@ -1846,16 +1846,16 @@ redo:
 	new.counters = old.counters;
 	if (freelist) {
 		new.inuse--;
-		set_freepointer(s, freelist, old.freelist);
-		new.freelist = freelist;
+		set_freepointer(s, freelist, old.slub_freelist);
+		new.slub_freelist = freelist;
 	} else
-		new.freelist = old.freelist;
+		new.slub_freelist = old.slub_freelist;
 
 	new.frozen = 0;
 
 	if (!new.inuse && n->nr_partial > s->min_partial)
 		m = M_FREE;
-	else if (new.freelist) {
+	else if (new.slub_freelist) {
 		m = M_PARTIAL;
 		if (!lock) {
 			lock = 1;
@@ -1904,8 +1904,8 @@ redo:
 
 	l = m;
 	if (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
+				old.slub_freelist, old.counters,
+				new.slub_freelist, new.counters,
 				"unfreezing slab"))
 		goto redo;
 
@@ -1950,18 +1950,18 @@ static void unfreeze_partials(struct kme
 
 		do {
 
-			old.freelist = page->freelist;
+			old.slub_freelist = page->slub_freelist;
 			old.counters = page->counters;
 			VM_BUG_ON(!old.frozen);
 
 			new.counters = old.counters;
-			new.freelist = old.freelist;
+			new.slub_freelist = old.slub_freelist;
 
 			new.frozen = 0;
 
 		} while (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
+				old.slub_freelist, old.counters,
+				new.slub_freelist, new.counters,
 				"unfreezing slab"));
 
 		if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
@@ -2184,8 +2184,8 @@ static inline void *new_slab_objects(str
 		 * No other reference to the page yet so we can
 		 * muck around with it freely without cmpxchg
 		 */
-		freelist = page->freelist;
-		page->freelist = NULL;
+		freelist = page->slub_freelist;
+		page->slub_freelist = NULL;
 
 		stat(s, ALLOC_SLAB);
 		c->page = page;
@@ -2205,7 +2205,7 @@ static inline bool pfmemalloc_match(stru
 }
 
 /*
- * Check the page->freelist of a page and either transfer the freelist to the
+ * Check the page->slub_freelist of a page and either transfer the freelist to the
  * per cpu freelist or deactivate the page.
  *
  * The page is still frozen if the return value is not NULL.
@@ -2221,7 +2221,7 @@ static inline void *get_freelist(struct
 	void *freelist;
 
 	do {
-		freelist = page->freelist;
+		freelist = page->slub_freelist;
 		counters = page->counters;
 
 		new.counters = counters;
@@ -2533,7 +2533,7 @@ static void __slab_free(struct kmem_cach
 			spin_unlock_irqrestore(&n->list_lock, flags);
 			n = NULL;
 		}
-		prior = page->freelist;
+		prior = page->slub_freelist;
 		counters = page->counters;
 		set_freepointer(s, object, prior);
 		new.counters = counters;
@@ -2877,9 +2877,9 @@ static void early_kmem_cache_node_alloc(
 				"in order to be able to continue\n");
 	}
 
-	n = page->freelist;
+	n = page->slub_freelist;
 	BUG_ON(!n);
-	page->freelist = get_freepointer(kmem_cache_node, n);
+	page->slub_freelist = get_freepointer(kmem_cache_node, n);
 	page->inuse = 1;
 	page->frozen = 0;
 	kmem_cache_node->node[node] = n;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

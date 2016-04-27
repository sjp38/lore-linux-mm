Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 050D96B0264
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 03:47:35 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u190so77239630pfb.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 00:47:34 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id ey9si3988261pab.123.2016.04.27.00.47.32
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 00:47:33 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 08/12] zsmalloc: introduce zspage structure
Date: Wed, 27 Apr 2016 16:48:21 +0900
Message-Id: <1461743305-19970-9-git-send-email-minchan@kernel.org>
In-Reply-To: <1461743305-19970-1-git-send-email-minchan@kernel.org>
References: <1461743305-19970-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

We have squeezed meta data of zspage into first page's descriptor.
So, to get meta data from subpage, we should get first page first
of all. But it makes trouble to implment page migration feature
of zsmalloc because any place where to get first page from subpage
can be raced with first page migration. IOW, first page it got
could be stale. For preventing it, I have tried several approahces
but it made code complicated so finally, I concluded to separate
metadata from first page. Of course, it consumes more memory. IOW,
16bytes per zspage on 32bit at the moment. It means we lost 1%
at *worst case*(40B/4096B) which is not bad I think at the cost of
maintenance.

Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 532 +++++++++++++++++++++++++++-------------------------------
 1 file changed, 243 insertions(+), 289 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b08ac1ae1743..4b5ead85c7e7 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -16,26 +16,11 @@
  * struct page(s) to form a zspage.
  *
  * Usage of struct page fields:
- *	page->private: points to the first component (0-order) page
- *	page->index (union with page->freelist): offset of the first object
- *		starting in this page. For the first page, this is
- *		always 0, so we use this field (aka freelist) to point
- *		to the first free object in zspage.
- *	page->lru: links together all component pages (except the first page)
- *		of a zspage
- *
- *	For _first_ page only:
- *
- *	page->private: refers to the component page after the first page
- *		If the page is first_page for huge object, it stores handle.
- *		Look at size_class->huge.
- *	page->freelist: points to the first free object in zspage.
- *		Free objects are linked together using in-place
- *		metadata.
- *	page->lru: links together first pages of various zspages.
- *		Basically forming list of zspages in a fullness group.
- *	page->mapping: class index and fullness group of the zspage
- *	page->inuse: the number of objects that are used in this zspage
+ *	page->private: points to zspage
+ *	page->index: offset of the first object starting in this page.
+ *		For the first page, this is always 0, so we use this field
+ *		to store handle for huge object.
+ *	page->next: links together all component pages of a zspage
  *
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
@@ -145,7 +130,7 @@
  *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
  *  (reason above)
  */
-#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> 8)
+#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> CLASS_BITS)
 
 /*
  * We do not maintain any list for completely empty or full pages
@@ -153,8 +138,6 @@
 enum fullness_group {
 	ZS_ALMOST_FULL,
 	ZS_ALMOST_EMPTY,
-	_ZS_NR_FULLNESS_GROUPS,
-
 	ZS_EMPTY,
 	ZS_FULL
 };
@@ -203,7 +186,7 @@ static const int fullness_threshold_frac = 4;
 
 struct size_class {
 	spinlock_t lock;
-	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
+	struct list_head fullness_list[2];
 	/*
 	 * Size of objects stored in this class. Must be multiple
 	 * of ZS_ALIGN.
@@ -222,7 +205,7 @@ struct size_class {
 
 /*
  * Placed within free objects to form a singly linked list.
- * For every zspage, first_page->freelist gives head of this list.
+ * For every zspage, zspage->freeobj gives head of this list.
  *
  * This must be power of 2 and less than or equal to ZS_ALIGN
  */
@@ -245,6 +228,7 @@ struct zs_pool {
 
 	struct size_class **size_class;
 	struct kmem_cache *handle_cachep;
+	struct kmem_cache *zspage_cachep;
 
 	gfp_t flags;	/* allocation flags used when growing pool */
 	atomic_long_t pages_allocated;
@@ -267,14 +251,19 @@ struct zs_pool {
  * A zspage's class index and fullness group
  * are encoded in its (first)page->mapping
  */
-#define FULLNESS_BITS	4
-#define CLASS_BITS	28
+#define FULLNESS_BITS	2
+#define CLASS_BITS	8
 
-#define FULLNESS_SHIFT	0
-#define CLASS_SHIFT	(FULLNESS_SHIFT + FULLNESS_BITS)
-
-#define FULLNESS_MASK	((1UL << FULLNESS_BITS) - 1)
-#define CLASS_MASK	((1UL << CLASS_BITS) - 1)
+struct zspage {
+	struct {
+		unsigned int fullness:FULLNESS_BITS;
+		unsigned int class:CLASS_BITS;
+	};
+	unsigned int inuse;
+	void *freeobj;
+	struct page *first_page;
+	struct list_head list; /* fullness list */
+};
 
 struct mapping_area {
 #ifdef CONFIG_PGTABLE_MAPPING
@@ -286,29 +275,55 @@ struct mapping_area {
 	enum zs_mapmode vm_mm; /* mapping mode */
 };
 
-static int create_handle_cache(struct zs_pool *pool)
+static int create_cache(struct zs_pool *pool)
 {
 	pool->handle_cachep = kmem_cache_create("zs_handle", ZS_HANDLE_SIZE,
 					0, 0, NULL);
-	return pool->handle_cachep ? 0 : 1;
+	if (!pool->handle_cachep)
+		return 1;
+
+	pool->zspage_cachep = kmem_cache_create("zspage", sizeof(struct zspage),
+					0, 0, NULL);
+	if (!pool->zspage_cachep) {
+		kmem_cache_destroy(pool->handle_cachep);
+		return 1;
+	}
+
+	return 0;
 }
 
-static void destroy_handle_cache(struct zs_pool *pool)
+static void destroy_cache(struct zs_pool *pool)
 {
 	kmem_cache_destroy(pool->handle_cachep);
+	kmem_cache_destroy(pool->zspage_cachep);
 }
 
-static unsigned long alloc_handle(struct zs_pool *pool)
+static unsigned long cache_alloc_handle(struct zs_pool *pool)
 {
 	return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
 		pool->flags & ~__GFP_HIGHMEM);
 }
 
-static void free_handle(struct zs_pool *pool, unsigned long handle)
+static void cache_free_handle(struct zs_pool *pool, unsigned long handle)
 {
 	kmem_cache_free(pool->handle_cachep, (void *)handle);
 }
 
+static struct zspage *cache_alloc_zspage(struct zs_pool *pool, gfp_t flags)
+{
+	struct zspage *zspage;
+
+	zspage = kmem_cache_alloc(pool->zspage_cachep, flags & ~__GFP_HIGHMEM);
+	if (zspage)
+		memset(zspage, 0, sizeof(struct zspage));
+	return zspage;
+};
+
+static void cache_free_zspage(struct zs_pool *pool, struct zspage *zspage)
+{
+	kmem_cache_free(pool->zspage_cachep, zspage);
+}
+
 static void record_obj(unsigned long handle, unsigned long obj)
 {
 	/*
@@ -411,67 +426,61 @@ static int is_first_page(struct page *page)
 	return PagePrivate(page);
 }
 
-static int is_last_page(struct page *page)
-{
-	return PagePrivate2(page);
-}
-
-static inline int get_zspage_inuse(struct page *first_page)
+static inline int get_zspage_inuse(struct zspage *zspage)
 {
-	return first_page->inuse;
+	return zspage->inuse;
 }
 
-static inline void set_zspage_inuse(struct page *first_page, int val)
+static inline void set_zspage_inuse(struct zspage *zspage, int val)
 {
-	first_page->inuse = val;
+	zspage->inuse = val;
 }
 
-static inline void mod_zspage_inuse(struct page *first_page, int val)
+static inline void mod_zspage_inuse(struct zspage *zspage, int val)
 {
-	first_page->inuse += val;
+	zspage->inuse += val;
 }
 
 static inline int get_first_obj_offset(struct page *page)
 {
+	if (is_first_page(page))
+		return 0;
+
 	return page->index;
 }
 
 static inline void set_first_obj_offset(struct page *page, int offset)
 {
+	if (is_first_page(page))
+		return;
+
 	page->index = offset;
 }
 
-static inline unsigned long get_freeobj(struct page *first_page)
+static inline unsigned long get_freeobj(struct zspage *zspage)
 {
-	return (unsigned long)first_page->freelist;
+	return (unsigned long)zspage->freeobj;
 }
 
-static inline void set_freeobj(struct page *first_page, unsigned long obj)
+static inline void set_freeobj(struct zspage *zspage, unsigned long obj)
 {
-	first_page->freelist = (void *)obj;
+	zspage->freeobj = (void *)obj;
 }
 
-static void get_zspage_mapping(struct page *first_page,
+static void get_zspage_mapping(struct zspage *zspage,
 				unsigned int *class_idx,
 				enum fullness_group *fullness)
 {
-	unsigned long m;
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
-
-	m = (unsigned long)first_page->mapping;
-	*fullness = (m >> FULLNESS_SHIFT) & FULLNESS_MASK;
-	*class_idx = (m >> CLASS_SHIFT) & CLASS_MASK;
+	*fullness = zspage->fullness;
+	*class_idx = zspage->class;
 }
 
-static void set_zspage_mapping(struct page *first_page,
+static void set_zspage_mapping(struct zspage *zspage,
 				unsigned int class_idx,
 				enum fullness_group fullness)
 {
-	unsigned long m;
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
-
-	m = (class_idx << CLASS_SHIFT) | (fullness << FULLNESS_SHIFT);
-	first_page->mapping = (struct address_space *)m;
+	zspage->class = class_idx;
+	zspage->fullness = fullness;
 }
 
 /*
@@ -665,14 +674,12 @@ static inline void zs_pool_stat_destroy(struct zs_pool *pool)
  * status of the given page.
  */
 static enum fullness_group get_fullness_group(struct size_class *class,
-						struct page *first_page)
+						struct zspage *zspage)
 {
 	int inuse, objs_per_zspage;
 	enum fullness_group fg;
 
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
-
-	inuse = get_zspage_inuse(first_page);
+	inuse = get_zspage_inuse(zspage);
 	objs_per_zspage = class->objs_per_zspage;
 
 	if (inuse == 0)
@@ -694,32 +701,31 @@ static enum fullness_group get_fullness_group(struct size_class *class,
  * identified by <class, fullness_group>.
  */
 static void insert_zspage(struct size_class *class,
-				enum fullness_group fullness,
-				struct page *first_page)
+				struct zspage *zspage,
+				enum fullness_group fullness)
 {
-	struct page **head;
-
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+	struct zspage *head;
 
-	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
+	if (fullness >= ZS_EMPTY)
 		return;
 
+	head = list_first_entry_or_null(&class->fullness_list[fullness],
+					struct zspage, list);
+
 	zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
 			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
 
-	head = &class->fullness_list[fullness];
-	if (!*head) {
-		*head = first_page;
-		return;
-	}
-
 	/*
-	 * We want to see more ZS_FULL pages and less almost
-	 * empty/full. Put pages with higher ->inuse first.
+	 * We want to see more ZS_FULL pages and less almost empty/full.
+	 * Put pages with higher ->inuse first.
 	 */
-	list_add_tail(&first_page->lru, &(*head)->lru);
-	if (get_zspage_inuse(first_page) >= get_zspage_inuse(*head))
-		*head = first_page;
+	if (head) {
+		if (get_zspage_inuse(zspage) < get_zspage_inuse(head)) {
+			list_add(&zspage->list, &head->list);
+			return;
+		}
+	}
+	list_add(&zspage->list, &class->fullness_list[fullness]);
 }
 
 /*
@@ -727,25 +733,15 @@ static void insert_zspage(struct size_class *class,
  * by <class, fullness_group>.
  */
 static void remove_zspage(struct size_class *class,
-				enum fullness_group fullness,
-				struct page *first_page)
+				struct zspage *zspage,
+				enum fullness_group fullness)
 {
-	struct page **head;
-
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
-
-	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
+	if (fullness >= ZS_EMPTY)
 		return;
 
-	head = &class->fullness_list[fullness];
-	VM_BUG_ON_PAGE(!*head, first_page);
-	if (list_empty(&(*head)->lru))
-		*head = NULL;
-	else if (*head == first_page)
-		*head = (struct page *)list_entry((*head)->lru.next,
-					struct page, lru);
+	VM_BUG_ON(list_empty(&class->fullness_list[fullness]));
 
-	list_del_init(&first_page->lru);
+	list_del_init(&zspage->list);
 	zs_stat_dec(class, fullness == ZS_ALMOST_EMPTY ?
 			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
 }
@@ -760,19 +756,19 @@ static void remove_zspage(struct size_class *class,
  * fullness group.
  */
 static enum fullness_group fix_fullness_group(struct size_class *class,
-						struct page *first_page)
+						struct zspage *zspage)
 {
 	int class_idx;
 	enum fullness_group currfg, newfg;
 
-	get_zspage_mapping(first_page, &class_idx, &currfg);
-	newfg = get_fullness_group(class, first_page);
+	get_zspage_mapping(zspage, &class_idx, &currfg);
+	newfg = get_fullness_group(class, zspage);
 	if (newfg == currfg)
 		goto out;
 
-	remove_zspage(class, currfg, first_page);
-	insert_zspage(class, newfg, first_page);
-	set_zspage_mapping(first_page, class_idx, newfg);
+	remove_zspage(class, zspage, currfg);
+	insert_zspage(class, zspage, newfg);
+	set_zspage_mapping(zspage, class_idx, newfg);
 
 out:
 	return newfg;
@@ -814,31 +810,15 @@ static int get_pages_per_zspage(int class_size)
 	return max_usedpc_order;
 }
 
-/*
- * A single 'zspage' is composed of many system pages which are
- * linked together using fields in struct page. This function finds
- * the first/head page, given any component page of a zspage.
- */
-static struct page *get_first_page(struct page *page)
+
+static struct zspage *get_zspage(struct page *page)
 {
-	if (is_first_page(page))
-		return page;
-	else
-		return (struct page *)page_private(page);
+	return (struct zspage *)page->private;
 }
 
 static struct page *get_next_page(struct page *page)
 {
-	struct page *next;
-
-	if (is_last_page(page))
-		next = NULL;
-	else if (is_first_page(page))
-		next = (struct page *)page_private(page);
-	else
-		next = list_entry(page->lru.next, struct page, lru);
-
-	return next;
+	return page->next;
 }
 
 /*
@@ -884,7 +864,7 @@ static unsigned long obj_to_head(struct size_class *class, struct page *page,
 {
 	if (class->huge) {
 		VM_BUG_ON_PAGE(!is_first_page(page), page);
-		return page_private(page);
+		return page->index;
 	} else
 		return *(unsigned long *)obj;
 }
@@ -892,10 +872,9 @@ static unsigned long obj_to_head(struct size_class *class, struct page *page,
 static unsigned long obj_idx_to_offset(struct page *page,
 				unsigned long obj_idx, int class_size)
 {
-	unsigned long off = 0;
+	unsigned long off;
 
-	if (!is_first_page(page))
-		off = get_first_obj_offset(page);
+	off = get_first_obj_offset(page);
 
 	return off + obj_idx * class_size;
 }
@@ -920,44 +899,31 @@ static void reset_page(struct page *page)
 	clear_bit(PG_private, &page->flags);
 	clear_bit(PG_private_2, &page->flags);
 	set_page_private(page, 0);
-	page->mapping = NULL;
-	page->freelist = NULL;
-	page_mapcount_reset(page);
+	page->index = 0;
 }
 
-static void free_zspage(struct page *first_page)
+static void free_zspage(struct zs_pool *pool, struct zspage *zspage)
 {
-	struct page *nextp, *tmp, *head_extra;
-
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
-	VM_BUG_ON_PAGE(get_zspage_inuse(first_page), first_page);
+	struct page *page, *next;
 
-	head_extra = (struct page *)page_private(first_page);
+	VM_BUG_ON(get_zspage_inuse(zspage));
 
-	reset_page(first_page);
-	__free_page(first_page);
+	next = page = zspage->first_page;
+	do {
+		next = page->next;
+		reset_page(page);
+		put_page(page);
+		page = next;
+	} while (page != NULL);
 
-	/* zspage with only 1 system page */
-	if (!head_extra)
-		return;
-
-	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
-		list_del(&nextp->lru);
-		reset_page(nextp);
-		__free_page(nextp);
-	}
-	reset_page(head_extra);
-	__free_page(head_extra);
+	cache_free_zspage(pool, zspage);
 }
 
 /* Initialize a newly allocated zspage */
-static void init_zspage(struct size_class *class, struct page *first_page)
+static void init_zspage(struct size_class *class, struct zspage *zspage)
 {
 	unsigned long off = 0;
-	struct page *page = first_page;
-
-	first_page->freelist = NULL;
-	set_zspage_inuse(first_page, 0);
+	struct page *page = zspage->first_page;
 
 	while (page) {
 		struct page *next_page;
@@ -965,14 +931,7 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 		unsigned int i = 1;
 		void *vaddr;
 
-		/*
-		 * page->index stores offset of first object starting
-		 * in the page. For the first page, this is always 0,
-		 * so we use first_page->index (aka ->freelist) to store
-		 * head of corresponding zspage's freelist.
-		 */
-		if (page != first_page)
-			set_first_obj_offset(page, off);
+		set_first_obj_offset(page, off);
 
 		vaddr = kmap_atomic(page);
 		link = (struct link_free *)vaddr + off / sizeof(*link);
@@ -994,44 +953,38 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 		off %= PAGE_SIZE;
 	}
 
-	set_freeobj(first_page, (unsigned long)location_to_obj(first_page, 0));
+	set_freeobj(zspage,
+		(unsigned long)location_to_obj(zspage->first_page, 0));
 }
 
-static void create_page_chain(struct page *pages[], int nr_pages)
+static void create_page_chain(struct zspage *zspage, struct page *pages[],
+				int nr_pages)
 {
 	int i;
 	struct page *page;
 	struct page *prev_page = NULL;
-	struct page *first_page = NULL;
 
 	/*
 	 * Allocate individual pages and link them together as:
-	 * 1. first page->private = first sub-page
-	 * 2. all sub-pages are linked together using page->lru
-	 * 3. each sub-page is linked to the first page using page->private
+	 * 1. all pages are linked together using page->next
+	 * 2. each sub-page point to zspage using page->private
 	 *
-	 * For each size class, First/Head pages are linked together using
-	 * page->lru. Also, we set PG_private to identify the first page
-	 * (i.e. no other sub-page has this flag set) and PG_private_2 to
-	 * identify the last page.
+	 * we set PG_private to identify the first page (i.e. no other sub-page
+	 * has this flag set) and PG_private_2 to identify the last page.
 	 */
 	for (i = 0; i < nr_pages; i++) {
 		page = pages[i];
-
-		INIT_LIST_HEAD(&page->lru);
+		set_page_private(page, (unsigned long)zspage);
 		if (i == 0) {
+			zspage->first_page = page;
 			SetPagePrivate(page);
-			set_page_private(page, 0);
-			first_page = page;
+		} else {
+			prev_page->next = page;
 		}
-		if (i == 1)
-			set_page_private(first_page, (unsigned long)page);
-		if (i >= 1)
-			set_page_private(page, (unsigned long)first_page);
-		if (i >= 2)
-			list_add(&page->lru, &prev_page->lru);
-		if (i == nr_pages - 1)
+		if (i == nr_pages - 1) {
 			SetPagePrivate2(page);
+			page->next = NULL;
+		}
 		prev_page = page;
 	}
 }
@@ -1039,43 +992,48 @@ static void create_page_chain(struct page *pages[], int nr_pages)
 /*
  * Allocate a zspage for the given size class
  */
-static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
+static struct zspage *alloc_zspage(struct zs_pool *pool,
+					struct size_class *class)
 {
 	int i;
-	struct page *first_page = NULL;
 	struct page *pages[ZS_MAX_PAGES_PER_ZSPAGE];
+	struct zspage *zspage = cache_alloc_zspage(pool, pool->flags);
+
+	if (!zspage)
+		return NULL;
 
 	for (i = 0; i < class->pages_per_zspage; i++) {
 		struct page *page;
 
-		page = alloc_page(flags);
+		page = alloc_page(pool->flags);
 		if (!page) {
 			while (--i >= 0)
 				__free_page(pages[i]);
+			cache_free_zspage(pool, zspage);
 			return NULL;
 		}
 		pages[i] = page;
 	}
 
-	create_page_chain(pages, class->pages_per_zspage);
-	first_page = pages[0];
-	init_zspage(class, first_page);
+	create_page_chain(zspage, pages, class->pages_per_zspage);
+	init_zspage(class, zspage);
 
-	return first_page;
+	return zspage;
 }
 
-static struct page *find_get_zspage(struct size_class *class)
+static struct zspage *find_get_zspage(struct size_class *class)
 {
 	int i;
-	struct page *page;
+	struct zspage *zspage;
 
-	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
-		page = class->fullness_list[i];
-		if (page)
+	for (i = ZS_ALMOST_FULL; i <= ZS_ALMOST_EMPTY; i++) {
+		zspage = list_first_entry_or_null(&class->fullness_list[i],
+				struct zspage, list);
+		if (zspage)
 			break;
 	}
 
-	return page;
+	return zspage;
 }
 
 #ifdef CONFIG_PGTABLE_MAPPING
@@ -1280,11 +1238,9 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 	return true;
 }
 
-static bool zspage_full(struct size_class *class, struct page *first_page)
+static bool zspage_full(struct size_class *class, struct zspage *zspage)
 {
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
-
-	return get_zspage_inuse(first_page) == class->objs_per_zspage;
+	return get_zspage_inuse(zspage) == class->objs_per_zspage;
 }
 
 unsigned long zs_get_total_pages(struct zs_pool *pool)
@@ -1310,6 +1266,7 @@ EXPORT_SYMBOL_GPL(zs_get_total_pages);
 void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 			enum zs_mapmode mm)
 {
+	struct zspage *zspage;
 	struct page *page;
 	unsigned long obj, obj_idx, off;
 
@@ -1332,7 +1289,8 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &page, &obj_idx);
-	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
+	zspage = get_zspage(page);
+	get_zspage_mapping(zspage, &class_idx, &fg);
 	class = pool->size_class[class_idx];
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
@@ -1361,6 +1319,7 @@ EXPORT_SYMBOL_GPL(zs_map_object);
 
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 {
+	struct zspage *zspage;
 	struct page *page;
 	unsigned long obj, obj_idx, off;
 
@@ -1371,7 +1330,8 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &page, &obj_idx);
-	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
+	zspage = get_zspage(page);
+	get_zspage_mapping(zspage, &class_idx, &fg);
 	class = pool->size_class[class_idx];
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
@@ -1393,7 +1353,7 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
 static unsigned long obj_malloc(struct size_class *class,
-				struct page *first_page, unsigned long handle)
+				struct zspage *zspage, unsigned long handle)
 {
 	unsigned long obj;
 	struct link_free *link;
@@ -1403,21 +1363,22 @@ static unsigned long obj_malloc(struct size_class *class,
 	void *vaddr;
 
 	handle |= OBJ_ALLOCATED_TAG;
-	obj = get_freeobj(first_page);
+	obj = get_freeobj(zspage);
 	obj_to_location(obj, &m_page, &m_objidx);
 	m_offset = obj_idx_to_offset(m_page, m_objidx, class->size);
 
 	vaddr = kmap_atomic(m_page);
 	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
-	set_freeobj(first_page, (unsigned long)link->next);
+	set_freeobj(zspage, (unsigned long)link->next);
 	if (!class->huge)
 		/* record handle in the header of allocated chunk */
 		link->handle = handle;
 	else
-		/* record handle in first_page->private */
-		set_page_private(first_page, handle);
+		/* record handle to page->index */
+		zspage->first_page->index = handle;
+
 	kunmap_atomic(vaddr);
-	mod_zspage_inuse(first_page, 1);
+	mod_zspage_inuse(zspage, 1);
 	zs_stat_inc(class, OBJ_USED, 1);
 
 	return obj;
@@ -1437,12 +1398,12 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 {
 	unsigned long handle, obj;
 	struct size_class *class;
-	struct page *first_page;
+	struct zspage *zspage;
 
 	if (unlikely(!size || size > ZS_MAX_ALLOC_SIZE))
 		return 0;
 
-	handle = alloc_handle(pool);
+	handle = cache_alloc_handle(pool);
 	if (!handle)
 		return 0;
 
@@ -1451,17 +1412,17 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	class = pool->size_class[get_size_class_index(size)];
 
 	spin_lock(&class->lock);
-	first_page = find_get_zspage(class);
+	zspage = find_get_zspage(class);
 
-	if (!first_page) {
+	if (!zspage) {
 		spin_unlock(&class->lock);
-		first_page = alloc_zspage(class, pool->flags);
-		if (unlikely(!first_page)) {
-			free_handle(pool, handle);
+		zspage = alloc_zspage(pool, class);
+		if (unlikely(!zspage)) {
+			cache_free_handle(pool, handle);
 			return 0;
 		}
 
-		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
+		set_zspage_mapping(zspage, class->index, ZS_EMPTY);
 		atomic_long_add(class->pages_per_zspage,
 					&pool->pages_allocated);
 
@@ -1470,9 +1431,9 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 				class->size, class->pages_per_zspage));
 	}
 
-	obj = obj_malloc(class, first_page, handle);
+	obj = obj_malloc(class, zspage, handle);
 	/* Now move the zspage to another fullness group, if required */
-	fix_fullness_group(class, first_page);
+	fix_fullness_group(class, zspage);
 	record_obj(handle, obj);
 	spin_unlock(&class->lock);
 
@@ -1483,13 +1444,14 @@ EXPORT_SYMBOL_GPL(zs_malloc);
 static void obj_free(struct size_class *class, unsigned long obj)
 {
 	struct link_free *link;
-	struct page *first_page, *f_page;
+	struct zspage *zspage;
+	struct page *f_page;
 	unsigned long f_objidx, f_offset;
 	void *vaddr;
 
 	obj &= ~OBJ_ALLOCATED_TAG;
 	obj_to_location(obj, &f_page, &f_objidx);
-	first_page = get_first_page(f_page);
+	zspage = get_zspage(f_page);
 
 	f_offset = obj_idx_to_offset(f_page, f_objidx, class->size);
 
@@ -1497,18 +1459,17 @@ static void obj_free(struct size_class *class, unsigned long obj)
 
 	/* Insert this object in containing zspage's freelist */
 	link = (struct link_free *)(vaddr + f_offset);
-	link->next = (void *)get_freeobj(first_page);
-	if (class->huge)
-		set_page_private(first_page, 0);
+	link->next = (void *)get_freeobj(zspage);
 	kunmap_atomic(vaddr);
-	set_freeobj(first_page, obj);
-	mod_zspage_inuse(first_page, -1);
+	set_freeobj(zspage, obj);
+	mod_zspage_inuse(zspage, -1);
 	zs_stat_dec(class, OBJ_USED, 1);
 }
 
 void zs_free(struct zs_pool *pool, unsigned long handle)
 {
-	struct page *first_page, *f_page;
+	struct zspage *zspage;
+	struct page *f_page;
 	unsigned long obj, f_objidx;
 	int class_idx;
 	struct size_class *class;
@@ -1520,25 +1481,25 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	pin_tag(handle);
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &f_page, &f_objidx);
-	first_page = get_first_page(f_page);
+	zspage = get_zspage(f_page);
 
-	get_zspage_mapping(first_page, &class_idx, &fullness);
+	get_zspage_mapping(zspage, &class_idx, &fullness);
 	class = pool->size_class[class_idx];
 
 	spin_lock(&class->lock);
 	obj_free(class, obj);
-	fullness = fix_fullness_group(class, first_page);
+	fullness = fix_fullness_group(class, zspage);
 	if (fullness == ZS_EMPTY) {
 		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
 				class->size, class->pages_per_zspage));
 		atomic_long_sub(class->pages_per_zspage,
 				&pool->pages_allocated);
-		free_zspage(first_page);
+		free_zspage(pool, zspage);
 	}
 	spin_unlock(&class->lock);
 	unpin_tag(handle);
 
-	free_handle(pool, handle);
+	cache_free_handle(pool, handle);
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
@@ -1617,8 +1578,7 @@ static unsigned long find_alloced_obj(struct size_class *class,
 	unsigned long handle = 0;
 	void *addr = kmap_atomic(page);
 
-	if (!is_first_page(page))
-		offset = get_first_obj_offset(page);
+	offset = get_first_obj_offset(page);
 	offset += class->size * index;
 
 	while (offset < PAGE_SIZE) {
@@ -1639,7 +1599,7 @@ static unsigned long find_alloced_obj(struct size_class *class,
 }
 
 struct zs_compact_control {
-	/* Source page for migration which could be a subpage of zspage. */
+	/* Source spage for migration which could be a subpage of zspage */
 	struct page *s_page;
 	/* Destination page for migration which should be a first page
 	 * of zspage. */
@@ -1670,14 +1630,14 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		}
 
 		/* Stop if there is no more space */
-		if (zspage_full(class, d_page)) {
+		if (zspage_full(class, get_zspage(d_page))) {
 			unpin_tag(handle);
 			ret = -ENOMEM;
 			break;
 		}
 
 		used_obj = handle_to_obj(handle);
-		free_obj = obj_malloc(class, d_page, handle);
+		free_obj = obj_malloc(class, get_zspage(d_page), handle);
 		zs_object_copy(class, free_obj, used_obj);
 		index++;
 		/*
@@ -1699,39 +1659,46 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 	return ret;
 }
 
-static struct page *isolate_target_page(struct size_class *class)
+static struct zspage *isolate_zspage(struct size_class *class, bool source)
 {
 	int i;
-	struct page *page;
+	struct zspage *zspage;
+	enum fullness_group fg[2] = {ZS_ALMOST_EMPTY, ZS_ALMOST_FULL};
 
-	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
-		page = class->fullness_list[i];
-		if (page) {
-			remove_zspage(class, i, page);
-			break;
+	if (!source) {
+		fg[0] = ZS_ALMOST_FULL;
+		fg[1] = ZS_ALMOST_EMPTY;
+	}
+
+	for (i = 0; i < 2; i++) {
+		zspage = list_first_entry_or_null(&class->fullness_list[fg[i]],
+							struct zspage, list);
+		if (zspage) {
+			remove_zspage(class, zspage, fg[i]);
+			return zspage;
 		}
 	}
 
-	return page;
+	return zspage;
 }
 
 /*
- * putback_zspage - add @first_page into right class's fullness list
+ * putback_zspage - add @zspage into right class's fullness list
  * @pool: target pool
  * @class: destination class
- * @first_page: target page
+ * @zspage: target page
  *
- * Return @fist_page's fullness_group
+ * Return @zspage's fullness_group
  */
 static enum fullness_group putback_zspage(struct zs_pool *pool,
 			struct size_class *class,
-			struct page *first_page)
+			struct zspage *zspage)
 {
 	enum fullness_group fullness;
 
-	fullness = get_fullness_group(class, first_page);
-	insert_zspage(class, fullness, first_page);
-	set_zspage_mapping(first_page, class->index, fullness);
+	fullness = get_fullness_group(class, zspage);
+	insert_zspage(class, zspage, fullness);
+	set_zspage_mapping(zspage, class->index, fullness);
 
 	if (fullness == ZS_EMPTY) {
 		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
@@ -1739,29 +1706,12 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 		atomic_long_sub(class->pages_per_zspage,
 				&pool->pages_allocated);
 
-		free_zspage(first_page);
+		free_zspage(pool, zspage);
 	}
 
 	return fullness;
 }
 
-static struct page *isolate_source_page(struct size_class *class)
-{
-	int i;
-	struct page *page = NULL;
-
-	for (i = ZS_ALMOST_EMPTY; i >= ZS_ALMOST_FULL; i--) {
-		page = class->fullness_list[i];
-		if (!page)
-			continue;
-
-		remove_zspage(class, i, page);
-		break;
-	}
-
-	return page;
-}
-
 /*
  *
  * Based on the number of unused allocated objects calculate
@@ -1783,20 +1733,20 @@ static unsigned long zs_can_compact(struct size_class *class)
 static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 {
 	struct zs_compact_control cc;
-	struct page *src_page;
-	struct page *dst_page = NULL;
+	struct zspage *src_zspage;
+	struct zspage *dst_zspage = NULL;
 
 	spin_lock(&class->lock);
-	while ((src_page = isolate_source_page(class))) {
+	while ((src_zspage = isolate_zspage(class, true))) {
 
 		if (!zs_can_compact(class))
 			break;
 
 		cc.index = 0;
-		cc.s_page = src_page;
+		cc.s_page = src_zspage->first_page;
 
-		while ((dst_page = isolate_target_page(class))) {
-			cc.d_page = dst_page;
+		while ((dst_zspage = isolate_zspage(class, false))) {
+			cc.d_page = dst_zspage->first_page;
 			/*
 			 * If there is no more space in dst_page, resched
 			 * and see if anyone had allocated another zspage.
@@ -1804,23 +1754,23 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 			if (!migrate_zspage(pool, class, &cc))
 				break;
 
-			putback_zspage(pool, class, dst_page);
+			putback_zspage(pool, class, dst_zspage);
 		}
 
 		/* Stop if we couldn't find slot */
-		if (dst_page == NULL)
+		if (dst_zspage == NULL)
 			break;
 
-		putback_zspage(pool, class, dst_page);
-		if (putback_zspage(pool, class, src_page) == ZS_EMPTY)
+		putback_zspage(pool, class, dst_zspage);
+		if (putback_zspage(pool, class, src_zspage) == ZS_EMPTY)
 			pool->stats.pages_compacted += class->pages_per_zspage;
 		spin_unlock(&class->lock);
 		cond_resched();
 		spin_lock(&class->lock);
 	}
 
-	if (src_page)
-		putback_zspage(pool, class, src_page);
+	if (src_zspage)
+		putback_zspage(pool, class, src_zspage);
 
 	spin_unlock(&class->lock);
 }
@@ -1938,7 +1888,7 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 	if (!pool->name)
 		goto err;
 
-	if (create_handle_cache(pool))
+	if (create_cache(pool))
 		goto err;
 
 	/*
@@ -1949,6 +1899,7 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 		int size;
 		int pages_per_zspage;
 		struct size_class *class;
+		int fullness = 0;
 
 		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
 		if (size > ZS_MAX_ALLOC_SIZE)
@@ -1984,6 +1935,9 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 			class->huge = true;
 		spin_lock_init(&class->lock);
 		pool->size_class[i] = class;
+		for (fullness = ZS_ALMOST_FULL; fullness <= ZS_ALMOST_EMPTY;
+								fullness++)
+			INIT_LIST_HEAD(&class->fullness_list[fullness]);
 
 		prev_class = class;
 	}
@@ -2024,8 +1978,8 @@ void zs_destroy_pool(struct zs_pool *pool)
 		if (class->index != i)
 			continue;
 
-		for (fg = 0; fg < _ZS_NR_FULLNESS_GROUPS; fg++) {
-			if (class->fullness_list[fg]) {
+		for (fg = ZS_ALMOST_FULL; fg <= ZS_ALMOST_EMPTY; fg++) {
+			if (!list_empty(&class->fullness_list[fg])) {
 				pr_info("Freeing non-empty class with size %db, fullness group %d\n",
 					class->size, fg);
 			}
@@ -2033,7 +1987,7 @@ void zs_destroy_pool(struct zs_pool *pool)
 		kfree(class);
 	}
 
-	destroy_handle_cache(pool);
+	destroy_cache(pool);
 	kfree(pool->size_class);
 	kfree(pool->name);
 	kfree(pool);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

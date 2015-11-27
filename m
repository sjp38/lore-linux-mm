Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6ADA76B0254
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 07:13:42 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so114005453pac.3
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:13:42 -0800 (PST)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id tr2si16118332pac.112.2015.11.27.04.13.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 Nov 2015 04:13:41 -0800 (PST)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH 1/3] zsmalloc: make struct can be migrated
Date: Fri, 27 Nov 2015 20:12:29 +0800
Message-ID: <1448626351-27380-2-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1448626351-27380-1-git-send-email-zhuhui@xiaomi.com>
References: <1448626351-27380-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey
 Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

After "[RFC zsmalloc 0/4] meta diet" [1], the struct it close to
be migrated.
But the LRU is still used.  And to use the migration frame in [2], need
a way to get class through page struct.
So this patch add a new struct zs_migration and store it in struct page.

[1] https://lkml.org/lkml/2015/8/10/90
[2] https://lkml.org/lkml/2015/7/7/21

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/zsmalloc.c | 178 ++++++++++++++++++++++++++++++++++------------------------
 1 file changed, 104 insertions(+), 74 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 1b18144..57c91a5 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -17,10 +17,10 @@
  *
  * Usage of struct page fields:
  *	page->first_page: points to the first component (0-order) page
- *	page->index (union with page->freelist): offset of the first object
- *		starting in this page.
- *	page->lru: links together all component pages (except the first page)
- *		of a zspage
+ *	ZS_MIGRATION(page)->index: offset of the first object starting in
+ *		this page
+ *	ZS_MIGRATION(page)->lru: links together all component pages (except
+ *		the first page) of a zspage
  *
  *	For _first_ page only:
  *
@@ -28,9 +28,9 @@
  *		component page after the first page
  *		If the page is first_page for huge object, it stores handle.
  *		Look at size_class->huge.
- *	page->lru: links together first pages of various zspages.
+ *	ZS_MIGRATION(page)->lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
- *	page->freelist: override by struct zs_meta
+ *	ZS_MIGRATION(page)->index: override by struct zs_meta
  *
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
@@ -136,7 +136,7 @@
 #define INUSE_BITS	11
 #define INUSE_MASK	((1 << INUSE_BITS) - 1)
 #define ETC_BITS	((sizeof(unsigned long) * 8) - FREE_OBJ_IDX_BITS - \
-			CLASS_IDX_BITS - FULLNESS_BITS - INUSE_BITS)
+			FULLNESS_BITS - INUSE_BITS)
 /*
  * On systems with 4K page size, this gives 255 size classes! There is a
  * trader-off here:
@@ -266,12 +266,21 @@ struct zs_pool {
  */
 struct zs_meta {
 	unsigned long free_idx:FREE_OBJ_IDX_BITS;
-	unsigned long class_idx:CLASS_IDX_BITS;
 	unsigned long fullness:FULLNESS_BITS;
 	unsigned long inuse:INUSE_BITS;
 	unsigned long etc:ETC_BITS;
 };
 
+struct zs_migration {
+	unsigned long index;
+	struct size_class *class;
+	struct list_head lru;
+	struct page *page;
+};
+
+#define ZS_MIGRATION(p) ((struct zs_migration *)((p)->freelist))
+#define ZS_META(p) ((struct zs_meta *)&(ZS_MIGRATION(p)->index))
+
 struct mapping_area {
 #ifdef CONFIG_PGTABLE_MAPPING
 	struct vm_struct *vm; /* vm area for mapping object that span pages */
@@ -311,6 +320,19 @@ static void record_obj(unsigned long handle, unsigned long obj)
 	*(unsigned long *)handle = obj;
 }
 
+struct kmem_cache *zs_migration_cachep;
+
+static struct migration *alloc_migration(gfp_t flags)
+{
+	return (struct migration *)kmem_cache_alloc(zs_migration_cachep,
+		flags & ~__GFP_HIGHMEM);
+}
+
+static void free_migration(struct migration *migration)
+{
+	kmem_cache_free(zs_migration_cachep, (void *)migration);
+}
+
 /* zpool driver */
 
 #ifdef CONFIG_ZPOOL
@@ -414,7 +436,7 @@ static int get_inuse_obj(struct page *page)
 
 	BUG_ON(!is_first_page(page));
 
-	m = (struct zs_meta *)&page->freelist;
+	m = ZS_META(page);
 
 	return m->inuse;
 }
@@ -425,48 +447,22 @@ static void set_inuse_obj(struct page *page, int inc)
 
 	BUG_ON(!is_first_page(page));
 
-	m = (struct zs_meta *)&page->freelist;
+	m = ZS_META(page);
 	m->inuse += inc;
 }
 
 static void set_free_obj_idx(struct page *first_page, int idx)
 {
-	struct zs_meta *m = (struct zs_meta *)&first_page->freelist;
+	struct zs_meta *m = ZS_META(first_page);
 	m->free_idx = idx;
 }
 
 static unsigned long get_free_obj_idx(struct page *first_page)
 {
-	struct zs_meta *m = (struct zs_meta *)&first_page->freelist;
+	struct zs_meta *m = ZS_META(first_page);
 	return m->free_idx;
 }
 
-static void get_zspage_mapping(struct page *page, unsigned int *class_idx,
-				enum fullness_group *fullness)
-{
-	struct zs_meta *m;
-	BUG_ON(!is_first_page(page));
-
-	m = (struct zs_meta *)&page->freelist;
-	*fullness = m->fullness;
-	*class_idx = m->class_idx;
-}
-
-static void set_zspage_mapping(struct page *page, unsigned int class_idx,
-				enum fullness_group fullness)
-{
-	struct zs_meta *m;
-
-	BUG_ON(!is_first_page(page));
-
-	BUG_ON(class_idx >= (1 << CLASS_IDX_BITS));
-	BUG_ON(fullness >= (1 << FULLNESS_BITS));
-
-	m = (struct zs_meta *)&page->freelist;
-	m->fullness = fullness;
-	m->class_idx = class_idx;
-}
-
 /*
  * zsmalloc divides the pool into various size classes where each
  * class maintains a list of zspages where each zspage is divided
@@ -698,7 +694,7 @@ static void insert_zspage(struct page *page, struct size_class *class,
 	 * We want to see more ZS_FULL pages and less almost
 	 * empty/full. Put pages with higher inuse first.
 	 */
-	list_add_tail(&page->lru, &(*head)->lru);
+	list_add_tail(&ZS_MIGRATION(page)->lru, &ZS_MIGRATION(*head)->lru);
 	if (get_inuse_obj(page) >= get_inuse_obj(*head))
 		*head = page;
 }
@@ -719,13 +715,18 @@ static void remove_zspage(struct page *page, struct size_class *class,
 
 	head = &class->fullness_list[fullness];
 	BUG_ON(!*head);
-	if (list_empty(&(*head)->lru))
+	if (list_empty(&ZS_MIGRATION(*head)->lru))
 		*head = NULL;
-	else if (*head == page)
-		*head = (struct page *)list_entry((*head)->lru.next,
-					struct page, lru);
+	else if (*head == page) {
+		struct zs_migration *m;
 
-	list_del_init(&page->lru);
+		m = (struct zs_migration *)
+		    list_entry(ZS_MIGRATION(*head)->lru.next,
+			       struct zs_migration, lru);
+		*head = m->page;
+	}
+
+	list_del_init(&ZS_MIGRATION(page)->lru);
 	zs_stat_dec(class, fullness == ZS_ALMOST_EMPTY ?
 			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
 }
@@ -742,19 +743,18 @@ static void remove_zspage(struct page *page, struct size_class *class,
 static enum fullness_group fix_fullness_group(struct size_class *class,
 						struct page *page)
 {
-	int class_idx;
 	enum fullness_group currfg, newfg;
 
 	BUG_ON(!is_first_page(page));
 
-	get_zspage_mapping(page, &class_idx, &currfg);
+	currfg = ZS_META(page)->fullness;
 	newfg = get_fullness_group(class, page);
 	if (newfg == currfg)
 		goto out;
 
 	remove_zspage(page, class, currfg);
 	insert_zspage(page, class, newfg);
-	set_zspage_mapping(page, class_idx, newfg);
+	ZS_META(page)->fullness = newfg;
 
 out:
 	return newfg;
@@ -817,8 +817,14 @@ static struct page *get_next_page(struct page *page)
 		next = NULL;
 	else if (is_first_page(page))
 		next = (struct page *)page_private(page);
-	else
-		next = list_entry(page->lru.next, struct page, lru);
+	else {
+		struct zs_migration *m;
+
+		m = (struct zs_migration *)
+		    list_entry(ZS_MIGRATION(page)->lru.next,
+			       struct zs_migration, lru);
+		next = m->page;
+	}
 
 	return next;
 }
@@ -908,13 +914,15 @@ static void reset_page(struct page *page)
 	clear_bit(PG_private, &page->flags);
 	clear_bit(PG_private_2, &page->flags);
 	set_page_private(page, 0);
+	free_migration(page->freelist);
 	page->freelist = NULL;
 	page_mapcount_reset(page);
 }
 
 static void free_zspage(struct page *first_page)
 {
-	struct page *nextp, *tmp, *head_extra;
+	struct zs_migration *tmp, *nextm;
+	struct page *nextp, *head_extra;
 
 	BUG_ON(!is_first_page(first_page));
 	BUG_ON(get_inuse_obj(first_page));
@@ -928,8 +936,10 @@ static void free_zspage(struct page *first_page)
 	if (!head_extra)
 		return;
 
-	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
-		list_del(&nextp->lru);
+	list_for_each_entry_safe(nextm, tmp, &ZS_MIGRATION(head_extra)->lru,
+				 lru) {
+		nextp = nextm->page;
+		list_del(&ZS_MIGRATION(nextp)->lru);
 		reset_page(nextp);
 		__free_page(nextp);
 	}
@@ -951,15 +961,14 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 		void *vaddr;
 
 		/*
-		 * page->index stores offset of first object starting
-		 * in the page.
+		 * ZS_MIGRATION(page)->index stores offset of first object
+		 * starting in the page.
 		 */
 		if (page != first_page)
-			page->index = off;
+			ZS_MIGRATION(page)->index = off;
 
 		vaddr = kmap_atomic(page);
 		link = (struct link_free *)vaddr + off / sizeof(*link);
-
 		while ((off += class->size) < PAGE_SIZE) {
 			link->next = (obj_idx++ << OBJ_ALLOCATED_TAG);
 			link += class->size / sizeof(*link);
@@ -994,13 +1003,13 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	/*
 	 * Allocate individual pages and link them together as:
 	 * 1. first page->private = first sub-page
-	 * 2. all sub-pages are linked together using page->lru
+	 * 2. all sub-pages are linked together using ZS_MIGRATION(page)->lru
 	 * 3. each sub-page is linked to the first page using page->first_page
 	 *
 	 * For each size class, First/Head pages are linked together using
-	 * page->lru. Also, we set PG_private to identify the first page
-	 * (i.e. no other sub-page has this flag set) and PG_private_2 to
-	 * identify the last page.
+	 * ZS_MIGRATION(page)->lru. Also, we set PG_private to identify the
+	 * first page (i.e. no other sub-page has this flag set) and
+	 * PG_private_2 to identify the last page.
 	 */
 	error = -ENOMEM;
 	for (i = 0; i < class->pages_per_zspage; i++) {
@@ -1009,8 +1018,17 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 		page = alloc_page(flags);
 		if (!page)
 			goto cleanup;
+		page->freelist = alloc_migration(flags);
+		if (!page->freelist) {
+			__free_page(page);
+			goto cleanup;
+		}
 
 		INIT_LIST_HEAD(&page->lru);
+		INIT_LIST_HEAD(&ZS_MIGRATION(page)->lru);
+		ZS_MIGRATION(page)->index = 0;
+		ZS_MIGRATION(page)->page = page;
+		ZS_MIGRATION(page)->class = class;
 		if (i == 0) {	/* first page */
 			SetPagePrivate(page);
 			set_page_private(page, 0);
@@ -1022,7 +1040,8 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 		if (i >= 1)
 			page->first_page = first_page;
 		if (i >= 2)
-			list_add(&page->lru, &prev_page->lru);
+			list_add(&ZS_MIGRATION(page)->lru,
+				 &ZS_MIGRATION(prev_page)->lru);
 		if (i == class->pages_per_zspage - 1)	/* last page */
 			SetPagePrivate2(page);
 		prev_page = page;
@@ -1292,7 +1311,6 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	struct page *obj_page, *first_page;
 	unsigned long obj, obj_idx, obj_ofs;
 
-	unsigned int class_idx;
 	enum fullness_group fg;
 	struct size_class *class;
 	struct mapping_area *area;
@@ -1315,9 +1333,10 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	obj_to_obj_idx(obj, &obj_page, &obj_idx);
 
 	first_page = get_first_page(obj_page);
-	get_zspage_mapping(first_page, &class_idx, &fg);
 
-	class = pool->size_class[class_idx];
+	fg = ZS_META(first_page)->fullness;
+	class = ZS_MIGRATION(first_page)->class;
+
 	obj_ofs = (class->size * obj_idx) % PAGE_SIZE;
 
 	area = &get_cpu_var(zs_map_area);
@@ -1348,7 +1367,6 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	struct page *obj_page, *first_page;
 	unsigned long obj, obj_idx, obj_ofs;
 
-	unsigned int class_idx;
 	enum fullness_group fg;
 	struct size_class *class;
 	struct mapping_area *area;
@@ -1359,8 +1377,8 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 
 	obj_to_obj_idx(obj, &obj_page, &obj_idx);
 	first_page = get_first_page(obj_page);
-	get_zspage_mapping(first_page, &class_idx, &fg);
-	class = pool->size_class[class_idx];
+	fg = ZS_META(first_page)->fullness;
+	class = ZS_MIGRATION(first_page)->class;
 	obj_ofs = (class->size * obj_idx) % PAGE_SIZE;
 
 	area = this_cpu_ptr(&zs_map_area);
@@ -1450,7 +1468,8 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 			return 0;
 		}
 
-		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
+		ZS_META(first_page)->fullness = ZS_EMPTY;
+		ZS_MIGRATION(first_page)->class = class;
 		atomic_long_add(class->pages_per_zspage,
 					&pool->pages_allocated);
 
@@ -1501,7 +1520,6 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 {
 	struct page *first_page, *obj_page;
 	unsigned long obj, obj_idx;
-	int class_idx;
 	struct size_class *class;
 	enum fullness_group fullness;
 
@@ -1513,8 +1531,8 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 
 	obj_to_obj_idx(obj, &obj_page, &obj_idx);
 	first_page = get_first_page(obj_page);
-	get_zspage_mapping(first_page, &class_idx, &fullness);
-	class = pool->size_class[class_idx];
+	fullness = ZS_META(first_page)->fullness;
+	class = ZS_MIGRATION(first_page)->class;
 
 	spin_lock(&class->lock);
 	obj_free(pool, class, obj);
@@ -1611,7 +1629,7 @@ static unsigned long find_alloced_obj(struct page *page, int index,
 	void *addr = kmap_atomic(page);
 
 	if (!is_first_page(page))
-		offset = page->index;
+		offset = ZS_MIGRATION(page)->index;
 	offset += class->size * index;
 
 	while (offset < PAGE_SIZE) {
@@ -1719,7 +1737,8 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 
 	fullness = get_fullness_group(class, first_page);
 	insert_zspage(first_page, class, fullness);
-	set_zspage_mapping(first_page, class->index, fullness);
+	ZS_META(first_page)->fullness = fullness;
+	ZS_MIGRATION(first_page)->class = class;
 
 	if (fullness == ZS_EMPTY) {
 		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
@@ -2041,7 +2060,7 @@ static int __init zs_init(void)
 		goto notifier_fail;
 
 	BUILD_BUG_ON(sizeof(unsigned long) * 8 < (FREE_OBJ_IDX_BITS + \
-		CLASS_IDX_BITS + FULLNESS_BITS + INUSE_BITS + ETC_BITS));
+		FULLNESS_BITS + INUSE_BITS + ETC_BITS));
 
 	init_zs_size_classes();
 
@@ -2054,6 +2073,15 @@ static int __init zs_init(void)
 		pr_err("zs stat initialization failed\n");
 		goto stat_fail;
 	}
+
+	zs_migration_cachep = kmem_cache_create("zs_migration",
+						sizeof(struct zs_migration),
+						0, 0, NULL);
+	if (!zs_migration_cachep) {
+		pr_err("zs migration initialization failed\n");
+		goto stat_fail;
+	}
+
 	return 0;
 
 stat_fail:
@@ -2068,6 +2096,8 @@ notifier_fail:
 
 static void __exit zs_exit(void)
 {
+	kmem_cache_destroy(zs_migration_cachep);
+
 #ifdef CONFIG_ZPOOL
 	zpool_unregister_driver(&zs_zpool_driver);
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

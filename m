Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 353C16B0255
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 03:12:38 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so20706339pac.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 00:12:37 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id xj2si11837856pbc.48.2015.08.10.00.12.33
        for <linux-mm@kvack.org>;
        Mon, 10 Aug 2015 00:12:35 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC zsmalloc 2/4] zsmalloc: squeeze inuse into page->mapping
Date: Mon, 10 Aug 2015 16:12:21 +0900
Message-Id: <1439190743-13933-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1439190743-13933-1-git-send-email-minchan@kernel.org>
References: <1439190743-13933-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: gioh.kim@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Currently, we store class:fullness into page->mapping.
The number of class we can support is 255 and fullness is 4 so
10bit is enough to represent them.
IOW, we have room (sizeof(void *) * 8 - 10) in mapping.

Meanwhile, the bits we need to store in-use objects in zspage
is just 11bit like below.

For example, 64K page system, class_size 32, in this case
class->pages_per_zspage is 1 so max_objects is 2048.

So, we could squeeze inuse object count to page->mapping.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 104 +++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 71 insertions(+), 33 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 491491a..75fefba 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -35,7 +35,7 @@
  *		metadata.
  *	page->lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
- *	page->mapping: class index and fullness group of the zspage
+ *	page->mapping: override by struct zs_meta
  *
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
@@ -132,6 +132,14 @@
 /* each chunk includes extra space to keep handle */
 #define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
 
+#define CLASS_IDX_BITS	8
+#define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
+#define FULLNESS_BITS	2
+#define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
+#define INUSE_BITS	11
+#define INUSE_MASK	((1 << INUSE_BITS) - 1)
+#define ETC_BITS	((sizeof(unsigned long) * 8) - CLASS_IDX_BITS \
+				- FULLNESS_BITS - INUSE_BITS)
 /*
  * On systems with 4K page size, this gives 255 size classes! There is a
  * trader-off here:
@@ -145,16 +153,15 @@
  *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
  *  (reason above)
  */
-#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> 8)
+#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> CLASS_IDX_BITS)
 
 /*
  * We do not maintain any list for completely empty or full pages
+ * Don't reorder.
  */
 enum fullness_group {
-	ZS_ALMOST_FULL,
+	ZS_ALMOST_FULL = 0,
 	ZS_ALMOST_EMPTY,
-	_ZS_NR_FULLNESS_GROUPS,
-
 	ZS_EMPTY,
 	ZS_FULL
 };
@@ -198,7 +205,7 @@ static const int fullness_threshold_frac = 4;
 
 struct size_class {
 	spinlock_t lock;
-	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
+	struct page *fullness_list[ZS_EMPTY];
 	/*
 	 * Size of objects stored in this class. Must be multiple
 	 * of ZS_ALIGN.
@@ -259,13 +266,16 @@ struct zs_pool {
 };
 
 /*
- * A zspage's class index and fullness group
- * are encoded in its (first)page->mapping
+ * In this implementation, a zspage's class index, fullness group,
+ * inuse object count are encoded in its (first)page->mapping
+ * sizeof(struct zs_meta) should be equal to sizeof(unsigned long).
  */
-#define CLASS_IDX_BITS	28
-#define FULLNESS_BITS	4
-#define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
-#define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
+struct zs_meta {
+	unsigned long class_idx:CLASS_IDX_BITS;
+	unsigned long fullness:FULLNESS_BITS;
+	unsigned long inuse:INUSE_BITS;
+	unsigned long etc:ETC_BITS;
+};
 
 struct mapping_area {
 #ifdef CONFIG_PGTABLE_MAPPING
@@ -403,26 +413,51 @@ static int is_last_page(struct page *page)
 	return PagePrivate2(page);
 }
 
+static int get_inuse_obj(struct page *page)
+{
+	struct zs_meta *m;
+
+	BUG_ON(!is_first_page(page));
+
+	m = (struct zs_meta *)&page->mapping;
+
+	return m->inuse;
+}
+
+static void set_inuse_obj(struct page *page, int inc)
+{
+	struct zs_meta *m;
+
+	BUG_ON(!is_first_page(page));
+
+	m = (struct zs_meta *)&page->mapping;
+	m->inuse += inc;
+}
+
 static void get_zspage_mapping(struct page *page, unsigned int *class_idx,
 				enum fullness_group *fullness)
 {
-	unsigned long m;
+	struct zs_meta *m;
 	BUG_ON(!is_first_page(page));
 
-	m = (unsigned long)page->mapping;
-	*fullness = m & FULLNESS_MASK;
-	*class_idx = (m >> FULLNESS_BITS) & CLASS_IDX_MASK;
+	m = (struct zs_meta *)&page->mapping;
+	*fullness = m->fullness;
+	*class_idx = m->class_idx;
 }
 
 static void set_zspage_mapping(struct page *page, unsigned int class_idx,
 				enum fullness_group fullness)
 {
-	unsigned long m;
+	struct zs_meta *m;
+
 	BUG_ON(!is_first_page(page));
 
-	m = ((class_idx & CLASS_IDX_MASK) << FULLNESS_BITS) |
-			(fullness & FULLNESS_MASK);
-	page->mapping = (struct address_space *)m;
+	BUG_ON(class_idx >= (1 << CLASS_IDX_BITS));
+	BUG_ON(fullness >= (1 << FULLNESS_BITS));
+
+	m = (struct zs_meta *)&page->mapping;
+	m->fullness = fullness;
+	m->class_idx = class_idx;
 }
 
 /*
@@ -612,7 +647,7 @@ static enum fullness_group get_fullness_group(struct size_class *class,
 	enum fullness_group fg;
 	BUG_ON(!is_first_page(page));
 
-	inuse = page->inuse;
+	inuse = get_inuse_obj(page);
 	max_objects = class->max_objects;
 
 	if (inuse == 0)
@@ -640,7 +675,7 @@ static void insert_zspage(struct page *page, struct size_class *class,
 
 	BUG_ON(!is_first_page(page));
 
-	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
+	if (fullness >= ZS_EMPTY)
 		return;
 
 	zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
@@ -654,10 +689,10 @@ static void insert_zspage(struct page *page, struct size_class *class,
 
 	/*
 	 * We want to see more ZS_FULL pages and less almost
-	 * empty/full. Put pages with higher ->inuse first.
+	 * empty/full. Put pages with higher inuse first.
 	 */
 	list_add_tail(&page->lru, &(*head)->lru);
-	if (page->inuse >= (*head)->inuse)
+	if (get_inuse_obj(page) >= get_inuse_obj(*head))
 		*head = page;
 }
 
@@ -672,7 +707,7 @@ static void remove_zspage(struct page *page, struct size_class *class,
 
 	BUG_ON(!is_first_page(page));
 
-	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
+	if (fullness >= ZS_EMPTY)
 		return;
 
 	head = &class->fullness_list[fullness];
@@ -874,7 +909,7 @@ static void free_zspage(struct page *first_page)
 	struct page *nextp, *tmp, *head_extra;
 
 	BUG_ON(!is_first_page(first_page));
-	BUG_ON(first_page->inuse);
+	BUG_ON(get_inuse_obj(first_page));
 
 	head_extra = (struct page *)page_private(first_page);
 
@@ -969,7 +1004,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 			SetPagePrivate(page);
 			set_page_private(page, 0);
 			first_page = page;
-			first_page->inuse = 0;
+			set_inuse_obj(page, 0);
 		}
 		if (i == 1)
 			set_page_private(first_page, (unsigned long)page);
@@ -1001,7 +1036,7 @@ static struct page *find_get_zspage(struct size_class *class)
 	int i;
 	struct page *page;
 
-	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
+	for (i = 0; i < ZS_EMPTY; i++) {
 		page = class->fullness_list[i];
 		if (page)
 			break;
@@ -1218,7 +1253,7 @@ static bool zspage_full(struct size_class *class, struct page *page)
 {
 	BUG_ON(!is_first_page(page));
 
-	return page->inuse == class->max_objects;
+	return get_inuse_obj(page) == class->max_objects;
 }
 
 unsigned long zs_get_total_pages(struct zs_pool *pool)
@@ -1355,7 +1390,7 @@ static unsigned long obj_malloc(struct page *first_page,
 		/* record handle in first_page->private */
 		set_page_private(first_page, handle);
 	kunmap_atomic(vaddr);
-	first_page->inuse++;
+	set_inuse_obj(first_page, 1);
 	zs_stat_inc(class, OBJ_USED, 1);
 
 	return obj;
@@ -1446,7 +1481,7 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
 		set_page_private(first_page, 0);
 	kunmap_atomic(vaddr);
 	first_page->freelist = (void *)obj;
-	first_page->inuse--;
+	set_inuse_obj(first_page, -1);
 	zs_stat_dec(class, OBJ_USED, 1);
 }
 
@@ -1643,7 +1678,7 @@ static struct page *isolate_target_page(struct size_class *class)
 	int i;
 	struct page *page;
 
-	for (i = 0; i < _ZS_NR_FULLNESS_GROUPS; i++) {
+	for (i = 0; i < ZS_EMPTY; i++) {
 		page = class->fullness_list[i];
 		if (page) {
 			remove_zspage(page, class, i);
@@ -1970,7 +2005,7 @@ void zs_destroy_pool(struct zs_pool *pool)
 		if (class->index != i)
 			continue;
 
-		for (fg = 0; fg < _ZS_NR_FULLNESS_GROUPS; fg++) {
+		for (fg = 0; fg < ZS_EMPTY; fg++) {
 			if (class->fullness_list[fg]) {
 				pr_info("Freeing non-empty class with size %db, fullness group %d\n",
 					class->size, fg);
@@ -1993,6 +2028,9 @@ static int __init zs_init(void)
 	if (ret)
 		goto notifier_fail;
 
+	BUILD_BUG_ON(sizeof(unsigned long) * 8 < (CLASS_IDX_BITS + \
+			FULLNESS_BITS + INUSE_BITS + ETC_BITS));
+
 	init_zs_size_classes();
 
 #ifdef CONFIG_ZPOOL
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D22716B0262
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:10:49 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id n5so34821525pfn.2
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:10:49 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u4si4364150par.185.2016.03.30.00.10.38
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 00:10:38 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 06/16] zsmalloc: squeeze inuse into page->mapping
Date: Wed, 30 Mar 2016 16:12:05 +0900
Message-Id: <1459321935-3655-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1459321935-3655-1-git-send-email-minchan@kernel.org>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

Currently, we store class:fullness into page->mapping.
The number of class we can support is 255 and fullness is 4 so
(8 + 2 = 10bit) is enough to represent them.
Meanwhile, the bits we need to store in-use objects in zspage
is that 11bit is enough.

For example, If we assume that 64K PAGE_SIZE, class_size 32
which is worst case, class->pages_per_zspage become 1 so
the number of objects in zspage is 2048 so 11bit is enough.
The next class is 32 + 256(i.e., ZS_SIZE_CLASS_DELTA).
With worst case that ZS_MAX_PAGES_PER_ZSPAGE, 64K * 4 /
(32 + 256) = 910 so 11bit is still enough.

So, we could squeeze inuse object count to page->mapping.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 103 ++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 71 insertions(+), 32 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 8649d0243e6c..4dd72a803568 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -34,8 +34,7 @@
  *		metadata.
  *	page->lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
- *	page->mapping: class index and fullness group of the zspage
- *	page->inuse: the number of objects that are used in this zspage
+ *	page->mapping: override by struct zs_meta
  *
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
@@ -132,6 +131,13 @@
 /* each chunk includes extra space to keep handle */
 #define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
 
+#define CLASS_BITS	8
+#define CLASS_MASK	((1 << CLASS_BITS) - 1)
+#define FULLNESS_BITS	2
+#define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
+#define INUSE_BITS	11
+#define INUSE_MASK	((1 << INUSE_BITS) - 1)
+
 /*
  * On systems with 4K page size, this gives 255 size classes! There is a
  * trader-off here:
@@ -145,7 +151,7 @@
  *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
  *  (reason above)
  */
-#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> 8)
+#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> CLASS_BITS)
 
 /*
  * We do not maintain any list for completely empty or full pages
@@ -155,7 +161,7 @@ enum fullness_group {
 	ZS_ALMOST_EMPTY,
 	_ZS_NR_FULLNESS_GROUPS,
 
-	ZS_EMPTY,
+	ZS_EMPTY = _ZS_NR_FULLNESS_GROUPS,
 	ZS_FULL
 };
 
@@ -263,14 +269,11 @@ struct zs_pool {
 #endif
 };
 
-/*
- * A zspage's class index and fullness group
- * are encoded in its (first)page->mapping
- */
-#define CLASS_IDX_BITS	28
-#define FULLNESS_BITS	4
-#define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
-#define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
+struct zs_meta {
+	unsigned long class:CLASS_BITS;
+	unsigned long fullness:FULLNESS_BITS;
+	unsigned long inuse:INUSE_BITS;
+};
 
 struct mapping_area {
 #ifdef CONFIG_PGTABLE_MAPPING
@@ -412,28 +415,61 @@ static int is_last_page(struct page *page)
 	return PagePrivate2(page);
 }
 
+static int get_zspage_inuse(struct page *first_page)
+{
+	struct zs_meta *m;
+
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+
+	m = (struct zs_meta *)&first_page->mapping;
+
+	return m->inuse;
+}
+
+static void set_zspage_inuse(struct page *first_page, int val)
+{
+	struct zs_meta *m;
+
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+
+	m = (struct zs_meta *)&first_page->mapping;
+	m->inuse = val;
+}
+
+static void mod_zspage_inuse(struct page *first_page, int val)
+{
+	struct zs_meta *m;
+
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+
+	m = (struct zs_meta *)&first_page->mapping;
+	m->inuse += val;
+}
+
 static void get_zspage_mapping(struct page *first_page,
 				unsigned int *class_idx,
 				enum fullness_group *fullness)
 {
-	unsigned long m;
+	struct zs_meta *m;
+
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	m = (unsigned long)first_page->mapping;
-	*fullness = m & FULLNESS_MASK;
-	*class_idx = (m >> FULLNESS_BITS) & CLASS_IDX_MASK;
+	m = (struct zs_meta *)&first_page->mapping;
+	*fullness = m->fullness;
+	*class_idx = m->class;
 }
 
 static void set_zspage_mapping(struct page *first_page,
 				unsigned int class_idx,
 				enum fullness_group fullness)
 {
-	unsigned long m;
+	struct zs_meta *m;
+
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	m = ((class_idx & CLASS_IDX_MASK) << FULLNESS_BITS) |
-			(fullness & FULLNESS_MASK);
-	first_page->mapping = (struct address_space *)m;
+	m = (struct zs_meta *)&first_page->mapping;
+	m->fullness = fullness;
+	m->class = class_idx;
 }
 
 /*
@@ -632,9 +668,7 @@ static enum fullness_group get_fullness_group(struct size_class *class,
 	int inuse, objs_per_zspage;
 	enum fullness_group fg;
 
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
-
-	inuse = first_page->inuse;
+	inuse = get_zspage_inuse(first_page);
 	objs_per_zspage = class->objs_per_zspage;
 
 	if (inuse == 0)
@@ -677,10 +711,10 @@ static void insert_zspage(struct size_class *class,
 
 	/*
 	 * We want to see more ZS_FULL pages and less almost
-	 * empty/full. Put pages with higher ->inuse first.
+	 * empty/full. Put pages with higher inuse first.
 	 */
 	list_add_tail(&first_page->lru, &(*head)->lru);
-	if (first_page->inuse >= (*head)->inuse)
+	if (get_zspage_inuse(first_page) >= get_zspage_inuse(*head))
 		*head = first_page;
 }
 
@@ -896,7 +930,7 @@ static void free_zspage(struct page *first_page)
 	struct page *nextp, *tmp, *head_extra;
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
-	VM_BUG_ON_PAGE(first_page->inuse, first_page);
+	VM_BUG_ON_PAGE(get_zspage_inuse(first_page), first_page);
 
 	head_extra = (struct page *)page_private(first_page);
 
@@ -992,7 +1026,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 			SetPagePrivate(page);
 			set_page_private(page, 0);
 			first_page = page;
-			first_page->inuse = 0;
+			set_zspage_inuse(page, 0);
 		}
 		if (i == 1)
 			set_page_private(first_page, (unsigned long)page);
@@ -1237,9 +1271,7 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 
 static bool zspage_full(struct size_class *class, struct page *first_page)
 {
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
-
-	return first_page->inuse == class->objs_per_zspage;
+	return get_zspage_inuse(first_page) == class->objs_per_zspage;
 }
 
 unsigned long zs_get_total_pages(struct zs_pool *pool)
@@ -1372,7 +1404,7 @@ static unsigned long obj_malloc(struct size_class *class,
 		/* record handle in first_page->private */
 		set_page_private(first_page, handle);
 	kunmap_atomic(vaddr);
-	first_page->inuse++;
+	mod_zspage_inuse(first_page, 1);
 	zs_stat_inc(class, OBJ_USED, 1);
 
 	return obj;
@@ -1457,7 +1489,7 @@ static void obj_free(struct size_class *class, unsigned long obj)
 		set_page_private(first_page, 0);
 	kunmap_atomic(vaddr);
 	first_page->freelist = (void *)obj;
-	first_page->inuse--;
+	mod_zspage_inuse(first_page, -1);
 	zs_stat_dec(class, OBJ_USED, 1);
 }
 
@@ -2002,6 +2034,13 @@ static int __init zs_init(void)
 	if (ret)
 		goto notifier_fail;
 
+	/*
+	 * A zspage's class index, fullness group, inuse object count are
+	 * encoded in its (first)page->mapping so sizeof(struct zs_meta)
+	 * should be less than sizeof(page->mapping(i.e., unsigned long)).
+	 */
+	BUILD_BUG_ON(sizeof(struct zs_meta) > sizeof(unsigned long));
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

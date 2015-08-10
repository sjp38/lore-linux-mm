Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E08336B0254
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 03:12:35 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so97474603pac.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 00:12:35 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id sn7si31674143pbc.78.2015.08.10.00.12.32
        for <linux-mm@kvack.org>;
        Mon, 10 Aug 2015 00:12:34 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC zsmalloc 1/4] zsmalloc: keep max_object in size_class
Date: Mon, 10 Aug 2015 16:12:20 +0900
Message-Id: <1439190743-13933-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1439190743-13933-1-git-send-email-minchan@kernel.org>
References: <1439190743-13933-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: gioh.kim@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Every zspage in a size_class has same max_objects so we could
move it to a size_class.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f135b1b..491491a 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -33,8 +33,6 @@
  *	page->freelist: points to the first free object in zspage.
  *		Free objects are linked together using in-place
  *		metadata.
- *	page->objects: maximum number of objects we can store in this
- *		zspage (class->zspage_order * PAGE_SIZE / class->size)
  *	page->lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
  *	page->mapping: class index and fullness group of the zspage
@@ -206,6 +204,7 @@ struct size_class {
 	 * of ZS_ALIGN.
 	 */
 	int size;
+	int max_objects;
 	unsigned int index;
 
 	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
@@ -606,14 +605,15 @@ static inline void zs_pool_stat_destroy(struct zs_pool *pool)
  * the pool (not yet implemented). This function returns fullness
  * status of the given page.
  */
-static enum fullness_group get_fullness_group(struct page *page)
+static enum fullness_group get_fullness_group(struct size_class *class,
+						struct page *page)
 {
 	int inuse, max_objects;
 	enum fullness_group fg;
 	BUG_ON(!is_first_page(page));
 
 	inuse = page->inuse;
-	max_objects = page->objects;
+	max_objects = class->max_objects;
 
 	if (inuse == 0)
 		fg = ZS_EMPTY;
@@ -706,7 +706,7 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
 	BUG_ON(!is_first_page(page));
 
 	get_zspage_mapping(page, &class_idx, &currfg);
-	newfg = get_fullness_group(page);
+	newfg = get_fullness_group(class, page);
 	if (newfg == currfg)
 		goto out;
 
@@ -985,9 +985,6 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	init_zspage(first_page, class);
 
 	first_page->freelist = location_to_obj(first_page, 0);
-	/* Maximum number of objects we can store in this zspage */
-	first_page->objects = class->pages_per_zspage * PAGE_SIZE / class->size;
-
 	error = 0; /* Success */
 
 cleanup:
@@ -1217,11 +1214,11 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 	return true;
 }
 
-static bool zspage_full(struct page *page)
+static bool zspage_full(struct size_class *class, struct page *page)
 {
 	BUG_ON(!is_first_page(page));
 
-	return page->inuse == page->objects;
+	return page->inuse == class->max_objects;
 }
 
 unsigned long zs_get_total_pages(struct zs_pool *pool)
@@ -1619,7 +1616,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		}
 
 		/* Stop if there is no more space */
-		if (zspage_full(d_page)) {
+		if (zspage_full(class, d_page)) {
 			unpin_tag(handle);
 			ret = -ENOMEM;
 			break;
@@ -1673,7 +1670,7 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 
 	BUG_ON(!is_first_page(first_page));
 
-	fullness = get_fullness_group(first_page);
+	fullness = get_fullness_group(class, first_page);
 	insert_zspage(first_page, class, fullness);
 	set_zspage_mapping(first_page, class->index, fullness);
 
@@ -1927,6 +1924,7 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
 		class->size = size;
 		class->index = i;
 		class->pages_per_zspage = pages_per_zspage;
+		class->max_objects = class->pages_per_zspage * PAGE_SIZE / class->size;
 		if (pages_per_zspage == 1 &&
 			get_maxobj_per_zspage(size, pages_per_zspage) == 1)
 			class->huge = true;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8088D828E2
	for <linux-mm@kvack.org>; Fri, 20 May 2016 10:24:12 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u185so196185488oie.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 07:24:12 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id pg8si5342644igc.84.2016.05.20.07.24.10
        for <linux-mm@kvack.org>;
        Fri, 20 May 2016 07:24:11 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6 04/12] zsmalloc: keep max_object in size_class
Date: Fri, 20 May 2016 23:23:37 +0900
Message-Id: <1463754225-31311-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1463754225-31311-1-git-send-email-minchan@kernel.org>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Every zspage in a size_class has same number of max objects so
we could move it to a size_class.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 32 +++++++++++++++-----------------
 1 file changed, 15 insertions(+), 17 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 72698db958e7..73a1eb4ffddf 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -32,8 +32,6 @@
  *	page->freelist: points to the first free object in zspage.
  *		Free objects are linked together using in-place
  *		metadata.
- *	page->objects: maximum number of objects we can store in this
- *		zspage (class->zspage_order * PAGE_SIZE / class->size)
  *	page->lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
  *	page->mapping: class index and fullness group of the zspage
@@ -211,6 +209,7 @@ struct size_class {
 	 * of ZS_ALIGN.
 	 */
 	int size;
+	int objs_per_zspage;
 	unsigned int index;
 
 	struct zs_size_stat stats;
@@ -627,21 +626,22 @@ static inline void zs_pool_stat_destroy(struct zs_pool *pool)
  * the pool (not yet implemented). This function returns fullness
  * status of the given page.
  */
-static enum fullness_group get_fullness_group(struct page *first_page)
+static enum fullness_group get_fullness_group(struct size_class *class,
+						struct page *first_page)
 {
-	int inuse, max_objects;
+	int inuse, objs_per_zspage;
 	enum fullness_group fg;
 
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
 	inuse = first_page->inuse;
-	max_objects = first_page->objects;
+	objs_per_zspage = class->objs_per_zspage;
 
 	if (inuse == 0)
 		fg = ZS_EMPTY;
-	else if (inuse == max_objects)
+	else if (inuse == objs_per_zspage)
 		fg = ZS_FULL;
-	else if (inuse <= 3 * max_objects / fullness_threshold_frac)
+	else if (inuse <= 3 * objs_per_zspage / fullness_threshold_frac)
 		fg = ZS_ALMOST_EMPTY;
 	else
 		fg = ZS_ALMOST_FULL;
@@ -728,7 +728,7 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
 	enum fullness_group currfg, newfg;
 
 	get_zspage_mapping(first_page, &class_idx, &currfg);
-	newfg = get_fullness_group(first_page);
+	newfg = get_fullness_group(class, first_page);
 	if (newfg == currfg)
 		goto out;
 
@@ -1008,9 +1008,6 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	init_zspage(class, first_page);
 
 	first_page->freelist = location_to_obj(first_page, 0);
-	/* Maximum number of objects we can store in this zspage */
-	first_page->objects = class->pages_per_zspage * PAGE_SIZE / class->size;
-
 	error = 0; /* Success */
 
 cleanup:
@@ -1238,11 +1235,11 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 	return true;
 }
 
-static bool zspage_full(struct page *first_page)
+static bool zspage_full(struct size_class *class, struct page *first_page)
 {
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 
-	return first_page->inuse == first_page->objects;
+	return first_page->inuse == class->objs_per_zspage;
 }
 
 unsigned long zs_get_total_pages(struct zs_pool *pool)
@@ -1628,7 +1625,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		}
 
 		/* Stop if there is no more space */
-		if (zspage_full(d_page)) {
+		if (zspage_full(class, d_page)) {
 			unpin_tag(handle);
 			ret = -ENOMEM;
 			break;
@@ -1687,7 +1684,7 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 {
 	enum fullness_group fullness;
 
-	fullness = get_fullness_group(first_page);
+	fullness = get_fullness_group(class, first_page);
 	insert_zspage(class, fullness, first_page);
 	set_zspage_mapping(first_page, class->index, fullness);
 
@@ -1939,8 +1936,9 @@ struct zs_pool *zs_create_pool(const char *name)
 		class->size = size;
 		class->index = i;
 		class->pages_per_zspage = pages_per_zspage;
-		if (pages_per_zspage == 1 &&
-			get_maxobj_per_zspage(size, pages_per_zspage) == 1)
+		class->objs_per_zspage = class->pages_per_zspage *
+						PAGE_SIZE / class->size;
+		if (pages_per_zspage == 1 && class->objs_per_zspage == 1)
 			class->huge = true;
 		spin_lock_init(&class->lock);
 		pool->size_class[i] = class;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

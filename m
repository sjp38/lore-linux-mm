Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 281586B0260
	for <linux-mm@kvack.org>; Tue, 31 May 2016 19:20:54 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s73so1975591pfs.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 16:20:54 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id y72si20422160pff.29.2016.05.31.16.20.49
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 16:20:50 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v7 04/12] zsmalloc: keep max_object in size_class
Date: Wed,  1 Jun 2016 08:21:13 +0900
Message-Id: <1464736881-24886-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1464736881-24886-1-git-send-email-minchan@kernel.org>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
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
index b6d4f258cb53..79295c73dc9f 100644
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
@@ -213,6 +211,7 @@ struct size_class {
 	 * of ZS_ALIGN.
 	 */
 	int size;
+	int objs_per_zspage;
 	unsigned int index;
 
 	struct zs_size_stat stats;
@@ -631,21 +630,22 @@ static inline void zs_pool_stat_destroy(struct zs_pool *pool)
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
@@ -732,7 +732,7 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
 	enum fullness_group currfg, newfg;
 
 	get_zspage_mapping(first_page, &class_idx, &currfg);
-	newfg = get_fullness_group(first_page);
+	newfg = get_fullness_group(class, first_page);
 	if (newfg == currfg)
 		goto out;
 
@@ -1012,9 +1012,6 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	init_zspage(class, first_page);
 
 	first_page->freelist = location_to_obj(first_page, 0);
-	/* Maximum number of objects we can store in this zspage */
-	first_page->objects = class->pages_per_zspage * PAGE_SIZE / class->size;
-
 	error = 0; /* Success */
 
 cleanup:
@@ -1242,11 +1239,11 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
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
@@ -1632,7 +1629,7 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		}
 
 		/* Stop if there is no more space */
-		if (zspage_full(d_page)) {
+		if (zspage_full(class, d_page)) {
 			unpin_tag(handle);
 			ret = -ENOMEM;
 			break;
@@ -1691,7 +1688,7 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 {
 	enum fullness_group fullness;
 
-	fullness = get_fullness_group(first_page);
+	fullness = get_fullness_group(class, first_page);
 	insert_zspage(class, fullness, first_page);
 	set_zspage_mapping(first_page, class->index, fullness);
 
@@ -1943,8 +1940,9 @@ struct zs_pool *zs_create_pool(const char *name)
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

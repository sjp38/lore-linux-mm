Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1D101828DF
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:18:28 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id x3so35024534pfb.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:18:28 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id gj3si4319160pac.243.2016.03.30.00.10.42
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 00:10:43 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 15/16] zsmalloc: migrate tail pages in zspage
Date: Wed, 30 Mar 2016 16:12:14 +0900
Message-Id: <1459321935-3655-16-git-send-email-minchan@kernel.org>
In-Reply-To: <1459321935-3655-1-git-send-email-minchan@kernel.org>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

This patch enables tail page migration of zspage.

In this point, I tested zsmalloc regression with micro-benchmark
which does zs_malloc/map/unmap/zs_free for all size class
in every CPU(my system is 12) during 20 sec.

It shows 1% regression which is really small when we consider
the benefit of this feature and realworkload overhead(i.e.,
most overhead comes from compression).

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 129 +++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 114 insertions(+), 15 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index a41cf3ef2077..e24f4a160892 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -551,6 +551,19 @@ static void set_zspage_mapping(struct page *first_page,
 	m->class = class_idx;
 }
 
+static bool check_isolated_page(struct page *first_page)
+{
+	struct page *cursor;
+
+	for (cursor = first_page; cursor != NULL; cursor =
+					get_next_page(cursor)) {
+		if (PageIsolated(cursor))
+			return true;
+	}
+
+	return false;
+}
+
 /*
  * zsmalloc divides the pool into various size classes where each
  * class maintains a list of zspages where each zspage is divided
@@ -1052,6 +1065,44 @@ void lock_zspage(struct page *first_page)
 	} while ((cursor = get_next_page(cursor)) != NULL);
 }
 
+int trylock_zspage(struct page *first_page, struct page *locked_page)
+{
+	struct page *cursor, *fail;
+
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+
+	for (cursor = first_page; cursor != NULL; cursor =
+			get_next_page(cursor)) {
+		if (cursor != locked_page) {
+			if (!trylock_page(cursor)) {
+				fail = cursor;
+				goto unlock;
+			}
+		}
+	}
+
+	return 1;
+unlock:
+	for (cursor = first_page; cursor != fail; cursor =
+			get_next_page(cursor)) {
+		if (cursor != locked_page)
+			unlock_page(cursor);
+	}
+
+	return 0;
+}
+
+void unlock_zspage(struct page *first_page, struct page *locked_page)
+{
+	struct page *cursor = first_page;
+
+	for (; cursor != NULL; cursor = get_next_page(cursor)) {
+		VM_BUG_ON_PAGE(!PageLocked(cursor), cursor);
+		if (cursor != locked_page)
+			unlock_page(cursor);
+	}
+}
+
 static void free_zspage(struct zs_pool *pool, struct page *first_page)
 {
 	struct page *nextp, *tmp;
@@ -1090,15 +1141,16 @@ static void init_zspage(struct size_class *class, struct page *first_page,
 	first_page->freelist = NULL;
 	INIT_LIST_HEAD(&first_page->lru);
 	set_zspage_inuse(first_page, 0);
-	BUG_ON(!trylock_page(first_page));
-	__SetPageMovable(first_page, mapping);
-	unlock_page(first_page);
 
 	while (page) {
 		struct page *next_page;
 		struct link_free *link;
 		void *vaddr;
 
+		BUG_ON(!trylock_page(page));
+		__SetPageMovable(page, mapping);
+		unlock_page(page);
+
 		vaddr = kmap_atomic(page);
 		link = (struct link_free *)vaddr + off / sizeof(*link);
 
@@ -1848,6 +1900,7 @@ static enum fullness_group putback_zspage(struct size_class *class,
 
 	VM_BUG_ON_PAGE(!list_empty(&first_page->lru), first_page);
 	VM_BUG_ON_PAGE(ZsPageIsolate(first_page), first_page);
+	VM_BUG_ON_PAGE(check_isolated_page(first_page), first_page);
 
 	fullness = get_fullness_group(class, first_page);
 	insert_zspage(class, fullness, first_page);
@@ -1954,6 +2007,12 @@ static struct page *isolate_source_page(struct size_class *class)
 		if (!page)
 			continue;
 
+		/* To prevent race between object and page migration */
+		if (!trylock_zspage(page, NULL)) {
+			page = NULL;
+			continue;
+		}
+
 		remove_zspage(class, i, page);
 
 		inuse = get_zspage_inuse(page);
@@ -1962,6 +2021,7 @@ static struct page *isolate_source_page(struct size_class *class)
 		if (inuse != freezed) {
 			unfreeze_zspage(class, page, freezed);
 			putback_zspage(class, page);
+			unlock_zspage(page, NULL);
 			page = NULL;
 			continue;
 		}
@@ -1993,6 +2053,12 @@ static struct page *isolate_target_page(struct size_class *class)
 		if (!page)
 			continue;
 
+		/* To prevent race between object and page migration */
+		if (!trylock_zspage(page, NULL)) {
+			page = NULL;
+			continue;
+		}
+
 		remove_zspage(class, i, page);
 
 		inuse = get_zspage_inuse(page);
@@ -2001,6 +2067,7 @@ static struct page *isolate_target_page(struct size_class *class)
 		if (inuse != freezed) {
 			unfreeze_zspage(class, page, freezed);
 			putback_zspage(class, page);
+			unlock_zspage(page, NULL);
 			page = NULL;
 			continue;
 		}
@@ -2074,11 +2141,13 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 			putback_zspage(class, dst_page);
 			unfreeze_zspage(class, dst_page,
 				class->objs_per_zspage);
+			unlock_zspage(dst_page, NULL);
 			spin_unlock(&class->lock);
 			dst_page = NULL;
 		}
 
 		if (zspage_empty(class, src_page)) {
+			unlock_zspage(src_page, NULL);
 			free_zspage(pool, src_page);
 			spin_lock(&class->lock);
 			zs_stat_dec(class, OBJ_ALLOCATED,
@@ -2101,12 +2170,14 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 		putback_zspage(class, src_page);
 		unfreeze_zspage(class, src_page,
 				class->objs_per_zspage);
+		unlock_zspage(src_page, NULL);
 	}
 
 	if (dst_page) {
 		putback_zspage(class, dst_page);
 		unfreeze_zspage(class, dst_page,
 				class->objs_per_zspage);
+		unlock_zspage(dst_page, NULL);
 	}
 
 	spin_unlock(&class->lock);
@@ -2209,10 +2280,11 @@ bool zs_page_isolate(struct page *page, isolate_mode_t mode)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageIsolated(page), page);
 	/*
-	 * In this implementation, it allows only first page migration.
+	 * first_page will not be destroyed by PG_lock of @page but it could
+	 * be migrated out. For prohibiting it, zs_page_migrate calls
+	 * trylock_zspage so it closes the race.
 	 */
-	VM_BUG_ON_PAGE(!is_first_page(page), page);
-	first_page = page;
+	first_page = get_first_page(page);
 
 	/*
 	 * Without class lock, fullness is meaningless while constant
@@ -2226,9 +2298,18 @@ bool zs_page_isolate(struct page *page, isolate_mode_t mode)
 	if (!spin_trylock(&class->lock))
 		return false;
 
+	if (check_isolated_page(first_page))
+		goto skip_isolate;
+
+	/*
+	 * If this is first time isolation for zspage, isolate zspage from
+	 * size_class to prevent further allocations from the zspage.
+	 */
 	get_zspage_mapping(first_page, &class_idx, &fullness);
 	remove_zspage(class, fullness, first_page);
 	SetZsPageIsolate(first_page);
+
+skip_isolate:
 	SetPageIsolated(page);
 	spin_unlock(&class->lock);
 
@@ -2251,7 +2332,7 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	VM_BUG_ON_PAGE(!PageMovable(page), page);
 	VM_BUG_ON_PAGE(!PageIsolated(page), page);
 
-	first_page = page;
+	first_page = get_first_page(page);
 	get_zspage_mapping(first_page, &class_idx, &fullness);
 	pool = page->mapping->private_data;
 	class = pool->size_class[class_idx];
@@ -2266,6 +2347,13 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	if (get_zspage_inuse(first_page) == 0)
 		goto out_class_unlock;
 
+	/*
+	 * It prevents first_page migration during tail page opeartion for
+	 * get_first_page's stability.
+	 */
+	if (!trylock_zspage(first_page, page))
+		goto out_class_unlock;
+
 	freezed = freeze_zspage(class, first_page);
 	if (freezed != get_zspage_inuse(first_page))
 		goto out_unfreeze;
@@ -2304,21 +2392,26 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
 	kunmap_atomic(addr);
 
 	replace_sub_page(class, first_page, newpage, page);
-	first_page = newpage;
+	first_page = get_first_page(newpage);
 	get_page(newpage);
 	VM_BUG_ON_PAGE(get_fullness_group(class, first_page) ==
 			ZS_EMPTY, first_page);
-	ClearZsPageIsolate(first_page);
-	putback_zspage(class, first_page);
+	if (!check_isolated_page(first_page)) {
+		INIT_LIST_HEAD(&first_page->lru);
+		ClearZsPageIsolate(first_page);
+		putback_zspage(class, first_page);
+	}
+
 
 	/* Migration complete. Free old page */
 	ClearPageIsolated(page);
 	reset_page(page);
 	put_page(page);
 	ret = MIGRATEPAGE_SUCCESS;
-
+	page = newpage;
 out_unfreeze:
 	unfreeze_zspage(class, first_page, freezed);
+	unlock_zspage(first_page, page);
 out_class_unlock:
 	spin_unlock(&class->lock);
 
@@ -2336,7 +2429,7 @@ void zs_page_putback(struct page *page)
 	VM_BUG_ON_PAGE(!PageMovable(page), page);
 	VM_BUG_ON_PAGE(!PageIsolated(page), page);
 
-	first_page = page;
+	first_page = get_first_page(page);
 	get_zspage_mapping(first_page, &class_idx, &fullness);
 	pool = page->mapping->private_data;
 	class = pool->size_class[class_idx];
@@ -2346,11 +2439,17 @@ void zs_page_putback(struct page *page)
 	 * in zs_free will wait the page lock of @page without
 	 * destroying of zspage.
 	 */
-	INIT_LIST_HEAD(&first_page->lru);
 	spin_lock(&class->lock);
 	ClearPageIsolated(page);
-	ClearZsPageIsolate(first_page);
-	putback_zspage(class, first_page);
+	/*
+	 * putback zspage to right list if this is last isolated page
+	 * putback in the zspage.
+	 */
+	if (!check_isolated_page(first_page)) {
+		INIT_LIST_HEAD(&first_page->lru);
+		ClearZsPageIsolate(first_page);
+		putback_zspage(class, first_page);
+	}
 	spin_unlock(&class->lock);
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

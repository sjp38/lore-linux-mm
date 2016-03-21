Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 951AC6B0253
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 02:30:09 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id x3so253244836pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 23:30:09 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id co4si14755676pad.101.2016.03.20.23.30.06
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 23:30:06 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 02/18] zsmalloc: use first_page rather than page
Date: Mon, 21 Mar 2016 15:30:51 +0900
Message-Id: <1458541867-27380-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1458541867-27380-1-git-send-email-minchan@kernel.org>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

This patch cleans up function parameter "struct page".
Many functions of zsmalloc expects that page paramter is "first_page"
so use "first_page" rather than "page" for code readability.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 62 ++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 32 insertions(+), 30 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e72efb109fde..b09a80d398c9 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -413,26 +413,28 @@ static int is_last_page(struct page *page)
 	return PagePrivate2(page);
 }
 
-static void get_zspage_mapping(struct page *page, unsigned int *class_idx,
+static void get_zspage_mapping(struct page *first_page,
+				unsigned int *class_idx,
 				enum fullness_group *fullness)
 {
 	unsigned long m;
-	BUG_ON(!is_first_page(page));
+	BUG_ON(!is_first_page(first_page));
 
-	m = (unsigned long)page->mapping;
+	m = (unsigned long)first_page->mapping;
 	*fullness = m & FULLNESS_MASK;
 	*class_idx = (m >> FULLNESS_BITS) & CLASS_IDX_MASK;
 }
 
-static void set_zspage_mapping(struct page *page, unsigned int class_idx,
+static void set_zspage_mapping(struct page *first_page,
+				unsigned int class_idx,
 				enum fullness_group fullness)
 {
 	unsigned long m;
-	BUG_ON(!is_first_page(page));
+	BUG_ON(!is_first_page(first_page));
 
 	m = ((class_idx & CLASS_IDX_MASK) << FULLNESS_BITS) |
 			(fullness & FULLNESS_MASK);
-	page->mapping = (struct address_space *)m;
+	first_page->mapping = (struct address_space *)m;
 }
 
 /*
@@ -625,14 +627,14 @@ static inline void zs_pool_stat_destroy(struct zs_pool *pool)
  * the pool (not yet implemented). This function returns fullness
  * status of the given page.
  */
-static enum fullness_group get_fullness_group(struct page *page)
+static enum fullness_group get_fullness_group(struct page *first_page)
 {
 	int inuse, max_objects;
 	enum fullness_group fg;
-	BUG_ON(!is_first_page(page));
+	BUG_ON(!is_first_page(first_page));
 
-	inuse = page->inuse;
-	max_objects = page->objects;
+	inuse = first_page->inuse;
+	max_objects = first_page->objects;
 
 	if (inuse == 0)
 		fg = ZS_EMPTY;
@@ -652,12 +654,12 @@ static enum fullness_group get_fullness_group(struct page *page)
  * have. This functions inserts the given zspage into the freelist
  * identified by <class, fullness_group>.
  */
-static void insert_zspage(struct page *page, struct size_class *class,
+static void insert_zspage(struct page *first_page, struct size_class *class,
 				enum fullness_group fullness)
 {
 	struct page **head;
 
-	BUG_ON(!is_first_page(page));
+	BUG_ON(!is_first_page(first_page));
 
 	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
 		return;
@@ -667,7 +669,7 @@ static void insert_zspage(struct page *page, struct size_class *class,
 
 	head = &class->fullness_list[fullness];
 	if (!*head) {
-		*head = page;
+		*head = first_page;
 		return;
 	}
 
@@ -675,21 +677,21 @@ static void insert_zspage(struct page *page, struct size_class *class,
 	 * We want to see more ZS_FULL pages and less almost
 	 * empty/full. Put pages with higher ->inuse first.
 	 */
-	list_add_tail(&page->lru, &(*head)->lru);
-	if (page->inuse >= (*head)->inuse)
-		*head = page;
+	list_add_tail(&first_page->lru, &(*head)->lru);
+	if (first_page->inuse >= (*head)->inuse)
+		*head = first_page;
 }
 
 /*
  * This function removes the given zspage from the freelist identified
  * by <class, fullness_group>.
  */
-static void remove_zspage(struct page *page, struct size_class *class,
+static void remove_zspage(struct page *first_page, struct size_class *class,
 				enum fullness_group fullness)
 {
 	struct page **head;
 
-	BUG_ON(!is_first_page(page));
+	BUG_ON(!is_first_page(first_page));
 
 	if (fullness >= _ZS_NR_FULLNESS_GROUPS)
 		return;
@@ -698,11 +700,11 @@ static void remove_zspage(struct page *page, struct size_class *class,
 	BUG_ON(!*head);
 	if (list_empty(&(*head)->lru))
 		*head = NULL;
-	else if (*head == page)
+	else if (*head == first_page)
 		*head = (struct page *)list_entry((*head)->lru.next,
 					struct page, lru);
 
-	list_del_init(&page->lru);
+	list_del_init(&first_page->lru);
 	zs_stat_dec(class, fullness == ZS_ALMOST_EMPTY ?
 			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
 }
@@ -717,21 +719,21 @@ static void remove_zspage(struct page *page, struct size_class *class,
  * fullness group.
  */
 static enum fullness_group fix_fullness_group(struct size_class *class,
-						struct page *page)
+						struct page *first_page)
 {
 	int class_idx;
 	enum fullness_group currfg, newfg;
 
-	BUG_ON(!is_first_page(page));
+	BUG_ON(!is_first_page(first_page));
 
-	get_zspage_mapping(page, &class_idx, &currfg);
-	newfg = get_fullness_group(page);
+	get_zspage_mapping(first_page, &class_idx, &currfg);
+	newfg = get_fullness_group(first_page);
 	if (newfg == currfg)
 		goto out;
 
-	remove_zspage(page, class, currfg);
-	insert_zspage(page, class, newfg);
-	set_zspage_mapping(page, class_idx, newfg);
+	remove_zspage(first_page, class, currfg);
+	insert_zspage(first_page, class, newfg);
+	set_zspage_mapping(first_page, class_idx, newfg);
 
 out:
 	return newfg;
@@ -1234,11 +1236,11 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
 	return true;
 }
 
-static bool zspage_full(struct page *page)
+static bool zspage_full(struct page *first_page)
 {
-	BUG_ON(!is_first_page(page));
+	BUG_ON(!is_first_page(first_page));
 
-	return page->inuse == page->objects;
+	return first_page->inuse == first_page->objects;
 }
 
 unsigned long zs_get_total_pages(struct zs_pool *pool)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4869D6B0268
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:10:58 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id n5so34824318pfn.2
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:10:58 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id tr1si4382288pab.135.2016.03.30.00.10.40
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 00:10:40 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 10/16] zsmalloc: factor page chain functionality out
Date: Wed, 30 Mar 2016 16:12:09 +0900
Message-Id: <1459321935-3655-11-git-send-email-minchan@kernel.org>
In-Reply-To: <1459321935-3655-1-git-send-email-minchan@kernel.org>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

For migration, we need to create sub-page chain of zspage
dynamically so this patch factors it out from alloc_zspage.

As a minor refactoring, it makes OBJ_ALLOCATED_TAG assign
more clear in obj_malloc(it could be another patch but it's
trivial so I want to put together in this patch).

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 80 ++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 46 insertions(+), 34 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index d4d33a819832..14bcc741eead 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -981,7 +981,9 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 	unsigned long off = 0;
 	struct page *page = first_page;
 
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+	first_page->freelist = NULL;
+	INIT_LIST_HEAD(&first_page->lru);
+	set_zspage_inuse(first_page, 0);
 
 	while (page) {
 		struct page *next_page;
@@ -1026,13 +1028,44 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 	set_freeobj(first_page, 0);
 }
 
+static void create_page_chain(struct page *pages[], int nr_pages)
+{
+	int i;
+	struct page *page;
+	struct page *prev_page = NULL;
+	struct page *first_page = NULL;
+
+	for (i = 0; i < nr_pages; i++) {
+		page = pages[i];
+
+		INIT_LIST_HEAD(&page->lru);
+		if (i == 0) {
+			SetPagePrivate(page);
+			set_page_private(page, 0);
+			first_page = page;
+		}
+
+		if (i == 1)
+			set_page_private(first_page, (unsigned long)page);
+		if (i >= 1)
+			set_page_private(page, (unsigned long)first_page);
+		if (i >= 2)
+			list_add(&page->lru, &prev_page->lru);
+		if (i == nr_pages - 1)
+			SetPagePrivate2(page);
+
+		prev_page = page;
+	}
+}
+
 /*
  * Allocate a zspage for the given size class
  */
 static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 {
-	int i, error;
-	struct page *first_page = NULL, *uninitialized_var(prev_page);
+	int i;
+	struct page *first_page = NULL;
+	struct page *pages[ZS_MAX_PAGES_PER_ZSPAGE];
 
 	/*
 	 * Allocate individual pages and link them together as:
@@ -1045,43 +1078,23 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	 * (i.e. no other sub-page has this flag set) and PG_private_2 to
 	 * identify the last page.
 	 */
-	error = -ENOMEM;
 	for (i = 0; i < class->pages_per_zspage; i++) {
 		struct page *page;
 
 		page = alloc_page(flags);
-		if (!page)
-			goto cleanup;
-
-		INIT_LIST_HEAD(&page->lru);
-		if (i == 0) {	/* first page */
-			page->freelist = NULL;
-			SetPagePrivate(page);
-			set_page_private(page, 0);
-			first_page = page;
-			set_zspage_inuse(page, 0);
+		if (!page) {
+			while (--i >= 0)
+				__free_page(pages[i]);
+			return NULL;
 		}
-		if (i == 1)
-			set_page_private(first_page, (unsigned long)page);
-		if (i >= 1)
-			set_page_private(page, (unsigned long)first_page);
-		if (i >= 2)
-			list_add(&page->lru, &prev_page->lru);
-		if (i == class->pages_per_zspage - 1)	/* last page */
-			SetPagePrivate2(page);
-		prev_page = page;
+
+		pages[i] = page;
 	}
 
+	create_page_chain(pages, class->pages_per_zspage);
+	first_page = pages[0];
 	init_zspage(class, first_page);
 
-	error = 0; /* Success */
-
-cleanup:
-	if (unlikely(error) && first_page) {
-		free_zspage(first_page);
-		first_page = NULL;
-	}
-
 	return first_page;
 }
 
@@ -1421,7 +1434,6 @@ static unsigned long obj_malloc(struct size_class *class,
 	unsigned long m_offset;
 	void *vaddr;
 
-	handle |= OBJ_ALLOCATED_TAG;
 	obj = get_freeobj(first_page);
 	objidx_to_page_and_offset(class, first_page, obj,
 				&m_page, &m_offset);
@@ -1431,10 +1443,10 @@ static unsigned long obj_malloc(struct size_class *class,
 	set_freeobj(first_page, link->next >> OBJ_ALLOCATED_TAG);
 	if (!class->huge)
 		/* record handle in the header of allocated chunk */
-		link->handle = handle;
+		link->handle = handle | OBJ_ALLOCATED_TAG;
 	else
 		/* record handle in first_page->private */
-		set_page_private(first_page, handle);
+		set_page_private(first_page, handle | OBJ_ALLOCATED_TAG);
 	kunmap_atomic(vaddr);
 	mod_zspage_inuse(first_page, 1);
 	zs_stat_inc(class, OBJ_USED, 1);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

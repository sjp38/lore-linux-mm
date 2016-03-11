Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 84501828DF
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:37:18 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id z76so135587703iof.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 23:37:18 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m8si11933311pfi.253.2016.03.10.23.29.51
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 23:29:52 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 13/19] zsmalloc: factor page chain functionality out
Date: Fri, 11 Mar 2016 16:30:17 +0900
Message-Id: <1457681423-26664-14-git-send-email-minchan@kernel.org>
In-Reply-To: <1457681423-26664-1-git-send-email-minchan@kernel.org>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>, Minchan Kim <minchan@kernel.org>

For migration, we need to create sub-page chain of zspage
dynamically so this patch factors it out from alloc_zspage.

As a minor refactoring, it makes OBJ_ALLOCATED_TAG assign
more clear in obj_malloc(it could be another patch but it's
trivial so I want to put together in this patch).

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 78 ++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 45 insertions(+), 33 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index bfc6a048afac..f86f8aaeb902 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -977,7 +977,9 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 	unsigned long off = 0;
 	struct page *page = first_page;
 
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+	first_page->freelist = NULL;
+	INIT_LIST_HEAD(&first_page->lru);
+	set_zspage_inuse(first_page, 0);
 
 	while (page) {
 		struct page *next_page;
@@ -1022,13 +1024,44 @@ static void init_zspage(struct size_class *class, struct page *first_page)
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
+	int i;
 	struct page *first_page = NULL, *uninitialized_var(prev_page);
+	struct page *pages[ZS_MAX_PAGES_PER_ZSPAGE];
 
 	/*
 	 * Allocate individual pages and link them together as:
@@ -1041,43 +1074,23 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
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
 
@@ -1419,7 +1432,6 @@ static unsigned long obj_malloc(struct size_class *class,
 	unsigned long m_offset;
 	void *vaddr;
 
-	handle |= OBJ_ALLOCATED_TAG;
 	obj = get_freeobj(first_page);
 	objidx_to_page_and_ofs(class, first_page, obj,
 				&m_page, &m_offset);
@@ -1429,10 +1441,10 @@ static unsigned long obj_malloc(struct size_class *class,
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

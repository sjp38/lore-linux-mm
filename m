Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A61636B0266
	for <linux-mm@kvack.org>; Tue, 31 May 2016 19:21:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b124so1975606pfb.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 16:21:06 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s7si60562641pas.203.2016.05.31.16.20.56
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 16:20:56 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v7 07/12] zsmalloc: factor page chain functionality out
Date: Wed,  1 Jun 2016 08:21:16 +0900
Message-Id: <1464736881-24886-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1464736881-24886-1-git-send-email-minchan@kernel.org>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

For page migration, we need to create page chain of zspage dynamically
so this patch factors it out from alloc_zspage.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 59 +++++++++++++++++++++++++++++++++++------------------------
 1 file changed, 35 insertions(+), 24 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 5da80961ff3e..07485a2e5b96 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -960,7 +960,8 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 	unsigned long off = 0;
 	struct page *page = first_page;
 
-	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+	first_page->freelist = NULL;
+	set_zspage_inuse(first_page, 0);
 
 	while (page) {
 		struct page *next_page;
@@ -996,15 +997,16 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 		page = next_page;
 		off %= PAGE_SIZE;
 	}
+
+	set_freeobj(first_page, (unsigned long)location_to_obj(first_page, 0));
 }
 
-/*
- * Allocate a zspage for the given size class
- */
-static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
+static void create_page_chain(struct page *pages[], int nr_pages)
 {
-	int i, error;
-	struct page *first_page = NULL, *uninitialized_var(prev_page);
+	int i;
+	struct page *page;
+	struct page *prev_page = NULL;
+	struct page *first_page = NULL;
 
 	/*
 	 * Allocate individual pages and link them together as:
@@ -1017,20 +1019,14 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	 * (i.e. no other sub-page has this flag set) and PG_private_2 to
 	 * identify the last page.
 	 */
-	error = -ENOMEM;
-	for (i = 0; i < class->pages_per_zspage; i++) {
-		struct page *page;
-
-		page = alloc_page(flags);
-		if (!page)
-			goto cleanup;
+	for (i = 0; i < nr_pages; i++) {
+		page = pages[i];
 
 		INIT_LIST_HEAD(&page->lru);
-		if (i == 0) {	/* first page */
+		if (i == 0) {
 			SetPagePrivate(page);
 			set_page_private(page, 0);
 			first_page = page;
-			set_zspage_inuse(first_page, 0);
 		}
 		if (i == 1)
 			set_page_private(first_page, (unsigned long)page);
@@ -1038,22 +1034,37 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 			set_page_private(page, (unsigned long)first_page);
 		if (i >= 2)
 			list_add(&page->lru, &prev_page->lru);
-		if (i == class->pages_per_zspage - 1)	/* last page */
+		if (i == nr_pages - 1)
 			SetPagePrivate2(page);
 		prev_page = page;
 	}
+}
 
-	init_zspage(class, first_page);
+/*
+ * Allocate a zspage for the given size class
+ */
+static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
+{
+	int i;
+	struct page *first_page = NULL;
+	struct page *pages[ZS_MAX_PAGES_PER_ZSPAGE];
 
-	set_freeobj(first_page,	(unsigned long)location_to_obj(first_page, 0));
-	error = 0; /* Success */
+	for (i = 0; i < class->pages_per_zspage; i++) {
+		struct page *page;
 
-cleanup:
-	if (unlikely(error) && first_page) {
-		free_zspage(first_page);
-		first_page = NULL;
+		page = alloc_page(flags);
+		if (!page) {
+			while (--i >= 0)
+				__free_page(pages[i]);
+			return NULL;
+		}
+		pages[i] = page;
 	}
 
+	create_page_chain(pages, class->pages_per_zspage);
+	first_page = pages[0];
+	init_zspage(class, first_page);
+
 	return first_page;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 83CC86B0032
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 06:46:28 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so28633411pad.27
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 03:46:28 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id lo1si82993568pab.201.2015.01.05.03.46.26
        for <linux-mm@kvack.org>;
        Mon, 05 Jan 2015 03:46:27 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm/page_alloc.c: drop dead destroy_compound_page()
Date: Mon,  5 Jan 2015 13:46:22 +0200
Message-Id: <1420458382-161038-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The only caller is __free_one_page(). By the time we should have
page->flags to be cleared already:

 - for 0-order pages though PCP list:
	free_hot_cold_page()
		free_pages_prepare()
			free_pages_check()
				page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
		<put the page to PCP list>

	free_pcppages_bulk()
		page = <withdraw pages from PCP list>
		__free_one_page(page)

 - for non-0-order pages:
	__free_pages_ok()
		free_pages_prepare()
			free_pages_check()
				page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
		free_one_page()
			__free_one_page()

So there's no way PageCompound() will return true in __free_one_page().
Let's remove dead destroy_compound_page() and put assert for page->flags
there instead.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/page_alloc.c | 35 +----------------------------------
 1 file changed, 1 insertion(+), 34 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1bb65e6f48dd..5e75380dacab 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -381,36 +381,6 @@ void prep_compound_page(struct page *page, unsigned long order)
 	}
 }
 
-/* update __split_huge_page_refcount if you change this function */
-static int destroy_compound_page(struct page *page, unsigned long order)
-{
-	int i;
-	int nr_pages = 1 << order;
-	int bad = 0;
-
-	if (unlikely(compound_order(page) != order)) {
-		bad_page(page, "wrong compound order", 0);
-		bad++;
-	}
-
-	__ClearPageHead(page);
-
-	for (i = 1; i < nr_pages; i++) {
-		struct page *p = page + i;
-
-		if (unlikely(!PageTail(p))) {
-			bad_page(page, "PageTail not set", 0);
-			bad++;
-		} else if (unlikely(p->first_page != page)) {
-			bad_page(page, "first_page not consistent", 0);
-			bad++;
-		}
-		__ClearPageTail(p);
-	}
-
-	return bad;
-}
-
 static inline void prep_zero_page(struct page *page, unsigned int order,
 							gfp_t gfp_flags)
 {
@@ -613,10 +583,7 @@ static inline void __free_one_page(struct page *page,
 	int max_order = MAX_ORDER;
 
 	VM_BUG_ON(!zone_is_initialized(zone));
-
-	if (unlikely(PageCompound(page)))
-		if (unlikely(destroy_compound_page(page, order)))
-			return;
+	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
 
 	VM_BUG_ON(migratetype == -1);
 	if (is_migrate_isolate(migratetype)) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

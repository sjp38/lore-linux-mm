From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH] hugetlb: ensure we do not reference a surplus page after handing it to buddy
Date: Tue, 19 Feb 2008 18:28:08 -0000
Message-Id: <1203445688.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Adam Litke <agl@us.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

When we free a page via free_huge_page and we detect that we are in
surplus the page will be returned to the buddy.  After this we no longer
own the page.  However at the end free_huge_page we clear out our mapping
pointer from page private.  Even where the page is not a surplus we
free the page to the hugepage pool, drop the pool locks and then clear
page private.  In either case the page may have been reallocated.  BAD.

Make sure we clear out page private before we free the page.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/hugetlb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index cb1b3a7..89e6286 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -120,6 +120,7 @@ static void free_huge_page(struct page *page)
 	struct address_space *mapping;
 
 	mapping = (struct address_space *) page_private(page);
+	set_page_private(page, 0);
 	BUG_ON(page_count(page));
 	INIT_LIST_HEAD(&page->lru);
 
@@ -134,7 +135,6 @@ static void free_huge_page(struct page *page)
 	spin_unlock(&hugetlb_lock);
 	if (mapping)
 		hugetlb_put_quota(mapping, 1);
-	set_page_private(page, 0);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

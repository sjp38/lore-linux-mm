Message-Id: <20080423015429.834926000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
Date: Wed, 23 Apr 2008 11:53:04 +1000
From: npiggin@suse.de
Subject: [patch 02/18] hugetlb: factor out huge_new_page
Content-Disposition: inline; filename=hugetlb-factor-page-prep.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Needed to avoid code duplication in follow up patches.

This happens to fix a minor bug. When alloc_bootmem_node returns
a fallback node on a different node than passed the old code
would have put it into the free lists of the wrong node.
Now it would end up in the freelist of the correct node.

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/hugetlb.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -190,6 +190,17 @@ static int adjust_pool_surplus(int delta
 	return ret;
 }
 
+static void prep_new_huge_page(struct page *page)
+{
+	unsigned nid = pfn_to_nid(page_to_pfn(page));
+	set_compound_page_dtor(page, free_huge_page);
+	spin_lock(&hugetlb_lock);
+	nr_huge_pages++;
+	nr_huge_pages_node[nid]++;
+	spin_unlock(&hugetlb_lock);
+	put_page(page); /* free it into the hugepage allocator */
+}
+
 static struct page *alloc_fresh_huge_page_node(int nid)
 {
 	struct page *page;
@@ -197,14 +208,8 @@ static struct page *alloc_fresh_huge_pag
 	page = alloc_pages_node(nid,
 		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
 		HUGETLB_PAGE_ORDER);
-	if (page) {
-		set_compound_page_dtor(page, free_huge_page);
-		spin_lock(&hugetlb_lock);
-		nr_huge_pages++;
-		nr_huge_pages_node[nid]++;
-		spin_unlock(&hugetlb_lock);
-		put_page(page); /* free it into the hugepage allocator */
-	}
+	if (page)
+		prep_new_huge_page(page);
 
 	return page;
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

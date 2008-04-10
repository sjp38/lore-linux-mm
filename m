Message-Id: <20080410171101.288094000@nick.local0.net>
References: <20080410170232.015351000@nick.local0.net>
Date: Fri, 11 Apr 2008 03:02:41 +1000
From: npiggin@suse.de
Subject: [patch 09/17] hugetlb: factor out huge_new_page
Content-Disposition: inline; filename=hugetlb-factor-page-prep.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Needed to avoid code duplication in follow up patches.

This happens to fix a minor bug. When alloc_bootmem_node returns
a fallback node on a different node than passed the old code
would have put it into the free lists of the wrong node.
Now it would end up in the freelist of the correct node.

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: pj@sgi.com
Cc: andi@firstfloor.org
Cc: kniht@linux.vnet.ibm.com

---
 mm/hugetlb.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -205,6 +205,17 @@ static int adjust_pool_surplus(struct hs
 	return ret;
 }
 
+static void huge_new_page(struct hstate *h, struct page *page)
+{
+	unsigned nid = pfn_to_nid(page_to_pfn(page));
+	set_compound_page_dtor(page, free_huge_page);
+	spin_lock(&hugetlb_lock);
+	h->nr_huge_pages++;
+	h->nr_huge_pages_node[nid]++;
+	spin_unlock(&hugetlb_lock);
+	put_page(page); /* free it into the hugepage allocator */
+}
+
 static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
@@ -212,14 +223,8 @@ static struct page *alloc_fresh_huge_pag
 	page = alloc_pages_node(nid,
 		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
 			huge_page_order(h));
-	if (page) {
-		set_compound_page_dtor(page, free_huge_page);
-		spin_lock(&hugetlb_lock);
-		h->nr_huge_pages++;
-		h->nr_huge_pages_node[nid]++;
-		spin_unlock(&hugetlb_lock);
-		put_page(page); /* free it into the hugepage allocator */
-	}
+	if (page)
+		huge_new_page(h, page);
 
 	return page;
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-Id: <20080603100938.344971361@amd.local0.net>
References: <20080603095956.781009952@amd.local0.net>
Date: Tue, 03 Jun 2008 19:59:57 +1000
From: npiggin@suse.de
Subject: [patch 01/21] hugetlb: factor out prep_new_huge_page
Content-Disposition: inline; filename=hugetlb-factor-page-prep.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, Adam Litke <agl@us.ibm.com>, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

Needed to avoid code duplication in follow up patches.

Acked-by: Adam Litke <agl@us.ibm.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/hugetlb.c |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-06-03 19:52:53.000000000 +1000
+++ linux-2.6/mm/hugetlb.c	2008-06-03 19:52:57.000000000 +1000
@@ -331,6 +331,16 @@ static int adjust_pool_surplus(int delta
 	return ret;
 }
 
+static void prep_new_huge_page(struct page *page, int nid)
+{
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
@@ -344,12 +354,7 @@ static struct page *alloc_fresh_huge_pag
 			__free_pages(page, HUGETLB_PAGE_ORDER);
 			return NULL;
 		}
-		set_compound_page_dtor(page, free_huge_page);
-		spin_lock(&hugetlb_lock);
-		nr_huge_pages++;
-		nr_huge_pages_node[nid]++;
-		spin_unlock(&hugetlb_lock);
-		put_page(page); /* free it into the hugepage allocator */
+		prep_new_huge_page(page, nid);
 	}
 
 	return page;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

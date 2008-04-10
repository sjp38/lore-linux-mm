Message-Id: <20080410171100.963460000@nick.local0.net>
References: <20080410170232.015351000@nick.local0.net>
Date: Fri, 11 Apr 2008 03:02:38 +1000
From: npiggin@suse.de
Subject: [patch 06/17] hugetlb: abstract numa round robin selection
Content-Disposition: inline; filename=hugetlb-abstract-numa-rr.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Need this as a separate function for a future patch.

No behaviour change.

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: pj@sgi.com
Cc: andi@firstfloor.org
Cc: kniht@linux.vnet.ibm.com

---
 mm/hugetlb.c |   37 ++++++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 15 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -224,6 +224,27 @@ static struct page *alloc_fresh_huge_pag
 	return page;
 }
 
+/*
+ * Use a helper variable to find the next node and then
+ * copy it back to hugetlb_next_nid afterwards:
+ * otherwise there's a window in which a racer might
+ * pass invalid nid MAX_NUMNODES to alloc_pages_node.
+ * But we don't need to use a spin_lock here: it really
+ * doesn't matter if occasionally a racer chooses the
+ * same nid as we do.  Move nid forward in the mask even
+ * if we just successfully allocated a hugepage so that
+ * the next caller gets hugepages on the next node.
+ */
+static int hstate_next_node(struct hstate *h)
+{
+	int next_nid;
+	next_nid = next_node(h->hugetlb_next_nid, node_online_map);
+	if (next_nid == MAX_NUMNODES)
+		next_nid = first_node(node_online_map);
+	h->hugetlb_next_nid = next_nid;
+	return next_nid;
+}
+
 static int alloc_fresh_huge_page(struct hstate *h)
 {
 	struct page *page;
@@ -237,21 +258,7 @@ static int alloc_fresh_huge_page(struct 
 		page = alloc_fresh_huge_page_node(h, h->hugetlb_next_nid);
 		if (page)
 			ret = 1;
-		/*
-		 * Use a helper variable to find the next node and then
-		 * copy it back to hugetlb_next_nid afterwards:
-		 * otherwise there's a window in which a racer might
-		 * pass invalid nid MAX_NUMNODES to alloc_pages_node.
-		 * But we don't need to use a spin_lock here: it really
-		 * doesn't matter if occasionally a racer chooses the
-		 * same nid as we do.  Move nid forward in the mask even
-		 * if we just successfully allocated a hugepage so that
-		 * the next caller gets hugepages on the next node.
-		 */
-		next_nid = next_node(h->hugetlb_next_nid, node_online_map);
-		if (next_nid == MAX_NUMNODES)
-			next_nid = first_node(node_online_map);
-		h->hugetlb_next_nid = next_nid;
+		next_nid = hstate_next_node(h);
 	} while (!page && h->hugetlb_next_nid != start_nid);
 
 	return ret;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

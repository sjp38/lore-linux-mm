Message-Id: <20080423015431.027712000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
Date: Wed, 23 Apr 2008 11:53:15 +1000
From: npiggin@suse.de
Subject: [patch 13/18] hugetlb: support boot allocate different sizes
Content-Disposition: inline; filename=hugetlb-different-page-sizes.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/hugetlb.c |   24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -582,10 +582,13 @@ static void __init hugetlb_init_hstate(s
 {
 	unsigned long i;
 
-	for (i = 0; i < MAX_NUMNODES; ++i)
-		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
+	/* Don't reinitialize lists if they have been already init'ed */
+	if (!h->hugepage_freelists[0].next) {
+		for (i = 0; i < MAX_NUMNODES; ++i)
+			INIT_LIST_HEAD(&h->hugepage_freelists[i]);
 
-	h->hugetlb_next_nid = first_node(node_online_map);
+		h->hugetlb_next_nid = first_node(node_online_map);
+	}
 
 	for (i = 0; i < h->max_huge_pages; ++i) {
 		if (h->order >= MAX_ORDER) {
@@ -594,7 +597,7 @@ static void __init hugetlb_init_hstate(s
 		} else if (!alloc_fresh_huge_page(h))
 			break;
 	}
-	h->max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
+	h->max_huge_pages = i;
 }
 
 static void __init hugetlb_init_hstates(void)
@@ -602,7 +605,10 @@ static void __init hugetlb_init_hstates(
 	struct hstate *h;
 
 	for_each_hstate(h) {
-		hugetlb_init_hstate(h);
+		/* oversize hugepages were init'ed in early boot */
+		if (h->order < MAX_ORDER)
+			hugetlb_init_hstate(h);
+		max_huge_pages[h - hstates] = h->max_huge_pages;
 	}
 }
 
@@ -665,6 +671,14 @@ static int __init hugetlb_setup(char *s)
 	if (sscanf(s, "%lu", mhp) <= 0)
 		*mhp = 0;
 
+	/*
+	 * Global state is always initialized later in hugetlb_init.
+	 * But we need to allocate >= MAX_ORDER hstates here early to still
+	 * use the bootmem allocator.
+	 */
+	if (max_hstate > 0 && parsed_hstate->order >= MAX_ORDER)
+		hugetlb_init_hstate(parsed_hstate);
+
 	return 1;
 }
 __setup("hugepages=", hugetlb_setup);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

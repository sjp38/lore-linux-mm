Message-Id: <20080525143453.424711000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
Date: Mon, 26 May 2008 00:23:29 +1000
From: npiggin@suse.de
Subject: [patch 12/23] hugetlb: support boot allocate different sizes
Content-Disposition: inline; filename=hugetlb-different-page-sizes.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

---
 mm/hugetlb.c |   24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -609,10 +609,13 @@ static void __init hugetlb_init_one_hsta
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
@@ -621,7 +624,7 @@ static void __init hugetlb_init_one_hsta
 		} else if (!alloc_fresh_huge_page(h))
 			break;
 	}
-	h->max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
+	h->max_huge_pages = i;
 }
 
 static void __init hugetlb_init_hstates(void)
@@ -629,7 +632,10 @@ static void __init hugetlb_init_hstates(
 	struct hstate *h;
 
 	for_each_hstate(h) {
-		hugetlb_init_one_hstate(h);
+		/* oversize hugepages were init'ed in early boot */
+		if (h->order < MAX_ORDER)
+			hugetlb_init_one_hstate(h);
+		max_huge_pages[h - hstates] = h->max_huge_pages;
 	}
 }
 
@@ -692,6 +698,14 @@ static int __init hugetlb_setup(char *s)
 	if (sscanf(s, "%lu", mhp) <= 0)
 		*mhp = 0;
 
+	/*
+	 * Global state is always initialized later in hugetlb_init.
+	 * But we need to allocate >= MAX_ORDER hstates here early to still
+	 * use the bootmem allocator.
+	 */
+	if (max_hstate > 0 && parsed_hstate->order >= MAX_ORDER)
+		hugetlb_init_one_hstate(parsed_hstate);
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

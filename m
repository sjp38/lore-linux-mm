Message-Id: <20080603100939.467921820@amd.local0.net>
References: <20080603095956.781009952@amd.local0.net>
Date: Tue, 03 Jun 2008 20:00:06 +1000
From: npiggin@suse.de
Subject: [patch 10/21] hugetlb: support boot allocate different sizes
Content-Disposition: inline; filename=hugetlb-different-page-sizes.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, Adam Litke <agl@us.ibm.com>, Andrew Hastings <abh@cray.com>, kniht@us.ibm.com, andi@firstfloor.orgabh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

Make some infrastructure changes to allow boot allocation of different
hugepage page sizes.

- move all basic hstate initialisation into hugetlb_add_hstate
- create a new function hugetlb_hstate_alloc_pages() to do the
  actual initial page allocations. Call this function early in
  order to allocate giant pages from bootmem.
- Check for multiple hugepages= parameters

Acked-by: Adam Litke <agl@us.ibm.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Andrew Hastings <abh@cray.com>
Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/hugetlb.c |   24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-06-03 19:56:50.000000000 +1000
+++ linux-2.6/mm/hugetlb.c	2008-06-03 19:56:51.000000000 +1000
@@ -906,15 +906,10 @@ static void __init gather_bootmem_preall
 	}
 }
 
-static void __init hugetlb_init_one_hstate(struct hstate *h)
+static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 {
 	unsigned long i;
 
-	for (i = 0; i < MAX_NUMNODES; ++i)
-		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
-
-	h->hugetlb_next_nid = first_node(node_online_map);
-
 	for (i = 0; i < h->max_huge_pages; ++i) {
 		if (h->order >= MAX_ORDER) {
 			if (!alloc_bootmem_huge_page(h))
@@ -922,7 +917,7 @@ static void __init hugetlb_init_one_hsta
 		} else if (!alloc_fresh_huge_page(h))
 			break;
 	}
-	h->max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
+	h->max_huge_pages = i;
 }
 
 static void __init hugetlb_init_hstates(void)
@@ -930,7 +925,9 @@ static void __init hugetlb_init_hstates(
 	struct hstate *h;
 
 	for_each_hstate(h) {
-		hugetlb_init_one_hstate(h);
+		/* oversize hugepages were init'ed in early boot */
+		if (h->order < MAX_ORDER)
+			hugetlb_hstate_alloc_pages(h);
 	}
 }
 
@@ -1232,6 +1229,8 @@ module_exit(hugetlb_exit);
 void __init hugetlb_add_hstate(unsigned order)
 {
 	struct hstate *h;
+	unsigned long i;
+
 	if (size_to_hstate(PAGE_SIZE << order)) {
 		printk(KERN_WARNING "hugepagesz= specified twice, ignoring\n");
 		return;
@@ -1241,15 +1240,21 @@ void __init hugetlb_add_hstate(unsigned 
 	h = &hstates[max_hstate++];
 	h->order = order;
 	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
+	h->nr_huge_pages = 0;
+	h->free_huge_pages = 0;
+	for (i = 0; i < MAX_NUMNODES; ++i)
+		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
+	h->hugetlb_next_nid = first_node(node_online_map);
 	snprintf(h->name, HSTATE_NAME_LEN, "hugepages-%lukB",
 					huge_page_size(h)/1024);
-	hugetlb_init_one_hstate(h);
+
 	parsed_hstate = h;
 }
 
 static int __init hugetlb_setup(char *s)
 {
 	unsigned long *mhp;
+	static unsigned long *last_mhp;
 
 	/*
 	 * !max_hstate means we haven't parsed a hugepagesz= parameter yet,
@@ -1260,9 +1265,25 @@ static int __init hugetlb_setup(char *s)
 	else
 		mhp = &parsed_hstate->max_huge_pages;
 
+	if (mhp == last_mhp) {
+		printk(KERN_WARNING "hugepages= specified twice without "
+			"interleaving hugepagesz=, ignoring\n");
+		return 1;
+	}
+
 	if (sscanf(s, "%lu", mhp) <= 0)
 		*mhp = 0;
 
+	/*
+	 * Global state is always initialized later in hugetlb_init.
+	 * But we need to allocate >= MAX_ORDER hstates here early to still
+	 * use the bootmem allocator.
+	 */
+	if (max_hstate && parsed_hstate->order >= MAX_ORDER)
+		hugetlb_hstate_alloc_pages(parsed_hstate);
+
+	last_mhp = mhp;
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

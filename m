Message-Id: <20080410171101.613691000@nick.local0.net>
References: <20080410170232.015351000@nick.local0.net>
Date: Fri, 11 Apr 2008 03:02:44 +1000
From: npiggin@suse.de
Subject: [patch 12/17] hugetlb: support boot allocate different sizes
Content-Disposition: inline; filename=hugetlb-different-page-sizes.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: pj@sgi.com
Cc: andi@firstfloor.org
Cc: kniht@linux.vnet.ibm.com

---
 include/linux/hugetlb.h |    1 +
 mm/hugetlb.c            |   23 ++++++++++++++++++-----
 2 files changed, 19 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -578,19 +578,23 @@ static int __init hugetlb_init_hstate(st
 		h->mask = HPAGE_MASK;
 	}
 
-	for (i = 0; i < MAX_NUMNODES; ++i)
-		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
+	/* Don't reinitialize lists if they have been already init'ed */
+	if (!h->hugepage_freelists[0].next) {
+		for (i = 0; i < MAX_NUMNODES; ++i)
+			INIT_LIST_HEAD(&h->hugepage_freelists[i]);
 
-	h->hugetlb_next_nid = first_node(node_online_map);
+		h->hugetlb_next_nid = first_node(node_online_map);
+	}
 
-	for (i = 0; i < max_huge_pages[h - hstates]; ++i) {
+	while (h->parsed_hugepages < max_huge_pages[h - hstates]) {
 		if (h->order > MAX_ORDER) {
 			if (!alloc_bm_huge_page(h))
 				break;
 		} else if (!alloc_fresh_huge_page(h))
 			break;
+		h->parsed_hugepages++;
 	}
-	max_huge_pages[h - hstates] = h->free_huge_pages = h->nr_huge_pages = i;
+	max_huge_pages[h - hstates] = h->parsed_hugepages;
 
 	printk(KERN_INFO "Total HugeTLB memory allocated, %ld %dMB pages\n",
 			h->free_huge_pages,
@@ -625,6 +629,15 @@ static int __init hugetlb_setup(char *s)
 	unsigned long *mhp = &max_huge_pages[parsed_hstate - hstates];
 	if (sscanf(s, "%lu", mhp) <= 0)
 		*mhp = 0;
+	/*
+	 * Global state is always initialized later in hugetlb_init.
+	 * But we need to allocate > MAX_ORDER hstates here early to still
+	 * use the bootmem allocator.
+	 * If you add additional hstates <= MAX_ORDER you'll need
+	 * to fix that.
+	 */
+	if (parsed_hstate != &global_hstate)
+		hugetlb_init_hstate(parsed_hstate);
 	return 1;
 }
 __setup("hugepages=", hugetlb_setup);
Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h
+++ linux-2.6/include/linux/hugetlb.h
@@ -210,6 +210,7 @@ struct hstate {
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
+	unsigned long parsed_hugepages;
 };
 
 void __init huge_add_hstate(unsigned order);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Andi Kleen <andi@firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
In-Reply-To: <20080317258.659191058@firstfloor.org>
Subject: [PATCH] [13/18] Add support to allocate hugepages of different size with hugepages=...
Message-Id: <20080317015827.15E811B41E0@basil.firstfloor.org>
Date: Mon, 17 Mar 2008 02:58:27 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Signed-off-by: Andi Kleen <ak@suse.de>

---
 include/linux/hugetlb.h |    1 +
 mm/hugetlb.c            |   23 ++++++++++++++++++-----
 2 files changed, 19 insertions(+), 5 deletions(-)

Index: linux/mm/hugetlb.c
===================================================================
--- linux.orig/mm/hugetlb.c
+++ linux/mm/hugetlb.c
@@ -552,19 +552,23 @@ static int __init hugetlb_init_hstate(st
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
@@ -602,6 +606,15 @@ static int __init hugetlb_setup(char *s)
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
Index: linux/include/linux/hugetlb.h
===================================================================
--- linux.orig/include/linux/hugetlb.h
+++ linux/include/linux/hugetlb.h
@@ -212,6 +212,7 @@ struct hstate {
 	unsigned int nr_huge_pages_node[MAX_NUMNODES];
 	unsigned int free_huge_pages_node[MAX_NUMNODES];
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
+	unsigned long parsed_hugepages;
 };
 
 void __init huge_add_hstate(unsigned order);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-Id: <20080525143452.518017000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
Date: Mon, 26 May 2008 00:23:21 +1000
From: npiggin@suse.de
Subject: [patch 04/23] hugetlb: multiple hstates
Content-Disposition: inline; filename=hugetlb-multiple-hstates.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Add basic support for more than one hstate in hugetlbfs

- Convert hstates to an array
- Add a first default entry covering the standard huge page size
- Add functions for architectures to register new hstates
- Add basic iterators over hstates

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 include/linux/hugetlb.h |   16 +++++++
 mm/hugetlb.c            |   98 +++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 95 insertions(+), 19 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -27,7 +27,15 @@ unsigned long sysctl_overcommit_huge_pag
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
-struct hstate global_hstate;
+static int max_hstate = 0;
+struct hstate hstates[HUGE_MAX_HSTATE];
+
+/* for command line parsing */
+static struct hstate * __initdata parsed_hstate = NULL;
+static unsigned long __initdata default_hstate_max_huge_pages = 0;
+
+#define for_each_hstate(h) \
+	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)
 
 /*
  * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
@@ -132,13 +140,24 @@ static void update_and_free_page(struct 
 	__free_pages(page, huge_page_order(h));
 }
 
+struct hstate *size_to_hstate(unsigned long size)
+{
+	struct hstate *h;
+
+	for_each_hstate (h) {
+		if (huge_page_size(h) == size)
+			return h;
+	}
+	return NULL;
+}
+
 static void free_huge_page(struct page *page)
 {
 	/*
 	 * Can't pass hstate in here because it is called from the
 	 * compound page destructor.
 	 */
-	struct hstate *h = &global_hstate;
+	struct hstate *h = page_hstate(page);
 	int nid = page_to_nid(page);
 	struct address_space *mapping;
 
@@ -523,38 +542,80 @@ static struct page *alloc_huge_page(stru
 	return page;
 }
 
-static int __init hugetlb_init(void)
+static void __init hugetlb_init_one_hstate(struct hstate *h)
 {
 	unsigned long i;
-	struct hstate *h = &global_hstate;
-
-	if (HPAGE_SHIFT == 0)
-		return 0;
-
-	if (!h->order) {
-		h->order = HPAGE_SHIFT - PAGE_SHIFT;
-		h->mask = HPAGE_MASK;
-	}
 
 	for (i = 0; i < MAX_NUMNODES; ++i)
 		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
 
 	h->hugetlb_next_nid = first_node(node_online_map);
 
-	for (i = 0; i < max_huge_pages; ++i) {
+	for (i = 0; i < h->max_huge_pages; ++i) {
 		if (!alloc_fresh_huge_page(h))
 			break;
 	}
-	max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
-	printk("Total HugeTLB memory allocated, %ld\n", h->free_huge_pages);
+	h->max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
+}
+
+static void __init hugetlb_init_hstates(void)
+{
+	struct hstate *h;
+
+	for_each_hstate(h) {
+		hugetlb_init_one_hstate(h);
+	}
+}
+
+static void __init report_hugepages(void)
+{
+	struct hstate *h;
+
+	for_each_hstate(h) {
+		printk(KERN_INFO "Total HugeTLB memory allocated, %ld %dMB pages\n",
+				h->free_huge_pages,
+				1 << (h->order + PAGE_SHIFT - 20));
+	}
+}
+
+static int __init hugetlb_init(void)
+{
+	BUILD_BUG_ON(HPAGE_SHIFT == 0);
+
+	if (!size_to_hstate(HPAGE_SIZE)) {
+		hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
+		parsed_hstate->max_huge_pages = default_hstate_max_huge_pages;
+	}
+
+	hugetlb_init_hstates();
+
+	report_hugepages();
+
 	return 0;
 }
 module_init(hugetlb_init);
 
+/* Should be called on processing a hugepagesz=... option */
+void __init hugetlb_add_hstate(unsigned order)
+{
+	struct hstate *h;
+	if (size_to_hstate(PAGE_SIZE << order)) {
+		printk(KERN_WARNING "hugepagesz= specified twice, ignoring\n");
+		return;
+	}
+	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
+	BUG_ON(order == 0);
+	h = &hstates[max_hstate++];
+	h->order = order;
+	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
+	hugetlb_init_one_hstate(h);
+	parsed_hstate = h;
+}
+
 static int __init hugetlb_setup(char *s)
 {
-	if (sscanf(s, "%lu", &max_huge_pages) <= 0)
-		max_huge_pages = 0;
+	if (sscanf(s, "%lu", &default_hstate_max_huge_pages) <= 0)
+		default_hstate_max_huge_pages = 0;
 	return 1;
 }
 __setup("hugepages=", hugetlb_setup);
@@ -585,7 +646,7 @@ static void try_to_free_low(struct hstat
 			if (PageHighMem(page))
 				continue;
 			list_del(&page->lru);
-			update_and_free_page(page);
+			update_and_free_page(h, page);
 			h->free_huge_pages--;
 			h->free_huge_pages_node[page_to_nid(page)]--;
 		}
@@ -675,6 +736,7 @@ int hugetlb_sysctl_handler(struct ctl_ta
 {
 	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
 	max_huge_pages = set_max_huge_pages(max_huge_pages);
+	global_hstate.max_huge_pages = max_huge_pages;
 	return 0;
 }
 
Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h
+++ linux-2.6/include/linux/hugetlb.h
@@ -171,7 +171,16 @@ struct hstate {
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 };
 
-extern struct hstate global_hstate;
+void __init hugetlb_add_hstate(unsigned order);
+struct hstate *size_to_hstate(unsigned long size);
+
+#ifndef HUGE_MAX_HSTATE
+#define HUGE_MAX_HSTATE 1
+#endif
+
+extern struct hstate hstates[HUGE_MAX_HSTATE];
+
+#define global_hstate (hstates[0])
 
 static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
 {
@@ -213,6 +222,11 @@ static inline unsigned int blocks_per_hu
 	return huge_page_size(h) / 512;
 }
 
+static inline struct hstate *page_hstate(struct page *page)
+{
+	return size_to_hstate(PAGE_SIZE << compound_order(page));
+}
+
 #else
 struct hstate {};
 #define hstate_file(f) NULL

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

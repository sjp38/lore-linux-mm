Message-Id: <20080423015430.162027000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
Date: Wed, 23 Apr 2008 11:53:07 +1000
From: npiggin@suse.de
Subject: [patch 05/18] hugetlb: multiple hstates
Content-Disposition: inline; filename=hugetlb-multiple-hstates.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Add basic support for more than one hstate in hugetlbfs

- Convert hstates to an array
- Add a first default entry covering the standard huge page size
- Add functions for architectures to register new hstates
- Add basic iterators over hstates

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 include/linux/hugetlb.h |   11 ++++
 mm/hugetlb.c            |  112 +++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 97 insertions(+), 26 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -27,7 +27,17 @@ unsigned long sysctl_overcommit_huge_pag
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
-struct hstate global_hstate;
+static int max_hstate = 0;
+
+static unsigned long default_hstate_resv = 0;
+
+struct hstate hstates[HUGE_MAX_HSTATE];
+
+/* for command line parsing */
+struct hstate *parsed_hstate __initdata = NULL;
+
+#define for_each_hstate(h) \
+	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)
 
 /*
  * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
@@ -128,9 +138,19 @@ static void update_and_free_page(struct 
 	__free_pages(page, huge_page_order(h));
 }
 
+struct hstate *size_to_hstate(unsigned long size)
+{
+	struct hstate *h;
+	for_each_hstate (h) {
+		if (huge_page_size(h) == size)
+			return h;
+	}
+	return NULL;
+}
+
 static void free_huge_page(struct page *page)
 {
-	struct hstate *h = &global_hstate;
+	struct hstate *h = size_to_hstate(PAGE_SIZE << compound_order(page));
 	int nid = page_to_nid(page);
 	struct address_space *mapping;
 
@@ -495,38 +515,80 @@ static struct page *alloc_huge_page(stru
 	return page;
 }
 
-static int __init hugetlb_init(void)
+static void __init hugetlb_init_hstate(struct hstate *h)
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
+		hugetlb_init_hstate(h);
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
+		huge_add_hstate(HUGETLB_PAGE_ORDER);
+		parsed_hstate->max_huge_pages = default_hstate_resv;
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
+void __init huge_add_hstate(unsigned order)
+{
+	struct hstate *h;
+	if (size_to_hstate(PAGE_SIZE << order)) {
+		printk("hugepagesz= specified twice, ignoring\n");
+		return;
+	}
+	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
+	BUG_ON(order < HPAGE_SHIFT - PAGE_SHIFT);
+	h = &hstates[max_hstate++];
+	h->order = order;
+	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
+	hugetlb_init_hstate(h);
+	parsed_hstate = h;
+}
+
 static int __init hugetlb_setup(char *s)
 {
-	if (sscanf(s, "%lu", &max_huge_pages) <= 0)
-		max_huge_pages = 0;
+	if (sscanf(s, "%lu", &default_hstate_resv) <= 0)
+		default_hstate_resv = 0;
 	return 1;
 }
 __setup("hugepages=", hugetlb_setup);
@@ -544,28 +606,27 @@ static unsigned int cpuset_mems_nr(unsig
 
 #ifdef CONFIG_SYSCTL
 #ifdef CONFIG_HIGHMEM
-static void try_to_free_low(unsigned long count)
+static void try_to_free_low(struct hstate *h, unsigned long count)
 {
-	struct hstate *h = &global_hstate;
 	int i;
 
 	for (i = 0; i < MAX_NUMNODES; ++i) {
 		struct page *page, *next;
 		struct list_head *freel = &h->hugepage_freelists[i];
 		list_for_each_entry_safe(page, next, freel, lru) {
-			if (count >= nr_huge_pages)
+			if (count >= h->nr_huge_pages)
 				return;
 			if (PageHighMem(page))
 				continue;
 			list_del(&page->lru);
-			update_and_free_page(page);
+			update_and_free_page(h, page);
 			h->free_huge_pages--;
 			h->free_huge_pages_node[page_to_nid(page)]--;
 		}
 	}
 }
 #else
-static inline void try_to_free_low(unsigned long count)
+static inline void try_to_free_low(struct hstate *h, unsigned long count)
 {
 }
 #endif
@@ -625,7 +686,7 @@ static unsigned long set_max_huge_pages(
 	 */
 	min_count = h->resv_huge_pages + h->nr_huge_pages - h->free_huge_pages;
 	min_count = max(count, min_count);
-	try_to_free_low(min_count);
+	try_to_free_low(h, min_count);
 	while (min_count < persistent_huge_pages(h)) {
 		struct page *page = dequeue_huge_page(h);
 		if (!page)
@@ -648,6 +709,7 @@ int hugetlb_sysctl_handler(struct ctl_ta
 {
 	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
 	max_huge_pages = set_max_huge_pages(max_huge_pages);
+	global_hstate.max_huge_pages = max_huge_pages;
 	return 0;
 }
 
@@ -1296,7 +1358,7 @@ out:
 int hugetlb_reserve_pages(struct inode *inode, long from, long to)
 {
 	long ret, chg;
-	struct hstate *h = &global_hstate;
+	struct hstate *h = hstate_inode(inode);
 
 	chg = region_chg(&inode->i_mapping->private_list, from, to);
 	if (chg < 0)
@@ -1315,7 +1377,7 @@ int hugetlb_reserve_pages(struct inode *
 
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 {
-	struct hstate *h = &global_hstate;
+	struct hstate *h = hstate_inode(inode);
 	long chg = region_truncate(&inode->i_mapping->private_list, offset);
 
 	spin_lock(&inode->i_lock);
Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h
+++ linux-2.6/include/linux/hugetlb.h
@@ -215,7 +215,16 @@ struct hstate {
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 };
 
-extern struct hstate global_hstate;
+void __init huge_add_hstate(unsigned order);
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

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

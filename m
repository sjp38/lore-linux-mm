Message-Id: <20080410171100.533001000@nick.local0.net>
References: <20080410170232.015351000@nick.local0.net>
Date: Fri, 11 Apr 2008 03:02:34 +1000
From: npiggin@suse.de
Subject: [patch 02/17] hugetlb: multiple hstates
Content-Disposition: inline; filename=hugetlb-multiple-hstates.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Add basic support for more than one hstate in hugetlbfs

- Convert hstates to an array
- Add a first default entry covering the standard huge page size
- Add functions for architectures to register new hstates
- Add basic iterators over hstates

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: pj@sgi.com
Cc: andi@firstfloor.org
Cc: kniht@linux.vnet.ibm.com

---
 include/linux/hugetlb.h |   11 ++++++-
 mm/hugetlb.c            |   71 ++++++++++++++++++++++++++++++++++++------------
 2 files changed, 64 insertions(+), 18 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -27,7 +27,15 @@ unsigned long sysctl_overcommit_huge_pag
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
-struct hstate global_hstate;
+static int max_hstate = 1;
+
+struct hstate hstates[HUGE_MAX_HSTATE];
+
+/* for command line parsing */
+struct hstate *parsed_hstate __initdata = &global_hstate;
+
+#define for_each_hstate(h) \
+	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)
 
 /*
  * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
@@ -128,9 +136,19 @@ static void update_and_free_page(struct 
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
 
@@ -490,15 +508,11 @@ static struct page *alloc_huge_page(stru
 	return page;
 }
 
-static int __init hugetlb_init(void)
+static int __init hugetlb_init_hstate(struct hstate *h)
 {
 	unsigned long i;
-	struct hstate *h = &global_hstate;
 
-	if (HPAGE_SHIFT == 0)
-		return 0;
-
-	if (!h->order) {
+	if (h == &global_hstate && !h->order) {
 		h->order = HPAGE_SHIFT - PAGE_SHIFT;
 		h->mask = HPAGE_MASK;
 	}
@@ -513,11 +527,35 @@ static int __init hugetlb_init(void)
 			break;
 	}
 	max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
-	printk("Total HugeTLB memory allocated, %ld\n", h->free_huge_pages);
+
+	printk(KERN_INFO "Total HugeTLB memory allocated, %ld %dMB pages\n",
+			h->free_huge_pages,
+			1 << (h->order + PAGE_SHIFT - 20));
 	return 0;
 }
+
+static int __init hugetlb_init(void)
+{
+	if (HPAGE_SHIFT == 0)
+		return 0;
+	return hugetlb_init_hstate(&global_hstate);
+}
 module_init(hugetlb_init);
 
+/* Should be called on processing a hugepagesz=... option */
+void __init huge_add_hstate(unsigned order)
+{
+	struct hstate *h;
+	BUG_ON(size_to_hstate(PAGE_SIZE << order));
+	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
+	BUG_ON(order <= HPAGE_SHIFT - PAGE_SHIFT);
+	h = &hstates[max_hstate++];
+	h->order = order;
+	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
+	hugetlb_init_hstate(h);
+	parsed_hstate = h;
+}
+
 static int __init hugetlb_setup(char *s)
 {
 	if (sscanf(s, "%lu", &max_huge_pages) <= 0)
@@ -539,28 +577,27 @@ static unsigned int cpuset_mems_nr(unsig
 
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
@@ -620,7 +657,7 @@ static unsigned long set_max_huge_pages(
 	 */
 	min_count = h->resv_huge_pages + h->nr_huge_pages - h->free_huge_pages;
 	min_count = max(count, min_count);
-	try_to_free_low(min_count);
+	try_to_free_low(h, min_count);
 	while (min_count < persistent_huge_pages(h)) {
 		struct page *page = dequeue_huge_page(h);
 		if (!page)
@@ -1291,7 +1328,7 @@ out:
 int hugetlb_reserve_pages(struct inode *inode, long from, long to)
 {
 	long ret, chg;
-	struct hstate *h = &global_hstate;
+	struct hstate *h = hstate_inode(inode);
 
 	chg = region_chg(&inode->i_mapping->private_list, from, to);
 	if (chg < 0)
@@ -1310,7 +1347,7 @@ int hugetlb_reserve_pages(struct inode *
 
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
@@ -212,7 +212,16 @@ struct hstate {
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

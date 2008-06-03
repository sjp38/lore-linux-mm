Message-Id: <20080603100938.600073661@amd.local0.net>
References: <20080603095956.781009952@amd.local0.net>
Date: Tue, 03 Jun 2008 19:59:59 +1000
From: npiggin@suse.de
Subject: [patch 03/21] hugetlb: multiple hstates
Content-Disposition: inline; filename=hugetlb-multiple-hstates.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, Adam Litke <agl@us.ibm.com>, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

Add basic support for more than one hstate in hugetlbfs

- Convert hstates to an array
- Add a first default entry covering the standard huge page size
- Add functions for architectures to register new hstates
- Add basic iterators over hstates

Acked-by: Adam Litke <agl@us.ibm.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 include/linux/hugetlb.h |   16 +++++++
 mm/hugetlb.c            |   98 +++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 95 insertions(+), 19 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-06-03 19:54:21.000000000 +1000
+++ linux-2.6/mm/hugetlb.c	2008-06-03 19:55:41.000000000 +1000
@@ -22,12 +22,19 @@
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
-unsigned long max_huge_pages;
-unsigned long sysctl_overcommit_huge_pages;
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
-struct hstate default_hstate;
+static int max_hstate = 0;
+unsigned int default_hstate_idx;
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
@@ -272,13 +279,24 @@ static void update_and_free_page(struct 
 	__free_pages(page, huge_page_order(h));
 }
 
+struct hstate *size_to_hstate(unsigned long size)
+{
+	struct hstate *h;
+
+	for_each_hstate(h) {
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
-	struct hstate *h = &default_hstate;
+	struct hstate *h = page_hstate(page);
 	int nid = page_to_nid(page);
 	struct address_space *mapping;
 
@@ -812,39 +830,94 @@ static struct page *alloc_huge_page(stru
 	return page;
 }
 
-static int __init hugetlb_init(void)
+static void __init hugetlb_init_one_hstate(struct hstate *h)
 {
 	unsigned long i;
-	struct hstate *h = &default_hstate;
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
-	printk(KERN_INFO "Total HugeTLB memory allocated, %ld\n",
-			h->free_huge_pages);
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
+		printk(KERN_INFO "Total HugeTLB memory allocated, "
+				"%ld %dMB pages\n",
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
+	default_hstate_idx = size_to_hstate(HPAGE_SIZE) - hstates;
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
+	unsigned long *mhp;
+
+	/*
+	 * !max_hstate means we haven't parsed a hugepagesz= parameter yet,
+	 * so this hugepages= parameter goes to the "default hstate".
+	 */
+	if (!max_hstate)
+		mhp = &default_hstate_max_huge_pages;
+	else
+		mhp = &parsed_hstate->max_huge_pages;
+
+	if (sscanf(s, "%lu", mhp) <= 0)
+		*mhp = 0;
+
 	return 1;
 }
 __setup("hugepages=", hugetlb_setup);
@@ -875,7 +948,7 @@ static void try_to_free_low(struct hstat
 			if (PageHighMem(page))
 				continue;
 			list_del(&page->lru);
-			update_and_free_page(page);
+			update_and_free_page(h, page);
 			h->free_huge_pages--;
 			h->free_huge_pages_node[page_to_nid(page)]--;
 		}
@@ -888,10 +961,9 @@ static inline void try_to_free_low(struc
 #endif
 
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static unsigned long set_max_huge_pages(unsigned long count)
+static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
 {
 	unsigned long min_count, ret;
-	struct hstate *h = &default_hstate;
 
 	/*
 	 * Increase the pool size
@@ -962,8 +1034,19 @@ int hugetlb_sysctl_handler(struct ctl_ta
 			   struct file *file, void __user *buffer,
 			   size_t *length, loff_t *ppos)
 {
+	struct hstate *h = &default_hstate;
+	unsigned long tmp;
+
+	if (!write)
+		tmp = h->max_huge_pages;
+
+	table->data = &tmp;
+	table->maxlen = sizeof(unsigned long);
 	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
-	max_huge_pages = set_max_huge_pages(max_huge_pages);
+
+	if (write)
+		h->max_huge_pages = set_max_huge_pages(h, tmp);
+
 	return 0;
 }
 
@@ -984,10 +1067,21 @@ int hugetlb_overcommit_handler(struct ct
 			size_t *length, loff_t *ppos)
 {
 	struct hstate *h = &default_hstate;
+	unsigned long tmp;
+
+	if (!write)
+		tmp = h->nr_overcommit_huge_pages;
+
+	table->data = &tmp;
+	table->maxlen = sizeof(unsigned long);
 	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
-	spin_lock(&hugetlb_lock);
-	h->nr_overcommit_huge_pages = sysctl_overcommit_huge_pages;
-	spin_unlock(&hugetlb_lock);
+
+	if (write) {
+		spin_lock(&hugetlb_lock);
+		h->nr_overcommit_huge_pages = tmp;
+		spin_unlock(&hugetlb_lock);
+	}
+
 	return 0;
 }
 
Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h	2008-06-03 19:53:30.000000000 +1000
+++ linux-2.6/include/linux/hugetlb.h	2008-06-03 19:55:17.000000000 +1000
@@ -36,8 +36,6 @@ int hugetlb_reserve_pages(struct inode *
 						struct vm_area_struct *vma);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 
-extern unsigned long max_huge_pages;
-extern unsigned long sysctl_overcommit_huge_pages;
 extern unsigned long hugepages_treat_as_movable;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
@@ -181,7 +179,17 @@ struct hstate {
 	unsigned int surplus_huge_pages_node[MAX_NUMNODES];
 };
 
-extern struct hstate default_hstate;
+void __init hugetlb_add_hstate(unsigned order);
+struct hstate *size_to_hstate(unsigned long size);
+
+#ifndef HUGE_MAX_HSTATE
+#define HUGE_MAX_HSTATE 1
+#endif
+
+extern struct hstate hstates[HUGE_MAX_HSTATE];
+extern unsigned int default_hstate_idx;
+
+#define default_hstate (hstates[default_hstate_idx])
 
 static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
 {
@@ -228,6 +236,11 @@ static inline unsigned int blocks_per_hu
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
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c	2008-06-03 19:52:52.000000000 +1000
+++ linux-2.6/kernel/sysctl.c	2008-06-03 19:55:17.000000000 +1000
@@ -915,7 +915,7 @@ static struct ctl_table vm_table[] = {
 #ifdef CONFIG_HUGETLB_PAGE
 	 {
 		.procname	= "nr_hugepages",
-		.data		= &max_huge_pages,
+		.data		= NULL,
 		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
 		.proc_handler	= &hugetlb_sysctl_handler,
@@ -941,10 +941,12 @@ static struct ctl_table vm_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nr_overcommit_hugepages",
-		.data		= &sysctl_overcommit_huge_pages,
-		.maxlen		= sizeof(sysctl_overcommit_huge_pages),
+		.data		= NULL,
+		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
 		.proc_handler	= &hugetlb_overcommit_handler,
+		.extra1		= (void *)&hugetlb_zero,
+		.extra2		= (void *)&hugetlb_infinity,
 	},
 #endif
 	{

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

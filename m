Message-Id: <20080410171100.855682000@nick.local0.net>
References: <20080410170232.015351000@nick.local0.net>
Date: Fri, 11 Apr 2008 03:02:37 +1000
From: npiggin@suse.de
Subject: [patch 05/17] hugetlb: multi hstate sysctls
Content-Disposition: inline; filename=hugetlbfs-sysctl-hstates.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Expand the hugetlbfs sysctls to handle arrays for all hstates

- I didn't bother with hugetlb_shm_group and treat_as_movable,
these are still single global.
- Also improve error propagation for the sysctl handlers a bit


Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: pj@sgi.com
Cc: andi@firstfloor.org
Cc: kniht@linux.vnet.ibm.com

---
 include/linux/hugetlb.h |    5 +++--
 kernel/sysctl.c         |    2 +-
 mm/hugetlb.c            |   43 +++++++++++++++++++++++++++++++------------
 3 files changed, 35 insertions(+), 15 deletions(-)

Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h
+++ linux-2.6/include/linux/hugetlb.h
@@ -32,8 +32,6 @@ int hugetlb_fault(struct mm_struct *mm, 
 int hugetlb_reserve_pages(struct inode *inode, long from, long to);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 
-extern unsigned long max_huge_pages;
-extern unsigned long sysctl_overcommit_huge_pages;
 extern unsigned long hugepages_treat_as_movable;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
@@ -262,6 +260,9 @@ static inline unsigned huge_page_shift(s
 	return h->order + PAGE_SHIFT;
 }
 
+extern unsigned long max_huge_pages[HUGE_MAX_HSTATE];
+extern unsigned long sysctl_overcommit_huge_pages[HUGE_MAX_HSTATE];
+
 #else
 struct hstate {};
 #define hstate_file(f) NULL
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c
+++ linux-2.6/kernel/sysctl.c
@@ -935,7 +935,7 @@ static struct ctl_table vm_table[] = {
 	 {
 		.procname	= "nr_hugepages",
 		.data		= &max_huge_pages,
-		.maxlen		= sizeof(unsigned long),
+		.maxlen 	= sizeof(max_huge_pages),
 		.mode		= 0644,
 		.proc_handler	= &hugetlb_sysctl_handler,
 		.extra1		= (void *)&hugetlb_zero,
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -22,8 +22,8 @@
 #include "internal.h"
 
 const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
-unsigned long max_huge_pages;
-unsigned long sysctl_overcommit_huge_pages;
+unsigned long max_huge_pages[HUGE_MAX_HSTATE];
+unsigned long sysctl_overcommit_huge_pages[HUGE_MAX_HSTATE];
 static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
 unsigned long hugepages_treat_as_movable;
 
@@ -522,11 +522,11 @@ static int __init hugetlb_init_hstate(st
 
 	h->hugetlb_next_nid = first_node(node_online_map);
 
-	for (i = 0; i < max_huge_pages; ++i) {
+	for (i = 0; i < max_huge_pages[h - hstates]; ++i) {
 		if (!alloc_fresh_huge_page(h))
 			break;
 	}
-	max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
+	max_huge_pages[h - hstates] = h->free_huge_pages = h->nr_huge_pages = i;
 
 	printk(KERN_INFO "Total HugeTLB memory allocated, %ld %dMB pages\n",
 			h->free_huge_pages,
@@ -558,8 +558,9 @@ void __init huge_add_hstate(unsigned ord
 
 static int __init hugetlb_setup(char *s)
 {
-	if (sscanf(s, "%lu", &max_huge_pages) <= 0)
-		max_huge_pages = 0;
+	unsigned long *mhp = &max_huge_pages[parsed_hstate - hstates];
+	if (sscanf(s, "%lu", mhp) <= 0)
+		*mhp = 0;
 	return 1;
 }
 __setup("hugepages=", hugetlb_setup);
@@ -603,10 +604,12 @@ static inline void try_to_free_low(struc
 #endif
 
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static unsigned long set_max_huge_pages(unsigned long count)
+static unsigned long
+set_max_huge_pages(struct hstate *h, unsigned long count, int *err)
 {
 	unsigned long min_count, ret;
-	struct hstate *h = &global_hstate;
+
+	*err = 0;
 
 	/*
 	 * Increase the pool size
@@ -678,8 +681,20 @@ int hugetlb_sysctl_handler(struct ctl_ta
 			   struct file *file, void __user *buffer,
 			   size_t *length, loff_t *ppos)
 {
-	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
-	max_huge_pages = set_max_huge_pages(max_huge_pages);
+	int err = 0;
+	struct hstate *h;
+	int i;
+	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+	if (err)
+		return err;
+	i = 0;
+	for_each_hstate (h) {
+		max_huge_pages[i] = set_max_huge_pages(h, max_huge_pages[i],
+							&err);
+		if (err)
+			return err;
+		i++;
+	}
 	return 0;
 }
 
@@ -699,10 +714,14 @@ int hugetlb_overcommit_handler(struct ct
 			struct file *file, void __user *buffer,
 			size_t *length, loff_t *ppos)
 {
-	struct hstate *h = &global_hstate;
+	struct hstate *h;
+	int i = 0;
 	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
 	spin_lock(&hugetlb_lock);
-	h->nr_overcommit_huge_pages = sysctl_overcommit_huge_pages;
+	for_each_hstate (h) {
+		h->nr_overcommit_huge_pages = sysctl_overcommit_huge_pages[i];
+		i++;
+	}
 	spin_unlock(&hugetlb_lock);
 	return 0;
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

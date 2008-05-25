Message-Id: <20080525143452.841211000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
Date: Mon, 26 May 2008 00:23:24 +1000
From: npiggin@suse.de
Subject: [patch 07/23] hugetlb: multi hstate sysctls
Content-Disposition: inline; filename=hugetlbfs-sysctl-hstates.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Expand the hugetlbfs sysctls to handle arrays for all hstates. This
now allows the removal of global_hstate -- everything is now hstate
aware.

- I didn't bother with hugetlb_shm_group and treat_as_movable,
these are still single global.
- Also improve error propagation for the sysctl handlers a bit

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 include/linux/hugetlb.h |    7 ++--
 kernel/sysctl.c         |    4 ++
 mm/hugetlb.c            |   70 +++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 61 insertions(+), 20 deletions(-)

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
@@ -182,8 +180,6 @@ struct hstate *size_to_hstate(unsigned l
 
 extern struct hstate hstates[HUGE_MAX_HSTATE];
 
-#define global_hstate (hstates[0])
-
 static inline struct hstate *hstate_inode(struct inode *i)
 {
 	struct hugetlbfs_sb_info *hsb;
@@ -231,6 +227,9 @@ static inline struct hstate *page_hstate
 	return size_to_hstate(PAGE_SIZE << compound_order(page));
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
@@ -928,7 +928,7 @@ static struct ctl_table vm_table[] = {
 	 {
 		.procname	= "nr_hugepages",
 		.data		= &max_huge_pages,
-		.maxlen		= sizeof(unsigned long),
+		.maxlen 	= sizeof(max_huge_pages),
 		.mode		= 0644,
 		.proc_handler	= &hugetlb_sysctl_handler,
 		.extra1		= (void *)&hugetlb_zero,
@@ -957,6 +957,8 @@ static struct ctl_table vm_table[] = {
 		.maxlen		= sizeof(sysctl_overcommit_huge_pages),
 		.mode		= 0644,
 		.proc_handler	= &hugetlb_overcommit_handler,
+		.extra1		= (void *)&hugetlb_zero,
+		.extra2		= (void *)&hugetlb_infinity,
 	},
 #endif
 	{
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
 
@@ -614,8 +614,16 @@ void __init hugetlb_add_hstate(unsigned 
 
 static int __init hugetlb_setup(char *s)
 {
-	if (sscanf(s, "%lu", &default_hstate_max_huge_pages) <= 0)
-		default_hstate_max_huge_pages = 0;
+	unsigned long *mhp;
+
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
@@ -659,10 +667,12 @@ static inline void try_to_free_low(struc
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
@@ -734,16 +744,33 @@ int hugetlb_sysctl_handler(struct ctl_ta
 			   struct file *file, void __user *buffer,
 			   size_t *length, loff_t *ppos)
 {
-	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
-	max_huge_pages = set_max_huge_pages(max_huge_pages);
-	global_hstate.max_huge_pages = max_huge_pages;
-	return 0;
+	int err;
+
+	table->maxlen = max_hstate * sizeof(unsigned long);
+	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+	if (err)
+		return err;
+
+	if (write) {
+		struct hstate *h;
+		for_each_hstate (h) {
+			int tmp;
+
+			h->max_huge_pages = set_max_huge_pages(h,
+					max_huge_pages[h - hstates], &tmp);
+			max_huge_pages[h - hstates] = h->max_huge_pages;
+			if (tmp && !err)
+				err = tmp;
+		}
+	}
+	return err;
 }
 
 int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
 			struct file *file, void __user *buffer,
 			size_t *length, loff_t *ppos)
 {
+ 	table->maxlen = max_hstate * sizeof(int);
 	proc_dointvec(table, write, file, buffer, length, ppos);
 	if (hugepages_treat_as_movable)
 		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
@@ -756,11 +783,24 @@ int hugetlb_overcommit_handler(struct ct
 			struct file *file, void __user *buffer,
 			size_t *length, loff_t *ppos)
 {
-	struct hstate *h = &global_hstate;
-	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
-	spin_lock(&hugetlb_lock);
-	h->nr_overcommit_huge_pages = sysctl_overcommit_huge_pages;
-	spin_unlock(&hugetlb_lock);
+	int err;
+
+	table->maxlen = max_hstate * sizeof(unsigned long);
+	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+	if (err)
+		return err;
+
+	if (write) {
+		struct hstate *h;
+
+		spin_lock(&hugetlb_lock);
+		for_each_hstate (h) {
+			h->nr_overcommit_huge_pages =
+				sysctl_overcommit_huge_pages[h - hstates];
+		}
+		spin_unlock(&hugetlb_lock);
+	}
+
 	return 0;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

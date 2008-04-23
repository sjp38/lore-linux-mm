Message-Id: <20080423015431.569358000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
Date: Wed, 23 Apr 2008 11:53:20 +1000
From: npiggin@suse.de
Subject: [patch 18/18] hugetlb: my fixes 2
Content-Disposition: inline; filename=hugetlb-fixes2.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Here is my next set of fixes and changes:
- Allow configurations without the default HPAGE_SIZE size (mainly useful
  for testing but maybe it is the right way to go).
- Fixed another case where mappings would be set up on incorrect boundaries
  because prepare_hugepage_range was not hpage-ified.
- Changed the sysctl table behaviour so it only displays as many values in
  the vector as there are hstates configured.
- Fixed oops in overcommit sysctl handler

This fixes several oopses seen on the libhugetlbfs test suite. Now it seems to
pass most of them and fails reasonably on others (eg. most 32-bit tests fail
due to being unable to map enough virtual memory, others due to not enough
hugepages given that I only have 2).

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
---
 arch/x86/mm/hugetlbpage.c |    4 ++--
 fs/hugetlbfs/inode.c      |    4 +++-
 include/linux/hugetlb.h   |   19 ++-----------------
 kernel/sysctl.c           |    2 ++
 mm/hugetlb.c              |   35 ++++++++++++++++++++++++++++++-----
 5 files changed, 39 insertions(+), 25 deletions(-)

Index: linux-2.6/arch/x86/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/hugetlbpage.c
+++ linux-2.6/arch/x86/mm/hugetlbpage.c
@@ -124,7 +124,7 @@ int huge_pmd_unshare(struct mm_struct *m
 	return 1;
 }
 
-pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, int sz)
+pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -402,7 +402,7 @@ hugetlb_get_unmapped_area(struct file *f
 		return -ENOMEM;
 
 	if (flags & MAP_FIXED) {
-		if (prepare_hugepage_range(addr, len))
+		if (prepare_hugepage_range(file, addr, len))
 			return -EINVAL;
 		return addr;
 	}
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -640,7 +640,7 @@ static int __init hugetlb_init(void)
 {
 	BUILD_BUG_ON(HPAGE_SHIFT == 0);
 
-	if (!size_to_hstate(HPAGE_SIZE)) {
+	if (!max_hstate) {
 		huge_add_hstate(HUGETLB_PAGE_ORDER);
 		parsed_hstate->max_huge_pages = default_hstate_resv;
 	}
@@ -821,9 +821,10 @@ int hugetlb_sysctl_handler(struct ctl_ta
 			   struct file *file, void __user *buffer,
 			   size_t *length, loff_t *ppos)
 {
-	int err = 0;
+	int err;
 	struct hstate *h;
 
+	table->maxlen = max_hstate * sizeof(unsigned long);
 	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
 	if (err)
 		return err;
@@ -846,6 +847,7 @@ int hugetlb_treat_movable_handler(struct
 			struct file *file, void __user *buffer,
 			size_t *length, loff_t *ppos)
 {
+	table->maxlen = max_hstate * sizeof(int);
 	proc_dointvec(table, write, file, buffer, length, ppos);
 	if (hugepages_treat_as_movable)
 		htlb_alloc_mask = GFP_HIGHUSER_MOVABLE;
@@ -858,15 +860,22 @@ int hugetlb_overcommit_handler(struct ct
 			struct file *file, void __user *buffer,
 			size_t *length, loff_t *ppos)
 {
+	int err;
 	struct hstate *h;
-	int i = 0;
-	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+
+	table->maxlen = max_hstate * sizeof(unsigned long);
+	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+	if (err)
+		return err;
+
 	spin_lock(&hugetlb_lock);
 	for_each_hstate (h) {
-		h->nr_overcommit_huge_pages = sysctl_overcommit_huge_pages[i];
+		h->nr_overcommit_huge_pages =
+				sysctl_overcommit_huge_pages[h - hstates];
 		i++;
 	}
 	spin_unlock(&hugetlb_lock);
+
 	return 0;
 }
 
@@ -1015,6 +1024,22 @@ nomem:
 	return -ENOMEM;
 }
 
+#ifndef ARCH_HAS_PREPARE_HUGEPAGE_RANGE
+/*
+ * If the arch doesn't supply something else, assume that hugepage
+ * size aligned regions are ok without further preparation.
+ */
+int prepare_hugepage_range(struct file *file, unsigned long addr, unsigned long len)
+{
+	struct hstate *h = hstate_file(file);
+	if (len & ~huge_page_mask(h))
+		return -EINVAL;
+	if (addr & ~huge_page_mask(h))
+		return -EINVAL;
+	return 0;
+}
+#endif
+
 void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			    unsigned long end)
 {
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c
+++ linux-2.6/fs/hugetlbfs/inode.c
@@ -141,7 +141,7 @@ hugetlb_get_unmapped_area(struct file *f
 		return -ENOMEM;
 
 	if (flags & MAP_FIXED) {
-		if (prepare_hugepage_range(addr, len))
+		if (prepare_hugepage_range(file, addr, len))
 			return -EINVAL;
 		return addr;
 	}
@@ -858,6 +858,8 @@ hugetlbfs_fill_super(struct super_block 
 	config.gid = current->fsgid;
 	config.mode = 0755;
 	config.hstate = size_to_hstate(HPAGE_SIZE);
+	if (!config.hstate)
+		config.hstate = &hstates[0];
 	ret = hugetlbfs_parse_options(data, &config);
 	if (ret)
 		return ret;
Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h
+++ linux-2.6/include/linux/hugetlb.h
@@ -64,22 +64,7 @@ void hugetlb_free_pgd_range(struct mmu_g
 			    unsigned long ceiling);
 #endif
 
-#ifndef ARCH_HAS_PREPARE_HUGEPAGE_RANGE
-/*
- * If the arch doesn't supply something else, assume that hugepage
- * size aligned regions are ok without further preparation.
- */
-static inline int prepare_hugepage_range(unsigned long addr, unsigned long len)
-{
-	if (len & ~HPAGE_MASK)
-		return -EINVAL;
-	if (addr & ~HPAGE_MASK)
-		return -EINVAL;
-	return 0;
-}
-#else
-int prepare_hugepage_range(unsigned long addr, unsigned long len);
-#endif
+int prepare_hugepage_range(struct file *file, unsigned long addr, unsigned long len);
 
 #ifndef ARCH_HAS_SETCLEAR_HUGE_PTE
 #define set_huge_pte_at(mm, addr, ptep, pte)	set_pte_at(mm, addr, ptep, pte)
@@ -116,7 +101,7 @@ static inline unsigned long hugetlb_tota
 #define hugetlb_report_node_meminfo(n, buf)	0
 #define follow_huge_pmd(mm, addr, pmd, write)	NULL
 #define follow_huge_pud(mm, addr, pud, write)	NULL
-#define prepare_hugepage_range(addr,len)	(-EINVAL)
+#define prepare_hugepage_range(file,addr,len)	(-EINVAL)
 #define pmd_huge(x)	0
 #define pud_huge(x)	0
 #define is_hugepage_only_range(mm, addr, len)	0
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c
+++ linux-2.6/kernel/sysctl.c
@@ -953,6 +953,8 @@ static struct ctl_table vm_table[] = {
 		.maxlen		= sizeof(sysctl_overcommit_huge_pages),
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

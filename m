Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id D04986B006E
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:48:36 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id i13so2376385qae.33
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:48:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s2si2597003qak.63.2014.06.12.14.48.36
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 14:48:36 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm v2 07/11] pagewalk: change type of arg of callbacks
Date: Thu, 12 Jun 2014 17:48:07 -0400
Message-Id: <1402609691-13950-8-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

Page table walker focuses on the leaf entries, and in some situation the
caller is interested only in the size of entry (not in the details of pages
pointed to by the entry.) Then it's helpful to share callback functions
between different levels. For this purpose this patch changes args in callback
functions and let them get the pointer of the entry in type of (void *).

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/openrisc/kernel/dma.c     |  6 ++++--
 arch/powerpc/mm/subpage-prot.c |  3 ++-
 fs/proc/task_mmu.c             | 31 +++++++++++++++++++------------
 include/linux/mm.h             |  6 +++---
 mm/madvise.c                   |  3 ++-
 mm/memcontrol.c                | 12 ++++++++----
 mm/mempolicy.c                 |  6 ++++--
 7 files changed, 42 insertions(+), 25 deletions(-)

diff --git mmotm-2014-05-21-16-57.orig/arch/openrisc/kernel/dma.c mmotm-2014-05-21-16-57/arch/openrisc/kernel/dma.c
index 0b77ddb1ee07..a2983e8f6f04 100644
--- mmotm-2014-05-21-16-57.orig/arch/openrisc/kernel/dma.c
+++ mmotm-2014-05-21-16-57/arch/openrisc/kernel/dma.c
@@ -29,9 +29,10 @@
 #include <asm/tlbflush.h>
 
 static int
-page_set_nocache(pte_t *pte, unsigned long addr,
+page_set_nocache(void *entry, unsigned long addr,
 		 unsigned long next, struct mm_walk *walk)
 {
+	pte_t *pte = entry;
 	unsigned long cl;
 
 	pte_val(*pte) |= _PAGE_CI;
@@ -50,9 +51,10 @@ page_set_nocache(pte_t *pte, unsigned long addr,
 }
 
 static int
-page_clear_nocache(pte_t *pte, unsigned long addr,
+page_clear_nocache(void *entry, unsigned long addr,
 		   unsigned long next, struct mm_walk *walk)
 {
+	pte_t *pte = entry;
 	pte_val(*pte) &= ~_PAGE_CI;
 
 	/*
diff --git mmotm-2014-05-21-16-57.orig/arch/powerpc/mm/subpage-prot.c mmotm-2014-05-21-16-57/arch/powerpc/mm/subpage-prot.c
index d0d94ac606f3..d62e9adc93fb 100644
--- mmotm-2014-05-21-16-57.orig/arch/powerpc/mm/subpage-prot.c
+++ mmotm-2014-05-21-16-57/arch/powerpc/mm/subpage-prot.c
@@ -131,9 +131,10 @@ static void subpage_prot_clear(unsigned long addr, unsigned long len)
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
+static int subpage_walk_pmd_entry(void *entry, unsigned long addr,
 				  unsigned long end, struct mm_walk *walk)
 {
+	pmd_t *pmd = entry;
 	struct vm_area_struct *vma = walk->vma;
 	spin_unlock(walk->ptl);
 	split_huge_page_pmd(vma, addr, pmd);
diff --git mmotm-2014-05-21-16-57.orig/fs/proc/task_mmu.c mmotm-2014-05-21-16-57/fs/proc/task_mmu.c
index 8211f6c8236d..a750d0842875 100644
--- mmotm-2014-05-21-16-57.orig/fs/proc/task_mmu.c
+++ mmotm-2014-05-21-16-57/fs/proc/task_mmu.c
@@ -437,9 +437,10 @@ struct mem_size_stats {
 	u64 pss;
 };
 
-static int smaps_pte(pte_t *pte, unsigned long addr, unsigned long end,
+static int smaps_pte(void *entry, unsigned long addr, unsigned long end,
 			struct mm_walk *walk)
 {
+	pte_t *pte = entry;
 	struct mem_size_stats *mss = walk->private;
 	struct vm_area_struct *vma = walk->vma;
 	pgoff_t pgoff = linear_page_index(vma, addr);
@@ -492,11 +493,11 @@ static int smaps_pte(pte_t *pte, unsigned long addr, unsigned long end,
 	return 0;
 }
 
-static int smaps_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
+static int smaps_pmd(void *entry, unsigned long addr, unsigned long end,
 			struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
-	smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
+	smaps_pte(entry, addr, end, walk);
 	mss->anonymous_thp += HPAGE_PMD_SIZE;
 	return 0;
 }
@@ -720,9 +721,10 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 #endif
 }
 
-static int clear_refs_pte(pte_t *pte, unsigned long addr,
+static int clear_refs_pte(void *entry, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 {
+	pte_t *pte = entry;
 	struct clear_refs_private *cp = walk->private;
 	struct vm_area_struct *vma = walk->vma;
 	struct page *page;
@@ -954,9 +956,10 @@ static inline void thp_pmd_to_pagemap_entry(pagemap_entry_t *pme, struct pagemap
 }
 #endif
 
-static int pagemap_pte(pte_t *pte, unsigned long addr, unsigned long end,
+static int pagemap_pte(void *entry, unsigned long addr, unsigned long end,
 			     struct mm_walk *walk)
 {
+	pte_t *pte = entry;
 	struct vm_area_struct *vma = walk->vma;
 	struct pagemapread *pm = walk->private;
 	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
@@ -969,10 +972,11 @@ static int pagemap_pte(pte_t *pte, unsigned long addr, unsigned long end,
 	return add_to_pagemap(addr, &pme, pm);
 }
 
-static int pagemap_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
+static int pagemap_pmd(void *entry, unsigned long addr, unsigned long end,
 			     struct mm_walk *walk)
 {
 	int err = 0;
+	pmd_t *pmd = entry;
 	struct vm_area_struct *vma = walk->vma;
 	struct pagemapread *pm = walk->private;
 	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
@@ -1009,9 +1013,10 @@ static void huge_pte_to_pagemap_entry(pagemap_entry_t *pme, struct pagemapread *
 }
 
 /* This function walks within one hugetlb entry in the single call */
-static int pagemap_hugetlb(pte_t *pte, unsigned long addr, unsigned long end,
+static int pagemap_hugetlb(void *entry, unsigned long addr, unsigned long end,
 			   struct mm_walk *walk)
 {
+	pte_t *pte = entry;
 	struct pagemapread *pm = walk->private;
 	struct vm_area_struct *vma = walk->vma;
 	int err = 0;
@@ -1243,9 +1248,10 @@ static struct page *can_gather_numa_stats(pte_t pte, struct vm_area_struct *vma,
 	return page;
 }
 
-static int gather_pte_stats(pte_t *pte, unsigned long addr,
+static int gather_pte_stats(void *entry, unsigned long addr,
 		unsigned long end, struct mm_walk *walk)
 {
+	pte_t *pte = entry;
 	struct numa_maps *md = walk->private;
 
 	struct page *page = can_gather_numa_stats(*pte, walk->vma, addr);
@@ -1255,12 +1261,12 @@ static int gather_pte_stats(pte_t *pte, unsigned long addr,
 	return 0;
 }
 
-static int gather_pmd_stats(pmd_t *pmd, unsigned long addr,
+static int gather_pmd_stats(void *entry, unsigned long addr,
 		unsigned long end, struct mm_walk *walk)
 {
 	struct numa_maps *md = walk->private;
 	struct vm_area_struct *vma = walk->vma;
-	pte_t huge_pte = *(pte_t *)pmd;
+	pte_t huge_pte = *(pte_t *)entry;
 	struct page *page;
 
 	page = can_gather_numa_stats(huge_pte, vma, addr);
@@ -1270,9 +1276,10 @@ static int gather_pmd_stats(pmd_t *pmd, unsigned long addr,
 	return 0;
 }
 #ifdef CONFIG_HUGETLB_PAGE
-static int gather_hugetlb_stats(pte_t *pte, unsigned long addr,
+static int gather_hugetlb_stats(void *entry, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 {
+	pte_t *pte = entry;
 	struct numa_maps *md;
 	struct page *page;
 
@@ -1292,7 +1299,7 @@ static int gather_hugetlb_stats(pte_t *pte, unsigned long addr,
 }
 
 #else
-static int gather_hugetlb_stats(pte_t *pte, unsigned long addr,
+static int gather_hugetlb_stats(void *entry, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 {
 	return 0;
diff --git mmotm-2014-05-21-16-57.orig/include/linux/mm.h mmotm-2014-05-21-16-57/include/linux/mm.h
index cbe17d9cbd7f..08c2a128dd5c 100644
--- mmotm-2014-05-21-16-57.orig/include/linux/mm.h
+++ mmotm-2014-05-21-16-57/include/linux/mm.h
@@ -1114,13 +1114,13 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
  * (see the comment on walk_page_range() for more details)
  */
 struct mm_walk {
-	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
+	int (*pmd_entry)(void *entry, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
-	int (*pte_entry)(pte_t *pte, unsigned long addr,
+	int (*pte_entry)(void *entry, unsigned long addr,
 			 unsigned long next, struct mm_walk *walk);
 	int (*pte_hole)(unsigned long addr, unsigned long next,
 			struct mm_walk *walk);
-	int (*hugetlb_entry)(pte_t *pte, unsigned long addr,
+	int (*hugetlb_entry)(void *entry, unsigned long addr,
 			unsigned long next, struct mm_walk *walk);
 	int (*test_walk)(unsigned long addr, unsigned long next,
 			struct mm_walk *walk);
diff --git mmotm-2014-05-21-16-57.orig/mm/madvise.c mmotm-2014-05-21-16-57/mm/madvise.c
index 06b390a6fbbd..df664fcbd443 100644
--- mmotm-2014-05-21-16-57.orig/mm/madvise.c
+++ mmotm-2014-05-21-16-57/mm/madvise.c
@@ -138,9 +138,10 @@ static long madvise_behavior(struct vm_area_struct *vma,
 /*
  * Assuming that page table walker holds page table lock.
  */
-static int swapin_walk_pte_entry(pte_t *pte, unsigned long start,
+static int swapin_walk_pte_entry(void *ent, unsigned long start,
 	unsigned long end, struct mm_walk *walk)
 {
+	pte_t *pte = ent;
 	pte_t ptent;
 	pte_t *orig_pte = pte - ((start & (PMD_SIZE - 1)) >> PAGE_SHIFT);
 	swp_entry_t entry;
diff --git mmotm-2014-05-21-16-57.orig/mm/memcontrol.c mmotm-2014-05-21-16-57/mm/memcontrol.c
index bb987cb9e043..7d62b6778a5b 100644
--- mmotm-2014-05-21-16-57.orig/mm/memcontrol.c
+++ mmotm-2014-05-21-16-57/mm/memcontrol.c
@@ -6709,19 +6709,21 @@ static inline enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
 }
 #endif
 
-static int mem_cgroup_count_precharge_pte(pte_t *pte,
+static int mem_cgroup_count_precharge_pte(void *entry,
 					unsigned long addr, unsigned long end,
 					struct mm_walk *walk)
 {
+	pte_t *pte = entry;
 	if (get_mctgt_type(walk->vma, addr, *pte, NULL))
 		mc.precharge++;	/* increment precharge temporarily */
 	return 0;
 }
 
-static int mem_cgroup_count_precharge_pmd(pmd_t *pmd,
+static int mem_cgroup_count_precharge_pmd(void *entry,
 					unsigned long addr, unsigned long end,
 					struct mm_walk *walk)
 {
+	pmd_t *pmd = entry;
 	struct vm_area_struct *vma = walk->vma;
 
 	if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
@@ -6875,11 +6877,12 @@ static void mem_cgroup_cancel_attach(struct cgroup_subsys_state *css,
 	mem_cgroup_clear_mc();
 }
 
-static int mem_cgroup_move_charge_pte(pte_t *pte,
+static int mem_cgroup_move_charge_pte(void *entry,
 				unsigned long addr, unsigned long end,
 				struct mm_walk *walk)
 {
 	int ret = 0;
+	pte_t *pte = entry;
 	struct vm_area_struct *vma = walk->vma;
 	union mc_target target;
 	struct page *page;
@@ -6936,10 +6939,11 @@ put:		/* get_mctgt_type() gets the page */
 	return 0;
 }
 
-static int mem_cgroup_move_charge_pmd(pmd_t *pmd,
+static int mem_cgroup_move_charge_pmd(void *entry,
 				unsigned long addr, unsigned long end,
 				struct mm_walk *walk)
 {
+	pmd_t *pmd = entry;
 	struct vm_area_struct *vma = walk->vma;
 	enum mc_target_type target_type;
 	union mc_target target;
diff --git mmotm-2014-05-21-16-57.orig/mm/mempolicy.c mmotm-2014-05-21-16-57/mm/mempolicy.c
index b8267f753748..f74cacb36b95 100644
--- mmotm-2014-05-21-16-57.orig/mm/mempolicy.c
+++ mmotm-2014-05-21-16-57/mm/mempolicy.c
@@ -490,9 +490,10 @@ struct queue_pages {
  * Scan through pages checking if pages follow certain conditions,
  * and move them to the pagelist if they do.
  */
-static int queue_pages_pte(pte_t *pte, unsigned long addr,
+static int queue_pages_pte(void *entry, unsigned long addr,
 			unsigned long next, struct mm_walk *walk)
 {
+	pte_t *pte = entry;
 	struct vm_area_struct *vma = walk->vma;
 	struct page *page;
 	struct queue_pages *qp = walk->private;
@@ -519,10 +520,11 @@ static int queue_pages_pte(pte_t *pte, unsigned long addr,
 	return 0;
 }
 
-static int queue_pages_hugetlb(pte_t *pte, unsigned long addr,
+static int queue_pages_hugetlb(void *ent, unsigned long addr,
 				unsigned long next, struct mm_walk *walk)
 {
 #ifdef CONFIG_HUGETLB_PAGE
+	pte_t *pte = ent;
 	struct queue_pages *qp = walk->private;
 	unsigned long flags = qp->flags;
 	int nid;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

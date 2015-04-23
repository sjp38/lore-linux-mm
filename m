Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id D48956B0098
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 17:05:18 -0400 (EDT)
Received: by pdea3 with SMTP id a3so28615984pde.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 14:05:18 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id xt6si14192368pbc.59.2015.04.23.14.05.01
        for <linux-mm@kvack.org>;
        Thu, 23 Apr 2015 14:05:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 17/28] mm, thp: remove infrastructure for handling splitting PMDs
Date: Fri, 24 Apr 2015 00:03:52 +0300
Message-Id: <1429823043-157133-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting we don't need to mark PMDs splitting. Let's drop code
to handle this.

Arch-specific code will removed separately.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 fs/proc/task_mmu.c            |  8 +++----
 include/asm-generic/pgtable.h |  5 ----
 include/linux/huge_mm.h       |  9 --------
 mm/gup.c                      |  7 ------
 mm/huge_memory.c              | 54 ++++++++-----------------------------------
 mm/memcontrol.c               | 14 ++---------
 mm/memory.c                   | 18 ++-------------
 mm/mincore.c                  |  2 +-
 mm/pgtable-generic.c          | 14 -----------
 mm/rmap.c                     |  4 +---
 10 files changed, 20 insertions(+), 115 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 95bc384ee3f7..edd63c40ed71 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -534,7 +534,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		smaps_pmd_entry(pmd, addr, walk);
 		spin_unlock(ptl);
 		return 0;
@@ -799,7 +799,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 	spinlock_t *ptl;
 	struct page *page;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
 			clear_soft_dirty_pmd(vma, addr, pmd);
 			goto out;
@@ -1112,7 +1112,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	pte_t *pte, *orig_pte;
 	int err = 0;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		int pmd_flags2;
 
 		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
@@ -1416,7 +1416,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 	pte_t *orig_pte;
 	pte_t *pte;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 39f1d6a2b04d..fe617b7e4be6 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -184,11 +184,6 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
-#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-extern void pmdp_splitting_flush(struct vm_area_struct *vma,
-				 unsigned long address, pmd_t *pmdp);
-#endif
-
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				       pgtable_t pgtable);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 47f80207782f..0382230b490f 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -49,15 +49,9 @@ enum transparent_hugepage_flag {
 #endif
 };
 
-enum page_check_address_pmd_flag {
-	PAGE_CHECK_ADDRESS_PMD_FLAG,
-	PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG,
-	PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG,
-};
 extern pmd_t *page_check_address_pmd(struct page *page,
 				     struct mm_struct *mm,
 				     unsigned long address,
-				     enum page_check_address_pmd_flag flag,
 				     spinlock_t **ptl);
 extern int pmd_freeable(pmd_t pmd);
 
@@ -102,7 +96,6 @@ extern unsigned long transparent_hugepage_flags;
 #define split_huge_page(page) BUILD_BUG()
 #define split_huge_pmd(__vma, __pmd, __address) BUILD_BUG()
 
-#define wait_split_huge_page(__anon_vma, __pmd) BUILD_BUG();
 #if HPAGE_PMD_ORDER >= MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
@@ -169,8 +162,6 @@ static inline int split_huge_page(struct page *page)
 {
 	return 0;
 }
-#define wait_split_huge_page(__anon_vma, __pmd)	\
-	do { } while (0)
 #define split_huge_pmd(__vma, __pmd, __address)	\
 	do { } while (0)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
diff --git a/mm/gup.c b/mm/gup.c
index 53f9681b7b30..0cebfa76fd0c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -207,13 +207,6 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 		spin_unlock(ptl);
 		return follow_page_pte(vma, address, pmd, flags);
 	}
-
-	if (unlikely(pmd_trans_splitting(*pmd))) {
-		spin_unlock(ptl);
-		wait_split_huge_page(vma->anon_vma, pmd);
-		return follow_page_pte(vma, address, pmd, flags);
-	}
-
 	if (flags & FOLL_SPLIT) {
 		int ret;
 		page = pmd_page(*pmd);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 16c6c262385c..23181f836b62 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -889,15 +889,6 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out_unlock;
 	}
 
-	if (unlikely(pmd_trans_splitting(pmd))) {
-		/* split huge page running from under us */
-		spin_unlock(src_ptl);
-		spin_unlock(dst_ptl);
-		pte_free(dst_mm, pgtable);
-
-		wait_split_huge_page(vma->anon_vma, src_pmd); /* src_vma */
-		goto out;
-	}
 	src_page = pmd_page(pmd);
 	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
 	get_page(src_page);
@@ -1403,7 +1394,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		struct page *page;
 		pgtable_t pgtable;
 		pmd_t orig_pmd;
@@ -1443,7 +1434,6 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		  pmd_t *old_pmd, pmd_t *new_pmd)
 {
 	spinlock_t *old_ptl, *new_ptl;
-	int ret = 0;
 	pmd_t pmd;
 
 	struct mm_struct *mm = vma->vm_mm;
@@ -1452,7 +1442,7 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 	    (new_addr & ~HPAGE_PMD_MASK) ||
 	    old_end - old_addr < HPAGE_PMD_SIZE ||
 	    (new_vma->vm_flags & VM_NOHUGEPAGE))
-		goto out;
+		return 0;
 
 	/*
 	 * The destination pmd shouldn't be established, free_pgtables()
@@ -1460,15 +1450,14 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 	 */
 	if (WARN_ON(!pmd_none(*new_pmd))) {
 		VM_BUG_ON(pmd_trans_huge(*new_pmd));
-		goto out;
+		return 0;
 	}
 
 	/*
 	 * We don't have to worry about the ordering of src and dst
 	 * ptlocks because exclusive mmap_sem prevents deadlock.
 	 */
-	ret = __pmd_trans_huge_lock(old_pmd, vma, &old_ptl);
-	if (ret == 1) {
+	if (__pmd_trans_huge_lock(old_pmd, vma, &old_ptl)) {
 		new_ptl = pmd_lockptr(mm, new_pmd);
 		if (new_ptl != old_ptl)
 			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
@@ -1484,9 +1473,9 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		if (new_ptl != old_ptl)
 			spin_unlock(new_ptl);
 		spin_unlock(old_ptl);
+		return 1;
 	}
-out:
-	return ret;
+	return 0;
 }
 
 /*
@@ -1502,7 +1491,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	spinlock_t *ptl;
 	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		pmd_t entry;
 		bool preserve_write = prot_numa && pmd_write(*pmd);
 		ret = 1;
@@ -1543,17 +1532,8 @@ int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl)
 {
 	*ptl = pmd_lock(vma->vm_mm, pmd);
-	if (likely(pmd_trans_huge(*pmd))) {
-		if (unlikely(pmd_trans_splitting(*pmd))) {
-			spin_unlock(*ptl);
-			wait_split_huge_page(vma->anon_vma, pmd);
-			return -1;
-		} else {
-			/* Thp mapped by 'pmd' is stable, so we can
-			 * handle it as it is. */
-			return 1;
-		}
-	}
+	if (likely(pmd_trans_huge(*pmd)))
+		return 1;
 	spin_unlock(*ptl);
 	return 0;
 }
@@ -1569,7 +1549,6 @@ int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 pmd_t *page_check_address_pmd(struct page *page,
 			      struct mm_struct *mm,
 			      unsigned long address,
-			      enum page_check_address_pmd_flag flag,
 			      spinlock_t **ptl)
 {
 	pgd_t *pgd;
@@ -1592,21 +1571,8 @@ pmd_t *page_check_address_pmd(struct page *page,
 		goto unlock;
 	if (pmd_page(*pmd) != page)
 		goto unlock;
-	/*
-	 * split_vma() may create temporary aliased mappings. There is
-	 * no risk as long as all huge pmd are found and have their
-	 * splitting bit set before __split_huge_page_refcount
-	 * runs. Finding the same huge pmd more than once during the
-	 * same rmap walk is not a problem.
-	 */
-	if (flag == PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG &&
-	    pmd_trans_splitting(*pmd))
-		goto unlock;
-	if (pmd_trans_huge(*pmd)) {
-		VM_BUG_ON(flag == PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG &&
-			  !pmd_trans_splitting(*pmd));
+	if (pmd_trans_huge(*pmd))
 		return pmd;
-	}
 unlock:
 	spin_unlock(*ptl);
 	return NULL;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f659d4f77138..1bc6a77067ad 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4888,7 +4888,7 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
 			mc.precharge += HPAGE_PMD_NR;
 		spin_unlock(ptl);
@@ -5056,17 +5056,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	union mc_target target;
 	struct page *page;
 
-	/*
-	 * We don't take compound_lock() here but no race with splitting thp
-	 * happens because:
-	 *  - if pmd_trans_huge_lock() returns 1, the relevant thp is not
-	 *    under splitting, which means there's no concurrent thp split,
-	 *  - if another thread runs into split_huge_page() just after we
-	 *    entered this if-block, the thread must wait for page table lock
-	 *    to be unlocked in __split_huge_page_splitting(), where the main
-	 *    part of thp split is not executed yet.
-	 */
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		if (mc.precharge < HPAGE_PMD_NR) {
 			spin_unlock(ptl);
 			return 0;
diff --git a/mm/memory.c b/mm/memory.c
index 61e7ed722760..1bad3766b00c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -565,7 +565,6 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	spinlock_t *ptl;
 	pgtable_t new = pte_alloc_one(mm, address);
-	int wait_split_huge_page;
 	if (!new)
 		return -ENOMEM;
 
@@ -585,18 +584,14 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */
 
 	ptl = pmd_lock(mm, pmd);
-	wait_split_huge_page = 0;
 	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
 		atomic_long_inc(&mm->nr_ptes);
 		pmd_populate(mm, pmd, new);
 		new = NULL;
-	} else if (unlikely(pmd_trans_splitting(*pmd)))
-		wait_split_huge_page = 1;
+	}
 	spin_unlock(ptl);
 	if (new)
 		pte_free(mm, new);
-	if (wait_split_huge_page)
-		wait_split_huge_page(vma->anon_vma, pmd);
 	return 0;
 }
 
@@ -612,8 +607,7 @@ int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
 	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
 		pmd_populate_kernel(&init_mm, pmd, new);
 		new = NULL;
-	} else
-		VM_BUG_ON(pmd_trans_splitting(*pmd));
+	}
 	spin_unlock(&init_mm.page_table_lock);
 	if (new)
 		pte_free_kernel(&init_mm, new);
@@ -3299,14 +3293,6 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (pmd_trans_huge(orig_pmd)) {
 			unsigned int dirty = flags & FAULT_FLAG_WRITE;
 
-			/*
-			 * If the pmd is splitting, return and retry the
-			 * the fault.  Alternative: wait until the split
-			 * is done, and goto retry.
-			 */
-			if (pmd_trans_splitting(orig_pmd))
-				return 0;
-
 			if (pmd_protnone(orig_pmd))
 				return do_huge_pmd_numa_page(mm, vma, address,
 							     orig_pmd, pmd);
diff --git a/mm/mincore.c b/mm/mincore.c
index be25efde64a4..feb867f5fdf4 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -117,7 +117,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	unsigned char *vec = walk->private;
 	int nr = (end - addr) >> PAGE_SHIFT;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		memset(vec, 1, nr);
 		spin_unlock(ptl);
 		goto out;
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index c25f94b33811..2fe699cedd4d 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -133,20 +133,6 @@ pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
-#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
-			  pmd_t *pmdp)
-{
-	pmd_t pmd = pmd_mksplitting(*pmdp);
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	set_pmd_at(vma->vm_mm, address, pmdp, pmd);
-	/* tlb flush only to serialize against gup-fast */
-	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
-}
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-#endif
-
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
diff --git a/mm/rmap.c b/mm/rmap.c
index 4ca4b5cffd95..1636a96e5f71 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -737,8 +737,7 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		 * rmap might return false positives; we must filter
 		 * these out using page_check_address_pmd().
 		 */
-		pmd = page_check_address_pmd(page, mm, address,
-					     PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
+		pmd = page_check_address_pmd(page, mm, address, &ptl);
 		if (!pmd)
 			return SWAP_AGAIN;
 
@@ -748,7 +747,6 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			return SWAP_FAIL; /* To break the loop */
 		}
 
-		/* go ahead even if the pmd is pmd_trans_splitting() */
 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

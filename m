Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9454E6B00A6
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 12:05:09 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so4938580pde.4
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 09:05:09 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xo10si2807592pac.162.2014.06.09.09.05.08
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 09:05:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 07/10] mm, thp: remove infrastructure for handling splitting PMDs
Date: Mon,  9 Jun 2014 19:04:18 +0300
Message-Id: <1402329861-7037-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting we don't need to mark PMDs splitting. Let's drop code
to handle this.

Arch-specific code will removed separately.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c            |  9 +++--
 include/asm-generic/pgtable.h |  5 ---
 include/linux/huge_mm.h       | 33 -----------------
 mm/gup.c                      | 14 +++-----
 mm/huge_memory.c              | 83 +++++++++----------------------------------
 mm/memcontrol.c               | 16 +++------
 mm/memory.c                   | 18 ++--------
 mm/pgtable-generic.c          | 14 --------
 mm/rmap.c                     |  4 +--
 9 files changed, 33 insertions(+), 163 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 25e5a1e044f2..ba99643add30 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -504,7 +504,8 @@ static int smaps_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
 	struct mem_size_stats *mss = walk->private;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, walk->vma, &ptl) == 1) {
+	ptl = pmd_lock(walk->vma->vm_mm, pmd);
+	if (likely(pmd_trans_huge(*pmd))) {
 		smaps_pte((pte_t *)pmd, addr, addr + HPAGE_PMD_SIZE, walk);
 		spin_unlock(ptl);
 		mss->anonymous_thp += HPAGE_PMD_SIZE;
@@ -993,7 +994,8 @@ static int pagemap_pmd(pmd_t *pmd, unsigned long addr, unsigned long end,
 
 	if (!vma)
 		return err;
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	ptl = pmd_lock(vma->vm_mm, pmd);
+	if (likely(pmd_trans_huge(*pmd))) {
 		int pmd_flags2;
 
 		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
@@ -1285,7 +1287,8 @@ static int gather_pmd_stats(pmd_t *pmd, unsigned long addr,
 	struct vm_area_struct *vma = walk->vma;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	ptl = pmd_lock(vma->vm_mm, pmd);
+	if (likely(pmd_trans_huge(*pmd))) {
 		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 53b2acc38213..204fa5db3068 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -167,11 +167,6 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
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
index 5e9d26cd98b7..cdb88f93f1fd 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -46,15 +46,9 @@ enum transparent_hugepage_flag {
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
 
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
@@ -110,14 +104,6 @@ extern void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		if (unlikely(pmd_trans_huge(*____pmd)))			\
 			__split_huge_pmd(__vma, __pmd, __address);	\
 	}  while (0)
-#define wait_split_huge_page(__anon_vma, __pmd)				\
-	do {								\
-		pmd_t *____pmd = (__pmd);				\
-		anon_vma_lock_write(__anon_vma);			\
-		anon_vma_unlock_write(__anon_vma);			\
-		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
-		       pmd_trans_huge(*____pmd));			\
-	} while (0)
 #if HPAGE_PMD_ORDER >= MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
@@ -127,18 +113,6 @@ extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
 				    long adjust_next);
-extern int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
-		spinlock_t **ptl);
-/* mmap_sem must be held on entry */
-static inline int pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
-		spinlock_t **ptl)
-{
-	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
-	if (pmd_trans_huge(*pmd))
-		return __pmd_trans_huge_lock(pmd, vma, ptl);
-	else
-		return 0;
-}
 static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 					 unsigned long start,
 					 unsigned long end,
@@ -177,8 +151,6 @@ static inline int split_huge_page(struct page *page)
 {
 	return 0;
 }
-#define wait_split_huge_page(__anon_vma, __pmd)	\
-	do { } while (0)
 #define split_huge_pmd(__vma, __pmd, __address)	\
 	do { } while (0)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
@@ -193,11 +165,6 @@ static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 					 long adjust_next)
 {
 }
-static inline int pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
-		spinlock_t **ptl)
-{
-	return 0;
-}
 
 static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 					unsigned long addr, pmd_t pmd, pmd_t *pmdp)
diff --git a/mm/gup.c b/mm/gup.c
index ac01800abce6..1c0b777144a4 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -194,16 +194,10 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	if (pmd_trans_huge(*pmd)) {
 		ptl = pmd_lock(mm, pmd);
 		if (likely(pmd_trans_huge(*pmd))) {
-			if (unlikely(pmd_trans_splitting(*pmd))) {
-				spin_unlock(ptl);
-				wait_split_huge_page(vma->anon_vma, pmd);
-			} else {
-				page = follow_trans_huge_pmd(vma, address,
-							     pmd, flags);
-				spin_unlock(ptl);
-				*page_mask = HPAGE_PMD_NR - 1;
-				return page;
-			}
+			page = follow_trans_huge_pmd(vma, address, pmd, flags);
+			spin_unlock(ptl);
+			*page_mask = HPAGE_PMD_NR - 1;
+			return page;
 		} else
 			spin_unlock(ptl);
 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 89c6f098f91f..31a7904994cc 100644
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
@@ -1346,7 +1337,8 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	ptl = pmd_lock(vma->vm_mm, pmd);
+	if (likely(pmd_trans_huge(*pmd))) {
 		struct page *page;
 		pgtable_t pgtable;
 		pmd_t orig_pmd;
@@ -1386,16 +1378,16 @@ int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	spinlock_t *ptl;
 	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	ptl = pmd_lock(vma->vm_mm, pmd);
+	if (pmd_trans_huge(*pmd)) {
 		/*
 		 * All logical pages in the range are present
 		 * if backed by a huge page.
 		 */
-		spin_unlock(ptl);
 		memset(vec, 1, (end - addr) >> PAGE_SHIFT);
 		ret = 1;
 	}
-
+	spin_unlock(ptl);
 	return ret;
 }
 
@@ -1405,7 +1397,6 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		  pmd_t *old_pmd, pmd_t *new_pmd)
 {
 	spinlock_t *old_ptl, *new_ptl;
-	int ret = 0;
 	pmd_t pmd;
 
 	struct mm_struct *mm = vma->vm_mm;
@@ -1414,7 +1405,7 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 	    (new_addr & ~HPAGE_PMD_MASK) ||
 	    old_end - old_addr < HPAGE_PMD_SIZE ||
 	    (new_vma->vm_flags & VM_NOHUGEPAGE))
-		goto out;
+		return 0;
 
 	/*
 	 * The destination pmd shouldn't be established, free_pgtables()
@@ -1422,15 +1413,15 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
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
+	old_ptl = pmd_lock(vma->vm_mm, old_pmd);
+	if (likely(pmd_trans_huge(*old_pmd))) {
 		new_ptl = pmd_lockptr(mm, new_pmd);
 		if (new_ptl != old_ptl)
 			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
@@ -1445,10 +1436,9 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
 		if (new_ptl != old_ptl)
 			spin_unlock(new_ptl);
-		spin_unlock(old_ptl);
 	}
-out:
-	return ret;
+	spin_unlock(old_ptl);
+	return 1;
 }
 
 /*
@@ -1464,7 +1454,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	spinlock_t *ptl;
 	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	ptl = pmd_lock(vma->vm_mm, pmd);
+	if (likely(pmd_trans_huge(*pmd))) {
 		pmd_t entry;
 		ret = 1;
 		if (!prot_numa) {
@@ -1490,39 +1481,12 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 				ret = HPAGE_PMD_NR;
 			}
 		}
-		spin_unlock(ptl);
 	}
-
+	spin_unlock(ptl);
 	return ret;
 }
 
 /*
- * Returns 1 if a given pmd maps a stable (not under splitting) thp.
- * Returns -1 if it maps a thp under splitting. Returns 0 otherwise.
- *
- * Note that if it returns 1, this routine returns without unlocking page
- * table locks. So callers must unlock them.
- */
-int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
-		spinlock_t **ptl)
-{
-	*ptl = pmd_lock(vma->vm_mm, pmd);
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
-	spin_unlock(*ptl);
-	return 0;
-}
-
-/*
  * This function returns whether a given @page is mapped onto the @address
  * in the virtual space of @mm.
  *
@@ -1533,7 +1497,6 @@ int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 pmd_t *page_check_address_pmd(struct page *page,
 			      struct mm_struct *mm,
 			      unsigned long address,
-			      enum page_check_address_pmd_flag flag,
 			      spinlock_t **ptl)
 {
 	pgd_t *pgd;
@@ -1556,21 +1519,8 @@ pmd_t *page_check_address_pmd(struct page *page,
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
@@ -1750,8 +1700,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		spinlock_t *ptl;
 		pmd_t *pmd;
 
-		pmd = page_check_address_pmd(page, vma->vm_mm, addr,
-				PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
+		pmd = page_check_address_pmd(page, vma->vm_mm, addr, &ptl);
 		if (pmd)
 			__split_huge_pmd(vma, pmd, addr);
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0ab520c4d630..5fceff94f9b6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6733,7 +6733,8 @@ static int mem_cgroup_count_precharge_pmd(pmd_t *pmd,
 	struct vm_area_struct *vma = walk->vma;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	ptl = pmd_lock(vma->vm_mm, pmd);
+	if (likely(pmd_trans_huge(*pmd))) {
 		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
 			mc.precharge += HPAGE_PMD_NR;
 		spin_unlock(ptl);
@@ -6902,17 +6903,8 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	struct page *page;
 	struct page_cgroup *pc;
 
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
+	ptl = pmd_lock(vma->vm_mm, pmd);
+	if (likely(pmd_trans_huge(*pmd))) {
 		if (mc.precharge < HPAGE_PMD_NR) {
 			spin_unlock(ptl);
 			return 0;
diff --git a/mm/memory.c b/mm/memory.c
index 805ff8d76e17..6af9f92e1936 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -563,7 +563,6 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	spinlock_t *ptl;
 	pgtable_t new = pte_alloc_one(mm, address);
-	int wait_split_huge_page;
 	if (!new)
 		return -ENOMEM;
 
@@ -583,18 +582,14 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
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
 
@@ -610,8 +605,7 @@ int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
 	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
 		pmd_populate_kernel(&init_mm, pmd, new);
 		new = NULL;
-	} else
-		VM_BUG_ON(pmd_trans_splitting(*pmd));
+	}
 	spin_unlock(&init_mm.page_table_lock);
 	if (new)
 		pte_free_kernel(&init_mm, new);
@@ -3270,14 +3264,6 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
 			if (pmd_numa(orig_pmd))
 				return do_huge_pmd_numa_page(mm, vma, address,
 							     orig_pmd, pmd);
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index a8b919925934..414f36c6e8f9 100644
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
index c3b0b397f2c2..cc820bd509e2 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -682,8 +682,7 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		 * rmap might return false positives; we must filter
 		 * these out using page_check_address_pmd().
 		 */
-		pmd = page_check_address_pmd(page, mm, address,
-					     PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
+		pmd = page_check_address_pmd(page, mm, address, &ptl);
 		if (!pmd)
 			return SWAP_AGAIN;
 
@@ -693,7 +692,6 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			return SWAP_FAIL; /* To break the loop */
 		}
 
-		/* go ahead even if the pmd is pmd_trans_splitting() */
 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
 		spin_unlock(ptl);
-- 
2.0.0.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

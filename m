Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 269386B0032
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 09:52:48 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so7867456pdb.1
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:52:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id a4si34755388pdi.249.2015.06.23.06.47.23
        for <linux-mm@kvack.org>;
        Tue, 23 Jun 2015 06:47:24 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 25/36] mm, thp: remove infrastructure for handling splitting PMDs
Date: Tue, 23 Jun 2015 16:46:35 +0300
Message-Id: <1435067206-92901-26-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting we don't need to mark PMDs splitting. Let's drop code
to handle this.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 fs/proc/task_mmu.c            |  8 +++---
 include/asm-generic/pgtable.h |  9 -------
 include/linux/huge_mm.h       | 21 +++++----------
 mm/gup.c                      | 12 +--------
 mm/huge_memory.c              | 60 ++++++++++---------------------------------
 mm/memcontrol.c               | 13 ++--------
 mm/memory.c                   | 18 ++-----------
 mm/mincore.c                  |  2 +-
 mm/mremap.c                   | 15 +++++------
 mm/pgtable-generic.c          | 14 ----------
 mm/rmap.c                     |  4 +--
 11 files changed, 37 insertions(+), 139 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 33051361c156..d860fc4a8433 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -548,7 +548,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		smaps_pmd_entry(pmd, addr, walk);
 		spin_unlock(ptl);
 		return 0;
@@ -815,7 +815,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 	spinlock_t *ptl;
 	struct page *page;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
 			clear_soft_dirty_pmd(vma, addr, pmd);
 			goto out;
@@ -1128,7 +1128,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	pte_t *pte, *orig_pte;
 	int err = 0;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		int pmd_flags2;
 
 		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(*pmd))
@@ -1435,7 +1435,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 	pte_t *orig_pte;
 	pte_t *pte;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 7a70de9ee890..2a952995d8ed 100644
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
 #ifndef pmdp_collapse_flush
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
@@ -581,10 +576,6 @@ static inline int pmd_trans_huge(pmd_t pmd)
 {
 	return 0;
 }
-static inline int pmd_trans_splitting(pmd_t pmd)
-{
-	return 0;
-}
 #ifndef __HAVE_ARCH_PMD_WRITE
 static inline int pmd_write(pmd_t pmd)
 {
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 47f80207782f..67b3f3760f4a 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -28,7 +28,7 @@ extern int zap_huge_pmd(struct mmu_gather *tlb,
 extern int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, unsigned long end,
 			unsigned char *vec);
-extern int move_huge_pmd(struct vm_area_struct *vma,
+extern bool move_huge_pmd(struct vm_area_struct *vma,
 			 struct vm_area_struct *new_vma,
 			 unsigned long old_addr,
 			 unsigned long new_addr, unsigned long old_end,
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
@@ -112,17 +105,17 @@ extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
 				    long adjust_next);
-extern int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
+extern bool __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl);
 /* mmap_sem must be held on entry */
-static inline int pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
+static inline bool pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl)
 {
 	VM_BUG_ON_VMA(!rwsem_is_locked(&vma->vm_mm->mmap_sem), vma);
 	if (pmd_trans_huge(*pmd))
 		return __pmd_trans_huge_lock(pmd, vma, ptl);
 	else
-		return 0;
+		return false;
 }
 static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 					 unsigned long start,
@@ -169,8 +162,6 @@ static inline int split_huge_page(struct page *page)
 {
 	return 0;
 }
-#define wait_split_huge_page(__anon_vma, __pmd)	\
-	do { } while (0)
 #define split_huge_pmd(__vma, __pmd, __address)	\
 	do { } while (0)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
@@ -185,10 +176,10 @@ static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 					 long adjust_next)
 {
 }
-static inline int pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
+static inline bool pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 		spinlock_t **ptl)
 {
-	return 0;
+	return false;
 }
 
 static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
diff --git a/mm/gup.c b/mm/gup.c
index f0f390fb9213..3ab0a8a7b255 100644
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
@@ -1023,9 +1016,6 @@ struct page *get_dump_page(unsigned long addr)
  *  *) HAVE_RCU_TABLE_FREE is enabled, and tlb_remove_table is used to free
  *      pages containing page tables.
  *
- *  *) THP splits will broadcast an IPI, this can be achieved by overriding
- *      pmdp_splitting_flush.
- *
  *  *) ptes can be read atomically by the architecture.
  *
  *  *) access_ok is sufficient to validate userspace address ranges.
@@ -1222,7 +1212,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		pmd_t pmd = READ_ONCE(*pmdp);
 
 		next = pmd_addr_end(addr, end);
-		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+		if (pmd_none(pmd))
 			return 0;
 
 		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 70fff4c9e067..efe52b5bd979 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -914,15 +914,6 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
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
@@ -1428,7 +1419,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		struct page *page;
 		pgtable_t pgtable;
 		pmd_t orig_pmd;
@@ -1462,13 +1453,12 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	return ret;
 }
 
-int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
+bool move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		  unsigned long old_addr,
 		  unsigned long new_addr, unsigned long old_end,
 		  pmd_t *old_pmd, pmd_t *new_pmd)
 {
 	spinlock_t *old_ptl, *new_ptl;
-	int ret = 0;
 	pmd_t pmd;
 
 	struct mm_struct *mm = vma->vm_mm;
@@ -1477,7 +1467,7 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 	    (new_addr & ~HPAGE_PMD_MASK) ||
 	    old_end - old_addr < HPAGE_PMD_SIZE ||
 	    (new_vma->vm_flags & VM_NOHUGEPAGE))
-		goto out;
+		return false;
 
 	/*
 	 * The destination pmd shouldn't be established, free_pgtables()
@@ -1485,15 +1475,14 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 	 */
 	if (WARN_ON(!pmd_none(*new_pmd))) {
 		VM_BUG_ON(pmd_trans_huge(*new_pmd));
-		goto out;
+		return false;
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
@@ -1509,9 +1498,9 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		if (new_ptl != old_ptl)
 			spin_unlock(new_ptl);
 		spin_unlock(old_ptl);
+		return true;
 	}
-out:
-	return ret;
+	return false;
 }
 
 /*
@@ -1527,7 +1516,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	spinlock_t *ptl;
 	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		pmd_t entry;
 		bool preserve_write = prot_numa && pmd_write(*pmd);
 		ret = 1;
@@ -1564,23 +1553,14 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
  * Note that if it returns 1, this routine returns without unlocking page
  * table locks. So callers must unlock them.
  */
-int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
+bool __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
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
+		return true;
 	spin_unlock(*ptl);
-	return 0;
+	return false;
 }
 
 /*
@@ -1594,7 +1574,6 @@ int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
 pmd_t *page_check_address_pmd(struct page *page,
 			      struct mm_struct *mm,
 			      unsigned long address,
-			      enum page_check_address_pmd_flag flag,
 			      spinlock_t **ptl)
 {
 	pgd_t *pgd;
@@ -1617,21 +1596,8 @@ pmd_t *page_check_address_pmd(struct page *page,
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
index e00d6b53b55b..ea5b0e373d79 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4896,7 +4896,7 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl)) {
 		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
 			mc.precharge += HPAGE_PMD_NR;
 		spin_unlock(ptl);
@@ -5064,16 +5064,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	union mc_target target;
 	struct page *page;
 
-	/*
-	 * No race with splitting thp happens because:
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
index d37aeda3a8fe..ff2e8ed5b82a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -566,7 +566,6 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	spinlock_t *ptl;
 	pgtable_t new = pte_alloc_one(mm, address);
-	int wait_split_huge_page;
 	if (!new)
 		return -ENOMEM;
 
@@ -586,18 +585,14 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
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
 
@@ -613,8 +608,7 @@ int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
 	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
 		pmd_populate_kernel(&init_mm, pmd, new);
 		new = NULL;
-	} else
-		VM_BUG_ON(pmd_trans_splitting(*pmd));
+	}
 	spin_unlock(&init_mm.page_table_lock);
 	if (new)
 		pte_free_kernel(&init_mm, new);
@@ -3343,14 +3337,6 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
diff --git a/mm/mremap.c b/mm/mremap.c
index d9cc4debd3aa..09b8b9b24c05 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -192,25 +192,24 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
 		if (!new_pmd)
 			break;
 		if (pmd_trans_huge(*old_pmd)) {
-			int err = 0;
 			if (extent == HPAGE_PMD_SIZE) {
+				bool moved;
 				VM_BUG_ON_VMA(vma->vm_file || !vma->anon_vma,
 					      vma);
 				/* See comment in move_ptes() */
 				if (need_rmap_locks)
 					anon_vma_lock_write(vma->anon_vma);
-				err = move_huge_pmd(vma, new_vma, old_addr,
+				moved = move_huge_pmd(vma, new_vma, old_addr,
 						    new_addr, old_end,
 						    old_pmd, new_pmd);
 				if (need_rmap_locks)
 					anon_vma_unlock_write(vma->anon_vma);
+				if (moved) {
+					need_flush = true;
+					continue;
+				}
 			}
-			if (err > 0) {
-				need_flush = true;
-				continue;
-			} else if (!err) {
-				split_huge_pmd(vma, old_pmd, old_addr);
-			}
+			split_huge_pmd(vma, old_pmd, old_addr);
 			VM_BUG_ON(pmd_trans_huge(*old_pmd));
 		}
 		if (pmd_none(*new_pmd) && __pte_alloc(new_vma->vm_mm, new_vma,
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 6b674e00153c..89b150f8c920 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -134,20 +134,6 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
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
index 51807d605ebf..0e3851661487 100644
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

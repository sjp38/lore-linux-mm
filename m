Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 04A896B0037
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:19:24 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/2] thp: support split page table lock
Date: Fri, 30 Aug 2013 13:18:40 -0400
Message-Id: <1377883120-5280-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1377883120-5280-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1377883120-5280-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org

Thp related code also uses per process mm->page_table_lock now. So making
it fine-grained can provide better performance.

This patch makes thp support split page table lock which makes us use
page->ptl of the pages storing "pmd_trans_huge" pmds.

Some functions like pmd_trans_huge_lock() and page_check_address_pmd()
are expected by their caller to pass back the pointer of ptl, so this
patch adds to those functions the arguments for that. Rather than that,
this patch gives only straightforward replacement.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/powerpc/mm/pgtable_64.c |   8 +-
 arch/s390/mm/pgtable.c       |   4 +-
 arch/sparc/mm/tlb.c          |   4 +-
 fs/proc/task_mmu.c           |  17 +++--
 include/linux/huge_mm.h      |  11 +--
 include/linux/mm.h           |   3 +
 mm/huge_memory.c             | 170 ++++++++++++++++++++++++++-----------------
 mm/memcontrol.c              |  14 ++--
 mm/memory.c                  |  15 ++--
 mm/migrate.c                 |   8 +-
 mm/mprotect.c                |   5 +-
 mm/pgtable-generic.c         |  10 +--
 mm/rmap.c                    |  11 ++-
 13 files changed, 161 insertions(+), 119 deletions(-)

diff --git v3.11-rc3.orig/arch/powerpc/mm/pgtable_64.c v3.11-rc3/arch/powerpc/mm/pgtable_64.c
index 536eec72..f9177eb 100644
--- v3.11-rc3.orig/arch/powerpc/mm/pgtable_64.c
+++ v3.11-rc3/arch/powerpc/mm/pgtable_64.c
@@ -605,7 +605,7 @@ void pmdp_splitting_flush(struct vm_area_struct *vma,
 
 #ifdef CONFIG_DEBUG_VM
 	WARN_ON(!pmd_trans_huge(*pmdp));
-	assert_spin_locked(&vma->vm_mm->page_table_lock);
+	assert_spin_locked(huge_pmd_lockptr(vma->vm_mm, pmdp));
 #endif
 
 #ifdef PTE_ATOMIC_UPDATES
@@ -643,7 +643,7 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				pgtable_t pgtable)
 {
 	pgtable_t *pgtable_slot;
-	assert_spin_locked(&mm->page_table_lock);
+	assert_spin_locked(huge_pmd_lockptr(mm, pmdp));
 	/*
 	 * we store the pgtable in the second half of PMD
 	 */
@@ -663,7 +663,7 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	pgtable_t pgtable;
 	pgtable_t *pgtable_slot;
 
-	assert_spin_locked(&mm->page_table_lock);
+	assert_spin_locked(huge_pmd_lockptr(mm, pmdp));
 	pgtable_slot = (pgtable_t *)pmdp + PTRS_PER_PMD;
 	pgtable = *pgtable_slot;
 	/*
@@ -687,7 +687,7 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 {
 #ifdef CONFIG_DEBUG_VM
 	WARN_ON(!pmd_none(*pmdp));
-	assert_spin_locked(&mm->page_table_lock);
+	assert_spin_locked(huge_pmd_lockptr(mm, pmdp));
 	WARN_ON(!pmd_trans_huge(pmd));
 #endif
 	return set_pte_at(mm, addr, pmdp_ptep(pmdp), pmd_pte(pmd));
diff --git v3.11-rc3.orig/arch/s390/mm/pgtable.c v3.11-rc3/arch/s390/mm/pgtable.c
index a8154a1..d6c6b5c 100644
--- v3.11-rc3.orig/arch/s390/mm/pgtable.c
+++ v3.11-rc3/arch/s390/mm/pgtable.c
@@ -1170,7 +1170,7 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 {
 	struct list_head *lh = (struct list_head *) pgtable;
 
-	assert_spin_locked(&mm->page_table_lock);
+	assert_spin_locked(huge_pmd_lockptr(mm, pmdp));
 
 	/* FIFO */
 	if (!mm->pmd_huge_pte)
@@ -1186,7 +1186,7 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	pgtable_t pgtable;
 	pte_t *ptep;
 
-	assert_spin_locked(&mm->page_table_lock);
+	assert_spin_locked(huge_pmd_lockptr(mm, pmdp));
 
 	/* FIFO */
 	pgtable = mm->pmd_huge_pte;
diff --git v3.11-rc3.orig/arch/sparc/mm/tlb.c v3.11-rc3/arch/sparc/mm/tlb.c
index 7a91f28..cca3bed 100644
--- v3.11-rc3.orig/arch/sparc/mm/tlb.c
+++ v3.11-rc3/arch/sparc/mm/tlb.c
@@ -193,7 +193,7 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 {
 	struct list_head *lh = (struct list_head *) pgtable;
 
-	assert_spin_locked(&mm->page_table_lock);
+	assert_spin_locked(huge_pmd_lockptr(mm, pmdp));
 
 	/* FIFO */
 	if (!mm->pmd_huge_pte)
@@ -208,7 +208,7 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	struct list_head *lh;
 	pgtable_t pgtable;
 
-	assert_spin_locked(&mm->page_table_lock);
+	assert_spin_locked(huge_pmd_lockptr(mm, pmdp));
 
 	/* FIFO */
 	pgtable = mm->pmd_huge_pte;
diff --git v3.11-rc3.orig/fs/proc/task_mmu.c v3.11-rc3/fs/proc/task_mmu.c
index dbf61f6..e23c882 100644
--- v3.11-rc3.orig/fs/proc/task_mmu.c
+++ v3.11-rc3/fs/proc/task_mmu.c
@@ -503,11 +503,11 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	struct mem_size_stats *mss = walk->private;
 	struct vm_area_struct *vma = mss->vma;
 	pte_t *pte;
-	spinlock_t *ptl;
+	spinlock_t *uninitialized_var(ptl);
 
-	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_PMD_SIZE, walk);
-		spin_unlock(&walk->mm->page_table_lock);
+		spin_unlock(ptl);
 		mss->anonymous_thp += HPAGE_PMD_SIZE;
 		return 0;
 	}
@@ -980,10 +980,11 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	pte_t *pte;
 	int err = 0;
 	pagemap_entry_t pme = make_pme(PM_NOT_PRESENT(pm->v2));
+	spinlock_t *uninitialized_var(ptl);
 
 	/* find the first VMA at or above 'addr' */
 	vma = find_vma(walk->mm, addr);
-	if (vma && pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (vma && pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		int pmd_flags2;
 
 		pmd_flags2 = (pmd_soft_dirty(*pmd) ? __PM_SOFT_DIRTY : 0);
@@ -997,7 +998,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			if (err)
 				break;
 		}
-		spin_unlock(&walk->mm->page_table_lock);
+		spin_unlock(ptl);
 		return err;
 	}
 
@@ -1276,13 +1277,13 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 		unsigned long end, struct mm_walk *walk)
 {
 	struct numa_maps *md;
-	spinlock_t *ptl;
+	spinlock_t *uninitialized_var(ptl);
 	pte_t *orig_pte;
 	pte_t *pte;
 
 	md = walk->private;
 
-	if (pmd_trans_huge_lock(pmd, md->vma) == 1) {
+	if (pmd_trans_huge_lock(pmd, md->vma, &ptl) == 1) {
 		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
@@ -1290,7 +1291,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 		if (page)
 			gather_stats(page, md, pte_dirty(huge_pte),
 				     HPAGE_PMD_SIZE/PAGE_SIZE);
-		spin_unlock(&walk->mm->page_table_lock);
+		spin_unlock(ptl);
 		return 0;
 	}
 
diff --git v3.11-rc3.orig/include/linux/huge_mm.h v3.11-rc3/include/linux/huge_mm.h
index b60de92..1faf757 100644
--- v3.11-rc3.orig/include/linux/huge_mm.h
+++ v3.11-rc3/include/linux/huge_mm.h
@@ -54,7 +54,8 @@ enum page_check_address_pmd_flag {
 extern pmd_t *page_check_address_pmd(struct page *page,
 				     struct mm_struct *mm,
 				     unsigned long address,
-				     enum page_check_address_pmd_flag flag);
+				     enum page_check_address_pmd_flag flag,
+				     spinlock_t **ptl);
 
 #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
 #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
@@ -133,14 +134,14 @@ extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long end,
 				    long adjust_next);
 extern int __pmd_trans_huge_lock(pmd_t *pmd,
-				 struct vm_area_struct *vma);
+				 struct vm_area_struct *vma, spinlock_t **ptl);
 /* mmap_sem must be held on entry */
 static inline int pmd_trans_huge_lock(pmd_t *pmd,
-				      struct vm_area_struct *vma)
+				struct vm_area_struct *vma, spinlock_t **ptl)
 {
 	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
 	if (pmd_trans_huge(*pmd))
-		return __pmd_trans_huge_lock(pmd, vma);
+		return __pmd_trans_huge_lock(pmd, vma, ptl);
 	else
 		return 0;
 }
@@ -219,7 +220,7 @@ static inline void vma_adjust_trans_huge(struct vm_area_struct *vma,
 {
 }
 static inline int pmd_trans_huge_lock(pmd_t *pmd,
-				      struct vm_area_struct *vma)
+				struct vm_area_struct *vma, spinlock_t **ptl)
 {
 	return 0;
 }
diff --git v3.11-rc3.orig/include/linux/mm.h v3.11-rc3/include/linux/mm.h
index f022460..9219f43 100644
--- v3.11-rc3.orig/include/linux/mm.h
+++ v3.11-rc3/include/linux/mm.h
@@ -1251,6 +1251,8 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
 } while (0)
 #define pte_lock_deinit(page)	((page)->mapping = NULL)
 #define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
+#define huge_pmd_lockptr(mm, pmdp) \
+		({(void)(mm); __pte_lockptr(virt_to_page(pmdp)); })
 #else	/* !USE_SPLIT_PTLOCKS */
 /*
  * We use mm->page_table_lock to guard all pagetable pages of the mm.
@@ -1258,6 +1260,7 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
 #define pte_lock_init(page)	do {} while (0)
 #define pte_lock_deinit(page)	do {} while (0)
 #define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
+#define huge_pmd_lockptr(mm, pmdp) ({(void)(pmd); &(mm)->page_table_lock; })
 #endif /* USE_SPLIT_PTLOCKS */
 
 static inline void pgtable_page_ctor(struct page *page)
diff --git v3.11-rc3.orig/mm/huge_memory.c v3.11-rc3/mm/huge_memory.c
index 243e710..3cb29e1 100644
--- v3.11-rc3.orig/mm/huge_memory.c
+++ v3.11-rc3/mm/huge_memory.c
@@ -705,6 +705,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct page *page)
 {
 	pgtable_t pgtable;
+	spinlock_t *ptl;
 
 	VM_BUG_ON(!PageCompound(page));
 	pgtable = pte_alloc_one(mm, haddr);
@@ -719,9 +720,10 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	 */
 	__SetPageUptodate(page);
 
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pmd_lockptr(mm, pmd);
+	spin_lock(ptl);
 	if (unlikely(!pmd_none(*pmd))) {
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 		mem_cgroup_uncharge_page(page);
 		put_page(page);
 		pte_free(mm, pgtable);
@@ -733,7 +735,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		set_pmd_at(mm, haddr, pmd, entry);
 		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		mm->nr_ptes++;
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 	}
 
 	return 0;
@@ -761,6 +763,7 @@ static inline struct page *alloc_hugepage(int defrag)
 }
 #endif
 
+/* Caller must hold page table lock. */
 static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
 		struct page *zero_page)
@@ -804,10 +807,11 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				count_vm_event(THP_FAULT_FALLBACK);
 				goto out;
 			}
-			spin_lock(&mm->page_table_lock);
+			ptl = huge_pmd_lockptr(mm, pmd);
+			spin_lock(ptl);
 			set = set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
 					zero_page);
-			spin_unlock(&mm->page_table_lock);
+			spin_unlock(ptl);
 			if (!set) {
 				pte_free(mm, pgtable);
 				put_huge_zero_page();
@@ -864,14 +868,17 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	pmd_t pmd;
 	pgtable_t pgtable;
 	int ret;
+	spinlock_t *uninitialized_var(dst_ptl), *uninitialized_var(src_ptl);
 
 	ret = -ENOMEM;
 	pgtable = pte_alloc_one(dst_mm, addr);
 	if (unlikely(!pgtable))
 		goto out;
 
-	spin_lock(&dst_mm->page_table_lock);
-	spin_lock_nested(&src_mm->page_table_lock, SINGLE_DEPTH_NESTING);
+	dst_ptl = huge_pmd_lockptr(dst_mm, dst_ptl);
+	src_ptl = huge_pmd_lockptr(src_mm, src_ptl);
+	spin_lock(dst_ptl);
+	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
 
 	ret = -EAGAIN;
 	pmd = *src_pmd;
@@ -880,7 +887,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out_unlock;
 	}
 	/*
-	 * mm->page_table_lock is enough to be sure that huge zero pmd is not
+	 * When page table lock is held, the huge zero pmd should not be
 	 * under splitting since we don't split the page itself, only pmd to
 	 * a page table.
 	 */
@@ -901,8 +908,8 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	}
 	if (unlikely(pmd_trans_splitting(pmd))) {
 		/* split huge page running from under us */
-		spin_unlock(&src_mm->page_table_lock);
-		spin_unlock(&dst_mm->page_table_lock);
+		spin_unlock(src_ptl);
+		spin_unlock(dst_ptl);
 		pte_free(dst_mm, pgtable);
 
 		wait_split_huge_page(vma->anon_vma, src_pmd); /* src_vma */
@@ -922,8 +929,8 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	ret = 0;
 out_unlock:
-	spin_unlock(&src_mm->page_table_lock);
-	spin_unlock(&dst_mm->page_table_lock);
+	spin_unlock(src_ptl);
+	spin_unlock(dst_ptl);
 out:
 	return ret;
 }
@@ -936,8 +943,9 @@ void huge_pmd_set_accessed(struct mm_struct *mm,
 {
 	pmd_t entry;
 	unsigned long haddr;
+	spinlock_t *ptl = huge_pmd_lockptr(mm, pmd);
 
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto unlock;
 
@@ -947,7 +955,7 @@ void huge_pmd_set_accessed(struct mm_struct *mm,
 		update_mmu_cache_pmd(vma, address, pmd);
 
 unlock:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 }
 
 static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
@@ -960,6 +968,7 @@ static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
 	int i, ret = 0;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	spinlock_t *ptl;
 
 	page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 	if (!page) {
@@ -980,7 +989,8 @@ static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pmd_lockptr(mm, pmd);
+	spin_lock(ptl);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_free_page;
 
@@ -1007,7 +1017,7 @@ static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
 	}
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	put_huge_zero_page();
 	inc_mm_counter(mm, MM_ANONPAGES);
 
@@ -1017,7 +1027,7 @@ static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
 out:
 	return ret;
 out_free_page:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	mem_cgroup_uncharge_page(page);
 	put_page(page);
@@ -1037,6 +1047,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	struct page **pages;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	spinlock_t *ptl;
 
 	pages = kmalloc(sizeof(struct page *) * HPAGE_PMD_NR,
 			GFP_KERNEL);
@@ -1077,7 +1088,8 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pmd_lockptr(mm, pmd);
+	spin_lock(ptl);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_free_pages;
 	VM_BUG_ON(!PageHead(page));
@@ -1103,7 +1115,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
 	page_remove_rmap(page);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
@@ -1114,7 +1126,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	return ret;
 
 out_free_pages:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	mem_cgroup_uncharge_start();
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
@@ -1134,12 +1146,13 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long haddr;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	spinlock_t *ptl = huge_pmd_lockptr(mm, pmd);
 
 	VM_BUG_ON(!vma->anon_vma);
 	haddr = address & HPAGE_PMD_MASK;
 	if (is_huge_zero_pmd(orig_pmd))
 		goto alloc;
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_unlock;
 
@@ -1155,7 +1168,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_unlock;
 	}
 	get_page(page);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow())
@@ -1200,11 +1213,11 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	if (page)
 		put_page(page);
 	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 		mem_cgroup_uncharge_page(new_page);
 		put_page(new_page);
 		goto out_mn;
@@ -1225,13 +1238,13 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		ret |= VM_FAULT_WRITE;
 	}
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 out_mn:
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 out:
 	return ret;
 out_unlock:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	return ret;
 }
 
@@ -1240,11 +1253,8 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 				   pmd_t *pmd,
 				   unsigned int flags)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	struct page *page = NULL;
 
-	assert_spin_locked(&mm->page_table_lock);
-
 	if (flags & FOLL_WRITE && !pmd_write(*pmd))
 		goto out;
 
@@ -1295,8 +1305,9 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int target_nid;
 	int current_nid = -1;
 	bool migrated;
+	spinlock_t *ptl = huge_pmd_lockptr(mm, pmdp);
 
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
 		goto out_unlock;
 
@@ -1314,17 +1325,17 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	/* Acquire the page lock to serialise THP migrations */
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	lock_page(page);
 
 	/* Confirm the PTE did not while locked */
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	if (unlikely(!pmd_same(pmd, *pmdp))) {
 		unlock_page(page);
 		put_page(page);
 		goto out_unlock;
 	}
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 
 	/* Migrate the THP to the requested node */
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
@@ -1336,7 +1347,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 
 check_same:
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
 		goto out_unlock;
 clear_pmdnuma:
@@ -1345,7 +1356,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	VM_BUG_ON(pmd_numa(*pmdp));
 	update_mmu_cache_pmd(vma, addr, pmdp);
 out_unlock:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	if (current_nid != -1)
 		task_numa_fault(current_nid, HPAGE_PMD_NR, false);
 	return 0;
@@ -1355,8 +1366,9 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
 	int ret = 0;
+	spinlock_t *uninitialized_var(ptl);
 
-	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		struct page *page;
 		pgtable_t pgtable;
 		pmd_t orig_pmd;
@@ -1371,7 +1383,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
 		if (is_huge_zero_pmd(orig_pmd)) {
 			tlb->mm->nr_ptes--;
-			spin_unlock(&tlb->mm->page_table_lock);
+			spin_unlock(ptl);
 			put_huge_zero_page();
 		} else {
 			page = pmd_page(orig_pmd);
@@ -1380,7 +1392,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 			VM_BUG_ON(!PageHead(page));
 			tlb->mm->nr_ptes--;
-			spin_unlock(&tlb->mm->page_table_lock);
+			spin_unlock(ptl);
 			tlb_remove_page(tlb, page);
 		}
 		pte_free(tlb->mm, pgtable);
@@ -1394,13 +1406,14 @@ int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned char *vec)
 {
 	int ret = 0;
+	spinlock_t *uninitialized_var(ptl);
 
-	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		/*
 		 * All logical pages in the range are present
 		 * if backed by a huge page.
 		 */
-		spin_unlock(&vma->vm_mm->page_table_lock);
+		spin_unlock(ptl);
 		memset(vec, 1, (end - addr) >> PAGE_SHIFT);
 		ret = 1;
 	}
@@ -1415,6 +1428,7 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 {
 	int ret = 0;
 	pmd_t pmd;
+	spinlock_t *uninitialized_var(ptl);
 
 	struct mm_struct *mm = vma->vm_mm;
 
@@ -1433,12 +1447,12 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 		goto out;
 	}
 
-	ret = __pmd_trans_huge_lock(old_pmd, vma);
+	ret = __pmd_trans_huge_lock(old_pmd, vma, &ptl);
 	if (ret == 1) {
 		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
 		VM_BUG_ON(!pmd_none(*new_pmd));
 		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 	}
 out:
 	return ret;
@@ -1449,8 +1463,9 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int ret = 0;
+	spinlock_t *uninitialized_var(ptl);
 
-	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		pmd_t entry;
 		entry = pmdp_get_and_clear(mm, addr, pmd);
 		if (!prot_numa) {
@@ -1466,7 +1481,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			}
 		}
 		set_pmd_at(mm, addr, pmd, entry);
-		spin_unlock(&vma->vm_mm->page_table_lock);
+		spin_unlock(ptl);
 		ret = 1;
 	}
 
@@ -1480,12 +1495,14 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
  * Note that if it returns 1, this routine returns without unlocking page
  * table locks. So callers must unlock them.
  */
-int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
+int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma,
+			  spinlock_t **ptl)
 {
-	spin_lock(&vma->vm_mm->page_table_lock);
+	*ptl = huge_pmd_lockptr(vma->vm_mm, pmd);
+	spin_lock(*ptl);
 	if (likely(pmd_trans_huge(*pmd))) {
 		if (unlikely(pmd_trans_splitting(*pmd))) {
-			spin_unlock(&vma->vm_mm->page_table_lock);
+			spin_unlock(*ptl);
 			wait_split_huge_page(vma->anon_vma, pmd);
 			return -1;
 		} else {
@@ -1494,14 +1511,23 @@ int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
 			return 1;
 		}
 	}
-	spin_unlock(&vma->vm_mm->page_table_lock);
+	spin_unlock(*ptl);
 	return 0;
 }
 
+/*
+ * This function returns whether a given @page is mapped onto the @address
+ * in the virtual space of @mm.
+ *
+ * When it's true, this function returns *pmd with holding the page table lock
+ * and passing it back to the caller via @ptl.
+ * If it's false, returns NULL without holding the page table lock.
+ */
 pmd_t *page_check_address_pmd(struct page *page,
 			      struct mm_struct *mm,
 			      unsigned long address,
-			      enum page_check_address_pmd_flag flag)
+			      enum page_check_address_pmd_flag flag,
+			      spinlock_t **ptl)
 {
 	pmd_t *pmd, *ret = NULL;
 
@@ -1511,10 +1537,12 @@ pmd_t *page_check_address_pmd(struct page *page,
 	pmd = mm_find_pmd(mm, address);
 	if (!pmd)
 		goto out;
+	*ptl = huge_pmd_lockptr(mm, pmd);
+	spin_lock(*ptl);
 	if (pmd_none(*pmd))
-		goto out;
+		goto unlock;
 	if (pmd_page(*pmd) != page)
-		goto out;
+		goto unlock;
 	/*
 	 * split_vma() may create temporary aliased mappings. There is
 	 * no risk as long as all huge pmd are found and have their
@@ -1524,12 +1552,15 @@ pmd_t *page_check_address_pmd(struct page *page,
 	 */
 	if (flag == PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG &&
 	    pmd_trans_splitting(*pmd))
-		goto out;
+		goto unlock;
 	if (pmd_trans_huge(*pmd)) {
 		VM_BUG_ON(flag == PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG &&
 			  !pmd_trans_splitting(*pmd));
 		ret = pmd;
+		goto out;
 	}
+unlock:
+	spin_unlock(*ptl);
 out:
 	return ret;
 }
@@ -1541,14 +1572,15 @@ static int __split_huge_page_splitting(struct page *page,
 	struct mm_struct *mm = vma->vm_mm;
 	pmd_t *pmd;
 	int ret = 0;
+	spinlock_t *uninitialized_var(ptl);
 	/* For mmu_notifiers */
 	const unsigned long mmun_start = address;
 	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
 
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-	spin_lock(&mm->page_table_lock);
+
 	pmd = page_check_address_pmd(page, mm, address,
-				     PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG);
+				PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
 	if (pmd) {
 		/*
 		 * We can't temporarily set the pmd to null in order
@@ -1559,8 +1591,8 @@ static int __split_huge_page_splitting(struct page *page,
 		 */
 		pmdp_splitting_flush(vma, address, pmd);
 		ret = 1;
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 	return ret;
@@ -1694,10 +1726,10 @@ static int __split_huge_page_map(struct page *page,
 	int ret = 0, i;
 	pgtable_t pgtable;
 	unsigned long haddr;
+	spinlock_t *uninitialized_var(ptl);
 
-	spin_lock(&mm->page_table_lock);
 	pmd = page_check_address_pmd(page, mm, address,
-				     PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG);
+				PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG, &ptl);
 	if (pmd) {
 		pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 		pmd_populate(mm, &_pmd, pgtable);
@@ -1752,8 +1784,8 @@ static int __split_huge_page_map(struct page *page,
 		pmdp_invalidate(vma, address, pmd);
 		pmd_populate(mm, pmd, pgtable);
 		ret = 1;
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 
 	return ret;
 }
@@ -2314,7 +2346,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	mmun_start = address;
 	mmun_end   = address + HPAGE_PMD_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-	spin_lock(&mm->page_table_lock); /* probably unnecessary */
+	spin_lock(ptl); /* probably unnecessary */
 	/*
 	 * After this gup_fast can't run anymore. This also removes
 	 * any huge TLB entry from the CPU so we won't allow
@@ -2322,7 +2354,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * to avoid the risk of CPU bugs in that area.
 	 */
 	_pmd = pmdp_clear_flush(vma, address, pmd);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 	spin_lock(ptl);
@@ -2331,7 +2363,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	if (unlikely(!isolated)) {
 		pte_unmap(pte);
-		spin_lock(&mm->page_table_lock);
+		spin_lock(ptl);
 		BUG_ON(!pmd_none(*pmd));
 		/*
 		 * We can only use set_pmd_at when establishing
@@ -2339,7 +2371,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 		 * points to regular pagetables. Use pmd_populate for that
 		 */
 		pmd_populate(mm, pmd, pmd_pgtable(_pmd));
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 		anon_vma_unlock_write(vma->anon_vma);
 		goto out;
 	}
@@ -2364,13 +2396,13 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	smp_wmb();
 
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	BUG_ON(!pmd_none(*pmd));
 	page_add_new_anon_rmap(new_page, vma, address);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, address, pmd, _pmd);
 	update_mmu_cache_pmd(vma, address, pmd);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 
 	*hpage = NULL;
 
@@ -2698,6 +2730,7 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
+	spinlock_t *ptl;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
@@ -2706,22 +2739,23 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pmd_lockptr(mm, pmd);
+	spin_lock(ptl);
 	if (unlikely(!pmd_trans_huge(*pmd))) {
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 		return;
 	}
 	if (is_huge_zero_pmd(*pmd)) {
 		__split_huge_zero_page_pmd(vma, haddr, pmd);
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 		return;
 	}
 	page = pmd_page(*pmd);
 	VM_BUG_ON(!page_count(page));
 	get_page(page);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
 	split_huge_page(page);
diff --git v3.11-rc3.orig/mm/memcontrol.c v3.11-rc3/mm/memcontrol.c
index 00a7a66..3949444 100644
--- v3.11-rc3.orig/mm/memcontrol.c
+++ v3.11-rc3/mm/memcontrol.c
@@ -6591,12 +6591,12 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
 {
 	struct vm_area_struct *vma = walk->private;
 	pte_t *pte;
-	spinlock_t *ptl;
+	spinlock_t *uninitialized_var(ptl);
 
-	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
 			mc.precharge += HPAGE_PMD_NR;
-		spin_unlock(&vma->vm_mm->page_table_lock);
+		spin_unlock(ptl);
 		return 0;
 	}
 
@@ -6769,7 +6769,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	int ret = 0;
 	struct vm_area_struct *vma = walk->private;
 	pte_t *pte;
-	spinlock_t *ptl;
+	spinlock_t *uninitialized_var(ptl);
 	enum mc_target_type target_type;
 	union mc_target target;
 	struct page *page;
@@ -6785,9 +6785,9 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 	 *    to be unlocked in __split_huge_page_splitting(), where the main
 	 *    part of thp split is not executed yet.
 	 */
-	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
 		if (mc.precharge < HPAGE_PMD_NR) {
-			spin_unlock(&vma->vm_mm->page_table_lock);
+			spin_unlock(ptl);
 			return 0;
 		}
 		target_type = get_mctgt_type_thp(vma, addr, *pmd, &target);
@@ -6804,7 +6804,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
 			}
 			put_page(page);
 		}
-		spin_unlock(&vma->vm_mm->page_table_lock);
+		spin_unlock(ptl);
 		return 0;
 	}
 
diff --git v3.11-rc3.orig/mm/memory.c v3.11-rc3/mm/memory.c
index 7ec1252..6827a35 100644
--- v3.11-rc3.orig/mm/memory.c
+++ v3.11-rc3/mm/memory.c
@@ -1531,20 +1531,21 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 			split_huge_page_pmd(vma, address, pmd);
 			goto split_fallthrough;
 		}
-		spin_lock(&mm->page_table_lock);
+		ptl = huge_pmd_lockptr(mm, pmd);
+		spin_lock(ptl);
 		if (likely(pmd_trans_huge(*pmd))) {
 			if (unlikely(pmd_trans_splitting(*pmd))) {
-				spin_unlock(&mm->page_table_lock);
+				spin_unlock(ptl);
 				wait_split_huge_page(vma->anon_vma, pmd);
 			} else {
 				page = follow_trans_huge_pmd(vma, address,
 							     pmd, flags);
-				spin_unlock(&mm->page_table_lock);
+				spin_unlock(ptl);
 				*page_mask = HPAGE_PMD_NR - 1;
 				goto out;
 			}
 		} else
-			spin_unlock(&mm->page_table_lock);
+			spin_unlock(ptl);
 		/* fall through */
 	}
 split_fallthrough:
@@ -3609,17 +3610,17 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	pte_t *pte, *orig_pte;
 	unsigned long _addr = addr & PMD_MASK;
 	unsigned long offset;
-	spinlock_t *ptl;
+	spinlock_t *ptl = huge_pmd_lockptr(mm, pmdp);
 	bool numa = false;
 	int local_nid = numa_node_id();
 
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	pmd = *pmdp;
 	if (pmd_numa(pmd)) {
 		set_pmd_at(mm, _addr, pmdp, pmd_mknonnuma(pmd));
 		numa = true;
 	}
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 
 	if (!numa)
 		return 0;
diff --git v3.11-rc3.orig/mm/migrate.c v3.11-rc3/mm/migrate.c
index c69a9c7..1e1e9f2 100644
--- v3.11-rc3.orig/mm/migrate.c
+++ v3.11-rc3/mm/migrate.c
@@ -1659,6 +1659,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	struct page *new_page = NULL;
 	struct mem_cgroup *memcg = NULL;
 	int page_lru = page_is_file_cache(page);
+	spinlock_t *ptl;
 
 	/*
 	 * Don't migrate pages that are mapped in multiple processes.
@@ -1699,9 +1700,10 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pmd_lockptr(mm, pmd);
+	spin_lock(ptl);
 	if (unlikely(!pmd_same(*pmd, entry))) {
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 
 		/* Reverse changes made by migrate_page_copy() */
 		if (TestClearPageActive(new_page))
@@ -1746,7 +1748,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	 * before it's fully transferred to the new page.
 	 */
 	mem_cgroup_end_migration(memcg, page, new_page, true);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 
 	unlock_page(new_page);
 	unlock_page(page);
diff --git v3.11-rc3.orig/mm/mprotect.c v3.11-rc3/mm/mprotect.c
index 94722a4..c65c390 100644
--- v3.11-rc3.orig/mm/mprotect.c
+++ v3.11-rc3/mm/mprotect.c
@@ -116,9 +116,10 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
 				       pmd_t *pmd)
 {
-	spin_lock(&mm->page_table_lock);
+	spinlock_t *ptl = huge_pmd_lockptr(mm, pmd);
+	spin_lock(ptl);
 	set_pmd_at(mm, addr & PMD_MASK, pmd, pmd_mknuma(*pmd));
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 }
 #else
 static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
diff --git v3.11-rc3.orig/mm/pgtable-generic.c v3.11-rc3/mm/pgtable-generic.c
index e1a6e4f..8e49928 100644
--- v3.11-rc3.orig/mm/pgtable-generic.c
+++ v3.11-rc3/mm/pgtable-generic.c
@@ -124,11 +124,10 @@ void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
 
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+/* The caller must hold page table lock */
 void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				pgtable_t pgtable)
 {
-	assert_spin_locked(&mm->page_table_lock);
-
 	/* FIFO */
 	if (!mm->pmd_huge_pte)
 		INIT_LIST_HEAD(&pgtable->lru);
@@ -141,13 +140,14 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 
 #ifndef __HAVE_ARCH_PGTABLE_WITHDRAW
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-/* no "address" argument so destroys page coloring of some arch */
+/*
+ * no "address" argument so destroys page coloring of some arch
+ * The caller must hold page table lock.
+ */
 pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 {
 	pgtable_t pgtable;
 
-	assert_spin_locked(&mm->page_table_lock);
-
 	/* FIFO */
 	pgtable = mm->pmd_huge_pte;
 	if (list_empty(&pgtable->lru))
diff --git v3.11-rc3.orig/mm/rmap.c v3.11-rc3/mm/rmap.c
index eccec58..798f6ae 100644
--- v3.11-rc3.orig/mm/rmap.c
+++ v3.11-rc3/mm/rmap.c
@@ -666,24 +666,24 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int referenced = 0;
+	spinlock_t *uninitialized_var(ptl);
 
 	if (unlikely(PageTransHuge(page))) {
 		pmd_t *pmd;
 
-		spin_lock(&mm->page_table_lock);
 		/*
 		 * rmap might return false positives; we must filter
 		 * these out using page_check_address_pmd().
 		 */
 		pmd = page_check_address_pmd(page, mm, address,
-					     PAGE_CHECK_ADDRESS_PMD_FLAG);
+					PAGE_CHECK_ADDRESS_PMD_FLAG, &ptl);
 		if (!pmd) {
-			spin_unlock(&mm->page_table_lock);
+			spin_unlock(ptl);
 			goto out;
 		}
 
 		if (vma->vm_flags & VM_LOCKED) {
-			spin_unlock(&mm->page_table_lock);
+			spin_unlock(ptl);
 			*mapcount = 0;	/* break early from loop */
 			*vm_flags |= VM_LOCKED;
 			goto out;
@@ -692,10 +692,9 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		/* go ahead even if the pmd is pmd_trans_splitting() */
 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 	} else {
 		pte_t *pte;
-		spinlock_t *ptl;
 
 		/*
 		 * rmap might return false positives; we must filter
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 7A0126B007B
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 06:12:25 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH 1/3] mm: Move all mmu notifier invocations to be done outside the PT lock
Date: Sun, 26 Aug 2012 13:11:37 +0300
Message-Id: <1345975899-2236-2-git-send-email-haggaie@mellanox.com>
In-Reply-To: <1345975899-2236-1-git-send-email-haggaie@mellanox.com>
References: <1345975899-2236-1-git-send-email-haggaie@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Andrea Arcangeli <andrea@qumranet.com>, Haggai Eran <haggaie@mellanox.com>

From: Sagi Grimberg <sagig@mellanox.com>

In order to allow sleeping during mmu notifier calls, we need to avoid
invoking them under the page table spinlock. This patch solves the
problem by calling invalidate_page notification after releasing
the lock (but before freeing the page itself), or by wrapping the page
invalidation with calls to invalidate_range_begin and
invalidate_range_end.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 include/linux/mmu_notifier.h | 48 --------------------------------------------
 mm/filemap_xip.c             |  4 +++-
 mm/huge_memory.c             | 32 +++++++++++++++++++++++------
 mm/hugetlb.c                 | 15 ++++++++------
 mm/memory.c                  | 10 ++++++---
 mm/rmap.c                    | 27 ++++++++++++++++++-------
 6 files changed, 65 insertions(+), 71 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index ee2baf0..470a825 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -246,50 +246,6 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 		__mmu_notifier_mm_destroy(mm);
 }
 
-/*
- * These two macros will sometime replace ptep_clear_flush.
- * ptep_clear_flush is implemented as macro itself, so this also is
- * implemented as a macro until ptep_clear_flush will converted to an
- * inline function, to diminish the risk of compilation failure. The
- * invalidate_page method over time can be moved outside the PT lock
- * and these two macros can be later removed.
- */
-#define ptep_clear_flush_notify(__vma, __address, __ptep)		\
-({									\
-	pte_t __pte;							\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	__pte = ptep_clear_flush(___vma, ___address, __ptep);		\
-	mmu_notifier_invalidate_page(___vma->vm_mm, ___address);	\
-	__pte;								\
-})
-
-#define pmdp_clear_flush_notify(__vma, __address, __pmdp)		\
-({									\
-	pmd_t __pmd;							\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	VM_BUG_ON(__address & ~HPAGE_PMD_MASK);				\
-	mmu_notifier_invalidate_range_start(___vma->vm_mm, ___address,	\
-					    (__address)+HPAGE_PMD_SIZE);\
-	__pmd = pmdp_clear_flush(___vma, ___address, __pmdp);		\
-	mmu_notifier_invalidate_range_end(___vma->vm_mm, ___address,	\
-					  (__address)+HPAGE_PMD_SIZE);	\
-	__pmd;								\
-})
-
-#define pmdp_splitting_flush_notify(__vma, __address, __pmdp)		\
-({									\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	VM_BUG_ON(__address & ~HPAGE_PMD_MASK);				\
-	mmu_notifier_invalidate_range_start(___vma->vm_mm, ___address,	\
-					    (__address)+HPAGE_PMD_SIZE);\
-	pmdp_splitting_flush(___vma, ___address, __pmdp);		\
-	mmu_notifier_invalidate_range_end(___vma->vm_mm, ___address,	\
-					  (__address)+HPAGE_PMD_SIZE);	\
-})
-
 #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
 ({									\
 	int __young;							\
@@ -368,11 +324,7 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 {
 }
 
-#define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define pmdp_clear_flush_young_notify pmdp_clear_flush_young
-#define ptep_clear_flush_notify ptep_clear_flush
-#define pmdp_clear_flush_notify pmdp_clear_flush
-#define pmdp_splitting_flush_notify pmdp_splitting_flush
 #define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 13e013b..a002a6d 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -193,11 +193,13 @@ retry:
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
-			pteval = ptep_clear_flush_notify(vma, address, pte);
+			pteval = ptep_clear_flush(vma, address, pte);
 			page_remove_rmap(page);
 			dec_mm_counter(mm, MM_FILEPAGES);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
+			/* must invalidate_page _before_ freeing the page */
+			mmu_notifier_invalidate_page(mm, address);
 			page_cache_release(page);
 		}
 	}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 57c4b93..5a5b9e4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -868,12 +868,14 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 		cond_resched();
 	}
 
+	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
+
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_free_pages;
 	VM_BUG_ON(!PageHead(page));
 
-	pmdp_clear_flush_notify(vma, haddr, pmd);
+	pmdp_clear_flush(vma, haddr, pmd);
 	/* leave pmd empty until pte is filled */
 
 	pgtable = get_pmd_huge_pte(mm);
@@ -896,6 +898,9 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	page_remove_rmap(page);
 	spin_unlock(&mm->page_table_lock);
 
+	mmu_notifier_invalidate_range_end(vma->vm_mm, haddr,
+					  haddr + HPAGE_PMD_SIZE);
+
 	ret |= VM_FAULT_WRITE;
 	put_page(page);
 
@@ -904,6 +909,7 @@ out:
 
 out_free_pages:
 	spin_unlock(&mm->page_table_lock);
+	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
 	mem_cgroup_uncharge_start();
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		mem_cgroup_uncharge_page(pages[i]);
@@ -970,20 +976,22 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
+	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
+
 	spin_lock(&mm->page_table_lock);
 	put_page(page);
 	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
 		spin_unlock(&mm->page_table_lock);
 		mem_cgroup_uncharge_page(new_page);
 		put_page(new_page);
-		goto out;
+		goto out_mn;
 	} else {
 		pmd_t entry;
 		VM_BUG_ON(!PageHead(page));
 		entry = mk_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		entry = pmd_mkhuge(entry);
-		pmdp_clear_flush_notify(vma, haddr, pmd);
+		pmdp_clear_flush(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		update_mmu_cache(vma, address, entry);
@@ -991,10 +999,14 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		put_page(page);
 		ret |= VM_FAULT_WRITE;
 	}
-out_unlock:
 	spin_unlock(&mm->page_table_lock);
+out_mn:
+	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
 out:
 	return ret;
+out_unlock:
+	spin_unlock(&mm->page_table_lock);
+	return ret;
 }
 
 struct page *follow_trans_huge_pmd(struct mm_struct *mm,
@@ -1208,6 +1220,8 @@ static int __split_huge_page_splitting(struct page *page,
 	pmd_t *pmd;
 	int ret = 0;
 
+	mmu_notifier_invalidate_range_start(mm, address,
+					    address + HPAGE_PMD_SIZE);
 	spin_lock(&mm->page_table_lock);
 	pmd = page_check_address_pmd(page, mm, address,
 				     PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG);
@@ -1219,10 +1233,12 @@ static int __split_huge_page_splitting(struct page *page,
 		 * and it won't wait on the anon_vma->root->mutex to
 		 * serialize against split_huge_page*.
 		 */
-		pmdp_splitting_flush_notify(vma, address, pmd);
+		pmdp_splitting_flush(vma, address, pmd);
 		ret = 1;
 	}
 	spin_unlock(&mm->page_table_lock);
+	mmu_notifier_invalidate_range_end(mm, address,
+					  address + HPAGE_PMD_SIZE);
 
 	return ret;
 }
@@ -1937,6 +1953,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pte = pte_offset_map(pmd, address);
 	ptl = pte_lockptr(mm, pmd);
 
+	mmu_notifier_invalidate_range_start(mm, address,
+					    address + HPAGE_PMD_SIZE);
 	spin_lock(&mm->page_table_lock); /* probably unnecessary */
 	/*
 	 * After this gup_fast can't run anymore. This also removes
@@ -1944,8 +1962,10 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * huge and small TLB entries for the same virtual address
 	 * to avoid the risk of CPU bugs in that area.
 	 */
-	_pmd = pmdp_clear_flush_notify(vma, address, pmd);
+	_pmd = pmdp_clear_flush(vma, address, pmd);
 	spin_unlock(&mm->page_table_lock);
+	mmu_notifier_invalidate_range_end(mm, address,
+					  address + HPAGE_PMD_SIZE);
 
 	spin_lock(ptl);
 	isolated = __collapse_huge_page_isolate(vma, address, pte);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bc72712..c569b97 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2611,6 +2611,9 @@ retry_avoidcopy:
 			    pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
 
+	mmu_notifier_invalidate_range_start(mm,
+		address & huge_page_mask(h),
+		(address & huge_page_mask(h)) + huge_page_size(h));
 	/*
 	 * Retake the page_table_lock to check for racing updates
 	 * before the page tables are altered
@@ -2619,9 +2622,6 @@ retry_avoidcopy:
 	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
 	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
 		/* Break COW */
-		mmu_notifier_invalidate_range_start(mm,
-			address & huge_page_mask(h),
-			(address & huge_page_mask(h)) + huge_page_size(h));
 		huge_ptep_clear_flush(vma, address, ptep);
 		set_huge_pte_at(mm, address, ptep,
 				make_huge_pte(vma, new_page, 1));
@@ -2629,10 +2629,13 @@ retry_avoidcopy:
 		hugepage_add_new_anon_rmap(new_page, vma, address);
 		/* Make the old page be freed below */
 		new_page = old_page;
-		mmu_notifier_invalidate_range_end(mm,
-			address & huge_page_mask(h),
-			(address & huge_page_mask(h)) + huge_page_size(h));
 	}
+	spin_unlock(&mm->page_table_lock);
+	mmu_notifier_invalidate_range_end(mm,
+		address & huge_page_mask(h),
+		(address & huge_page_mask(h)) + huge_page_size(h));
+	/* Caller expects lock to be held */
+	spin_lock(&mm->page_table_lock);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
 	return 0;
diff --git a/mm/memory.c b/mm/memory.c
index 5736170..b657a2e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2516,7 +2516,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		spinlock_t *ptl, pte_t orig_pte)
 	__releases(ptl)
 {
-	struct page *old_page, *new_page;
+	struct page *old_page, *new_page = NULL;
 	pte_t entry;
 	int ret = 0;
 	int page_mkwrite = 0;
@@ -2760,10 +2760,14 @@ gotten:
 	} else
 		mem_cgroup_uncharge_page(new_page);
 
-	if (new_page)
-		page_cache_release(new_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
+	if (new_page) {
+		if (new_page == old_page)
+			/* cow happened, notify before releasing old_page */
+			mmu_notifier_invalidate_page(mm, address);
+		page_cache_release(new_page);
+	}
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
diff --git a/mm/rmap.c b/mm/rmap.c
index 0f3b7cd..f13e6cf 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -694,7 +694,7 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			unsigned long *vm_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	int referenced = 0;
+	int referenced = 0, clear_flush_young = 0;
 
 	if (unlikely(PageTransHuge(page))) {
 		pmd_t *pmd;
@@ -741,7 +741,8 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			goto out;
 		}
 
-		if (ptep_clear_flush_young_notify(vma, address, pte)) {
+		clear_flush_young = 1;
+		if (ptep_clear_flush_young(vma, address, pte)) {
 			/*
 			 * Don't treat a reference through a sequentially read
 			 * mapping as such.  If the page has been used in
@@ -757,6 +758,9 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 
 	(*mapcount)--;
 
+	if (clear_flush_young)
+		referenced += mmu_notifier_clear_flush_young(mm, address);
+
 	if (referenced)
 		*vm_flags |= vma->vm_flags;
 out:
@@ -929,7 +933,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		pte_t entry;
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		entry = ptep_clear_flush_notify(vma, address, pte);
+		entry = ptep_clear_flush(vma, address, pte);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -937,6 +941,9 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	}
 
 	pte_unmap_unlock(pte, ptl);
+
+	if (ret)
+		mmu_notifier_invalidate_page(mm, address);
 out:
 	return ret;
 }
@@ -1256,7 +1263,7 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush_notify(vma, address, pte);
+	pteval = ptep_clear_flush(vma, address, pte);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
@@ -1318,6 +1325,8 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+	if (ret != SWAP_FAIL)
+		mmu_notifier_invalidate_page(mm, address);
 out:
 	return ret;
 
@@ -1382,7 +1391,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	spinlock_t *ptl;
 	struct page *page;
 	unsigned long address;
-	unsigned long end;
+	unsigned long start, end;
 	int ret = SWAP_AGAIN;
 	int locked_vma = 0;
 
@@ -1405,6 +1414,9 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 	if (!pmd_present(*pmd))
 		return ret;
 
+	start = address;
+	mmu_notifier_invalidate_range_start(mm, start, end);
+
 	/*
 	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
 	 * keep the sem while scanning the cluster for mlocking pages.
@@ -1433,12 +1445,12 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 			continue;	/* don't unmap */
 		}
 
-		if (ptep_clear_flush_young_notify(vma, address, pte))
+		if (ptep_clear_flush_young(vma, address, pte))
 			continue;
 
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		pteval = ptep_clear_flush_notify(vma, address, pte);
+		pteval = ptep_clear_flush(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))
@@ -1454,6 +1466,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 	if (locked_vma)
 		up_read(&vma->vm_mm->mmap_sem);
 	return ret;
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

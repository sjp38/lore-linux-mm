Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 4ABBB6B0037
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 13:19:23 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/2] hugetlbfs: support split page table lock
Date: Fri, 30 Aug 2013 13:18:39 -0400
Message-Id: <1377883120-5280-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1377883120-5280-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1377883120-5280-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org

Currently all of page table handling by hugetlbfs code are done under
mm->page_table_lock. So when a process have many threads and they heavily
access to the memory, lock contention happens and impacts the performance.

This patch makes hugepage support split page table lock so that we use
page->ptl of the leaf node of page table tree which is pte for normal pages
but can be pmd and/or pud for hugepages of some architectures.

ChangeLog v2:
 - add split ptl on other archs missed in v1

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/powerpc/mm/hugetlbpage.c |  6 ++-
 arch/tile/mm/hugetlbpage.c    |  6 ++-
 include/linux/hugetlb.h       | 20 ++++++++++
 mm/hugetlb.c                  | 92 ++++++++++++++++++++++++++-----------------
 mm/mempolicy.c                |  5 ++-
 mm/migrate.c                  |  4 +-
 mm/rmap.c                     |  2 +-
 7 files changed, 90 insertions(+), 45 deletions(-)

diff --git v3.11-rc3.orig/arch/powerpc/mm/hugetlbpage.c v3.11-rc3/arch/powerpc/mm/hugetlbpage.c
index d67db4b..7e56cb7 100644
--- v3.11-rc3.orig/arch/powerpc/mm/hugetlbpage.c
+++ v3.11-rc3/arch/powerpc/mm/hugetlbpage.c
@@ -124,6 +124,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 {
 	struct kmem_cache *cachep;
 	pte_t *new;
+	spinlock_t *ptl;
 
 #ifdef CONFIG_PPC_FSL_BOOK3E
 	int i;
@@ -141,7 +142,8 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 	if (! new)
 		return -ENOMEM;
 
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pte_lockptr(mm, new);
+	spin_lock(ptl);
 #ifdef CONFIG_PPC_FSL_BOOK3E
 	/*
 	 * We have multiple higher-level entries that point to the same
@@ -174,7 +176,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 #endif
 	}
 #endif
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	return 0;
 }
 
diff --git v3.11-rc3.orig/arch/tile/mm/hugetlbpage.c v3.11-rc3/arch/tile/mm/hugetlbpage.c
index 0ac3599..c10cef9 100644
--- v3.11-rc3.orig/arch/tile/mm/hugetlbpage.c
+++ v3.11-rc3/arch/tile/mm/hugetlbpage.c
@@ -59,6 +59,7 @@ static pte_t *pte_alloc_hugetlb(struct mm_struct *mm, pmd_t *pmd,
 				unsigned long address)
 {
 	pte_t *new;
+	spinlock_t *ptl;
 
 	if (pmd_none(*pmd)) {
 		new = pte_alloc_one_kernel(mm, address);
@@ -67,14 +68,15 @@ static pte_t *pte_alloc_hugetlb(struct mm_struct *mm, pmd_t *pmd,
 
 		smp_wmb(); /* See comment in __pte_alloc */
 
-		spin_lock(&mm->page_table_lock);
+		ptl = huge_pte_lockptr(mm, new);
+		spin_lock(ptl);
 		if (likely(pmd_none(*pmd))) {  /* Has another populated it ? */
 			mm->nr_ptes++;
 			pmd_populate_kernel(mm, pmd, new);
 			new = NULL;
 		} else
 			VM_BUG_ON(pmd_trans_splitting(*pmd));
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 		if (new)
 			pte_free_kernel(mm, new);
 	}
diff --git v3.11-rc3.orig/include/linux/hugetlb.h v3.11-rc3/include/linux/hugetlb.h
index 0393270..8de0127 100644
--- v3.11-rc3.orig/include/linux/hugetlb.h
+++ v3.11-rc3/include/linux/hugetlb.h
@@ -80,6 +80,24 @@ extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
 extern struct list_head huge_boot_pages;
 
+#if USE_SPLIT_PTLOCKS
+#define huge_pte_lockptr(mm, ptep) ({__pte_lockptr(virt_to_page(ptep)); })
+#else	/* !USE_SPLIT_PTLOCKS */
+#define huge_pte_lockptr(mm, ptep) ({&(mm)->page_table_lock; })
+#endif	/* USE_SPLIT_PTLOCKS */
+
+#define huge_pte_offset_lock(mm, address, ptlp)		\
+({							\
+	pte_t *__pte = huge_pte_offset(mm, address);	\
+	spinlock_t *__ptl = NULL;			\
+	if (__pte) {					\
+		__ptl = huge_pte_lockptr(mm, __pte);	\
+		*(ptlp) = __ptl;			\
+		spin_lock(__ptl);			\
+	}						\
+	__pte;						\
+})
+
 /* arch callbacks */
 
 pte_t *huge_pte_alloc(struct mm_struct *mm,
@@ -164,6 +182,8 @@ static inline void __unmap_hugepage_range(struct mmu_gather *tlb,
 	BUG();
 }
 
+#define huge_pte_lockptr(mm, ptep) 0
+
 #endif /* !CONFIG_HUGETLB_PAGE */
 
 #define HUGETLB_ANON_FILE "anon_hugepage"
diff --git v3.11-rc3.orig/mm/hugetlb.c v3.11-rc3/mm/hugetlb.c
index 0f8da6b..b2dbca4 100644
--- v3.11-rc3.orig/mm/hugetlb.c
+++ v3.11-rc3/mm/hugetlb.c
@@ -2372,6 +2372,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
+		spinlock_t *src_ptl, *dst_ptl;
 		src_pte = huge_pte_offset(src, addr);
 		if (!src_pte)
 			continue;
@@ -2383,8 +2384,10 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 		if (dst_pte == src_pte)
 			continue;
 
-		spin_lock(&dst->page_table_lock);
-		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
+		dst_ptl = huge_pte_lockptr(dst, dst_pte);
+		src_ptl = huge_pte_lockptr(src, src_pte);
+		spin_lock(dst_ptl);
+		spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
 		if (!huge_pte_none(huge_ptep_get(src_pte))) {
 			if (cow)
 				huge_ptep_set_wrprotect(src, addr, src_pte);
@@ -2394,8 +2397,8 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			page_dup_rmap(ptepage);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
-		spin_unlock(&src->page_table_lock);
-		spin_unlock(&dst->page_table_lock);
+		spin_unlock(src_ptl);
+		spin_unlock(dst_ptl);
 	}
 	return 0;
 
@@ -2438,6 +2441,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	unsigned long address;
 	pte_t *ptep;
 	pte_t pte;
+	spinlock_t *ptl;
 	struct page *page;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
@@ -2451,25 +2455,24 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	tlb_start_vma(tlb, vma);
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 again:
-	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += sz) {
-		ptep = huge_pte_offset(mm, address);
+		ptep = huge_pte_offset_lock(mm, address, &ptl);
 		if (!ptep)
 			continue;
 
 		if (huge_pmd_unshare(mm, &address, ptep))
-			continue;
+			goto unlock;
 
 		pte = huge_ptep_get(ptep);
 		if (huge_pte_none(pte))
-			continue;
+			goto unlock;
 
 		/*
 		 * HWPoisoned hugepage is already unmapped and dropped reference
 		 */
 		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
 			huge_pte_clear(mm, address, ptep);
-			continue;
+			goto unlock;
 		}
 
 		page = pte_page(pte);
@@ -2480,7 +2483,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 */
 		if (ref_page) {
 			if (page != ref_page)
-				continue;
+				goto unlock;
 
 			/*
 			 * Mark the VMA as having unmapped its page so that
@@ -2497,13 +2500,18 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 
 		page_remove_rmap(page);
 		force_flush = !__tlb_remove_page(tlb, page);
-		if (force_flush)
+		if (force_flush) {
+			spin_unlock(ptl);
 			break;
+		}
 		/* Bail out after unmapping reference page if supplied */
-		if (ref_page)
+		if (ref_page) {
+			spin_unlock(ptl);
 			break;
+		}
+unlock:
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 	/*
 	 * mmu_gather ran out of room to batch pages, we break out of
 	 * the PTE lock to avoid doing the potential expensive TLB invalidate
@@ -2617,6 +2625,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	int outside_reserve = 0;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	spinlock_t *ptl = huge_pte_lockptr(mm, ptep);
 
 	old_page = pte_page(pte);
 
@@ -2648,7 +2657,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	page_cache_get(old_page);
 
 	/* Drop page_table_lock as buddy allocator may be called */
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	new_page = alloc_huge_page(vma, address, outside_reserve);
 
 	if (IS_ERR(new_page)) {
@@ -2666,7 +2675,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 			BUG_ON(huge_pte_none(pte));
 			if (unmap_ref_private(mm, vma, old_page, address)) {
 				BUG_ON(huge_pte_none(pte));
-				spin_lock(&mm->page_table_lock);
+				spin_lock(ptl);
 				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
 				if (likely(pte_same(huge_ptep_get(ptep), pte)))
 					goto retry_avoidcopy;
@@ -2680,7 +2689,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 
 		/* Caller expects lock to be held */
-		spin_lock(&mm->page_table_lock);
+		spin_lock(ptl);
 		if (err == -ENOMEM)
 			return VM_FAULT_OOM;
 		else
@@ -2695,7 +2704,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_cache_release(new_page);
 		page_cache_release(old_page);
 		/* Caller expects lock to be held */
-		spin_lock(&mm->page_table_lock);
+		spin_lock(ptl);
 		return VM_FAULT_OOM;
 	}
 
@@ -2710,7 +2719,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * Retake the page_table_lock to check for racing updates
 	 * before the page tables are altered
 	 */
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
 	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
 		/* Break COW */
@@ -2722,10 +2731,10 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		/* Make the old page be freed below */
 		new_page = old_page;
 	}
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	/* Caller expects lock to be held */
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	page_cache_release(new_page);
 	page_cache_release(old_page);
 	return 0;
@@ -2775,6 +2784,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *page;
 	struct address_space *mapping;
 	pte_t new_pte;
+	spinlock_t *ptl;
 
 	/*
 	 * Currently, we are forced to kill the process in the event the
@@ -2860,7 +2870,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			goto backout_unlocked;
 		}
 
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pte_lockptr(mm, ptep);
+	spin_lock(ptl);
 	size = i_size_read(mapping->host) >> huge_page_shift(h);
 	if (idx >= size)
 		goto backout;
@@ -2882,13 +2893,13 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page);
 	}
 
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	unlock_page(page);
 out:
 	return ret;
 
 backout:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 backout_unlocked:
 	unlock_page(page);
 	put_page(page);
@@ -2900,6 +2911,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	pte_t *ptep;
 	pte_t entry;
+	spinlock_t *ptl;
 	int ret;
 	struct page *page = NULL;
 	struct page *pagecache_page = NULL;
@@ -2968,7 +2980,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (page != pagecache_page)
 		lock_page(page);
 
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pte_lockptr(mm, ptep);
+	spin_lock(ptl);
 	/* Check for a racing update before calling hugetlb_cow */
 	if (unlikely(!pte_same(entry, huge_ptep_get(ptep))))
 		goto out_page_table_lock;
@@ -2988,7 +3001,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		update_mmu_cache(vma, address, ptep);
 
 out_page_table_lock:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 
 	if (pagecache_page) {
 		unlock_page(pagecache_page);
@@ -3014,9 +3027,9 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long remainder = *nr_pages;
 	struct hstate *h = hstate_vma(vma);
 
-	spin_lock(&mm->page_table_lock);
 	while (vaddr < vma->vm_end && remainder) {
 		pte_t *pte;
+		spinlock_t *ptl = NULL;
 		int absent;
 		struct page *page;
 
@@ -3024,8 +3037,10 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * Some archs (sparc64, sh*) have multiple pte_ts to
 		 * each hugepage.  We have to make sure we get the
 		 * first, for the page indexing below to work.
+		 *
+		 * Note that page table lock is not held when pte is null.
 		 */
-		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
+		pte = huge_pte_offset_lock(mm, vaddr & huge_page_mask(h), &ptl);
 		absent = !pte || huge_pte_none(huge_ptep_get(pte));
 
 		/*
@@ -3037,6 +3052,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 */
 		if (absent && (flags & FOLL_DUMP) &&
 		    !hugetlbfs_pagecache_present(h, vma, vaddr)) {
+			if (pte)
+				spin_unlock(ptl);
 			remainder = 0;
 			break;
 		}
@@ -3056,10 +3073,10 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		      !huge_pte_write(huge_ptep_get(pte)))) {
 			int ret;
 
-			spin_unlock(&mm->page_table_lock);
+			if (pte)
+				spin_unlock(ptl);
 			ret = hugetlb_fault(mm, vma, vaddr,
 				(flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
-			spin_lock(&mm->page_table_lock);
 			if (!(ret & VM_FAULT_ERROR))
 				continue;
 
@@ -3090,8 +3107,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 */
 			goto same_page;
 		}
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 	*nr_pages = remainder;
 	*position = vaddr;
 
@@ -3112,13 +3129,14 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	flush_cache_range(vma, address, end);
 
 	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
-	spin_lock(&mm->page_table_lock);
 	for (; address < end; address += huge_page_size(h)) {
-		ptep = huge_pte_offset(mm, address);
+		spinlock_t *ptl;
+		ptep = huge_pte_offset_lock(mm, address, &ptl);
 		if (!ptep)
 			continue;
 		if (huge_pmd_unshare(mm, &address, ptep)) {
 			pages++;
+			spin_unlock(ptl);
 			continue;
 		}
 		if (!huge_pte_none(huge_ptep_get(ptep))) {
@@ -3128,8 +3146,8 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 			set_huge_pte_at(mm, address, ptep, pte);
 			pages++;
 		}
+		spin_unlock(ptl);
 	}
-	spin_unlock(&mm->page_table_lock);
 	/*
 	 * Must flush TLB before releasing i_mmap_mutex: x86's huge_pmd_unshare
 	 * may have cleared our pud entry and done put_page on the page table:
@@ -3292,6 +3310,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	unsigned long saddr;
 	pte_t *spte = NULL;
 	pte_t *pte;
+	spinlock_t *ptl;
 
 	if (!vma_shareable(vma, addr))
 		return (pte_t *)pmd_alloc(mm, pud, addr);
@@ -3314,13 +3333,14 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	if (!spte)
 		goto out;
 
-	spin_lock(&mm->page_table_lock);
+	ptl = huge_pte_lockptr(mm, spte);
+	spin_lock(ptl);
 	if (pud_none(*pud))
 		pud_populate(mm, pud,
 				(pmd_t *)((unsigned long)spte & PAGE_MASK));
 	else
 		put_page(virt_to_page(spte));
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
 	mutex_unlock(&mapping->i_mmap_mutex);
@@ -3334,7 +3354,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
  * indicated by page_count > 1, unmap is achieved by clearing pud and
  * decrementing the ref count. If count == 1, the pte page is not shared.
  *
- * called with vma->vm_mm->page_table_lock held.
+ * called with page table lock held.
  *
  * returns: 1 successfully unmapped a shared pte page
  *	    0 the underlying pte page is not shared, or it is the last user
diff --git v3.11-rc3.orig/mm/mempolicy.c v3.11-rc3/mm/mempolicy.c
index 838d022..5afe17b 100644
--- v3.11-rc3.orig/mm/mempolicy.c
+++ v3.11-rc3/mm/mempolicy.c
@@ -522,8 +522,9 @@ static void queue_pages_hugetlb_pmd_range(struct vm_area_struct *vma,
 #ifdef CONFIG_HUGETLB_PAGE
 	int nid;
 	struct page *page;
+	spinlock_t *ptl = pte_lockptr(vma->vm_mm, pmd);
 
-	spin_lock(&vma->vm_mm->page_table_lock);
+	spin_lock(ptl);
 	page = pte_page(huge_ptep_get((pte_t *)pmd));
 	nid = page_to_nid(page);
 	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
@@ -533,7 +534,7 @@ static void queue_pages_hugetlb_pmd_range(struct vm_area_struct *vma,
 	    (flags & MPOL_MF_MOVE && page_mapcount(page) == 1))
 		isolate_huge_page(page, private);
 unlock:
-	spin_unlock(&vma->vm_mm->page_table_lock);
+	spin_unlock(ptl);
 #else
 	BUG();
 #endif
diff --git v3.11-rc3.orig/mm/migrate.c v3.11-rc3/mm/migrate.c
index 61f14a1..c69a9c7 100644
--- v3.11-rc3.orig/mm/migrate.c
+++ v3.11-rc3/mm/migrate.c
@@ -130,7 +130,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		ptep = huge_pte_offset(mm, addr);
 		if (!ptep)
 			goto out;
-		ptl = &mm->page_table_lock;
+		ptl = huge_pte_lockptr(mm, ptep);
 	} else {
 		pmd = mm_find_pmd(mm, addr);
 		if (!pmd)
@@ -249,7 +249,7 @@ void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
 
 void migration_entry_wait_huge(struct mm_struct *mm, pte_t *pte)
 {
-	spinlock_t *ptl = &(mm)->page_table_lock;
+	spinlock_t *ptl = huge_pte_lockptr(mm, pte);
 	__migration_entry_wait(mm, pte, ptl);
 }
 
diff --git v3.11-rc3.orig/mm/rmap.c v3.11-rc3/mm/rmap.c
index c56ba98..eccec58 100644
--- v3.11-rc3.orig/mm/rmap.c
+++ v3.11-rc3/mm/rmap.c
@@ -601,7 +601,7 @@ pte_t *__page_check_address(struct page *page, struct mm_struct *mm,
 
 	if (unlikely(PageHuge(page))) {
 		pte = huge_pte_offset(mm, address);
-		ptl = &mm->page_table_lock;
+		ptl = huge_pte_lockptr(mm, pte);
 		goto check;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

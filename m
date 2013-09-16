Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id F3E1D6B00B1
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 07:26:04 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 7/9] mm: convent the rest to new page table lock api
Date: Mon, 16 Sep 2013 14:25:38 +0300
Message-Id: <1379330740-5602-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Only trivial cases left. Let's convert them altogether.

hugetlbfs is not covered for now.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c     | 108 ++++++++++++++++++++++++++++-----------------------
 mm/memory.c          |  17 ++++----
 mm/migrate.c         |   7 ++--
 mm/mprotect.c        |   4 +-
 mm/pgtable-generic.c |   4 +-
 5 files changed, 77 insertions(+), 63 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3a1f5c1..0d85512 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -709,6 +709,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct page *page)
 {
 	pgtable_t pgtable;
+	spinlock_t *ptl;
 
 	VM_BUG_ON(!PageCompound(page));
 	pgtable = pte_alloc_one(mm, haddr);
@@ -723,9 +724,9 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	 */
 	__SetPageUptodate(page);
 
-	spin_lock(&mm->page_table_lock);
+	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_none(*pmd))) {
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 		mem_cgroup_uncharge_page(page);
 		put_page(page);
 		pte_free(mm, pgtable);
@@ -738,7 +739,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		set_pmd_at(mm, haddr, pmd, entry);
 		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		atomic_inc(&mm->nr_ptes);
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 	}
 
 	return 0;
@@ -766,6 +767,7 @@ static inline struct page *alloc_hugepage(int defrag)
 }
 #endif
 
+/* Caller must hold page table lock. */
 static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
 		struct page *zero_page)
@@ -797,6 +799,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_OOM;
 	if (!(flags & FAULT_FLAG_WRITE) &&
 			transparent_hugepage_use_zero_page()) {
+		spinlock_t *ptl;
 		pgtable_t pgtable;
 		struct page *zero_page;
 		bool set;
@@ -809,10 +812,10 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			count_vm_event(THP_FAULT_FALLBACK);
 			return VM_FAULT_FALLBACK;
 		}
-		spin_lock(&mm->page_table_lock);
+		ptl = pmd_lock(mm, pmd);
 		set = set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
 				zero_page);
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 		if (!set) {
 			pte_free(mm, pgtable);
 			put_huge_zero_page();
@@ -845,6 +848,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 		  struct vm_area_struct *vma)
 {
+	spinlock_t *dst_ptl, *src_ptl;
 	struct page *src_page;
 	pmd_t pmd;
 	pgtable_t pgtable;
@@ -855,8 +859,9 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	if (unlikely(!pgtable))
 		goto out;
 
-	spin_lock(&dst_mm->page_table_lock);
-	spin_lock_nested(&src_mm->page_table_lock, SINGLE_DEPTH_NESTING);
+	dst_ptl = pmd_lock(dst_mm, dst_pmd);
+	src_ptl = pmd_lockptr(src_mm, src_pmd);
+	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
 
 	ret = -EAGAIN;
 	pmd = *src_pmd;
@@ -865,7 +870,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out_unlock;
 	}
 	/*
-	 * mm->page_table_lock is enough to be sure that huge zero pmd is not
+	 * When page table lock is held, the huge zero pmd should not be
 	 * under splitting since we don't split the page itself, only pmd to
 	 * a page table.
 	 */
@@ -886,8 +891,8 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	}
 	if (unlikely(pmd_trans_splitting(pmd))) {
 		/* split huge page running from under us */
-		spin_unlock(&src_mm->page_table_lock);
-		spin_unlock(&dst_mm->page_table_lock);
+		spin_unlock(src_ptl);
+		spin_unlock(dst_ptl);
 		pte_free(dst_mm, pgtable);
 
 		wait_split_huge_page(vma->anon_vma, src_pmd); /* src_vma */
@@ -907,8 +912,8 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 
 	ret = 0;
 out_unlock:
-	spin_unlock(&src_mm->page_table_lock);
-	spin_unlock(&dst_mm->page_table_lock);
+	spin_unlock(src_ptl);
+	spin_unlock(dst_ptl);
 out:
 	return ret;
 }
@@ -919,10 +924,11 @@ void huge_pmd_set_accessed(struct mm_struct *mm,
 			   pmd_t *pmd, pmd_t orig_pmd,
 			   int dirty)
 {
+	spinlock_t *ptl;
 	pmd_t entry;
 	unsigned long haddr;
 
-	spin_lock(&mm->page_table_lock);
+	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto unlock;
 
@@ -932,13 +938,14 @@ void huge_pmd_set_accessed(struct mm_struct *mm,
 		update_mmu_cache_pmd(vma, address, pmd);
 
 unlock:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 }
 
 static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long address,
 		pmd_t *pmd, pmd_t orig_pmd, unsigned long haddr)
 {
+	spinlock_t *ptl;
 	pgtable_t pgtable;
 	pmd_t _pmd;
 	struct page *page;
@@ -965,7 +972,7 @@ static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 
-	spin_lock(&mm->page_table_lock);
+	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_free_page;
 
@@ -992,7 +999,7 @@ static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
 	}
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	put_huge_zero_page();
 	inc_mm_counter(mm, MM_ANONPAGES);
 
@@ -1002,7 +1009,7 @@ static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
 out:
 	return ret;
 out_free_page:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	mem_cgroup_uncharge_page(page);
 	put_page(page);
@@ -1016,6 +1023,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 					struct page *page,
 					unsigned long haddr)
 {
+	spinlock_t *ptl;
 	pgtable_t pgtable;
 	pmd_t _pmd;
 	int ret = 0, i;
@@ -1062,7 +1070,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 
-	spin_lock(&mm->page_table_lock);
+	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_free_pages;
 	VM_BUG_ON(!PageHead(page));
@@ -1088,7 +1096,7 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
 	page_remove_rmap(page);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
@@ -1099,7 +1107,7 @@ out:
 	return ret;
 
 out_free_pages:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 	mem_cgroup_uncharge_start();
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
@@ -1114,17 +1122,19 @@ out_free_pages:
 int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
 {
+	spinlock_t *ptl;
 	int ret = 0;
 	struct page *page = NULL, *new_page;
 	unsigned long haddr;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
+	ptl = pmd_lockptr(mm, pmd);
 	VM_BUG_ON(!vma->anon_vma);
 	haddr = address & HPAGE_PMD_MASK;
 	if (is_huge_zero_pmd(orig_pmd))
 		goto alloc;
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	if (unlikely(!pmd_same(*pmd, orig_pmd)))
 		goto out_unlock;
 
@@ -1140,7 +1150,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_unlock;
 	}
 	get_page(page);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow())
@@ -1187,11 +1197,11 @@ alloc:
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
@@ -1213,13 +1223,13 @@ alloc:
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
 
@@ -1231,7 +1241,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page = NULL;
 
-	assert_spin_locked(&mm->page_table_lock);
+	assert_spin_locked(pmd_lockptr(mm, pmd));
 
 	if (flags & FOLL_WRITE && !pmd_write(*pmd))
 		goto out;
@@ -1278,13 +1288,14 @@ out:
 int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp)
 {
+	spinlock_t *ptl;
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
 	int target_nid;
 	int current_nid = -1;
 	bool migrated;
 
-	spin_lock(&mm->page_table_lock);
+	ptl = pmd_lock(mm, pmdp);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
 		goto out_unlock;
 
@@ -1302,17 +1313,17 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -1324,7 +1335,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 
 check_same:
-	spin_lock(&mm->page_table_lock);
+	spin_lock(ptl);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
 		goto out_unlock;
 clear_pmdnuma:
@@ -1333,7 +1344,7 @@ clear_pmdnuma:
 	VM_BUG_ON(pmd_numa(*pmdp));
 	update_mmu_cache_pmd(vma, addr, pmdp);
 out_unlock:
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	if (current_nid != -1)
 		task_numa_fault(current_nid, HPAGE_PMD_NR, false);
 	return 0;
@@ -2282,7 +2293,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pte_t *pte;
 	pgtable_t pgtable;
 	struct page *new_page;
-	spinlock_t *ptl;
+	spinlock_t *pmd_ptl, *pte_ptl;
 	int isolated;
 	unsigned long hstart, hend;
 	unsigned long mmun_start;	/* For mmu_notifiers */
@@ -2325,12 +2336,12 @@ static void collapse_huge_page(struct mm_struct *mm,
 	anon_vma_lock_write(vma->anon_vma);
 
 	pte = pte_offset_map(pmd, address);
-	ptl = pte_lockptr(mm, pmd);
+	pte_ptl = pte_lockptr(mm, pmd);
 
 	mmun_start = address;
 	mmun_end   = address + HPAGE_PMD_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-	spin_lock(&mm->page_table_lock); /* probably unnecessary */
+	pmd_ptl = pmd_lock(mm, pmd); /* probably unnecessary */
 	/*
 	 * After this gup_fast can't run anymore. This also removes
 	 * any huge TLB entry from the CPU so we won't allow
@@ -2338,16 +2349,16 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * to avoid the risk of CPU bugs in that area.
 	 */
 	_pmd = pmdp_clear_flush(vma, address, pmd);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(pmd_ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
-	spin_lock(ptl);
+	spin_lock(pte_ptl);
 	isolated = __collapse_huge_page_isolate(vma, address, pte);
-	spin_unlock(ptl);
+	spin_unlock(pte_ptl);
 
 	if (unlikely(!isolated)) {
 		pte_unmap(pte);
-		spin_lock(&mm->page_table_lock);
+		spin_lock(pmd_ptl);
 		BUG_ON(!pmd_none(*pmd));
 		/*
 		 * We can only use set_pmd_at when establishing
@@ -2355,7 +2366,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 		 * points to regular pagetables. Use pmd_populate for that
 		 */
 		pmd_populate(mm, pmd, pmd_pgtable(_pmd));
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(pmd_ptl);
 		anon_vma_unlock_write(vma->anon_vma);
 		goto out;
 	}
@@ -2366,7 +2377,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	anon_vma_unlock_write(vma->anon_vma);
 
-	__collapse_huge_page_copy(pte, new_page, vma, address, ptl);
+	__collapse_huge_page_copy(pte, new_page, vma, address, pte_ptl);
 	pte_unmap(pte);
 	__SetPageUptodate(new_page);
 	pgtable = pmd_pgtable(_pmd);
@@ -2381,13 +2392,13 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 */
 	smp_wmb();
 
-	spin_lock(&mm->page_table_lock);
+	spin_lock(pmd_ptl);
 	BUG_ON(!pmd_none(*pmd));
 	page_add_new_anon_rmap(new_page, vma, address);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, address, pmd, _pmd);
 	update_mmu_cache_pmd(vma, address, pmd);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(pmd_ptl);
 
 	*hpage = NULL;
 
@@ -2712,6 +2723,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 		pmd_t *pmd)
 {
+	spinlock_t *ptl;
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
@@ -2723,22 +2735,22 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-	spin_lock(&mm->page_table_lock);
+	ptl = pmd_lock(mm, pmd);
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
diff --git a/mm/memory.c b/mm/memory.c
index 1046396..551b15e3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -552,6 +552,7 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 		pmd_t *pmd, unsigned long address)
 {
+	spinlock_t *ptl;
 	pgtable_t new = pte_alloc_one(mm, address);
 	int wait_split_huge_page;
 	if (!new)
@@ -572,7 +573,7 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */
 
-	spin_lock(&mm->page_table_lock);
+	ptl = pmd_lock(mm, pmd);
 	wait_split_huge_page = 0;
 	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
 		atomic_inc(&mm->nr_ptes);
@@ -580,7 +581,7 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 		new = NULL;
 	} else if (unlikely(pmd_trans_splitting(*pmd)))
 		wait_split_huge_page = 1;
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 	if (new)
 		pte_free(mm, new);
 	if (wait_split_huge_page)
@@ -1516,20 +1517,20 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 			split_huge_page_pmd(vma, address, pmd);
 			goto split_fallthrough;
 		}
-		spin_lock(&mm->page_table_lock);
+		ptl = pmd_lock(mm, pmd);
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
@@ -3602,13 +3603,13 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	bool numa = false;
 	int local_nid = numa_node_id();
 
-	spin_lock(&mm->page_table_lock);
+	ptl = pmd_lock(mm, pmdp);
 	pmd = *pmdp;
 	if (pmd_numa(pmd)) {
 		set_pmd_at(mm, _addr, pmdp, pmd_mknonnuma(pmd));
 		numa = true;
 	}
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 
 	if (!numa)
 		return 0;
diff --git a/mm/migrate.c b/mm/migrate.c
index b7ded7e..399d831 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1653,6 +1653,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 				unsigned long address,
 				struct page *page, int node)
 {
+	spinlock_t *ptl;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated = 0;
@@ -1699,9 +1700,9 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	WARN_ON(PageLRU(new_page));
 
 	/* Recheck the target PMD */
-	spin_lock(&mm->page_table_lock);
+	ptl = pmd_lock(mm, pmd);
 	if (unlikely(!pmd_same(*pmd, entry))) {
-		spin_unlock(&mm->page_table_lock);
+		spin_unlock(ptl);
 
 		/* Reverse changes made by migrate_page_copy() */
 		if (TestClearPageActive(new_page))
@@ -1746,7 +1747,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	 * before it's fully transferred to the new page.
 	 */
 	mem_cgroup_end_migration(memcg, page, new_page, true);
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 
 	unlock_page(new_page);
 	unlock_page(page);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 94722a4..d01a535 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -116,9 +116,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
 				       pmd_t *pmd)
 {
-	spin_lock(&mm->page_table_lock);
+	spinlock_t *ptl = pmd_lock(mm, pmd);
 	set_pmd_at(mm, addr & PMD_MASK, pmd, pmd_mknuma(*pmd));
-	spin_unlock(&mm->page_table_lock);
+	spin_unlock(ptl);
 }
 #else
 static inline void change_pmd_protnuma(struct mm_struct *mm, unsigned long addr,
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 41fee3e..cbb3854 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -151,7 +151,7 @@ void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
 void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				pgtable_t pgtable)
 {
-	assert_spin_locked(&mm->page_table_lock);
+	assert_spin_locked(pmd_lockptr(mm, pmdp));
 
 	/* FIFO */
 	if (!pmd_huge_pte(mm, pmdp))
@@ -170,7 +170,7 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 {
 	pgtable_t pgtable;
 
-	assert_spin_locked(&mm->page_table_lock);
+	assert_spin_locked(pmd_lockptr(mm, pmdp));
 
 	/* FIFO */
 	pgtable = pmd_huge_pte(mm, pmdp);
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

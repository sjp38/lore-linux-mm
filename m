Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB476B0080
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 09:47:30 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so7413069pac.2
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:47:29 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id l9si34766250pdj.235.2015.06.23.06.47.14
        for <linux-mm@kvack.org>;
        Tue, 23 Jun 2015 06:47:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 12/36] thp: drop all split_huge_page()-related code
Date: Tue, 23 Jun 2015 16:46:22 +0300
Message-Id: <1435067206-92901-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1435067206-92901-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We will re-introduce new version with new refcounting later in patchset.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/huge_mm.h |  28 +---
 mm/huge_memory.c        | 400 +-----------------------------------------------
 2 files changed, 7 insertions(+), 421 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 34bbf769d52e..47f80207782f 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -97,28 +97,12 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 #endif /* CONFIG_DEBUG_VM */
 
 extern unsigned long transparent_hugepage_flags;
-extern int split_huge_page_to_list(struct page *page, struct list_head *list);
-static inline int split_huge_page(struct page *page)
-{
-	return split_huge_page_to_list(page, NULL);
-}
-extern void __split_huge_page_pmd(struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd);
-#define split_huge_pmd(__vma, __pmd, __address)				\
-	do {								\
-		pmd_t *____pmd = (__pmd);				\
-		if (unlikely(pmd_trans_huge(*____pmd)))			\
-			__split_huge_page_pmd(__vma, __address,		\
-					____pmd);			\
-	}  while (0)
-#define wait_split_huge_page(__anon_vma, __pmd)				\
-	do {								\
-		pmd_t *____pmd = (__pmd);				\
-		anon_vma_lock_write(__anon_vma);			\
-		anon_vma_unlock_write(__anon_vma);			\
-		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
-		       pmd_trans_huge(*____pmd));			\
-	} while (0)
+
+#define split_huge_page_to_list(page, list) BUILD_BUG()
+#define split_huge_page(page) BUILD_BUG()
+#define split_huge_pmd(__vma, __pmd, __address) BUILD_BUG()
+
+#define wait_split_huge_page(__anon_vma, __pmd) BUILD_BUG();
 #if HPAGE_PMD_ORDER >= MAX_ORDER
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cdc3a358eb17..daa12e51fe70 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1673,329 +1673,6 @@ int pmd_freeable(pmd_t pmd)
 	return !pmd_dirty(pmd);
 }
 
-static int __split_huge_page_splitting(struct page *page,
-				       struct vm_area_struct *vma,
-				       unsigned long address)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	spinlock_t *ptl;
-	pmd_t *pmd;
-	int ret = 0;
-	/* For mmu_notifiers */
-	const unsigned long mmun_start = address;
-	const unsigned long mmun_end   = address + HPAGE_PMD_SIZE;
-
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-	pmd = page_check_address_pmd(page, mm, address,
-			PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG, &ptl);
-	if (pmd) {
-		/*
-		 * We can't temporarily set the pmd to null in order
-		 * to split it, the pmd must remain marked huge at all
-		 * times or the VM won't take the pmd_trans_huge paths
-		 * and it won't wait on the anon_vma->root->rwsem to
-		 * serialize against split_huge_page*.
-		 */
-		pmdp_splitting_flush(vma, address, pmd);
-
-		ret = 1;
-		spin_unlock(ptl);
-	}
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-
-	return ret;
-}
-
-static void __split_huge_page_refcount(struct page *page,
-				       struct list_head *list)
-{
-	int i;
-	struct zone *zone = page_zone(page);
-	struct lruvec *lruvec;
-	int tail_count = 0;
-
-	/* prevent PageLRU to go away from under us, and freeze lru stats */
-	spin_lock_irq(&zone->lru_lock);
-	lruvec = mem_cgroup_page_lruvec(page, zone);
-
-	compound_lock(page);
-	/* complete memcg works before add pages to LRU */
-	mem_cgroup_split_huge_fixup(page);
-
-	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
-		struct page *page_tail = page + i;
-
-		/* tail_page->_mapcount cannot change */
-		BUG_ON(page_mapcount(page_tail) < 0);
-		tail_count += page_mapcount(page_tail);
-		/* check for overflow */
-		BUG_ON(tail_count < 0);
-		BUG_ON(atomic_read(&page_tail->_count) != 0);
-		/*
-		 * tail_page->_count is zero and not changing from
-		 * under us. But get_page_unless_zero() may be running
-		 * from under us on the tail_page. If we used
-		 * atomic_set() below instead of atomic_add(), we
-		 * would then run atomic_set() concurrently with
-		 * get_page_unless_zero(), and atomic_set() is
-		 * implemented in C not using locked ops. spin_unlock
-		 * on x86 sometime uses locked ops because of PPro
-		 * errata 66, 92, so unless somebody can guarantee
-		 * atomic_set() here would be safe on all archs (and
-		 * not only on x86), it's safer to use atomic_add().
-		 */
-		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
-			   &page_tail->_count);
-
-		/* after clearing PageTail the gup refcount can be released */
-		smp_mb__after_atomic();
-
-		/*
-		 * retain hwpoison flag of the poisoned tail page:
-		 *   fix for the unsuitable process killed on Guest Machine(KVM)
-		 *   by the memory-failure.
-		 */
-		page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP | __PG_HWPOISON;
-		page_tail->flags |= (page->flags &
-				     ((1L << PG_referenced) |
-				      (1L << PG_swapbacked) |
-				      (1L << PG_mlocked) |
-				      (1L << PG_uptodate) |
-				      (1L << PG_active) |
-				      (1L << PG_unevictable)));
-		page_tail->flags |= (1L << PG_dirty);
-
-		/* clear PageTail before overwriting first_page */
-		smp_wmb();
-
-		/*
-		 * __split_huge_page_splitting() already set the
-		 * splitting bit in all pmd that could map this
-		 * hugepage, that will ensure no CPU can alter the
-		 * mapcount on the head page. The mapcount is only
-		 * accounted in the head page and it has to be
-		 * transferred to all tail pages in the below code. So
-		 * for this code to be safe, the split the mapcount
-		 * can't change. But that doesn't mean userland can't
-		 * keep changing and reading the page contents while
-		 * we transfer the mapcount, so the pmd splitting
-		 * status is achieved setting a reserved bit in the
-		 * pmd, not by clearing the present bit.
-		*/
-		page_tail->_mapcount = page->_mapcount;
-
-		BUG_ON(page_tail->mapping != TAIL_MAPPING);
-		page_tail->mapping = page->mapping;
-
-		page_tail->index = page->index + i;
-		page_cpupid_xchg_last(page_tail, page_cpupid_last(page));
-
-		BUG_ON(!PageAnon(page_tail));
-		BUG_ON(!PageUptodate(page_tail));
-		BUG_ON(!PageDirty(page_tail));
-		BUG_ON(!PageSwapBacked(page_tail));
-
-		lru_add_page_tail(page, page_tail, lruvec, list);
-	}
-	atomic_sub(tail_count, &page->_count);
-	BUG_ON(atomic_read(&page->_count) <= 0);
-
-	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
-
-	ClearPageCompound(page);
-	compound_unlock(page);
-	spin_unlock_irq(&zone->lru_lock);
-
-	for (i = 1; i < HPAGE_PMD_NR; i++) {
-		struct page *page_tail = page + i;
-		BUG_ON(page_count(page_tail) <= 0);
-		/*
-		 * Tail pages may be freed if there wasn't any mapping
-		 * like if add_to_swap() is running on a lru page that
-		 * had its mapping zapped. And freeing these pages
-		 * requires taking the lru_lock so we do the put_page
-		 * of the tail pages after the split is complete.
-		 */
-		put_page(page_tail);
-	}
-
-	/*
-	 * Only the head page (now become a regular page) is required
-	 * to be pinned by the caller.
-	 */
-	BUG_ON(page_count(page) <= 0);
-}
-
-static int __split_huge_page_map(struct page *page,
-				 struct vm_area_struct *vma,
-				 unsigned long address)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	spinlock_t *ptl;
-	pmd_t *pmd, _pmd;
-	int ret = 0, i;
-	pgtable_t pgtable;
-	unsigned long haddr;
-
-	pmd = page_check_address_pmd(page, mm, address,
-			PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG, &ptl);
-	if (pmd) {
-		pgtable = pgtable_trans_huge_withdraw(mm, pmd);
-		pmd_populate(mm, &_pmd, pgtable);
-		if (pmd_write(*pmd))
-			BUG_ON(page_mapcount(page) != 1);
-
-		haddr = address;
-		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
-			pte_t *pte, entry;
-			BUG_ON(PageCompound(page+i));
-			/*
-			 * Note that NUMA hinting access restrictions are not
-			 * transferred to avoid any possibility of altering
-			 * permissions across VMAs.
-			 */
-			entry = mk_pte(page + i, vma->vm_page_prot);
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-			if (!pmd_write(*pmd))
-				entry = pte_wrprotect(entry);
-			if (!pmd_young(*pmd))
-				entry = pte_mkold(entry);
-			pte = pte_offset_map(&_pmd, haddr);
-			BUG_ON(!pte_none(*pte));
-			set_pte_at(mm, haddr, pte, entry);
-			pte_unmap(pte);
-		}
-
-		smp_wmb(); /* make pte visible before pmd */
-		/*
-		 * Up to this point the pmd is present and huge and
-		 * userland has the whole access to the hugepage
-		 * during the split (which happens in place). If we
-		 * overwrite the pmd with the not-huge version
-		 * pointing to the pte here (which of course we could
-		 * if all CPUs were bug free), userland could trigger
-		 * a small page size TLB miss on the small sized TLB
-		 * while the hugepage TLB entry is still established
-		 * in the huge TLB. Some CPU doesn't like that. See
-		 * http://support.amd.com/us/Processor_TechDocs/41322.pdf,
-		 * Erratum 383 on page 93. Intel should be safe but is
-		 * also warns that it's only safe if the permission
-		 * and cache attributes of the two entries loaded in
-		 * the two TLB is identical (which should be the case
-		 * here). But it is generally safer to never allow
-		 * small and huge TLB entries for the same virtual
-		 * address to be loaded simultaneously. So instead of
-		 * doing "pmd_populate(); flush_tlb_range();" we first
-		 * mark the current pmd notpresent (atomically because
-		 * here the pmd_trans_huge and pmd_trans_splitting
-		 * must remain set at all times on the pmd until the
-		 * split is complete for this pmd), then we flush the
-		 * SMP TLB and finally we write the non-huge version
-		 * of the pmd entry with pmd_populate.
-		 */
-		pmdp_invalidate(vma, address, pmd);
-		pmd_populate(mm, pmd, pgtable);
-		ret = 1;
-		spin_unlock(ptl);
-	}
-
-	return ret;
-}
-
-/* must be called with anon_vma->root->rwsem held */
-static void __split_huge_page(struct page *page,
-			      struct anon_vma *anon_vma,
-			      struct list_head *list)
-{
-	int mapcount, mapcount2;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-	struct anon_vma_chain *avc;
-
-	BUG_ON(!PageHead(page));
-	BUG_ON(PageTail(page));
-
-	mapcount = 0;
-	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
-		struct vm_area_struct *vma = avc->vma;
-		unsigned long addr = vma_address(page, vma);
-		BUG_ON(is_vma_temporary_stack(vma));
-		mapcount += __split_huge_page_splitting(page, vma, addr);
-	}
-	/*
-	 * It is critical that new vmas are added to the tail of the
-	 * anon_vma list. This guarantes that if copy_huge_pmd() runs
-	 * and establishes a child pmd before
-	 * __split_huge_page_splitting() freezes the parent pmd (so if
-	 * we fail to prevent copy_huge_pmd() from running until the
-	 * whole __split_huge_page() is complete), we will still see
-	 * the newly established pmd of the child later during the
-	 * walk, to be able to set it as pmd_trans_splitting too.
-	 */
-	if (mapcount != page_mapcount(page)) {
-		pr_err("mapcount %d page_mapcount %d\n",
-			mapcount, page_mapcount(page));
-		BUG();
-	}
-
-	__split_huge_page_refcount(page, list);
-
-	mapcount2 = 0;
-	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
-		struct vm_area_struct *vma = avc->vma;
-		unsigned long addr = vma_address(page, vma);
-		BUG_ON(is_vma_temporary_stack(vma));
-		mapcount2 += __split_huge_page_map(page, vma, addr);
-	}
-	if (mapcount != mapcount2) {
-		pr_err("mapcount %d mapcount2 %d page_mapcount %d\n",
-			mapcount, mapcount2, page_mapcount(page));
-		BUG();
-	}
-}
-
-/*
- * Split a hugepage into normal pages. This doesn't change the position of head
- * page. If @list is null, tail pages will be added to LRU list, otherwise, to
- * @list. Both head page and tail pages will inherit mapping, flags, and so on
- * from the hugepage.
- * Return 0 if the hugepage is split successfully otherwise return 1.
- */
-int split_huge_page_to_list(struct page *page, struct list_head *list)
-{
-	struct anon_vma *anon_vma;
-	int ret = 1;
-
-	BUG_ON(is_huge_zero_page(page));
-	BUG_ON(!PageAnon(page));
-
-	/*
-	 * The caller does not necessarily hold an mmap_sem that would prevent
-	 * the anon_vma disappearing so we first we take a reference to it
-	 * and then lock the anon_vma for write. This is similar to
-	 * page_lock_anon_vma_read except the write lock is taken to serialise
-	 * against parallel split or collapse operations.
-	 */
-	anon_vma = page_get_anon_vma(page);
-	if (!anon_vma)
-		goto out;
-	anon_vma_lock_write(anon_vma);
-
-	ret = 0;
-	if (!PageCompound(page))
-		goto out_unlock;
-
-	BUG_ON(!PageSwapBacked(page));
-	__split_huge_page(page, anon_vma, list);
-	count_vm_event(THP_SPLIT_PAGE);
-
-	BUG_ON(PageCompound(page));
-out_unlock:
-	anon_vma_unlock_write(anon_vma);
-	put_anon_vma(anon_vma);
-out:
-	return ret;
-}
-
 #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
@@ -2935,81 +2612,6 @@ static int khugepaged(void *none)
 	return 0;
 }
 
-static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
-		unsigned long haddr, pmd_t *pmd)
-{
-	struct mm_struct *mm = vma->vm_mm;
-	pgtable_t pgtable;
-	pmd_t _pmd;
-	int i;
-
-	pmdp_huge_clear_flush_notify(vma, haddr, pmd);
-	/* leave pmd empty until pte is filled */
-
-	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
-	pmd_populate(mm, &_pmd, pgtable);
-
-	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
-		pte_t *pte, entry;
-		entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
-		entry = pte_mkspecial(entry);
-		pte = pte_offset_map(&_pmd, haddr);
-		VM_BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, haddr, pte, entry);
-		pte_unmap(pte);
-	}
-	smp_wmb(); /* make pte visible before pmd */
-	pmd_populate(mm, pmd, pgtable);
-	put_huge_zero_page();
-}
-
-void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
-		pmd_t *pmd)
-{
-	spinlock_t *ptl;
-	struct page *page;
-	struct mm_struct *mm = vma->vm_mm;
-	unsigned long haddr = address & HPAGE_PMD_MASK;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
-
-	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
-
-	mmun_start = haddr;
-	mmun_end   = haddr + HPAGE_PMD_SIZE;
-again:
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_trans_huge(*pmd))) {
-		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-		return;
-	}
-	if (is_huge_zero_pmd(*pmd)) {
-		__split_huge_zero_page_pmd(vma, haddr, pmd);
-		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-		return;
-	}
-	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!page_count(page), page);
-	get_page(page);
-	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-
-	split_huge_page(page);
-
-	put_page(page);
-
-	/*
-	 * We don't always have down_write of mmap_sem here: a racing
-	 * do_huge_pmd_wp_page() might have copied-on-write to another
-	 * huge page before our split_huge_page() got the anon_vma lock.
-	 */
-	if (unlikely(pmd_trans_huge(*pmd)))
-		goto again;
-}
-
 static void split_huge_pmd_address(struct vm_area_struct *vma,
 				    unsigned long address)
 {
@@ -3034,7 +2636,7 @@ static void split_huge_pmd_address(struct vm_area_struct *vma,
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
 	 * materialize from under us.
 	 */
-	__split_huge_page_pmd(vma, address, pmd);
+	split_huge_pmd(vma, pmd, address);
 }
 
 void __vma_adjust_trans_huge(struct vm_area_struct *vma,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0C8828DF
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:56:27 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id bx7so2492261pad.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:56:27 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id l77si3947538pfb.252.2016.04.05.14.56.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:56:26 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id zm5so18684679pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:56:26 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:56:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 25/31] huge tmpfs recovery: shmem_recovery_remap &
 remap_team_by_pmd
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051455010.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

And once we have a fully populated huge page, replace the pte mappings
(by now already pointing into this huge page, as page migration has
arranged) by a huge pmd mapping - not just in the mm which prompted
this work, but in any other mm which might benefit from it.

However, the transition from pte mappings to huge pmd mapping is a
new one, which may surprise code elsewhere - pte_offset_map() and
pte_offset_map_lock() in particular.  See the earlier discussion in
"huge tmpfs: avoid premature exposure of new pagetable", but now we
are forced to go beyond its solution.

The answer will be to put *pmd checking inside them, and examine
whether a pagetable page could ever be recycled for another purpose
before the pte lock is taken: the deposit/withdraw protocol, and
mmap_sem conventions, work nicely against that danger; but special
attention will have to be paid to MADV_DONTNEED's zap_huge_pmd()
pte_free under down_read of mmap_sem.

Avoid those complications for now: just use a rather unwelcome
down_write or down_write_trylock of mmap_sem here in
shmem_recovery_remap(), to exclude msyscalls or faults or ptrace or
GUP or NUMA work or /proc access.  rmap access is already excluded
by our holding i_mmap_rwsem.  Fast GUP on x86 is made safe by the
TLB flush in remap_team_by_pmd()'s pmdp_collapse_flush(), its IPIs
as usual blocked by fast GUP's local_irq_disable().  Fast GUP on
powerpc is made safe as usual by its RCU freeing of page tables
(though zap_huge_pmd()'s pte_free appears to violate that, but
if so it's an issue for anon THP too: investigate further later).

Does remap_team_by_pmd() really need its mmu_notifier_invalidate_range
pair?  The manner of mapping changes, but nothing is actually unmapped.
Of course, the same question can be asked of remap_team_by_ptes().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/pageteam.h |    2 
 mm/huge_memory.c         |   87 +++++++++++++++++++++++++++++++++++++
 mm/shmem.c               |   76 ++++++++++++++++++++++++++++++++
 3 files changed, 165 insertions(+)

--- a/include/linux/pageteam.h
+++ b/include/linux/pageteam.h
@@ -313,6 +313,8 @@ void unmap_team_by_pmd(struct vm_area_st
 			unsigned long addr, pmd_t *pmd, struct page *page);
 void remap_team_by_ptes(struct vm_area_struct *vma,
 			unsigned long addr, pmd_t *pmd);
+void remap_team_by_pmd(struct vm_area_struct *vma,
+			unsigned long addr, pmd_t *pmd, struct page *page);
 #else
 static inline int map_team_by_pmd(struct vm_area_struct *vma,
 			unsigned long addr, pmd_t *pmd, struct page *page)
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3706,3 +3706,90 @@ raced:
 	spin_unlock(pml);
 	mmu_notifier_invalidate_range_end(mm, addr, end);
 }
+
+void remap_team_by_pmd(struct vm_area_struct *vma, unsigned long addr,
+		       pmd_t *pmd, struct page *head)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct page *page = head;
+	pgtable_t pgtable;
+	unsigned long end;
+	spinlock_t *pml;
+	spinlock_t *ptl;
+	pmd_t pmdval;
+	pte_t *pte;
+	int rss = 0;
+
+	VM_BUG_ON_PAGE(!PageTeam(head), head);
+	VM_BUG_ON_PAGE(!PageLocked(head), head);
+	VM_BUG_ON(addr & ~HPAGE_PMD_MASK);
+	end = addr + HPAGE_PMD_SIZE;
+
+	mmu_notifier_invalidate_range_start(mm, addr, end);
+	pml = pmd_lock(mm, pmd);
+	pmdval = *pmd;
+	/* I don't see how this can happen now, but be defensive */
+	if (pmd_trans_huge(pmdval) || pmd_none(pmdval))
+		goto out;
+
+	ptl = pte_lockptr(mm, pmd);
+	if (ptl != pml)
+		spin_lock(ptl);
+
+	pgtable = pmd_pgtable(pmdval);
+	pmdval = mk_pmd(head, vma->vm_page_prot);
+	pmdval = pmd_mkhuge(pmd_mkdirty(pmdval));
+
+	/* Perhaps wise to mark head as mapped before removing pte rmaps */
+	page_add_file_rmap(head);
+
+	/*
+	 * Just as remap_team_by_ptes() would prefer to fill the page table
+	 * earlier, remap_team_by_pmd() would prefer to empty it later; but
+	 * ppc64's variant of the deposit/withdraw protocol prevents that.
+	 */
+	pte = pte_offset_map(pmd, addr);
+	do {
+		if (pte_none(*pte))
+			continue;
+
+		VM_BUG_ON(!pte_present(*pte));
+		VM_BUG_ON(pte_page(*pte) != page);
+
+		pte_clear(mm, addr, pte);
+		page_remove_rmap(page, false);
+		put_page(page);
+		rss++;
+	} while (pte++, page++, addr += PAGE_SIZE, addr != end);
+
+	pte -= HPAGE_PMD_NR;
+	addr -= HPAGE_PMD_SIZE;
+
+	if (rss) {
+		pmdp_collapse_flush(vma, addr, pmd);
+		pgtable_trans_huge_deposit(mm, pmd, pgtable);
+		set_pmd_at(mm, addr, pmd, pmdval);
+		update_mmu_cache_pmd(vma, addr, pmd);
+		get_page(head);
+		page_add_team_rmap(head);
+		add_mm_counter(mm, MM_SHMEMPAGES, HPAGE_PMD_NR - rss);
+	} else {
+		/*
+		 * Hmm.  We might have caught this vma in between unmap_vmas()
+		 * and free_pgtables(), which is a surprising time to insert a
+		 * huge page.  Before our caller checked mm_users, I sometimes
+		 * saw a "bad pmd" report, and pgtable_pmd_page_dtor() BUG on
+		 * pmd_huge_pte, when killing off tests.  But checking mm_users
+		 * is not enough to protect against munmap(): so for safety,
+		 * back out if we found no ptes to replace.
+		 */
+		page_remove_rmap(head, false);
+	}
+
+	if (ptl != pml)
+		spin_unlock(ptl);
+	pte_unmap(pte);
+out:
+	spin_unlock(pml);
+	mmu_notifier_invalidate_range_end(mm, addr, end);
+}
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1097,6 +1097,82 @@ unlock:
 
 static void shmem_recovery_remap(struct recovery *recovery, struct page *head)
 {
+	struct mm_struct *mm = recovery->mm;
+	struct address_space *mapping = head->mapping;
+	pgoff_t pgoff = head->index;
+	struct vm_area_struct *vma;
+	unsigned long addr;
+	pmd_t *pmd;
+	bool try_other_mms = false;
+
+	/*
+	 * XXX: This use of mmap_sem is regrettable.  It is needed for one
+	 * reason only: because callers of pte_offset_map(_lock)() are not
+	 * prepared for a huge pmd to appear in place of a page table at any
+	 * instant.  That can be fixed in pte_offset_map(_lock)() and callers,
+	 * but that is a more invasive change, so just do it this way for now.
+	 */
+	down_write(&mm->mmap_sem);
+	lock_page(head);
+	if (!PageTeam(head)) {
+		unlock_page(head);
+		up_write(&mm->mmap_sem);
+		return;
+	}
+	VM_BUG_ON_PAGE(!PageChecked(head), head);
+	i_mmap_lock_write(mapping);
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		/* XXX: Use anon_vma as over-strict hint of COWed pages */
+		if (vma->anon_vma)
+			continue;
+		addr = vma_address(head, vma);
+		if (addr & (HPAGE_PMD_SIZE-1))
+			continue;
+		if (vma->vm_end < addr + HPAGE_PMD_SIZE)
+			continue;
+		if (!atomic_read(&vma->vm_mm->mm_users))
+			continue;
+		if (vma->vm_mm != mm) {
+			try_other_mms = true;
+			continue;
+		}
+		/* Only replace existing ptes: empty pmd can fault for itself */
+		pmd = mm_find_pmd(vma->vm_mm, addr);
+		if (!pmd)
+			continue;
+		remap_team_by_pmd(vma, addr, pmd, head);
+		shr_stats(remap_faulter);
+	}
+	up_write(&mm->mmap_sem);
+	if (!try_other_mms)
+		goto out;
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		if (vma->vm_mm == mm)
+			continue;
+		/* XXX: Use anon_vma as over-strict hint of COWed pages */
+		if (vma->anon_vma)
+			continue;
+		addr = vma_address(head, vma);
+		if (addr & (HPAGE_PMD_SIZE-1))
+			continue;
+		if (vma->vm_end < addr + HPAGE_PMD_SIZE)
+			continue;
+		if (!atomic_read(&vma->vm_mm->mm_users))
+			continue;
+		/* Only replace existing ptes: empty pmd can fault for itself */
+		pmd = mm_find_pmd(vma->vm_mm, addr);
+		if (!pmd)
+			continue;
+		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
+			remap_team_by_pmd(vma, addr, pmd, head);
+			shr_stats(remap_another);
+			up_write(&vma->vm_mm->mmap_sem);
+		} else
+			shr_stats(remap_untried);
+	}
+out:
+	i_mmap_unlock_write(mapping);
+	unlock_page(head);
 }
 
 static void shmem_recovery_work(struct work_struct *work)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

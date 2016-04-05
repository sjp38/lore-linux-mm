Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 14F416B0299
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:25:39 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id zm5so18259458pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:25:39 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id m27si41640439pfj.88.2016.04.05.14.25.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:25:38 -0700 (PDT)
Received: by mail-pa0-x22d.google.com with SMTP id zm5so18259235pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:25:38 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:25:35 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 10/31] huge tmpfs: map shmem by huge page pmd or by page team
 ptes
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051424280.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is the commit which at last gets huge mappings of tmpfs working,
as can be seen from the ShmemPmdMapped line of /proc/meminfo.

The main thing here is the trio of functions map_team_by_pmd(),
unmap_team_by_pmd() and remap_team_by_ptes() added to huge_memory.c;
and of course the enablement of FAULT_FLAG_MAY_HUGE from memory.c
to shmem.c, with VM_FAULT_HUGE back from shmem.c to memory.c.  But
one-line and few-line changes scattered throughout huge_memory.c.

Huge tmpfs is relying on the pmd_trans_huge() page table hooks which
the original Anonymous THP project placed throughout mm; but skips
almost all of its complications, going to its own simpler handling.

Kirill has a much better idea of what copy_huge_pmd() should do for
pagecache: nothing, just as we don't copy shared file ptes.  I shall
adopt his idea in a future version, but for now show how to dup team.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 Documentation/vm/transhuge.txt |   38 ++++-
 include/linux/pageteam.h       |   48 ++++++
 mm/huge_memory.c               |  229 +++++++++++++++++++++++++++++--
 mm/memory.c                    |   12 +
 4 files changed, 307 insertions(+), 20 deletions(-)

--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -9,8 +9,8 @@ using huge pages for the backing of virt
 that supports the automatic promotion and demotion of page sizes and
 without the shortcomings of hugetlbfs.
 
-Currently it only works for anonymous memory mappings but in the
-future it can expand over the pagecache layer starting with tmpfs.
+Initially it only worked for anonymous memory mappings, but then was
+extended to the pagecache layer, starting with tmpfs.
 
 The reason applications are running faster is because of two
 factors. The first factor is almost completely irrelevant and it's not
@@ -57,9 +57,8 @@ miss is going to run faster.
   feature that applies to all dynamic high order allocations in the
   kernel)
 
-- this initial support only offers the feature in the anonymous memory
-  regions but it'd be ideal to move it to tmpfs and the pagecache
-  later
+- initial support only offered the feature in anonymous memory regions,
+  but then it was extended to huge tmpfs pagecache: see section below.
 
 Transparent Hugepage Support maximizes the usefulness of free memory
 if compared to the reservation approach of hugetlbfs by allowing all
@@ -458,3 +457,32 @@ exit(2) if an THP crosses VMA boundary.
 Function deferred_split_huge_page() is used to queue page for splitting.
 The splitting itself will happen when we get memory pressure via shrinker
 interface.
+
+== Huge tmpfs ==
+
+Transparent hugepages were implemented much later in tmpfs.
+That implementation shares much of the "pmd" infrastructure
+devised for anonymous hugepages, and their reliance on compaction.
+
+But unlike hugetlbfs, which has always been free to impose its own
+restrictions, a transparent implementation of pagecache in tmpfs must
+be able to support files both large and small, with large extents
+mapped by hugepage pmds at the same time as small extents (of the
+very same pagecache) are mapped by ptes.  For this reason, the
+compound pages used for hugetlbfs and anonymous hugepages were found
+unsuitable, and the opposite approach taken: the high-order backing
+page is split from the start, and managed as a team of partially
+independent small cache pages.
+
+Huge tmpfs is enabled simply by a "huge=1" mount option, and does not
+attend to the boot options, sysfs settings and madvice controlling
+anonymous hugepages.  Huge tmpfs recovery (putting a hugepage back
+together after it was disbanded for reclaim, or after a period of
+fragmentation) is done by a workitem scheduled from fault, without
+involving khugepaged at all.
+
+For more info on huge tmpfs, see Documentation/filesystems/tmpfs.txt.
+It is an open question whether that implementation forms the basis for
+extending transparent hugepages to other filesystems' pagecache: in its
+present form, it makes use of struct page's private field, available on
+tmpfs, but already in use on most other filesystems.
--- a/include/linux/pageteam.h
+++ b/include/linux/pageteam.h
@@ -29,10 +29,56 @@ static inline struct page *team_head(str
 	return head;
 }
 
-/* Temporary stub for mm/rmap.c until implemented in mm/huge_memory.c */
+/*
+ * Returns true if this team is mapped by pmd somewhere.
+ */
+static inline bool team_pmd_mapped(struct page *head)
+{
+	return atomic_long_read(&head->team_usage) > HPAGE_PMD_NR;
+}
+
+/*
+ * Returns true if this was the first mapping by pmd, whereupon mapped stats
+ * need to be updated.
+ */
+static inline bool inc_team_pmd_mapped(struct page *head)
+{
+	return atomic_long_inc_return(&head->team_usage) == HPAGE_PMD_NR+1;
+}
+
+/*
+ * Returns true if this was the last mapping by pmd, whereupon mapped stats
+ * need to be updated.
+ */
+static inline bool dec_team_pmd_mapped(struct page *head)
+{
+	return atomic_long_dec_return(&head->team_usage) == HPAGE_PMD_NR;
+}
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+int map_team_by_pmd(struct vm_area_struct *vma,
+			unsigned long addr, pmd_t *pmd, struct page *page);
+void unmap_team_by_pmd(struct vm_area_struct *vma,
+			unsigned long addr, pmd_t *pmd, struct page *page);
+void remap_team_by_ptes(struct vm_area_struct *vma,
+			unsigned long addr, pmd_t *pmd);
+#else
+static inline int map_team_by_pmd(struct vm_area_struct *vma,
+			unsigned long addr, pmd_t *pmd, struct page *page)
+{
+	VM_BUG_ON_PAGE(1, page);
+	return 0;
+}
 static inline void unmap_team_by_pmd(struct vm_area_struct *vma,
 			unsigned long addr, pmd_t *pmd, struct page *page)
 {
+	VM_BUG_ON_PAGE(1, page);
+}
+static inline void remap_team_by_ptes(struct vm_area_struct *vma,
+			unsigned long addr, pmd_t *pmd)
+{
+	VM_BUG_ON(1);
 }
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_PAGETEAM_H */
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -25,6 +25,7 @@
 #include <linux/mman.h>
 #include <linux/memremap.h>
 #include <linux/pagemap.h>
+#include <linux/pageteam.h>
 #include <linux/debugfs.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
@@ -63,6 +64,8 @@ enum scan_result {
 #define CREATE_TRACE_POINTS
 #include <trace/events/huge_memory.h>
 
+static void page_remove_team_rmap(struct page *);
+
 /*
  * By default transparent hugepage support is disabled in order that avoid
  * to risk increase the memory footprint of applications without a guaranteed
@@ -1120,17 +1123,23 @@ int copy_huge_pmd(struct mm_struct *dst_
 	if (!vma_is_dax(vma)) {
 		/* thp accounting separate from pmd_devmap accounting */
 		src_page = pmd_page(pmd);
-		VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
 		get_page(src_page);
-		page_dup_rmap(src_page, true);
-		add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+		if (PageAnon(src_page)) {
+			VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
+			page_dup_rmap(src_page, true);
+			pmdp_set_wrprotect(src_mm, addr, src_pmd);
+			pmd = pmd_wrprotect(pmd);
+		} else {
+			VM_BUG_ON_PAGE(!PageTeam(src_page), src_page);
+			page_dup_rmap(src_page, false);
+			inc_team_pmd_mapped(src_page);
+		}
+		add_mm_counter(dst_mm, mm_counter(src_page), HPAGE_PMD_NR);
 		atomic_long_inc(&dst_mm->nr_ptes);
 		pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 	}
 
-	pmdp_set_wrprotect(src_mm, addr, src_pmd);
-	pmd = pmd_mkold(pmd_wrprotect(pmd));
-	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
+	set_pmd_at(dst_mm, addr, dst_pmd, pmd_mkold(pmd));
 
 	ret = 0;
 out_unlock:
@@ -1429,7 +1438,7 @@ struct page *follow_trans_huge_pmd(struc
 		goto out;
 
 	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG_ON_PAGE(!PageHead(page) && !PageTeam(page), page);
 	if (flags & FOLL_TOUCH)
 		touch_pmd(vma, addr, pmd);
 	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
@@ -1454,7 +1463,7 @@ struct page *follow_trans_huge_pmd(struc
 		}
 	}
 	page += (addr & ~HPAGE_PMD_MASK) >> PAGE_SHIFT;
-	VM_BUG_ON_PAGE(!PageCompound(page), page);
+	VM_BUG_ON_PAGE(!PageCompound(page) && !PageTeam(page), page);
 	if (flags & FOLL_GET)
 		get_page(page);
 
@@ -1692,10 +1701,12 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 		put_huge_zero_page();
 	} else {
 		struct page *page = pmd_page(orig_pmd);
-		page_remove_rmap(page, true);
+		if (PageTeam(page))
+			page_remove_team_rmap(page);
+		page_remove_rmap(page, PageHead(page));
 		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-		add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
-		VM_BUG_ON_PAGE(!PageHead(page), page);
+		VM_BUG_ON_PAGE(!PageHead(page) && !PageTeam(page), page);
+		add_mm_counter(tlb->mm, mm_counter(page), -HPAGE_PMD_NR);
 		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
 		atomic_long_dec(&tlb->mm->nr_ptes);
 		spin_unlock(ptl);
@@ -1739,7 +1750,7 @@ bool move_huge_pmd(struct vm_area_struct
 		VM_BUG_ON(!pmd_none(*new_pmd));
 
 		if (pmd_move_must_withdraw(new_ptl, old_ptl) &&
-				vma_is_anonymous(vma)) {
+				!vma_is_dax(vma)) {
 			pgtable_t pgtable;
 			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
 			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
@@ -1789,7 +1800,6 @@ int change_huge_pmd(struct vm_area_struc
 				entry = pmd_mkwrite(entry);
 			ret = HPAGE_PMD_NR;
 			set_pmd_at(mm, addr, pmd, entry);
-			BUG_ON(!preserve_write && pmd_write(entry));
 		}
 		spin_unlock(ptl);
 	}
@@ -2991,6 +3001,11 @@ void __split_huge_pmd(struct vm_area_str
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 
+	if (!vma_is_anonymous(vma) && !vma->vm_ops->pmd_fault) {
+		remap_team_by_ptes(vma, address, pmd);
+		return;
+	}
+
 	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
 	ptl = pmd_lock(mm, pmd);
 	if (pmd_trans_huge(*pmd)) {
@@ -3469,4 +3484,190 @@ static int __init split_huge_pages_debug
 	return 0;
 }
 late_initcall(split_huge_pages_debugfs);
-#endif
+#endif /* CONFIG_DEBUG_FS */
+
+/*
+ * huge pmd support for huge tmpfs
+ */
+
+static void page_add_team_rmap(struct page *page)
+{
+	VM_BUG_ON_PAGE(PageAnon(page), page);
+	VM_BUG_ON_PAGE(!PageTeam(page), page);
+	if (inc_team_pmd_mapped(page))
+		__inc_zone_page_state(page, NR_SHMEM_PMDMAPPED);
+}
+
+static void page_remove_team_rmap(struct page *page)
+{
+	VM_BUG_ON_PAGE(PageAnon(page), page);
+	VM_BUG_ON_PAGE(!PageTeam(page), page);
+	if (dec_team_pmd_mapped(page))
+		__dec_zone_page_state(page, NR_SHMEM_PMDMAPPED);
+}
+
+int map_team_by_pmd(struct vm_area_struct *vma, unsigned long addr,
+		    pmd_t *pmd, struct page *page)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgtable_t pgtable;
+	spinlock_t *pml;
+	pmd_t pmdval;
+	int ret = VM_FAULT_NOPAGE;
+
+	/*
+	 * Another task may have mapped it in just ahead of us; but we
+	 * have the huge page locked, so others will wait on us now... or,
+	 * is there perhaps some way another might still map in a single pte?
+	 */
+	VM_BUG_ON_PAGE(!PageTeam(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	if (!pmd_none(*pmd))
+		goto raced2;
+
+	addr &= HPAGE_PMD_MASK;
+	pgtable = pte_alloc_one(mm, addr);
+	if (!pgtable) {
+		ret = VM_FAULT_OOM;
+		goto raced2;
+	}
+
+	pml = pmd_lock(mm, pmd);
+	if (!pmd_none(*pmd))
+		goto raced1;
+	pmdval = mk_pmd(page, vma->vm_page_prot);
+	pmdval = pmd_mkhuge(pmd_mkdirty(pmdval));
+	pgtable_trans_huge_deposit(mm, pmd, pgtable);
+	set_pmd_at(mm, addr, pmd, pmdval);
+	page_add_file_rmap(page);
+	page_add_team_rmap(page);
+	update_mmu_cache_pmd(vma, addr, pmd);
+	atomic_long_inc(&mm->nr_ptes);
+	spin_unlock(pml);
+
+	unlock_page(page);
+	add_mm_counter(mm, MM_SHMEMPAGES, HPAGE_PMD_NR);
+	return ret;
+raced1:
+	spin_unlock(pml);
+	pte_free(mm, pgtable);
+raced2:
+	unlock_page(page);
+	put_page(page);
+	return ret;
+}
+
+void unmap_team_by_pmd(struct vm_area_struct *vma, unsigned long addr,
+		       pmd_t *pmd, struct page *page)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgtable_t pgtable = NULL;
+	unsigned long end;
+	spinlock_t *pml;
+
+	VM_BUG_ON_PAGE(!PageTeam(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	/*
+	 * But even so there might be a racing zap_huge_pmd() or
+	 * remap_team_by_ptes() while the page_table_lock is dropped.
+	 */
+
+	addr &= HPAGE_PMD_MASK;
+	end = addr + HPAGE_PMD_SIZE;
+
+	mmu_notifier_invalidate_range_start(mm, addr, end);
+	pml = pmd_lock(mm, pmd);
+	if (pmd_trans_huge(*pmd) && pmd_page(*pmd) == page) {
+		pmdp_huge_clear_flush(vma, addr, pmd);
+		pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+		page_remove_team_rmap(page);
+		page_remove_rmap(page, false);
+		atomic_long_dec(&mm->nr_ptes);
+	}
+	spin_unlock(pml);
+	mmu_notifier_invalidate_range_end(mm, addr, end);
+
+	if (!pgtable)
+		return;
+
+	pte_free(mm, pgtable);
+	update_hiwater_rss(mm);
+	add_mm_counter(mm, MM_SHMEMPAGES, -HPAGE_PMD_NR);
+	put_page(page);
+}
+
+void remap_team_by_ptes(struct vm_area_struct *vma, unsigned long addr,
+			pmd_t *pmd)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	struct page *head;
+	struct page *page;
+	pgtable_t pgtable;
+	unsigned long end;
+	spinlock_t *pml;
+	spinlock_t *ptl;
+	pte_t *pte;
+	pmd_t _pmd;
+	pmd_t pmdval;
+	pte_t pteval;
+
+	addr &= HPAGE_PMD_MASK;
+	end = addr + HPAGE_PMD_SIZE;
+
+	mmu_notifier_invalidate_range_start(mm, addr, end);
+	pml = pmd_lock(mm, pmd);
+	if (!pmd_trans_huge(*pmd))
+		goto raced;
+
+	page = head = pmd_page(*pmd);
+	pmdval = pmdp_huge_clear_flush(vma, addr, pmd);
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+	pmd_populate(mm, &_pmd, pgtable);
+	ptl = pte_lockptr(mm, &_pmd);
+	if (ptl != pml)
+		spin_lock(ptl);
+	pmd_populate(mm, pmd, pgtable);
+	update_mmu_cache_pmd(vma, addr, pmd);
+
+	/*
+	 * It would be nice to have prepared this page table in advance,
+	 * so we could just switch from pmd to ptes under one lock.
+	 * But a comment in zap_huge_pmd() warns that ppc64 needs
+	 * to look at the deposited page table when clearing the pmd.
+	 */
+	pte = pte_offset_map(pmd, addr);
+	do {
+		pteval = pte_mkdirty(mk_pte(page, vma->vm_page_prot));
+		if (!pmd_young(pmdval))
+			pteval = pte_mkold(pteval);
+		set_pte_at(mm, addr, pte, pteval);
+		VM_BUG_ON_PAGE(!PageTeam(page), page);
+		if (page != head) {
+			page_add_file_rmap(page);
+			get_page(page);
+		}
+		/*
+		 * Move page flags from head to page,
+		 * as __split_huge_page_tail() does for anon?
+		 * Start off by assuming not, but reconsider later.
+		 */
+	} while (pte++, page++, addr += PAGE_SIZE, addr != end);
+
+	/*
+	 * remap_team_by_ptes() is called from various locking contexts.
+	 * Don't dec_team_pmd_mapped() until after that page table has been
+	 * completed (with atomic_long_sub_return supplying a barrier):
+	 * otherwise shmem_disband_hugeteam() may disband it concurrently,
+	 * and pages be freed while mapped.
+	 */
+	page_remove_team_rmap(head);
+
+	pte -= HPAGE_PMD_NR;
+	addr -= HPAGE_PMD_NR;
+	if (ptl != pml)
+		spin_unlock(ptl);
+	pte_unmap(pte);
+raced:
+	spin_unlock(pml);
+	mmu_notifier_invalidate_range_end(mm, addr, end);
+}
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -45,6 +45,7 @@
 #include <linux/swap.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/pageteam.h>
 #include <linux/ksm.h>
 #include <linux/rmap.h>
 #include <linux/export.h>
@@ -2809,11 +2810,21 @@ static int __do_fault(struct vm_area_str
 	vmf.gfp_mask = __get_fault_gfp_mask(vma);
 	vmf.cow_page = cow_page;
 
+	/*
+	 * Give huge pmd a chance before allocating pte or trying fault around.
+	 */
+	if (unlikely(pmd_none(*pmd)))
+		vmf.flags |= FAULT_FLAG_MAY_HUGE;
+
 	ret = vma->vm_ops->fault(vma, &vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 	if (!vmf.page)
 		goto out;
+	if (unlikely(ret & VM_FAULT_HUGE)) {
+		ret |= map_team_by_pmd(vma, address, pmd, vmf.page);
+		return ret;
+	}
 
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
 		lock_page(vmf.page);
@@ -3304,6 +3315,7 @@ static int wp_huge_pmd(struct mm_struct
 		return do_huge_pmd_wp_page(mm, vma, address, pmd, orig_pmd);
 	if (vma->vm_ops->pmd_fault)
 		return vma->vm_ops->pmd_fault(vma, address, pmd, flags);
+	remap_team_by_ptes(vma, address, pmd);
 	return VM_FAULT_FALLBACK;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

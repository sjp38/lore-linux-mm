Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 752D26B0038
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 12:24:55 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so7951473pab.35
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 09:24:55 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id tq5si19664056pac.182.2014.02.11.09.24.54
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 09:24:54 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, thp: drop do_huge_pmd_wp_zero_page_fallback()
Date: Tue, 11 Feb 2014 19:24:46 +0200
Message-Id: <1392139486-15520-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I've realized that there's no need in do_huge_pmd_wp_zero_page_fallback().
We can just split zero page with split_huge_page_pmd() and return
VM_FAULT_FALLBACK. handle_pte_fault() will handle write-protection fault
for us.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 79 ++------------------------------------------------------
 1 file changed, 2 insertions(+), 77 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 65a88bef8694..436fd2b51284 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -941,81 +941,6 @@ unlock:
 	spin_unlock(ptl);
 }
 
-static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
-		struct vm_area_struct *vma, unsigned long address,
-		pmd_t *pmd, pmd_t orig_pmd, unsigned long haddr)
-{
-	spinlock_t *ptl;
-	pgtable_t pgtable;
-	pmd_t _pmd;
-	struct page *page;
-	int i, ret = 0;
-	unsigned long mmun_start;	/* For mmu_notifiers */
-	unsigned long mmun_end;		/* For mmu_notifiers */
-
-	page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
-	if (!page) {
-		ret |= VM_FAULT_OOM;
-		goto out;
-	}
-
-	if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL)) {
-		put_page(page);
-		ret |= VM_FAULT_OOM;
-		goto out;
-	}
-
-	clear_user_highpage(page, address);
-	__SetPageUptodate(page);
-
-	mmun_start = haddr;
-	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-
-	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_same(*pmd, orig_pmd)))
-		goto out_free_page;
-
-	pmdp_clear_flush(vma, haddr, pmd);
-	/* leave pmd empty until pte is filled */
-
-	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
-	pmd_populate(mm, &_pmd, pgtable);
-
-	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
-		pte_t *pte, entry;
-		if (haddr == (address & PAGE_MASK)) {
-			entry = mk_pte(page, vma->vm_page_prot);
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-			page_add_new_anon_rmap(page, vma, haddr);
-		} else {
-			entry = pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
-			entry = pte_mkspecial(entry);
-		}
-		pte = pte_offset_map(&_pmd, haddr);
-		VM_BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, haddr, pte, entry);
-		pte_unmap(pte);
-	}
-	smp_wmb(); /* make pte visible before pmd */
-	pmd_populate(mm, pmd, pgtable);
-	spin_unlock(ptl);
-	put_huge_zero_page();
-	inc_mm_counter(mm, MM_ANONPAGES);
-
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-
-	ret |= VM_FAULT_WRITE;
-out:
-	return ret;
-out_free_page:
-	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-	mem_cgroup_uncharge_page(page);
-	put_page(page);
-	goto out;
-}
-
 static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long address,
@@ -1161,8 +1086,8 @@ alloc:
 
 	if (unlikely(!new_page)) {
 		if (!page) {
-			ret = do_huge_pmd_wp_zero_page_fallback(mm, vma,
-					address, pmd, orig_pmd, haddr);
+			split_huge_page_pmd(vma, address, pmd);
+			ret |= VM_FAULT_FALLBACK;
 		} else {
 			ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
 					pmd, orig_pmd, page, haddr);
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

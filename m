Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE626B0256
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 05:09:33 -0500 (EST)
Received: by pasz6 with SMTP id z6so28338806pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 02:09:33 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id qw9si11787455pbb.172.2015.11.11.02.09.32
        for <linux-mm@kvack.org>;
        Wed, 11 Nov 2015 02:09:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: fix leak due split_huge_page() vs. exit race
Date: Wed, 11 Nov 2015 12:09:27 +0200
Message-Id: <1447236567-68751-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Consider following race:

		CPU0				CPU1
shrink_page_list()
  add_to_swap()
    split_huge_page_to_list()
      __split_huge_pmd_locked()
        pmdp_huge_clear_flush_notify()
	// pmd_none() == true
					exit_mmap()
					  unmap_vmas()
					    zap_pmd_range()
					      // no action on pmd since pmd_none() == true
	pmd_populate()

As result the THP will not be freed. The leak is detected by check_mm():

	BUG: Bad rss-counter state mm:ffff880058d2e580 idx:1 val:512

The patch restore the logic original split_huge_page() had before
refcounting rework: never have intermediate pmd_none() == true.

There are few other places where we do have pmd_none() == true for some
time, but they are safe:

 - __split_huge_zero_page_pmd() is not reachable during exit, since huge
   zero page is not on LRU.

 - do_huge_pmd_wp_page() and do_huge_pmd_wp_page_fallback() are also not
   reachable during exit: exit_mmap() and handling page fault for the mm
   are mutual exclusive.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6834b39a7114..91e2f4b7ca39 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2809,9 +2809,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	write = pmd_write(*pmd);
 	young = pmd_young(*pmd);
 
-	/* leave pmd empty until pte is filled */
-	pmdp_huge_clear_flush_notify(vma, haddr, pmd);
-
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);
 
@@ -2861,6 +2858,28 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	}
 
 	smp_wmb(); /* make pte visible before pmd */
+	/*
+	 * Up to this point the pmd is present and huge and userland has the
+	 * whole access to the hugepage during the split (which happens in
+	 * place). If we overwrite the pmd with the not-huge version pointing
+	 * to the pte here (which of course we could if all CPUs were bug
+	 * free), userland could trigger a small page size TLB miss on the
+	 * small sized TLB while the hugepage TLB entry is still established in
+	 * the huge TLB. Some CPU doesn't like that.
+	 * See http://support.amd.com/us/Processor_TechDocs/41322.pdf, Erratum
+	 * 383 on page 93. Intel should be safe but is also warns that it's
+	 * only safe if the permission and cache attributes of the two entries
+	 * loaded in the two TLB is identical (which should be the case here).
+	 * But it is generally safer to never allow small and huge TLB entries
+	 * for the same virtual address to be loaded simultaneously. So instead
+	 * of doing "pmd_populate(); flush_pmd_tlb_range();" we first mark the
+	 * current pmd notpresent (atomically because here the pmd_trans_huge
+	 * and pmd_trans_splitting must remain set at all times on the pmd
+	 * until the split is complete for this pmd), then we flush the SMP TLB
+	 * and finally we write the non-huge version of the pmd entry with
+	 * pmd_populate.
+	 */
+	pmdp_invalidate(vma, haddr, pmd);
 	pmd_populate(mm, pmd, pgtable);
 
 	if (freeze) {
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

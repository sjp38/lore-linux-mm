Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 97B6F6B0259
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:24 -0400 (EDT)
Received: by pacgq8 with SMTP id gq8so15960356pac.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:24 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id bw2si775930pbd.161.2015.08.04.12.58.13
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:14 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 08/11] thp: Fix zap_huge_pmd() for DAX
Date: Tue,  4 Aug 2015 15:58:02 -0400
Message-Id: <1438718285-21168-9-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, willy@linux.intel.com

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The original DAX code assumed that pgtable_t was a pointer, which isn't
true on all architectures.  Restructure the code to not rely on that
assumption.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
[further fixes from Matthew integrated into this patch]
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 mm/huge_memory.c | 71 +++++++++++++++++++++++++-------------------------------
 1 file changed, 31 insertions(+), 40 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 326d17e..b51bed1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1426,50 +1426,41 @@ out:
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
+	pmd_t orig_pmd;
 	spinlock_t *ptl;
-	int ret = 0;
 
-	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		pgtable_t pgtable;
-		pmd_t orig_pmd;
-		/*
-		 * For architectures like ppc64 we look at deposited pgtable
-		 * when calling pmdp_huge_get_and_clear. So do the
-		 * pgtable_trans_huge_withdraw after finishing pmdp related
-		 * operations.
-		 */
-		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
-							tlb->fullmm);
-		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
-		if (vma_is_dax(vma)) {
-			if (is_huge_zero_pmd(orig_pmd)) {
-				pgtable = NULL;
-			} else {
-				spin_unlock(ptl);
-				return 1;
-			}
-		} else {
-			pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
-		}
-		if (is_huge_zero_pmd(orig_pmd)) {
-			atomic_long_dec(&tlb->mm->nr_ptes);
-			spin_unlock(ptl);
+	if (__pmd_trans_huge_lock(pmd, vma, &ptl) != 1)
+		return 0;
+	/*
+	 * For architectures like ppc64 we look at deposited pgtable
+	 * when calling pmdp_huge_get_and_clear. So do the
+	 * pgtable_trans_huge_withdraw after finishing pmdp related
+	 * operations.
+	 */
+	orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
+			tlb->fullmm);
+	tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
+	if (vma_is_dax(vma)) {
+		spin_unlock(ptl);
+		if (is_huge_zero_pmd(orig_pmd))
 			put_huge_zero_page();
-		} else {
-			struct page *page = pmd_page(orig_pmd);
-			page_remove_rmap(page);
-			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
-			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
-			VM_BUG_ON_PAGE(!PageHead(page), page);
-			atomic_long_dec(&tlb->mm->nr_ptes);
-			spin_unlock(ptl);
-			tlb_remove_page(tlb, page);
-		}
-		if (pgtable)
-			pte_free(tlb->mm, pgtable);
-		ret = 1;
+	} else if (is_huge_zero_pmd(orig_pmd)) {
+		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
+		atomic_long_dec(&tlb->mm->nr_ptes);
+		spin_unlock(ptl);
+		put_huge_zero_page();
+	} else {
+		struct page *page = pmd_page(orig_pmd);
+		page_remove_rmap(page);
+		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
+		add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+		VM_BUG_ON_PAGE(!PageHead(page), page);
+		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
+		atomic_long_dec(&tlb->mm->nr_ptes);
+		spin_unlock(ptl);
+		tlb_remove_page(tlb, page);
 	}
-	return ret;
+	return 1;
 }
 
 int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

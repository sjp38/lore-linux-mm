Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A0D2B9003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 16:29:38 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so173435495pac.2
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:29:38 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id iw5si15355719pbc.27.2015.07.10.13.29.35
        for <linux-mm@kvack.org>;
        Fri, 10 Jul 2015 13:29:35 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 03/10] thp: Prepare for DAX huge pages
Date: Fri, 10 Jul 2015 16:29:18 -0400
Message-Id: <1436560165-8943-4-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1436560165-8943-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Add a vma_is_dax() helper macro to test whether the VMA is DAX, and use
it in zap_huge_pmd() and __split_huge_page_pmd().

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/dax.h |  4 ++++
 mm/huge_memory.c    | 46 ++++++++++++++++++++++++++++------------------
 2 files changed, 32 insertions(+), 18 deletions(-)

diff --git a/include/linux/dax.h b/include/linux/dax.h
index 4f27d3d..9b51f9d 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -18,4 +18,8 @@ int dax_pfn_mkwrite(struct vm_area_struct *, struct vm_fault *);
 #define dax_mkwrite(vma, vmf, gb, iod)		dax_fault(vma, vmf, gb, iod)
 #define __dax_mkwrite(vma, vmf, gb, iod)	__dax_fault(vma, vmf, gb, iod)
 
+static inline bool vma_is_dax(struct vm_area_struct *vma)
+{
+	return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
+}
 #endif
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 911071b..b7bd855 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -23,6 +23,7 @@
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
+#include <linux/dax.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -1391,7 +1392,6 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	int ret = 0;
 
 	if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
-		struct page *page;
 		pgtable_t pgtable;
 		pmd_t orig_pmd;
 		/*
@@ -1403,13 +1403,22 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
 							tlb->fullmm);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
-		pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
+		if (vma_is_dax(vma)) {
+			if (is_huge_zero_pmd(orig_pmd)) {
+				pgtable = NULL;
+			} else {
+				spin_unlock(ptl);
+				return 1;
+			}
+		} else {
+			pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
+		}
 		if (is_huge_zero_pmd(orig_pmd)) {
 			atomic_long_dec(&tlb->mm->nr_ptes);
 			spin_unlock(ptl);
 			put_huge_zero_page();
 		} else {
-			page = pmd_page(orig_pmd);
+			struct page *page = pmd_page(orig_pmd);
 			page_remove_rmap(page);
 			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
@@ -1418,7 +1427,8 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			spin_unlock(ptl);
 			tlb_remove_page(tlb, page);
 		}
-		pte_free(tlb->mm, pgtable);
+		if (pgtable)
+			pte_free(tlb->mm, pgtable);
 		ret = 1;
 	}
 	return ret;
@@ -2887,7 +2897,7 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 		pmd_t *pmd)
 {
 	spinlock_t *ptl;
-	struct page *page;
+	struct page *page = NULL;
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 	unsigned long mmun_start;	/* For mmu_notifiers */
@@ -2900,25 +2910,25 @@ void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
 again:
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	ptl = pmd_lock(mm, pmd);
-	if (unlikely(!pmd_trans_huge(*pmd))) {
-		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-		return;
-	}
-	if (is_huge_zero_pmd(*pmd)) {
+	if (unlikely(!pmd_trans_huge(*pmd)))
+		goto unlock;
+	if (vma_is_dax(vma)) {
+		pmdp_huge_clear_flush(vma, haddr, pmd);
+	} else if (is_huge_zero_pmd(*pmd)) {
 		__split_huge_zero_page_pmd(vma, haddr, pmd);
-		spin_unlock(ptl);
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
-		return;
+	} else {
+		page = pmd_page(*pmd);
+		VM_BUG_ON_PAGE(!page_count(page), page);
+		get_page(page);
 	}
-	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!page_count(page), page);
-	get_page(page);
+ unlock:
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
-	split_huge_page(page);
+	if (!page)
+		return;
 
+	split_huge_page(page);
 	put_page(page);
 
 	/*
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

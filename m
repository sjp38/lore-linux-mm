Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE2FF6B0253
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 11:14:33 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id u25so31183597qki.3
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 08:14:33 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id h188si23278409qke.106.2017.02.05.08.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Feb 2017 08:14:33 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v3 02/14] mm: thp: create new __zap_huge_pmd_locked function.
Date: Sun,  5 Feb 2017 11:12:40 -0500
Message-Id: <20170205161252.85004-3-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-1-zi.yan@sent.com>
References: <20170205161252.85004-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

It allows removing huge pmd while holding the pmd lock.
It is prepared for future zap_pmd_range() use.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 include/linux/huge_mm.h |  3 +++
 mm/huge_memory.c        | 27 ++++++++++++++++++---------
 2 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 2036f69c8284..44ee130c7207 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -26,6 +26,9 @@ extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 extern bool madvise_free_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr, unsigned long next);
+extern int __zap_huge_pmd_locked(struct mmu_gather *tlb,
+			struct vm_area_struct *vma,
+			pmd_t *pmd, unsigned long addr);
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cd66532ef667..d8e15fd817b0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1590,17 +1590,12 @@ static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
 	atomic_long_dec(&mm->nr_ptes);
 }
 
-int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
+int __zap_huge_pmd_locked(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
 	pmd_t orig_pmd;
-	spinlock_t *ptl;
 
 	tlb_remove_check_page_size_change(tlb, HPAGE_PMD_SIZE);
-
-	ptl = __pmd_trans_huge_lock(pmd, vma);
-	if (!ptl)
-		return 0;
 	/*
 	 * For architectures like ppc64 we look at deposited pgtable
 	 * when calling pmdp_huge_get_and_clear. So do the
@@ -1611,13 +1606,11 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			tlb->fullmm);
 	tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 	if (vma_is_dax(vma)) {
-		spin_unlock(ptl);
 		if (is_huge_zero_pmd(orig_pmd))
 			tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
 	} else if (is_huge_zero_pmd(orig_pmd)) {
 		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
 		atomic_long_dec(&tlb->mm->nr_ptes);
-		spin_unlock(ptl);
 		tlb_remove_page_size(tlb, pmd_page(orig_pmd), HPAGE_PMD_SIZE);
 	} else {
 		struct page *page = pmd_page(orig_pmd);
@@ -1635,9 +1628,25 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 				zap_deposited_table(tlb->mm, pmd);
 			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
 		}
-		spin_unlock(ptl);
 		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
 	}
+
+	return 1;
+}
+
+int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
+		 pmd_t *pmd, unsigned long addr)
+{
+	spinlock_t *ptl;
+
+
+	ptl = __pmd_trans_huge_lock(pmd, vma);
+	if (!ptl)
+		return 0;
+
+	__zap_huge_pmd_locked(tlb, vma, pmd, addr);
+
+	spin_unlock(ptl);
 	return 1;
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

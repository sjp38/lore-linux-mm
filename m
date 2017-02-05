Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A503F6B0033
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 11:14:33 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id w20so70907609qtb.3
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 08:14:33 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id p37si3614226qkp.199.2017.02.05.08.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Feb 2017 08:14:32 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v3 01/14] mm: thp: make __split_huge_pmd_locked visible.
Date: Sun,  5 Feb 2017 11:12:39 -0500
Message-Id: <20170205161252.85004-2-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-1-zi.yan@sent.com>
References: <20170205161252.85004-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

It allows splitting huge pmd while you are holding the pmd lock.
It is prepared for future zap_pmd_range() use.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 include/linux/huge_mm.h |  2 ++
 mm/huge_memory.c        | 22 ++++++++++++----------
 2 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a3762d49ba39..2036f69c8284 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -120,6 +120,8 @@ static inline int split_huge_page(struct page *page)
 }
 void deferred_split_huge_page(struct page *page);
 
+void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long haddr, bool freeze);
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long address, bool freeze, struct page *page);
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 03e4566fc226..cd66532ef667 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1877,8 +1877,8 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 	pmd_populate(mm, pmd, pgtable);
 }
 
-static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long haddr, bool freeze)
+void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
+		unsigned long address, bool freeze)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page;
@@ -1887,6 +1887,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	bool young, write, dirty, soft_dirty;
 	unsigned long addr;
 	int i;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
 
 	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
 	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
@@ -1895,6 +1896,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	count_vm_event(THP_SPLIT_PMD);
 
+	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
+
 	if (!vma_is_anonymous(vma)) {
 		_pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
 		/*
@@ -1904,16 +1907,17 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		if (arch_needs_pgtable_deposit())
 			zap_deposited_table(mm, pmd);
 		if (vma_is_dax(vma))
-			return;
+			goto out;
 		page = pmd_page(_pmd);
 		if (!PageReferenced(page) && pmd_young(_pmd))
 			SetPageReferenced(page);
 		page_remove_rmap(page, true);
 		put_page(page);
 		add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
-		return;
+		goto out;
 	} else if (is_huge_zero_pmd(*pmd)) {
-		return __split_huge_zero_page_pmd(vma, haddr, pmd);
+		__split_huge_zero_page_pmd(vma, haddr, pmd);
+		goto out;
 	}
 
 	page = pmd_page(*pmd);
@@ -2010,6 +2014,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			put_page(page + i);
 		}
 	}
+out:
+	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
 }
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
@@ -2017,11 +2023,8 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 {
 	spinlock_t *ptl;
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long haddr = address & HPAGE_PMD_MASK;
 
-	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
 	ptl = pmd_lock(mm, pmd);
-
 	/*
 	 * If caller asks to setup a migration entries, we need a page to check
 	 * pmd against. Otherwise we can end up replacing wrong page.
@@ -2036,10 +2039,9 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			clear_page_mlock(page);
 	} else if (!pmd_devmap(*pmd))
 		goto out;
-	__split_huge_pmd_locked(vma, pmd, haddr, freeze);
+	__split_huge_pmd_locked(vma, pmd, address, freeze);
 out:
 	spin_unlock(ptl);
-	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
 }
 
 void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

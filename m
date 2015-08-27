Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id B7CE76B0254
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:04:57 -0400 (EDT)
Received: by pacti10 with SMTP id ti10so19423660pac.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 02:04:57 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id z15si2514846pbt.189.2015.08.27.02.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 02:04:56 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 08/11] mm,thp: reduce ifdef'ery for THP in generic code
Date: Thu, 27 Aug 2015 14:33:11 +0530
Message-ID: <1440666194-21478-9-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arc-linux-dev@synopsys.com, Vineet Gupta <Vineet.Gupta1@synopsys.com>

This is purely cosmetic, just makes code more readable

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 include/asm-generic/pgtable.h | 20 ++++++++++++++++++++
 mm/pgtable-generic.c          | 24 +++---------------------
 2 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 29c57b2cb344..11e8bf45a08f 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -30,9 +30,20 @@ extern int ptep_set_access_flags(struct vm_area_struct *vma,
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern int pmdp_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp,
 				 pmd_t entry, int dirty);
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+static inline int pmdp_set_access_flags(struct vm_area_struct *vma,
+					unsigned long address, pmd_t *pmdp,
+					pmd_t entry, int dirty)
+{
+	BUG();
+	return 0;
+}
+
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
@@ -81,8 +92,17 @@ int ptep_clear_flush_young(struct vm_area_struct *vma,
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 int pmdp_clear_flush_young(struct vm_area_struct *vma,
 			   unsigned long address, pmd_t *pmdp);
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+static inline int pmdp_clear_flush_young(struct vm_area_struct *vma,
+					 unsigned long address, pmd_t *pmdp)
+{
+	BUG();
+	return 0;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 48851894e699..c9c59bb75a17 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -82,12 +82,13 @@ pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
 }
 #endif
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+
 #ifndef __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
 int pmdp_set_access_flags(struct vm_area_struct *vma,
 			  unsigned long address, pmd_t *pmdp,
 			  pmd_t entry, int dirty)
 {
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	int changed = !pmd_same(*pmdp, entry);
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	if (changed) {
@@ -95,10 +96,6 @@ int pmdp_set_access_flags(struct vm_area_struct *vma,
 		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	}
 	return changed;
-#else /* CONFIG_TRANSPARENT_HUGEPAGE */
-	BUG();
-	return 0;
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 }
 #endif
 
@@ -107,11 +104,7 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
 			   unsigned long address, pmd_t *pmdp)
 {
 	int young;
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-#else
-	BUG();
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 	young = pmdp_test_and_clear_young(vma, address, pmdp);
 	if (young)
 		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
@@ -120,7 +113,6 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_HUGE_CLEAR_FLUSH
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
 			    pmd_t *pmdp)
 {
@@ -131,11 +123,9 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
 }
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
 			  pmd_t *pmdp)
 {
@@ -145,11 +135,9 @@ void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
 	/* tlb flush only to serialize against gup-fast */
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 }
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				pgtable_t pgtable)
 {
@@ -162,11 +150,9 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 		list_add(&pgtable->lru, &pmd_huge_pte(mm, pmdp)->lru);
 	pmd_huge_pte(mm, pmdp) = pgtable;
 }
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
 #ifndef __HAVE_ARCH_PGTABLE_WITHDRAW
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 /* no "address" argument so destroys page coloring of some arch */
 pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 {
@@ -185,11 +171,9 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	}
 	return pgtable;
 }
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_INVALIDATE
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 		     pmd_t *pmdp)
 {
@@ -197,11 +181,9 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 }
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
 #ifndef pmdp_collapse_flush
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
 			  pmd_t *pmdp)
 {
@@ -217,5 +199,5 @@ pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
 	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
 }
-#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

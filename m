Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 953326B0260
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 06:36:48 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so6119999pac.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 03:36:48 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id ge9si1558120pbc.39.2015.09.22.03.36.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 03:36:47 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH v2 10/12] mm,thp: introduce flush_pmd_tlb_range
Date: Tue, 22 Sep 2015 16:04:54 +0530
Message-ID: <1442918096-17454-11-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
References: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vineet Gupta <Vineet.Gupta1@synopsys.com>

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 mm/huge_memory.c     |  2 +-
 mm/pgtable-generic.c | 25 +++++++++++++++++++------
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4b06b8db9df2..e25eb3d2081a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1880,7 +1880,7 @@ static int __split_huge_page_map(struct page *page,
 		 * here). But it is generally safer to never allow
 		 * small and huge TLB entries for the same virtual
 		 * address to be loaded simultaneously. So instead of
-		 * doing "pmd_populate(); flush_tlb_range();" we first
+		 * doing "pmd_populate(); flush_pmd_tlb_range();" we first
 		 * mark the current pmd notpresent (atomically because
 		 * here the pmd_trans_huge and pmd_trans_splitting
 		 * must remain set at all times on the pmd until the
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index c9c59bb75a17..b0fed9a4776e 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -84,6 +84,19 @@ pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
+#ifndef __HAVE_ARCH_FLUSH_PMD_TLB_RANGE
+
+/*
+ * ARCHes with special requirements for evicting THP backing TLB entries can
+ * implement this. Otherwise also, it can help optimizing thp flush operation.
+ * flush_tlb_range() can have optimization to nuke the entire TLB if flush span
+ * is greater than a threashhold, which will likely be true for a single
+ * huge page.
+ * e.g. see arch/arc: flush_pmd_tlb_range
+ */
+#define flush_pmd_tlb_range(vma, addr, end)	flush_tlb_range(vma, addr, end)
+#endif
+
 #ifndef __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
 int pmdp_set_access_flags(struct vm_area_struct *vma,
 			  unsigned long address, pmd_t *pmdp,
@@ -93,7 +106,7 @@ int pmdp_set_access_flags(struct vm_area_struct *vma,
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	if (changed) {
 		set_pmd_at(vma->vm_mm, address, pmdp, entry);
-		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+		flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	}
 	return changed;
 }
@@ -107,7 +120,7 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	young = pmdp_test_and_clear_young(vma, address, pmdp);
 	if (young)
-		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+		flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return young;
 }
 #endif
@@ -120,7 +133,7 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	VM_BUG_ON(!pmd_trans_huge(*pmdp));
 	pmd = pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
-	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
 }
 #endif
@@ -133,7 +146,7 @@ void pmdp_splitting_flush(struct vm_area_struct *vma, unsigned long address,
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	set_pmd_at(vma->vm_mm, address, pmdp, pmd);
 	/* tlb flush only to serialize against gup-fast */
-	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 }
 #endif
 
@@ -179,7 +192,7 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 {
 	pmd_t entry = *pmdp;
 	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(entry));
-	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 }
 #endif
 
@@ -196,7 +209,7 @@ pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 	VM_BUG_ON(pmd_trans_huge(*pmdp));
 	pmd = pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
-	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
+	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
 	return pmd;
 }
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A94516B0257
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:04:48 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so19136190pab.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 02:04:48 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id k12si2546913pbq.59.2015.08.27.02.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 02:04:47 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 07/11] mm: move some code around
Date: Thu, 27 Aug 2015 14:33:10 +0530
Message-ID: <1440666194-21478-8-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arc-linux-dev@synopsys.com, Vineet Gupta <Vineet.Gupta1@synopsys.com>

This reduces/simplifies the diff for the next patch which moves THP
specific code.

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 mm/pgtable-generic.c | 50 +++++++++++++++++++++++++-------------------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 6b674e00153c..48851894e699 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -57,6 +57,31 @@ int ptep_set_access_flags(struct vm_area_struct *vma,
 }
 #endif
 
+#ifndef __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
+int ptep_clear_flush_young(struct vm_area_struct *vma,
+			   unsigned long address, pte_t *ptep)
+{
+	int young;
+	young = ptep_test_and_clear_young(vma, address, ptep);
+	if (young)
+		flush_tlb_page(vma, address);
+	return young;
+}
+#endif
+
+#ifndef __HAVE_ARCH_PTEP_CLEAR_FLUSH
+pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
+		       pte_t *ptep)
+{
+	struct mm_struct *mm = (vma)->vm_mm;
+	pte_t pte;
+	pte = ptep_get_and_clear(mm, address, ptep);
+	if (pte_accessible(mm, pte))
+		flush_tlb_page(vma, address);
+	return pte;
+}
+#endif
+
 #ifndef __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
 int pmdp_set_access_flags(struct vm_area_struct *vma,
 			  unsigned long address, pmd_t *pmdp,
@@ -77,18 +102,6 @@ int pmdp_set_access_flags(struct vm_area_struct *vma,
 }
 #endif
 
-#ifndef __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
-int ptep_clear_flush_young(struct vm_area_struct *vma,
-			   unsigned long address, pte_t *ptep)
-{
-	int young;
-	young = ptep_test_and_clear_young(vma, address, ptep);
-	if (young)
-		flush_tlb_page(vma, address);
-	return young;
-}
-#endif
-
 #ifndef __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
 int pmdp_clear_flush_young(struct vm_area_struct *vma,
 			   unsigned long address, pmd_t *pmdp)
@@ -106,19 +119,6 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
 }
 #endif
 
-#ifndef __HAVE_ARCH_PTEP_CLEAR_FLUSH
-pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
-		       pte_t *ptep)
-{
-	struct mm_struct *mm = (vma)->vm_mm;
-	pte_t pte;
-	pte = ptep_get_and_clear(mm, address, ptep);
-	if (pte_accessible(mm, pte))
-		flush_tlb_page(vma, address);
-	return pte;
-}
-#endif
-
 #ifndef __HAVE_ARCH_PMDP_HUGE_CLEAR_FLUSH
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma, unsigned long address,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

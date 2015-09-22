Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8E43C6B0256
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 06:35:31 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so6091598pac.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 03:35:31 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id fd7si1466057pab.199.2015.09.22.03.35.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 03:35:30 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH v2 01/12] ARC: mm: switch pgtable_to to pte_t *
Date: Tue, 22 Sep 2015 16:04:45 +0530
Message-ID: <1442918096-17454-2-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
References: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vineet Gupta <Vineet.Gupta1@synopsys.com>

ARC is the only arch with unsigned long type (vs. struct page *).
Historically this was done to avoid the page_address() calls in various
arch hooks which need to get the virtual/logical address of the table.

Some arches alternately define it as pte_t *, and is as efficient as
unsigned long (generated code doesn't change)

Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/page.h    | 4 ++--
 arch/arc/include/asm/pgalloc.h | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/arc/include/asm/page.h b/arch/arc/include/asm/page.h
index 9c8aa41e45c2..2994cac1069e 100644
--- a/arch/arc/include/asm/page.h
+++ b/arch/arc/include/asm/page.h
@@ -43,7 +43,6 @@ typedef struct {
 typedef struct {
 	unsigned long pgprot;
 } pgprot_t;
-typedef unsigned long pgtable_t;
 
 #define pte_val(x)      ((x).pte)
 #define pgd_val(x)      ((x).pgd)
@@ -60,7 +59,6 @@ typedef unsigned long pgtable_t;
 typedef unsigned long pte_t;
 typedef unsigned long pgd_t;
 typedef unsigned long pgprot_t;
-typedef unsigned long pgtable_t;
 
 #define pte_val(x)	(x)
 #define pgd_val(x)	(x)
@@ -71,6 +69,8 @@ typedef unsigned long pgtable_t;
 
 #endif
 
+typedef pte_t * pgtable_t;
+
 #define ARCH_PFN_OFFSET     (CONFIG_LINUX_LINK_BASE >> PAGE_SHIFT)
 
 #define pfn_valid(pfn)      (((pfn) - ARCH_PFN_OFFSET) < max_mapnr)
diff --git a/arch/arc/include/asm/pgalloc.h b/arch/arc/include/asm/pgalloc.h
index 81208bfd9dcb..9149b5ca26d7 100644
--- a/arch/arc/include/asm/pgalloc.h
+++ b/arch/arc/include/asm/pgalloc.h
@@ -107,7 +107,7 @@ pte_alloc_one(struct mm_struct *mm, unsigned long address)
 	pgtable_t pte_pg;
 	struct page *page;
 
-	pte_pg = __get_free_pages(GFP_KERNEL | __GFP_REPEAT, __get_order_pte());
+	pte_pg = (pgtable_t)__get_free_pages(GFP_KERNEL | __GFP_REPEAT, __get_order_pte());
 	if (!pte_pg)
 		return 0;
 	memzero((void *)pte_pg, PTRS_PER_PTE * 4);
@@ -128,12 +128,12 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 static inline void pte_free(struct mm_struct *mm, pgtable_t ptep)
 {
 	pgtable_page_dtor(virt_to_page(ptep));
-	free_pages(ptep, __get_order_pte());
+	free_pages((unsigned long)ptep, __get_order_pte());
 }
 
 #define __pte_free_tlb(tlb, pte, addr)  pte_free((tlb)->mm, pte)
 
 #define check_pgt_cache()   do { } while (0)
-#define pmd_pgtable(pmd) pmd_page_vaddr(pmd)
+#define pmd_pgtable(pmd)	((pgtable_t) pmd_page_vaddr(pmd))
 
 #endif /* _ASM_ARC_PGALLOC_H */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

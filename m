Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8976B0263
	for <linux-mm@kvack.org>; Mon, 30 May 2016 01:44:51 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id f190so136100387qke.0
        for <linux-mm@kvack.org>; Sun, 29 May 2016 22:44:51 -0700 (PDT)
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com. [129.33.205.208])
        by mx.google.com with ESMTPS id g5si26821526qkc.260.2016.05.29.22.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 29 May 2016 22:44:50 -0700 (PDT)
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 30 May 2016 01:44:50 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 4/4] powerpc/mm/radix: Implement tlb mmu gather flush efficiently
Date: Mon, 30 May 2016 11:14:22 +0530
Message-Id: <1464587062-17745-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1464587062-17745-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1464587062-17745-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

if mmu gather flush resulted in a page table free force a RIC=2 flush
with IS=1. Otherwise do a range flush with IS=0 and RIC=0

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/32/pgalloc.h  |  1 -
 arch/powerpc/include/asm/book3s/64/pgalloc.h  | 16 ++++++++++++-
 arch/powerpc/include/asm/book3s/64/tlbflush.h |  1 +
 arch/powerpc/include/asm/book3s/pgalloc.h     |  5 ----
 arch/powerpc/mm/tlb-radix.c                   | 34 +++++++++++++++++++++++++--
 5 files changed, 48 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/32/pgalloc.h b/arch/powerpc/include/asm/book3s/32/pgalloc.h
index a2350194fc76..8e21bb492dca 100644
--- a/arch/powerpc/include/asm/book3s/32/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/32/pgalloc.h
@@ -102,7 +102,6 @@ static inline void pgtable_free_tlb(struct mmu_gather *tlb,
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 				  unsigned long address)
 {
-	tlb_flush_pgtable(tlb, address);
 	pgtable_page_dtor(table);
 	pgtable_free_tlb(tlb, page_address(table), 0);
 }
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
index 488279edb1f0..26eb2cb80c4e 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -110,6 +110,11 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
                                   unsigned long address)
 {
+	/*
+	 * By now all the pud entries should be none entries. So go
+	 * ahead and flush the page walk cache
+	 */
+	flush_tlb_pgtable(tlb, address);
         pgtable_free_tlb(tlb, pud, PUD_INDEX_SIZE);
 }
 
@@ -127,6 +132,11 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd,
                                   unsigned long address)
 {
+	/*
+	 * By now all the pud entries should be none entries. So go
+	 * ahead and flush the page walk cache
+	 */
+	flush_tlb_pgtable(tlb, address);
         return pgtable_free_tlb(tlb, pmd, PMD_CACHE_INDEX);
 }
 
@@ -198,7 +208,11 @@ static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 				  unsigned long address)
 {
-	tlb_flush_pgtable(tlb, address);
+	/*
+	 * By now all the pud entries should be none entries. So go
+	 * ahead and flush the page walk cache
+	 */
+	flush_tlb_pgtable(tlb, address);
 	pgtable_free_tlb(tlb, table, 0);
 }
 
diff --git a/arch/powerpc/include/asm/book3s/64/tlbflush.h b/arch/powerpc/include/asm/book3s/64/tlbflush.h
index ea29cc3318d2..497271af3bd6 100644
--- a/arch/powerpc/include/asm/book3s/64/tlbflush.h
+++ b/arch/powerpc/include/asm/book3s/64/tlbflush.h
@@ -84,4 +84,5 @@ static inline void flush_tlb_page(struct vm_area_struct *vma,
 #define flush_tlb_page(vma, addr)	local_flush_tlb_page(vma, addr)
 #endif /* CONFIG_SMP */
 
+extern void flush_tlb_pgtable(struct mmu_gather *tlb, unsigned long address);
 #endif /*  _ASM_POWERPC_BOOK3S_64_TLBFLUSH_H */
diff --git a/arch/powerpc/include/asm/book3s/pgalloc.h b/arch/powerpc/include/asm/book3s/pgalloc.h
index 54f591e9572e..c0a69ae92256 100644
--- a/arch/powerpc/include/asm/book3s/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/pgalloc.h
@@ -4,11 +4,6 @@
 #include <linux/mm.h>
 
 extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
-static inline void tlb_flush_pgtable(struct mmu_gather *tlb,
-				     unsigned long address)
-{
-
-}
 
 #ifdef CONFIG_PPC64
 #include <asm/book3s/64/pgalloc.h>
diff --git a/arch/powerpc/mm/tlb-radix.c b/arch/powerpc/mm/tlb-radix.c
index d996ce279ccb..169c56b6dc98 100644
--- a/arch/powerpc/mm/tlb-radix.c
+++ b/arch/powerpc/mm/tlb-radix.c
@@ -239,13 +239,32 @@ void radix__flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
 }
 EXPORT_SYMBOL(radix__flush_tlb_range);
 
-
 void radix__tlb_flush(struct mmu_gather *tlb)
 {
+	int psize = 0;
 	struct mm_struct *mm = tlb->mm;
-	radix__flush_tlb_mm(mm);
+	int page_size = tlb->page_size;
+
+	if (page_size == (1UL << mmu_psize_defs[mmu_virtual_psize].shift))
+		psize = mmu_virtual_psize;
+	else if (page_size == (1UL << mmu_psize_defs[MMU_PAGE_2M].shift))
+		psize = MMU_PAGE_2M;
+	else if (page_size == (1UL << mmu_psize_defs[MMU_PAGE_1G].shift))
+		psize = MMU_PAGE_1G;
+	else
+		goto flush_mm;
+
+
+	if (!tlb->fullmm && !tlb->need_flush_all) {
+		radix__flush_tlb_range_psize(mm, tlb->start, tlb->end, psize);
+	} else {
+flush_mm:
+		radix__flush_tlb_mm(mm);
+	}
 }
 
+
+
 #define TLB_FLUSH_ALL -1UL
 /*
  * Number of pages above which we will do a bcast tlbie. Just a
@@ -299,3 +318,14 @@ void radix__flush_pmd_tlb_range(struct vm_area_struct *vma,
 	radix__flush_tlb_range_psize(vma->vm_mm, start, end, MMU_PAGE_2M);
 }
 EXPORT_SYMBOL(radix__flush_pmd_tlb_range);
+/*
+ * flush the page walk cache for the address
+ */
+void flush_tlb_pgtable(struct mmu_gather *tlb, unsigned long address)
+{
+	/*
+	 * If we are doing a range flush with mmu gather, since we have
+	 * done a page table free, force a page walk cache flush.
+	 */
+	tlb->need_flush_all = 1;
+}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

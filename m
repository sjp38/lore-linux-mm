Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A6A526B0260
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 05:40:15 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id l14so122949433qke.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 02:40:15 -0700 (PDT)
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com. [129.33.205.207])
        by mx.google.com with ESMTPS id x3si27620502qkx.216.2016.06.02.02.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 02:40:14 -0700 (PDT)
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 2 Jun 2016 05:40:14 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 3/4] mm/mmu_gather: Track page size with mmu gather and force flush if page size change
Date: Thu,  2 Jun 2016 15:09:48 +0530
Message-Id: <1464860389-29019-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1464860389-29019-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1464860389-29019-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This allows arch which need to do special handing with respect to
different page size when flushing tlb to implement the same in mmu gather

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/arm/include/asm/tlb.h  | 18 +++++++++++++++
 arch/ia64/include/asm/tlb.h | 18 +++++++++++++++
 arch/s390/include/asm/tlb.h | 18 +++++++++++++++
 arch/sh/include/asm/tlb.h   | 18 +++++++++++++++
 arch/um/include/asm/tlb.h   | 18 +++++++++++++++
 include/asm-generic/tlb.h   | 56 +++++++++++++++++++++++++++++++++------------
 mm/huge_memory.c            |  2 +-
 mm/hugetlb.c                |  2 +-
 mm/memory.c                 | 13 ++++++++---
 9 files changed, 144 insertions(+), 19 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 45dea952b0e6..1e25cd80589e 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -225,6 +225,24 @@ static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 	}
 }
 
+static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
+					  struct page *page, int page_size)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
+					 struct page *page)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
+static inline void tlb_remove_page_size(struct mmu_gather *tlb,
+					struct page *page, int page_size)
+{
+	return tlb_remove_page(tlb, page);
+}
+
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 	unsigned long addr)
 {
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index 85005ab513e9..77e541cf0e5d 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -242,6 +242,24 @@ static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 	}
 }
 
+static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
+					  struct page *page, int page_size)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
+					 struct page *page)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
+static inline void tlb_remove_page_size(struct mmu_gather *tlb,
+					struct page *page, int page_size)
+{
+	return tlb_remove_page(tlb, page);
+}
+
 /*
  * Remove TLB entry for PTE mapped at virtual address ADDRESS.  This is called for any
  * PTE, not just those pointing to (normal) physical memory.
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 6b98cb3601d5..15711de10403 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -98,6 +98,24 @@ static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 	free_page_and_swap_cache(page);
 }
 
+static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
+					  struct page *page, int page_size)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
+					 struct page *page)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
+static inline void tlb_remove_page_size(struct mmu_gather *tlb,
+					struct page *page, int page_size)
+{
+	return tlb_remove_page(tlb, page);
+}
+
 /*
  * pte_free_tlb frees a pte table and clears the CRSTE for the
  * page table from the tlb.
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 3dec5e0734f5..025cdb1032f6 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -109,6 +109,24 @@ static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 	__tlb_remove_page(tlb, page);
 }
 
+static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
+					  struct page *page, int page_size)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
+					 struct page *page)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
+static inline void tlb_remove_page_size(struct mmu_gather *tlb,
+					struct page *page, int page_size)
+{
+	return tlb_remove_page(tlb, page);
+}
+
 #define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
 #define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
 #define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index c6638f8e5e90..821ff0acfe17 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -110,6 +110,24 @@ static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 	__tlb_remove_page(tlb, page);
 }
 
+static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
+					  struct page *page, int page_size)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
+					 struct page *page)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
+static inline void tlb_remove_page_size(struct mmu_gather *tlb,
+					struct page *page, int page_size)
+{
+	return tlb_remove_page(tlb, page);
+}
+
 /**
  * tlb_remove_tlb_entry - remember a pte unmapping for later tlb invalidation.
  *
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 2ac8fe202e9a..3ca36c111b47 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -112,6 +112,7 @@ struct mmu_gather {
 	 * that that we can adjust the range after the flush
 	 */
 	unsigned long addr;
+	int page_size;
 };
 
 #define HAVE_GENERIC_MMU_GATHER
@@ -120,25 +121,16 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start,
 							unsigned long end);
-bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page);
-
-/* tlb_remove_page
- *	Similar to __tlb_remove_page but will call tlb_flush_mmu() itself when
- *	required.
- */
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	if (__tlb_remove_page(tlb, page)) {
-		tlb_flush_mmu(tlb);
-		__tlb_adjust_range(tlb, tlb->addr);
-		__tlb_remove_page(tlb, page);
-	}
-}
+extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
+				   int page_size);
 
 static inline void __tlb_adjust_range(struct mmu_gather *tlb,
 				      unsigned long address)
 {
 	tlb->start = min(tlb->start, address);
+	/*
+	 * IS it enough to update the range by PAGE_SIZE ?
+	 */
 	tlb->end = max(tlb->end, address + PAGE_SIZE);
 	/*
 	 * Track the last address with which we adjusted the range. This
@@ -148,6 +140,42 @@ static inline void __tlb_adjust_range(struct mmu_gather *tlb,
 	tlb->addr = address;
 }
 
+static inline void tlb_remove_page_size(struct mmu_gather *tlb,
+					struct page *page, int page_size)
+{
+	if (__tlb_remove_page_size(tlb, page, page_size)) {
+		tlb_flush_mmu(tlb);
+		tlb->page_size = page_size;
+		__tlb_adjust_range(tlb, tlb->addr);
+		__tlb_remove_page_size(tlb, page, page_size);
+	}
+}
+
+static bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	return __tlb_remove_page_size(tlb, page, PAGE_SIZE);
+}
+
+/* tlb_remove_page
+ *	Similar to __tlb_remove_page but will call tlb_flush_mmu() itself when
+ *	required.
+ */
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	return tlb_remove_page_size(tlb, page, PAGE_SIZE);
+}
+/*
+ * Used on reset
+ */
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb, struct page *page)
+{
+	/* active->nr should be zero when we call this */
+	VM_BUG_ON_PAGE(tlb->active->nr, page);
+	tlb->page_size = PAGE_SIZE;
+	__tlb_adjust_range(tlb, tlb->addr);
+	return __tlb_remove_page(tlb, page);
+}
+
 static inline void __tlb_reset_range(struct mmu_gather *tlb)
 {
 	if (tlb->fullmm) {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9ed58530f695..a5711093a829 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1694,7 +1694,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
 		atomic_long_dec(&tlb->mm->nr_ptes);
 		spin_unlock(ptl);
-		tlb_remove_page(tlb, page);
+		tlb_remove_page_size(tlb, page, HPAGE_PMD_SIZE);
 	}
 	return 1;
 }
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8dd91cd5571c..3495c519583d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3211,7 +3211,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		page_remove_rmap(page, true);
 
 		spin_unlock(ptl);
-		tlb_remove_page(tlb, page);
+		tlb_remove_page_size(tlb, page, huge_page_size(h));
 		/*
 		 * Bail out after unmapping reference page if supplied
 		 */
diff --git a/mm/memory.c b/mm/memory.c
index a01db5bc756b..c2e7ea955f06 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -233,6 +233,7 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
 #endif
+	tlb->page_size = 0;
 
 	__tlb_reset_range(tlb);
 }
@@ -294,12 +295,19 @@ void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long e
  *	When out of page slots we must call tlb_flush_mmu().
  *returns true if the caller should flush.
  */
-bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_size)
 {
 	struct mmu_gather_batch *batch;
 
 	VM_BUG_ON(!tlb->end);
 
+	if (!tlb->page_size)
+		tlb->page_size = page_size;
+	else {
+		if (page_size != tlb->page_size)
+			return true;
+	}
+
 	batch = tlb->active;
 	if (batch->nr == batch->max) {
 		if (!tlb_next_batch(tlb))
@@ -1207,8 +1215,7 @@ again:
 		tlb_flush_mmu_free(tlb);
 		if (pending_page) {
 			/* remove the page with new size */
-			__tlb_adjust_range(tlb, tlb->addr);
-			__tlb_remove_page(tlb, pending_page);
+			__tlb_remove_pte_page(tlb, pending_page);
 			pending_page = NULL;
 		}
 		if (addr != end)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

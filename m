Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6915C6B003C
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 11:01:52 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so3698965wgh.27
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:01:51 -0700 (PDT)
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
        by mx.google.com with ESMTPS id lr14si2397078wic.0.2014.03.28.08.01.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 08:01:51 -0700 (PDT)
Received: by mail-we0-f171.google.com with SMTP id t61so2695844wes.2
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:01:50 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH V4 5/7] arm64: Convert asm/tlb.h to generic mmu_gather
Date: Fri, 28 Mar 2014 15:01:30 +0000
Message-Id: <1396018892-6773-6-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
References: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: peterz@infradead.org, gary.robertson@linaro.org, anders.roxell@linaro.org, akpm@linux-foundation.org, Steve Capper <steve.capper@linaro.org>

From: Catalin Marinas <catalin.marinas@arm.com>

Over the past couple of years, the generic mmu_gather gained range
tracking - 597e1c3580b7 (mm/mmu_gather: enable tlb flush range in generic
mmu_gather), 2b047252d087 (Fix TLB gather virtual address range
invalidation corner cases) - and tlb_fast_mode() has been removed -
29eb77825cc7 (arch, mm: Remove tlb_fast_mode()).

The new mmu_gather structure is now suitable for arm64 and this patch
converts the arch asm/tlb.h to the generic code. One functional
difference is the shift_arg_pages() case where previously the code was
flushing the full mm (no tlb_start_vma call) but now it flushes the
range given to tlb_gather_mmu() (possibly slightly more efficient
previously).

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
I think Catalin already has this patch in his upstream tree, it's
included in this series for the sake of completeness.
---
 arch/arm64/include/asm/tlb.h | 136 +++++++------------------------------------
 1 file changed, 20 insertions(+), 116 deletions(-)

diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index 717031a..72cadf5 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -19,115 +19,44 @@
 #ifndef __ASM_TLB_H
 #define __ASM_TLB_H
 
-#include <linux/pagemap.h>
-#include <linux/swap.h>
 
-#include <asm/pgalloc.h>
-#include <asm/tlbflush.h>
-
-#define MMU_GATHER_BUNDLE	8
-
-/*
- * TLB handling.  This allows us to remove pages from the page
- * tables, and efficiently handle the TLB issues.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		fullmm;
-	struct vm_area_struct	*vma;
-	unsigned long		start, end;
-	unsigned long		range_start;
-	unsigned long		range_end;
-	unsigned int		nr;
-	unsigned int		max;
-	struct page		**pages;
-	struct page		*local[MMU_GATHER_BUNDLE];
-};
+#include <asm-generic/tlb.h>
 
 /*
- * This is unnecessarily complex.  There's three ways the TLB shootdown
- * code is used:
+ * There's three ways the TLB shootdown code is used:
  *  1. Unmapping a range of vmas.  See zap_page_range(), unmap_region().
  *     tlb->fullmm = 0, and tlb_start_vma/tlb_end_vma will be called.
- *     tlb->vma will be non-NULL.
  *  2. Unmapping all vmas.  See exit_mmap().
  *     tlb->fullmm = 1, and tlb_start_vma/tlb_end_vma will be called.
- *     tlb->vma will be non-NULL.  Additionally, page tables will be freed.
+ *     Page tables will be freed.
  *  3. Unmapping argument pages.  See shift_arg_pages().
  *     tlb->fullmm = 0, but tlb_start_vma/tlb_end_vma will not be called.
- *     tlb->vma will be NULL.
  */
 static inline void tlb_flush(struct mmu_gather *tlb)
 {
-	if (tlb->fullmm || !tlb->vma)
+	if (tlb->fullmm) {
 		flush_tlb_mm(tlb->mm);
-	else if (tlb->range_end > 0) {
-		flush_tlb_range(tlb->vma, tlb->range_start, tlb->range_end);
-		tlb->range_start = TASK_SIZE;
-		tlb->range_end = 0;
+	} else if (tlb->end > 0) {
+		struct vm_area_struct vma = { .vm_mm = tlb->mm, };
+		flush_tlb_range(&vma, tlb->start, tlb->end);
+		tlb->start = TASK_SIZE;
+		tlb->end = 0;
 	}
 }
 
 static inline void tlb_add_flush(struct mmu_gather *tlb, unsigned long addr)
 {
 	if (!tlb->fullmm) {
-		if (addr < tlb->range_start)
-			tlb->range_start = addr;
-		if (addr + PAGE_SIZE > tlb->range_end)
-			tlb->range_end = addr + PAGE_SIZE;
-	}
-}
-
-static inline void __tlb_alloc_page(struct mmu_gather *tlb)
-{
-	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
-
-	if (addr) {
-		tlb->pages = (void *)addr;
-		tlb->max = PAGE_SIZE / sizeof(struct page *);
+		tlb->start = min(tlb->start, addr);
+		tlb->end = max(tlb->end, addr + PAGE_SIZE);
 	}
 }
 
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	tlb_flush(tlb);
-	free_pages_and_swap_cache(tlb->pages, tlb->nr);
-	tlb->nr = 0;
-	if (tlb->pages == tlb->local)
-		__tlb_alloc_page(tlb);
-}
-
-static inline void
-tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long start, unsigned long end)
-{
-	tlb->mm = mm;
-	tlb->fullmm = !(start | (end+1));
-	tlb->start = start;
-	tlb->end = end;
-	tlb->vma = NULL;
-	tlb->max = ARRAY_SIZE(tlb->local);
-	tlb->pages = tlb->local;
-	tlb->nr = 0;
-	__tlb_alloc_page(tlb);
-}
-
-static inline void
-tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
-{
-	tlb_flush_mmu(tlb);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	if (tlb->pages != tlb->local)
-		free_pages((unsigned long)tlb->pages, 0);
-}
-
 /*
  * Memorize the range for the TLB flush.
  */
-static inline void
-tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long addr)
+static inline void __tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep,
+					  unsigned long addr)
 {
 	tlb_add_flush(tlb, addr);
 }
@@ -137,38 +66,24 @@ tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long addr)
  * case where we're doing a full MM flush.  When we're doing a munmap,
  * the vmas are adjusted to only cover the region to be torn down.
  */
-static inline void
-tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
+static inline void tlb_start_vma(struct mmu_gather *tlb,
+				 struct vm_area_struct *vma)
 {
 	if (!tlb->fullmm) {
-		tlb->vma = vma;
-		tlb->range_start = TASK_SIZE;
-		tlb->range_end = 0;
+		tlb->start = TASK_SIZE;
+		tlb->end = 0;
 	}
 }
 
-static inline void
-tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
+static inline void tlb_end_vma(struct mmu_gather *tlb,
+			       struct vm_area_struct *vma)
 {
 	if (!tlb->fullmm)
 		tlb_flush(tlb);
 }
 
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	tlb->pages[tlb->nr++] = page;
-	VM_BUG_ON(tlb->nr > tlb->max);
-	return tlb->max - tlb->nr;
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	if (!__tlb_remove_page(tlb, page))
-		tlb_flush_mmu(tlb);
-}
-
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
-	unsigned long addr)
+				  unsigned long addr)
 {
 	pgtable_page_dtor(pte);
 	tlb_add_flush(tlb, addr);
@@ -184,16 +99,5 @@ static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
 }
 #endif
 
-#define pte_free_tlb(tlb, ptep, addr)	__pte_free_tlb(tlb, ptep, addr)
-#define pmd_free_tlb(tlb, pmdp, addr)	__pmd_free_tlb(tlb, pmdp, addr)
-#define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
-
-#define tlb_migrate_finish(mm)		do { } while (0)
-
-static inline void
-tlb_remove_pmd_tlb_entry(struct mmu_gather *tlb, pmd_t *pmdp, unsigned long addr)
-{
-	tlb_add_flush(tlb, addr);
-}
 
 #endif
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

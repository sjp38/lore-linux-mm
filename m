Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7CD8E000F
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:54:58 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id k143-v6so2717749ite.5
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:54:58 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n142-v6si2770791itg.69.2018.09.26.04.54.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Sep 2018 04:54:57 -0700 (PDT)
Message-ID: <20180926114801.094298493@infradead.org>
Date: Wed, 26 Sep 2018 13:36:34 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 11/18] um/tlb: Convert to generic mmu_gather
References: <20180926113623.863696043@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com, Richard Weinberger <richard@nod.at>

Generic mmu_gather provides the simple flush_tlb_range() based range
tracking mmu_gather UM needs.

Cc: Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Richard Weinberger <richard@nod.at>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/um/include/asm/tlb.h |  156 ----------------------------------------------
 1 file changed, 2 insertions(+), 154 deletions(-)

--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -2,160 +2,8 @@
 #ifndef __UM_TLB_H
 #define __UM_TLB_H
 
-#include <linux/pagemap.h>
-#include <linux/swap.h>
-#include <asm/percpu.h>
-#include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
-
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
-
-/* struct mmu_gather is an opaque type used by the mm code for passing around
- * any data needed by arch specific code for tlb_remove_page.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		need_flush; /* Really unmapped some ptes? */
-	unsigned long		start;
-	unsigned long		end;
-	unsigned int		fullmm; /* non-zero means full mm flush */
-};
-
-static inline void __tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep,
-					  unsigned long address)
-{
-	if (tlb->start > address)
-		tlb->start = address;
-	if (tlb->end < address + PAGE_SIZE)
-		tlb->end = address + PAGE_SIZE;
-}
-
-static inline void init_tlb_gather(struct mmu_gather *tlb)
-{
-	tlb->need_flush = 0;
-
-	tlb->start = TASK_SIZE;
-	tlb->end = 0;
-
-	if (tlb->fullmm) {
-		tlb->start = 0;
-		tlb->end = TASK_SIZE;
-	}
-}
-
-static inline void
-arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-		unsigned long start, unsigned long end)
-{
-	tlb->mm = mm;
-	tlb->start = start;
-	tlb->end = end;
-	tlb->fullmm = !(start | (end+1));
-
-	init_tlb_gather(tlb);
-}
-
-extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
-			       unsigned long end);
-
-static inline void
-tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
-{
-	flush_tlb_mm_range(tlb->mm, tlb->start, tlb->end);
-}
-
-static inline void
-tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-	init_tlb_gather(tlb);
-}
-
-static inline void
-tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	if (!tlb->need_flush)
-		return;
-
-	tlb_flush_mmu_tlbonly(tlb);
-	tlb_flush_mmu_free(tlb);
-}
-
-/* arch_tlb_finish_mmu
- *	Called at the end of the shootdown operation to free up any resources
- *	that were required.
- */
-static inline void
-arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end, bool force)
-{
-	if (force) {
-		tlb->start = start;
-		tlb->end = end;
-		tlb->need_flush = 1;
-	}
-	tlb_flush_mmu(tlb);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-}
-
-/* tlb_remove_page
- *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)),
- *	while handling the additional races in SMP caused by other CPUs
- *	caching valid mappings in their TLBs.
- */
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	tlb->need_flush = 1;
-	free_page_and_swap_cache(page);
-	return false; /* avoid calling tlb_flush_mmu */
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	__tlb_remove_page(tlb, page);
-}
-
-static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
-					  struct page *page, int page_size)
-{
-	return __tlb_remove_page(tlb, page);
-}
-
-static inline void tlb_remove_page_size(struct mmu_gather *tlb,
-					struct page *page, int page_size)
-{
-	return tlb_remove_page(tlb, page);
-}
-
-/**
- * tlb_remove_tlb_entry - remember a pte unmapping for later tlb invalidation.
- *
- * Record the fact that pte's were really umapped in ->need_flush, so we can
- * later optimise away the tlb invalidate.   This helps when userspace is
- * unmapping already-unmapped pages, which happens quite a lot.
- */
-#define tlb_remove_tlb_entry(tlb, ptep, address)		\
-	do {							\
-		tlb->need_flush = 1;				\
-		__tlb_remove_tlb_entry(tlb, ptep, address);	\
-	} while (0)
-
-#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
-	tlb_remove_tlb_entry(tlb, ptep, address)
-
-static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
-{
-}
-
-#define pte_free_tlb(tlb, ptep, addr) __pte_free_tlb(tlb, ptep, addr)
-
-#define pud_free_tlb(tlb, pudp, addr) __pud_free_tlb(tlb, pudp, addr)
-
-#define pmd_free_tlb(tlb, pmdp, addr) __pmd_free_tlb(tlb, pmdp, addr)
-
-#define tlb_migrate_finish(mm) do {} while (0)
+#include <asm-generic/cacheflush.h>
+#include <asm-generic/tlb.h>
 
 #endif

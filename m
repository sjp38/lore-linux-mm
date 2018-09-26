Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 053438E0003
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:54:57 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id d194-v6so2803753itb.8
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:54:57 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m2-v6si3330862iob.97.2018.09.26.04.54.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Sep 2018 04:54:55 -0700 (PDT)
Message-ID: <20180926114801.040318402@infradead.org>
Date: Wed, 26 Sep 2018 13:36:33 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 10/18] sh/tlb: Convert SH to generic mmu_gather
References: <20180926113623.863696043@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>

Generic mmu_gather provides everything SH needs (range tracking and
cache coherency).

Cc: Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/sh/include/asm/pgalloc.h |    7 ++
 arch/sh/include/asm/tlb.h     |  130 ------------------------------------------
 2 files changed, 8 insertions(+), 129 deletions(-)

--- a/arch/sh/include/asm/pgalloc.h
+++ b/arch/sh/include/asm/pgalloc.h
@@ -72,6 +72,15 @@ do {							\
 	tlb_remove_page((tlb), (pte));			\
 } while (0)
 
+#if CONFIG_PGTABLE_LEVELS > 2
+#define __pmd_free_tlb(tlb, pmdp, addr)			\
+do {							\
+	struct page *page = virt_to_page(pmdp);		\
+	pgtable_pmd_page_dtor(page);			\
+	tlb_remove_page((tlb), page);			\
+} while (0);
+#endif
+
 static inline void check_pgt_cache(void)
 {
 	quicklist_trim(QUICK_PT, NULL, 25, 16);
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -11,131 +11,8 @@
 
 #ifdef CONFIG_MMU
 #include <linux/swap.h>
-#include <asm/pgalloc.h>
-#include <asm/tlbflush.h>
-#include <asm/mmu_context.h>
-
-/*
- * TLB handling.  This allows us to remove pages from the page
- * tables, and efficiently handle the TLB issues.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		fullmm;
-	unsigned long		start, end;
-};
 
-static inline void init_tlb_gather(struct mmu_gather *tlb)
-{
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
-static inline void
-arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end, bool force)
-{
-	if (tlb->fullmm || force)
-		flush_tlb_mm(tlb->mm);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-}
-
-static inline void
-tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long address)
-{
-	if (tlb->start > address)
-		tlb->start = address;
-	if (tlb->end < address + PAGE_SIZE)
-		tlb->end = address + PAGE_SIZE;
-}
-
-#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
-	tlb_remove_tlb_entry(tlb, ptep, address)
-
-/*
- * In the case of tlb vma handling, we can optimise these away in the
- * case where we're doing a full MM flush.  When we're doing a munmap,
- * the vmas are adjusted to only cover the region to be torn down.
- */
-static inline void
-tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm)
-		flush_cache_range(vma, vma->vm_start, vma->vm_end);
-}
-
-static inline void
-tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm && tlb->end) {
-		flush_tlb_range(vma, tlb->start, tlb->end);
-		init_tlb_gather(tlb);
-	}
-}
-
-static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
-{
-}
-
-static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-}
-
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-}
-
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
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
-static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
-{
-}
-
-#define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
-#define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
-#define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
-
-#define tlb_migrate_finish(mm)		do { } while (0)
+#include <asm-generic/tlb.h>
 
 #if defined(CONFIG_CPU_SH4) || defined(CONFIG_SUPERH64)
 extern void tlb_wire_entry(struct vm_area_struct *, unsigned long, pte_t);
@@ -155,11 +32,6 @@ static inline void tlb_unwire_entry(void
 
 #else /* CONFIG_MMU */
 
-#define tlb_start_vma(tlb, vma)				do { } while (0)
-#define tlb_end_vma(tlb, vma)				do { } while (0)
-#define __tlb_remove_tlb_entry(tlb, pte, address)	do { } while (0)
-#define tlb_flush(tlb)					do { } while (0)
-
 #include <asm-generic/tlb.h>
 
 #endif /* CONFIG_MMU */

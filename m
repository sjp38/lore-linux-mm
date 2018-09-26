Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3FC8E0003
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:54:39 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id d128-v6so2839607ite.5
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:54:39 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c67-v6si3546392jad.123.2018.09.26.04.54.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Sep 2018 04:54:37 -0700 (PDT)
Message-ID: <20180926114800.614533601@infradead.org>
Date: Wed, 26 Sep 2018 13:36:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 02/18] asm-generic/tlb: Provide HAVE_MMU_GATHER_PAGE_SIZE
References: <20180926113623.863696043@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com

Move the mmu_gather::page_size things into the generic code instead of
powerpc specific bits.

Cc: Nick Piggin <npiggin@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/Kconfig                   |    3 +++
 arch/arm/include/asm/tlb.h     |    3 +--
 arch/ia64/include/asm/tlb.h    |    3 +--
 arch/powerpc/Kconfig           |    1 +
 arch/powerpc/include/asm/tlb.h |   17 -----------------
 arch/s390/include/asm/tlb.h    |    4 +---
 arch/sh/include/asm/tlb.h      |    4 +---
 arch/um/include/asm/tlb.h      |    4 +---
 include/asm-generic/tlb.h      |   32 +++++++++++++++++++-------------
 mm/huge_memory.c               |    4 ++--
 mm/hugetlb.c                   |    2 +-
 mm/madvise.c                   |    2 +-
 mm/memory.c                    |    4 ++--
 mm/mmu_gather.c                |    5 +++++
 14 files changed, 39 insertions(+), 49 deletions(-)

--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -365,6 +365,9 @@ config HAVE_RCU_TABLE_FREE
 config HAVE_RCU_TABLE_INVALIDATE
 	bool
 
+config HAVE_MMU_GATHER_PAGE_SIZE
+	bool
+
 config ARCH_HAVE_NMI_SAFE_CMPXCHG
 	bool
 
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -286,8 +286,7 @@ tlb_remove_pmd_tlb_entry(struct mmu_gath
 
 #define tlb_migrate_finish(mm)		do { } while (0)
 
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+static inline void tlb_change_page_size(struct mmu_gather *tlb,
 						     unsigned int page_size)
 {
 }
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -282,8 +282,7 @@ do {							\
 #define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
 	tlb_remove_tlb_entry(tlb, ptep, address)
 
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+static inline void tlb_change_page_size(struct mmu_gather *tlb,
 						     unsigned int page_size)
 {
 }
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -216,6 +216,7 @@ config PPC
 	select HAVE_PERF_REGS
 	select HAVE_PERF_USER_STACK_DUMP
 	select HAVE_RCU_TABLE_FREE		if SMP
+	select HAVE_MMU_GATHER_PAGE_SIZE
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select HAVE_RELIABLE_STACKTRACE		if PPC64 && CPU_LITTLE_ENDIAN
 	select HAVE_SYSCALL_TRACEPOINTS
--- a/arch/powerpc/include/asm/tlb.h
+++ b/arch/powerpc/include/asm/tlb.h
@@ -27,7 +27,6 @@
 #define tlb_start_vma(tlb, vma)	do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 #define __tlb_remove_tlb_entry	__tlb_remove_tlb_entry
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
 
 extern void tlb_flush(struct mmu_gather *tlb);
 
@@ -46,22 +45,6 @@ static inline void __tlb_remove_tlb_entr
 #endif
 }
 
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
-						     unsigned int page_size)
-{
-	if (!tlb->page_size)
-		tlb->page_size = page_size;
-	else if (tlb->page_size != page_size) {
-		if (!tlb->fullmm)
-			tlb_flush_mmu(tlb);
-		/*
-		 * update the page size after flush for the new
-		 * mmu_gather.
-		 */
-		tlb->page_size = page_size;
-	}
-}
-
 #ifdef CONFIG_SMP
 static inline int mm_is_core_local(struct mm_struct *mm)
 {
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -180,9 +180,7 @@ static inline void pud_free_tlb(struct m
 #define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
 	tlb_remove_tlb_entry(tlb, ptep, address)
 
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
-						     unsigned int page_size)
+static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
 {
 }
 
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -127,9 +127,7 @@ static inline void tlb_remove_page_size(
 	return tlb_remove_page(tlb, page);
 }
 
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
-						     unsigned int page_size)
+static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
 {
 }
 
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -146,9 +146,7 @@ static inline void tlb_remove_page_size(
 #define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
 	tlb_remove_tlb_entry(tlb, ptep, address)
 
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
-						     unsigned int page_size)
+static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
 {
 }
 
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -61,7 +61,7 @@
  *    tlb_remove_page() and tlb_remove_page_size() imply the call to
  *    tlb_flush_mmu() when required and has no return value.
  *
- *  - tlb_remove_check_page_size_change()
+ *  - tlb_change_page_size()
  *
  *    call before __tlb_remove_page*() to set the current page-size; implies a
  *    possible tlb_flush_mmu() call.
@@ -110,6 +110,11 @@
  *
  * Additionally there are a few opt-in features:
  *
+ *  HAVE_MMU_GATHER_PAGE_SIZE
+ *
+ *  This ensures we call tlb_flush() every time tlb_change_page_size() actually
+ *  changes the size and provides mmu_gather::page_size to tlb_flush().
+ *
  *  HAVE_RCU_TABLE_FREE
  *
  *  This provides tlb_remove_table(), to be used instead of tlb_remove_page()
@@ -235,11 +240,15 @@ struct mmu_gather {
 	unsigned int		cleared_puds : 1;
 	unsigned int		cleared_p4ds : 1;
 
+	unsigned int		batch_count;
+
 	struct mmu_gather_batch *active;
 	struct mmu_gather_batch	local;
 	struct page		*__pages[MMU_GATHER_BUNDLE];
-	unsigned int		batch_count;
-	int page_size;
+
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
+	unsigned int page_size;
+#endif
 };
 
 void arch_tlb_gather_mmu(struct mmu_gather *tlb,
@@ -305,21 +314,18 @@ static inline void tlb_remove_page(struc
 	return tlb_remove_page_size(tlb, page, PAGE_SIZE);
 }
 
-#ifndef tlb_remove_check_page_size_change
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+static inline void tlb_change_page_size(struct mmu_gather *tlb,
 						     unsigned int page_size)
 {
-	/*
-	 * We don't care about page size change, just update
-	 * mmu_gather page size here so that debug checks
-	 * doesn't throw false warning.
-	 */
-#ifdef CONFIG_DEBUG_VM
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
+	if (tlb->page_size && tlb->page_size != page_size) {
+		if (!tlb->fullmm)
+			tlb_flush_mmu(tlb);
+	}
+
 	tlb->page_size = page_size;
 #endif
 }
-#endif
 
 static inline unsigned long tlb_get_unmap_shift(struct mmu_gather *tlb)
 {
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1617,7 +1617,7 @@ bool madvise_free_huge_pmd(struct mmu_ga
 	struct mm_struct *mm = tlb->mm;
 	bool ret = false;
 
-	tlb_remove_check_page_size_change(tlb, HPAGE_PMD_SIZE);
+	tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (!ptl)
@@ -1693,7 +1693,7 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 	pmd_t orig_pmd;
 	spinlock_t *ptl;
 
-	tlb_remove_check_page_size_change(tlb, HPAGE_PMD_SIZE);
+	tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
 
 	ptl = __pmd_trans_huge_lock(pmd, vma);
 	if (!ptl)
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3337,7 +3337,7 @@ void __unmap_hugepage_range(struct mmu_g
 	 * This is a hugetlb vma, all the pte entries should point
 	 * to huge page.
 	 */
-	tlb_remove_check_page_size_change(tlb, sz);
+	tlb_change_page_size(tlb, sz);
 	tlb_start_vma(tlb, vma);
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	address = start;
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -328,7 +328,7 @@ static int madvise_free_pte_range(pmd_t
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
-	tlb_remove_check_page_size_change(tlb, PAGE_SIZE);
+	tlb_change_page_size(tlb, PAGE_SIZE);
 	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	flush_tlb_batched_pending(mm);
 	arch_enter_lazy_mmu_mode();
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -355,7 +355,7 @@ void free_pgd_range(struct mmu_gather *t
 	 * We add page table cache pages with PAGE_SIZE,
 	 * (see pte_free_tlb()), flush the tlb if we need
 	 */
-	tlb_remove_check_page_size_change(tlb, PAGE_SIZE);
+	tlb_change_page_size(tlb, PAGE_SIZE);
 	pgd = pgd_offset(tlb->mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1046,7 +1046,7 @@ static unsigned long zap_pte_range(struc
 	pte_t *pte;
 	swp_entry_t entry;
 
-	tlb_remove_check_page_size_change(tlb, PAGE_SIZE);
+	tlb_change_page_size(tlb, PAGE_SIZE);
 again:
 	init_rss_vec(rss);
 	start_pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -58,7 +58,9 @@ void arch_tlb_gather_mmu(struct mmu_gath
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
 #endif
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
 	tlb->page_size = 0;
+#endif
 
 	__tlb_reset_range(tlb);
 }
@@ -121,7 +123,10 @@ bool __tlb_remove_page_size(struct mmu_g
 	struct mmu_gather_batch *batch;
 
 	VM_BUG_ON(!tlb->end);
+
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
 	VM_WARN_ON(tlb->page_size != page_size);
+#endif
 
 	batch = tlb->active;
 	/*

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id C0B6D6B0080
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:41:53 -0400 (EDT)
Message-Id: <20120627212831.279978500@chello.nl>
Date: Wed, 27 Jun 2012 23:15:50 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 10/20] mm: Provide generic range tracking and flushing
References: <20120627211540.459910855@chello.nl>
Content-Disposition: inline; filename=mm-generic-tlb-range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

In order to convert various architectures to generic tlb we need to
provide some extra infrastructure to track the range of the flushed
page tables.

There are two mmu_gather cases to consider:

  unmap_region()
    tlb_gather_mmu()
    unmap_vmas()
      for (; vma; vma = vma->vm_next)
        unmap_page_range()
          tlb_start_vma() -> flush cache range/track vm_flags
          zap_*_range()
            arch_enter_lazy_mmu_mode()
            ptep_get_and_clear_full() -> batch/track external tlbs
            tlb_remove_tlb_entry() -> track range/external tlbs
            tlb_remove_page() -> batch page
            arch_lazy_leave_mmu_mode() -> flush external tlbs
          tlb_end_vma()
    free_pgtables()
      while (vma)
        unlink_*_vma()
        free_*_range()
          *_free_tlb() -> track range/batch page
    tlb_finish_mmu() -> flush TLBs and flush everything
  free vmas

and:

  shift_arg_pages()
    tlb_gather_mmu()
    free_*_range()
      *_free_tlb() -> track tlb range
    tlb_finish_mmu() -> flush things

There are various reasons that we need to flush TLBs _after_ tearing
down the page-tables themselves. For some architectures (x86 among
others) this serializes against (both hardware and software) page
table walkers like gup_fast().

For others (ARM) this is (also) needed to evict stale page-table
caches - ARM LPAE mode apparently caches page tables and concurrent
hardware walkers could re-populate these caches if the final tlb flush
were to be from tlb_end_vma() since an concurrent walk could still be
in progress.

So implement generic range tracking over both clearing the PTEs and
tearing down the page-tables.

Cc: Russell King <rmk@arm.linux.org.uk>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Paul Mundt <lethal@linux-sh.org>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Kyle McMartin <kyle@mcmartin.ca>
Cc: James Bottomley <jejb@parisc-linux.org>
Cc: David Miller <davem@davemloft.net>
Cc: Chris Zankel <chris@zankel.net>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/Kconfig              |    3 
 include/asm-generic/tlb.h |  193 ++++++++++++++++++++++++++++++++++++++++++----
 mm/memory.c               |    3 
 3 files changed, 185 insertions(+), 14 deletions(-)
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -244,6 +244,9 @@ config HAVE_HW_PAGE_TABLE_WALKS
 	  linux page-table structure. Therefore we don't need to emit
 	  hardware TLB flush instructions before freeing page-table pages.
 
+config HAVE_MMU_GATHER_RANGE
+	bool
+
 config ARCH_HAVE_NMI_SAFE_CMPXCHG
 	bool
 
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -5,12 +5,77 @@
  * Copyright 2001 Red Hat, Inc.
  * Based on code from mm/memory.c Copyright Linus Torvalds and others.
  *
- * Copyright 2011 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
+ * Copyright 2011-2012 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version
  * 2 of the License, or (at your option) any later version.
+ *
+ * This generic implementation tries to cover all TLB invalidate needs
+ * across our archicture spectrum, please ask before adding a new arch
+ * specific mmu_gather implementation.
+ *
+ * The TLB shootdown code deals with all the fun races an SMP system bring
+ * to the otherwise simple task of unmapping and freeing pages.
+ *
+ * There are two mmu_gather cases to consider, the below shows the various
+ * hooks and how this implementation employs them:
+ *
+ *   unmap_region()
+ *     tlb_gather_mmu()
+ *     unmap_vmas()
+ *       for (; vma; vma = vma->vm_next)
+ *         unmap_page_range()
+ *           tlb_start_vma() -> flush cache range/track vm_flags
+ *           zap_*_range()
+ *             arch_enter_lazy_mmu_mode()
+ *             ptep_get_and_clear_full() -> batch/track external tlbs
+ *             tlb_remove_tlb_entry() -> track range/external tlbs
+ *             tlb_remove_page() -> batch page
+ *             arch_leave_lazy_mmu_mode() -> flush external tlbs
+ *         tlb_end_vma()
+ *     free_pgtables()
+ *       while (vma)
+ *         unlink_*_vma()
+ *         free_*_range()
+ *           *_free_tlb() -> track range/batch page
+ *     tlb_finish_mmu() -> flush TLBs and pages
+ *   free vmas
+ *
+ * and:
+ *
+ *   shift_arg_pages()
+ *     tlb_gather_mmu()
+ *     free_*_range()
+ *       *_free_tlb() -> track range/batch page
+ *     tlb_finish_mmu() -> flush TLBs and pages
+ *
+ * This code has 3 relevant Kconfig knobs:
+ *
+ *  CONFIG_HAVE_MMU_GATHER_RANGE -- In case the architecture has an efficient
+ *    flush_tlb_range() implementation this adds range tracking to the
+ *    mmu_gather and avoids full mm invalidation where possible.
+ *
+ *    There's a number of curious details wrt passing a vm_area_struct, see
+ *    our tlb_start_vma() implementation.
+ *
+ *  CONFIG_HAVE_RCU_TABLE_FREE -- In case flush_tlb_*() doesn't
+ *    serialize software walkers against page-table tear-down. This option
+ *    enables a semi-RCU freeing of page-tables such that disabling IRQs
+ *    will still provide the required serialization. See the big comment
+ *    a page or so down.
+ *
+ *  CONFIG_HAVE_HW_PAGE_TABLE_WALKS -- Optimization for architectures with
+ *    'external' hash-table MMUs and similar which don't require a TLB
+ *    invalidate before freeing page-tables, always used in conjunction
+ *    with CONFIG_HAVE_RCU_TABLE_FREE to provide proper serialization for
+ *    software page-table walkers.
+ *
+ *    For instance SPARC64 and PPC use arch_{enter,leave}_lazy_mmu_mode()
+ *    toghether with ptep_get_and_clear_full() to wipe their hash-table.
+ *
+ *    See arch/Kconfig for more details.
  */
 #ifndef _ASM_GENERIC__TLB_H
 #define _ASM_GENERIC__TLB_H
@@ -37,7 +102,8 @@ struct mmu_gather_batch {
 #define MAX_GATHER_BATCH	\
 	((PAGE_SIZE - sizeof(struct mmu_gather_batch)) / sizeof(void *))
 
-/* struct mmu_gather is an opaque type used by the mm code for passing around
+/*
+ * struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
  */
 struct mmu_gather {
@@ -45,6 +111,10 @@ struct mmu_gather {
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	struct mmu_table_batch	*batch;
 #endif
+#ifdef CONFIG_HAVE_MMU_GATHER_RANGE
+	unsigned long		start, end;
+	unsigned long		vm_flags;
+#endif
 	unsigned int		need_flush : 1,	/* Did free PTEs */
 				fast_mode  : 1; /* No batching   */
 
@@ -83,6 +153,16 @@ struct mmu_gather {
  * pressure. To guarantee progress we fall back to single table freeing, see
  * the implementation of tlb_remove_table_one().
  *
+ * When this option is selected, the arch is expected to use:
+ *
+ *  void tlb_remove_table(struct mmu_gather *tlb, void *table)
+ *
+ * to 'free' page-tables from their respective __{pte,pmd,pud}_free_tlb()
+ * implementations and has to provide an implementation of:
+ *
+ *   void  __tlb_remove_table(void *);
+ *
+ * that actually does the free.
  */
 struct mmu_table_batch {
 	struct rcu_head		rcu;
@@ -118,8 +198,90 @@ static inline void tlb_remove_table(stru
 
 #endif /* CONFIG_HAVE_RCU_TABLE_FREE */
 
+void tlb_flush_mmu(struct mmu_gather *tlb);
+
 #define HAVE_GENERIC_MMU_GATHER
 
+#ifdef CONFIG_HAVE_MMU_GATHER_RANGE
+
+static inline void tlb_range_init(struct mmu_gather *tlb)
+{
+	tlb->start = TASK_SIZE;
+	tlb->end = 0;
+	tlb->vm_flags = 0;
+}
+
+static inline void
+tlb_track_range(struct mmu_gather *tlb, unsigned long addr, unsigned long end)
+{
+	if (!tlb->fullmm) {
+		tlb->start = min(tlb->start, addr);
+		tlb->end = max(tlb->end, end);
+	}
+}
+
+static inline void tlb_flush(struct mmu_gather *tlb)
+{
+	/*
+	 * Fake VMA, some architectures use VM_EXEC to flush I-TLB/I$,
+	 * and some use VM_HUGETLB since they have separate HPAGE TLBs.
+	 */
+	struct vm_area_struct vma = {
+		.vm_mm = tlb->mm,
+		.vm_flags = tlb->vm_flags,
+	};
+
+	flush_tlb_range(&vma, tlb->start, tlb->end);
+	tlb_range_init(tlb);
+}
+
+static inline void
+tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
+{
+	if (tlb->fullmm)
+		return;
+
+	/*
+	 * flush_tlb_range() implementations that look at VM_HUGETLB
+	 * (tile, mips-r4k) flush only large pages, so force flush on
+	 * VM_HUGETLB vma boundaries.
+	 */
+	if ((tlb->vm_flags & VM_HUGETLB) != (vma->vm_flags & VM_HUGETLB))
+		tlb_flush_mmu(tlb);
+
+	/*
+	 * flush_tlb_range() implementations that flush I-TLB also flush
+	 * D-TLB (tile, extensa, arm), so its ok to just add VM_EXEC to
+	 * an existing range.
+	 */
+	tlb->vm_flags |= vma->vm_flags & (VM_EXEC|VM_HUGETLB);
+
+	flush_cache_range(vma, vma->vm_start, vma->vm_end);
+}
+
+static inline void
+tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
+{
+}
+
+#else /* CONFIG_HAVE_MMU_GATHER_RANGE */
+
+static inline void tlb_range_init(struct mmu_gather *tlb)
+{
+}
+
+/*
+ * Macro avoids argument evaluation.
+ */
+#define tlb_track_range(tlb, addr, end) do { } while (0)
+
+static inline void tlb_flush(struct mmu_gather *tlb)
+{
+	flush_tlb_mm(tlb->mm);
+}
+
+#endif /* CONFIG_HAVE_MMU_GATHER_RANGE */
+
 static inline int tlb_fast_mode(struct mmu_gather *tlb)
 {
 #ifdef CONFIG_SMP
@@ -134,7 +296,6 @@ static inline int tlb_fast_mode(struct m
 }
 
 void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, bool fullmm);
-void tlb_flush_mmu(struct mmu_gather *tlb);
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end);
 int __tlb_remove_page(struct mmu_gather *tlb, struct page *page);
 
@@ -155,10 +316,11 @@ static inline void tlb_remove_page(struc
  * later optimise away the tlb invalidate.   This helps when userspace is
  * unmapping already-unmapped pages, which happens quite a lot.
  */
-#define tlb_remove_tlb_entry(tlb, ptep, address)		\
+#define tlb_remove_tlb_entry(tlb, ptep, addr)			\
 	do {							\
 		tlb->need_flush = 1;				\
-		__tlb_remove_tlb_entry(tlb, ptep, address);	\
+		tlb_track_range(tlb, addr, addr + PAGE_SIZE);	\
+		__tlb_remove_tlb_entry(tlb, ptep, addr);	\
 	} while (0)
 
 /**
@@ -175,26 +337,31 @@ static inline void tlb_remove_page(struc
 		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);	\
 	} while (0)
 
-#define pte_free_tlb(tlb, ptep, address, end)			\
+#define pte_free_tlb(tlb, ptep, addr, end)			\
 	do {							\
 		tlb->need_flush = 1;				\
-		__pte_free_tlb(tlb, ptep, address);		\
+		tlb_track_range(tlb, addr, end);		\
+		__pte_free_tlb(tlb, ptep, addr);		\
 	} while (0)
 
-#ifndef __ARCH_HAS_4LEVEL_HACK
-#define pud_free_tlb(tlb, pudp, address, end)			\
+#define pmd_free_tlb(tlb, pmdp, addr, end)			\
 	do {							\
 		tlb->need_flush = 1;				\
-		__pud_free_tlb(tlb, pudp, address);		\
+		tlb_track_range(tlb, addr, end);		\
+		__pmd_free_tlb(tlb, pmdp, addr);		\
 	} while (0)
-#endif
 
-#define pmd_free_tlb(tlb, pmdp, address, end)			\
+#ifndef __ARCH_HAS_4LEVEL_HACK
+#define pud_free_tlb(tlb, pudp, addr, end)			\
 	do {							\
 		tlb->need_flush = 1;				\
-		__pmd_free_tlb(tlb, pmdp, address);		\
+		tlb_track_range(tlb, addr, end);		\
+		__pud_free_tlb(tlb, pudp, addr);		\
 	} while (0)
+#endif
 
+#ifndef tlb_migrate_finish
 #define tlb_migrate_finish(mm) do {} while (0)
+#endif
 
 #endif /* _ASM_GENERIC__TLB_H */
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -214,6 +214,7 @@ void tlb_gather_mmu(struct mmu_gather *t
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
 	tlb->active     = &tlb->local;
 
+	tlb_range_init(tlb);
 	tlb_table_init(tlb);
 
 	if (fullmm) {
@@ -228,7 +229,7 @@ void tlb_flush_mmu(struct mmu_gather *tl
 
 	if (!tlb->fullmm && tlb->need_flush) {
 		tlb->need_flush = 0;
-		flush_tlb_mm(tlb->mm);
+		tlb_flush(tlb);
 	}
 
 	tlb_table_flush(tlb);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

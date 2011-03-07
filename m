Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6B98D0045
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 12:49:30 -0500 (EST)
Message-Id: <20110307172206.898358080@chello.nl>
Date: Mon, 07 Mar 2011 18:13:56 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 06/15] mm: Provide generic range tracking and flushing
References: <20110307171350.989666626@chello.nl>
Content-Disposition: inline; filename=mm-generic-tlb-range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

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
Cc: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Kyle McMartin <kyle@mcmartin.ca>
Cc: James Bottomley <jejb@parisc-linux.org>
Cc: David Miller <davem@davemloft.net>
Cc: Chris Zankel <chris@zankel.net>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/Kconfig              |    3 +
 include/asm-generic/tlb.h |  122 ++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 105 insertions(+), 20 deletions(-)

Index: linux-2.6/arch/Kconfig
===================================================================
--- linux-2.6.orig/arch/Kconfig
+++ linux-2.6/arch/Kconfig
@@ -187,4 +187,7 @@ config ARCH_HAVE_NMI_SAFE_CMPXCHG
 config HAVE_RCU_TABLE_FREE
 	bool
 
+config HAVE_MMU_GATHER_RANGE
+	bool
+
 source "kernel/gcov/Kconfig"
Index: linux-2.6/include/asm-generic/tlb.h
===================================================================
--- linux-2.6.orig/include/asm-generic/tlb.h
+++ linux-2.6/include/asm-generic/tlb.h
@@ -78,7 +78,8 @@ struct mmu_gather_batch {
 #define MAX_GATHER_BATCH	\
 	((PAGE_SIZE - sizeof(struct mmu_gather_batch)) / sizeof(void *))
 
-/* struct mmu_gather is an opaque type used by the mm code for passing around
+/*
+ * struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
  */
 struct mmu_gather {
@@ -86,6 +87,10 @@ struct mmu_gather {
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	struct mmu_table_batch	*batch;
 #endif
+#ifdef CONFIG_HAVE_MMU_GATHER_RANGE
+	unsigned long		start, end;
+	unsigned long		vm_flags;
+#endif
 	unsigned int		need_flush : 1,	/* Did free PTEs */
 				fast_mode  : 1; /* No batching   */
 
@@ -106,6 +111,75 @@ struct mmu_gather {
   #define tlb_fast_mode(tlb) 1
 #endif
 
+#ifdef CONFIG_HAVE_MMU_GATHER_RANGE
+
+static inline void tlb_init_range(struct mmu_gather *tlb)
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
+static inline void
+tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
+{
+	if (!tlb->fullmm) {
+		flush_cache_range(vma, vma->vm_start, vma->vm_end);
+		tlb->vm_flags |= vma->vm_flags;
+	}
+}
+
+static inline void
+tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
+{
+}
+
+static inline void tlb_flush(struct mmu_gather *tlb)
+{
+	/*
+	 * Fake VMA, some architectures use VM_EXEC to flush I-TLB/I$,
+	 * and some use VM_HUGETLB since they have separate HPAGE TLBs.
+	 *
+	 * Since its an artificial VMA, VM_HUGETLB means only part of
+	 * the range can be HUGE, so you always have to flush normal
+	 * TLBs.
+	 */
+	struct vm_area_struct vma = {
+		.vm_mm = tlb->mm,
+		.vm_flags = tlb->vm_flags & (VM_EXEC | VM_HUGETLB),
+	};
+
+	flush_tlb_range(&vma, tlb->start, tlb->end);
+	tlb_init_range(tlb);
+}
+
+#else /* CONFIG_HAVE_MMU_GATHER_RANGE */
+
+static inline void tlb_init_range(struct mmu_gather *tlb)
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
 static inline int tlb_next_batch(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
@@ -146,6 +220,8 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
 	tlb->active     = &tlb->local;
 
+	tlb_init_range(tlb);
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
 #endif
@@ -163,7 +239,7 @@ tlb_flush_mmu(struct mmu_gather *tlb)
 
 	if (!tlb->fullmm && tlb->need_flush) {
 		tlb->need_flush = 0;
-		flush_tlb_mm(tlb->mm);
+		tlb_flush(tlb);
 	}
 
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
@@ -240,32 +316,38 @@ static inline void tlb_remove_page(struc
  * later optimise away the tlb invalidate.   This helps when userspace is
  * unmapping already-unmapped pages, which happens quite a lot.
  */
-#define tlb_remove_tlb_entry(tlb, ptep, address)		\
-	do {							\
-		tlb->need_flush = 1;				\
-		__tlb_remove_tlb_entry(tlb, ptep, address);	\
+#define tlb_remove_tlb_entry(tlb, ptep, addr)				\
+	do {								\
+		tlb->need_flush = 1;					\
+		tlb_track_range(tlb, addr, addr + PAGE_SIZE);		\
+		__tlb_remove_tlb_entry(tlb, ptep, addr);		\
 	} while (0)
 
-#define pte_free_tlb(tlb, ptep, address)			\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pte_free_tlb(tlb, ptep, address);		\
+#define pte_free_tlb(tlb, ptep, addr)					\
+	do {								\
+		tlb->need_flush = 1;					\
+		tlb_track_range(tlb, addr, pmd_addr_end(addr, TASK_SIZE));\
+		__pte_free_tlb(tlb, ptep, addr);			\
 	} while (0)
 
-#ifndef __ARCH_HAS_4LEVEL_HACK
-#define pud_free_tlb(tlb, pudp, address)			\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pud_free_tlb(tlb, pudp, address);		\
+#define pmd_free_tlb(tlb, pmdp, addr)					\
+	do {								\
+		tlb->need_flush = 1;					\
+		tlb_track_range(tlb, addr, pud_addr_end(addr, TASK_SIZE));\
+		__pmd_free_tlb(tlb, pmdp, addr);			\
 	} while (0)
-#endif
 
-#define pmd_free_tlb(tlb, pmdp, address)			\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pmd_free_tlb(tlb, pmdp, address);		\
+#ifndef __ARCH_HAS_4LEVEL_HACK
+#define pud_free_tlb(tlb, pudp, addr)					\
+	do {								\
+		tlb->need_flush = 1;					\
+		tlb_track_range(tlb, addr, pgd_addr_end(addr, TASK_SIZE));\
+		__pud_free_tlb(tlb, pudp, addr);			\
 	} while (0)
+#endif
 
+#ifndef tlb_migrate_finish
 #define tlb_migrate_finish(mm) do {} while (0)
+#endif
 
 #endif /* _ASM_GENERIC__TLB_H */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

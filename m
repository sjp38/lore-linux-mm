Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF238D003C
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 13:11:04 -0500 (EST)
Message-Id: <20110302180259.036399167@chello.nl>
Date: Wed, 02 Mar 2011 18:59:31 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 3/6] mm: Provide generic range tracking and flushing
References: <20110302175928.022902359@chello.nl>
Content-Disposition: inline; filename=mm-generic-tlb-range.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

In order to convert ia64, arm and sh to generic tlb we need to provide
some extra infrastructure to track the range of the flushed page
tables.

There are two mmu_gather cases to consider:

  unmap_region()
    tlb_gather_mmu()
    unmap_vmas()
      for (; vma; vma = vma->vm_next)
        unmao_page_range()
          tlb_start_vma() -> flush cache range
          zap_*_range()
            ptep_get_and_clear_full() -> batch/track external tlbs
            tlb_remove_tlb_entry() -> batch/track external tlbs
            tlb_remove_page() -> track range/batch page
          tlb_end_vma()
    free_pgtables()
      while (vma)
        unlink_*_vma()
        free_*_range()
          *_free_tlb() -> track tlb range
    tlb_finish_mmu() -> flush everything
  free vmas

and:

  shift_arg_pages()
    tlb_gather_mmu()
    free_*_range()
      *_free_tlb() -> track tlb range
    tlb_finish_mmu() -> flush things

There are various reasons that we need to flush TLBs _after_ freeing
the page-tables themselves. For some architectures (x86 among others)
this serializes against (both hardware and software) page table
walkers like gup_fast().  

For others (ARM) this is (also) needed to evict stale page-table
caches - ARM LPAE mode apparently caches page tables and concurrent
hardware walkers could re-populate these caches if the final tlb flush
were to be from tlb_end_vma() since an concurrent walk could still be
in progress.

Now that we fixed flush_tlb_range() to take an mm_struct argument we
can implement the needed range tracking as outlined above.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/Kconfig              |    3 +
 include/asm-generic/tlb.h |   93 ++++++++++++++++++++++++++++++++++++----------
 2 files changed, 77 insertions(+), 19 deletions(-)

Index: linux-2.6/arch/Kconfig
===================================================================
--- linux-2.6.orig/arch/Kconfig
+++ linux-2.6/arch/Kconfig
@@ -184,4 +184,7 @@ config HAVE_ARCH_MUTEX_CPU_RELAX
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
@@ -78,11 +78,15 @@ struct mmu_gather_batch {
 #define MAX_GATHER_BATCH	\
 	((PAGE_SIZE - sizeof(struct mmu_gather_batch)) / sizeof(void *))
 
-/* struct mmu_gather is an opaque type used by the mm code for passing around
+/*
+ * struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
  */
 struct mmu_gather {
 	struct mm_struct	*mm;
+#ifdef CONFIG_HAVE_MMU_GATHER_RANGE
+	unsigned long		start, end;
+#endif
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	struct mmu_table_batch	*batch;
 #endif
@@ -106,6 +110,48 @@ struct mmu_gather {
   #define tlb_fast_mode(tlb) 1
 #endif
 
+#ifdef CONFIG_HAVE_MMU_GATHER_RANGE
+
+static inline void tlb_init_range(struct mmu_gather *tlb)
+{
+	tlb->start = TASK_SIZE;
+	tlb->end = 0;
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
+	if (!tlb->fullmm)
+		flush_cache_range(vma, vma->vm_start, vma->vm_end);
+}
+
+static inline void
+tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
+{
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
+#endif /* CONFIG_HAVE_MMU_GATHER_RANGE */
+
 static inline int tlb_next_batch(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
@@ -146,6 +192,8 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
 	tlb->active     = &tlb->local;
 
+	tlb_init_range(tlb);
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
 #endif
@@ -164,6 +212,7 @@ tlb_flush_mmu(struct mmu_gather *tlb)
 	if (!tlb->fullmm && tlb->need_flush) {
 		tlb->need_flush = 0;
 		tlb_flush(tlb);
+		tlb_init_range(tlb);
 	}
 
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
@@ -240,32 +289,38 @@ static inline void tlb_remove_page(struc
  * later optimise away the tlb invalidate.   This helps when userspace is
  * unmapping already-unmapped pages, which happens quite a lot.
  */
-#define tlb_remove_tlb_entry(tlb, ptep, address)		\
-	do {							\
-		tlb->need_flush = 1;				\
-		__tlb_remove_tlb_entry(tlb, ptep, address);	\
+#define tlb_remove_tlb_entry(tlb, ptep, address)			\
+	do {								\
+		tlb->need_flush = 1;					\
+		tlb_track_range(tlb, address, address + PAGE_SIZE);	\
+		__tlb_remove_tlb_entry(tlb, ptep, address);		\
 	} while (0)
 
-#define pte_free_tlb(tlb, ptep, address)			\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pte_free_tlb(tlb, ptep, address);		\
+#define pte_free_tlb(tlb, ptep, address)					\
+	do {									\
+		tlb->need_flush = 1;						\
+		tlb_track_range(tlb, address, pmd_addr_end(address, TASK_SIZE));\
+		__pte_free_tlb(tlb, ptep, address);				\
 	} while (0)
 
-#ifndef __ARCH_HAS_4LEVEL_HACK
-#define pud_free_tlb(tlb, pudp, address)			\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pud_free_tlb(tlb, pudp, address);		\
+#define pmd_free_tlb(tlb, pmdp, address)					\
+	do {									\
+		tlb->need_flush = 1;						\
+		tlb_track_range(tlb, address, pud_addr_end(address, TASK_SIZE));\
+		__pmd_free_tlb(tlb, pmdp, address);				\
 	} while (0)
-#endif
 
-#define pmd_free_tlb(tlb, pmdp, address)			\
-	do {							\
-		tlb->need_flush = 1;				\
-		__pmd_free_tlb(tlb, pmdp, address);		\
+#ifndef __ARCH_HAS_4LEVEL_HACK
+#define pud_free_tlb(tlb, pudp, address)					\
+	do {									\
+		tlb->need_flush = 1;						\
+		tlb_track_range(tlb, address, pgd_addr_end(address, TASK_SIZE));\
+		__pud_free_tlb(tlb, pudp, address);				\
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 913428D004D
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 09:38:58 -0400 (EDT)
Message-Id: <20110401121725.414814402@chello.nl>
Date: Fri, 01 Apr 2011 14:13:00 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 02/20] powerpc: mmu_gather rework
References: <20110401121258.211963744@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-powerpc-preemptible_mmu_gather.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

Fix up powerpc to the new mmu_gather stuffs.

PPC has an extra batching queue to RCU free the actual pagetable
allocations, use the ARCH extentions for that for now.

For the ppc64_tlb_batch, which tracks the vaddrs to unhash from the
hardware hash-table, keep using per-cpu arrays but flush on context
switch and use a TLF bit to track the lazy_mmu state.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
LKML-Reference: <new-submission>
---
 arch/powerpc/include/asm/pgalloc.h     |    4 ++--
 arch/powerpc/include/asm/thread_info.h |    2 ++
 arch/powerpc/include/asm/tlb.h         |   10 ++++++++++
 arch/powerpc/kernel/process.c          |   23 ++++++++++++++++++++++-
 arch/powerpc/mm/pgtable.c              |   14 ++++----------
 arch/powerpc/mm/tlb_hash32.c           |    2 +-
 arch/powerpc/mm/tlb_hash64.c           |    6 ++++--
 arch/powerpc/mm/tlb_nohash.c           |    2 +-
 8 files changed, 46 insertions(+), 17 deletions(-)

Index: linux-2.6/arch/powerpc/include/asm/tlb.h
===================================================================
--- linux-2.6.orig/arch/powerpc/include/asm/tlb.h
+++ linux-2.6/arch/powerpc/include/asm/tlb.h
@@ -28,6 +28,16 @@
 #define tlb_start_vma(tlb, vma)	do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 
+#define HAVE_ARCH_MMU_GATHER 1
+
+struct pte_freelist_batch;
+
+struct arch_mmu_gather {
+	struct pte_freelist_batch *batch;
+};
+
+#define ARCH_MMU_GATHER_INIT (struct arch_mmu_gather){ .batch = NULL, }
+
 extern void tlb_flush(struct mmu_gather *tlb);
 
 /* Get the generic bits... */
Index: linux-2.6/arch/powerpc/kernel/process.c
===================================================================
--- linux-2.6.orig/arch/powerpc/kernel/process.c
+++ linux-2.6/arch/powerpc/kernel/process.c
@@ -395,6 +395,9 @@ struct task_struct *__switch_to(struct t
 	struct thread_struct *new_thread, *old_thread;
 	unsigned long flags;
 	struct task_struct *last;
+#ifdef CONFIG_PPC_BOOK3S_64
+	struct ppc64_tlb_batch *batch;
+#endif
 
 #ifdef CONFIG_SMP
 	/* avoid complexity of lazy save/restore of fpu
@@ -513,7 +516,17 @@ struct task_struct *__switch_to(struct t
 		old_thread->accum_tb += (current_tb - start_tb);
 		new_thread->start_tb = current_tb;
 	}
-#endif
+#endif /* CONFIG_PPC64 */
+
+#ifdef CONFIG_PPC_BOOK3S_64
+	batch = &__get_cpu_var(ppc64_tlb_batch);
+	if (batch->active) {
+		current_thread_info()->local_flags |= _TLF_LAZY_MMU;
+		if (batch->index)
+			__flush_tlb_pending(batch);
+		batch->active = 0;
+	}
+#endif /* CONFIG_PPC_BOOK3S_64 */
 
 	local_irq_save(flags);
 
@@ -528,6 +541,14 @@ struct task_struct *__switch_to(struct t
 	hard_irq_disable();
 	last = _switch(old_thread, new_thread);
 
+#ifdef CONFIG_PPC_BOOK3S_64
+	if (current_thread_info()->local_flags & _TLF_LAZY_MMU) {
+		current_thread_info()->local_flags &= ~_TLF_LAZY_MMU;
+		batch = &__get_cpu_var(ppc64_tlb_batch);
+		batch->active = 1;
+	}
+#endif /* CONFIG_PPC_BOOK3S_64 */
+
 	local_irq_restore(flags);
 
 	return last;
Index: linux-2.6/arch/powerpc/mm/pgtable.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/pgtable.c
+++ linux-2.6/arch/powerpc/mm/pgtable.c
@@ -33,8 +33,6 @@
 
 #include "mmu_decl.h"
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 #ifdef CONFIG_SMP
 
 /*
@@ -43,7 +41,6 @@ DEFINE_PER_CPU(struct mmu_gather, mmu_ga
  * freeing a page table page that is being walked without locks
  */
 
-static DEFINE_PER_CPU(struct pte_freelist_batch *, pte_freelist_cur);
 static unsigned long pte_freelist_forced_free;
 
 struct pte_freelist_batch
@@ -97,12 +94,10 @@ static void pte_free_submit(struct pte_f
 
 void pgtable_free_tlb(struct mmu_gather *tlb, void *table, unsigned shift)
 {
-	/* This is safe since tlb_gather_mmu has disabled preemption */
-	struct pte_freelist_batch **batchp = &__get_cpu_var(pte_freelist_cur);
+	struct pte_freelist_batch **batchp = &tlb->arch.batch;
 	unsigned long pgf;
 
-	if (atomic_read(&tlb->mm->mm_users) < 2 ||
-	    cpumask_equal(mm_cpumask(tlb->mm), cpumask_of(smp_processor_id()))){
+	if (atomic_read(&tlb->mm->mm_users) < 2) {
 		pgtable_free(table, shift);
 		return;
 	}
@@ -124,10 +119,9 @@ void pgtable_free_tlb(struct mmu_gather 
 	}
 }
 
-void pte_free_finish(void)
+void pte_free_finish(struct mmu_gather *tlb)
 {
-	/* This is safe since tlb_gather_mmu has disabled preemption */
-	struct pte_freelist_batch **batchp = &__get_cpu_var(pte_freelist_cur);
+	struct pte_freelist_batch **batchp = &tlb->arch.batch;
 
 	if (*batchp == NULL)
 		return;
Index: linux-2.6/arch/powerpc/include/asm/thread_info.h
===================================================================
--- linux-2.6.orig/arch/powerpc/include/asm/thread_info.h
+++ linux-2.6/arch/powerpc/include/asm/thread_info.h
@@ -139,10 +139,12 @@ static inline struct thread_info *curren
 #define TLF_NAPPING		0	/* idle thread enabled NAP mode */
 #define TLF_SLEEPING		1	/* suspend code enabled SLEEP mode */
 #define TLF_RESTORE_SIGMASK	2	/* Restore signal mask in do_signal */
+#define TLF_LAZY_MMU		3	/* tlb_batch is active */
 
 #define _TLF_NAPPING		(1 << TLF_NAPPING)
 #define _TLF_SLEEPING		(1 << TLF_SLEEPING)
 #define _TLF_RESTORE_SIGMASK	(1 << TLF_RESTORE_SIGMASK)
+#define _TLF_LAZY_MMU		(1 << TLF_LAZY_MMU)
 
 #ifndef __ASSEMBLY__
 #define HAVE_SET_RESTORE_SIGMASK	1
Index: linux-2.6/arch/powerpc/include/asm/pgalloc.h
===================================================================
--- linux-2.6.orig/arch/powerpc/include/asm/pgalloc.h
+++ linux-2.6/arch/powerpc/include/asm/pgalloc.h
@@ -32,13 +32,13 @@ static inline void pte_free(struct mm_st
 
 #ifdef CONFIG_SMP
 extern void pgtable_free_tlb(struct mmu_gather *tlb, void *table, unsigned shift);
-extern void pte_free_finish(void);
+extern void pte_free_finish(struct mmu_gather *tlb);
 #else /* CONFIG_SMP */
 static inline void pgtable_free_tlb(struct mmu_gather *tlb, void *table, unsigned shift)
 {
 	pgtable_free(table, shift);
 }
-static inline void pte_free_finish(void) { }
+static inline void pte_free_finish(struct mmu_gather *tlb) { }
 #endif /* !CONFIG_SMP */
 
 static inline void __pte_free_tlb(struct mmu_gather *tlb, struct page *ptepage,
Index: linux-2.6/arch/powerpc/mm/tlb_hash32.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_hash32.c
+++ linux-2.6/arch/powerpc/mm/tlb_hash32.c
@@ -73,7 +73,7 @@ void tlb_flush(struct mmu_gather *tlb)
 	}
 
 	/* Push out batch of freed page tables */
-	pte_free_finish();
+	pte_free_finish(tlb);
 }
 
 /*
Index: linux-2.6/arch/powerpc/mm/tlb_nohash.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_nohash.c
+++ linux-2.6/arch/powerpc/mm/tlb_nohash.c
@@ -301,7 +301,7 @@ void tlb_flush(struct mmu_gather *tlb)
 	flush_tlb_mm(tlb->mm);
 
 	/* Push out batch of freed page tables */
-	pte_free_finish();
+	pte_free_finish(tlb);
 }
 
 /*
Index: linux-2.6/arch/powerpc/mm/tlb_hash64.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/tlb_hash64.c
+++ linux-2.6/arch/powerpc/mm/tlb_hash64.c
@@ -155,7 +155,7 @@ void __flush_tlb_pending(struct ppc64_tl
 
 void tlb_flush(struct mmu_gather *tlb)
 {
-	struct ppc64_tlb_batch *tlbbatch = &__get_cpu_var(ppc64_tlb_batch);
+	struct ppc64_tlb_batch *tlbbatch = &get_cpu_var(ppc64_tlb_batch);
 
 	/* If there's a TLB batch pending, then we must flush it because the
 	 * pages are going to be freed and we really don't want to have a CPU
@@ -164,8 +164,10 @@ void tlb_flush(struct mmu_gather *tlb)
 	if (tlbbatch->index)
 		__flush_tlb_pending(tlbbatch);
 
+	put_cpu_var(ppc64_tlb_batch);
+
 	/* Push out batch of freed page tables */
-	pte_free_finish();
+	pte_free_finish(tlb);
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

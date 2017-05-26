Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 47C746B02FA
	for <linux-mm@kvack.org>; Thu, 25 May 2017 20:48:00 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w205so257674291oif.12
        for <linux-mm@kvack.org>; Thu, 25 May 2017 17:48:00 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f2si5100237otc.155.2017.05.25.17.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 17:47:59 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 5/8] x86/mm: Remove the UP tlbflush code; always use the formerly SMP code
Date: Thu, 25 May 2017 17:47:49 -0700
Message-Id: <ed3e5f1969288bcf4361a4b29dacb82abb9a7857.1495759610.git.luto@kernel.org>
In-Reply-To: <cover.1495759610.git.luto@kernel.org>
References: <cover.1495759610.git.luto@kernel.org>
In-Reply-To: <cover.1495759610.git.luto@kernel.org>
References: <cover.1495759610.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

The UP tlbflush generates somewhat nicer code than the SMP version.
Aside from that, it's fallen quite a bit behind the SMP code:

 - flush_tlb_mm_range() didn't flush individual pages if the range
   was small.

 - The lazy TLB code was much weaker.  This usually wouldn't matter,
   but, if a kernel thread flushed its lazy "active_mm" more than
   once (due to reclaim or similar), it wouldn't be unlazied and
   would instead pointlessly flush repeatedly.

 - Tracepoints were missing.

Aside from that, simply having the UP code around was a maintanence
burden, since it means that any change to the TLB flush code had to
make sure not to break it.

Simplify everything by deleting the UP code.

Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/Kconfig                   |  2 +-
 arch/x86/include/asm/hardirq.h     |  2 +-
 arch/x86/include/asm/mmu.h         |  6 ---
 arch/x86/include/asm/mmu_context.h |  2 -
 arch/x86/include/asm/tlbbatch.h    |  2 -
 arch/x86/include/asm/tlbflush.h    | 76 +-------------------------------------
 arch/x86/mm/init.c                 |  2 -
 arch/x86/mm/tlb.c                  | 17 +--------
 8 files changed, 5 insertions(+), 104 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cd18994a9555..d65f87e083d1 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -69,7 +69,7 @@ config X86
 	select ARCH_USE_BUILTIN_BSWAP
 	select ARCH_USE_QUEUED_RWLOCKS
 	select ARCH_USE_QUEUED_SPINLOCKS
-	select ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH if SMP
+	select ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
 	select ARCH_WANT_FRAME_POINTERS
 	select ARCH_WANTS_DYNAMIC_TASK_STRUCT
 	select BUILDTIME_EXTABLE_SORT
diff --git a/arch/x86/include/asm/hardirq.h b/arch/x86/include/asm/hardirq.h
index 59405a248fc2..9b76cd331990 100644
--- a/arch/x86/include/asm/hardirq.h
+++ b/arch/x86/include/asm/hardirq.h
@@ -22,8 +22,8 @@ typedef struct {
 #ifdef CONFIG_SMP
 	unsigned int irq_resched_count;
 	unsigned int irq_call_count;
-	unsigned int irq_tlb_count;
 #endif
+	unsigned int irq_tlb_count;
 #ifdef CONFIG_X86_THERMAL_VECTOR
 	unsigned int irq_thermal_count;
 #endif
diff --git a/arch/x86/include/asm/mmu.h b/arch/x86/include/asm/mmu.h
index f9813b6d8b80..79b647a7ebd0 100644
--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -37,12 +37,6 @@ typedef struct {
 #endif
 } mm_context_t;
 
-#ifdef CONFIG_SMP
 void leave_mm(int cpu);
-#else
-static inline void leave_mm(int cpu)
-{
-}
-#endif
 
 #endif /* _ASM_X86_MMU_H */
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 68b329d77b3a..187c39470a0b 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -99,10 +99,8 @@ static inline void load_mm_ldt(struct mm_struct *mm)
 
 static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
 {
-#ifdef CONFIG_SMP
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
-#endif
 }
 
 static inline int init_new_context(struct task_struct *tsk,
diff --git a/arch/x86/include/asm/tlbbatch.h b/arch/x86/include/asm/tlbbatch.h
index 01a6de16fb96..f4a6ff352a0e 100644
--- a/arch/x86/include/asm/tlbbatch.h
+++ b/arch/x86/include/asm/tlbbatch.h
@@ -3,7 +3,6 @@
 
 #include <linux/cpumask.h>
 
-#ifdef CONFIG_SMP
 struct arch_tlbflush_unmap_batch {
 	/*
 	 * Each bit set is a CPU that potentially has a TLB entry for one of
@@ -11,6 +10,5 @@ struct arch_tlbflush_unmap_batch {
 	 */
 	struct cpumask cpumask;
 };
-#endif
 
 #endif /* _ARCH_X86_TLBBATCH_H */
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 9934c7c99213..dbb5a9f0fed8 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -7,6 +7,7 @@
 #include <asm/processor.h>
 #include <asm/cpufeature.h>
 #include <asm/special_insns.h>
+#include <asm/smp.h>
 
 static inline void __invpcid(unsigned long pcid, unsigned long addr,
 			     unsigned long type)
@@ -65,10 +66,8 @@ static inline void invpcid_flush_all_nonglobals(void)
 #endif
 
 struct tlb_state {
-#ifdef CONFIG_SMP
 	struct mm_struct *active_mm;
 	int state;
-#endif
 
 	/*
 	 * Access to this CR4 shadow and to H/W CR4 is protected by
@@ -231,77 +230,6 @@ struct flush_tlb_info {
 	unsigned long end;
 };
 
-#ifndef CONFIG_SMP
-
-/* "_up" is for UniProcessor.
- *
- * This is a helper for other header functions.  *Not* intended to be called
- * directly.  All global TLB flushes need to either call this, or to bump the
- * vm statistics themselves.
- */
-static inline void __flush_tlb_up(void)
-{
-	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
-	__flush_tlb();
-}
-
-static inline void flush_tlb_all(void)
-{
-	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
-	__flush_tlb_all();
-}
-
-static inline void local_flush_tlb(void)
-{
-	__flush_tlb_up();
-}
-
-static inline void flush_tlb_mm(struct mm_struct *mm)
-{
-	if (mm == current->active_mm)
-		__flush_tlb_up();
-}
-
-static inline void flush_tlb_page(struct vm_area_struct *vma,
-				  unsigned long addr)
-{
-	if (vma->vm_mm == current->active_mm)
-		__flush_tlb_one(addr);
-}
-
-static inline void flush_tlb_range(struct vm_area_struct *vma,
-				   unsigned long start, unsigned long end)
-{
-	if (vma->vm_mm == current->active_mm)
-		__flush_tlb_up();
-}
-
-static inline void flush_tlb_mm_range(struct mm_struct *mm,
-	   unsigned long start, unsigned long end, unsigned long vmflag)
-{
-	if (mm == current->active_mm)
-		__flush_tlb_up();
-}
-
-static inline void native_flush_tlb_others(const struct cpumask *cpumask,
-					   const struct flush_tlb_info *info)
-{
-}
-
-static inline void reset_lazy_tlbstate(void)
-{
-}
-
-static inline void flush_tlb_kernel_range(unsigned long start,
-					  unsigned long end)
-{
-	flush_tlb_all();
-}
-
-#else  /* SMP */
-
-#include <asm/smp.h>
-
 #define local_flush_tlb() __flush_tlb()
 
 #define flush_tlb_mm(mm)	flush_tlb_mm_range(mm, 0UL, TLB_FLUSH_ALL, 0UL)
@@ -339,8 +267,6 @@ static inline void arch_tlbbatch_add_mm(struct arch_tlbflush_unmap_batch *batch,
 
 extern void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch);
 
-#endif	/* SMP */
-
 #ifndef CONFIG_PARAVIRT
 #define flush_tlb_others(mask, info)	\
 	native_flush_tlb_others(mask, info)
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index cbc87ea98751..c61183b57427 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -811,10 +811,8 @@ void __init zone_sizes_init(void)
 }
 
 DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
-#ifdef CONFIG_SMP
 	.active_mm = &init_mm,
 	.state = 0,
-#endif
 	.cr4 = ~0UL,	/* fail hard if we screw up cr4 shadow initialization */
 };
 EXPORT_SYMBOL_GPL(cpu_tlbstate);
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index c03b4a0ce58c..da1416c77bfb 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -15,7 +15,7 @@
 #include <linux/debugfs.h>
 
 /*
- *	Smarter SMP flushing macros.
+ *	TLB flushing, formerly SMP-only
  *		c/o Linus Torvalds.
  *
  *	These mean you can really definitely utterly forget about
@@ -28,8 +28,6 @@
  *	Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
  */
 
-#ifdef CONFIG_SMP
-
 /*
  * We cannot call mmdrop() because we are in interrupt context,
  * instead update mm->cpu_vm_mask.
@@ -53,8 +51,6 @@ void leave_mm(int cpu)
 }
 EXPORT_SYMBOL_GPL(leave_mm);
 
-#endif /* CONFIG_SMP */
-
 void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 	       struct task_struct *tsk)
 {
@@ -85,10 +81,8 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 				set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
 		}
 
-#ifdef CONFIG_SMP
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
 		this_cpu_write(cpu_tlbstate.active_mm, next);
-#endif
 
 		cpumask_set_cpu(cpu, mm_cpumask(next));
 
@@ -146,9 +140,7 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		if (unlikely(prev->context.ldt != next->context.ldt))
 			load_mm_ldt(next);
 #endif
-	}
-#ifdef CONFIG_SMP
-	  else {
+	} else {
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
 		BUG_ON(this_cpu_read(cpu_tlbstate.active_mm) != next);
 
@@ -175,11 +167,8 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 			load_mm_ldt(next);
 		}
 	}
-#endif
 }
 
-#ifdef CONFIG_SMP
-
 /*
  * The flush IPI assumes that a thread switch happens in this order:
  * [cpu0: the cpu that switches]
@@ -436,5 +425,3 @@ static int __init create_tlb_single_page_flush_ceiling(void)
 	return 0;
 }
 late_initcall(create_tlb_single_page_flush_ceiling);
-
-#endif /* CONFIG_SMP */
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

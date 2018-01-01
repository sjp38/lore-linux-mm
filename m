Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCB866B026F
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 09:33:38 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o32so21878960wrf.20
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 06:33:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 30si23413530wrq.133.2018.01.01.06.33.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jan 2018 06:33:37 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.9 18/75] x86/mm: Remove the UP asm/tlbflush.h code, always use the (formerly) SMP code
Date: Mon,  1 Jan 2018 15:31:55 +0100
Message-Id: <20180101140059.520664035@linuxfoundation.org>
In-Reply-To: <20180101140056.475827799@linuxfoundation.org>
References: <20180101140056.475827799@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bpetkov@suse.de>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Nadav Amit <nadav.amit@gmail.com>, Nadav Amit <namit@vmware.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>

4.9-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Andy Lutomirski <luto@kernel.org>

commit ce4a4e565f5264909a18c733b864c3f74467f69e upstream.

The UP asm/tlbflush.h generates somewhat nicer code than the SMP version.
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

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bpetkov@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/Kconfig                   |    2 
 arch/x86/include/asm/hardirq.h     |    2 
 arch/x86/include/asm/mmu.h         |    6 --
 arch/x86/include/asm/mmu_context.h |    2 
 arch/x86/include/asm/tlbflush.h    |   78 -------------------------------------
 arch/x86/mm/init.c                 |    2 
 arch/x86/mm/tlb.c                  |   17 --------
 7 files changed, 5 insertions(+), 104 deletions(-)

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -45,7 +45,7 @@ config X86
 	select ARCH_USE_CMPXCHG_LOCKREF		if X86_64
 	select ARCH_USE_QUEUED_RWLOCKS
 	select ARCH_USE_QUEUED_SPINLOCKS
-	select ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH if SMP
+	select ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
 	select ARCH_WANTS_DYNAMIC_TASK_STRUCT
 	select ARCH_WANT_FRAME_POINTERS
 	select ARCH_WANT_IPC_PARSE_VERSION	if X86_32
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
--- a/arch/x86/include/asm/mmu.h
+++ b/arch/x86/include/asm/mmu.h
@@ -33,12 +33,6 @@ typedef struct {
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
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -99,10 +99,8 @@ static inline void load_mm_ldt(struct mm
 
 static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
 {
-#ifdef CONFIG_SMP
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_LAZY);
-#endif
 }
 
 static inline int init_new_context(struct task_struct *tsk,
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -7,6 +7,7 @@
 #include <asm/processor.h>
 #include <asm/cpufeature.h>
 #include <asm/special_insns.h>
+#include <asm/smp.h>
 
 static inline void __invpcid(unsigned long pcid, unsigned long addr,
 			     unsigned long type)
@@ -65,10 +66,8 @@ static inline void invpcid_flush_all_non
 #endif
 
 struct tlb_state {
-#ifdef CONFIG_SMP
 	struct mm_struct *active_mm;
 	int state;
-#endif
 
 	/*
 	 * Access to this CR4 shadow and to H/W CR4 is protected by
@@ -216,79 +215,6 @@ static inline void __flush_tlb_one(unsig
  * and page-granular flushes are available only on i486 and up.
  */
 
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
-					   struct mm_struct *mm,
-					   unsigned long start,
-					   unsigned long end)
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
@@ -319,8 +245,6 @@ static inline void reset_lazy_tlbstate(v
 	this_cpu_write(cpu_tlbstate.active_mm, &init_mm);
 }
 
-#endif	/* SMP */
-
 #ifndef CONFIG_PARAVIRT
 #define flush_tlb_others(mask, mm, start, end)	\
 	native_flush_tlb_others(mask, mm, start, end)
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -764,10 +764,8 @@ void __init zone_sizes_init(void)
 }
 
 DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
-#ifdef CONFIG_SMP
 	.active_mm = &init_mm,
 	.state = 0,
-#endif
 	.cr4 = ~0UL,	/* fail hard if we screw up cr4 shadow initialization */
 };
 EXPORT_SYMBOL_GPL(cpu_tlbstate);
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
 struct flush_tlb_info {
 	struct mm_struct *flush_mm;
 	unsigned long flush_start;
@@ -59,8 +57,6 @@ void leave_mm(int cpu)
 }
 EXPORT_SYMBOL_GPL(leave_mm);
 
-#endif /* CONFIG_SMP */
-
 void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 	       struct task_struct *tsk)
 {
@@ -91,10 +87,8 @@ void switch_mm_irqs_off(struct mm_struct
 				set_pgd(pgd, init_mm.pgd[stack_pgd_index]);
 		}
 
-#ifdef CONFIG_SMP
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
 		this_cpu_write(cpu_tlbstate.active_mm, next);
-#endif
 
 		cpumask_set_cpu(cpu, mm_cpumask(next));
 
@@ -152,9 +146,7 @@ void switch_mm_irqs_off(struct mm_struct
 		if (unlikely(prev->context.ldt != next->context.ldt))
 			load_mm_ldt(next);
 #endif
-	}
-#ifdef CONFIG_SMP
-	  else {
+	} else {
 		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
 		BUG_ON(this_cpu_read(cpu_tlbstate.active_mm) != next);
 
@@ -181,11 +173,8 @@ void switch_mm_irqs_off(struct mm_struct
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
@@ -438,5 +427,3 @@ static int __init create_tlb_single_page
 	return 0;
 }
 late_initcall(create_tlb_single_page_flush_ceiling);
-
-#endif /* CONFIG_SMP */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

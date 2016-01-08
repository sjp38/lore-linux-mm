Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C344E828E9
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:53 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id q63so16322503pfb.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:53 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id cz10si57770478pad.0.2016.01.08.15.15.53
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:53 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 12/13] x86/mm: Uninline switch_mm
Date: Fri,  8 Jan 2016 15:15:30 -0800
Message-Id: <df4b08184f61f5b87deb065ab87e56699009253d.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

It's fairly large and it has quite a few callers.  This may also
help untangle some headers down the road.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/mmu_context.h | 93 +-----------------------------------
 arch/x86/mm/tlb.c                  | 97 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 99 insertions(+), 91 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index 1edc9cd198b8..05c4d0ab64bb 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -104,102 +104,13 @@ static inline void enter_lazy_tlb(struct mm_struct *mm, struct task_struct *tsk)
 #endif
 }
 
-static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
-			     struct task_struct *tsk)
-{
-	unsigned cpu = smp_processor_id();
-
-	if (likely(prev != next)) {
-#ifdef CONFIG_SMP
-		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
-		this_cpu_write(cpu_tlbstate.active_mm, next);
-#endif
-		cpumask_set_cpu(cpu, mm_cpumask(next));
+extern void switch_mm(struct mm_struct *prev, struct mm_struct *next,
+		      struct task_struct *tsk);
 
-		/*
-		 * Re-load page tables.
-		 *
-		 * This logic has an ordering constraint:
-		 *
-		 *  CPU 0: Write to a PTE for 'next'
-		 *  CPU 0: load bit 1 in mm_cpumask.  if nonzero, send IPI.
-		 *  CPU 1: set bit 1 in next's mm_cpumask
-		 *  CPU 1: load from the PTE that CPU 0 writes (implicit)
-		 *
-		 * We need to prevent an outcome in which CPU 1 observes
-		 * the new PTE value and CPU 0 observes bit 1 clear in
-		 * mm_cpumask.  (If that occurs, then the IPI will never
-		 * be sent, and CPU 0's TLB will contain a stale entry.)
-		 *
-		 * The bad outcome can occur if either CPU's load is
-		 * reordered before that CPU's store, so both CPUs much
-		 * execute full barriers to prevent this from happening.
-		 *
-		 * Thus, switch_mm needs a full barrier between the
-		 * store to mm_cpumask and any operation that could load
-		 * from next->pgd.  This barrier synchronizes with
-		 * remote TLB flushers.  Fortunately, load_cr3 is
-		 * serializing and thus acts as a full barrier.
-		 *
-		 */
-		load_cr3(next->pgd);
 
-		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
 
-		/* Stop flush ipis for the previous mm */
-		cpumask_clear_cpu(cpu, mm_cpumask(prev));
 
-		/* Load per-mm CR4 state */
-		load_mm_cr4(next);
 
-#ifdef CONFIG_MODIFY_LDT_SYSCALL
-		/*
-		 * Load the LDT, if the LDT is different.
-		 *
-		 * It's possible that prev->context.ldt doesn't match
-		 * the LDT register.  This can happen if leave_mm(prev)
-		 * was called and then modify_ldt changed
-		 * prev->context.ldt but suppressed an IPI to this CPU.
-		 * In this case, prev->context.ldt != NULL, because we
-		 * never set context.ldt to NULL while the mm still
-		 * exists.  That means that next->context.ldt !=
-		 * prev->context.ldt, because mms never share an LDT.
-		 */
-		if (unlikely(prev->context.ldt != next->context.ldt))
-			load_mm_ldt(next);
-#endif
-	}
-#ifdef CONFIG_SMP
-	  else {
-		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
-		BUG_ON(this_cpu_read(cpu_tlbstate.active_mm) != next);
-
-		if (!cpumask_test_cpu(cpu, mm_cpumask(next))) {
-			/*
-			 * On established mms, the mm_cpumask is only changed
-			 * from irq context, from ptep_clear_flush() while in
-			 * lazy tlb mode, and here. Irqs are blocked during
-			 * schedule, protecting us from simultaneous changes.
-			 */
-			cpumask_set_cpu(cpu, mm_cpumask(next));
-
-			/*
-			 * We were in lazy tlb mode and leave_mm disabled
-			 * tlb flush IPI delivery. We must reload CR3
-			 * to make sure to use no freed page tables.
-			 *
-			 * As above, this is a barrier that forces
-			 * TLB repopulation to be ordered after the
-			 * store to mm_cpumask.
-			 */
-			load_cr3(next->pgd);
-			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
-			load_mm_cr4(next);
-			load_mm_ldt(next);
-		}
-	}
-#endif
-}
 
 #define activate_mm(prev, next)			\
 do {						\
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 87fcc7a62e71..9790c9338e52 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -59,6 +59,103 @@ void leave_mm(int cpu)
 }
 EXPORT_SYMBOL_GPL(leave_mm);
 
+void switch_mm(struct mm_struct *prev, struct mm_struct *next,
+	       struct task_struct *tsk)
+{
+	unsigned cpu = smp_processor_id();
+
+	if (likely(prev != next)) {
+#ifdef CONFIG_SMP
+		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
+		this_cpu_write(cpu_tlbstate.active_mm, next);
+#endif
+		cpumask_set_cpu(cpu, mm_cpumask(next));
+
+		/*
+		 * Re-load page tables.
+		 *
+		 * This logic has an ordering constraint:
+		 *
+		 *  CPU 0: Write to a PTE for 'next'
+		 *  CPU 0: load bit 1 in mm_cpumask.  if nonzero, send IPI.
+		 *  CPU 1: set bit 1 in next's mm_cpumask
+		 *  CPU 1: load from the PTE that CPU 0 writes (implicit)
+		 *
+		 * We need to prevent an outcome in which CPU 1 observes
+		 * the new PTE value and CPU 0 observes bit 1 clear in
+		 * mm_cpumask.  (If that occurs, then the IPI will never
+		 * be sent, and CPU 0's TLB will contain a stale entry.)
+		 *
+		 * The bad outcome can occur if either CPU's load is
+		 * reordered before that CPU's store, so both CPUs much
+		 * execute full barriers to prevent this from happening.
+		 *
+		 * Thus, switch_mm needs a full barrier between the
+		 * store to mm_cpumask and any operation that could load
+		 * from next->pgd.  This barrier synchronizes with
+		 * remote TLB flushers.  Fortunately, load_cr3 is
+		 * serializing and thus acts as a full barrier.
+		 *
+		 */
+		load_cr3(next->pgd);
+
+		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
+
+		/* Stop flush ipis for the previous mm */
+		cpumask_clear_cpu(cpu, mm_cpumask(prev));
+
+		/* Load per-mm CR4 state */
+		load_mm_cr4(next);
+
+#ifdef CONFIG_MODIFY_LDT_SYSCALL
+		/*
+		 * Load the LDT, if the LDT is different.
+		 *
+		 * It's possible that prev->context.ldt doesn't match
+		 * the LDT register.  This can happen if leave_mm(prev)
+		 * was called and then modify_ldt changed
+		 * prev->context.ldt but suppressed an IPI to this CPU.
+		 * In this case, prev->context.ldt != NULL, because we
+		 * never set context.ldt to NULL while the mm still
+		 * exists.  That means that next->context.ldt !=
+		 * prev->context.ldt, because mms never share an LDT.
+		 */
+		if (unlikely(prev->context.ldt != next->context.ldt))
+			load_mm_ldt(next);
+#endif
+	}
+#ifdef CONFIG_SMP
+	  else {
+		this_cpu_write(cpu_tlbstate.state, TLBSTATE_OK);
+		BUG_ON(this_cpu_read(cpu_tlbstate.active_mm) != next);
+
+		if (!cpumask_test_cpu(cpu, mm_cpumask(next))) {
+			/*
+			 * On established mms, the mm_cpumask is only changed
+			 * from irq context, from ptep_clear_flush() while in
+			 * lazy tlb mode, and here. Irqs are blocked during
+			 * schedule, protecting us from simultaneous changes.
+			 */
+			cpumask_set_cpu(cpu, mm_cpumask(next));
+
+			/*
+			 * We were in lazy tlb mode and leave_mm disabled
+			 * tlb flush IPI delivery. We must reload CR3
+			 * to make sure to use no freed page tables.
+			 *
+			 * As above, this is a barrier that forces
+			 * TLB repopulation to be ordered after the
+			 * store to mm_cpumask.
+			 */
+			load_cr3(next->pgd);
+			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
+			load_mm_cr4(next);
+			load_mm_ldt(next);
+		}
+	}
+#endif
+}
+
 /*
  * The flush IPI assumes that a thread switch happens in this order:
  * [cpu0: the cpu that switches]
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

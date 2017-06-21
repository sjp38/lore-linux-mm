Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E18D76B0315
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:22:26 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e191so64002715oih.4
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 22:22:26 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e103si3881147ote.50.2017.06.20.22.22.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 22:22:25 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 07/11] x86/mm: Stop calling leave_mm() in idle code
Date: Tue, 20 Jun 2017 22:22:13 -0700
Message-Id: <2b3572123ab0d0fb9a9b82dc0deee8a33eeac51f.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

Now that lazy TLB suppresses all flush IPIs (as opposed to all but
the first), there's no need to leave_mm() when going idle.

This means we can get rid of the rcuidle hack in
switch_mm_irqs_off() and we can unexport leave_mm().

This also removes acpi_unlazy_tlb() from the x86 and ia64 headers,
since it has no callers any more.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/ia64/include/asm/acpi.h  |  2 --
 arch/x86/include/asm/acpi.h   |  2 --
 arch/x86/mm/tlb.c             | 19 +++----------------
 drivers/acpi/processor_idle.c |  2 --
 drivers/idle/intel_idle.c     |  9 ++++-----
 5 files changed, 7 insertions(+), 27 deletions(-)

diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index a3d0211970e9..c86a947f5368 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -112,8 +112,6 @@ static inline void arch_acpi_set_pdc_bits(u32 *buf)
 	buf[2] |= ACPI_PDC_EST_CAPABILITY_SMP;
 }
 
-#define acpi_unlazy_tlb(x)
-
 #ifdef CONFIG_ACPI_NUMA
 extern cpumask_t early_cpu_possible_map;
 #define for_each_possible_early_cpu(cpu)  \
diff --git a/arch/x86/include/asm/acpi.h b/arch/x86/include/asm/acpi.h
index 2efc768e4362..562286fa151f 100644
--- a/arch/x86/include/asm/acpi.h
+++ b/arch/x86/include/asm/acpi.h
@@ -150,8 +150,6 @@ static inline void disable_acpi(void) { }
 extern int x86_acpi_numa_init(void);
 #endif /* CONFIG_ACPI_NUMA */
 
-#define acpi_unlazy_tlb(x)	leave_mm(x)
-
 #ifdef CONFIG_ACPI_APEI
 static inline pgprot_t arch_apei_get_mem_attribute(phys_addr_t addr)
 {
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index fea2b07ac7d8..5f932fd80881 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -50,7 +50,6 @@ void leave_mm(int cpu)
 
 	switch_mm(NULL, &init_mm, NULL);
 }
-EXPORT_SYMBOL_GPL(leave_mm);
 
 void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 	       struct task_struct *tsk)
@@ -113,14 +112,8 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 			this_cpu_write(cpu_tlbstate.ctxs[0].tlb_gen,
 				       next_tlb_gen);
 			write_cr3(__pa(next->pgd));
-			/*
-			 * This gets called via leave_mm() in the idle path
-			 * where RCU functions differently.  Tracing normally
-			 * uses RCU, so we have to call the tracepoint
-			 * specially here.
-			 */
-			trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH,
-						TLB_FLUSH_ALL);
+			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH,
+					TLB_FLUSH_ALL);
 		}
 
 		/*
@@ -166,13 +159,7 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		this_cpu_write(cpu_tlbstate.loaded_mm, next);
 		write_cr3(__pa(next->pgd));
 
-		/*
-		 * This gets called via leave_mm() in the idle path where RCU
-		 * functions differently.  Tracing normally uses RCU, so we
-		 * have to call the tracepoint specially here.
-		 */
-		trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH,
-					TLB_FLUSH_ALL);
+		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
 	}
 
 	load_mm_cr4(next);
diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
index 5c8aa9cf62d7..fe3d2a40f311 100644
--- a/drivers/acpi/processor_idle.c
+++ b/drivers/acpi/processor_idle.c
@@ -708,8 +708,6 @@ static DEFINE_RAW_SPINLOCK(c3_lock);
 static void acpi_idle_enter_bm(struct acpi_processor *pr,
 			       struct acpi_processor_cx *cx, bool timer_bc)
 {
-	acpi_unlazy_tlb(smp_processor_id());
-
 	/*
 	 * Must be done before busmaster disable as we might need to
 	 * access HPET !
diff --git a/drivers/idle/intel_idle.c b/drivers/idle/intel_idle.c
index 216d7ec88c0c..2ae43f59091d 100644
--- a/drivers/idle/intel_idle.c
+++ b/drivers/idle/intel_idle.c
@@ -912,16 +912,15 @@ static __cpuidle int intel_idle(struct cpuidle_device *dev,
 	struct cpuidle_state *state = &drv->states[index];
 	unsigned long eax = flg2MWAIT(state->flags);
 	unsigned int cstate;
-	int cpu = smp_processor_id();
 
 	cstate = (((eax) >> MWAIT_SUBSTATE_SIZE) & MWAIT_CSTATE_MASK) + 1;
 
 	/*
-	 * leave_mm() to avoid costly and often unnecessary wakeups
-	 * for flushing the user TLB's associated with the active mm.
+	 * NB: if CPUIDLE_FLAG_TLB_FLUSHED is set, this idle transition
+	 * will probably flush the TLB.  It's not guaranteed to flush
+	 * the TLB, though, so it's not clear that we can do anything
+	 * useful with this knowledge.
 	 */
-	if (state->flags & CPUIDLE_FLAG_TLB_FLUSHED)
-		leave_mm(cpu);
 
 	if (!(lapic_timer_reliable_states & (1 << (cstate))))
 		tick_broadcast_enter();
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

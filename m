Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id AAF0882F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 02:46:47 -0500 (EST)
Received: by pasz6 with SMTP id z6so115596827pas.2
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 00:46:47 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id ez3si24933070pab.130.2015.11.01.00.46.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Nov 2015 00:46:46 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so120446710pac.3
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 00:46:46 -0700 (PDT)
From: Jungseok Lee <jungseoklee85@gmail.com>
Subject: [PATCH v6 3/3] arm64: Introduce IRQ stack
Date: Sun,  1 Nov 2015 07:46:17 +0000
Message-Id: <1446363977-23656-4-git-send-email-jungseoklee85@gmail.com>
In-Reply-To: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com>
References: <1446363977-23656-1-git-send-email-jungseoklee85@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, cl@linux.com, tj@kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: james.morse@arm.com, takahiro.akashi@linaro.org, mark.rutland@arm.com, barami97@gmail.com, linux-kernel@vger.kernel.org

Currently, kernel context and interrupts are handled using a single
kernel stack navigated by sp_el1. This forces a system to use 16KB
stack, not 8KB one. This restriction can make low memory platforms
suffer from memory pressure accompanied by performance degradation.

This patch addresses the issue as introducing a separate percpu IRQ
stack to handle both hard and soft interrupts with two ground rules:

  - Utilize sp_el0 in EL1 context, which is not used currently
  - Do not complicate current_thread_info calculation

It is a core concept to directly retrieve struct thread_info from
sp_el0. This approach helps to prevent text section size from being
increased largely as removing masking operation using THREAD_SIZE
in tons of places.

[Thanks to James Morse for his valuable feedbacks which greatly help
to figure out a better implementation. - Jungseok]

Cc: AKASHI Takahiro <takahiro.akashi@linaro.org>
Tested-by: James Morse <james.morse@arm.com>
Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
---
Note that this change has been tested with 4 different combos:
- THREAD_SIZE = 16KB, IRQ_STACK_SIZE = 16KB
- THREAD_SIZE = 16KB, IRQ_STACK_SIZE =  8KB
- THREAD_SIZE =  8KB, IRQ_STACK_SIZE = 16KB
- THREAD_SIZE =  8KB, IRQ_STACK_SIZE =  8KB

I've reviwed the approach using do_softirq_own_stack() which Catalin
mentioned, but it is questionable to reduce max stack depth highly.
That is why this hunk does not change its direction.

 arch/arm64/Kconfig                   |  1 +
 arch/arm64/include/asm/irq.h         |  6 +++
 arch/arm64/include/asm/percpu.h      |  6 +++
 arch/arm64/include/asm/thread_info.h | 10 +++-
 arch/arm64/kernel/entry.S            | 42 ++++++++++++++--
 arch/arm64/kernel/head.S             |  5 ++
 arch/arm64/kernel/irq.c              |  2 +
 arch/arm64/kernel/sleep.S            |  3 ++
 arch/arm64/kernel/smp.c              |  4 +-
 9 files changed, 70 insertions(+), 9 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 4d8a5b2..de4e4c9 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -69,6 +69,7 @@ config ARM64
 	select HAVE_FUNCTION_GRAPH_TRACER
 	select HAVE_GENERIC_DMA_COHERENT
 	select HAVE_HW_BREAKPOINT if PERF_EVENTS
+	select HAVE_IRQ_EXIT_ON_IRQ_STACK
 	select HAVE_MEMBLOCK
 	select HAVE_PATA_PLATFORM
 	select HAVE_PERF_EVENTS
diff --git a/arch/arm64/include/asm/irq.h b/arch/arm64/include/asm/irq.h
index 0916929..d4c23bd 100644
--- a/arch/arm64/include/asm/irq.h
+++ b/arch/arm64/include/asm/irq.h
@@ -1,6 +1,11 @@
 #ifndef __ASM_IRQ_H
 #define __ASM_IRQ_H
 
+#define IRQ_STACK_SIZE		16384
+#define IRQ_STACK_START_SP	(IRQ_STACK_SIZE - 16)
+
+#ifndef __ASSEMBLY__
+
 #include <linux/irqchip/arm-gic-acpi.h>
 
 #include <asm-generic/irq.h>
@@ -21,3 +26,4 @@ static inline void acpi_irq_init(void)
 #define acpi_irq_init acpi_irq_init
 
 #endif
+#endif
diff --git a/arch/arm64/include/asm/percpu.h b/arch/arm64/include/asm/percpu.h
index 0a456be..c581ed4 100644
--- a/arch/arm64/include/asm/percpu.h
+++ b/arch/arm64/include/asm/percpu.h
@@ -16,6 +16,12 @@
 #ifndef __ASM_PERCPU_H
 #define __ASM_PERCPU_H
 
+#ifdef CONFIG_ARM64_4K_PAGES
+#include <asm/irq.h>
+
+#define PERCPU_ATOM_SIZE	IRQ_STACK_SIZE
+#endif
+
 static inline void set_my_cpu_offset(unsigned long off)
 {
 	asm volatile("msr tpidr_el1, %0" :: "r" (off) : "memory");
diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
index 90c7ff2..abd64bd 100644
--- a/arch/arm64/include/asm/thread_info.h
+++ b/arch/arm64/include/asm/thread_info.h
@@ -73,10 +73,16 @@ register unsigned long current_stack_pointer asm ("sp");
  */
 static inline struct thread_info *current_thread_info(void) __attribute_const__;
 
+/*
+ * struct thread_info can be accessed directly via sp_el0.
+ */
 static inline struct thread_info *current_thread_info(void)
 {
-	return (struct thread_info *)
-		(current_stack_pointer & ~(THREAD_SIZE - 1));
+	unsigned long sp_el0;
+
+	asm ("mrs %0, sp_el0" : "=r" (sp_el0));
+
+	return (struct thread_info *)sp_el0;
 }
 
 #define thread_saved_pc(tsk)	\
diff --git a/arch/arm64/kernel/entry.S b/arch/arm64/kernel/entry.S
index 7ed3d75..d24acfc 100644
--- a/arch/arm64/kernel/entry.S
+++ b/arch/arm64/kernel/entry.S
@@ -27,6 +27,7 @@
 #include <asm/cpufeature.h>
 #include <asm/errno.h>
 #include <asm/esr.h>
+#include <asm/irq.h>
 #include <asm/thread_info.h>
 #include <asm/unistd.h>
 
@@ -88,7 +89,8 @@
 
 	.if	\el == 0
 	mrs	x21, sp_el0
-	get_thread_info tsk			// Ensure MDSCR_EL1.SS is clear,
+	mov	tsk, sp
+	and	tsk, tsk, #~(THREAD_SIZE - 1)	// Ensure MDSCR_EL1.SS is clear,
 	ldr	x19, [tsk, #TI_FLAGS]		// since we can unmask debug
 	disable_step_tsk x19, x20		// exceptions when scheduling.
 	.else
@@ -108,6 +110,13 @@
 	.endif
 
 	/*
+	 * Set sp_el0 to current thread_info.
+	 */
+	.if	\el == 0
+	msr	sp_el0, tsk
+	.endif
+
+	/*
 	 * Registers that may be useful after this macro is invoked:
 	 *
 	 * x21 - aborted SP
@@ -164,8 +173,28 @@ alternative_endif
 	.endm
 
 	.macro	get_thread_info, rd
-	mov	\rd, sp
-	and	\rd, \rd, #~(THREAD_SIZE - 1)	// top of stack
+	mrs	\rd, sp_el0
+	.endm
+
+	.macro	irq_stack_entry
+	adr_l	x19, irq_stacks
+	mrs	x20, tpidr_el1
+	add	x20, x19, x20
+	mov	x23, sp
+	and	x23, x23, #~(IRQ_STACK_SIZE - 1)
+	cmp	x20, x23			// check irq re-entrance
+	mov	x19, sp
+	mov	x23, #IRQ_STACK_START_SP
+	add	x23, x20, x23			// x23 = top of irq stack
+	csel	x23, x19, x23, eq
+	mov	sp, x23
+	.endm
+
+	/*
+	 * x19 is preserved between irq_stack_entry and irq_stack_exit.
+	 */
+	.macro	irq_stack_exit
+	mov	sp, x19
 	.endm
 
 /*
@@ -183,10 +212,11 @@ tsk	.req	x28		// current thread_info
  * Interrupt handling.
  */
 	.macro	irq_handler
-	adrp	x1, handle_arch_irq
-	ldr	x1, [x1, #:lo12:handle_arch_irq]
+	ldr_l	x1, handle_arch_irq
 	mov	x0, sp
+	irq_stack_entry
 	blr	x1
+	irq_stack_exit
 	.endm
 
 	.text
@@ -599,6 +629,8 @@ ENTRY(cpu_switch_to)
 	ldp	x29, x9, [x8], #16
 	ldr	lr, [x8]
 	mov	sp, x9
+	and	x9, x9, #~(THREAD_SIZE - 1)
+	msr	sp_el0, x9
 	ret
 ENDPROC(cpu_switch_to)
 
diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
index 514c1cc..353376e 100644
--- a/arch/arm64/kernel/head.S
+++ b/arch/arm64/kernel/head.S
@@ -424,6 +424,9 @@ __mmap_switched:
 	b	1b
 2:
 	adr_l	sp, initial_sp, x4
+	mov	x4, sp
+	and	x4, x4, #~(THREAD_SIZE - 1)
+	msr	sp_el0, x4			// Save thread_info
 	str_l	x21, __fdt_pointer, x5		// Save FDT pointer
 	str_l	x24, memstart_addr, x6		// Save PHYS_OFFSET
 	mov	x29, #0
@@ -604,6 +607,8 @@ ENDPROC(secondary_startup)
 ENTRY(__secondary_switched)
 	ldr	x0, [x21]			// get secondary_data.stack
 	mov	sp, x0
+	and	x0, x0, #~(THREAD_SIZE - 1)
+	msr	sp_el0, x0			// save thread_info
 	mov	x29, #0
 	b	secondary_start_kernel
 ENDPROC(__secondary_switched)
diff --git a/arch/arm64/kernel/irq.c b/arch/arm64/kernel/irq.c
index 9f17ec0..943d106 100644
--- a/arch/arm64/kernel/irq.c
+++ b/arch/arm64/kernel/irq.c
@@ -30,6 +30,8 @@
 
 unsigned long irq_err_count;
 
+DEFINE_PER_CPU(char [IRQ_STACK_SIZE], irq_stacks) __aligned(IRQ_STACK_SIZE);
+
 int arch_show_interrupts(struct seq_file *p, int prec)
 {
 	show_ipi_list(p, prec);
diff --git a/arch/arm64/kernel/sleep.S b/arch/arm64/kernel/sleep.S
index f586f7c..e33fe33 100644
--- a/arch/arm64/kernel/sleep.S
+++ b/arch/arm64/kernel/sleep.S
@@ -173,6 +173,9 @@ ENTRY(cpu_resume)
 	/* load physical address of identity map page table in x1 */
 	adrp	x1, idmap_pg_dir
 	mov	sp, x2
+	/* save thread_info */
+	and	x2, x2, #~(THREAD_SIZE - 1)
+	msr	sp_el0, x2
 	/*
 	 * cpu_do_resume expects x0 to contain context physical address
 	 * pointer and x1 to contain physical address of 1:1 page tables
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index 2bbdc0e..4908923 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -91,8 +91,8 @@ int __cpu_up(unsigned int cpu, struct task_struct *idle)
 	int ret;
 
 	/*
-	 * We need to tell the secondary core where to find its stack and the
-	 * page tables.
+	 * We need to tell the secondary core where to find its process stack
+	 * and the page tables.
 	 */
 	secondary_data.stack = task_stack_page(idle) + THREAD_START_SP;
 	__flush_dcache_area(&secondary_data, sizeof(secondary_data));
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

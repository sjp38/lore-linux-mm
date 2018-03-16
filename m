Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A28B06B0028
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:30:05 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y145so1221966wmd.4
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:30:05 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id p51si571943edc.208.2018.03.16.12.30.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:30:03 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 07/35] x86/entry/32: Enter the kernel via trampoline stack
Date: Fri, 16 Mar 2018 20:29:25 +0100
Message-Id: <1521228593-3820-8-git-send-email-joro@8bytes.org>
In-Reply-To: <1521228593-3820-1-git-send-email-joro@8bytes.org>
References: <1521228593-3820-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Use the entry-stack as a trampoline to enter the kernel. The
entry-stack is already in the cpu_entry_area and will be
mapped to userspace when PTI is enabled.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S        | 136 +++++++++++++++++++++++++++++++--------
 arch/x86/include/asm/switch_to.h |   6 +-
 arch/x86/kernel/asm-offsets.c    |   1 +
 arch/x86/kernel/cpu/common.c     |   5 +-
 arch/x86/kernel/process.c        |   2 -
 arch/x86/kernel/process_32.c     |  10 +--
 6 files changed, 121 insertions(+), 39 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 9bd7718..88aefb9 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -154,25 +154,36 @@
 
 #endif /* CONFIG_X86_32_LAZY_GS */
 
-.macro SAVE_ALL pt_regs_ax=%eax
+.macro SAVE_ALL pt_regs_ax=%eax switch_stacks=0
 	cld
+	/* Push segment registers and %eax */
 	PUSH_GS
 	pushl	%fs
 	pushl	%es
 	pushl	%ds
 	pushl	\pt_regs_ax
+
+	/* Load kernel segments */
+	movl	$(__USER_DS), %eax
+	movl	%eax, %ds
+	movl	%eax, %es
+	movl	$(__KERNEL_PERCPU), %eax
+	movl	%eax, %fs
+	SET_KERNEL_GS %eax
+
+	/* Push integer registers and complete PT_REGS */
 	pushl	%ebp
 	pushl	%edi
 	pushl	%esi
 	pushl	%edx
 	pushl	%ecx
 	pushl	%ebx
-	movl	$(__USER_DS), %edx
-	movl	%edx, %ds
-	movl	%edx, %es
-	movl	$(__KERNEL_PERCPU), %edx
-	movl	%edx, %fs
-	SET_KERNEL_GS %edx
+
+	/* Switch to kernel stack if necessary */
+.if \switch_stacks > 0
+	SWITCH_TO_KERNEL_STACK
+.endif
+
 .endm
 
 /*
@@ -269,6 +280,72 @@
 .Lend_\@:
 #endif /* CONFIG_X86_ESPFIX32 */
 .endm
+
+
+/*
+ * Called with pt_regs fully populated and kernel segments loaded,
+ * so we can access PER_CPU and use the integer registers.
+ *
+ * We need to be very careful here with the %esp switch, because an NMI
+ * can happen everywhere. If the NMI handler finds itself on the
+ * entry-stack, it will overwrite the task-stack and everything we
+ * copied there. So allocate the stack-frame on the task-stack and
+ * switch to it before we do any copying.
+ */
+.macro SWITCH_TO_KERNEL_STACK
+
+	ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
+
+	/* Are we on the entry stack? Bail out if not! */
+	movl	PER_CPU_VAR(cpu_entry_area), %edi
+	addl	$CPU_ENTRY_AREA_entry_stack, %edi
+	cmpl	%esp, %edi
+	jae	.Lend_\@
+
+	/* Load stack pointer into %esi and %edi */
+	movl	%esp, %esi
+	movl	%esi, %edi
+
+	/* Move %edi to the top of the entry stack */
+	andl	$(MASK_entry_stack), %edi
+	addl	$(SIZEOF_entry_stack), %edi
+
+	/* Load top of task-stack into %edi */
+	movl	TSS_entry_stack(%edi), %edi
+
+	/* Bytes to copy */
+	movl	$PTREGS_SIZE, %ecx
+
+#ifdef CONFIG_VM86
+	testl	$X86_EFLAGS_VM, PT_EFLAGS(%esi)
+	jz	.Lcopy_pt_regs_\@
+
+	/*
+	 * Stack-frame contains 4 additional segment registers when
+	 * coming from VM86 mode
+	 */
+	addl	$(4 * 4), %ecx
+
+.Lcopy_pt_regs_\@:
+#endif
+
+	/* Allocate frame on task-stack */
+	subl	%ecx, %edi
+
+	/* Switch to task-stack */
+	movl	%edi, %esp
+
+	/*
+	 * We are now on the task-stack and can safely copy over the
+	 * stack-frame
+	 */
+	shrl	$2, %ecx
+	cld
+	rep movsl
+
+.Lend_\@:
+.endm
+
 /*
  * %eax: prev task
  * %edx: next task
@@ -462,6 +539,7 @@ ENTRY(xen_sysenter_target)
  */
 ENTRY(entry_SYSENTER_32)
 	movl	TSS_entry_stack(%esp), %esp
+
 .Lsysenter_past_esp:
 	pushl	$__USER_DS		/* pt_regs->ss */
 	pushl	%ebp			/* pt_regs->sp (stashed in bp) */
@@ -470,7 +548,7 @@ ENTRY(entry_SYSENTER_32)
 	pushl	$__USER_CS		/* pt_regs->cs */
 	pushl	$0			/* pt_regs->ip = 0 (placeholder) */
 	pushl	%eax			/* pt_regs->orig_ax */
-	SAVE_ALL pt_regs_ax=$-ENOSYS	/* save rest */
+	SAVE_ALL pt_regs_ax=$-ENOSYS	/* save rest, stack already switched */
 
 	/*
 	 * SYSENTER doesn't filter flags, so we need to clear NT, AC
@@ -581,7 +659,8 @@ ENDPROC(entry_SYSENTER_32)
 ENTRY(entry_INT80_32)
 	ASM_CLAC
 	pushl	%eax			/* pt_regs->orig_ax */
-	SAVE_ALL pt_regs_ax=$-ENOSYS	/* save rest */
+
+	SAVE_ALL pt_regs_ax=$-ENOSYS switch_stacks=1	/* save rest */
 
 	/*
 	 * User mode is traced as though IRQs are on, and the interrupt gate
@@ -673,7 +752,8 @@ END(irq_entries_start)
 common_interrupt:
 	ASM_CLAC
 	addl	$-0x80, (%esp)			/* Adjust vector into the [-256, -1] range */
-	SAVE_ALL
+
+	SAVE_ALL switch_stacks=1
 	ENCODE_FRAME_POINTER
 	TRACE_IRQS_OFF
 	movl	%esp, %eax
@@ -681,16 +761,16 @@ common_interrupt:
 	jmp	ret_from_intr
 ENDPROC(common_interrupt)
 
-#define BUILD_INTERRUPT3(name, nr, fn)	\
-ENTRY(name)				\
-	ASM_CLAC;			\
-	pushl	$~(nr);			\
-	SAVE_ALL;			\
-	ENCODE_FRAME_POINTER;		\
-	TRACE_IRQS_OFF			\
-	movl	%esp, %eax;		\
-	call	fn;			\
-	jmp	ret_from_intr;		\
+#define BUILD_INTERRUPT3(name, nr, fn)			\
+ENTRY(name)						\
+	ASM_CLAC;					\
+	pushl	$~(nr);					\
+	SAVE_ALL switch_stacks=1;			\
+	ENCODE_FRAME_POINTER;				\
+	TRACE_IRQS_OFF					\
+	movl	%esp, %eax;				\
+	call	fn;					\
+	jmp	ret_from_intr;				\
 ENDPROC(name)
 
 #define BUILD_INTERRUPT(name, nr)		\
@@ -916,16 +996,20 @@ common_exception:
 	pushl	%es
 	pushl	%ds
 	pushl	%eax
+	movl	$(__USER_DS), %eax
+	movl	%eax, %ds
+	movl	%eax, %es
+	movl	$(__KERNEL_PERCPU), %eax
+	movl	%eax, %fs
 	pushl	%ebp
 	pushl	%edi
 	pushl	%esi
 	pushl	%edx
 	pushl	%ecx
 	pushl	%ebx
+	SWITCH_TO_KERNEL_STACK
 	ENCODE_FRAME_POINTER
 	cld
-	movl	$(__KERNEL_PERCPU), %ecx
-	movl	%ecx, %fs
 	UNWIND_ESPFIX_STACK
 	GS_TO_REG %ecx
 	movl	PT_GS(%esp), %edi		# get the function address
@@ -933,9 +1017,6 @@ common_exception:
 	movl	$-1, PT_ORIG_EAX(%esp)		# no syscall to restart
 	REG_TO_PTGS %ecx
 	SET_KERNEL_GS %ecx
-	movl	$(__USER_DS), %ecx
-	movl	%ecx, %ds
-	movl	%ecx, %es
 	TRACE_IRQS_OFF
 	movl	%esp, %eax			# pt_regs pointer
 	CALL_NOSPEC %edi
@@ -954,6 +1035,7 @@ ENTRY(debug)
 	 */
 	ASM_CLAC
 	pushl	$-1				# mark this as an int
+
 	SAVE_ALL
 	ENCODE_FRAME_POINTER
 	xorl	%edx, %edx			# error code 0
@@ -989,6 +1071,7 @@ END(debug)
  */
 ENTRY(nmi)
 	ASM_CLAC
+
 #ifdef CONFIG_X86_ESPFIX32
 	pushl	%eax
 	movl	%ss, %eax
@@ -1056,7 +1139,8 @@ END(nmi)
 ENTRY(int3)
 	ASM_CLAC
 	pushl	$-1				# mark this as an int
-	SAVE_ALL
+
+	SAVE_ALL switch_stacks=1
 	ENCODE_FRAME_POINTER
 	TRACE_IRQS_OFF
 	xorl	%edx, %edx			# zero error code
diff --git a/arch/x86/include/asm/switch_to.h b/arch/x86/include/asm/switch_to.h
index eb5f799..20e5f7ab 100644
--- a/arch/x86/include/asm/switch_to.h
+++ b/arch/x86/include/asm/switch_to.h
@@ -89,13 +89,9 @@ static inline void refresh_sysenter_cs(struct thread_struct *thread)
 /* This is used when switching tasks or entering/exiting vm86 mode. */
 static inline void update_sp0(struct task_struct *task)
 {
-	/* On x86_64, sp0 always points to the entry trampoline stack, which is constant: */
-#ifdef CONFIG_X86_32
-	load_sp0(task->thread.sp0);
-#else
+	/* sp0 always points to the entry trampoline stack, which is constant: */
 	if (static_cpu_has(X86_FEATURE_XENPV))
 		load_sp0(task_top_of_stack(task));
-#endif
 }
 
 #endif /* _ASM_X86_SWITCH_TO_H */
diff --git a/arch/x86/kernel/asm-offsets.c b/arch/x86/kernel/asm-offsets.c
index 232152c..86f06e8 100644
--- a/arch/x86/kernel/asm-offsets.c
+++ b/arch/x86/kernel/asm-offsets.c
@@ -103,6 +103,7 @@ void common(void) {
 	OFFSET(CPU_ENTRY_AREA_entry_trampoline, cpu_entry_area, entry_trampoline);
 	OFFSET(CPU_ENTRY_AREA_entry_stack, cpu_entry_area, entry_stack_page);
 	DEFINE(SIZEOF_entry_stack, sizeof(struct entry_stack));
+	DEFINE(MASK_entry_stack, (~(sizeof(struct entry_stack) - 1)));
 
 	/* Offset for sp0 and sp1 into the tss_struct */
 	OFFSET(TSS_sp0, tss_struct, x86_tss.sp0);
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index d63f4b57..a0ed348 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1709,11 +1709,12 @@ void cpu_init(void)
 	enter_lazy_tlb(&init_mm, curr);
 
 	/*
-	 * Initialize the TSS.  Don't bother initializing sp0, as the initial
-	 * task never enters user mode.
+	 * Initialize the TSS.  sp0 points to the entry trampoline stack
+	 * regardless of what task is running.
 	 */
 	set_tss_desc(cpu, &get_cpu_entry_area(cpu)->tss.x86_tss);
 	load_TR_desc();
+	load_sp0((unsigned long)(cpu_entry_stack(cpu) + 1));
 
 	load_mm_ldt(&init_mm);
 
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index cb368c2..7fab4fa 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -57,14 +57,12 @@ __visible DEFINE_PER_CPU_PAGE_ALIGNED(struct tss_struct, cpu_tss_rw) = {
 		 */
 		.sp0 = (1UL << (BITS_PER_LONG-1)) + 1,
 
-#ifdef CONFIG_X86_64
 		/*
 		 * .sp1 is cpu_current_top_of_stack.  The init task never
 		 * runs user code, but cpu_current_top_of_stack should still
 		 * be well defined before the first context switch.
 		 */
 		.sp1 = TOP_OF_INIT_STACK,
-#endif
 
 #ifdef CONFIG_X86_32
 		.ss0 = __KERNEL_DS,
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index 097d36a..3f3a8c6 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -289,10 +289,12 @@ __switch_to(struct task_struct *prev_p, struct task_struct *next_p)
 	 */
 	update_sp0(next_p);
 	refresh_sysenter_cs(next);
-	this_cpu_write(cpu_current_top_of_stack,
-		       (unsigned long)task_stack_page(next_p) +
-		       THREAD_SIZE);
-	/* SYSENTER reads the task-stack from tss.sp1 */
+	this_cpu_write(cpu_current_top_of_stack, task_top_of_stack(next_p));
+	/*
+	 * TODO: Find a way to let cpu_current_top_of_stack point to
+	 * cpu_tss_rw.x86_tss.sp1. Doing so now results in stack corruption with
+	 * iret exceptions.
+	 */
 	this_cpu_write(cpu_tss_rw.x86_tss.sp1, next_p->thread.sp0);
 
 	/*
-- 
2.7.4

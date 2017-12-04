Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 12CD16B0266
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:51:52 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v184so5280241wmf.1
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:51:52 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id x5si10170093wrd.29.2017.12.04.08.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:51:50 -0800 (PST)
Message-Id: <20171204150607.230196179@linutronix.de>
Date: Mon, 04 Dec 2017 15:07:35 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 29/60] x86/mm/kpti: Prepare the x86/entry assembly code for
 entry/exit CR3 switching
References: <20171204140706.296109558@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-mm-kpti--Prepare_the_x86-entry_assembly_code_for_entry-exit_CR3_switching.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@suse.de>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, richard.fellner@student.tugraz.at, michael.schwarz@iaik.tugraz.at

From: Dave Hansen <dave.hansen@linux.intel.com>

KERNEL_PAGE_TABLE_ISOLATION needs to switch to a different CR3 value when
it enters the kernel and switch back when it exits.  This essentially needs
to be done before leaving assembly code.

This is extra challenging because the switching context is tricky: the
registers that can be clobbered can vary.  It is also hard to store things
on the stack because there is an established ABI (ptregs) or the stack is
entirely unsafe to use.

Establish a set of macros that allow changing to the user and kernel CR3
values.

Interactions with SWAPGS:
Previous versions of the KERNEL_PAGE_TABLE_ISOLATION code relied on having
per-CPU scratch space to save/restore a register that can be used for the
CR3 MOV.  The %GS register is used to index into our per-CPU space, so
SWAPGS *had* to be done before the CR3 switch.  That scratch space is gone
now, but the semantic that SWAPGS must be done before the CR3 MOV is
retained.  This is good to keep because it is not that hard to do and it
allows to do things like add per-CPU debugging information.

What this does in the NMI code is worth pointing out.  NMIs can interrupt
*any* context and they can also be nested with NMIs interrupting other
NMIs.  The comments below ".Lnmi_from_kernel" explain the format of the
stack during this situation.  Changing the format of this stack is hard.
Instead of storing the old CR3 value on the stack, this depends on the
*regular* register save/restore mechanism and then uses %r14 to keep CR3
during the NMI.  It is callee-saved and will not be clobbered by the C NMI
handlers that get called.

[ peterz: ESPFIX optimization ]

Based-on-code-from: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: keescook@google.com
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: moritz.lipp@iaik.tugraz.at
Cc: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: hughd@google.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: richard.fellner@student.tugraz.at
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: michael.schwarz@iaik.tugraz.at
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Link: https://lkml.kernel.org/r/20171123003442.2D047A7D@viggo.jf.intel.com

---
 arch/x86/entry/calling.h         |   66 +++++++++++++++++++++++++++++++++++++++
 arch/x86/entry/entry_64.S        |   45 +++++++++++++++++++++++---
 arch/x86/entry/entry_64_compat.S |   24 +++++++++++++-
 3 files changed, 128 insertions(+), 7 deletions(-)

--- a/arch/x86/entry/calling.h
+++ b/arch/x86/entry/calling.h
@@ -1,6 +1,8 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 #include <linux/jump_label.h>
 #include <asm/unwind_hints.h>
+#include <asm/cpufeatures.h>
+#include <asm/page_types.h>
 
 /*
 
@@ -187,6 +189,70 @@ For 32-bit we have the following convent
 #endif
 .endm
 
+#ifdef CONFIG_KERNEL_PAGE_TABLE_ISOLATION
+
+/* KERNEL_PAGE_TABLE_ISOLATION PGDs are 8k.  Flip bit 12 to switch between the two halves: */
+#define KPTI_SWITCH_MASK (1<<PAGE_SHIFT)
+
+.macro ADJUST_KERNEL_CR3 reg:req
+	/* Clear "KERNEL_PAGE_TABLE_ISOLATION bit", point CR3 at kernel pagetables: */
+	andq	$(~KPTI_SWITCH_MASK), \reg
+.endm
+
+.macro ADJUST_USER_CR3 reg:req
+	/* Move CR3 up a page to the user page tables: */
+	orq	$(KPTI_SWITCH_MASK), \reg
+.endm
+
+.macro SWITCH_TO_KERNEL_CR3 scratch_reg:req
+	mov	%cr3, \scratch_reg
+	ADJUST_KERNEL_CR3 \scratch_reg
+	mov	\scratch_reg, %cr3
+.endm
+
+.macro SWITCH_TO_USER_CR3 scratch_reg:req
+	mov	%cr3, \scratch_reg
+	ADJUST_USER_CR3 \scratch_reg
+	mov	\scratch_reg, %cr3
+.endm
+
+.macro SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg:req save_reg:req
+	movq	%cr3, \scratch_reg
+	movq	\scratch_reg, \save_reg
+	/*
+	 * Is the switch bit zero?  This means the address is
+	 * up in real KERNEL_PAGE_TABLE_ISOLATION patches in a moment.
+	 */
+	testq	$(KPTI_SWITCH_MASK), \scratch_reg
+	jz	.Ldone_\@
+
+	ADJUST_KERNEL_CR3 \scratch_reg
+	movq	\scratch_reg, %cr3
+
+.Ldone_\@:
+.endm
+
+.macro RESTORE_CR3 save_reg:req
+	/*
+	 * The CR3 write could be avoided when not changing its value,
+	 * but would require a CR3 read *and* a scratch register.
+	 */
+	movq	\save_reg, %cr3
+.endm
+
+#else /* CONFIG_KERNEL_PAGE_TABLE_ISOLATION=n: */
+
+.macro SWITCH_TO_KERNEL_CR3 scratch_reg:req
+.endm
+.macro SWITCH_TO_USER_CR3 scratch_reg:req
+.endm
+.macro SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg:req save_reg:req
+.endm
+.macro RESTORE_CR3 save_reg:req
+.endm
+
+#endif
+
 #endif /* CONFIG_X86_64 */
 
 /*
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -168,6 +168,9 @@ ENTRY(entry_SYSCALL_64_trampoline)
 	/* Stash the user RSP. */
 	movq	%rsp, RSP_SCRATCH
 
+	/* Note: using %rsp as a scratch reg. */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp
+
 	/* Load the top of the task stack into RSP */
 	movq	CPU_ENTRY_AREA_tss + TSS_sp1 + CPU_ENTRY_AREA, %rsp
 
@@ -208,6 +211,10 @@ ENTRY(entry_SYSCALL_64)
 
 	swapgs
 	movq	%rsp, PER_CPU_VAR(rsp_scratch)
+	/*
+	 * This path is not taken when KERNEL_PAGE_TABLE_ISOLATION is disabled so it
+	 * is not required to switch CR3.
+	 */
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 
 	/* Construct struct pt_regs on stack */
@@ -403,6 +410,7 @@ GLOBAL(entry_SYSCALL_64_after_hwframe)
 	 * We are on the trampoline stack.  All regs except RDI are live.
 	 * We can do future final exit work right here.
 	 */
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
 
 	popq	%rdi
 	popq	%rsp
@@ -740,6 +748,8 @@ GLOBAL(swapgs_restore_regs_and_return_to
 	 * We can do future final exit work right here.
 	 */
 
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
+
 	/* Restore RDI. */
 	popq	%rdi
 	SWAPGS
@@ -822,7 +832,9 @@ ENTRY(native_iret)
 	 */
 
 	pushq	%rdi				/* Stash user RDI */
-	SWAPGS
+	SWAPGS					/* to kernel GS */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi	/* to kernel CR3 */
+
 	movq	PER_CPU_VAR(espfix_waddr), %rdi
 	movq	%rax, (0*8)(%rdi)		/* user RAX */
 	movq	(1*8)(%rsp), %rax		/* user RIP */
@@ -838,7 +850,6 @@ ENTRY(native_iret)
 	/* Now RAX == RSP. */
 
 	andl	$0xffff0000, %eax		/* RAX = (RSP & 0xffff0000) */
-	popq	%rdi				/* Restore user RDI */
 
 	/*
 	 * espfix_stack[31:16] == 0.  The page tables are set up such that
@@ -849,7 +860,11 @@ ENTRY(native_iret)
 	 * still points to an RO alias of the ESPFIX stack.
 	 */
 	orq	PER_CPU_VAR(espfix_stack), %rax
-	SWAPGS
+
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi	/* to user CR3 */
+	SWAPGS					/* to user GS */
+	popq	%rdi				/* Restore user RDI */
+
 	movq	%rax, %rsp
 	UNWIND_HINT_IRET_REGS offset=8
 
@@ -949,6 +964,8 @@ ENTRY(switch_to_thread_stack)
 	UNWIND_HINT_FUNC
 
 	pushq	%rdi
+	/* Need to switch before accessing the thread stack. */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
 	movq	%rsp, %rdi
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 	UNWIND_HINT sp_offset=16 sp_reg=ORC_REG_DI
@@ -1250,7 +1267,11 @@ ENTRY(paranoid_entry)
 	js	1f				/* negative -> in kernel */
 	SWAPGS
 	xorl	%ebx, %ebx
-1:	ret
+
+1:
+	SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg=%rax save_reg=%r14
+
+	ret
 END(paranoid_entry)
 
 /*
@@ -1272,6 +1293,7 @@ ENTRY(paranoid_exit)
 	testl	%ebx, %ebx			/* swapgs needed? */
 	jnz	.Lparanoid_exit_no_swapgs
 	TRACE_IRQS_IRETQ
+	RESTORE_CR3	save_reg=%r14
 	SWAPGS_UNSAFE_STACK
 	jmp	.Lparanoid_exit_restore
 .Lparanoid_exit_no_swapgs:
@@ -1299,6 +1321,8 @@ ENTRY(error_entry)
 	 * from user mode due to an IRET fault.
 	 */
 	SWAPGS
+	/* We have user CR3.  Change to kernel CR3. */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rax
 
 .Lerror_entry_from_usermode_after_swapgs:
 	/* Put us onto the real thread stack. */
@@ -1345,6 +1369,7 @@ ENTRY(error_entry)
 	 * .Lgs_change's error handler with kernel gsbase.
 	 */
 	SWAPGS
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rax
 	jmp .Lerror_entry_done
 
 .Lbstep_iret:
@@ -1354,10 +1379,11 @@ ENTRY(error_entry)
 
 .Lerror_bad_iret:
 	/*
-	 * We came from an IRET to user mode, so we have user gsbase.
-	 * Switch to kernel gsbase:
+	 * We came from an IRET to user mode, so we have user
+	 * gsbase and CR3.  Switch to kernel gsbase and CR3:
 	 */
 	SWAPGS
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rax
 
 	/*
 	 * Pretend that the exception came from user mode: set up pt_regs
@@ -1389,6 +1415,10 @@ END(error_exit)
 /*
  * Runs on exception stack.  Xen PV does not go through this path at all,
  * so we can use real assembly here.
+ *
+ * Registers:
+ *	%r14: Used to save/restore the CR3 of the interrupted context
+ *	      when KERNEL_PAGE_TABLE_ISOLATION is in use.  Do not clobber.
  */
 ENTRY(nmi)
 	UNWIND_HINT_IRET_REGS
@@ -1452,6 +1482,7 @@ ENTRY(nmi)
 
 	swapgs
 	cld
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdx
 	movq	%rsp, %rdx
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 	UNWIND_HINT_IRET_REGS base=%rdx offset=8
@@ -1704,6 +1735,8 @@ ENTRY(nmi)
 	movq	$-1, %rsi
 	call	do_nmi
 
+	RESTORE_CR3 save_reg=%r14
+
 	testl	%ebx, %ebx			/* swapgs needed? */
 	jnz	nmi_restore
 nmi_swapgs:
--- a/arch/x86/entry/entry_64_compat.S
+++ b/arch/x86/entry/entry_64_compat.S
@@ -49,6 +49,10 @@
 ENTRY(entry_SYSENTER_compat)
 	/* Interrupts are off on entry. */
 	SWAPGS
+
+	/* We are about to clobber %rsp anyway, clobbering here is OK */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp
+
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 
 	/*
@@ -216,6 +220,12 @@ GLOBAL(entry_SYSCALL_compat_after_hwfram
 	pushq   $0			/* pt_regs->r15 = 0 */
 
 	/*
+	 * We just saved %rdi so it is safe to clobber.  It is not
+	 * preserved during the C calls inside TRACE_IRQS_OFF anyway.
+	 */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
+
+	/*
 	 * User mode is traced as though IRQs are on, and SYSENTER
 	 * turned them off.
 	 */
@@ -256,10 +266,22 @@ GLOBAL(entry_SYSCALL_compat_after_hwfram
 	 * when the system call started, which is already known to user
 	 * code.  We zero R8-R10 to avoid info leaks.
          */
+	movq	RSP-ORIG_RAX(%rsp), %rsp
+
+	/*
+	 * The original userspace %rsp (RSP-ORIG_RAX(%rsp)) is stored
+	 * on the process stack which is not mapped to userspace and
+	 * not readable after we SWITCH_TO_USER_CR3.  Delay the CR3
+	 * switch until after after the last reference to the process
+	 * stack.
+	 *
+	 * %r8 is zeroed before the sysret, thus safe to clobber.
+	 */
+	SWITCH_TO_USER_CR3 scratch_reg=%r8
+
 	xorq	%r8, %r8
 	xorq	%r9, %r9
 	xorq	%r10, %r10
-	movq	RSP-ORIG_RAX(%rsp), %rsp
 	swapgs
 	sysretl
 END(entry_SYSCALL_compat)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

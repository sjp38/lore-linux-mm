Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2F956B0268
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:35:50 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 190so17653840pgh.16
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:35:50 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b188si16111070pfb.7.2017.11.22.16.35.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 16:35:49 -0800 (PST)
Subject: [PATCH 02/23] x86, kaiser: prepare assembly for entry/exit CR3 switching
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 22 Nov 2017 16:34:42 -0800
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Message-Id: <20171123003442.2D047A7D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

This is largely code from Andy Lutomirski.  I fixed a few bugs
in it, and added a few SWITCH_TO_* spots.

KAISER needs to switch to a different CR3 value when it enters
the kernel and switch back when it exits.  This essentially
needs to be done before leaving assembly code.

This is extra challenging because the switching context is
tricky: the registers that can be clobbered can vary.  It is also
hard to store things on the stack because there is an established
ABI (ptregs) or the stack is entirely unsafe to use.

This patch establishes a set of macros that allow changing to
the user and kernel CR3 values.

Interactions with SWAPGS: previous versions of the KAISER code
relied on having per-cpu scratch space to save/restore a register
that can be used for the CR3 MOV.  The %GS register is used to
index into our per-cpu space, so SWAPGS *had* to be done before
the CR3 switch.  That scratch space is gone now, but the semantic
that SWAPGS must be done before the CR3 MOV is retained.  This is
good to keep because it is not that hard to do and it allows us
to do things like add per-cpu debugging information to help us
figure out what goes wrong sometimes.

What this does in the NMI code is worth pointing out.  NMIs
can interrupt *any* context and they can also be nested with
NMIs interrupting other NMIs.  The comments below
".Lnmi_from_kernel" explain the format of the stack during this
situation.  Changing the format of this stack is not a fun
exercise: I tried.  Instead of storing the old CR3 value on the
stack, this patch depend on the *regular* register save/restore
mechanism and then uses %r14 to keep CR3 during the NMI.  It is
callee-saved and will not be clobbered by the C NMI handlers that
get called.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/entry/calling.h         |   65 +++++++++++++++++++++++++++++++++++++
 b/arch/x86/entry/entry_64.S        |   47 +++++++++++++++++++++++---
 b/arch/x86/entry/entry_64_compat.S |   32 +++++++++++++++++-
 3 files changed, 138 insertions(+), 6 deletions(-)

diff -puN arch/x86/entry/calling.h~kaiser-luto-base-cr3-work arch/x86/entry/calling.h
--- a/arch/x86/entry/calling.h~kaiser-luto-base-cr3-work	2017-11-22 15:45:44.745619750 -0800
+++ b/arch/x86/entry/calling.h	2017-11-22 15:45:44.753619750 -0800
@@ -1,6 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 #include <linux/jump_label.h>
 #include <asm/unwind_hints.h>
+#include <asm/cpufeatures.h>
 
 /*
 
@@ -187,6 +188,70 @@ For 32-bit we have the following convent
 #endif
 .endm
 
+#ifdef CONFIG_KAISER
+
+/* KAISER PGDs are 8k.  Flip bit 12 to switch between the two halves: */
+#define KAISER_SWITCH_MASK (1<<PAGE_SHIFT)
+
+.macro ADJUST_KERNEL_CR3 reg:req
+	/* Clear "KAISER bit", point CR3 at kernel pagetables: */
+	andq	$(~KAISER_SWITCH_MASK), \reg
+.endm
+
+.macro ADJUST_USER_CR3 reg:req
+	/* Move CR3 up a page to the user page tables: */
+	orq	$(KAISER_SWITCH_MASK), \reg
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
+	movq	%cr3, %r\scratch_reg
+	movq	%r\scratch_reg, \save_reg
+	/*
+	 * Is the switch bit zero?  This means the address is
+	 * up in real KAISER patches in a moment.
+	 */
+	testq	$(KAISER_SWITCH_MASK), %r\scratch_reg
+	jz	.Ldone_\@
+
+	ADJUST_KERNEL_CR3 %r\scratch_reg
+	movq	%r\scratch_reg, %cr3
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
+#else /* CONFIG_KAISER=n: */
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
diff -puN arch/x86/entry/entry_64_compat.S~kaiser-luto-base-cr3-work arch/x86/entry/entry_64_compat.S
--- a/arch/x86/entry/entry_64_compat.S~kaiser-luto-base-cr3-work	2017-11-22 15:45:44.747619750 -0800
+++ b/arch/x86/entry/entry_64_compat.S	2017-11-22 15:45:44.753619750 -0800
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
@@ -256,10 +266,22 @@ sysret32_from_system_call:
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
@@ -297,6 +319,14 @@ ENTRY(entry_INT80_compat)
 	ASM_CLAC			/* Do this early to minimize exposure */
 	SWAPGS
 
+	/*
+	 * Must switch CR3 before thread stack is used.  %r8 itself
+	 * is not saved into pt_regs and is not preserved across
+	 * function calls (like TRACE_IRQS_OFF calls), thus should
+	 * be safe to use.
+	 */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%r8
+
 	subq	$16*8, %rsp
 	call	switch_to_thread_stack
 	addq	$16*8, %rsp
diff -puN arch/x86/entry/entry_64.S~kaiser-luto-base-cr3-work arch/x86/entry/entry_64.S
--- a/arch/x86/entry/entry_64.S~kaiser-luto-base-cr3-work	2017-11-22 15:45:44.749619750 -0800
+++ b/arch/x86/entry/entry_64.S	2017-11-22 15:45:44.754619750 -0800
@@ -164,6 +164,9 @@ ENTRY(entry_SYSCALL_64_trampoline)
 	/* Stash the user RSP. */
 	movq	%rsp, RSP_SCRATCH
 
+	/* Note: using %rsp as a scratch reg. */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp
+
 	/* Load the top of the task stack into RSP */
 	movq	CPU_ENTRY_AREA_tss + TSS_sp1 + CPU_ENTRY_AREA, %rsp
 
@@ -207,9 +210,16 @@ ENTRY(entry_SYSCALL_64)
 
 	swapgs
 	movq	%rsp, PER_CPU_VAR(rsp_scratch)
-	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 
-	TRACE_IRQS_OFF
+	/*
+	 * The kernel CR3 is needed to map the process stack, but we
+	 * need a scratch register to be able to load CR3.  %rsp is
+	 * clobberable right now, so use it as a scratch register.
+	 * %rsp will be look crazy here for a couple instructions.
+	 */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rsp
+
+	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 
 	/* Construct struct pt_regs on stack */
 	pushq	$__USER_DS			/* pt_regs->ss */
@@ -231,6 +241,9 @@ GLOBAL(entry_SYSCALL_64_after_hwframe)
 	sub	$(6*8), %rsp			/* pt_regs->bp, bx, r12-15 not saved */
 	UNWIND_HINT_REGS extra=0
 
+	/* Must wait until we have the kernel CR3 to call C functions: */
+	TRACE_IRQS_OFF
+
 	/*
 	 * If we need to do entry work or if we guess we'll need to do
 	 * exit work, go straight to the slow path.
@@ -402,6 +415,7 @@ syscall_return_via_sysret:
 	 * We are on the trampoline stack.  All regs except RDI are live.
 	 * We can do future final exit work right here.
 	 */
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
 
 	popq	%rdi
 	popq	%rsp
@@ -743,6 +757,8 @@ GLOBAL(swapgs_restore_regs_and_return_to
 	 * We can do future final exit work right here.
 	 */
 
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
+
 	/* Restore RDI. */
 	popq	%rdi
 	SWAPGS
@@ -952,6 +968,10 @@ ENTRY(switch_to_thread_stack)
 	UNWIND_HINT_IRET_REGS offset=17*8
 
 	movq	%rdi, RDI+8(%rsp)
+
+	/* Need to switch before accessing the thread stack. */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
+
 	movq	%rsp, %rdi
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 	UNWIND_HINT_IRET_REGS offset=17*8 base=%rdi
@@ -1252,7 +1272,11 @@ ENTRY(paranoid_entry)
 	js	1f				/* negative -> in kernel */
 	SWAPGS
 	xorl	%ebx, %ebx
-1:	ret
+
+1:
+	SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg=ax save_reg=%r14
+
+	ret
 END(paranoid_entry)
 
 /*
@@ -1274,6 +1298,7 @@ ENTRY(paranoid_exit)
 	testl	%ebx, %ebx			/* swapgs needed? */
 	jnz	.Lparanoid_exit_no_swapgs
 	TRACE_IRQS_IRETQ
+	RESTORE_CR3	%r14
 	SWAPGS_UNSAFE_STACK
 	jmp	.Lparanoid_exit_restore
 .Lparanoid_exit_no_swapgs:
@@ -1302,6 +1327,9 @@ ENTRY(error_entry)
 	 */
 	SWAPGS
 
+	/* We have user CR3.  Change to kernel CR3. */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rax
+
 .Lerror_entry_from_usermode_after_swapgs:
 	/* Put us onto the real thread stack. */
 	leaq	8(%rsp), %rdi			/* pt_regs pointer */
@@ -1346,6 +1374,7 @@ ENTRY(error_entry)
 	 * gsbase and proceed.  We'll fix up the exception and land in
 	 * .Lgs_change's error handler with kernel gsbase.
 	 */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rax
 	SWAPGS
 	jmp .Lerror_entry_done
 
@@ -1356,9 +1385,10 @@ ENTRY(error_entry)
 
 .Lerror_bad_iret:
 	/*
-	 * We came from an IRET to user mode, so we have user gsbase.
-	 * Switch to kernel gsbase:
+	 * We came from an IRET to user mode, so we have user
+	 * gsbase and CR3.  Switch to kernel gsbase and CR3:
 	 */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rax
 	SWAPGS
 
 	/*
@@ -1391,6 +1421,10 @@ END(error_exit)
 /*
  * Runs on exception stack.  Xen PV does not go through this path at all,
  * so we can use real assembly here.
+ *
+ * Registers:
+ *	%r14: Used to save/restore the CR3 of the interrupted context
+ *	      when KAISER is in use.  Do not clobber.
  */
 ENTRY(nmi)
 	UNWIND_HINT_IRET_REGS
@@ -1454,6 +1488,7 @@ ENTRY(nmi)
 
 	swapgs
 	cld
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdx
 	movq	%rsp, %rdx
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 	UNWIND_HINT_IRET_REGS base=%rdx offset=8
@@ -1706,6 +1741,8 @@ end_repeat_nmi:
 	movq	$-1, %rsi
 	call	do_nmi
 
+	RESTORE_CR3 save_reg=%r14
+
 	testl	%ebx, %ebx			/* swapgs needed? */
 	jnz	nmi_restore
 nmi_swapgs:
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

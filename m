Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E32C6440D2B
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:31:26 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 190so5145962pgh.16
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:31:26 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id e3si9388560pgp.779.2017.11.10.11.31.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:31:25 -0800 (PST)
Subject: [PATCH 05/30] x86, kaiser: prepare assembly for entry/exit CR3 switching
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:07 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193107.67B798C3@viggo.jf.intel.com>
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
 b/arch/x86/entry/entry_64.S        |   34 ++++++++++++++++---
 b/arch/x86/entry/entry_64_compat.S |    8 ++++
 3 files changed, 102 insertions(+), 5 deletions(-)

diff -puN arch/x86/entry/calling.h~kaiser-luto-base-cr3-work arch/x86/entry/calling.h
--- a/arch/x86/entry/calling.h~kaiser-luto-base-cr3-work	2017-11-10 11:22:07.191244954 -0800
+++ b/arch/x86/entry/calling.h	2017-11-10 11:22:07.198244954 -0800
@@ -1,5 +1,6 @@
 #include <linux/jump_label.h>
 #include <asm/unwind_hints.h>
+#include <asm/cpufeatures.h>
 
 /*
 
@@ -186,6 +187,70 @@ For 32-bit we have the following convent
 #endif
 .endm
 
+#ifdef CONFIG_KAISER
+
+/* KAISER PGDs are 8k.  We flip bit 12 to switch between the two halves: */
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
+	 * We could avoid the CR3 write if not changing its value,
+	 * but that requires a CR3 read *and* a scratch register.
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
--- a/arch/x86/entry/entry_64_compat.S~kaiser-luto-base-cr3-work	2017-11-10 11:22:07.193244954 -0800
+++ b/arch/x86/entry/entry_64_compat.S	2017-11-10 11:22:07.198244954 -0800
@@ -91,6 +91,9 @@ ENTRY(entry_SYSENTER_compat)
 	pushq   $0			/* pt_regs->r15 = 0 */
 	cld
 
+	/* We just saved all the registers, so safe to clobber %rdi */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
+
 	/*
 	 * SYSENTER doesn't filter flags, so we need to clear NT and AC
 	 * ourselves.  To save a few cycles, we can check whether
@@ -214,6 +217,8 @@ GLOBAL(entry_SYSCALL_compat_after_hwfram
 	pushq   $0			/* pt_regs->r14 = 0 */
 	pushq   $0			/* pt_regs->r15 = 0 */
 
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
+
 	/*
 	 * User mode is traced as though IRQs are on, and SYSENTER
 	 * turned them off.
@@ -240,6 +245,7 @@ sysret32_from_system_call:
 	popq	%rsi			/* pt_regs->si */
 	popq	%rdi			/* pt_regs->di */
 
+	SWITCH_TO_USER_CR3 scratch_reg=%r8
         /*
          * USERGS_SYSRET32 does:
          *  GSBASE = user's GS base
@@ -324,6 +330,8 @@ ENTRY(entry_INT80_compat)
 	pushq   %r15                    /* pt_regs->r15 */
 	cld
 
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%r11
+
 	movq	%rsp, %rdi			/* pt_regs pointer */
 	call	sync_regs
 	movq	%rax, %rsp			/* switch stack */
diff -puN arch/x86/entry/entry_64.S~kaiser-luto-base-cr3-work arch/x86/entry/entry_64.S
--- a/arch/x86/entry/entry_64.S~kaiser-luto-base-cr3-work	2017-11-10 11:22:07.194244954 -0800
+++ b/arch/x86/entry/entry_64.S	2017-11-10 11:22:07.199244954 -0800
@@ -147,8 +147,6 @@ ENTRY(entry_SYSCALL_64)
 	movq	%rsp, PER_CPU_VAR(rsp_scratch)
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 
-	TRACE_IRQS_OFF
-
 	/* Construct struct pt_regs on stack */
 	pushq	$__USER_DS			/* pt_regs->ss */
 	pushq	PER_CPU_VAR(rsp_scratch)	/* pt_regs->sp */
@@ -169,6 +167,13 @@ GLOBAL(entry_SYSCALL_64_after_hwframe)
 	sub	$(6*8), %rsp			/* pt_regs->bp, bx, r12-15 not saved */
 	UNWIND_HINT_REGS extra=0
 
+	/* NB: right here, all regs except r11 are live. */
+
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%r11
+
+	/* Must wait until we have the kernel CR3 to call C functions: */
+	TRACE_IRQS_OFF
+
 	/*
 	 * If we need to do entry work or if we guess we'll need to do
 	 * exit work, go straight to the slow path.
@@ -340,6 +345,7 @@ syscall_return_via_sysret:
 	 * We are on the trampoline stack.  All regs except RDI are live.
 	 * We can do future final exit work right here.
 	 */
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
 
 	popq	%rdi
 	popq	%rsp
@@ -679,6 +685,8 @@ GLOBAL(swapgs_restore_regs_and_return_to
 	 * We can do future final exit work right here.
 	 */
 
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
+
 	/* Restore RDI. */
 	popq	%rdi
 	SWAPGS
@@ -1167,7 +1175,11 @@ ENTRY(paranoid_entry)
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
@@ -1189,6 +1201,7 @@ ENTRY(paranoid_exit)
 	testl	%ebx, %ebx			/* swapgs needed? */
 	jnz	.Lparanoid_exit_no_swapgs
 	TRACE_IRQS_IRETQ
+	RESTORE_CR3	%r14
 	SWAPGS_UNSAFE_STACK
 	jmp	.Lparanoid_exit_restore
 .Lparanoid_exit_no_swapgs:
@@ -1217,6 +1230,9 @@ ENTRY(error_entry)
 	 */
 	SWAPGS
 
+	/* We have user CR3.  Change to kernel CR3. */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rax
+
 .Lerror_entry_from_usermode_after_swapgs:
 	/*
 	 * We need to tell lockdep that IRQs are off.  We can't do this until
@@ -1263,9 +1279,10 @@ ENTRY(error_entry)
 
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
@@ -1298,6 +1315,10 @@ END(error_exit)
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
@@ -1389,6 +1410,7 @@ ENTRY(nmi)
 	UNWIND_HINT_REGS
 	ENCODE_FRAME_POINTER
 
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
 	/*
 	 * At this point we no longer need to worry about stack damage
 	 * due to nesting -- we're on the normal thread stack and we're
@@ -1613,6 +1635,8 @@ end_repeat_nmi:
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

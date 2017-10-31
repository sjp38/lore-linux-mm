Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 411F86B025E
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:31:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id l23so446853pgc.10
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:31:53 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f126si2860108pfg.410.2017.10.31.15.31.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:31:51 -0700 (PDT)
Subject: [PATCH 01/23] x86, kaiser: prepare assembly for entry/exit CR3 switching
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:31:48 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223148.5334003A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


This is largely code from Andy Lutomirski.  I fixed a few bugs
in it, and added a few SWITCH_TO_* spots.

KAISER needs to switch to a different CR3 value when it enters
the kernel and switch back when it exits.  This essentially
needs to be done before we leave assembly code.

This is extra challenging because the context in which we have to
make this switch is tricky: the registers we are allowed to
clobber can vary.  It's also hard to store things on the stack
because there are already things on it with an established ABI
(ptregs) or the stack is unsafe to use at all.

This patch establishes a set of macros that allow changing to
the user and kernel CR3 values, but do not actually switch
CR3.  The code will, however, clobber the registers that it
says it will and also does perform *writes* to CR3.  So, this
patch by itself tests that the registers we are clobbering
and restoring from are OK, and that things like our stack
manipulation are in safe places.

In other words, if you bisect to here, this *does* introduce
changes that can break things.

Interactions with SWAPGS: previous versions of the KAISER code
relied on having per-cpu scratch space so we have a register
to clobber for our CR3 MOV.  The %GS register is what we use
to index into our per-cpu sapce, so SWAPGS *had* to be done
before the CR3 switch.  That scratch space is gone now, but we
still keep the semantic that SWAPGS must be done before the
CR3 MOV.  This is good to keep because it is not that hard to
do and it allows us to do things like add per-cpu debugging
information to help us figure out what goes wrong sometimes.

What this does in the NMI code is worth pointing out.  NMIs
can interrupt *any* context and they can also be nested with
NMIs interrupting other NMIs.  The comments below
".Lnmi_from_kernel" explain the format of the stack that we
have to deal with this situation.  Changing the format of
this stack is not a fun exercise: I tried.  Instead of
storing the old CR3 value on the stack, we depend on the
*regular* register save/restore mechanism and then use %r14
to keep CR3 during the NMI.  It will not be clobbered by the
C NMI handlers that get called.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/entry/calling.h         |   40 +++++++++++++++++++++++++++++++++++++
 b/arch/x86/entry/entry_64.S        |   33 +++++++++++++++++++++++++-----
 b/arch/x86/entry/entry_64_compat.S |   13 ++++++++++++
 3 files changed, 81 insertions(+), 5 deletions(-)

diff -puN arch/x86/entry/calling.h~kaiser-luto-base-cr3-work arch/x86/entry/calling.h
--- a/arch/x86/entry/calling.h~kaiser-luto-base-cr3-work	2017-10-31 15:03:48.105007253 -0700
+++ b/arch/x86/entry/calling.h	2017-10-31 15:03:48.113007631 -0700
@@ -1,5 +1,6 @@
 #include <linux/jump_label.h>
 #include <asm/unwind_hints.h>
+#include <asm/cpufeatures.h>
 
 /*
 
@@ -217,6 +218,45 @@ For 32-bit we have the following convent
 #endif
 .endm
 
+.macro ADJUST_KERNEL_CR3 reg:req
+.endm
+
+.macro ADJUST_USER_CR3 reg:req
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
+	 * Just stick a random bit in here that never gets set.  Fixed
+	 * up in real KAISER patches in a moment.
+	 */
+	bt	$63, %r\scratch_reg
+	jz	.Ldone_\@
+
+	ADJUST_KERNEL_CR3 %r\scratch_reg
+	movq	%r\scratch_reg, %cr3
+
+.Ldone_\@:
+.endm
+
+.macro RESTORE_CR3 save_reg:req
+	/* optimize this */
+	movq	\save_reg, %cr3
+.endm
+
 #endif /* CONFIG_X86_64 */
 
 /*
diff -puN arch/x86/entry/entry_64_compat.S~kaiser-luto-base-cr3-work arch/x86/entry/entry_64_compat.S
--- a/arch/x86/entry/entry_64_compat.S~kaiser-luto-base-cr3-work	2017-10-31 15:03:48.107007348 -0700
+++ b/arch/x86/entry/entry_64_compat.S	2017-10-31 15:03:48.113007631 -0700
@@ -48,8 +48,13 @@
 ENTRY(entry_SYSENTER_compat)
 	/* Interrupts are off on entry. */
 	SWAPGS_UNSAFE_STACK
+
 	movq	PER_CPU_VAR(cpu_current_top_of_stack), %rsp
 
+	pushq	%rdi
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
+	popq	%rdi
+
 	/*
 	 * User tracing code (ptrace or signal handlers) might assume that
 	 * the saved RAX contains a 32-bit number when we're invoking a 32-bit
@@ -91,6 +96,9 @@ ENTRY(entry_SYSENTER_compat)
 	pushq   $0			/* pt_regs->r15 = 0 */
 	cld
 
+	pushq	%rdi
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
+	popq	%rdi
 	/*
 	 * SYSENTER doesn't filter flags, so we need to clear NT and AC
 	 * ourselves.  To save a few cycles, we can check whether
@@ -214,6 +222,8 @@ GLOBAL(entry_SYSCALL_compat_after_hwfram
 	pushq   $0			/* pt_regs->r14 = 0 */
 	pushq   $0			/* pt_regs->r15 = 0 */
 
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
+
 	/*
 	 * User mode is traced as though IRQs are on, and SYSENTER
 	 * turned them off.
@@ -240,6 +250,7 @@ sysret32_from_system_call:
 	popq	%rsi			/* pt_regs->si */
 	popq	%rdi			/* pt_regs->di */
 
+	SWITCH_TO_USER_CR3 scratch_reg=%r8
         /*
          * USERGS_SYSRET32 does:
          *  GSBASE = user's GS base
@@ -324,6 +335,7 @@ ENTRY(entry_INT80_compat)
 	pushq   %r15                    /* pt_regs->r15 */
 	cld
 
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%r11
 	/*
 	 * User mode is traced as though IRQs are on, and the interrupt
 	 * gate turned them off.
@@ -337,6 +349,7 @@ ENTRY(entry_INT80_compat)
 	/* Go back to user mode. */
 	TRACE_IRQS_ON
 	SWAPGS
+	SWITCH_TO_USER_CR3 scratch_reg=%r11
 	jmp	restore_regs_and_iret
 END(entry_INT80_compat)
 
diff -puN arch/x86/entry/entry_64.S~kaiser-luto-base-cr3-work arch/x86/entry/entry_64.S
--- a/arch/x86/entry/entry_64.S~kaiser-luto-base-cr3-work	2017-10-31 15:03:48.109007442 -0700
+++ b/arch/x86/entry/entry_64.S	2017-10-31 15:03:48.115007726 -0700
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
@@ -220,6 +225,7 @@ entry_SYSCALL_64_fastpath:
 	TRACE_IRQS_ON		/* user mode is traced as IRQs on */
 	movq	RIP(%rsp), %rcx
 	movq	EFLAGS(%rsp), %r11
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
 	RESTORE_C_REGS_EXCEPT_RCX_R11
 	movq	RSP(%rsp), %rsp
 	UNWIND_HINT_EMPTY
@@ -313,6 +319,7 @@ return_from_SYSCALL_64:
 	 * perf profiles. Nothing jumps here.
 	 */
 syscall_return_via_sysret:
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
 	/* rcx and r11 are already restored (see code above) */
 	RESTORE_C_REGS_EXCEPT_RCX_R11
 	movq	RSP(%rsp), %rsp
@@ -320,6 +327,7 @@ syscall_return_via_sysret:
 	USERGS_SYSRET64
 
 opportunistic_sysret_failed:
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
 	SWAPGS
 	jmp	restore_c_regs_and_iret
 END(entry_SYSCALL_64)
@@ -422,6 +430,7 @@ ENTRY(ret_from_fork)
 	movq	%rsp, %rdi
 	call	syscall_return_slowpath	/* returns with IRQs disabled */
 	TRACE_IRQS_ON			/* user mode is traced as IRQS on */
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
 	SWAPGS
 	jmp	restore_regs_and_iret
 
@@ -611,6 +620,7 @@ GLOBAL(retint_user)
 	mov	%rsp,%rdi
 	call	prepare_exit_to_usermode
 	TRACE_IRQS_IRETQ
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
 	SWAPGS
 	jmp	restore_regs_and_iret
 
@@ -1091,7 +1101,11 @@ ENTRY(paranoid_entry)
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
@@ -1118,6 +1132,7 @@ ENTRY(paranoid_exit)
 paranoid_exit_no_swapgs:
 	TRACE_IRQS_IRETQ_DEBUG
 paranoid_exit_restore:
+	RESTORE_CR3	%r14
 	RESTORE_EXTRA_REGS
 	RESTORE_C_REGS
 	REMOVE_PT_GPREGS_FROM_STACK 8
@@ -1144,6 +1159,9 @@ ENTRY(error_entry)
 	 */
 	SWAPGS
 
+	/* We have user CR3.  Change to kernel CR3. */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rax
+
 .Lerror_entry_from_usermode_after_swapgs:
 	/*
 	 * We need to tell lockdep that IRQs are off.  We can't do this until
@@ -1190,9 +1208,10 @@ ENTRY(error_entry)
 
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
@@ -1313,6 +1332,7 @@ ENTRY(nmi)
 	UNWIND_HINT_REGS
 	ENCODE_FRAME_POINTER
 
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi
 	/*
 	 * At this point we no longer need to worry about stack damage
 	 * due to nesting -- we're on the normal thread stack and we're
@@ -1328,6 +1348,7 @@ ENTRY(nmi)
 	 * work, because we don't want to enable interrupts.
 	 */
 	SWAPGS
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi
 	jmp	restore_regs_and_iret
 
 .Lnmi_from_kernel:
@@ -1538,6 +1559,8 @@ end_repeat_nmi:
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

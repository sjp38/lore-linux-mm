Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEE306B027F
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:27:57 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u65so10777072wrc.8
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:27:57 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id 20si5485524edt.82.2018.03.05.02.26.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:26:15 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 14/34] x86/entry/32: Add PTI cr3 switch to non-NMI entry/exit points
Date: Mon,  5 Mar 2018 11:25:43 +0100
Message-Id: <1520245563-8444-15-git-send-email-joro@8bytes.org>
In-Reply-To: <1520245563-8444-1-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Add unconditional cr3 switches between user and kernel cr3
to all non-NMI entry and exit points.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 91 +++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 88 insertions(+), 3 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 35379e5..8f78abc 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -328,6 +328,30 @@
 #endif /* CONFIG_X86_ESPFIX32 */
 .endm
 
+/* Unconditionally switch to user cr3 */
+.macro SWITCH_TO_USER_CR3 scratch_reg:req
+	ALTERNATIVE "jmp .Lend_\@", "", X86_FEATURE_PTI
+
+	movl	%cr3, \scratch_reg
+	orl	$PTI_SWITCH_MASK, \scratch_reg
+	movl	\scratch_reg, %cr3
+.Lend_\@:
+.endm
+
+/* Unconditionally switch to kernel cr3 */
+.macro SWITCH_TO_KERNEL_CR3 scratch_reg:req
+	ALTERNATIVE "jmp .Lend_\@", "", X86_FEATURE_PTI
+	movl	%cr3, \scratch_reg
+	/* Test if we are already on kernel CR3 */
+	testl	$PTI_SWITCH_MASK, \scratch_reg
+	jz	.Lend_\@
+	andl	$(~PTI_SWITCH_MASK), \scratch_reg
+	movl	\scratch_reg, %cr3
+	/* Return original CR3 in \scratch_reg */
+	orl	$PTI_SWITCH_MASK, \scratch_reg
+.Lend_\@:
+.endm
+
 
 /*
  * Called with pt_regs fully populated and kernel segments loaded,
@@ -341,11 +365,19 @@
  */
 
 #define CS_FROM_ENTRY_STACK	(1 << 31)
+#define CS_FROM_USER_CR3	(1 << 30)
 
 .macro SWITCH_TO_KERNEL_STACK
 
 	ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
 
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%eax
+
+	/*
+	 * %eax now contains the entry cr3 and we carry it forward in
+	 * that register for the time this macro runs
+	 */
+
 	/* Are we on the entry stack? Bail out if not! */
 	movl	PER_CPU_VAR(cpu_entry_area), %edi
 	addl	$CPU_ENTRY_AREA_entry_stack, %edi
@@ -408,7 +440,8 @@
 	 * but switch back to the entry-stack again when we approach
 	 * iret and return to the interrupted code-path. This usually
 	 * happens when we hit an exception while restoring user-space
-	 * segment registers on the way back to user-space.
+	 * segment registers on the way back to user-space or when the
+	 * sysenter handler runs with eflags.tf set.
 	 *
 	 * When we switch to the task-stack here, we can't trust the
 	 * contents of the entry-stack anymore, as the exception handler
@@ -425,6 +458,7 @@
 	 *
 	 * %esi: Entry-Stack pointer (same as %esp)
 	 * %edi: Top of the task stack
+	 * %eax: CR3 on kernel entry
 	 */
 
 	/* Calculate number of bytes on the entry stack in %ecx */
@@ -441,6 +475,14 @@
 	orl	$CS_FROM_ENTRY_STACK, PT_CS(%esp)
 
 	/*
+	 * Test the cr3 used to enter the kernel and add a marker
+	 * so that we can switch back to it before iret.
+	 */
+	testl	$PTI_SWITCH_MASK, %eax
+	jz	.Lcopy_pt_regs_\@
+	orl	$CS_FROM_USER_CR3, PT_CS(%esp)
+
+	/*
 	 * %esi and %edi are unchanged, %ecx contains the number of
 	 * bytes to copy. The code at .Lcopy_pt_regs_\@ will allocate
 	 * the stack-frame on task-stack and copy everything over
@@ -506,7 +548,7 @@
 
 /*
  * This macro handles the case when we return to kernel-mode on the iret
- * path and have to switch back to the entry stack.
+ * path and have to switch back to the entry stack and/or user-cr3
  *
  * See the comments below the .Lentry_from_kernel_\@ label in the
  * SWITCH_TO_KERNEL_STACK macro for more details.
@@ -552,6 +594,18 @@
 	/* Safe to switch to entry-stack now */
 	movl	%ebx, %esp
 
+	/*
+	 * We came from entry-stack and need to check if we also need to
+	 * switch back to user cr3.
+	 */
+	testl	$CS_FROM_USER_CR3, PT_CS(%esp)
+	jz	.Lend_\@
+
+	/* Clear marker from stack-frame */
+	andl	$(~CS_FROM_USER_CR3), PT_CS(%esp)
+
+	SWITCH_TO_USER_CR3 scratch_reg=%eax
+
 .Lend_\@:
 .endm
 /*
@@ -746,6 +800,18 @@ ENTRY(xen_sysenter_target)
  * 0(%ebp) arg6
  */
 ENTRY(entry_SYSENTER_32)
+	/*
+	 * On entry-stack with all userspace-regs live - save and
+	 * restore eflags and %eax to use it as scratch-reg for the cr3
+	 * switch.
+	 */
+	pushfl
+	pushl	%eax
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%eax
+	popl	%eax
+	popfl
+
+	/* Stack empty again, switch to task stack */
 	movl	TSS_entry_stack(%esp), %esp
 
 .Lsysenter_past_esp:
@@ -826,6 +892,9 @@ ENTRY(entry_SYSENTER_32)
 	/* Switch to entry stack */
 	movl	%eax, %esp
 
+	/* Now ready to switch the cr3 */
+	SWITCH_TO_USER_CR3 scratch_reg=%eax
+
 	/*
 	 * Restore all flags except IF. (We restore IF separately because
 	 * STI gives a one-instruction window in which we won't be interrupted,
@@ -906,7 +975,23 @@ restore_all:
 .Lrestore_all_notrace:
 	CHECK_AND_APPLY_ESPFIX
 .Lrestore_nocheck:
-	RESTORE_REGS 4				# skip orig_eax/error_code
+	/*
+	 * First restore user segments. This can cause exceptions, so we
+	 * run it with kernel cr3.
+	 */
+	RESTORE_SEGMENTS
+
+	/*
+	 * Segments are restored - no more exceptions from here on except on
+	 * iret, but that handled safely.
+	 */
+	SWITCH_TO_USER_CR3 scratch_reg=%eax
+
+	/* Restore rest */
+	RESTORE_INT_REGS
+
+	/* Unwind stack to the iret frame */
+	RESTORE_SKIP_SEGMENTS 4			# skip orig_eax/error_code
 .Lirq_return:
 	INTERRUPT_RETURN
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

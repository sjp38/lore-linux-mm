Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 80C936B0028
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:26:34 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u68so1365894wmd.5
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:26:34 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id p90si2415859edd.128.2018.03.05.02.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:26:12 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 11/34] x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack
Date: Mon,  5 Mar 2018 11:25:40 +0100
Message-Id: <1520245563-8444-12-git-send-email-joro@8bytes.org>
In-Reply-To: <1520245563-8444-1-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

It can happen that we enter the kernel from kernel-mode and
on the entry-stack. The most common way this happens is when
we get an exception while loading the user-space segment
registers on the kernel-to-userspace exit path.

The segment loading needs to be done after the entry-stack
switch, because the stack-switch needs kernel %fs for
per_cpu access.

When this happens, we need to make sure that we leave the
kernel with the entry-stack again, so that the interrupted
code-path runs on the right stack when switching to the
user-cr3.

We do this by detecting this condition on kernel-entry by
checking CS.RPL and %esp, and if it happens, we copy over
the complete content of the entry stack to the task-stack.
This needs to be done because once we enter the exception
handlers we might be scheduled out or even migrated to a
different CPU, so that we can't rely on the entry-stack
contents. We also leave a marker in the stack-frame to
detect this condition on the exit path.

On the exit path the copy is reversed, we copy all of the
remaining task-stack back to the entry-stack and switch
to it.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 110 +++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 109 insertions(+), 1 deletion(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index bb0bd896..3a84945 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -299,6 +299,9 @@
  * copied there. So allocate the stack-frame on the task-stack and
  * switch to it before we do any copying.
  */
+
+#define CS_FROM_ENTRY_STACK	(1 << 31)
+
 .macro SWITCH_TO_KERNEL_STACK
 
 	ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
@@ -320,6 +323,10 @@
 	/* Load top of task-stack into %edi */
 	movl	TSS_entry_stack(%edi), %edi
 
+	/* Special case - entry from kernel mode via entry stack */
+	testl	$SEGMENT_RPL_MASK, PT_CS(%esp)
+	jz	.Lentry_from_kernel_\@
+
 	/* Bytes to copy */
 	movl	$PTREGS_SIZE, %ecx
 
@@ -333,8 +340,8 @@
 	 */
 	addl	$(4 * 4), %ecx
 
-.Lcopy_pt_regs_\@:
 #endif
+.Lcopy_pt_regs_\@:
 
 	/* Allocate frame on task-stack */
 	subl	%ecx, %edi
@@ -350,6 +357,56 @@
 	cld
 	rep movsl
 
+	jmp .Lend_\@
+
+.Lentry_from_kernel_\@:
+
+	/*
+	 * This handles the case when we enter the kernel from
+	 * kernel-mode and %esp points to the entry-stack. When this
+	 * happens we need to switch to the task-stack to run C code,
+	 * but switch back to the entry-stack again when we approach
+	 * iret and return to the interrupted code-path. This usually
+	 * happens when we hit an exception while restoring user-space
+	 * segment registers on the way back to user-space.
+	 *
+	 * When we switch to the task-stack here, we can't trust the
+	 * contents of the entry-stack anymore, as the exception handler
+	 * might be scheduled out or moved to another CPU. Therefore we
+	 * copy the complete entry-stack to the task-stack and set a
+	 * marker in the iret-frame (bit 31 of the CS dword) to detect
+	 * what we've done on the iret path.
+	 *
+	 * On the iret path we copy everything back and switch to the
+	 * entry-stack, so that the interrupted kernel code-path
+	 * continues on the same stack it was interrupted with.
+	 *
+	 * Be aware that an NMI can happen anytime in this code.
+	 *
+	 * %esi: Entry-Stack pointer (same as %esp)
+	 * %edi: Top of the task stack
+	 */
+
+	/* Calculate number of bytes on the entry stack in %ecx */
+	movl	%esi, %ecx
+
+	/* %ecx to the top of entry-stack */
+	andl	$(MASK_entry_stack), %ecx
+	addl	$(SIZEOF_entry_stack), %ecx
+
+	/* Number of bytes on the entry stack to %ecx */
+	sub	%esi, %ecx
+
+	/* Mark stackframe as coming from entry stack */
+	orl	$CS_FROM_ENTRY_STACK, PT_CS(%esp)
+
+	/*
+	 * %esi and %edi are unchanged, %ecx contains the number of
+	 * bytes to copy. The code at .Lcopy_pt_regs_\@ will allocate
+	 * the stack-frame on task-stack and copy everything over
+	 */
+	jmp .Lcopy_pt_regs_\@
+
 .Lend_\@:
 .endm
 
@@ -408,6 +465,56 @@
 .endm
 
 /*
+ * This macro handles the case when we return to kernel-mode on the iret
+ * path and have to switch back to the entry stack.
+ *
+ * See the comments below the .Lentry_from_kernel_\@ label in the
+ * SWITCH_TO_KERNEL_STACK macro for more details.
+ */
+.macro PARANOID_EXIT_TO_KERNEL_MODE
+
+	/*
+	 * Test if we entered the kernel with the entry-stack. Most
+	 * likely we did not, because this code only runs on the
+	 * return-to-kernel path.
+	 */
+	testl	$CS_FROM_ENTRY_STACK, PT_CS(%esp)
+	jz	.Lend_\@
+
+	/* Unlikely slow-path */
+
+	/* Clear marker from stack-frame */
+	andl	$(~CS_FROM_ENTRY_STACK), PT_CS(%esp)
+
+	/* Copy the remaining task-stack contents to entry-stack */
+	movl	%esp, %esi
+	movl	PER_CPU_VAR(cpu_tss_rw + TSS_sp0), %edi
+
+	/* Bytes on the task-stack to ecx */
+	movl	PER_CPU_VAR(cpu_current_top_of_stack), %ecx
+	subl	%esi, %ecx
+
+	/* Allocate stack-frame on entry-stack */
+	subl	%ecx, %edi
+
+	/*
+	 * Save future stack-pointer, we must not switch until the
+	 * copy is done, otherwise the NMI handler could destroy the
+	 * contents of the task-stack we are about to copy.
+	 */
+	movl	%edi, %ebx
+
+	/* Do the copy */
+	shrl	$2, %ecx
+	cld
+	rep movsl
+
+	/* Safe to switch to entry-stack now */
+	movl	%ebx, %esp
+
+.Lend_\@:
+.endm
+/*
  * %eax: prev task
  * %edx: next task
  */
@@ -765,6 +872,7 @@ restore_all:
 
 restore_all_kernel:
 	TRACE_IRQS_IRET
+	PARANOID_EXIT_TO_KERNEL_MODE
 	RESTORE_REGS 4
 	jmp	.Lirq_return
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

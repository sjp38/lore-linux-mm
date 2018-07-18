Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 766266B0274
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:41:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d30-v6so1705287edd.0
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 02:41:30 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id j34-v6si279873edb.167.2018.07.18.02.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 02:41:29 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 08/39] x86/entry/32: Leave the kernel via trampoline stack
Date: Wed, 18 Jul 2018 11:40:45 +0200
Message-Id: <1531906876-13451-9-git-send-email-joro@8bytes.org>
In-Reply-To: <1531906876-13451-1-git-send-email-joro@8bytes.org>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Switch back to the trampoline stack before returning to
userspace.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 79 +++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 77 insertions(+), 2 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index fea49ec..a905e62 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -343,6 +343,60 @@
 .endm
 
 /*
+ * Switch back from the kernel stack to the entry stack.
+ *
+ * The %esp register must point to pt_regs on the task stack. It will
+ * first calculate the size of the stack-frame to copy, depending on
+ * whether we return to VM86 mode or not. With that it uses 'rep movsl'
+ * to copy the contents of the stack over to the entry stack.
+ *
+ * We must be very careful here, as we can't trust the contents of the
+ * task-stack once we switched to the entry-stack. When an NMI happens
+ * while on the entry-stack, the NMI handler will switch back to the top
+ * of the task stack, overwriting our stack-frame we are about to copy.
+ * Therefore we switch the stack only after everything is copied over.
+ */
+.macro SWITCH_TO_ENTRY_STACK
+
+	ALTERNATIVE     "", "jmp .Lend_\@", X86_FEATURE_XENPV
+
+	/* Bytes to copy */
+	movl	$PTREGS_SIZE, %ecx
+
+#ifdef CONFIG_VM86
+	testl	$(X86_EFLAGS_VM), PT_EFLAGS(%esp)
+	jz	.Lcopy_pt_regs_\@
+
+	/* Additional 4 registers to copy when returning to VM86 mode */
+	addl    $(4 * 4), %ecx
+
+.Lcopy_pt_regs_\@:
+#endif
+
+	/* Initialize source and destination for movsl */
+	movl	PER_CPU_VAR(cpu_tss_rw + TSS_sp0), %edi
+	subl	%ecx, %edi
+	movl	%esp, %esi
+
+	/* Save future stack pointer in %ebx */
+	movl	%edi, %ebx
+
+	/* Copy over the stack-frame */
+	shrl	$2, %ecx
+	cld
+	rep movsl
+
+	/*
+	 * Switch to entry-stack - needs to happen after everything is
+	 * copied because the NMI handler will overwrite the task-stack
+	 * when on entry-stack
+	 */
+	movl	%ebx, %esp
+
+.Lend_\@:
+.endm
+
+/*
  * %eax: prev task
  * %edx: next task
  */
@@ -581,25 +635,45 @@ ENTRY(entry_SYSENTER_32)
 
 /* Opportunistic SYSEXIT */
 	TRACE_IRQS_ON			/* User mode traces as IRQs on. */
+
+	/*
+	 * Setup entry stack - we keep the pointer in %eax and do the
+	 * switch after almost all user-state is restored.
+	 */
+
+	/* Load entry stack pointer and allocate frame for eflags/eax */
+	movl	PER_CPU_VAR(cpu_tss_rw + TSS_sp0), %eax
+	subl	$(2*4), %eax
+
+	/* Copy eflags and eax to entry stack */
+	movl	PT_EFLAGS(%esp), %edi
+	movl	PT_EAX(%esp), %esi
+	movl	%edi, (%eax)
+	movl	%esi, 4(%eax)
+
+	/* Restore user registers and segments */
 	movl	PT_EIP(%esp), %edx	/* pt_regs->ip */
 	movl	PT_OLDESP(%esp), %ecx	/* pt_regs->sp */
 1:	mov	PT_FS(%esp), %fs
 	PTGS_TO_GS
+
 	popl	%ebx			/* pt_regs->bx */
 	addl	$2*4, %esp		/* skip pt_regs->cx and pt_regs->dx */
 	popl	%esi			/* pt_regs->si */
 	popl	%edi			/* pt_regs->di */
 	popl	%ebp			/* pt_regs->bp */
-	popl	%eax			/* pt_regs->ax */
+
+	/* Switch to entry stack */
+	movl	%eax, %esp
 
 	/*
 	 * Restore all flags except IF. (We restore IF separately because
 	 * STI gives a one-instruction window in which we won't be interrupted,
 	 * whereas POPF does not.)
 	 */
-	addl	$PT_EFLAGS-PT_DS, %esp	/* point esp at pt_regs->flags */
 	btrl	$X86_EFLAGS_IF_BIT, (%esp)
 	popfl
+	popl	%eax
 
 	/*
 	 * Return back to the vDSO, which will pop ecx and edx.
@@ -668,6 +742,7 @@ ENTRY(entry_INT80_32)
 
 restore_all:
 	TRACE_IRQS_IRET
+	SWITCH_TO_ENTRY_STACK
 .Lrestore_all_notrace:
 	CHECK_AND_APPLY_ESPFIX
 .Lrestore_nocheck:
-- 
2.7.4

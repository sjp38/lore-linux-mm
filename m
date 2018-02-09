Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C31046B0008
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 04:25:58 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 73so4226334wrb.13
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 01:25:58 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id 5si1516182edb.158.2018.02.09.01.25.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 01:25:57 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 09/31] x86/entry/32: Leave the kernel via trampoline stack
Date: Fri,  9 Feb 2018 10:25:18 +0100
Message-Id: <1518168340-9392-10-git-send-email-joro@8bytes.org>
In-Reply-To: <1518168340-9392-1-git-send-email-joro@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Switch back to the trampoline stack before returning to
userspace.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 55 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 55 insertions(+)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index e714b53..ba3d8c2 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -338,6 +338,59 @@
 .endm
 
 /*
+ * Switch back from the kernel stack to the entry stack.
+ *
+ * The %esp register must point to pt_regs on the task stack. It will
+ * first calculate the size of the stack-frame to copy, depending on
+ * whether we return to VM86 mode or not. With that it uses 'rep movsb'
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
+	/* Initialize source and destination for movsb */
+	movl	PER_CPU_VAR(cpu_tss_rw + TSS_sp0), %edi
+	subl	%ecx, %edi
+	movl	%esp, %esi
+
+	/* Save future stack pointer in %ebx */
+	movl %edi, %ebx
+
+	/* Copy over the stack-frame */
+	cld
+	rep movsb
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
@@ -578,6 +631,7 @@ ENTRY(entry_SYSENTER_32)
 
 /* Opportunistic SYSEXIT */
 	TRACE_IRQS_ON			/* User mode traces as IRQs on. */
+	SWITCH_TO_ENTRY_STACK		/* Switch to per-cpu entry stack */
 	movl	PT_EIP(%esp), %edx	/* pt_regs->ip */
 	movl	PT_OLDESP(%esp), %ecx	/* pt_regs->sp */
 1:	mov	PT_FS(%esp), %fs
@@ -665,6 +719,7 @@ ENTRY(entry_INT80_32)
 
 restore_all:
 	TRACE_IRQS_IRET
+	SWITCH_TO_ENTRY_STACK
 .Lrestore_all_notrace:
 	CHECK_AND_APPLY_ESPFIX
 .Lrestore_nocheck:
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

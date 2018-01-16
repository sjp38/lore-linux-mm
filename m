Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 227C96B025F
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:29:00 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y111so1468248wrc.2
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:29:00 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id r44si611841edd.42.2018.01.16.08.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 08:39:20 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 03/16] x86/entry/32: Leave the kernel via the trampoline stack
Date: Tue, 16 Jan 2018 17:36:46 +0100
Message-Id: <1516120619-1159-4-git-send-email-joro@8bytes.org>
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Switch back to the trampoline stack before returning to
userspace.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S        | 58 ++++++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/asm-offsets_32.c |  1 +
 2 files changed, 59 insertions(+)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 5a7bdb73be9f..14018eeb11c3 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -263,6 +263,61 @@
 .endm
 
 /*
+ * Switch back from the kernel stack to the entry stack.
+ *
+ * iret_frame > 0 adds code to copie over an iret frame from the old to
+ *                the new stack. It also adds a check which bails out if
+ *                we are not returning to user-space.
+ *
+ * This macro is allowed not modify eflags when iret_frame == 0.
+ */
+.macro SWITCH_TO_ENTRY_STACK iret_frame=0
+	.if \iret_frame > 0
+	/* Are we returning to userspace? */
+	testb   $3, 4(%esp) /* return CS */
+	jz .Lend_\@
+	.endif
+
+	/*
+	 * We run with user-%fs already loaded from pt_regs, so we don't
+	 * have access to per_cpu data anymore, and there is no swapgs
+	 * equivalent on x86_32.
+	 * We work around this by loading the kernel-%fs again and
+	 * reading the entry stack address from there. Then we restore
+	 * the user-%fs and return.
+	 */
+	pushl %fs
+	pushl %edi
+
+	/* Re-load kernel-%fs, after that we can use PER_CPU_VAR */
+	movl $(__KERNEL_PERCPU), %edi
+	movl %edi, %fs
+
+	/* Save old stack pointer to copy the return frame over if needed */
+	movl %esp, %edi
+	movl PER_CPU_VAR(cpu_tss_rw + TSS_sp0), %esp
+
+	/* Now we are on the entry stack */
+
+	.if \iret_frame > 0
+	/* Stack frame: ss, esp, eflags, cs, eip, fs, edi */
+	pushl 6*4(%edi) /* ss */
+	pushl 5*4(%edi) /* esp */
+	pushl 4*4(%edi) /* eflags */
+	pushl 3*4(%edi) /* cs */
+	pushl 2*4(%edi) /* eip */
+	.endif
+
+	pushl 4(%edi)   /* fs */
+	
+	/* Restore user %edi and user %fs */
+	movl (%edi), %edi
+	popl %fs
+
+.Lend_\@:
+.endm
+
+/*
  * %eax: prev task
  * %edx: next task
  */
@@ -512,6 +567,8 @@ ENTRY(entry_SYSENTER_32)
 	btr	$X86_EFLAGS_IF_BIT, (%esp)
 	popfl
 
+	SWITCH_TO_ENTRY_STACK
+
 	/*
 	 * Return back to the vDSO, which will pop ecx and edx.
 	 * Don't bother with DS and ES (they already contain __USER_DS).
@@ -601,6 +658,7 @@ restore_all:
 .Lrestore_nocheck:
 	RESTORE_REGS 4				# skip orig_eax/error_code
 .Lirq_return:
+	SWITCH_TO_ENTRY_STACK iret_frame=1
 	INTERRUPT_RETURN
 
 .section .fixup, "ax"
diff --git a/arch/x86/kernel/asm-offsets_32.c b/arch/x86/kernel/asm-offsets_32.c
index 7270dd834f4b..b628f898edd2 100644
--- a/arch/x86/kernel/asm-offsets_32.c
+++ b/arch/x86/kernel/asm-offsets_32.c
@@ -50,6 +50,7 @@ void foo(void)
 	DEFINE(TSS_sysenter_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp1) -
 	       offsetofend(struct cpu_entry_area, entry_stack_page.stack));
 
+	OFFSET(TSS_sp0, tss_struct, x86_tss.sp0);
 	OFFSET(TSS_sp1, tss_struct, x86_tss.sp1);
 
 #ifdef CONFIG_CC_STACKPROTECTOR
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

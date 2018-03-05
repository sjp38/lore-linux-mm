Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 421516B0007
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:26:21 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id d12so10277039wri.4
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:26:21 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id j91si269939edc.275.2018.03.05.02.26.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:26:09 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 04/34] x86/entry/32: Put ESPFIX code into a macro
Date: Mon,  5 Mar 2018 11:25:33 +0100
Message-Id: <1520245563-8444-5-git-send-email-joro@8bytes.org>
In-Reply-To: <1520245563-8444-1-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

This makes it easier to split up the shared iret code path.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 97 ++++++++++++++++++++++++-----------------------
 1 file changed, 49 insertions(+), 48 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index e659776..0289bde 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -221,6 +221,54 @@
 	POP_GS_EX
 .endm
 
+.macro CHECK_AND_APPLY_ESPFIX
+#ifdef CONFIG_X86_ESPFIX32
+#define GDT_ESPFIX_SS PER_CPU_VAR(gdt_page) + (GDT_ENTRY_ESPFIX_SS * 8)
+
+	ALTERNATIVE	"jmp .Lend_\@", "", X86_BUG_ESPFIX
+
+	movl	PT_EFLAGS(%esp), %eax		# mix EFLAGS, SS and CS
+	/*
+	 * Warning: PT_OLDSS(%esp) contains the wrong/random values if we
+	 * are returning to the kernel.
+	 * See comments in process.c:copy_thread() for details.
+	 */
+	movb	PT_OLDSS(%esp), %ah
+	movb	PT_CS(%esp), %al
+	andl	$(X86_EFLAGS_VM | (SEGMENT_TI_MASK << 8) | SEGMENT_RPL_MASK), %eax
+	cmpl	$((SEGMENT_LDT << 8) | USER_RPL), %eax
+	jne	.Lend_\@	# returning to user-space with LDT SS
+
+	/*
+	 * Setup and switch to ESPFIX stack
+	 *
+	 * We're returning to userspace with a 16 bit stack. The CPU will not
+	 * restore the high word of ESP for us on executing iret... This is an
+	 * "official" bug of all the x86-compatible CPUs, which we can work
+	 * around to make dosemu and wine happy. We do this by preloading the
+	 * high word of ESP with the high word of the userspace ESP while
+	 * compensating for the offset by changing to the ESPFIX segment with
+	 * a base address that matches for the difference.
+	 */
+	mov	%esp, %edx			/* load kernel esp */
+	mov	PT_OLDESP(%esp), %eax		/* load userspace esp */
+	mov	%dx, %ax			/* eax: new kernel esp */
+	sub	%eax, %edx			/* offset (low word is 0) */
+	shr	$16, %edx
+	mov	%dl, GDT_ESPFIX_SS + 4		/* bits 16..23 */
+	mov	%dh, GDT_ESPFIX_SS + 7		/* bits 24..31 */
+	pushl	$__ESPFIX_SS
+	pushl	%eax				/* new kernel esp */
+	/*
+	 * Disable interrupts, but do not irqtrace this section: we
+	 * will soon execute iret and the tracer was already set to
+	 * the irqstate after the IRET:
+	 */
+	DISABLE_INTERRUPTS(CLBR_ANY)
+	lss	(%esp), %esp			/* switch to espfix segment */
+.Lend_\@:
+#endif /* CONFIG_X86_ESPFIX32 */
+.endm
 /*
  * %eax: prev task
  * %edx: next task
@@ -548,21 +596,7 @@ ENTRY(entry_INT80_32)
 restore_all:
 	TRACE_IRQS_IRET
 .Lrestore_all_notrace:
-#ifdef CONFIG_X86_ESPFIX32
-	ALTERNATIVE	"jmp .Lrestore_nocheck", "", X86_BUG_ESPFIX
-
-	movl	PT_EFLAGS(%esp), %eax		# mix EFLAGS, SS and CS
-	/*
-	 * Warning: PT_OLDSS(%esp) contains the wrong/random values if we
-	 * are returning to the kernel.
-	 * See comments in process.c:copy_thread() for details.
-	 */
-	movb	PT_OLDSS(%esp), %ah
-	movb	PT_CS(%esp), %al
-	andl	$(X86_EFLAGS_VM | (SEGMENT_TI_MASK << 8) | SEGMENT_RPL_MASK), %eax
-	cmpl	$((SEGMENT_LDT << 8) | USER_RPL), %eax
-	je .Lldt_ss				# returning to user-space with LDT SS
-#endif
+	CHECK_AND_APPLY_ESPFIX
 .Lrestore_nocheck:
 	RESTORE_REGS 4				# skip orig_eax/error_code
 .Lirq_return:
@@ -575,39 +609,6 @@ ENTRY(iret_exc	)
 	jmp	common_exception
 .previous
 	_ASM_EXTABLE(.Lirq_return, iret_exc)
-
-#ifdef CONFIG_X86_ESPFIX32
-.Lldt_ss:
-/*
- * Setup and switch to ESPFIX stack
- *
- * We're returning to userspace with a 16 bit stack. The CPU will not
- * restore the high word of ESP for us on executing iret... This is an
- * "official" bug of all the x86-compatible CPUs, which we can work
- * around to make dosemu and wine happy. We do this by preloading the
- * high word of ESP with the high word of the userspace ESP while
- * compensating for the offset by changing to the ESPFIX segment with
- * a base address that matches for the difference.
- */
-#define GDT_ESPFIX_SS PER_CPU_VAR(gdt_page) + (GDT_ENTRY_ESPFIX_SS * 8)
-	mov	%esp, %edx			/* load kernel esp */
-	mov	PT_OLDESP(%esp), %eax		/* load userspace esp */
-	mov	%dx, %ax			/* eax: new kernel esp */
-	sub	%eax, %edx			/* offset (low word is 0) */
-	shr	$16, %edx
-	mov	%dl, GDT_ESPFIX_SS + 4		/* bits 16..23 */
-	mov	%dh, GDT_ESPFIX_SS + 7		/* bits 24..31 */
-	pushl	$__ESPFIX_SS
-	pushl	%eax				/* new kernel esp */
-	/*
-	 * Disable interrupts, but do not irqtrace this section: we
-	 * will soon execute iret and the tracer was already set to
-	 * the irqstate after the IRET:
-	 */
-	DISABLE_INTERRUPTS(CLBR_ANY)
-	lss	(%esp), %esp			/* switch to espfix segment */
-	jmp	.Lrestore_nocheck
-#endif
 ENDPROC(entry_INT80_32)
 
 .macro FIXUP_ESPFIX_STACK
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

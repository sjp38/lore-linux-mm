Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F34CC6B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:35:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i14so1907414pgf.13
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 02:35:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id bd7si1045172plb.694.2017.11.29.02.35.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 02:35:49 -0800 (PST)
Message-Id: <20171129103512.869504878@infradead.org>
Date: Wed, 29 Nov 2017 11:33:06 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 5/6] x86/mm/kaiser: Optimize RESTORE_CR3
References: <20171129103301.131535445@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-kaiser-optimize-restore_cr3.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

Currently RESTORE_CR3 does an unconditional flush
(SAVE_AND_SWITCH_TO_KERNEL_CR3 does not set bit 63 on \save_reg).

When restoring to a user ASID, check the user_asid_flush_mask to see
if we can avoid the flush.

For kernel ASIDs we can unconditionaly avoid the flush, since we do
explicit flushes for them.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/entry/calling.h  |   29 +++++++++++++++++++++++++++--
 arch/x86/entry/entry_64.S |    4 ++--
 2 files changed, 29 insertions(+), 4 deletions(-)

--- a/arch/x86/entry/calling.h
+++ b/arch/x86/entry/calling.h
@@ -263,8 +263,33 @@ For 32-bit we have the following convent
 .Ldone_\@:
 .endm
 
-.macro RESTORE_CR3 save_reg:req
+.macro RESTORE_CR3 scratch_reg:req save_reg:req
 	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
+
+	/* ASID bit 11 is for user */
+	bt	$11, \save_reg
+	/*
+	 * KERNEL pages can always resume with NOFLUSH as we do
+	 * explicit flushes.
+	 */
+	jnc	.Lnoflush_\@
+
+	/*
+	 * Check if there's a pending flush for the user ASID we're
+	 * about to set.
+	 */
+	movq	\save_reg, \scratch_reg
+	andq	$(0x7FF), \scratch_reg
+	bt	\scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
+	jnc	.Lnoflush_\@
+
+	btr	\scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
+	jmp	.Ldo_\@
+
+.Lnoflush_\@:
+	ALTERNATIVE "", "bts $63, \save_reg", X86_FEATURE_PCID
+
+.Ldo_\@:
 	/*
 	 * The CR3 write could be avoided when not changing its value,
 	 * but would require a CR3 read *and* a scratch register.
@@ -281,7 +306,7 @@ For 32-bit we have the following convent
 .endm
 .macro SAVE_AND_SWITCH_TO_KERNEL_CR3 scratch_reg:req save_reg:req
 .endm
-.macro RESTORE_CR3 save_reg:req
+.macro RESTORE_CR3 scratch_reg:req save_reg:req
 .endm
 
 #endif
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -1278,7 +1278,7 @@ ENTRY(paranoid_exit)
 	testl	%ebx, %ebx			/* swapgs needed? */
 	jnz	.Lparanoid_exit_no_swapgs
 	TRACE_IRQS_IRETQ
-	RESTORE_CR3	save_reg=%r14
+	RESTORE_CR3	scratch_reg=%rbx save_reg=%r14
 	SWAPGS_UNSAFE_STACK
 	jmp	.Lparanoid_exit_restore
 .Lparanoid_exit_no_swapgs:
@@ -1720,7 +1720,7 @@ ENTRY(nmi)
 	movq	$-1, %rsi
 	call	do_nmi
 
-	RESTORE_CR3 save_reg=%r14
+	RESTORE_CR3 scratch_reg=%r15 save_reg=%r14
 
 	testl	%ebx, %ebx			/* swapgs needed? */
 	jnz	nmi_restore


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

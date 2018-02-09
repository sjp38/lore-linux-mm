Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20A8E6B000C
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 04:26:00 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 30so4207000wrw.6
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 01:26:00 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id c10si713834edf.457.2018.02.09.01.25.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 01:25:58 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 10/31] x86/entry/32: Introduce SAVE_ALL_NMI and RESTORE_ALL_NMI
Date: Fri,  9 Feb 2018 10:25:19 +0100
Message-Id: <1518168340-9392-11-git-send-email-joro@8bytes.org>
In-Reply-To: <1518168340-9392-1-git-send-email-joro@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

These macros will be used in the NMI handler code and
replace plain SAVE_ALL and RESTORE_REGS there. We will add
the NMI-specific CR3-switch to these macros later.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index ba3d8c2..be1d814 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -167,6 +167,9 @@
 
 .endm
 
+.macro SAVE_ALL_NMI
+	SAVE_ALL
+.endm
 /*
  * This is a sneaky trick to help the unwinder find pt_regs on the stack.  The
  * frame pointer is replaced with an encoded pointer to pt_regs.  The encoding
@@ -224,6 +227,18 @@
 	RESTORE_SKIP_SEGMENTS \pop
 .endm
 
+.macro RESTORE_ALL_NMI pop=0
+	/*
+	 * Restore segments - might cause exceptions when loading
+	 * user-space segments
+	 */
+	RESTORE_SEGMENTS
+
+	/* Restore integer registers and unwind stack to iret frame */
+	RESTORE_INT_REGS
+	RESTORE_SKIP_SEGMENTS \pop
+.endm
+
 .macro CHECK_AND_APPLY_ESPFIX
 #ifdef CONFIG_X86_ESPFIX32
 #define GDT_ESPFIX_SS PER_CPU_VAR(gdt_page) + (GDT_ENTRY_ESPFIX_SS * 8)
@@ -1127,7 +1142,7 @@ ENTRY(nmi)
 #endif
 
 	pushl	%eax				# pt_regs->orig_ax
-	SAVE_ALL
+	SAVE_ALL_NMI
 	ENCODE_FRAME_POINTER
 	xorl	%edx, %edx			# zero error code
 	movl	%esp, %eax			# pt_regs pointer
@@ -1155,7 +1170,7 @@ ENTRY(nmi)
 
 .Lnmi_return:
 	CHECK_AND_APPLY_ESPFIX
-	RESTORE_REGS 4
+	RESTORE_ALL_NMI pop=4
 	jmp	.Lirq_return
 
 #ifdef CONFIG_X86_ESPFIX32
@@ -1171,12 +1186,12 @@ ENTRY(nmi)
 	pushl	16(%esp)
 	.endr
 	pushl	%eax
-	SAVE_ALL
+	SAVE_ALL_NMI
 	ENCODE_FRAME_POINTER
 	FIXUP_ESPFIX_STACK			# %eax == %esp
 	xorl	%edx, %edx			# zero error code
 	call	do_nmi
-	RESTORE_REGS
+	RESTORE_ALL_NMI
 	lss	12+4(%esp), %esp		# back to espfix stack
 	jmp	.Lirq_return
 #endif
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

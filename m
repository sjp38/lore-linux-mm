Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC426B000E
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 04:25:59 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 30so4206953wrw.6
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 01:25:59 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id 36si1511743edo.126.2018.02.09.01.25.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 01:25:57 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 07/31] x86/entry/32: Restore segments before int registers
Date: Fri,  9 Feb 2018 10:25:16 +0100
Message-Id: <1518168340-9392-8-git-send-email-joro@8bytes.org>
In-Reply-To: <1518168340-9392-1-git-send-email-joro@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Restoring the segments can cause exceptions that need to be
handled. With PTI enabled, we still need to be on kernel cr3
when the exception happens. For the cr3-switch we need
at least one integer scratch register, so we can't switch
with the user integer registers already loaded.

Avoid a push/pop cycle to free a register for the cr3 switch
by restoring the segments first. That way the integer
registers are not live yet and we can use them for the cr3
switch.

This also helps in the NMI path, where we need to leave with
the same cr3 as we entered. There we still have the
callee-saved registers live when switching cr3s.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 50 ++++++++++++++++++++---------------------------
 1 file changed, 21 insertions(+), 29 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 9bd7718..b39c5e2 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -92,11 +92,6 @@
 .macro PUSH_GS
 	pushl	$0
 .endm
-.macro POP_GS pop=0
-	addl	$(4 + \pop), %esp
-.endm
-.macro POP_GS_EX
-.endm
 
  /* all the rest are no-op */
 .macro PTGS_TO_GS
@@ -116,20 +111,6 @@
 	pushl	%gs
 .endm
 
-.macro POP_GS pop=0
-98:	popl	%gs
-  .if \pop <> 0
-	add	$\pop, %esp
-  .endif
-.endm
-.macro POP_GS_EX
-.pushsection .fixup, "ax"
-99:	movl	$0, (%esp)
-	jmp	98b
-.popsection
-	_ASM_EXTABLE(98b, 99b)
-.endm
-
 .macro PTGS_TO_GS
 98:	mov	PT_GS(%esp), %gs
 .endm
@@ -201,24 +182,35 @@
 	popl	%eax
 .endm
 
-.macro RESTORE_REGS pop=0
-	RESTORE_INT_REGS
-1:	popl	%ds
-2:	popl	%es
-3:	popl	%fs
-	POP_GS \pop
+.macro RESTORE_SEGMENTS
+1:	mov	PT_DS(%esp), %ds
+2:	mov	PT_ES(%esp), %es
+3:	mov	PT_FS(%esp), %fs
+	PTGS_TO_GS
 .pushsection .fixup, "ax"
-4:	movl	$0, (%esp)
+4:	movl	$0, PT_DS(%esp)
 	jmp	1b
-5:	movl	$0, (%esp)
+5:	movl	$0, PT_ES(%esp)
 	jmp	2b
-6:	movl	$0, (%esp)
+6:	movl	$0, PT_FS(%esp)
 	jmp	3b
 .popsection
 	_ASM_EXTABLE(1b, 4b)
 	_ASM_EXTABLE(2b, 5b)
 	_ASM_EXTABLE(3b, 6b)
-	POP_GS_EX
+	PTGS_TO_GS_EX
+.endm
+
+.macro RESTORE_SKIP_SEGMENTS pop=0
+	/* Jump over the segments stored on stack */
+	addl	$((4 * 4) + \pop), %esp
+.endm
+
+.macro RESTORE_REGS pop=0
+	RESTORE_SEGMENTS
+	RESTORE_INT_REGS
+	/* Skip over already restored segment registers */
+	RESTORE_SKIP_SEGMENTS \pop
 .endm
 
 .macro CHECK_AND_APPLY_ESPFIX
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EBE8B6B0023
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:47:52 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o8-v6so18713635wra.12
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:47:52 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id o46si5205569edc.122.2018.04.23.08.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 08:47:51 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 11/37] x86/entry/32: Simplify debug entry point
Date: Mon, 23 Apr 2018 17:47:14 +0200
Message-Id: <1524498460-25530-12-git-send-email-joro@8bytes.org>
In-Reply-To: <1524498460-25530-1-git-send-email-joro@8bytes.org>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The common exception entry code now handles the
entry-from-sysenter stack situation and makes sure to leave
with the same stack as it entered the kernel.

So there is no need anymore for the special handling in the
debug entry code.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 35 +++--------------------------------
 1 file changed, 3 insertions(+), 32 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index b3477ff..71e1cb3 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -1231,41 +1231,12 @@ END(common_exception)
 
 ENTRY(debug)
 	/*
-	 * #DB can happen at the first instruction of
-	 * entry_SYSENTER_32 or in Xen's SYSENTER prologue.  If this
-	 * happens, then we will be running on a very small stack.  We
-	 * need to detect this condition and switch to the thread
-	 * stack before calling any C code at all.
-	 *
-	 * If you edit this code, keep in mind that NMIs can happen in here.
+	 * Entry from sysenter is now handled in common_exception
 	 */
 	ASM_CLAC
 	pushl	$-1				# mark this as an int
-
-	SAVE_ALL
-	ENCODE_FRAME_POINTER
-	xorl	%edx, %edx			# error code 0
-	movl	%esp, %eax			# pt_regs pointer
-
-	/* Are we currently on the SYSENTER stack? */
-	movl	PER_CPU_VAR(cpu_entry_area), %ecx
-	addl	$CPU_ENTRY_AREA_entry_stack + SIZEOF_entry_stack, %ecx
-	subl	%eax, %ecx	/* ecx = (end of entry_stack) - esp */
-	cmpl	$SIZEOF_entry_stack, %ecx
-	jb	.Ldebug_from_sysenter_stack
-
-	TRACE_IRQS_OFF
-	call	do_debug
-	jmp	ret_from_exception
-
-.Ldebug_from_sysenter_stack:
-	/* We're on the SYSENTER stack.  Switch off. */
-	movl	%esp, %ebx
-	movl	PER_CPU_VAR(cpu_current_top_of_stack), %esp
-	TRACE_IRQS_OFF
-	call	do_debug
-	movl	%ebx, %esp
-	jmp	ret_from_exception
+	pushl	$do_debug
+	jmp	common_exception
 END(debug)
 
 /*
-- 
2.7.4

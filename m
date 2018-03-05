Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD8086B000D
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 05:26:21 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o23so11077873wrc.9
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 02:26:21 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id p5si91075edi.538.2018.03.05.02.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 02:26:12 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 06/34] x86/entry/32: Split off return-to-kernel path
Date: Mon,  5 Mar 2018 11:25:35 +0100
Message-Id: <1520245563-8444-7-git-send-email-joro@8bytes.org>
In-Reply-To: <1520245563-8444-1-git-send-email-joro@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Use a separate return path when we know we are returning to
the kernel. This allows us to put the PTI cr3-switch and the
switch to the entry-stack into the return-to-user path
without further checking.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index 00ae759..9bd7718 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -65,7 +65,7 @@
 # define preempt_stop(clobbers)	DISABLE_INTERRUPTS(clobbers); TRACE_IRQS_OFF
 #else
 # define preempt_stop(clobbers)
-# define resume_kernel		restore_all
+# define resume_kernel		restore_all_kernel
 #endif
 
 .macro TRACE_IRQS_IRET
@@ -400,9 +400,9 @@ ENTRY(resume_kernel)
 	DISABLE_INTERRUPTS(CLBR_ANY)
 .Lneed_resched:
 	cmpl	$0, PER_CPU_VAR(__preempt_count)
-	jnz	restore_all
+	jnz	restore_all_kernel
 	testl	$X86_EFLAGS_IF, PT_EFLAGS(%esp)	# interrupts off (exception path) ?
-	jz	restore_all
+	jz	restore_all_kernel
 	call	preempt_schedule_irq
 	jmp	.Lneed_resched
 END(resume_kernel)
@@ -602,6 +602,11 @@ restore_all:
 .Lirq_return:
 	INTERRUPT_RETURN
 
+restore_all_kernel:
+	TRACE_IRQS_IRET
+	RESTORE_REGS 4
+	jmp	.Lirq_return
+
 .section .fixup, "ax"
 ENTRY(iret_exc	)
 	pushl	$0				# no error code
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id C450C6B026E
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:29:11 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id 19so1266371uae.15
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:29:11 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id g7si2653098edj.376.2018.01.16.08.39.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 08:39:18 -0800 (PST)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 01/16] x86/entry/32: Rename TSS_sysenter_sp0 to TSS_sysenter_stack
Date: Tue, 16 Jan 2018 17:36:44 +0100
Message-Id: <1516120619-1159-2-git-send-email-joro@8bytes.org>
In-Reply-To: <1516120619-1159-1-git-send-email-joro@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

The stack addresss doesn't need to be stored in tss.sp0 if
we switch manually like on sysenter. Rename the offset so
that it still makes sense when we its location.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/entry/entry_32.S        | 2 +-
 arch/x86/kernel/asm-offsets_32.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
index a1f28a54f23a..eb8c5615777b 100644
--- a/arch/x86/entry/entry_32.S
+++ b/arch/x86/entry/entry_32.S
@@ -401,7 +401,7 @@ ENTRY(xen_sysenter_target)
  * 0(%ebp) arg6
  */
 ENTRY(entry_SYSENTER_32)
-	movl	TSS_sysenter_sp0(%esp), %esp
+	movl	TSS_sysenter_stack(%esp), %esp
 .Lsysenter_past_esp:
 	pushl	$__USER_DS		/* pt_regs->ss */
 	pushl	%ebp			/* pt_regs->sp (stashed in bp) */
diff --git a/arch/x86/kernel/asm-offsets_32.c b/arch/x86/kernel/asm-offsets_32.c
index fa1261eefa16..654229bac2fc 100644
--- a/arch/x86/kernel/asm-offsets_32.c
+++ b/arch/x86/kernel/asm-offsets_32.c
@@ -47,7 +47,7 @@ void foo(void)
 	BLANK();
 
 	/* Offset from the sysenter stack to tss.sp0 */
-	DEFINE(TSS_sysenter_sp0, offsetof(struct cpu_entry_area, tss.x86_tss.sp0) -
+	DEFINE(TSS_sysenter_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp0) -
 	       offsetofend(struct cpu_entry_area, entry_stack_page.stack));
 
 #ifdef CONFIG_CC_STACKPROTECTOR
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

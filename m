Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96A666B0038
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 17:35:48 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 26so25795004pfs.22
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:35:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s13si23620612plp.649.2017.11.27.14.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 14:35:44 -0800 (PST)
Message-Id: <20171127223405.181647306@infradead.org>
Date: Mon, 27 Nov 2017 23:31:11 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 1/5] x86/mm/kaiser: Alternative ESPFIX
References: <20171127223110.479550152@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-kaiser-espfix.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

Change the asm to do the CR3 switcheroo so we can remove the magic
mappings.

Since RDI is unused after SWAPGS we can use it as a scratch reg for
SWITCH_TO_KERNEL. And once we've computed the new RSP (in RAX) we no
longer need RDI and can again use it as scratch reg for
SWITCH_TO_USER.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/entry/entry_64.S   |   11 ++++++++---
 arch/x86/kernel/espfix_64.c |   10 ++--------
 2 files changed, 10 insertions(+), 11 deletions(-)

--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -825,7 +825,9 @@ ENTRY(native_iret)
 	 */
 
 	pushq	%rdi				/* Stash user RDI */
-	SWAPGS
+	SWAPGS					/* to kernel GS */
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rdi	/* to kernel CR3 */
+
 	movq	PER_CPU_VAR(espfix_waddr), %rdi
 	movq	%rax, (0*8)(%rdi)		/* user RAX */
 	movq	(1*8)(%rsp), %rax		/* user RIP */
@@ -841,7 +843,6 @@ ENTRY(native_iret)
 	/* Now RAX == RSP. */
 
 	andl	$0xffff0000, %eax		/* RAX = (RSP & 0xffff0000) */
-	popq	%rdi				/* Restore user RDI */
 
 	/*
 	 * espfix_stack[31:16] == 0.  The page tables are set up such that
@@ -852,7 +853,11 @@ ENTRY(native_iret)
 	 * still points to an RO alias of the ESPFIX stack.
 	 */
 	orq	PER_CPU_VAR(espfix_stack), %rax
-	SWAPGS
+
+	SWITCH_TO_USER_CR3 scratch_reg=%rdi	/* to user CR3 */
+	SWAPGS					/* to user GS */
+	popq	%rdi				/* Restore user RDI */
+
 	movq	%rax, %rsp
 	UNWIND_HINT_IRET_REGS offset=8
 
--- a/arch/x86/kernel/espfix_64.c
+++ b/arch/x86/kernel/espfix_64.c
@@ -61,8 +61,8 @@
 #define PGALLOC_GFP (GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
 
 /* This contains the *bottom* address of the espfix stack */
-DEFINE_PER_CPU_USER_MAPPED(unsigned long, espfix_stack);
-DEFINE_PER_CPU_USER_MAPPED(unsigned long, espfix_waddr);
+DEFINE_PER_CPU_READ_MOSTLY(unsigned long, espfix_stack);
+DEFINE_PER_CPU_READ_MOSTLY(unsigned long, espfix_waddr);
 
 /* Initialization mutex - should this be a spinlock? */
 static DEFINE_MUTEX(espfix_init_mutex);
@@ -226,10 +226,4 @@ void init_espfix_ap(int cpu)
 	per_cpu(espfix_stack, cpu) = addr;
 	per_cpu(espfix_waddr, cpu) = (unsigned long)stack_page
 				      + (addr & ~PAGE_MASK);
-	/*
-	 * _PAGE_GLOBAL is not really required.  This is not a hot
-	 * path, but we do it here for consistency.
-	 */
-	kaiser_add_mapping((unsigned long)stack_page, PAGE_SIZE,
-			__PAGE_KERNEL | _PAGE_GLOBAL);
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

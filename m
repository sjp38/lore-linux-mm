Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA966B0374
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:31:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m62so18403356pfi.1
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:31:58 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f19si32364502pgn.104.2017.06.06.04.31.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 04:31:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 06/14] x86/boot/compressed: Enable 5-level paging during decompression stage
Date: Tue,  6 Jun 2017 14:31:25 +0300
Message-Id: <20170606113133.22974-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
References: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We need to cover two basic cases: when bootloader left us in 32-bit mode
and when bootloader enabled long mode.

The patch implements unified codepath to enabled 5-level paging for both
cases. It means case when we start in 32-bit mode, we first enable long
mode with 4-level and then switch over to 5-level paging.

Switching from 4-level to 5-level paging is not trivial. We cannot do it
directly. Setting LA57 in long mode would trigger #GP. So we need to
switch off long mode first and the then re-enable with 5-level paging.

NOTE: The need of switching off long mode means we are in trouble if
bootloader put us above 4G boundary. If bootloader wants to boot 5-level
paging kernel, it has to put kernel below 4G or enable 5-level paging on
it's own, so we could avoid the step.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 86 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 85 insertions(+), 1 deletion(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index d2ae1f821e0c..fbf4c32d0b62 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -346,6 +346,48 @@ preferred_addr:
 	/* Set up the stack */
 	leaq	boot_stack_end(%rbx), %rsp
 
+#ifdef CONFIG_X86_5LEVEL
+	/* Check if 5-level paging has already enabled */
+	movq	%cr4, %rax
+	testl	$X86_CR4_LA57, %eax
+	jnz	lvl5
+
+	/*
+	 * At this point we are in long mode with 4-level paging enabled,
+	 * but we want to enable 5-level paging.
+	 *
+	 * The problem is that we cannot do it directly. Setting LA57 in
+	 * long mode would trigger #GP. So we need to switch off long mode
+	 * first.
+	 *
+	 * NOTE: This is not going to work if bootloader put us above 4G
+	 * limit.
+	 *
+	 * The first step is go into compatibility mode.
+	 */
+
+	/* Clear additional page table */
+	leaq	lvl5_pgtable(%rbx), %rdi
+	xorq	%rax, %rax
+	movq	$(PAGE_SIZE/8), %rcx
+	rep	stosq
+
+	/*
+	 * Setup current CR3 as the first and only entry in a new top level
+	 * page table.
+	 */
+	movq	%cr3, %rdi
+	leaq	0x7 (%rdi), %rax
+	movq	%rax, lvl5_pgtable(%rbx)
+
+	/* Switch to compatibility mode (CS.L = 0 CS.D = 1) via far return */
+	pushq	$__KERNEL32_CS
+	leaq	compatible_mode(%rip), %rax
+	pushq	%rax
+	lretq
+lvl5:
+#endif
+
 	/* Zero EFLAGS */
 	pushq	$0
 	popfq
@@ -429,6 +471,44 @@ relocated:
 	jmp	*%rax
 
 	.code32
+#ifdef CONFIG_X86_5LEVEL
+compatible_mode:
+	/* Setup data and stack segments */
+	movl	$__KERNEL_DS, %eax
+	movl	%eax, %ds
+	movl	%eax, %ss
+
+	/* Disable paging */
+	movl	%cr0, %eax
+	btrl	$X86_CR0_PG_BIT, %eax
+	movl	%eax, %cr0
+
+	/* Point CR3 to 5-level paging */
+	leal	lvl5_pgtable(%ebx), %eax
+	movl	%eax, %cr3
+
+	/* Enable PAE and LA57 mode */
+	movl	%cr4, %eax
+	orl	$(X86_CR4_PAE | X86_CR4_LA57), %eax
+	movl	%eax, %cr4
+
+	/* Calculate address we are running at */
+	call	1f
+1:	popl	%edi
+	subl	$1b, %edi
+
+	/* Prepare stack for far return to Long Mode */
+	pushl	$__KERNEL_CS
+	leal	lvl5(%edi), %eax
+	push	%eax
+
+	/* Enable paging back */
+	movl	$(X86_CR0_PG | X86_CR0_PE), %eax
+	movl	%eax, %cr0
+
+	lret
+#endif
+
 no_longmode:
 	/* This isn't an x86-64 CPU so hang */
 1:
@@ -442,7 +522,7 @@ gdt:
 	.word	gdt_end - gdt
 	.long	gdt
 	.word	0
-	.quad	0x0000000000000000	/* NULL descriptor */
+	.quad	0x00cf9a000000ffff	/* __KERNEL32_CS */
 	.quad	0x00af9a000000ffff	/* __KERNEL_CS */
 	.quad	0x00cf92000000ffff	/* __KERNEL_DS */
 	.quad	0x0080890000000000	/* TS descriptor */
@@ -486,3 +566,7 @@ boot_stack_end:
 	.balign 4096
 pgtable:
 	.fill BOOT_PGT_SIZE, 1, 0
+#ifdef CONFIG_X86_5LEVEL
+lvl5_pgtable:
+	.fill PAGE_SIZE, 1, 0
+#endif
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAADF2802A2
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 17:06:59 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id g75so8738377pfg.4
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:06:59 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z20si10179462pfe.221.2017.11.10.14.06.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 14:06:58 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 4/4] x86/boot/compressed/64: Handle 5-level paging boot if kernel is above 4G
Date: Sat, 11 Nov 2017 01:06:45 +0300
Message-Id: <20171110220645.59944-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
References: <20171110220645.59944-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch addresses shortcoming in current boot process on machines
that supports 5-level paging.

If bootloader enables 64-bit mode with 4-level paging, we need to
switch over to 5-level paging. The switching requires disabling paging.
It works fine if kernel itself is loaded below 4G.

If bootloader put the kernel above 4G (not sure if anybody does this),
we would loose control as soon as paging is disabled as code becomes
unreachable.

This patch implements trampoline in lower memory to handle this
situation.

We only need the memory for very short time, until main kernel image
setup its own page tables.

We go though trampoline even if we don't have to: if we're already in
5-level paging mode or if we don't need to switch to it. This way the
trampoline code gets tested not only in special rare case, but on every
boot.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 72 +++++++++++++++++++++++---------------
 1 file changed, 43 insertions(+), 29 deletions(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index 33a47d5c6445..525972ca27b7 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -33,6 +33,7 @@
 #include <asm/processor-flags.h>
 #include <asm/asm-offsets.h>
 #include <asm/bootparam.h>
+#include "pgtable.h"
 
 /*
  * Locally defined symbols should be marked hidden:
@@ -339,31 +340,22 @@ ENTRY(startup_64)
 	call	paging_prepare
 	popq	%rsi
 	movq	%rax, %rcx
-	andq	$(~1UL), %rcx
-
-	testq	$1, %rax
-	jz	lvl5
-
-	/* Clear additional page table */
-	leaq	lvl5_pgtable(%rbx), %rdi
-	xorq	%rax, %rax
-	movq	$(PAGE_SIZE/8), %rcx
-	rep	stosq
 
 	/*
-	 * Setup current CR3 as the first and only entry in a new top level
-	 * page table.
+	 * Load address of trampoline_return into RDI.
+	 * It will be used by trampoline to return to main code.
 	 */
-	movq	%cr3, %rdi
-	leaq	0x7 (%rdi), %rax
-	movq	%rax, lvl5_pgtable(%rbx)
+	leaq	trampoline_return(%rip), %rdi
 
 	/* Switch to compatibility mode (CS.L = 0 CS.D = 1) via far return */
 	pushq	$__KERNEL32_CS
-	leaq	compatible_mode(%rip), %rax
+	andq	$(~1UL), %rax /* Clear bit 0: encode if 5-level paging neeeded */
+	leaq	TRAMPOLINE_32BIT_CODE_OFF(%rax), %rax
 	pushq	%rax
 	lretq
-lvl5:
+trampoline_return:
+	/* Restore stack, 32-bit trampoline uses own stack */
+	leaq	boot_stack_end(%rbx), %rsp
 
 	/* Zero EFLAGS */
 	pushq	$0
@@ -501,36 +493,51 @@ relocated:
 	jmp	*%rax
 
 	.code32
+/*
+ * This is 32-bit trampoline that will be copied over to low memory.
+ *
+ * RDI contains return address (might be above 4G).
+ * ECX contains the base address of trampoline memory.
+ * Bit 0 of ECX encodes if 5-level paging is required.
+ */
 ENTRY(trampoline_32bit_src)
-compatible_mode:
 	/* Setup data and stack segments */
 	movl	$__KERNEL_DS, %eax
 	movl	%eax, %ds
 	movl	%eax, %ss
 
+	movl	%ecx, %edx
+	andl	$(~1UL), %edx
+
+	/* Setup new stack at the end of trampoline memory */
+	leal	TRAMPOLINE_32BIT_STACK_END (%edx), %esp
+
 	/* Disable paging */
 	movl	%cr0, %eax
 	btrl	$X86_CR0_PG_BIT, %eax
 	movl	%eax, %cr0
 
-	/* Point CR3 to 5-level paging */
-	leal	lvl5_pgtable(%ebx), %eax
+	/* Point CR3 to trampoline top level page table */
+	leal	TRAMPOLINE_32BIT_PGTABLE_OFF (%edx), %eax
 	movl	%eax, %cr3
 
 	/* Enable PAE and LA57 mode */
 	movl	%cr4, %eax
-	orl	$(X86_CR4_PAE | X86_CR4_LA57), %eax
+	orl	$X86_CR4_PAE, %eax
+
+	/* Bit 0 of ECX encodes if 5-level paging is required */
+	testl	$1, %ecx
+	jz	1f
+	orl	$X86_CR4_LA57, %eax
+1:
 	movl	%eax, %cr4
 
-	/* Calculate address we are running at */
-	call	1f
-1:	popl	%edi
-	subl	$1b, %edi
+	/* Calculate address of paging_enabled once we are in trampoline */
+	leal	paging_enabled - trampoline_32bit_src + TRAMPOLINE_32BIT_CODE_OFF (%edx), %eax
 
 	/* Prepare stack for far return to Long Mode */
 	pushl	$__KERNEL_CS
-	leal	lvl5(%edi), %eax
-	push	%eax
+	pushl	%eax
 
 	/* Enable paging back */
 	movl	$(X86_CR0_PG | X86_CR0_PE), %eax
@@ -538,6 +545,15 @@ compatible_mode:
 
 	lret
 
+	.code64
+paging_enabled:
+	/* Return from trampoline */
+	jmp	*%rdi
+
+	/* Bound size of trampoline code */
+	.org	trampoline_32bit_src + TRAMPOLINE_32BIT_CODE_SIZE
+
+	.code32
 no_longmode:
 	/* This isn't an x86-64 CPU so hang */
 1:
@@ -595,5 +611,3 @@ boot_stack_end:
 	.balign 4096
 pgtable:
 	.fill BOOT_PGT_SIZE, 1, 0
-lvl5_pgtable:
-	.fill PAGE_SIZE, 1, 0
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

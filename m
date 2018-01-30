Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3093C6B0008
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 08:52:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 205so10832229pfw.4
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:52:55 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id h15-v6si2093628plk.480.2018.01.30.05.52.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 05:52:53 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv8 4/4] x86/boot/compressed/64: Handle 5-level paging boot if kernel is above 4G
Date: Tue, 30 Jan 2018 16:52:39 +0300
Message-Id: <20180130135239.72244-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180130135239.72244-1-kirill.shutemov@linux.intel.com>
References: <20180130135239.72244-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch addresses a shortcoming in current boot process on machines
that supports 5-level paging.

If a bootloader enables 64-bit mode with 4-level paging, we might need to
switch over to 5-level paging. The switching requires the disabling
paging. It works fine if kernel itself is loaded below 4G.

But if the bootloader put the kernel above 4G (not sure if anybody does
this), we would lose control as soon as paging is disabled, because the
code becomes unreachable to the CPU.

This patch implements a trampoline in lower memory to handle this
situation.

We only need the memory for a very short time, until the main kernel
image sets up own page tables.

We go through the trampoline even if we don't have to: if we're already
in 5-level paging mode or if we don't need to switch to it. This way the
trampoline gets tested on every boot.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 128 ++++++++++++++++++++++++++-----------
 1 file changed, 90 insertions(+), 38 deletions(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index 1bcc62a232f6..2c4158ef60af 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -33,6 +33,7 @@
 #include <asm/processor-flags.h>
 #include <asm/asm-offsets.h>
 #include <asm/bootparam.h>
+#include "pgtable.h"
 
 /*
  * Locally defined symbols should be marked hidden:
@@ -306,13 +307,34 @@ ENTRY(startup_64)
 
 	/*
 	 * At this point we are in long mode with 4-level paging enabled,
-	 * but we want to enable 5-level paging.
+	 * but we might want to enable 5-level paging or vice versa.
 	 *
-	 * The problem is that we cannot do it directly. Setting LA57 in
-	 * long mode would trigger #GP. So we need to switch off long mode
-	 * first.
+	 * The problem is that we cannot do it directly. Setting or clearing
+	 * CR4.LA57 in long mode would trigger #GP. So we need to switch off
+	 * long mode and paging first.
+	 *
+	 * We also need a trampoline in lower memory to switch over from
+	 * 4- to 5-level paging for cases when the bootloader puts the kernel
+	 * above 4G, but didn't enable 5-level paging for us.
+	 *
+	 * The same trampoline can be used to switch from 5- to 4-level paging
+	 * mode, like when starting 4-level paging kernel via kexec() when
+	 * original kernel worked in 5-level paging mode.
+	 *
+	 * For the trampoline, we need the top page table to reside in lower
+	 * memory as we don't have a way to load 64-bit values into CR3 in
+	 * 32-bit mode.
+	 *
+	 * We go though the trampoline even if we don't have to: if we're
+	 * already in a desired paging mode. This way the trampoline code gets
+	 * tested on every boot.
 	 */
 
+	/* Make sure we have GDT with 32-bit code segment */
+	leaq	gdt(%rip), %rax
+	movl	%eax, gdt64+2(%rip)
+	lgdt	gdt64(%rip)
+
 	/*
 	 * paging_prepare() would set up the trampoline and check if we need to
 	 * enable 5-level paging.
@@ -330,30 +352,20 @@ ENTRY(startup_64)
 	/* Save the trampoline address in RCX */
 	movq	%rax, %rcx
 
-	/* Check if we need to enable 5-level paging */
-	cmpq	$0, %rdx
-	jz	lvl5
-
-	/* Clear additional page table */
-	leaq	lvl5_pgtable(%rbx), %rdi
-	xorq	%rax, %rax
-	movq	$(PAGE_SIZE/8), %rcx
-	rep	stosq
-
 	/*
-	 * Setup current CR3 as the first and only entry in a new top level
-	 * page table.
+	 * Load the address of trampoline_return() into RDI.
+	 * It will be used by the trampoline to return to the main code.
 	 */
-	movq	%cr3, %rdi
-	leaq	0x7 (%rdi), %rax
-	movq	%rax, lvl5_pgtable(%rbx)
+	leaq	trampoline_return(%rip), %rdi
 
 	/* Switch to compatibility mode (CS.L = 0 CS.D = 1) via far return */
 	pushq	$__KERNEL32_CS
-	leaq	compatible_mode(%rip), %rax
+	leaq	TRAMPOLINE_32BIT_CODE_OFFSET(%rax), %rax
 	pushq	%rax
 	lretq
-lvl5:
+trampoline_return:
+	/* Restore the stack, the 32-bit trampoline uses its own stack */
+	leaq	boot_stack_end(%rbx), %rsp
 
 	/* Zero EFLAGS */
 	pushq	$0
@@ -491,45 +503,82 @@ relocated:
 	jmp	*%rax
 
 	.code32
+/*
+ * This is the 32-bit trampoline that will be copied over to low memory.
+ *
+ * RDI contains the return address (might be above 4G).
+ * ECX contains the base address of the trampoline memory.
+ * Non zero RDX on return means we need to enable 5-level paging.
+ */
 ENTRY(trampoline_32bit_src)
-compatible_mode:
 	/* Set up data and stack segments */
 	movl	$__KERNEL_DS, %eax
 	movl	%eax, %ds
 	movl	%eax, %ss
 
+	/* Setup new stack */
+	leal	TRAMPOLINE_32BIT_STACK_END(%ecx), %esp
+
 	/* Disable paging */
 	movl	%cr0, %eax
 	btrl	$X86_CR0_PG_BIT, %eax
 	movl	%eax, %cr0
 
-	/* Point CR3 to 5-level paging */
-	leal	lvl5_pgtable(%ebx), %eax
-	movl	%eax, %cr3
+	/* Check what paging mode we want to be in after the trampoline */
+	cmpl	$0, %edx
+	jz	1f
 
-	/* Enable PAE and LA57 mode */
+	/* We want 5-level paging: don't touch CR3 if it already points to 5-level page tables */
 	movl	%cr4, %eax
-	orl	$(X86_CR4_PAE | X86_CR4_LA57), %eax
+	testl	$X86_CR4_LA57, %eax
+	jnz	3f
+	jmp	2f
+1:
+	/* We want 4-level paging: don't touch CR3 if it already points to 4-level page tables */
+	movl	%cr4, %eax
+	testl	$X86_CR4_LA57, %eax
+	jz	3f
+2:
+	/* Point CR3 to the trampoline's new top level page table */
+	leal	TRAMPOLINE_32BIT_PGTABLE_OFFSET(%ecx), %eax
+	movl	%eax, %cr3
+3:
+	/* Enable PAE and LA57 (if required) paging modes */
+	movl	$X86_CR4_PAE, %eax
+	cmpl	$0, %edx
+	jz	1f
+	orl	$X86_CR4_LA57, %eax
+1:
 	movl	%eax, %cr4
 
-	/* Calculate address we are running at */
-	call	1f
-1:	popl	%edi
-	subl	$1b, %edi
+	/* Calculate address of paging_enabled() once we are executing in the trampoline */
+	leal	paging_enabled - trampoline_32bit_src + TRAMPOLINE_32BIT_CODE_OFFSET(%ecx), %eax
 
-	/* Prepare stack for far return to Long Mode */
+	/* Prepare the stack for far return to Long Mode */
 	pushl	$__KERNEL_CS
-	leal	lvl5(%edi), %eax
-	push	%eax
+	pushl	%eax
 
-	/* Enable paging back */
+	/* Enable paging again */
 	movl	$(X86_CR0_PG | X86_CR0_PE), %eax
 	movl	%eax, %cr0
 
 	lret
 
+	.code64
+paging_enabled:
+	/* Return from the trampoline */
+	jmp	*%rdi
+
+	/*
+         * The trampoline code has a size limit.
+         * Make sure we fail to compile if the trampoline code grows
+         * beyond TRAMPOLINE_32BIT_CODE_SIZE bytes.
+	 */
+	.org	trampoline_32bit_src + TRAMPOLINE_32BIT_CODE_SIZE
+
+	.code32
 no_longmode:
-	/* This isn't an x86-64 CPU so hang */
+	/* This isn't an x86-64 CPU, so hang intentionally, we cannot continue */
 1:
 	hlt
 	jmp     1b
@@ -537,6 +586,11 @@ no_longmode:
 #include "../../kernel/verify_cpu.S"
 
 	.data
+gdt64:
+	.word	gdt_end - gdt
+	.long	0
+	.word	0
+	.quad   0
 gdt:
 	.word	gdt_end - gdt
 	.long	gdt
@@ -585,5 +639,3 @@ boot_stack_end:
 	.balign 4096
 pgtable:
 	.fill BOOT_PGT_SIZE, 1, 0
-lvl5_pgtable:
-	.fill PAGE_SIZE, 1, 0
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

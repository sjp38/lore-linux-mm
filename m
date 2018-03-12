Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BCAE66B0008
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 06:02:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d5so5524927pfn.12
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 03:02:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b1-v6si5700764plr.335.2018.03.12.03.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 03:02:58 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/4] x86/boot/compressed/64: Use page table in trampoline memory
Date: Mon, 12 Mar 2018 13:02:45 +0300
Message-Id: <20180312100246.89175-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180312100246.89175-1-kirill.shutemov@linux.intel.com>
References: <20180312100246.89175-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If a bootloader enables 64-bit mode with 4-level paging, we might need to
switch over to 5-level paging. The switching requires the disabling
paging. It works fine if kernel itself is loaded below 4G.

But if the bootloader put the kernel above 4G (i.e. in kexec() case),
we would lose control as soon as paging is disabled, because the code
becomes unreachable to the CPU.

To handle the situation, we need a trampoline in lower memory that would
take care of switching on 5-level paging.

Apart from the trampoline code itself we also need a place to store
top-level page table in lower memory as we don't have a way to load
64-bit values into CR3 in 32-bit mode. We only really need 8 bytes there
as we only use the very first entry of the page table. But we allocate a
whole page anyway.

This patch switches 32-bit code to use page table in trampoline memory.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 47 +++++++++++++++++++-------------------
 1 file changed, 23 insertions(+), 24 deletions(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index 0014459d9bcb..836ed319e995 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -336,23 +336,6 @@ ENTRY(startup_64)
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
-	/*
-	 * Setup current CR3 as the first and only entry in a new top level
-	 * page table.
-	 */
-	movq	%cr3, %rdi
-	leaq	0x7 (%rdi), %rax
-	movq	%rax, lvl5_pgtable(%rbx)
 
 	/* Switch to compatibility mode (CS.L = 0 CS.D = 1) via far return */
 	pushq	$__KERNEL32_CS
@@ -524,13 +507,31 @@ compatible_mode:
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
 
 	/* Calculate address we are running at */
@@ -611,5 +612,3 @@ boot_stack_end:
 	.balign 4096
 pgtable:
 	.fill BOOT_PGT_SIZE, 1, 0
-lvl5_pgtable:
-	.fill PAGE_SIZE, 1, 0
-- 
2.16.1

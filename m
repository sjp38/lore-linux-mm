Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 939E26B0268
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 12:10:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j64so47908504pfj.6
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 09:10:35 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 136si6547579pgf.563.2017.10.09.09.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 09:10:33 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC] x86/boot/compressed/64: Handle 5-level paging boot if kernel is above 4G
Date: Mon,  9 Oct 2017 19:09:24 +0300
Message-Id: <20171009160924.68032-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

[
  The patch is based on my boot-time switching patchset and would not apply
  directly to current upstream, but I would appreciate early feedback.
]

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

I use MBR memory (0x7c00) to store trampoline code.

Apart from trampoline itself we also need place to store top level page
table in lower memory as we don't have a way to load 64-bit value into
CR3 from 32-bit mode. We only really need 8-bytes there as we only use
the very first entry of the page table.

For this I use 0x7000.

Not sure if this placement is entirely safe, but I don't see a better
spot to place them.

We only need them for very short time, until main kernel image setup its
own page tables.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 68 +++++++++++++++++++++++++-------------
 1 file changed, 45 insertions(+), 23 deletions(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index cefe4958fda9..049a289342bd 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -288,6 +288,22 @@ ENTRY(startup_64)
 	leaq	boot_stack_end(%rbx), %rsp
 
 #ifdef CONFIG_X86_5LEVEL
+/*
+ * We need trampoline in lower memory switch from 4- to 5-level paging for
+ * cases when bootloader put kernel above 4G, but didn't enable 5-level paging
+ * for us.
+ *
+ * Here we use MBR memory to store trampoline code.
+ *
+ * We also have to have top page table in lower memory as we don't have a way
+ * to load 64-bit value into CR3 from 32-bit mode. We only need 8-bytes there
+ * as we only use the very first entry of the page table.
+ *
+ * Here we use 0x7000 as top-level page table.
+ */
+#define LVL5_TRAMPOLINE	0x7c00
+#define LVL5_PGTABLE	0x7000
+
 	/* Preserve RBX across CPUID */
 	movq	%rbx, %r8
 
@@ -323,29 +339,37 @@ ENTRY(startup_64)
 	 * long mode would trigger #GP. So we need to switch off long mode
 	 * first.
 	 *
-	 * NOTE: This is not going to work if bootloader put us above 4G
-	 * limit.
+	 * We use trampoline in lower memory to handle situation when
+	 * bootloader put the kernel image above 4G.
 	 *
 	 * The first step is go into compatibility mode.
 	 */
 
-	/* Clear additional page table */
-	leaq	lvl5_pgtable(%rbx), %rdi
-	xorq	%rax, %rax
-	movq	$(PAGE_SIZE/8), %rcx
-	rep	stosq
+	/* Copy trampoline code in place */
+	movq	%rsi, %r9
+	leaq	lvl5_trampoline(%rip), %rsi
+	movq	$LVL5_TRAMPOLINE, %rdi
+	movq	$(lvl5_trampoline_end - lvl5_trampoline), %rcx
+	rep	movsb
+	movq	%r9, %rsi
 
 	/*
-	 * Setup current CR3 as the first and only entry in a new top level
+	 * Setup current CR3 as the first and the only entry in a new top level
 	 * page table.
 	 */
 	movq	%cr3, %rdi
 	leaq	0x7 (%rdi), %rax
-	movq	%rax, lvl5_pgtable(%rbx)
+	movq	%rax, LVL5_PGTABLE
+
+	/*
+	 * Load address of lvl5 into RDI.
+	 * It will be used to return address from trampoline.
+	 */
+	leaq	lvl5(%rip), %rdi
 
 	/* Switch to compatibility mode (CS.L = 0 CS.D = 1) via far return */
 	pushq	$__KERNEL32_CS
-	leaq	compatible_mode(%rip), %rax
+	movq	$LVL5_TRAMPOLINE, %rax
 	pushq	%rax
 	lretq
 lvl5:
@@ -488,9 +512,9 @@ relocated:
  */
 	jmp	*%rax
 
-	.code32
 #ifdef CONFIG_X86_5LEVEL
-compatible_mode:
+	.code32
+lvl5_trampoline:
 	/* Setup data and stack segments */
 	movl	$__KERNEL_DS, %eax
 	movl	%eax, %ds
@@ -502,7 +526,7 @@ compatible_mode:
 	movl	%eax, %cr0
 
 	/* Point CR3 to 5-level paging */
-	leal	lvl5_pgtable(%ebx), %eax
+	movl	$LVL5_PGTABLE, %eax
 	movl	%eax, %cr3
 
 	/* Enable PAE and LA57 mode */
@@ -510,14 +534,9 @@ compatible_mode:
 	orl	$(X86_CR4_PAE | X86_CR4_LA57), %eax
 	movl	%eax, %cr4
 
-	/* Calculate address we are running at */
-	call	1f
-1:	popl	%edi
-	subl	$1b, %edi
-
 	/* Prepare stack for far return to Long Mode */
 	pushl	$__KERNEL_CS
-	leal	lvl5(%edi), %eax
+	movl	$(lvl5_enabled - lvl5_trampoline + LVL5_TRAMPOLINE), %eax
 	push	%eax
 
 	/* Enable paging back */
@@ -525,8 +544,15 @@ compatible_mode:
 	movl	%eax, %cr0
 
 	lret
+
+	.code64
+lvl5_enabled:
+	/* Return from trampoline */
+	jmp	*%rdi
+lvl5_trampoline_end:
 #endif
 
+	.code32
 no_longmode:
 	/* This isn't an x86-64 CPU so hang */
 1:
@@ -584,7 +610,3 @@ boot_stack_end:
 	.balign 4096
 pgtable:
 	.fill BOOT_PGT_SIZE, 1, 0
-#ifdef CONFIG_X86_5LEVEL
-lvl5_pgtable:
-	.fill PAGE_SIZE, 1, 0
-#endif
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

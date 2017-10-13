Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 394AB6B0038
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:24:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t188so1621698pfd.20
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 05:24:04 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id o3si570658pld.135.2017.10.13.05.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 05:24:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC] x86/boot/compressed/64: Handle 5-level paging boot if kernel is above 4G
Date: Fri, 13 Oct 2017 15:23:45 +0300
Message-Id: <20171013122345.86304-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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

Apart from trampoline itself we also need place to store top level page
table in lower memory as we don't have a way to load 64-bit value into
CR3 from 32-bit mode. We only really need 8-bytes there as we only use
the very first entry of the page table.

place_trampoline() would choose an address for the trampoline page.
The implementation is based on reserve_bios_regions(). We take a page
next to end of lowmem.

We only need the page  for very short time, until main kernel image
setup its own page tables.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 87 ++++++++++++++++++++++++++------------
 arch/x86/boot/compressed/misc.c    | 25 +++++++++++
 2 files changed, 84 insertions(+), 28 deletions(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index cefe4958fda9..961c72755986 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -288,8 +288,23 @@ ENTRY(startup_64)
 	leaq	boot_stack_end(%rbx), %rsp
 
 #ifdef CONFIG_X86_5LEVEL
+/*
+ * We need trampoline in lower memory switch from 4- to 5-level paging for
+ * cases when bootloader put kernel above 4G, but didn't enable 5-level paging
+ * for us.
+ *
+ * We also have to have top page table in lower memory as we don't have a way
+ * to load 64-bit value into CR3 from 32-bit mode. We only need 8-bytes there
+ * as we only use the very first entry of the page table.
+ *
+ * The same page can be used to place both trampoline code and top level page
+ * table. place_trampoline() will find suitable place for the trampoline page.
+ * Code will be placed with offset 0x100 from beginning of the page.
+ */
+#define LVL5_TRAMPOLINE_CODE	0x100
+
 	/* Preserve RBX across CPUID */
-	movq	%rbx, %r8
+	movq	%rbx, %r15
 
 	/* Check if leaf 7 is supported */
 	xorl	%eax, %eax
@@ -307,9 +322,6 @@ ENTRY(startup_64)
 	andl	$(1 << 16), %ecx
 	jz	lvl5
 
-	/* Restore RBX */
-	movq	%r8, %rbx
-
 	/* Check if 5-level paging has already been enabled */
 	movq	%cr4, %rax
 	testl	$X86_CR4_LA57, %eax
@@ -323,34 +335,53 @@ ENTRY(startup_64)
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
+	/*
+	 * Find sitable place for trampoline.
+	 * The address will be stored in RBX.
+	 */
+	call	place_trampoline
+	movq	%rax, %rbx
+
+	/* Preserve RSI, to be used by movsb below */
+	movq	%rsi, %r14
+
+	/* Copy trampoline code in place */
+	leaq	lvl5_trampoline_src(%rip), %rsi
+	leaq	LVL5_TRAMPOLINE_CODE(%rbx), %rdi
+	movq	$(lvl5_trampoline_end - lvl5_trampoline_src), %rcx
+	rep	movsb
+
+	/* Restore RSI */
+	movq	%r14, %rsi
 
 	/*
-	 * Setup current CR3 as the first and only entry in a new top level
+	 * Setup current CR3 as the first and the only entry in a new top level
 	 * page table.
 	 */
 	movq	%cr3, %rdi
 	leaq	0x7 (%rdi), %rax
-	movq	%rax, lvl5_pgtable(%rbx)
+	movq	%rax, (%rbx)
+
+	/*
+	 * Load address of lvl5 into RDI.
+	 * It will be used to return address from trampoline.
+	 */
+	leaq	lvl5(%rip), %rdi
 
 	/* Switch to compatibility mode (CS.L = 0 CS.D = 1) via far return */
 	pushq	$__KERNEL32_CS
-	leaq	compatible_mode(%rip), %rax
+	leaq	LVL5_TRAMPOLINE_CODE(%rbx), %rax
 	pushq	%rax
 	lretq
 lvl5:
 	/* Restore RBX */
-	movq	%r8, %rbx
+	movq	%r15, %rbx
 #endif
 
 	/* Zero EFLAGS */
@@ -488,9 +519,9 @@ relocated:
  */
 	jmp	*%rax
 
-	.code32
 #ifdef CONFIG_X86_5LEVEL
-compatible_mode:
+	.code32
+lvl5_trampoline_src:
 	/* Setup data and stack segments */
 	movl	$__KERNEL_DS, %eax
 	movl	%eax, %ds
@@ -502,7 +533,7 @@ compatible_mode:
 	movl	%eax, %cr0
 
 	/* Point CR3 to 5-level paging */
-	leal	lvl5_pgtable(%ebx), %eax
+	leal	(%ebx), %eax
 	movl	%eax, %cr3
 
 	/* Enable PAE and LA57 mode */
@@ -510,23 +541,27 @@ compatible_mode:
 	orl	$(X86_CR4_PAE | X86_CR4_LA57), %eax
 	movl	%eax, %cr4
 
-	/* Calculate address we are running at */
-	call	1f
-1:	popl	%edi
-	subl	$1b, %edi
+	/* Calculate address of lvl5_enabled once we are in trampoline */
+	leal	lvl5_enabled - lvl5_trampoline_src + LVL5_TRAMPOLINE_CODE (%ebx), %eax
 
 	/* Prepare stack for far return to Long Mode */
 	pushl	$__KERNEL_CS
-	leal	lvl5(%edi), %eax
-	push	%eax
+	pushl	%eax
 
 	/* Enable paging back */
 	movl	$(X86_CR0_PG | X86_CR0_PE), %eax
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
@@ -584,7 +619,3 @@ boot_stack_end:
 	.balign 4096
 pgtable:
 	.fill BOOT_PGT_SIZE, 1, 0
-#ifdef CONFIG_X86_5LEVEL
-lvl5_pgtable:
-	.fill PAGE_SIZE, 1, 0
-#endif
diff --git a/arch/x86/boot/compressed/misc.c b/arch/x86/boot/compressed/misc.c
index c14217cd0155..809c91837521 100644
--- a/arch/x86/boot/compressed/misc.c
+++ b/arch/x86/boot/compressed/misc.c
@@ -415,3 +415,28 @@ void fortify_panic(const char *name)
 {
 	error("detected buffer overflow");
 }
+
+#ifdef CONFIG_X86_5LEVEL
+
+#define BIOS_START_MIN		0x20000U	/* 128K, less than this is insane */
+#define BIOS_START_MAX		0x9f000U	/* 640K, absolute maximum */
+
+asmlinkage __visible unsigned int place_trampoline()
+{
+	unsigned int bios_start, ebda_start;
+
+	/* Based on reserve_bios_regions() */
+
+	ebda_start = *(unsigned short *)0x40e << 4;
+	bios_start = *(unsigned short *)0x413 << 10;
+
+	if (bios_start < BIOS_START_MIN || bios_start > BIOS_START_MAX)
+		bios_start = BIOS_START_MAX;
+
+	if (ebda_start > BIOS_START_MIN && ebda_start < bios_start)
+		bios_start = ebda_start;
+
+	/* Place trampoline one page below end of low memory, alinged to 4k */
+	return round_down(bios_start - PAGE_SIZE, PAGE_SIZE);
+}
+#endif
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

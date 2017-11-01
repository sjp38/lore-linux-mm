Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C54E6B025E
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 07:55:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b192so2339206pga.14
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 04:55:13 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d17si730499pgo.491.2017.11.01.04.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 04:55:11 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/4] x86/boot/compressed/64: Handle 5-level paging boot if kernel is above 4G
Date: Wed,  1 Nov 2017 14:55:03 +0300
Message-Id: <20171101115503.18358-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
References: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
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

We only need the memory for very short time, until main kernel image
setup its own page tables.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S | 72 ++++++++++++++++++++++++--------------
 1 file changed, 45 insertions(+), 27 deletions(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index 4d1555b39de0..e8331f5a77f4 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -32,6 +32,7 @@
 #include <asm/processor-flags.h>
 #include <asm/asm-offsets.h>
 #include <asm/bootparam.h>
+#include "pagetable.h"
 
 /*
  * Locally defined symbols should be marked hidden:
@@ -288,6 +289,19 @@ ENTRY(startup_64)
 	leaq	boot_stack_end(%rbx), %rsp
 
 #ifdef CONFIG_X86_5LEVEL
+/*
+ * We need trampoline in lower memory switch from 4- to 5-level paging for
+ * cases when bootloader put kernel above 4G, but didn't enable 5-level paging
+ * for us.
+ *
+ * We also have to have top page table in lower memory as we don't have a way
+ * to load 64-bit value into CR3 from 32-bit mode. We only need 8-bytes there
+ * as we only use the very first entry of the page table, but we allocate whole
+ * page anyway. We cannot have the code in the same because, there's hazard
+ * that a CPU would read page table speculatively and get confused seeing
+ * garbage.
+ */
+
 	/*
 	 * Check if we need to enable 5-level paging.
 	 * RSI holds real mode data and need to be preserved across
@@ -309,8 +323,8 @@ ENTRY(startup_64)
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
@@ -327,26 +341,20 @@ ENTRY(startup_64)
 	popq	%rsi
 	movq	%rax, %rcx
 
-	/* Clear additional page table */
-	leaq	lvl5_pgtable(%rbx), %rdi
-	xorq	%rax, %rax
-	movq	$(PAGE_SIZE/8), %rcx
-	rep	stosq
-
 	/*
-	 * Setup current CR3 as the first and only entry in a new top level
-	 * page table.
+	 * Load address of lvl5 into RDI.
+	 * It will be used to return address from trampoline.
 	 */
-	movq	%cr3, %rdi
-	leaq	0x7 (%rdi), %rax
-	movq	%rax, lvl5_pgtable(%rbx)
+	leaq	lvl5(%rip), %rdi
 
 	/* Switch to compatibility mode (CS.L = 0 CS.D = 1) via far return */
 	pushq	$__KERNEL32_CS
-	leaq	compatible_mode(%rip), %rax
+	leaq	LVL5_TRAMPOLINE_CODE_OFF(%rcx), %rax
 	pushq	%rax
 	lretq
 lvl5:
+	/* Restore stack, 32-bit trampoline uses own stack */
+	leaq	boot_stack_end(%rbx), %rsp
 #endif
 
 	/* Zero EFLAGS */
@@ -484,22 +492,30 @@ relocated:
  */
 	jmp	*%rax
 
-	.code32
 #ifdef CONFIG_X86_5LEVEL
+	.code32
+/*
+ * This is 32-bit trampoline that will be copied over to low memory.
+ *
+ * RDI contains return address (might be above 4G).
+ * ECX contains the base address of trampoline memory.
+ */
 ENTRY(lvl5_trampoline_src)
-compatible_mode:
 	/* Setup data and stack segments */
 	movl	$__KERNEL_DS, %eax
 	movl	%eax, %ds
 	movl	%eax, %ss
 
+	/* Setup new stack at the end of trampoline memory */
+	leal	LVL5_TRAMPOLINE_STACK_END (%ecx), %esp
+
 	/* Disable paging */
 	movl	%cr0, %eax
 	btrl	$X86_CR0_PG_BIT, %eax
 	movl	%eax, %cr0
 
 	/* Point CR3 to 5-level paging */
-	leal	lvl5_pgtable(%ebx), %eax
+	leal	LVL5_TRAMPOLINE_PGTABLE_OFF (%ecx), %eax
 	movl	%eax, %cr3
 
 	/* Enable PAE and LA57 mode */
@@ -507,23 +523,29 @@ compatible_mode:
 	orl	$(X86_CR4_PAE | X86_CR4_LA57), %eax
 	movl	%eax, %cr4
 
-	/* Calculate address we are running at */
-	call	1f
-1:	popl	%edi
-	subl	$1b, %edi
+	/* Calculate address of lvl5_enabled once we are in trampoline */
+	leal	lvl5_enabled - lvl5_trampoline_src + LVL5_TRAMPOLINE_CODE_OFF (%ecx), %eax
 
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
+
+	/* Bound size of trampoline code */
+	.org	lvl5_trampoline_src + LVL5_TRAMPOLINE_CODE_SIZE
 #endif
 
+	.code32
 no_longmode:
 	/* This isn't an x86-64 CPU so hang */
 1:
@@ -581,7 +603,3 @@ boot_stack_end:
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

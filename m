Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F64B6B025E
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 09:00:32 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i14so193608pgf.13
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 06:00:32 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id y101si111971plh.768.2017.12.05.06.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 06:00:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 3/4] x86/boot/compressed/64: Introduce place_trampoline()
Date: Tue,  5 Dec 2017 16:59:41 +0300
Message-Id: <20171205135942.24634-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
References: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If a bootloader enables 64-bit mode with 4-level paging, we might need to
switch over to 5-level paging. The switching requires disabling paging.
It works fine if kernel itself is loaded below 4G.

But if the bootloader put the kernel above 4G (not sure if anybody does
this), we would loose control as soon as paging is disabled as code
becomes unreachable.

To handle the situation, we need a trampoline in lower memory that would
take care about switching on 5-level paging.

Apart from the trampoline code itself we also need a place to store top
level page table in lower memory as we don't have a way to load 64-bit
value into CR3 from 32-bit mode. We only really need 8-bytes there as we
only use the very first entry of the page table. But we allocate whole
page anyway.

We cannot have code in the same page as page table because there's
hazard that a CPU would read page table speculatively and get confused
seeing garbage.

We also need a small stack in the trampoline to re-enable long mode via
long return. But stack and code can share the page just fine.

This patch introduces paging_prepare() that checks if we need to enable
5-level paging and then finds a right spot in lower memory for the
trampoline. Then it copies trampoline code there and setups new top
level page table for 5-level paging.

At this point we do all the preparation, but not yet use trampoline.
It will be done in the following patch.

The trampoline will be used even on 4-level paging machine. This way we
will get better coverage and keep trampoline code in shape.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S    | 42 +++++++++++------------
 arch/x86/boot/compressed/pgtable.h    | 18 ++++++++++
 arch/x86/boot/compressed/pgtable_64.c | 64 +++++++++++++++++++++++++++++------
 3 files changed, 91 insertions(+), 33 deletions(-)
 create mode 100644 arch/x86/boot/compressed/pgtable.h

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index fc313e29fe2c..92d47b1bf10a 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -304,20 +304,6 @@ ENTRY(startup_64)
 	/* Set up the stack */
 	leaq	boot_stack_end(%rbx), %rsp
 
-#ifdef CONFIG_X86_5LEVEL
-	/*
-	 * Check if we need to enable 5-level paging.
-	 * RSI holds real mode data and need to be preserved across
-	 * a function call.
-	 */
-	pushq	%rsi
-	call	l5_paging_required
-	popq	%rsi
-
-	/* If l5_paging_required() returned zero, we're done here. */
-	cmpq	$0, %rax
-	je	lvl5
-
 	/*
 	 * At this point we are in long mode with 4-level paging enabled,
 	 * but we want to enable 5-level paging.
@@ -325,12 +311,28 @@ ENTRY(startup_64)
 	 * The problem is that we cannot do it directly. Setting LA57 in
 	 * long mode would trigger #GP. So we need to switch off long mode
 	 * first.
+	 */
+
+	/*
+	 * paging_prepare() would setup trampoline and check if we need to
+	 * enable 5-level paging.
 	 *
-	 * NOTE: This is not going to work if bootloader put us above 4G
-	 * limit.
+	 * Address of the trampoline is returned in RAX. The bit 0 is used
+	 * to encode if we need to enabled 5-level paging.
 	 *
-	 * The first step is go into compatibility mode.
+	 * RSI holds real mode data and need to be preserved across
+	 * a function call.
 	 */
+	pushq	%rsi
+	call	paging_prepare
+	popq	%rsi
+
+	/* Save trampoline address in RCX */
+	movq	%rax, %rcx
+	andq	$~1, %rcx
+
+	testq	$1, %rax
+	jz	lvl5
 
 	/* Clear additional page table */
 	leaq	lvl5_pgtable(%rbx), %rdi
@@ -352,7 +354,6 @@ ENTRY(startup_64)
 	pushq	%rax
 	lretq
 lvl5:
-#endif
 
 	/* Zero EFLAGS */
 	pushq	$0
@@ -490,7 +491,7 @@ relocated:
 	jmp	*%rax
 
 	.code32
-#ifdef CONFIG_X86_5LEVEL
+ENTRY(trampoline_32bit_src)
 compatible_mode:
 	/* Setup data and stack segments */
 	movl	$__KERNEL_DS, %eax
@@ -526,7 +527,6 @@ compatible_mode:
 	movl	%eax, %cr0
 
 	lret
-#endif
 
 no_longmode:
 	/* This isn't an x86-64 CPU so hang */
@@ -585,7 +585,5 @@ boot_stack_end:
 	.balign 4096
 pgtable:
 	.fill BOOT_PGT_SIZE, 1, 0
-#ifdef CONFIG_X86_5LEVEL
 lvl5_pgtable:
 	.fill PAGE_SIZE, 1, 0
-#endif
diff --git a/arch/x86/boot/compressed/pgtable.h b/arch/x86/boot/compressed/pgtable.h
new file mode 100644
index 000000000000..1a88f58227c3
--- /dev/null
+++ b/arch/x86/boot/compressed/pgtable.h
@@ -0,0 +1,18 @@
+#ifndef BOOT_COMPRESSED_PAGETABLE_H
+#define BOOT_COMPRESSED_PAGETABLE_H
+
+#define TRAMPOLINE_32BIT_SIZE		(2 * PAGE_SIZE)
+
+#define TRAMPOLINE_32BIT_PGTABLE_OFF	0
+
+#define TRAMPOLINE_32BIT_CODE_OFF	PAGE_SIZE
+#define TRAMPOLINE_32BIT_CODE_SIZE	0x60
+
+#define TRAMPOLINE_32BIT_STACK_END	TRAMPOLINE_32BIT_SIZE
+
+#ifndef __ASSEMBLER__
+
+extern void (*trampoline_32bit_src)(void *return_ptr);
+
+#endif /* __ASSEMBLER__ */
+#endif /* BOOT_COMPRESSED_PAGETABLE_H */
diff --git a/arch/x86/boot/compressed/pgtable_64.c b/arch/x86/boot/compressed/pgtable_64.c
index 491fa2d08bca..f72f87c2be8c 100644
--- a/arch/x86/boot/compressed/pgtable_64.c
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -1,4 +1,6 @@
 #include <asm/processor.h>
+#include "pgtable.h"
+#include "../string.h"
 
 /*
  * __force_order is used by special_insns.h asm code to force instruction
@@ -11,19 +13,59 @@
  */
 unsigned long __force_order;
 
-int l5_paging_required(void)
+#define BIOS_START_MIN		0x20000U	/* 128K, less than this is insane */
+#define BIOS_START_MAX		0x9f000U	/* 640K, absolute maximum */
+
+unsigned long paging_prepare(void)
 {
-	/* Check if leaf 7 is supported. */
-	if (native_cpuid_eax(0) < 7)
-		return 0;
+	unsigned long bios_start, ebda_start, trampoline_start, *trampoline;
+	int l5_required = 0;
+
+	/* Check if la57 is desired and supported */
+	if (IS_ENABLED(CONFIG_X86_5LEVEL) && native_cpuid_eax(0) >= 7 &&
+			(native_cpuid_ecx(7) & (1 << (X86_FEATURE_LA57 & 31))))
+		l5_required = 1;
+
+	/*
+	 * Find a suitable spot for the trampoline.
+	 * Code is based on reserve_bios_regions().
+	 */
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
+	/* Place the trampoline just below the end of low memory, aligned to 4k */
+	trampoline_start = bios_start - TRAMPOLINE_32BIT_SIZE;
+	trampoline_start = round_down(trampoline_start, PAGE_SIZE);
+
+	trampoline = (unsigned long *)trampoline_start;
+
+	/* Clear trampoline memory first */
+	memset(trampoline, 0, TRAMPOLINE_32BIT_SIZE);
 
-	/* Check if la57 is supported. */
-	if (!(native_cpuid_ecx(7) & (1 << (X86_FEATURE_LA57 & 31))))
-		return 0;
+	/* Copy trampoline code in place */
+	memcpy(trampoline + TRAMPOLINE_32BIT_CODE_OFF / sizeof(unsigned long),
+			&trampoline_32bit_src, TRAMPOLINE_32BIT_CODE_SIZE);
 
-	/* Check if 5-level paging has already been enabled. */
-	if (native_read_cr4() & X86_CR4_LA57)
-		return 0;
+	/*
+	 * For 5-level paging, setup current CR3 as the first and
+	 * the only entry in a new top level page table.
+	 *
+	 * For 4-level paging, trampoline wouldn't touch CR3.
+	 * KASLR relies on CR3 pointing to _pgtable.
+	 * See initialize_identity_maps.
+	 */
+	if (l5_required) {
+		trampoline[TRAMPOLINE_32BIT_PGTABLE_OFF] =
+			__native_read_cr3() + _PAGE_TABLE_NOENC;
+	}
 
-	return 1;
+	/* Bit 0 is used to encode if 5-level paging is required */
+	return trampoline_start | l5_required;
 }
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

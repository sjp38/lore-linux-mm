Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFF6800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 12:09:28 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id q195so1322960ioe.5
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:09:28 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 80si4810932ioo.242.2018.01.23.09.09.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 09:09:27 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6, RESEND 3/4] x86/boot/compressed/64: Prepare trampoline memory
Date: Tue, 23 Jan 2018 20:09:12 +0300
Message-Id: <20180123170913.41791-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180123170913.41791-1-kirill.shutemov@linux.intel.com>
References: <20180123170913.41791-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If a bootloader enables 64-bit mode with 4-level paging, we might need to
switch over to 5-level paging. The switching requires the disabling
paging. It works fine if kernel itself is loaded below 4G.

But if the bootloader put the kernel above 4G (not sure if anybody does
this), we would lose control as soon as paging is disabled, because the
code becomes unreachable to the CPU.

To handle the situation, we need a trampoline in lower memory that would
take care of switching on 5-level paging.

Apart from the trampoline code itself we also need a place to store top
level page table in lower memory as we don't have a way to load 64-bit
values into CR3 in 32-bit mode. We only really need 8 bytes there as we
only use the very first entry of the page table. But we allocate a whole
page anyway.

We cannot have the code in the same page as the page table because there's
a risk that a CPU would read the page table speculatively and get confused
by seeing garbage. It's never a good idea to have junk in PTE entries
visible to the CPU.

We also need a small stack in the trampoline to re-enable long mode via
long return. But stack and code can share the page just fine.

This patch changes paging_prepare() to find a right spot in lower memory
for the trampoline. Then it copies the trampoline code there and sets up
the new top level page table for 5-level paging.

At this point we do all the preparation, but don't use trampoline yet.
It will be done in the following patch.

The trampoline will be used even on 4-level paging machines. This way we
will get better test coverage and the keep the trampoline code in shape.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S    |  3 ++-
 arch/x86/boot/compressed/pgtable.h    | 18 ++++++++++++++
 arch/x86/boot/compressed/pgtable_64.c | 44 +++++++++++++++++++++++++++++++++++
 3 files changed, 64 insertions(+), 1 deletion(-)
 create mode 100644 arch/x86/boot/compressed/pgtable.h

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index 10b4df46de84..1bcc62a232f6 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -491,8 +491,9 @@ relocated:
 	jmp	*%rax
 
 	.code32
+ENTRY(trampoline_32bit_src)
 compatible_mode:
-	/* Setup data and stack segments */
+	/* Set up data and stack segments */
 	movl	$__KERNEL_DS, %eax
 	movl	%eax, %ds
 	movl	%eax, %ss
diff --git a/arch/x86/boot/compressed/pgtable.h b/arch/x86/boot/compressed/pgtable.h
new file mode 100644
index 000000000000..6e0db2260147
--- /dev/null
+++ b/arch/x86/boot/compressed/pgtable.h
@@ -0,0 +1,18 @@
+#ifndef BOOT_COMPRESSED_PAGETABLE_H
+#define BOOT_COMPRESSED_PAGETABLE_H
+
+#define TRAMPOLINE_32BIT_SIZE		(2 * PAGE_SIZE)
+
+#define TRAMPOLINE_32BIT_PGTABLE_OFFSET	0
+
+#define TRAMPOLINE_32BIT_CODE_OFFSET	PAGE_SIZE
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
index 3f1697fcc7a8..c8f9e93598d5 100644
--- a/arch/x86/boot/compressed/pgtable_64.c
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -1,4 +1,6 @@
 #include <asm/processor.h>
+#include "pgtable.h"
+#include "../string.h"
 
 /*
  * __force_order is used by special_insns.h asm code to force instruction
@@ -9,6 +11,9 @@
  */
 unsigned long __force_order;
 
+#define BIOS_START_MIN		0x20000U	/* 128K, less than this is insane */
+#define BIOS_START_MAX		0x9f000U	/* 640K, absolute maximum */
+
 struct paging_config {
 	unsigned long trampoline_start;
 	unsigned long l5_required;
@@ -17,11 +22,50 @@ struct paging_config {
 struct paging_config paging_prepare(void)
 {
 	struct paging_config paging_config = {};
+	unsigned long bios_start, ebda_start, *trampoline;
 
 	/* Check if LA57 is desired and supported */
 	if (IS_ENABLED(CONFIG_X86_5LEVEL) && native_cpuid_eax(0) >= 7 &&
 			(native_cpuid_ecx(7) & (1 << (X86_FEATURE_LA57 & 31))))
 		paging_config.l5_required = 1;
 
+	/*
+	 * Find a suitable spot for the trampoline.
+	 * This code is based on reserve_bios_regions().
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
+	paging_config.trampoline_start = bios_start - TRAMPOLINE_32BIT_SIZE;
+	paging_config.trampoline_start = round_down(paging_config.trampoline_start, PAGE_SIZE);
+
+	trampoline = (unsigned long *)paging_config.trampoline_start;
+
+	/* Clear trampoline memory first */
+	memset(trampoline, 0, TRAMPOLINE_32BIT_SIZE);
+
+	/* Copy trampoline code in place */
+	memcpy(trampoline + TRAMPOLINE_32BIT_CODE_OFFSET / sizeof(unsigned long),
+			&trampoline_32bit_src, TRAMPOLINE_32BIT_CODE_SIZE);
+
+	/*
+	 * For 5-level paging, set up current CR3 as the first and
+	 * the only entry in a new top level page table.
+	 *
+	 * For 4-level paging, trampoline wouldn't touch CR3.
+	 * KASLR relies on CR3 pointing to _pgtable.
+	 * See initialize_identity_maps().
+	 */
+	if (paging_config.l5_required)
+		trampoline[TRAMPOLINE_32BIT_PGTABLE_OFFSET] = __native_read_cr3() + _PAGE_TABLE_NOENC;
+
 	return paging_config;
 }
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

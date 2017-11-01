Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 18A8D6B0260
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 07:55:43 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u23so2363686pgo.4
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 04:55:43 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id c4si660312pgt.539.2017.11.01.04.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 04:55:41 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/4] x86/boot/compressed/64: Introduce place_trampoline()
Date: Wed,  1 Nov 2017 14:55:02 +0300
Message-Id: <20171101115503.18358-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
References: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If bootloader enables 64-bit mode with 4-level paging, we need to
switch over to 5-level paging. The switching requires disabling paging.
It works fine if kernel itself is loaded below 4G.

If bootloader put the kernel above 4G (not sure if anybody does this),
we would loose control as soon as paging is disabled as code becomes
unreachable.

To handle the situation, we need a trampoline in lower memory that would
take care about switching on 5-level paging.

Apart from trampoline itself we also need place to store top level page
table in lower memory as we don't have a way to load 64-bit value into
CR3 from 32-bit mode. We only really need 8-bytes there as we only use
the very first entry of the page table. But we allocate whole page
anyway. We cannot have the code in the same because, there's hazard that
a CPU would read page table speculatively and get confused seeing
garbage.

This patch introduces place_trampoline() that finds right spot in lower
memory for trampoline, copies trampoline code there and setups new top
level page table for 5-level paging.

At this point we do all the preparation, but not yet use trampoline.
It will be done in following patch.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S   | 13 +++++++++++
 arch/x86/boot/compressed/pagetable.c | 42 ++++++++++++++++++++++++++++++++++++
 arch/x86/boot/compressed/pagetable.h | 18 ++++++++++++++++
 3 files changed, 73 insertions(+)
 create mode 100644 arch/x86/boot/compressed/pagetable.h

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index 6ac8239af2b6..4d1555b39de0 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -315,6 +315,18 @@ ENTRY(startup_64)
 	 * The first step is go into compatibility mode.
 	 */
 
+	/*
+	 * Find suitable place for trampoline and populate it.
+	 * The address will be stored in RCX.
+	 *
+	 * RSI holds real mode data and need to be preserved across
+	 * a function call.
+	 */
+	pushq	%rsi
+	call	place_trampoline
+	popq	%rsi
+	movq	%rax, %rcx
+
 	/* Clear additional page table */
 	leaq	lvl5_pgtable(%rbx), %rdi
 	xorq	%rax, %rax
@@ -474,6 +486,7 @@ relocated:
 
 	.code32
 #ifdef CONFIG_X86_5LEVEL
+ENTRY(lvl5_trampoline_src)
 compatible_mode:
 	/* Setup data and stack segments */
 	movl	$__KERNEL_DS, %eax
diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
index cd2dd49333cc..74245e9e875f 100644
--- a/arch/x86/boot/compressed/pagetable.c
+++ b/arch/x86/boot/compressed/pagetable.c
@@ -23,6 +23,8 @@
 #undef CONFIG_AMD_MEM_ENCRYPT
 
 #include "misc.h"
+#include "pagetable.h"
+#include "../string.h"
 
 /* These actually do the work of building the kernel identity maps. */
 #include <asm/init.h>
@@ -172,4 +174,44 @@ int need_to_enabled_l5(void)
 
 	return 1;
 }
+
+#define BIOS_START_MIN		0x20000U	/* 128K, less than this is insane */
+#define BIOS_START_MAX		0x9f000U	/* 640K, absolute maximum */
+
+unsigned long *place_trampoline(void)
+{
+	unsigned long bios_start, ebda_start, trampoline_start, *trampoline;
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
+	/* Place trampoline below end of low memory, aligned to 4k */
+	trampoline_start = bios_start - LVL5_TRAMPOLINE_SIZE;
+	trampoline_start = round_down(trampoline_start, PAGE_SIZE);
+
+	trampoline = (unsigned long *)trampoline_start;
+
+	/* Clear trampoline memory first */
+	memset(trampoline, 0, LVL5_TRAMPOLINE_SIZE);
+
+	/* Copy trampoline code in place */
+	memcpy(trampoline + LVL5_TRAMPOLINE_CODE_OFF / sizeof(unsigned long),
+			&lvl5_trampoline_src, LVL5_TRAMPOLINE_CODE_SIZE);
+
+	/*
+	 * Setup current CR3 as the first and the only entry in a new top level
+	 * page table.
+	 */
+	trampoline[0] = __read_cr3() + _PAGE_TABLE_NOENC;
+
+	return trampoline;
+}
 #endif
diff --git a/arch/x86/boot/compressed/pagetable.h b/arch/x86/boot/compressed/pagetable.h
new file mode 100644
index 000000000000..906436cc1c02
--- /dev/null
+++ b/arch/x86/boot/compressed/pagetable.h
@@ -0,0 +1,18 @@
+#ifndef BOOT_COMPRESSED_PAGETABLE_H
+#define BOOT_COMPRESSED_PAGETABLE_H
+
+#define LVL5_TRAMPOLINE_SIZE		(2 * PAGE_SIZE)
+
+#define LVL5_TRAMPOLINE_PGTABLE_OFF	0
+
+#define LVL5_TRAMPOLINE_CODE_OFF	PAGE_SIZE
+#define LVL5_TRAMPOLINE_CODE_SIZE	0x40
+
+#define LVL5_TRAMPOLINE_STACK_END	LVL5_TRAMPOLINE_SIZE
+
+#ifndef __ASSEMBLER__
+
+extern void (*lvl5_trampoline_src)(void *return_ptr);
+
+#endif /* __ASSEMBLER__ */
+#endif /* BOOT_COMPRESSED_PAGETABLE_H */
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

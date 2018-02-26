Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B026B6B0011
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:05:05 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f125so7852440pfb.21
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 10:05:05 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g7-v6si7004759plt.91.2018.02.26.10.05.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 10:05:04 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/5] x86/boot/compressed/64: Find a place for 32-bit trampoline
Date: Mon, 26 Feb 2018 21:04:48 +0300
Message-Id: <20180226180451.86788-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
References: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If a bootloader enables 64-bit mode with 4-level paging, we might need to
switch over to 5-level paging. The switching requires the disabling of
paging, which works fine if kernel itself is loaded below 4G.

But if the bootloader puts the kernel above 4G (not sure if anybody does
this), we would lose control as soon as paging is disabled, because the
code becomes unreachable to the CPU.

To handle the situation, we need a trampoline in lower memory that would
take care of switching on 5-level paging.

This patch finds a spot in low memory for a trampoline.

The heuristic is based on code in reserve_bios_regions().

We find the end of low memory based on BIOS and EBDA start addresses.
The trampoline is put just before end of low memory. It's mimic approach
taken to allocate memory for realtime trampoline.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/misc.c       |  4 ++++
 arch/x86/boot/compressed/pgtable.h    | 11 +++++++++++
 arch/x86/boot/compressed/pgtable_64.c | 34 ++++++++++++++++++++++++++++++++++
 3 files changed, 49 insertions(+)
 create mode 100644 arch/x86/boot/compressed/pgtable.h

diff --git a/arch/x86/boot/compressed/misc.c b/arch/x86/boot/compressed/misc.c
index b50c42455e25..e58409667b13 100644
--- a/arch/x86/boot/compressed/misc.c
+++ b/arch/x86/boot/compressed/misc.c
@@ -14,6 +14,7 @@
 
 #include "misc.h"
 #include "error.h"
+#include "pgtable.h"
 #include "../string.h"
 #include "../voffset.h"
 
@@ -372,6 +373,9 @@ asmlinkage __visible void *extract_kernel(void *rmode, memptr heap,
 	debug_putaddr(output_len);
 	debug_putaddr(kernel_total_size);
 
+	/* Report address of 32-bit trampoline */
+	debug_putaddr(trampoline_32bit);
+
 	/*
 	 * The memory hole needed for the kernel is the larger of either
 	 * the entire decompressed kernel plus relocation table, or the
diff --git a/arch/x86/boot/compressed/pgtable.h b/arch/x86/boot/compressed/pgtable.h
new file mode 100644
index 000000000000..57722a2fe2a0
--- /dev/null
+++ b/arch/x86/boot/compressed/pgtable.h
@@ -0,0 +1,11 @@
+#ifndef BOOT_COMPRESSED_PAGETABLE_H
+#define BOOT_COMPRESSED_PAGETABLE_H
+
+#define TRAMPOLINE_32BIT_SIZE		(2 * PAGE_SIZE)
+
+#ifndef __ASSEMBLER__
+
+extern unsigned long *trampoline_32bit;
+
+#endif /* __ASSEMBLER__ */
+#endif /* BOOT_COMPRESSED_PAGETABLE_H */
diff --git a/arch/x86/boot/compressed/pgtable_64.c b/arch/x86/boot/compressed/pgtable_64.c
index 45c76eff2718..21d5cc1cd5fa 100644
--- a/arch/x86/boot/compressed/pgtable_64.c
+++ b/arch/x86/boot/compressed/pgtable_64.c
@@ -1,4 +1,5 @@
 #include <asm/processor.h>
+#include "pgtable.h"
 
 /*
  * __force_order is used by special_insns.h asm code to force instruction
@@ -9,14 +10,27 @@
  */
 unsigned long __force_order;
 
+#define BIOS_START_MIN		0x20000U	/* 128K, less than this is insane */
+#define BIOS_START_MAX		0x9f000U	/* 640K, absolute maximum */
+
 struct paging_config {
 	unsigned long trampoline_start;
 	unsigned long l5_required;
 };
 
+/*
+ * Trampoline address will be printed by extract_kernel() for debugging
+ * purposes.
+ *
+ * Avoid putting the pointer into .bss as it will be cleared between
+ * paging_prepare() and extract_kernel().
+ */
+unsigned long *trampoline_32bit __section(.data);
+
 struct paging_config paging_prepare(void)
 {
 	struct paging_config paging_config = {};
+	unsigned long bios_start, ebda_start;
 
 	/*
 	 * Check if LA57 is desired and supported.
@@ -35,5 +49,25 @@ struct paging_config paging_prepare(void)
 		paging_config.l5_required = 1;
 	}
 
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
+	trampoline_32bit = (unsigned long *)paging_config.trampoline_start;
+
 	return paging_config;
 }
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

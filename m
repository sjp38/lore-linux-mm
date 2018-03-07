Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 855FF6B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 04:36:22 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y10so797914pge.2
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 01:36:22 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q22si11178560pgn.210.2018.03.07.01.36.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 01:36:20 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 2/5] x86/boot/compressed/64: Find a place for 32-bit trampoline
Date: Wed,  7 Mar 2018 12:36:10 +0300
Message-Id: <20180307093610.49121-1-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180227154217.69347-1-kirill.shutemov@linux.intel.com>
References: <20180227154217.69347-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
Tested-by: Borislav Petkov <bp@suse.de>
---
 arch/x86/boot/compressed/misc.c       |  6 ++++++
 arch/x86/boot/compressed/pgtable.h    | 13 +++++++++++++
 arch/x86/boot/compressed/pgtable_64.c | 34 ++++++++++++++++++++++++++++++++++
 3 files changed, 53 insertions(+)
 create mode 100644 arch/x86/boot/compressed/pgtable.h

diff --git a/arch/x86/boot/compressed/misc.c b/arch/x86/boot/compressed/misc.c
index b50c42455e25..8e4b55dd5df9 100644
--- a/arch/x86/boot/compressed/misc.c
+++ b/arch/x86/boot/compressed/misc.c
@@ -14,6 +14,7 @@
 
 #include "misc.h"
 #include "error.h"
+#include "pgtable.h"
 #include "../string.h"
 #include "../voffset.h"
 
@@ -372,6 +373,11 @@ asmlinkage __visible void *extract_kernel(void *rmode, memptr heap,
 	debug_putaddr(output_len);
 	debug_putaddr(kernel_total_size);
 
+#ifdef CONFIG_X86_64
+	/* Report address of 32-bit trampoline */
+	debug_putaddr(trampoline_32bit);
+#endif
+
 	/*
 	 * The memory hole needed for the kernel is the larger of either
 	 * the entire decompressed kernel plus relocation table, or the
diff --git a/arch/x86/boot/compressed/pgtable.h b/arch/x86/boot/compressed/pgtable.h
new file mode 100644
index 000000000000..58e654431e2a
--- /dev/null
+++ b/arch/x86/boot/compressed/pgtable.h
@@ -0,0 +1,13 @@
+#ifndef BOOT_COMPRESSED_PAGETABLE_H
+#define BOOT_COMPRESSED_PAGETABLE_H
+
+#define TRAMPOLINE_32BIT_SIZE		(2 * PAGE_SIZE)
+
+#ifndef __ASSEMBLY__
+
+#ifdef CONFIG_X86_64
+extern unsigned long *trampoline_32bit;
+#endif
+
+#endif /* __ASSEMBLY__ */
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

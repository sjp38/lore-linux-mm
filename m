Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF3FA6B000E
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:17:17 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i11so1744510pgq.10
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 03:17:17 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e1-v6si2695518ple.154.2018.02.14.03.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 03:17:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 8/9] x86/mm: Make __VIRTUAL_MASK_SHIFT dynamic
Date: Wed, 14 Feb 2018 14:16:55 +0300
Message-Id: <20180214111656.88514-9-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
References: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For boot-time switching between paging modes, we need to be able to
adjust virtual mask shifts.

The change doesn't affect the kernel image size much:

   text	   data	    bss	    dec	    hex	filename
8628892	4734340	1368064	14731296	 e0c820	vmlinux.before
8628966	4734340	1368064	14731370	 e0c86a	vmlinux.after

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/entry/entry_64.S            | 12 ++++++++++++
 arch/x86/include/asm/page_64_types.h |  2 +-
 arch/x86/mm/dump_pagetables.c        | 12 ++++++++++--
 arch/x86/mm/kaslr.c                  |  4 +++-
 4 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index cd216c9431e1..1608b13a0b36 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -260,8 +260,20 @@ GLOBAL(entry_SYSCALL_64_after_hwframe)
 	 * Change top bits to match most significant bit (47th or 56th bit
 	 * depending on paging mode) in the address.
 	 */
+#ifdef CONFIG_X86_5LEVEL
+	testl	$1, pgtable_l5_enabled(%rip)
+	jz	1f
+	shl	$(64 - 57), %rcx
+	sar	$(64 - 57), %rcx
+	jmp	2f
+1:
+	shl	$(64 - 48), %rcx
+	sar	$(64 - 48), %rcx
+2:
+#else
 	shl	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
 	sar	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
+#endif
 
 	/* If this changed %rcx, it was not canonical */
 	cmpq	%rcx, %r11
diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index d54a3d5b5b3b..fa7dc7cd8c19 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -56,7 +56,7 @@
 #define __PHYSICAL_MASK_SHIFT	52
 
 #ifdef CONFIG_X86_5LEVEL
-#define __VIRTUAL_MASK_SHIFT	56
+#define __VIRTUAL_MASK_SHIFT	(pgtable_l5_enabled ? 56 : 47)
 #else
 #define __VIRTUAL_MASK_SHIFT	47
 #endif
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 420058b05d39..9efee6f464ab 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -85,8 +85,12 @@ static struct addr_marker address_markers[] = {
 	[VMALLOC_START_NR]	= { 0UL,		"vmalloc() Area" },
 	[VMEMMAP_START_NR]	= { 0UL,		"Vmemmap" },
 #ifdef CONFIG_KASAN
-	[KASAN_SHADOW_START_NR]	= { KASAN_SHADOW_START,	"KASAN shadow" },
-	[KASAN_SHADOW_END_NR]	= { KASAN_SHADOW_END,	"KASAN shadow end" },
+	/*
+	 * These fields get initialized with the (dynamic)
+	 * KASAN_SHADOW_{START,END} values in pt_dump_init().
+	 */
+	[KASAN_SHADOW_START_NR]	= { 0UL,		"KASAN shadow" },
+	[KASAN_SHADOW_END_NR]	= { 0UL,		"KASAN shadow end" },
 #endif
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 	[LDT_NR]		= { 0UL,		"LDT remap" },
@@ -571,6 +575,10 @@ static int __init pt_dump_init(void)
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
 	address_markers[LDT_NR].start_address = LDT_BASE_ADDR;
 #endif
+#ifdef CONFIG_KASAN
+	address_markers[KASAN_SHADOW_START_NR].start_address = KASAN_SHADOW_START;
+	address_markers[KASAN_SHADOW_END_NR].start_address = KASAN_SHADOW_END;
+#endif
 #endif
 #ifdef CONFIG_X86_32
 	address_markers[VMALLOC_START_NR].start_address = VMALLOC_START;
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index 515b98a8ccee..d079878c6cbc 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -52,7 +52,7 @@ static __initdata struct kaslr_memory_region {
 	unsigned long *base;
 	unsigned long size_tb;
 } kaslr_regions[] = {
-	{ &page_offset_base, 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT) /* Maximum */ },
+	{ &page_offset_base, 0 },
 	{ &vmalloc_base, VMALLOC_SIZE_TB },
 	{ &vmemmap_base, 1 },
 };
@@ -93,6 +93,8 @@ void __init kernel_randomize_memory(void)
 	if (!kaslr_memory_enabled())
 		return;
 
+	kaslr_regions[0].size_tb = 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT);
+
 	/*
 	 * Update Physical memory mapping to available and
 	 * add padding if needed (especially for memory hotplug support).
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

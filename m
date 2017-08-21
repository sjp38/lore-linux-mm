Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 88F702803E9
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 11:29:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t193so59433524pgc.0
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 08:29:31 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t76si7342978pgc.539.2017.08.21.08.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 08:29:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 10/19] x86/mm: Make __PHYSICAL_MASK_SHIFT and __VIRTUAL_MASK_SHIFT dynamic
Date: Mon, 21 Aug 2017 18:29:07 +0300
Message-Id: <20170821152916.40124-11-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
References: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For boot-time switching between paging modes, we need to be able to
adjust physical and virtual mask shifts.

It has significant effect on kernel image size:

   text    data     bss     dec     hex filename
10710666        4880000  860160 16450826         fb050a vmlinux.before
10735996        4880000  860160 16476156         fb67fc vmlinux.after

The change is mostly due to __PHYSICAL_MASK_SHIFT change: the value is
used in pte_pfn() and many other page table manipulation routines
(directly or indirectly).

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/entry/entry_64.S            | 12 ++++++++++++
 arch/x86/include/asm/page_64_types.h |  4 ++--
 arch/x86/mm/dump_pagetables.c        |  8 ++++++--
 arch/x86/mm/kaslr.c                  |  4 +++-
 4 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index daf8936d0628..1dd5710315ef 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -273,8 +273,20 @@ return_from_SYSCALL_64:
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
index 0126d6bc2eb1..79d2180ffdec 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -52,8 +52,8 @@
 
 /* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
 #ifdef CONFIG_X86_5LEVEL
-#define __PHYSICAL_MASK_SHIFT	52
-#define __VIRTUAL_MASK_SHIFT	56
+#define __PHYSICAL_MASK_SHIFT	(pgtable_l5_enabled ? 52 : 46)
+#define __VIRTUAL_MASK_SHIFT	(pgtable_l5_enabled ? 56 : 47)
 #else
 #define __PHYSICAL_MASK_SHIFT	46
 #define __VIRTUAL_MASK_SHIFT	47
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 2eabd07ae2d2..a1d983a45ab0 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -82,8 +82,8 @@ static struct addr_marker address_markers[] = {
 	{ 0/* VMALLOC_START */, "vmalloc() Area" },
 	{ 0/* VMEMMAP_START */, "Vmemmap" },
 #ifdef CONFIG_KASAN
-	{ KASAN_SHADOW_START,	"KASAN shadow" },
-	{ KASAN_SHADOW_END,	"KASAN shadow end" },
+	{ 0/* KASAN_SHADOW_START */,	"KASAN shadow" },
+	{ 0/* KASAN_SHADOW_END */,	"KASAN shadow end" },
 #endif
 # ifdef CONFIG_X86_ESPFIX64
 	{ ESPFIX_BASE_ADDR,	"ESPfix Area", 16 },
@@ -515,6 +515,10 @@ static int __init pt_dump_init(void)
 	address_markers[LOW_KERNEL_NR].start_address = PAGE_OFFSET;
 	address_markers[VMALLOC_START_NR].start_address = VMALLOC_START;
 	address_markers[VMEMMAP_START_NR].start_address = VMEMMAP_START;
+#ifdef CONFIG_KASAN
+	address_markers[KASAN_SHADOW_START_NR].start_address = KASAN_SHADOW_START;
+	address_markers[KASAN_SHADOW_END_NR].start_address = KASAN_SHADOW_END;
+#endif
 #endif
 #ifdef CONFIG_X86_32
 	address_markers[VMALLOC_START_NR].start_address = VMALLOC_START;
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index e6420b18f6e0..5597dd0635dd 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -62,7 +62,7 @@ static __initdata struct kaslr_memory_region {
 	unsigned long *base;
 	unsigned long size_tb;
 } kaslr_regions[] = {
-	{ &page_offset_base, 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT) /* Maximum */ },
+	{ &page_offset_base, 0 },
 	{ &vmalloc_base, VMALLOC_SIZE_TB },
 	{ &vmemmap_base, 1 },
 };
@@ -106,6 +106,8 @@ void __init kernel_randomize_memory(void)
 	if (!kaslr_memory_enabled())
 		return;
 
+	kaslr_regions[0].size_tb = 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT);
+
 	/*
 	 * Update Physical memory mapping to available and
 	 * add padding if needed (especially for memory hotplug support).
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

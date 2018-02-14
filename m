Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1AF86B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:25:51 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a2so2182286pgn.7
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:25:51 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b9si1651107pff.42.2018.02.14.10.25.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 10:25:50 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/9] x86/mm: Adjust vmalloc base and size at boot-time
Date: Wed, 14 Feb 2018 21:25:37 +0300
Message-Id: <20180214182542.69302-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
References: <20180214182542.69302-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

vmalloc area has different placement and size depending on paging mode.
Let's adjust it during early boot accodring to machine capability.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable_64_types.h | 16 ++++++++++------
 arch/x86/kernel/head64.c                |  3 ++-
 arch/x86/mm/kaslr.c                     |  3 ++-
 3 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 59d971c85de5..686329994ade 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -102,25 +102,29 @@ extern unsigned int ptrs_per_p4d;
 #define LDT_PGD_ENTRY		(pgtable_l5_enabled ? LDT_PGD_ENTRY_L5 : LDT_PGD_ENTRY_L4)
 #define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
 
+#define __VMALLOC_BASE_L4	0xffffc90000000000
+#define __VMALLOC_BASE_L5 	0xffa0000000000000
+
+#define VMALLOC_SIZE_TB_L4	32UL
+#define VMALLOC_SIZE_TB_L5	12800UL
+
 #ifdef CONFIG_X86_5LEVEL
-# define VMALLOC_SIZE_TB	_AC(12800, UL)
-# define __VMALLOC_BASE		_AC(0xffa0000000000000, UL)
 # define __VMEMMAP_BASE		_AC(0xffd4000000000000, UL)
 #else
-# define VMALLOC_SIZE_TB	_AC(32, UL)
-# define __VMALLOC_BASE		_AC(0xffffc90000000000, UL)
 # define __VMEMMAP_BASE		_AC(0xffffea0000000000, UL)
 #endif
 
 #ifdef CONFIG_DYNAMIC_MEMORY_LAYOUT
 # define VMALLOC_START		vmalloc_base
+# define VMALLOC_SIZE_TB	(pgtable_l5_enabled ? VMALLOC_SIZE_TB_L5 : VMALLOC_SIZE_TB_L4)
 # define VMEMMAP_START		vmemmap_base
 #else
-# define VMALLOC_START		__VMALLOC_BASE
+# define VMALLOC_START		__VMALLOC_BASE_L4
+# define VMALLOC_SIZE_TB	VMALLOC_SIZE_TB_L4
 # define VMEMMAP_START		__VMEMMAP_BASE
 #endif /* CONFIG_DYNAMIC_MEMORY_LAYOUT */
 
-#define VMALLOC_END		(VMALLOC_START + _AC((VMALLOC_SIZE_TB << 40) - 1, UL))
+#define VMALLOC_END		(VMALLOC_START + (VMALLOC_SIZE_TB << 40) - 1)
 
 #define MODULES_VADDR		(__START_KERNEL_map + KERNEL_IMAGE_SIZE)
 /* The module sections ends with the start of the fixmap */
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 876d3bf2b23a..22bf2015254c 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -51,7 +51,7 @@ EXPORT_SYMBOL(ptrs_per_p4d);
 #ifdef CONFIG_DYNAMIC_MEMORY_LAYOUT
 unsigned long page_offset_base __ro_after_init = __PAGE_OFFSET_BASE_L4;
 EXPORT_SYMBOL(page_offset_base);
-unsigned long vmalloc_base __ro_after_init = __VMALLOC_BASE;
+unsigned long vmalloc_base __ro_after_init = __VMALLOC_BASE_L4;
 EXPORT_SYMBOL(vmalloc_base);
 unsigned long vmemmap_base __ro_after_init = __VMEMMAP_BASE;
 EXPORT_SYMBOL(vmemmap_base);
@@ -87,6 +87,7 @@ static void __head check_la57_support(unsigned long physaddr)
 	*fixup_int(&pgdir_shift, physaddr) = 48;
 	*fixup_int(&ptrs_per_p4d, physaddr) = 512;
 	*fixup_long(&page_offset_base, physaddr) = __PAGE_OFFSET_BASE_L5;
+	*fixup_long(&vmalloc_base, physaddr) = __VMALLOC_BASE_L5;
 }
 #else
 static void __head check_la57_support(unsigned long physaddr) {}
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index 7828a7ca3bba..641169d38184 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -50,7 +50,7 @@ static __initdata struct kaslr_memory_region {
 	unsigned long size_tb;
 } kaslr_regions[] = {
 	{ &page_offset_base, 0 },
-	{ &vmalloc_base, VMALLOC_SIZE_TB },
+	{ &vmalloc_base, 0 },
 	{ &vmemmap_base, 1 },
 };
 
@@ -94,6 +94,7 @@ void __init kernel_randomize_memory(void)
 		return;
 
 	kaslr_regions[0].size_tb = 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT);
+	kaslr_regions[1].size_tb = VMALLOC_SIZE_TB;
 
 	/*
 	 * Update Physical memory mapping to available and
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

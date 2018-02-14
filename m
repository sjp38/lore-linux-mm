Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9C16B0009
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:17:17 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 62so6759368ply.4
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 03:17:17 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e1-v6si2695518ple.154.2018.02.14.03.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 03:17:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 5/9] x86/mm: Make LDT_BASE_ADDR dynamic
Date: Wed, 14 Feb 2018 14:16:52 +0300
Message-Id: <20180214111656.88514-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
References: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

LDT_BASE_ADDR has different value in 4- and 5-level paging
configurations.

We need to make it dynamic in preparation for boot-time switching
between paging modes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable_64_types.h | 9 +++++----
 arch/x86/mm/dump_pagetables.c           | 5 ++++-
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 5e2d724f8f47..903e4d054bcb 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -92,18 +92,19 @@ extern unsigned int pgtable_l5_enabled;
  */
 #define MAXMEM			_AC(__AC(1, UL) << MAX_PHYSMEM_BITS, UL)
 
+#define LDT_PGD_ENTRY_L4	-3UL
+#define LDT_PGD_ENTRY_L5	-112UL
+#define LDT_PGD_ENTRY		(pgtable_l5_enabled ? LDT_PGD_ENTRY_L5 : LDT_PGD_ENTRY_L4)
+#define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
+
 #ifdef CONFIG_X86_5LEVEL
 # define VMALLOC_SIZE_TB	_AC(12800, UL)
 # define __VMALLOC_BASE		_AC(0xffa0000000000000, UL)
 # define __VMEMMAP_BASE		_AC(0xffd4000000000000, UL)
-# define LDT_PGD_ENTRY		_AC(-112, UL)
-# define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
 #else
 # define VMALLOC_SIZE_TB	_AC(32, UL)
 # define __VMALLOC_BASE		_AC(0xffffc90000000000, UL)
 # define __VMEMMAP_BASE		_AC(0xffffea0000000000, UL)
-# define LDT_PGD_ENTRY		_AC(-3, UL)
-# define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
 #endif
 
 #ifdef CONFIG_DYNAMIC_MEMORY_LAYOUT
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 2a4849e92831..a89f2dbc3531 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -89,7 +89,7 @@ static struct addr_marker address_markers[] = {
 	[KASAN_SHADOW_END_NR]	= { KASAN_SHADOW_END,	"KASAN shadow end" },
 #endif
 #ifdef CONFIG_MODIFY_LDT_SYSCALL
-	[LDT_NR]		= { LDT_BASE_ADDR,	"LDT remap" },
+	[LDT_NR]		= { 0UL,		"LDT remap" },
 #endif
 	[CPU_ENTRY_AREA_NR]	= { CPU_ENTRY_AREA_BASE,"CPU entry Area" },
 #ifdef CONFIG_X86_ESPFIX64
@@ -570,6 +570,9 @@ static int __init pt_dump_init(void)
 	address_markers[LOW_KERNEL_NR].start_address = PAGE_OFFSET;
 	address_markers[VMALLOC_START_NR].start_address = VMALLOC_START;
 	address_markers[VMEMMAP_START_NR].start_address = VMEMMAP_START;
+#ifdef CONFIG_MODIFY_LDT_SYSCALL
+	address_markers[LDT_NR].start_address = LDT_BASE_ADDR;
+#endif
 #endif
 #ifdef CONFIG_X86_32
 	address_markers[VMALLOC_START_NR].start_address = VMALLOC_START;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

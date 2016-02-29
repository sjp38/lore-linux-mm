Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 27D036B0262
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:45:37 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p65so48535895wmp.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:37 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id f88si21620467wmi.3.2016.02.29.06.45.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 06:45:35 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id l68so65911945wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:35 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 5/9] arm64: mm: move vmemmap region right below the linear region
Date: Mon, 29 Feb 2016 15:44:40 +0100
Message-Id: <1456757084-1078-6-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net, Ard Biesheuvel <ard.biesheuvel@linaro.org>

This moves the vmemmap region right below PAGE_OFFSET, aka the start
of the linear region, and redefines its size to be a power of two.
Due to the placement of PAGE_OFFSET in the middle of the address space,
whose size is a power of two as well, this guarantees that virt to
page conversions and vice versa can be implemented efficiently, by
masking and shifting rather than ordinary arithmetic.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/include/asm/memory.h  | 18 +++++++++++++++++-
 arch/arm64/include/asm/pgtable.h | 11 +++--------
 arch/arm64/mm/dump.c             | 16 ++++++++--------
 arch/arm64/mm/init.c             | 16 +++++++++++-----
 4 files changed, 39 insertions(+), 22 deletions(-)

diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index 12f8a00fb3f1..8a2ab195ca77 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -40,6 +40,21 @@
 #define PCI_IO_SIZE		SZ_16M
 
 /*
+ * Log2 of the upper bound of the size of a struct page. Used for sizing
+ * the vmemmap region only, does not affect actual memory footprint.
+ * We don't use sizeof(struct page) directly since taking its size here
+ * requires its definition to be available at this point in the inclusion
+ * chain, and it may not be a power of 2 in the first place.
+ */
+#define STRUCT_PAGE_MAX_SHIFT	6
+
+/*
+ * VMEMMAP_SIZE - allows the whole linear region to be covered by
+ *                a struct page array
+ */
+#define VMEMMAP_SIZE (UL(1) << (VA_BITS - PAGE_SHIFT - 1 + STRUCT_PAGE_MAX_SHIFT))
+
+/*
  * PAGE_OFFSET - the virtual address of the start of the kernel image (top
  *		 (VA_BITS - 1))
  * VA_BITS - the maximum number of bits for virtual addresses.
@@ -54,7 +69,8 @@
 #define MODULES_END		(MODULES_VADDR + MODULES_VSIZE)
 #define MODULES_VADDR		(VA_START + KASAN_SHADOW_SIZE)
 #define MODULES_VSIZE		(SZ_128M)
-#define PCI_IO_END		(PAGE_OFFSET - SZ_2M)
+#define VMEMMAP_START		(PAGE_OFFSET - VMEMMAP_SIZE)
+#define PCI_IO_END		(VMEMMAP_START - SZ_2M)
 #define PCI_IO_START		(PCI_IO_END - PCI_IO_SIZE)
 #define FIXADDR_TOP		(PCI_IO_START - SZ_2M)
 #define TASK_SIZE_64		(UL(1) << VA_BITS)
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index af80e437d075..fdea729f1fbf 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -24,20 +24,15 @@
 #include <asm/pgtable-prot.h>
 
 /*
- * VMALLOC and SPARSEMEM_VMEMMAP ranges.
+ * VMALLOC range.
  *
- * VMEMAP_SIZE: allows the whole linear region to be covered by a struct page array
- *	(rounded up to PUD_SIZE).
  * VMALLOC_START: beginning of the kernel vmalloc space
- * VMALLOC_END: extends to the available space below vmmemmap, PCI I/O space,
- *	fixed mappings and modules
+ * VMALLOC_END: extends to the available space below vmmemmap, PCI I/O space
+ *	and fixed mappings
  */
-#define VMEMMAP_SIZE		ALIGN((1UL << (VA_BITS - PAGE_SHIFT - 1)) * sizeof(struct page), PUD_SIZE)
-
 #define VMALLOC_START		(MODULES_END)
 #define VMALLOC_END		(PAGE_OFFSET - PUD_SIZE - VMEMMAP_SIZE - SZ_64K)
 
-#define VMEMMAP_START		(VMALLOC_END + SZ_64K)
 #define vmemmap			((struct page *)VMEMMAP_START - (memstart_addr >> PAGE_SHIFT))
 
 #define FIRST_USER_ADDRESS	0UL
diff --git a/arch/arm64/mm/dump.c b/arch/arm64/mm/dump.c
index f9271cb2f5e3..a21f47421b0c 100644
--- a/arch/arm64/mm/dump.c
+++ b/arch/arm64/mm/dump.c
@@ -37,14 +37,14 @@ enum address_markers_idx {
 	MODULES_END_NR,
 	VMALLOC_START_NR,
 	VMALLOC_END_NR,
-#ifdef CONFIG_SPARSEMEM_VMEMMAP
-	VMEMMAP_START_NR,
-	VMEMMAP_END_NR,
-#endif
 	FIXADDR_START_NR,
 	FIXADDR_END_NR,
 	PCI_START_NR,
 	PCI_END_NR,
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+	VMEMMAP_START_NR,
+	VMEMMAP_END_NR,
+#endif
 	KERNEL_SPACE_NR,
 };
 
@@ -53,14 +53,14 @@ static struct addr_marker address_markers[] = {
 	{ MODULES_END,		"Modules end" },
 	{ VMALLOC_START,	"vmalloc() Area" },
 	{ VMALLOC_END,		"vmalloc() End" },
-#ifdef CONFIG_SPARSEMEM_VMEMMAP
-	{ 0,			"vmemmap start" },
-	{ 0,			"vmemmap end" },
-#endif
 	{ FIXADDR_START,	"Fixmap start" },
 	{ FIXADDR_TOP,		"Fixmap end" },
 	{ PCI_IO_START,		"PCI I/O start" },
 	{ PCI_IO_END,		"PCI I/O end" },
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+	{ 0,			"vmemmap start" },
+	{ 0,			"vmemmap end" },
+#endif
 	{ PAGE_OFFSET,		"Linear Mapping" },
 	{ -1,			NULL },
 };
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index cebad6cceda8..9cfe94b41b54 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -365,13 +365,13 @@ void __init mem_init(void)
 		  "      .text : 0x%p" " - 0x%p" "   (%6ld KB)\n"
 		  "    .rodata : 0x%p" " - 0x%p" "   (%6ld KB)\n"
 		  "      .data : 0x%p" " - 0x%p" "   (%6ld KB)\n"
+		  "      fixed : 0x%16lx - 0x%16lx   (%6ld KB)\n"
+		  "    PCI I/O : 0x%16lx - 0x%16lx   (%6ld MB)\n"
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 		  "    vmemmap : 0x%16lx - 0x%16lx   (%6ld GB maximum)\n"
 		  "              0x%16lx - 0x%16lx   (%6ld MB actual)\n"
 #endif
-		  "    fixed   : 0x%16lx - 0x%16lx   (%6ld KB)\n"
-		  "    PCI I/O : 0x%16lx - 0x%16lx   (%6ld MB)\n"
-		  "    memory  : 0x%16lx - 0x%16lx   (%6ld MB)\n",
+		  "     memory : 0x%16lx - 0x%16lx   (%6ld MB)\n",
 #ifdef CONFIG_KASAN
 		  MLG(KASAN_SHADOW_START, KASAN_SHADOW_END),
 #endif
@@ -381,14 +381,14 @@ void __init mem_init(void)
 		  MLK_ROUNDUP(_text, __start_rodata),
 		  MLK_ROUNDUP(__start_rodata, _etext),
 		  MLK_ROUNDUP(_sdata, _edata),
+		  MLK(FIXADDR_START, FIXADDR_TOP),
+		  MLM(PCI_IO_START, PCI_IO_END),
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 		  MLG(VMEMMAP_START,
 		      VMEMMAP_START + VMEMMAP_SIZE),
 		  MLM((unsigned long)phys_to_page(memblock_start_of_DRAM()),
 		      (unsigned long)virt_to_page(high_memory)),
 #endif
-		  MLK(FIXADDR_START, FIXADDR_TOP),
-		  MLM(PCI_IO_START, PCI_IO_END),
 		  MLM(__phys_to_virt(memblock_start_of_DRAM()),
 		      (unsigned long)high_memory));
 
@@ -404,6 +404,12 @@ void __init mem_init(void)
 	BUILD_BUG_ON(TASK_SIZE_32			> TASK_SIZE_64);
 #endif
 
+	/*
+	 * Make sure we chose the upper bound of sizeof(struct page)
+	 * correctly.
+	 */
+	BUILD_BUG_ON(sizeof(struct page) > (1 << STRUCT_PAGE_MAX_SHIFT));
+
 	if (PAGE_SIZE >= 16384 && get_num_physpages() <= 128) {
 		extern int sysctl_overcommit_memory;
 		/*
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 77A536B0260
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 10:46:26 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id 127so100545177wmu.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:26 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id b186si6345685wmd.114.2016.03.30.07.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 07:46:25 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id p65so75391732wmp.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:25 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 5/9] arm64: mm: move vmemmap region right below the linear region
Date: Wed, 30 Mar 2016 16:46:00 +0200
Message-Id: <1459349164-27175-6-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net
Cc: mark.rutland@arm.com, steve.capper@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

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
 arch/arm64/mm/init.c             | 14 ++++++++++----
 4 files changed, 38 insertions(+), 21 deletions(-)

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
index 377257a8d393..2abfa4d09e65 100644
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
index 89376f3c65a3..d55d720dba79 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -412,6 +412,10 @@ void __init mem_init(void)
 		MLK_ROUNDUP(__start_rodata, _etext),
 		MLK_ROUNDUP(__init_begin, __init_end),
 		MLK_ROUNDUP(_sdata, _edata));
+	pr_cont("    fixed   : 0x%16lx - 0x%16lx   (%6ld KB)\n",
+		MLK(FIXADDR_START, FIXADDR_TOP));
+	pr_cont("    PCI I/O : 0x%16lx - 0x%16lx   (%6ld MB)\n",
+		MLM(PCI_IO_START, PCI_IO_END));
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 	pr_cont("    vmemmap : 0x%16lx - 0x%16lx   (%6ld GB maximum)\n"
 		"              0x%16lx - 0x%16lx   (%6ld MB actual)\n",
@@ -420,10 +424,6 @@ void __init mem_init(void)
 		MLM((unsigned long)phys_to_page(memblock_start_of_DRAM()),
 		    (unsigned long)virt_to_page(high_memory)));
 #endif
-	pr_cont("    fixed   : 0x%16lx - 0x%16lx   (%6ld KB)\n",
-		MLK(FIXADDR_START, FIXADDR_TOP));
-	pr_cont("    PCI I/O : 0x%16lx - 0x%16lx   (%6ld MB)\n",
-		MLM(PCI_IO_START, PCI_IO_END));
 	pr_cont("    memory  : 0x%16lx - 0x%16lx   (%6ld MB)\n",
 		MLM(__phys_to_virt(memblock_start_of_DRAM()),
 		    (unsigned long)high_memory));
@@ -440,6 +440,12 @@ void __init mem_init(void)
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

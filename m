Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0DF6B007E
	for <linux-mm@kvack.org>; Mon,  2 May 2016 04:39:40 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so282073540pac.1
        for <linux-mm@kvack.org>; Mon, 02 May 2016 01:39:40 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id c68si20996063pfd.116.2016.05.02.01.39.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 May 2016 01:39:39 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH] ARC: support HIGHMEM even without PAE40
Date: Mon, 2 May 2016 14:09:06 +0530
Message-ID: <1462178346-18111-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-snps-arc@lists.infradead.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Vineet Gupta <Vineet.Gupta1@synopsys.com>, Noam Camus <noamc@ezchip.com>

Initial HIGHMEM support on ARC was introduced for PAE40 where the low
memory (0x8000_0000 based) and high memory (0x1_0000_0000) were
physically contiguous. So CONFIG_FLATMEM sufficed (despite a peipheral
hole in the middle, which wasted a bit of struct page memory, but things
worked).

However w/o PAE, highmem was not possible and we could only reach
~1.75GB of DDR. Now there is a use case to access ~4GB of DDR w/o PAE40
The idea is to have low memory at canonical 0x8000_0000 and highmem
at 0 so enire 4GB address space is available for physical addressing
This needs additional platform/interconnect mapping to convert
the non contiguous physical addresses into linear bus adresses.

>From Linux point of view, non contiguous divide means FLATMEM no
longer works and DISCONTIGMEM is needed to track the pfns in the 2
regions.

This scheme would also work for PAE40, only better in that we don't
waste struct page memory for the peripheral hole.

The DT description will be something like

    memory {
        ...
        reg = <0x80000000 0x200000000   /* 512MB: lowmem */
               0x00000000 0x10000000>;  /* 256MB: highmem */
   }

Signed-off-by: Noam Camus <noamc@ezchip.com>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
Aplogies for the extraneous CC. While this is an ARC only patch, having mm
mm glance over it will be much appreicated, to see if this is the right way
to achieve what i needed. FWIW system with this patch boots fine and can
access highmem pages alright.
---
 arch/arc/Kconfig               | 13 ++++++++++
 arch/arc/include/asm/mmzone.h  | 33 ++++++++++++++++++++++++++
 arch/arc/include/asm/page.h    |  6 ++---
 arch/arc/include/asm/pgtable.h |  4 +---
 arch/arc/mm/init.c             | 54 ++++++++++++++++++++++++++++++------------
 5 files changed, 89 insertions(+), 21 deletions(-)
 create mode 100644 arch/arc/include/asm/mmzone.h

diff --git a/arch/arc/Kconfig b/arch/arc/Kconfig
index 12d0284a46e5..1025da212fbd 100644
--- a/arch/arc/Kconfig
+++ b/arch/arc/Kconfig
@@ -56,6 +56,9 @@ config GENERIC_CSUM
 config RWSEM_GENERIC_SPINLOCK
 	def_bool y
 
+config ARCH_DISCONTIGMEM_ENABLE
+	def_bool y
+
 config ARCH_FLATMEM_ENABLE
 	def_bool y
 
@@ -345,6 +348,15 @@ config ARC_HUGEPAGE_16M
 
 endchoice
 
+config NODES_SHIFT
+	int "Maximum NUMA Nodes (as a power of 2)"
+	default "1" if !DISCONTIGMEM
+	default "2" if DISCONTIGMEM
+	depends on NEED_MULTIPLE_NODES
+	---help---
+	  Accessing memory beyond 1GB (with or w/o PAE) requires 2 memory
+	  zones.
+
 if ISA_ARCOMPACT
 
 config ARC_COMPACT_IRQ_LEVELS
@@ -453,6 +465,7 @@ config LINUX_LINK_BASE
 
 config HIGHMEM
 	bool "High Memory Support"
+	select DISCONTIGMEM
 	help
 	  With ARC 2G:2G address split, only upper 2G is directly addressable by
 	  kernel. Enable this to potentially allow access to rest of 2G and PAE
diff --git a/arch/arc/include/asm/mmzone.h b/arch/arc/include/asm/mmzone.h
new file mode 100644
index 000000000000..a4cc82f723bc
--- /dev/null
+++ b/arch/arc/include/asm/mmzone.h
@@ -0,0 +1,33 @@
+/*
+ * Copyright (C) 2016 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef _ASM_ARC_MMZONE_H
+#define _ASM_ARC_MMZONE_H
+
+#ifdef CONFIG_DISCONTIGMEM
+
+extern struct pglist_data node_data[];
+#define NODE_DATA(nid) (&node_data[nid])
+
+static inline int pfn_to_nid(unsigned long pfn)
+{
+	if (pfn >= ARCH_PFN_OFFSET)
+		return 0;
+
+	return 1;
+}
+
+static inline int pfn_valid(unsigned long pfn)
+{
+	int nid = pfn_to_nid(pfn);
+
+	return (pfn <= node_end_pfn(nid));
+}
+#endif /* CONFIG_DISCONTIGMEM  */
+
+#endif
diff --git a/arch/arc/include/asm/page.h b/arch/arc/include/asm/page.h
index 36da89e2c853..3361f5888005 100644
--- a/arch/arc/include/asm/page.h
+++ b/arch/arc/include/asm/page.h
@@ -76,7 +76,9 @@ typedef pte_t * pgtable_t;
 
 #define ARCH_PFN_OFFSET		virt_to_pfn(CONFIG_LINUX_LINK_BASE)
 
+#ifdef CONFIG_FLATMEM
 #define pfn_valid(pfn)		(((pfn) - ARCH_PFN_OFFSET) < max_mapnr)
+#endif
 
 /*
  * __pa, __va, virt_to_page (ALERT: deprecated, don't use them)
@@ -88,9 +90,7 @@ typedef pte_t * pgtable_t;
 #define __pa(vaddr)  ((unsigned long)vaddr)
 #define __va(paddr)  ((void *)((unsigned long)(paddr)))
 
-#define virt_to_page(kaddr)	\
-	(mem_map + virt_to_pfn((kaddr) - CONFIG_LINUX_LINK_BASE))
-
+#define virt_to_page(kaddr)	pfn_to_page(virt_to_pfn(kaddr))
 #define virt_addr_valid(kaddr)  pfn_valid(virt_to_pfn(kaddr))
 
 /* Default Permissions for stack/heaps pages (Non Executable) */
diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index 7d6c93e63adf..cb756f982b86 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -278,11 +278,9 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 #define pmd_present(x)			(pmd_val(x))
 #define pmd_clear(xp)			do { pmd_val(*(xp)) = 0; } while (0)
 
-#define pte_page(pte)	\
-	(mem_map + virt_to_pfn(pte_val(pte) - CONFIG_LINUX_LINK_BASE))
-
 #define mk_pte(page, prot)	pfn_pte(page_to_pfn(page), prot)
 #define pte_pfn(pte)		virt_to_pfn(pte_val(pte))
+#define pte_page(pte)		pfn_to_page(pte_pfn(pte))
 #define pfn_pte(pfn, prot)	(__pte(((pte_t)(pfn) << PAGE_SHIFT) | \
 				 pgprot_val(prot)))
 #define __pte_index(addr)	(virt_to_pfn(addr) & (PTRS_PER_PTE - 1))
diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index 7d2c4fbf4f22..23e4162ca67d 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -29,11 +29,16 @@ static const unsigned long low_mem_start = CONFIG_LINUX_LINK_BASE;
 static unsigned long low_mem_sz;
 
 #ifdef CONFIG_HIGHMEM
-static unsigned long min_high_pfn;
+static unsigned long min_high_pfn, max_high_pfn;
 static u64 high_mem_start;
 static u64 high_mem_sz;
 #endif
 
+#ifdef CONFIG_DISCONTIGMEM
+struct pglist_data node_data[MAX_NUMNODES] __read_mostly;
+EXPORT_SYMBOL(node_data);
+#endif
+
 /* User can over-ride above with "mem=nnn[KkMm]" in cmdline */
 static int __init setup_mem_sz(char *str)
 {
@@ -108,13 +113,11 @@ void __init setup_arch_memory(void)
 	/* Last usable page of low mem */
 	max_low_pfn = max_pfn = PFN_DOWN(low_mem_start + low_mem_sz);
 
-#ifdef CONFIG_HIGHMEM
-	min_high_pfn = PFN_DOWN(high_mem_start);
-	max_pfn = PFN_DOWN(high_mem_start + high_mem_sz);
+#ifdef CONFIG_FLATMEM
+	/* pfn_valid() uses this */
+	max_mapnr = max_low_pfn - min_low_pfn;
 #endif
 
-	max_mapnr = max_pfn - min_low_pfn;
-
 	/*------------- bootmem allocator setup -----------------------*/
 
 	/*
@@ -128,7 +131,7 @@ void __init setup_arch_memory(void)
 	 * the crash
 	 */
 
-	memblock_add(low_mem_start, low_mem_sz);
+	memblock_add_node(low_mem_start, low_mem_sz, 0);
 	memblock_reserve(low_mem_start, __pa(_end) - low_mem_start);
 
 #ifdef CONFIG_BLK_DEV_INITRD
@@ -145,13 +148,6 @@ void __init setup_arch_memory(void)
 	zones_size[ZONE_NORMAL] = max_low_pfn - min_low_pfn;
 	zones_holes[ZONE_NORMAL] = 0;
 
-#ifdef CONFIG_HIGHMEM
-	zones_size[ZONE_HIGHMEM] = max_pfn - max_low_pfn;
-
-	/* This handles the peripheral address space hole */
-	zones_holes[ZONE_HIGHMEM] = min_high_pfn - max_low_pfn;
-#endif
-
 	/*
 	 * We can't use the helper free_area_init(zones[]) because it uses
 	 * PAGE_OFFSET to compute the @min_low_pfn which would be wrong
@@ -164,6 +160,34 @@ void __init setup_arch_memory(void)
 			    zones_holes);	/* holes */
 
 #ifdef CONFIG_HIGHMEM
+	/*
+	 * Populate a new node with highmem
+	 *
+	 * On ARC (w/o PAE) HIGHMEM addresses are actually smaller (0 based)
+	 * than addresses in normal ala low memory (0x8000_0000 based).
+	 * Even with PAE, the huge peripheral space hole would waste a lot of
+	 * mem with single mem_map[]. This warrants a mem_map per region design.
+	 * Thus HIGHMEM on ARC is imlemented with DISCONTIGMEM.
+	 *
+	 * DISCONTIGMEM in turns requires multiple nodes. node 0 above is
+	 * populated with normal memory zone while node 1 only has highmem
+	 */
+	node_set_online(1);
+
+	min_high_pfn = PFN_DOWN(high_mem_start);
+	max_high_pfn = PFN_DOWN(high_mem_start + high_mem_sz);
+
+	zones_size[ZONE_NORMAL] = 0;
+	zones_holes[ZONE_NORMAL] = 0;
+
+	zones_size[ZONE_HIGHMEM] = max_high_pfn - min_high_pfn;
+	zones_holes[ZONE_HIGHMEM] = 0;
+
+	free_area_init_node(1,			/* node-id */
+			    zones_size,		/* num pages per zone */
+			    min_high_pfn,	/* first pfn of node */
+			    zones_holes);	/* holes */
+
 	high_memory = (void *)(min_high_pfn << PAGE_SHIFT);
 	kmap_init();
 #endif
@@ -181,7 +205,7 @@ void __init mem_init(void)
 	unsigned long tmp;
 
 	reset_all_zones_managed_pages();
-	for (tmp = min_high_pfn; tmp < max_pfn; tmp++)
+	for (tmp = min_high_pfn; tmp < max_high_pfn; tmp++)
 		free_highmem_page(pfn_to_page(tmp));
 #endif
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

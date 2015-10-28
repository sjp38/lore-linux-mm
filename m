Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 179F682F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 07:24:32 -0400 (EDT)
Received: by pabla5 with SMTP id la5so4905116pab.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 04:24:31 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id rp16si69754471pab.8.2015.10.28.04.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 04:24:30 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 2/3] ARC: mm: HIGHMEM: kmap API implementation
Date: Wed, 28 Oct 2015 16:53:12 +0530
Message-ID: <1446031393-2312-3-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1446031393-2312-1-git-send-email-vgupta@synopsys.com>
References: <1446031393-2312-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Mel
 Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-snps-arc@lists.infraded.org, Alexey Brodkin <Alexey.Brodkin@synopsys.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>

Implement kmap* API for ARC.

This enables
 - permanent kernel maps (pkmaps): :kmap() API
 - fixmap : kmap_atomic()

We use a very simple/uniform approach for both (unlike some of the other
arches). So fixmap doesn't use the customary compile time address stuff.
The important semantic is sleep'ability (pkmap) vs. not (fixmap) which
the API guarantees.

Note that this patch only enables highmem for subsequent PAE40 support
as there is no real highmem for ARC in pure 32-bit paradigm as explained
below.

ARC has 2:2 address split of the 32-bit address space with lower half
being translated (virtual) while upper half unstranslated
(0x8000_0000 to 0xFFFF_FFFF). kernel itself is linked at base of
unstranslated space (i.e. 0x8000_0000 onwards), which is mapped to say
DDR 0x0 by external Bus Glue logic (outside the core). So kernel can
potentially access 1.75G worth of memory directly w/o need for highmem.
(the top 256M is taken by uncached peripheral space from 0xF000_0000 to
0xFFFF_FFFF)

In PAE40, hardware can address memory beyond 4G (0x1_0000_0000) while
the logical/virtual addresses remain 32-bits. Thus highmem is required
for kernel proper to be able to access these pages for it's own purposes
(user space is agnostic to this anyways).

For testing the kmap machinery though w/o PAE, we added hacks to ARC mm
init code to fake some of the memory to be in ZONE_HIGHMEM.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/Kconfig                  |   7 ++
 arch/arc/include/asm/highmem.h    |  61 +++++++++++++++++
 arch/arc/include/asm/kmap_types.h |  18 +++++
 arch/arc/include/asm/processor.h  |   7 +-
 arch/arc/mm/Makefile              |   1 +
 arch/arc/mm/highmem.c             | 138 ++++++++++++++++++++++++++++++++++++++
 arch/arc/mm/init.c                |  18 ++++-
 7 files changed, 248 insertions(+), 2 deletions(-)
 create mode 100644 arch/arc/include/asm/highmem.h
 create mode 100644 arch/arc/include/asm/kmap_types.h
 create mode 100644 arch/arc/mm/highmem.c

diff --git a/arch/arc/Kconfig b/arch/arc/Kconfig
index cc938967282b..fd9632f4ddc8 100644
--- a/arch/arc/Kconfig
+++ b/arch/arc/Kconfig
@@ -446,6 +446,13 @@ config LINUX_LINK_BASE
 	  Linux needs to be scooted a bit.
 	  If you don't know what the above means, leave this setting alone.
 
+config HIGHMEM
+	bool "High Memory Support"
+	help
+	  With ARC 2G:2G address split, only upper 2G is directly addressable by
+	  kernel. Enable this to potentially allow access to rest of 2G and PAE
+	  in future
+
 config ARC_CURR_IN_REG
 	bool "Dedicate Register r25 for current_task pointer"
 	default y
diff --git a/arch/arc/include/asm/highmem.h b/arch/arc/include/asm/highmem.h
new file mode 100644
index 000000000000..b1585c96324a
--- /dev/null
+++ b/arch/arc/include/asm/highmem.h
@@ -0,0 +1,61 @@
+/*
+ * Copyright (C) 2015 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#ifndef _ASM_HIGHMEM_H
+#define _ASM_HIGHMEM_H
+
+#ifdef CONFIG_HIGHMEM
+
+#include <uapi/asm/page.h>
+#include <asm/kmap_types.h>
+
+/* start after vmalloc area */
+#define FIXMAP_BASE		(PAGE_OFFSET - FIXMAP_SIZE - PKMAP_SIZE)
+#define FIXMAP_SIZE		PGDIR_SIZE	/* only 1 PGD worth */
+#define KM_TYPE_NR		((FIXMAP_SIZE >> PAGE_SHIFT)/NR_CPUS)
+#define FIXMAP_ADDR(nr)		(FIXMAP_BASE + ((nr) << PAGE_SHIFT))
+
+/* start after fixmap area */
+#define PKMAP_BASE		(FIXMAP_BASE + FIXMAP_SIZE)
+#define PKMAP_SIZE		PGDIR_SIZE
+#define LAST_PKMAP		(PKMAP_SIZE >> PAGE_SHIFT)
+#define LAST_PKMAP_MASK		(LAST_PKMAP - 1)
+#define PKMAP_ADDR(nr)		(PKMAP_BASE + ((nr) << PAGE_SHIFT))
+#define PKMAP_NR(virt)		(((virt) - PKMAP_BASE) >> PAGE_SHIFT)
+
+#define kmap_prot		PAGE_KERNEL
+
+
+#include <asm/cacheflush.h>
+
+extern void *kmap(struct page *page);
+extern void *kmap_high(struct page *page);
+extern void *kmap_atomic(struct page *page);
+extern void __kunmap_atomic(void *kvaddr);
+extern void kunmap_high(struct page *page);
+
+extern void kmap_init(void);
+
+static inline void flush_cache_kmaps(void)
+{
+	flush_cache_all();
+}
+
+static inline void kunmap(struct page *page)
+{
+	BUG_ON(in_interrupt());
+	if (!PageHighMem(page))
+		return;
+	kunmap_high(page);
+}
+
+
+#endif
+
+#endif
diff --git a/arch/arc/include/asm/kmap_types.h b/arch/arc/include/asm/kmap_types.h
new file mode 100644
index 000000000000..f0d7f6acea4e
--- /dev/null
+++ b/arch/arc/include/asm/kmap_types.h
@@ -0,0 +1,18 @@
+/*
+ * Copyright (C) 2015 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#ifndef _ASM_KMAP_TYPES_H
+#define _ASM_KMAP_TYPES_H
+
+/*
+ * We primarily need to define KM_TYPE_NR here but that in turn
+ * is a function of PGDIR_SIZE etc.
+ * To avoid circular deps issue, put everything in asm/highmem.h
+ */
+#endif
diff --git a/arch/arc/include/asm/processor.h b/arch/arc/include/asm/processor.h
index ee682d8e0213..44545354e9e8 100644
--- a/arch/arc/include/asm/processor.h
+++ b/arch/arc/include/asm/processor.h
@@ -114,7 +114,12 @@ extern unsigned int get_wchan(struct task_struct *p);
  * -----------------------------------------------------------------------------
  */
 #define VMALLOC_START	0x70000000
-#define VMALLOC_SIZE	(PAGE_OFFSET - VMALLOC_START)
+
+/*
+ * 1 PGDIR_SIZE each for fixmap/pkmap, 2 PGDIR_SIZE gutter
+ * See asm/highmem.h for details
+ */
+#define VMALLOC_SIZE	(PAGE_OFFSET - VMALLOC_START - PGDIR_SIZE * 4)
 #define VMALLOC_END	(VMALLOC_START + VMALLOC_SIZE)
 
 #define USER_KERNEL_GUTTER    0x10000000
diff --git a/arch/arc/mm/Makefile b/arch/arc/mm/Makefile
index 7beb941556c3..3703a4969349 100644
--- a/arch/arc/mm/Makefile
+++ b/arch/arc/mm/Makefile
@@ -8,3 +8,4 @@
 
 obj-y	:= extable.o ioremap.o dma.o fault.o init.o
 obj-y	+= tlb.o tlbex.o cache.o mmap.o
+obj-$(CONFIG_HIGHMEM)	+= highmem.o
diff --git a/arch/arc/mm/highmem.c b/arch/arc/mm/highmem.c
new file mode 100644
index 000000000000..7f215626b8da
--- /dev/null
+++ b/arch/arc/mm/highmem.c
@@ -0,0 +1,138 @@
+/*
+ * Copyright (C) 2015 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/bootmem.h>
+#include <linux/export.h>
+#include <linux/highmem.h>
+#include <asm/processor.h>
+#include <asm/pgtable.h>
+#include <asm/pgalloc.h>
+#include <asm/tlbflush.h>
+
+/*
+ * HIGHMEM API:
+ *
+ * kmap() API provides sleep semantics hence refered to as "permanent maps"
+ * It allows mapping LAST_PKMAP pages, using @last_pkmap_nr as the cursor
+ * for book-keeping
+ *
+ * kmap_atomic() can't sleep (calls pagefault_disable()), thus it provides
+ * shortlived ala "temporary mappings" which historically were implemented as
+ * fixmaps (compile time addr etc). Their book-keeping is done per cpu.
+ *
+ *	Both these facts combined (preemption disabled and per-cpu allocation)
+ *	means the total number of concurrent fixmaps will be limited to max
+ *	such allocations in a single control path. Thus KM_TYPE_NR (another
+ *	historic relic) is a small'ish number which caps max percpu fixmaps
+ *
+ * ARC HIGHMEM Details
+ *
+ * - the kernel vaddr space from 0x7z to 0x8z (currently used by vmalloc/module)
+ *   is now shared between vmalloc and kmap (non overlapping though)
+ *
+ * - Both fixmap/pkmap use a dedicated page table each, hooked up to swapper PGD
+ *   This means each only has 1 PGDIR_SIZE worth of kvaddr mappings, which means
+ *   2M of kvaddr space for typical config (8K page and 11:8:13 traversal split)
+ *
+ * - fixmap anyhow needs a limited number of mappings. So 2M kvaddr == 256 PTE
+ *   slots across NR_CPUS would be more than sufficient (generic code defines
+ *   KM_TYPE_NR as 20).
+ *
+ * - pkmap being preemptible, in theory could do with more than 256 concurrent
+ *   mappings. However, generic pkmap code: map_new_virtual(), doesn't traverse
+ *   the PGD and only works with a single page table @pkmap_page_table, hence
+ *   sets the limit
+ */
+
+extern pte_t * pkmap_page_table;
+static pte_t * fixmap_page_table;
+
+void *kmap(struct page *page)
+{
+	BUG_ON(in_interrupt());
+	if (!PageHighMem(page))
+		return page_address(page);
+
+	return kmap_high(page);
+}
+
+void *kmap_atomic(struct page *page)
+{
+	int idx, cpu_idx;
+	unsigned long vaddr;
+
+	pagefault_disable();
+	if (!PageHighMem(page))
+		return page_address(page);
+
+	cpu_idx = kmap_atomic_idx_push();
+	idx = cpu_idx + KM_TYPE_NR * smp_processor_id();
+	vaddr = FIXMAP_ADDR(idx);
+
+	set_pte_at(&init_mm, vaddr, fixmap_page_table + idx,
+		   mk_pte(page, kmap_prot));
+
+	return (void *)vaddr;
+}
+EXPORT_SYMBOL(kmap_atomic);
+
+void __kunmap_atomic(void *kv)
+{
+	unsigned long kvaddr = (unsigned long)kv;
+
+	if (kvaddr >= FIXMAP_BASE && kvaddr < (FIXMAP_BASE + FIXMAP_SIZE)) {
+
+		/*
+		 * Because preemption is disabled, this vaddr can be associated
+		 * with the current allocated index.
+		 * But in case of multiple live kmap_atomic(), it still relies on
+		 * callers to unmap in right order.
+		 */
+		int cpu_idx = kmap_atomic_idx();
+		int idx = cpu_idx + KM_TYPE_NR * smp_processor_id();
+
+		WARN_ON(kvaddr != FIXMAP_ADDR(idx));
+
+		pte_clear(&init_mm, kvaddr, fixmap_page_table + idx);
+		local_flush_tlb_kernel_range(kvaddr, kvaddr + PAGE_SIZE);
+
+		kmap_atomic_idx_pop();
+	}
+
+	pagefault_enable();
+}
+EXPORT_SYMBOL(__kunmap_atomic);
+
+noinline pte_t *alloc_kmap_pgtable(unsigned long kvaddr)
+{
+	pgd_t *pgd_k;
+	pud_t *pud_k;
+	pmd_t *pmd_k;
+	pte_t *pte_k;
+
+	pgd_k = pgd_offset_k(kvaddr);
+	pud_k = pud_offset(pgd_k, kvaddr);
+	pmd_k = pmd_offset(pud_k, kvaddr);
+
+	pte_k = (pte_t *)alloc_bootmem_low_pages(PAGE_SIZE);
+	pmd_populate_kernel(&init_mm, pmd_k, pte_k);
+	return pte_k;
+}
+
+void kmap_init(void)
+{
+	/* Due to recursive include hell, we can't do this in processor.h */
+	BUILD_BUG_ON(PAGE_OFFSET < (VMALLOC_END + FIXMAP_SIZE + PKMAP_SIZE));
+
+	BUILD_BUG_ON(KM_TYPE_NR > PTRS_PER_PTE);
+	pkmap_page_table = alloc_kmap_pgtable(PKMAP_BASE);
+
+	BUILD_BUG_ON(LAST_PKMAP > PTRS_PER_PTE);
+	fixmap_page_table = alloc_kmap_pgtable(FIXMAP_BASE);
+}
diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index 5256765d5db0..a8fe1a5c2896 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -15,6 +15,7 @@
 #endif
 #include <linux/swap.h>
 #include <linux/module.h>
+#include <linux/highmem.h>
 #include <asm/page.h>
 #include <asm/pgalloc.h>
 #include <asm/sections.h>
@@ -94,7 +95,7 @@ void __init setup_arch_memory(void)
 	/* first page of system - kernel .vector starts here */
 	min_low_pfn = ARCH_PFN_OFFSET;
 
-	/* Last usable page of low mem (no HIGHMEM yet for ARC port) */
+	/* Last usable page of low mem */
 	max_low_pfn = max_pfn = PFN_DOWN(end_mem);
 
 	max_mapnr = max_pfn - min_low_pfn;
@@ -114,6 +115,9 @@ void __init setup_arch_memory(void)
 	/*-------------- node setup --------------------------------*/
 	memset(zones_size, 0, sizeof(zones_size));
 	zones_size[ZONE_NORMAL] = max_mapnr;
+#ifdef CONFIG_HIGHMEM
+	zones_size[ZONE_HIGHMEM] = max_pfn - max_low_pfn;
+#endif
 
 	/*
 	 * We can't use the helper free_area_init(zones[]) because it uses
@@ -127,6 +131,10 @@ void __init setup_arch_memory(void)
 			    NULL);		/* NO holes */
 
 	high_memory = (void *)end_mem;
+
+#ifdef CONFIG_HIGHMEM
+	kmap_init();
+#endif
 }
 
 /*
@@ -137,6 +145,14 @@ void __init setup_arch_memory(void)
  */
 void __init mem_init(void)
 {
+#ifdef CONFIG_HIGHMEM
+	unsigned long tmp;
+
+	reset_all_zones_managed_pages();
+	for (tmp = max_low_pfn; tmp < max_pfn; tmp++)
+		free_highmem_page(pfn_to_page(tmp));
+#endif
+
 	free_all_bootmem();
 	mem_init_print_info(NULL);
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

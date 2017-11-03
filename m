Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id E39ED6B025F
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 14:52:36 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t3so4480078ywf.1
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 11:52:36 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g13si1608825ybf.75.2017.11.03.11.52.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 11:52:35 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v1 2/2] arm64/mm/kasan: don't use vmemmap_populate() to initialize shadow
Date: Fri,  3 Nov 2017 14:51:47 -0400
Message-Id: <20171103185147.2688-3-pasha.tatashin@oracle.com>
In-Reply-To: <20171103185147.2688-1-pasha.tatashin@oracle.com>
References: <20171103185147.2688-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, will.deacon@arm.com, mhocko@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

The kasan shadow is currently mapped using vmemmap_populate() since that
provides a semi-convenient way to map pages into init_top_pgt. However,
since that no longer zeroes the mapped pages, it is not suitable for kasan,
which requires zeroed shadow memory.

Add kasan_populate_shadow() interface and use it instead of
vmemmap_populate(). Besides, this allows us to take advantage of gigantic
pages and use them to populate the shadow, which should save us some memory
wasted on page tables and reduce TLB pressure.

Signed-off-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 arch/arm64/Kconfig         |   2 +-
 arch/arm64/mm/kasan_init.c | 130 ++++++++++++++++++++++++++++-----------------
 2 files changed, 81 insertions(+), 51 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 0df64a6a56d4..888580b9036e 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -68,7 +68,7 @@ config ARM64
 	select HAVE_ARCH_BITREVERSE
 	select HAVE_ARCH_HUGE_VMAP
 	select HAVE_ARCH_JUMP_LABEL
-	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP && !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
+	select HAVE_ARCH_KASAN if !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 81f03959a4ab..acba49fb5aac 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -11,6 +11,7 @@
  */
 
 #define pr_fmt(fmt) "kasan: " fmt
+#include <linux/bootmem.h>
 #include <linux/kasan.h>
 #include <linux/kernel.h>
 #include <linux/sched/task.h>
@@ -35,77 +36,117 @@ static pgd_t tmp_pg_dir[PTRS_PER_PGD] __initdata __aligned(PGD_SIZE);
  * with the physical address from __pa_symbol.
  */
 
-static void __init kasan_early_pte_populate(pmd_t *pmd, unsigned long addr,
-					unsigned long end)
+static phys_addr_t __init kasan_alloc_zeroed_page(int node)
 {
-	pte_t *pte;
-	unsigned long next;
+	void *p = memblock_virt_alloc_try_nid(PAGE_SIZE, PAGE_SIZE,
+					      __pa(MAX_DMA_ADDRESS),
+					      MEMBLOCK_ALLOC_ACCESSIBLE, node);
+	return __pa(p);
+}
+
+static pte_t *__init kasan_pte_offset(pmd_t *pmd, unsigned long addr, int node,
+				      bool early)
+{
+	if (pmd_none(*pmd)) {
+		phys_addr_t pte_phys = early ? __pa_symbol(kasan_zero_pte)
+					     : kasan_alloc_zeroed_page(node);
+		__pmd_populate(pmd, pte_phys, PMD_TYPE_TABLE);
+	}
+
+	return early ? pte_offset_kimg(pmd, addr)
+		     : pte_offset_kernel(pmd, addr);
+}
 
-	if (pmd_none(*pmd))
-		__pmd_populate(pmd, __pa_symbol(kasan_zero_pte), PMD_TYPE_TABLE);
+static pmd_t *__init kasan_pmd_offset(pud_t *pud, unsigned long addr, int node,
+				      bool early)
+{
+	if (pud_none(*pud)) {
+		phys_addr_t pmd_phys = early ? __pa_symbol(kasan_zero_pmd)
+					     : kasan_alloc_zeroed_page(node);
+		__pud_populate(pud, pmd_phys, PMD_TYPE_TABLE);
+	}
+
+	return early ? pmd_offset_kimg(pud, addr) : pmd_offset(pud, addr);
+}
+
+static pud_t *__init kasan_pud_offset(pgd_t *pgd, unsigned long addr, int node,
+				      bool early)
+{
+	if (pgd_none(*pgd)) {
+		phys_addr_t pud_phys = early ? __pa_symbol(kasan_zero_pud)
+					     : kasan_alloc_zeroed_page(node);
+		__pgd_populate(pgd, pud_phys, PMD_TYPE_TABLE);
+	}
+
+	return early ? pud_offset_kimg(pgd, addr) : pud_offset(pgd, addr);
+}
+
+static void __init kasan_pte_populate(pmd_t *pmd, unsigned long addr,
+				      unsigned long end, int node, bool early)
+{
+	unsigned long next;
+	pte_t *pte = kasan_pte_offset(pmd, addr, node, early);
 
-	pte = pte_offset_kimg(pmd, addr);
 	do {
+		phys_addr_t page_phys = early ? __pa_symbol(kasan_zero_page)
+					      : kasan_alloc_zeroed_page(node);
 		next = addr + PAGE_SIZE;
-		set_pte(pte, pfn_pte(sym_to_pfn(kasan_zero_page),
-					PAGE_KERNEL));
+		set_pte(pte, pfn_pte(__phys_to_pfn(page_phys), PAGE_KERNEL));
 	} while (pte++, addr = next, addr != end && pte_none(*pte));
 }
 
-static void __init kasan_early_pmd_populate(pud_t *pud,
-					unsigned long addr,
-					unsigned long end)
+static void __init kasan_pmd_populate(pud_t *pud, unsigned long addr,
+				      unsigned long end, int node, bool early)
 {
-	pmd_t *pmd;
 	unsigned long next;
+	pmd_t *pmd = kasan_pmd_offset(pud, addr, node, early);
 
-	if (pud_none(*pud))
-		__pud_populate(pud, __pa_symbol(kasan_zero_pmd), PMD_TYPE_TABLE);
-
-	pmd = pmd_offset_kimg(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
-		kasan_early_pte_populate(pmd, addr, next);
+		kasan_pte_populate(pmd, addr, next, node, early);
 	} while (pmd++, addr = next, addr != end && pmd_none(*pmd));
 }
 
-static void __init kasan_early_pud_populate(pgd_t *pgd,
-					unsigned long addr,
-					unsigned long end)
+static void __init kasan_pud_populate(pgd_t *pgd, unsigned long addr,
+				      unsigned long end, int node, bool early)
 {
-	pud_t *pud;
 	unsigned long next;
+	pud_t *pud = kasan_pud_offset(pgd, addr, node, early);
 
-	if (pgd_none(*pgd))
-		__pgd_populate(pgd, __pa_symbol(kasan_zero_pud), PUD_TYPE_TABLE);
-
-	pud = pud_offset_kimg(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
-		kasan_early_pmd_populate(pud, addr, next);
+		kasan_pmd_populate(pud, addr, next, node, early);
 	} while (pud++, addr = next, addr != end && pud_none(*pud));
 }
 
-static void __init kasan_map_early_shadow(void)
+static void __init kasan_pgd_populate(unsigned long addr, unsigned long end,
+				      int node, bool early)
 {
-	unsigned long addr = KASAN_SHADOW_START;
-	unsigned long end = KASAN_SHADOW_END;
 	unsigned long next;
 	pgd_t *pgd;
 
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		kasan_early_pud_populate(pgd, addr, next);
+		kasan_pud_populate(pgd, addr, next, node, early);
 	} while (pgd++, addr = next, addr != end);
 }
 
+/* The early shadow maps everything to a single page of zeroes */
 asmlinkage void __init kasan_early_init(void)
 {
 	BUILD_BUG_ON(KASAN_SHADOW_OFFSET != KASAN_SHADOW_END - (1UL << 61));
 	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_START, PGDIR_SIZE));
 	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));
-	kasan_map_early_shadow();
+	kasan_pgd_populate(KASAN_SHADOW_START, KASAN_SHADOW_END, NUMA_NO_NODE,
+			   true);
+}
+
+/* Set up full kasan mappings, ensuring that the mapped pages are zeroed */
+static void __init kasan_map_populate(unsigned long start, unsigned long end,
+				      int node)
+{
+	kasan_pgd_populate(start & PAGE_MASK, PAGE_ALIGN(end), node, false);
 }
 
 /*
@@ -142,8 +183,8 @@ void __init kasan_init(void)
 	struct memblock_region *reg;
 	int i;
 
-	kimg_shadow_start = (u64)kasan_mem_to_shadow(_text);
-	kimg_shadow_end = (u64)kasan_mem_to_shadow(_end);
+	kimg_shadow_start = (u64)kasan_mem_to_shadow(_text) & PAGE_MASK;
+	kimg_shadow_end = PAGE_ALIGN((u64)kasan_mem_to_shadow(_end));
 
 	mod_shadow_start = (u64)kasan_mem_to_shadow((void *)MODULES_VADDR);
 	mod_shadow_end = (u64)kasan_mem_to_shadow((void *)MODULES_END);
@@ -161,19 +202,8 @@ void __init kasan_init(void)
 
 	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
 
-	vmemmap_populate(kimg_shadow_start, kimg_shadow_end,
-			 pfn_to_nid(virt_to_pfn(lm_alias(_text))));
-
-	/*
-	 * vmemmap_populate() has populated the shadow region that covers the
-	 * kernel image with SWAPPER_BLOCK_SIZE mappings, so we have to round
-	 * the start and end addresses to SWAPPER_BLOCK_SIZE as well, to prevent
-	 * kasan_populate_zero_shadow() from replacing the page table entries
-	 * (PMD or PTE) at the edges of the shadow region for the kernel
-	 * image.
-	 */
-	kimg_shadow_start = round_down(kimg_shadow_start, SWAPPER_BLOCK_SIZE);
-	kimg_shadow_end = round_up(kimg_shadow_end, SWAPPER_BLOCK_SIZE);
+	kasan_map_populate(kimg_shadow_start, kimg_shadow_end,
+			   pfn_to_nid(virt_to_pfn(lm_alias(_text))));
 
 	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
 				   (void *)mod_shadow_start);
@@ -191,9 +221,9 @@ void __init kasan_init(void)
 		if (start >= end)
 			break;
 
-		vmemmap_populate((unsigned long)kasan_mem_to_shadow(start),
-				(unsigned long)kasan_mem_to_shadow(end),
-				pfn_to_nid(virt_to_pfn(start)));
+		kasan_map_populate((unsigned long)kasan_mem_to_shadow(start),
+				   (unsigned long)kasan_mem_to_shadow(end),
+				   pfn_to_nid(virt_to_pfn(start)));
 	}
 
 	/*
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E27996B026E
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 13:33:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i124so6336925wmf.1
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 10:33:12 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m91si1241475ede.497.2017.10.13.10.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 10:33:11 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v12 11/11] arm64: kasan: Avoid using vmemmap_populate to initialise shadow
Date: Fri, 13 Oct 2017 13:32:14 -0400
Message-Id: <20171013173214.27300-12-pasha.tatashin@oracle.com>
In-Reply-To: <20171013173214.27300-1-pasha.tatashin@oracle.com>
References: <20171013173214.27300-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, akpm@linux-foundation.org, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

From: Will Deacon <will.deacon@arm.com>

The kasan shadow is currently mapped using vmemmap_populate since that
provides a semi-convenient way to map pages into swapper. However, since
that no longer zeroes the mapped pages, it is not suitable for kasan,
which requires that the shadow is zeroed in order to avoid false
positives.

This patch removes our reliance on vmemmap_populate and reuses the
existing kasan page table code, which is already required for creating
the early shadow.

Signed-off-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 arch/arm64/Kconfig         |   2 +-
 arch/arm64/mm/kasan_init.c | 180 +++++++++++++++++++--------------------------
 2 files changed, 76 insertions(+), 106 deletions(-)

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
index cb4af2951c90..acba49fb5aac 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -11,6 +11,7 @@
  */
 
 #define pr_fmt(fmt) "kasan: " fmt
+#include <linux/bootmem.h>
 #include <linux/kasan.h>
 #include <linux/kernel.h>
 #include <linux/sched/task.h>
@@ -28,66 +29,6 @@
 
 static pgd_t tmp_pg_dir[PTRS_PER_PGD] __initdata __aligned(PGD_SIZE);
 
-/* Creates mappings for kasan during early boot. The mapped memory is zeroed */
-static int __meminit kasan_map_populate(unsigned long start, unsigned long end,
-					int node)
-{
-	unsigned long addr, pfn, next;
-	unsigned long long size;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-	int ret;
-
-	ret = vmemmap_populate(start, end, node);
-	/*
-	 * We might have partially populated memory, so check for no entries,
-	 * and zero only those that actually exist.
-	 */
-	for (addr = start; addr < end; addr = next) {
-		pgd = pgd_offset_k(addr);
-		if (pgd_none(*pgd)) {
-			next = pgd_addr_end(addr, end);
-			continue;
-		}
-
-		pud = pud_offset(pgd, addr);
-		if (pud_none(*pud)) {
-			next = pud_addr_end(addr, end);
-			continue;
-		}
-		if (pud_sect(*pud)) {
-			/* This is PUD size page */
-			next = pud_addr_end(addr, end);
-			size = PUD_SIZE;
-			pfn = pud_pfn(*pud);
-		} else {
-			pmd = pmd_offset(pud, addr);
-			if (pmd_none(*pmd)) {
-				next = pmd_addr_end(addr, end);
-				continue;
-			}
-			if (pmd_sect(*pmd)) {
-				/* This is PMD size page */
-				next = pmd_addr_end(addr, end);
-				size = PMD_SIZE;
-				pfn = pmd_pfn(*pmd);
-			} else {
-				pte = pte_offset_kernel(pmd, addr);
-				next = addr + PAGE_SIZE;
-				if (pte_none(*pte))
-					continue;
-				/* This is base size page */
-				size = PAGE_SIZE;
-				pfn = pte_pfn(*pte);
-			}
-		}
-		memset(phys_to_virt(PFN_PHYS(pfn)), 0, size);
-	}
-	return ret;
-}
-
 /*
  * The p*d_populate functions call virt_to_phys implicitly so they can't be used
  * directly on kernel symbols (bm_p*d). All the early functions are called too
@@ -95,77 +36,117 @@ static int __meminit kasan_map_populate(unsigned long start, unsigned long end,
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
 
-	if (pmd_none(*pmd))
-		__pmd_populate(pmd, __pa_symbol(kasan_zero_pte), PMD_TYPE_TABLE);
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
+
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
@@ -202,8 +183,8 @@ void __init kasan_init(void)
 	struct memblock_region *reg;
 	int i;
 
-	kimg_shadow_start = (u64)kasan_mem_to_shadow(_text);
-	kimg_shadow_end = (u64)kasan_mem_to_shadow(_end);
+	kimg_shadow_start = (u64)kasan_mem_to_shadow(_text) & PAGE_MASK;
+	kimg_shadow_end = PAGE_ALIGN((u64)kasan_mem_to_shadow(_end));
 
 	mod_shadow_start = (u64)kasan_mem_to_shadow((void *)MODULES_VADDR);
 	mod_shadow_end = (u64)kasan_mem_to_shadow((void *)MODULES_END);
@@ -224,17 +205,6 @@ void __init kasan_init(void)
 	kasan_map_populate(kimg_shadow_start, kimg_shadow_end,
 			   pfn_to_nid(virt_to_pfn(lm_alias(_text))));
 
-	/*
-	 * kasan_map_populate() has populated the shadow region that covers the
-	 * kernel image with SWAPPER_BLOCK_SIZE mappings, so we have to round
-	 * the start and end addresses to SWAPPER_BLOCK_SIZE as well, to prevent
-	 * kasan_populate_zero_shadow() from replacing the page table entries
-	 * (PMD or PTE) at the edges of the shadow region for the kernel
-	 * image.
-	 */
-	kimg_shadow_start = round_down(kimg_shadow_start, SWAPPER_BLOCK_SIZE);
-	kimg_shadow_end = round_up(kimg_shadow_end, SWAPPER_BLOCK_SIZE);
-
 	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
 				   (void *)mod_shadow_start);
 	kasan_populate_zero_shadow((void *)kimg_shadow_end,
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

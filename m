Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA3C6B0037
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 21:35:42 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id a15so8174243eae.41
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:35:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e48si86953676eeh.50.2014.01.06.18.35.40
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 18:35:41 -0800 (PST)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH v2 5/5] arm64: add early_ioremap support
Date: Mon,  6 Jan 2014 21:35:20 -0500
Message-Id: <1389062120-31896-6-git-send-email-msalter@redhat.com>
In-Reply-To: <1389062120-31896-1-git-send-email-msalter@redhat.com>
References: <1389062120-31896-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, patches@linaro.org, linux-mm@kvack.org, Mark Salter <msalter@redhat.com>, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

Add support for early IO or memory mappings which are needed
before the normal ioremap() is usable. This also adds fixmap
support for permanent fixed mappings such as that used by the
earlyprintk device register region.

Signed-off-by: Mark Salter <msalter@redhat.com>
CC: linux-arm-kernel@lists.infradead.org
CC: Catalin Marinas <catalin.marinas@arm.com>
CC: Will Deacon <will.deacon@arm.com>
---
 Documentation/arm64/memory.txt   |  4 +-
 arch/arm64/Kconfig               |  1 +
 arch/arm64/include/asm/Kbuild    |  1 +
 arch/arm64/include/asm/fixmap.h  | 68 ++++++++++++++++++++++++++++++++
 arch/arm64/include/asm/io.h      |  1 +
 arch/arm64/include/asm/memory.h  |  2 +-
 arch/arm64/kernel/early_printk.c |  8 +++-
 arch/arm64/kernel/head.S         |  9 ++---
 arch/arm64/kernel/setup.c        |  2 +
 arch/arm64/mm/ioremap.c          | 85 ++++++++++++++++++++++++++++++++++++++++
 arch/arm64/mm/mmu.c              | 41 -------------------
 11 files changed, 170 insertions(+), 52 deletions(-)
 create mode 100644 arch/arm64/include/asm/fixmap.h

diff --git a/Documentation/arm64/memory.txt b/Documentation/arm64/memory.txt
index 5e054bf..953c81e 100644
--- a/Documentation/arm64/memory.txt
+++ b/Documentation/arm64/memory.txt
@@ -35,7 +35,7 @@ ffffffbc00000000	ffffffbdffffffff	   8GB		vmemmap
 
 ffffffbe00000000	ffffffbffbbfffff	  ~8GB		[guard, future vmmemap]
 
-ffffffbffbc00000	ffffffbffbdfffff	   2MB		earlyprintk device
+ffffffbffbc00000	ffffffbffbdfffff	   2MB		fixed mappings
 
 ffffffbffbe00000	ffffffbffbe0ffff	  64KB		PCI I/O space
 
@@ -60,7 +60,7 @@ fffffdfc00000000	fffffdfdffffffff	   8GB		vmemmap
 
 fffffdfe00000000	fffffdfffbbfffff	  ~8GB		[guard, future vmmemap]
 
-fffffdfffbc00000	fffffdfffbdfffff	   2MB		earlyprintk device
+fffffdfffbc00000	fffffdfffbdfffff	   2MB		fixed mappings
 
 fffffdfffbe00000	fffffdfffbe0ffff	  64KB		PCI I/O space
 
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 6d4dd22..e66a317 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -12,6 +12,7 @@ config ARM64
 	select CLONE_BACKWARDS
 	select COMMON_CLK
 	select GENERIC_CLOCKEVENTS
+	select GENERIC_EARLY_IOREMAP
 	select GENERIC_IOMAP
 	select GENERIC_IRQ_PROBE
 	select GENERIC_IRQ_SHOW
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index 519f89f..b7f99a3 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -10,6 +10,7 @@ generic-y += delay.h
 generic-y += div64.h
 generic-y += dma.h
 generic-y += emergency-restart.h
+generic-y += early_ioremap.h
 generic-y += errno.h
 generic-y += ftrace.h
 generic-y += hw_irq.h
diff --git a/arch/arm64/include/asm/fixmap.h b/arch/arm64/include/asm/fixmap.h
new file mode 100644
index 0000000..7ad4f29
--- /dev/null
+++ b/arch/arm64/include/asm/fixmap.h
@@ -0,0 +1,68 @@
+/*
+ * fixmap.h: compile-time virtual memory allocation
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 1998 Ingo Molnar
+ * Copyright (C) 2013 Mark Salter <msalter@redhat.com>
+ *
+ * Adapted from arch/x86_64 version.
+ *
+ */
+
+#ifndef _ASM_ARM64_FIXMAP_H
+#define _ASM_ARM64_FIXMAP_H
+
+#ifndef __ASSEMBLY__
+#include <linux/kernel.h>
+#include <asm/page.h>
+
+/*
+ * Here we define all the compile-time 'special' virtual
+ * addresses. The point is to have a constant address at
+ * compile time, but to set the physical address only
+ * in the boot process.
+ *
+ * These 'compile-time allocated' memory buffers are
+ * page-sized. Use set_fixmap(idx,phys) to associate
+ * physical memory with fixmap indices.
+ *
+ */
+enum fixed_addresses {
+	FIX_EARLYCON,
+	__end_of_permanent_fixed_addresses,
+
+	/*
+	 * Temporary boot-time mappings, used by early_ioremap(),
+	 * before ioremap() is functional.
+	 */
+#ifdef CONFIG_ARM64_64K_PAGES
+#define NR_FIX_BTMAPS		4
+#else
+#define NR_FIX_BTMAPS		64
+#endif
+#define FIX_BTMAPS_SLOTS	7
+#define TOTAL_FIX_BTMAPS	(NR_FIX_BTMAPS * FIX_BTMAPS_SLOTS)
+
+	FIX_BTMAP_END = __end_of_permanent_fixed_addresses,
+	FIX_BTMAP_BEGIN = FIX_BTMAP_END + TOTAL_FIX_BTMAPS - 1,
+	__end_of_fixed_addresses
+};
+
+#define FIXADDR_SIZE	(__end_of_permanent_fixed_addresses << PAGE_SHIFT)
+#define FIXADDR_START	(FIXADDR_TOP - FIXADDR_SIZE)
+
+#define FIXMAP_PAGE_NORMAL PAGE_KERNEL_EXEC
+#define FIXMAP_PAGE_IO     __pgprot(PROT_DEVICE_nGnRE)
+
+extern void __early_set_fixmap(enum fixed_addresses idx,
+			       phys_addr_t phys, pgprot_t flags);
+
+#define __set_fixmap __early_set_fixmap
+
+#include <asm-generic/fixmap.h>
+
+#endif /* !__ASSEMBLY__ */
+#endif /* _ASM_ARM64_FIXMAP_H */
diff --git a/arch/arm64/include/asm/io.h b/arch/arm64/include/asm/io.h
index 5727697..1e34831 100644
--- a/arch/arm64/include/asm/io.h
+++ b/arch/arm64/include/asm/io.h
@@ -27,6 +27,7 @@
 #include <asm/byteorder.h>
 #include <asm/barrier.h>
 #include <asm/pgtable.h>
+#include <asm/early_ioremap.h>
 
 #include <xen/xen.h>
 
diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index 3776217..50a97df 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -49,7 +49,7 @@
 #define PAGE_OFFSET		(UL(0xffffffffffffffff) << (VA_BITS - 1))
 #define MODULES_END		(PAGE_OFFSET)
 #define MODULES_VADDR		(MODULES_END - SZ_64M)
-#define EARLYCON_IOBASE		(MODULES_VADDR - SZ_4M)
+#define FIXADDR_TOP		(MODULES_VADDR - SZ_2M - PAGE_SIZE)
 #define TASK_SIZE_64		(UL(1) << VA_BITS)
 
 #ifdef CONFIG_COMPAT
diff --git a/arch/arm64/kernel/early_printk.c b/arch/arm64/kernel/early_printk.c
index fbb6e18..850d9a4 100644
--- a/arch/arm64/kernel/early_printk.c
+++ b/arch/arm64/kernel/early_printk.c
@@ -26,6 +26,8 @@
 #include <linux/amba/serial.h>
 #include <linux/serial_reg.h>
 
+#include <asm/fixmap.h>
+
 static void __iomem *early_base;
 static void (*printch)(char ch);
 
@@ -141,8 +143,10 @@ static int __init setup_early_printk(char *buf)
 	}
 	/* no options parsing yet */
 
-	if (paddr)
-		early_base = early_io_map(paddr, EARLYCON_IOBASE);
+	if (paddr) {
+		set_fixmap_io(FIX_EARLYCON, paddr);
+		early_base = (void __iomem *)fix_to_virt(FIX_EARLYCON);
+	}
 
 	printch = match->printch;
 	early_console = &early_console_dev;
diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
index c68cca5..4b47dcb 100644
--- a/arch/arm64/kernel/head.S
+++ b/arch/arm64/kernel/head.S
@@ -412,7 +412,7 @@ ENDPROC(__calc_phys_offset)
  *   - identity mapping to enable the MMU (low address, TTBR0)
  *   - first few MB of the kernel linear mapping to jump to once the MMU has
  *     been enabled, including the FDT blob (TTBR1)
- *   - UART mapping if CONFIG_EARLY_PRINTK is enabled (TTBR1)
+ *   - pgd entry for fixed mappings (TTBR1)
  */
 __create_page_tables:
 	pgtbl	x25, x26, x24			// idmap_pg_dir and swapper_pg_dir addresses
@@ -465,15 +465,12 @@ __create_page_tables:
 	sub	x6, x6, #1			// inclusive range
 	create_block_map x0, x7, x3, x5, x6
 1:
-#ifdef CONFIG_EARLY_PRINTK
 	/*
-	 * Create the pgd entry for the UART mapping. The full mapping is done
-	 * later based earlyprintk kernel parameter.
+	 * Create the pgd entry for the fixed mappings.
 	 */
-	ldr	x5, =EARLYCON_IOBASE		// UART virtual address
+	ldr	x5, =FIXADDR_TOP		// Fixed mapping virtual address
 	add	x0, x26, #2 * PAGE_SIZE		// section table address
 	create_pgd_entry x26, x0, x5, x6, x7
-#endif
 	ret
 ENDPROC(__create_page_tables)
 	.ltorg
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 029ecfe..5516f54 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -42,6 +42,7 @@
 #include <linux/of_fdt.h>
 #include <linux/of_platform.h>
 
+#include <asm/fixmap.h>
 #include <asm/cputype.h>
 #include <asm/elf.h>
 #include <asm/cputable.h>
@@ -222,6 +223,7 @@ void __init setup_arch(char **cmdline_p)
 	*cmdline_p = boot_command_line;
 
 	init_mem_pgprot();
+	early_ioremap_init();
 
 	parse_early_param();
 
diff --git a/arch/arm64/mm/ioremap.c b/arch/arm64/mm/ioremap.c
index 2bb1d58..7ec3283 100644
--- a/arch/arm64/mm/ioremap.c
+++ b/arch/arm64/mm/ioremap.c
@@ -25,6 +25,10 @@
 #include <linux/vmalloc.h>
 #include <linux/io.h>
 
+#include <asm/fixmap.h>
+#include <asm/tlbflush.h>
+#include <asm/pgalloc.h>
+
 static void __iomem *__ioremap_caller(phys_addr_t phys_addr, size_t size,
 				      pgprot_t prot, void *caller)
 {
@@ -98,3 +102,84 @@ void __iomem *ioremap_cache(phys_addr_t phys_addr, size_t size)
 				__builtin_return_address(0));
 }
 EXPORT_SYMBOL(ioremap_cache);
+
+#ifndef CONFIG_ARM64_64K_PAGES
+static pte_t bm_pte[PTRS_PER_PTE] __page_aligned_bss;
+#endif
+
+static inline pmd_t * __init early_ioremap_pmd(unsigned long addr)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+
+	pgd = pgd_offset_k(addr);
+	BUG_ON(pgd_none(*pgd) || pgd_bad(*pgd));
+
+	pud = pud_offset(pgd, addr);
+	BUG_ON(pud_none(*pud) || pud_bad(*pud));
+
+	return pmd_offset(pud, addr);
+}
+
+static inline pte_t * __init early_ioremap_pte(unsigned long addr)
+{
+	pmd_t *pmd = early_ioremap_pmd(addr);
+
+	BUG_ON(pmd_none(*pmd) || pmd_bad(*pmd));
+
+	return pte_offset_kernel(pmd, addr);
+}
+
+void __init early_ioremap_init(void)
+{
+	pmd_t *pmd;
+
+	pmd = early_ioremap_pmd(fix_to_virt(FIX_BTMAP_BEGIN));
+#ifndef CONFIG_ARM64_64K_PAGES
+	/* need to populate pmd for 4k pagesize only */
+	pmd_populate_kernel(&init_mm, pmd, bm_pte);
+#endif
+	/*
+	 * The boot-ioremap range spans multiple pmds, for which
+	 * we are not prepared:
+	 */
+	BUILD_BUG_ON((__fix_to_virt(FIX_BTMAP_BEGIN) >> PMD_SHIFT)
+		     != (__fix_to_virt(FIX_BTMAP_END) >> PMD_SHIFT));
+
+	if (pmd != early_ioremap_pmd(fix_to_virt(FIX_BTMAP_END))) {
+		WARN_ON(1);
+		pr_warn("pmd %p != %p\n",
+			pmd, early_ioremap_pmd(fix_to_virt(FIX_BTMAP_END)));
+		pr_warn("fix_to_virt(FIX_BTMAP_BEGIN): %08lx\n",
+			fix_to_virt(FIX_BTMAP_BEGIN));
+		pr_warn("fix_to_virt(FIX_BTMAP_END):   %08lx\n",
+			fix_to_virt(FIX_BTMAP_END));
+
+		pr_warn("FIX_BTMAP_END:       %d\n", FIX_BTMAP_END);
+		pr_warn("FIX_BTMAP_BEGIN:     %d\n",
+			FIX_BTMAP_BEGIN);
+	}
+
+	early_ioremap_setup();
+}
+
+void __init __early_set_fixmap(enum fixed_addresses idx,
+			       phys_addr_t phys, pgprot_t flags)
+{
+	unsigned long addr = __fix_to_virt(idx);
+	pte_t *pte;
+
+	if (idx >= __end_of_fixed_addresses) {
+		BUG();
+		return;
+	}
+
+	pte = early_ioremap_pte(addr);
+
+	if (pgprot_val(flags))
+		set_pte(pte, pfn_pte(phys >> PAGE_SHIFT, flags));
+	else {
+		pte_clear(&init_mm, addr, pte);
+		flush_tlb_kernel_range(addr, addr+PAGE_SIZE);
+	}
+}
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 541c782..7b345e3 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -252,47 +252,6 @@ static void __init create_mapping(phys_addr_t phys, unsigned long virt,
 	} while (pgd++, addr = next, addr != end);
 }
 
-#ifdef CONFIG_EARLY_PRINTK
-/*
- * Create an early I/O mapping using the pgd/pmd entries already populated
- * in head.S as this function is called too early to allocated any memory. The
- * mapping size is 2MB with 4KB pages or 64KB or 64KB pages.
- */
-void __iomem * __init early_io_map(phys_addr_t phys, unsigned long virt)
-{
-	unsigned long size, mask;
-	bool page64k = IS_ENABLED(CONFIG_ARM64_64K_PAGES);
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-
-	/*
-	 * No early pte entries with !ARM64_64K_PAGES configuration, so using
-	 * sections (pmd).
-	 */
-	size = page64k ? PAGE_SIZE : SECTION_SIZE;
-	mask = ~(size - 1);
-
-	pgd = pgd_offset_k(virt);
-	pud = pud_offset(pgd, virt);
-	if (pud_none(*pud))
-		return NULL;
-	pmd = pmd_offset(pud, virt);
-
-	if (page64k) {
-		if (pmd_none(*pmd))
-			return NULL;
-		pte = pte_offset_kernel(pmd, virt);
-		set_pte(pte, __pte((phys & mask) | PROT_DEVICE_nGnRE));
-	} else {
-		set_pmd(pmd, __pmd((phys & mask) | PROT_SECT_DEVICE_nGnRE));
-	}
-
-	return (void __iomem *)((virt & mask) + (phys & ~mask));
-}
-#endif
-
 static void __init map_mem(void)
 {
 	struct memblock_region *reg;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

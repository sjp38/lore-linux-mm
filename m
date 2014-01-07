Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id A1BE86B0038
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 21:35:46 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id w62so47873wes.34
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:35:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id vo5si28289532wjc.58.2014.01.06.18.35.45
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 18:35:45 -0800 (PST)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH v2 3/5] arm: add early_ioremap support
Date: Mon,  6 Jan 2014 21:35:18 -0500
Message-Id: <1389062120-31896-4-git-send-email-msalter@redhat.com>
In-Reply-To: <1389062120-31896-1-git-send-email-msalter@redhat.com>
References: <1389062120-31896-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, patches@linaro.org, linux-mm@kvack.org, Mark Salter <msalter@redhat.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>

This patch uses the generic early_ioremap code to implement
early_ioremap for ARM. The ARM-specific bits come mostly from
an earlier patch from Leif Lindholm <leif.lindholm@linaro.org>
here:

  https://lkml.org/lkml/2013/10/3/279

Signed-off-by: Mark Salter <msalter@redhat.com>
Tested-by: Leif Lindholm <leif.lindholm@linaro.org>
CC: linux-arm-kernel@lists.infradead.org
CC: Russell King <linux@arm.linux.org.uk>
CC: Catalin Marinas <catalin.marinas@arm.com>
CC: Will Deacon <will.deacon@arm.com>
CC: Arnd Bergmann <arnd@arndb.de>
---
 arch/arm/Kconfig              | 11 +++++
 arch/arm/include/asm/Kbuild   |  1 +
 arch/arm/include/asm/fixmap.h | 18 +++++++++
 arch/arm/include/asm/io.h     |  1 +
 arch/arm/kernel/setup.c       |  3 ++
 arch/arm/mm/Makefile          |  1 +
 arch/arm/mm/early_ioremap.c   | 93 +++++++++++++++++++++++++++++++++++++++++++
 arch/arm/mm/mmu.c             |  2 +
 8 files changed, 130 insertions(+)
 create mode 100644 arch/arm/mm/early_ioremap.c

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index c1f1a7e..78a79a6a 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1842,6 +1842,17 @@ config UACCESS_WITH_MEMCPY
 	  However, if the CPU data cache is using a write-allocate mode,
 	  this option is unlikely to provide any performance gain.
 
+config EARLY_IOREMAP
+	depends on MMU
+	bool "Provide early_ioremap() support for kernel initialization."
+	select GENERIC_EARLY_IOREMAP
+	help
+	  Provide a mechanism for kernel initialisation code to temporarily
+	  map, in a highmem-agnostic way, memory pages in before ioremap()
+	  and friends are available (before paging_init() has run). It uses
+	  the same virtual memory range as kmap so all early mappings must
+	  be unapped before paging_init() is called.
+
 config SECCOMP
 	bool
 	prompt "Enable seccomp to safely compute untrusted bytecode"
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index c38b58c..49ec506 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -4,6 +4,7 @@ generic-y += auxvec.h
 generic-y += bitsperlong.h
 generic-y += cputime.h
 generic-y += current.h
+generic-y += early_ioremap.h
 generic-y += emergency-restart.h
 generic-y += errno.h
 generic-y += exec.h
diff --git a/arch/arm/include/asm/fixmap.h b/arch/arm/include/asm/fixmap.h
index 68ea615..e92b7a4 100644
--- a/arch/arm/include/asm/fixmap.h
+++ b/arch/arm/include/asm/fixmap.h
@@ -21,8 +21,26 @@ enum fixed_addresses {
 	FIX_KMAP_BEGIN,
 	FIX_KMAP_END = (FIXADDR_TOP - FIXADDR_START) >> PAGE_SHIFT,
 	__end_of_fixed_addresses
+/*
+ * 224 temporary boot-time mappings, used by early_ioremap(),
+ * before ioremap() is functional.
+ *
+ * (P)re-using the FIXADDR region, which is used for highmem
+ * later on, and statically aligned to 1MB.
+ */
+#define NR_FIX_BTMAPS		32
+#define FIX_BTMAPS_SLOTS	7
+#define TOTAL_FIX_BTMAPS	(NR_FIX_BTMAPS * FIX_BTMAPS_SLOTS)
+#define FIX_BTMAP_END		FIX_KMAP_BEGIN
+#define FIX_BTMAP_BEGIN		(FIX_BTMAP_END + TOTAL_FIX_BTMAPS - 1)
 };
 
+#define FIXMAP_PAGE_NORMAL (L_PTE_MT_WRITEBACK | L_PTE_YOUNG | L_PTE_PRESENT)
+#define FIXMAP_PAGE_IO (L_PTE_MT_DEV_NONSHARED | L_PTE_YOUNG | L_PTE_PRESENT)
+
+extern void __early_set_fixmap(enum fixed_addresses idx,
+			       phys_addr_t phys, pgprot_t flags);
+
 #include <asm-generic/fixmap.h>
 
 #endif
diff --git a/arch/arm/include/asm/io.h b/arch/arm/include/asm/io.h
index 3c597c2..131e0ba 100644
--- a/arch/arm/include/asm/io.h
+++ b/arch/arm/include/asm/io.h
@@ -28,6 +28,7 @@
 #include <asm/byteorder.h>
 #include <asm/memory.h>
 #include <asm-generic/pci_iomap.h>
+#include <asm/early_ioremap.h>
 #include <xen/xen.h>
 
 /*
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 987a7f5..038fb75 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -36,6 +36,7 @@
 #include <asm/cpu.h>
 #include <asm/cputype.h>
 #include <asm/elf.h>
+#include <asm/io.h>
 #include <asm/procinfo.h>
 #include <asm/psci.h>
 #include <asm/sections.h>
@@ -887,6 +888,8 @@ void __init setup_arch(char **cmdline_p)
 
 	parse_early_param();
 
+	early_ioremap_init();
+
 	sort(&meminfo.bank, meminfo.nr_banks, sizeof(meminfo.bank[0]), meminfo_cmp, NULL);
 
 	early_paging_init(mdesc, lookup_processor_type(read_cpuid_id()));
diff --git a/arch/arm/mm/Makefile b/arch/arm/mm/Makefile
index ecfe6e5..fea855e 100644
--- a/arch/arm/mm/Makefile
+++ b/arch/arm/mm/Makefile
@@ -15,6 +15,7 @@ endif
 obj-$(CONFIG_MODULES)		+= proc-syms.o
 
 obj-$(CONFIG_ALIGNMENT_TRAP)	+= alignment.o
+obj-$(CONFIG_EARLY_IOREMAP)	+= early_ioremap.o
 obj-$(CONFIG_HIGHMEM)		+= highmem.o
 obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
 
diff --git a/arch/arm/mm/early_ioremap.c b/arch/arm/mm/early_ioremap.c
new file mode 100644
index 0000000..c3e2bf2
--- /dev/null
+++ b/arch/arm/mm/early_ioremap.c
@@ -0,0 +1,93 @@
+/*
+ * early_ioremap() support for ARM
+ *
+ * Based on existing support in arch/x86/mm/ioremap.c
+ *
+ * Restrictions: currently only functional before paging_init()
+ */
+
+#include <linux/init.h>
+#include <linux/io.h>
+
+#include <asm/fixmap.h>
+#include <asm/pgalloc.h>
+#include <asm/pgtable.h>
+#include <asm/tlbflush.h>
+
+#include <asm/mach/map.h>
+
+static pte_t bm_pte[PTRS_PER_PTE] __aligned(PTE_HWTABLE_SIZE) __initdata;
+
+static inline pmd_t * __init early_ioremap_pmd(unsigned long addr)
+{
+	unsigned int index = pgd_index(addr);
+	pgd_t *pgd = cpu_get_pgd() + index;
+	pud_t *pud = pud_offset(pgd, addr);
+	pmd_t *pmd = pmd_offset(pud, addr);
+
+	return pmd;
+}
+
+static inline pte_t * __init early_ioremap_pte(unsigned long addr)
+{
+	return &bm_pte[pte_index(addr)];
+}
+
+void __init early_ioremap_init(void)
+{
+	pmd_t *pmd;
+
+	pmd = early_ioremap_pmd(fix_to_virt(FIX_BTMAP_BEGIN));
+
+	pmd_populate_kernel(NULL, pmd, bm_pte);
+
+	/*
+	 * Make sure we don't span multiple pmds.
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
+		pr_warn("FIX_BTMAP_END:       %d\n", FIX_BTMAP_END);
+		pr_warn("FIX_BTMAP_BEGIN:     %d\n", FIX_BTMAP_BEGIN);
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
+	u64 desc;
+
+	if (idx > FIX_KMAP_END) {
+		BUG();
+		return;
+	}
+	pte = early_ioremap_pte(addr);
+
+	if (pgprot_val(flags))
+		set_pte_at(NULL, 0xfff00000, pte,
+			   pfn_pte(phys >> PAGE_SHIFT, flags));
+	else
+		pte_clear(NULL, addr, pte);
+	flush_tlb_kernel_range(addr, addr + PAGE_SIZE);
+	desc = *pte;
+}
+
+void __init
+early_ioremap_shutdown(void)
+{
+	pmd_t *pmd;
+	pmd = early_ioremap_pmd(fix_to_virt(FIX_BTMAP_BEGIN));
+	pmd_clear(pmd);
+}
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index 580ef2d..bef59b9 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -34,6 +34,7 @@
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
 #include <asm/mach/pci.h>
+#include <asm/early_ioremap.h>
 
 #include "mm.h"
 #include "tcm.h"
@@ -1405,6 +1406,7 @@ void __init paging_init(const struct machine_desc *mdesc)
 {
 	void *zero_page;
 
+	early_ioremap_reset();
 	build_mem_type_table();
 	prepare_page_table();
 	map_lowmem();
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

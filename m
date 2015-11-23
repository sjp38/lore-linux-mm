Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 94F846B0259
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:07:11 -0500 (EST)
Received: by wmec201 with SMTP id c201so150006417wme.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:07:11 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id f2si17852885wma.46.2015.11.23.01.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 01:07:10 -0800 (PST)
Received: by wmuu63 with SMTP id u63so44712023wmu.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:07:10 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v3 06/13] ARM: add support for generic early_ioremap/early_memremap
Date: Mon, 23 Nov 2015 10:06:26 +0100
Message-Id: <1448269593-20758-7-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

This enables the generic early_ioremap implementation for ARM.

It uses the fixmap region reserved for kmap. Since early_ioremap
is only supported before paging_init(), and kmap is only supported
afterwards, this is guaranteed not to cause any clashes.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm/Kconfig              |  1 +
 arch/arm/include/asm/Kbuild   |  1 +
 arch/arm/include/asm/fixmap.h | 29 +++++++++++++++++++-
 arch/arm/kernel/setup.c       |  7 +++--
 arch/arm/mm/ioremap.c         |  9 ++++++
 arch/arm/mm/mmu.c             |  2 +-
 6 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 0365cbbc9179..7e338228cc8d 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -20,6 +20,7 @@ config ARM
 	select GENERIC_ALLOCATOR
 	select GENERIC_ATOMIC64 if (CPU_V7M || CPU_V6 || !CPU_32v6K || !AEABI)
 	select GENERIC_CLOCKEVENTS_BROADCAST if SMP
+	select GENERIC_EARLY_IOREMAP
 	select GENERIC_IDLE_POLL_SETUP
 	select GENERIC_IRQ_PROBE
 	select GENERIC_IRQ_SHOW
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index bd425302c97a..16da6380eb85 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -3,6 +3,7 @@
 generic-y += bitsperlong.h
 generic-y += cputime.h
 generic-y += current.h
+generic-y += early_ioremap.h
 generic-y += emergency-restart.h
 generic-y += errno.h
 generic-y += exec.h
diff --git a/arch/arm/include/asm/fixmap.h b/arch/arm/include/asm/fixmap.h
index 58cfe9f1a687..5c17d2dec777 100644
--- a/arch/arm/include/asm/fixmap.h
+++ b/arch/arm/include/asm/fixmap.h
@@ -19,20 +19,47 @@ enum fixed_addresses {
 	FIX_TEXT_POKE0,
 	FIX_TEXT_POKE1,
 
-	__end_of_fixed_addresses
+	__end_of_fixmap_region,
+
+	/*
+	 * Share the kmap() region with early_ioremap(): this is guaranteed
+	 * not to clash since early_ioremap() is only available before
+	 * paging_init(), and kmap() only after.
+	 */
+#define NR_FIX_BTMAPS		32
+#define FIX_BTMAPS_SLOTS	7
+#define TOTAL_FIX_BTMAPS	(NR_FIX_BTMAPS * FIX_BTMAPS_SLOTS)
+
+	FIX_BTMAP_END = __end_of_permanent_fixed_addresses,
+	FIX_BTMAP_BEGIN = FIX_BTMAP_END + TOTAL_FIX_BTMAPS - 1,
+	__end_of_early_ioremap_region
 };
 
+static const enum fixed_addresses __end_of_fixed_addresses =
+	__end_of_fixmap_region > __end_of_early_ioremap_region ?
+	__end_of_fixmap_region : __end_of_early_ioremap_region;
+
 #define FIXMAP_PAGE_COMMON	(L_PTE_YOUNG | L_PTE_PRESENT | L_PTE_XN | L_PTE_DIRTY)
 
 #define FIXMAP_PAGE_NORMAL	(FIXMAP_PAGE_COMMON | L_PTE_MT_WRITEBACK)
+#define FIXMAP_PAGE_RO		(FIXMAP_PAGE_NORMAL | L_PTE_RDONLY)
 
 /* Used by set_fixmap_(io|nocache), both meant for mapping a device */
 #define FIXMAP_PAGE_IO		(FIXMAP_PAGE_COMMON | L_PTE_MT_DEV_SHARED | L_PTE_SHARED)
 #define FIXMAP_PAGE_NOCACHE	FIXMAP_PAGE_IO
 
+#define __early_set_fixmap	__set_fixmap
+
+#ifdef CONFIG_MMU
+
 void __set_fixmap(enum fixed_addresses idx, phys_addr_t phys, pgprot_t prot);
 void __init early_fixmap_init(void);
 
 #include <asm-generic/fixmap.h>
 
+#else
+
+static inline void early_fixmap_init(void) { }
+
+#endif
 #endif
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 20edd349d379..5df2bca57c42 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -38,6 +38,7 @@
 #include <asm/cpu.h>
 #include <asm/cputype.h>
 #include <asm/elf.h>
+#include <asm/early_ioremap.h>
 #include <asm/fixmap.h>
 #include <asm/procinfo.h>
 #include <asm/psci.h>
@@ -956,8 +957,8 @@ void __init setup_arch(char **cmdline_p)
 	strlcpy(cmd_line, boot_command_line, COMMAND_LINE_SIZE);
 	*cmdline_p = cmd_line;
 
-	if (IS_ENABLED(CONFIG_FIX_EARLYCON_MEM))
-		early_fixmap_init();
+	early_fixmap_init();
+	early_ioremap_init();
 
 	parse_early_param();
 
@@ -968,6 +969,8 @@ void __init setup_arch(char **cmdline_p)
 	sanity_check_meminfo();
 	arm_memblock_init(mdesc);
 
+	early_ioremap_reset();
+
 	paging_init(mdesc);
 	request_standard_resources(mdesc);
 
diff --git a/arch/arm/mm/ioremap.c b/arch/arm/mm/ioremap.c
index 0c81056c1dd7..66a978d05958 100644
--- a/arch/arm/mm/ioremap.c
+++ b/arch/arm/mm/ioremap.c
@@ -30,6 +30,7 @@
 #include <asm/cp15.h>
 #include <asm/cputype.h>
 #include <asm/cacheflush.h>
+#include <asm/early_ioremap.h>
 #include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
@@ -469,3 +470,11 @@ int pci_ioremap_io(unsigned int offset, phys_addr_t phys_addr)
 }
 EXPORT_SYMBOL_GPL(pci_ioremap_io);
 #endif
+
+/*
+ * Must be called after early_fixmap_init
+ */
+void __init early_ioremap_init(void)
+{
+	early_ioremap_setup();
+}
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index 4867f5daf82c..de19f90221e2 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -390,7 +390,7 @@ void __init early_fixmap_init(void)
 	 * The early fixmap range spans multiple pmds, for which
 	 * we are not prepared:
 	 */
-	BUILD_BUG_ON((__fix_to_virt(__end_of_permanent_fixed_addresses) >> PMD_SHIFT)
+	BUILD_BUG_ON((__fix_to_virt(__end_of_early_ioremap_region) >> PMD_SHIFT)
 		     != FIXADDR_TOP >> PMD_SHIFT);
 
 	pmd = fixmap_pmd(FIXADDR_TOP);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

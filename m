Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 38E046B0036
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 21:35:40 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so8064368eek.26
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:35:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r9si86903143eeo.128.2014.01.06.18.35.38
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 18:35:39 -0800 (PST)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH v2 2/5] x86: use generic early_ioremap
Date: Mon,  6 Jan 2014 21:35:17 -0500
Message-Id: <1389062120-31896-3-git-send-email-msalter@redhat.com>
In-Reply-To: <1389062120-31896-1-git-send-email-msalter@redhat.com>
References: <1389062120-31896-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, patches@linaro.org, linux-mm@kvack.org, Mark Salter <msalter@redhat.com>, x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

Move x86 over to the generic early ioremap implementation. The
generic implementation is functionally the same except that the
early_memremap() function returns a normal pointer instead of an
__iomem pointer. This is in line with sparse warning cleanups in
this patch series:

   https://lkml.org/lkml/2013/12/22/69

Signed-off-by: Mark Salter <msalter@redhat.com>
CC: x86@kernel.org
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Arnd Bergmann <arnd@arndb.de>
CC: Ingo Molnar <mingo@kernel.org>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: "H. Peter Anvin" <hpa@zytor.com>
---
 arch/x86/Kconfig              |   1 +
 arch/x86/include/asm/Kbuild   |   1 +
 arch/x86/include/asm/fixmap.h |   6 ++
 arch/x86/include/asm/io.h     |  14 +--
 arch/x86/mm/ioremap.c         | 224 +-----------------------------------------
 arch/x86/mm/pgtable_32.c      |   2 +-
 6 files changed, 13 insertions(+), 235 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 0952ecd..50e1eab 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -125,6 +125,7 @@ config X86
 	select RTC_LIB
 	select HAVE_DEBUG_STACKOVERFLOW
 	select HAVE_IRQ_EXIT_ON_IRQ_STACK if X86_64
+	select GENERIC_EARLY_IOREMAP
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index 7f66985..203f5f9 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -5,3 +5,4 @@ genhdr-y += unistd_64.h
 genhdr-y += unistd_x32.h
 
 generic-y += clkdev.h
+generic-y += early_ioremap.h
diff --git a/arch/x86/include/asm/fixmap.h b/arch/x86/include/asm/fixmap.h
index 7252cd3..e5f236d 100644
--- a/arch/x86/include/asm/fixmap.h
+++ b/arch/x86/include/asm/fixmap.h
@@ -177,5 +177,11 @@ static inline void __set_fixmap(enum fixed_addresses idx,
 
 #include <asm-generic/fixmap.h>
 
+#define __late_set_fixmap(idx, phys, flags) __set_fixmap(idx, phys, flags)
+#define __late_clear_fixmap(idx) __set_fixmap(idx, 0, __pgprot(0))
+
+void __early_set_fixmap(enum fixed_addresses idx,
+			phys_addr_t phys, pgprot_t flags);
+
 #endif /* !__ASSEMBLY__ */
 #endif /* _ASM_X86_FIXMAP_H */
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 34f69cb..aae7010 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -39,6 +39,7 @@
 #include <linux/string.h>
 #include <linux/compiler.h>
 #include <asm/page.h>
+#include <asm/early_ioremap.h>
 
 #define build_mmio_read(name, size, type, reg, barrier) \
 static inline type name(const volatile void __iomem *addr) \
@@ -316,19 +317,6 @@ extern int ioremap_change_attr(unsigned long vaddr, unsigned long size,
 				unsigned long prot_val);
 extern void __iomem *ioremap_wc(resource_size_t offset, unsigned long size);
 
-/*
- * early_ioremap() and early_iounmap() are for temporary early boot-time
- * mappings, before the real ioremap() is functional.
- * A boot-time mapping is currently limited to at most 16 pages.
- */
-extern void early_ioremap_init(void);
-extern void early_ioremap_reset(void);
-extern void __iomem *early_ioremap(resource_size_t phys_addr,
-				   unsigned long size);
-extern void __iomem *early_memremap(resource_size_t phys_addr,
-				    unsigned long size);
-extern void early_iounmap(void __iomem *addr, unsigned long size);
-extern void fixup_early_ioremap(void);
 extern bool is_early_ioremap_ptep(pte_t *ptep);
 
 #ifdef CONFIG_XEN
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 799580c..597ac15 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -328,17 +328,6 @@ void unxlate_dev_mem_ptr(unsigned long phys, void *addr)
 	return;
 }
 
-static int __initdata early_ioremap_debug;
-
-static int __init early_ioremap_debug_setup(char *str)
-{
-	early_ioremap_debug = 1;
-
-	return 0;
-}
-early_param("early_ioremap_debug", early_ioremap_debug_setup);
-
-static __initdata int after_paging_init;
 static pte_t bm_pte[PAGE_SIZE/sizeof(pte_t)] __page_aligned_bss;
 
 static inline pmd_t * __init early_ioremap_pmd(unsigned long addr)
@@ -362,18 +351,11 @@ bool __init is_early_ioremap_ptep(pte_t *ptep)
 	return ptep >= &bm_pte[0] && ptep < &bm_pte[PAGE_SIZE/sizeof(pte_t)];
 }
 
-static unsigned long slot_virt[FIX_BTMAPS_SLOTS] __initdata;
-
 void __init early_ioremap_init(void)
 {
 	pmd_t *pmd;
-	int i;
 
-	if (early_ioremap_debug)
-		printk(KERN_INFO "early_ioremap_init()\n");
-
-	for (i = 0; i < FIX_BTMAPS_SLOTS; i++)
-		slot_virt[i] = __fix_to_virt(FIX_BTMAP_BEGIN - NR_FIX_BTMAPS*i);
+	early_ioremap_setup();
 
 	pmd = early_ioremap_pmd(fix_to_virt(FIX_BTMAP_BEGIN));
 	memset(bm_pte, 0, sizeof(bm_pte));
@@ -402,13 +384,8 @@ void __init early_ioremap_init(void)
 	}
 }
 
-void __init early_ioremap_reset(void)
-{
-	after_paging_init = 1;
-}
-
-static void __init __early_set_fixmap(enum fixed_addresses idx,
-				      phys_addr_t phys, pgprot_t flags)
+void __init __early_set_fixmap(enum fixed_addresses idx,
+			       phys_addr_t phys, pgprot_t flags)
 {
 	unsigned long addr = __fix_to_virt(idx);
 	pte_t *pte;
@@ -425,198 +402,3 @@ static void __init __early_set_fixmap(enum fixed_addresses idx,
 		pte_clear(&init_mm, addr, pte);
 	__flush_tlb_one(addr);
 }
-
-static inline void __init early_set_fixmap(enum fixed_addresses idx,
-					   phys_addr_t phys, pgprot_t prot)
-{
-	if (after_paging_init)
-		__set_fixmap(idx, phys, prot);
-	else
-		__early_set_fixmap(idx, phys, prot);
-}
-
-static inline void __init early_clear_fixmap(enum fixed_addresses idx)
-{
-	if (after_paging_init)
-		clear_fixmap(idx);
-	else
-		__early_set_fixmap(idx, 0, __pgprot(0));
-}
-
-static void __iomem *prev_map[FIX_BTMAPS_SLOTS] __initdata;
-static unsigned long prev_size[FIX_BTMAPS_SLOTS] __initdata;
-
-void __init fixup_early_ioremap(void)
-{
-	int i;
-
-	for (i = 0; i < FIX_BTMAPS_SLOTS; i++) {
-		if (prev_map[i]) {
-			WARN_ON(1);
-			break;
-		}
-	}
-
-	early_ioremap_init();
-}
-
-static int __init check_early_ioremap_leak(void)
-{
-	int count = 0;
-	int i;
-
-	for (i = 0; i < FIX_BTMAPS_SLOTS; i++)
-		if (prev_map[i])
-			count++;
-
-	if (!count)
-		return 0;
-	WARN(1, KERN_WARNING
-	       "Debug warning: early ioremap leak of %d areas detected.\n",
-		count);
-	printk(KERN_WARNING
-		"please boot with early_ioremap_debug and report the dmesg.\n");
-
-	return 1;
-}
-late_initcall(check_early_ioremap_leak);
-
-static void __init __iomem *
-__early_ioremap(resource_size_t phys_addr, unsigned long size, pgprot_t prot)
-{
-	unsigned long offset;
-	resource_size_t last_addr;
-	unsigned int nrpages;
-	enum fixed_addresses idx;
-	int i, slot;
-
-	WARN_ON(system_state != SYSTEM_BOOTING);
-
-	slot = -1;
-	for (i = 0; i < FIX_BTMAPS_SLOTS; i++) {
-		if (!prev_map[i]) {
-			slot = i;
-			break;
-		}
-	}
-
-	if (slot < 0) {
-		printk(KERN_INFO "%s(%08llx, %08lx) not found slot\n",
-		       __func__, (u64)phys_addr, size);
-		WARN_ON(1);
-		return NULL;
-	}
-
-	if (early_ioremap_debug) {
-		printk(KERN_INFO "%s(%08llx, %08lx) [%d] => ",
-		       __func__, (u64)phys_addr, size, slot);
-		dump_stack();
-	}
-
-	/* Don't allow wraparound or zero size */
-	last_addr = phys_addr + size - 1;
-	if (!size || last_addr < phys_addr) {
-		WARN_ON(1);
-		return NULL;
-	}
-
-	prev_size[slot] = size;
-	/*
-	 * Mappings have to be page-aligned
-	 */
-	offset = phys_addr & ~PAGE_MASK;
-	phys_addr &= PAGE_MASK;
-	size = PAGE_ALIGN(last_addr + 1) - phys_addr;
-
-	/*
-	 * Mappings have to fit in the FIX_BTMAP area.
-	 */
-	nrpages = size >> PAGE_SHIFT;
-	if (nrpages > NR_FIX_BTMAPS) {
-		WARN_ON(1);
-		return NULL;
-	}
-
-	/*
-	 * Ok, go for it..
-	 */
-	idx = FIX_BTMAP_BEGIN - NR_FIX_BTMAPS*slot;
-	while (nrpages > 0) {
-		early_set_fixmap(idx, phys_addr, prot);
-		phys_addr += PAGE_SIZE;
-		--idx;
-		--nrpages;
-	}
-	if (early_ioremap_debug)
-		printk(KERN_CONT "%08lx + %08lx\n", offset, slot_virt[slot]);
-
-	prev_map[slot] = (void __iomem *)(offset + slot_virt[slot]);
-	return prev_map[slot];
-}
-
-/* Remap an IO device */
-void __init __iomem *
-early_ioremap(resource_size_t phys_addr, unsigned long size)
-{
-	return __early_ioremap(phys_addr, size, PAGE_KERNEL_IO);
-}
-
-/* Remap memory */
-void __init __iomem *
-early_memremap(resource_size_t phys_addr, unsigned long size)
-{
-	return __early_ioremap(phys_addr, size, PAGE_KERNEL);
-}
-
-void __init early_iounmap(void __iomem *addr, unsigned long size)
-{
-	unsigned long virt_addr;
-	unsigned long offset;
-	unsigned int nrpages;
-	enum fixed_addresses idx;
-	int i, slot;
-
-	slot = -1;
-	for (i = 0; i < FIX_BTMAPS_SLOTS; i++) {
-		if (prev_map[i] == addr) {
-			slot = i;
-			break;
-		}
-	}
-
-	if (slot < 0) {
-		printk(KERN_INFO "early_iounmap(%p, %08lx) not found slot\n",
-			 addr, size);
-		WARN_ON(1);
-		return;
-	}
-
-	if (prev_size[slot] != size) {
-		printk(KERN_INFO "early_iounmap(%p, %08lx) [%d] size not consistent %08lx\n",
-			 addr, size, slot, prev_size[slot]);
-		WARN_ON(1);
-		return;
-	}
-
-	if (early_ioremap_debug) {
-		printk(KERN_INFO "early_iounmap(%p, %08lx) [%d]\n", addr,
-		       size, slot);
-		dump_stack();
-	}
-
-	virt_addr = (unsigned long)addr;
-	if (virt_addr < fix_to_virt(FIX_BTMAP_BEGIN)) {
-		WARN_ON(1);
-		return;
-	}
-	offset = virt_addr & ~PAGE_MASK;
-	nrpages = PAGE_ALIGN(offset + size) >> PAGE_SHIFT;
-
-	idx = FIX_BTMAP_BEGIN - NR_FIX_BTMAPS*slot;
-	while (nrpages > 0) {
-		early_clear_fixmap(idx);
-		--idx;
-		--nrpages;
-	}
-	prev_map[slot] = NULL;
-}
diff --git a/arch/x86/mm/pgtable_32.c b/arch/x86/mm/pgtable_32.c
index a69bcb8..4dd8cf6 100644
--- a/arch/x86/mm/pgtable_32.c
+++ b/arch/x86/mm/pgtable_32.c
@@ -127,7 +127,7 @@ static int __init parse_reservetop(char *arg)
 
 	address = memparse(arg, &arg);
 	reserve_top_address(address);
-	fixup_early_ioremap();
+	early_ioremap_init();
 	return 0;
 }
 early_param("reservetop", parse_reservetop);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id D0F1282F65
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:52:58 -0400 (EDT)
Received: by lbcao8 with SMTP id ao8so147614231lbc.3
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:52:58 -0700 (PDT)
Received: from mail-lb0-x22d.google.com (mail-lb0-x22d.google.com. [2a00:1450:4010:c04::22d])
        by mx.google.com with ESMTPS id qi7si11665305lbb.13.2015.10.12.08.52.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 08:52:57 -0700 (PDT)
Received: by lbbk10 with SMTP id k10so35200041lbb.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:52:57 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v7 2/4] arm64: add KASAN support
Date: Mon, 12 Oct 2015 18:52:58 +0300
Message-Id: <1444665180-301-3-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linus Walleij <linus.walleij@linaro.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, linux-mm@kvack.org, kasan-dev <kasan-dev@googlegroups.com>, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, Andrey Konovalov <andreyknvl@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

This patch adds arch specific code for kernel address sanitizer
(see Documentation/kasan.txt).

1/8 of kernel addresses reserved for shadow memory. There was no
big enough hole for this, so virtual addresses for shadow were
stolen from vmalloc area.

At early boot stage the whole shadow region populated with just
one physical page (kasan_zero_page). Later, this page reused
as readonly zero shadow for some memory that KASan currently
don't track (vmalloc).
After mapping the physical memory, pages for shadow memory are
allocated and mapped.

Functions like memset/memmove/memcpy do a lot of memory accesses.
If bad pointer passed to one of these function it is important
to catch this. Compiler's instrumentation cannot do this since
these functions are written in assembly.
KASan replaces memory functions with manually instrumented variants.
Original functions declared as weak symbols so strong definitions
in mm/kasan/kasan.c could replace them. Original functions have aliases
with '__' prefix in name, so we could call non-instrumented variant
if needed.
Some files built without kasan instrumentation (e.g. mm/slub.c).
Original mem* function replaced (via #define) with prefixed variants
to disable memory access checks for such files.

Signed-off-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Tested-by: Linus Walleij <linus.walleij@linaro.org>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/Kconfig               |   1 +
 arch/arm64/Makefile              |   7 ++
 arch/arm64/include/asm/kasan.h   |  36 +++++++++
 arch/arm64/include/asm/pgtable.h |   7 ++
 arch/arm64/include/asm/string.h  |  16 ++++
 arch/arm64/kernel/Makefile       |   2 +
 arch/arm64/kernel/arm64ksyms.c   |   3 +
 arch/arm64/kernel/head.S         |   3 +
 arch/arm64/kernel/image.h        |   6 ++
 arch/arm64/kernel/module.c       |  16 +++-
 arch/arm64/kernel/setup.c        |   4 +
 arch/arm64/lib/memcpy.S          |   3 +
 arch/arm64/lib/memmove.S         |   7 +-
 arch/arm64/lib/memset.S          |   3 +
 arch/arm64/mm/Makefile           |   3 +
 arch/arm64/mm/kasan_init.c       | 165 +++++++++++++++++++++++++++++++++++++++
 drivers/firmware/efi/Makefile    |   8 ++
 scripts/Makefile.kasan           |   4 +-
 18 files changed, 288 insertions(+), 6 deletions(-)
 create mode 100644 arch/arm64/include/asm/kasan.h
 create mode 100644 arch/arm64/mm/kasan_init.c

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 1b35bdb..2782c11 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -48,6 +48,7 @@ config ARM64
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_BITREVERSE
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
diff --git a/arch/arm64/Makefile b/arch/arm64/Makefile
index f9914d7..f41c676 100644
--- a/arch/arm64/Makefile
+++ b/arch/arm64/Makefile
@@ -55,6 +55,13 @@ else
 TEXT_OFFSET := 0x00080000
 endif
 
+# KASAN_SHADOW_OFFSET = VA_START + (1 << (VA_BITS - 3)) - (1 << 61)
+# in 32-bit arithmetic
+KASAN_SHADOW_OFFSET := $(shell printf "0x%08x00000000\n" $$(( \
+			(0xffffffff & (-1 << ($(CONFIG_ARM64_VA_BITS) - 32))) \
+			+ (1 << ($(CONFIG_ARM64_VA_BITS) - 32 - 3)) \
+			- (1 << (64 - 32 - 3)) )) )
+
 export	TEXT_OFFSET GZFLAGS
 
 core-y		+= arch/arm64/kernel/ arch/arm64/mm/
diff --git a/arch/arm64/include/asm/kasan.h b/arch/arm64/include/asm/kasan.h
new file mode 100644
index 0000000..71dfe14
--- /dev/null
+++ b/arch/arm64/include/asm/kasan.h
@@ -0,0 +1,36 @@
+#ifndef __ASM_KASAN_H
+#define __ASM_KASAN_H
+
+#ifndef __ASSEMBLY__
+
+#ifdef CONFIG_KASAN
+
+#include <asm/memory.h>
+
+/*
+ * KASAN_SHADOW_START: beginning of the kernel virtual addresses.
+ * KASAN_SHADOW_END: KASAN_SHADOW_START + 1/8 of kernel virtual addresses.
+ */
+#define KASAN_SHADOW_START      (VA_START)
+#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1UL << (VA_BITS - 3)))
+
+/*
+ * This value is used to map an address to the corresponding shadow
+ * address by the following formula:
+ *     shadow_addr = (address >> 3) + KASAN_SHADOW_OFFSET;
+ *
+ * (1 << 61) shadow addresses - [KASAN_SHADOW_OFFSET,KASAN_SHADOW_END]
+ * cover all 64-bits of virtual addresses. So KASAN_SHADOW_OFFSET
+ * should satisfy the following equation:
+ *      KASAN_SHADOW_OFFSET = KASAN_SHADOW_END - (1ULL << 61)
+ */
+#define KASAN_SHADOW_OFFSET     (KASAN_SHADOW_END - (1ULL << (64 - 3)))
+
+void kasan_init(void);
+
+#else
+static inline void kasan_init(void) { }
+#endif
+
+#endif
+#endif
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 3f481ef..e3b515f 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -41,7 +41,14 @@
  *	fixed mappings and modules
  */
 #define VMEMMAP_SIZE		ALIGN((1UL << (VA_BITS - PAGE_SHIFT)) * sizeof(struct page), PUD_SIZE)
+
+#ifndef CONFIG_KASAN
 #define VMALLOC_START		(VA_START)
+#else
+#include <asm/kasan.h>
+#define VMALLOC_START		(KASAN_SHADOW_END + SZ_64K)
+#endif
+
 #define VMALLOC_END		(PAGE_OFFSET - PUD_SIZE - VMEMMAP_SIZE - SZ_64K)
 
 #define vmemmap			((struct page *)(VMALLOC_END + SZ_64K))
diff --git a/arch/arm64/include/asm/string.h b/arch/arm64/include/asm/string.h
index 64d2d48..2eb714c 100644
--- a/arch/arm64/include/asm/string.h
+++ b/arch/arm64/include/asm/string.h
@@ -36,17 +36,33 @@ extern __kernel_size_t strnlen(const char *, __kernel_size_t);
 
 #define __HAVE_ARCH_MEMCPY
 extern void *memcpy(void *, const void *, __kernel_size_t);
+extern void *__memcpy(void *, const void *, __kernel_size_t);
 
 #define __HAVE_ARCH_MEMMOVE
 extern void *memmove(void *, const void *, __kernel_size_t);
+extern void *__memmove(void *, const void *, __kernel_size_t);
 
 #define __HAVE_ARCH_MEMCHR
 extern void *memchr(const void *, int, __kernel_size_t);
 
 #define __HAVE_ARCH_MEMSET
 extern void *memset(void *, int, __kernel_size_t);
+extern void *__memset(void *, int, __kernel_size_t);
 
 #define __HAVE_ARCH_MEMCMP
 extern int memcmp(const void *, const void *, size_t);
 
+
+#if defined(CONFIG_KASAN) && !defined(__SANITIZE_ADDRESS__)
+
+/*
+ * For files that are not instrumented (e.g. mm/slub.c) we
+ * should use not instrumented version of mem* functions.
+ */
+
+#define memcpy(dst, src, len) __memcpy(dst, src, len)
+#define memmove(dst, src, len) __memmove(dst, src, len)
+#define memset(s, c, n) __memset(s, c, n)
+#endif
+
 #endif
diff --git a/arch/arm64/kernel/Makefile b/arch/arm64/kernel/Makefile
index 7b17f62..1b6bda2 100644
--- a/arch/arm64/kernel/Makefile
+++ b/arch/arm64/kernel/Makefile
@@ -7,6 +7,8 @@ AFLAGS_head.o		:= -DTEXT_OFFSET=$(TEXT_OFFSET)
 CFLAGS_efi-stub.o 	:= -DTEXT_OFFSET=$(TEXT_OFFSET)
 CFLAGS_armv8_deprecated.o := -I$(src)
 
+KASAN_SANITIZE_efi-stub.o	:= n
+
 CFLAGS_REMOVE_ftrace.o = -pg
 CFLAGS_REMOVE_insn.o = -pg
 CFLAGS_REMOVE_return_address.o = -pg
diff --git a/arch/arm64/kernel/arm64ksyms.c b/arch/arm64/kernel/arm64ksyms.c
index a85843d..3b6d8cc 100644
--- a/arch/arm64/kernel/arm64ksyms.c
+++ b/arch/arm64/kernel/arm64ksyms.c
@@ -51,6 +51,9 @@ EXPORT_SYMBOL(strnlen);
 EXPORT_SYMBOL(memset);
 EXPORT_SYMBOL(memcpy);
 EXPORT_SYMBOL(memmove);
+EXPORT_SYMBOL(__memset);
+EXPORT_SYMBOL(__memcpy);
+EXPORT_SYMBOL(__memmove);
 EXPORT_SYMBOL(memchr);
 EXPORT_SYMBOL(memcmp);
 
diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
index 28a81e9..2a8c1d5 100644
--- a/arch/arm64/kernel/head.S
+++ b/arch/arm64/kernel/head.S
@@ -444,6 +444,9 @@ __mmap_switched:
 	str_l	x21, __fdt_pointer, x5		// Save FDT pointer
 	str_l	x24, memstart_addr, x6		// Save PHYS_OFFSET
 	mov	x29, #0
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	b	start_kernel
 ENDPROC(__mmap_switched)
 
diff --git a/arch/arm64/kernel/image.h b/arch/arm64/kernel/image.h
index e083af0..6eb8fee 100644
--- a/arch/arm64/kernel/image.h
+++ b/arch/arm64/kernel/image.h
@@ -80,6 +80,12 @@ __efistub_strcmp		= __pi_strcmp;
 __efistub_strncmp		= __pi_strncmp;
 __efistub___flush_dcache_area	= __pi___flush_dcache_area;
 
+#ifdef CONFIG_KASAN
+__efistub___memcpy		= __pi_memcpy;
+__efistub___memmove		= __pi_memmove;
+__efistub___memset		= __pi_memset;
+#endif
+
 __efistub__text			= _text;
 __efistub__end			= _end;
 __efistub__edata		= _edata;
diff --git a/arch/arm64/kernel/module.c b/arch/arm64/kernel/module.c
index 876eb8d..f4bc779 100644
--- a/arch/arm64/kernel/module.c
+++ b/arch/arm64/kernel/module.c
@@ -21,6 +21,7 @@
 #include <linux/bitops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/kasan.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/moduleloader.h>
@@ -34,9 +35,18 @@
 
 void *module_alloc(unsigned long size)
 {
-	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
-				    GFP_KERNEL, PAGE_KERNEL_EXEC, 0,
-				    NUMA_NO_NODE, __builtin_return_address(0));
+	void *p;
+
+	p = __vmalloc_node_range(size, MODULE_ALIGN, MODULES_VADDR, MODULES_END,
+				GFP_KERNEL, PAGE_KERNEL_EXEC, 0,
+				NUMA_NO_NODE, __builtin_return_address(0));
+
+	if (p && (kasan_module_alloc(p, size) < 0)) {
+		vfree(p);
+		return NULL;
+	}
+
+	return p;
 }
 
 enum aarch64_reloc_op {
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 6bab21f..79df79a 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -54,6 +54,7 @@
 #include <asm/elf.h>
 #include <asm/cpufeature.h>
 #include <asm/cpu_ops.h>
+#include <asm/kasan.h>
 #include <asm/sections.h>
 #include <asm/setup.h>
 #include <asm/smp_plat.h>
@@ -434,6 +435,9 @@ void __init setup_arch(char **cmdline_p)
 
 	paging_init();
 	relocate_initrd();
+
+	kasan_init();
+
 	request_standard_resources();
 
 	early_ioremap_reset();
diff --git a/arch/arm64/lib/memcpy.S b/arch/arm64/lib/memcpy.S
index 36a6a62..6761393 100644
--- a/arch/arm64/lib/memcpy.S
+++ b/arch/arm64/lib/memcpy.S
@@ -68,7 +68,10 @@
 	stp \ptr, \regB, [\regC], \val
 	.endm
 
+	.weak memcpy
+ENTRY(__memcpy)
 ENTRY(memcpy)
 #include "copy_template.S"
 	ret
 ENDPIPROC(memcpy)
+ENDPROC(__memcpy)
diff --git a/arch/arm64/lib/memmove.S b/arch/arm64/lib/memmove.S
index 68e2f20..a5a4459 100644
--- a/arch/arm64/lib/memmove.S
+++ b/arch/arm64/lib/memmove.S
@@ -57,12 +57,14 @@ C_h	.req	x12
 D_l	.req	x13
 D_h	.req	x14
 
+	.weak memmove
+ENTRY(__memmove)
 ENTRY(memmove)
 	cmp	dstin, src
-	b.lo	memcpy
+	b.lo	__memcpy
 	add	tmp1, src, count
 	cmp	dstin, tmp1
-	b.hs	memcpy		/* No overlap.  */
+	b.hs	__memcpy		/* No overlap.  */
 
 	add	dst, dstin, count
 	add	src, src, count
@@ -195,3 +197,4 @@ ENTRY(memmove)
 	b.ne	.Ltail63
 	ret
 ENDPIPROC(memmove)
+ENDPROC(__memmove)
diff --git a/arch/arm64/lib/memset.S b/arch/arm64/lib/memset.S
index 29f405f..f2670a9 100644
--- a/arch/arm64/lib/memset.S
+++ b/arch/arm64/lib/memset.S
@@ -54,6 +54,8 @@ dst		.req	x8
 tmp3w		.req	w9
 tmp3		.req	x9
 
+	.weak memset
+ENTRY(__memset)
 ENTRY(memset)
 	mov	dst, dstin	/* Preserve return value.  */
 	and	A_lw, val, #255
@@ -214,3 +216,4 @@ ENTRY(memset)
 	b.ne	.Ltail_maybe_long
 	ret
 ENDPIPROC(memset)
+ENDPROC(__memset)
diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
index 773d37a..57f57fd 100644
--- a/arch/arm64/mm/Makefile
+++ b/arch/arm64/mm/Makefile
@@ -4,3 +4,6 @@ obj-y				:= dma-mapping.o extable.o fault.o init.o \
 				   context.o proc.o pageattr.o
 obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
 obj-$(CONFIG_ARM64_PTDUMP)	+= dump.o
+
+obj-$(CONFIG_KASAN)		+= kasan_init.o
+KASAN_SANITIZE_kasan_init.o	:= n
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
new file mode 100644
index 0000000..b6a92f5
--- /dev/null
+++ b/arch/arm64/mm/kasan_init.c
@@ -0,0 +1,165 @@
+/*
+ * This file contains kasan initialization code for ARM64.
+ *
+ * Copyright (c) 2015 Samsung Electronics Co., Ltd.
+ * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#define pr_fmt(fmt) "kasan: " fmt
+#include <linux/kasan.h>
+#include <linux/kernel.h>
+#include <linux/memblock.h>
+#include <linux/start_kernel.h>
+
+#include <asm/page.h>
+#include <asm/pgalloc.h>
+#include <asm/pgtable.h>
+#include <asm/tlbflush.h>
+
+static pgd_t tmp_pg_dir[PTRS_PER_PGD] __initdata __aligned(PGD_SIZE);
+
+static void __init kasan_early_pte_populate(pmd_t *pmd, unsigned long addr,
+					unsigned long end)
+{
+	pte_t *pte;
+	unsigned long next;
+
+	if (pmd_none(*pmd))
+		pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
+
+	pte = pte_offset_kernel(pmd, addr);
+	do {
+		next = addr + PAGE_SIZE;
+		set_pte(pte, pfn_pte(virt_to_pfn(kasan_zero_page),
+					PAGE_KERNEL));
+	} while (pte++, addr = next, addr != end && pte_none(*pte));
+}
+
+static void __init kasan_early_pmd_populate(pud_t *pud,
+					unsigned long addr,
+					unsigned long end)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	if (pud_none(*pud))
+		pud_populate(&init_mm, pud, kasan_zero_pmd);
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		kasan_early_pte_populate(pmd, addr, next);
+	} while (pmd++, addr = next, addr != end && pmd_none(*pmd));
+}
+
+static void __init kasan_early_pud_populate(pgd_t *pgd,
+					unsigned long addr,
+					unsigned long end)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	if (pgd_none(*pgd))
+		pgd_populate(&init_mm, pgd, kasan_zero_pud);
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		kasan_early_pmd_populate(pud, addr, next);
+	} while (pud++, addr = next, addr != end && pud_none(*pud));
+}
+
+static void __init kasan_map_early_shadow(void)
+{
+	unsigned long addr = KASAN_SHADOW_START;
+	unsigned long end = KASAN_SHADOW_END;
+	unsigned long next;
+	pgd_t *pgd;
+
+	pgd = pgd_offset_k(addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		kasan_early_pud_populate(pgd, addr, next);
+	} while (pgd++, addr = next, addr != end);
+}
+
+void __init kasan_early_init(void)
+{
+	BUILD_BUG_ON(KASAN_SHADOW_OFFSET != KASAN_SHADOW_END - (1UL << 61));
+	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_START, PGDIR_SIZE));
+	BUILD_BUG_ON(!IS_ALIGNED(KASAN_SHADOW_END, PGDIR_SIZE));
+	kasan_map_early_shadow();
+}
+
+static void __init clear_pgds(unsigned long start,
+			unsigned long end)
+{
+	/*
+	 * Remove references to kasan page tables from
+	 * swapper_pg_dir. pgd_clear() can't be used
+	 * here because it's nop on 2,3-level pagetable setups
+	 */
+	for (; start < end; start += PGDIR_SIZE)
+		set_pgd(pgd_offset_k(start), __pgd(0));
+}
+
+static void __init cpu_set_ttbr1(unsigned long ttbr1)
+{
+	asm(
+	"	msr	ttbr1_el1, %0\n"
+	"	isb"
+	:
+	: "r" (ttbr1));
+}
+
+void __init kasan_init(void)
+{
+	struct memblock_region *reg;
+
+	/*
+	 * We are going to perform proper setup of shadow memory.
+	 * At first we should unmap early shadow (clear_pgds() call bellow).
+	 * However, instrumented code couldn't execute without shadow memory.
+	 * tmp_pg_dir used to keep early shadow mapped until full shadow
+	 * setup will be finished.
+	 */
+	memcpy(tmp_pg_dir, swapper_pg_dir, sizeof(tmp_pg_dir));
+	cpu_set_ttbr1(__pa(tmp_pg_dir));
+	flush_tlb_all();
+
+	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
+
+	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
+			kasan_mem_to_shadow((void *)MODULES_VADDR));
+
+	for_each_memblock(memory, reg) {
+		void *start = (void *)__phys_to_virt(reg->base);
+		void *end = (void *)__phys_to_virt(reg->base + reg->size);
+
+		if (start >= end)
+			break;
+
+		/*
+		 * end + 1 here is intentional. We check several shadow bytes in
+		 * advance to slightly speed up fastpath. In some rare cases
+		 * we could cross boundary of mapped shadow, so we just map
+		 * some more here.
+		 */
+		vmemmap_populate((unsigned long)kasan_mem_to_shadow(start),
+				(unsigned long)kasan_mem_to_shadow(end) + 1,
+				pfn_to_nid(virt_to_pfn(start)));
+	}
+
+	memset(kasan_zero_page, 0, PAGE_SIZE);
+	cpu_set_ttbr1(__pa(swapper_pg_dir));
+	flush_tlb_all();
+
+	/* At this point kasan is fully initialized. Enable error messages */
+	init_task.kasan_depth = 0;
+	pr_info("KernelAddressSanitizer initialized\n");
+}
diff --git a/drivers/firmware/efi/Makefile b/drivers/firmware/efi/Makefile
index 6fd3da9..413fcf2 100644
--- a/drivers/firmware/efi/Makefile
+++ b/drivers/firmware/efi/Makefile
@@ -1,6 +1,14 @@
 #
 # Makefile for linux kernel
 #
+
+#
+# ARM64 maps efi runtime services in userspace addresses
+# which don't have KASAN shadow. So dereference of these addresses
+# in efi_call_virt() will cause crash if this code instrumented.
+#
+KASAN_SANITIZE_runtime-wrappers.o	:= n
+
 obj-$(CONFIG_EFI)			+= efi.o vars.o reboot.o
 obj-$(CONFIG_EFI_VARS)			+= efivars.o
 obj-$(CONFIG_EFI_ESRT)			+= esrt.o
diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 3f874d2..37323b0 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -5,10 +5,12 @@ else
 	call_threshold := 0
 endif
 
+KASAN_SHADOW_OFFSET ?= $(CONFIG_KASAN_SHADOW_OFFSET)
+
 CFLAGS_KASAN_MINIMAL := -fsanitize=kernel-address
 
 CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-address \
-		-fasan-shadow-offset=$(CONFIG_KASAN_SHADOW_OFFSET) \
+		-fasan-shadow-offset=$(KASAN_SHADOW_OFFSET) \
 		--param asan-stack=1 --param asan-globals=1 \
 		--param asan-instrumentation-with-call-threshold=$(call_threshold))
 
-- 
2.4.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

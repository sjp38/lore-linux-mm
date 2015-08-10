Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id AB25A82F5F
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 18:23:09 -0400 (EDT)
Received: by lagz9 with SMTP id z9so61346908lag.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 15:23:09 -0700 (PDT)
Received: from mail-lb0-x242.google.com (mail-lb0-x242.google.com. [2a00:1450:4010:c04::242])
        by mx.google.com with ESMTPS id l7si15308255lbo.54.2015.08.10.15.23.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 15:23:08 -0700 (PDT)
Received: by lbbtg9 with SMTP id tg9so5556763lbb.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 15:23:07 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v5 5/6] arm64: add KASAN support
Date: Tue, 11 Aug 2015 05:18:18 +0300
Message-Id: <1439259499-13913-6-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Marek <mmarek@suse.com>, linux-kbuild@vger.kernel.org

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
---
 arch/arm64/Kconfig               |   1 +
 arch/arm64/Makefile              |   7 ++
 arch/arm64/include/asm/kasan.h   |  36 +++++++++
 arch/arm64/include/asm/pgtable.h |   7 ++
 arch/arm64/include/asm/string.h  |  16 ++++
 arch/arm64/kernel/arm64ksyms.c   |   3 +
 arch/arm64/kernel/head.S         |   3 +
 arch/arm64/kernel/module.c       |  16 +++-
 arch/arm64/kernel/setup.c        |   2 +
 arch/arm64/lib/memcpy.S          |   3 +
 arch/arm64/lib/memmove.S         |   7 +-
 arch/arm64/lib/memset.S          |   3 +
 arch/arm64/mm/Makefile           |   3 +
 arch/arm64/mm/kasan_init.c       | 165 +++++++++++++++++++++++++++++++++++++++
 scripts/Makefile.kasan           |   4 +-
 15 files changed, 270 insertions(+), 6 deletions(-)
 create mode 100644 arch/arm64/include/asm/kasan.h
 create mode 100644 arch/arm64/mm/kasan_init.c

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 318175f..b4a379e 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -46,6 +46,7 @@ config ARM64
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_BITREVERSE
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
diff --git a/arch/arm64/Makefile b/arch/arm64/Makefile
index 4d2a925..4cd8ea7 100644
--- a/arch/arm64/Makefile
+++ b/arch/arm64/Makefile
@@ -40,6 +40,13 @@ else
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
index a1f9f61..a071da4 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -40,7 +40,14 @@
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
index c0ff3ce..945bd6d 100644
--- a/arch/arm64/kernel/head.S
+++ b/arch/arm64/kernel/head.S
@@ -449,6 +449,9 @@ __mmap_switched:
 	str_l	x21, __fdt_pointer, x5		// Save FDT pointer
 	str_l	x24, memstart_addr, x6		// Save PHYS_OFFSET
 	mov	x29, #0
+#ifdef CONFIG_KASAN
+	bl	kasan_early_init
+#endif
 	b	start_kernel
 ENDPROC(__mmap_switched)
 
diff --git a/arch/arm64/kernel/module.c b/arch/arm64/kernel/module.c
index 67bf410..7d90c0f 100644
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
index f3067d4..bf82ab8 100644
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
@@ -392,6 +393,7 @@ void __init setup_arch(char **cmdline_p)
 	acpi_boot_table_init();
 
 	paging_init();
+	kasan_init();
 	request_standard_resources();
 
 	early_ioremap_reset();
diff --git a/arch/arm64/lib/memcpy.S b/arch/arm64/lib/memcpy.S
index 8a9a96d..42cc4b7 100644
--- a/arch/arm64/lib/memcpy.S
+++ b/arch/arm64/lib/memcpy.S
@@ -56,6 +56,8 @@ C_h	.req	x12
 D_l	.req	x13
 D_h	.req	x14
 
+	.weak memcpy
+ENTRY(__memcpy)
 ENTRY(memcpy)
 	mov	dst, dstin
 	cmp	count, #16
@@ -199,3 +201,4 @@ ENTRY(memcpy)
 	b.ne	.Ltail63
 	ret
 ENDPROC(memcpy)
+ENDPROC(__memcpy)
diff --git a/arch/arm64/lib/memmove.S b/arch/arm64/lib/memmove.S
index 57b19ea..8819433 100644
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
 ENDPROC(memmove)
+ENDPROC(__memmove)
diff --git a/arch/arm64/lib/memset.S b/arch/arm64/lib/memset.S
index 7c72dfd..edc0e7d 100644
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
 ENDPROC(memset)
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
index 0000000..3cf1d89
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
+	pr_info("Kernel address sanitizer initialized\n");
+}
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
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

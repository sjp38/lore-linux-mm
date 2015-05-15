Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2B24D6B0074
	for <linux-mm@kvack.org>; Fri, 15 May 2015 09:59:30 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so39521799igb.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 06:59:30 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id ua4si2699143pac.164.2015.05.15.06.59.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 15 May 2015 06:59:25 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOE00F4G9IWRE80@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 15 May 2015 14:59:20 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v2 5/5] arm64: add KASan support
Date: Fri, 15 May 2015 16:59:04 +0300
Message-id: <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

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

KASan's stack instrumentation significantly increases stack's
consumption, so CONFIG_KASAN doubles THREAD_SIZE.

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

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/arm64/Kconfig                   |   7 ++
 arch/arm64/include/asm/kasan.h       |  24 ++++++
 arch/arm64/include/asm/pgtable.h     |   7 ++
 arch/arm64/include/asm/string.h      |  16 ++++
 arch/arm64/include/asm/thread_info.h |   8 ++
 arch/arm64/kernel/head.S             |   3 +
 arch/arm64/kernel/module.c           |  16 +++-
 arch/arm64/kernel/setup.c            |   2 +
 arch/arm64/lib/memcpy.S              |   3 +
 arch/arm64/lib/memmove.S             |   7 +-
 arch/arm64/lib/memset.S              |   3 +
 arch/arm64/mm/Makefile               |   3 +
 arch/arm64/mm/kasan_init.c           | 143 +++++++++++++++++++++++++++++++++++
 13 files changed, 237 insertions(+), 5 deletions(-)
 create mode 100644 arch/arm64/include/asm/kasan.h
 create mode 100644 arch/arm64/mm/kasan_init.c

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 7796af4..4cc73cc 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -44,6 +44,7 @@ config ARM64
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_BITREVERSE
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
@@ -119,6 +120,12 @@ config GENERIC_CSUM
 config GENERIC_CALIBRATE_DELAY
 	def_bool y
 
+config KASAN_SHADOW_OFFSET
+	hex
+	default 0xdfff200000000000 if ARM64_VA_BITS_48
+	default 0xdffffc8000000000 if ARM64_VA_BITS_42
+	default 0xdfffff9000000000 if ARM64_VA_BITS_39
+
 config ZONE_DMA
 	def_bool y
 
diff --git a/arch/arm64/include/asm/kasan.h b/arch/arm64/include/asm/kasan.h
new file mode 100644
index 0000000..65ac50d
--- /dev/null
+++ b/arch/arm64/include/asm/kasan.h
@@ -0,0 +1,24 @@
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
+#define KASAN_SHADOW_START      (UL(0xffffffffffffffff) << (VA_BITS))
+#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1UL << (VA_BITS - 3)))
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
index bd5db28..8700f66 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -40,7 +40,14 @@
  *	fixed mappings and modules
  */
 #define VMEMMAP_SIZE		ALIGN((1UL << (VA_BITS - PAGE_SHIFT)) * sizeof(struct page), PUD_SIZE)
+
+#ifndef CONFIG_KASAN
 #define VMALLOC_START		(UL(0xffffffffffffffff) << VA_BITS)
+#else
+#include <asm/kasan.h>
+#define VMALLOC_START		KASAN_SHADOW_END
+#endif
+
 #define VMALLOC_END		(PAGE_OFFSET - PUD_SIZE - VMEMMAP_SIZE - SZ_64K)
 
 #define vmemmap			((struct page *)(VMALLOC_END + SZ_64K))
diff --git a/arch/arm64/include/asm/string.h b/arch/arm64/include/asm/string.h
index 64d2d48..bff522c 100644
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
+ * For files that not instrumented (e.g. mm/slub.c) we
+ * should use not instrumented version of mem* functions.
+ */
+
+#define memcpy(dst, src, len) __memcpy(dst, src, len)
+#define memmove(dst, src, len) __memmove(dst, src, len)
+#define memset(s, c, n) __memset(s, c, n)
+#endif
+
 #endif
diff --git a/arch/arm64/include/asm/thread_info.h b/arch/arm64/include/asm/thread_info.h
index dcd06d1..cfe5ea5 100644
--- a/arch/arm64/include/asm/thread_info.h
+++ b/arch/arm64/include/asm/thread_info.h
@@ -24,10 +24,18 @@
 #include <linux/compiler.h>
 
 #ifndef CONFIG_ARM64_64K_PAGES
+#ifndef CONFIG_KASAN
 #define THREAD_SIZE_ORDER	2
+#else
+#define THREAD_SIZE_ORDER	3
+#endif
 #endif
 
+#ifndef CONFIG_KASAN
 #define THREAD_SIZE		16384
+#else
+#define THREAD_SIZE		32768
+#endif
 #define THREAD_START_SP		(THREAD_SIZE - 16)
 
 #ifndef __ASSEMBLY__
diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
index 19f915e..650b1e8 100644
--- a/arch/arm64/kernel/head.S
+++ b/arch/arm64/kernel/head.S
@@ -486,6 +486,9 @@ __mmap_switched:
 	str_l	x21, __fdt_pointer, x5		// Save FDT pointer
 	str_l	x24, memstart_addr, x6		// Save PHYS_OFFSET
 	mov	x29, #0
+#ifdef CONFIG_KASAN
+	b	kasan_early_init
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
index 7475313..963b53a 100644
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
@@ -401,6 +402,7 @@ void __init setup_arch(char **cmdline_p)
 	acpi_boot_table_init();
 
 	paging_init();
+	kasan_init();
 	request_standard_resources();
 
 	early_ioremap_reset();
diff --git a/arch/arm64/lib/memcpy.S b/arch/arm64/lib/memcpy.S
index 8a9a96d..845e40a 100644
--- a/arch/arm64/lib/memcpy.S
+++ b/arch/arm64/lib/memcpy.S
@@ -56,6 +56,8 @@ C_h	.req	x12
 D_l	.req	x13
 D_h	.req	x14
 
+.weak memcpy
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
index 57b19ea..48074d2 100644
--- a/arch/arm64/lib/memmove.S
+++ b/arch/arm64/lib/memmove.S
@@ -57,12 +57,14 @@ C_h	.req	x12
 D_l	.req	x13
 D_h	.req	x14
 
+.weak memmove
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
index 7c72dfd..4ab2594 100644
--- a/arch/arm64/lib/memset.S
+++ b/arch/arm64/lib/memset.S
@@ -54,6 +54,8 @@ dst		.req	x8
 tmp3w		.req	w9
 tmp3		.req	x9
 
+.weak memset
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
index 773d37a..e17703c 100644
--- a/arch/arm64/mm/Makefile
+++ b/arch/arm64/mm/Makefile
@@ -4,3 +4,6 @@ obj-y				:= dma-mapping.o extable.o fault.o init.o \
 				   context.o proc.o pageattr.o
 obj-$(CONFIG_HUGETLB_PAGE)	+= hugetlbpage.o
 obj-$(CONFIG_ARM64_PTDUMP)	+= dump.o
+
+KASAN_SANITIZE_kasan_init.o	:= n
+obj-$(CONFIG_KASAN)		+= kasan_init.o
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
new file mode 100644
index 0000000..35dbd84
--- /dev/null
+++ b/arch/arm64/mm/kasan_init.c
@@ -0,0 +1,143 @@
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
+unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
+static pgd_t tmp_page_table[PTRS_PER_PGD] __initdata __aligned(PAGE_SIZE);
+
+#if CONFIG_PGTABLE_LEVELS > 3
+pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
+#endif
+#if CONFIG_PGTABLE_LEVELS > 2
+pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
+#endif
+pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
+
+static void __init kasan_early_pmd_populate(unsigned long start,
+					unsigned long end, pud_t *pud)
+{
+	unsigned long addr;
+	unsigned long next;
+	pmd_t *pmd;
+
+	pmd = pmd_offset(pud, start);
+	for (addr = start; addr < end; addr = next, pmd++) {
+		pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
+		next = pmd_addr_end(addr, end);
+	}
+}
+
+static void __init kasan_early_pud_populate(unsigned long start,
+					unsigned long end, pgd_t *pgd)
+{
+	unsigned long addr;
+	unsigned long next;
+	pud_t *pud;
+
+	pud = pud_offset(pgd, start);
+	for (addr = start; addr < end; addr = next, pud++) {
+		pud_populate(&init_mm, pud, kasan_zero_pmd);
+		next = pud_addr_end(addr, end);
+		kasan_early_pmd_populate(addr, next, pud);
+	}
+}
+
+static void __init kasan_map_early_shadow(pgd_t *pgdp)
+{
+	int i;
+	unsigned long start = KASAN_SHADOW_START;
+	unsigned long end = KASAN_SHADOW_END;
+	unsigned long addr;
+	unsigned long next;
+	pgd_t *pgd;
+
+	for (i = 0; i < PTRS_PER_PTE; i++)
+		set_pte(&kasan_zero_pte[i], pfn_pte(
+				virt_to_pfn(kasan_zero_page), PAGE_KERNEL));
+
+	pgd = pgd_offset_k(start);
+	for (addr = start; addr < end; addr = next, pgd++) {
+		pgd_populate(&init_mm, pgd, kasan_zero_pud);
+		next = pgd_addr_end(addr, end);
+		kasan_early_pud_populate(addr, next, pgd);
+	}
+}
+
+void __init kasan_early_init(void)
+{
+	kasan_map_early_shadow(swapper_pg_dir);
+	start_kernel();
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
+	for (; start && start < end; start += PGDIR_SIZE)
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
+	 * tmp_page_table used to keep early shadow mapped until full shadow
+	 * setup will be finished.
+	 */
+	memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
+	cpu_set_ttbr1(__pa(tmp_page_table));
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
+}
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

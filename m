Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4146B0075
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:49:28 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so227905108pad.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:49:28 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ag9si5744720pad.217.2015.03.24.07.49.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 24 Mar 2015 07:49:25 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NLQ00L5I1D0NQ60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Mar 2015 14:53:24 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH 2/2] arm64: add KASan support
Date: Tue, 24 Mar 2015 17:49:04 +0300
Message-id: <1427208544-8232-3-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com>
References: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <a.ryabinin@samsung.com>

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
 arch/arm64/include/asm/pgtable.h     |   3 +-
 arch/arm64/include/asm/string.h      |  16 +++
 arch/arm64/include/asm/thread_info.h |   8 ++
 arch/arm64/kernel/head.S             |   3 +
 arch/arm64/kernel/module.c           |  16 ++-
 arch/arm64/kernel/setup.c            |   2 +
 arch/arm64/lib/memcpy.S              |   3 +
 arch/arm64/lib/memmove.S             |   7 +-
 arch/arm64/lib/memset.S              |   3 +
 arch/arm64/mm/Makefile               |   3 +
 arch/arm64/mm/kasan_init.c           | 211 +++++++++++++++++++++++++++++++++++
 12 files changed, 276 insertions(+), 6 deletions(-)
 create mode 100644 arch/arm64/mm/kasan_init.c

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 4085df1..10bbd71 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -41,6 +41,7 @@ config ARM64
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_BITREVERSE
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_ARCH_KASAN if SPARSEMEM_VMEMMAP
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
@@ -116,6 +117,12 @@ config GENERIC_CSUM
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
 
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index bd5db28..f5ce010 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -40,7 +40,7 @@
  *	fixed mappings and modules
  */
 #define VMEMMAP_SIZE		ALIGN((1UL << (VA_BITS - PAGE_SHIFT)) * sizeof(struct page), PUD_SIZE)
-#define VMALLOC_START		(UL(0xffffffffffffffff) << VA_BITS)
+#define VMALLOC_START		((UL(0xffffffffffffffff) << VA_BITS) + (UL(1) << (VA_BITS - 3)))
 #define VMALLOC_END		(PAGE_OFFSET - PUD_SIZE - VMEMMAP_SIZE - SZ_64K)
 
 #define vmemmap			((struct page *)(VMALLOC_END + SZ_64K))
@@ -73,6 +73,7 @@ extern void __pgd_error(const char *file, int line, unsigned long val);
 
 #define PAGE_KERNEL		__pgprot(_PAGE_DEFAULT | PTE_PXN | PTE_UXN | PTE_DIRTY | PTE_WRITE)
 #define PAGE_KERNEL_EXEC	__pgprot(_PAGE_DEFAULT | PTE_UXN | PTE_DIRTY | PTE_WRITE)
+#define PAGE_KERNEL_RO		__pgprot(_PAGE_DEFAULT | PTE_PXN | PTE_UXN | PTE_DIRTY)
 
 #define PAGE_HYP		__pgprot(_PAGE_DEFAULT | PTE_HYP)
 #define PAGE_HYP_DEVICE		__pgprot(PROT_DEVICE_nGnRE | PTE_HYP)
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
index 702e1e6..4a2c11e 100644
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
index 51c9811..1a99e95 100644
--- a/arch/arm64/kernel/head.S
+++ b/arch/arm64/kernel/head.S
@@ -482,6 +482,9 @@ __mmap_switched:
 	str_l	x21, __fdt_pointer, x5		// Save FDT pointer
 	str_l	x24, memstart_addr, x6		// Save PHYS_OFFSET
 	mov	x29, #0
+#ifdef CONFIG_KASAN
+	b kasan_early_init
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
index 51ef972..f197f45 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -31,6 +31,7 @@
 #include <linux/screen_info.h>
 #include <linux/init.h>
 #include <linux/kexec.h>
+#include <linux/kasan.h>
 #include <linux/crash_dump.h>
 #include <linux/root_dev.h>
 #include <linux/clk-provider.h>
@@ -396,6 +397,7 @@ void __init setup_arch(char **cmdline_p)
 	arm64_memblock_init();
 
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
index 0000000..df537da
--- /dev/null
+++ b/arch/arm64/mm/kasan_init.c
@@ -0,0 +1,211 @@
+#include <linux/kasan.h>
+#include <linux/kernel.h>
+#include <linux/memblock.h>
+#include <linux/start_kernel.h>
+
+#include <asm/page.h>
+#include <asm/pgtable.h>
+#include <asm/tlbflush.h>
+
+static char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
+static pgd_t tmp_page_table[PTRS_PER_PGD] __initdata __aligned(PAGE_SIZE);
+
+#if CONFIG_PGTABLE_LEVELS > 3
+static pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
+#endif
+#if CONFIG_PGTABLE_LEVELS > 2
+static pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
+#endif
+static pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
+
+static void __init init_kasan_page_tables(void)
+{
+	int i;
+
+#if CONFIG_PGTABLE_LEVELS > 3
+	for (i = 0; i < PTRS_PER_PUD; i++)
+		set_pud(&kasan_zero_pud[i], __pud(__pa(kasan_zero_pmd)
+							| PAGE_KERNEL));
+#endif
+#if CONFIG_PGTABLE_LEVELS > 2
+	for (i = 0; i < PTRS_PER_PMD; i++)
+		set_pmd(&kasan_zero_pmd[i], __pmd(__pa(kasan_zero_pte)
+							| PAGE_KERNEL));
+#endif
+	for (i = 0; i < PTRS_PER_PTE; i++)
+		set_pte(&kasan_zero_pte[i], __pte(__pa(kasan_zero_page)
+							| PAGE_KERNEL));
+}
+
+void __init kasan_map_early_shadow(pgd_t *pgdp)
+{
+	int i;
+	unsigned long start = KASAN_SHADOW_START;
+	unsigned long end = KASAN_SHADOW_END;
+	pgd_t pgd;
+
+#if CONFIG_PGTABLE_LEVELS > 3
+	pgd = __pgd(__pa(kasan_zero_pud) | PAGE_KERNEL);
+#elif CONFIG_PGTABLE_LEVELS > 2
+	pgd = __pgd(__pa(kasan_zero_pmd) | PAGE_KERNEL);
+#else
+	pgd = __pgd(__pa(kasan_zero_pte) | PAGE_KERNEL);
+#endif
+
+	for (i = pgd_index(start); start < end; i++) {
+		set_pgd(&pgdp[i], pgd);
+		start += PGDIR_SIZE;
+	}
+}
+
+void __init kasan_early_init(void)
+{
+	init_kasan_page_tables();
+	kasan_map_early_shadow(swapper_pg_dir);
+	kasan_map_early_shadow(idmap_pg_dir);
+	flush_tlb_all();
+	start_kernel();
+}
+
+static void __init clear_pgds(unsigned long start,
+			unsigned long end)
+{
+	for (; start && start < end; start += PGDIR_SIZE)
+		set_pgd(pgd_offset_k(start), __pgd(0));
+}
+
+static int __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
+				unsigned long end)
+{
+	pte_t *pte = pte_offset_kernel(pmd, addr);
+
+	while (addr + PAGE_SIZE <= end) {
+		set_pte(pte, __pte(__pa(kasan_zero_page)
+					| PAGE_KERNEL_RO));
+		addr += PAGE_SIZE;
+		pte = pte_offset_kernel(pmd, addr);
+	}
+	return 0;
+}
+
+static int __init zero_pmd_populate(pud_t *pud, unsigned long addr,
+				unsigned long end)
+{
+	int ret = 0;
+	pmd_t *pmd = pmd_offset(pud, addr);
+
+	while (IS_ALIGNED(addr, PMD_SIZE) && addr + PMD_SIZE <= end) {
+		set_pmd(pmd, __pmd(__pa(kasan_zero_pte)
+					| PAGE_KERNEL_RO));
+		addr += PMD_SIZE;
+		pmd++;
+	}
+
+	if (addr < end) {
+		if (pmd_none(*pmd)) {
+			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
+			if (!p)
+				return -ENOMEM;
+			set_pmd(pmd, __pmd(__pa(p) | PAGE_KERNEL));
+		}
+		ret = zero_pte_populate(pmd, addr, end);
+	}
+	return ret;
+}
+
+static int __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
+				unsigned long end)
+{
+	int ret = 0;
+	pud_t *pud = pud_offset(pgd, addr);
+
+#if CONFIG_PGTABLE_LEVELS > 2
+	while (IS_ALIGNED(addr, PUD_SIZE) && addr + PUD_SIZE <= end) {
+		set_pud(pud, __pud(__pa(kasan_zero_pmd)
+					| PAGE_KERNEL_RO));
+		addr += PUD_SIZE;
+		pud++;
+	}
+#endif
+
+	if (addr < end) {
+		if (pud_none(*pud)) {
+			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
+			if (!p)
+				return -ENOMEM;
+			set_pud(pud, __pud(__pa(p) | PAGE_KERNEL));
+		}
+		ret = zero_pmd_populate(pud, addr, end);
+	}
+	return ret;
+}
+
+static int __init zero_pgd_populate(unsigned long addr, unsigned long end)
+{
+	int ret = 0;
+	pgd_t *pgd = pgd_offset_k(addr);
+
+#if CONFIG_PGTABLE_LEVELS > 3
+	 while (IS_ALIGNED(addr, PGDIR_SIZE) && addr + PGDIR_SIZE <= end) {
+		set_pgd(pgd, __pgd(__pa(kasan_zero_pud)
+					| PAGE_KERNEL_RO));
+		addr += PGDIR_SIZE;
+		pgd++;
+	}
+#endif
+
+	 if (addr < end) {
+		 if (pgd_none(*pgd)) {
+			 void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
+			 if (!p)
+				 return -ENOMEM;
+			 set_pgd(pgd, __pgd(__pa(p) | PAGE_KERNEL));
+		 }
+		 ret = zero_pud_populate(pgd, addr, end);
+	 }
+	 return ret;
+}
+
+static void __init populate_zero_shadow(unsigned long start, unsigned long end)
+{
+	if (zero_pgd_populate(start, end))
+		panic("kasan: unable to map zero shadow!");
+}
+
+static void cpu_set_ttbr1(unsigned long ttbr1)
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
+	memcpy(tmp_page_table, swapper_pg_dir, sizeof(tmp_page_table));
+	cpu_set_ttbr1(__pa(tmp_page_table));
+
+	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
+
+	populate_zero_shadow(KASAN_SHADOW_START,
+			(unsigned long)kasan_mem_to_shadow((void *)MODULES_VADDR));
+
+	for_each_memblock(memory, reg) {
+		void *start = (void *)__phys_to_virt(reg->base);
+		void *end = (void *)__phys_to_virt(reg->base + reg->size);
+
+		if (start >= end)
+			break;
+
+		vmemmap_populate((unsigned long)kasan_mem_to_shadow(start),
+				(unsigned long)kasan_mem_to_shadow(end),
+				pfn_to_nid(virt_to_pfn(start)));
+	}
+
+	memset(kasan_zero_page, 0, PAGE_SIZE);
+	cpu_set_ttbr1(__pa(swapper_pg_dir));
+	init_task.kasan_depth = 0;
+}
-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

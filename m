Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id E649382F5F
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 18:23:01 -0400 (EDT)
Received: by lagz9 with SMTP id z9so61345582lag.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 15:23:01 -0700 (PDT)
Received: from mail-la0-x243.google.com (mail-la0-x243.google.com. [2a00:1450:4010:c03::243])
        by mx.google.com with ESMTPS id g10si15237002laf.177.2015.08.10.15.22.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 15:22:59 -0700 (PDT)
Received: by labia3 with SMTP id ia3so5621488lab.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 15:22:59 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v5 2/6] x86/kasan, mm: introduce generic kasan_populate_zero_shadow()
Date: Tue, 11 Aug 2015 05:18:15 +0300
Message-Id: <1439259499-13913-3-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

Introduce generic kasan_populate_zero_shadow(shadow_start, shadow_end).
This function maps kasan_zero_page to the [shadow_start, shadow_end]
addresses.

This replaces x86_64 specific populate_zero_shadow() and will
be used for ARM64 in follow on patches.

Signed-off-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
---
 arch/x86/mm/kasan_init_64.c | 123 ++---------------------------------
 include/linux/kasan.h       |   9 +++
 mm/kasan/Makefile           |   2 +-
 mm/kasan/kasan_init.c       | 152 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 167 insertions(+), 119 deletions(-)
 create mode 100644 mm/kasan/kasan_init.c

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index e1840f3..9ce5da2 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -12,20 +12,6 @@
 extern pgd_t early_level4_pgt[PTRS_PER_PGD];
 extern struct range pfn_mapped[E820_X_MAX];
 
-static pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
-static pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
-static pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
-
-/*
- * This page used as early shadow. We don't use empty_zero_page
- * at early stages, stack instrumentation could write some garbage
- * to this page.
- * Latter we reuse it as zero shadow for large ranges of memory
- * that allowed to access, but not instrumented by kasan
- * (vmalloc/vmemmap ...).
- */
-static unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
-
 static int __init map_range(struct range *range)
 {
 	unsigned long start;
@@ -62,106 +48,6 @@ static void __init kasan_map_early_shadow(pgd_t *pgd)
 	}
 }
 
-static int __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
-				unsigned long end)
-{
-	pte_t *pte = pte_offset_kernel(pmd, addr);
-
-	while (addr + PAGE_SIZE <= end) {
-		WARN_ON(!pte_none(*pte));
-		set_pte(pte, __pte(__pa_nodebug(kasan_zero_page)
-					| __PAGE_KERNEL_RO));
-		addr += PAGE_SIZE;
-		pte = pte_offset_kernel(pmd, addr);
-	}
-	return 0;
-}
-
-static int __init zero_pmd_populate(pud_t *pud, unsigned long addr,
-				unsigned long end)
-{
-	int ret = 0;
-	pmd_t *pmd = pmd_offset(pud, addr);
-
-	while (IS_ALIGNED(addr, PMD_SIZE) && addr + PMD_SIZE <= end) {
-		WARN_ON(!pmd_none(*pmd));
-		set_pmd(pmd, __pmd(__pa_nodebug(kasan_zero_pte)
-					| _KERNPG_TABLE));
-		addr += PMD_SIZE;
-		pmd = pmd_offset(pud, addr);
-	}
-	if (addr < end) {
-		if (pmd_none(*pmd)) {
-			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
-			if (!p)
-				return -ENOMEM;
-			set_pmd(pmd, __pmd(__pa_nodebug(p) | _KERNPG_TABLE));
-		}
-		ret = zero_pte_populate(pmd, addr, end);
-	}
-	return ret;
-}
-
-
-static int __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
-				unsigned long end)
-{
-	int ret = 0;
-	pud_t *pud = pud_offset(pgd, addr);
-
-	while (IS_ALIGNED(addr, PUD_SIZE) && addr + PUD_SIZE <= end) {
-		WARN_ON(!pud_none(*pud));
-		set_pud(pud, __pud(__pa_nodebug(kasan_zero_pmd)
-					| _KERNPG_TABLE));
-		addr += PUD_SIZE;
-		pud = pud_offset(pgd, addr);
-	}
-
-	if (addr < end) {
-		if (pud_none(*pud)) {
-			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
-			if (!p)
-				return -ENOMEM;
-			set_pud(pud, __pud(__pa_nodebug(p) | _KERNPG_TABLE));
-		}
-		ret = zero_pmd_populate(pud, addr, end);
-	}
-	return ret;
-}
-
-static int __init zero_pgd_populate(unsigned long addr, unsigned long end)
-{
-	int ret = 0;
-	pgd_t *pgd = pgd_offset_k(addr);
-
-	while (IS_ALIGNED(addr, PGDIR_SIZE) && addr + PGDIR_SIZE <= end) {
-		WARN_ON(!pgd_none(*pgd));
-		set_pgd(pgd, __pgd(__pa_nodebug(kasan_zero_pud)
-					| _KERNPG_TABLE));
-		addr += PGDIR_SIZE;
-		pgd = pgd_offset_k(addr);
-	}
-
-	if (addr < end) {
-		if (pgd_none(*pgd)) {
-			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
-			if (!p)
-				return -ENOMEM;
-			set_pgd(pgd, __pgd(__pa_nodebug(p) | _KERNPG_TABLE));
-		}
-		ret = zero_pud_populate(pgd, addr, end);
-	}
-	return ret;
-}
-
-
-static void __init populate_zero_shadow(const void *start, const void *end)
-{
-	if (zero_pgd_populate((unsigned long)start, (unsigned long)end))
-		panic("kasan: unable to map zero shadow!");
-}
-
-
 #ifdef CONFIG_KASAN_INLINE
 static int kasan_die_handler(struct notifier_block *self,
 			     unsigned long val,
@@ -213,7 +99,7 @@ void __init kasan_init(void)
 
 	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
 
-	populate_zero_shadow((void *)KASAN_SHADOW_START,
+	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
 			kasan_mem_to_shadow((void *)PAGE_OFFSET));
 
 	for (i = 0; i < E820_X_MAX; i++) {
@@ -223,14 +109,15 @@ void __init kasan_init(void)
 		if (map_range(&pfn_mapped[i]))
 			panic("kasan: unable to allocate shadow!");
 	}
-	populate_zero_shadow(kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
-			kasan_mem_to_shadow((void *)__START_KERNEL_map));
+	kasan_populate_zero_shadow(
+		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
+		kasan_mem_to_shadow((void *)__START_KERNEL_map));
 
 	vmemmap_populate((unsigned long)kasan_mem_to_shadow(_stext),
 			(unsigned long)kasan_mem_to_shadow(_end),
 			NUMA_NO_NODE);
 
-	populate_zero_shadow(kasan_mem_to_shadow((void *)MODULES_END),
+	kasan_populate_zero_shadow(kasan_mem_to_shadow((void *)MODULES_END),
 			(void *)KASAN_SHADOW_END);
 
 	memset(kasan_zero_page, 0, PAGE_SIZE);
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 6fb1c7d..4b9f85c 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -12,8 +12,17 @@ struct vm_struct;
 #define KASAN_SHADOW_SCALE_SHIFT 3
 
 #include <asm/kasan.h>
+#include <asm/pgtable.h>
 #include <linux/sched.h>
 
+extern unsigned char kasan_zero_page[PAGE_SIZE];
+extern pte_t kasan_zero_pte[PTRS_PER_PTE];
+extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
+extern pud_t kasan_zero_pud[PTRS_PER_PUD];
+
+void kasan_populate_zero_shadow(const void *shadow_start,
+				const void *shadow_end);
+
 static inline void *kasan_mem_to_shadow(const void *addr)
 {
 	return (void *)((unsigned long)addr >> KASAN_SHADOW_SCALE_SHIFT)
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index bd837b8..6471014 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -5,4 +5,4 @@ CFLAGS_REMOVE_kasan.o = -pg
 # see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533
 CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
-obj-y := kasan.o report.o
+obj-y := kasan.o report.o kasan_init.o
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
new file mode 100644
index 0000000..3f9a41c
--- /dev/null
+++ b/mm/kasan/kasan_init.c
@@ -0,0 +1,152 @@
+/*
+ * This file contains some kasan initialization code.
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
+#include <linux/bootmem.h>
+#include <linux/init.h>
+#include <linux/kasan.h>
+#include <linux/kernel.h>
+#include <linux/memblock.h>
+#include <linux/pfn.h>
+
+#include <asm/page.h>
+#include <asm/pgalloc.h>
+
+/*
+ * This page serves two purposes:
+ *   - It used as early shadow memory. The entire shadow region populated
+ *     with this page, before we will be able to setup normal shadow memory.
+ *   - Latter it reused it as zero shadow to cover large ranges of memory
+ *     that allowed to access, but not handled by kasan (vmalloc/vmemmap ...).
+ */
+unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
+
+#if CONFIG_PGTABLE_LEVELS > 3
+pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
+#endif
+#if CONFIG_PGTABLE_LEVELS > 2
+pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
+#endif
+pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
+
+static __init void *early_alloc(size_t size, int node)
+{
+	return memblock_virt_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
+					BOOTMEM_ALLOC_ACCESSIBLE, node);
+}
+
+static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
+				unsigned long end)
+{
+	pte_t *pte = pte_offset_kernel(pmd, addr);
+	pte_t zero_pte;
+
+	zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
+	zero_pte = pte_wrprotect(zero_pte);
+
+	while (addr + PAGE_SIZE <= end) {
+		set_pte_at(&init_mm, addr, pte, zero_pte);
+		addr += PAGE_SIZE;
+		pte = pte_offset_kernel(pmd, addr);
+	}
+}
+
+static void __init zero_pmd_populate(pud_t *pud, unsigned long addr,
+				unsigned long end)
+{
+	pmd_t *pmd = pmd_offset(pud, addr);
+	unsigned long next;
+
+	do {
+		next = pmd_addr_end(addr, end);
+
+		if (IS_ALIGNED(addr, PMD_SIZE) && end - addr >= PMD_SIZE) {
+			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
+			continue;
+		}
+
+		if (pmd_none(*pmd)) {
+			pmd_populate_kernel(&init_mm, pmd,
+					early_alloc(PAGE_SIZE, NUMA_NO_NODE));
+		}
+		zero_pte_populate(pmd, addr, next);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static void __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
+				unsigned long end)
+{
+	pud_t *pud = pud_offset(pgd, addr);
+	unsigned long next;
+
+	do {
+		next = pud_addr_end(addr, end);
+		if (IS_ALIGNED(addr, PUD_SIZE) && end - addr >= PUD_SIZE) {
+			pmd_t *pmd;
+
+			pud_populate(&init_mm, pud, kasan_zero_pmd);
+			pmd = pmd_offset(pud, addr);
+			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
+			continue;
+		}
+
+		if (pud_none(*pud)) {
+			pud_populate(&init_mm, pud,
+				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
+		}
+		zero_pmd_populate(pud, addr, next);
+	} while (pud++, addr = next, addr != end);
+}
+
+/**
+ * kasan_populate_zero_shadow - populate shadow memory region with
+ *                               kasan_zero_page
+ * @shadow_start - start of the memory range to populate
+ * @shadow_end   - end of the memory range to populate
+ */
+void __init kasan_populate_zero_shadow(const void *shadow_start,
+				const void *shadow_end)
+{
+	unsigned long addr = (unsigned long)shadow_start;
+	unsigned long end = (unsigned long)shadow_end;
+	pgd_t *pgd = pgd_offset_k(addr);
+	unsigned long next;
+
+	do {
+		next = pgd_addr_end(addr, end);
+
+		if (IS_ALIGNED(addr, PGDIR_SIZE) && end - addr >= PGDIR_SIZE) {
+			pud_t *pud;
+			pmd_t *pmd;
+
+			/*
+			 * kasan_zero_pud should be populated with pmds
+			 * at this moment.
+			 * [pud,pmd]_populate*() below needed only for
+			 * 3,2 - level page tables where we don't have
+			 * puds,pmds, so pgd_populate(), pud_populate()
+			 * is noops.
+			 */
+			pgd_populate(&init_mm, pgd, kasan_zero_pud);
+			pud = pud_offset(pgd, addr);
+			pud_populate(&init_mm, pud, kasan_zero_pmd);
+			pmd = pmd_offset(pud, addr);
+			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
+			continue;
+		}
+
+		if (pgd_none(*pgd)) {
+			pgd_populate(&init_mm, pgd,
+				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
+		}
+		zero_pud_populate(pgd, addr, next);
+	} while (pgd++, addr = next, addr != end);
+}
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

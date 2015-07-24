Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 097E36B0256
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:42:35 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so16103251pdr.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 09:42:34 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id be10si21537990pad.11.2015.07.24.09.42.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 09:42:33 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NS0000843QSY260@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Jul 2015 17:42:29 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v4 2/7] mm: kasan: introduce generic
 kasan_populate_zero_shadow()
Date: Fri, 24 Jul 2015 19:41:54 +0300
Message-id: <1437756119-12817-3-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

Introduce generic kasan_populate_zero_shadow(start, end).
This function maps kasan_zero_page to the [start, end] addresses.

In follow on patches it will be used for ARMv8 (and maybe other
architectures) and will replace x86_64 specific populate_zero_shadow().

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/mm/kasan_init_64.c |  14 ----
 include/linux/kasan.h       |   8 +++
 mm/kasan/Makefile           |   2 +-
 mm/kasan/kasan_init.c       | 151 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 160 insertions(+), 15 deletions(-)
 create mode 100644 mm/kasan/kasan_init.c

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index e1840f3..812086c 100644
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
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 6fb1c7d..d795f53 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -12,8 +12,16 @@ struct vm_struct;
 #define KASAN_SHADOW_SCALE_SHIFT 3
 
 #include <asm/kasan.h>
+#include <asm/pgtable.h>
 #include <linux/sched.h>
 
+extern unsigned char kasan_zero_page[PAGE_SIZE];
+extern pte_t kasan_zero_pte[PTRS_PER_PTE];
+extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
+extern pud_t kasan_zero_pud[PTRS_PER_PUD];
+
+void kasan_populate_zero_shadow(const void *from, const void *to);
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
index 0000000..e276853
--- /dev/null
+++ b/mm/kasan/kasan_init.c
@@ -0,0 +1,151 @@
+/*
+ * This file contains some kasan initialization code.
+ *
+ * Copyright (c) 2015 Samsung Electronics Co., Ltd.
+ * Author: Andrey Ryabinin
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
+ * @from - start of the memory range to populate
+ * @to   - end of the memory range to populate
+ */
+void __init kasan_populate_zero_shadow(const void *from, const void *to)
+{
+	unsigned long addr = (unsigned long)from;
+	unsigned long end = (unsigned long)to;
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
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

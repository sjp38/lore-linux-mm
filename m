Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4057E6B02F3
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:17:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a66so114838875pfl.6
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:51 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id t21si12371758pfl.183.2017.05.15.18.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:17:50 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id h64so14448130pge.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:50 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v1 04/11] mm/kasan: extend kasan_populate_zero_shadow()
Date: Tue, 16 May 2017 10:16:42 +0900
Message-Id: <1494897409-14408-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

In the following patch, per-page shadow memory will be introduced and
some ranges are checked by per-page shadow and the others are checked by
original shadow. To notify the range type, per-page shadow will be mapped
by the page that is filled by a special shadow value,
KASAN_PER_PAGE_BYPASS. Using the actual page for this purpose causes
memory consumption so this patch introduces the black shadow page which
is conceptually similar to the zero shadow page. And, this patch also
extend kasan_populate_zero_shadow() to handle/map the black shadow page.

In addition, this patch adds 'private' argument to this function to force
populate intermediate level page table. It will also used by
the following patch to reduce memory consumption.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 arch/arm64/mm/kasan_init.c  |  17 +++---
 arch/x86/mm/kasan_init_64.c |  15 +++---
 include/linux/kasan.h       |  11 +++-
 mm/kasan/kasan_init.c       | 123 ++++++++++++++++++++++++++++++--------------
 4 files changed, 112 insertions(+), 54 deletions(-)

diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 687a358..f60b74d 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -168,21 +168,24 @@ void __init kasan_init(void)
 	 * vmemmap_populate() has populated the shadow region that covers the
 	 * kernel image with SWAPPER_BLOCK_SIZE mappings, so we have to round
 	 * the start and end addresses to SWAPPER_BLOCK_SIZE as well, to prevent
-	 * kasan_populate_zero_shadow() from replacing the page table entries
+	 * kasan_populate_shadow() from replacing the page table entries
 	 * (PMD or PTE) at the edges of the shadow region for the kernel
 	 * image.
 	 */
 	kimg_shadow_start = round_down(kimg_shadow_start, SWAPPER_BLOCK_SIZE);
 	kimg_shadow_end = round_up(kimg_shadow_end, SWAPPER_BLOCK_SIZE);
 
-	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
-				   (void *)mod_shadow_start);
-	kasan_populate_zero_shadow((void *)kimg_shadow_end,
-				   kasan_mem_to_shadow((void *)PAGE_OFFSET));
+	kasan_populate_shadow((void *)KASAN_SHADOW_START,
+				   (void *)mod_shadow_start,
+				   true, false);
+	kasan_populate_shadow((void *)kimg_shadow_end,
+				   kasan_mem_to_shadow((void *)PAGE_OFFSET),
+				   true, false);
 
 	if (kimg_shadow_start > mod_shadow_end)
-		kasan_populate_zero_shadow((void *)mod_shadow_end,
-					   (void *)kimg_shadow_start);
+		kasan_populate_shadow((void *)mod_shadow_end,
+					   (void *)kimg_shadow_start,
+					   true, false);
 
 	for_each_memblock(memory, reg) {
 		void *start = (void *)__phys_to_virt(reg->base);
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 0c7d812..adc673b 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -127,8 +127,9 @@ void __init kasan_init(void)
 
 	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
 
-	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
-			kasan_mem_to_shadow((void *)PAGE_OFFSET));
+	kasan_populate_shadow((void *)KASAN_SHADOW_START,
+			kasan_mem_to_shadow((void *)PAGE_OFFSET),
+			true, false);
 
 	for (i = 0; i < E820_MAX_ENTRIES; i++) {
 		if (pfn_mapped[i].end == 0)
@@ -137,16 +138,18 @@ void __init kasan_init(void)
 		if (map_range(&pfn_mapped[i]))
 			panic("kasan: unable to allocate shadow!");
 	}
-	kasan_populate_zero_shadow(
+	kasan_populate_shadow(
 		kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
-		kasan_mem_to_shadow((void *)__START_KERNEL_map));
+		kasan_mem_to_shadow((void *)__START_KERNEL_map),
+		true, false);
 
 	vmemmap_populate((unsigned long)kasan_mem_to_shadow(_stext),
 			(unsigned long)kasan_mem_to_shadow(_end),
 			NUMA_NO_NODE);
 
-	kasan_populate_zero_shadow(kasan_mem_to_shadow((void *)MODULES_END),
-			(void *)KASAN_SHADOW_END);
+	kasan_populate_shadow(kasan_mem_to_shadow((void *)MODULES_END),
+			(void *)KASAN_SHADOW_END,
+			true, false);
 
 	load_cr3(init_level4_pgt);
 	__flush_tlb_all();
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index a5c7046..7e501b3 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -21,8 +21,15 @@ extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
 extern pud_t kasan_zero_pud[PTRS_PER_PUD];
 extern p4d_t kasan_zero_p4d[PTRS_PER_P4D];
 
-void kasan_populate_zero_shadow(const void *shadow_start,
-				const void *shadow_end);
+extern unsigned char kasan_black_page[PAGE_SIZE];
+extern pte_t kasan_black_pte[PTRS_PER_PTE];
+extern pmd_t kasan_black_pmd[PTRS_PER_PMD];
+extern pud_t kasan_black_pud[PTRS_PER_PUD];
+extern p4d_t kasan_black_p4d[PTRS_PER_P4D];
+
+void kasan_populate_shadow(const void *shadow_start,
+				const void *shadow_end,
+				bool zero, bool private);
 
 static inline void *kasan_mem_to_shadow(const void *addr)
 {
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 48559d9..cd0a551 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -21,6 +21,8 @@
 #include <asm/page.h>
 #include <asm/pgalloc.h>
 
+#include "kasan.h"
+
 /*
  * This page serves two purposes:
  *   - It used as early shadow memory. The entire shadow region populated
@@ -30,16 +32,26 @@
  */
 unsigned char kasan_zero_page[PAGE_SIZE] __page_aligned_bss;
 
+/*
+ * The shadow memory range that this page is mapped will be considered
+ * to be checked later by another shadow memory.
+ */
+unsigned char kasan_black_page[PAGE_SIZE] __page_aligned_bss;
+
 #if CONFIG_PGTABLE_LEVELS > 4
 p4d_t kasan_zero_p4d[PTRS_PER_P4D] __page_aligned_bss;
+p4d_t kasan_black_p4d[PTRS_PER_P4D] __page_aligned_bss;
 #endif
 #if CONFIG_PGTABLE_LEVELS > 3
 pud_t kasan_zero_pud[PTRS_PER_PUD] __page_aligned_bss;
+pud_t kasan_black_pud[PTRS_PER_PUD] __page_aligned_bss;
 #endif
 #if CONFIG_PGTABLE_LEVELS > 2
 pmd_t kasan_zero_pmd[PTRS_PER_PMD] __page_aligned_bss;
+pmd_t kasan_black_pmd[PTRS_PER_PMD] __page_aligned_bss;
 #endif
 pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
+pte_t kasan_black_pte[PTRS_PER_PTE] __page_aligned_bss;
 
 static __init void *early_alloc(size_t size, int node)
 {
@@ -47,32 +59,38 @@ static __init void *early_alloc(size_t size, int node)
 					BOOTMEM_ALLOC_ACCESSIBLE, node);
 }
 
-static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
-				unsigned long end)
+static void __init kasan_pte_populate(pmd_t *pmd, unsigned long addr,
+				unsigned long end, bool zero)
 {
-	pte_t *pte = pte_offset_kernel(pmd, addr);
-	pte_t zero_pte;
+	pte_t *ptep = pte_offset_kernel(pmd, addr);
+	pte_t pte;
+	unsigned char *page;
 
-	zero_pte = pfn_pte(PFN_DOWN(__pa_symbol(kasan_zero_page)), PAGE_KERNEL);
-	zero_pte = pte_wrprotect(zero_pte);
+	pte = pfn_pte(PFN_DOWN(zero ?
+		__pa_symbol(kasan_zero_page) : __pa_symbol(kasan_black_page)),
+		PAGE_KERNEL);
+	pte = pte_wrprotect(pte);
 
 	while (addr + PAGE_SIZE <= end) {
-		set_pte_at(&init_mm, addr, pte, zero_pte);
+		set_pte_at(&init_mm, addr, ptep, pte);
 		addr += PAGE_SIZE;
-		pte = pte_offset_kernel(pmd, addr);
+		ptep = pte_offset_kernel(pmd, addr);
 	}
 
 	if (addr == end)
 		return;
 
 	/* Population for unaligned end address */
-	zero_pte = pfn_pte(PFN_DOWN(
-		__pa(early_alloc(PAGE_SIZE, NUMA_NO_NODE))), PAGE_KERNEL);
-	set_pte_at(&init_mm, addr, pte, zero_pte);
+	page = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
+	if (!zero)
+		__memcpy(page, kasan_black_page, end - addr);
+
+	pte = pfn_pte(PFN_DOWN(__pa(page)), PAGE_KERNEL);
+	set_pte_at(&init_mm, addr, ptep, pte);
 }
 
-static void __init zero_pmd_populate(pud_t *pud, unsigned long addr,
-				unsigned long end)
+static void __init kasan_pmd_populate(pud_t *pud, unsigned long addr,
+				unsigned long end, bool zero, bool private)
 {
 	pmd_t *pmd = pmd_offset(pud, addr);
 	unsigned long next;
@@ -80,8 +98,11 @@ static void __init zero_pmd_populate(pud_t *pud, unsigned long addr,
 	do {
 		next = pmd_addr_end(addr, end);
 
-		if (IS_ALIGNED(addr, PMD_SIZE) && end - addr >= PMD_SIZE) {
-			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
+		if (IS_ALIGNED(addr, PMD_SIZE) && end - addr >= PMD_SIZE &&
+			!private) {
+			pmd_populate_kernel(&init_mm, pmd,
+				zero ? lm_alias(kasan_zero_pte) :
+					lm_alias(kasan_black_pte));
 			continue;
 		}
 
@@ -89,24 +110,30 @@ static void __init zero_pmd_populate(pud_t *pud, unsigned long addr,
 			pmd_populate_kernel(&init_mm, pmd,
 					early_alloc(PAGE_SIZE, NUMA_NO_NODE));
 		}
-		zero_pte_populate(pmd, addr, next);
+
+		kasan_pte_populate(pmd, addr, next, zero);
 	} while (pmd++, addr = next, addr != end);
 }
 
-static void __init zero_pud_populate(p4d_t *p4d, unsigned long addr,
-				unsigned long end)
+static void __init kasan_pud_populate(p4d_t *p4d, unsigned long addr,
+				unsigned long end, bool zero, bool private)
 {
 	pud_t *pud = pud_offset(p4d, addr);
 	unsigned long next;
 
 	do {
 		next = pud_addr_end(addr, end);
-		if (IS_ALIGNED(addr, PUD_SIZE) && end - addr >= PUD_SIZE) {
+		if (IS_ALIGNED(addr, PUD_SIZE) && end - addr >= PUD_SIZE &&
+			!private) {
 			pmd_t *pmd;
 
-			pud_populate(&init_mm, pud, lm_alias(kasan_zero_pmd));
+			pud_populate(&init_mm, pud,
+				zero ? lm_alias(kasan_zero_pmd) :
+					lm_alias(kasan_black_pmd));
 			pmd = pmd_offset(pud, addr);
-			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
+			pmd_populate_kernel(&init_mm, pmd,
+				zero ? lm_alias(kasan_zero_pte) :
+					lm_alias(kasan_black_pte));
 			continue;
 		}
 
@@ -114,28 +141,34 @@ static void __init zero_pud_populate(p4d_t *p4d, unsigned long addr,
 			pud_populate(&init_mm, pud,
 				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
 		}
-		zero_pmd_populate(pud, addr, next);
+		kasan_pmd_populate(pud, addr, next, zero, private);
 	} while (pud++, addr = next, addr != end);
 }
 
-static void __init zero_p4d_populate(pgd_t *pgd, unsigned long addr,
-				unsigned long end)
+static void __init kasan_p4d_populate(pgd_t *pgd, unsigned long addr,
+				unsigned long end, bool zero, bool private)
 {
 	p4d_t *p4d = p4d_offset(pgd, addr);
 	unsigned long next;
 
 	do {
 		next = p4d_addr_end(addr, end);
-		if (IS_ALIGNED(addr, P4D_SIZE) && end - addr >= P4D_SIZE) {
+		if (IS_ALIGNED(addr, P4D_SIZE) && end - addr >= P4D_SIZE &&
+			!private) {
 			pud_t *pud;
 			pmd_t *pmd;
 
-			p4d_populate(&init_mm, p4d, lm_alias(kasan_zero_pud));
+			p4d_populate(&init_mm, p4d,
+				zero ? lm_alias(kasan_zero_pud) :
+					lm_alias(kasan_black_pud));
 			pud = pud_offset(p4d, addr);
-			pud_populate(&init_mm, pud, lm_alias(kasan_zero_pmd));
+			pud_populate(&init_mm, pud,
+				zero ? lm_alias(kasan_zero_pmd) :
+					lm_alias(kasan_black_pmd));
 			pmd = pmd_offset(pud, addr);
 			pmd_populate_kernel(&init_mm, pmd,
-						lm_alias(kasan_zero_pte));
+				zero ? lm_alias(kasan_zero_pte) :
+					lm_alias(kasan_black_pte));
 			continue;
 		}
 
@@ -143,18 +176,21 @@ static void __init zero_p4d_populate(pgd_t *pgd, unsigned long addr,
 			p4d_populate(&init_mm, p4d,
 				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
 		}
-		zero_pud_populate(p4d, addr, next);
+		kasan_pud_populate(p4d, addr, next, zero, private);
 	} while (p4d++, addr = next, addr != end);
 }
 
 /**
- * kasan_populate_zero_shadow - populate shadow memory region with
- *                               kasan_zero_page
+ * kasan_populate_shadow - populate shadow memory region with
+ *                               kasan_(zero|black)_page
  * @shadow_start - start of the memory range to populate
  * @shadow_end   - end of the memory range to populate
+ * @zero	 - type of populated shadow, zero and black
+ * @private	 - force to populate private shadow except the last page
  */
-void __init kasan_populate_zero_shadow(const void *shadow_start,
-				const void *shadow_end)
+void __init kasan_populate_shadow(const void *shadow_start,
+				const void *shadow_end,
+				bool zero, bool private)
 {
 	unsigned long addr = (unsigned long)shadow_start;
 	unsigned long end = (unsigned long)shadow_end;
@@ -164,7 +200,8 @@ void __init kasan_populate_zero_shadow(const void *shadow_start,
 	do {
 		next = pgd_addr_end(addr, end);
 
-		if (IS_ALIGNED(addr, PGDIR_SIZE) && end - addr >= PGDIR_SIZE) {
+		if (IS_ALIGNED(addr, PGDIR_SIZE) && end - addr >= PGDIR_SIZE &&
+			!private) {
 			p4d_t *p4d;
 			pud_t *pud;
 			pmd_t *pmd;
@@ -187,14 +224,22 @@ void __init kasan_populate_zero_shadow(const void *shadow_start,
 			 * architectures will switch to pgtable-nop4d.h.
 			 */
 #ifndef __ARCH_HAS_5LEVEL_HACK
-			pgd_populate(&init_mm, pgd, lm_alias(kasan_zero_p4d));
+			pgd_populate(&init_mm, pgd,
+				zero ? lm_alias(kasan_zero_p4d) :
+					lm_alias(kasan_black_p4d));
 #endif
 			p4d = p4d_offset(pgd, addr);
-			p4d_populate(&init_mm, p4d, lm_alias(kasan_zero_pud));
+			p4d_populate(&init_mm, p4d,
+				zero ? lm_alias(kasan_zero_pud) :
+					lm_alias(kasan_black_pud));
 			pud = pud_offset(p4d, addr);
-			pud_populate(&init_mm, pud, lm_alias(kasan_zero_pmd));
+			pud_populate(&init_mm, pud,
+				zero ? lm_alias(kasan_zero_pmd) :
+					lm_alias(kasan_black_pmd));
 			pmd = pmd_offset(pud, addr);
-			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
+			pmd_populate_kernel(&init_mm, pmd,
+				zero ? lm_alias(kasan_zero_pte) :
+					lm_alias(kasan_black_pte));
 			continue;
 		}
 
@@ -202,6 +247,6 @@ void __init kasan_populate_zero_shadow(const void *shadow_start,
 			pgd_populate(&init_mm, pgd,
 				early_alloc(PAGE_SIZE, NUMA_NO_NODE));
 		}
-		zero_p4d_populate(pgd, addr, next);
+		kasan_p4d_populate(pgd, addr, next, zero, private);
 	} while (pgd++, addr = next, addr != end);
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

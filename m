Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id ADCEB6B0073
	for <linux-mm@kvack.org>; Fri, 15 May 2015 09:59:27 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so13284292pdb.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 06:59:27 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id da1si2760789pad.9.2015.05.15.06.59.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 15 May 2015 06:59:24 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOE00L7V9IV4N80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 15 May 2015 14:59:19 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v2 4/5] kasan, x86: move populate_zero_shadow() out of arch
 directory
Date: Fri, 15 May 2015 16:59:03 +0300
Message-id: <1431698344-28054-5-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE..." <x86@kernel.org>

populate_zero_shadow() is cross-platform now.
Rename it to kasan_populate_zero_shadow() and move to
the generic code.
No functional changes here.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/include/asm/kasan.h |  10 ++--
 arch/x86/mm/kasan_init_64.c  | 137 ++-----------------------------------------
 include/linux/kasan.h        |   8 +++
 mm/kasan/Makefile            |   2 +-
 mm/kasan/kasan_init.c        | 136 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 154 insertions(+), 139 deletions(-)
 create mode 100644 mm/kasan/kasan_init.c

diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
index b766c55..fa80b13 100644
--- a/arch/x86/include/asm/kasan.h
+++ b/arch/x86/include/asm/kasan.h
@@ -14,13 +14,11 @@
 
 #ifndef __ASSEMBLY__
 
-extern pte_t kasan_zero_pte[];
-extern pmd_t kasan_zero_pmd[];
-extern pud_t kasan_zero_pud[];
-
 #ifdef CONFIG_KASAN
-void __init kasan_map_early_shadow(pgd_t *pgd);
-void __init kasan_init(void);
+#include <asm/pgtable_types.h>
+
+void kasan_map_early_shadow(pgd_t *pgd);
+void kasan_init(void);
 #else
 static inline void kasan_map_early_shadow(pgd_t *pgd) { }
 static inline void kasan_init(void) { }
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 853dab4..21342fd 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -2,7 +2,6 @@
 #include <linux/kasan.h>
 #include <linux/kdebug.h>
 #include <linux/mm.h>
-#include <linux/pfn.h>
 #include <linux/sched.h>
 #include <linux/vmalloc.h>
 
@@ -51,133 +50,6 @@ void __init kasan_map_early_shadow(pgd_t *pgd)
 	}
 }
 
-static __init void *early_alloc(size_t size, int node)
-{
-	return memblock_virt_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
-					BOOTMEM_ALLOC_ACCESSIBLE, node);
-}
-
-static int __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
-				unsigned long end)
-{
-	pte_t *pte = pte_offset_kernel(pmd, addr);
-	pte_t zero_pte;
-
-	zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
-	zero_pte = pte_wrprotect(zero_pte);
-
-	while (addr + PAGE_SIZE <= end) {
-		set_pte_at(&init_mm, addr, pte, zero_pte);
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
-	unsigned long next;
-
-	do {
-		next = pmd_addr_end(addr, end);
-
-		if (IS_ALIGNED(addr, PMD_SIZE) && end - addr >= PMD_SIZE) {
-			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
-			continue;
-		}
-
-		if (pmd_none(*pmd)) {
-			void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
-			if (!p)
-				return -ENOMEM;
-			pmd_populate_kernel(&init_mm, pmd, p);
-		}
-		zero_pte_populate(pmd, addr, pmd_addr_end(addr, end));
-	} while (pmd++, addr = next, addr != end);
-
-	return ret;
-}
-
-static int __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
-				unsigned long end)
-{
-	int ret = 0;
-	pud_t *pud = pud_offset(pgd, addr);
-	unsigned long next;
-
-	do {
-		next = pud_addr_end(addr, end);
-		if (IS_ALIGNED(addr, PUD_SIZE) && end - addr >= PUD_SIZE) {
-			pmd_t *pmd;
-
-			pud_populate(&init_mm, pud, kasan_zero_pmd);
-			pmd = pmd_offset(pud, addr);
-			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
-			continue;
-		}
-
-		if (pud_none(*pud)) {
-			void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
-			if (!p)
-				return -ENOMEM;
-			pud_populate(&init_mm, pud, p);
-		}
-		zero_pmd_populate(pud, addr, pud_addr_end(addr, end));
-	} while (pud++, addr = next, addr != end);
-
-	return ret;
-}
-
-static int __init zero_pgd_populate(unsigned long addr, unsigned long end)
-{
-	int ret = 0;
-	pgd_t *pgd = pgd_offset_k(addr);
-	unsigned long next;
-
-	do {
-		next = pgd_addr_end(addr, end);
-
-		if (IS_ALIGNED(addr, PGDIR_SIZE) && end - addr >= PGDIR_SIZE) {
-			pud_t *pud;
-			pmd_t *pmd;
-
-			/*
-			 * kasan_zero_pud should be populated with pmds
-			 * at this moment.
-			 * [pud,pmd]_populate*() bellow needed only for
-			 * 3,2 - level page tables where we don't have
-			 * puds,pmds, so pgd_populate(), pud_populate()
-			 * is noops.
-			 */
-			pgd_populate(&init_mm, pgd, kasan_zero_pud);
-			pud = pud_offset(pgd, addr);
-			pud_populate(&init_mm, pud, kasan_zero_pmd);
-			pmd = pmd_offset(pud, addr);
-			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
-			continue;
-		}
-
-		if (pgd_none(*pgd)) {
-			void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
-			if (!p)
-				return -ENOMEM;
-			pgd_populate(&init_mm, pgd, p);
-		}
-		zero_pud_populate(pgd, addr, next);
-	} while (pgd++, addr = next, addr != end);
-
-	return ret;
-}
-
-static void __init populate_zero_shadow(const void *start, const void *end)
-{
-	if (zero_pgd_populate((unsigned long)start, (unsigned long)end))
-		panic("kasan: unable to map zero shadow!");
-}
-
 #ifdef CONFIG_KASAN_INLINE
 static int kasan_die_handler(struct notifier_block *self,
 			     unsigned long val,
@@ -208,7 +80,7 @@ void __init kasan_init(void)
 
 	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
 
-	populate_zero_shadow((void *)KASAN_SHADOW_START,
+	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
 			kasan_mem_to_shadow((void *)PAGE_OFFSET));
 
 	for (i = 0; i < E820_X_MAX; i++) {
@@ -218,14 +90,15 @@ void __init kasan_init(void)
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
index 5486d77..5ef3925 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -13,8 +13,16 @@ struct vm_struct;
 #define KASAN_SHADOW_OFFSET _AC(CONFIG_KASAN_SHADOW_OFFSET, UL)
 
 #include <asm/kasan.h>
+#include <asm/pgtable.h>
 #include <linux/sched.h>
 
+extern unsigned char kasan_zero_page[PAGE_SIZE];
+extern pte_t kasan_zero_pte[PTRS_PER_PTE];
+extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
+extern pud_t kasan_zero_pud[PTRS_PER_PUD];
+
+void kasan_populate_zero_shadow(const void *start, const void *end);
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
index 0000000..5136383
--- /dev/null
+++ b/mm/kasan/kasan_init.c
@@ -0,0 +1,136 @@
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
+static __init void *early_alloc(size_t size, int node)
+{
+	return memblock_virt_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
+					BOOTMEM_ALLOC_ACCESSIBLE, node);
+}
+
+static int __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
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
+	return 0;
+}
+
+static int __init zero_pmd_populate(pud_t *pud, unsigned long addr,
+				unsigned long end)
+{
+	int ret = 0;
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
+			void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
+			if (!p)
+				return -ENOMEM;
+			pmd_populate_kernel(&init_mm, pmd, p);
+		}
+		zero_pte_populate(pmd, addr, pmd_addr_end(addr, end));
+	} while (pmd++, addr = next, addr != end);
+
+	return ret;
+}
+
+static int __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
+				unsigned long end)
+{
+	int ret = 0;
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
+			void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
+			if (!p)
+				return -ENOMEM;
+			pud_populate(&init_mm, pud, p);
+		}
+		zero_pmd_populate(pud, addr, pud_addr_end(addr, end));
+	} while (pud++, addr = next, addr != end);
+
+	return ret;
+}
+
+static int __init zero_pgd_populate(unsigned long addr, unsigned long end)
+{
+	int ret = 0;
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
+			 * [pud,pmd]_populate*() bellow needed only for
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
+			void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
+			if (!p)
+				return -ENOMEM;
+			pgd_populate(&init_mm, pgd, p);
+		}
+		zero_pud_populate(pgd, addr, next);
+	} while (pgd++, addr = next, addr != end);
+
+	return ret;
+}
+
+void __init kasan_populate_zero_shadow(const void *start, const void *end)
+{
+	if (zero_pgd_populate((unsigned long)start, (unsigned long)end))
+		panic("kasan: unable to map zero shadow!");
+}
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

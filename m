Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7DB6B0072
	for <linux-mm@kvack.org>; Fri, 15 May 2015 09:59:25 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so13258439pdf.3
        for <linux-mm@kvack.org>; Fri, 15 May 2015 06:59:25 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id s1si2744508pdf.63.2015.05.15.06.59.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 15 May 2015 06:59:22 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOE00G819IT3680@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 15 May 2015 14:59:17 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v2 3/5] x86: kasan: generalize populate_zero_shadow() code
Date: Fri, 15 May 2015 16:59:02 +0300
Message-id: <1431698344-28054-4-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE..." <x86@kernel.org>

Currently populate_zero_shadow() uses some x86_64 specific
functions/macroses and  only with 4-level pagetables.

This patch generalizes populate_zero_shadow() making
possible to reuse it for other architectures later.

The main changes are:
 * Use p?d_populate*() instead of set_p?d()
 * Use memblock allocator directly instead of vmemmap_alloc_block()

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/mm/kasan_init_64.c | 115 +++++++++++++++++++++++++++-----------------
 1 file changed, 72 insertions(+), 43 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 4860906..853dab4 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -2,9 +2,11 @@
 #include <linux/kasan.h>
 #include <linux/kdebug.h>
 #include <linux/mm.h>
+#include <linux/pfn.h>
 #include <linux/sched.h>
 #include <linux/vmalloc.h>
 
+#include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 #include <asm/sections.h>
 
@@ -49,15 +51,23 @@ void __init kasan_map_early_shadow(pgd_t *pgd)
 	}
 }
 
+static __init void *early_alloc(size_t size, int node)
+{
+	return memblock_virt_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
+					BOOTMEM_ALLOC_ACCESSIBLE, node);
+}
+
 static int __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
 				unsigned long end)
 {
 	pte_t *pte = pte_offset_kernel(pmd, addr);
+	pte_t zero_pte;
+
+	zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
+	zero_pte = pte_wrprotect(zero_pte);
 
 	while (addr + PAGE_SIZE <= end) {
-		WARN_ON(!pte_none(*pte));
-		set_pte(pte, __pte(__pa_nodebug(kasan_zero_page)
-					| __PAGE_KERNEL_RO));
+		set_pte_at(&init_mm, addr, pte, zero_pte);
 		addr += PAGE_SIZE;
 		pte = pte_offset_kernel(pmd, addr);
 	}
@@ -69,50 +79,55 @@ static int __init zero_pmd_populate(pud_t *pud, unsigned long addr,
 {
 	int ret = 0;
 	pmd_t *pmd = pmd_offset(pud, addr);
+	unsigned long next;
+
+	do {
+		next = pmd_addr_end(addr, end);
+
+		if (IS_ALIGNED(addr, PMD_SIZE) && end - addr >= PMD_SIZE) {
+			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
+			continue;
+		}
 
-	while (IS_ALIGNED(addr, PMD_SIZE) && addr + PMD_SIZE <= end) {
-		WARN_ON(!pmd_none(*pmd));
-		set_pmd(pmd, __pmd(__pa_nodebug(kasan_zero_pte)
-					| __PAGE_KERNEL_RO));
-		addr += PMD_SIZE;
-		pmd = pmd_offset(pud, addr);
-	}
-	if (addr < end) {
 		if (pmd_none(*pmd)) {
-			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
+			void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
 			if (!p)
 				return -ENOMEM;
-			set_pmd(pmd, __pmd(__pa_nodebug(p) | _KERNPG_TABLE));
+			pmd_populate_kernel(&init_mm, pmd, p);
 		}
-		ret = zero_pte_populate(pmd, addr, end);
-	}
+		zero_pte_populate(pmd, addr, pmd_addr_end(addr, end));
+	} while (pmd++, addr = next, addr != end);
+
 	return ret;
 }
 
-
 static int __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
 				unsigned long end)
 {
 	int ret = 0;
 	pud_t *pud = pud_offset(pgd, addr);
+	unsigned long next;
 
-	while (IS_ALIGNED(addr, PUD_SIZE) && addr + PUD_SIZE <= end) {
-		WARN_ON(!pud_none(*pud));
-		set_pud(pud, __pud(__pa_nodebug(kasan_zero_pmd)
-					| __PAGE_KERNEL_RO));
-		addr += PUD_SIZE;
-		pud = pud_offset(pgd, addr);
-	}
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
 
-	if (addr < end) {
 		if (pud_none(*pud)) {
-			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
+			void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
 			if (!p)
 				return -ENOMEM;
-			set_pud(pud, __pud(__pa_nodebug(p) | _KERNPG_TABLE));
+			pud_populate(&init_mm, pud, p);
 		}
-		ret = zero_pmd_populate(pud, addr, end);
-	}
+		zero_pmd_populate(pud, addr, pud_addr_end(addr, end));
+	} while (pud++, addr = next, addr != end);
+
 	return ret;
 }
 
@@ -120,35 +135,49 @@ static int __init zero_pgd_populate(unsigned long addr, unsigned long end)
 {
 	int ret = 0;
 	pgd_t *pgd = pgd_offset_k(addr);
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
 
-	while (IS_ALIGNED(addr, PGDIR_SIZE) && addr + PGDIR_SIZE <= end) {
-		WARN_ON(!pgd_none(*pgd));
-		set_pgd(pgd, __pgd(__pa_nodebug(kasan_zero_pud)
-					| __PAGE_KERNEL_RO));
-		addr += PGDIR_SIZE;
-		pgd = pgd_offset_k(addr);
-	}
-
-	if (addr < end) {
 		if (pgd_none(*pgd)) {
-			void *p = vmemmap_alloc_block(PAGE_SIZE, NUMA_NO_NODE);
+			void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
 			if (!p)
 				return -ENOMEM;
-			set_pgd(pgd, __pgd(__pa_nodebug(p) | _KERNPG_TABLE));
+			pgd_populate(&init_mm, pgd, p);
 		}
-		ret = zero_pud_populate(pgd, addr, end);
-	}
+		zero_pud_populate(pgd, addr, next);
+	} while (pgd++, addr = next, addr != end);
+
 	return ret;
 }
 
-
 static void __init populate_zero_shadow(const void *start, const void *end)
 {
 	if (zero_pgd_populate((unsigned long)start, (unsigned long)end))
 		panic("kasan: unable to map zero shadow!");
 }
 
-
 #ifdef CONFIG_KASAN_INLINE
 static int kasan_die_handler(struct notifier_block *self,
 			     unsigned long val,
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

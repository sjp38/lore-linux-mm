Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 685A36B025B
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:42:45 -0400 (EDT)
Received: by padck2 with SMTP id ck2so16957390pad.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 09:42:45 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id h4si21854311pdi.136.2015.07.24.09.42.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 09:42:40 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NS00021B3R0AB60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Jul 2015 17:42:36 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v4 7/7] x86/kasan: switch to generic
 kasan_populate_zero_shadow()
Date: Fri, 24 Jul 2015 19:41:59 +0300
Message-id: <1437756119-12817-8-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

Now when we have generic kasan_populate_zero_shadow() we could
use it for x86.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/mm/kasan_init_64.c | 109 ++------------------------------------------
 1 file changed, 5 insertions(+), 104 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 812086c..9ce5da2 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -48,106 +48,6 @@ static void __init kasan_map_early_shadow(pgd_t *pgd)
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
@@ -199,7 +99,7 @@ void __init kasan_init(void)
 
 	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
 
-	populate_zero_shadow((void *)KASAN_SHADOW_START,
+	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
 			kasan_mem_to_shadow((void *)PAGE_OFFSET));
 
 	for (i = 0; i < E820_X_MAX; i++) {
@@ -209,14 +109,15 @@ void __init kasan_init(void)
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
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

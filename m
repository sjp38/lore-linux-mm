Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0726B0311
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:18:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c10so114861344pfg.10
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:18:02 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id p185si12005603pga.149.2017.05.15.18.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:18:01 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id f27so7514741pfe.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:18:01 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v1 07/11] x86/kasan: use per-page shadow memory
Date: Tue, 16 May 2017 10:16:45 +0900
Message-Id: <1494897409-14408-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patch enables for x86 to use per-page shadow memory.
Most of initialization code for per-page shadow memory is
copied from the code for original shadow memory.

There are two things that aren't trivial.
1. per-page shadow memory for global variable is initialized
as the bypass range. It's not the target for on-demand shadow
memory allocation since shadow memory for global variable is
always required.
2. per-page shadow memory for the module is initialized as the
bypass range since on-demand shadow memory allocation
for the module is already implemented.

Note that on-demand allocation for original shadow memory isn't
implemented yet so there is no memory saving on this patch.
It will be implemented in the following patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 arch/x86/include/asm/kasan.h |  6 +++
 arch/x86/mm/kasan_init_64.c  | 87 +++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 84 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
index f527b02..cfa63c7 100644
--- a/arch/x86/include/asm/kasan.h
+++ b/arch/x86/include/asm/kasan.h
@@ -18,6 +18,12 @@
  */
 #define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1ULL << (__VIRTUAL_MASK_SHIFT - 3)))
 
+#define HAVE_KASAN_PER_PAGE_SHADOW 1
+#define KASAN_PSHADOW_SIZE	((1ULL << (47 - PAGE_SHIFT)))
+#define KASAN_PSHADOW_START	(kasan_pshadow_offset + \
+					(0xffff800000000000ULL >> PAGE_SHIFT))
+#define KASAN_PSHADOW_END	(KASAN_PSHADOW_START + KASAN_PSHADOW_SIZE)
+
 #ifndef __ASSEMBLY__
 
 #ifdef CONFIG_KASAN
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index adc673b..1c300bf 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -15,19 +15,29 @@
 extern pgd_t early_level4_pgt[PTRS_PER_PGD];
 extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
-static int __init map_range(struct range *range)
+static int __init map_range(struct range *range, bool pshadow)
 {
 	unsigned long start;
 	unsigned long end;
 
-	start = (unsigned long)kasan_mem_to_shadow(pfn_to_kaddr(range->start));
-	end = (unsigned long)kasan_mem_to_shadow(pfn_to_kaddr(range->end));
+	start = (unsigned long)pfn_to_kaddr(range->start);
+	end = (unsigned long)pfn_to_kaddr(range->end);
 
 	/*
 	 * end + 1 here is intentional. We check several shadow bytes in advance
 	 * to slightly speed up fastpath. In some rare cases we could cross
 	 * boundary of mapped shadow, so we just map some more here.
 	 */
+	if (pshadow) {
+		start = (unsigned long)kasan_mem_to_pshadow((void *)start);
+		end = (unsigned long)kasan_mem_to_pshadow((void *)end);
+
+		return vmemmap_populate(start, end + 1, NUMA_NO_NODE);
+	}
+
+	start = (unsigned long)kasan_mem_to_shadow((void *)start);
+	end = (unsigned long)kasan_mem_to_shadow((void *)end);
+
 	return vmemmap_populate(start, end + 1, NUMA_NO_NODE);
 }
 
@@ -49,11 +59,10 @@ static void __init clear_pgds(unsigned long start,
 	}
 }
 
-static void __init kasan_map_early_shadow(pgd_t *pgd)
+static void __init kasan_map_early_shadow(pgd_t *pgd,
+			unsigned long start, unsigned long end)
 {
 	int i;
-	unsigned long start = KASAN_SHADOW_START;
-	unsigned long end = KASAN_SHADOW_END;
 
 	for (i = pgd_index(start); start < end; i++) {
 		switch (CONFIG_PGTABLE_LEVELS) {
@@ -109,8 +118,35 @@ void __init kasan_early_init(void)
 	for (i = 0; CONFIG_PGTABLE_LEVELS >= 5 && i < PTRS_PER_P4D; i++)
 		kasan_zero_p4d[i] = __p4d(p4d_val);
 
-	kasan_map_early_shadow(early_level4_pgt);
-	kasan_map_early_shadow(init_level4_pgt);
+	kasan_map_early_shadow(early_level4_pgt,
+		KASAN_SHADOW_START, KASAN_SHADOW_END);
+	kasan_map_early_shadow(init_level4_pgt,
+		KASAN_SHADOW_START, KASAN_SHADOW_END);
+
+	kasan_early_init_pshadow();
+
+	kasan_map_early_shadow(early_level4_pgt,
+		KASAN_PSHADOW_START, KASAN_PSHADOW_END);
+	kasan_map_early_shadow(init_level4_pgt,
+		KASAN_PSHADOW_START, KASAN_PSHADOW_END);
+
+	/* Prepare black shadow memory */
+	pte_val = __pa_nodebug(kasan_black_page) | __PAGE_KERNEL_RO;
+	pmd_val = __pa_nodebug(kasan_black_pte) | _KERNPG_TABLE;
+	pud_val = __pa_nodebug(kasan_black_pmd) | _KERNPG_TABLE;
+	p4d_val = __pa_nodebug(kasan_black_pud) | _KERNPG_TABLE;
+
+	for (i = 0; i < PTRS_PER_PTE; i++)
+		kasan_black_pte[i] = __pte(pte_val);
+
+	for (i = 0; i < PTRS_PER_PMD; i++)
+		kasan_black_pmd[i] = __pmd(pmd_val);
+
+	for (i = 0; i < PTRS_PER_PUD; i++)
+		kasan_black_pud[i] = __pud(pud_val);
+
+	for (i = 0; CONFIG_PGTABLE_LEVELS >= 5 && i < PTRS_PER_P4D; i++)
+		kasan_black_p4d[i] = __p4d(p4d_val);
 }
 
 void __init kasan_init(void)
@@ -135,7 +171,7 @@ void __init kasan_init(void)
 		if (pfn_mapped[i].end == 0)
 			break;
 
-		if (map_range(&pfn_mapped[i]))
+		if (map_range(&pfn_mapped[i], false))
 			panic("kasan: unable to allocate shadow!");
 	}
 	kasan_populate_shadow(
@@ -151,6 +187,39 @@ void __init kasan_init(void)
 			(void *)KASAN_SHADOW_END,
 			true, false);
 
+	/* For per-page shadow */
+	clear_pgds(KASAN_PSHADOW_START, KASAN_PSHADOW_END);
+
+	kasan_populate_shadow((void *)KASAN_PSHADOW_START,
+			kasan_mem_to_pshadow((void *)PAGE_OFFSET),
+			true, false);
+
+	for (i = 0; i < E820_MAX_ENTRIES; i++) {
+		if (pfn_mapped[i].end == 0)
+			break;
+
+		if (map_range(&pfn_mapped[i], true))
+			panic("kasan: unable to allocate shadow!");
+	}
+	kasan_populate_shadow(
+		kasan_mem_to_pshadow((void *)PAGE_OFFSET + MAXMEM),
+		kasan_mem_to_pshadow((void *)__START_KERNEL_map),
+		true, false);
+
+	kasan_populate_shadow(
+		kasan_mem_to_pshadow(_stext),
+		kasan_mem_to_pshadow(_end),
+		false, false);
+
+	kasan_populate_shadow(
+		kasan_mem_to_pshadow((void *)MODULES_VADDR),
+		kasan_mem_to_pshadow((void *)MODULES_END),
+		false, false);
+
+	kasan_populate_shadow(kasan_mem_to_pshadow((void *)MODULES_END),
+			(void *)KASAN_PSHADOW_END,
+			true, false);
+
 	load_cr3(init_level4_pgt);
 	__flush_tlb_all();
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

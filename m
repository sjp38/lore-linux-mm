Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 918C76B0315
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:18:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id m5so48458627pfc.1
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:18:06 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id g1si12280485pln.18.2017.05.15.18.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:18:05 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id w69so17864571pfk.1
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:18:05 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v1 08/11] mm/kasan: support on-demand shadow allocation/mapping
Date: Tue, 16 May 2017 10:16:46 +0900
Message-Id: <1494897409-14408-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Original shadow memory is only used when it is used by specific types
of access. We can distinguish them and can allocate actual shadow memory
on-demand to reduce memory consumption.

There is a problem on this on-demand shadow memory. After setting up
new mapping, we need to flush TLB entry in all cpus but it's not always
possible in some contexts. Solving this problem isn't possible without
considering architecture specific property so this patch introduces
two architecture specific functions. Architecture who wants to use
this feature needs to implemente them correctly.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 arch/x86/mm/kasan_init_64.c |   9 +++
 mm/kasan/kasan.c            | 133 +++++++++++++++++++++++++++++++++++++++++++-
 mm/kasan/kasan.h            |  16 ++++--
 mm/kasan/kasan_init.c       |   2 +
 4 files changed, 154 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 1c300bf..136b73d 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -239,3 +239,12 @@ void __init kasan_init(void)
 	init_task.kasan_depth = 0;
 	pr_info("KernelAddressSanitizer initialized\n");
 }
+
+void arch_kasan_map_shadow(unsigned long s, unsigned long e)
+{
+}
+
+bool arch_kasan_recheck_prepare(unsigned long addr, size_t size)
+{
+	return false;
+}
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index fb18283..8d59cf0 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -36,9 +36,13 @@
 #include <linux/types.h>
 #include <linux/vmalloc.h>
 #include <linux/bug.h>
+#include <asm/cacheflush.h>
 
 #include "kasan.h"
 #include "../slab.h"
+#include "../internal.h"
+
+static DEFINE_SPINLOCK(shadow_lock);
 
 void kasan_enable_current(void)
 {
@@ -140,6 +144,103 @@ void kasan_unpoison_pshadow(const void *address, size_t size)
 	kasan_mark_pshadow(address, size, 0);
 }
 
+static bool kasan_black_shadow(pte_t *ptep)
+{
+	pte_t pte = *ptep;
+
+	if (pte_none(pte))
+		return true;
+
+	if (pte_pfn(pte) == kasan_black_page_pfn)
+		return true;
+
+	return false;
+}
+
+static int kasan_exist_shadow_pte(pte_t *ptep, pgtable_t token,
+			unsigned long addr, void *data)
+{
+	unsigned long *count = data;
+
+	if (kasan_black_shadow(ptep))
+		return 0;
+
+	(*count)++;
+	return 0;
+}
+
+static int kasan_map_shadow_pte(pte_t *ptep, pgtable_t token,
+			unsigned long addr, void *data)
+{
+	pte_t pte;
+	gfp_t gfp_flags = *(gfp_t *)data;
+	struct page *page;
+	unsigned long flags;
+
+	if (!kasan_black_shadow(ptep))
+		return 0;
+
+	page = alloc_page(gfp_flags);
+	if (!page)
+		return -ENOMEM;
+
+	__memcpy(page_address(page), kasan_black_page, PAGE_SIZE);
+
+	spin_lock_irqsave(&shadow_lock, flags);
+	if (!kasan_black_shadow(ptep))
+		goto out;
+
+	pte = mk_pte(page, PAGE_KERNEL);
+	set_pte_at(&init_mm, addr, ptep, pte);
+	page = NULL;
+
+out:
+	spin_unlock_irqrestore(&shadow_lock, flags);
+	if (page)
+		__free_page(page);
+
+	return 0;
+}
+
+static int kasan_map_shadow(const void *addr, size_t size, gfp_t flags)
+{
+	int err;
+	unsigned long shadow_start, shadow_end;
+	unsigned long count = 0;
+
+	if (!kasan_pshadow_inited())
+		return 0;
+
+	flags = flags & GFP_RECLAIM_MASK;
+	shadow_start = (unsigned long)kasan_mem_to_shadow(addr);
+	shadow_end = (unsigned long)kasan_mem_to_shadow(addr + size);
+	shadow_start = round_down(shadow_start, PAGE_SIZE);
+	shadow_end = ALIGN(shadow_end, PAGE_SIZE);
+
+	err = apply_to_page_range(&init_mm, shadow_start,
+				shadow_end - shadow_start,
+				kasan_exist_shadow_pte, &count);
+	if (err) {
+		pr_err("checking shadow entry is failed");
+		return err;
+	}
+
+	if (count == (shadow_end - shadow_start) / PAGE_SIZE)
+		goto out;
+
+	err = apply_to_page_range(&init_mm, shadow_start,
+		shadow_end - shadow_start,
+		kasan_map_shadow_pte, (void *)&flags);
+
+out:
+	arch_kasan_map_shadow(shadow_start, shadow_end);
+	flush_cache_vmap(shadow_start, shadow_end);
+	if (err)
+		pr_err("mapping shadow entry is failed");
+
+	return err;
+}
+
 /*
  * All functions below always inlined so compiler could
  * perform better optimizations in each of __asan_loadX/__assn_storeX
@@ -389,6 +490,24 @@ static __always_inline bool memory_is_poisoned(unsigned long addr, size_t size)
 	return memory_is_poisoned_n(addr, size);
 }
 
+static noinline void check_memory_region_slow(unsigned long addr,
+				size_t size, bool write,
+				unsigned long ret_ip)
+{
+	preempt_disable();
+	if (!arch_kasan_recheck_prepare(addr, size))
+		goto report;
+
+	if (!memory_is_poisoned(addr, size)) {
+		preempt_enable();
+		return;
+	}
+
+report:
+	preempt_enable();
+	kasan_report(addr, size, write, ret_ip);
+}
+
 static __always_inline void check_memory_region_inline(unsigned long addr,
 						size_t size, bool write,
 						unsigned long ret_ip)
@@ -405,7 +524,7 @@ static __always_inline void check_memory_region_inline(unsigned long addr,
 	if (likely(!memory_is_poisoned(addr, size)))
 		return;
 
-	kasan_report(addr, size, write, ret_ip);
+	check_memory_region_slow(addr, size, write, ret_ip);
 }
 
 static void check_memory_region(unsigned long addr,
@@ -783,9 +902,15 @@ void kasan_kfree_large(const void *ptr)
 
 int kasan_slab_page_alloc(const void *addr, size_t size, gfp_t flags)
 {
+	int err;
+
 	if (!kasan_pshadow_inited() || !addr)
 		return 0;
 
+	err = kasan_map_shadow(addr, size, flags);
+	if (err)
+		return err;
+
 	kasan_unpoison_shadow(addr, size);
 	kasan_poison_pshadow(addr, size);
 
@@ -836,9 +961,15 @@ void kasan_free_shadow(const struct vm_struct *vm)
 
 int kasan_stack_alloc(const void *addr, size_t size)
 {
+	int err;
+
 	if (!kasan_pshadow_inited() || !addr)
 		return 0;
 
+	err = kasan_map_shadow(addr, size, THREADINFO_GFP);
+	if (err)
+		return err;
+
 	kasan_unpoison_shadow(addr, size);
 	kasan_poison_pshadow(addr, size);
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index e9a67ac..db04087 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -88,19 +88,25 @@ struct kasan_free_meta {
 	struct qlist_node quarantine_link;
 };
 
+extern unsigned long kasan_black_page_pfn;
+
 struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
 					const void *object);
 struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 					const void *object);
 
-static inline bool kasan_pshadow_inited(void)
-{
 #ifdef HAVE_KASAN_PER_PAGE_SHADOW
-	return true;
+void arch_kasan_map_shadow(unsigned long s, unsigned long e);
+bool arch_kasan_recheck_prepare(unsigned long addr, size_t size);
+
+static inline bool kasan_pshadow_inited(void) {	return true; }
+
 #else
-	return false;
+static inline void arch_kasan_map_shadow(unsigned long s, unsigned long e) { }
+static inline bool arch_kasan_recheck_prepare(unsigned long addr,
+					size_t size) { return false; }
+static inline bool kasan_pshadow_inited(void) {	return false; }
 #endif
-}
 
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index da9dcab..85dff70 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -25,6 +25,7 @@
 #include "kasan.h"
 
 unsigned long kasan_pshadow_offset __read_mostly;
+unsigned long kasan_black_page_pfn __read_mostly;
 
 /*
  * This page serves two purposes:
@@ -278,6 +279,7 @@ void __init kasan_early_init_pshadow(void)
 					(kernel_offset >> PAGE_SHIFT);
 
 	BUILD_BUG_ON(KASAN_FREE_PAGE != KASAN_PER_PAGE_BYPASS);
+	kasan_black_page_pfn = PFN_DOWN(__pa(kasan_black_page));
 	for (i = 0; i < PAGE_SIZE; i++)
 		kasan_black_page[i] = KASAN_FREE_PAGE;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

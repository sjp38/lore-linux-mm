Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5706B0338
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:18:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a66so114843437pfl.6
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:18:15 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id l8si12138281pln.114.2017.05.15.18.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:18:14 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id n23so16742871pfb.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:18:14 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v1 10/11] mm/kasan: support dynamic shadow memory free
Date: Tue, 16 May 2017 10:16:48 +0900
Message-Id: <1494897409-14408-11-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

On-demand alloc/map the shadow memory isn't sufficient to save
memory consumption since shadow memory would be populated
for all the memory range in the long running system. This patch
implements dynamic shadow memory unmap/free to solve this problem.

Since shadow memory is populated in order-3 page unit, we can also
unmap/free in order-3 page unit. Therefore, this patch inserts
a hook in buddy allocator to detect free of order-3 page.

Note that unmapping need to flush TLBs in all cpus so actual
unmap/free is delegate to the workqueue.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/kasan.h |   4 ++
 mm/kasan/kasan.c      | 134 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c       |  10 ++++
 3 files changed, 148 insertions(+)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index c8ef665..9e44cf6 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -87,6 +87,8 @@ int kasan_stack_alloc(const void *address, size_t size);
 void kasan_stack_free(const void *addr, size_t size);
 int kasan_slab_page_alloc(const void *address, size_t size, gfp_t flags);
 void kasan_slab_page_free(const void *addr, size_t size);
+bool kasan_free_buddy(struct page *page, unsigned int order,
+			unsigned int max_order);
 
 void kasan_unpoison_task_stack(struct task_struct *task);
 void kasan_unpoison_stack_above_sp_to(const void *watermark);
@@ -140,6 +142,8 @@ static inline void kasan_stack_free(const void *addr, size_t size) {}
 static inline int kasan_slab_page_alloc(const void *address, size_t size,
 					gfp_t flags) { return 0; }
 static inline void kasan_slab_page_free(const void *addr, size_t size) {}
+static inline bool kasan_free_buddy(struct page *page, unsigned int order,
+			unsigned int max_order) { return false; }
 
 static inline void kasan_unpoison_task_stack(struct task_struct *task) {}
 static inline void kasan_unpoison_stack_above_sp_to(const void *watermark) {}
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 8d59cf0..e5612be 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -36,13 +36,19 @@
 #include <linux/types.h>
 #include <linux/vmalloc.h>
 #include <linux/bug.h>
+#include <linux/page-isolation.h>
 #include <asm/cacheflush.h>
+#include <asm/tlbflush.h>
+#include <asm/sections.h>
 
 #include "kasan.h"
 #include "../slab.h"
 #include "../internal.h"
 
 static DEFINE_SPINLOCK(shadow_lock);
+static LIST_HEAD(unmap_list);
+static void kasan_unmap_shadow_workfn(struct work_struct *work);
+static DECLARE_WORK(kasan_unmap_shadow_work, kasan_unmap_shadow_workfn);
 
 void kasan_enable_current(void)
 {
@@ -241,6 +247,125 @@ static int kasan_map_shadow(const void *addr, size_t size, gfp_t flags)
 	return err;
 }
 
+static int kasan_unmap_shadow_pte(pte_t *ptep, pgtable_t token,
+			unsigned long addr, void *data)
+{
+	pte_t pte;
+	struct page *page;
+	struct list_head *list = data;
+
+	if (kasan_black_shadow(ptep))
+		return 0;
+
+	if (addr >= (unsigned long)_text && addr < (unsigned long)_end)
+		return 0;
+
+	pte = *ptep;
+	page = pfn_to_page(pte_pfn(pte));
+	list_add(&page->lru, list);
+
+	pte = pfn_pte(PFN_DOWN(__pa(kasan_black_page)), PAGE_KERNEL);
+	pte = pte_wrprotect(pte);
+	set_pte_at(&init_mm, addr, ptep, pte);
+
+	return 0;
+}
+
+static void kasan_unmap_shadow_workfn(struct work_struct *work)
+{
+	struct page *page, *next;
+	LIST_HEAD(list);
+	LIST_HEAD(shadow_list);
+	unsigned long flags;
+	unsigned int order;
+	unsigned long shadow_addr, shadow_size;
+	unsigned long tlb_start = ULONG_MAX, tlb_end = 0;
+	int err;
+
+	spin_lock_irqsave(&shadow_lock, flags);
+	list_splice_init(&unmap_list, &list);
+	spin_unlock_irqrestore(&shadow_lock, flags);
+
+	if (list_empty(&list))
+		return;
+
+	list_for_each_entry_safe(page, next, &list, lru) {
+		order = page_private(page);
+		post_alloc_hook(page, order, GFP_NOWAIT);
+		set_page_private(page, order);
+
+		shadow_addr = (unsigned long)kasan_mem_to_shadow(
+						page_address(page));
+		shadow_size = PAGE_SIZE << (order - KASAN_SHADOW_SCALE_SHIFT);
+
+		tlb_start = min(shadow_addr, tlb_start);
+		tlb_end = max(shadow_addr + shadow_size, tlb_end);
+
+		flush_cache_vunmap(shadow_addr, shadow_addr + shadow_size);
+		err = apply_to_page_range(&init_mm, shadow_addr, shadow_size,
+				kasan_unmap_shadow_pte, &shadow_list);
+		if (err) {
+			pr_err("invalid shadow entry is found");
+			list_del(&page->lru);
+		}
+	}
+	flush_tlb_kernel_range(tlb_start, tlb_end);
+
+	list_for_each_entry_safe(page, next, &list, lru) {
+		list_del(&page->lru);
+		__free_pages(page, page_private(page));
+	}
+	list_for_each_entry_safe(page, next, &shadow_list, lru) {
+		list_del(&page->lru);
+		__free_page(page);
+	}
+}
+
+static bool kasan_unmap_shadow(struct page *page, unsigned int order,
+			unsigned int max_order)
+{
+	int err;
+	unsigned long shadow_addr, shadow_size;
+	unsigned long count = 0;
+	LIST_HEAD(list);
+	unsigned long flags;
+	struct zone *zone;
+	int mt;
+
+	if (order < KASAN_SHADOW_SCALE_SHIFT)
+		return false;
+
+	if (max_order != (KASAN_SHADOW_SCALE_SHIFT + 1))
+		return false;
+
+	shadow_addr = (unsigned long)kasan_mem_to_shadow(page_address(page));
+	shadow_size = PAGE_SIZE << (order - KASAN_SHADOW_SCALE_SHIFT);
+	err = apply_to_page_range(&init_mm, shadow_addr, shadow_size,
+				kasan_exist_shadow_pte, &count);
+	if (err) {
+		pr_err("checking shadow entry is failed");
+		return false;
+	}
+
+	if (!count)
+		return false;
+
+	zone = page_zone(page);
+	mt = get_pageblock_migratetype(page);
+	if (!is_migrate_isolate(mt))
+		__mod_zone_freepage_state(zone, -(1UL << order), mt);
+
+	set_page_private(page, order);
+
+	spin_lock_irqsave(&shadow_lock, flags);
+	list_add(&page->lru, &unmap_list);
+	spin_unlock_irqrestore(&shadow_lock, flags);
+
+	schedule_work(&kasan_unmap_shadow_work);
+
+	return true;
+}
+
 /*
  * All functions below always inlined so compiler could
  * perform better optimizations in each of __asan_loadX/__assn_storeX
@@ -601,6 +726,15 @@ void kasan_free_pages(struct page *page, unsigned int order)
 	}
 }
 
+bool kasan_free_buddy(struct page *page, unsigned int order,
+			unsigned int max_order)
+{
+	if (!kasan_pshadow_inited())
+		return false;
+
+	return kasan_unmap_shadow(page, order, max_order);
+}
+
 /*
  * Adaptive redzone policy taken from the userspace AddressSanitizer runtime.
  * For larger allocations larger redzones are used.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b175c3..4a6f722 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -797,6 +797,12 @@ static inline void __free_one_page(struct page *page,
 
 	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
+#ifdef CONFIG_KASAN
+	/* Suppress merging at initial attempt to unmap shadow memory */
+	max_order = min_t(unsigned int,
+			KASAN_SHADOW_SCALE_SHIFT + 1, max_order);
+#endif
+
 	VM_BUG_ON(!zone_is_initialized(zone));
 	VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
 
@@ -832,6 +838,10 @@ static inline void __free_one_page(struct page *page,
 		pfn = combined_pfn;
 		order++;
 	}
+
+	if (unlikely(kasan_free_buddy(page, order, max_order)))
+		return;
+
 	if (max_order < MAX_ORDER) {
 		/* If we are here, it means order is >= pageblock_order.
 		 * We want to prevent merge between freepages on isolate
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

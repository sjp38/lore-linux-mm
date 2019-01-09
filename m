Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A78DA8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 06:13:23 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g12so3967919pll.22
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 03:13:23 -0800 (PST)
Received: from alexa-out-blr.qualcomm.com (alexa-out-blr-02.qualcomm.com. [103.229.18.198])
        by mx.google.com with ESMTPS id t12si64779560plr.311.2019.01.09.03.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 03:13:22 -0800 (PST)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH v8] mm/page_alloc.c: memory_hotplug: free pages as higher order
Date: Wed,  9 Jan 2019 16:43:15 +0530
Message-Id: <1547032395-24582-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arunks.linux@gmail.com, alexander.h.duyck@linux.intel.com, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com, Arun KS <arunks@codeaurora.org>

When freeing pages are done with higher order, time spent on coalescing
pages by buddy allocator can be reduced.  With section size of 256MB, hot
add latency of a single section shows improvement from 50-60 ms to less
than 1 ms, hence improving the hot add latency by 60 times.  Modify
external providers of online callback to align with the change.

Signed-off-by: Arun KS <arunks@codeaurora.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
---
Changes since v7:
- Rebased to 5.0-rc1.
- Fixed onlined_pages accounting.
- Added comment for return value of online_page_callback.
- Renamed xen_bring_pgs_online to xen_online_pages.

Changes since v6:
- Rebased to 4.20
- Changelog updated.
- No improvement seen on arm64, hence removed removal of prefetch.

Changes since v5:
- Rebased to 4.20-rc1.
- Changelog updated.

Changes since v4:
- As suggested by Michal Hocko,
- Simplify logic in online_pages_block() by using get_order().
- Seperate out removal of prefetch from __free_pages_core().

Changes since v3:
- Renamed _free_pages_boot_core -> __free_pages_core.
- Removed prefetch from __free_pages_core.
- Removed xen_online_page().

Changes since v2:
- Reuse code from __free_pages_boot_core().

Changes since v1:
- Removed prefetch().

Changes since RFC:
- Rebase.
- As suggested by Michal Hocko remove pages_per_block.
- Modifed external providers of online_page_callback.

v7: https://lore.kernel.org/patchwork/patch/1028908/
v6: https://lore.kernel.org/patchwork/patch/1007253/
v5: https://lore.kernel.org/patchwork/patch/995739/
v4: https://lore.kernel.org/patchwork/patch/995111/
v3: https://lore.kernel.org/patchwork/patch/992348/
v2: https://lore.kernel.org/patchwork/patch/991363/
v1: https://lore.kernel.org/patchwork/patch/989445/
RFC: https://lore.kernel.org/patchwork/patch/984754/
---
 drivers/hv/hv_balloon.c        |  6 +++--
 drivers/xen/balloon.c          | 21 +++++++++++------
 include/linux/memory_hotplug.h |  2 +-
 mm/internal.h                  |  1 +
 mm/memory_hotplug.c            | 51 +++++++++++++++++++++++++++++++-----------
 mm/page_alloc.c                |  8 +++----
 6 files changed, 62 insertions(+), 27 deletions(-)

diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index 5301fef..211f3fe 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -771,7 +771,7 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
 	}
 }
 
-static void hv_online_page(struct page *pg)
+static int hv_online_page(struct page *pg, unsigned int order)
 {
 	struct hv_hotadd_state *has;
 	unsigned long flags;
@@ -783,10 +783,12 @@ static void hv_online_page(struct page *pg)
 		if ((pfn < has->start_pfn) || (pfn >= has->end_pfn))
 			continue;
 
-		hv_page_online_one(has, pg);
+		hv_bring_pgs_online(has, pfn, (1UL << order));
 		break;
 	}
 	spin_unlock_irqrestore(&dm_device.ha_lock, flags);
+
+	return 0;
 }
 
 static int pfn_covered(unsigned long start_pfn, unsigned long pfn_cnt)
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index ceb5048..116a042 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -345,7 +345,7 @@ static enum bp_state reserve_additional_memory(void)
 
 	/*
 	 * add_memory_resource() will call online_pages() which in its turn
-	 * will call xen_online_page() callback causing deadlock if we don't
+	 * will call xen_online_pages() callback causing deadlock if we don't
 	 * release balloon_mutex here. Unlocking here is safe because the
 	 * callers drop the mutex before trying again.
 	 */
@@ -369,15 +369,22 @@ static enum bp_state reserve_additional_memory(void)
 	return BP_ECANCELED;
 }
 
-static void xen_online_page(struct page *page)
+static int xen_online_pages(struct page *pg, unsigned int order)
 {
-	__online_page_set_limits(page);
+	unsigned long i, size = (1 << order);
+	unsigned long start_pfn = page_to_pfn(pg);
+	struct page *p;
 
+	pr_debug("Online %lu pages starting at pfn 0x%lx\n", size, start_pfn);
 	mutex_lock(&balloon_mutex);
-
-	__balloon_append(page);
-
+	for (i = 0; i < size; i++) {
+		p = pfn_to_page(start_pfn + i);
+		__online_page_set_limits(p);
+		__balloon_append(p);
+	}
 	mutex_unlock(&balloon_mutex);
+
+	return 0;
 }
 
 static int xen_memory_notifier(struct notifier_block *nb, unsigned long val, void *v)
@@ -702,7 +709,7 @@ static int __init balloon_init(void)
 	balloon_stats.max_retry_count = RETRY_UNLIMITED;
 
 #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	set_online_page_callback(&xen_online_page);
+	set_online_page_callback(&xen_online_pages);
 	register_memory_notifier(&xen_memory_nb);
 	register_sysctl_table(xen_root);
 #endif
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 07da5c6..d56bfba 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -87,7 +87,7 @@ extern int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long *valid_start, unsigned long *valid_end);
 extern void __offline_isolated_pages(unsigned long, unsigned long);
 
-typedef void (*online_page_callback_t)(struct page *page);
+typedef int (*online_page_callback_t)(struct page *page, unsigned int order);
 
 extern int set_online_page_callback(online_page_callback_t callback);
 extern int restore_online_page_callback(online_page_callback_t callback);
diff --git a/mm/internal.h b/mm/internal.h
index f4a7bb0..536bc2a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -163,6 +163,7 @@ static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 extern int __isolate_free_page(struct page *page, unsigned int order);
 extern void memblock_free_pages(struct page *page, unsigned long pfn,
 					unsigned int order);
+extern void __free_pages_core(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
 extern void post_alloc_hook(struct page *page, unsigned int order,
 					gfp_t gfp_flags);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b9a667d..573d9c32 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -47,7 +47,7 @@
  * and restore_online_page_callback() for generic callback restore.
  */
 
-static void generic_online_page(struct page *page);
+static int generic_online_page(struct page *page, unsigned int order);
 
 static online_page_callback_t online_page_callback = generic_online_page;
 static DEFINE_MUTEX(online_page_callback_lock);
@@ -656,30 +656,55 @@ void __online_page_free(struct page *page)
 }
 EXPORT_SYMBOL_GPL(__online_page_free);
 
-static void generic_online_page(struct page *page)
+static int generic_online_page(struct page *page, unsigned int order)
 {
-	__online_page_set_limits(page);
-	__online_page_increment_counters(page);
-	__online_page_free(page);
+	__free_pages_core(page, order);
+	totalram_pages_add(1UL << order);
+#ifdef CONFIG_HIGHMEM
+	if (PageHighMem(page))
+		totalhigh_pages_add(1UL << order);
+#endif
+	return 0;
+}
+
+static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
+{
+	unsigned long end = start + nr_pages;
+	int order, ret, onlined_pages = 0;
+
+	while (start < end) {
+		order = min(MAX_ORDER - 1,
+			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
+
+		/*
+		 * External callback providers can deny onlining pages. So check
+		 * for return value.
+		 * zero		: if all pages are onlined.
+		 * positive	: if only few pages are onlined.
+		 * negative	: if none of the pages are onlined.
+		 */
+		ret = (*online_page_callback)(pfn_to_page(start), order);
+		if (!ret)
+			onlined_pages += (1UL << order);
+		else if (ret > 0)
+			onlined_pages += ret;
+
+		start += (1UL << order);
+	}
+	return onlined_pages;
 }
 
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 			void *arg)
 {
-	unsigned long i;
 	unsigned long onlined_pages = *(unsigned long *)arg;
-	struct page *page;
 
 	if (PageReserved(pfn_to_page(start_pfn)))
-		for (i = 0; i < nr_pages; i++) {
-			page = pfn_to_page(start_pfn + i);
-			(*online_page_callback)(page);
-			onlined_pages++;
-		}
+		onlined_pages = online_pages_blocks(start_pfn, nr_pages);
 
 	online_mem_sections(start_pfn, start_pfn + nr_pages);
 
-	*(unsigned long *)arg = onlined_pages;
+	*(unsigned long *)arg += onlined_pages;
 	return 0;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d295c9b..883212a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1303,7 +1303,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
-static void __init __free_pages_boot_core(struct page *page, unsigned int order)
+void __free_pages_core(struct page *page, unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
 	struct page *p = page;
@@ -1382,7 +1382,7 @@ void __init memblock_free_pages(struct page *page, unsigned long pfn,
 {
 	if (early_page_uninitialised(pfn))
 		return;
-	return __free_pages_boot_core(page, order);
+	__free_pages_core(page, order);
 }
 
 /*
@@ -1472,14 +1472,14 @@ static void __init deferred_free_range(unsigned long pfn,
 	if (nr_pages == pageblock_nr_pages &&
 	    (pfn & (pageblock_nr_pages - 1)) == 0) {
 		set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-		__free_pages_boot_core(page, pageblock_order);
+		__free_pages_core(page, pageblock_order);
 		return;
 	}
 
 	for (i = 0; i < nr_pages; i++, page++, pfn++) {
 		if ((pfn & (pageblock_nr_pages - 1)) == 0)
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-		__free_pages_boot_core(page, 0);
+		__free_pages_core(page, 0);
 	}
 }
 
-- 
1.9.1

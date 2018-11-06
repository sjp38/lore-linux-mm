Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADAB6B02BA
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 01:03:35 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id i81-v6so11687749pfj.1
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 22:03:35 -0800 (PST)
Received: from alexa-out-blr-01.qualcomm.com (alexa-out-blr-01.qualcomm.com. [103.229.18.197])
        by mx.google.com with ESMTPS id y27si11829553pga.459.2018.11.05.22.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 22:03:33 -0800 (PST)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH v6 1/2] memory_hotplug: Free pages as higher order
Date: Tue,  6 Nov 2018 11:33:13 +0530
Message-Id: <1541484194-1493-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arunks.linux@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com, Arun KS <arunks@codeaurora.org>

When free pages are done with higher order, time spend on
coalescing pages by buddy allocator can be reduced. With
section size of 256MB, hot add latency of a single section
shows improvement from 50-60 ms to less than 1 ms, hence
improving the hot add latency by 60%. Modify external
providers of online callback to align with the change.

This patch modifies totalram_pages, zone->managed_pages and
totalhigh_pages outside managed_page_count_lock. A follow up
series will be send to convert these variable to atomic to
avoid readers potentially seeing a store tear.

Signed-off-by: Arun KS <arunks@codeaurora.org>
---
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

v5: https://lore.kernel.org/patchwork/patch/995739/
v4: https://lore.kernel.org/patchwork/patch/995111/
v3: https://lore.kernel.org/patchwork/patch/992348/
v2: https://lore.kernel.org/patchwork/patch/991363/
v1: https://lore.kernel.org/patchwork/patch/989445/
RFC: https://lore.kernel.org/patchwork/patch/984754/

---

Signed-off-by: Arun KS <arunks@codeaurora.org>
---
 drivers/hv/hv_balloon.c        |  6 ++++--
 drivers/xen/balloon.c          | 23 +++++++++++++++--------
 include/linux/memory_hotplug.h |  2 +-
 mm/internal.h                  |  1 +
 mm/memory_hotplug.c            | 42 ++++++++++++++++++++++++++++++------------
 mm/page_alloc.c                |  8 ++++----
 6 files changed, 55 insertions(+), 27 deletions(-)

diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index 4163151..5728dc4 100644
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
index fdfc64f..1214828 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -390,8 +390,8 @@ static enum bp_state reserve_additional_memory(void)
 
 	/*
 	 * add_memory_resource() will call online_pages() which in its turn
-	 * will call xen_online_page() callback causing deadlock if we don't
-	 * release balloon_mutex here. Unlocking here is safe because the
+	 * will call xen_bring_pgs_online() callback causing deadlock if we
+	 * don't release balloon_mutex here. Unlocking here is safe because the
 	 * callers drop the mutex before trying again.
 	 */
 	mutex_unlock(&balloon_mutex);
@@ -414,15 +414,22 @@ static enum bp_state reserve_additional_memory(void)
 	return BP_ECANCELED;
 }
 
-static void xen_online_page(struct page *page)
+static int xen_bring_pgs_online(struct page *pg, unsigned int order)
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
@@ -747,7 +754,7 @@ static int __init balloon_init(void)
 	balloon_stats.max_retry_count = RETRY_UNLIMITED;
 
 #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	set_online_page_callback(&xen_online_page);
+	set_online_page_callback(&xen_bring_pgs_online);
 	register_memory_notifier(&xen_memory_nb);
 	register_sysctl_table(xen_root);
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ffd9cd1..84e9ae2 100644
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
index 291eb2b..3b1ec14 100644
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
index 2b2b3cc..99b4228 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -46,7 +46,7 @@
  * and restore_online_page_callback() for generic callback restore.
  */
 
-static void generic_online_page(struct page *page);
+static int generic_online_page(struct page *page, unsigned int order);
 
 static online_page_callback_t online_page_callback = generic_online_page;
 static DEFINE_MUTEX(online_page_callback_lock);
@@ -655,26 +655,44 @@ void __online_page_free(struct page *page)
 }
 EXPORT_SYMBOL_GPL(__online_page_free);
 
-static void generic_online_page(struct page *page)
+static int generic_online_page(struct page *page, unsigned int order)
 {
-	__online_page_set_limits(page);
-	__online_page_increment_counters(page);
-	__online_page_free(page);
+	__free_pages_core(page, order);
+	totalram_pages += (1UL << order);
+#ifdef CONFIG_HIGHMEM
+	if (PageHighMem(page))
+		totalhigh_pages += (1UL << order);
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
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a919ba5..7cf503f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1264,7 +1264,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
-static void __init __free_pages_boot_core(struct page *page, unsigned int order)
+void __free_pages_core(struct page *page, unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
 	struct page *p = page;
@@ -1343,7 +1343,7 @@ void __init memblock_free_pages(struct page *page, unsigned long pfn,
 {
 	if (early_page_uninitialised(pfn))
 		return;
-	return __free_pages_boot_core(page, order);
+	return __free_pages_core(page, order);
 }
 
 /*
@@ -1433,14 +1433,14 @@ static void __init deferred_free_range(unsigned long pfn,
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

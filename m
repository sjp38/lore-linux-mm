Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 889918E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 02:59:11 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 77-v6so1767749pgg.0
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 23:59:11 -0700 (PDT)
Received: from alexa-out-blr-01.qualcomm.com (alexa-out-blr-01.qualcomm.com. [103.229.18.197])
        by mx.google.com with ESMTPS id 184-v6si1371989pfe.249.2018.09.26.23.59.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 23:59:09 -0700 (PDT)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH v3] memory_hotplug: Free pages as higher order
Date: Thu, 27 Sep 2018 12:28:50 +0530
Message-Id: <1538031530-25489-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org
Cc: vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com, Arun KS <arunks@codeaurora.org>

When free pages are done with higher order, time spend on
coalescing pages by buddy allocator can be reduced. With
section size of 256MB, hot add latency of a single section
shows improvement from 50-60 ms to less than 1 ms, hence
improving the hot add latency by 60%.

Modify external providers of online callback to align with
the change.

Signed-off-by: Arun KS <arunks@codeaurora.org>
---
Changes since v2:
reuse code from __free_pages_boot_core()

Changes since v1:
- Removed prefetch()

Changes since RFC:
- Rebase.
- As suggested by Michal Hocko remove pages_per_block.
- Modifed external providers of online_page_callback.

v2: https://lore.kernel.org/patchwork/patch/991363/
v1: https://lore.kernel.org/patchwork/patch/989445/
RFC: https://lore.kernel.org/patchwork/patch/984754/

---
 drivers/hv/hv_balloon.c        |  6 ++++--
 drivers/xen/balloon.c          | 18 ++++++++++++++---
 include/linux/memory_hotplug.h |  2 +-
 mm/internal.h                  |  1 +
 mm/memory_hotplug.c            | 44 ++++++++++++++++++++++++++++++------------
 mm/page_alloc.c                |  2 +-
 6 files changed, 54 insertions(+), 19 deletions(-)

diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index b1b7880..c5bc0b5 100644
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
index e12bb25..010cf4d 100644
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
@@ -422,6 +422,18 @@ static void xen_online_page(struct page *page)
 	mutex_unlock(&balloon_mutex);
 }
 
+static int xen_bring_pgs_online(struct page *pg, unsigned int order)
+{
+	unsigned long i, size = (1 << order);
+	unsigned long start_pfn = page_to_pfn(pg);
+
+	pr_debug("Online %lu pages starting at pfn 0x%lx\n", size, start_pfn);
+	for (i = 0; i < size; i++)
+		xen_online_page(pfn_to_page(start_pfn + i));
+
+	return 0;
+}
+
 static int xen_memory_notifier(struct notifier_block *nb, unsigned long val, void *v)
 {
 	if (val == MEM_ONLINE)
@@ -744,7 +756,7 @@ static int __init balloon_init(void)
 	balloon_stats.max_retry_count = RETRY_UNLIMITED;
 
 #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
-	set_online_page_callback(&xen_online_page);
+	set_online_page_callback(&xen_bring_pgs_online);
 	register_memory_notifier(&xen_memory_nb);
 	register_sysctl_table(xen_root);
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 34a2822..7b04c1d 100644
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
index 87256ae..2b0efac 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -163,6 +163,7 @@ static inline struct page *pageblock_pfn_to_page(unsigned long start_pfn,
 extern int __isolate_free_page(struct page *page, unsigned int order);
 extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
 					unsigned int order);
+extern void __free_pages_boot_core(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
 extern void post_alloc_hook(struct page *page, unsigned int order,
 					gfp_t gfp_flags);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 38d94b7..3c81f20 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -47,7 +47,7 @@
  * and restore_online_page_callback() for generic callback restore.
  */
 
-static void generic_online_page(struct page *page);
+static int generic_online_page(struct page *page, unsigned int order);
 
 static online_page_callback_t online_page_callback = generic_online_page;
 static DEFINE_MUTEX(online_page_callback_lock);
@@ -655,26 +655,46 @@ void __online_page_free(struct page *page)
 }
 EXPORT_SYMBOL_GPL(__online_page_free);
 
-static void generic_online_page(struct page *page)
+static int generic_online_page(struct page *page, unsigned int order)
 {
-	__online_page_set_limits(page);
-	__online_page_increment_counters(page);
-	__online_page_free(page);
+	__free_pages_boot_core(page, order);
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
+		order = min(MAX_ORDER - 1UL, __ffs(start));
+
+		while (start + (1UL << order) > end)
+			order--;
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
index 89d2a2a..a442381 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1252,7 +1252,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
-static void __init __free_pages_boot_core(struct page *page, unsigned int order)
+void __free_pages_boot_core(struct page *page, unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
 	struct page *p = page;
-- 
1.9.1

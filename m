Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 145B58E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 05:39:27 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r130-v6so5518004pgr.13
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 02:39:27 -0700 (PDT)
Received: from alexa-out-blr.qualcomm.com (alexa-out-blr-02.qualcomm.com. [103.229.18.198])
        by mx.google.com with ESMTPS id i22-v6si27027550pgi.52.2018.09.21.02.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 02:39:25 -0700 (PDT)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH] memory_hotplug: Free pages as higher order
Date: Fri, 21 Sep 2018 15:08:29 +0530
Message-Id: <1537522709-7519-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, iamjoonsoo.kim@lge.com, osalvador@suse.de, malat@debian.org, yasu.isimatu@gmail.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org
Cc: svaddagi@codeaurora.org, vinmenon@codeaurora.org, Arun KS <arunks@codeaurora.org>

When free pages are done with higher order, time spend on
coalescing pages by buddy allocator can be reduced. With
section size of 256MB, hot add latency of a single section
shows improvement from 50-60 ms to less than 1 ms, hence
improving the hot add latency by 60%.

Modify external providers of online callback to align with
the change.

Signed-off-by: Arun KS <arunks@codeaurora.org>

---

Changes since RFC:
- Rebase.
- As suggested by Michal Hocko remove pages_per_block.
- Modifed external providers of online_page_callback.

RFC:
https://lore.kernel.org/patchwork/patch/984754/
---
 drivers/hv/hv_balloon.c        |  6 +++--
 drivers/xen/balloon.c          | 18 +++++++++++---
 include/linux/memory_hotplug.h |  2 +-
 mm/memory_hotplug.c            | 55 +++++++++++++++++++++++++++++++++---------
 4 files changed, 63 insertions(+), 18 deletions(-)

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
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 38d94b7..24c2b8e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -47,7 +47,7 @@
  * and restore_online_page_callback() for generic callback restore.
  */
 
-static void generic_online_page(struct page *page);
+static int generic_online_page(struct page *page, unsigned int order);
 
 static online_page_callback_t online_page_callback = generic_online_page;
 static DEFINE_MUTEX(online_page_callback_lock);
@@ -655,26 +655,57 @@ void __online_page_free(struct page *page)
 }
 EXPORT_SYMBOL_GPL(__online_page_free);
 
-static void generic_online_page(struct page *page)
+static int generic_online_page(struct page *page, unsigned int order)
 {
-	__online_page_set_limits(page);
-	__online_page_increment_counters(page);
-	__online_page_free(page);
+	unsigned long nr_pages = 1 << order;
+	struct page *p = page;
+	unsigned int loop;
+
+	prefetchw(p);
+	for (loop = 0 ; loop < (nr_pages - 1) ; loop++, p++) {
+		prefetch(p + 1);
+		__ClearPageReserved(p);
+		set_page_count(p, 0);
+	}
+	__ClearPageReserved(p);
+	set_page_count(p, 0);
+
+	adjust_managed_page_count(page, nr_pages);
+	set_page_refcounted(page);
+	__free_pages(page, order);
+
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
 
-- 
1.9.1

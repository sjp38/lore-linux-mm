Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 176616B0253
	for <linux-mm@kvack.org>; Thu, 26 May 2016 02:22:39 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id x1so92342787pav.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 23:22:39 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id n8si18345958paw.216.2016.05.25.23.22.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 23:22:38 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id c84so745633pfc.1
        for <linux-mm@kvack.org>; Wed, 25 May 2016 23:22:38 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3 1/6] mm/page_alloc: recalculate some of zone threshold when on/offline memory
Date: Thu, 26 May 2016 15:22:23 +0900
Message-Id: <1464243748-16367-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Some of zone threshold depends on number of managed pages in the zone.
When memory is going on/offline, it can be changed and we need to
adjust them.

This patch add recalculation to appropriate places and clean-up
related function for better maintanance.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 36 +++++++++++++++++++++++++++++-------
 1 file changed, 29 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d27e8b9..90e5a82 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4874,6 +4874,8 @@ int local_memory_node(int node)
 }
 #endif
 
+static void setup_min_unmapped_ratio(struct zone *zone);
+static void setup_min_slab_ratio(struct zone *zone);
 #else	/* CONFIG_NUMA */
 
 static void set_zonelist_order(void)
@@ -5988,9 +5990,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone->managed_pages = is_highmem_idx(j) ? realsize : freesize;
 #ifdef CONFIG_NUMA
 		zone->node = nid;
-		zone->min_unmapped_pages = (freesize*sysctl_min_unmapped_ratio)
-						/ 100;
-		zone->min_slab_pages = (freesize * sysctl_min_slab_ratio) / 100;
+		setup_min_unmapped_ratio(zone);
+		setup_min_slab_ratio(zone);
 #endif
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
@@ -6896,6 +6897,7 @@ int __meminit init_per_zone_wmark_min(void)
 {
 	unsigned long lowmem_kbytes;
 	int new_min_free_kbytes;
+	struct zone *zone;
 
 	lowmem_kbytes = nr_free_buffer_pages() * (PAGE_SIZE >> 10);
 	new_min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
@@ -6913,6 +6915,14 @@ int __meminit init_per_zone_wmark_min(void)
 	setup_per_zone_wmarks();
 	refresh_zone_stat_thresholds();
 	setup_per_zone_lowmem_reserve();
+
+	for_each_zone(zone) {
+#ifdef CONFIG_NUMA
+		setup_min_unmapped_ratio(zone);
+		setup_min_slab_ratio(zone);
+#endif
+	}
+
 	return 0;
 }
 core_initcall(init_per_zone_wmark_min)
@@ -6954,6 +6964,12 @@ int watermark_scale_factor_sysctl_handler(struct ctl_table *table, int write,
 }
 
 #ifdef CONFIG_NUMA
+static void setup_min_unmapped_ratio(struct zone *zone)
+{
+	zone->min_unmapped_pages = (zone->managed_pages *
+			sysctl_min_unmapped_ratio) / 100;
+}
+
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
@@ -6965,11 +6981,17 @@ int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 		return rc;
 
 	for_each_zone(zone)
-		zone->min_unmapped_pages = (zone->managed_pages *
-				sysctl_min_unmapped_ratio) / 100;
+		setup_min_unmapped_ratio(zone);
+
 	return 0;
 }
 
+static void setup_min_slab_ratio(struct zone *zone)
+{
+	zone->min_slab_pages = (zone->managed_pages *
+			sysctl_min_slab_ratio) / 100;
+}
+
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
@@ -6981,8 +7003,8 @@ int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
 		return rc;
 
 	for_each_zone(zone)
-		zone->min_slab_pages = (zone->managed_pages *
-				sysctl_min_slab_ratio) / 100;
+		setup_min_slab_ratio(zone);
+
 	return 0;
 }
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

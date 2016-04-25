Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65C766B0253
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 01:21:15 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so345362434pfe.3
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 22:21:15 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id d5si4665473pab.16.2016.04.24.22.21.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Apr 2016 22:21:14 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id c189so17326311pfb.3
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 22:21:14 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 1/6] mm/page_alloc: recalculate some of zone threshold when on/offline memory
Date: Mon, 25 Apr 2016 14:21:05 +0900
Message-Id: <1461561670-28012-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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
index 71fa015..ffa93e0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4633,6 +4633,8 @@ int local_memory_node(int node)
 }
 #endif
 
+static void setup_min_unmapped_ratio(struct zone *zone);
+static void setup_min_slab_ratio(struct zone *zone);
 #else	/* CONFIG_NUMA */
 
 static void set_zonelist_order(void)
@@ -5747,9 +5749,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
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
@@ -6655,6 +6656,7 @@ int __meminit init_per_zone_wmark_min(void)
 {
 	unsigned long lowmem_kbytes;
 	int new_min_free_kbytes;
+	struct zone *zone;
 
 	lowmem_kbytes = nr_free_buffer_pages() * (PAGE_SIZE >> 10);
 	new_min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
@@ -6672,6 +6674,14 @@ int __meminit init_per_zone_wmark_min(void)
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
 module_init(init_per_zone_wmark_min)
@@ -6713,6 +6723,12 @@ int watermark_scale_factor_sysctl_handler(struct ctl_table *table, int write,
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
@@ -6724,11 +6740,17 @@ int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
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
@@ -6740,8 +6762,8 @@ int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
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

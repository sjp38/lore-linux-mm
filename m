Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0AE46B0260
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 02:30:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o124so7839707pfg.1
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 23:30:45 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id y82si41099071pfd.118.2016.08.08.23.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 23:30:44 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id ez1so410479pab.3
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 23:30:44 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 2/2] mm/page_alloc: recalculate some of node threshold when on/offline memory
Date: Tue,  9 Aug 2016 15:30:48 +0900
Message-Id: <1470724248-26780-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1470724248-26780-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1470724248-26780-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Some of node threshold depends on number of managed pages in the node.
When memory is going on/offline, it can be changed and we need to
adjust them.

This patch add recalculation to appropriate places and clean-up
related function for better maintanance.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 50 +++++++++++++++++++++++++++++++++++---------------
 1 file changed, 35 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 555b609..277c3d0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4793,6 +4793,8 @@ int local_memory_node(int node)
 }
 #endif
 
+static void setup_min_unmapped_ratio(void);
+static void setup_min_slab_ratio(void);
 #else	/* CONFIG_NUMA */
 
 static void set_zonelist_order(void)
@@ -5914,9 +5916,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		zone->managed_pages = is_highmem_idx(j) ? realsize : freesize;
 #ifdef CONFIG_NUMA
 		zone->node = nid;
-		pgdat->min_unmapped_pages += (freesize*sysctl_min_unmapped_ratio)
-						/ 100;
-		pgdat->min_slab_pages += (freesize * sysctl_min_slab_ratio) / 100;
 #endif
 		zone->name = zone_names[j];
 		zone->zone_pgdat = pgdat;
@@ -6841,6 +6840,12 @@ int __meminit init_per_zone_wmark_min(void)
 	setup_per_zone_wmarks();
 	refresh_zone_stat_thresholds();
 	setup_per_zone_lowmem_reserve();
+
+#ifdef CONFIG_NUMA
+	setup_min_unmapped_ratio();
+	setup_min_slab_ratio();
+#endif
+
 	return 0;
 }
 core_initcall(init_per_zone_wmark_min)
@@ -6882,16 +6887,10 @@ int watermark_scale_factor_sysctl_handler(struct ctl_table *table, int write,
 }
 
 #ifdef CONFIG_NUMA
-int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
+static void setup_min_unmapped_ratio(void)
 {
-	struct pglist_data *pgdat;
+	pg_data_t *pgdat;
 	struct zone *zone;
-	int rc;
-
-	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
-	if (rc)
-		return rc;
 
 	for_each_online_pgdat(pgdat)
 		pgdat->min_unmapped_pages = 0;
@@ -6899,26 +6898,47 @@ int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 	for_each_zone(zone)
 		zone->zone_pgdat->min_unmapped_pages += (zone->managed_pages *
 				sysctl_min_unmapped_ratio) / 100;
-	return 0;
 }
 
-int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
+
+int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
-	struct pglist_data *pgdat;
-	struct zone *zone;
 	int rc;
 
 	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
 	if (rc)
 		return rc;
 
+	setup_min_unmapped_ratio();
+
+	return 0;
+}
+
+static void setup_min_slab_ratio(void)
+{
+	pg_data_t *pgdat;
+	struct zone *zone;
+
 	for_each_online_pgdat(pgdat)
 		pgdat->min_slab_pages = 0;
 
 	for_each_zone(zone)
 		zone->zone_pgdat->min_slab_pages += (zone->managed_pages *
 				sysctl_min_slab_ratio) / 100;
+}
+
+int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int rc;
+
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (rc)
+		return rc;
+
+	setup_min_slab_ratio();
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 194716B0256
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 03:35:55 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id ba1so348889157obb.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 00:35:55 -0800 (PST)
Received: from mgwym01.jp.fujitsu.com (mgwym01.jp.fujitsu.com. [211.128.242.40])
        by mx.google.com with ESMTPS id c71si52961734oih.74.2016.01.08.00.35.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 00:35:54 -0800 (PST)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 922B5AC02E3
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 17:35:48 +0900 (JST)
From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v4 1/2] mm/page_alloc.c: calculate zone_start_pfn at zone_spanned_pages_in_node()
Date: Fri,  8 Jan 2016 17:26:37 +0900
Message-Id: <1452241597-19640-1-git-send-email-izumi.taku@jp.fujitsu.com>
In-Reply-To: <1452241523-19559-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1452241523-19559-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, dave.hansen@intel.com, matt@codeblueprint.co.uk, arnd@arndb.de, steve.capper@linaro.org, sudeep.holla@arm.com, Taku Izumi <izumi.taku@jp.fujitsu.com>

Currently each zone's zone_start_pfn is calculated at
free_area_init_core().  However zone's range is fixed at the time when
invoking zone_spanned_pages_in_node().

This patch changes each zone->zone_start_pfn is calculated at
zone_spanned_pages_in_node().

v1 -> v2:
 - Fix up the case of CONFIG_HAVE_MEMBLOCK_NODE_MAP=n
 - No functional change in case of CONFIG_HAVE_MEMBLOCK_NODE_MAP=y

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 mm/page_alloc.c | 40 +++++++++++++++++++++++++++++-----------
 1 file changed, 29 insertions(+), 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3c3a5c5..efb8996 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5076,31 +5076,31 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
 					unsigned long node_start_pfn,
 					unsigned long node_end_pfn,
+					unsigned long *zone_start_pfn,
+					unsigned long *zone_end_pfn,
 					unsigned long *ignored)
 {
-	unsigned long zone_start_pfn, zone_end_pfn;
-
 	/* When hotadd a new node from cpu_up(), the node should be empty */
 	if (!node_start_pfn && !node_end_pfn)
 		return 0;
 
 	/* Get the start and end of the zone */
-	zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
-	zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
+	*zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
+	*zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
 	adjust_zone_range_for_zone_movable(nid, zone_type,
 				node_start_pfn, node_end_pfn,
-				&zone_start_pfn, &zone_end_pfn);
+				zone_start_pfn, zone_end_pfn);
 
 	/* Check that this node has pages within the zone's required range */
-	if (zone_end_pfn < node_start_pfn || zone_start_pfn > node_end_pfn)
+	if (*zone_end_pfn < node_start_pfn || *zone_start_pfn > node_end_pfn)
 		return 0;
 
 	/* Move the zone boundaries inside the node if necessary */
-	zone_end_pfn = min(zone_end_pfn, node_end_pfn);
-	zone_start_pfn = max(zone_start_pfn, node_start_pfn);
+	*zone_end_pfn = min(*zone_end_pfn, node_end_pfn);
+	*zone_start_pfn = max(*zone_start_pfn, node_start_pfn);
 
 	/* Return the spanned pages */
-	return zone_end_pfn - zone_start_pfn;
+	return *zone_end_pfn - *zone_start_pfn;
 }
 
 /*
@@ -5165,8 +5165,18 @@ static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
 					unsigned long node_start_pfn,
 					unsigned long node_end_pfn,
+					unsigned long *zone_start_pfn,
+					unsigned long *zone_end_pfn,
 					unsigned long *zones_size)
 {
+	unsigned int zone;
+
+	*zone_start_pfn = node_start_pfn;
+	for (zone = 0; zone < zone_type; zone++)
+		*zone_start_pfn += zones_size[zone];
+
+	*zone_end_pfn = *zone_start_pfn + zones_size[zone_type];
+
 	return zones_size[zone_type];
 }
 
@@ -5195,15 +5205,22 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
 
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		struct zone *zone = pgdat->node_zones + i;
+		unsigned long zone_start_pfn, zone_end_pfn;
 		unsigned long size, real_size;
 
 		size = zone_spanned_pages_in_node(pgdat->node_id, i,
 						  node_start_pfn,
 						  node_end_pfn,
+						  &zone_start_pfn,
+						  &zone_end_pfn,
 						  zones_size);
 		real_size = size - zone_absent_pages_in_node(pgdat->node_id, i,
 						  node_start_pfn, node_end_pfn,
 						  zholes_size);
+		if (size)
+			zone->zone_start_pfn = zone_start_pfn;
+		else
+			zone->zone_start_pfn = 0;
 		zone->spanned_pages = size;
 		zone->present_pages = real_size;
 
@@ -5324,7 +5341,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
-	unsigned long zone_start_pfn = pgdat->node_start_pfn;
 	int ret;
 
 	pgdat_resize_init(pgdat);
@@ -5340,6 +5356,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, freesize, memmap_pages;
+		unsigned long zone_start_pfn = zone->zone_start_pfn;
 
 		size = zone->spanned_pages;
 		realsize = freesize = zone->present_pages;
@@ -5408,7 +5425,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		ret = init_currently_empty_zone(zone, zone_start_pfn, size);
 		BUG_ON(ret);
 		memmap_init(size, nid, j, zone_start_pfn);
-		zone_start_pfn += size;
 	}
 }
 
@@ -5476,6 +5492,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 	pr_info("Initmem setup node %d [mem %#018Lx-%#018Lx]\n", nid,
 		(u64)start_pfn << PAGE_SHIFT,
 		end_pfn ? ((u64)end_pfn << PAGE_SHIFT) - 1 : 0);
+#else
+	start_pfn = node_start_pfn;
 #endif
 	calculate_node_totalpages(pgdat, start_pfn, end_pfn,
 				  zones_size, zholes_size);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

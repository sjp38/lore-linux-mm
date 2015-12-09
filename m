Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id D7E7D6B0259
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 22:16:54 -0500 (EST)
Received: by igvg19 with SMTP id g19so115563115igv.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 19:16:54 -0800 (PST)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id u29si9571191ioi.124.2015.12.08.19.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 19:16:54 -0800 (PST)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id E9973AC0186
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 12:16:47 +0900 (JST)
From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 1/2] mm: Calculate zone_start_pfn at zone_spanned_pages_in_node()
Date: Wed,  9 Dec 2015 12:19:21 +0900
Message-Id: <1449631161-14822-1-git-send-email-izumi.taku@jp.fujitsu.com>
In-Reply-To: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, dave.hansen@intel.com, matt@codeblueprint.co.uk, Taku Izumi <izumi.taku@jp.fujitsu.com>

Currently each zone's zone_start_pfn is calculated at
free_area_init_core(). However zone's range is fixed at
the time when invoking zone_spanned_pages_in_node().

This patch changes each zone->zone_start_pfn is
calculated at zone_spanned_pages_in_node().

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 mm/page_alloc.c | 30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 17a3c66..acb0b4e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4928,31 +4928,31 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
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
@@ -5017,6 +5017,8 @@ static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
 					unsigned long node_start_pfn,
 					unsigned long node_end_pfn,
+					unsigned long *zone_start_pfn,
+					unsigned long *zone_end_pfn,
 					unsigned long *zones_size)
 {
 	return zones_size[zone_type];
@@ -5047,15 +5049,22 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
 
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
 
@@ -5176,7 +5185,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
-	unsigned long zone_start_pfn = pgdat->node_start_pfn;
 	int ret;
 
 	pgdat_resize_init(pgdat);
@@ -5192,6 +5200,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, freesize, memmap_pages;
+		unsigned long zone_start_pfn = zone->zone_start_pfn;
 
 		size = zone->spanned_pages;
 		realsize = freesize = zone->present_pages;
@@ -5260,7 +5269,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		ret = init_currently_empty_zone(zone, zone_start_pfn, size);
 		BUG_ON(ret);
 		memmap_init(size, nid, j, zone_start_pfn);
-		zone_start_pfn += size;
 	}
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

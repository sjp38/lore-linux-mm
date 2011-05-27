Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 85F5390010C
	for <linux-mm@kvack.org>; Fri, 27 May 2011 08:32:07 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp02.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4RCW0Xe010712
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RCVrZX2826404
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RCVq0i003624
	for <linux-mm@kvack.org>; Fri, 27 May 2011 22:31:52 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 05/10] mm: Create zonelists
Date: Fri, 27 May 2011 18:01:33 +0530
Message-Id: <1306499498-14263-6-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

The default zonelist that is node ordered contains all zones from within a
node and then all zones from the next node and so on. By introducing memory
regions, the primary aim is to group memory allocations to a given area of
memory together. The modified zonelists thus contain all zones from one
region, followed by all zones from the next region and so on. This ensures
that all the memory in one region is allocated before going over to the next
region, unless targetted memory allocations are performed.

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 mm/page_alloc.c |   62 +++++++++++++++++++++++++++++++++---------------------
 1 files changed, 38 insertions(+), 24 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3c48635..da8b045 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2668,20 +2668,26 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
 				int nr_zones, enum zone_type zone_type)
 {
 	struct zone *zone;
+	int nid = pgdat->node_id;
+	int i;
+	enum zone_type z_type = zone_type;
 
 	BUG_ON(zone_type >= MAX_NR_ZONES);
 	zone_type++;
 
-	do {
-		zone_type--;
-		zone = pgdat->node_zones + zone_type;
-		if (populated_zone(zone)) {
-			zoneref_set_zone(zone,
-				&zonelist->_zonerefs[nr_zones++]);
-			check_highest_zone(zone_type);
-		}
-
-	} while (zone_type);
+	for_each_mem_region_in_nid(i, nid) {
+		mem_region_t *mem_region = &pgdat->mem_regions[i];
+		do {
+			zone_type--;
+			zone = mem_region->zones + zone_type;
+			if (populated_zone(zone)) {
+				zoneref_set_zone(zone,
+					&zonelist->_zonerefs[nr_zones++]);
+				check_highest_zone(zone_type);
+			}
+		} while (zone_type);
+		zone_type = z_type + 1;
+	}
 	return nr_zones;
 }
 
@@ -2898,7 +2904,7 @@ static int node_order[MAX_NUMNODES];
 
 static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 {
-	int pos, j, node;
+	int pos, j, node, p;
 	int zone_type;		/* needs to be signed */
 	struct zone *z;
 	struct zonelist *zonelist;
@@ -2922,7 +2928,7 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 
 static int default_zonelist_order(void)
 {
-	int nid, zone_type;
+	int nid, zone_type, i;
 	unsigned long low_kmem_size,total_size;
 	struct zone *z;
 	int average_size;
@@ -2937,12 +2943,16 @@ static int default_zonelist_order(void)
 	total_size = 0;
 	for_each_online_node(nid) {
 		for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
-			z = &NODE_DATA(nid)->node_zones[zone_type];
-			if (populated_zone(z)) {
-				if (zone_type < ZONE_NORMAL)
-					low_kmem_size += z->present_pages;
-				total_size += z->present_pages;
-			} else if (zone_type == ZONE_NORMAL) {
+			for_each_mem_region_in_nid(i, nid) {
+				mem_region_t *mem_region = &(NODE_DATA(nid)->mem_regions[i]);
+				z = &mem_region->zones[zone_type];
+				if (populated_zone(z)) {
+					if (zone_type < ZONE_NORMAL)
+						low_kmem_size +=
+							z->present_pages;
+
+					total_size += z->present_pages;
+				} else if (zone_type == ZONE_NORMAL) {
 				/*
 				 * If any node has only lowmem, then node order
 				 * is preferred to allow kernel allocations
@@ -2950,7 +2960,8 @@ static int default_zonelist_order(void)
 				 * on other nodes when there is an abundance of
 				 * lowmem available to allocate from.
 				 */
-				return ZONELIST_ORDER_NODE;
+					return ZONELIST_ORDER_NODE;
+				}
 			}
 		}
 	}
@@ -2968,11 +2979,14 @@ static int default_zonelist_order(void)
 		low_kmem_size = 0;
 		total_size = 0;
 		for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
-			z = &NODE_DATA(nid)->node_zones[zone_type];
-			if (populated_zone(z)) {
-				if (zone_type < ZONE_NORMAL)
-					low_kmem_size += z->present_pages;
-				total_size += z->present_pages;
+			for_each_mem_region_in_nid(i, nid) {
+				mem_region_t *mem_region = &(NODE_DATA(nid)->mem_regions[i]);
+				z = &mem_region->zones[zone_type];
+				if (populated_zone(z)) {
+					if (zone_type < ZONE_NORMAL)
+						low_kmem_size += z->present_pages;
+					total_size += z->present_pages;
+				}
 			}
 		}
 		if (low_kmem_size &&
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

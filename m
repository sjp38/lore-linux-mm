Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 8252B6B0068
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:42:11 -0500 (EST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 01:12:03 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6Jg06M6619218
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 01:12:00 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA71BoXj026843
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 12:11:51 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 05/10] mm: Create zonelists
Date: Wed, 07 Nov 2012 01:10:56 +0530
Message-ID: <20121106194052.6560.36457.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
References: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Ankita Garg <gargankita@gmail.com>

The default zonelist that is node ordered contains all zones from within a
node and then all zones from the next node and so on. By introducing memory
regions, the primary aim is to group memory allocations to a given area of
memory together. The modified zonelists thus contain all zones from one
region, followed by all zones from the next region and so on. This ensures
that all the memory in one region is allocated before going over to the next
region, unless targetted memory allocations are performed.

Signed-off-by: Ankita Garg <gargankita@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   69 +++++++++++++++++++++++++++++++++----------------------
 1 file changed, 42 insertions(+), 27 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a8e86b5..9c1d680 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3040,21 +3040,25 @@ static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
 static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
 				int nr_zones, enum zone_type zone_type)
 {
+	enum zone_type z_type = zone_type;
+	struct mem_region *region;
 	struct zone *zone;
 
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
+	for_each_mem_region_in_node(region, pgdat->node_id) {
+		do {
+			zone_type--;
+			zone = region->region_zones + zone_type;
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
 
@@ -3275,17 +3279,20 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 	int zone_type;		/* needs to be signed */
 	struct zone *z;
 	struct zonelist *zonelist;
+	struct mem_region *region;
 
 	zonelist = &pgdat->node_zonelists[0];
 	pos = 0;
 	for (zone_type = MAX_NR_ZONES - 1; zone_type >= 0; zone_type--) {
 		for (j = 0; j < nr_nodes; j++) {
 			node = node_order[j];
-			z = &NODE_DATA(node)->node_zones[zone_type];
-			if (populated_zone(z)) {
-				zoneref_set_zone(z,
-					&zonelist->_zonerefs[pos++]);
-				check_highest_zone(zone_type);
+			for_each_mem_region_in_node(region, node) {
+				z = &region->region_zones[zone_type];
+				if (populated_zone(z)) {
+					zoneref_set_zone(z,
+						&zonelist->_zonerefs[pos++]);
+					check_highest_zone(zone_type);
+				}
 			}
 		}
 	}
@@ -3299,6 +3306,8 @@ static int default_zonelist_order(void)
 	unsigned long low_kmem_size,total_size;
 	struct zone *z;
 	int average_size;
+	struct mem_region *region;
+
 	/*
          * ZONE_DMA and ZONE_DMA32 can be very small area in the system.
 	 * If they are really small and used heavily, the system can fall
@@ -3310,12 +3319,15 @@ static int default_zonelist_order(void)
 	total_size = 0;
 	for_each_online_node(nid) {
 		for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
-			z = &NODE_DATA(nid)->node_zones[zone_type];
-			if (populated_zone(z)) {
-				if (zone_type < ZONE_NORMAL)
-					low_kmem_size += z->present_pages;
-				total_size += z->present_pages;
-			} else if (zone_type == ZONE_NORMAL) {
+			for_each_mem_region_in_node(region, nid) {
+				z = &region->region_zones[zone_type];
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
@@ -3323,7 +3335,8 @@ static int default_zonelist_order(void)
 				 * on other nodes when there is an abundance of
 				 * lowmem available to allocate from.
 				 */
-				return ZONELIST_ORDER_NODE;
+					return ZONELIST_ORDER_NODE;
+				}
 			}
 		}
 	}
@@ -3341,11 +3354,13 @@ static int default_zonelist_order(void)
 		low_kmem_size = 0;
 		total_size = 0;
 		for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
-			z = &NODE_DATA(nid)->node_zones[zone_type];
-			if (populated_zone(z)) {
-				if (zone_type < ZONE_NORMAL)
-					low_kmem_size += z->present_pages;
-				total_size += z->present_pages;
+			for_each_mem_region_in_node(region, nid) {
+				z = &region->region_zones[zone_type];
+				if (populated_zone(z)) {
+					if (zone_type < ZONE_NORMAL)
+						low_kmem_size += z->present_pages;
+					total_size += z->present_pages;
+				}
 			}
 		}
 		if (low_kmem_size &&

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 428BE6B0025
	for <linux-mm@kvack.org>; Fri, 27 May 2011 08:32:06 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4RCW0Tn029023
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RCVr6R3084512
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RCVqUv003644
	for <linux-mm@kvack.org>; Fri, 27 May 2011 22:31:53 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 06/10] mm: Verify zonelists
Date: Fri, 27 May 2011 18:01:34 +0530
Message-Id: <1306499498-14263-7-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

Verify that the zonelists were created appropriately. Below is the output in
the dmesg for the verification of creation of zonelists. 4 regions, each of
size 512MB were created on the Samsung Orion/Exynos board (board has 2G RAM).

The regions were created as follows:

created region 0 in nid 0 start pfn 262144 spanned pages 131072
created region 1 in nid 0 start pfn 393216 spanned pages 131072
created region 2 in nid 0 start pfn 524288 spanned pages 131072
created region 3 in nid 0 start pfn 655360 spanned pages 57344

mminit::zonelist general 0:Normal = 0:Normal 0:Normal 0:Normal 0:Normal
mminit::zonelist general 0:Normal = 0:Normal 0:Normal 0:Normal 0:Normal
mminit::zonelist general 0:Normal = 0:Normal 0:Normal 0:Normal 0:Normal
mminit::zonelist general 0:Normal = 0:Normal 0:Normal 0:Normal 0:Normal

Since now 4 zones are present inside a node, the above shows 4 zonelists
being created.

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 mm/mm_init.c |   51 +++++++++++++++++++++++++++------------------------
 1 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/mm/mm_init.c b/mm/mm_init.c
index 4e0e265..77468f8 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -21,44 +21,47 @@ int mminit_loglevel;
 /* The zonelists are simply reported, validation is manual. */
 void mminit_verify_zonelist(void)
 {
-	int nid;
+	int nid, p;
 
 	if (mminit_loglevel < MMINIT_VERIFY)
 		return;
 
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
-		struct zone *zone;
-		struct zoneref *z;
-		struct zonelist *zonelist;
-		int i, listid, zoneid;
-
-		BUG_ON(MAX_ZONELISTS > 2);
-		for (i = 0; i < MAX_ZONELISTS * MAX_NR_ZONES; i++) {
-
-			/* Identify the zone and nodelist */
-			zoneid = i % MAX_NR_ZONES;
-			listid = i / MAX_NR_ZONES;
-			zonelist = &pgdat->node_zonelists[listid];
-			zone = &pgdat->node_zones[zoneid];
-			if (!populated_zone(zone))
-				continue;
-
-			/* Print information about the zonelist */
-			printk(KERN_DEBUG "mminit::zonelist %s %d:%s = ",
-				listid > 0 ? "thisnode" : "general", nid,
-				zone->name);
-
-			/* Iterate the zonelist */
-			for_each_zone_zonelist(zone, z, zonelist, zoneid) {
+		for_each_mem_region_in_nid(p, nid) {
+			mem_region_t *mem_region = &(NODE_DATA(nid)->mem_regions[p]);
+			struct zone *zone;
+			struct zoneref *z;
+			struct zonelist *zonelist;
+			int i, listid, zoneid;
+
+			BUG_ON(MAX_ZONELISTS > 2);
+			for (i = 0; i < MAX_ZONELISTS * MAX_NR_ZONES; i++) {
+
+				/* Identify the zone and nodelist */
+				zoneid = i % MAX_NR_ZONES;
+				listid = i / MAX_NR_ZONES;
+				zonelist = &pgdat->node_zonelists[listid];
+				zone = &mem_region->zones[zoneid];
+				if (!populated_zone(zone))
+					continue;
+
+				/* Print information about the zonelist */
+				printk(KERN_DEBUG "mminit::zonelist %s %d:%s = ",
+					listid > 0 ? "thisnode" : "general", nid,
+					zone->name);
+
+				/* Iterate the zonelist */
+				for_each_zone_zonelist(zone, z, zonelist, zoneid) {
 #ifdef CONFIG_NUMA
-				printk(KERN_CONT "%d:%s ",
-					zone->node, zone->name);
+					printk(KERN_CONT "%d:%s ",
+						zone->node, zone->name);
 #else
-				printk(KERN_CONT "0:%s ", zone->name);
+					printk(KERN_CONT "0:%s ", zone->name);
 #endif /* CONFIG_NUMA */
+				}
+				printk(KERN_CONT "\n");
 			}
-			printk(KERN_CONT "\n");
 		}
 	}
 }
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

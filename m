Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 9DC396B006C
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:42:20 -0500 (EST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 05:39:11 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JgFgr64684084
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:42:15 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6JgEme019441
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:42:15 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 06/10] mm: Verify zonelists
Date: Wed, 07 Nov 2012 01:11:08 +0530
Message-ID: <20121106194104.6560.48366.stgit@srivatsabhat.in.ibm.com>
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

Verify that the zonelists were created appropriately.

Signed-off-by: Ankita Garg <gargankita@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/mm_init.c |   57 ++++++++++++++++++++++++++++++---------------------------
 1 file changed, 30 insertions(+), 27 deletions(-)

diff --git a/mm/mm_init.c b/mm/mm_init.c
index 1ffd97a..5c19842 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -21,6 +21,7 @@ int mminit_loglevel;
 /* The zonelists are simply reported, validation is manual. */
 void mminit_verify_zonelist(void)
 {
+	struct mem_region *region;
 	int nid;
 
 	if (mminit_loglevel < MMINIT_VERIFY)
@@ -28,37 +29,39 @@ void mminit_verify_zonelist(void)
 
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
+		for_each_mem_region_in_node(region, nid) {
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
+				zone = &region->region_zones[zoneid];
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

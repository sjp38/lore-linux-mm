From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080422183253.13750.74985.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080422183133.13750.57133.sendpatchset@skynet.skynet.ie>
References: <20080422183133.13750.57133.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/4] Print out the zonelists on request for manual verification
Date: Tue, 22 Apr 2008 19:32:53 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, mingo@elte.hu, linux-kernel@vger.kernel.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch prints out the zonelists during boot for manual verification by
the user if the mminit_loglevel is MMINIT_VERIFY or higher. This is useful
for checking if the zonelists were somehow corrupt during initialisation.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 mm/internal.h   |    5 +++++
 mm/mm_init.c    |   45 +++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c |    1 +
 3 files changed, 51 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/internal.h linux-2.6.25-mm1-0030_display_zonelist/mm/internal.h
--- linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/internal.h	2008-04-22 17:49:48.000000000 +0100
+++ linux-2.6.25-mm1-0030_display_zonelist/mm/internal.h	2008-04-22 17:50:06.000000000 +0100
@@ -80,6 +80,7 @@ do { \
 extern void mminit_verify_pageflags(void);
 extern void mminit_verify_page_links(struct page *page,
 		enum zone_type zone, unsigned long nid, unsigned long pfn);
+extern void mminit_verify_zonelist(void);
 
 #else
 
@@ -96,6 +97,10 @@ static inline void mminit_verify_page_li
 		enum zone_type zone, unsigned long nid, unsigned long pfn)
 {
 }
+
+static inline void mminit_verify_zonelist(void)
+{
+}
 #endif /* CONFIG_DEBUG_MEMORY_INIT */
 
 /* mminit_validate_physlimits is independent of CONFIG_DEBUG_MEMORY_INIT */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/mm_init.c linux-2.6.25-mm1-0030_display_zonelist/mm/mm_init.c
--- linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/mm_init.c	2008-04-22 17:49:33.000000000 +0100
+++ linux-2.6.25-mm1-0030_display_zonelist/mm/mm_init.c	2008-04-22 17:50:06.000000000 +0100
@@ -11,6 +11,51 @@
 
 int __meminitdata mminit_loglevel;
 
+/* Note that the verification of correctness is required from the user */
+void mminit_verify_zonelist(void)
+{
+	int nid;
+
+	if (mminit_loglevel < MMINIT_VERIFY)
+		return;
+
+	for_each_online_node(nid) {
+		pg_data_t *pgdat = NODE_DATA(nid);
+		struct zone *zone;
+		struct zoneref *z;
+		struct zonelist *zonelist;
+		int i, listid, zoneid;
+
+		BUG_ON(MAX_ZONELISTS > 2);
+		for (i = 0; i < MAX_ZONELISTS * MAX_NR_ZONES; i++) {
+
+			/* Identify the zone and nodelist */
+			zoneid = i % MAX_NR_ZONES;
+			listid = i / MAX_NR_ZONES;
+			zonelist = &pgdat->node_zonelists[listid];
+			zone = &pgdat->node_zones[zoneid];
+			if (!populated_zone(zone))
+				continue;
+
+			/* Print information about the zonelist */
+			printk(KERN_DEBUG "mminit::zonelist %s %d:%s = ",
+				listid > 0 ? "thisnode" : "general", nid,
+				zone->name);
+
+			/* Iterate the zonelist */
+			for_each_zone_zonelist(zone, z, zonelist, zoneid) {
+#ifdef CONFIG_NUMA
+				printk(KERN_CONT "%d:%s ",
+						zone->node, zone->name);
+#else
+				printk(KERN_CONT "0:%s ", zone->name);
+#endif
+			}
+			printk(KERN_CONT "\n");
+		}
+	}
+}
+
 void __init mminit_verify_pageflags(void)
 {
 	int shift, width;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/page_alloc.c linux-2.6.25-mm1-0030_display_zonelist/mm/page_alloc.c
--- linux-2.6.25-mm1-0025_defensive_pfn_checks/mm/page_alloc.c	2008-04-22 17:49:48.000000000 +0100
+++ linux-2.6.25-mm1-0030_display_zonelist/mm/page_alloc.c	2008-04-22 17:50:06.000000000 +0100
@@ -2456,6 +2456,7 @@ void build_all_zonelists(void)
 
 	if (system_state == SYSTEM_BOOTING) {
 		__build_all_zonelists(NULL);
+		mminit_verify_zonelist();
 		cpuset_init_current_mems_allowed();
 	} else {
 		/* we have to stop all cpus to guarantee there is no user

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

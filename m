From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080417000744.18399.84537.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080417000624.18399.35041.sendpatchset@skynet.skynet.ie>
References: <20080417000624.18399.35041.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/4] Print out the zonelists on request for manual verification
Date: Thu, 17 Apr 2008 01:07:44 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, mingo@elte.hu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch prints out the zonelists during boot for manual verification
by the user. This is useful for checking if the zonelists were somehow
corrupt during initialisation. Note that this patch will not work in -mm
due to differences in how zonelists are used.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 mm/internal.h   |    5 +++++
 mm/mm_init.c    |   40 ++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c |    1 +
 3 files changed, 46 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0025_defensive_pfn_checks/mm/internal.h linux-2.6.25-rc9-0030_display_zonelist/mm/internal.h
--- linux-2.6.25-rc9-0025_defensive_pfn_checks/mm/internal.h	2008-04-17 00:20:47.000000000 +0100
+++ linux-2.6.25-rc9-0030_display_zonelist/mm/internal.h	2008-04-17 00:21:07.000000000 +0100
@@ -81,6 +81,7 @@ do { \
 extern void mminit_verify_pageflags(void);
 extern void mminit_verify_page_links(struct page *page,
 		enum zone_type zone, unsigned long nid, unsigned long pfn);
+extern void mminit_verify_zonelist(void);
 
 #else
 
@@ -97,6 +98,10 @@ static inline void mminit_verify_page_li
 		enum zone_type zone, unsigned long nid, unsigned long pfn)
 {
 }
+
+static inline void mminit_verify_zonelist(void)
+{
+}
 #endif /* CONFIG_DEBUG_MEMORY_INIT */
 
 /* mminit_validate_physlimits is independent of CONFIG_DEBUG_MEMORY_INIT */
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0025_defensive_pfn_checks/mm/mm_init.c linux-2.6.25-rc9-0030_display_zonelist/mm/mm_init.c
--- linux-2.6.25-rc9-0025_defensive_pfn_checks/mm/mm_init.c	2008-04-17 00:20:33.000000000 +0100
+++ linux-2.6.25-rc9-0030_display_zonelist/mm/mm_init.c	2008-04-17 00:21:07.000000000 +0100
@@ -11,6 +11,46 @@
 
 int __initdata mminit_debug_level;
 
+/* Note that the verification of correctness is required from the user */
+void mminit_verify_zonelist(void)
+{
+	int nid;
+
+	if (mminit_debug_level < MMINIT_VERIFY)
+		return;
+
+	for_each_online_node(nid) {
+		pg_data_t *pgdat = NODE_DATA(nid);
+		struct zone *zone;
+		struct zone **z;
+		int listid;
+
+		for (listid = 0; listid < MAX_ZONELISTS; listid++) {
+			zone = &pgdat->node_zones[listid % MAX_NR_ZONES];
+
+			if (!populated_zone(zone))
+				continue;
+
+			printk(KERN_INFO "mminit::zonelist %s %d:%s = ",
+				listid >= MAX_NR_ZONES ? "thisnode" : "general",
+				nid,
+				zone->name);
+			z = pgdat->node_zonelists[listid].zones;
+
+			while (*z != NULL) {
+#ifdef CONFIG_NUMA
+				printk(KERN_CONT "%d:%s ",
+						(*z)->node, (*z)->name);
+#else
+				printk(KERN_CONT "0:%s ", (*z)->name);
+#endif
+				z++;
+			}
+			printk(KERN_CONT "\n");
+		}
+	}
+}
+
 void __init mminit_verify_pageflags(void)
 {
 	unsigned long shift;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0025_defensive_pfn_checks/mm/page_alloc.c linux-2.6.25-rc9-0030_display_zonelist/mm/page_alloc.c
--- linux-2.6.25-rc9-0025_defensive_pfn_checks/mm/page_alloc.c	2008-04-17 00:20:47.000000000 +0100
+++ linux-2.6.25-rc9-0030_display_zonelist/mm/page_alloc.c	2008-04-17 00:21:07.000000000 +0100
@@ -2353,6 +2353,7 @@ void build_all_zonelists(void)
 
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

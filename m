From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080416135158.1346.11416.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
References: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 3/4] Print out the zonelists on request for manual verification
Date: Wed, 16 Apr 2008 14:51:58 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, mingo@elte.hu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch prints out the zonelists during boot for manual verification by
the user. This is useful for checking if the zonelists were somehow corrupt
during initialisation.

Note that this patch will not work in -mm due to differences in how zonelists
are used. This is specific to how 2.6.25-rc9 works but a similar version for -mm
would be straight-forward enough.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 mm/internal.h   |    1 +
 mm/mm_init.c    |   40 ++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c |    1 +
 3 files changed, 42 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0020_memmap_init_debug/mm/internal.h linux-2.6.25-rc9-0030_display_zonelist/mm/internal.h
--- linux-2.6.25-rc9-0020_memmap_init_debug/mm/internal.h	2008-04-16 14:44:32.000000000 +0100
+++ linux-2.6.25-rc9-0030_display_zonelist/mm/internal.h	2008-04-16 14:44:46.000000000 +0100
@@ -67,6 +67,7 @@ enum mminit_levels {
 	MMINIT_TRACE
 };
 
+extern void mminit_verify_zonelist(void);
 extern void mminit_verify_pageflags(void);
 extern void mminit_verify_page_links(struct page *page, enum zone_type zone,
 				unsigned long nid, unsigned long pfn);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0020_memmap_init_debug/mm/mm_init.c linux-2.6.25-rc9-0030_display_zonelist/mm/mm_init.c
--- linux-2.6.25-rc9-0020_memmap_init_debug/mm/mm_init.c	2008-04-16 14:44:32.000000000 +0100
+++ linux-2.6.25-rc9-0030_display_zonelist/mm/mm_init.c	2008-04-16 14:44:46.000000000 +0100
@@ -10,6 +10,46 @@ int __initdata mminit_debug_level;
 
 #define MMINIT_BUF_LEN 256
 
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
+		int zoneid;
+
+		for (zoneid = 0; zoneid < MAX_ZONELISTS; zoneid++) {
+			zone = &pgdat->node_zones[zoneid];
+
+			if (!populated_zone(zone))
+				continue;
+
+			printk(KERN_INFO "Zonelist %s %d:%s = ",
+				zoneid >= MAX_NR_ZONES ? "thisnode" : "general",
+				nid,
+				zone->name);
+			z = pgdat->node_zonelists[zoneid].zones;
+
+			while (*z != NULL) {
+#ifdef CONFIG_NUMA
+				printk(KERN_INFO "%d:%s ",
+						(*z)->node, (*z)->name);
+#else
+				printk(KERN_INFO "0:%s ", (*z)->name);
+#endif
+				z++;
+			}
+			printk(KERN_INFO "\n");
+		}
+	}
+}
+
 void __init mminit_verify_pageflags(void)
 {
 	unsigned long shift = 0;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0020_memmap_init_debug/mm/page_alloc.c linux-2.6.25-rc9-0030_display_zonelist/mm/page_alloc.c
--- linux-2.6.25-rc9-0020_memmap_init_debug/mm/page_alloc.c	2008-04-16 14:44:32.000000000 +0100
+++ linux-2.6.25-rc9-0030_display_zonelist/mm/page_alloc.c	2008-04-16 14:44:46.000000000 +0100
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

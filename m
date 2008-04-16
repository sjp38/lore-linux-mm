From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080416135138.1346.87095.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
References: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/4] Verify the page links and memory model
Date: Wed, 16 Apr 2008 14:51:38 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>, mingo@elte.hu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch prints out information on how the page flags are being used and
verifies they are correct if mminit_debug_level is MMINIT_VERIFY or higher.
When the page flags are updated with section, node and zone information, an
additional check is made to ensure the values can be retrieved correctly. The
final check made with respect to pages is that pfn_to_page() and page_to_pfn()
are returning sensible values.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 mm/internal.h   |    3 ++
 mm/mm_init.c    |   65 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 mm/page_alloc.c |    6 ++++
 3 files changed, 73 insertions(+), 1 deletion(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0010_mminit_debug_framework/mm/internal.h linux-2.6.25-rc9-0020_memmap_init_debug/mm/internal.h
--- linux-2.6.25-rc9-0010_mminit_debug_framework/mm/internal.h	2008-04-16 14:44:19.000000000 +0100
+++ linux-2.6.25-rc9-0020_memmap_init_debug/mm/internal.h	2008-04-16 14:44:32.000000000 +0100
@@ -67,6 +67,9 @@ enum mminit_levels {
 	MMINIT_TRACE
 };
 
+extern void mminit_verify_pageflags(void);
+extern void mminit_verify_page_links(struct page *page, enum zone_type zone,
+				unsigned long nid, unsigned long pfn);
 extern void mminit_debug_printk(unsigned int level, const char *prefix,
 				const char *fmt, ...);
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0010_mminit_debug_framework/mm/mm_init.c linux-2.6.25-rc9-0020_memmap_init_debug/mm/mm_init.c
--- linux-2.6.25-rc9-0010_mminit_debug_framework/mm/mm_init.c	2008-04-16 14:44:19.000000000 +0100
+++ linux-2.6.25-rc9-0020_memmap_init_debug/mm/mm_init.c	2008-04-16 14:44:32.000000000 +0100
@@ -4,11 +4,74 @@
  */
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include "internal.h"
 
 int __initdata mminit_debug_level;
 
 #define MMINIT_BUF_LEN 256
 
+void __init mminit_verify_pageflags(void)
+{
+	unsigned long shift = 0;
+	if (mminit_debug_level < MMINIT_VERIFY)
+		return;
+
+	mminit_debug_printk(MMINIT_TRACE, "pageflags_layout_widths",
+		"Section %d Node %d Zone %d Reserved %d\n",
+		SECTIONS_WIDTH,
+		NODES_WIDTH,
+		ZONES_WIDTH,
+		FLAGS_RESERVED);
+	mminit_debug_printk(MMINIT_TRACE, "pageflags_layout_shifts",
+		"Section %d Node %d Zone %d\n",
+#ifdef SECTION_SHIFT
+		SECTIONS_SHIFT,
+#else
+		0,
+#endif
+		NODES_SHIFT,
+		ZONES_SHIFT,
+		ZONEID_SHIFT);
+	mminit_debug_printk(MMINIT_TRACE, "pageflags_layout_offsets",
+		"Section %d Node %d Zone %d\n",
+		SECTIONS_PGSHIFT,
+		NODES_PGSHIFT,
+		ZONES_PGSHIFT);
+	mminit_debug_printk(MMINIT_TRACE, "pageflags_layout_zoneid",
+		"Zone ID: %d -> %d\n",
+		ZONEID_PGOFF, ZONEID_PGOFF + ZONEID_SHIFT);
+#ifdef NODE_NOT_IN_PAGE_FLAGS
+	mminit_debug_printk(MMINIT_TRACE, "pageflags_layout_nodeflags",
+		"Node not in page flags");
+#endif
+
+	shift = 8 * sizeof(unsigned long);
+	if (SECTIONS_WIDTH) {
+		shift -= SECTIONS_WIDTH;
+		BUG_ON(shift != SECTIONS_PGSHIFT);
+	}
+	if (NODES_WIDTH) {
+		shift -= NODES_WIDTH;
+		BUG_ON(shift != NODES_PGSHIFT);
+	}
+	if (ZONES_WIDTH) {
+		shift -= ZONES_WIDTH;
+		BUG_ON(shift != ZONES_PGSHIFT);
+	}
+	BUG_ON(ZONES_MASK & NODES_MASK & SECTIONS_MASK);
+}
+
+void __meminit mminit_verify_page_links(struct page *page, enum zone_type zone,
+			unsigned long nid, unsigned long pfn)
+{
+	if (mminit_debug_level < MMINIT_VERIFY)
+		return;
+
+	BUG_ON(page_to_nid(page) != nid);
+	BUG_ON(page_zone_id(page) != zone);
+	BUG_ON(page_to_pfn(page) != pfn);
+}
+
 void __meminit mminit_debug_printk(unsigned int level, const char *prefix,
 			const char *fmt, ...)
 {
@@ -28,7 +91,7 @@ void __meminit mminit_debug_printk(unsig
 		printk(s);
 
 		WARN_ON(len < 5);
-		WARN_ON(len == MMINIT_BUF_LEN);
+		WARN_ON(len > MMINIT_BUF_LEN);
 	}
 }
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc9-0010_mminit_debug_framework/mm/page_alloc.c linux-2.6.25-rc9-0020_memmap_init_debug/mm/page_alloc.c
--- linux-2.6.25-rc9-0010_mminit_debug_framework/mm/page_alloc.c	2008-04-16 14:44:19.000000000 +0100
+++ linux-2.6.25-rc9-0020_memmap_init_debug/mm/page_alloc.c	2008-04-16 14:44:32.000000000 +0100
@@ -2533,6 +2533,7 @@ void __meminit memmap_init_zone(unsigned
 		}
 		page = pfn_to_page(pfn);
 		set_page_links(page, zone, nid, pfn);
+		mminit_verify_page_links(page, zone, nid, pfn);
 		init_page_count(page);
 		reset_page_mapcount(page);
 		SetPageReserved(page);
@@ -2829,6 +2830,10 @@ __meminit int init_currently_empty_zone(
 
 	zone->zone_start_pfn = zone_start_pfn;
 
+	mminit_debug_printk(MMINIT_TRACE, "memmap_init",
+			"Initialising map node %d zone %d pfns %lu -> %lu\n",
+			pgdat->node_id, zone_idx(zone),
+			zone_start_pfn, (zone_start_pfn + size));
 	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);
 
 	zone_init_free_lists(zone);
@@ -3896,6 +3901,7 @@ void __init free_area_init_nodes(unsigne
 						early_node_map[i].end_pfn);
 
 	/* Initialise every node */
+	mminit_verify_pageflags();
 	setup_nr_node_ids();
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

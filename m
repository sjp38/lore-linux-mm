From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080428192919.23649.23282.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080428192839.23649.82172.sendpatchset@skynet.skynet.ie>
References: <20080428192839.23649.82172.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/4] Verify the page links and memory model
Date: Mon, 28 Apr 2008 20:29:19 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, mingo@elte.hu, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch prints out information on how the page flags are being used if
mminit_loglevel is MMINIT_VERIFY or higher and unconditionally performs
sanity checks on the flags regardless of loglevel. When the page flags are
updated with section, node and zone information, a check are made to ensure
the values can be retrieved correctly. Finally we confirm that pfn_to_page
and page_to_pfn are the correct inverse functions.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 mm/internal.h   |   12 ++++++++
 mm/mm_init.c    |   70 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c |    6 ++++
 3 files changed, 88 insertions(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0010_mminit_debug_framework/mm/internal.h linux-2.6.25-mm1-0020_memmap_init_debug/mm/internal.h
--- linux-2.6.25-mm1-0010_mminit_debug_framework/mm/internal.h	2008-04-28 14:39:59.000000000 +0100
+++ linux-2.6.25-mm1-0020_memmap_init_debug/mm/internal.h	2008-04-28 14:41:48.000000000 +0100
@@ -78,6 +78,10 @@ do { \
 	} \
 } while (0)
 
+extern void mminit_verify_pageflags_layout(void);
+extern void mminit_verify_page_links(struct page *page,
+		enum zone_type zone, unsigned long nid, unsigned long pfn);
+
 #else
 
 static inline void mminit_dprintk(enum mminit_level level,
@@ -85,5 +89,13 @@ static inline void mminit_dprintk(unsign
 {
 }
 
+static inline void mminit_verify_pageflags_layout(void)
+{
+}
+
+static inline void mminit_verify_page_links(struct page *page,
+		enum zone_type zone, unsigned long nid, unsigned long pfn)
+{
+}
 #endif /* CONFIG_DEBUG_MEMORY_INIT */
 #endif
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0010_mminit_debug_framework/mm/mm_init.c linux-2.6.25-mm1-0020_memmap_init_debug/mm/mm_init.c
--- linux-2.6.25-mm1-0010_mminit_debug_framework/mm/mm_init.c	2008-04-28 14:39:59.000000000 +0100
+++ linux-2.6.25-mm1-0020_memmap_init_debug/mm/mm_init.c	2008-04-28 14:41:48.000000000 +0100
@@ -7,9 +7,79 @@
  */
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include "internal.h"
 
 int __meminitdata mminit_loglevel;
 
+void __init mminit_verify_pageflags_layout(void)
+{
+	int shift, width;
+	unsigned long or_mask, add_mask;
+
+	shift = 8 * sizeof(unsigned long);
+	width = shift - SECTIONS_WIDTH - NODES_WIDTH - ZONES_WIDTH;
+	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_widths",
+		"Section %d Node %d Zone %d Flags %d\n",
+		SECTIONS_WIDTH,
+		NODES_WIDTH,
+		ZONES_WIDTH,
+		NR_PAGEFLAGS);
+	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_shifts",
+		"Section %d Node %d Zone %d\n",
+#ifdef SECTIONS_SHIFT
+		SECTIONS_SHIFT,
+#else
+		0,
+#endif
+		NODES_SHIFT,
+		ZONES_SHIFT);
+	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_offsets",
+		"Section %d Node %d Zone %d\n",
+		SECTIONS_PGSHIFT,
+		NODES_PGSHIFT,
+		ZONES_PGSHIFT);
+	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_zoneid",
+		"Zone ID: %d -> %d\n",
+		ZONEID_PGOFF, ZONEID_PGOFF + ZONEID_SHIFT);
+	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_usage",
+		"location: %d -> %d unused %d -> %d flags %d -> %d\n",
+		shift, width, width, NR_PAGEFLAGS, NR_PAGEFLAGS, 0);
+#ifdef NODE_NOT_IN_PAGE_FLAGS
+	mminit_dprintk(MMINIT_TRACE, "pageflags_layout_nodeflags",
+		"Node not in page flags");
+#endif
+
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
+
+	/* Check for bitmask overlaps */
+	or_mask = (ZONES_MASK << ZONES_PGSHIFT) |
+			(NODES_MASK << NODES_PGSHIFT) |
+			(SECTIONS_MASK << SECTIONS_PGSHIFT);
+	add_mask = (ZONES_MASK << ZONES_PGSHIFT) +
+			(NODES_MASK << NODES_PGSHIFT) +
+			(SECTIONS_MASK << SECTIONS_PGSHIFT);
+	BUG_ON(or_mask != add_mask);
+}
+
+void __meminit mminit_verify_page_links(struct page *page, enum zone_type zone,
+			unsigned long nid, unsigned long pfn)
+{
+	BUG_ON(page_to_nid(page) != nid);
+	BUG_ON(page_zonenum(page) != zone);
+	BUG_ON(page_to_pfn(page) != pfn);
+}
+
 static __init int set_mminit_loglevel(char *str)
 {
 	get_option(&str, &mminit_loglevel);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-0010_mminit_debug_framework/mm/page_alloc.c linux-2.6.25-mm1-0020_memmap_init_debug/mm/page_alloc.c
--- linux-2.6.25-mm1-0010_mminit_debug_framework/mm/page_alloc.c	2008-04-28 14:39:59.000000000 +0100
+++ linux-2.6.25-mm1-0020_memmap_init_debug/mm/page_alloc.c	2008-04-28 14:41:48.000000000 +0100
@@ -2637,6 +2637,7 @@ void __meminit memmap_init_zone(unsigned
 		}
 		page = pfn_to_page(pfn);
 		set_page_links(page, zone, nid, pfn);
+		mminit_verify_page_links(page, zone, nid, pfn);
 		init_page_count(page);
 		reset_page_mapcount(page);
 		pc = page_get_page_cgroup(page);
@@ -2939,6 +2940,10 @@ __meminit int init_currently_empty_zone(
 
 	zone->zone_start_pfn = zone_start_pfn;
 
+	mminit_dprintk(MMINIT_TRACE, "memmap_init",
+			"Initialising map node %d zone %d pfns %lu -> %lu\n",
+			pgdat->node_id, zone_idx(zone),
+			zone_start_pfn, (zone_start_pfn + size));
 	memmap_init(size, pgdat->node_id, zone_idx(zone), zone_start_pfn);
 
 	zone_init_free_lists(zone);
@@ -4012,6 +4017,7 @@ void __init free_area_init_nodes(unsigne
 						early_node_map[i].end_pfn);
 
 	/* Initialise every node */
+	mminit_verify_pageflags_layout();
 	setup_nr_node_ids();
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

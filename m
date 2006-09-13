Date: Wed, 13 Sep 2006 13:44:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Get rid of zone_table
Message-ID: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The zone table is mostly not needed. If we have a node in the page flags 
then we can get to the zone via NODE_DATA(). In case of SMP and UP 
NODE_DATA() is a constant pointer which allows us to access an exact 
replica of zonetable in the node_zones field. In all of the above cases 
there will be no need at all for the zone table.

The only remaining case is if in a NUMA system the node numbers do not fit 
into the page flags. In that case we make sparse generate a table that 
maps sections to nodes and use that table to to figure out the node 
number.

For sparsemem the zone table seems to be have been fairly large based on 
the maximum possible number of sections and the number of zones per node.

The section_to_node table (if we still need it) is still the size of the 
number of sections but the individual elements are integers (which already 
saves 50% on 64 bit platforms) and we do not need to duplicate the entries 
per zone type. So even if we have to keep the table then we shrink it to 
1/4th (32bit) or 1/8th )(64bit).

Tested on IA64(NUMA) and x86_64 (UP)

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/include/linux/mm.h
===================================================================
--- linux-2.6.18-rc6-mm2.orig/include/linux/mm.h	2006-09-13 14:17:24.798144329 -0500
+++ linux-2.6.18-rc6-mm2/include/linux/mm.h	2006-09-13 15:42:22.040414207 -0500
@@ -395,7 +395,9 @@
  * We are going to use the flags for the page to node mapping if its in
  * there.  This includes the case where there is no node, so it is implicit.
  */
-#define FLAGS_HAS_NODE		(NODES_WIDTH > 0 || NODES_SHIFT == 0)
+#if !(NODES_WIDTH > 0 || NODES_SHIFT == 0)
+#define NODE_NOT_IN_PAGE_FLAGS
+#endif
 
 #ifndef PFN_SECTION_SHIFT
 #define PFN_SECTION_SHIFT 0
@@ -410,13 +412,13 @@
 #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
 #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
 
-/* NODE:ZONE or SECTION:ZONE is used to lookup the zone from a page. */
-#if FLAGS_HAS_NODE
-#define ZONETABLE_SHIFT		(NODES_SHIFT + ZONES_SHIFT)
+/* NODE:ZONE or SECTION:ZONE is used to ID a zone for the buddy allcator */
+#ifdef NODE_NOT_IN_PAGE_FLAGS
+#define ZONEID_SHIFT		(SECTIONS_SHIFT + ZONES_SHIFT)
 #else
-#define ZONETABLE_SHIFT		(SECTIONS_SHIFT + ZONES_SHIFT)
+#define ZONEID_SHIFT		(NODES_SHIFT + ZONES_SHIFT)
 #endif
-#define ZONETABLE_PGSHIFT	ZONES_PGSHIFT
+#define ZONEID_PGSHIFT		ZONES_PGSHIFT
 
 #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
 #error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
@@ -425,23 +427,24 @@
 #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
 #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
-#define ZONETABLE_MASK		((1UL << ZONETABLE_SHIFT) - 1)
+#define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
 static inline enum zone_type page_zonenum(struct page *page)
 {
 	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
 }
 
-struct zone;
-extern struct zone *zone_table[];
-
+/*
+ * The identification function is only used by the buddy allocator for
+ * determining if two pages could be buddies. We are not really
+ * identify a zone since we could be using a the section number
+ * id if we have not node id available in page flags.
+ * We guarantee only that it will return the same value for two
+ * combinable pages in a zone.
+ */
 static inline int page_zone_id(struct page *page)
 {
-	return (page->flags >> ZONETABLE_PGSHIFT) & ZONETABLE_MASK;
-}
-static inline struct zone *page_zone(struct page *page)
-{
-	return zone_table[page_zone_id(page)];
+	return (page->flags >> ZONEID_PGSHIFT) & ZONEID_MASK;
 }
 
 static inline unsigned long zone_to_nid(struct zone *zone)
@@ -449,13 +452,20 @@
 	return zone->zone_pgdat->node_id;
 }
 
+#ifdef NODE_NOT_IN_PAGE_FLAGS
+extern unsigned long page_to_nid(struct page *page);
+#else
 static inline unsigned long page_to_nid(struct page *page)
 {
-	if (FLAGS_HAS_NODE)
-		return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
-	else
-		return zone_to_nid(page_zone(page));
+	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
 }
+#endif
+
+static inline struct zone *page_zone(struct page *page)
+{
+	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
+}
+
 static inline unsigned long page_to_section(struct page *page)
 {
 	return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
@@ -472,6 +482,7 @@
 	page->flags &= ~(NODES_MASK << NODES_PGSHIFT);
 	page->flags |= (node & NODES_MASK) << NODES_PGSHIFT;
 }
+
 static inline void set_page_section(struct page *page, unsigned long section)
 {
 	page->flags &= ~(SECTIONS_MASK << SECTIONS_PGSHIFT);
@@ -972,8 +983,6 @@
 extern void show_mem(void);
 extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
-extern void zonetable_add(struct zone *zone, int nid, enum zone_type zid,
-					unsigned long pfn, unsigned long size);
 
 #ifdef CONFIG_NUMA
 extern void setup_per_cpu_pageset(void);
Index: linux-2.6.18-rc6-mm2/mm/sparse.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/sparse.c	2006-09-13 14:17:24.805957488 -0500
+++ linux-2.6.18-rc6-mm2/mm/sparse.c	2006-09-13 15:10:24.845606274 -0500
@@ -24,6 +24,21 @@
 #endif
 EXPORT_SYMBOL(mem_section);
 
+#ifdef NODE_NOT_IN_PAGE_FLAGS
+/*
+ * If we did not store the node number in the page then we have to
+ * do a lookup in the section_to_node_table in order to find which
+ * node the page belongs to.
+ */
+static int section_to_node_table[NR_MEM_SECTIONS];
+
+extern unsigned long page_to_nid(struct page *page)
+{
+	return section_to_node_table[page_to_section(page)];
+}
+EXPORT_SYMBOL(page_to_nid);
+#endif
+
 #ifdef CONFIG_SPARSEMEM_EXTREME
 static struct mem_section *sparse_index_alloc(int nid)
 {
@@ -49,6 +64,10 @@
 	struct mem_section *section;
 	int ret = 0;
 
+#ifdef NODE_NOT_IN_PAGE_FLAGS
+	section_to_node_table[section_nr] = nid;
+#endif
+
 	if (mem_section[root])
 		return -EEXIST;
 
Index: linux-2.6.18-rc6-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/page_alloc.c	2006-09-13 14:17:24.812794002 -0500
+++ linux-2.6.18-rc6-mm2/mm/page_alloc.c	2006-09-13 14:18:11.739602442 -0500
@@ -82,13 +82,6 @@
 
 EXPORT_SYMBOL(totalram_pages);
 
-/*
- * Used by page_zone() to look up the address of the struct zone whose
- * id is encoded in the upper bits of page->flags
- */
-struct zone *zone_table[1 << ZONETABLE_SHIFT] __read_mostly;
-EXPORT_SYMBOL(zone_table);
-
 static char *zone_names[MAX_NR_ZONES] = {
 	 "DMA",
 #ifdef CONFIG_ZONE_DMA32
@@ -1808,20 +1801,6 @@
 	}
 }
 
-#define ZONETABLE_INDEX(x, zone_nr)	((x << ZONES_SHIFT) | zone_nr)
-void zonetable_add(struct zone *zone, int nid, enum zone_type zid,
-		unsigned long pfn, unsigned long size)
-{
-	unsigned long snum = pfn_to_section_nr(pfn);
-	unsigned long end = pfn_to_section_nr(pfn + size);
-
-	if (FLAGS_HAS_NODE)
-		zone_table[ZONETABLE_INDEX(nid, zid)] = zone;
-	else
-		for (; snum <= end; snum++)
-			zone_table[ZONETABLE_INDEX(snum, zid)] = zone;
-}
-
 #ifndef __HAVE_ARCH_MEMMAP_INIT
 #define memmap_init(size, nid, zone, start_pfn) \
 	memmap_init_zone((size), (nid), (zone), (start_pfn))
@@ -2525,7 +2504,6 @@
 		if (!size)
 			continue;
 
-		zonetable_add(zone, nid, j, zone_start_pfn, size);
 		ret = init_currently_empty_zone(zone, zone_start_pfn, size);
 		BUG_ON(ret);
 		zone_start_pfn += size;
Index: linux-2.6.18-rc6-mm2/mm/memory_hotplug.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/memory_hotplug.c	2006-09-13 14:17:24.823537096 -0500
+++ linux-2.6.18-rc6-mm2/mm/memory_hotplug.c	2006-09-13 14:18:11.750345535 -0500
@@ -72,7 +72,6 @@
 			return ret;
 	}
 	memmap_init_zone(nr_pages, nid, zone_type, phys_start_pfn);
-	zonetable_add(zone, nid, zone_type, phys_start_pfn, nr_pages);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

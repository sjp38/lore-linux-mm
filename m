Date: Mon, 11 Sep 2006 17:17:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] Could we get rid of zone_table?
Message-ID: <Pine.LNX.4.64.0609111714320.7466@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It seems that there is no need for zone_table for systems with
the nodes encoded in the page flags. One can use the NODE_DATA
function to locate the pgdat and get the zone from there.

I think the only case where we cannot encode the node number
are the early 32 bit NUMA systems? In that case one would only
need an array that maps the sections to the corresponding pgdat
structure and would then get to the zone from there. Dave, could
you add something like that to sparse.c? Then we get this whole
thing out of the page allocator.c. I guess that having the ability to 
figure out where a section belongs may also useful for other 
purposes in the sparse implementation.

This patch only removes the zone_table for the case that
the node number was encoded in the page->flags.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.18-rc6-mm1.orig/include/linux/mm.h	2006-09-11 18:39:14.000000000 -0500
+++ linux-2.6.18-rc6-mm1/include/linux/mm.h	2006-09-11 19:01:06.145480674 -0500
@@ -499,9 +499,22 @@
 {
 	return (page->flags >> ZONETABLE_PGSHIFT) & ZONETABLE_MASK;
 }
+
+#if FLAGS_HAS_NODE
+static inline unsigned long page_to_nid(struct page *page)
+{
+	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
+}
+#endif
+
 static inline struct zone *page_zone(struct page *page)
 {
+#if FLAGS_HAS_NODE
+	return &NODE_DATA(page_to_nid(page))
+			->node_zones[page_zone_id(page)];
+#else
 	return zone_table[page_zone_id(page)];
+#endif
 }
 
 static inline unsigned long zone_to_nid(struct zone *zone)
@@ -509,13 +522,13 @@
 	return zone->zone_pgdat->node_id;
 }
 
+#if !FLAGS_HAS_NODE
 static inline unsigned long page_to_nid(struct page *page)
 {
-	if (FLAGS_HAS_NODE)
-		return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
-	else
-		return zone_to_nid(page_zone(page));
+	return zone_to_nid(page_zone(page));
 }
+#endif
+
 static inline unsigned long page_to_section(struct page *page)
 {
 	return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
@@ -1037,8 +1050,13 @@
 extern void show_mem(void);
 extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
+#if FLAGS_HAS_NODE
+static inline void zonetable_add(struct zone *zone, int nid,
+	enum zone_type zid, unsigned long pfn, unsigned long size) {}
+#else
 extern void zonetable_add(struct zone *zone, int nid, enum zone_type zid,
 					unsigned long pfn, unsigned long size);
+#endif
 
 #ifdef CONFIG_NUMA
 extern void setup_per_cpu_pageset(void);
Index: linux-2.6.18-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc6-mm1.orig/mm/page_alloc.c	2006-09-11 18:39:14.000000000 -0500
+++ linux-2.6.18-rc6-mm1/mm/page_alloc.c	2006-09-11 18:49:00.228450657 -0500
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
@@ -1808,6 +1801,14 @@
 	}
 }
 
+#if !FLAGS_HAS_NODE
+/*
+ * Used by page_zone() to look up the address of the struct zone whose
+ * id is encoded in the upper bits of page->flags
+ */
+struct zone *zone_table[1 << ZONETABLE_SHIFT] __read_mostly;
+EXPORT_SYMBOL(zone_table);
+
 #define ZONETABLE_INDEX(x, zone_nr)	((x << ZONES_SHIFT) | zone_nr)
 void zonetable_add(struct zone *zone, int nid, enum zone_type zid,
 		unsigned long pfn, unsigned long size)
@@ -1815,12 +1816,10 @@
 	unsigned long snum = pfn_to_section_nr(pfn);
 	unsigned long end = pfn_to_section_nr(pfn + size);
 
-	if (FLAGS_HAS_NODE)
-		zone_table[ZONETABLE_INDEX(nid, zid)] = zone;
-	else
-		for (; snum <= end; snum++)
-			zone_table[ZONETABLE_INDEX(snum, zid)] = zone;
+	for (; snum <= end; snum++)
+		zone_table[ZONETABLE_INDEX(snum, zid)] = zone;
 }
+#endif
 
 #ifndef __HAVE_ARCH_MEMMAP_INIT
 #define memmap_init(size, nid, zone, start_pfn) \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

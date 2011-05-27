Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 45E2C6B0027
	for <linux-mm@kvack.org>; Fri, 27 May 2011 08:32:06 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4RCW0Ai013837
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RCVqmh999574
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RCVqhW003593
	for <linux-mm@kvack.org>; Fri, 27 May 2011 22:31:52 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 02/10] mm: Helper routines
Date: Fri, 27 May 2011 18:01:30 +0530
Message-Id: <1306499498-14263-3-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

With the introduction of regions, helper routines are needed to walk through
all the regions and zones inside a node. This patch adds these helper
routines.

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 include/linux/mm.h     |   21 ++++++++++++++++-----
 include/linux/mmzone.h |   25 ++++++++++++++++++++++---
 mm/mmzone.c            |   36 +++++++++++++++++++++++++++++++-----
 mm/page_alloc.c        |   10 ++++++++++
 4 files changed, 79 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6507dde..25299a3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -675,11 +675,6 @@ static inline int page_to_nid(struct page *page)
 }
 #endif
 
-static inline struct zone *page_zone(struct page *page)
-{
-	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
-}
-
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 static inline unsigned long page_to_section(struct page *page)
 {
@@ -687,6 +682,22 @@ static inline unsigned long page_to_section(struct page *page)
 }
 #endif
 
+static inline struct zone *page_zone(struct page *page)
+{
+	pg_data_t *pg = NODE_DATA(page_to_nid(page));
+	int i;
+	unsigned long pfn = page_to_pfn(page);
+
+	for (i = 0; i< pg->nr_mem_regions; i++) {
+		mem_region_t *mem_region= &(pg->mem_regions[i]);
+		unsigned long end_pfn = mem_region->start_pfn + mem_region->spanned_pages - 1;
+		if ((pfn >= mem_region->start_pfn) && (pfn <= end_pfn))
+			return &mem_region->zones[page_zonenum(page)];
+	}
+
+	return NULL;
+}
+
 static inline void set_page_zone(struct page *page, enum zone_type zone)
 {
 	page->flags &= ~(ZONES_MASK << ZONES_PGSHIFT);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 997a474..3f13dc8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -711,7 +711,7 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
  */
-#define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
+#define zone_idx(zone)		((zone) - (zone)->zone_mem_region->zones)
 
 static inline int populated_zone(struct zone *zone)
 {
@@ -818,6 +818,7 @@ extern struct pglist_data contig_page_data;
 
 extern struct pglist_data *first_online_pgdat(void);
 extern struct pglist_data *next_online_pgdat(struct pglist_data *pgdat);
+extern struct zone* first_zone(void);
 extern struct zone *next_zone(struct zone *zone);
 
 /**
@@ -828,6 +829,24 @@ extern struct zone *next_zone(struct zone *zone);
 	for (pgdat = first_online_pgdat();		\
 	     pgdat;					\
 	     pgdat = next_online_pgdat(pgdat))
+
+extern struct mem_region_list_data *first_mem_region(struct pglist_data *pgdat);
+/**
+ * for_each_mem_region - helper macro to iterate over all the memory regions in a
+ * node
+ * @mem_region - pointer to a mem_region_t variable
+ */
+#define for_each_online_mem_region(mem_region)			\
+	for (mem_region = first_node_mem_region();		\
+		mem_region;					\
+		mem_region = next_mem_region(mem_region))
+
+inline int first_mem_region_in_nid(int nid);
+int next_mem_region_in_nid(int idx, int nid);
+/* Basic iterator support to walk all the memory regions in a node */
+#define for_each_mem_region_in_nid(i, nid) 		\
+	for (i = 0; i != -1; i = next_mem_region_in_nid(i, nid))
+
 /**
  * for_each_zone - helper macro to iterate over all memory zones
  * @zone - pointer to struct zone variable
@@ -836,12 +855,12 @@ extern struct zone *next_zone(struct zone *zone);
  * fills it in.
  */
 #define for_each_zone(zone)			        \
-	for (zone = (first_online_pgdat())->node_zones; \
+	     for (zone = (first_zone());		\
 	     zone;					\
 	     zone = next_zone(zone))
 
 #define for_each_populated_zone(zone)		        \
-	for (zone = (first_online_pgdat())->node_zones; \
+	     for (zone = (first_zone());		\
 	     zone;					\
 	     zone = next_zone(zone))			\
 		if (!populated_zone(zone))		\
diff --git a/mm/mmzone.c b/mm/mmzone.c
index f5b7d17..0e2bec3 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -24,21 +24,47 @@ struct pglist_data *next_online_pgdat(struct pglist_data *pgdat)
 	return NODE_DATA(nid);
 }
 
+inline struct mem_region_list_data *first_mem_region(struct pglist_data *pgdat)
+{
+	return &pgdat->mem_regions[0];
+}
+
+struct mem_region_list_data *next_mem_region(struct mem_region_list_data *mem_region)
+{
+	int next_region = mem_region->region + 1;
+	pg_data_t *pgdat = NODE_DATA(mem_region->node);
+
+	if (next_region == pgdat->nr_mem_regions)
+		return NULL;
+	return &(pgdat->mem_regions[next_region]);
+}
+
+inline struct zone *first_zone(void)
+{
+	return (first_online_pgdat())->mem_regions[0].zones;
+}
+
 /*
  * next_zone - helper magic for for_each_zone()
  */
 struct zone *next_zone(struct zone *zone)
 {
 	pg_data_t *pgdat = zone->zone_pgdat;
+	mem_region_t *mem_region = zone->zone_mem_region;
 
-	if (zone < pgdat->node_zones + MAX_NR_ZONES - 1)
+	if (zone < mem_region->zones + MAX_NR_ZONES - 1)
 		zone++;
 	else {
-		pgdat = next_online_pgdat(pgdat);
-		if (pgdat)
-			zone = pgdat->node_zones;
+		mem_region = next_mem_region(mem_region);
+		if (!mem_region) {
+			pgdat = next_online_pgdat(pgdat);
+			if (pgdat)
+				zone = pgdat->mem_regions[0].zones;
+			else
+				zone = NULL;
+		}
 		else
-			zone = NULL;
+			zone = mem_region->zones;
 	}
 	return zone;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3f8bce2..af2529d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2492,6 +2492,16 @@ out:
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
 
+int next_mem_region_in_nid(int idx, int nid)
+{
+	pg_data_t *pgdat = NODE_DATA(nid);
+	int region = idx + 1;
+
+	if (region == pgdat->nr_mem_regions)
+		return -1;
+	return region;
+}
+
 /*
  * Show free area list (used inside shift_scroll-lock stuff)
  * We also calculate the percentage fragmentation. We do this by counting the
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

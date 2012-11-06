Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 7EABA6B006C
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:41:14 -0500 (EST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 05:38:50 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JUuQT65863826
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:30:56 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6Jf9Te000458
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:41:10 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 02/10] mm: Helper routines
Date: Wed, 07 Nov 2012 01:10:02 +0530
Message-ID: <20121106193956.6560.79831.stgit@srivatsabhat.in.ibm.com>
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

With the introduction of regions, helper routines are needed to walk through
all the regions and zones inside a node. This patch adds these helper
routines.

Signed-off-by: Ankita Garg <gargankita@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mm.h     |    7 ++-----
 include/linux/mmzone.h |   22 +++++++++++++++++++---
 mm/mmzone.c            |   48 ++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 65 insertions(+), 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fa06804..70f1009 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -693,11 +693,6 @@ static inline int page_to_nid(const struct page *page)
 }
 #endif
 
-static inline struct zone *page_zone(const struct page *page)
-{
-	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
-}
-
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 static inline void set_page_section(struct page *page, unsigned long section)
 {
@@ -711,6 +706,8 @@ static inline unsigned long page_to_section(const struct page *page)
 }
 #endif
 
+struct zone *page_zone(struct page *page);
+
 static inline void set_page_zone(struct page *page, enum zone_type zone)
 {
 	page->flags &= ~(ZONES_MASK << ZONES_PGSHIFT);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3f9b106..6f5d533 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -800,7 +800,7 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
  */
-#define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
+#define zone_idx(zone)		((zone) - (zone)->zone_mem_region->region_zones)
 
 static inline int populated_zone(struct zone *zone)
 {
@@ -907,7 +907,9 @@ extern struct pglist_data contig_page_data;
 
 extern struct pglist_data *first_online_pgdat(void);
 extern struct pglist_data *next_online_pgdat(struct pglist_data *pgdat);
+extern struct zone *first_zone(void);
 extern struct zone *next_zone(struct zone *zone);
+extern struct mem_region *next_mem_region(struct mem_region *region);
 
 /**
  * for_each_online_pgdat - helper macro to iterate over all online nodes
@@ -917,6 +919,20 @@ extern struct zone *next_zone(struct zone *zone);
 	for (pgdat = first_online_pgdat();		\
 	     pgdat;					\
 	     pgdat = next_online_pgdat(pgdat))
+
+
+/**
+ * for_each_mem_region_in_node - helper macro to iterate over all the memory
+ * regions in a node.
+ * @region - pointer to a struct mem_region variable
+ * @nid - node id of the node
+ */
+#define for_each_mem_region_in_node(region, nid)	\
+	for (region = (NODE_DATA(nid))->node_regions;	\
+	     region;					\
+	     region = next_mem_region(region))
+
+
 /**
  * for_each_zone - helper macro to iterate over all memory zones
  * @zone - pointer to struct zone variable
@@ -925,12 +941,12 @@ extern struct zone *next_zone(struct zone *zone);
  * fills it in.
  */
 #define for_each_zone(zone)			        \
-	for (zone = (first_online_pgdat())->node_zones; \
+	for (zone = (first_zone()); 			\
 	     zone;					\
 	     zone = next_zone(zone))
 
 #define for_each_populated_zone(zone)		        \
-	for (zone = (first_online_pgdat())->node_zones; \
+	for (zone = (first_zone()); 			\
 	     zone;					\
 	     zone = next_zone(zone))			\
 		if (!populated_zone(zone))		\
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 3cef80f..d32d10a 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -23,22 +23,62 @@ struct pglist_data *next_online_pgdat(struct pglist_data *pgdat)
 	return NODE_DATA(nid);
 }
 
+struct mem_region *next_mem_region(struct mem_region *region)
+{
+	int next_region = region->region + 1;
+	pg_data_t *pgdat = NODE_DATA(region->node);
+
+	if (next_region == pgdat->nr_node_regions)
+		return NULL;
+	return &(pgdat->node_regions[next_region]);
+}
+
+struct zone *first_zone(void)
+{
+	return (first_online_pgdat())->node_regions[0].region_zones;
+}
+
+struct zone *page_zone(struct page *page)
+{
+        pg_data_t *pgdat  = NODE_DATA(page_to_nid(page));
+        unsigned long pfn = page_to_pfn(page);
+        struct mem_region *region;
+
+        for_each_mem_region_in_node(region, pgdat->node_id) {
+                unsigned long end_pfn = region->start_pfn +
+                                        region->spanned_pages;
+
+                if ((pfn >= region->start_pfn) && (pfn < end_pfn))
+                        return &region->region_zones[page_zonenum(page)];
+        }
+
+        return NULL;
+}
+
+
 /*
  * next_zone - helper magic for for_each_zone()
  */
 struct zone *next_zone(struct zone *zone)
 {
 	pg_data_t *pgdat = zone->zone_pgdat;
+	struct mem_region *region = zone->zone_mem_region;
+
+	if (zone < region->region_zones + MAX_NR_ZONES - 1)
+		return ++zone;
 
-	if (zone < pgdat->node_zones + MAX_NR_ZONES - 1)
-		zone++;
-	else {
+	region = next_mem_region(region);
+
+	if (region) {
+		zone = region->region_zones;
+	} else {
 		pgdat = next_online_pgdat(pgdat);
 		if (pgdat)
-			zone = pgdat->node_zones;
+			zone = pgdat->node_regions[0].region_zones;
 		else
 			zone = NULL;
 	}
+
 	return zone;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

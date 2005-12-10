Date: Sat, 10 Dec 2005 20:03:01 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 3. (is_easy_reclaim func)[4/5]
Message-Id: <20051210194128.482C.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

This is for calculation of the watermark zone->pages_min/low/high.
And it defines is_higher_zone().

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: zone_reclaim/include/linux/mmzone.h
===================================================================
--- zone_reclaim.orig/include/linux/mmzone.h	2005-12-10 17:13:16.000000000 +0900
+++ zone_reclaim/include/linux/mmzone.h	2005-12-10 17:39:57.000000000 +0900
@@ -394,6 +394,11 @@ static inline int populated_zone(struct 
 	return (!!zone->present_pages);
 }
 
+static inline int is_easy_reclaim_idx(int idx)
+{
+	return (idx == ZONE_EASY_RECLAIM);
+}
+
 static inline int is_highmem_idx(int idx)
 {
 	return (idx == ZONE_HIGHMEM);
@@ -410,11 +415,21 @@ static inline int is_normal_idx(int idx)
  *              to ZONE_{DMA/NORMAL/HIGHMEM/etc} in general code to a minimum.
  * @zone - pointer to struct zone variable
  */
+static inline int is_easy_reclaim(struct zone *zone)
+{
+	return zone == zone->zone_pgdat->node_zones + ZONE_EASY_RECLAIM;
+}
+
 static inline int is_highmem(struct zone *zone)
 {
 	return zone == zone->zone_pgdat->node_zones + ZONE_HIGHMEM;
 }
 
+static inline int is_higher_zone(struct zone *zone)
+{
+	return (is_highmem(zone) || is_easy_reclaim(zone));
+}
+
 static inline int is_normal(struct zone *zone)
 {
 	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
Index: zone_reclaim/mm/page_alloc.c
===================================================================
--- zone_reclaim.orig/mm/page_alloc.c	2005-12-10 17:15:10.000000000 +0900
+++ zone_reclaim/mm/page_alloc.c	2005-12-10 17:40:59.000000000 +0900
@@ -2573,7 +2573,7 @@ void setup_per_zone_pages_min(void)
 
 	/* Calculate total number of !ZONE_HIGHMEM pages */
 	for_each_zone(zone) {
-		if (!is_highmem(zone))
+		if (!is_higher_zone(zone))
 			lowmem_pages += zone->present_pages;
 	}
 
@@ -2581,7 +2581,7 @@ void setup_per_zone_pages_min(void)
 		unsigned long tmp;
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		tmp = (pages_min * zone->present_pages) / lowmem_pages;
-		if (is_highmem(zone)) {
+		if (is_higher_zone(zone)) {
 			/*
 			 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
 			 * need highmem pages, so cap pages_min to a small

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

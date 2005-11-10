Date: Thu, 10 Nov 2005 19:41:25 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch:RFC] New zone ZONE_EASY_RECLAIM[5/5]
Message-Id: <20051110190132.023A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This is for calculation of the watermark zone->pages_min/low/high.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---

Index: new_zone/include/linux/mmzone.h
===================================================================
--- new_zone.orig/include/linux/mmzone.h	2005-11-09 16:40:29.000000000 +0900
+++ new_zone/include/linux/mmzone.h	2005-11-09 16:52:44.000000000 +0900
@@ -372,6 +372,11 @@ static inline struct zone *next_zone(str
 #define for_each_zone(zone) \
 	for (zone = pgdat_list->node_zones; zone; zone = next_zone(zone))
 
+static inline int is_easy_reclaim_idx(int idx)
+{
+	return (idx == ZONE_EASY_RECLAIM);
+}
+
 static inline int is_highmem_idx(int idx)
 {
 	return (idx == ZONE_HIGHMEM);
@@ -387,6 +392,11 @@ static inline int is_normal_idx(int idx)
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
Index: new_zone/mm/page_alloc.c
===================================================================
--- new_zone.orig/mm/page_alloc.c	2005-11-09 16:40:29.000000000 +0900
+++ new_zone/mm/page_alloc.c	2005-11-09 16:40:33.000000000 +0900
@@ -2379,13 +2379,13 @@ static void setup_per_zone_pages_min(voi
 
 	/* Calculate total number of !ZONE_HIGHMEM pages */
 	for_each_zone(zone) {
-		if (!is_highmem(zone))
+		if (!is_highmem(zone) && !is_easy_reclaim(zone))
 			lowmem_pages += zone->present_pages;
 	}
 
 	for_each_zone(zone) {
 		spin_lock_irqsave(&zone->lru_lock, flags);
-		if (is_highmem(zone)) {
+		if (is_highmem(zone) || is_easy_reclaim(zone)) {
 			/*
 			 * Often, highmem doesn't need to reserve any pages.
 			 * But the pages_min/low/high values are also used for

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

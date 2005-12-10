Date: Sat, 10 Dec 2005 20:02:54 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 3. (change build_zonelists)[3/5]
Message-Id: <20051210194021.482A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
Cc: Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

This is changing build_zonelists for new zone.

__GFP_xxxs are flag for requires of page allocation which zone
is prefered. But, it is used as an index number for zonelists[] too.
But after my patch, __GFP_xxx might be set at same time. So,
last set bit number of __GFP is recognized for zonelists' index
by this patch.

Note:
 This patch is modified take 3 to avoid panic on i386.
 __GFP_DMA32 is 0 for i386. So, ZONE_DMA32 is selected 
 if zone_bits is 0 which means Zone_normal. 
 Zone_DMA32 is not allocated on i386, so kernel paniced 
 by no normal memory.
 In this patch, even if zone_bits is 0 adn __GFP_DMA32 is 0,
 Zone_Normal is selected.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: zone_reclaim/mm/page_alloc.c
===================================================================
--- zone_reclaim.orig/mm/page_alloc.c	2005-12-06 14:11:20.000000000 +0900
+++ zone_reclaim/mm/page_alloc.c	2005-12-06 15:41:50.000000000 +0900
@@ -1574,6 +1574,10 @@ static int __init build_zonelists_node(p
 		struct zone *zone;
 	default:
 		BUG();
+	case ZONE_EASY_RECLAIM:
+		zone = pgdat->node_zones + ZONE_EASY_RECLAIM;
+		if (zone->present_pages)
+			zonelist->zones[j++] = zone;
 	case ZONE_HIGHMEM:
 		zone = pgdat->node_zones + ZONE_HIGHMEM;
 		if (populated_zone(zone)) {
@@ -1602,12 +1606,16 @@ static int __init build_zonelists_node(p
 static inline int highest_zone(int zone_bits)
 {
 	int res = ZONE_NORMAL;
-	if (zone_bits & (__force int)__GFP_HIGHMEM)
-		res = ZONE_HIGHMEM;
-	if (zone_bits & (__force int)__GFP_DMA32)
-		res = ZONE_DMA32;
+
 	if (zone_bits & (__force int)__GFP_DMA)
 		res = ZONE_DMA;
+	if (zone_bits & (__force int)__GFP_DMA32)
+		res = ZONE_DMA32;
+	if (zone_bits & (__force int)__GFP_HIGHMEM)
+		res = ZONE_HIGHMEM;
+	if (zone_bits & (__force int)__GFP_EASY_RECLAIM)
+		res = ZONE_EASY_RECLAIM;
+
 	return res;
 }
 
Index: zone_reclaim/include/linux/gfp.h
===================================================================
--- zone_reclaim.orig/include/linux/gfp.h	2005-12-06 14:12:43.000000000 +0900
+++ zone_reclaim/include/linux/gfp.h	2005-12-06 14:12:44.000000000 +0900
@@ -80,7 +80,7 @@ struct vm_area_struct;
 
 static inline int gfp_zone(gfp_t gfp)
 {
-	int zone = GFP_ZONEMASK & (__force int) gfp;
+	int zone = fls(GFP_ZONEMASK & (__force int) gfp);
 	BUG_ON(zone >= GFP_ZONETYPES);
 	return zone;
 }

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

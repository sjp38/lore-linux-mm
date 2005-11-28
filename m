Date: Mon, 28 Nov 2005 20:36:30 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch] New zone ZONE_EASY_RECLAIM take 2[3/5]
Message-Id: <20051128200400.5D7E.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Joel Schopp <jschopp@austin.ibm.com>, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is changing build_zonelists for new zone.

__GFP_xxxs are flag for requires of page allocation which zone
is prefered. But, it is used as an index number for zonelists[] too.
But after my patch, __GFP_xxx might be set at same time. So,
last set bit number of __GFP is recognized for zonelists' index
by this patch.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: new_zone_mm/mm/page_alloc.c
===================================================================
--- new_zone_mm.orig/mm/page_alloc.c	2005-11-28 16:12:53.000000000 +0900
+++ new_zone_mm/mm/page_alloc.c	2005-11-28 16:15:55.000000000 +0900
@@ -1498,6 +1498,10 @@ static int __init build_zonelists_node(p
 		struct zone *zone;
 	default:
 		BUG();
+	case ZONE_EASY_RECLAIM:
+		zone = pgdat->node_zones + ZONE_EASY_RECLAIM;
+		if (zone->present_pages)
+			zonelist->zones[j++] = zone;
 	case ZONE_HIGHMEM:
 		zone = pgdat->node_zones + ZONE_HIGHMEM;
 		if (zone->present_pages) {
@@ -1526,11 +1530,14 @@ static int __init build_zonelists_node(p
 static inline int highest_zone(int zone_bits)
 {
 	int res = ZONE_NORMAL;
-	if (zone_bits & (__force int)__GFP_HIGHMEM)
+
+	if (zone_bits == fls((__force int)__GFP_EASY_RECLAIM))
+		res = ZONE_EASY_RECLAIM;
+	else if (zone_bits == fls((__force int)__GFP_HIGHMEM))
 		res = ZONE_HIGHMEM;
-	if (zone_bits & (__force int)__GFP_DMA32)
+	else if (zone_bits == fls((__force int)__GFP_DMA32))
 		res = ZONE_DMA32;
-	if (zone_bits & (__force int)__GFP_DMA)
+	else if (zone_bits == fls((__force int)__GFP_DMA))
 		res = ZONE_DMA;
 	return res;
 }
Index: new_zone_mm/include/linux/gfp.h
===================================================================
--- new_zone_mm.orig/include/linux/gfp.h	2005-11-28 16:15:48.000000000 +0900
+++ new_zone_mm/include/linux/gfp.h	2005-11-28 16:15:55.000000000 +0900
@@ -79,8 +79,10 @@ struct vm_area_struct;
 /* 4GB DMA on some platforms */
 #define GFP_DMA32	__GFP_DMA32
 
-
-#define gfp_zone(mask) ((__force int)((mask) & (__force gfp_t)GFP_ZONEMASK))
+static inline unsigned int gfp_zone(unsigned int mask)
+{
+	return fls(mask & GFP_ZONEMASK);
+}
 
 /*
  * There is only one page-allocator function, and two main namespaces to

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

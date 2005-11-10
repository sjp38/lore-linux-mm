Date: Thu, 10 Nov 2005 19:41:18 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch:RFC] New zone ZONE_EASY_RECLAIM[4/5]
Message-Id: <20051110190053.0236.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

__GFP_xxxs are flag for requires of page allocation which zone
is prefered. But, it is used as an index number for zonelists[] too.
But after my patch, __GFP_xxx might be set at same time. So,
last set bit number of __GFP is recognized for zonelists' index
by this patch.



Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---

Index: new_zone/fs/buffer.c
===================================================================
--- new_zone.orig/fs/buffer.c	2005-11-08 17:23:22.000000000 +0900
+++ new_zone/fs/buffer.c	2005-11-08 17:27:37.000000000 +0900
@@ -502,7 +502,7 @@ static void free_more_memory(void)
 	yield();
 
 	for_each_pgdat(pgdat) {
-		zones = pgdat->node_zonelists[GFP_NOFS&GFP_ZONEMASK].zones;
+		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
 		if (*zones)
 			try_to_free_pages(zones, GFP_NOFS);
 	}
Index: new_zone/include/linux/gfp.h
===================================================================
--- new_zone.orig/include/linux/gfp.h	2005-11-08 17:26:12.000000000 +0900
+++ new_zone/include/linux/gfp.h	2005-11-09 15:43:25.000000000 +0900
@@ -65,6 +65,10 @@ struct vm_area_struct;
 
 #define GFP_DMA		__GFP_DMA
 
+static inline unsigned int gfp_zone(unsigned int mask)
+{
+	return fls(mask & GFP_ZONEMASK);
+}
 
 /*
  * There is only one page-allocator function, and two main namespaces to
@@ -95,7 +99,7 @@ static inline struct page *alloc_pages_n
 		return NULL;
 
 	return __alloc_pages(gfp_mask, order,
-		NODE_DATA(nid)->node_zonelists + (gfp_mask & GFP_ZONEMASK));
+		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
 }
 
 #ifdef CONFIG_NUMA
Index: new_zone/include/linux/mmzone.h
===================================================================
--- new_zone.orig/include/linux/mmzone.h	2005-11-08 17:27:30.000000000 +0900
+++ new_zone/include/linux/mmzone.h	2005-11-08 17:27:37.000000000 +0900
@@ -92,6 +92,7 @@ struct per_cpu_pageset {
  * combinations of zone modifiers in "zone modifier space".
  */
 #define GFP_ZONEMASK	0x07
+
 /*
  * As an optimisation any zone modifier bits which are only valid when
  * no other zone modifier bits are set (loners) should be placed in
Index: new_zone/mm/mempolicy.c
===================================================================
--- new_zone.orig/mm/mempolicy.c	2005-11-08 17:23:22.000000000 +0900
+++ new_zone/mm/mempolicy.c	2005-11-08 17:27:37.000000000 +0900
@@ -712,7 +712,7 @@ static struct zonelist *zonelist_policy(
 		nd = 0;
 		BUG();
 	}
-	return NODE_DATA(nd)->node_zonelists + (gfp & GFP_ZONEMASK);
+	return NODE_DATA(nd)->node_zonelists + gfp_zone(gfp);
 }
 
 /* Do dynamic interleaving for a process */
@@ -757,7 +757,7 @@ static struct page *alloc_page_interleav
 	struct page *page;
 
 	BUG_ON(!node_online(nid));
-	zl = NODE_DATA(nid)->node_zonelists + (gfp & GFP_ZONEMASK);
+	zl = NODE_DATA(nid)->node_zonelists + gfp_zone(gfp);
 	page = __alloc_pages(gfp, order, zl);
 	if (page && page_zone(page) == zl->zones[0]) {
 		zone_pcp(zl->zones[0],get_cpu())->interleave_hit++;
Index: new_zone/mm/page_alloc.c
===================================================================
--- new_zone.orig/mm/page_alloc.c	2005-11-08 17:27:30.000000000 +0900
+++ new_zone/mm/page_alloc.c	2005-11-08 17:27:37.000000000 +0900
@@ -1089,7 +1089,7 @@ static unsigned int nr_free_zone_pages(i
  */
 unsigned int nr_free_buffer_pages(void)
 {
-	return nr_free_zone_pages(GFP_USER & GFP_ZONEMASK);
+	return nr_free_zone_pages(gfp_zone(GFP_USER));
 }
 
 /*
@@ -1097,7 +1097,7 @@ unsigned int nr_free_buffer_pages(void)
  */
 unsigned int nr_free_pagecache_pages(void)
 {
-	return nr_free_zone_pages(GFP_HIGHUSER & GFP_ZONEMASK);
+	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER));
 }
 
 #ifdef CONFIG_HIGHMEM

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

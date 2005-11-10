Date: Thu, 10 Nov 2005 19:41:10 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch:RFC] New zone ZONE_EASY_RECLAIM[3/5]
Message-Id: <20051110190126.0238.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

This is changing build_zonelists for new zone.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---

Index: new_zone/mm/page_alloc.c
===================================================================
--- new_zone.orig/mm/page_alloc.c	2005-11-08 17:23:24.000000000 +0900
+++ new_zone/mm/page_alloc.c	2005-11-08 17:27:26.000000000 +0900
@@ -1407,6 +1407,10 @@ static int __init build_zonelists_node(p
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
@@ -1428,6 +1432,20 @@ static int __init build_zonelists_node(p
 	return j;
 }
 
+static inline int highest_zone(int i)
+{
+	int res = ZONE_NORMAL;
+
+	if (i == fls(__GFP_EASY_RECLAIM))
+		res = ZONE_EASY_RECLAIM;
+	else if(i == fls(__GFP_HIGHMEM))
+		res = ZONE_HIGHMEM;
+	else if(i == fls(__GFP_DMA))
+		res = ZONE_DMA;
+
+	return res;
+}
+
 #ifdef CONFIG_NUMA
 #define MAX_NODE_LOAD (num_online_nodes())
 static int __initdata node_load[MAX_NUMNODES];
@@ -1524,11 +1542,7 @@ static void __init build_zonelists(pg_da
 			zonelist = pgdat->node_zonelists + i;
 			for (j = 0; zonelist->zones[j] != NULL; j++);
 
-			k = ZONE_NORMAL;
-			if (i & __GFP_HIGHMEM)
-				k = ZONE_HIGHMEM;
-			if (i & __GFP_DMA)
-				k = ZONE_DMA;
+			k = highest_zone(i);
 
 	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
 			zonelist->zones[j] = NULL;
@@ -1549,11 +1563,7 @@ static void __init build_zonelists(pg_da
 		zonelist = pgdat->node_zonelists + i;
 
 		j = 0;
-		k = ZONE_NORMAL;
-		if (i & __GFP_HIGHMEM)
-			k = ZONE_HIGHMEM;
-		if (i & __GFP_DMA)
-			k = ZONE_DMA;
+		k = highest_zone(i);
 
  		j = build_zonelists_node(pgdat, zonelist, j, k);
  		/*

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

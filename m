Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i9Q2bMNo007342
	for <linux-mm@kvack.org>; Mon, 25 Oct 2004 19:37:22 -0700 (PDT)
Date: Mon, 25 Oct 2004 19:36:59 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: [RFC/Patch]Making Removable zone[3/4]
In-Reply-To: <20041025160642.690F.YGOTO@us.fujitsu.com>
References: <20041025160642.690F.YGOTO@us.fujitsu.com>
Message-Id: <20041025193557.6915.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is to make new order of zone index and zonelist.


 hotremovable-goto/include/linux/mmzone.h |   10 +++-
 hotremovable-goto/mm/page_alloc.c        |   67 +++++++++++++------------------
 2 files changed, 37 insertions(+), 40 deletions(-)

diff -puN include/linux/mmzone.h~zones_order include/linux/mmzone.h
--- hotremovable/include/linux/mmzone.h~zones_order	Fri Aug 27 21:07:01 2004
+++ hotremovable-goto/include/linux/mmzone.h	Fri Aug 27 21:07:01 2004
@@ -234,6 +234,11 @@ struct zonelist {
 	struct zone *zones[MAX_NUMNODES * MAX_NR_ZONES + 1]; // NULL delimited
 };
 
+/* zonelist is decided by zone_order */
+struct zonelist_order{
+       char zone_order[MAX_NR_ZONES + 1];  /* -1 delimited */
+};
+extern const struct zonelist_order zorder[];
 
 /*
  * The pg_data_t structure is used in machines with CONFIG_DISCONTIGMEM
@@ -408,8 +413,9 @@ extern struct pglist_data contig_page_da
 #error NODES_SHIFT > MAX_NODES_SHIFT
 #endif
 
-/* There are currently 3 zones: DMA, Normal & Highmem, thus we need 2 bits */
-#define MAX_ZONES_SHIFT		2
+/* There are currently 6 zones: {DMA, Normal , Highmem} x
+                                {hot-Removable or Un-Removable} thus we need 3 bits */
+#define MAX_ZONES_SHIFT		3
 
 #if ZONES_SHIFT > MAX_ZONES_SHIFT
 #error ZONES_SHIFT > MAX_ZONES_SHIFT
diff -puN mm/page_alloc.c~zones_order mm/page_alloc.c
--- hotremovable/mm/page_alloc.c~zones_order	Fri Aug 27 21:07:01 2004
+++ hotremovable-goto/mm/page_alloc.c	Fri Aug 27 21:07:01 2004
@@ -47,6 +47,18 @@ long nr_swap_pages;
 int numnodes = 1;
 int sysctl_lower_zone_protection = 0;
 
+const struct zonelist_order zorder[GFP_ZONETYPES] = {
+	{{     ZONE_NORMAL,     ZONE_DMA, -1, -1, -1, -1, -1}},		/* __GFP_NORMAL */
+	{{        ZONE_DMA,           -1, -1, -1, -1, -1, -1}},		/* __GFP_DMA */
+	{{    ZONE_HIGHMEM,  ZONE_NORMAL,        ZONE_DMA, -1, -1, -1, -1}}, /* __GFP_HIGHMEM */
+	{{ -1, -1, -1, -1, -1, -1, -1}},				/* reserve */
+	{{ ZONE_NORMAL_RMV,  ZONE_NORMAL,    ZONE_DMA_RMV,
+	         ZONE_DMA, -1, -1, -1}},				/* __GFP_NORMAL | __GFP_REMOVABLE */
+	{{    ZONE_DMA_RMV,     ZONE_DMA, -1, -1, -1, -1, -1}},		/* __GFP_DMA | __GFP_REMOVABLE */
+	{{ZONE_HIGHMEM_RMV, ZONE_HIGHMEM, ZONE_NORMAL_RMV,
+	      ZONE_NORMAL,    ZONE_DMA_RMV, ZONE_DMA, -1}}		/* __GFP_HIGHMEM | __GFP_REMOVABLE */
+};
+
 EXPORT_SYMBOL(totalram_pages);
 EXPORT_SYMBOL(nr_swap_pages);
 
@@ -1452,27 +1464,17 @@ void show_free_areas(void)
  */
 static int __init build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist, int j, int k)
 {
-	switch (k) {
-		struct zone *zone;
-	default:
-		BUG();
-	case ZONE_HIGHMEM:
-		zone = pgdat->node_zones + ZONE_HIGHMEM;
-		if (zone->present_pages) {
-#ifndef CONFIG_HIGHMEM
-			BUG();
-#endif
-			zonelist->zones[j++] = zone;
-		}
-	case ZONE_NORMAL:
-		zone = pgdat->node_zones + ZONE_NORMAL;
-		if (zone->present_pages)
-			zonelist->zones[j++] = zone;
-	case ZONE_DMA:
-		zone = pgdat->node_zones + ZONE_DMA;
-		if (zone->present_pages)
-			zonelist->zones[j++] = zone;
-	}
+	struct zone *zone;
+	int i = 0,index;
+
+	index = zorder[k].zone_order[i];
+
+	while(index != -1){
+		zone = pgdat->node_zones + index;
+		zonelist->zones[j++] = zone;
+		i++;
+		index = zorder[k].zone_order[i];
+	};
 
 	return j;
 }
@@ -1537,7 +1539,7 @@ static int __init find_next_best_node(in
 
 static void __init build_zonelists(pg_data_t *pgdat)
 {
-	int i, j, k, node, local_node;
+	int i, j, node, local_node;
 	int prev_node, load;
 	struct zonelist *zonelist;
 	DECLARE_BITMAP(used_mask, MAX_NUMNODES);
@@ -1569,13 +1571,7 @@ static void __init build_zonelists(pg_da
 			zonelist = pgdat->node_zonelists + i;
 			for (j = 0; zonelist->zones[j] != NULL; j++);
 
-			k = ZONE_NORMAL;
-			if (i & __GFP_HIGHMEM)
-				k = ZONE_HIGHMEM;
-			if (i & __GFP_DMA)
-				k = ZONE_DMA;
-
-	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
+	 		j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
 			zonelist->zones[j] = NULL;
 		}
 	}
@@ -1585,7 +1581,7 @@ static void __init build_zonelists(pg_da
 
 static void __init build_zonelists(pg_data_t *pgdat)
 {
-	int i, j, k, node, local_node;
+	int i, j, node, local_node;
 
 	local_node = pgdat->node_id;
 	for (i = 0; i < GFP_ZONETYPES; i++) {
@@ -1595,13 +1591,8 @@ static void __init build_zonelists(pg_da
 		memset(zonelist, 0, sizeof(*zonelist));
 
 		j = 0;
-		k = ZONE_NORMAL;
-		if (i & __GFP_HIGHMEM)
-			k = ZONE_HIGHMEM;
-		if (i & __GFP_DMA)
-			k = ZONE_DMA;
 
- 		j = build_zonelists_node(pgdat, zonelist, j, k);
+ 		j = build_zonelists_node(pgdat, zonelist, j, i);
  		/*
  		 * Now we build the zonelist so that it contains the zones
  		 * of all the other nodes.
@@ -1611,9 +1602,9 @@ static void __init build_zonelists(pg_da
  		 * node N+1 (modulo N)
  		 */
  		for (node = local_node + 1; node < numnodes; node++)
- 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
+ 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
  		for (node = 0; node < local_node; node++)
- 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
+ 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, i);
  
 		zonelist->zones[j] = NULL;
 	}
_

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

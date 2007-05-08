Date: Tue, 8 May 2007 20:18:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] change zonelist order v5 [2/3] automatic configuration
Message-Id: <20070508201819.99f499df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070508201401.8f78ec37.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070508201401.8f78ec37.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, clameter@sgi.com, akpm@linux-foundation.org, ak@suse.de, jbarnes@virtuousgeek.org
List-ID: <linux-mm.kvack.org>

Add auto zone ordering configuration.

This function will select ZONE_ORDER_NODE when

There are only ZONE_DMA or ZONE_DMA32.
|| size of (ZONE_DMA/DMA32) > (System Total Memory)/2
|| Assume Node(A)
	Node (A) is enough big &&
	Node (A)'s ZONE_DMA/DMA32 occupies 60% of Node(A)'s memory.
	(In this case, ZONE_ORDER_ZONE may not offer enough locality...)

otherwise, ZONE_ORDER_ZONE is selected.

Maybe there is no best and simple way to configure zone order. I wrote this base on
my experience and discussion on the list.

Anyway, a user can specifiy zone order from boot option/sysctl.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/page_alloc.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 49 insertions(+), 2 deletions(-)

Index: linux-2.6.21-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/page_alloc.c
+++ linux-2.6.21-mm1/mm/page_alloc.c
@@ -2248,8 +2248,55 @@ static void build_zonelists_in_zone_orde
 
 static int default_zonelist_order(void)
 {
-	/* dummy, just select node order. */
-	return ZONELIST_ORDER_NODE;
+	int nid, zone_type;
+	unsigned long low_kmem_size,total_size;
+	struct zone *z;
+	int average_size;
+	/*
+         * ZONE_DMA and ZONE_DMA32 can be very small area in the sytem.
+	 * If they are really small and used heavily, the system can fall
+	 * into OOM very easily.
+	 * This function detect ZONE_DMA/DMA32 size and confgigures zone order.
+	 */
+	/* Is there ZONE_NORMAL ? (ex. ppc has only DMA zone..) */
+	low_kmem_size = 0;
+	total_size = 0;
+	for_each_online_node(nid) {
+		for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
+			z = &NODE_DATA(nid)->node_zones[zone_type];
+			if (populated_zone(z)) {
+				if (zone_type < ZONE_NORMAL)
+					low_kmem_size += z->present_pages;
+				total_size += z->present_pages;
+			}
+		}
+	}
+	if (!low_kmem_size ||  /* there are no DMA area. */
+	    low_kmem_size > total_size/2) /* DMA/DMA32 is big. */
+		return ZONELIST_ORDER_NODE;
+	/*
+	 * look into each node's config.
+  	 * If there is a node whose DMA/DMA32 memory is very big area on
+ 	 * local memory, NODE_ORDER may be suitable.
+         */
+	average_size = total_size / (num_online_nodes() + 1);
+	for_each_online_node(nid) {
+		low_kmem_size = 0;
+		total_size = 0;
+		for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
+			z = &NODE_DATA(nid)->node_zones[zone_type];
+			if (populated_zone(z)) {
+				if (zone_type < ZONE_NORMAL)
+					low_kmem_size += z->present_pages;
+				total_size += z->present_pages;
+			}
+		}
+		if (low_kmem_size &&
+		    total_size > average_size && /* ignore small node */
+		    low_kmem_size > total_size * 70/100)
+			return ZONELIST_ORDER_NODE;
+	}
+	return ZONELIST_ORDER_ZONE;
 }
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

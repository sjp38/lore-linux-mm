Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D31E26B02FD
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 10:39:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p204so5705040wmg.3
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:32 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id p1si6700495wrp.296.2017.07.21.07.39.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 07:39:31 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id p204so7229353wmg.1
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:39:31 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/9] mm, page_alloc: simplify zonelist initialization
Date: Fri, 21 Jul 2017 16:39:12 +0200
Message-Id: <20170721143915.14161-7-mhocko@kernel.org>
In-Reply-To: <20170721143915.14161-1-mhocko@kernel.org>
References: <20170721143915.14161-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

build_zonelists gradually builds zonelists from the nearest to the most
distant node. As we do not know how many populated zones we will have in
each node we rely on the _zoneref to terminate initialized part of the
zonelist by a NULL zone. While this is functionally correct it is quite
suboptimal because we cannot allow updaters to race with zonelists
users because they could see an empty zonelist and fail the allocation
or hit the OOM killer in the worst case.

We can do much better, though. We can store the node ordering into an
already existing node_order array and then give this array to
build_zonelists_in_node_order and do the whole initialization at once.
zonelists consumers still might see halfway initialized state but that
should be much more tolerateable because the list will not be empty and
they would either see some zone twice or skip over some zone(s) in the
worst case which shouldn't lead to immediate failures.

While at it let's simplify build_zonelists_node which is rather
confusing now. It gets an index into the zoneref array and returns
the updated index for the next iteration. Let's rename the function
to build_zonerefs_node to better reflect its purpose and give it
zoneref array to update. The function doesn't the index anymore. It
just returns the number of added zones so that the caller can advance
the zonered array start for the next update.

This patch alone doesn't introduce any functional change yet, though, it
is merely a preparatory work for later changes.

Changes since v1
- build_zonelists_node -> build_zonerefs_node and operate directly on
  zonerefs array rather than play tricks with index into the array.
- give build_zonelists_in_node_order nr_nodes to not iterate over all
  MAX_NUMNODES as per Mel

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 81 +++++++++++++++++++++++++++++----------------------------
 1 file changed, 41 insertions(+), 40 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e9aca464f66..0d78dc5a708f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4772,18 +4772,17 @@ static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
  *
  * Add all populated zones of a node to the zonelist.
  */
-static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
-				int nr_zones)
+static int build_zonerefs_node(pg_data_t *pgdat, struct zoneref *zonerefs)
 {
 	struct zone *zone;
 	enum zone_type zone_type = MAX_NR_ZONES;
+	int nr_zones = 0;
 
 	do {
 		zone_type--;
 		zone = pgdat->node_zones + zone_type;
 		if (managed_zone(zone)) {
-			zoneref_set_zone(zone,
-				&zonelist->_zonerefs[nr_zones++]);
+			zoneref_set_zone(zone, &zonerefs[nr_zones++]);
 			check_highest_zone(zone_type);
 		}
 	} while (zone_type);
@@ -4913,17 +4912,24 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
  * This results in maximum locality--normal zone overflows into local
  * DMA zone, if any--but risks exhausting DMA zone.
  */
-static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
+static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
+		unsigned nr_nodes)
 {
-	int j;
-	struct zonelist *zonelist;
+	struct zoneref *zonerefs;
+	int i;
+
+	zonerefs = pgdat->node_zonelists[ZONELIST_FALLBACK]._zonerefs;
+
+	for (i = 0; i < nr_nodes; i++) {
+		int nr_zones;
 
-	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
-	for (j = 0; zonelist->_zonerefs[j].zone != NULL; j++)
-		;
-	j = build_zonelists_node(NODE_DATA(node), zonelist, j);
-	zonelist->_zonerefs[j].zone = NULL;
-	zonelist->_zonerefs[j].zone_idx = 0;
+		pg_data_t *node = NODE_DATA(node_order[i]);
+
+		nr_zones = build_zonerefs_node(node, zonerefs);
+		zonerefs += nr_zones;
+	}
+	zonerefs->zone = NULL;
+	zonerefs->zone_idx = 0;
 }
 
 /*
@@ -4931,13 +4937,14 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
  */
 static void build_thisnode_zonelists(pg_data_t *pgdat)
 {
-	int j;
-	struct zonelist *zonelist;
+	struct zoneref *zonerefs;
+	int nr_zones;
 
-	zonelist = &pgdat->node_zonelists[ZONELIST_NOFALLBACK];
-	j = build_zonelists_node(pgdat, zonelist, 0);
-	zonelist->_zonerefs[j].zone = NULL;
-	zonelist->_zonerefs[j].zone_idx = 0;
+	zonerefs = pgdat->node_zonelists[ZONELIST_NOFALLBACK]._zonerefs;
+	nr_zones = build_zonerefs_node(pgdat, zonerefs);
+	zonerefs += nr_zones;
+	zonerefs->zone = NULL;
+	zonerefs->zone_idx = 0;
 }
 
 /*
@@ -4946,21 +4953,13 @@ static void build_thisnode_zonelists(pg_data_t *pgdat)
  * exhausted, but results in overflowing to remote node while memory
  * may still exist in local DMA zone.
  */
-static int node_order[MAX_NUMNODES];
 
 static void build_zonelists(pg_data_t *pgdat)
 {
-	int i, node, load;
+	static int node_order[MAX_NUMNODES];
+	int node, load, nr_nodes = 0;
 	nodemask_t used_mask;
 	int local_node, prev_node;
-	struct zonelist *zonelist;
-
-	/* initialize zonelists */
-	for (i = 0; i < MAX_ZONELISTS; i++) {
-		zonelist = pgdat->node_zonelists + i;
-		zonelist->_zonerefs[0].zone = NULL;
-		zonelist->_zonerefs[0].zone_idx = 0;
-	}
 
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
@@ -4969,8 +4968,6 @@ static void build_zonelists(pg_data_t *pgdat)
 	nodes_clear(used_mask);
 
 	memset(node_order, 0, sizeof(node_order));
-	i = 0;
-
 	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
 		/*
 		 * We don't want to pressure a particular node.
@@ -4981,11 +4978,12 @@ static void build_zonelists(pg_data_t *pgdat)
 		    node_distance(local_node, prev_node))
 			node_load[node] = load;
 
+		node_order[nr_nodes++] = node;
 		prev_node = node;
 		load--;
-		build_zonelists_in_node_order(pgdat, node);
 	}
 
+	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
 	build_thisnode_zonelists(pgdat);
 }
 
@@ -5014,13 +5012,14 @@ static void setup_min_slab_ratio(void);
 static void build_zonelists(pg_data_t *pgdat)
 {
 	int node, local_node;
-	enum zone_type j;
-	struct zonelist *zonelist;
+	struct zoneref *zonerefs;
+	int nr_zones;
 
 	local_node = pgdat->node_id;
 
-	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
-	j = build_zonelists_node(pgdat, zonelist, 0);
+	zonerefs = pgdat->node_zonelists[ZONELIST_FALLBACK]._zonerefs;
+	nr_zones = build_zonerefs_node(pgdat, zonerefs);
+	zonerefs += nr_zones;
 
 	/*
 	 * Now we build the zonelist so that it contains the zones
@@ -5033,16 +5032,18 @@ static void build_zonelists(pg_data_t *pgdat)
 	for (node = local_node + 1; node < MAX_NUMNODES; node++) {
 		if (!node_online(node))
 			continue;
-		j = build_zonelists_node(NODE_DATA(node), zonelist, j);
+		nr_zones = build_zonerefs_node(NODE_DATA(node), zonerefs);
+		zonerefs += nr_zones;
 	}
 	for (node = 0; node < local_node; node++) {
 		if (!node_online(node))
 			continue;
-		j = build_zonelists_node(NODE_DATA(node), zonelist, j);
+		nr_zones = build_zonerefs_node(NODE_DATA(node), zonerefs);
+		zonerefs += nr_zones;
 	}
 
-	zonelist->_zonerefs[j].zone = NULL;
-	zonelist->_zonerefs[j].zone_idx = 0;
+	zonerefs->zone = NULL;
+	zonerefs->zone_idx = 0;
 }
 
 #endif	/* CONFIG_NUMA */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

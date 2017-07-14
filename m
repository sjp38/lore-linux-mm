Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0FB1440901
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:00:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v60so10625372wrc.7
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:33 -0700 (PDT)
Received: from mail-wr0-f195.google.com (mail-wr0-f195.google.com. [209.85.128.195])
        by mx.google.com with ESMTPS id h68si1651095wma.39.2017.07.14.01.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 01:00:32 -0700 (PDT)
Received: by mail-wr0-f195.google.com with SMTP id 77so11075905wrb.3
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:32 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/9] mm, page_alloc: simplify zonelist initialization
Date: Fri, 14 Jul 2017 10:00:03 +0200
Message-Id: <20170714080006.7250-7-mhocko@kernel.org>
In-Reply-To: <20170714080006.7250-1-mhocko@kernel.org>
References: <20170714080006.7250-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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

This patch alone doesn't introduce any functional change yet, though, it
is merely a preparatory work for later changes.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 42 ++++++++++++++++++------------------------
 1 file changed, 18 insertions(+), 24 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 00e117922b3f..78bd62418380 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4913,17 +4913,20 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
  * This results in maximum locality--normal zone overflows into local
  * DMA zone, if any--but risks exhausting DMA zone.
  */
-static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
+static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order)
 {
-	int j;
 	struct zonelist *zonelist;
+	int i, zoneref_idx = 0;
 
 	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
-	for (j = 0; zonelist->_zonerefs[j].zone != NULL; j++)
-		;
-	j = build_zonelists_node(NODE_DATA(node), zonelist, j);
-	zonelist->_zonerefs[j].zone = NULL;
-	zonelist->_zonerefs[j].zone_idx = 0;
+
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		pg_data_t *node = NODE_DATA(node_order[i]);
+
+		zoneref_idx = build_zonelists_node(node, zonelist, zoneref_idx);
+	}
+	zonelist->_zonerefs[zoneref_idx].zone = NULL;
+	zonelist->_zonerefs[zoneref_idx].zone_idx = 0;
 }
 
 /*
@@ -4931,13 +4934,13 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
  */
 static void build_thisnode_zonelists(pg_data_t *pgdat)
 {
-	int j;
 	struct zonelist *zonelist;
+	int zoneref_idx = 0;
 
 	zonelist = &pgdat->node_zonelists[ZONELIST_NOFALLBACK];
-	j = build_zonelists_node(pgdat, zonelist, 0);
-	zonelist->_zonerefs[j].zone = NULL;
-	zonelist->_zonerefs[j].zone_idx = 0;
+	zoneref_idx = build_zonelists_node(pgdat, zonelist, zoneref_idx);
+	zonelist->_zonerefs[zoneref_idx].zone = NULL;
+	zonelist->_zonerefs[zoneref_idx].zone_idx = 0;
 }
 
 /*
@@ -4946,21 +4949,13 @@ static void build_thisnode_zonelists(pg_data_t *pgdat)
  * exhausted, but results in overflowing to remote node while memory
  * may still exist in local DMA zone.
  */
-static int node_order[MAX_NUMNODES];
 
 static void build_zonelists(pg_data_t *pgdat)
 {
-	int i, node, load;
+	static int node_order[MAX_NUMNODES];
+	int node, load, i = 0;
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
@@ -4969,8 +4964,6 @@ static void build_zonelists(pg_data_t *pgdat)
 	nodes_clear(used_mask);
 
 	memset(node_order, 0, sizeof(node_order));
-	i = 0;
-
 	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
 		/*
 		 * We don't want to pressure a particular node.
@@ -4981,11 +4974,12 @@ static void build_zonelists(pg_data_t *pgdat)
 		    node_distance(local_node, prev_node))
 			node_load[node] = load;
 
+		node_order[i++] = node;
 		prev_node = node;
 		load--;
-		build_zonelists_in_node_order(pgdat, node);
 	}
 
+	build_zonelists_in_node_order(pgdat, node_order);
 	build_thisnode_zonelists(pgdat);
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

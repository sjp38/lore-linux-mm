Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9523E8E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 04:51:12 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id x26so1071471pgc.5
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 01:51:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor34345650pfj.35.2018.12.20.01.51.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 01:51:10 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv2 1/3] mm/numa: change the topo of build_zonelist_xx()
Date: Thu, 20 Dec 2018 17:50:37 +0800
Message-Id: <1545299439-31370-2-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
References: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

The current build_zonelist_xx func relies on pgdat instance to build
zonelist, if a numa node is offline, there will no pgdat instance for it.
But in some case, there is still requirement for zonelist of offline node,
especially with nr_cpus option.
This patch change these funcs topo to ease the building of zonelist for
offline nodes.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
---
 mm/page_alloc.c | 44 +++++++++++++++++++++-----------------------
 1 file changed, 21 insertions(+), 23 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc4..17dbf6e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5049,7 +5049,7 @@ static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
  *
  * Add all populated zones of a node to the zonelist.
  */
-static int build_zonerefs_node(pg_data_t *pgdat, struct zoneref *zonerefs)
+static int build_zonerefs_node(int nid, struct zoneref *zonerefs)
 {
 	struct zone *zone;
 	enum zone_type zone_type = MAX_NR_ZONES;
@@ -5057,7 +5057,7 @@ static int build_zonerefs_node(pg_data_t *pgdat, struct zoneref *zonerefs)
 
 	do {
 		zone_type--;
-		zone = pgdat->node_zones + zone_type;
+		zone = NODE_DATA(nid)->node_zones + zone_type;
 		if (managed_zone(zone)) {
 			zoneref_set_zone(zone, &zonerefs[nr_zones++]);
 			check_highest_zone(zone_type);
@@ -5186,20 +5186,20 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
  * This results in maximum locality--normal zone overflows into local
  * DMA zone, if any--but risks exhausting DMA zone.
  */
-static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
-		unsigned nr_nodes)
+static void build_zonelists_in_node_order(struct zonelist *node_zonelists,
+	int *node_order, unsigned int nr_nodes)
 {
 	struct zoneref *zonerefs;
 	int i;
 
-	zonerefs = pgdat->node_zonelists[ZONELIST_FALLBACK]._zonerefs;
+	zonerefs = node_zonelists[ZONELIST_FALLBACK]._zonerefs;
 
 	for (i = 0; i < nr_nodes; i++) {
 		int nr_zones;
 
 		pg_data_t *node = NODE_DATA(node_order[i]);
 
-		nr_zones = build_zonerefs_node(node, zonerefs);
+		nr_zones = build_zonerefs_node(node->node_id, zonerefs);
 		zonerefs += nr_zones;
 	}
 	zonerefs->zone = NULL;
@@ -5209,13 +5209,14 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
 /*
  * Build gfp_thisnode zonelists
  */
-static void build_thisnode_zonelists(pg_data_t *pgdat)
+static void build_thisnode_zonelists(struct zonelist *node_zonelists,
+	int nid)
 {
 	struct zoneref *zonerefs;
 	int nr_zones;
 
-	zonerefs = pgdat->node_zonelists[ZONELIST_NOFALLBACK]._zonerefs;
-	nr_zones = build_zonerefs_node(pgdat, zonerefs);
+	zonerefs = node_zonelists[ZONELIST_NOFALLBACK]._zonerefs;
+	nr_zones = build_zonerefs_node(nid, zonerefs);
 	zonerefs += nr_zones;
 	zonerefs->zone = NULL;
 	zonerefs->zone_idx = 0;
@@ -5228,15 +5229,14 @@ static void build_thisnode_zonelists(pg_data_t *pgdat)
  * may still exist in local DMA zone.
  */
 
-static void build_zonelists(pg_data_t *pgdat)
+static void build_zonelists(struct zonelist *node_zonelists, int local_node)
 {
 	static int node_order[MAX_NUMNODES];
 	int node, load, nr_nodes = 0;
 	nodemask_t used_mask;
-	int local_node, prev_node;
+	int prev_node;
 
 	/* NUMA-aware ordering of nodes */
-	local_node = pgdat->node_id;
 	load = nr_online_nodes;
 	prev_node = local_node;
 	nodes_clear(used_mask);
@@ -5257,8 +5257,8 @@ static void build_zonelists(pg_data_t *pgdat)
 		load--;
 	}
 
-	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
-	build_thisnode_zonelists(pgdat);
+	build_zonelists_in_node_order(node_zonelists, node_order, nr_nodes);
+	build_thisnode_zonelists(node_zonelists, local_node);
 }
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
@@ -5283,16 +5283,14 @@ static void setup_min_unmapped_ratio(void);
 static void setup_min_slab_ratio(void);
 #else	/* CONFIG_NUMA */
 
-static void build_zonelists(pg_data_t *pgdat)
+static void build_zonelists(struct zonelist *node_zonelists, int local_node)
 {
 	int node, local_node;
 	struct zoneref *zonerefs;
 	int nr_zones;
 
-	local_node = pgdat->node_id;
-
-	zonerefs = pgdat->node_zonelists[ZONELIST_FALLBACK]._zonerefs;
-	nr_zones = build_zonerefs_node(pgdat, zonerefs);
+	zonerefs = node_zonelists[ZONELIST_FALLBACK]._zonerefs;
+	nr_zones = build_zonerefs_node(local_node, zonerefs);
 	zonerefs += nr_zones;
 
 	/*
@@ -5306,13 +5304,13 @@ static void build_zonelists(pg_data_t *pgdat)
 	for (node = local_node + 1; node < MAX_NUMNODES; node++) {
 		if (!node_online(node))
 			continue;
-		nr_zones = build_zonerefs_node(NODE_DATA(node), zonerefs);
+		nr_zones = build_zonerefs_node(node, zonerefs);
 		zonerefs += nr_zones;
 	}
 	for (node = 0; node < local_node; node++) {
 		if (!node_online(node))
 			continue;
-		nr_zones = build_zonerefs_node(NODE_DATA(node), zonerefs);
+		nr_zones = build_zonerefs_node(node, zonerefs);
 		zonerefs += nr_zones;
 	}
 
@@ -5359,12 +5357,12 @@ static void __build_all_zonelists(void *data)
 	 * building zonelists is fine - no need to touch other nodes.
 	 */
 	if (self && !node_online(self->node_id)) {
-		build_zonelists(self);
+		build_zonelists(self->node_zonelists, self->node_id);
 	} else {
 		for_each_online_node(nid) {
 			pg_data_t *pgdat = NODE_DATA(nid);
 
-			build_zonelists(pgdat);
+			build_zonelists(pgdat->node_zonelists, pgdat->node_id);
 		}
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
-- 
2.7.4

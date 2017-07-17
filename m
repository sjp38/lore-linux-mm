Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 39CFE6B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:06:44 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p204so18179322wmg.3
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 23:06:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si8993221wmg.72.2017.07.16.23.06.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 16 Jul 2017 23:06:42 -0700 (PDT)
Date: Mon, 17 Jul 2017 08:06:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/9] mm, page_alloc: simplify zonelist initialization
Message-ID: <20170717060639.GA7397@dhcp22.suse.cz>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-7-mhocko@kernel.org>
 <20170714124645.i3duhuie6cczlybr@suse.de>
 <20170714130242.GQ2618@dhcp22.suse.cz>
 <20170714141823.2j7t37t6zdzdf3sv@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170714141823.2j7t37t6zdzdf3sv@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Fri 14-07-17 15:18:23, Mel Gorman wrote:
> On Fri, Jul 14, 2017 at 03:02:42PM +0200, Michal Hocko wrote:
[...]
> > What do you think about this on top?
> > ---
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 49bade7ff049..3b98524c04ec 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4913,20 +4913,21 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
> >   * This results in maximum locality--normal zone overflows into local
> >   * DMA zone, if any--but risks exhausting DMA zone.
> >   */
> > -static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order)
> > +static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
> > +		unsigned nr_nodes)
> >  {
> >  	struct zonelist *zonelist;
> > -	int i, zoneref_idx = 0;
> > +	int i, nr_zones = 0;
> >  
> >  	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
> >  
> > -	for (i = 0; i < MAX_NUMNODES; i++) {
> > +	for (i = 0; i < nr_nodes; i++) {
> 
> The first iteration is then -- for (i = 0; i < 0; i++)

find_next_best_node always returns at least one node (the local one) so
I believe that nr_nodes should never be 0.

> Fairly sure that's not what you meant.
> 
> 
> >  		pg_data_t *node = NODE_DATA(node_order[i]);
> >  
> > -		zoneref_idx = build_zonelists_node(node, zonelist, zoneref_idx);
> > +		nr_zones = build_zonelists_node(node, zonelist, nr_zones);
> 
> I meant converting build_zonelists_node and passing in &nr_zones and
> returning false when an empty node is encountered. In this context,
> it's also not about zones, it really is nr_zonerefs. Rename nr_zones in
> build_zonelists_node as well.

hmm, why don't we rather make it zonerefs based then. Something
like the following?
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b98524c04ec..01e67e629351 100644
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
@@ -4916,18 +4915,21 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
 		unsigned nr_nodes)
 {
-	struct zonelist *zonelist;
-	int i, nr_zones = 0;
+	struct zoneref *zonerefs;
+	int i;
 
-	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
+	zonerefs = pgdat->node_zonelists[ZONELIST_FALLBACK]._zonerefs;
 
 	for (i = 0; i < nr_nodes; i++) {
+		int nr_zones;
+
 		pg_data_t *node = NODE_DATA(node_order[i]);
 
-		nr_zones = build_zonelists_node(node, zonelist, nr_zones);
+		nr_zones = build_zonerefs_node(node, zonerefs);
+		zonerefs += nr_zones;
 	}
-	zonelist->_zonerefs[nr_zones].zone = NULL;
-	zonelist->_zonerefs[nr_zones].zone_idx = 0;
+	zonerefs->zone = NULL;
+	zonerefs->zone_idx = 0;
 }
 
 /*
@@ -4935,13 +4937,14 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
  */
 static void build_thisnode_zonelists(pg_data_t *pgdat)
 {
-	struct zonelist *zonelist;
-	int nr_zones = 0;
+	struct zoneref *zonerefs;
+	int nr_zones;
 
-	zonelist = &pgdat->node_zonelists[ZONELIST_NOFALLBACK];
-	nr_zones = build_zonelists_node(pgdat, zonelist, nr_zones);
-	zonelist->_zonerefs[nr_zones].zone = NULL;
-	zonelist->_zonerefs[nr_zones].zone_idx = 0;
+	zonerefs = pgdat->node_zonelists[ZONELIST_NOFALLBACK]._zonerefs;
+	nr_zones = build_zonerefs_node(pgdat, zonerefs);
+	zonerefs += nr_zones;
+	zonerefs->zone = NULL;
+	zonerefs->zone_idx = 0;
 }
 
 /*
@@ -5009,13 +5012,13 @@ static void setup_min_slab_ratio(void);
 static void build_zonelists(pg_data_t *pgdat)
 {
 	int node, local_node;
-	enum zone_type j;
-	struct zonelist *zonelist;
+	struct zoneref *zonerefs;
 
 	local_node = pgdat->node_id;
 
-	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
-	j = build_zonelists_node(pgdat, zonelist, 0);
+	zonrefs = pgdat->node_zonelists[ZONELIST_FALLBACK]._zonerefs;
+	nr_zones = build_zonerefs_node(pgdat, zonerefs);
+	zonerefs += nr_zones;
 
 	/*
 	 * Now we build the zonelist so that it contains the zones
@@ -5028,16 +5031,18 @@ static void build_zonelists(pg_data_t *pgdat)
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
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

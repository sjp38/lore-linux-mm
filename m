Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 844EA440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 09:02:49 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p204so9119060wmg.3
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 06:02:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t206si2200170wmg.119.2017.07.14.06.02.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 06:02:48 -0700 (PDT)
Date: Fri, 14 Jul 2017 15:02:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/9] mm, page_alloc: simplify zonelist initialization
Message-ID: <20170714130242.GQ2618@dhcp22.suse.cz>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-7-mhocko@kernel.org>
 <20170714124645.i3duhuie6cczlybr@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170714124645.i3duhuie6cczlybr@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Fri 14-07-17 13:46:46, Mel Gorman wrote:
> On Fri, Jul 14, 2017 at 10:00:03AM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > build_zonelists gradually builds zonelists from the nearest to the most
> > distant node. As we do not know how many populated zones we will have in
> > each node we rely on the _zoneref to terminate initialized part of the
> > zonelist by a NULL zone. While this is functionally correct it is quite
> > suboptimal because we cannot allow updaters to race with zonelists
> > users because they could see an empty zonelist and fail the allocation
> > or hit the OOM killer in the worst case.
> > 
> > We can do much better, though. We can store the node ordering into an
> > already existing node_order array and then give this array to
> > build_zonelists_in_node_order and do the whole initialization at once.
> > zonelists consumers still might see halfway initialized state but that
> > should be much more tolerateable because the list will not be empty and
> > they would either see some zone twice or skip over some zone(s) in the
> > worst case which shouldn't lead to immediate failures.
> > 
> > This patch alone doesn't introduce any functional change yet, though, it
> > is merely a preparatory work for later changes.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/page_alloc.c | 42 ++++++++++++++++++------------------------
> >  1 file changed, 18 insertions(+), 24 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 00e117922b3f..78bd62418380 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4913,17 +4913,20 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
> >   * This results in maximum locality--normal zone overflows into local
> >   * DMA zone, if any--but risks exhausting DMA zone.
> >   */
> > -static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
> > +static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order)
> >  {
> > -	int j;
> >  	struct zonelist *zonelist;
> > +	int i, zoneref_idx = 0;
> >  
> >  	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
> > -	for (j = 0; zonelist->_zonerefs[j].zone != NULL; j++)
> > -		;
> > -	j = build_zonelists_node(NODE_DATA(node), zonelist, j);
> > -	zonelist->_zonerefs[j].zone = NULL;
> > -	zonelist->_zonerefs[j].zone_idx = 0;
> > +
> > +	for (i = 0; i < MAX_NUMNODES; i++) {
> > +		pg_data_t *node = NODE_DATA(node_order[i]);
> > +
> > +		zoneref_idx = build_zonelists_node(node, zonelist, zoneref_idx);
> > +	}
> 
> The naming here is weird to say the least and makes this a lot more
> confusing than it needs to be. Primarily, it's because the zoneref_idx
> parameter gets renamed to nr_zones in build_zonelists_node where it's
> nothing to do with the number of zones at all.

you are right. I just wanted to get rid of `j' and didn't realize
nr_zones would fit much better.

> It also iterates for longer than it needs to. MAX_NUMNODES can be a
> large value of mostly empty nodes but it happily goes through them
> anyway. Pass zoneref_idx in as a pointer that is updated by the function
> and use the return value to break the loop when an empty node is
> encountered?
> 
> > +	zonelist->_zonerefs[zoneref_idx].zone = NULL;
> > +	zonelist->_zonerefs[zoneref_idx].zone_idx = 0;
> >  }
> >  
> 
> It *might* be safer given the next patch to zero out the remainder of
> the _zonerefs to that there is no combination of node add/remove that has
> an iterator working with a semi-valid _zoneref which is beyond the last
> correct value. It *should* be safe as the very last entry will always
> be null but if you don't zero it out, it is possible for iterators to be
> working beyond the "end" of the zonelist for a short window.

yes that is true but there will always be terminating NULL zone and I
found that acceptable. It is basically the same thing as accessing an
empty zone or a zone twice. Or do you think this is absolutely necessary
to handle?

> Otherwise think it's ok including my stupid comment about node_order
> stack usage.

What do you think about this on top?
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 49bade7ff049..3b98524c04ec 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4913,20 +4913,21 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
  * This results in maximum locality--normal zone overflows into local
  * DMA zone, if any--but risks exhausting DMA zone.
  */
-static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order)
+static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
+		unsigned nr_nodes)
 {
 	struct zonelist *zonelist;
-	int i, zoneref_idx = 0;
+	int i, nr_zones = 0;
 
 	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
 
-	for (i = 0; i < MAX_NUMNODES; i++) {
+	for (i = 0; i < nr_nodes; i++) {
 		pg_data_t *node = NODE_DATA(node_order[i]);
 
-		zoneref_idx = build_zonelists_node(node, zonelist, zoneref_idx);
+		nr_zones = build_zonelists_node(node, zonelist, nr_zones);
 	}
-	zonelist->_zonerefs[zoneref_idx].zone = NULL;
-	zonelist->_zonerefs[zoneref_idx].zone_idx = 0;
+	zonelist->_zonerefs[nr_zones].zone = NULL;
+	zonelist->_zonerefs[nr_zones].zone_idx = 0;
 }
 
 /*
@@ -4935,12 +4936,12 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order)
 static void build_thisnode_zonelists(pg_data_t *pgdat)
 {
 	struct zonelist *zonelist;
-	int zoneref_idx = 0;
+	int nr_zones = 0;
 
 	zonelist = &pgdat->node_zonelists[ZONELIST_NOFALLBACK];
-	zoneref_idx = build_zonelists_node(pgdat, zonelist, zoneref_idx);
-	zonelist->_zonerefs[zoneref_idx].zone = NULL;
-	zonelist->_zonerefs[zoneref_idx].zone_idx = 0;
+	nr_zones = build_zonelists_node(pgdat, zonelist, nr_zones);
+	zonelist->_zonerefs[nr_zones].zone = NULL;
+	zonelist->_zonerefs[nr_zones].zone_idx = 0;
 }
 
 /*
@@ -4979,7 +4980,7 @@ static void build_zonelists(pg_data_t *pgdat)
 		load--;
 	}
 
-	build_zonelists_in_node_order(pgdat, node_order);
+	build_zonelists_in_node_order(pgdat, node_order, i);
 	build_thisnode_zonelists(pgdat);
 }
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB716B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 03:19:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l81so1841167wmg.8
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 00:19:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x192si1201873wme.155.2017.07.20.00.19.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 00:19:37 -0700 (PDT)
Date: Thu, 20 Jul 2017 09:19:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/9] mm, page_alloc: simplify zonelist initialization
Message-ID: <20170720071935.GC9058@dhcp22.suse.cz>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-7-mhocko@kernel.org>
 <d23a3570-e39c-d708-c9d1-80258d45a97f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d23a3570-e39c-d708-c9d1-80258d45a97f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 20-07-17 08:55:42, Vlastimil Babka wrote:
> On 07/14/2017 10:00 AM, Michal Hocko wrote:
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
> 
> I've collected the fold-ups from this thread and looked at the result as
> single patch. Sems OK, just two things:
> - please rename variable "i" in build_zonelists() to e.g. "nr_nodes"
> - the !CONFIG_NUMA variant of build_zonelists() won't build, because it
> doesn't declare nr_zones variable

Thanks! I will fold this in.
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c0d3e8eeb150..6f192405e469 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4957,7 +4957,7 @@ static void build_thisnode_zonelists(pg_data_t *pgdat)
 static void build_zonelists(pg_data_t *pgdat)
 {
 	static int node_order[MAX_NUMNODES];
-	int node, load, i = 0;
+	int node, load, nr_nodes = 0;
 	nodemask_t used_mask;
 	int local_node, prev_node;
 
@@ -4978,12 +4978,12 @@ static void build_zonelists(pg_data_t *pgdat)
 		    node_distance(local_node, prev_node))
 			node_load[node] = load;
 
-		node_order[i++] = node;
+		node_order[nr_nodes++] = node;
 		prev_node = node;
 		load--;
 	}
 
-	build_zonelists_in_node_order(pgdat, node_order, i);
+	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
 	build_thisnode_zonelists(pgdat);
 }
 
@@ -5013,10 +5013,11 @@ static void build_zonelists(pg_data_t *pgdat)
 {
 	int node, local_node;
 	struct zoneref *zonerefs;
+	int nr_zones;
 
 	local_node = pgdat->node_id;
 
-	zonrefs = pgdat->node_zonelists[ZONELIST_FALLBACK]._zonerefs;
+	zonerefs = pgdat->node_zonelists[ZONELIST_FALLBACK]._zonerefs;
 	nr_zones = build_zonerefs_node(pgdat, zonerefs);
 	zonerefs += nr_zones;
 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3D66828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:58:52 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id js8so55823305lbc.2
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 03:58:52 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id vo2si6572771wjb.79.2016.06.23.03.58.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 03:58:51 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 448C898BAB
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 10:58:51 +0000 (UTC)
Date: Thu, 23 Jun 2016 11:58:49 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/27] mm, vmscan: Begin reclaiming pages on a per-node
 basis
Message-ID: <20160623105849.GS1868@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-5-git-send-email-mgorman@techsingularity.net>
 <6eecdf50-7880-2bfe-5519-004a4beeece6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <6eecdf50-7880-2bfe-5519-004a4beeece6@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 22, 2016 at 04:04:34PM +0200, Vlastimil Babka wrote:
> >-static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >+static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
> >+		enum zone_type classzone_idx)
> > {
> > 	struct zoneref *z;
> > 	struct zone *zone;
> > 	unsigned long nr_soft_reclaimed;
> > 	unsigned long nr_soft_scanned;
> > 	gfp_t orig_mask;
> >-	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
> >
> > 	/*
> > 	 * If the number of buffer_heads in the machine exceeds the maximum
> >@@ -2560,15 +2579,20 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >
> > 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > 					gfp_zone(sc->gfp_mask), sc->nodemask) {
> 
> Using sc->reclaim_idx could be faster/nicer here than gfp_zone()?

Yes, then the reclaim_idx and classzone_idx needs to be updated if
buffer_heads_over_limit in the check above but that is better anyway.

> Although after "mm, vmscan: Update classzone_idx if buffer_heads_over_limit"
> there would need to be a variable for the highmem adjusted value - maybe
> reuse "requested_highidx"? Not important though.
> 

I think it's ok in the buffer_heads_over_limit case to reclaim
from more zones than requested. It may require another pass through
do_try_to_free_pages if a low zone was not reclaimed and required by the
caller but that's ok and expected if there are too many buffer_heads.

> >-		enum zone_type classzone_idx;
> >-
> > 		if (!populated_zone(zone))
> > 			continue;
> >
> >-		classzone_idx = requested_highidx;
> >+		/*
> >+		 * Note that reclaim_idx does not change as it is the highest
> >+		 * zone reclaimed from which for empty zones is a no-op but
> >+		 * classzone_idx is used by shrink_node to test if the slabs
> >+		 * should be shrunk on a given node.
> >+		 */
> > 		while (!populated_zone(zone->zone_pgdat->node_zones +
> >-							classzone_idx))
> >+							classzone_idx)) {
> > 			classzone_idx--;
> >+			continue;
> >+		}
> >
> > 		/*
> > 		 * Take care memory controller reclaiming has small influence
> >@@ -2594,8 +2618,8 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> > 			 */
> > 			if (IS_ENABLED(CONFIG_COMPACTION) &&
> > 			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
> >-			    zonelist_zone_idx(z) <= requested_highidx &&
> >-			    compaction_ready(zone, sc->order, requested_highidx)) {
> >+			    zonelist_zone_idx(z) <= classzone_idx &&
> >+			    compaction_ready(zone, sc->order, classzone_idx)) {
> > 				sc->compaction_ready = true;
> > 				continue;
> > 			}
> >@@ -2615,7 +2639,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> > 			/* need some check for avoid more shrink_zone() */
> > 		}
> >
> >-		shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
> >+		shrink_node(zone->zone_pgdat, sc, classzone_idx);
> > 	}
> >
> > 	/*
> >@@ -2647,6 +2671,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> > 	int initial_priority = sc->priority;
> > 	unsigned long total_scanned = 0;
> > 	unsigned long writeback_threshold;
> >+	enum zone_type classzone_idx = sc->reclaim_idx;
> 
> Hmm, try_to_free_mem_cgroup_pages() seems to call this with sc->reclaim_idx
> not explicitly inirialized (e.g. 0). And shrink_all_memory() as well. I
> probably didn't check them in v6 and pointed out only try_to_free_pages()
> (which is now OK), sorry.
> 

That gets fixed in "mm, memcg: move memcg limit enforcement from zones
to nodes" but I can move the hunk to this patch to make bisection a
little easier.

> > retry:
> > 	delayacct_freepages_start();
> >
> >@@ -2657,7 +2682,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> > 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
> > 				sc->priority);
> > 		sc->nr_scanned = 0;
> >-		shrink_zones(zonelist, sc);
> >+		shrink_zones(zonelist, sc, classzone_idx);
> 
> Looks like classzone_idx here is only used here to pass to shrink_zones()
> unchanged, which means it can just use it directly without a new param?
> 

Yes

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id B19D16B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 10:47:55 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id js8so28516251lbc.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:47:55 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id 18si17257293wml.98.2016.06.16.07.47.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 07:47:54 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id EFBA499217
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 14:47:53 +0000 (UTC)
Date: Thu, 16 Jun 2016 15:47:52 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 12/27] mm, vmscan: Make shrink_node decisions more
 node-centric
Message-ID: <20160616144752.GI1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-13-git-send-email-mgorman@techsingularity.net>
 <a411d98e-acfb-9658-22b1-4bbefb1e00d7@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <a411d98e-acfb-9658-22b1-4bbefb1e00d7@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 16, 2016 at 03:35:15PM +0200, Vlastimil Babka wrote:
> On 06/09/2016 08:04 PM, Mel Gorman wrote:
> >Earlier patches focused on having direct reclaim and kswapd use data that
> >is node-centric for reclaiming but shrink_node() itself still uses too much
> >zone information. This patch removes unnecessary zone-based information
> >with the most important decision being whether to continue reclaim or
> >not. Some memcg APIs are adjusted as a result even though memcg itself
> >still uses some zone information.
> >
> >Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> [...]
> 
> >@@ -2372,21 +2374,27 @@ static inline bool should_continue_reclaim(struct zone *zone,
> > 	 * inactive lists are large enough, continue reclaiming
> > 	 */
> > 	pages_for_compaction = (2UL << sc->order);
> >-	inactive_lru_pages = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE);
> >+	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
> > 	if (get_nr_swap_pages() > 0)
> >-		inactive_lru_pages += node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
> >+		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
> > 	if (sc->nr_reclaimed < pages_for_compaction &&
> > 			inactive_lru_pages > pages_for_compaction)
> > 		return true;
> >
> > 	/* If compaction would go ahead or the allocation would succeed, stop */
> >-	switch (compaction_suitable(zone, sc->order, 0, 0)) {
> >-	case COMPACT_PARTIAL:
> >-	case COMPACT_CONTINUE:
> >-		return false;
> >-	default:
> >-		return true;
> >+	for (z = 0; z <= sc->reclaim_idx; z++) {
> >+		struct zone *zone = &pgdat->node_zones[z];
> >+
> >+		switch (compaction_suitable(zone, sc->order, 0, 0)) {
> 
> Using 0 for classzone_idx here was sort of OK when each zone was reclaimed
> separately, as a Normal allocation not passing appropriate classzone_idx
> (and thus subtracting lowmem reserve from free pages) means that a false
> COMPACT_PARTIAL (or COMPACT_CONTINUE) could be returned for e.g. DMA zone.
> It means a premature end of reclaim for this single zone, which is
> relatively small anyway, so no big deal (and we might avoid useless
> over-reclaim, when even reclaiming everything wouldn't get us above the
> lowmem_reserve).
> 
> But in node-centric reclaim, such premature "return false" from a DMA zone
> stops reclaiming the whole node. So I think we should involve the real
> classzone_idx here.
> 

Fair point although for compaction, it'll occur for a marginal corner
case. Premature allowed compaction for ZONE_DMA is unfortunate but
bizarre to think there would be a high-order allocation restricted to
just that zone too.

I'll pass in sc->reclaim_idx as it represents the allocating order. That
highlights that direct reclaim was not setting reclaim_idx but that's
been corrected.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

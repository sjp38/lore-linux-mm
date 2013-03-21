Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 607246B0027
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 14:14:00 -0400 (EDT)
Date: Thu, 21 Mar 2013 18:13:56 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/10] mm: vmscan: Move logic from balance_pgdat() to
 kswapd_shrink_zone()
Message-ID: <20130321181356.GO1878@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-11-git-send-email-mgorman@suse.de>
 <20130321171804.GW6094@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130321171804.GW6094@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 21, 2013 at 06:18:04PM +0100, Michal Hocko wrote:
> On Sun 17-03-13 13:04:16, Mel Gorman wrote:
> > +
> > +	/*
> > +	 * Kswapd reclaims only single pages with compaction enabled. Trying
> > +	 * too hard to reclaim until contiguous free pages have become
> > +	 * available can hurt performance by evicting too much useful data
> > +	 * from memory. Do not reclaim more than needed for compaction.
> > +	 */
> > +	if (IS_ENABLED(CONFIG_COMPACTION) && sc->order &&
> > +			compaction_suitable(zone, sc->order) !=
> > +				COMPACT_SKIPPED)
> > +		testorder = 0;
> > +
> > +	/*
> > +	 * We put equal pressure on every zone, unless one zone has way too
> > +	 * many pages free already. The "too many pages" is defined as the
> > +	 * high wmark plus a "gap" where the gap is either the low
> > +	 * watermark or 1% of the zone, whichever is smaller.
> > +	 */
> > +	balance_gap = min(low_wmark_pages(zone),
> > +		(zone->managed_pages + KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
> > +		KSWAPD_ZONE_BALANCE_GAP_RATIO);
> > +
> > +	/*
> > +	 * If there is no low memory pressure or the zone is balanced then no
> > +	 * reclaim is necessary
> > +	 */
> > +	lowmem_pressure = (buffer_heads_over_limit && is_highmem(zone));
> > +	if (!(lowmem_pressure || !zone_balanced(zone, testorder,
> > +						balance_gap, classzone_idx)))
> 
> if (!lowmem_pressure && zone_balanced) would be less cryptic I guess
> 

It would.

> > +		return true;
> > +
> >  	shrink_zone(zone, sc);
> >  
> >  	/*
> > @@ -2689,6 +2724,16 @@ static bool kswapd_shrink_zone(struct zone *zone,
> >  
> >  	zone_clear_flag(zone, ZONE_WRITEBACK);
> >  
> > +	/*
> > +	 * If a zone reaches its high watermark, consider it to be no longer
> > +	 * congested. It's possible there are dirty pages backed by congested
> > +	 * BDIs but as pressure is relieved, speculatively avoid congestion
> > +	 * waits.
> > +	 */
> > +	if (!zone->all_unreclaimable &&
> > +	    zone_balanced(zone, testorder, 0, classzone_idx))
> > +		zone_clear_flag(zone, ZONE_CONGESTED);
> > +
> >  	return sc->nr_scanned >= sc->nr_to_reclaim;
> >  }
> >  
> > @@ -2821,8 +2866,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> >  		 */
> >  		for (i = 0; i <= end_zone; i++) {
> >  			struct zone *zone = pgdat->node_zones + i;
> > -			int testorder;
> > -			unsigned long balance_gap;
> >  
> >  			if (!populated_zone(zone))
> >  				continue;
> > @@ -2843,61 +2886,16 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> >  			sc.nr_reclaimed += nr_soft_reclaimed;
> >  
> >  			/*
> > -			 * We put equal pressure on every zone, unless
> > -			 * one zone has way too many pages free
> > -			 * already. The "too many pages" is defined
> > -			 * as the high wmark plus a "gap" where the
> > -			 * gap is either the low watermark or 1%
> > -			 * of the zone, whichever is smaller.
> > -			 */
> > -			balance_gap = min(low_wmark_pages(zone),
> > -				(zone->managed_pages +
> > -					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
> > -				KSWAPD_ZONE_BALANCE_GAP_RATIO);
> > -			/*
> > -			 * Kswapd reclaims only single pages with compaction
> > -			 * enabled. Trying too hard to reclaim until contiguous
> > -			 * free pages have become available can hurt performance
> > -			 * by evicting too much useful data from memory.
> > -			 * Do not reclaim more than needed for compaction.
> > +			 * There should be no need to raise the scanning
> > +			 * priority if enough pages are already being scanned
> > +			 * that that high watermark would be met at 100%
> > +			 * efficiency.
> >  			 */
> > -			testorder = order;
> > -			if (IS_ENABLED(CONFIG_COMPACTION) && order &&
> > -					compaction_suitable(zone, order) !=
> > -						COMPACT_SKIPPED)
> > -				testorder = 0;
> > -
> > -			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
> > -			    !zone_balanced(zone, testorder,
> > -					   balance_gap, end_zone)) {
> > -				/*
> > -				 * There should be no need to raise the
> > -				 * scanning priority if enough pages are
> > -				 * already being scanned that that high
> > -				 * watermark would be met at 100% efficiency.
> > -				 */
> > -				if (kswapd_shrink_zone(zone, &sc,
> > +			if (kswapd_shrink_zone(zone, end_zone, &sc,
> >  						lru_pages, shrinking_slab))
> >  					raise_priority = false;
> >  
> > -				nr_to_reclaim += sc.nr_to_reclaim;
> > -			}
> > -
> > -			if (zone->all_unreclaimable) {
> > -				if (end_zone && end_zone == i)
> > -					end_zone--;
> > -				continue;
> > -			}
> > -
> > -			if (zone_balanced(zone, testorder, 0, end_zone))
> > -				/*
> > -				 * If a zone reaches its high watermark,
> > -				 * consider it to be no longer congested. It's
> > -				 * possible there are dirty pages backed by
> > -				 * congested BDIs but as pressure is relieved,
> > -				 * speculatively avoid congestion waits
> > -				 */
> > -				zone_clear_flag(zone, ZONE_CONGESTED);
> > +			nr_to_reclaim += sc.nr_to_reclaim;
> >  		}
> 
> nr_to_reclaim is updated if the zone is balanced an no reclaim is done
> which break compaction condition AFAICS.
> 

True, it only makes sense to account for the pages it actually attempted
to reclaim. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

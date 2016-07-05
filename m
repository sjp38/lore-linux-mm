Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1F46B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 06:14:10 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so84549174wma.3
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 03:14:10 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id b68si479232wmi.95.2016.07.05.03.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jul 2016 03:14:08 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id B09321C15AF
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 11:14:07 +0100 (IST)
Date: Tue, 5 Jul 2016 11:14:05 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 03/31] mm, vmscan: move LRU lists to node
Message-ID: <20160705101405.GF11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-4-git-send-email-mgorman@techsingularity.net>
 <20160705011957.GB28164@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160705011957.GB28164@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 05, 2016 at 10:19:57AM +0900, Minchan Kim wrote:
> On Fri, Jul 01, 2016 at 09:01:11PM +0100, Mel Gorman wrote:
> > This moves the LRU lists from the zone to the node and related data such
> > as counters, tracing, congestion tracking and writeback tracking.
> > Unfortunately, due to reclaim and compaction retry logic, it is necessary
> > to account for the number of LRU pages on both zone and node logic.  Most
> > reclaim logic is based on the node counters but the retry logic uses the
> > zone counters which do not distinguish inactive and inactive sizes.  It
> 
>                                                       active
> 

Fixed.

> > @@ -352,12 +352,12 @@ static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
> >  	 * we have to be prepared to initialize lruvec->zone here;
> 
>                                                 lruvec->pgdat
> 

Fixed.

> > @@ -357,13 +360,6 @@ struct zone {
> >  #ifdef CONFIG_NUMA
> >  	int node;
> >  #endif
> > -
> > -	/*
> > -	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
> > -	 * this zone's LRU.  Maintained by the pageout code.
> > -	 */
> > -	unsigned int inactive_ratio;
> > -
> >  	struct pglist_data	*zone_pgdat;
> >  	struct per_cpu_pageset __percpu *pageset;
> >  
> > @@ -495,9 +491,6 @@ struct zone {
> >  
> >  	/* Write-intensive fields used by page reclaim */
> 
> trivial:
> We moved lru_lock and lruvec to pgdat so I'm not sure we need ZONE_PADDING,
> still.
> 

It still separates the page allocator structures from compaction and
vmstats. The comment is misleading so I added a patch to clarify what
the padding is doing.

> >  
> > -	/* Fields commonly accessed by the page reclaim scanner */
> > -	struct lruvec		lruvec;
> > -
> >  	/*
> >  	 * When free pages are below this point, additional steps are taken
> >  	 * when reading the number of free pages to avoid per-cpu counter
> > @@ -537,17 +530,20 @@ struct zone {
> >  
> >  enum zone_flags {
> >  	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
> > -	ZONE_CONGESTED,			/* zone has many dirty pages backed by
> > +	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
> > +};
> > +
> 
> > +enum pgdat_flags {
> > +	PGDAT_CONGESTED,		/* zone has many dirty pages backed by
> 
>                                            node or pgdat, whatever.
> 

Fixed.

> >  					 * a congested BDI
> >  					 */
> > -	ZONE_DIRTY,			/* reclaim scanning has recently found
> > +	PGDAT_DIRTY,			/* reclaim scanning has recently found
> >  					 * many dirty file pages at the tail
> >  					 * of the LRU.
> >  					 */
> > -	ZONE_WRITEBACK,			/* reclaim scanning has recently found
> > +	PGDAT_WRITEBACK,		/* reclaim scanning has recently found
> >  					 * many pages under writeback
> >  					 */
> > -	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
> >  };
> >  
> >  static inline unsigned long zone_end_pfn(const struct zone *zone)
> > @@ -701,12 +697,26 @@ typedef struct pglist_data {
> >  	unsigned long first_deferred_pfn;
> >  #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
> >  
> > +
> 
> Unnecessary change.
> 

Fixed.

> > diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> > index d1744aa3ab9c..ced0c3e9da88 100644
> > --- a/include/linux/vmstat.h
> > +++ b/include/linux/vmstat.h
> > @@ -178,6 +178,23 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
> >  	return x;
> >  }
> >  
> > +static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
> > +					enum zone_stat_item item)
> 
>                                         enum node_stat_item
> 

Fixed

> > @@ -1147,9 +1147,9 @@ static void free_one_page(struct zone *zone,
> >  {
> >  	unsigned long nr_scanned;
> >  	spin_lock(&zone->lock);
> > -	nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
> > +	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
> >  	if (nr_scanned)
> > -		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
> > +		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
> >  
> >  	if (unlikely(has_isolate_pageblock(zone) ||
> >  		is_migrate_isolate(migratetype))) {
> > @@ -3526,7 +3526,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
> >  
> >  		available = reclaimable = zone_reclaimable_pages(zone);
> >  		available -= DIV_ROUND_UP(no_progress_loops * available,
> > -					  MAX_RECLAIM_RETRIES);
> > +					MAX_RECLAIM_RETRIES);
> 
> Unnecessary change.
> 

Fixed.

> >  		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
> >  
> >  		/*
> > @@ -4331,6 +4331,7 @@ void show_free_areas(unsigned int filter)
> 
> <snip.
> 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index e7ffcd259cc4..86a523a761c9 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -191,26 +191,42 @@ static bool sane_reclaim(struct scan_control *sc)
> >  }
> >  #endif
> >  
> > +/*
> > + * This misses isolated pages which are not accounted for to save counters.
> > + * As the data only determines if reclaim or compaction continues, it is
> > + * not expected that isolated pages will be a dominating factor.
> 
> When I read below commit, one of the reason it was introduced is whether we
> should continue to reclaim page or not.
> At that time, several people wanted it by my guessing [suggested|acked]-by
> so I think we should notice it to them.
> 
> Michal?
> 

Ultimately this gets fixed up at the end of the series when
zone_reclaimable_pages gets removed again to avoid double accounting.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

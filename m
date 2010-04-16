Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3414D6B01F2
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 10:35:43 -0400 (EDT)
Date: Fri, 16 Apr 2010 15:35:21 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/10] vmscan: Update isolated page counters outside of
	main path in shrink_inactive_list()
Message-ID: <20100416143521.GH19264@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-11-git-send-email-mel@csn.ul.ie> <20100416115315.27AA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100416115315.27AA.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 08:19:00PM +0900, KOSAKI Motohiro wrote:
> > When shrink_inactive_list() isolates pages, it updates a number of
> > counters using temporary variables to gather them. These consume stack
> > and it's in the main path that calls ->writepage(). This patch moves the
> > accounting updates outside of the main path to reduce stack usage.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/vmscan.c |   63 +++++++++++++++++++++++++++++++++++-----------------------
> >  1 files changed, 38 insertions(+), 25 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 2c22c83..4225319 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1061,7 +1061,8 @@ static unsigned long clear_active_flags(struct list_head *page_list,
> >  			ClearPageActive(page);
> >  			nr_active++;
> >  		}
> > -		count[lru]++;
> > +		if (count)
> > +			count[lru]++;
> >  	}
> >  
> >  	return nr_active;
> > @@ -1141,12 +1142,13 @@ static int too_many_isolated(struct zone *zone, int file,
> >   * TODO: Try merging with migrations version of putback_lru_pages
> >   */
> >  static noinline void putback_lru_pages(struct zone *zone,
> > -				struct zone_reclaim_stat *reclaim_stat,
> > +				struct scan_control *sc,
> >  				unsigned long nr_anon, unsigned long nr_file,
> >   				struct list_head *page_list)
> >  {
> >  	struct page *page;
> >  	struct pagevec pvec;
> > +	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> 
> Seems unrelated change here.
> Otherwise looks good.
> 

It was needed somewhat otherwise the split in accounting looked odd. It
could be done as two patches but it felt trickier to review.

>  - kosaki
> >  
> >  	pagevec_init(&pvec, 1);
> >  
> > @@ -1185,6 +1187,37 @@ static noinline void putback_lru_pages(struct zone *zone,
> >  	pagevec_release(&pvec);
> >  }
> >  
> > +static noinline void update_isolated_counts(struct zone *zone, 
> > +					struct scan_control *sc,
> > +					unsigned long *nr_anon,
> > +					unsigned long *nr_file,
> > +					struct list_head *isolated_list)
> > +{
> > +	unsigned long nr_active;
> > +	unsigned int count[NR_LRU_LISTS] = { 0, };
> > +	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> > +
> > +	nr_active = clear_active_flags(isolated_list, count);
> > +	__count_vm_events(PGDEACTIVATE, nr_active);
> > +
> > +	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
> > +			      -count[LRU_ACTIVE_FILE]);
> > +	__mod_zone_page_state(zone, NR_INACTIVE_FILE,
> > +			      -count[LRU_INACTIVE_FILE]);
> > +	__mod_zone_page_state(zone, NR_ACTIVE_ANON,
> > +			      -count[LRU_ACTIVE_ANON]);
> > +	__mod_zone_page_state(zone, NR_INACTIVE_ANON,
> > +			      -count[LRU_INACTIVE_ANON]);
> > +
> > +	*nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
> > +	*nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
> > +	__mod_zone_page_state(zone, NR_ISOLATED_ANON, *nr_anon);
> > +	__mod_zone_page_state(zone, NR_ISOLATED_FILE, *nr_file);
> > +
> > +	reclaim_stat->recent_scanned[0] += *nr_anon;
> > +	reclaim_stat->recent_scanned[1] += *nr_file;
> > +}
> > +
> >  /*
> >   * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
> >   * of reclaimed pages
> > @@ -1196,11 +1229,9 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> >  	LIST_HEAD(page_list);
> >  	unsigned long nr_scanned;
> >  	unsigned long nr_reclaimed = 0;
> > -	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> >  	int lumpy_reclaim = 0;
> >  	unsigned long nr_taken;
> >  	unsigned long nr_active;
> > -	unsigned int count[NR_LRU_LISTS] = { 0, };
> >  	unsigned long nr_anon;
> >  	unsigned long nr_file;
> >  
> > @@ -1244,25 +1275,7 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> >  		return 0;
> >  	}
> >  
> > -	nr_active = clear_active_flags(&page_list, count);
> > -	__count_vm_events(PGDEACTIVATE, nr_active);
> > -
> > -	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
> > -			      -count[LRU_ACTIVE_FILE]);
> > -	__mod_zone_page_state(zone, NR_INACTIVE_FILE,
> > -			      -count[LRU_INACTIVE_FILE]);
> > -	__mod_zone_page_state(zone, NR_ACTIVE_ANON,
> > -			      -count[LRU_ACTIVE_ANON]);
> > -	__mod_zone_page_state(zone, NR_INACTIVE_ANON,
> > -			      -count[LRU_INACTIVE_ANON]);
> > -
> > -	nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
> > -	nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
> > -	__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
> > -	__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
> > -
> > -	reclaim_stat->recent_scanned[0] += nr_anon;
> > -	reclaim_stat->recent_scanned[1] += nr_file;
> > +	update_isolated_counts(zone, sc, &nr_anon, &nr_file, &page_list);
> >  
> >  	spin_unlock_irq(&zone->lru_lock);
> >  
> > @@ -1281,7 +1294,7 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> >  		 * The attempt at page out may have made some
> >  		 * of the pages active, mark them inactive again.
> >  		 */
> > -		nr_active = clear_active_flags(&page_list, count);
> > +		nr_active = clear_active_flags(&page_list, NULL);
> >  		count_vm_events(PGDEACTIVATE, nr_active);
> >  
> >  		nr_reclaimed += shrink_page_list(&page_list, sc,
> > @@ -1293,7 +1306,7 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> >  		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
> >  	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
> >  
> > -	putback_lru_pages(zone, reclaim_stat, nr_anon, nr_file, &page_list);
> > +	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
> >  	return nr_reclaimed;
> >  }
> >  
> > -- 
> > 1.6.5
> > 
> 
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

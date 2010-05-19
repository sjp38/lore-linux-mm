Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6566B023E
	for <linux-mm@kvack.org>; Wed, 19 May 2010 17:42:47 -0400 (EDT)
Date: Wed, 19 May 2010 23:42:17 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 4/5] vmscan: remove isolate_pages callback scan control
Message-ID: <20100519214217.GC2868@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
 <20100430224316.121105897@cmpxchg.org>
 <20100513122717.215E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513122717.215E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 12:29:05PM +0900, KOSAKI Motohiro wrote:
> > For now, we have global isolation vs. memory control group isolation,
> > do not allow the reclaim entry function to set an arbitrary page
> > isolation callback, we do not need that flexibility.
> > 
> > And since we already pass around the group descriptor for the memory
> > control group isolation case, just use it to decide which one of the
> > two isolator functions to use.
> > 
> > The decisions can be merged into nearby branches, so no extra cost
> > there.  In fact, we save the indirect calls.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  include/linux/memcontrol.h |   13 ++++++-----
> >  mm/vmscan.c                |   52 ++++++++++++++++++++++++---------------------
> >  2 files changed, 35 insertions(+), 30 deletions(-)
> > 
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -82,12 +82,6 @@ struct scan_control {
> >  	 * are scanned.
> >  	 */
> >  	nodemask_t	*nodemask;
> > -
> > -	/* Pluggable isolate pages callback */
> > -	unsigned long (*isolate_pages)(unsigned long nr, struct list_head *dst,
> > -			unsigned long *scanned, int order, int mode,
> > -			struct zone *z, struct mem_cgroup *mem_cont,
> > -			int active, int file);
> >  };
> >  
> >  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> > @@ -1000,7 +994,6 @@ static unsigned long isolate_pages_globa
> >  					struct list_head *dst,
> >  					unsigned long *scanned, int order,
> >  					int mode, struct zone *z,
> > -					struct mem_cgroup *mem_cont,
> >  					int active, int file)
> >  {
> >  	int lru = LRU_BASE;
> > @@ -1144,11 +1137,11 @@ static unsigned long shrink_inactive_lis
> >  		unsigned long nr_anon;
> >  		unsigned long nr_file;
> >  
> > -		nr_taken = sc->isolate_pages(SWAP_CLUSTER_MAX,
> > -			     &page_list, &nr_scan, sc->order, mode,
> > -				zone, sc->mem_cgroup, 0, file);
> > -
> >  		if (scanning_global_lru(sc)) {
> > +			nr_taken = isolate_pages_global(SWAP_CLUSTER_MAX,
> > +							&page_list, &nr_scan,
> > +							sc->order, mode,
> > +							zone, 0, file);
> >  			zone->pages_scanned += nr_scan;
> >  			if (current_is_kswapd())
> >  				__count_zone_vm_events(PGSCAN_KSWAPD, zone,
> > @@ -1156,6 +1149,16 @@ static unsigned long shrink_inactive_lis
> >  			else
> >  				__count_zone_vm_events(PGSCAN_DIRECT, zone,
> >  						       nr_scan);
> > +		} else {
> > +			nr_taken = mem_cgroup_isolate_pages(SWAP_CLUSTER_MAX,
> > +							&page_list, &nr_scan,
> > +							sc->order, mode,
> > +							zone, sc->mem_cgroup,
> > +							0, file);
> > +			/*
> > +			 * mem_cgroup_isolate_pages() keeps track of
> > +			 * scanned pages on its own.
> > +			 */
> >  		}
> 
> There are the same logic in shrink_active/inactive_list.
> Can we make wrapper function? It probably improve code readability.

They are not completely identical, PGSCAN_DIRECT/PGSCAN_KSWAPD
accounting is only done in shrink_inactive_list(), so we would need an
extra branch.  Can we leave it like that for now?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

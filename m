Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C743F6B0085
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 00:22:58 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id oB15MsVq002547
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:22:54 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB15MsPF1642590
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:22:54 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB15MrkE008878
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:22:53 +1100
Date: Wed, 1 Dec 2010 10:52:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages
Message-ID: <20101201052248.GM2746@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
 <20101130101602.17475.32611.stgit@localhost6.localdomain6>
 <20101130204532.8322.A69D9226@jp.fujitsu.com>
 <20101201051632.GH2746@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101201051632.GH2746@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2010-12-01 10:46:32]:

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-12-01 09:14:13]:
> 
> > > Provide control using zone_reclaim() and a boot parameter. The
> > > code reuses functionality from zone_reclaim() to isolate unmapped
> > > pages and reclaim them as a priority, ahead of other mapped pages.
> > > 
> > > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > ---
> > >  include/linux/swap.h |    5 ++-
> > >  mm/page_alloc.c      |    7 +++--
> > >  mm/vmscan.c          |   72 +++++++++++++++++++++++++++++++++++++++++++++++++-
> > >  3 files changed, 79 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > > index eba53e7..78b0830 100644
> > > --- a/include/linux/swap.h
> > > +++ b/include/linux/swap.h
> > > @@ -252,11 +252,12 @@ extern int vm_swappiness;
> > >  extern int remove_mapping(struct address_space *mapping, struct page *page);
> > >  extern long vm_total_pages;
> > >  
> > > -#ifdef CONFIG_NUMA
> > > -extern int zone_reclaim_mode;
> > >  extern int sysctl_min_unmapped_ratio;
> > >  extern int sysctl_min_slab_ratio;
> > >  extern int zone_reclaim(struct zone *, gfp_t, unsigned int);
> > > +extern bool should_balance_unmapped_pages(struct zone *zone);
> > > +#ifdef CONFIG_NUMA
> > > +extern int zone_reclaim_mode;
> > >  #else
> > >  #define zone_reclaim_mode 0
> > >  static inline int zone_reclaim(struct zone *z, gfp_t mask, unsigned int order)
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 62b7280..4228da3 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1662,6 +1662,9 @@ zonelist_scan:
> > >  			unsigned long mark;
> > >  			int ret;
> > >  
> > > +			if (should_balance_unmapped_pages(zone))
> > > +				wakeup_kswapd(zone, order);
> > > +
> > 
> > You don't have to add extra branch into fast path.
> > 
> > 
> > >  			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
> > >  			if (zone_watermark_ok(zone, order, mark,
> > >  				    classzone_idx, alloc_flags))
> > > @@ -4136,10 +4139,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
> > >  
> > >  		zone->spanned_pages = size;
> > >  		zone->present_pages = realsize;
> > > -#ifdef CONFIG_NUMA
> > > -		zone->node = nid;
> > >  		zone->min_unmapped_pages = (realsize*sysctl_min_unmapped_ratio)
> > >  						/ 100;
> > > +#ifdef CONFIG_NUMA
> > > +		zone->node = nid;
> > >  		zone->min_slab_pages = (realsize * sysctl_min_slab_ratio) / 100;
> > >  #endif
> > >  		zone->name = zone_names[j];
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 0ac444f..98950f4 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -145,6 +145,21 @@ static DECLARE_RWSEM(shrinker_rwsem);
> > >  #define scanning_global_lru(sc)	(1)
> > >  #endif
> > >  
> > > +static unsigned long balance_unmapped_pages(int priority, struct zone *zone,
> > > +						struct scan_control *sc);
> > > +static int unmapped_page_control __read_mostly;
> > > +
> > > +static int __init unmapped_page_control_parm(char *str)
> > > +{
> > > +	unmapped_page_control = 1;
> > > +	/*
> > > +	 * XXX: Should we tweak swappiness here?
> > > +	 */
> > > +	return 1;
> > > +}
> > > +__setup("unmapped_page_control", unmapped_page_control_parm);
> > > +
> > > +
> > >  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
> > >  						  struct scan_control *sc)
> > >  {
> > > @@ -2223,6 +2238,12 @@ loop_again:
> > >  				shrink_active_list(SWAP_CLUSTER_MAX, zone,
> > >  							&sc, priority, 0);
> > >  
> > > +			/*
> > > +			 * We do unmapped page balancing once here and once
> > > +			 * below, so that we don't lose out
> > > +			 */
> > > +			balance_unmapped_pages(priority, zone, &sc);
> > 
> > You can't invoke any reclaim from here. It is in zone balancing detection
> > phase. It mean your code reclaim pages from zones which has lots free pages too.
> 
> The goal is to check not only for zone_watermark_ok, but also to see
> if unmapped pages are way higher than expected values.
> 
> > 
> > > +
> > >  			if (!zone_watermark_ok_safe(zone, order,
> > >  					high_wmark_pages(zone), 0, 0)) {
> > >  				end_zone = i;
> > > @@ -2258,6 +2279,11 @@ loop_again:
> > >  				continue;
> > >  
> > >  			sc.nr_scanned = 0;
> > > +			/*
> > > +			 * Balance unmapped pages upfront, this should be
> > > +			 * really cheap
> > > +			 */
> > > +			balance_unmapped_pages(priority, zone, &sc);
> > 
> > 
> > This code break page-cache/slab balancing logic. And this is conflict
> > against Nick's per-zone slab effort.
> >
> 
> OK, cc'ing Nick for comments.
>  
> > Plus, high-order + priority=5 reclaim Simon's case. (see "Free memory never 
> > fully used, swapping" threads)
> >
> 
> OK, this path should not add to swapping activity, if that is your
> concern.
> 
>  
> > >  
> > >  			/*
> > >  			 * Call soft limit reclaim before calling shrink_zone.
> > > @@ -2491,7 +2517,8 @@ void wakeup_kswapd(struct zone *zone, int order)
> > >  		pgdat->kswapd_max_order = order;
> > >  	if (!waitqueue_active(&pgdat->kswapd_wait))
> > >  		return;
> > > -	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0))
> > > +	if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0, 0) &&
> > > +		!should_balance_unmapped_pages(zone))
> > >  		return;
> > >  
> > >  	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
> > > @@ -2740,6 +2767,49 @@ zone_reclaim_unmapped_pages(struct zone *zone, struct scan_control *sc,
> > >  }
> > >  
> > >  /*
> > > + * Routine to balance unmapped pages, inspired from the code under
> > > + * CONFIG_NUMA that does unmapped page and slab page control by keeping
> > > + * min_unmapped_pages in the zone. We currently reclaim just unmapped
> > > + * pages, slab control will come in soon, at which point this routine
> > > + * should be called balance cached pages
> > > + */
> > > +static unsigned long balance_unmapped_pages(int priority, struct zone *zone,
> > > +						struct scan_control *sc)
> > > +{
> > > +	if (unmapped_page_control &&
> > > +		(zone_unmapped_file_pages(zone) > zone->min_unmapped_pages)) {
> > > +		struct scan_control nsc;
> > > +		unsigned long nr_pages;
> > > +
> > > +		nsc = *sc;
> > > +
> > > +		nsc.swappiness = 0;
> > > +		nsc.may_writepage = 0;
> > > +		nsc.may_unmap = 0;
> > > +		nsc.nr_reclaimed = 0;
> > 
> > Don't you need to fill nsc.nr_to_reclaim field?
> > 
> 
> Yes, since the relcaim code looks at nr_reclaimed, it needs to be 0 at
> every iteration - did I miss something?
> 
> > > +
> > > +		nr_pages = zone_unmapped_file_pages(zone) -
> > > +				zone->min_unmapped_pages;
> > > +		/* Magically try to reclaim eighth the unmapped cache pages */
> > > +		nr_pages >>= 3;
> > 
> > Please don't make magic.
> >
>  
> OK, it is a hueristic, how do I use it?
> 
> > > +
> > > +		zone_reclaim_unmapped_pages(zone, &nsc, nr_pages);
> > > +		return nsc.nr_reclaimed;
> > > +	}
> > > +	return 0;
> > > +}
> > > +
> > > +#define UNMAPPED_PAGE_RATIO 16
> > 
> > Please don't make magic ratio.
> 
> OK, it is a hueristic, how do I use heuristics - sysctl?
> 
> > 
> > > +bool should_balance_unmapped_pages(struct zone *zone)
> > > +{
> > > +	if (unmapped_page_control &&
> > > +		(zone_unmapped_file_pages(zone) >
> > > +			UNMAPPED_PAGE_RATIO * zone->min_unmapped_pages))
> > > +		return true;
> > > +	return false;
> > > +}
> > > +
> > > +/*
> > >   * Try to free up some pages from this zone through reclaim.
> > >   */
> > >  static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> > 
> > 
> > Hmm....
> > 
> > As far as I reviewed, I can't find any reason why this patch works as expected.
> > So, I think cleancache looks promising more than this idea. Have you seen Dan's
> > patch? I would suggested discuss him.
> 
> Please try the patch, I've been using it and it works exactly as
> expected for me. kswapd does the balancing and works well. I've posted
> some data as well.
>

My local MTA failed to deliver the message, trying again. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

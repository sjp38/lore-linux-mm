Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3966B0071
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 00:22:45 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id oB15Mb8I002469
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:22:37 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB15MbrV1384596
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:22:37 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB15MbNj008321
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 16:22:37 +1100
Date: Wed, 1 Dec 2010 10:52:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages
Message-ID: <20101201052232.GL2746@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
 <20101130101602.17475.32611.stgit@localhost6.localdomain6>
 <20101130142509.4f49d452.akpm@linux-foundation.org>
 <20101201045421.GG2746@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101201045421.GG2746@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2010-12-01 10:24:21]:

> * Andrew Morton <akpm@linux-foundation.org> [2010-11-30 14:25:09]:
> 
> > On Tue, 30 Nov 2010 15:46:31 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
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
> > 
> > This change will need to be moved into the first patch.
> > 
> 
> OK, will do, thanks for pointing it out
> 
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
> > 
> > gack, this is on the page allocator fastpath, isn't it?  So
> > 99.99999999% of the world's machines end up doing a pointless call to a
> > pointless function which pointlessly tests a pointless global and
> > pointlessly returns?  All because of some whacky KSM thing?
> > 
> > The speed and space overhead of this code should be *zero* if
> > !CONFIG_UNMAPPED_PAGECACHE_CONTROL and should be minimal if
> > CONFIG_UNMAPPED_PAGECACHE_CONTROL=y.  The way to do the latter is to
> > inline the test of unmapped_page_control into callers and only if it is
> > true (and use unlikely(), please) do we call into the KSM gunk.
> >
> 
> Will do, should_balance_unmapped_pages() will be a made a no-op in the
> absence of CONFIG_UNMAPPED_PAGECACHE_CONTROL
>  
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
> > 
> > aw c'mon guys, everybody knows that when you add a kernel parameter you
> > document it in Documentation/kernel-parameters.txt.
> 
> Will do - feeling silly on missing it out, that is where reviews help.
> 
> > 
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
> > More unjustifiable overhead on a commonly-executed codepath.
> >
> 
> Will refactor with a CONFIG suggested above.
>  
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
> > 
> > The problem I have with this comment is that it uses the term "balance"
> > without ever defining it.  Plus "balance" is already a term which is used
> > in memory reclaim.
> > 
> > So if you can think up a unique noun then that's good but whether or
> > not that is done, please describe with great care what that term
> > actually means in this context.
> 
> I used balance as a not a 1:1 balance, but to balance the proportion
> of unmapped page cache based on a sysctl/tunable.
> 
> > 
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
> > Doing a clone-and-own of a scan_control is novel.  What's going on here?
> 
> This code overwrites the swappiness, may_* and nr_reclaimed for
> correct stats. The idea is to vary the reclaim behaviour/bias it.
> 
> > 
> > > +		nr_pages = zone_unmapped_file_pages(zone) -
> > > +				zone->min_unmapped_pages;
> > > +		/* Magically try to reclaim eighth the unmapped cache pages */
> > > +		nr_pages >>= 3;
> > > +
> > > +		zone_reclaim_unmapped_pages(zone, &nsc, nr_pages);
> > > +		return nsc.nr_reclaimed;
> > > +	}
> > > +	return 0;
> > > +}
> > > +
> > > +#define UNMAPPED_PAGE_RATIO 16
> > 
> > Well.  Giving 16 a name didn't really clarify anything.  Attentive
> > readers will want to know what this does, why 16 was chosen and what
> > the effects of changing it will be.
> 
> Sorry, I documented that in the changelog of the first patchset. I'll
> document it here as well. The reason for choosing 16 is based on
> heuristics and test, the tradeoff being overenthusiastic reclaim
> versus size of cache/performance.
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
> > 
> > 
> > > Reviewed-by: Christoph Lameter <cl@linux.com>
> > 
> > So you're OK with shoving all this flotsam into 100,000,000 cellphones? 
> > This was a pretty outrageous patchset!
> 
> I'll do a better one, BTW, a lot of embedded folks are interested in
> page cache control outside of cgroup behaviour.
> 
> Thanks for the detailed review!
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 1D4A26B0085
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:57:03 -0400 (EDT)
Date: Fri, 13 Jul 2012 09:57:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3 v3] memory-hotplug: fix kswapd looping forever problem
Message-ID: <20120713005710.GA5248@bbox>
References: <1342061449-29590-1-git-send-email-minchan@kernel.org>
 <1342061449-29590-3-git-send-email-minchan@kernel.org>
 <20120712140154.72766586.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120712140154.72766586.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar@ap.sony.com>

On Thu, Jul 12, 2012 at 02:01:54PM -0700, Andrew Morton wrote:
> On Thu, 12 Jul 2012 11:50:49 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > When hotplug offlining happens on zone A, it starts to mark freed page
> > as MIGRATE_ISOLATE type in buddy for preventing further allocation.
> > (MIGRATE_ISOLATE is very irony type because it's apparently on buddy
> > but we can't allocate them).
> > When the memory shortage happens during hotplug offlining,
> > current task starts to reclaim, then wake up kswapd.
> > Kswapd checks watermark, then go sleep because current zone_watermark_ok_safe
> > doesn't consider MIGRATE_ISOLATE freed page count.
> > Current task continue to reclaim in direct reclaim path without kswapd's helping.
> > The problem is that zone->all_unreclaimable is set by only kswapd
> > so that current task would be looping forever like below.
> > 
> > __alloc_pages_slowpath
> > restart:
> > 	wake_all_kswapd
> > rebalance:
> > 	__alloc_pages_direct_reclaim
> > 		do_try_to_free_pages
> > 			if global_reclaim && !all_unreclaimable
> > 				return 1; /* It means we did did_some_progress */
> > 	skip __alloc_pages_may_oom
> > 	should_alloc_retry
> > 		goto rebalance;
> > 
> > If we apply KOSAKI's patch[1] which doesn't depends on kswapd
> > about setting zone->all_unreclaimable, we can solve this problem
> > by killing some task in direct reclaim path. But it doesn't wake up kswapd, still.
> > It could be a problem still if other subsystem needs GFP_ATOMIC request.
> > So kswapd should consider MIGRATE_ISOLATE when it calculate free pages
> > BEFORE going sleep.
> > 
> > This patch counts the number of MIGRATE_ISOLATE page block and
> > zone_watermark_ok_safe will consider it if the system has such blocks
> > (fortunately, it's very rare so no problem in POV overhead and kswapd is never
> > hotpath).
> > 
> > Copy/modify from Mel's quote
> > "
> > Ideal solution would be "allocating" the pageblock.
> > It would keep the free space accounting as it is but historically,
> > memory hotplug didn't allocate pages because it would be difficult to
> > detect if a pageblock was isolated or if part of some balloon.
> > Allocating just full pageblocks would work around this, However,
> > it would play very badly with CMA.
> > "
> > 
> > [1] http://lkml.org/lkml/2012/6/14/74
> >
> > ...
> >
> > +#ifdef CONFIG_MEMORY_ISOLATION
> > +static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
> > +{
> > +	unsigned long nr_pages = 0;
> > +
> > +	if (unlikely(zone->nr_pageblock_isolate)) {
> > +		nr_pages = zone->nr_pageblock_isolate * pageblock_nr_pages;
> > +	}
> > +	return nr_pages;
> > +}
> 
> That's pretty verbose.  I couldn't resist fiddling with it ;)
> 
> > +#else
> > +static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
> > +{
> > +	return 0;
> > +}
> > +#endif
> > +
> >  bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
> >  		      int classzone_idx, int alloc_flags)
> >  {
> > @@ -1633,6 +1655,14 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
> >  	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
> >  		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
> >  
> > +	/*
> > +	 * If the zone has MIGRATE_ISOLATE type free page,
> > +	 * we should consider it. nr_zone_isolate_freepages is never
> > +	 * accurate so kswapd might not sleep although she can.
> > +	 * But it's more desirable for memory hotplug rather than
> > +	 * forever sleep which cause livelock in direct reclaim path.
> > +	 */
> 
> I had a go at clarifying this comment.  Please review the result.
> 
> > +	free_pages -= nr_zone_isolate_freepages(z);
> >  	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
> >  								free_pages);
> >  }
> > @@ -4397,6 +4427,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
> >  		lruvec_init(&zone->lruvec, zone);
> >  		zap_zone_vm_stats(zone);
> >  		zone->flags = 0;
> > +		zone->nr_pageblock_isolate = 0;
> >  		if (!size)
> >  			continue;
> >  
> > diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> > index fb482cf..64abb33 100644
> > --- a/mm/page_isolation.c
> > +++ b/mm/page_isolation.c
> > @@ -8,6 +8,31 @@
> >  #include <linux/memory.h>
> >  #include "internal.h"
> >  
> > +/* called by holding zone->lock */
> > +static void set_pageblock_isolate(struct zone *zone, struct page *page)
> > +{
> > +	BUG_ON(page_zone(page) != zone);
> 
> Well.  If this is the case then why not eliminate this function's
> `zone' argument?
> 
> > +	if (get_pageblock_migratetype(page) == MIGRATE_ISOLATE)
> > +		return;
> > +
> > +	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> > +	zone->nr_pageblock_isolate++;
> > +}
> > +
> > +/* called by holding zone->lock */
> > +static void restore_pageblock_isolate(struct zone *zone, struct page *page,
> > +		int migratetype)
> > +{
> > +	BUG_ON(page_zone(page) != zone);
> 
> ditto
> 
> > +	if (WARN_ON(get_pageblock_migratetype(page) != MIGRATE_ISOLATE))
> > +		return;
> > +
> > +	BUG_ON(zone->nr_pageblock_isolate <= 0);
> > +	set_pageblock_migratetype(page, migratetype);
> > +	zone->nr_pageblock_isolate--;
> > +}
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: memory-hotplug-fix-kswapd-looping-forever-problem-fix
> 
> simplify nr_zone_isolate_freepages(), rework zone_watermark_ok_safe() comment, simplify set_pageblock_isolate() and restore_pageblock_isolate().
> 
> Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Minchan Kim <minchan@kernel.org>

Looks better.
Thanks, Andrew!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

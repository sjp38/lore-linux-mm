Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9138E6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 11:43:04 -0400 (EDT)
Received: by qyl38 with SMTP id 38so2573695qyl.14
        for <linux-mm@kvack.org>; Mon, 10 Oct 2011 08:42:59 -0700 (PDT)
Date: Tue, 11 Oct 2011 00:42:50 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch v2]vmscan: correctly detect GFP_ATOMIC allocation failure
Message-ID: <20111010154250.GA1791@barrios-desktop>
References: <1318043674.22361.38.camel@sli10-conroe>
 <alpine.DEB.2.00.1110072014040.13992@chino.kir.corp.google.com>
 <1318044928.22361.41.camel@sli10-conroe>
 <1318053412.22361.51.camel@sli10-conroe>
 <20111008102531.GC8679@barrios-desktop>
 <1318139591.22361.56.camel@sli10-conroe>
 <20111009080156.GB23003@barrios-desktop>
 <1318148271.22361.67.camel@sli10-conroe>
 <20111009151035.GA1679@barrios-desktop>
 <1318231693.22361.75.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1318231693.22361.75.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>

On Mon, Oct 10, 2011 at 03:28:13PM +0800, Shaohua Li wrote:
> On Sun, 2011-10-09 at 23:10 +0800, Minchan Kim wrote:
> > On Sun, Oct 09, 2011 at 04:17:51PM +0800, Shaohua Li wrote:
> > > On Sun, 2011-10-09 at 16:01 +0800, Minchan Kim wrote:
> > > > On Sun, Oct 09, 2011 at 01:53:11PM +0800, Shaohua Li wrote:
> > > > > On Sat, 2011-10-08 at 18:25 +0800, Minchan Kim wrote:
> > > > > > On Sat, Oct 08, 2011 at 01:56:52PM +0800, Shaohua Li wrote:
> > > > > > > On Sat, 2011-10-08 at 11:35 +0800, Shaohua Li wrote:
> > > > > > > > On Sat, 2011-10-08 at 11:19 +0800, David Rientjes wrote:
> > > > > > > > > On Sat, 8 Oct 2011, Shaohua Li wrote:
> > > > > > > > > 
> > > > > > > > > > has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
> > > > > > > > > > failure risk. For a high end_zone, if any zone below or equal to it has min
> > > > > > > > > > matermark ok, we have no risk. But current logic is any zone has min watermark
> > > > > > > > > > not ok, then we have risk. This is wrong to me.
> > > > > > > > > > 
> > > > > > > > > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > > > > > > > > > ---
> > > > > > > > > >  mm/vmscan.c |    7 ++++---
> > > > > > > > > >  1 file changed, 4 insertions(+), 3 deletions(-)
> > > > > > > > > > 
> > > > > > > > > > Index: linux/mm/vmscan.c
> > > > > > > > > > ===================================================================
> > > > > > > > > > --- linux.orig/mm/vmscan.c	2011-09-27 15:09:29.000000000 +0800
> > > > > > > > > > +++ linux/mm/vmscan.c	2011-09-27 15:14:45.000000000 +0800
> > > > > > > > > > @@ -2463,7 +2463,7 @@ loop_again:
> > > > > > > > > >  
> > > > > > > > > >  	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> > > > > > > > > >  		unsigned long lru_pages = 0;
> > > > > > > > > > -		int has_under_min_watermark_zone = 0;
> > > > > > > > > > +		int has_under_min_watermark_zone = 1;
> > > > > > > > > 
> > > > > > > > > bool
> > > > > > > > > 
> > > > > > > > > >  
> > > > > > > > > >  		/* The swap token gets in the way of swapout... */
> > > > > > > > > >  		if (!priority)
> > > > > > > > > > @@ -2594,9 +2594,10 @@ loop_again:
> > > > > > > > > >  				 * means that we have a GFP_ATOMIC allocation
> > > > > > > > > >  				 * failure risk. Hurry up!
> > > > > > > > > >  				 */
> > > > > > > > > > -				if (!zone_watermark_ok_safe(zone, order,
> > > > > > > > > > +				if (has_under_min_watermark_zone &&
> > > > > > > > > > +					    zone_watermark_ok_safe(zone, order,
> > > > > > > > > >  					    min_wmark_pages(zone), end_zone, 0))
> > > > > > > > > > -					has_under_min_watermark_zone = 1;
> > > > > > > > > > +					has_under_min_watermark_zone = 0;
> > > > > > > > > >  			} else {
> > > > > > > > > >  				/*
> > > > > > > > > >  				 * If a zone reaches its high watermark,
> > > > > > > > > 
> > > > > > > > > Ignore checking the min watermark for a moment and consider if all zones 
> > > > > > > > > are above the high watermark (a situation where kswapd does not need to 
> > > > > > > > > do aggressive reclaim), then has_under_min_watermark_zone doesn't get 
> > > > > > > > > cleared and never actually stalls on congestion_wait().  Notice this is 
> > > > > > > > > congestion_wait() and not wait_iff_congested(), so the clearing of 
> > > > > > > > > ZONE_CONGESTED doesn't prevent this.
> > > > > > > > if all zones are above the high watermark, we will have i < 0 when
> > > > > > > > detecting the highest imbalanced zone, and the whole loop will end
> > > > > > > > without run into congestion_wait().
> > > > > > > > or I can add a clearing has_under_min_watermark_zone in the else block
> > > > > > > > to be safe.
> > > > > > > Subject: vmscan: correctly detect GFP_ATOMIC allocation failure -v2
> > > > > > > 
> > > > > > > has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
> > > > > > > failure risk. For a high end_zone, if any zone below or equal to it has min
> > > > > > > matermark ok, we have no risk. But current logic is any zone has min watermark
> > > > > > > not ok, then we have risk. This is wrong to me.
> > > > > > 
> > > > > > I think it's not a right or wrong problem but a policy stuff.
> > > > > > If we are going to start busy reclaiming for atomic allocation
> > > > > > after we see all lower zones' min water mark pages are already consumed
> > > > > > It could make you go through long latency and is likely to fail atomic allocation
> > > > > > stream(Because, there is nothing to do for aotmic allocation fail in direct reclaim
> > > > > > so kswapd should always do best effort for it)
> > > > > > 
> > > > > > I don't mean you are wrong but we are very careful about this
> > > > > > and at least need some experiments with atomic allocaion stream, I think.
> > > > > yes. this is a policy problem. I just don't want the kswapd keep running
> > > > > even there is no immediate risk of atomic allocation fail.
> > > > > One problem here is end_zone could be high, and low zone always doesn't
> > > > > meet min watermark. So kswapd keeps running without a wait and builds
> > > > > big priority.
> > > > 
> > > > It could be but I think it's a mistake of admin if he handles such rare system.
> > > > Couldn't he lower the reserved pages for highmem?
> > > not because admin changes reserved pages. we still have the
> > > zone->lowmem_reserve[] issue for zone_watermark_ok here.
> > 
> > Sorry I couldn't understand your point.
> > I mean if min watermark is too high, you could lower min_free_kbytes.
> > If reserved pages is too high, you could handle lowmem_reserve_ratio.
> > Could we solve the problem with those knobs?
> I mean a system with default setting. Changing the knobs might solve the
> problem, but few people know it, so not a right solution.

We couldn't cover whole cases so that we should focus on common case.
That's why we need knobs.
Do you think your case is general one we should handle it by default?
If you really think, we have to fix watermark setting logic rathe than kswapd.

> 
> > In addition, kswapd could easily set all_unreclaimable of the zone in your example.
> > Then, kswapd should just peek the zone once in a while if the zone is all_unreclaimable.
> > It should be no problem in CPU overhead.
> even the low zone has all_unreclaimable, the high zone will be scanned
> again with low priority (because its high watermark might not be ok, but
> min watermark is ok), and does not do congestion_wait. This will make a

As you said, high zone is below high watermark so it's natural since it's
one of kswapd goal. Why it doesn't sleep is that one zone of zonelists is
below min_watmark. So it's natural in current policy, too.

> lot of unnecessary page scan. With wait, some pages might be freed.

Hmm, My opinion is different. Now the high zone haven't been filled up
enough free pages to satisfy high watemark although prioirty is high(ie, priority < DEF_PRIORITY -2).
It means we should extend window size to isolate from LRU.

Having said that, I understand your point.
If it isn't, we can go after sleeping by congestion_wait so that scan/sec would be low.
But the situation is emergency because min_watermark is very important mark to work system goes well.
It is related to PF_MEMALLOC. So let's sacrifice CPU overhead for system stability.

> DMA zone is a special case, and I thought this can happen in other low
> zones too. such low zones might have lru pages. so all_unreclaimable
> isn't set in such zones.
> 
> Thanks,
> Shaohua
> 

-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1A46B002E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 03:59:16 -0400 (EDT)
Received: by qyk27 with SMTP id 27so470917qyk.14
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 00:59:14 -0700 (PDT)
Date: Wed, 12 Oct 2011 16:59:06 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch v2]vmscan: correctly detect GFP_ATOMIC allocation failure
Message-ID: <20111012075906.GB1866@barrios-desktop>
References: <20111008102531.GC8679@barrios-desktop>
 <1318139591.22361.56.camel@sli10-conroe>
 <20111009080156.GB23003@barrios-desktop>
 <1318148271.22361.67.camel@sli10-conroe>
 <20111009151035.GA1679@barrios-desktop>
 <1318231693.22361.75.camel@sli10-conroe>
 <20111010154250.GA1791@barrios-desktop>
 <1318311010.22361.95.camel@sli10-conroe>
 <20111011065401.GA4415@barrios-desktop>
 <1318387739.22361.109.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1318387739.22361.109.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 12, 2011 at 10:48:59AM +0800, Shaohua Li wrote:
 > > there are two cases one zone is below min_watermark.
> > > 1. the zone is below min_watermark for allocation in the zone. in this
> > > case we need hurry up.
> > > 2. the zone is below min_watermark for allocation from high zone. we
> > > don't really need hurry up if other zone is above min_watermark.
> > > Since low zone need to reserve pages for high zone, the second case
> > > could be common.
> > 
> > You mean "lowmem_reserve"?
> > It means opposite. It is a mechanism to defend using of lowmem pages from high zone allocation
> > because it could be fatal to allow process pages to be allocated from low zone.
> > Also, We could set each ratio for reserved pages of zones.
> > How could we make sure lower zones have enough free pages for higher zone?
> lowmem_reserve causes the problem, but it's not a fault of
> lowmem_reserve. I'm thinking changing it.
> 
> > > Yes, keeping kswapd running in this case can reduce the chance
> > > GFP_ATOMIC failure. But my patch will not cause immediate failure
> > > because there is still some zones which are above min_watermark and can
> > > meet the GFP_ATOMIC allocation. And keeping kswapd running has some
> > 
> > True. It was why I said "I don't mean you are wrong but we are very careful about this."
> > Normally, it could handle but might fail on sudden peak of atomic allocation stream.
> > Recently, we have suffered from many reporting of GFP_AOTMIC allocation than olded.
> > So I would like to be very careful and that's why I suggest we need at least some experiment.
> > Through it, Andrew could make final call.
> sure.
> 
> > > drawbacks:
> > > 1. cpu overhead
> > > 2. extend isolate window size, so trash working set.
> > > Considering DMA zone, we almost always have DMA zone min_watermark not
> > > ok for any allocation from high zone. So we will always have such
> > > drawbacks.
> > 
> > I agree with you in that it's a problem.
> > I think the real solution is to remove the zone from allocation fallback list in such case
> > because the lower zone could never meet any allocation for the higher zone.
> > But it makes code rather complicated as we have to consider admin who can change
> > reserved pages anytime.
> Not worthy the complication.
> 
> > So how about this?
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 8913374..f71ed2f 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2693,8 +2693,16 @@ loop_again:
> >                                  * failure risk. Hurry up!
> >                                  */
> >                                 if (!zone_watermark_ok_safe(zone, order,
> > -                                           min_wmark_pages(zone), end_zone, 0))
> > -                                       has_under_min_watermark_zone = 1;
> > +                                           min_wmark_pages(zone), end_zone, 0)) {
> > +                                       /*
> > +                                        * In case of big reserved page for higher zone,
> > +                                        * it is pointless to try reclaimaing pages quickly
> > +                                        * because it could never meet the requirement.
> > +                                        */
> > +                                       if (zone->present_pages >
> > +                                               min_wmark_pages(zone) + zone->lowmem_reserve[end_zone])
> > +                                               has_under_min_watermark_zone = 1;
> > +                               }
> >                         } else {
> >                                 /*
> >                                  * If a zone reaches its high watermark,
> This looks like a workaround just for DMA zone. present_pages could be
> bigger than min_mwark+lowmem_reserve. And We still suffered from the
> issue, for example, a DMA32 zone with some pages allocated for DMA, or a
> zone which has some lru pages, but still much smaller than high zone.

Right. I thought about it but couldn't have a good idea for it. :(

> 
> > Even, we could apply this at starting of the loop so that we can avoid unnecessary scanning st the beginning.
> > In that case, we have to apply zone->lowmem_reserve[end_zone] only because we have to consider NO_WATERMARK alloc case.
> yes, we can do this to avoid unnecessary scan. but DMA zone hasn't lru
> pages, so not sure how big the benefit is here.

At least, we can prevent has_under_min_watermark_zone from set.
But it still have a problem you pointed out earlier.

> 
> > > Or is something below better? we can avoid the big reserved pages
> > > accounting to the min_wmark_pages for low zone. if high zone is under
> > > min_wmark, kswapd will not sleep.
> > >                                if (!zone_watermark_ok_safe(zone, order,
> > > -                                            min_wmark_pages(zone), end_zone, 0))
> > > +                                            min_wmark_pages(zone), 0, 0))
> > >                                         has_under_min_watermark_zone = 1;
> > 
> > I think it's not a good idea since page allocator always considers classzone_idx.
> > So although we fix kswapd issue through your changes, page allocator still can't allocate memory
> > and wakes up kswapd, again.
> why kswapd will be waked up again? The high zone itself still has
> min_wark+low_reserve ok for the allocation(classzone_idx 0 means
> checking the low_reserve for allocation from the zone itself), so the
> allocation can be met.

You're absolutely right.
I got confused. Sorry about that.

I like this than your old version.
That's because it could rush if one of zonelist is consumed as below min_watermak.
It could mitigate GFP_ALLOC fail than yours old version but still would be higher than now.
So, we need the number.

Could you repost this as formal patch with good comment and number?
Personally, I like description based on scenario with kind step-by-step.
Feel free to use my description in my patch if you want.

Thanks for patient discussion in spite of my irregular reply, Shaohua.

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

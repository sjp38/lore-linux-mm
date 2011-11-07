Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 238D16B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 00:07:03 -0500 (EST)
Subject: Re: [patch v3]vmscan: correctly detect GFP_ATOMIC allocation
 failure
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <1319778908.22361.158.camel@sli10-conroe>
References: <20111009080156.GB23003@barrios-desktop>
	 <1318148271.22361.67.camel@sli10-conroe>
	 <20111009151035.GA1679@barrios-desktop>
	 <1318231693.22361.75.camel@sli10-conroe>
	 <20111010154250.GA1791@barrios-desktop>
	 <1318311010.22361.95.camel@sli10-conroe>
	 <20111011065401.GA4415@barrios-desktop>
	 <1318387739.22361.109.camel@sli10-conroe>
	 <20111012075906.GB1866@barrios-desktop>
	 <1318904032.22361.113.camel@sli10-conroe>
	 <20111027225042.GA29407@barrios-laptop.redhat.com>
	 <1319778908.22361.158.camel@sli10-conroe>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 07 Nov 2011 13:15:52 +0800
Message-ID: <1320642952.22361.203.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm <linux-mm@kvack.org>

On Fri, 2011-10-28 at 13:15 +0800, Shaohua Li wrote:
> On Fri, 2011-10-28 at 06:50 +0800, Minchan Kim wrote:
> > On Tue, Oct 18, 2011 at 10:13:52AM +0800, Shaohua Li wrote:
> > > On Wed, 2011-10-12 at 15:59 +0800, Minchan Kim wrote:
> > > > On Wed, Oct 12, 2011 at 10:48:59AM +0800, Shaohua Li wrote:
> > > >  > > there are two cases one zone is below min_watermark.
> > > > > > > 1. the zone is below min_watermark for allocation in the zone. in this
> > > > > > > case we need hurry up.
> > > > > > > 2. the zone is below min_watermark for allocation from high zone. we
> > > > > > > don't really need hurry up if other zone is above min_watermark.
> > > > > > > Since low zone need to reserve pages for high zone, the second case
> > > > > > > could be common.
> > > > > > 
> > > > > > You mean "lowmem_reserve"?
> > > > > > It means opposite. It is a mechanism to defend using of lowmem pages from high zone allocation
> > > > > > because it could be fatal to allow process pages to be allocated from low zone.
> > > > > > Also, We could set each ratio for reserved pages of zones.
> > > > > > How could we make sure lower zones have enough free pages for higher zone?
> > > > > lowmem_reserve causes the problem, but it's not a fault of
> > > > > lowmem_reserve. I'm thinking changing it.
> > > > > 
> > > > > > > Yes, keeping kswapd running in this case can reduce the chance
> > > > > > > GFP_ATOMIC failure. But my patch will not cause immediate failure
> > > > > > > because there is still some zones which are above min_watermark and can
> > > > > > > meet the GFP_ATOMIC allocation. And keeping kswapd running has some
> > > > > > 
> > > > > > True. It was why I said "I don't mean you are wrong but we are very careful about this."
> > > > > > Normally, it could handle but might fail on sudden peak of atomic allocation stream.
> > > > > > Recently, we have suffered from many reporting of GFP_AOTMIC allocation than olded.
> > > > > > So I would like to be very careful and that's why I suggest we need at least some experiment.
> > > > > > Through it, Andrew could make final call.
> > > > > sure.
> > > > > 
> > > > > > > drawbacks:
> > > > > > > 1. cpu overhead
> > > > > > > 2. extend isolate window size, so trash working set.
> > > > > > > Considering DMA zone, we almost always have DMA zone min_watermark not
> > > > > > > ok for any allocation from high zone. So we will always have such
> > > > > > > drawbacks.
> > > > > > 
> > > > > > I agree with you in that it's a problem.
> > > > > > I think the real solution is to remove the zone from allocation fallback list in such case
> > > > > > because the lower zone could never meet any allocation for the higher zone.
> > > > > > But it makes code rather complicated as we have to consider admin who can change
> > > > > > reserved pages anytime.
> > > > > Not worthy the complication.
> > > > > 
> > > > > > So how about this?
> > > > > > 
> > > > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > > > index 8913374..f71ed2f 100644
> > > > > > --- a/mm/vmscan.c
> > > > > > +++ b/mm/vmscan.c
> > > > > > @@ -2693,8 +2693,16 @@ loop_again:
> > > > > >                                  * failure risk. Hurry up!
> > > > > >                                  */
> > > > > >                                 if (!zone_watermark_ok_safe(zone, order,
> > > > > > -                                           min_wmark_pages(zone), end_zone, 0))
> > > > > > -                                       has_under_min_watermark_zone = 1;
> > > > > > +                                           min_wmark_pages(zone), end_zone, 0)) {
> > > > > > +                                       /*
> > > > > > +                                        * In case of big reserved page for higher zone,
> > > > > > +                                        * it is pointless to try reclaimaing pages quickly
> > > > > > +                                        * because it could never meet the requirement.
> > > > > > +                                        */
> > > > > > +                                       if (zone->present_pages >
> > > > > > +                                               min_wmark_pages(zone) + zone->lowmem_reserve[end_zone])
> > > > > > +                                               has_under_min_watermark_zone = 1;
> > > > > > +                               }
> > > > > >                         } else {
> > > > > >                                 /*
> > > > > >                                  * If a zone reaches its high watermark,
> > > > > This looks like a workaround just for DMA zone. present_pages could be
> > > > > bigger than min_mwark+lowmem_reserve. And We still suffered from the
> > > > > issue, for example, a DMA32 zone with some pages allocated for DMA, or a
> > > > > zone which has some lru pages, but still much smaller than high zone.
> > > > 
> > > > Right. I thought about it but couldn't have a good idea for it. :(
> > > > 
> > > > > 
> > > > > > Even, we could apply this at starting of the loop so that we can avoid unnecessary scanning st the beginning.
> > > > > > In that case, we have to apply zone->lowmem_reserve[end_zone] only because we have to consider NO_WATERMARK alloc case.
> > > > > yes, we can do this to avoid unnecessary scan. but DMA zone hasn't lru
> > > > > pages, so not sure how big the benefit is here.
> > > > 
> > > > At least, we can prevent has_under_min_watermark_zone from set.
> > > > But it still have a problem you pointed out earlier.
> > > > 
> > > > > 
> > > > > > > Or is something below better? we can avoid the big reserved pages
> > > > > > > accounting to the min_wmark_pages for low zone. if high zone is under
> > > > > > > min_wmark, kswapd will not sleep.
> > > > > > >                                if (!zone_watermark_ok_safe(zone, order,
> > > > > > > -                                            min_wmark_pages(zone), end_zone, 0))
> > > > > > > +                                            min_wmark_pages(zone), 0, 0))
> > > > > > >                                         has_under_min_watermark_zone = 1;
> > > > > > 
> > > > > > I think it's not a good idea since page allocator always considers classzone_idx.
> > > > > > So although we fix kswapd issue through your changes, page allocator still can't allocate memory
> > > > > > and wakes up kswapd, again.
> > > > > why kswapd will be waked up again? The high zone itself still has
> > > > > min_wark+low_reserve ok for the allocation(classzone_idx 0 means
> > > > > checking the low_reserve for allocation from the zone itself), so the
> > > > > allocation can be met.
> > > > 
> > > > You're absolutely right.
> > > > I got confused. Sorry about that.
> > > > 
> > > > I like this than your old version.
> > > > That's because it could rush if one of zonelist is consumed as below min_watermak.
> > > > It could mitigate GFP_ALLOC fail than yours old version but still would be higher than now.
> > > > So, we need the number.
> > > > 
> > > > Could you repost this as formal patch with good comment and number?
> > > > Personally, I like description based on scenario with kind step-by-step.
> > > > Feel free to use my description in my patch if you want.
> > > > 
> > > > Thanks for patient discussion in spite of my irregular reply, Shaohua.
> > > Thanks for your time. Here is patch. I'm trying to get some number, but
> > > didn't find a proper workload to demonstrate the atomic allocation
> > > failure. Any suggestion for the workload?
> > 
> > Sorry for really really late response.
> > 
> > Hmm.. I didn't have a such test.
> > But it seems recently we had a such report, again.
> > https://lkml.org/lkml/2011/10/18/131
> > If you want it, you could ask him.
> I'll ask.
This issue isn't related to GFP_ATOMIC.
I tested a lot of fio/ffsb/tcp/udp tests in 2 machines (one two socket
and the other 4 socket) here and didn't find any problem. Apparently
this doesn't mean the test proves there is no problem but I hope
somebody can look at the patch.

Thanks,
Shaohua

> > > Subject: vmscan: correctly detect GFP_ATOMIC allocation failure -v3
> > > 
> > > has_under_min_watermark_zone is used to detect if there is GFP_ATOMIC allocation
> > > failure risk. Current logic is if any zone has min watermark not ok, we have
> > > risk.
> > > 
> > > Low zone needs reserve memory to avoid fallback from high zone. The reserved
> > > memory is zone->lowmem_reserve[]. If high zone is big, low zone's
> > > min_wmark + lowmem_reserve[] usually is big. Sometimes min_wmark +
> > > lowmem_reserve[] could even be higher than zone->present_pages. An example is
> > > DMA zone. Other low zones could have the similar high reserved memory though
> > > might still have margins between reserved pages and present pages. So in kswapd
> > > loop, if end_zone is a high zone, has_under_min_watermark_zone could be easily
> > > set or always set for DMA.
> > > 
> > > Let's consider end_zone is a high zone and it has high_mwark not ok, but
> > > min_mwark ok. A DMA zone always has present_pages less than reserved pages, so
> > > has_under_min_watermark_zone is always set. When kswapd is running, there are
> > > some drawbacks:
> > > 1. kswapd can keep unnecessary running without congestion_wait. high zone
> > > already can meet GFP_ATOMIC. The running will waste some CPU.
> > > 2. kswapd can scan much more pages to trash working set. congestion_wait can
> > > slow down scan if kswapd has trouble. Now congestion_wait is skipped, kswapd
> > > will keep scanning unnecessary pages.
> > > 
> > > So since DMA zone always set has_under_min_watermark_zone, current logic actually
> > > equals to that kswapd keeps running without congestion_wait till high zone has
> > > high wmark ok when it has trouble. This is not intended.
> > > 
> > > In this path, we test the min_mwark against the zone itself. This doesn't change
> > > the behavior of high zone. For low zone, we now exclude lowmem_reserve for high
> > > zone to avoid unnecessary running.
> > > 
> > > Note: With this patch, we could have potential higher risk of GFP_ATOMIC failure.
> > > 
> > > v3: Uses a less intrusive method to determine if has_under_min_watermark_zone
> > > should be set after discussion with Minchan.
> > > v2: use bool and clear has_under_min_watermark_zone for zone with watermark ok
> > > as suggested by David Rientjes.
> > > 
> > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > 
> > As you know, I give my reviewed-by as a token of "code looks good to me".
> > But still, we see atomic allocation failure messasge recently.
> > So you need to get a acked-by as a toekn of "I support this idea" of
> > others(ie, Mel/Rik are right person).
> > 
> > I hope it would be better to write down it in description that
> > it's real problem of your system and the patch solves it.
> Thanks, I haven't test case exposing this issue, but just thought the
> logic looks buggy.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

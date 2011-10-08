Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2B5236B002C
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 23:03:59 -0400 (EDT)
Subject: Re: [patch 1/2]vmscan: correct all_unreclaimable for zone without
 lru pages
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20111001065943.GA6601@barrios-desktop>
References: <1317108184.29510.200.camel@sli10-conroe>
	 <20110928065721.GA15021@barrios-desktop>
	 <1317193711.22361.16.camel@sli10-conroe>
	 <20110928175750.GA1696@barrios-desktop>
	 <1317258891.22361.19.camel@sli10-conroe>
	 <20110929091853.GA1865@barrios-desktop>
	 <1317348743.22361.29.camel@sli10-conroe>
	 <20111001065943.GA6601@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 08 Oct 2011 11:09:51 +0800
Message-ID: <1318043391.22361.34.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sat, 2011-10-01 at 14:59 +0800, Minchan Kim wrote:
> On Fri, Sep 30, 2011 at 10:12:23AM +0800, Shaohua Li wrote:
> > On Thu, 2011-09-29 at 17:18 +0800, Minchan Kim wrote:
> > > On Thu, Sep 29, 2011 at 09:14:51AM +0800, Shaohua Li wrote:
> > > > On Thu, 2011-09-29 at 01:57 +0800, Minchan Kim wrote:
> > > > > On Wed, Sep 28, 2011 at 03:08:31PM +0800, Shaohua Li wrote:
> > > > > > On Wed, 2011-09-28 at 14:57 +0800, Minchan Kim wrote:
> > > > > > > On Tue, Sep 27, 2011 at 03:23:04PM +0800, Shaohua Li wrote:
> > > > > > > > I saw DMA zone always has ->all_unreclaimable set. The reason is the high zones
> > > > > > > > are big, so zone_watermark_ok/_safe() will always return false with a high
> > > > > > > > classzone_idx for DMA zone, because DMA zone's lowmem_reserve is big for a high
> > > > > > > > classzone_idx. When kswapd runs into DMA zone, it doesn't scan/reclaim any
> > > > > > > > pages(no pages in lru), but mark the zone as all_unreclaimable. This can
> > > > > > > > happen in other low zones too.
> > > > > > >
> > > > > > > Good catch!
> > > > > > >
> > > > > > > > This is confusing and can potentially cause oom. Say a low zone has
> > > > > > > > all_unreclaimable when high zone hasn't enough memory. Then allocating
> > > > > > > > some pages in low zone(for example reading blkdev with highmem support),
> > > > > > > > then run into direct reclaim. Since the zone has all_unreclaimable set,
> > > > > > > > direct reclaim might reclaim nothing and an oom reported. If
> > > > > > > > all_unreclaimable is unset, the zone can actually reclaim some pages.
> > > > > > > > If all_unreclaimable is unset, in the inner loop of balance_pgdat we always have
> > > > > > > > all_zones_ok 0 when checking a low zone's watermark. If high zone watermark isn't
> > > > > > > > good, there is no problem. Otherwise, we might loop one more time in the outer
> > > > > > > > loop, but since high zone watermark is ok, the end_zone will be lower, then low
> > > > > > > > zone's watermark check will be ok and the outer loop will break. So looks this
> > > > > > > > doesn't bring any problem.
> > > > > > >
> > > > > > > I think it would be better to correct zone_reclaimable.
> > > > > > > My point is zone_reclaimable should consider zone->pages_scanned.
> > > > > > > The point of the function is how many pages scanned VS how many pages remained in LRU.
> > > > > > > If reclaimer doesn't scan the zone at all because of no lru pages, it shouldn't tell
> > > > > > > the zone is all_unreclaimable.
> > > > > > actually this is exact my first version of the patch. The problem is if
> > > > > > a zone is true unreclaimable (used by kenrel pages or whatever), we will
> > > > > > have zone->pages_scanned 0 too. I thought we should set
> > > > > > all_unreclaimable in this case.
> > > > >
> > > > > Let's think the problem again.
> > > > > Fundamental problem is that why the lower zone's lowmem_reserve for higher zone is huge big
> > > > > that might be bigger than the zone's size.
> > > > > I think we need the boundary for limiting lowmem_reseve.
> > > > > So how about this?
> > > > I didn't see a reason why high zone allocation should fallback to low
> > > > zone if high zone is big. Changing the lowmem_reserve can cause the
> > > > fallback. Has any rationale here?
> > >
> > > I try to think better solution than yours but I got failed. :(
> > > The why I try to avoid your patch is that kswapd is very complicated these days so
> > > I wanted to not add more logic for handling corner cases if we can solve it
> > > other ways. But as I said, but I got failed.
> > >
> > > It seems that it doesn't make sense that previous my patch that limit lowmem_reserve.
> > > Because we can have higher zone which is very big size so that lowmem_zone[higher_zone] of
> > > low zone could be bigger freely than the lowmem itself size.
> > > It implies the low zone should be not used for higher allocation.
> > > It has no reason to limit it. My brain was broken. :(
> > >
> > > But I have a question about your patch still.
> > > What happens if DMA zone sets zone->all_unreclaimable with 1?
> > >
> > > You said as follows,
> > >
> > > > This is confusing and can potentially cause oom. Say a low zone has
> > > > all_unreclaimable when high zone hasn't enough memory. Then allocating
> > > > some pages in low zone(for example reading blkdev with highmem support),
> > > > then run into direct reclaim. Since the zone has all_unreclaimable set,
> > >
> > > If low zone has enough pages for allocation, it cannot have entered reclaim.
> > > It means now low zone doesn't have enough free pages for the order allocation.
> > > So it's natural to enter reclaim path.
> > >
> > > > direct reclaim might reclaim nothing and an oom reported. If
> > >
> > > It's not correct "nothing". At least, it will do something in DEF_PRIORITY.
> > it does something, but might not reclaim any pages, for example, it
> > starts page write, but page isn't in disk yet in DEF_PRIORITY and it
> > skip further reclaiming in !DEF_PRIORITY.
> >
> > > > all_unreclaimable is unset, the zone can actually reclaim some pages.
> > >
> > > The reason of this problem is that the zone has no lru page, you said.
> > > Then how could we reclaim some pages in the zone even if the zone's all_unreclaimable is unset?
> > > You expect slab pages?
> > The zone could have lru pages. Let's take an example, allocation from
> > ZONE_HIGHMEM, then kswapd runs, ZONE_NORMAL gets all_unreclaimable set
> > even it has free pages. Then we do write blkdev device, which use
> > ZONE_NORMAL for page cache. Some pages in ZONE_NORMAL are in lru, then
> > we run into direct page reclaim for ZONE_NORMAL. Since all_unreclaimable
> > is set and pages in ZONE_NORMAL lru are dirty, direct reclaim could
> > fail. But I'd agree this is a corner case.
> > Besides when I saw ZONE_DMA has a lot of free pages and
> > all_unreclaimable is set, it's really confusing.
> 
> Hi Shaohua,
> Sorry for late response and Thanks for your explanation.
> It's valuable to fix, I think.
> How about this?
> 
> I hope other guys have a interest in the problem.
> Cced them.
Hi,
it's a long holiday here, so I'm late, sorry.

> From 070d5b1a69921bc71c6aaa5445fb1d29ecb38f74 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan.kim@gmail.com>
> Date: Sat, 1 Oct 2011 15:26:08 +0900
> Subject: [RFC] vmscan: set all_unreclaimable of zone carefully
> 
> Shaohua Li reported all_unreclaimable of DMA zone is always set
> because the system has a big memory HIGH zone so that lowmem_reserve[HIGH]
> could be a big.
> 
> It could be a problem as follows
> 
> Assumption :
> 1. The system has a big high memory so that lowmem_reserve[HIGH] of DMA zone would be big.
> 2. HIGH/NORMAL zone are full but DMA zone has enough free pages.
> 
> Scenario
> 1. A request to allocate a page in HIGH zone.
> 2. HIGH/NORMAL zone already consumes lots of pages so that it would be fall-backed to DMA zone.
> 3. In DMA zone, allocator got failed, too becuase lowmem_reserve[HIGH] is very big so that it wakes up kswapd
> 4. kswapd would call shrink_zone while it see DMA zone since DMA zone's lowmem_reserve[HIGHMEM]
>    would be big so that it couldn't meet zone_watermark_ok_safe(high_wmark_pages(zone) + balance_gap,
>    *end_zone*)
> 5. DMA zone doesn't meet stop condition(nr_slab != 0, !zone_reclaimable) because the zone has small lru pages
>    and it doesn't have slab pages so that kswapd would set all_unreclaimable of the zone to *1* easily.
> 6. B request to allocate many pages in NORMAL zone but NORMAL zone has no free pages
>    so that it would be fall-backed to DMA zone.
> 7. DMA zone would allocates many pages for NORMAL zone because lowmem_reserve[NORMAL] is small.
>    These pages are used by application(ie, it menas LRU pages. Yes. Now DMA zone could have many reclaimable pages)
> 8. C request to allocate a page in NORMAL zone but he got failed because DMA zone doesn't have enough free pages.
>    (Most of pages in DMA zone are consumed by B)
> 9. Kswapd try to reclaim lru pages in DMA zone but got failed because all_unreclaimable of the zone is 1. Otherwise,
>    it could reclaim many pages which are used by B.
> 
> Of coures, we can do something in DEF_PRIORITY but it couldn't do enough because it can't raise
> synchronus reclaim in direct reclaim path if the zone has many dirty pages
> so that the process is killed by OOM.
> 
> The principal problem is caused by step 8.
> In step 8, we increased # of lru size very much but still the zone->all_unreclaimable is 1.
> If we increase lru size, it is valuable to try reclaiming again.
> The rationale is that we reset all_unreclaimable to 0 even if we free just a one page.
So this fixes the oom, but we still have DMA has all_unreclaimable set
always, because all_unreclaimable == zone_reclaimable_pages() + 1. Not a
problem?
What's wrong with my original patch? It appears reasonable if a zone has
a lot of free memory, don't set unreclaimable to it.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

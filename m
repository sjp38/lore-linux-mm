Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id EA0646B0034
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 22:32:56 -0400 (EDT)
Date: Fri, 2 Aug 2013 11:33:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Possible deadloop in direct reclaim?
Message-ID: <20130802023326.GC32486@bbox>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
 <20130801054338.GD19540@bbox>
 <89813612683626448B837EE5A0B6A7CB3B630BE04E@SC-VEXCH4.marvell.com>
 <20130801073330.GG19540@bbox>
 <89813612683626448B837EE5A0B6A7CB3B630BE0E3@SC-VEXCH4.marvell.com>
 <20130801084259.GA32486@bbox>
 <20130802015241.GB32486@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130802015241.GB32486@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, Aug 02, 2013 at 11:26:28AM +0900, Minchan Kim wrote:
> Hello Lisa and KOSAKI,
> 
> Lisa's quote style is very hard to follow so I'd like to write at bottom
> as ignoring line by line rule.
> 
> Lisa, please correct your MUA.
> 
> On Thu, Aug 01, 2013 at 05:42:59PM +0900, Minchan Kim wrote:
> > On Thu, Aug 01, 2013 at 01:20:34AM -0700, Lisa Du wrote:
> > > >-----Original Message-----
> > > >From: Minchan Kim [mailto:minchan@kernel.org]
> > > >Sent: 2013a1'8ae??1ae?JPY 15:34
> > > >To: Lisa Du
> > > >Cc: linux-mm@kvack.org; KOSAKI Motohiro
> > > >Subject: Re: Possible deadloop in direct reclaim?
> > > >
> > > >On Wed, Jul 31, 2013 at 11:13:07PM -0700, Lisa Du wrote:
> > > >> >On Mon, Jul 22, 2013 at 09:58:17PM -0700, Lisa Du wrote:
> > > >> >> Dear Sir:
> > > >> >> Currently I met a possible deadloop in direct reclaim. After run plenty
> > > >of
> > > >> >the application, system run into a status that system memory is very
> > > >> >fragmentized. Like only order-0 and order-1 memory left.
> > > >> >> Then one process required a order-2 buffer but it enter an endless
> > > >direct
> > > >> >reclaim. From my trace log, I can see this loop already over 200,000
> > > >times.
> > > >> >Kswapd was first wake up and then go back to sleep as it cannot
> > > >rebalance
> > > >> >this order's memory. But zone->all_unreclaimable remains 1.
> > > >> >> Though direct_reclaim every time returns no pages, but as
> > > >> >zone->all_unreclaimable = 1, so it loop again and again. Even when
> > > >> >zone->pages_scanned also becomes very large. It will block the process
> > > >for
> > > >> >long time, until some watchdog thread detect this and kill this process.
> > > >> >Though it's in __alloc_pages_slowpath, but it's too slow right? Maybe
> > > >cost
> > > >> >over 50 seconds or even more.
> > > >> >> I think it's not as expected right?  Can we also add below check in the
> > > >> >function all_unreclaimable() to terminate this loop?
> > > >> >>
> > > >> >> @@ -2355,6 +2355,8 @@ static bool all_unreclaimable(struct zonelist
> > > >> >*zonelist,
> > > >> >>                         continue;
> > > >> >>                 if (!zone->all_unreclaimable)
> > > >> >>                         return false;
> > > >> >> +               if (sc->nr_reclaimed == 0
> > > >&& !zone_reclaimable(zone))
> > > >> >> +                       return true;
> > > >> >>         }
> > > >> >>          BTW: I'm using kernel3.4, I also try to search in the
> > > >kernel3.9,
> > > >> >didn't see a possible fix for such issue. Or is anyone also met such issue
> > > >> >before? Any comment will be welcomed, looking forward to your reply!
> > > >> >>
> > > >> >> Thanks!
> > > >> >
> > > >> >I'd like to ask somethigs.
> > > >> >
> > > >> >1. Do you have enabled swap?
> > > >> I set CONFIG_SWAP=y, but I didn't really have a swap partition, that
> > > >means my swap buffer size is 0;
> > > >> >2. Do you enable CONFIG_COMPACTION?
> > > >> No, I didn't enable;
> > > >> >3. Could we get your zoneinfo via cat /proc/zoneinfo?
> > > >> I dump some info from ramdump, please review:
> > > >
> > > >Thanks for the information.
> > > >You said order-2 allocation was failed so I will assume preferred zone
> > > >is normal zone, not high zone because high order allocation in kernel side
> > > >isn't from high zone.
> > > Yes, that's right!
> > > >
> > > >> crash> kmem -z
> > > >> NODE: 0  ZONE: 0  ADDR: c08460c0  NAME: "Normal"
> > > >>   SIZE: 192512  PRESENT: 182304  MIN/LOW/HIGH: 853/1066/1279
> > > >
> > > >712M normal memory.
> > > >
> > > >>   VM_STAT:
> > > >>           NR_FREE_PAGES: 16092
> > > >
> > > >There are plenty of free pages over high watermark but there are heavy
> > > >fragmentation as I see below information.
> > > >
> > > >So, kswapd doesn't scan this zone loop iteration is done with order-2.
> > > >I mean kswapd will scan this zone with order-0 if first iteration is
> > > >done by this
> > > >
> > > >        order = sc.order = 0;
> > > >
> > > >        goto loop_again;
> > > >
> > > >But this time, zone_watermark_ok_safe with testorder = 0 on normal zone
> > > >is always true so that scanning of zone will be skipped. It means kswapd
> > > >never set zone->unreclaimable to 1.
> > > Yes, definitely!
> > > >
> > > >>        NR_INACTIVE_ANON: 17
> > > >>          NR_ACTIVE_ANON: 55091
> > > >>        NR_INACTIVE_FILE: 17
> > > >>          NR_ACTIVE_FILE: 17
> > > >>          NR_UNEVICTABLE: 0
> > > >>                NR_MLOCK: 0
> > > >>           NR_ANON_PAGES: 55077
> > > >
> > > >There are about 200M anon pages and few file pages.
> > > >You don't have swap so that reclaimer couldn't go far.
> > > >
> > > >>          NR_FILE_MAPPED: 42
> > > >>           NR_FILE_PAGES: 69
> > > >>           NR_FILE_DIRTY: 0
> > > >>            NR_WRITEBACK: 0
> > > >>     NR_SLAB_RECLAIMABLE: 1226
> > > >>   NR_SLAB_UNRECLAIMABLE: 9373
> > > >>            NR_PAGETABLE: 2776
> > > >>         NR_KERNEL_STACK: 798
> > > >>         NR_UNSTABLE_NFS: 0
> > > >>               NR_BOUNCE: 0
> > > >>         NR_VMSCAN_WRITE: 91
> > > >>     NR_VMSCAN_IMMEDIATE: 115381
> > > >>       NR_WRITEBACK_TEMP: 0
> > > >>        NR_ISOLATED_ANON: 0
> > > >>        NR_ISOLATED_FILE: 0
> > > >>                NR_SHMEM: 31
> > > >>              NR_DIRTIED: 15256
> > > >>              NR_WRITTEN: 11981
> > > >> NR_ANON_TRANSPARENT_HUGEPAGES: 0
> > > >>
> > > >> NODE: 0  ZONE: 1  ADDR: c08464c0  NAME: "HighMem"
> > > >>   SIZE: 69632  PRESENT: 69088  MIN/LOW/HIGH: 67/147/228
> > > >>   VM_STAT:
> > > >>           NR_FREE_PAGES: 161
> > > >
> > > >Reclaimer should reclaim this zone.
> > > >
> > > >>        NR_INACTIVE_ANON: 104
> > > >>          NR_ACTIVE_ANON: 46114
> > > >>        NR_INACTIVE_FILE: 9722
> > > >>          NR_ACTIVE_FILE: 12263
> > > >
> > > >It seems there are lots of room to evict file pages.
> > > >
> > > >>          NR_UNEVICTABLE: 168
> > > >>                NR_MLOCK: 0
> > > >>           NR_ANON_PAGES: 46102
> > > >>          NR_FILE_MAPPED: 12227
> > > >>           NR_FILE_PAGES: 22270
> > > >>           NR_FILE_DIRTY: 1
> > > >>            NR_WRITEBACK: 0
> > > >>     NR_SLAB_RECLAIMABLE: 0
> > > >>   NR_SLAB_UNRECLAIMABLE: 0
> > > >>            NR_PAGETABLE: 0
> > > >>         NR_KERNEL_STACK: 0
> > > >>         NR_UNSTABLE_NFS: 0
> > > >>               NR_BOUNCE: 0
> > > >>         NR_VMSCAN_WRITE: 0
> > > >>     NR_VMSCAN_IMMEDIATE: 0
> > > >>       NR_WRITEBACK_TEMP: 0
> > > >>        NR_ISOLATED_ANON: 0
> > > >>        NR_ISOLATED_FILE: 0
> > > >>                NR_SHMEM: 117
> > > >>              NR_DIRTIED: 7364
> > > >>              NR_WRITTEN: 6989
> > > >> NR_ANON_TRANSPARENT_HUGEPAGES: 0
> > > >>
> > > >> ZONE  NAME        SIZE    FREE  MEM_MAP   START_PADDR
> > > >START_MAPNR
> > > >>   0   Normal    192512   16092  c1200000       0            0
> > > >> AREA    SIZE  FREE_AREA_STRUCT  BLOCKS  PAGES
> > > >>   0       4k      c08460f0           3      3
> > > >>   0       4k      c08460f8         436    436
> > > >>   0       4k      c0846100       15237  15237
> > > >>   0       4k      c0846108           0      0
> > > >>   0       4k      c0846110           0      0
> > > >>   1       8k      c084611c          39     78
> > > >>   1       8k      c0846124           0      0
> > > >>   1       8k      c084612c         169    338
> > > >>   1       8k      c0846134           0      0
> > > >>   1       8k      c084613c           0      0
> > > >>   2      16k      c0846148           0      0
> > > >>   2      16k      c0846150           0      0
> > > >>   2      16k      c0846158           0      0
> > > >> ---------Normal zone all order > 1 has no free pages
> > > >> ZONE  NAME        SIZE    FREE  MEM_MAP   START_PADDR
> > > >START_MAPNR
> > > >>   1   HighMem    69632     161  c17e0000    2f000000
> > > >192512
> > > >> AREA    SIZE  FREE_AREA_STRUCT  BLOCKS  PAGES
> > > >>   0       4k      c08464f0          12     12
> > > >>   0       4k      c08464f8           0      0
> > > >>   0       4k      c0846500          14     14
> > > >>   0       4k      c0846508           3      3
> > > >>   0       4k      c0846510           0      0
> > > >>   1       8k      c084651c           0      0
> > > >>   1       8k      c0846524           0      0
> > > >>   1       8k      c084652c           0      0
> > > >>   2      16k      c0846548           0      0
> > > >>   2      16k      c0846550           0      0
> > > >>   2      16k      c0846558           0      0
> > > >>   2      16k      c0846560           1      4
> > > >>   2      16k      c0846568           0      0
> > > >>   5     128k      c08465cc           0      0
> > > >>   5     128k      c08465d4           0      0
> > > >>   5     128k      c08465dc           0      0
> > > >>   5     128k      c08465e4           4    128
> > > >>   5     128k      c08465ec           0      0
> > > >> ------Other's all zero
> > > >>
> > > >> Some other zone information I dump from pglist_data
> > > >> {
> > > >> 	watermark = {853, 1066, 1279},
> > > >>       percpu_drift_mark = 0,
> > > >>       lowmem_reserve = {0, 2159, 2159},
> > > >>       dirty_balance_reserve = 3438,
> > > >>       pageset = 0xc07f6144,
> > > >>       lock = {
> > > >>         {
> > > >>           rlock = {
> > > >>             raw_lock = {
> > > >>               lock = 0
> > > >>             },
> > > >>             break_lock = 0
> > > >>           }
> > > >>         }
> > > >>       },
> > > >> 	all_unreclaimable = 0,
> > > >>       reclaim_stat = {
> > > >>         recent_rotated = {903355, 960912},
> > > >>         recent_scanned = {932404, 2462017}
> > > >>       },
> > > >>       pages_scanned = 84231,
> > > >
> > > >Most of scan happens in direct reclaim path, I guess
> > > >but direct reclaim couldn't reclaim any pages due to lack of swap device.
> > > >
> > > >It means we have to set zone->all_unreclaimable in direct reclaim path,
> > > >too.
> > > >Below patch fix your problem?
> > > Yes, your patch should fix my problem! 
> > > Actually I also did another patch, after test, should also fix my issue, 
> > > but I didn't set zone->all_unreclaimable in direct reclaim path as you, 
> > > just double check zone_reclaimable() status in all_unreclaimable() function.
> > > Maybe your patch is better!
> > 
> > Nope. I think your patch is better. :)
> > Just thing is anlaysis of the problem and description and I think we could do
> > better but unfortunately, I don't have enough time today so I will see tomorrow.
> > Just nitpick below.
> > 
> > Thanks.
> > 
> > > 
> > > commit 26d2b60d06234683a81666da55129f9c982271a5
> > > Author: Lisa Du <cldu@marvell.com>
> > > Date:   Thu Aug 1 10:16:32 2013 +0800
> > > 
> > >     mm: fix infinite direct_reclaim when memory is very fragmentized
> > >     
> > >     latest all_unreclaimable check in direct reclaim is the following commit.
> > >     2011 Apr 14; commit 929bea7c; vmscan:  all_unreclaimable() use
> > >                                 zone->all_unreclaimable as a name
> > >     and in addition, add oom_killer_disabled check to avoid reintroduce the
> > >     issue of commit d1908362 ("vmscan: check all_unreclaimable in direct reclaim path").
> > >     
> > >     But except the hibernation case in which kswapd is freezed, there's also other case
> > >     which may lead infinite loop in direct relaim. In a real test, direct_relaimer did
> > >     over 200000 times rebalance in __alloc_pages_slowpath(), so this process will be
> > >     blocked until watchdog detect and kill it. The root cause is as below:
> > >     
> > >     If system memory is very fragmentized like only order-0 and order-1 left,
> > >     kswapd will go to sleep as system cann't rebalanced for high-order allocations.
> > >     But direct_reclaim still works for higher order request. So zones can become a state
> > >     zone->all_unreclaimable = 0 but zone->pages_scanned > zone_reclaimable_pages(zone) * 6.
> > >     In this case if a process like do_fork try to allocate an order-2 memory which is not
> > >     a COSTLY_ORDER, as direct_reclaim always said it did_some_progress, so rebalance again
> > >     and again in __alloc_pages_slowpath(). This issue is easily happen in no swap and no
> > >     compaction enviroment.
> > >     
> > >     So add furthur check in all_unreclaimable() to avoid such case.
> > >     
> > >     Change-Id: Id3266b47c63f5b96aab466fd9f1f44d37e16cdcb
> > >     Signed-off-by: Lisa Du <cldu@marvell.com>
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 2cff0d4..34582d9 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2301,7 +2301,9 @@ static bool all_unreclaimable(struct zonelist *zonelist,
> > >                         continue;
> > >                 if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> > >                         continue;
> > > -               if (!zone->all_unreclaimable)
> > > +               if (zone->all_unreclaimable)
> > > +                       continue;
> > 
> > Nitpick: If we use zone_reclaimable(), above check is redundant and
> > gain is very tiny because this path is already slow.
> > 
> > > +               if (zone_reclaimable(zone))
> > >                         return false;
> > >         }
> > > >
> > > >From a5d82159b98f3d90c2f9ff9e486699fb4c67cced Mon Sep 17 00:00:00
> > > >2001
> > > >From: Minchan Kim <minchan@kernel.org>
> > > >Date: Thu, 1 Aug 2013 16:18:00 +0900
> > > >Subject:[PATCH] mm: set zone->all_unreclaimable in direct reclaim
> > > > path
> > > >
> > > >Lisa reported there are lots of free pages in a zone but most of them
> > > >is order-0 pages so it means the zone is heavily fragemented.
> > > >Then, high order allocation could make direct reclaim path'slong stall(
> > > >ex, 50 second) in no swap and no compaction environment.
> > > >
> > > >The reason is kswapd can skip the zone's scanning because the zone
> > > >is lots of free pages and kswapd changes scanning order from high-order
> > > >to 0-order after his first iteration is done because kswapd think
> > > >order-0 allocation is the most important.
> > > >Look at 73ce02e9 in detail.
> > > >
> > > >The problem from that is that only kswapd can set zone->all_unreclaimable
> > > >to 1 at the moment so direct reclaim path should loop forever until a ghost
> > > >can set the zone->all_unreclaimable to 1.
> > > >
> > > >This patch makes direct reclaim path to set zone->all_unreclaimable
> > > >to avoid infinite loop. So now we don't need a ghost.
> > > >
> > > >Reported-by: Lisa Du <cldu@marvell.com>
> > > >Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > >---
> > > > mm/vmscan.c |   29 ++++++++++++++++++++++++++++-
> > > > 1 file changed, 28 insertions(+), 1 deletion(-)
> > > >
> > > >diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > >index 33dc256..f957e87 100644
> > > >--- a/mm/vmscan.c
> > > >+++ b/mm/vmscan.c
> > > >@@ -2317,6 +2317,23 @@ static bool all_unreclaimable(struct zonelist
> > > >*zonelist,
> > > > 	return true;
> > > > }
> > > >
> > > >+static void check_zones_unreclaimable(struct zonelist *zonelist,
> > > >+					struct scan_control *sc)
> > > >+{
> > > >+	struct zoneref *z;
> > > >+	struct zone *zone;
> > > >+
> > > >+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > > >+			gfp_zone(sc->gfp_mask), sc->nodemask) {
> > > >+		if (!populated_zone(zone))
> > > >+			continue;
> > > >+		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> > > >+			continue;
> > > >+		if (!zone_reclaimable(zone))
> > > >+			zone->all_unreclaimable = 1;
> > > >+	}
> > > >+}
> > > >+
> > > > /*
> > > >  * This is the main entry point to direct page reclaim.
> > > >  *
> > > >@@ -2370,7 +2387,17 @@ static unsigned long
> > > >do_try_to_free_pages(struct zonelist *zonelist,
> > > > 				lru_pages += zone_reclaimable_pages(zone);
> > > > 			}
> > > >
> > > >-			shrink_slab(shrink, sc->nr_scanned, lru_pages);
> > > >+			/*
> > > >+			 * When a zone has enough order-0 free memory but
> > > >+			 * zone is heavily fragmented and we need high order
> > > >+			 * page from the zone, kswapd could skip the zone
> > > >+			 * after first iteration with high order. So, kswapd
> > > >+			 * never set the zone->all_unreclaimable to 1 so
> > > >+			 * direct reclaim path needs the check.
> > > >+			 */
> > > >+			if (!shrink_slab(shrink, sc->nr_scanned, lru_pages))
> > > >+				check_zones_unreclaimable(zonelist, sc);
> > > >+
> > > > 			if (reclaim_state) {
> > > > 				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> > > > 				reclaim_state->reclaimed_slab = 0;
> > > >--
> > > >1.7.9.5
> > > >
> > > >--
> > > >Kind regards,
> > > >Minchan Kim
> > 
> 
> I reviewed current mmotm because recently Mel changed kswapd a lot and
> all_unreclaimable patch history today.
> What I see is recent mmotm has a same problem, too if system have no swap
> and no compaction. Of course, compaction is default yes option so we could
> recommend to enable if system works well but it's up to user and we should
                                ^^^ typo
                      if system want work well

> avoid direct reclaim hang although user disable compaction.
> 
> When I see the patch history, real culprit is 929bea7c.
> 
> "  zone->all_unreclaimable and zone->pages_scanned are neigher atomic
>     variables nor protected by lock.  Therefore zones can become a state of
>     zone->page_scanned=0 and zone->all_unreclaimable=1.  In this case, current
>     all_unreclaimable() return false even though zone->all_unreclaimabe=1."
> 
> I understand the problem but apparently, it makes Lisa's problem because
> kswapd can give up balancing when high order allocation happens to prevent
> excessive reclaim with assuming the process requested high order allocation
> can do direct reclaim/compaction. But what if the process can't reclaim
> by no swap but lots of anon pages and can't compact by !CONFIG_COMPACTION?
> 
> In such system, OOM kill is natural but not hang.
> So, a solution we can fix simply introduces zone_reclaimable check again in
> all_unreclaimabe() like this.
> 
> What do you think about it?
> 
> It's a same patch Lisa posted so we should give a credit
> to her/him(Sorry I'm not sure) if we agree thie approach.
> 
> Lisa, If KOSAKI agree with this, could you resend this patch with your SOB?
> 
> Thanks.
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a3bf7fd..78f46d8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2367,7 +2367,15 @@ static bool all_unreclaimable(struct zonelist *zonelist,
>  			continue;
>  		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>  			continue;
> -		if (!zone->all_unreclaimable)
> +		/*
> +		 * zone->page_scanned and could be raced so we need
                                      ^^^
                                      typo: please remove it.

> +		 * dobule check by zone->all_unreclaimable. Morever, kswapd
> +		 * could skip (zone->all_unreclaimable = 1) if the zone
> +		 * is heavily fragmented but enough free pages to meet
> +		 * high watermark. In such case, kswapd never set
> +		 * all_unreclaimable to 1 so we need zone_reclaimable, too.
> +		 */
> +		if (!zone->all_unreclaimable || zone_reclaimable(zone))
>  			return false;
>  	}
>  
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

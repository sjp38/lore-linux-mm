Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DACBB9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:58:00 -0400 (EDT)
Received: by pzk4 with SMTP id 4so22581494pzk.6
        for <linux-mm@kvack.org>; Wed, 28 Sep 2011 10:57:57 -0700 (PDT)
Date: Thu, 29 Sep 2011 02:57:50 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 1/2]vmscan: correct all_unreclaimable for zone without
 lru pages
Message-ID: <20110928175750.GA1696@barrios-desktop>
References: <1317108184.29510.200.camel@sli10-conroe>
 <20110928065721.GA15021@barrios-desktop>
 <1317193711.22361.16.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317193711.22361.16.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@google.com>, Michal Hocko <mhocko@suse.cz>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Sep 28, 2011 at 03:08:31PM +0800, Shaohua Li wrote:
> On Wed, 2011-09-28 at 14:57 +0800, Minchan Kim wrote:
> > On Tue, Sep 27, 2011 at 03:23:04PM +0800, Shaohua Li wrote:
> > > I saw DMA zone always has ->all_unreclaimable set. The reason is the high zones
> > > are big, so zone_watermark_ok/_safe() will always return false with a high
> > > classzone_idx for DMA zone, because DMA zone's lowmem_reserve is big for a high
> > > classzone_idx. When kswapd runs into DMA zone, it doesn't scan/reclaim any
> > > pages(no pages in lru), but mark the zone as all_unreclaimable. This can
> > > happen in other low zones too.
> > 
> > Good catch!
> > 
> > > This is confusing and can potentially cause oom. Say a low zone has
> > > all_unreclaimable when high zone hasn't enough memory. Then allocating
> > > some pages in low zone(for example reading blkdev with highmem support),
> > > then run into direct reclaim. Since the zone has all_unreclaimable set,
> > > direct reclaim might reclaim nothing and an oom reported. If
> > > all_unreclaimable is unset, the zone can actually reclaim some pages.
> > > If all_unreclaimable is unset, in the inner loop of balance_pgdat we always have
> > > all_zones_ok 0 when checking a low zone's watermark. If high zone watermark isn't
> > > good, there is no problem. Otherwise, we might loop one more time in the outer
> > > loop, but since high zone watermark is ok, the end_zone will be lower, then low
> > > zone's watermark check will be ok and the outer loop will break. So looks this
> > > doesn't bring any problem.
> > 
> > I think it would be better to correct zone_reclaimable.
> > My point is zone_reclaimable should consider zone->pages_scanned.
> > The point of the function is how many pages scanned VS how many pages remained in LRU.
> > If reclaimer doesn't scan the zone at all because of no lru pages, it shouldn't tell
> > the zone is all_unreclaimable.
> actually this is exact my first version of the patch. The problem is if
> a zone is true unreclaimable (used by kenrel pages or whatever), we will
> have zone->pages_scanned 0 too. I thought we should set
> all_unreclaimable in this case.

Let's think the problem again.
Fundamental problem is that why the lower zone's lowmem_reserve for higher zone is huge big
that might be bigger than the zone's size.
I think we need the boundary for limiting lowmem_reseve.
So how about this?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2a25213..9267db4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5101,6 +5101,7 @@ static void setup_per_zone_lowmem_reserve(void)
                        idx = j;
                        while (idx) {
                                struct zone *lower_zone;
+                               unsigned long lowmem_reserve;
 
                                idx--;
 
@@ -5108,8 +5109,9 @@ static void setup_per_zone_lowmem_reserve(void)
                                        sysctl_lowmem_reserve_ratio[idx] = 1;
 
                                lower_zone = pgdat->node_zones + idx;
-                               lower_zone->lowmem_reserve[j] = present_pages /
-                                       sysctl_lowmem_reserve_ratio[idx];
+                               lowmem_reserve = present_pages / sysctl_lowmem_reserve_ratio[idx];
+                               lower_zone->lowmem_reserve[j] = min(lowmem_reserve,
+                                               lower_zone->present_pages - high_wmark_pages(zone));
                                present_pages += lower_zone->present_pages;
                        }
                }


> 
> Thanks,
> Shaohua
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

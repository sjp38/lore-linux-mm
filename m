Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C4999000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 03:03:34 -0400 (EDT)
Subject: Re: [patch 1/2]vmscan: correct all_unreclaimable for zone without
 lru pages
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110928065721.GA15021@barrios-desktop>
References: <1317108184.29510.200.camel@sli10-conroe>
	 <20110928065721.GA15021@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 28 Sep 2011 15:08:31 +0800
Message-ID: <1317193711.22361.16.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@google.com>, Michal Hocko <mhocko@suse.cz>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, 2011-09-28 at 14:57 +0800, Minchan Kim wrote:
> On Tue, Sep 27, 2011 at 03:23:04PM +0800, Shaohua Li wrote:
> > I saw DMA zone always has ->all_unreclaimable set. The reason is the high zones
> > are big, so zone_watermark_ok/_safe() will always return false with a high
> > classzone_idx for DMA zone, because DMA zone's lowmem_reserve is big for a high
> > classzone_idx. When kswapd runs into DMA zone, it doesn't scan/reclaim any
> > pages(no pages in lru), but mark the zone as all_unreclaimable. This can
> > happen in other low zones too.
> 
> Good catch!
> 
> > This is confusing and can potentially cause oom. Say a low zone has
> > all_unreclaimable when high zone hasn't enough memory. Then allocating
> > some pages in low zone(for example reading blkdev with highmem support),
> > then run into direct reclaim. Since the zone has all_unreclaimable set,
> > direct reclaim might reclaim nothing and an oom reported. If
> > all_unreclaimable is unset, the zone can actually reclaim some pages.
> > If all_unreclaimable is unset, in the inner loop of balance_pgdat we always have
> > all_zones_ok 0 when checking a low zone's watermark. If high zone watermark isn't
> > good, there is no problem. Otherwise, we might loop one more time in the outer
> > loop, but since high zone watermark is ok, the end_zone will be lower, then low
> > zone's watermark check will be ok and the outer loop will break. So looks this
> > doesn't bring any problem.
> 
> I think it would be better to correct zone_reclaimable.
> My point is zone_reclaimable should consider zone->pages_scanned.
> The point of the function is how many pages scanned VS how many pages remained in LRU.
> If reclaimer doesn't scan the zone at all because of no lru pages, it shouldn't tell
> the zone is all_unreclaimable.
actually this is exact my first version of the patch. The problem is if
a zone is true unreclaimable (used by kenrel pages or whatever), we will
have zone->pages_scanned 0 too. I thought we should set
all_unreclaimable in this case.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

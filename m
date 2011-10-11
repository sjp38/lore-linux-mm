Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6375A6B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 05:08:07 -0400 (EDT)
Received: by vcbfo14 with SMTP id fo14so7299016vcb.14
        for <linux-mm@kvack.org>; Tue, 11 Oct 2011 02:08:05 -0700 (PDT)
Date: Tue, 11 Oct 2011 18:07:56 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 1/2]vmscan: correct all_unreclaimable for zone without
 lru pages
Message-ID: <20111011090756.GA16202@barrios-desktop>
References: <20110929091853.GA1865@barrios-desktop>
 <1317348743.22361.29.camel@sli10-conroe>
 <20111001065943.GA6601@barrios-desktop>
 <1318043391.22361.34.camel@sli10-conroe>
 <20111008043232.GA7615@barrios-desktop>
 <1318052901.22361.49.camel@sli10-conroe>
 <20111008093531.GA8679@barrios-desktop>
 <1318140488.22361.63.camel@sli10-conroe>
 <20111009074558.GA23003@barrios-desktop>
 <20111011170941.ba7accce.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111011170941.ba7accce.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, mel <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hi Kame,

On Tue, Oct 11, 2011 at 05:09:41PM +0900, KAMEZAWA Hiroyuki wrote:
> On Sun, 9 Oct 2011 16:45:58 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> > hanks for your careful review.
> > I will send a formal version.
> > 
> > From 49078e0ebccae371b04930ae76dfd5ba158032ca Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan.kim@gmail.com>
> > Date: Sun, 9 Oct 2011 16:38:40 +0900
> > Subject: [PATCH] vmscan: judge zone's all_unreclaimable carefully
> > 
> > Shaohua Li reported all_unreclaimable of DMA zone is always set
> > because the system has a big memory HIGH zone so that lowmem_reserve[HIGH]
> > could be a big.
> > 
> > It could be a problem as follows
> > 
> > Assumption :
> > 1. The system has a big high memory so that lowmem_reserve[HIGH] of DMA zone would be big.
> > 2. HIGH/NORMAL zone are full but DMA zone has enough free pages.
> > 
> > Scenario
> > 1. A request to allocate a page in HIGH zone.
> > 2. HIGH/NORMAL zone already consumes lots of pages so that it would be fall-backed to DMA zone.
> > 3. In DMA zone, allocator got failed, too becuase lowmem_reserve[HIGH] is very big so that it wakes up kswapd
> > 4. kswapd would call shrink_zone while it see DMA zone since DMA zone's lowmem_reserve[HIGHMEM]
> >    would be big so that it couldn't meet zone_watermark_ok_safe(high_wmark_pages(zone) + balance_gap,
> >    *end_zone*)
> > 5. DMA zone doesn't meet stop condition(nr_slab != 0, !zone_reclaimable) because the zone has small lru pages
> >    and it doesn't have slab pages so that kswapd would set all_unreclaimable of the zone to *1* easily.
> > 6. B request to allocate many pages in NORMAL zone but NORMAL zone has no free pages
> >    so that it would be fall-backed to DMA zone.
> > 7. DMA zone would allocates many pages for NORMAL zone because lowmem_reserve[NORMAL] is small.
> >    These pages are used by application(ie, it menas LRU pages. Yes. Now DMA zone could have many reclaimable pages)
> > 8. C request to allocate a page in NORMAL zone but he got failed because DMA zone doesn't have enough free pages.
> >    (Most of pages in DMA zone are consumed by B)
> > 9. Kswapd try to reclaim lru pages in DMA zone but got failed because all_unreclaimable of the zone is 1. Otherwise,
> >    it could reclaim many pages which are used by B.
> > 
> > Of coures, we can do something in DEF_PRIORITY but it couldn't do enough because it can't raise
> > synchronus reclaim in direct reclaim path if the zone has many dirty pages
> > so that the process is killed by OOM.
> > 
> > The principal problem is caused by step 8.
> > In step 8, we increased # of lru size very much but still the zone->all_unreclaimable is 1.
> > If we increase lru size, it is valuable to try reclaiming again.
> > The rationale is that we reset all_unreclaimable to 0 even if we free just a one page.
> > 
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Cc: Johannes Weiner <jweiner@redhat.com>
> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Reported-by: Shaohua Li <shaohua.li@intel.com>
> > Reviewed-by: Shaohua Li <shaohua.li@intel.com>
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> 
> Hmm, catching changes of page usage in a zone ?

Not exactly.
It does catch only lru page increasement of zone.

> And this will allow to catch swap_on() and make a zone reclaimable
> even if no page usage changes. right ?

It's not in the patch but I think it could be a another patch.
Could you post it if you really need it?

> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks, Kame.

> 
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

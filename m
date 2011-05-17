Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6365D6B0029
	for <linux-mm@kvack.org>; Tue, 17 May 2011 07:34:40 -0400 (EDT)
Date: Tue, 17 May 2011 12:34:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc:
 patch.
Message-ID: <20110517113430.GM5279@suse.de>
References: <4DCDA347.9080207@cray.com>
 <BANLkTikiXUzbsUkzaKZsZg+5ugruA2JdMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <BANLkTikiXUzbsUkzaKZsZg+5ugruA2JdMA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Barry <abarry@cray.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, May 17, 2011 at 07:34:47PM +0900, Minchan Kim wrote:
> On Sat, May 14, 2011 at 6:31 AM, Andrew Barry <abarry@cray.com> wrote:
> > I believe I found a problem in __alloc_pages_slowpath, which allows a process to
> > get stuck endlessly looping, even when lots of memory is available.
> >
> > Running an I/O and memory intensive stress-test I see a 0-order page allocation
> > with __GFP_IO and __GFP_WAIT, running on a system with very little free memory.
> > Right about the same time that the stress-test gets killed by the OOM-killer,
> > the utility trying to allocate memory gets stuck in __alloc_pages_slowpath even
> > though most of the systems memory was freed by the oom-kill of the stress-test.
> >
> > The utility ends up looping from the rebalance label down through the
> > wait_iff_congested continiously. Because order=0, __alloc_pages_direct_compact
> > skips the call to get_page_from_freelist. Because all of the reclaimable memory
> > on the system has already been reclaimed, __alloc_pages_direct_reclaim skips the
> > call to get_page_from_freelist. Since there is no __GFP_FS flag, the block with
> > __alloc_pages_may_oom is skipped. The loop hits the wait_iff_congested, then
> > jumps back to rebalance without ever trying to get_page_from_freelist. This loop
> > repeats infinitely.
> >
> > Is there a reason that this loop is set up this way for 0 order allocations? I
> > applied the below patch, and the problem corrects itself. Does anyone have any
> > thoughts on the patch, or on a better way to address this situation?
> >
> > The test case is pretty pathological. Running a mix of I/O stress-tests that do
> > a lot of fork() and consume all of the system memory, I can pretty reliably hit
> > this on 600 nodes, in about 12 hours. 32GB/node.
> >
> 
> It's amazing.
> I think it's _very_ rare but it's possible if test program killed by
> oom has only lots of anonymous pages and allocation tasks try to
> allocate order-0 page with GFP_NOFS.
> 
> When the [in]active lists are empty suddenly(But I am not sure how
> come the situation happens.)

Maybe because the stress test consumed almost all, if not all, of the
LRU and then got oom-killed emptying the lists.

> and we are reclaiming order-0 page,
> compaction and __alloc_pages_direct_reclaim doesn't work. compaction
> doesn't work as it's order-0 page reclaiming.  In case of
> __alloc_pages_direct_reclaim, it would work only if we have lru pages
> in [in]active list. But unfortunately we don't have any pages in lru
> list.
> So, last resort is following codes in do_try_to_free_pages.
> 
>         /* top priority shrink_zones still had more to do? don't OOM, then */
>         if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
>                 return 1;
> 
> But it has a problem, too. all_unreclaimable checks zone->all_unreclaimable.
> zone->all_unreclaimable is set by below condition.
> 
> zone->pages_scanned < zone_reclaimable_pages(zone) * 6
> 
> If lru list is completely empty, shrink_zone doesn't work so
> zone->pages_scanned would be zero. But as we know, zone_page_state
> isn't exact by per_cpu_pageset. So it might be positive value. After
> all, zone_reclaimable always return true. It means kswapd never set
> zone->all_unreclaimable.  So last resort become nop.
> 
> In this case, current allocation doesn't have a chance to call
> get_page_from_freelist as Andrew Barry said.
> 
> Does it make sense?
> If it is, how about this?
> 

This looks like a better fix. The alternative fix continually wakes
kswapd and takes additional unnecessary steps.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

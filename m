Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 74DBC6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 04:49:20 -0400 (EDT)
Date: Tue, 24 May 2011 09:49:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc:
 patch.
Message-ID: <20110524084915.GC5279@suse.de>
References: <4DCDA347.9080207@cray.com>
 <BANLkTikiXUzbsUkzaKZsZg+5ugruA2JdMA@mail.gmail.com>
 <4DD2991B.5040707@cray.com>
 <BANLkTimYEs315jjY9OZsL6--mRq3O_zbDA@mail.gmail.com>
 <20110520164924.GB2386@barrios-desktop>
 <4DDB3A1E.6090206@jp.fujitsu.com>
 <20110524083008.GA5279@suse.de>
 <4DDB6DF6.2050700@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4DDB6DF6.2050700@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: minchan.kim@gmail.com, abarry@cray.com, akpm@linux-foundation.org, linux-mm@kvack.org, riel@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Tue, May 24, 2011 at 05:36:06PM +0900, KOSAKI Motohiro wrote:
> (2011/05/24 17:30), Mel Gorman wrote:
> > On Tue, May 24, 2011 at 01:54:54PM +0900, KOSAKI Motohiro wrote:
> >>> >From 8bd3f16736548375238161d1bd85f7d7c381031f Mon Sep 17 00:00:00 2001
> >>> From: Minchan Kim <minchan.kim@gmail.com>
> >>> Date: Sat, 21 May 2011 01:37:41 +0900
> >>> Subject: [PATCH] Prevent unending loop in __alloc_pages_slowpath
> >>>
> >>> From: Andrew Barry <abarry@cray.com>
> >>>
> >>> I believe I found a problem in __alloc_pages_slowpath, which allows a process to
> >>> get stuck endlessly looping, even when lots of memory is available.
> >>>
> >>> Running an I/O and memory intensive stress-test I see a 0-order page allocation
> >>> with __GFP_IO and __GFP_WAIT, running on a system with very little free memory.
> >>> Right about the same time that the stress-test gets killed by the OOM-killer,
> >>> the utility trying to allocate memory gets stuck in __alloc_pages_slowpath even
> >>> though most of the systems memory was freed by the oom-kill of the stress-test.
> >>>
> >>> The utility ends up looping from the rebalance label down through the
> >>> wait_iff_congested continiously. Because order=0, __alloc_pages_direct_compact
> >>> skips the call to get_page_from_freelist. Because all of the reclaimable memory
> >>> on the system has already been reclaimed, __alloc_pages_direct_reclaim skips the
> >>> call to get_page_from_freelist. Since there is no __GFP_FS flag, the block with
> >>> __alloc_pages_may_oom is skipped. The loop hits the wait_iff_congested, then
> >>> jumps back to rebalance without ever trying to get_page_from_freelist. This loop
> >>> repeats infinitely.
> >>>
> >>> The test case is pretty pathological. Running a mix of I/O stress-tests that do
> >>> a lot of fork() and consume all of the system memory, I can pretty reliably hit
> >>> this on 600 nodes, in about 12 hours. 32GB/node.
> >>>
> >>> Signed-off-by: Andrew Barry <abarry@cray.com>
> >>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> >>> Cc: Mel Gorman <mgorman@suse.de>
> >>> ---
> >>>  mm/page_alloc.c |    2 +-
> >>>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>>
> >>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >>> index 3f8bce2..e78b324 100644
> >>> --- a/mm/page_alloc.c
> >>> +++ b/mm/page_alloc.c
> >>> @@ -2064,6 +2064,7 @@ restart:
> >>>  		first_zones_zonelist(zonelist, high_zoneidx, NULL,
> >>>  					&preferred_zone);
> >>>  
> >>> +rebalance:
> >>>  	/* This is the last chance, in general, before the goto nopage. */
> >>>  	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
> >>>  			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
> >>> @@ -2071,7 +2072,6 @@ restart:
> >>>  	if (page)
> >>>  		goto got_pg;
> >>>  
> >>> -rebalance:
> >>>  	/* Allocate without watermarks if the context allows */
> >>>  	if (alloc_flags & ALLOC_NO_WATERMARKS) {
> >>>  		page = __alloc_pages_high_priority(gfp_mask, order,
> >>
> >> I'm sorry I missed this thread long time.
> >>
> >> In this case, I think we should call drain_all_pages().
> > 
> > Why?
> 
> Otherwise, we don't have good PCP dropping trigger. Big machine might have
> big pcp cache.
> 

Big machines also have a large cost for sending IPIs.

> 
> > If the direct reclaimer failed to reclaim any pages on its own, the call
> > to get_page_from_freelist() is going to be useless and there is
> > no guarantee that any other CPU managed to reclaim pages either. All
> > this ends up doing is sending in IPI which if it's very lucky will take
> > a page from another CPUs free list.
> 
> It's no matter. because did_some_progress==0 mean vmscan failed to reclaim
> any pages and reach priority==0. Thus, it obviously slow path.
> 

Maybe, but that still is no reason to send an IPI that probably isn't
going to help but incur a high cost on large machines (we've had bugs
related to excessive IPI usage before). As it is, a failure to reclaim
will fall through and assuming it has the right flags, it will wait
on congestion to clear before retrying direct reclaim. When it starts
to make progress, the pages will get drained at a time when it'll help.

> >> then following
> >> patch is better.
> >> However I also think your patch is valuable. because while the task is
> >> sleeping in wait_iff_congested(), an another task may free some pages.
> >> thus, rebalance path should try to get free pages. iow, you makes sense.
> >>
> >> So, I'd like to propose to merge both your and my patch.
> >>
> >> Thanks.
> >>
> >>
> >> From 2e77784668f6ca53d88ecb46aa6b99d9d0f33ffa Mon Sep 17 00:00:00 2001
> >> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >> Date: Tue, 24 May 2011 13:41:57 +0900
> >> Subject: [PATCH] vmscan: remove painful micro optimization
> >>
> >> Currently, __alloc_pages_direct_reclaim() call get_page_from_freelist()
> >> only if try_to_free_pages() return !0.
> >>
> >> It's no necessary micro optimization becauase "return 0" mean vmscan reached
> >> priority 0 and didn't get any pages, iow, it's really slow path. But also it
> >> has bad side effect. If we don't call drain_all_pages(), we have a chance to
> >> get infinite loop.
> >>
> > 
> > With the "rebalance" patch, where is the infinite loop?
> 
> I wrote the above.
> 

Where? Failing to call drain_all_pages() if reclaim fails is not an
infinite loop. It'll wait on congestion and retry until some progress
is made on reclaim and even then, it'll only drain the pages if the
subsequent allocation failed. That is not an infinite loop unless the
machine is wedged so badly it cannot make any progress on reclaim in
which case the machine is in serious trouble and an IPI isn't going
to fix things.

Hence, I'm failing to see why avoiding expensive IPI calls is a painful
micro-optimisation.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

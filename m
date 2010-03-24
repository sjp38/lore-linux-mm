Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2852A6B01E0
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 09:14:32 -0400 (EDT)
Date: Wed, 24 Mar 2010 14:13:58 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone pressure
Message-ID: <20100324131358.GA20640@cmpxchg.org>
References: <20100315130935.f8b0a2d7.akpm@linux-foundation.org> <20100322235053.GD9590@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100322235053.GD9590@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Mar 22, 2010 at 11:50:54PM +0000, Mel Gorman wrote:
> On Mon, Mar 15, 2010 at 01:09:35PM -0700, Andrew Morton wrote:
> > On Mon, 15 Mar 2010 13:34:50 +0100
> > Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com> wrote:
> > 
> > > c) If direct reclaim did reasonable progress in try_to_free but did not
> > > get a page, AND there is no write in flight at all then let it try again
> > > to free up something.
> > > This could be extended by some kind of max retry to avoid some weird
> > > looping cases as well.
> > > 
> > > d) Another way might be as easy as letting congestion_wait return
> > > immediately if there are no outstanding writes - this would keep the 
> > > behavior for cases with write and avoid the "running always in full 
> > > timeout" issue without writes.
> > 
> > They're pretty much equivalent and would work.  But there are two
> > things I still don't understand:
> > 
> > 1: Why is direct reclaim calling congestion_wait() at all?  If no
> > writes are going on there's lots of clean pagecache around so reclaim
> > should trivially succeed.  What's preventing it from doing so?
> > 
> > 2: This is, I think, new behaviour.  A regression.  What caused it?
> > 
> 
> 120+ kernels and a lot of hurt later;
> 
> Short summary - The number of times kswapd and the page allocator have been
> 	calling congestion_wait and the length of time it spends in there
> 	has been increasing since 2.6.29. Oddly, it has little to do
> 	with the page allocator itself.
> 
> Test scenario
> =============
> X86-64 machine 1 socket 4 cores
> 4 consumer-grade disks connected as RAID-0 - software raid. RAID controller
> 	on-board and a piece of crap, and a decent RAID card could blow
> 	the budget.
> Booted mem=256 to ensure it is fully IO-bound and match closer to what
> 	Christian was doing
> 
> At each test, the disks are partitioned, the raid arrays created and an
> ext2 filesystem created. iozone sequential read/write tests are run with
> increasing number of processes up to 64. Each test creates 8G of files. i.e.
> 1 process = 8G. 2 processes = 2x4G etc
> 
> 	iozone -s 8388608 -t 1 -r 64 -i 0 -i 1
> 	iozone -s 4194304 -t 2 -r 64 -i 0 -i 1
> 	etc.
> 
> Metrics
> =======
> 
> Each kernel was instrumented to collected the following stats
> 
> 	pg-Stall	Page allocator stalled calling congestion_wait
> 	pg-Wait		The amount of time spent in congestion_wait
> 	pg-Rclm		Pages reclaimed by direct reclaim
> 	ksd-stall	balance_pgdat() (ie kswapd) staled on congestion_wait
> 	ksd-wait	Time spend by balance_pgdat in congestion_wait
> 
> Large differences in this do not necessarily show up in iozone because the
> disks are so slow that the stalls are a tiny percentage overall. However, in
> the event that there are many disks, it might be a greater problem. I believe
> Christian is hitting a corner case where small delays trigger a much larger
> stall.
> 
> Why The Increases
> =================
> 
> The big problem here is that there was no one change. Instead, it has been
> a steady build-up of a number of problems. The ones I identified are in the
> block IO, CFQ IO scheduler, tty and page reclaim. Some of these are fixed
> but need backporting and others I expect are a major surprise. Whether they
> are worth backporting or not heavily depends on whether Christian's problem
> is resolved.
> 
> Some of the "fixes" below are obviously not fixes at all. Gathering this data
> took a significant amount of time. It'd be nice if people more familiar with
> the relevant problem patches could spring a theory or patch.
> 
> The Problems
> ============

[...]

> 3. Page reclaim evict-once logic from 56e49d21 hurts really badly
> 	fix title: revertevict
> 	fixed in mainline? no
> 	affects: 2.6.31 to now
> 
> 	For reasons that are not immediately obvious, the evict-once patches
> 	*really* hurt the time spent on congestion and the number of pages
> 	reclaimed. Rik, I'm afaid I'm punting this to you for explanation
> 	because clearly you tested this for AIM7 and might have some
> 	theories. For the purposes of testing, I just reverted the changes.
> 

[...]

> Results
> =======
> 
> Here are the highlights of kernels tested. I'm omitting the bisection
> results for obvious reasons. The metrics were gathered at two points;
> after filesystem creation and after IOZone completed.
> 
> The lower the number for each metric, the better.
> 
>                                                      After Filesystem Setup                                       After IOZone
>                                          pg-Stall  pg-Wait  pg-Rclm  ksd-stall  ksd-wait        pg-Stall  pg-Wait  pg-Rclm  ksd-stall  ksd-wait

[...]

> Again, fixing tty and reverting evict-once helps bring figures more in line
> with 2.6.29.
> 
> 2.6.33                                          0        0        0          3         0          152248   754226  4940952     267214         0
> 2.6.33-revertevict                              0        0        0          3         0             883     4306    28918        507         0
> 2.6.33-ttyfix                                   0        0        0          3         0          157831   782473  5129011     237116         0
> 2.6.33-ttyfix-revertevict                       0        0        0          2         0            1056     5235    34796        519         0
> 2.6.33.1                                        0        0        0          3         1          156422   776724  5078145     234938         0
> 2.6.33.1-revertevict                            0        0        0          2         0            1095     5405    36058        477         0
> 2.6.33.1-ttyfix                                 0        0        0          3         1          136324   673148  4434461     236597         0
> 2.6.33.1-ttyfix-revertevict                     0        0        0          1         1            1339     6624    43583        466         0
> 
> At this point, the CFQ commit "cfq-iosched: fairness for sync no-idle
> queues" has lodged itself deep within CGQ and I couldn't tear it out or
> see how to fix it. Fixing tty and reverting evict-once helps but the number
> of stalls is significantly increased and a much larger number of pages get
> reclaimed overall.
> 
> Corrado?
> 
> 2.6.34-rc1                                      0        0        0          1         1          150629   746901  4895328     239233         0
> 2.6.34-rc1-revertevict                          0        0        0          1         0            2595    12901    84988        622         0

I was wondering why kswapd would not make any progress and stall without
dirty pages, luckily Rik has better eyes than me.

So if he is right and most inactive pages are under IO (thus locked and
skipped) when kswapd is running, we have two choices:

  1) deactivate pages and reclaim them instead
  2) sleep and wait for IO to finish

The patch in question changes 1) to 2) because it won't scan small active
lists and the inactive list does not shrink in size when rotating busy
pages.

You said pg-Rclm is only direct reclaim.  I assume the sum of reclaimed
pages from kswapd and direct reclaim stays in the same ballpark, only
the ratio shifted towards direct reclaim?

Waiting for the disks seems to be better than going after the working set
but I have a feeling we are waiting for the wrong event to happen there.

I am amazingly ignorant when it comes to the block layer, but glancing over
the queue congestion code, it seems we are waiting for the queue to shrink
below a certain threshold.  Is this correct?

When it comes to the reclaim scanner, however, aren't we more interested in
single completions than in the overall state of the queue?

With such a constant stream of IO as in Mel's test, I could imagine that
the queue never really gets below that threshold (here goes the ignorance part)
and we always hit the timeout.  While what we really want is to be woken
up when, say, SWAP_CLUSTER_MAX pages finished since we went to sleep.

Because at that point there is a chance to reclaim some pages again,
even if a lot of requests are still pending.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

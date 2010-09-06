Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B8F196B004A
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:51:15 -0400 (EDT)
Date: Tue, 7 Sep 2010 07:50:23 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-ID: <20100906215023.GC7362@dastard>
References: <20100903202101.f937b0bb.akpm@linux-foundation.org>
 <20100904075840.GE705@dastard>
 <20100904081414.GF705@dastard>
 <20100905015400.GA10714@localhost>
 <20100905021555.GG705@dastard>
 <20100905060539.GA17450@localhost>
 <20100905131447.GJ705@dastard>
 <20100905134554.GA7083@localhost>
 <20100906040243.GA7362@dastard>
 <20100906084015.GJ8384@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100906084015.GJ8384@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 06, 2010 at 09:40:15AM +0100, Mel Gorman wrote:
> On Mon, Sep 06, 2010 at 02:02:43PM +1000, Dave Chinner wrote:
> > however, here are the fs_mark processes:
> > 
> > [  596.628086] fs_mark       R  running task        0  2373   2163 0x00000008
> > [  596.628086]  0000000000000000 ffffffff81bb8610 00000000000008fc 0000000000000002
> > [  596.628086]  0000000000000000 0000000000000296 0000000000000297 ffffffffffffff10
> > [  596.628086]  ffffffff810b48c2 0000000000000010 0000000000000202 ffff880116b61798
> > [  596.628086] Call Trace:
> > [  596.628086]  [<ffffffff810b48c2>] ? smp_call_function_many+0x1a2/0x210
> > [  596.628086]  [<ffffffff810b48a5>] ? smp_call_function_many+0x185/0x210
> > [  596.628086]  [<ffffffff81109ff0>] ? drain_local_pages+0x0/0x20
> > [  596.628086]  [<ffffffff810b4952>] ? smp_call_function+0x22/0x30
> > [  596.628086]  [<ffffffff81084934>] ? on_each_cpu+0x24/0x50
> > [  596.628086]  [<ffffffff81108a8c>] ? drain_all_pages+0x1c/0x20
> > [  596.628086]  [<ffffffff81108fad>] ? __alloc_pages_nodemask+0x42d/0x700
> > [  596.628086]  [<ffffffff8113d0f2>] ? kmem_getpages+0x62/0x160
> > [  596.628086]  [<ffffffff8113dce6>] ? fallback_alloc+0x196/0x240
> > [  596.628086]  [<ffffffff8113da68>] ? ____cache_alloc_node+0x98/0x180
> > [  596.628086]  [<ffffffff8113e643>] ? __kmalloc+0x193/0x230
> > [  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
> > [  596.628086]  [<ffffffff8131083f>] ? kmem_alloc+0x8f/0xe0
> > [  596.628086]  [<ffffffff8131092e>] ? kmem_zalloc+0x1e/0x50
> > [  596.628086]  [<ffffffff812fac80>] ? xfs_log_commit_cil+0x500/0x590
> > [  596.628086]  [<ffffffff81310943>] ? kmem_zalloc+0x33/0x50
> 
> This looks like an order-0 allocation. The "Drain per-cpu lists after
> direct reclaim allocation fails" avoids calling drain_all_pages() for a
> number of cases but introduces a case where it's called for order-0
> pages. The intention was to avoid allocations failing just because of
> the lists but maybe it's happening too often.

Yes, that should be an order-0 allocation. Possibly an order-1
allocation. but unlikely.

> I include a patch at the very end of this mail that might relieve this.

Ok, I'll try it later today.

> > I just went to grab the CAL counters, and found the system in
> > another livelock.  This time I managed to start the sysrq-trigger
> > dump while the livelock was in progress - I bas??cally got one shot
> > at a command before everything stopped responding. Now I'm waiting
> > for the livelock to pass.... 5min.... the fs_mark workload
> > has stopped (ctrl-c finally responded), still livelocked....
> > 10min.... 15min.... 20min.... OK, back now.
> > 
> > Interesting - all the fs_mark processes are in D state waiting on IO
> > completion processing.
> 
> Very interesting, maybe they are all stuck in congestion_wait() this
> time? There are a few sources where that is possible.

No, they are waiting on log IO completion, not doing allocation or
in the VM at all.  They stuck in xlog_get_iclog_state() waiting for
all the log IO buffers to be processed which are stuck behind the
inode buffer IO completions in th kworker threads that I posted. 

This potentially is caused by the kworker thread consolidation - log
IO completion processing used to be in a separate workqueue for
processing latency and deadlock prevention reasons - the data and
metadata IO completion can block, whereas we need the log IO
completion to occur as quickly as possible. I've seen one deadlock
that the separate work queues solved w.r.t. loop devices, and I
suspect that part of the problem here is that transaction completion
cannot occur (and free the memory it and the CIL holds) because log IO
completion processing is being delayed significantly by metadata IO
completion...

> > A second set of
> > traces I got during the livelock also showed this:
....
> > 
> > Because I tried to ctrl-c the fs_mark workload. All those lock
> > traces on the stack aren't related to XFS, so I'm wondering exactly
> > where they have come from....
> > 
> > Finally, /proc/interrupts shows:
> > 
> > CAL:      12156      12039      12676      12478      12919    12177      12767      12460   Function call interrupts
> > 
> > Which shows that this wasn't an IPI storm that caused this
> > particular livelock.
> 
> No, but it's possible we got stuck somewhere like too_many_isolated() or
> in congestion_wait. One thing at a time though, would you mind testing
> the following patch? I haven't tested this *at all* but it should reduce
> the number of times drain_all_pages() are called further while not
> eliminating them entirely.

Ok, I'll try it later today, but first I think I need to do some
deeper investigation on the kworker thread behaviour....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

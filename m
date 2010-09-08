Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8448B6B004A
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 04:50:07 -0400 (EDT)
Date: Wed, 8 Sep 2010 18:49:23 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-ID: <20100908084923.GW705@dastard>
References: <20100904075840.GE705@dastard>
 <20100904081414.GF705@dastard>
 <20100905015400.GA10714@localhost>
 <20100905021555.GG705@dastard>
 <20100905060539.GA17450@localhost>
 <20100905131447.GJ705@dastard>
 <20100905134554.GA7083@localhost>
 <20100906040243.GA7362@dastard>
 <20100906084015.GJ8384@csn.ul.ie>
 <20100906215023.GC7362@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100906215023.GC7362@dastard>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 07, 2010 at 07:50:23AM +1000, Dave Chinner wrote:
> On Mon, Sep 06, 2010 at 09:40:15AM +0100, Mel Gorman wrote:
> > On Mon, Sep 06, 2010 at 02:02:43PM +1000, Dave Chinner wrote:
> > > I just went to grab the CAL counters, and found the system in
> > > another livelock.  This time I managed to start the sysrq-trigger
> > > dump while the livelock was in progress - I bas??cally got one shot
> > > at a command before everything stopped responding. Now I'm waiting
> > > for the livelock to pass.... 5min.... the fs_mark workload
> > > has stopped (ctrl-c finally responded), still livelocked....
> > > 10min.... 15min.... 20min.... OK, back now.
> > > 
> > > Interesting - all the fs_mark processes are in D state waiting on IO
> > > completion processing.
> > 
> > Very interesting, maybe they are all stuck in congestion_wait() this
> > time? There are a few sources where that is possible.
> 
> No, they are waiting on log IO completion, not doing allocation or
> in the VM at all.  They stuck in xlog_get_iclog_state() waiting for
> all the log IO buffers to be processed which are stuck behind the
> inode buffer IO completions in th kworker threads that I posted. 
> 
> This potentially is caused by the kworker thread consolidation - log
> IO completion processing used to be in a separate workqueue for
> processing latency and deadlock prevention reasons - the data and
> metadata IO completion can block, whereas we need the log IO
> completion to occur as quickly as possible. I've seen one deadlock
> that the separate work queues solved w.r.t. loop devices, and I
> suspect that part of the problem here is that transaction completion
> cannot occur (and free the memory it and the CIL holds) because log IO
> completion processing is being delayed significantly by metadata IO
> completion...
.....
> > > Which shows that this wasn't an IPI storm that caused this
> > > particular livelock.
> > 
> > No, but it's possible we got stuck somewhere like too_many_isolated() or
> > in congestion_wait. One thing at a time though, would you mind testing
> > the following patch? I haven't tested this *at all* but it should reduce
> > the number of times drain_all_pages() are called further while not
> > eliminating them entirely.
> 
> Ok, I'll try it later today, but first I think I need to do some
> deeper investigation on the kworker thread behaviour....

Ok, so an update is needed here. I have confirmed that the above
livelock was caused by the kworker thread consolidation, and I have
a fix for it (make the log IO completion processing queue WQ_HIGHPRI
so it gets queued ahead of the data/metadata IO completions), and
I've been able to create over a billion inodes now without a
livelock occurring. See the thread titled "[2.6.36-rc3] Workqueues,
XFS, dependencies and deadlock" if you want more details.

To make sure I've been seeing two different livelocks, I removed
Mel's series from my tree (which still contained the above workqueue
fix), and I started seeing short memory allocation livelocks (10-15s
at most) with abnormal increases in CAL counts indication an
increase in IPIs during the short livelocks.  IOWs, the livelock
was't as severe as before the workqueue fix, but still present.
Hence the workqueue issue was definitely a contributing factor to
the severity of the memory allocation triggered issue.

It is clear that there have been two different livelocks with
different caused by the same test, which has led to a lot of
confusion in this thread. It appears that Mel's patch series as
originally posted in this thread is all that is necessary to avoid
the memory allocation livelock issue I was seeing. The workqueue
fix solves the other livelock I was seeing once Mel's patches were
in place.

Thanks to everyone for helping me track these livelocks down and
providing lots of suggestions for things to try. I'll keep testing
and looking for livelocks, but my confidence is increasing that
we've got to the root of them now. 

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

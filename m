Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8406B01F1
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 04:16:54 -0400 (EDT)
Date: Fri, 27 Aug 2010 10:16:48 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] writeback: Record if the congestion was unnecessary
Message-ID: <20100827081648.GD6805@cmpxchg.org>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
 <1282835656-5638-3-git-send-email-mel@csn.ul.ie>
 <20100826182904.GC6805@cmpxchg.org>
 <20100826203130.GL20944@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100826203130.GL20944@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 09:31:30PM +0100, Mel Gorman wrote:
> On Thu, Aug 26, 2010 at 08:29:04PM +0200, Johannes Weiner wrote:
> > On Thu, Aug 26, 2010 at 04:14:15PM +0100, Mel Gorman wrote:
> > > If congestion_wait() is called when there is no congestion, the caller
> > > will wait for the full timeout. This can cause unreasonable and
> > > unnecessary stalls. There are a number of potential modifications that
> > > could be made to wake sleepers but this patch measures how serious the
> > > problem is. It keeps count of how many congested BDIs there are. If
> > > congestion_wait() is called with no BDIs congested, the tracepoint will
> > > record that the wait was unnecessary.
> > 
> > I am not convinced that unnecessary is the right word.  On a workload
> > without any IO (i.e. no congestion_wait() necessary, ever), I noticed
> > the VM regressing both in time and in reclaiming the right pages when
> > simply removing congestion_wait() from the direct reclaim paths (the
> > one in __alloc_pages_slowpath and the other one in
> > do_try_to_free_pages).
> > 
> > So just being stupid and waiting for the timeout in direct reclaim
> > while kswapd can make progress seemed to do a better job for that
> > load.
> > 
> > I can not exactly pinpoint the reason for that behaviour, it would be
> > nice if somebody had an idea.
> > 
> 
> There is a possibility that the behaviour in that case was due to flusher
> threads doing the writes rather than direct reclaim queueing pages for IO
> in an inefficient manner. So the stall is stupid but happens to work out
> well because flusher threads get the chance to do work.

The workload was accessing a large sparse-file through mmap, so there
wasn't much IO in the first place.

And I experimented on the latest -mmotm where direct reclaim wouldn't
do writeback by itself anymore, but kick the flushers.

> > So personally I think it's a good idea to get an insight on the use of
> > congestion_wait() [patch 1] but I don't agree with changing its
> > behaviour just yet, or judging its usefulness solely on whether it
> > correctly waits for bdi congestion.
> > 
> 
> Unfortunately, I strongly suspect that some of the desktop stalls seen during
> IO (one of which involved no writes) were due to calling congestion_wait
> and waiting the full timeout where no writes are going on.

Oh, I am in full agreement here!  Removing those congestion_wait() as
described above showed a reduction in peak latency.  The dilemma is
only that it increased the overall walltime of the load.

And the scanning behaviour deteriorated, as in having increased
scanning pressure on other zones than the unpatched kernel did.

So I think very much that we need a fix.  congestion_wait() causes
stalls and relying on random sleeps for the current reclaim behaviour
can not be the solution, at all.

I just don't think we can remove it based on the argument that it
doesn't do what it is supposed to do, when it does other things right
that it is not supposed to do ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

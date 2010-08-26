Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B1FA96B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 16:31:46 -0400 (EDT)
Date: Thu, 26 Aug 2010 21:31:30 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] writeback: Record if the congestion was unnecessary
Message-ID: <20100826203130.GL20944@csn.ul.ie>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie> <1282835656-5638-3-git-send-email-mel@csn.ul.ie> <20100826182904.GC6805@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100826182904.GC6805@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 26, 2010 at 08:29:04PM +0200, Johannes Weiner wrote:
> On Thu, Aug 26, 2010 at 04:14:15PM +0100, Mel Gorman wrote:
> > If congestion_wait() is called when there is no congestion, the caller
> > will wait for the full timeout. This can cause unreasonable and
> > unnecessary stalls. There are a number of potential modifications that
> > could be made to wake sleepers but this patch measures how serious the
> > problem is. It keeps count of how many congested BDIs there are. If
> > congestion_wait() is called with no BDIs congested, the tracepoint will
> > record that the wait was unnecessary.
> 
> I am not convinced that unnecessary is the right word.  On a workload
> without any IO (i.e. no congestion_wait() necessary, ever), I noticed
> the VM regressing both in time and in reclaiming the right pages when
> simply removing congestion_wait() from the direct reclaim paths (the
> one in __alloc_pages_slowpath and the other one in
> do_try_to_free_pages).
> 
> So just being stupid and waiting for the timeout in direct reclaim
> while kswapd can make progress seemed to do a better job for that
> load.
> 
> I can not exactly pinpoint the reason for that behaviour, it would be
> nice if somebody had an idea.
> 

There is a possibility that the behaviour in that case was due to flusher
threads doing the writes rather than direct reclaim queueing pages for IO
in an inefficient manner. So the stall is stupid but happens to work out
well because flusher threads get the chance to do work.

> So personally I think it's a good idea to get an insight on the use of
> congestion_wait() [patch 1] but I don't agree with changing its
> behaviour just yet, or judging its usefulness solely on whether it
> correctly waits for bdi congestion.
> 

Unfortunately, I strongly suspect that some of the desktop stalls seen during
IO (one of which involved no writes) were due to calling congestion_wait
and waiting the full timeout where no writes are going on.

It gets potentially worse too. Lets say we have a system with many BDIs of
different speed - e.g. SSD on one end of the spectrum and USB flash drive
on the other. The congestion for writes could be on the USB flash drive but
due to low memory, the allocator, direct reclaimers and kswapd go to sleep
periodically on congestion_wait for USB even though the bulk of the pages
need reclaiming are backed by an SSD.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

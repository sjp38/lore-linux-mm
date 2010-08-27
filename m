Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD706B01F4
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 05:34:11 -0400 (EDT)
Date: Fri, 27 Aug 2010 10:33:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] writeback: Do not congestion sleep when there are
	no congested BDIs
Message-ID: <20100827093355.GC19556@csn.ul.ie>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie> <1282835656-5638-4-git-send-email-mel@csn.ul.ie> <20100827051316.GH705@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100827051316.GH705@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 03:13:16PM +1000, Dave Chinner wrote:
> On Thu, Aug 26, 2010 at 04:14:16PM +0100, Mel Gorman wrote:
> > If congestion_wait() is called with no BDIs congested, the caller will
> > sleep for the full timeout and this is an unnecessary sleep.
> 
> That, I think, is an invalid assumption. congestion_wait is used in
> some places as a backoff mechanism that waits for some IO work to be
> done, with congestion disappearing being a indication that progress
> has been made and so we can retry sooner than the entire timeout.
> 

As it's write IO rather than some IO, I wonder if that's really the
right thing to do. However, I accept your (and others) point that
converting all congestion_wait() callers may be too much of a change.

> For example, if _xfs_buf_lookup_pages() fails to allocate page cache
> pages for a buffer, it will kick the xfsbufd to writeback dirty
> buffers (so they can be freed) and immediately enter
> congestion_wait(). If there isn't congestion when we enter
> congestion_wait(), we still want to give the xfsbufds a chance to
> clean some pages before we retry the allocation for the new buffer.
> Removing the congestion_wait() sleep behaviour will effectively
> _increase_ memory pressure with XFS on fast disk subsystems because
> it now won't backoff between failed allocation attempts...
> 
> Perhaps a congestion_wait_iff_congested() variant is needed for the
> VM? I can certainly see how it benefits the VM from a latency
> perspective, but it is the opposite behaviour that is expected in
> other places...
> 

I'm added a wait_iff_congested() and updated a few of the VM callers. I changed
a fairly minimum number of what appeared to be the obvious ones to change.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2252E6B0219
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 00:45:08 -0400 (EDT)
Date: Wed, 14 Apr 2010 14:44:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100414044458.GF2493@dastard>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com>
 <m2h28c262361004131724ycf9bf4a5xd9b1bad2b4797f50@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m2h28c262361004131724ycf9bf4a5xd9b1bad2b4797f50@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 09:24:33AM +0900, Minchan Kim wrote:
> Hi, Dave.
> 
> On Tue, Apr 13, 2010 at 9:17 AM, Dave Chinner <david@fromorbit.com> wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> >
> > When we enter direct reclaim we may have used an arbitrary amount of stack
> > space, and hence enterring the filesystem to do writeback can then lead to
> > stack overruns. This problem was recently encountered x86_64 systems with
> > 8k stacks running XFS with simple storage configurations.
> >
> > Writeback from direct reclaim also adversely affects background writeback. The
> > background flusher threads should already be taking care of cleaning dirty
> > pages, and direct reclaim will kick them if they aren't already doing work. If
> > direct reclaim is also calling ->writepage, it will cause the IO patterns from
> > the background flusher threads to be upset by LRU-order writeback from
> > pageout() which can be effectively random IO. Having competing sources of IO
> > trying to clean pages on the same backing device reduces throughput by
> > increasing the amount of seeks that the backing device has to do to write back
> > the pages.
> >
> > Hence for direct reclaim we should not allow ->writepages to be entered at all.
> > Set up the relevant scan_control structures to enforce this, and prevent
> > sc->may_writepage from being set in other places in the direct reclaim path in
> > response to other events.
> 
> I think your solution is rather aggressive change as Mel and Kosaki
> already pointed out.

It may be agressive, but writeback from direct reclaim is, IMO, one
of the worst aspects of the current VM design because of it's
adverse effect on the IO subsystem.

I'd prefer to remove it completely that continue to try and patch
around it, especially given that everyone seems to agree that it
does have an adverse affect on IO...

> Do flush thread aware LRU of dirty pages in system level recency not
> dirty pages recency?

It writes back in the order inodes were dirtied. i.e. the LRU is a
coarser measure, but it it still definitely there. It also takes
into account fairness of IO between dirty inodes, so no one dirty
inode prevents IO beining issued on a other dirty inodes on the
LRU...

> Of course flush thread can clean dirty pages faster than direct reclaimer.
> But if it don't aware LRUness, hot page thrashing can be happened by
> corner case.
> It could lost write merge.
> 
> And non-rotation storage might be not big of seek cost.

Non-rotational storage still goes faster when it is fed large, well
formed IOs.

> I think we have to consider that case if we decide to change direct reclaim I/O.
> 
> How do we separate the problem?
> 
> 1. stack hogging problem.
> 2. direct reclaim random write.

AFAICT, the only way to _reliably_ avoid the stack usage problem is
to avoid writeback in direct reclaim. That has the side effect of
fixing #2 as well, so do they really need separating?

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

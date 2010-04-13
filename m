Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 506106B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 06:29:17 -0400 (EDT)
Date: Tue, 13 Apr 2010 20:29:38 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100413102938.GX2493@dastard>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com>
 <20100413142445.D0FE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100413142445.D0FE.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 05:31:25PM +0900, KOSAKI Motohiro wrote:
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
> Ummm..
> This patch is harder to ack. This patch's pros/cons seems
> 
> Pros:
> 	1) prevent XFS stack overflow
> 	2) improve io workload performance
> 
> Cons:
> 	3) TOTALLY kill lumpy reclaim (i.e. high order allocation)
> 
> So, If we only need to consider io workload this is no downside. but
> it can't.
> 
> I think (1) is XFS issue. XFS should care it itself.

The filesystem is irrelevant, IMO.

The traces from the reporter showed that we've got close to a 2k
stack footprint for memory allocation to direct reclaim and then we
can put the entire writeback path on top of that. This is roughly
3.5k for XFS, and then depending on the storage subsystem
configuration and transport can be another 2k of stack needed below
XFS.

IOWs, if we completely ignore the filesystem stack usage, there's
still up to 4k of stack needed in the direct reclaim path. Given
that one of the stack traces supplied show direct reclaim being
entered with over 3k of stack already used, pretty much any
filesystem is capable of blowing an 8k stack.

So, this is not an XFS issue, even though XFS is the first to
uncover it. Don't shoot the messenger....

> but (2) is really
> VM issue. Now our VM makes too agressive pageout() and decrease io 
> throughput. I've heard this issue from Chris (cc to him). I'd like to 
> fix this.

I didn't expect this to be easy. ;)

I had a good look at what the code was doing before I wrote the
patch, and IMO, there is no good reason for issuing IO from direct
reclaim.

My reasoning is as follows - consider a system with a typical
sata disk and the machine is low on memory and in direct reclaim.

direct reclaim is taking pages of the end of the LRU and writing
them one at a time from there. It is scanning thousands of pages
pages and it triggers IO on on the dirty ones it comes across.
This is done with no regard to the IO patterns it generates - it can
(and frequently does) result in completely random single page IO
patterns hitting the disk, and as a result cleaning pages happens
really, really slowly. If we are in a OOM situation, the machine
will grind to a halt as it struggles to clean maybe 1MB of RAM per
second.

On the other hand, if the IO is well formed then the disk might be
capable of 100MB/s. The background flusher threads and filesystems
try very hard to issue well formed IOs, so the difference in the
rate that memory can be cleaned may be a couple of orders of
magnitude.

(Of course, the difference will typically be somewhere in between
these two extremes, but I'm simply trying to illustrate how big
the difference in performance can be.)

IOWs, the background flusher threads are there to clean memory by
issuing IO as efficiently as possible.  Direct reclaim is very
efficient at reclaiming clean memory, but it really, really sucks at
cleaning dirty memory in a predictable and deterministic manner. It
is also much more likely to hit worst case IO patterns than the
background flusher threads.

Hence I think that direct reclaim should be deferring to the
background flusher threads for cleaning memory and not trying to be
doing it itself.

> but we never kill pageout() completely because we can't
> assume users don't run high order allocation workload.

I think that lumpy reclaim will still work just fine.

Lumpy reclaim appears to be using IO as a method of slowing
down the reclaim cycle - the congestion_wait() call will still
function as it does now if the background flusher threads are active
and causing congestion. I don't see why lumpy reclaim specifically
needs to be issuing IO to make it work - if the congestion_wait() is
not waiting long enough then wait longer - don't issue IO to extend
the wait time.

Also, there doesn't appear to be anything special about the chunks of
pages it's issuing IO on and waiting for, either. They are simply
the last N pages on the LRU that could be grabbed so they have no
guarantee of contiguity, so the IO it issues does nothing specific
to help higher order allocations to succeed.

Hence it really seems to me that the effectiveness of lumpy reclaim
is determined mostly by the effectiveness of the IO subsystem - the
faster the IO subsystem cleans pages, the less time lumpy reclaim
will block and the faster it will free pages. From this observation
and the fact that issuing IO only from the bdi flusher threads will
have the same effect (improves IO subsystem effectiveness), it seems
to me that lumpy reclaim should not be adversely affected by this
change.

Of course, the code is a maze of twisty passages, so I probably
missed something important. Hopefully someone can tell me what. ;)

FWIW, the biggest problem here is that I have absolutely no clue on
how to test what the impact on lumpy reclaim really is. Does anyone
have a relatively simple test that can be run to determine what the
impact is?

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

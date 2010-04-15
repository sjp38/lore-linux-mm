Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 762426B01E3
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 04:54:29 -0400 (EDT)
Date: Thu, 15 Apr 2010 18:54:20 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100415085420.GT2493@dastard>
References: <20100415130212.D16E.A69D9226@jp.fujitsu.com>
 <20100415062055.GQ2493@dastard>
 <20100415152816.D18C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100415152816.D18C.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 03:35:14PM +0900, KOSAKI Motohiro wrote:
> > On Thu, Apr 15, 2010 at 01:09:01PM +0900, KOSAKI Motohiro wrote:
> > > Hi
> > > 
> > > > How about this? For now, we stop direct reclaim from doing writeback
> > > > only on order zero allocations, but allow it for higher order
> > > > allocations. That will prevent the majority of situations where
> > > > direct reclaim blows the stack and interferes with background
> > > > writeout, but won't cause lumpy reclaim to change behaviour.
> > > > This reduces the scope of impact and hence testing and validation
> > > > the needs to be done.
> > > 
> > > Tend to agree. but I would proposed slightly different algorithm for
> > > avoind incorrect oom.
> > > 
> > > for high order allocation
> > > 	allow to use lumpy reclaim and pageout() for both kswapd and direct reclaim
> > 
> > SO same as current.
> 
> Yes. as same as you propsed.
> 
> > 
> > > for low order allocation
> > > 	- kswapd:          always delegate io to flusher thread
> > > 	- direct reclaim:  delegate io to flusher thread only if vm pressure is low
> > 
> > IMO, this really doesn't fix either of the problems - the bad IO
> > patterns nor the stack usage. All it will take is a bit more memory
> > pressure to trigger stack and IO problems, and the user reporting the
> > problems is generating an awful lot of memory pressure...
> 
> This patch doesn't care stack usage. because
>   - again, I think all stack eater shold be diet.

Agreed (again), but we've already come to the conclusion that a
stack diet is not enough.

>   - under allowing lumpy reclaim world, only deny low order reclaim
>     doesn't solve anything.

Yes, I suggested it *as a first step*, not as the end goal. Your
patches don't reach the first step which is fixing the reported
stack problem for order-0 allocations...

> Please don't forget priority=0 recliam failure incvoke OOM-killer.
> I don't imagine anyone want it.

Given that I haven't been able to trigger OOM without writeback from
direct reclaim so far (*) I'm not finding any evidence that it is a
problem or that there are regressions.  I want to be able to say
that this change has no known regressions. I want to find the
regression and  work to fix them, but without test cases there's no
way I can do this.

This is what I'm getting frustrated about - I want to fix this
problem once and for all, but I can't find out what I need to do to
robustly test such a change so we can have a high degree of
confidence that it doesn't introduce major regressions. Can anyone
help here?

(*) except in one case I've already described where it mananged to
allocate enough huge pages to starve the system of order zero pages,
which is what I asked it to do.

> And, Which IO workload trigger <6 priority vmscan?

You're asking me? I've been asking you for workloads that wind up
reclaim priority.... :/

All I can say is that the most common trigger I see for OOM is
copying a large file on a busy system that is running off a single
spindle.  When that happens on my laptop I walk away and get a cup
of coffee when that happens and when I come back I pick up all the
broken bits the OOM killer left behind.....

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

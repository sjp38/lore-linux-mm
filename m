Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB196B0255
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 21:42:28 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so4654354pad.3
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 18:42:28 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id kw7si1374441pbc.3.2015.09.16.18.42.26
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 18:42:27 -0700 (PDT)
Date: Thu, 17 Sep 2015 11:41:48 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFD] memory pressure and sizing problem
Message-ID: <20150917014148.GX26895@dastard>
References: <20150903154445.GA10394@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150903154445.GA10394@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Sep 03, 2015 at 11:44:45AM -0400, Tejun Heo wrote:
> Hello,
> 
> It's bothering that we don't have a good mechanism to detect and
> expose memory pressure and it doesn't seem to be for want of trying.
> I've been thinking about it for several days and would like to find
> out whether it makes sense.  Not being a mm person, I'm likely
> mistaken in a lot of details, if not the core concept.  Please point
> out whenever I wander into the lala land.
> 
> 
> 1. Background
> 
> AFAIK, there currently are two metrics in use.  One is scan ratio -
> how many pages are being scanned for reclaim per unit time.  This is
> what paces the different reclaimers.  While it is related to memory
> pressure, it involves enough of other factors to be useful as a
> measure of pressure - e.g. a high-bandwidth streaming workload would
> cause high scan ratio but can't be said to be under memory pressure.

There are other places we generate memory pressure, too - some slab
caches can generate more pressure than the page cache in various
workloads. If we are going to have a "generic memory pressure"
measurement then we need to include caches that have shrinkers to
control their size....

> 2. Memory pressure and sizing problem
> 
> Memory pressure sounds intuitive but isn't actually that well defined.
> It's closely tied to answering the sizing problem - "how much memory
> does a given workload need to run smoothly?" and answering that has
> become more important with cgroup and containerization.
> 
> Sizing is inherently tricky because mm only tracks a small portion of
> all memory accesses.  We can't tell "this process referenced this page
> twice, 2mins and 18secs ago".  Deciding whether a page is actively
> used costs and we only track enough information to make reclaim work
> reasonably.  Consequently, it's impossible to tell the working set
> size of a workload without subjecting it to memory reclaim.

Right, that's why some subsystems have moved away from using the
page cache for large scale caching - the single access bit is
insufficient to express the relative reclaim priority of a given
page.

> Once a workload is subject to memory reclaim, we need a way to tell
> whether it needs more memory and that measure can be called memory
> pressure - a workload is under memory pressure if it needs more memory
> to execute smoothly.  More precisely, I think it can be defined as the
> following.

Define "smoothly". :)

> 3. Memory pressure
> 
>   In a given amount of time, the proportion of time that the execution
>   duration of the workload has been lengthened due to lack of memory.
> 
> I used "lengthened" instead of "delayed" because delays don't
> necessarily indicate that the workload can benefit from more memory.
> Consider the following execution pattern where '_' is idle and '+' is
> running.  Let's assume that each CPU burst is caused by receiving a
> request over network.
> 
>   W0: ++____++____++____
> 
> Let's say the workload now needs to fault in some memory during each
> CPU burst - represented by 'm'.
> 
>   W1: +mm+__+mm+__+mm+__
> 
> While delays due to memory shortage have occurred, the duration of the
> execution stayed the same.  In terms of amount of work done, the
> workload wouldn't have benefited from more memory.  Now, consider the
> following workload where 'i' represents direct IO from filesystem.
> 
>   W2: ++iiii++iiii++iiii
> 
> If the workload experiences the same page faults,
> 
>   W3: +mm+iiii+mm+iiii+mm+iiii
> 
> The entire workload has been lengthened by 6 slots or 25%.  According
> to the above definition, it's under 25% memory pressure.  This is a
> well-defined metric which doesn't depend on implementation details and
> enables immediate intuitive understanding of the current state.

What this misses is that the "direct IO" can generate significant
memory pressure itself. e.g. it requires block allocation, and the
metadata that needs to be scanned and modified for the allocation is
not in memory.  At this point, the *filesystem* has a memory demand
spread across several caches and the heap, and can easily run to
being tens of pages of memory being needed.

IOWs, this filesystem memory demand can be significant to enable
"smooth" performance, because if we have to fetch metadata from disk
on every IO (because it's being reclaimed between IOs by other
memory demand) we will cause the system to grind to a halt. This is
one of the reasons XFS moved away from using the page cache to back
it's metadata buffers - we have a tree structure that the reclaim
algorithm has to be aware of...

In my mind, the key issue here is that much of the filesystem memory
demand cannot be accounted to a single process - internal metadata
may be owned by the filesytem (e.g. free space btrees, dquots, etc)
and is accessed and modified by any process that is using the
filesytem.  Hence trying to account and control the necessary
filesystem working set using memory pressure calculated from a
process basis is ... complex. It may even be impossible to make it
work.

FWIW, this reminds me somewhat of the problems CFQ has with fsync
heavy workloads and filesystems that issue journal commits from a
different process context (e.g. a work queue). CFQ can't know that
the process is blocked waiting on another process ot issue the IO,
(i.e. that there was a process to global context switch within the
filesystem which generated the dependency) so the journal IO is
delayed until the current (blocked) process IO timeslice expires.

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

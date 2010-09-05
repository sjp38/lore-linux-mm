Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 411F16B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 19:33:56 -0400 (EDT)
Date: Mon, 6 Sep 2010 09:33:13 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-ID: <20100905233313.GV7362@dastard>
References: <20100903160026.564fdcc9.akpm@linux-foundation.org>
 <20100904022545.GD705@dastard>
 <20100903202101.f937b0bb.akpm@linux-foundation.org>
 <20100904075840.GE705@dastard>
 <20100904081414.GF705@dastard>
 <20100905015400.GA10714@localhost>
 <20100905021555.GG705@dastard>
 <20100905060539.GA17450@localhost>
 <20100905131447.GJ705@dastard>
 <20100905134554.GA7083@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100905134554.GA7083@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 05, 2010 at 09:45:54PM +0800, Wu Fengguang wrote:
> [restoring CC list]
> 
> On Sun, Sep 05, 2010 at 09:14:47PM +0800, Dave Chinner wrote:
> > On Sun, Sep 05, 2010 at 02:05:39PM +0800, Wu Fengguang wrote:
> > > On Sun, Sep 05, 2010 at 10:15:55AM +0800, Dave Chinner wrote:
> > > > On Sun, Sep 05, 2010 at 09:54:00AM +0800, Wu Fengguang wrote:
> > > > > Dave, could you post (publicly) the kconfig and /proc/vmstat?
> > > > > 
> > > > > I'd like to check if you have swap or memory compaction enabled..
> > > > 
> > > > Swap is enabled - it has 512MB of swap space:
> > > > 
> > > > $ free
> > > >              total       used       free     shared    buffers     cached
> > > > Mem:       4054304     100928    3953376          0       4096      43108
> > > > -/+ buffers/cache:      53724    4000580
> > > > Swap:       497976          0     497976
> > > 
> > > It looks swap is not used at all.
> > 
> > It isn't 30s after boot, abut I haven't checked after a livelock.
> 
> That's fine. I see in your fs_mark-wedge-1.png that there are no
> read/write IO at all when CPUs are 100% busy. So there should be no
> swap IO at "livelock" time.
> 
> > > > And memory compaction is not enabled:
> > > > 
> > > > $ grep COMPACT .config
> > > > # CONFIG_COMPACTION is not set
> 
> Memory compaction is not likely the cause too. It will only kick in for
> order > 3 allocations.
> 
> > > > 
> > > > The .config is pretty much a 'make defconfig' and then enabling XFS and
> > > > whatever debug I need (e.g. locking, memleak, etc).
> > > 
> > > Thanks! The problem seems hard to debug -- you cannot login at all
> > > when it is doing lock contentions, so cannot get sysrq call traces.
> > 
> > Well, I don't know whether it is lock contention at all. The sets of
> > traces I have got previously have shown backtraces on all CPUs in
> > direct reclaim with several in draining queues, but no apparent lock
> > contention.
> 
> That's interesting. Do you still have the full backtraces?
> 
> Maybe your system eats too much slab cache (icache/dcache) by creating
> so many zero-sized files. The system may run into problems reclaiming
> so many (dirty) slab pages.

Yes, that's where most of the memory pressure is coming from.
However, it's not stuck reclaiming slab - it's pretty clear from
another chart that I run that the slab cache contents is not
changing aross the livelock. IOWs, it appears to get stuck before it
gets to shrink_slab().

Worth noting, though, is that XFS metadata workloads do create page
cache pressure as well - all the metadata pages are cached on a
separate address space, so perhaps it is getting stuck there...

> > > How about enabling CONFIG_LOCK_STAT? Then you can check
> > > /proc/lock_stat when the contentions are over.
> > 
> > Enabling the locking debug/stats gathering slows the workload
> > by a factor of 3 and doesn't produce the livelock....
> 
> Oh sorry.. but it would still be interesting to check the top
> contended locks for this workload without any livelocks :)

I'll see what i can do.

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

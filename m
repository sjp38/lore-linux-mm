Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9BCBD6B004A
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 22:21:52 -0500 (EST)
Date: Thu, 18 Nov 2010 14:21:41 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/13] IO-less dirty throttling v2
Message-ID: <20101118032141.GP13830@dastard>
References: <20101117042720.033773013@intel.com>
 <20101117150330.139251f9.akpm@linux-foundation.org>
 <20101118020640.GS22876@dastard>
 <20101117180912.38541ca4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117180912.38541ca4.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 06:09:12PM -0800, Andrew Morton wrote:
> On Thu, 18 Nov 2010 13:06:40 +1100 Dave Chinner <david@fromorbit.com> wrote:
> 
> > On Wed, Nov 17, 2010 at 03:03:30PM -0800, Andrew Morton wrote:
> > > On Wed, 17 Nov 2010 12:27:20 +0800
> > > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > 
> > > > On a simple test of 100 dd, it reduces the CPU %system time from 30% to 3%, and
> > > > improves IO throughput from 38MB/s to 42MB/s.
> > > 
> > > The changes in CPU consumption are remarkable.  I've looked through the
> > > changelogs but cannot find mention of where all that time was being
> > > spent?
> > 
> > In the writeback path, mostly because every CPU is trying to run
> > writeback at the same time and causing contention on locks and
> > shared structures in the writeback path. That no longer happens
> > because writeback is only happening from one thread instead of from
> > all CPUs at once.
> 
> It'd be nice to see this quantified.  Partly because handing things
> over to kernel threads uncurs extra overhead - scheduling cost and CPU
> cache footprint.

Sure, but in this case, the scheduling cost is much lower than
actually doing writeback of 1500 pages. The CPU cache footprint of
the syscall is also greatly reduced as well because we don't go down
the writeback path. That shows up in the fact that the "app
overhead" measured by fs_mark goes down significantly with this
patch series (30-50% reduction) - it's doing the same work, but it's
taking much less wall time....

And if you are after lock contention numbers, I have quantified it
though I do not have saved lock_stat numbers at hand.  Running the
current inode_lock breakup patchset and the fs_mark workload (8-way
parallel create of 1 byte files), lock_stat shows the
inode_wb_list_lock as the hottest lock in the system (more trafficed
and much more contended than the dcache_lock), along with the
inode->i_lock being the most trafficed.

Running `perf top -p <pid of bdi-flusher>` showed it spending 30-40%
of it's time in __ticket_spin_lock. I saw the same thing with every
fs_mark process also showing 30-40% of it's time in
__ticket_spin_lock. Every process also showed a good chunk of time
in the writeback path. Overall, the fsmark processes showed a CPU
consumption of ~620% CPU, with the bdi-flusher at 80% of a CPU and
kswapd at 80% of CPU.

With the patchset, all that spin lock time is gone from the profiles
(down to about 2%) as is the writeback path (except fo the
bdi-flusher, which is all writeback path). Overall, we have fsmark
processes showing 250% CPU, the bdi-flusher at 80% of a cpu, and
kswapd at about 20% of a CPU, with over 400% idle time.

IOWs, we've traded off 3-4 CPUs worth of spinlock contention and a
flusher thread running at 80% CPU for a flusher thread that runs at
80% CPU doing the same amount of work. To me, that says the cost of
scheduling is orders of magnitude lower than the cost of the current
code...

> But mainly because we're taking the work accounting away from the user
> who caused it and crediting it to the kernel thread instead, and that's
> an actively *bad* thing to do.

The current foreground writeback is doing work on behalf of the
system (i.e. doing background writeback) and therefore crediting it
to the user process. That seems wrong to me; it's hiding the
overhead of system tasks in user processes.

IMO, time spent doing background writeback should not be creditted
to user processes - writeback caching is a function of the OS and
it's overhead should be accounted as such. Indeed, nobody has
realised (until now) just how inefficient it really is because of
the fact that the overhead is mostly hidden in user process system
time.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

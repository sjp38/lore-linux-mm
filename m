Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0E6EC6B004A
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 20:41:06 -0500 (EST)
Date: Thu, 18 Nov 2010 12:40:51 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/13] IO-less dirty throttling
Message-ID: <20101118014051.GR22876@dastard>
References: <20101117035821.000579293@intel.com>
 <20101117072538.GO22876@dastard>
 <20101117100655.GA26501@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117100655.GA26501@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 06:06:55PM +0800, Wu Fengguang wrote:
> On Wed, Nov 17, 2010 at 03:25:38PM +0800, Dave Chinner wrote:
> > On Wed, Nov 17, 2010 at 11:58:21AM +0800, Wu Fengguang wrote:
> > > Andrew,
> > >
> > > This is a revised subset of "[RFC] soft and dynamic dirty throttling limits"
> > > <http://thread.gmane.org/gmane.linux.kernel.mm/52966>.
> > >
> > > The basic idea is to introduce a small region under the bdi dirty threshold.
> > > The task will be throttled gently when stepping into the bottom of region,
> > > and get throttled more and more aggressively as bdi dirty+writeback pages
> > > goes up closer to the top of region. At some point the application will be
> > > throttled at the right bandwidth that balances with the device write bandwidth.
> > > (the first patch and documentation has more details)
> > >
> > > Changes from initial RFC:
> > >
> > > - adaptive ratelimiting, to reduce overheads when under throttle threshold
> > > - prevent overrunning dirty limit on lots of concurrent dirtiers
> > > - add Documentation/filesystems/writeback-throttling-design.txt
> > > - lower max pause time from 200ms to 100ms; min pause time from 10ms to 1jiffy
> > > - don't drop the laptop mode code
> > > - update and comment the trace event
> > > - benchmarks on concurrent dd and fs_mark covering both large and tiny files
> > > - bdi->write_bandwidth updates should be rate limited on concurrent dirtiers,
> > >   otherwise it will drift fast and fluctuate
> > > - don't call balance_dirty_pages_ratelimit() when writing to already dirtied
> > >   pages, otherwise the task will be throttled too much
> > >
> > > The patches are based on 2.6.37-rc2 and Jan's sync livelock patches. For easier
> > > access I put them in
> > >
> > > git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v2
> > 
> > Great - just pulled it down and I'll start running some tests.
> > 
> > The tree that I'm testing has the vfs inode lock breakup in it, the
> > inode cache SLAB_DESTROY_BY_RCU series, a large bunch of XFS lock
> > breakup patches and now the above branch in it. It's here:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/dgc/xfsdev.git working
> > 
> > > On a simple test of 100 dd, it reduces the CPU %system time from 30% to 3%, and
> > > improves IO throughput from 38MB/s to 42MB/s.
> > 
> > Excellent - I suspect that the reduction in contention on the inode
> > writeback locks is responsible for dropping the CPU usage right down.
> > 
> > I'm seeing throughput for a _single_ large dd (100GB) increase from ~650MB/s
> > to 700MB/s with your series. For other numbers of dd's:
> 
> Great! I didn't expect it to improve _throughput_ of single dd case.

At 650MB/s without your series, the dd process is CPU bound. With
your series the dd process now only consumes ~65% of the cpu, so I
suspect that if I was running on a faster block device it'd go even
faster. Removing the writeback path from the write() path certainly
helps in this regard.

> > # dd processes          total throughput         total        per proc
> >    1                      700MB/s                   400/s       100/s
> >    2                      700MB/s                   500/s       100/s
> >    4                      700MB/s                   700/s       100/s
> >    8                      690MB/s                 1,100/s       100/s
> >   16                      675MB/s                 2,000/s       110/s
> >   32                      675MB/s                 5,000/s       150/s
> >  100                      650MB/s                22,000/s       210/s
> > 1000                      600MB/s               160,000/s       160/s
> > 
> > A couple of things I noticed - firstly, the number of context
> > switches scales roughly with the number of writing processes - is
> > there any reason for waking every writer 100-200 times a second? At
> > the thousand writer mark, we reach a context switch rate of more
> > than one per page we complete IO on. Any idea on whether this can be
> > improved at all?
> 
> It's simple to have the pause time stabilize at larger values.  I can
> even easily detect that there are lots of concurrent dirtiers, and in
> such cases adaptively enlarge it to no more than 200ms. Does that
> value sound reasonable?

Certainly. I think that the more concurrent dirtiers, the less
frequently each individual dirtier should be woken. There's no point
waking a dirtier if all they can do is write a single page before
they are throttled again - IO is most efficient when done in larger
batches...

> Precisely controlling pause time is the major capability pursued by
> this implementation (comparing to the earlier attempts to wait on
> write completions).
> 
> > Also, the system CPU usage while throttling stayed quite low but not
> > constant. The more writing processes, the lower the system CPU usage
> > (despite the increase in context switches). Further, if the dd's
> > didn't all start at the same time, then system CPU usage would
> > roughly double when the first dd's complete and cpu usage stayed
> > high until all the writers completed. So there's some trigger when
> > writers finish/exit there that is changing throttle behaviour.
> > Increasing the number of writers does not seem to have any adverse
> > affects.
> 
> Depending on various conditions, the pause time will be stabilizing at
> different point in the range [1 jiffy, 100 ms]. This is a very big
> range and I made no attempt (although possible) to further control it.
> 
> The smaller pause time, the more overheads in context switches _as
> well as_ global_page_state() costs (mainly cacheline bouncing) in
> balance_dirty_pages().

I didn't notice any change in context switches when the CPU usage
changed, so perhaps it was more cacheline bouncing in
global_page_state(). I think more investigation is needed, though.

> I wonder whether or not the majority context switches indicate a
> corresponding invocation of balance_dirty_pages()?

/me needs to run with writeback tracing turned on

> > FWIW, I'd consider the throughput (1200 files/s) to quite low for 12
> > disks and a number of CPUs being active. I'm not sure how you
> > configured the storage/filesystem, but you should configure the
> > filesystem with at least 2x as many AGs as there are CPUs, and run
> > one create thread per CPU rather than one per disk.  Also, making
> > sure you have a largish log (512MB in this case) is helpful, too.
> 
> The test machine has 16 CPUs and 12 disks. I used plain simple mkfs
> commands. I don't have access to the test box now (it's running LKP
> for the just released -rc2). I'll checkout the xfs configuration and
> recreate it with more AGs and log.

Cool.

> And yeah it's a good idea to
> increase the number of threads, with "-t 16"?

No, that just increases the number of threads working on a specific
directory. creates are serialised by the directory i_mutex, so
there's no point running multiple threads per directory.

That's why I use multiple "-d <dir>" options - you get a thread per
directory that way, and they don't serialise with each other given
enough AGs...

> btw, is it a must to run
> the test for one whole day? If not, which optarg can be decreased?
> "-L 64"?

Yeah, -L controls the number of iterations (there's one line of
output per iteration). Generally, for sanity checking, I'll just run
a few iterations. I only ever run the full 50M inode runs when I've
got something I want to compare. Mind you, it generally only takes
an hour on my system, so that's not so bad...

> > Ok, so throughput is also down by ~5% from ~23k files/s to ~22k
> > files/s.
> 
> Hmm. The bad thing is I have no idea on how to avoid that. It's not
> doing IO any more, so what can I do to influence the IO throughput? ;)

That's now a problem of writeback optimisation - where it should be
dealt with ;)

> Maybe there are unnecessary sleep points in the writeout path? 

It sleeps on congestion, but otherwise shouldn't be blocking
anywhere.

> Or even one flusher thread is not enough _now_?

It hasn't been enough for XFS on really large systems doing high
bandwidth IO for a long time. It's only since 2.6.35 and the
introduction of the delaylog mount option that XFS has really been
able to drive small file IO this hard.

> Anyway that seems not
> the flaw of _this_ patchset, but problems exposed and unfortunately
> made more imminent by it.

Agreed.

> btw, do you have the total elapsed time before/after patch? As you
> said it's the final criterion :)

Yeah, sorry, should have posted them - I didn't because I snapped
the numbers before the run had finished. Without series:

373.19user 14940.49system 41:42.17elapsed 612%CPU (0avgtext+0avgdata 82560maxresident)k
0inputs+0outputs (403major+2599763minor)pagefaults 0swaps

With your series:

359.64user 5559.32system 40:53.23elapsed 241%CPU (0avgtext+0avgdata 82496maxresident)k
0inputs+0outputs (312major+2598798minor)pagefaults 0swaps

So the wall time with your series is lower, and system CPU time is
way down (as I've already noted) for this workload on XFS.

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

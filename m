Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1FE4A60080D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 09:18:26 -0400 (EDT)
Date: Tue, 27 Jul 2010 23:18:10 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: VFS scalability git tree
Message-ID: <20100727131810.GO7362@dastard>
References: <20100722190100.GA22269@amd>
 <20100723135514.GJ32635@dastard>
 <20100727070538.GA2893@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100727070538.GA2893@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 27, 2010 at 05:05:39PM +1000, Nick Piggin wrote:
> On Fri, Jul 23, 2010 at 11:55:14PM +1000, Dave Chinner wrote:
> > On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> > > I'm pleased to announce I have a git tree up of my vfs scalability work.
> > > 
> > > git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> > > http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git
> > > 
> > > Branch vfs-scale-working
> > 
> > With a production build (i.e. no lockdep, no xfs debug), I'll
> > run the same fs_mark parallel create/unlink workload to show
> > scalability as I ran here:
> > 
> > http://oss.sgi.com/archives/xfs/2010-05/msg00329.html
> 
> I've made a similar setup, 2s8c machine, but using 2GB ramdisk instead
> of a real disk (I don't have easy access to a good disk setup ATM, but
> I guess we're more interested in code above the block layer anyway).
> 
> Made an XFS on /dev/ram0 with 16 ags, 64MB log, otherwise same config as
> yours.

A s a personal prefernce, I don't like testing filesystem performance
on ramdisks because it hides problems caused by changes in IO
latency. I'll come back to this later.

> I found that performance is a little unstable, so I sync and echo 3 >
> drop_caches between each run.

Quite possibly because of the smaller log - that will cause more
frequent pushing on the log tail and hence I/O patterns will vary a
bit...

Also, keep in mind that delayed logging is shiny and new - it has
increased XFS metadata performance and parallelism by an order of
magnitude and so we're really seeing new a bunch of brand new issues
that have never been seen before with this functionality.  As such,
there's still some interactions I haven't got to the bottom of with
delayed logging - it's stable enough to use and benchmark and won't
corrupt anything but there are still has some warts we need to
solve. The difficulty (as always) is in reliably reproducing the bad
behaviour.

> When it starts reclaiming memory, things
> get a bit more erratic (and XFS seemed to be almost livelocking for tens
> of seconds in inode reclaim).

I can't say that I've seen this - even when testing up to 10m
inodes. Yes, kswapd is almost permanently active on these runs,
but when creating 100,000 inodes/s we also need to be reclaiming
100,000 inodes/s so it's not surprising that when 7 CPUs are doing
allocation we need at least one CPU to run reclaim....

> So I started with 50 runs of fs_mark
> -n 20000 (which did not cause reclaim), rebuilding a new filesystem
> between every run.
> 
> That gave the following files/sec numbers:
>     N           Min           Max        Median           Avg Stddev
> x  50      100986.4        127622      125013.4     123248.82 5244.1988
> +  50      100967.6      135918.6      130214.9     127926.94 6374.6975
> Difference at 95.0% confidence
>         4678.12 +/- 2316.07
>         3.79567% +/- 1.87919%
>         (Student's t, pooled s = 5836.88)
> 
> This is 3.8% in favour of vfs-scale-working.
> 
> I then did 10 runs of -n 20000 but with -L 4 (4 iterations) which did
> start to fill up memory and cause reclaim during the 2nd and subsequent
> iterations.

I haven't used this mode, so I can't really comment on the results
you are seeing.

> > enabled. ext4 is using default mkfs and mount parameters except for
> > barrier=0. All numbers are averages of three runs.
> > 
> > 	fs_mark rate (thousands of files/second)
> >            2.6.35-rc5   2.6.35-rc5-scale
> > threads    xfs   ext4     xfs    ext4
> >   1         20    39       20     39
> >   2         35    55       35     57
> >   4         60    41       57     42
> >   8         79     9       75      9
> > 
> > ext4 is getting IO bound at more than 2 threads, so apart from
> > pointing out that XFS is 8-9x faster than ext4 at 8 thread, I'm
> > going to ignore ext4 for the purposes of testing scalability here.
> > 
> > For XFS w/ delayed logging, 2.6.35-rc5 is only getting to about 600%
> > CPU and with Nick's patches it's about 650% (10% higher) for
> > slightly lower throughput.  So at this class of machine for this
> > workload, the changes result in a slight reduction in scalability.
> 
> I wonder if these results are stable. It's possible that changes in
> reclaim behaviour are causing my patches to require more IO for a
> given unit of work?

More likely that's the result of using a smaller log size because it
will require more frequent metadata pushes to make space for new
transactions.

> I was seeing XFS 'livelock' in reclaim more with my patches, it
> could be due to more parallelism now being allowed from the vfs and
> reclaim.
>
> Based on my above numbers, I don't see that rcu-inodes is causing a
> problem, and in terms of SMP scalability, there is really no way that
> vanilla is more scalable, so I'm interested to see where this slowdown
> is coming from.

As I said initially, ram disks hide IO latency changes resulting
from increased numbers of IO or increases in seek distances.  My
initial guess is the change in inode reclaim behaviour causing
different IO patterns and more seeks under reclaim because the zone
based reclaim is no longer reclaiming inodes in the order
they are created (i.e. we are not doing sequential inode reclaim any
more.

FWIW, I use PCP monitoring graphs to correlate behavioural changes
across different subsystems because it is far easier to relate
information visually than it is by looking at raw numbers or traces.
I think this graph shows the effect of relcaim on performance
most clearly:

http://userweb.kernel.org/~dgc/shrinker-2.6.36/fs_mark-2.6.35-rc3-context-only-per-xfs-batch6-16x500-xfs.png

It's pretty clear that when the inode/dentry cache shrinkers are
running, sustained create/unlink performance goes right down. From a
different tab not in the screen shot (the other "test-4" tab), I
could see CPU usage also goes down and the disk iops go way up
whenever the create/unlink performance dropped. This same behaviour
happens with the vfs-scale patchset, so it's not related to lock
contention - just aggressive reclaim of still-dirty inodes.

FYI, The patch under test there was the XFS shrinker ignoring 7 out
of 8 shrinker calls and then on the 8th call doing the work of all
previous calls. i.e emulating  SHRINK_BATCH = 1024. Interestingly
enough, that one change reduced the runtime of the 8m inode
create/unlink load by ~25% (from ~24min to ~18min).

That is by far the largest improvement I've been able to obtain from
modifying the shrinker code, and it is from those sorts of
observations that I think that IO being issued from reclaim is
currently the most significant performance limiting factor for XFS
in this sort of workload....

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

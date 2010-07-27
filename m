Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D8DAB600044
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 03:05:45 -0400 (EDT)
Date: Tue, 27 Jul 2010 17:05:39 +1000
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: VFS scalability git tree
Message-ID: <20100727070538.GA2893@amd>
References: <20100722190100.GA22269@amd>
 <20100723135514.GJ32635@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723135514.GJ32635@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 11:55:14PM +1000, Dave Chinner wrote:
> On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> > I'm pleased to announce I have a git tree up of my vfs scalability work.
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> > http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git
> > 
> > Branch vfs-scale-working
> 
> With a production build (i.e. no lockdep, no xfs debug), I'll
> run the same fs_mark parallel create/unlink workload to show
> scalability as I ran here:
> 
> http://oss.sgi.com/archives/xfs/2010-05/msg00329.html

I've made a similar setup, 2s8c machine, but using 2GB ramdisk instead
of a real disk (I don't have easy access to a good disk setup ATM, but
I guess we're more interested in code above the block layer anyway).

Made an XFS on /dev/ram0 with 16 ags, 64MB log, otherwise same config as
yours.

I found that performance is a little unstable, so I sync and echo 3 >
drop_caches between each run. When it starts reclaiming memory, things
get a bit more erratic (and XFS seemed to be almost livelocking for tens
of seconds in inode reclaim). So I started with 50 runs of fs_mark
-n 20000 (which did not cause reclaim), rebuilding a new filesystem
between every run.

That gave the following files/sec numbers:
    N           Min           Max        Median           Avg Stddev
x  50      100986.4        127622      125013.4     123248.82 5244.1988
+  50      100967.6      135918.6      130214.9     127926.94 6374.6975
Difference at 95.0% confidence
        4678.12 +/- 2316.07
        3.79567% +/- 1.87919%
        (Student's t, pooled s = 5836.88)

This is 3.8% in favour of vfs-scale-working.

I then did 10 runs of -n 20000 but with -L 4 (4 iterations) which did
start to fill up memory and cause reclaim during the 2nd and subsequent
iterations.

    N           Min           Max        Median           Avg Stddev
x  10      116919.7      126785.7      123279.2     122245.17 3169.7993
+  10      110985.1      132440.7      130122.1     126573.41 7151.2947
No difference proven at 95.0% confidence

x  10       75820.9      105934.9       79521.7      84263.37 11210.173
+  10       75698.3      115091.7         82932      93022.75 16725.304
No difference proven at 95.0% confidence

x  10       66330.5       74950.4       69054.5         69102 2335.615
+  10       68348.5       74231.5       70728.2      70879.45 1838.8345
No difference proven at 95.0% confidence

x  10       59353.8       69813.1       67416.7      65164.96 4175.8209
+  10       59670.7       77719.1       74326.1      70966.02 6469.0398
Difference at 95.0% confidence
        5801.06 +/- 5115.66
        8.90212% +/- 7.85033%
        (Student's t, pooled s = 5444.54)

vfs-scale-working was ahead at every point, but the results were
too erratic to read much into it (even the last point I think is
questionable).

I can provide raw numbers or more details on the setup if required.


> enabled. ext4 is using default mkfs and mount parameters except for
> barrier=0. All numbers are averages of three runs.
> 
> 	fs_mark rate (thousands of files/second)
>            2.6.35-rc5   2.6.35-rc5-scale
> threads    xfs   ext4     xfs    ext4
>   1         20    39       20     39
>   2         35    55       35     57
>   4         60    41       57     42
>   8         79     9       75      9
> 
> ext4 is getting IO bound at more than 2 threads, so apart from
> pointing out that XFS is 8-9x faster than ext4 at 8 thread, I'm
> going to ignore ext4 for the purposes of testing scalability here.
> 
> For XFS w/ delayed logging, 2.6.35-rc5 is only getting to about 600%
> CPU and with Nick's patches it's about 650% (10% higher) for
> slightly lower throughput.  So at this class of machine for this
> workload, the changes result in a slight reduction in scalability.

I wonder if these results are stable. It's possible that changes in
reclaim behaviour are causing my patches to require more IO for a
given unit of work?

I was seeing XFS 'livelock' in reclaim more with my patches, it
could be due to more parallelism now being allowed from the vfs and
reclaim.

Based on my above numbers, I don't see that rcu-inodes is causing a
problem, and in terms of SMP scalability, there is really no way that
vanilla is more scalable, so I'm interested to see where this slowdown
is coming from.


> I looked at dbench on XFS as well, but didn't see any significant
> change in the numbers at up to 200 load threads, so not much to
> talk about there.

On a smaller system, dbench doesn't bottleneck too much. It's more of
a test to find shared cachelines and such on larger systems when you're
talking about several GB/s bandwidths.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

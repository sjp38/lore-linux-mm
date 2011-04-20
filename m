Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D02C88D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 03:38:26 -0400 (EDT)
Date: Wed, 20 Apr 2011 15:38:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110420073822.GA30672@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.515923886@intel.com>
 <20110419073523.GF23985@dastard>
 <20110419095740.GC5257@quack.suse.cz>
 <20110419125616.GA20059@localhost>
 <20110420012120.GK23985@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110420012120.GK23985@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

> > > > > @@ -585,7 +597,8 @@ void writeback_inodes_wb(struct bdi_writ
> > > > >  	if (!wbc->wb_start)
> > > > >  		wbc->wb_start = jiffies; /* livelock avoidance */
> > > > >  	spin_lock(&inode_wb_list_lock);
> > > > > -	if (!wbc->for_kupdate || list_empty(&wb->b_io))
> > > > > +
> > > > > +	if (list_empty(&wb->b_io))
> > > > >  		queue_io(wb, wbc);
> > > > >
> > > > >  	while (!list_empty(&wb->b_io)) {
> > > > > @@ -612,7 +625,7 @@ static void __writeback_inodes_sb(struct
> > > > >  	WARN_ON(!rwsem_is_locked(&sb->s_umount));
> > > > >
> > > > >  	spin_lock(&inode_wb_list_lock);
> > > > > -	if (!wbc->for_kupdate || list_empty(&wb->b_io))
> > > > > +	if (list_empty(&wb->b_io))
> > > > >  		queue_io(wb, wbc);
> > > > >  	writeback_sb_inodes(sb, wb, wbc, true);
> > > > >  	spin_unlock(&inode_wb_list_lock);
> > > >
> > > > That changes the order in which we queue inodes for writeback.
> > > > Instead of calling every time to move b_more_io inodes onto the b_io
> > > > list and expiring more aged inodes, we only ever do it when the list
> > > > is empty. That is, it seems to me that this will tend to give
> > > > b_more_io inodes a smaller share of writeback because they are being
> > > > moved back to the b_io list less frequently where there are lots of
> > > > other inodes being dirtied. Have you tested the impact of this
> > > > change on mixed workload performance? Indeed, can you starve
> > > > writeback of a large file simply by creating lots of small files in
> > > > another thread?
> > >   Yeah, this change looks suspicious to me as well.
> >
> > The exact behaviors are indeed rather complex. I personally feel the
> > new "always refill iff empty" policy more consistent, clean and easy
> > to understand.
>
> That may be so, but that doesn't make the change good from an IO
> perspective. You said you'd only done light testing, and that's not
> sufficient to guage the impact of such a change.
>
> > It basically says: at each round started by a b_io refill, setup a
> > _fixed_ work set with all current expired (or all currently dirtied
> > inodes if non is expired) and walk through it. "Fixed" work set means
> > no new inodes will be added to the work set during the walk.  When a
> > complete walk is done, start over with a new set of inodes that are
> > eligible at the time.
>
> Yes, I know what it does - I can read the code. You haven't however,
> answered why it is a good change from an IO persepctive, however.
>
> > The figure in page 14 illustrates the "rounds" idea:
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/linux-writeback-queues.pdf
> >
> > This procedure provides fairness among the inodes and guarantees each
> > inode to be synced once and only once at each round. So it's free from
> > starvations.
>
> Perhaps you should add some of this commentary to the commit
> message? That talks about the VM and LRU writeback, but that has
> nothing to do with writeback fairness. The commit message or
> comments in the code need to explain why something is being
> changed....

OK, added to changelog.

> >
> > If you are worried about performance, here is a simple tar+dd benchmark.
> > Both commands are actually running faster with this patchset:
> .....
> > The base kernel is 2.6.39-rc3+ plus IO-less patchset plus large write
> > chunk size. The test box has 3G mem and runs XFS. Test script is:
>
> <sigh>
>
> The numbers are meaningless to me - you've got a large number of
> other changes that are affecting writeback behaviour, and that's
> especially important because, at minimum, the change in write chunk
> size will hide any differences in IO patterns that this change will

The previous benchmarks are sure valuable and more future proof,
assuming that we are going to do IO-less and larger writeback soon.

> make. Please test against a vanilla kernel if that is what you are
> aiming these patches for. If you aren't aiming for a vanilla kernel,
> please say so in the patch series header...

Here are the test results for vanilla kernel. It's again shows better
numbers for dd, tar and overall run time.

             2.6.39-rc3   2.6.39-rc3-dyn-expire+
------------------------------------------------
all elapsed     256.043      252.367
stddev           24.381       12.530

tar elapsed      30.097       28.808
dd  elapsed      13.214       11.782

wfg /tmp% g cpu log-no-moving-expire-vanilla log-moving-expire-vanilla|g tar
log-no-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.59s user 4.00s system 47% cpu 35.221 total
log-no-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.62s user 4.19s system 51% cpu 32.358 total
log-no-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.43s user 4.11s system 51% cpu 32.356 total
log-no-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.28s user 4.09s system 60% cpu 26.914 total
log-no-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.25s user 4.12s system 59% cpu 27.345 total
log-no-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.55s user 4.21s system 63% cpu 26.347 total
log-no-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.39s user 3.97s system 44% cpu 36.360 total
log-no-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.44s user 3.88s system 58% cpu 28.046 total
log-no-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.40s user 4.09s system 56% cpu 29.000 total
log-no-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.50s user 3.95s system 60% cpu 27.020 total
log-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.44s user 4.03s system 56% cpu 28.939 total
log-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.63s user 4.06s system 56% cpu 29.488 total
log-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.43s user 3.95s system 51% cpu 31.666 total
log-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.46s user 3.99s system 63% cpu 25.768 total
log-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.14s user 4.26s system 54% cpu 29.838 total
log-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.43s user 4.09s system 63% cpu 25.855 total
log-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.61s user 4.36s system 57% cpu 29.588 total
log-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.36s user 4.13s system 63% cpu 25.816 total
log-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.49s user 3.94s system 55% cpu 29.499 total
log-moving-expire-vanilla:tar jxf /dev/shm/linux-2.6.38.3.tar.bz2  12.53s user 3.92s system 51% cpu 31.625 total
wfg /tmp% g cpu log-no-moving-expire-vanilla log-moving-expire-vanilla|g dd
log-no-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.34s system 9% cpu 14.084 total
log-no-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.27s system 8% cpu 14.240 total
log-no-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.25s system 9% cpu 13.437 total
log-no-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.21s system 9% cpu 12.783 total
log-no-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.23s system 9% cpu 12.614 total
log-no-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.25s system 9% cpu 12.733 total
log-no-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.25s system 10% cpu 12.438 total
log-no-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.21s system 9% cpu 12.356 total
log-no-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.21s system 8% cpu 14.724 total
log-no-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 9% cpu 12.734 total
log-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.57s system 13% cpu 12.002 total
log-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.30s system 9% cpu 14.049 total
log-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.36s system 11% cpu 12.031 total
log-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.25s system 10% cpu 11.679 total
log-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.26s system 11% cpu 11.276 total
log-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.25s system 10% cpu 11.501 total
log-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.20s system 10% cpu 11.344 total
log-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.24s system 10% cpu 11.345 total
log-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.27s system 11% cpu 11.280 total
log-moving-expire-vanilla:dd if=/dev/zero of=/fs/zero bs=1M count=1000  0.00s user 1.22s system 10% cpu 11.312 total
wfg /tmp% g elapsed log-no-moving-expire-vanilla log-moving-expire-vanilla
log-no-moving-expire-vanilla:elapsed: 317.59000000000196
log-no-moving-expire-vanilla:elapsed: 269.16999999999825
log-no-moving-expire-vanilla:elapsed: 271.61000000000058
log-no-moving-expire-vanilla:elapsed: 233.08000000000175
log-no-moving-expire-vanilla:elapsed: 238.20000000000073
log-no-moving-expire-vanilla:elapsed: 240.68999999999505
log-no-moving-expire-vanilla:elapsed: 257.43000000000029
log-no-moving-expire-vanilla:elapsed: 249.45000000000437
log-no-moving-expire-vanilla:elapsed: 251.55000000000291
log-no-moving-expire-vanilla:elapsed: 231.65999999999622
log-moving-expire-vanilla:elapsed: 270.54999999999927
log-moving-expire-vanilla:elapsed: 254.34000000000015
log-moving-expire-vanilla:elapsed: 248.61000000000058
log-moving-expire-vanilla:elapsed: 238.18000000000029
log-moving-expire-vanilla:elapsed: 263.5
log-moving-expire-vanilla:elapsed: 234.15999999999985
log-moving-expire-vanilla:elapsed: 266.81000000000131
log-moving-expire-vanilla:elapsed: 238.14999999999782
log-moving-expire-vanilla:elapsed: 263.14999999999782
log-moving-expire-vanilla:elapsed: 246.22000000000116

> Anyway, I'm going to put some numbers into a hypothetical steady
> state situation to demonstrate the differences in algorithms.
> Let's say we have lots of inodes with 100 dirty pages being created,
> and one large writeback going on. We expire 8 new inodes for every
> 1024 pages we write back.
>
> With the old code, we do:
>
> 	b_more_io (large inode) -> b_io (1l)
> 	8 newly expired inodes -> b_io (1l, 8s)
>
> 	writeback  large inode 1024 pages -> b_more_io
>
> 	b_more_io (large inode) -> b_io (8s, 1l)
> 	8 newly expired inodes -> b_io (8s, 1l, 8s)
>
> 	writeback  8 small inodes 800 pages
> 		   1 large inode 224 pages -> b_more_io
>
> 	b_more_io (large inode) -> b_io (8s, 1l)
> 	8 newly expired inodes -> b_io (8s, 1l, 8s)
> 	.....
>
> Your new code:
>
> 	b_more_io (large inode) -> b_io (1l)
> 	8 newly expired inodes -> b_io (1l, 8s)
>
> 	writeback  large inode 1024 pages -> b_more_io
> 	(b_io == 8s)
> 	writeback  8 small inodes 800 pages
>
> 	b_io empty: (1800 pages written)
> 		b_more_io (large inode) -> b_io (1l)
> 		14 newly expired inodes -> b_io (1l, 14s)
>
> 	writeback  large inode 1024 pages -> b_more_io
> 	(b_io == 14s)
> 	writeback  10 small inodes 1000 pages
> 		   1 small inode 24 pages -> b_more_io (1l, 1s(24))
> 	writeback  5 small inodes 500 pages
> 	b_io empty: (2548 pages written)
> 		b_more_io (large inode) -> b_io (1l, 1s(24))
> 		20 newly expired inodes -> b_io (1l, 1s(24), 20s)
> 	......
>
> Rough progression of pages written at b_io refill:
>
> Old code:
>
> 	total	large file	% of writeback
> 	1024	224		21.9% (fixed)
>
> New code:
> 	total	large file	% of writeback
> 	1800	1024		~55%
> 	2550	1024		~40%
> 	3050	1024		~33%
> 	3500	1024		~29%
> 	3950	1024		~26%
> 	4250	1024		~24%
> 	4500	1024		~22.7%
> 	4700	1024		~21.7%
> 	4800	1024		~21.3%
> 	4800	1024		~21.3%
> 	(pretty much steady state from here)
>
> Ok, so the steady state is reached with a similar percentage of
> writeback to the large file as the existing code. Ok, that's good,
> but providing some evidence that is doesn't change the shared of
> writeback to the large should be in the commit message ;)
>
> The other advantage to this is that we always write 1024 page chunks
> to the large file, rather than smaller "whatever remains" chunks. I
> think this will have a bigger effect on a vanilla kernel than on the
> kernel you tested on above because of the smaller writeback chunk
> size.

Good analyze! I've included them to the changelog :)

> I'm convinced that the refilling only when the queue is empty is a
> sane change now. you need to separate this from the
> move_expired_inodes() changes because it is doing something very
> different to writeback.

OK. It actually depends on the patch "writeback: try more writeback as long as
something was written". So I'll include it as the last one in next post.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

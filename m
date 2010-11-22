Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EFFBC6B0071
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 21:02:13 -0500 (EST)
Date: Mon, 22 Nov 2010 10:01:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 01/13] writeback: IO-less balance_dirty_pages()
Message-ID: <20101122020145.GB10126@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042849.410279291@intel.com>
 <AANLkTimV1Y5_6CSjz24dbLjYcoiVn6+6chPhpzHZm8LK@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimV1Y5_6CSjz24dbLjYcoiVn6+6chPhpzHZm8LK@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Minchan,

On Wed, Nov 17, 2010 at 06:34:26PM +0800, Minchan Kim wrote:
> Hi Wu,
> 
> As you know, I am not a expert in this area.
> So I hope my review can help understanding other newbie like me and
> make clear this document. :)
> I didn't look into the code. before it, I would like to clear your concept.

Yeah, it's some big change of "concept" :)

Sorry for the late reply, as I'm still tuning things and some details
may change as a result. The biggest challenge now is the stability of
the control algorithms. Everything is floating around and I'm trying
to keep the fluctuations down by borrowing some equation from the
optimal control theory.

> On Wed, Nov 17, 2010 at 1:27 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > As proposed by Chris, Dave and Jan, don't start foreground writeback IO
> > inside balance_dirty_pages(). Instead, simply let it idle sleep for some
> > time to throttle the dirtying task. In the mean while, kick off the
> > per-bdi flusher thread to do background writeback IO.
> >
> > This patch introduces the basic framework, which will be further
> > consolidated by the next patches.
> >
> > RATIONALS
> > =========
> >
> > The current balance_dirty_pages() is rather IO inefficient.
> >
> > - concurrent writeback of multiple inodes (Dave Chinner)
> >
> > A If every thread doing writes and being throttled start foreground
> > A writeback, it leads to N IO submitters from at least N different
> > A inodes at the same time, end up with N different sets of IO being
> > A issued with potentially zero locality to each other, resulting in
> > A much lower elevator sort/merge efficiency and hence we seek the disk
> > A all over the place to service the different sets of IO.
> > A OTOH, if there is only one submission thread, it doesn't jump between
> > A inodes in the same way when congestion clears - it keeps writing to
> > A the same inode, resulting in large related chunks of sequential IOs
> > A being issued to the disk. This is more efficient than the above
> > A foreground writeback because the elevator works better and the disk
> > A seeks less.
> >
> > - IO size too small for fast arrays and too large for slow USB sticks
> >
> > A The write_chunk used by current balance_dirty_pages() cannot be
> > A directly set to some large value (eg. 128MB) for better IO efficiency.
> > A Because it could lead to more than 1 second user perceivable stalls.
> > A Even the current 4MB write size may be too large for slow USB sticks.
> > A The fact that balance_dirty_pages() starts IO on itself couples the
> > A IO size to wait time, which makes it hard to do suitable IO size while
> > A keeping the wait time under control.
> >
> > For the above two reasons, it's much better to shift IO to the flusher
> > threads and let balance_dirty_pages() just wait for enough time or progress.
> >
> > Jan Kara, Dave Chinner and me explored the scheme to let
> > balance_dirty_pages() wait for enough writeback IO completions to
> > safeguard the dirty limit. However it's found to have two problems:
> >
> > - in large NUMA systems, the per-cpu counters may have big accounting
> > A errors, leading to big throttle wait time and jitters.
> >
> > - NFS may kill large amount of unstable pages with one single COMMIT.
> > A Because NFS server serves COMMIT with expensive fsync() IOs, it is
> > A desirable to delay and reduce the number of COMMITs. So it's not
> > A likely to optimize away such kind of bursty IO completions, and the
> > A resulted large (and tiny) stall times in IO completion based throttling.
> >
> > So here is a pause time oriented approach, which tries to control the
> > pause time in each balance_dirty_pages() invocations, by controlling
> > the number of pages dirtied before calling balance_dirty_pages(), for
> > smooth and efficient dirty throttling:
> >
> > - avoid useless (eg. zero pause time) balance_dirty_pages() calls
> > - avoid too small pause time (less than A 10ms, which burns CPU power)
> > - avoid too large pause time (more than 100ms, which hurts responsiveness)
> > - avoid big fluctuations of pause times
> >
> > For example, when doing a simple cp on ext4 with mem=4G HZ=250.
> >
> > before patch, the pause time fluctuates from 0 to 324ms
> > (and the stall time may grow very large for slow devices)
> >
> > [ 1237.139962] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=56
> > [ 1237.207489] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=0
> > [ 1237.225190] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=0
> > [ 1237.234488] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=0
> > [ 1237.244692] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=0
> > [ 1237.375231] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=31
> > [ 1237.443035] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=15
> > [ 1237.574630] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=31
> > [ 1237.642394] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=15
> > [ 1237.666320] balance_dirty_pages: write_chunk=1536 pages_written=57 pause=5
> > [ 1237.973365] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=81
> > [ 1238.212626] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=56
> > [ 1238.280431] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=15
> > [ 1238.412029] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=31
> > [ 1238.412791] balance_dirty_pages: write_chunk=1536 pages_written=0 pause=0
> >
> > after patch, the pause time remains stable around 32ms
> >
> > cp-2687 A [002] A 1452.237012: balance_dirty_pages: weight=56% dirtied=128 pause=8
> > cp-2687 A [002] A 1452.246157: balance_dirty_pages: weight=56% dirtied=128 pause=8
> > cp-2687 A [006] A 1452.253043: balance_dirty_pages: weight=56% dirtied=128 pause=8
> > cp-2687 A [006] A 1452.261899: balance_dirty_pages: weight=57% dirtied=128 pause=8
> > cp-2687 A [006] A 1452.268939: balance_dirty_pages: weight=57% dirtied=128 pause=8
> > cp-2687 A [002] A 1452.276932: balance_dirty_pages: weight=57% dirtied=128 pause=8
> > cp-2687 A [002] A 1452.285889: balance_dirty_pages: weight=57% dirtied=128 pause=8
> >
> > CONTROL SYSTEM
> > ==============
> >
> > The current task_dirty_limit() adjusts bdi_dirty_limit to get
> > task_dirty_limit according to the dirty "weight" of the current task,
> > which is the percent of pages recently dirtied by the task. If 100%
> > pages are recently dirtied by the task, it will lower bdi_dirty_limit by
> > 1/8. If only 1% pages are dirtied by the task, it will return almost
> > unmodified bdi_dirty_limit. In this way, a heavy dirtier will get
> > blocked at task_dirty_limit=(bdi_dirty_limit-bdi_dirty_limit/8) while
> > allowing a light dirtier to progress (the latter won't be blocked
> > because R << B in fig.1).
> >
> > Fig.1 before patch, a heavy dirtier and a light dirtier
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A R
> > ----------------------------------------------+-o---------------------------*--|
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A L A A  A  A  A  A  A  A  A  A  A  A  A  A  B A T
> > A T: bdi_dirty_limit, as returned by bdi_dirty_limit()
> > A L: T - T/8
> >
> > A R: bdi_reclaimable + bdi_writeback
> >
> > A A: task_dirty_limit for a heavy dirtier ~= R ~= L
> > A B: task_dirty_limit for a light dirtier ~= T
> >
> > Since each process has its own dirty limit, we reuse A/B for the tasks as
> > well as their dirty limits.
> >
> > If B is a newly started heavy dirtier, then it will slowly gain weight
> > and A will lose weight. A The task_dirty_limit for A and B will be
> > approaching the center of region (L, T) and eventually stabilize there.
> >
> > Fig.2 before patch, two heavy dirtiers converging to the same threshold
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  R
> > ----------------------------------------------+--------------o-*---------------|
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A L A  A  A  A  A  A  A A B A  A  A  A  A  A  A  T
> 
> Seems good until now.
> So, What's the problem if two heavy dirtiers have a same threshold?

That's not a problem. It's the proper behavior to converge for two
"dd"s.

> > Fig.3 after patch, one heavy dirtier
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A |
> > A  A throttle_bandwidth ~= bdi_bandwidth A => A  A  o
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | o
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  o
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  A  o
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  A  A  o
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A | A  A  A  A  o
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A La| A  A  A  A  A  o
> > ----------------------------------------------+-+-------------o----------------|
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A R A  A  A  A  A  A  A A  A  A  A  A  A  A  A T
> > A T: bdi_dirty_limit
> > A A: task_dirty_limit A  A  A = T - Wa * T/16
> > A La: task_throttle_thresh = A - A/16
> >
> > A R: bdi_dirty_pages = bdi_reclaimable + bdi_writeback ~= La
> >
> > Now for IO-less balance_dirty_pages(), let's do it in a "bandwidth control"
> > way. In fig.3, a soft dirty limit region (La, A) is introduced. When R enters
> > this region, the task may be throttled for J jiffies on every N pages it dirtied.
> > Let's call (N/J) the "throttle bandwidth". It is computed by the following formula:
> >
> > A  A  A  A throttle_bandwidth = bdi_bandwidth * (A - R) / (A - La)
> > where
> > A  A  A  A A = T - Wa * T/16
> > A  A  A  A La = A - A/16
> > where Wa is task weight for A. It's 0 for very light dirtier and 1 for
> > the one heavy dirtier (that consumes 100% bdi write bandwidth). A The
> > task weight will be updated independently by task_dirty_inc() at
> > set_page_dirty() time.
> 
> 
> Dumb question.
> 
> I can't see the difference between old and new,
> La depends on A.
> A depends on Wa.
> T is constant?

T is the bdi's share of the global dirty limit. It's stable in normal,
and here we use it as the reference point for per-bdi dirty throttling.

> Then, throttle_bandwidth depends on Wa.

Sure, each task will be throttled at different bandwidth if there
"Wa" are different.

> Wa depends on the number of dirtied pages during some interval.
> So if light dirtier become heavy, at last light dirtier and heavy
> dirtier will have a same weight.
> It means throttle_bandwidth is same. It's a same with old result.

Yeah. Wa and throttle_bandwidth is changing over time.
 
> Please, open my eyes. :)

You get the dynamics right :)

> Thanks for the great work.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

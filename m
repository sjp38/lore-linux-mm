Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ED4CD6B0109
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 07:39:06 -0400 (EDT)
Date: Mon, 13 Sep 2010 19:38:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 02/17] writeback: IO-less balance_dirty_pages()
Message-ID: <20100913113859.GA30905@localhost>
References: <20100912154945.758129106@intel.com>
 <20100912155202.887304459@intel.com>
 <20100913084534.GE411@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100913084534.GE411@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 13, 2010 at 04:45:34PM +0800, Dave Chinner wrote:
> On Sun, Sep 12, 2010 at 11:49:47PM +0800, Wu Fengguang wrote:
> > As proposed by Chris, Dave and Jan, don't start foreground writeback IO
> > inside balance_dirty_pages(). Instead, simply let it idle sleep for some
> > time to throttle the dirtying task. In the mean while, kick off the
> > per-bdi flusher thread to do background writeback IO.
> > 
> > This patch introduces the basic framework, which will be further
> > consolidated by the next patches.
> 
> Can you put all this documentation into, say,
> Documentation/filesystems/writeback-throttling-design.txt?

OK.

> FWIW, I'm reading this and commenting without having looked at the
> code - I want to understand the design, not the implementation ;)

To get a further understanding of the dynamics, you are advised to run
it on a fast storage and check out the traces as shown in patch 07 ;)

> > RATIONALS
> > =========
> > 
> > The current balance_dirty_pages() is rather IO inefficient.
> > 
> > - concurrent writeback of multiple inodes (Dave Chinner)
> > 
> >   If every thread doing writes and being throttled start foreground
> >   writeback, it leads to N IO submitters from at least N different
> >   inodes at the same time, end up with N different sets of IO being
> >   issued with potentially zero locality to each other, resulting in
> >   much lower elevator sort/merge efficiency and hence we seek the disk
> >   all over the place to service the different sets of IO.
> >   OTOH, if there is only one submission thread, it doesn't jump between
> >   inodes in the same way when congestion clears - it keeps writing to
> >   the same inode, resulting in large related chunks of sequential IOs
> >   being issued to the disk. This is more efficient than the above
> >   foreground writeback because the elevator works better and the disk
> >   seeks less.
> > 
> > - small nr_to_write for fast arrays
> > 
> >   The write_chunk used by current balance_dirty_pages() cannot be
> >   directly set to some large value (eg. 128MB) for better IO efficiency.
> >   Because it could lead to more than 1 second user perceivable stalls.
> >   This limits current balance_dirty_pages() to small inefficient IOs.
> 
> Contrary to popular belief, I don't think nr_to_write is too small.
> It's slow devices that cause problems with large chunks, not fast
> arrays.

Then we have another merit "shorter stall time for slow devices" :)
This algorithm is able to adapt to reasonable pause time for both fast
and slow devices.

> > For the above two reasons, it's much better to shift IO to the flusher
> > threads and let balance_dirty_pages() just wait for enough time or progress.
> > 
> > Jan Kara, Dave Chinner and me explored the scheme to let
> > balance_dirty_pages() wait for enough writeback IO completions to
> > safeguard the dirty limit. This is found to have two problems:
> > 
> > - in large NUMA systems, the per-cpu counters may have big accounting
> >   errors, leading to big throttle wait time and jitters.
> > 
> > - NFS may kill large amount of unstable pages with one single COMMIT.
> >   Because NFS server serves COMMIT with expensive fsync() IOs, it is
> >   desirable to delay and reduce the number of COMMITs. So it's not
> >   likely to optimize away such kind of bursty IO completions, and the
> >   resulted large (and tiny) stall times in IO completion based throttling.
> > 
> > So here is a pause time oriented approach, which tries to control
> > 
> > - the pause time in each balance_dirty_pages() invocations
> > - the number of pages dirtied before calling balance_dirty_pages()
> > 
> > for smooth and efficient dirty throttling:
> > 
> > - avoid useless (eg. zero pause time) balance_dirty_pages() calls
> > - avoid too small pause time (less than  10ms, which burns CPU power)
> 
> For fast arrays, 10ms may be to high a lower bound. e.g. at 1GB/s,
> 10ms = 10MB written, at 10GB/s it is 100MB, so lower bounds for
> faster arrays might be necessary to prevent unneccessarily long
> wakeup latencies....

No problem. Then the user may need to enable HZ=1000 to get 1ms lower
bound.

I chose 10ms boundary because I believed it's good to keep at least 1
second worth of dirty/writeback pages for good IO performance. (Is
that true for your experiences?)

That means 10GB for a 10GB/s device. Given such a big pool of dirty
pages, a 10ms pause time (eg. 100MB drop of dirty pages) seems pretty
small.

> > CONTROL SYSTEM
> > ==============
> > 
> > The current task_dirty_limit() adjusts bdi_thresh according to the dirty
> > "weight" of the current task, which is the percent of pages recently
> > dirtied by the task. If 100% pages are recently dirtied by the task, it
> > will lower bdi_thresh by 1/8. If only 1% pages are dirtied by the task,
> > it will return almost unmodified bdi_thresh. In this way, a heavy
> > dirtier will get blocked at (bdi_thresh-bdi_thresh/8) while allowing a
> > light dirtier to progress (the latter won't be blocked because R << B in
> > fig.1).
> > 
> > Fig.1 before patch, a heavy dirtier and a light dirtier
> >                                                 R
> > ----------------------------------------------+-o---------------------------*--|
> >                                               L A                           B  T
> >   T: bdi_dirty_limit
> >   L: bdi_dirty_limit - bdi_dirty_limit/8
> > 
> >   R: bdi_reclaimable + bdi_writeback
> > 
> >   A: bdi_thresh for a heavy dirtier ~= R ~= L
> >   B: bdi_thresh for a light dirtier ~= T
> 
> Let me get your terminology straight:
> 
> 	T = throttle threshold

It's the value returned from bdi_dirty_limit() before calling
task_dirty_limit().

> 	L = lower throttle bound

Right.

> 	R = reclaimable pages

R = dirty + writeback + unstable pages currently in the bdi

> 	A/B: two dritying processes

A/B means processes in some contexts and the value returned from
task_dirty_limit() in other contexts.

> > 
> > If B is a newly started heavy dirtier, then it will slowly gain weight
> > and A will lose weight.  The bdi_thresh for A and B will be approaching
> > the center of region (L, T) and eventually stabilize there.
> > 
> > Fig.2 before patch, two heavy dirtiers converging to the same threshold
> >                                                              R
> > ----------------------------------------------+--------------o-*---------------|
> >                                               L              A B               T
> > 
> > Now for IO-less balance_dirty_pages(), let's do it in a "bandwidth control"
> > way. In fig.3, a soft dirty limit region (L, A) is introduced. When R enters
> > this region, the task may be throttled for T seconds on every N pages it dirtied.
> > Let's call (N/T) the "throttle bandwidth". It is computed by the following fomula:
> > 
> 
> Now you've redefined R, L, T and A to mean completely different
> things. That's kind of confusing, because you use them in similar
> graphs

The meanings are slightly redefined _after_ this patch. But for the above
graph, the meanings are still the same, except that A/B/R is floating
around as time go by.

> >         throttle_bandwidth = bdi_bandwidth * (A - R) / (A - L)
> > where
> >         L = A - A/16
> > 	A = T - T/16

        A = T - weight*(T/16)

where weight is 0 for very light dirtier and 1 for the one heavy
dirtier (that consumes 100% bdi write bandwidth)

Sorry..

> That means A and L are constants, so your algorithm comes down to
> a first-order linear system:
> 
> 	throttle_bandwidth = bdi_bandwidth * (15 - 16R/T)
> 
> that will only work in the range of 7/8T < R < 15/16T. That is,
> for R < L, throttle bandwidth will be calculated to be greater than
> bdi_bandwidth,

When R < L, we don't throttle it at all.

> and for R > A, throttle bandwidth will be negative.

When R > A, the code will detect the negativeness and choose to pause
200ms (the upper pause boundary), then loop over again.

> > So when there is only one heavy dirtier (fig.3),
> > 
> >         R ~= L
> >         throttle_bandwidth ~= bdi_bandwidth
> > 
> > It's a stable balance:
> > - when R > L, then throttle_bandwidth < bdi_bandwidth, so R will decrease to L
> > - when R < L, then throttle_bandwidth > bdi_bandwidth, so R will increase to L
> 
> That does not imply stability. First-order control algorithms are
> generally unstable - they have trouble with convergence and tend to
> overshoot and oscillate - because you can't easily control the rate
> of change of the controlled variable.

Sure there are always oscillations. And it would be bounded. When
there is 1 heavy dirtier, the error bound will be nr_dirtied_pause
and/or (pause time * bdi bandwidth). When there are 2 equal speed 
dirtiers, the max error is 2 * (pause time * bdi bandwidth/2), which
is still the same (given the same pause time).

The error is unavoidable anyway as long as you do throttle pause of
any kind, either by waiting for enough IO completions, or simply to
wait for some calculated pause time. The core feature offered by this
patch is, it allows you to control error by explicitly controlling the
pause time :)

> > Fig.3 after patch, one heavy dirtier
> > 
> >                                                 |
> >     throttle_bandwidth ~= bdi_bandwidth  =>     o
> >                                                 | o
> >                                                 |   o
> >                                                 |     o
> >                                                 |       o
> >                                                 |         o
> >                                               L |           o
> > ----------------------------------------------+-+-------------o----------------|
> >                                                 R             A                T
> >   T: bdi_dirty_limit
> >   A: task_dirty_limit = bdi_dirty_limit - bdi_dirty_limit/16

Here A = T - weight*T/16 = T - 1*T/16 = T*15/16

> >   L: task_dirty_limit - task_dirty_limit/16
> > 
> >   R: bdi_reclaimable + bdi_writeback ~= L
> > 
> > When there comes a new cp task, its weight will grow from 0 to 50%.
> 
> While the other decreases from 100% to 50%? What causes this?

The weight will be updated independently by task_dirty_inc() at
set_page_dirty() time.

> > When the weight is still small, it's considered a light dirtier and it's
> > allowed to dirty pages much faster than the bdi write bandwidth. In fact
> > initially it won't be throttled at all when R < Lb where Lb=B-B/16 and B~=T.
> 
> I'm missing something - if the task_dirty_limit is T/16, then the

task_dirty_limit is A = T - weight*(T/16). T/16 is the max possible
region size.

> the first task will have consumed all the dirty pages up to this
> point (i.e. R ~= T/16). The then second task starts, and while it is

With only 1 heavy dirtier, R = L = A - A/16 where A = T - 1*T/16
(weight=1).

> unthrottled, it will push R well past T. That will cause the first

When the second task B starts, its weight=0, so B=T-weight*T/16=T.
It will get throttled as soon as R (which is independent of tasks)
enters Lb (ie. the L value for B) = B - B/16, it will get gently
throttled at exactly the bdi bandwidth. So R will grow, because now
the dirty bandwidth of A plus B exceeds the bdi write bandwidth.
As R grows, both A and B will get more and more throttled, until
reaching the new balance point.

> task to throttle hard almost immediately, and effectively get
> throttled until the weight of the second task passes the "heavy"
> threshold.  The first task won't get unthrottled until R passes back
> down below T. That seems undesirable....
> 
> > Fig.4 after patch, an old cp + a newly started cp
> > 
> >                      (throttle bandwidth) =>    *
> >                                                 | *
> >                                                 |   *
> >                                                 |     *
> >                                                 |       *
> >                                                 |         *
> >                                                 |           *
> >                                                 |             *
> >                       throttle bandwidth  =>    o               *
> >                                                 | o               *
> >                                                 |   o               *
> >                                                 |     o               *
> >                                                 |       o               *
> >                                                 |         o               *
> >                                                 |           o               *
> > ------------------------------------------------+-------------o---------------*|
> >                                                 R             A               BT
> > 
> > So R will quickly grow large (fig.5). As the two heavy dirtiers' weight
> > converge to 50%, the points A, B will go towards each other and
> 
> This assumes that the two processes are reaching equal amount sof
> dirty pages in the page cache? (weight is not defined anywhere, so I
> can't tell from reading the document how it is calculated)

R = bdi dirty + writeback + unstable pages, which is independent of
(and has the same value for) any tasks. There is only one vertical
line of R; and many diagonal lines, one for each task.

> > eventually become one in fig.5. R will stabilize around A-A/32 where
> > A=B=T-T/16. throttle_bandwidth will stabilize around bdi_bandwidth/2.
> 
> Why? You haven't explained how weight affects any of the defined
> variables

Sorry. The corrected sentence is

        R will stabilize around A-A/32 where A=B=T-0.5*T/16=T-T/32.
        throttle_bandwidth will stabilize around bdi_bandwidth/2.

> > There won't be big oscillations between A and B, because as long as A
> > coincides with B, their throttle_bandwidth and dirtied pages will be
> > equal, A's weight will stop decreasing and B's weight will stop growing,
> > so the two points won't keep moving and cross each other. So it's a
> > pretty stable control system. The only problem is, it converges a bit
> > slow (except for really fast storage array).
> 
> Convergence should really be independent of the write speed,
> otherwise we'll be forever trying to find the "best" value for
> different configurations.

The convergence speed mainly affects R and much less on the write
speeds of A/B. So this is not a big problem.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

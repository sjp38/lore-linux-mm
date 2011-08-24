Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4AF446B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 14:01:26 -0400 (EDT)
Date: Wed, 24 Aug 2011 14:00:58 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110824180058.GC22434@redhat.com>
References: <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1313154259.6576.42.camel@twins>
 <20110812142020.GB17781@localhost>
 <1314027488.24275.74.camel@twins>
 <20110823034042.GC7332@localhost>
 <1314093660.8002.24.camel@twins>
 <20110823141504.GA15949@localhost>
 <20110823174757.GC15820@redhat.com>
 <20110824001257.GA6349@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110824001257.GA6349@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 24, 2011 at 08:12:58AM +0800, Wu Fengguang wrote:
> > You somehow directly jump to  
> > 
> > 	balanced_rate = task_ratelimit_200ms * write_bw / dirty_rate
> > 
> > without explaining why following will not work.
> > 
> > 	balanced_rate_(i+1) = balance_rate(i) * write_bw / dirty_rate
> 
> Thanks for asking that, it's probably the root of confusions, so let
> me answer it standalone.
> 
> It's actually pretty simple to explain this equation:
> 
>                                                write_bw
>         balanced_rate = task_ratelimit_200ms * ----------       (1)
>                                                dirty_rate
> 
> If there are N dd tasks, each task is throttled at task_ratelimit_200ms
> for the past 200ms, we are going to measure the overall bdi dirty rate
> 
>         dirty_rate = N * task_ratelimit_200ms                   (2)
> 
> put (2) into (1) we get
> 
>         balanced_rate = write_bw / N                            (3)
> 
> So equation (1) is the right estimation to get the desired target (3).
> 
> 
> As for
> 
>                                                   write_bw
>         balanced_rate_(i+1) = balanced_rate_(i) * ----------    (4)
>                                                   dirty_rate
> 
> Let's compare it with the "expanded" form of (1):
> 
>                                                               write_bw
>         balanced_rate_(i+1) = balanced_rate_(i) * pos_ratio * ----------      (5)
>                                                               dirty_rate
> 
> So the difference lies in pos_ratio.
> 
> Believe it or not, it's exactly the seemingly use of pos_ratio that
> makes (5) independent(*) of the position control.
> 
> Why? Look at (4), assume the system is in a state
> 
> - dirty rate is already balanced, ie. balanced_rate_(i) = write_bw / N
> - dirty position is not balanced, for example pos_ratio = 0.5
> 
> balance_dirty_pages() will be rate limiting each tasks at half the
> balanced dirty rate, yielding a measured
> 
>         dirty_rate = write_bw / 2                               (6)
> 
> Put (6) into (4), we get
> 
>         balanced_rate_(i+1) = balanced_rate_(i) * 2
>                             = (write_bw / N) * 2
> 
> That means, any position imbalance will lead to balanced_rate
> estimation errors if we follow (4). Whereas if (1)/(5) is used, we
> always get the right balanced dirty ratelimit value whether or not
> (pos_ratio == 1.0), hence make the rate estimation independent(*) of
> dirty position control.
> 
> (*) independent as in real values, not the seemingly relations in equation

Ok, I think I am beginning to see your point. Let me just elaborate on
the example you gave.

Assume a system is completely balanced and a task is writing at 100MB/s
rate.

write_bw = dirty_rate = 100MB/s, pos_ratio = 1; N=1

bdi->dirty_ratelimit = 100MB/s

Now another tasks starts dirtying the page cache on same bdi. Number of 
dirty pages should go up pretty fast and likely position ratio feedback
will kick in to reduce the dirtying rate. (rate based feedback does not
kick in till next 200ms) and pos_ratio feedback seems to be instantaneous.
Assume new pos_ratio is .5

So new throttle rate for both the tasks is 50MB/s.

bdi->dirty_ratelimit = 100MB/s (a feedback has not kicked in yet)
task_ratelimit = bdi->dirty_ratelimit * pos_ratio = 100 *.5 = 50MB/s

Now lets say 200ms have passed and rate base feedback is reevaluated.

						      write_bw	
bdi->dirty_ratelimit_(i+1) = bdi->dirty_ratelimit_i * ---------
						      dirty_bw

bdi->dirty_ratelimit_(i+1) = 100 * 100/100 = 100MB/s

Ideally bdi->dirty_ratelimit should have now become 50MB/s as N=2 but 
that did not happen. And reason being that there are two feedback control
loops and pos_ratio loops reacts to imbalances much more quickly. Because
previous loop has already reacted to the imbalance and reduced the
dirtying rate of task, rate based loop does not try to adjust anything
and thinks everything is just fine.

Things are fine in the sense that still dirty_rate == write_bw but
system is not balanced in terms of number of dirty pages and pos_ratio=.5

So you are trying to make one feedback loop aware of second loop so that
if second loop is unbalanced, first loop reacts to that as well and not
just look at dirty_rate and write_bw. So refining new balanced rate by
pos_ratio helps.
						      write_bw	
bdi->dirty_ratelimit_(i+1) = bdi->dirty_ratelimit_i * --------- * pos_ratio
						      dirty_bw

Now if global dirty pages are imbalanced, balanced rate will still go
down despite the fact that dirty_bw == write_bw. This will lead to
further reduction in task dirty rate. Which in turn will lead to reduced
number of dirty rate and should eventually lead to pos_ratio=1.

A related question though I should have asked you this long back. How does
throttling based on rate helps. Why we could not just work with two
pos_ratios. One is gloabl postion ratio and other is bdi position ratio.
And then throttle task gradually to achieve smooth throttling behavior.
IOW, what property does rate provide which is not available just by
looking at per bdi dirty pages. Can't we come up with bdi setpoint and
limit the way you have done for gloabl setpoint and throttle tasks
accordingly?

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

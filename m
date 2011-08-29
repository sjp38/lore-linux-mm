Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 98409900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 09:37:36 -0400 (EDT)
Date: Mon, 29 Aug 2011 21:37:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110829133729.GA27871@localhost>
References: <1313154259.6576.42.camel@twins>
 <20110812142020.GB17781@localhost>
 <1314027488.24275.74.camel@twins>
 <20110823034042.GC7332@localhost>
 <1314093660.8002.24.camel@twins>
 <20110823141504.GA15949@localhost>
 <20110823174757.GC15820@redhat.com>
 <20110824001257.GA6349@localhost>
 <20110824180058.GC22434@redhat.com>
 <1314623527.2816.28.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314623527.2816.28.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 29, 2011 at 09:12:07PM +0800, Peter Zijlstra wrote:
> On Wed, 2011-08-24 at 14:00 -0400, Vivek Goyal wrote:
> > 
> > Ok, I think I am beginning to see your point. Let me just elaborate on
> > the example you gave.
> > 
> > Assume a system is completely balanced and a task is writing at 100MB/s
> > rate.
> > 
> > write_bw = dirty_rate = 100MB/s, pos_ratio = 1; N=1
> > 
> > bdi->dirty_ratelimit = 100MB/s
> > 
> > Now another tasks starts dirtying the page cache on same bdi. Number of 
> > dirty pages should go up pretty fast and likely position ratio feedback
> > will kick in to reduce the dirtying rate. (rate based feedback does not
> > kick in till next 200ms) and pos_ratio feedback seems to be instantaneous.
> > Assume new pos_ratio is .5
> > 
> > So new throttle rate for both the tasks is 50MB/s.
> > 
> > bdi->dirty_ratelimit = 100MB/s (a feedback has not kicked in yet)
> > task_ratelimit = bdi->dirty_ratelimit * pos_ratio = 100 *.5 = 50MB/s
> > 
> > Now lets say 200ms have passed and rate base feedback is reevaluated.
> > 
> >                                                       write_bw  
> > bdi->dirty_ratelimit_(i+1) = bdi->dirty_ratelimit_i * ---------
> >                                                       dirty_bw
> > 
> > bdi->dirty_ratelimit_(i+1) = 100 * 100/100 = 100MB/s
> > 
> > Ideally bdi->dirty_ratelimit should have now become 50MB/s as N=2 but 
> > that did not happen. And reason being that there are two feedback control
> > loops and pos_ratio loops reacts to imbalances much more quickly. Because
> > previous loop has already reacted to the imbalance and reduced the
> > dirtying rate of task, rate based loop does not try to adjust anything
> > and thinks everything is just fine.
> > 
> > Things are fine in the sense that still dirty_rate == write_bw but
> > system is not balanced in terms of number of dirty pages and pos_ratio=.5
> > 
> > So you are trying to make one feedback loop aware of second loop so that
> > if second loop is unbalanced, first loop reacts to that as well and not
> > just look at dirty_rate and write_bw. So refining new balanced rate by
> > pos_ratio helps.
> >                                                       write_bw  
> > bdi->dirty_ratelimit_(i+1) = bdi->dirty_ratelimit_i * --------- * pos_ratio
> >                                                       dirty_bw
> > 
> > Now if global dirty pages are imbalanced, balanced rate will still go
> > down despite the fact that dirty_bw == write_bw. This will lead to
> > further reduction in task dirty rate. Which in turn will lead to reduced
> > number of dirty rate and should eventually lead to pos_ratio=1.
> 
> 
> Ok so this argument makes sense, is there some formalism to describe
> such systems where such things are more evident?

I find the most easy and clean way to describe it is,

(1) the below formula
                                                          write_bw  
    bdi->dirty_ratelimit_(i+1) = bdi->dirty_ratelimit_i * --------- * pos_ratio
                                                          dirty_bw
is able to yield

    dirty_ratelimit_(i) ~= (write_bw / N)

as long as

- write_bw, dirty_bw and pos_ratio are not changing rapidly
- dirty pages are not around @freerun or @limit

Otherwise there will be larger estimation errors.

(2) based on (1), we get

    task_ratelimit ~= (write_bw / N) * pos_ratio

So the pos_ratio feedback is able to drive dirty count to the
setpoint, where pos_ratio = 1.

That interpretation based on _real values_ can neatly decouple the two
feedback loops :) It makes full utilization of the fact "the
dirty_ratelimit _value_ is independent on pos_ratio except for
possible impacts on estimation errors".

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

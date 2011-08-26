Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 32D9E6B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 21:56:15 -0400 (EDT)
Date: Fri, 26 Aug 2011 09:56:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110826015610.GA10320@localhost>
References: <20110812142020.GB17781@localhost>
 <1314027488.24275.74.camel@twins>
 <20110823034042.GC7332@localhost>
 <1314093660.8002.24.camel@twins>
 <20110823141504.GA15949@localhost>
 <20110823174757.GC15820@redhat.com>
 <20110824001257.GA6349@localhost>
 <20110824180058.GC22434@redhat.com>
 <20110825031934.GA9764@localhost>
 <20110825222001.GG27162@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110825222001.GG27162@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 26, 2011 at 06:20:01AM +0800, Vivek Goyal wrote:
> On Thu, Aug 25, 2011 at 11:19:34AM +0800, Wu Fengguang wrote:
> 
> [..]
> > > So you are trying to make one feedback loop aware of second loop so that
> > > if second loop is unbalanced, first loop reacts to that as well and not
> > > just look at dirty_rate and write_bw. So refining new balanced rate by
> > > pos_ratio helps.
> > > 						      write_bw	
> > > bdi->dirty_ratelimit_(i+1) = bdi->dirty_ratelimit_i * --------- * pos_ratio
> > > 						      dirty_bw
> > > 
> > > Now if global dirty pages are imbalanced, balanced rate will still go
> > > down despite the fact that dirty_bw == write_bw. This will lead to
> > > further reduction in task dirty rate. Which in turn will lead to reduced
> > > number of dirty rate and should eventually lead to pos_ratio=1.
> > 
> > Right, that's a good alternative viewpoint to the below one.
> > 
> >   						  write_bw	
> >   bdi->dirty_ratelimit_(i+1) = task_ratelimit_i * ---------
> >   						  dirty_bw
> > 
> > (1) the periodic rate estimation uses that to refresh the balanced rate on every 200ms
> > (2) as long as the rate estimation is correct, pos_ratio is able to drive itself to 1.0
> 
> Personally I found it much easier to understand the other representation.
> Once you have come up with equation.
> 
> balance_rate_(i+1) = balance_rate(i) * write_bw/dirty_bw
> 
> Can you please put few lines of comments to explain that why above
> alone is not sufficient and we need to take pos_ratio also in to
> account to keep number of dirty pages in check. And then go onto
> 
> balance_rate_(i+1) = balance_rate(i) * write_bw/dirty_bw * pos_ratio
> 
> This kind of maintains the continuity of explanation and explains
> that why are we deviating from the theory we discussed so far.

Good point. Here is the commented code:

        /*
         * task_ratelimit reflects each dd's dirty rate for the past 200ms.
         */
        task_ratelimit = (u64)dirty_ratelimit *
                                        pos_ratio >> RATELIMIT_CALC_SHIFT;

        /*
         * A linear estimation of the "balanced" throttle rate. The theory is,
         * if there are N dd tasks, each throttled at task_ratelimit, the bdi's
         * dirty_rate will be measured to be (N * task_ratelimit). So the below
         * formula will yield the balanced rate limit (write_bw / N).
         *
         * Note that the expanded form is not a pure rate feedback:
         *      rate_(i+1) = rate_(i) * (write_bw / dirty_rate)              (1)
         * but also takes pos_ratio into account:
         *      rate_(i+1) = rate_(i) * (write_bw / dirty_rate) * pos_ratio  (2)
         *
         * (1) is not realistic because pos_ratio also takes part in balancing
         * the dirty rate.  Consider the state
         *      pos_ratio = 0.5                                              (3)
         *      rate = 2 * (write_bw / N)                                    (4)
         * If (1) is used, it will stuck in that state! Because each dd will be
         * throttled at
         *      task_ratelimit = pos_ratio * rate = (write_bw / N)           (5)
         * yielding
         *      dirty_rate = N * task_ratelimit = write_bw                   (6)
         * put (6) into (1) we get
         *      rate_(i+1) = rate_(i)                                        (7)
         *
         * So we end up using (2) to always keep
         *      rate_(i+1) ~= (write_bw / N)                                 (8)
         * regardless of the value of pos_ratio. As long as (8) is satisfied,
         * pos_ratio is able to drive itself to 1.0, which is not only where
         * the dirty count meet the setpoint, but also where the slope of
         * pos_ratio is most flat and hence task_ratelimit is least fluctuated.
         */
        balanced_dirty_ratelimit = div_u64((u64)task_ratelimit * write_bw,
                                           dirty_rate | 1);

> > 
> > > A related question though I should have asked you this long back. How does
> > > throttling based on rate helps. Why we could not just work with two
> > > pos_ratios. One is gloabl postion ratio and other is bdi position ratio.
> > > And then throttle task gradually to achieve smooth throttling behavior.
> > > IOW, what property does rate provide which is not available just by
> > > looking at per bdi dirty pages. Can't we come up with bdi setpoint and
> > > limit the way you have done for gloabl setpoint and throttle tasks
> > > accordingly?
> > 
> > Good question. If we have no idea of the balanced rate at all, but
> > still want to limit dirty pages within the range [freerun, limit],
> > all we can do is to throttle the task at eg. 1TB/s at @freerun and
> > 0 at @limit. Then you get a really sharp control line which will make
> > task_ratelimit fluctuate like mad...
> > 
> > So the balanced rate estimation is the key to get smooth task_ratelimit,
> > while pos_ratio is the ultimate guarantee for the dirty pages range.
> 
> Ok, that makes sense. By keeping an estimation of rate at which bdi
> can write, our range of throttling goes down. Say 0 to 300MB/s instead
> of 0 to 1TB/sec and that can lead to a more smooth behavior.

Yeah exactly, and even better, we can make the slope much more flat
around the setpoint to achieve excellent smoothness in stable state :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

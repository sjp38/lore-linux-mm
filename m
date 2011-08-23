Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9372D6B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 21:07:44 -0400 (EDT)
Date: Tue, 23 Aug 2011 09:07:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110823010721.GB7332@localhost>
References: <20110816022006.348714319@intel.com>
 <20110816022329.190706384@intel.com>
 <20110819020637.GA13597@redhat.com>
 <20110819025406.GA13365@localhost>
 <20110819190037.GJ18656@redhat.com>
 <20110821034657.GA30747@localhost>
 <20110822172230.GB17833@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110822172230.GB17833@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 23, 2011 at 01:22:30AM +0800, Vivek Goyal wrote:
> On Sun, Aug 21, 2011 at 11:46:58AM +0800, Wu Fengguang wrote:
> > On Sat, Aug 20, 2011 at 03:00:37AM +0800, Vivek Goyal wrote:
> > > On Fri, Aug 19, 2011 at 10:54:06AM +0800, Wu Fengguang wrote:
> > > > Hi Vivek,
> > > > 
> > > > > > +		base_rate = bdi->dirty_ratelimit;
> > > > > > +		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
> > > > > > +					       background_thresh, nr_dirty,
> > > > > > +					       bdi_thresh, bdi_dirty);
> > > > > > +		if (unlikely(pos_ratio == 0)) {
> > > > > > +			pause = MAX_PAUSE;
> > > > > > +			goto pause;
> > > > > >  		}
> > > > > > +		task_ratelimit = (u64)base_rate *
> > > > > > +					pos_ratio >> RATELIMIT_CALC_SHIFT;
> > > > > 
> > > > > Hi Fenguaang,
> > > > > 
> > > > > I am little confused here. I see that you have already taken pos_ratio
> > > > > into account in bdi_update_dirty_ratelimit() and wondering why to take
> > > > > that into account again in balance_diry_pages().
> > > > > 
> > > > > We calculated the pos_rate and balanced_rate and adjusted the
> > > > > bdi->dirty_ratelimit accordingly in bdi_update_dirty_ratelimit().
> > > > 
> > > > Good question. There are some inter-dependencies in the calculation,
> > > > and the dependency chain is the opposite to the one in your mind:
> > > > balance_dirty_pages() used pos_ratio in the first place, so that
> > > > bdi_update_dirty_ratelimit() have to use pos_ratio in the calculation
> > > > of the balanced dirty rate, too.
> > > > 
> > > > Let's return to how the balanced dirty rate is estimated. Please pay
> > > > special attention to the last paragraphs below the "......" line.
> > > > 
> > > > Start by throttling each dd task at rate
> > > > 
> > > >         task_ratelimit = task_ratelimit_0                               (1)
> > > >                          (any non-zero initial value is OK)
> > > > 
> > > > After 200ms, we measured
> > > > 
> > > >         dirty_rate = # of pages dirtied by all dd's / 200ms
> > > >         write_bw   = # of pages written to the disk / 200ms
> > > > 
> > > > For the aggressive dd dirtiers, the equality holds
> > > > 
> > > >         dirty_rate == N * task_rate
> > > >                    == N * task_ratelimit
> > > >                    == N * task_ratelimit_0                              (2)
> > > > Or     
> > > >         task_ratelimit_0 = dirty_rate / N                               (3)
> > > > 
> > > > Now we conclude that the balanced task ratelimit can be estimated by
> > > > 
> > > >         balanced_rate = task_ratelimit_0 * (write_bw / dirty_rate)      (4)
> > > > 
> > > > Because with (2) and (3), (4) yields the desired equality (1):
> > > > 
> > > >         balanced_rate == (dirty_rate / N) * (write_bw / dirty_rate)
> > > >                       == write_bw / N
> > > 
> > > Hi Fengguang,
> > > 
> > > Following is my understanding. Please correct me where I got it wrong.
> > > 
> > > Ok, I think I follow till this point. I think what you are saying is
> > > that following is our goal in a stable system.
> > > 
> > > 	task_ratelimit = write_bw/N				(6)
> > > 
> > > So we measure the write_bw of a bdi over a period of time and use that
> > > as feedback loop to modify bdi->dirty_ratelimit which inturn modifies
> > > task_ratelimit and hence we achieve the balance. So we will start with
> > > some arbitrary task limit say task_ratelimit_0, and modify that limit
> > > over a period of time based on our feedback loop to achieve a balanced
> > > system. And following seems to be the formula.
> > > 					    write_bw
> > > 	task_ratelimit = task_ratelimit_0 * ------- 		(7)
> > > 					    dirty_rate
> > > 
> > > Now I also understand that by using (2) and (3), you proved that
> > > how (7) will lead to (6) and that is our deisred goal. 
> > 
> > That's right.
> > 
> > > > 
> > > > .............................................................................
> > > > 
> > > > Now let's revisit (1). Since balance_dirty_pages() chooses to execute
> > > > the ratelimit
> > > > 
> > > >         task_ratelimit = task_ratelimit_0
> > > >                        = dirty_ratelimit * pos_ratio                    (5)
> > > > 
> > > 
> > > So balance_drity_pages() chose to take into account pos_ratio() also
> > > because for various reason like just taking into account only bandwidth
> > > variation as feedback was not sufficient. So we also took pos_ratio
> > > into account which in-trun is dependent on gloabal dirty pages and per
> > > bdi dirty_pages/rate.
> > 
> > That's right so far. balance_drity_pages() needs to do dirty position
> > control, so used formula (5).
> > 
> > > So we refined the formula for calculating a tasks's effective rate
> > > over a period of time to following.
> > > 					    write_bw
> > > 	task_ratelimit = task_ratelimit_0 * ------- * pos_ratio		(9)
> > > 					    dirty_rate
> > > 
> > 
> > That's not true. It should still be formula (7) when
> > balance_drity_pages() considers pos_ratio.
> 
> Why it is not true? If I do some math, it sounds right. Let me summarize
> my understanding again.

Ah sorry! (9) actually holds true, as made clear by your below reasoning.

> - In a steady state stable system, we want dirty_bw = write_bw, IOW.
>  
>   dirty_bw/write_bw = 1  		(1)
> 
>   If we can achieve above then that means we are throttling tasks at
>   just right rate.
> 
> Or
> -  dirty_bw  == write_bw
>    N * task_ratelimit == write_bw
>    task_ratelimit =  write_bw/N         (2)
> 
>   So as long as we can come up with a system where balance_dirty_pages()
>   calculates task_ratelimit to be write_bw/N, we should be fine.

Right.

> - But this does not take care of imbalances. So if system goes out of
>   balance before feedback loop kicks in and dirty rate shoots up, then
>   cache size will grow and number of dirty pages will shoot up. Hence
>   we brought in the notion of position ratio where we also vary a 
>   tasks's dirty ratelimit based on number of dirty pages. So our
>   effective formula became.
> 
>   task_ratelimit = write_bw/N * pos_ratio     (3)
> 
>   So as long as we meet (3), we should reach to stable state.

Right.

> -  But here N is unknown in advance so balance_drity_pages() can not make
>    use of this formula directly. But write_bw and dirty_bw from previous
>    200ms are known. So following can replace (3).
> 
> 				       write_bw
>    task_ratelimit = task_ratelimit_0 * --------- * pos_ratio      (4)
> 					dirty_bw	
> 
>    dirty_bw = task_ratelimit_0 * N                (5)
> 
>    Substitute (5) in (4)
> 
>    task_ratelimit = write_bw/N * pos_ratio      (6)
> 
>    (6) is same as (3) which has been derived from (4) and that means at any
>    given point of time (4) can be used by balance_drity_pages() to calculate
>    a tasks's throttling rate.

Right. Sorry what's in my mind was

                                       write_bw
    balanced_rate = task_ratelimit_0 * --------
                                       dirty_bw        

    task_ratelimit = balanced_rate * pos_ratio

which is effective the same to your combined equation (4).

> - Now going back to (4). Because we have a feedback loop where we
>   continuously update a previous number based on feedback, we can track
>   previous value in bdi->dirty_ratelimit.
> 
> 				       write_bw
>    task_ratelimit = task_ratelimit_0 * --------- * pos_ratio 
> 					dirty_bw	
> 
>    Or
> 
>    task_ratelimit = bdi->dirty_ratelimit * pos_ratio         (7)
> 
>    where
> 					    write_bw	
>   bdi->dirty_ratelimit = task_ratelimit_0 * ---------
> 					    dirty_bw

Right.

>   Because task_ratelimit_0 is initial value to begin with and we will
>   keep on coming with new value every 200ms, we should be able to write
>   above as follows.
> 
> 						      write_bw
>   bdi->dirty_ratelimit_n = bdi->dirty_ratelimit_n-1 * --------  (8)
> 						      dirty_bw
> 
>   Effectively we start with an initial value of task_ratelimit_0 and
>   then keep on updating it based on rate change feedback every 200ms.

Right.

>   To summarize,
> 
>   We need to achieve (3) for a balanced system. Because we don't know the
>   value of N in advance, we can use (4) to achieve effect of (3). So we
>   start with a default value of task_ratelimit_0 and update that every
>   200ms based on how write and dirty rate on device is changing (8). We also
>   further refine that rate by pos_ratio so that any variations in number
>   of dirty pages due to temporary imbalances in the system can be
>   accounted for (7).
> 
> I see that you also use (7). I think only contention point is how
> (8) is perceived. So can you please explain why do you think that
> above calculation or (9) is wrong.

There is no contention point and (9) is right..Sorry it's my fault.
We are well aligned in the above reasoning :)

> I can kind of understand that you have done various adjustments to keep the
> task_ratelimit and bdi->dirty_ratelimit relatively stable. Just that
> I am not able to understand your calculations in updating bdi->dirty_ratelimit.  

You mean the below chunk of code? Which is effectively the same as this _one_
line of code

        bdi->dirty_ratelimit = balanced_rate;

except for doing some tricks (conditional update and limiting step size) to
stabilize bdi->dirty_ratelimit:

        unsigned long base_rate = bdi->dirty_ratelimit;

        /*
         * Use a different name for the same value to distinguish the concepts.
         * Only the relative value of
         *     (pos_rate - base_rate) = (pos_ratio - 1) * base_rate
         * will be used below, which reflects the direction and size of dirty
         * position error.
         */
        pos_rate = (u64)base_rate * pos_ratio >> RATELIMIT_CALC_SHIFT;

        /*
         * dirty_ratelimit will follow balanced_rate iff pos_rate is on the
         * same side of dirty_ratelimit, too.
         * For example,
         * - (base_rate > balanced_rate) => dirty rate is too high
         * - (base_rate > pos_rate)      => dirty pages are above setpoint
         * so lowering base_rate will help meet both the position and rate
         * control targets. Otherwise, don't update base_rate if it will only
         * help meet the rate target. After all, what the users ultimately feel
         * and care are stable dirty rate and small position error.  This
         * update policy can also prevent dirty_ratelimit from being driven
         * away by possible systematic errors in balanced_rate.
         *
         * |base_rate - pos_rate| is also used to limit the step size for
         * filtering out the sigular points of balanced_rate, which keeps
         * jumping around randomly and can even leap far away at times due to
         * the small 200ms estimation period of dirty_rate (we want to keep
         * that period small to reduce time lags).
         */
        delta = 0;
        if (base_rate < balanced_rate) {
                if (base_rate < pos_rate)
                        delta = min(balanced_rate, pos_rate) - base_rate;
        } else {
                if (base_rate > pos_rate)
                        delta = base_rate - max(balanced_rate, pos_rate);
        }
       
        /*
         * Don't pursue 100% rate matching. It's impossible since the balanced
         * rate itself is constantly fluctuating. So decrease the track speed
         * when it gets close to the target. Helps eliminate pointless tremors.
         */
        delta >>= base_rate / (8 * delta + 1);
        /*
         * Limit the tracking speed to avoid overshooting.
         */
        delta = (delta + 7) / 8;

        if (base_rate < balanced_rate)
                base_rate += delta;
        else   
                base_rate -= delta;

        bdi->dirty_ratelimit = max(base_rate, 1UL);

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

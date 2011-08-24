Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5FE526B0169
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 23:09:49 -0400 (EDT)
Date: Wed, 24 Aug 2011 11:09:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110824030942.GA26055@localhost>
References: <20110816022006.348714319@intel.com>
 <20110816022329.190706384@intel.com>
 <20110819020637.GA13597@redhat.com>
 <20110819025406.GA13365@localhost>
 <20110819190037.GJ18656@redhat.com>
 <20110821034657.GA30747@localhost>
 <20110822172230.GB17833@redhat.com>
 <20110823010721.GB7332@localhost>
 <20110823135355.GB20291@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110823135355.GB20291@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 23, 2011 at 09:53:55PM +0800, Vivek Goyal wrote:
> On Tue, Aug 23, 2011 at 09:07:21AM +0800, Wu Fengguang wrote:
> 
> [..]
> > > > > So we refined the formula for calculating a tasks's effective rate
> > > > > over a period of time to following.
> > > > > 					    write_bw
> > > > > 	task_ratelimit = task_ratelimit_0 * ------- * pos_ratio		(9)
> > > > > 					    dirty_rate
> > > > > 
> > > > 
> > > > That's not true. It should still be formula (7) when
> > > > balance_drity_pages() considers pos_ratio.
> > > 
> > > Why it is not true? If I do some math, it sounds right. Let me summarize
> > > my understanding again.
> > 
> > Ah sorry! (9) actually holds true, as made clear by your below reasoning.
> > 
> > > - In a steady state stable system, we want dirty_bw = write_bw, IOW.
> > >  
> > >   dirty_bw/write_bw = 1  		(1)
> > > 
> > >   If we can achieve above then that means we are throttling tasks at
> > >   just right rate.
> > > 
> > > Or
> > > -  dirty_bw  == write_bw
> > >    N * task_ratelimit == write_bw
> > >    task_ratelimit =  write_bw/N         (2)
> > > 
> > >   So as long as we can come up with a system where balance_dirty_pages()
> > >   calculates task_ratelimit to be write_bw/N, we should be fine.
> > 
> > Right.
> > 
> > > - But this does not take care of imbalances. So if system goes out of
> > >   balance before feedback loop kicks in and dirty rate shoots up, then
> > >   cache size will grow and number of dirty pages will shoot up. Hence
> > >   we brought in the notion of position ratio where we also vary a 
> > >   tasks's dirty ratelimit based on number of dirty pages. So our
> > >   effective formula became.
> > > 
> > >   task_ratelimit = write_bw/N * pos_ratio     (3)
> > > 
> > >   So as long as we meet (3), we should reach to stable state.
> > 
> > Right.
> > 
> > > -  But here N is unknown in advance so balance_drity_pages() can not make
> > >    use of this formula directly. But write_bw and dirty_bw from previous
> > >    200ms are known. So following can replace (3).
> > > 
> > > 				       write_bw
> > >    task_ratelimit = task_ratelimit_0 * --------- * pos_ratio      (4)
> > > 					dirty_bw	
> > > 
> > >    dirty_bw = task_ratelimit_0 * N                (5)
> > > 
> > >    Substitute (5) in (4)
> > > 
> > >    task_ratelimit = write_bw/N * pos_ratio      (6)
> > > 
> > >    (6) is same as (3) which has been derived from (4) and that means at any
> > >    given point of time (4) can be used by balance_drity_pages() to calculate
> > >    a tasks's throttling rate.
> > 
> > Right. Sorry what's in my mind was
> > 
> >                                        write_bw
> >     balanced_rate = task_ratelimit_0 * --------
> >                                        dirty_bw        
> > 
> >     task_ratelimit = balanced_rate * pos_ratio
> > 
> > which is effective the same to your combined equation (4).
> > 
> > > - Now going back to (4). Because we have a feedback loop where we
> > >   continuously update a previous number based on feedback, we can track
> > >   previous value in bdi->dirty_ratelimit.
> > > 
> > > 				       write_bw
> > >    task_ratelimit = task_ratelimit_0 * --------- * pos_ratio 
> > > 					dirty_bw	
> > > 
> > >    Or
> > > 
> > >    task_ratelimit = bdi->dirty_ratelimit * pos_ratio         (7)
> > > 
> > >    where
> > > 					    write_bw	
> > >   bdi->dirty_ratelimit = task_ratelimit_0 * ---------
> > > 					    dirty_bw
> > 
> > Right.
> > 
> > >   Because task_ratelimit_0 is initial value to begin with and we will
> > >   keep on coming with new value every 200ms, we should be able to write
> > >   above as follows.
> > > 
> > > 						      write_bw
> > >   bdi->dirty_ratelimit_n = bdi->dirty_ratelimit_n-1 * --------  (8)
> > > 						      dirty_bw
> > > 
> > >   Effectively we start with an initial value of task_ratelimit_0 and
> > >   then keep on updating it based on rate change feedback every 200ms.
> > 
> > Right.
> > 
> > >   To summarize,
> > > 
> > >   We need to achieve (3) for a balanced system. Because we don't know the
> > >   value of N in advance, we can use (4) to achieve effect of (3). So we
> > >   start with a default value of task_ratelimit_0 and update that every
> > >   200ms based on how write and dirty rate on device is changing (8). We also
> > >   further refine that rate by pos_ratio so that any variations in number
> > >   of dirty pages due to temporary imbalances in the system can be
> > >   accounted for (7).
> > > 
> > > I see that you also use (7). I think only contention point is how
> > > (8) is perceived. So can you please explain why do you think that
> > > above calculation or (9) is wrong.
> > 
> > There is no contention point and (9) is right..Sorry it's my fault.
> > We are well aligned in the above reasoning :)
> 
> Great. Now we are on same page now at least till this point.
> 
> > 
> > > I can kind of understand that you have done various adjustments to keep the
> > > task_ratelimit and bdi->dirty_ratelimit relatively stable. Just that
> > > I am not able to understand your calculations in updating bdi->dirty_ratelimit.  
> > 
> > You mean the below chunk of code? Which is effectively the same as this _one_
> > line of code
> > 
> >         bdi->dirty_ratelimit = balanced_rate;
> > 
> > except for doing some tricks (conditional update and limiting step size) to
> > stabilize bdi->dirty_ratelimit:
> 
> I am fine with bdi->dirty_ratelimit being called balanced rate. I am
> taking exception to the fact that you are also taking into accout
> pos_ratio while coming up with new balanced_rate after 200ms of feedback.
> 
> We agreed to updating bdi->dirty_ratelimit as follows (8 above).
> 
>  
>  						      write_bw
>    bdi->dirty_ratelimit_n = bdi->dirty_ratelimit_n-1 * --------  (8)
>  						      dirty_bw
> 
> I think in your terminology it could be called.
> 					   write_bw
>   new_balanced_rate = prev_balanced_rate * ----------            (9)
> 					   dirty_bw
> 
> But what you seem to be doing is following.
> 							write_bw
>   new_balanced_rate = prev_balanced_rate * pos_ratio * -----------  (10)
> 							dirty_bw
> 
> Of course I have just tried to simlify your actual calculations to
> show why I am questioning the presence of pos_ratio while calculating
> the new bdi->dirty_ratelimit. I am fine with limiting the step size etc.
> 
> So (9) and (10) don't match?
> 
> Now going back to your code and show how I arrived at (10).
> 
> executed_rate = (u64)base_rate * pos_ratio >> RATELIMIT_CALC_SHIFT; (11)
> balanced_rate = div_u64((u64)executed_rate * bdi->avg_write_bandwidth,
> 			dirty_rate | 1);			(12)
> 
> Combining (11) and (12) gives us (10).
> 				     write_bw
> balance_rate = base_rate * pos_ratio --------
> 				     dirty_rate
> 
> Or
> 					    write_bw
> bdi->dirty_ratelimit = base_rate * pos_ratio --------
> 					     dirty_rate

I hope the other email on the balanced_rate estimation equation can
clarify the questions on pos_ratio..

> To complicate the things you also have the notion of pos_rate and reduce
> the step size based on either pos_rate or balance_rate.
> 
> pos_rate = executed_rate = base_rate * pos_ratio;
> 
> 				     write_bw
> balance_rate = base_rate * pos_ratio --------
> 				     dirty_rate
> 
> bdi->dirty_rate_limit = min_change(pos_rate, balance_rate)       (13)
> 
> So for feedback, why are not sticking to simply (9) and limit the step
> size and not take pos_ratio into account. 

pos_rate is used to limit the step size. This reply to Peter has more
details:

http://www.spinics.net/lists/linux-fsdevel/msg47991.html

> Even if you have to take it into account, it needs to be explained clearly
> and so many rate definitions confuse things more. Keeping name constant
> everywhere (even for local variables), helps understand the code better.
> 

Good idea! There are two many names that differs subtly..

> Look at number of rates we have in code and it gets so confusing.
> 
> balanced_rate
> base_rate
> bdi->dirty_ratelimit
> 
> executed_rate
> pos_rate
> task_ratelimit
> 
> dirty_rate
> write_bw
> 
> Here balanced_rate, base_rate and bdi->dirty_ratelimit all seem to be
> referring to same thing and that is not obivious from the code. Looks
> like task->ratelimit and executed_rate and pos_rate are referring to same
> thing.

Right.

> So instead of 6 rates, we could atleast collpase the naming to 2 rates
> to keep the context clear. Just prefix/suffix more strings to highlight
> subtle difference between two rates.

How about

  balanced_rate            =>  balanced_dirty_ratelimit
  base_rate                =>  dirty_ratelimit
  bdi->dirty_ratelimit     ==  bdi->dirty_ratelimit

  pos_rate                 =>  task_ratelimit
  executed_rate            =>  task_ratelimit
  task_ratelimit           ==  task_ratelimit

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

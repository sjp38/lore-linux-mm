Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E8D3E6B016B
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 13:22:51 -0400 (EDT)
Date: Mon, 22 Aug 2011 13:22:30 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110822172230.GB17833@redhat.com>
References: <20110816022006.348714319@intel.com>
 <20110816022329.190706384@intel.com>
 <20110819020637.GA13597@redhat.com>
 <20110819025406.GA13365@localhost>
 <20110819190037.GJ18656@redhat.com>
 <20110821034657.GA30747@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110821034657.GA30747@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Aug 21, 2011 at 11:46:58AM +0800, Wu Fengguang wrote:
> On Sat, Aug 20, 2011 at 03:00:37AM +0800, Vivek Goyal wrote:
> > On Fri, Aug 19, 2011 at 10:54:06AM +0800, Wu Fengguang wrote:
> > > Hi Vivek,
> > > 
> > > > > +		base_rate = bdi->dirty_ratelimit;
> > > > > +		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
> > > > > +					       background_thresh, nr_dirty,
> > > > > +					       bdi_thresh, bdi_dirty);
> > > > > +		if (unlikely(pos_ratio == 0)) {
> > > > > +			pause = MAX_PAUSE;
> > > > > +			goto pause;
> > > > >  		}
> > > > > +		task_ratelimit = (u64)base_rate *
> > > > > +					pos_ratio >> RATELIMIT_CALC_SHIFT;
> > > > 
> > > > Hi Fenguaang,
> > > > 
> > > > I am little confused here. I see that you have already taken pos_ratio
> > > > into account in bdi_update_dirty_ratelimit() and wondering why to take
> > > > that into account again in balance_diry_pages().
> > > > 
> > > > We calculated the pos_rate and balanced_rate and adjusted the
> > > > bdi->dirty_ratelimit accordingly in bdi_update_dirty_ratelimit().
> > > 
> > > Good question. There are some inter-dependencies in the calculation,
> > > and the dependency chain is the opposite to the one in your mind:
> > > balance_dirty_pages() used pos_ratio in the first place, so that
> > > bdi_update_dirty_ratelimit() have to use pos_ratio in the calculation
> > > of the balanced dirty rate, too.
> > > 
> > > Let's return to how the balanced dirty rate is estimated. Please pay
> > > special attention to the last paragraphs below the "......" line.
> > > 
> > > Start by throttling each dd task at rate
> > > 
> > >         task_ratelimit = task_ratelimit_0                               (1)
> > >                          (any non-zero initial value is OK)
> > > 
> > > After 200ms, we measured
> > > 
> > >         dirty_rate = # of pages dirtied by all dd's / 200ms
> > >         write_bw   = # of pages written to the disk / 200ms
> > > 
> > > For the aggressive dd dirtiers, the equality holds
> > > 
> > >         dirty_rate == N * task_rate
> > >                    == N * task_ratelimit
> > >                    == N * task_ratelimit_0                              (2)
> > > Or     
> > >         task_ratelimit_0 = dirty_rate / N                               (3)
> > > 
> > > Now we conclude that the balanced task ratelimit can be estimated by
> > > 
> > >         balanced_rate = task_ratelimit_0 * (write_bw / dirty_rate)      (4)
> > > 
> > > Because with (2) and (3), (4) yields the desired equality (1):
> > > 
> > >         balanced_rate == (dirty_rate / N) * (write_bw / dirty_rate)
> > >                       == write_bw / N
> > 
> > Hi Fengguang,
> > 
> > Following is my understanding. Please correct me where I got it wrong.
> > 
> > Ok, I think I follow till this point. I think what you are saying is
> > that following is our goal in a stable system.
> > 
> > 	task_ratelimit = write_bw/N				(6)
> > 
> > So we measure the write_bw of a bdi over a period of time and use that
> > as feedback loop to modify bdi->dirty_ratelimit which inturn modifies
> > task_ratelimit and hence we achieve the balance. So we will start with
> > some arbitrary task limit say task_ratelimit_0, and modify that limit
> > over a period of time based on our feedback loop to achieve a balanced
> > system. And following seems to be the formula.
> > 					    write_bw
> > 	task_ratelimit = task_ratelimit_0 * ------- 		(7)
> > 					    dirty_rate
> > 
> > Now I also understand that by using (2) and (3), you proved that
> > how (7) will lead to (6) and that is our deisred goal. 
> 
> That's right.
> 
> > > 
> > > .............................................................................
> > > 
> > > Now let's revisit (1). Since balance_dirty_pages() chooses to execute
> > > the ratelimit
> > > 
> > >         task_ratelimit = task_ratelimit_0
> > >                        = dirty_ratelimit * pos_ratio                    (5)
> > > 
> > 
> > So balance_drity_pages() chose to take into account pos_ratio() also
> > because for various reason like just taking into account only bandwidth
> > variation as feedback was not sufficient. So we also took pos_ratio
> > into account which in-trun is dependent on gloabal dirty pages and per
> > bdi dirty_pages/rate.
> 
> That's right so far. balance_drity_pages() needs to do dirty position
> control, so used formula (5).
> 
> > So we refined the formula for calculating a tasks's effective rate
> > over a period of time to following.
> > 					    write_bw
> > 	task_ratelimit = task_ratelimit_0 * ------- * pos_ratio		(9)
> > 					    dirty_rate
> > 
> 
> That's not true. It should still be formula (7) when
> balance_drity_pages() considers pos_ratio.

Why it is not true? If I do some math, it sounds right. Let me summarize
my understanding again.

- In a steady state stable system, we want dirty_bw = write_bw, IOW.
 
  dirty_bw/write_bw = 1  		(1)

  If we can achieve above then that means we are throttling tasks at
  just right rate.

Or
-  dirty_bw  == write_bw
   N * task_ratelimit == write_bw
   task_ratelimit =  write_bw/N         (2)

  So as long as we can come up with a system where balance_dirty_pages()
  calculates task_ratelimit to be write_bw/N, we should be fine.

- But this does not take care of imbalances. So if system goes out of
  balance before feedback loop kicks in and dirty rate shoots up, then
  cache size will grow and number of dirty pages will shoot up. Hence
  we brought in the notion of position ratio where we also vary a 
  tasks's dirty ratelimit based on number of dirty pages. So our
  effective formula became.

  task_ratelimit = write_bw/N * pos_ratio     (3)

  So as long as we meet (3), we should reach to stable state.

-  But here N is unknown in advance so balance_drity_pages() can not make
   use of this formula directly. But write_bw and dirty_bw from previous
   200ms are known. So following can replace (3).

				       write_bw
   task_ratelimit = task_ratelimit_0 * --------- * pos_ratio      (4)
					dirty_bw	

   dirty_bw = tas_ratelimit_0 * N                (5)

   Substitute (5) in (4)

   task_ratelimit = write_bw/N * pos_ratio      (6)

   (6) is same as (3) which has been derived from (4) and that means at any
   given point of time (4) can be used by balance_drity_pages() to calculate
   a tasks's throttling rate.

- Now going back to (4). Because we have a feedback loop where we
  continuously update a previous number based on feedback, we can track
  previous value in bdi->dirty_ratelimit.

				       write_bw
   task_ratelimit = task_ratelimit_0 * --------- * pos_ratio 
					dirty_bw	

   Or

   task_ratelimit = bdi->dirty_ratelimit * pos_ratio         (7)

   where
					    write_bw	
  bdi->dirty_ratelimit = task_ratelimit_0 * ---------
					    dirty_bw
  
  Because task_ratelimit_0 is initial value to begin with and we will
  keep on coming with new value every 200ms, we should be able to write
  above as follows.

						      write_bw
  bdi->dirty_ratelimit_n = bdi->dirty_ratelimit_n-1 * --------  (8)
						      dirty_bw

  Effectively we start with an initial value of task_ratelimit_0 and
  then keep on updating it based on rate change feedback every 200ms.

  To summarize,

  We need to achieve (3) for a balanced system. Because we don't know the
  value of N in advance, we can use (4) to achieve effect of (3). So we
  start with a default value of task_ratelimit_0 and update that every
  200ms based on how write and dirty rate on device is changing (8). We also
  further refine that rate by pos_ratio so that any variations in number
  of dirty pages due to temporary imbalances in the system can be
  accounted for (7).

I see that you also use (7). I think only contention point is how
(8) is perceived. So can you please explain why do you think that
above calculation or (9) is wrong.

I can kind of understand that you have done various adjustments to keep the
task_ratelimit and bdi->dirty_ratelimit relatively stable. Just that
I am not able to understand your calculations in updating bdi->dirty_ratelimit.  
Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

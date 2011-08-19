Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 24C756B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 15:01:05 -0400 (EDT)
Date: Fri, 19 Aug 2011 15:00:37 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110819190037.GJ18656@redhat.com>
References: <20110816022006.348714319@intel.com>
 <20110816022329.190706384@intel.com>
 <20110819020637.GA13597@redhat.com>
 <20110819025406.GA13365@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110819025406.GA13365@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 19, 2011 at 10:54:06AM +0800, Wu Fengguang wrote:
> Hi Vivek,
> 
> > > +		base_rate = bdi->dirty_ratelimit;
> > > +		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
> > > +					       background_thresh, nr_dirty,
> > > +					       bdi_thresh, bdi_dirty);
> > > +		if (unlikely(pos_ratio == 0)) {
> > > +			pause = MAX_PAUSE;
> > > +			goto pause;
> > >  		}
> > > +		task_ratelimit = (u64)base_rate *
> > > +					pos_ratio >> RATELIMIT_CALC_SHIFT;
> > 
> > Hi Fenguaang,
> > 
> > I am little confused here. I see that you have already taken pos_ratio
> > into account in bdi_update_dirty_ratelimit() and wondering why to take
> > that into account again in balance_diry_pages().
> > 
> > We calculated the pos_rate and balanced_rate and adjusted the
> > bdi->dirty_ratelimit accordingly in bdi_update_dirty_ratelimit().
> 
> Good question. There are some inter-dependencies in the calculation,
> and the dependency chain is the opposite to the one in your mind:
> balance_dirty_pages() used pos_ratio in the first place, so that
> bdi_update_dirty_ratelimit() have to use pos_ratio in the calculation
> of the balanced dirty rate, too.
> 
> Let's return to how the balanced dirty rate is estimated. Please pay
> special attention to the last paragraphs below the "......" line.
> 
> Start by throttling each dd task at rate
> 
>         task_ratelimit = task_ratelimit_0                               (1)
>                          (any non-zero initial value is OK)
> 
> After 200ms, we measured
> 
>         dirty_rate = # of pages dirtied by all dd's / 200ms
>         write_bw   = # of pages written to the disk / 200ms
> 
> For the aggressive dd dirtiers, the equality holds
> 
>         dirty_rate == N * task_rate
>                    == N * task_ratelimit
>                    == N * task_ratelimit_0                              (2)
> Or     
>         task_ratelimit_0 = dirty_rate / N                               (3)
> 
> Now we conclude that the balanced task ratelimit can be estimated by
> 
>         balanced_rate = task_ratelimit_0 * (write_bw / dirty_rate)      (4)
> 
> Because with (2) and (3), (4) yields the desired equality (1):
> 
>         balanced_rate == (dirty_rate / N) * (write_bw / dirty_rate)
>                       == write_bw / N

Hi Fengguang,

Following is my understanding. Please correct me where I got it wrong.

Ok, I think I follow till this point. I think what you are saying is
that following is our goal in a stable system.

	task_ratelimit = write_bw/N				(6)

So we measure the write_bw of a bdi over a period of time and use that
as feedback loop to modify bdi->dirty_ratelimit which inturn modifies
task_ratelimit and hence we achieve the balance. So we will start with
some arbitrary task limit say task_ratelimit_0, and modify that limit
over a period of time based on our feedback loop to achieve a balanced
system. And following seems to be the formula.
					    write_bw
	task_ratelimit = task_ratelimit_0 * ------- 		(7)
					    dirty_rate

Now I also understand that by using (2) and (3), you proved that
how (7) will lead to (6) and that is our deisred goal. 

> 
> .............................................................................
> 
> Now let's revisit (1). Since balance_dirty_pages() chooses to execute
> the ratelimit
> 
>         task_ratelimit = task_ratelimit_0
>                        = dirty_ratelimit * pos_ratio                    (5)
> 

So balance_drity_pages() chose to take into account pos_ratio() also
because for various reason like just taking into account only bandwidth
variation as feedback was not sufficient. So we also took pos_ratio
into account which in-trun is dependent on gloabal dirty pages and per
bdi dirty_pages/rate.

So we refined the formula for calculating a tasks's effective rate
over a period of time to following.
					    write_bw
	task_ratelimit = task_ratelimit_0 * ------- * pos_ratio		(9)
					    dirty_rate

Is my understanding right so far?

> Put (5) into (4), we get the final form used in
> bdi_update_dirty_ratelimit()
> 
>         balanced_rate = (dirty_ratelimit * pos_ratio) * (write_bw / dirty_rate)
> 
> So you really need to take (dirty_ratelimit * pos_ratio) as a single entity.

Now few questions.

- What is dirty_ratelimit in formula above?

- Is it wrong to understand the issue in following manner.

  bdi->dirty_ratelimit is tracking write bandwidth variation on the bdi
  and effectively tracks write_bw/N.

  bdi->dirty_ratelimit = write_bw/N

  or 

					    		  write_bw
  bdi->dirty_ratelimit = previous_bdi->dirty_ratelimit * -------------    (10)
					     		  dirty_rate

 Hence a tasks's balanced rate from (9) and (10) is.

 task_ratelimit = bdi->dirty_ratelimit * pos_ratio		(11)

So my understanding about (10) and (11) is wrong? if no, then question
comes that bdi->dirty_ratelimit is supposed to be keeping track of 
write bandwidth variations only. And in turn task ratelimit will be
driven by both bandwidth varation as well as pos_ratio variation.

But you seem to be doing following.

 bdi->dirty_ratelimit = adjust based on a cobination of bandwidth feedback
		        and pos_ratio feedback. 

 task_ratelimit = bdi->dirty_ratelimit * pos_ratio		(12)

So my question is that when task_ratelimit is finally being adjusted 
based on pos_ratio feedback, why bdi->dirty_ratelimit also needs to
take that into account.

I know you have tried explaining it, but sorry, I did not get it. May
be give it another shot in a layman's terms and I might understand it.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4BFE16B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 04:35:17 -0400 (EDT)
Date: Tue, 16 Aug 2011 16:35:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110816083511.GA19970@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.733282037@intel.com>
 <1312811193.10488.33.camel@twins>
 <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1312910427.1083.68.camel@twins>
 <20110810223427.GA18227@quack.suse.cz>
 <20110811022952.GA11404@localhost>
 <20110811111423.GD4755@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110811111423.GD4755@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Aug 11, 2011 at 07:14:23PM +0800, Jan Kara wrote:
> On Thu 11-08-11 10:29:52, Wu Fengguang wrote:
> > On Thu, Aug 11, 2011 at 06:34:27AM +0800, Jan Kara wrote:
> > > On Tue 09-08-11 19:20:27, Peter Zijlstra wrote:
> > > > On Tue, 2011-08-09 at 12:32 +0200, Peter Zijlstra wrote:
> > > > > >                     origin - dirty
> > > > > >         pos_ratio = --------------
> > > > > >                     origin - goal 
> > > > > 
> > > > > > which comes from the below [*] control line, so that when (dirty == goal),
> > > > > > pos_ratio == 1.0:
> > > > > 
> > > > > OK, so basically you want a linear function for which:
> > > > > 
> > > > > f(goal) = 1 and has a root somewhere > goal.
> > > > > 
> > > > > (that one line is much more informative than all your graphs put
> > > > > together, one can start from there and derive your function)
> > > > > 
> > > > > That does indeed get you the above function, now what does it mean? 
> > > > 
> > > > So going by:
> > > > 
> > > >                                          write_bw
> > > >   ref_bw = dirty_ratelimit * pos_ratio * --------
> > > >                                          dirty_bw
> > > 
> > >   Actually, thinking about these formulas, why do we even bother with
> > > computing all these factors like write_bw, dirty_bw, pos_ratio, ...
> > > Couldn't we just have a feedback loop (probably similar to the one
> > > computing pos_ratio) which will maintain single value - ratelimit? When we
> > > are getting close to dirty limit, we will scale ratelimit down, when we
> > > will be getting significantly below dirty limit, we will scale the
> > > ratelimit up.  Because looking at the formulas it seems to me that the net
> > > effect is the same - pos_ratio basically overrules everything... 
> > 
> > Good question. That is actually one of the early approaches I tried.
> > It somehow worked, however the resulted ratelimit is not only slow
> > responding, but also oscillating all the time.
>   Yes, I think I vaguely remember that.
> 
> > This is due to the imperfections
> > 
> > 1) pos_ratio at best only provides a "direction" for adjusting the
> >    ratelimit. There is only vague clues that if pos_ratio is small,
> >    the errors in ratelimit should be small.
> > 
> > 2) Due to time-lag, the assumptions in (1) about "direction" and
> >    "error size" can be wrong. The ratelimit may already be
> >    over-adjusted when the dirty pages take time to approach the
> >    setpoint. The larger memory, the more time lag, the easier to
> >    overshoot and oscillate.
> > 
> > 3) dirty pages are constantly fluctuating around the setpoint,
> >    so is pos_ratio.
> > 
> > With (1) and (2), it's a control system very susceptible to disturbs.
> > With (3) we get constant disturbs. Well I had very hard time and
> > played dirty tricks (which you may never want to know ;-) trying to
> > tradeoff between response time and stableness..
>   Yes, I can see especially 2) is a problem. But I don't understand why
> your current formula would be that much different. As Peter decoded from
> your code, your current formula is:
>                                         write_bw
>  ref_bw = dirty_ratelimit * pos_ratio * --------
>                                         dirty_bw
> 
> while previously it was essentially:
>  ref_bw = dirty_ratelimit * pos_ratio

Sorry what's the code you are referring to? Does the changelog in the
newly posted patchset make the ref_bw calculation and dirty_ratelimit
updating more clear?

> So what is so magical about computing write_bw and dirty_bw separately? Is
> it because previously you did not use derivation of distance from the goal
> for updating pos_ratio? Because in your current formula write_bw/dirty_bw
> is a derivation of position...

dirty_bw is the main feedback. If we are throttling too much, the
resulting dirty_bw will be lowered than write_bw. Thus 

                                      write_bw
   ref_bw = ratelimit_in_past_200ms * --------
                                      dirty_bw

will give us a higher ref_bw than ratelimit_in_past_200ms. For pure
dd workload, the computed ref_bw by the above formula is exactly the
balanced rate (if not considering trivial errors).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

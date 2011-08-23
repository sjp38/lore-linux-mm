Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8A1DE6B0171
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 14:09:18 -0400 (EDT)
Date: Tue, 23 Aug 2011 13:47:57 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110823174757.GC15820@redhat.com>
References: <1312811193.10488.33.camel@twins>
 <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1313154259.6576.42.camel@twins>
 <20110812142020.GB17781@localhost>
 <1314027488.24275.74.camel@twins>
 <20110823034042.GC7332@localhost>
 <1314093660.8002.24.camel@twins>
 <20110823141504.GA15949@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110823141504.GA15949@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 23, 2011 at 10:15:04PM +0800, Wu Fengguang wrote:
> On Tue, Aug 23, 2011 at 06:01:00PM +0800, Peter Zijlstra wrote:
> > On Tue, 2011-08-23 at 11:40 +0800, Wu Fengguang wrote:
> > > - not a factor at all for updating balanced_rate (whether or not we do (2))
> > >   well, in this concept: the balanced_rate formula inherently does not
> > >   derive the balanced_rate_(i+1) from balanced_rate_i. Rather it's
> > >   based on the ratelimit executed for the past 200ms:
> > > 
> > >           balanced_rate_(i+1) = task_ratelimit_200ms * bw_ratio
> > 
> > Ok, this is where it all goes funny..
> > 
> > So if you want completely separated feedback loops I would expect
> 
> If call it feedback loops, then it's a series of independent feedback
> loops of depth 1.  Because each balanced_rate is a fresh estimation
> dependent solely on
> 
> - writeout bandwidth
> - N, the number of dd tasks
> 
> in the past 200ms.
> 
> As long as a CONSTANT ratelimit (whatever value it is) is executed in
> the past 200ms, we can get the same balanced_rate.
> 
>         balanced_rate = CONSTANT_ratelimit * write_bw / dirty_rate
> 
> The resulted balanced_rate is independent of how large the CONSTANT
> ratelimit is, because if we start with a doubled CONSTANT ratelimit,
> we'll see doubled dirty_rate and result in the same balanced_rate. 
> 
> In that manner, balance_rate_(i+1) is not really depending on the
> value of balance_rate_(i): whatever balance_rate_(i) is, we are going
> to get the same balance_rate_(i+1) if not considering estimation
> errors. Note that the estimation errors mainly come from the
> fluctuations in dirty_rate.
> 
> That may well be what's already in your mind, just that we disagree
> about the terms ;)
> 
> > something like:
> > 
> > 	balance_rate_(i+1) = balance_rate_(i) * bw_ratio   ; every 200ms
> > 
> > The former is a complete feedback loop, expressing the new value in the
> > old value (*) with bw_ratio as feedback parameter; if we throttled too
> > much, the dirty_rate will have dropped and the bw_ratio will be <1
> > causing the balance_rate to drop increasing the dirty_rate, and vice
> > versa.
> 
> In principle, the bw_ratio works that way. However since
> balance_rate_(i) is not the exact _executed_ ratelimit in
> balance_dirty_pages().
> 
> > (*) which is the form I expected and why I thought your primary feedback
> > loop looked like: rate_(i+1) = rate_(i) * pos_ratio * bw_ratio
>  
> Because the executed ratelimit was rate_(i) * pos_ratio.
> 
> > With the above balance_rate is an independent variable that tracks the
> > write bandwidth. Now possibly you'd want a low-pass filter on that since
> > your bw_ratio is a bit funny in the head, but that's another story.
> 
> Yeah.
> 
> > Then when you use the balance_rate to actually throttle tasks you apply
> > your secondary control steering the dirty page count, yielding:
> > 
> > 	task_rate = balance_rate * pos_ratio
> 
> Right. Note the above formula is not a derived one, but an original
> one that later leads to pos_ratio showing up in the calculation of
> balanced_rate.
> 
> > >   and task_ratelimit_200ms happen to can be estimated from
> > > 
> > >           task_ratelimit_200ms ~= balanced_rate_i * pos_ratio
> > 
> > >   We may alternatively record every task_ratelimit executed in the
> > >   past 200ms and average them all to get task_ratelimit_200ms. In this
> > >   way we take the "superfluous" pos_ratio out of sight :) 
> > 
> > Right, so I'm not at all sure that makes sense, its not immediately
> > evident that <task_ratelimit> ~= balance_rate * pos_ratio. Nor is it
> > clear to me why your primary feedback loop uses task_ratelimit_200ms at
> > all. 
> 
> task_ratelimit is used and hence defined to be (balance_rate * pos_ratio)
> by balance_dirty_pages(). So this is an original formula:
> 
>         task_ratelimit = balance_rate * pos_ratio
> 
> task_ratelimit_200ms is also used as an original data source in
> 
>         balanced_rate = task_ratelimit_200ms * write_bw / dirty_rate
> 

I think above calculates to.

 task_ratelimit = balanced_rate * pos_ratio
or
 task_ratelimit = task_ratelimit_200ms * write_bw / dirty_rate * pos_ratio
or
 task_ratelimit = balance_rate * pos_ratio  * write_bw / dirty_rate * pos_ratio
or
								    2
 task_ratelimit = balance_rate * write_bw / dirty_rate * (pos_ratio)

And the question is why not.

 task_ratelimit = prev-balance_rate * write_bw / dirty_rate * pos_ratio

Which sounds intutive as comapred to former one.

You somehow directly jump to  

	balanced_rate = task_ratelimit_200ms * write_bw / dirty_rate

without explaining why following will not work.

	balanced_rate_(i+1) = balance_rate(i) * write_bw / dirty_rate

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

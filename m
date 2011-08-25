Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8447B6B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 01:30:12 -0400 (EDT)
Date: Thu, 25 Aug 2011 13:30:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110825053007.GA8220@localhost>
References: <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1313154259.6576.42.camel@twins>
 <20110812142020.GB17781@localhost>
 <1314027488.24275.74.camel@twins>
 <20110823034042.GC7332@localhost>
 <1314093660.8002.24.camel@twins>
 <20110823141504.GA15949@localhost>
 <1314201460.6925.44.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314201460.6925.44.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 24, 2011 at 11:57:39PM +0800, Peter Zijlstra wrote:
> On Tue, 2011-08-23 at 22:15 +0800, Wu Fengguang wrote:
> > On Tue, Aug 23, 2011 at 06:01:00PM +0800, Peter Zijlstra wrote:
> > > On Tue, 2011-08-23 at 11:40 +0800, Wu Fengguang wrote:
> > > > - not a factor at all for updating balanced_rate (whether or not we do (2))
> > > >   well, in this concept: the balanced_rate formula inherently does not
> > > >   derive the balanced_rate_(i+1) from balanced_rate_i. Rather it's
> > > >   based on the ratelimit executed for the past 200ms:
> > > > 
> > > >           balanced_rate_(i+1) = task_ratelimit_200ms * bw_ratio
> > > 
> > > Ok, this is where it all goes funny..
> > > 
> > > So if you want completely separated feedback loops I would expect
> > 
> > If call it feedback loops, then it's a series of independent feedback
> > loops of depth 1.  Because each balanced_rate is a fresh estimation
> > dependent solely on
> > 
> > - writeout bandwidth
> > - N, the number of dd tasks
> > 
> > in the past 200ms.
> > 
> > As long as a CONSTANT ratelimit (whatever value it is) is executed in
> > the past 200ms, we can get the same balanced_rate.
> > 
> >         balanced_rate = CONSTANT_ratelimit * write_bw / dirty_rate
> > 
> > The resulted balanced_rate is independent of how large the CONSTANT
> > ratelimit is, because if we start with a doubled CONSTANT ratelimit,
> > we'll see doubled dirty_rate and result in the same balanced_rate. 
> > 
> > In that manner, balance_rate_(i+1) is not really depending on the
> > value of balance_rate_(i): whatever balance_rate_(i) is, we are going
> > to get the same balance_rate_(i+1) 
> 
> At best this argument says it doesn't matter what we use, making
> balance_rate_i an equally valid choice. However I don't buy this, your
> argument is broken, your CONSTANT_ratelimit breaks feedback but then you
> rely on the iterative form of feedback to finish your argument.
> 
> Consider:
> 
> 	r_(i+1) = r_i * ratio_i
> 
> you say, r_i := C for all i, then by definition ratio_i must be 1 and
> you've got nothing. The only way your conclusion can be right is by
> allowing the proper iteration, otherwise we'll never reach the
> equilibrium.
> 
> Now it is true you can introduce random perturbations in r_i at any
> given point and still end up in equilibrium, such is the power of
> iterative feedback, but that doesn't say you can do away with r_i. 

Sure there are always r_i.

Sorry what I mean CONSTANT_ratelimit is, it remains CONSTANT _inside_
every 200ms. There will be a series of different CONSTANT values for
each 200ms, which is roughly (r_i * pos_ratio_i).

> > > something like:
> > > 
> > > 	balance_rate_(i+1) = balance_rate_(i) * bw_ratio   ; every 200ms
> > > 
> > > The former is a complete feedback loop, expressing the new value in the
> > > old value (*) with bw_ratio as feedback parameter; if we throttled too
> > > much, the dirty_rate will have dropped and the bw_ratio will be <1
> > > causing the balance_rate to drop increasing the dirty_rate, and vice
> > > versa.
> > 
> > In principle, the bw_ratio works that way. However since
> > balance_rate_(i) is not the exact _executed_ ratelimit in
> > balance_dirty_pages().
> 
> This seems to be where your argument goes bad, the actually executed
> ratelimit is not important, the variance introduced by pos_ratio is
> purely for the benefit of the dirty page count. 
> 
> It doesn't matter for the balance_rate. Without pos_ratio, the dirty
> page count would stay stable (ignoring all these oscillations and other
> fun things), and therefore it is the balance_rate we should be using for
> the iterative feedback.

Nope. The dirty page count can always stay stable somewhere (but not
necessarily at setpoint) purely by the pos_ratio feedback, as illustrated
by Vivek's example.

But that's not the balance state we want. Although the pos_ratio
feedback all by itself is strong enough to keep (dirty_rate == write_bw),
the ideal state is to achieve pos_ratio=1 and eliminate its feedback
error as much as possible, so as to get smooth task_ratelimit.

We may take this viewpoint: a "successful" balance_rate should help
keep pos_ratio around 1.0 in long term.

> > > (*) which is the form I expected and why I thought your primary feedback
> > > loop looked like: rate_(i+1) = rate_(i) * pos_ratio * bw_ratio
> >  
> > Because the executed ratelimit was rate_(i) * pos_ratio.
> 
> No, because iterative feedback has the form: 
> 
> 	new = old $op $feedback-term
> 

The problem is, the pos_ratio feedback will jump in and prematurely make
$feedback-term = 1, thus rendering the pure rate feedback weak/useless.

> > > Then when you use the balance_rate to actually throttle tasks you apply
> > > your secondary control steering the dirty page count, yielding:
> > > 
> > > 	task_rate = balance_rate * pos_ratio
> > 
> > Right. Note the above formula is not a derived one, 
> 
> Agreed, its not a derived expression but the originator of the dirty
> page count control.
> 
> > but an original
> > one that later leads to pos_ratio showing up in the calculation of
> > balanced_rate.
> 
> That's where I disagree :-)
> 
> > > >   and task_ratelimit_200ms happen to can be estimated from
> > > > 
> > > >           task_ratelimit_200ms ~= balanced_rate_i * pos_ratio
> > > 
> > > >   We may alternatively record every task_ratelimit executed in the
> > > >   past 200ms and average them all to get task_ratelimit_200ms. In this
> > > >   way we take the "superfluous" pos_ratio out of sight :) 
> > > 
> > > Right, so I'm not at all sure that makes sense, its not immediately
> > > evident that <task_ratelimit> ~= balance_rate * pos_ratio. Nor is it
> > > clear to me why your primary feedback loop uses task_ratelimit_200ms at
> > > all. 
> > 
> > task_ratelimit is used and hence defined to be (balance_rate * pos_ratio)
> > by balance_dirty_pages(). So this is an original formula:
> > 
> >         task_ratelimit = balance_rate * pos_ratio
> > 
> > task_ratelimit_200ms is also used as an original data source in
> > 
> >         balanced_rate = task_ratelimit_200ms * write_bw / dirty_rate
> 
> But that's exactly where you conflate the positional feedback with the
> throughput feedback, the effective ratelimit includes the positional
> feedback so that the dirty page count can move around, but that is
> completely orthogonal to the throughput feedback since the throughout
> thing would leave the dirty count constant (ideal case again).
> 
> That is, yes the iterative feedback still works because you still got
> your primary feedback in place, but the addition of pos_ratio in the
> feedback loop is a pure perturbation and doesn't matter one whit.

The problem is that pure rate feedback is not possible because
pos_ratio also takes part in altering the task rate...

> > Then we try to estimate task_ratelimit_200ms by assuming all tasks
> > have been executing the same CONSTANT ratelimit in
> > balance_dirty_pages(). Hence we get
> > 
> >         task_ratelimit_200ms ~= prev_balance_rate * pos_ratio
> 
> But this just cannot be true (and, as argued above, is completely
> unnecessary). 
> 
> Consider the case where the dirty count is way below the setpoint but
> the base ratelimit is pretty accurate. In that case we would start out
> by creating very low task ratelimits such that the dirty count can

s/low/high/

> increase. Once we match the setpoint we go back to the base ratelimit.
> The average over those 200ms would be <1, but since we're right at the
> setpoint when we do the base ratelimit feedback we pick exactly 1. 

Yeah that's the kind of error introduced by the CONSTANT ratelimit.
Which could be pretty large in small memory boxes. Given that
pos_ratio will fluctuate more anyway when memory and hence the
dirty control scope is small, such rate estimation errors are tolerable.

> Anyway, its completely irrelevant.. :-)

Yeah, that's one step further to discuss all kinds of possible errors
on top of the basic theory :)

> > > >   There is fundamentally no dependency between balanced_rate_(i+1) and
> > > >   balanced_rate_i/task_ratelimit_200ms: the balanced_rate estimation
> > > >   only asks for _whatever_ CONSTANT task ratelimit to be executed for
> > > >   200ms, then it get the balanced rate from the dirty_rate feedback.
> > > 
> > > How can there not be a relation between balance_rate_(i+1) and
> > > balance_rate_(i) ? 
> > 
> > In this manner: even though balance_rate_(i) is somehow used for
> > calculating balance_rate_(i+1), the latter will evaluate to the same
> > value given whatever balance_rate_(i).
> 
> But only if you allow for the iterative feedback to work, you absolutely
> need that balance_rate_(i), without that its completely broken.

Agreed.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

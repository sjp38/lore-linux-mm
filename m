Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 986F56B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 23:40:48 -0400 (EDT)
Date: Tue, 23 Aug 2011 11:40:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110823034042.GC7332@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.733282037@intel.com>
 <1312811193.10488.33.camel@twins>
 <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1313154259.6576.42.camel@twins>
 <20110812142020.GB17781@localhost>
 <1314027488.24275.74.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314027488.24275.74.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 22, 2011 at 11:38:07PM +0800, Peter Zijlstra wrote:
> On Fri, 2011-08-12 at 22:20 +0800, Wu Fengguang wrote:
> > On Fri, Aug 12, 2011 at 09:04:19PM +0800, Peter Zijlstra wrote:
> > > On Tue, 2011-08-09 at 19:20 +0200, Peter Zijlstra wrote:
> > 
> > To start with,
> > 
> >                                                 write_bw
> >         ref_bw = task_ratelimit_in_past_200ms * --------
> >                                                 dirty_bw
> > 
> > where
> >         task_ratelimit_in_past_200ms ~= dirty_ratelimit * pos_ratio
> > 
> > > > Now all of the above would seem to suggest:
> > > > 
> > > >   dirty_ratelimit := ref_bw
> > 
> > Right, ideally ref_bw is the balanced dirty ratelimit. I actually
> > started with exactly the above equation when I got choked by pure
> > pos_bw based feedback control (as mentioned in the reply to Jan's
> > email) and introduced the ref_bw estimation as the way out.
> > 
> > But there are some imperfections in ref_bw, too. Which makes it not
> > suitable for direct use:
> > 
> > 1) large fluctuations
> 
> OK, understood.
> 
> > 2) due to truncates and fs redirties, the (write_bw <=> dirty_bw)
> > becomes unbalanced match, which leads to large systematical errors
> > in ref_bw. The truncates, due to its possibly bumpy nature, can hardly
> > be compensated smoothly.
> 
> OK.
> 
> > 3) since we ultimately want to
> > 
> > - keep the dirty pages around the setpoint as long time as possible
> > - keep the fluctuations of task ratelimit as small as possible
> 
> Fair enough ;-)
> 
> > the update policy used for (2) also serves the above goals nicely:
> > if for some reason the dirty pages are high (pos_bw < dirty_ratelimit),
> > and dirty_ratelimit is low (dirty_ratelimit < ref_bw), there is no
> > point to bring up dirty_ratelimit in a hurry and to hurt both the
> > above two goals.
> 
> Right, so still I feel somewhat befuddled, so we have:
> 
> 	dirty_ratelimit - rate at which we throttle dirtiers as
> 			  estimated upto 200ms ago.

Note that bdi->dirty_ratelimit is supposed to be the balanced
ratelimit, ie. (write_bw / N), regardless whether dirty pages meets
the setpoint.

In _concept_, the bdi balanced ratelimit is updated _independent_ of
the position control embodied in the task ratelimit calculation.

A lot of confusions seem to come from the seemingly inter-twisted rate
and position controls, however in my mind, there are two levels of
relationship:

1) work fundamentally independent of each other, each tries to fulfill
   one single target (either balanced rate or balanced position)

2) _based_ on (1), completely optional, try to constraint the rate update 
   to get more stable ->dirty_ratelimit and more balanced dirty position

Note that (2) is not a must even if there are systematic errors in
balanced_rate calculation. For example, the v8 patchset only does (1)
and hence do simple

        bdi->dirty_ratelimit = balanced_rate;

And it can still balance at some point (though not exactly around the setpoint):

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v8/3G-bs=1M/ext4-1dd-1M-8p-2942M-20:10-3.0.0-next-20110802+-2011-08-08.19:47/balance_dirty_pages-pages.png

Even if ext4 has mis-matched (dirty_rate:write_bw ~= 3:2) hence
introduced systematic errors in balanced_rate:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v8/3G-bs=1M/ext4-1dd-1M-8p-2942M-20:10-3.0.0-next-20110802+-2011-08-08.19:47/global_dirtied_written.png

> 	pos_ratio	- ratio adjusting the dirty_ratelimit
> 			  for variance in dirty pages around its target

So pos_ratio is

- is a _limiting_ factor rather than an _adjusting_ factor for
  updating ->dirty_ratelimit (when do (2))

- not a factor at all for updating balanced_rate (whether or not we do (2))
  well, in this concept: the balanced_rate formula inherently does not
  derive the balanced_rate_(i+1) from balanced_rate_i. Rather it's
  based on the ratelimit executed for the past 200ms:

          balanced_rate_(i+1) = task_ratelimit_200ms * bw_ratio

  and task_ratelimit_200ms happen to can be estimated from

          task_ratelimit_200ms ~= balanced_rate_i * pos_ratio

  There is fundamentally no dependency between balanced_rate_(i+1) and
  balanced_rate_i/task_ratelimit_200ms: the balanced_rate estimation
  only asks for _whatever_ CONSTANT task ratelimit to be executed for
  200ms, then it get the balanced rate from the dirty_rate feedback.

  We may alternatively record every task_ratelimit executed in the
  past 200ms and average them all to get task_ratelimit_200ms. In this
  way we take the "superfluous" pos_ratio out of sight :)

> 	bw_ratio	- ratio adjusting the dirty_ratelimit
> 			  for variance in input/output bandwidth
> 
> and we need to basically do:
> 
> 	dirty_ratelimit *= pos_ratio * bw_ratio

So there is even no such recursing at all:

        balanced_rate *= bw_ratio

Each balanced_rate is estimated from the start, based on each 200ms period.

> to update the dirty_ratelimit to reflect the current state. However per
> 1) and 2) bw_ratio is crappy and hard to fix.
> 
> So you propose to update dirty_ratelimit only if both pos_ratio and
> bw_ratio point in the same direction, however that would result in:
> 
>   if (pos_ratio < UNIT && bw_ratio < UNIT ||
>       pos_ratio > UNIT && bw_ratio > UNIT) {
> 	dirty_ratelimit = (dirty_ratelimit * pos_ratio) / UNIT;
> 	dirty_ratelimit = (dirty_ratelimit * bw_ratio) / UNIT;
>   }

We start by doing this for (1):

        dirty_ratelimit = balanced_rate

and then try to refine it for (1)+(2):

        dirty_ratelimit => balanced_rate, but limit the progress by pos_ratio

> > > > However for that you use:
> > > > 
> > > >   if (pos_bw < dirty_ratelimit && ref_bw < dirty_ratelimit)
> > > >         dirty_ratelimit = max(ref_bw, pos_bw);
> > > > 
> > > >   if (pos_bw > dirty_ratelimit && ref_bw > dirty_ratelimit)
> > > >         dirty_ratelimit = min(ref_bw, pos_bw);
> > 
> > The above are merely constraints to the dirty_ratelimit update.
> > It serves to
> > 
> > 1) stop adjusting the rate when it's against the position control
> >    target (the adjusted rate will slow down the progress of dirty
> >    pages going back to setpoint).
> 
> Not strictly speaking, suppose pos_ratio = 0.5 and bw_ratio = 1.1, then
> they point in different directions however:
> 
>  0.5 < 1 &&  0.5 * 1.1 < 1
> 
> so your code will in fact update the dirty_ratelimit, even though the
> two factors point in opposite directions.

It does not work that way since pos_ratio does not take part in the
multiplication. However I admit that the tests

        (pos_bw < dirty_ratelimit && ref_bw < dirty_ratelimit)
        (pos_bw > dirty_ratelimit && ref_bw > dirty_ratelimit)

don't aim to avoid all unnecessary updates, and it may even stop some
rightful updates. It's not possible at all to act perfect. It's merely
a rule that sounds "reasonable" in theory and works reasonably good in
practice :) I'd be happy to try more if there are better ones.

> > 2) limit the step size. pos_bw is changing values step by step,
> >    leaving a consistent trace comparing to the randomly jumping
> >    ref_bw. pos_bw also has smaller errors in stable state and normally
> >    have larger errors when there are big errors in rate. So it's a
> >    pretty good limiting factor for the step size of dirty_ratelimit.
> 
> OK, so that's the min/max stuff, however it only works because you use
> pos_bw and ref_bw instead of the fully separated factors.

Yes, the min/max stuff is for limiting the step size. The "limiting"
intention can be made more clear if written as

        delta = balanced_rate - base_rate;

        if (delta > pos_rate - base_rate)
            delta = pos_rate - base_rate;

        delta /= 8;

> > Hope the above elaboration helps :)
> 
> A little.. 

And now? ;)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

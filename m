Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6A1416B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 22:44:00 -0400 (EDT)
Date: Fri, 12 Aug 2011 10:43:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110812024353.GA11606@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094526.733282037@intel.com>
 <1312811193.10488.33.camel@twins>
 <20110808141128.GA22080@localhost>
 <1312814501.10488.41.camel@twins>
 <20110808230535.GC7176@localhost>
 <1313103367.26866.39.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313103367.26866.39.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 12, 2011 at 06:56:06AM +0800, Peter Zijlstra wrote:
> On Tue, 2011-08-09 at 19:20 +0200, Peter Zijlstra wrote:
> > So going by:
> > 
> >                                          write_bw
> >   ref_bw = dirty_ratelimit * pos_ratio * --------
> >                                          dirty_bw
> > 
> > pos_ratio seems to be the feedback on the deviation of the dirty pages
> > around its setpoint. So we adjust the reference bw (or rather ratelimit)
> > to take account of the shift in output vs input capacity as well as the
> > shift in dirty pages around its setpoint.
> > 
> > From that we derive the condition that: 
> > 
> >   pos_ratio(setpoint) := 1
> > 
> > Now in order to create a linear function we need one more condition. We
> > get one from the fact that once we hit the limit we should hard throttle
> > our writers. We get that by setting the ratelimit to 0, because, after
> > all, pause = nr_dirtied / ratelimit would yield inf. in that case. Thus:
> > 
> >   pos_ratio(limit) := 0
> > 
> > Using these two conditions we can solve the equations and get your:
> > 
> >                         limit - dirty
> >   pos_ratio(dirty) =  ----------------
> >                       limit - setpoint
> > 
> > Now, for some reason you chose not to use limit, but something like
> > min(limit, 4*thresh) something to do with the slope affecting the rate
> > of adjustment. This wants a comment someplace. 
> 
> Ok, so I think that pos_ratio(limit) := 0, is a stronger condition than
> your negative slope (df/dx < 0), simply because it implies your
> condition and because it expresses our hard stop at limit.

Right. That's good point.

> Also, while I know this is totally over the top, but..
> 
> I saw you added a ramp and brake area in future patches, so have you
> considered using a third order polynomial instead?

No I have not ;)

The 3 lines/curves should be a bit more flexible/configurable than the
single 3rd order polynomial.  However the 3rd order polynomial is sure
much more simple and consistent by removing the explicit rampup/brake
areas and curves.

> The simple:
> 
>  f(x) = -x^3 
> 
> has the 'right' shape, all we need is move it so that:
> 
>  f(s) = 1
> 
> and stretch it to put the single root at our limit. You'd get something
> like:
> 
>                s - x 3
>  f(x) :=  1 + (-----)
>                  d
> 
> Which, as required, is 1 at our setpoint and the factor d stretches the
> middle bit. Which has a single (real) root at: 
> 
>   x = s + d, 
> 
> by setting that to our limit, we get:
> 
>   d = l - s
> 
> Making our final function look like:
> 
>                s - x 3
>  f(x) :=  1 + (-----)
>                l - s

Very intuitive reasoning, thanks!

I substituted real numbers to the function assuming a mem=2GB system.

with limit=thresh:

        gnuplot> set xrange [60000:80000]
        gnuplot> plot 1 +  (70000.0 - x)**3/(80000-70000.0)**3

with limit=thresh+thresh/DIRTY_SCOPE

        gnuplot> set xrange [60000:90000]
        gnuplot> plot 1 +  (70000.0 - x)**3/(90000-70000.0)**3

Figures attached.  The latter produces reasonably flat slope and I'll
give it a spin in the dd tests :)
 
> You can clamp it at [0,2] or so.

Looking at the figures, we may even do without the clamp because it's
already inside the range [0, 2].

> The implementation wouldn't be too horrid either, something like:
> 
> unsigned long bdi_pos_ratio(..)
> {
> 	if (dirty > limit)
> 		return 0;
> 
> 	if (dirty < 2*setpoint - limit)
> 		return 2 * SCALE;
> 
> 	x = SCALE * (setpoint - dirty) / (limit - setpoint);
> 	xx = (x * x) / SCALE;
> 	xxx = (xx * x) / SCALE;
> 
> 	return xxx;
> }

Looks very neat, much simpler than the three curves solution!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

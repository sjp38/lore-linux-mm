Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB03900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 16:24:19 -0400 (EDT)
Date: Wed, 17 Aug 2011 22:24:14 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110817202414.GK9959@quack.suse.cz>
References: <20110816022006.348714319@intel.com>
 <20110816022328.811348370@intel.com>
 <20110816194112.GA25517@quack.suse.cz>
 <20110817132347.GA6628@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110817132347.GA6628@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

  Hi Fengguang,

On Wed 17-08-11 21:23:47, Wu Fengguang wrote:
> On Wed, Aug 17, 2011 at 03:41:12AM +0800, Jan Kara wrote:
> > > +static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
> > > +					unsigned long thresh,
> > > +					unsigned long bg_thresh,
> > > +					unsigned long dirty,
> > > +					unsigned long bdi_thresh,
> > > +					unsigned long bdi_dirty)
> > > +{
> > > +	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
> > > +	unsigned long limit = hard_dirty_limit(thresh);
> > > +	unsigned long x_intercept;
> > > +	unsigned long setpoint;		/* the target balance point */
> > > +	unsigned long span;
> > > +	long long pos_ratio;		/* for scaling up/down the rate limit */
> > > +	long x;
> > > +
> > > +	if (unlikely(dirty >= limit))
> > > +		return 0;
> > > +
> > > +	/*
> > > +	 * global setpoint
> > > +	 *
> > > +	 *                         setpoint - dirty 3
> > > +	 *        f(dirty) := 1 + (----------------)
> > > +	 *                         limit - setpoint
> > > +	 *
> > > +	 * it's a 3rd order polynomial that subjects to
> > > +	 *
> > > +	 * (1) f(freerun)  = 2.0 => rampup base_rate reasonably fast
> > > +	 * (2) f(setpoint) = 1.0 => the balance point
> > > +	 * (3) f(limit)    = 0   => the hard limit
> > > +	 * (4) df/dx       < 0	 => negative feedback control
                          ^^^ Strictly speaking this is <= 0

> > > +	 * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
> > > +	 *     => fast response on large errors; small oscillation near setpoint
> > > +	 */
> > > +	setpoint = (freerun + limit) / 2;
> > > +	x = div_s64((setpoint - dirty) << RATELIMIT_CALC_SHIFT,
> > > +		    limit - setpoint + 1);
> > > +	pos_ratio = x;
> > > +	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> > > +	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> > > +	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
> > > +
> > > +	/*
> > > +	 * bdi setpoint
  OK, so if I understand the code right, we now have basic pos_ratio based
on global situation. Now, in the following code, we might scale pos_ratio
further down, if bdi_dirty is too much over bdi's share, right? Do we also
want to scale pos_ratio up, if we are under bdi's share? If yes, do we
really want to do it even if global pos_ratio < 1 (i.e. we are over global
setpoint)?

Maybe we could update the comment with something like:
 * We have computed basic pos_ratio above based on global situation. If the
 * bdi is over its share of dirty pages, we want to scale pos_ratio further
 * down. That is done by the following mechanism:
and now describe how updating works.

> > > +	 *
> > > +	 *        f(dirty) := 1.0 + k * (dirty - setpoint)
                  ^^^^^^^ bdi_dirty?             ^^^ maybe I'd name it
bdi_setpoint to distinguish clearly from the global value.

> > > +	 *
> > > +	 * The main bdi control line is a linear function that subjects to
> > > +	 *
> > > +	 * (1) f(setpoint) = 1.0
> > > +	 * (2) k = - 1 / (8 * write_bw)  (in single bdi case)
> > > +	 *     or equally: x_intercept = setpoint + 8 * write_bw
> > > +	 *
> > > +	 * For single bdi case, the dirty pages are observed to fluctuate
> > > +	 * regularly within range
> > > +	 *        [setpoint - write_bw/2, setpoint + write_bw/2]
> > > +	 * for various filesystems, where (2) can yield in a reasonable 12.5%
> > > +	 * fluctuation range for pos_ratio.
> > > +	 *
> > > +	 * For JBOD case, bdi_thresh (not bdi_dirty!) could fluctuate up to its
> > > +	 * own size, so move the slope over accordingly.
> > > +	 */
> > > +	if (unlikely(bdi_thresh > thresh))
> > > +		bdi_thresh = thresh;
> > > +	/*
> > > +	 * scale global setpoint to bdi's:  setpoint *= bdi_thresh / thresh
> > > +	 */
> > > +	x = div_u64((u64)bdi_thresh << 16, thresh | 1);
> > > +	setpoint = setpoint * (u64)x >> 16;
> > > +	/*
> > > +	 * Use span=(4*write_bw) in single bdi case as indicated by
> > > +	 * (thresh - bdi_thresh ~= 0) and transit to bdi_thresh in JBOD case.
> > > +	 */
> > > +	span = div_u64((u64)bdi_thresh * (thresh - bdi_thresh) +
> > > +		       (u64)(4 * bdi->avg_write_bandwidth) * bdi_thresh,
> > > +		       thresh + 1);
> >   I think you can slightly simplify this to:
> > (thresh - bdi_thresh + 4 * bdi->avg_write_bandwidth) * (u64)x >> 16;
> 
> Good idea!
> 
> > > +	x_intercept = setpoint + 2 * span;
   ^^ BTW, why do you have 2*span here? It can result in x_intercept being
~3*bdi_thresh... So maybe you should use bdi_thresh/2 in the computation of
span?

> >   What if x_intercept >  bdi_thresh? Since 8*bdi->avg_write_bandwidth is
> > easily 500 MB, that happens quite often I imagine?
> 
> That's fine because I no longer target "bdi_thresh" as some limiting
> factor as the global "thresh". Due to it being unstable in small
> memory JBOD systems, which is the big and unique problem in JBOD.
  I see. Given the control mechanism below, I think we can try this idea
and see whether it makes problems in practice or not. But the fact that
bdi_thresh is no longer treated as limit should be noted in a changelog -
probably of the last patch (although that is already too long for my taste
so I'll look into how we could make it shorter so that average developer
has enough patience to read it ;).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

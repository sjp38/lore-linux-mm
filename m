Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 38E116B016B
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 15:41:21 -0400 (EDT)
Date: Tue, 16 Aug 2011 21:41:12 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110816194112.GA25517@quack.suse.cz>
References: <20110816022006.348714319@intel.com>
 <20110816022328.811348370@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110816022328.811348370@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

  Hello Fengguang,

  this patch is much easier to read than in older versions! Good work!

> +static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
> +					unsigned long thresh,
> +					unsigned long bg_thresh,
> +					unsigned long dirty,
> +					unsigned long bdi_thresh,
> +					unsigned long bdi_dirty)
> +{
> +	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
> +	unsigned long limit = hard_dirty_limit(thresh);
> +	unsigned long x_intercept;
> +	unsigned long setpoint;		/* the target balance point */
> +	unsigned long span;
> +	long long pos_ratio;		/* for scaling up/down the rate limit */
> +	long x;
> +
> +	if (unlikely(dirty >= limit))
> +		return 0;
> +
> +	/*
> +	 * global setpoint
> +	 *
> +	 *                         setpoint - dirty 3
> +	 *        f(dirty) := 1 + (----------------)
> +	 *                         limit - setpoint
> +	 *
> +	 * it's a 3rd order polynomial that subjects to
> +	 *
> +	 * (1) f(freerun)  = 2.0 => rampup base_rate reasonably fast
> +	 * (2) f(setpoint) = 1.0 => the balance point
> +	 * (3) f(limit)    = 0   => the hard limit
> +	 * (4) df/dx       < 0	 => negative feedback control
> +	 * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
> +	 *     => fast response on large errors; small oscillation near setpoint
> +	 */
> +	setpoint = (freerun + limit) / 2;
> +	x = div_s64((setpoint - dirty) << RATELIMIT_CALC_SHIFT,
> +		    limit - setpoint + 1);
> +	pos_ratio = x;
> +	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> +	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> +	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
> +
> +	/*
> +	 * bdi setpoint
> +	 *
> +	 *        f(dirty) := 1.0 + k * (dirty - setpoint)
> +	 *
> +	 * The main bdi control line is a linear function that subjects to
> +	 *
> +	 * (1) f(setpoint) = 1.0
> +	 * (2) k = - 1 / (8 * write_bw)  (in single bdi case)
> +	 *     or equally: x_intercept = setpoint + 8 * write_bw
> +	 *
> +	 * For single bdi case, the dirty pages are observed to fluctuate
> +	 * regularly within range
> +	 *        [setpoint - write_bw/2, setpoint + write_bw/2]
> +	 * for various filesystems, where (2) can yield in a reasonable 12.5%
> +	 * fluctuation range for pos_ratio.
> +	 *
> +	 * For JBOD case, bdi_thresh (not bdi_dirty!) could fluctuate up to its
> +	 * own size, so move the slope over accordingly.
> +	 */
> +	if (unlikely(bdi_thresh > thresh))
> +		bdi_thresh = thresh;
> +	/*
> +	 * scale global setpoint to bdi's:  setpoint *= bdi_thresh / thresh
> +	 */
> +	x = div_u64((u64)bdi_thresh << 16, thresh | 1);
> +	setpoint = setpoint * (u64)x >> 16;
> +	/*
> +	 * Use span=(4*write_bw) in single bdi case as indicated by
> +	 * (thresh - bdi_thresh ~= 0) and transit to bdi_thresh in JBOD case.
> +	 */
> +	span = div_u64((u64)bdi_thresh * (thresh - bdi_thresh) +
> +		       (u64)(4 * bdi->avg_write_bandwidth) * bdi_thresh,
> +		       thresh + 1);
  I think you can slightly simplify this to:
(thresh - bdi_thresh + 4 * bdi->avg_write_bandwidth) * (u64)x >> 16;


> +	x_intercept = setpoint + 2 * span;
  What if x_intercept >  bdi_thresh? Since 8*bdi->avg_write_bandwidth is
easily 500 MB, that happens quite often I imagine?

> +
> +	if (unlikely(bdi_dirty > setpoint + span)) {
> +		if (unlikely(bdi_dirty > limit))
> +			return 0;
  Shouldn't this be bdi_thresh instead of limit? I understand this is a
hard limit but with more bdis this condition is rather weak and almost
never true.

> +		if (x_intercept < limit) {
> +			x_intercept = limit;	/* auxiliary control line */
> +			setpoint += span;
> +			pos_ratio >>= 1;
> +		}
  And here you stretch the control area upto the global dirty limit. I
understand you maybe don't want to be really strict and cut control area at
bdi_thresh but your choice looks like too benevolent - when you have
several active bdi's with different speeds this will effectively erase
difference between them, won't it? E.g. with 10 bdi's (x_intercept -
bdi_dirty) / (x_intercept - setpoint) is going to be close to 1 unless
bdi_dirty really heavily exceeds bdi_thresh. So wouldn't it be better to
just make sure control area is reasonably large (e.g. at least 16 MB) to
allow BDI to ramp up it's bdi_thresh but don't extend it upto global dirty
limit?

> +	}
> +	pos_ratio *= x_intercept - bdi_dirty;
> +	do_div(pos_ratio, x_intercept - setpoint + 1);
> +
> +	return pos_ratio;
> +}
> +

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

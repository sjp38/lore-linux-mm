Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 621BF6B0169
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 22:53:43 -0400 (EDT)
Date: Thu, 18 Aug 2011 22:53:21 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110819025321.GB13597@redhat.com>
References: <20110816022006.348714319@intel.com>
 <20110816022328.811348370@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110816022328.811348370@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 16, 2011 at 10:20:08AM +0800, Wu Fengguang wrote:

[..]
> +/*
> + * Dirty position control.
> + *
> + * (o) global/bdi setpoints
> + *
> + * We want the dirty pages be balanced around the global/bdi setpoints.
> + * When the number of dirty pages is higher/lower than the setpoint, the
> + * dirty position control ratio (and hence task dirty ratelimit) will be
> + * decreased/increased to bring the dirty pages back to the setpoint.
> + *
> + *     pos_ratio = 1 << RATELIMIT_CALC_SHIFT
> + *
> + *     if (dirty < setpoint) scale up   pos_ratio
> + *     if (dirty > setpoint) scale down pos_ratio
> + *
> + *     if (bdi_dirty < bdi_setpoint) scale up   pos_ratio
> + *     if (bdi_dirty > bdi_setpoint) scale down pos_ratio
> + *
> + *     task_ratelimit = balanced_rate * pos_ratio >> RATELIMIT_CALC_SHIFT
> + *
> + * (o) global control line
> + *
> + *     ^ pos_ratio
> + *     |
> + *     |            |<===== global dirty control scope ======>|
> + * 2.0 .............*
> + *     |            .*
> + *     |            . *
> + *     |            .   *
> + *     |            .     *
> + *     |            .        *
> + *     |            .            *
> + * 1.0 ................................*
> + *     |            .                  .     *
> + *     |            .                  .          *
> + *     |            .                  .              *
> + *     |            .                  .                 *
> + *     |            .                  .                    *
> + *   0 +------------.------------------.----------------------*------------->
> + *           freerun^          setpoint^                 limit^   dirty pages
> + *
> + * (o) bdi control lines
> + *
> + * The control lines for the global/bdi setpoints both stretch up to @limit.
> + * The below figure illustrates the main bdi control line with an auxiliary
> + * line extending it to @limit.
> + *
> + *   o
> + *     o
> + *       o                                      [o] main control line
> + *         o                                    [*] auxiliary control line
> + *           o
> + *             o
> + *               o
> + *                 o
> + *                   o
> + *                     o
> + *                       o--------------------- balance point, rate scale = 1
> + *                       | o
> + *                       |   o
> + *                       |     o
> + *                       |       o
> + *                       |         o
> + *                       |           o
> + *                       |             o------- connect point, rate scale = 1/2
> + *                       |               .*
> + *                       |                 .   *
> + *                       |                   .      *
> + *                       |                     .         *
> + *                       |                       .           *
> + *                       |                         .              *
> + *                       |                           .                 *
> + *  [--------------------+-----------------------------.--------------------*]
> + *  0                 setpoint                     x_intercept           limit
> + *
> + * The auxiliary control line allows smoothly throttling bdi_dirty down to
> + * normal if it starts high in situations like
> + * - start writing to a slow SD card and a fast disk at the same time. The SD
> + *   card's bdi_dirty may rush to many times higher than bdi setpoint.
> + * - the bdi dirty thresh drops quickly due to change of JBOD workload
> + */
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
> +	x_intercept = setpoint + 2 * span;
> +

Hi Fengguang,

Few very basic queries.

- Why can't we use the same formula for bdi position ratio as gloabl
  position ratio. Are you not looking for similar proporties. Near the
  set point variation is less and away from setup poing throttling is
  faster.

- In the bdi calculation, setpoint seems to be in number of pages and 
  limit (x_intercept) seems to be a combination of nr pages + pages/sec.
  Why it is different from gloabl setpoint and limit. I mean could this
  not have been like global calculation where we try to keep bdi_dirty
  close to bdi_thresh and calculate pos_ratio. 

- In global pos_ratio calculation terminology used is "limit" while
  the same thing seems be being meintioned as x_intercept in bdi position
  ratio calculation.

Am I missing something very basic here.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

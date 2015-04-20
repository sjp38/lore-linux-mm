Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id D88696B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 11:18:23 -0400 (EDT)
Received: by widdi4 with SMTP id di4so95861195wid.0
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 08:18:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s2si16604611wiy.25.2015.04.20.08.18.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Apr 2015 08:18:22 -0700 (PDT)
Date: Mon, 20 Apr 2015 17:18:17 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 14/49] writeback: s/bdi/wb/ in mm/page-writeback.c
Message-ID: <20150420151817.GC17020@quack.suse.cz>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
 <1428350318-8215-15-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1428350318-8215-15-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

On Mon 06-04-15 15:58:03, Tejun Heo wrote:
> Writeback operations will now be per wb (bdi_writeback) instead of
> bdi.  Replace the relevant bdi references in symbol names and comments
> with wb.  This patch is purely cosmetic and doesn't make any
> functional changes.
  It's good you made things consistent. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Jens Axboe <axboe@kernel.dk>
> ---
>  mm/page-writeback.c | 270 ++++++++++++++++++++++++++--------------------------
>  1 file changed, 134 insertions(+), 136 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 29fb4f3..c615a15 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -595,7 +595,7 @@ static long long pos_ratio_polynom(unsigned long setpoint,
>   *
>   * (o) global/bdi setpoints
>   *
> - * We want the dirty pages be balanced around the global/bdi setpoints.
> + * We want the dirty pages be balanced around the global/wb setpoints.
>   * When the number of dirty pages is higher/lower than the setpoint, the
>   * dirty position control ratio (and hence task dirty ratelimit) will be
>   * decreased/increased to bring the dirty pages back to the setpoint.
> @@ -605,8 +605,8 @@ static long long pos_ratio_polynom(unsigned long setpoint,
>   *     if (dirty < setpoint) scale up   pos_ratio
>   *     if (dirty > setpoint) scale down pos_ratio
>   *
> - *     if (bdi_dirty < bdi_setpoint) scale up   pos_ratio
> - *     if (bdi_dirty > bdi_setpoint) scale down pos_ratio
> + *     if (wb_dirty < wb_setpoint) scale up   pos_ratio
> + *     if (wb_dirty > wb_setpoint) scale down pos_ratio
>   *
>   *     task_ratelimit = dirty_ratelimit * pos_ratio >> RATELIMIT_CALC_SHIFT
>   *
> @@ -631,7 +631,7 @@ static long long pos_ratio_polynom(unsigned long setpoint,
>   *   0 +------------.------------------.----------------------*------------->
>   *           freerun^          setpoint^                 limit^   dirty pages
>   *
> - * (o) bdi control line
> + * (o) wb control line
>   *
>   *     ^ pos_ratio
>   *     |
> @@ -657,27 +657,27 @@ static long long pos_ratio_polynom(unsigned long setpoint,
>   *     |                      .                           .
>   *     |                      .                             .
>   *   0 +----------------------.-------------------------------.------------->
> - *                bdi_setpoint^                    x_intercept^
> + *                wb_setpoint^                    x_intercept^
>   *
> - * The bdi control line won't drop below pos_ratio=1/4, so that bdi_dirty can
> + * The wb control line won't drop below pos_ratio=1/4, so that wb_dirty can
>   * be smoothly throttled down to normal if it starts high in situations like
>   * - start writing to a slow SD card and a fast disk at the same time. The SD
> - *   card's bdi_dirty may rush to many times higher than bdi_setpoint.
> - * - the bdi dirty thresh drops quickly due to change of JBOD workload
> + *   card's wb_dirty may rush to many times higher than wb_setpoint.
> + * - the wb dirty thresh drops quickly due to change of JBOD workload
>   */
>  static unsigned long wb_position_ratio(struct bdi_writeback *wb,
>  				       unsigned long thresh,
>  				       unsigned long bg_thresh,
>  				       unsigned long dirty,
> -				       unsigned long bdi_thresh,
> -				       unsigned long bdi_dirty)
> +				       unsigned long wb_thresh,
> +				       unsigned long wb_dirty)
>  {
>  	unsigned long write_bw = wb->avg_write_bandwidth;
>  	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
>  	unsigned long limit = hard_dirty_limit(thresh);
>  	unsigned long x_intercept;
>  	unsigned long setpoint;		/* dirty pages' target balance point */
> -	unsigned long bdi_setpoint;
> +	unsigned long wb_setpoint;
>  	unsigned long span;
>  	long long pos_ratio;		/* for scaling up/down the rate limit */
>  	long x;
> @@ -696,146 +696,145 @@ static unsigned long wb_position_ratio(struct bdi_writeback *wb,
>  	/*
>  	 * The strictlimit feature is a tool preventing mistrusted filesystems
>  	 * from growing a large number of dirty pages before throttling. For
> -	 * such filesystems balance_dirty_pages always checks bdi counters
> -	 * against bdi limits. Even if global "nr_dirty" is under "freerun".
> +	 * such filesystems balance_dirty_pages always checks wb counters
> +	 * against wb limits. Even if global "nr_dirty" is under "freerun".
>  	 * This is especially important for fuse which sets bdi->max_ratio to
>  	 * 1% by default. Without strictlimit feature, fuse writeback may
>  	 * consume arbitrary amount of RAM because it is accounted in
>  	 * NR_WRITEBACK_TEMP which is not involved in calculating "nr_dirty".
>  	 *
>  	 * Here, in wb_position_ratio(), we calculate pos_ratio based on
> -	 * two values: bdi_dirty and bdi_thresh. Let's consider an example:
> +	 * two values: wb_dirty and wb_thresh. Let's consider an example:
>  	 * total amount of RAM is 16GB, bdi->max_ratio is equal to 1%, global
>  	 * limits are set by default to 10% and 20% (background and throttle).
> -	 * Then bdi_thresh is 1% of 20% of 16GB. This amounts to ~8K pages.
> -	 * wb_dirty_limit(wb, bg_thresh) is about ~4K pages. bdi_setpoint is
> -	 * about ~6K pages (as the average of background and throttle bdi
> +	 * Then wb_thresh is 1% of 20% of 16GB. This amounts to ~8K pages.
> +	 * wb_dirty_limit(wb, bg_thresh) is about ~4K pages. wb_setpoint is
> +	 * about ~6K pages (as the average of background and throttle wb
>  	 * limits). The 3rd order polynomial will provide positive feedback if
> -	 * bdi_dirty is under bdi_setpoint and vice versa.
> +	 * wb_dirty is under wb_setpoint and vice versa.
>  	 *
>  	 * Note, that we cannot use global counters in these calculations
> -	 * because we want to throttle process writing to a strictlimit BDI
> +	 * because we want to throttle process writing to a strictlimit wb
>  	 * much earlier than global "freerun" is reached (~23MB vs. ~2.3GB
>  	 * in the example above).
>  	 */
>  	if (unlikely(wb->bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
> -		long long bdi_pos_ratio;
> -		unsigned long bdi_bg_thresh;
> +		long long wb_pos_ratio;
> +		unsigned long wb_bg_thresh;
>  
> -		if (bdi_dirty < 8)
> +		if (wb_dirty < 8)
>  			return min_t(long long, pos_ratio * 2,
>  				     2 << RATELIMIT_CALC_SHIFT);
>  
> -		if (bdi_dirty >= bdi_thresh)
> +		if (wb_dirty >= wb_thresh)
>  			return 0;
>  
> -		bdi_bg_thresh = div_u64((u64)bdi_thresh * bg_thresh, thresh);
> -		bdi_setpoint = dirty_freerun_ceiling(bdi_thresh,
> -						     bdi_bg_thresh);
> +		wb_bg_thresh = div_u64((u64)wb_thresh * bg_thresh, thresh);
> +		wb_setpoint = dirty_freerun_ceiling(wb_thresh, wb_bg_thresh);
>  
> -		if (bdi_setpoint == 0 || bdi_setpoint == bdi_thresh)
> +		if (wb_setpoint == 0 || wb_setpoint == wb_thresh)
>  			return 0;
>  
> -		bdi_pos_ratio = pos_ratio_polynom(bdi_setpoint, bdi_dirty,
> -						  bdi_thresh);
> +		wb_pos_ratio = pos_ratio_polynom(wb_setpoint, wb_dirty,
> +						 wb_thresh);
>  
>  		/*
> -		 * Typically, for strictlimit case, bdi_setpoint << setpoint
> -		 * and pos_ratio >> bdi_pos_ratio. In the other words global
> +		 * Typically, for strictlimit case, wb_setpoint << setpoint
> +		 * and pos_ratio >> wb_pos_ratio. In the other words global
>  		 * state ("dirty") is not limiting factor and we have to
> -		 * make decision based on bdi counters. But there is an
> +		 * make decision based on wb counters. But there is an
>  		 * important case when global pos_ratio should get precedence:
>  		 * global limits are exceeded (e.g. due to activities on other
> -		 * BDIs) while given strictlimit BDI is below limit.
> +		 * wb's) while given strictlimit wb is below limit.
>  		 *
> -		 * "pos_ratio * bdi_pos_ratio" would work for the case above,
> +		 * "pos_ratio * wb_pos_ratio" would work for the case above,
>  		 * but it would look too non-natural for the case of all
> -		 * activity in the system coming from a single strictlimit BDI
> +		 * activity in the system coming from a single strictlimit wb
>  		 * with bdi->max_ratio == 100%.
>  		 *
>  		 * Note that min() below somewhat changes the dynamics of the
>  		 * control system. Normally, pos_ratio value can be well over 3
> -		 * (when globally we are at freerun and bdi is well below bdi
> +		 * (when globally we are at freerun and wb is well below wb
>  		 * setpoint). Now the maximum pos_ratio in the same situation
>  		 * is 2. We might want to tweak this if we observe the control
>  		 * system is too slow to adapt.
>  		 */
> -		return min(pos_ratio, bdi_pos_ratio);
> +		return min(pos_ratio, wb_pos_ratio);
>  	}
>  
>  	/*
>  	 * We have computed basic pos_ratio above based on global situation. If
> -	 * the bdi is over/under its share of dirty pages, we want to scale
> +	 * the wb is over/under its share of dirty pages, we want to scale
>  	 * pos_ratio further down/up. That is done by the following mechanism.
>  	 */
>  
>  	/*
> -	 * bdi setpoint
> +	 * wb setpoint
>  	 *
> -	 *        f(bdi_dirty) := 1.0 + k * (bdi_dirty - bdi_setpoint)
> +	 *        f(wb_dirty) := 1.0 + k * (wb_dirty - wb_setpoint)
>  	 *
> -	 *                        x_intercept - bdi_dirty
> +	 *                        x_intercept - wb_dirty
>  	 *                     := --------------------------
> -	 *                        x_intercept - bdi_setpoint
> +	 *                        x_intercept - wb_setpoint
>  	 *
> -	 * The main bdi control line is a linear function that subjects to
> +	 * The main wb control line is a linear function that subjects to
>  	 *
> -	 * (1) f(bdi_setpoint) = 1.0
> -	 * (2) k = - 1 / (8 * write_bw)  (in single bdi case)
> -	 *     or equally: x_intercept = bdi_setpoint + 8 * write_bw
> +	 * (1) f(wb_setpoint) = 1.0
> +	 * (2) k = - 1 / (8 * write_bw)  (in single wb case)
> +	 *     or equally: x_intercept = wb_setpoint + 8 * write_bw
>  	 *
> -	 * For single bdi case, the dirty pages are observed to fluctuate
> +	 * For single wb case, the dirty pages are observed to fluctuate
>  	 * regularly within range
> -	 *        [bdi_setpoint - write_bw/2, bdi_setpoint + write_bw/2]
> +	 *        [wb_setpoint - write_bw/2, wb_setpoint + write_bw/2]
>  	 * for various filesystems, where (2) can yield in a reasonable 12.5%
>  	 * fluctuation range for pos_ratio.
>  	 *
> -	 * For JBOD case, bdi_thresh (not bdi_dirty!) could fluctuate up to its
> +	 * For JBOD case, wb_thresh (not wb_dirty!) could fluctuate up to its
>  	 * own size, so move the slope over accordingly and choose a slope that
> -	 * yields 100% pos_ratio fluctuation on suddenly doubled bdi_thresh.
> +	 * yields 100% pos_ratio fluctuation on suddenly doubled wb_thresh.
>  	 */
> -	if (unlikely(bdi_thresh > thresh))
> -		bdi_thresh = thresh;
> +	if (unlikely(wb_thresh > thresh))
> +		wb_thresh = thresh;
>  	/*
> -	 * It's very possible that bdi_thresh is close to 0 not because the
> +	 * It's very possible that wb_thresh is close to 0 not because the
>  	 * device is slow, but that it has remained inactive for long time.
>  	 * Honour such devices a reasonable good (hopefully IO efficient)
>  	 * threshold, so that the occasional writes won't be blocked and active
>  	 * writes can rampup the threshold quickly.
>  	 */
> -	bdi_thresh = max(bdi_thresh, (limit - dirty) / 8);
> +	wb_thresh = max(wb_thresh, (limit - dirty) / 8);
>  	/*
> -	 * scale global setpoint to bdi's:
> -	 *	bdi_setpoint = setpoint * bdi_thresh / thresh
> +	 * scale global setpoint to wb's:
> +	 *	wb_setpoint = setpoint * wb_thresh / thresh
>  	 */
> -	x = div_u64((u64)bdi_thresh << 16, thresh + 1);
> -	bdi_setpoint = setpoint * (u64)x >> 16;
> +	x = div_u64((u64)wb_thresh << 16, thresh + 1);
> +	wb_setpoint = setpoint * (u64)x >> 16;
>  	/*
> -	 * Use span=(8*write_bw) in single bdi case as indicated by
> -	 * (thresh - bdi_thresh ~= 0) and transit to bdi_thresh in JBOD case.
> +	 * Use span=(8*write_bw) in single wb case as indicated by
> +	 * (thresh - wb_thresh ~= 0) and transit to wb_thresh in JBOD case.
>  	 *
> -	 *        bdi_thresh                    thresh - bdi_thresh
> -	 * span = ---------- * (8 * write_bw) + ------------------- * bdi_thresh
> -	 *          thresh                            thresh
> +	 *        wb_thresh                    thresh - wb_thresh
> +	 * span = --------- * (8 * write_bw) + ------------------ * wb_thresh
> +	 *         thresh                           thresh
>  	 */
> -	span = (thresh - bdi_thresh + 8 * write_bw) * (u64)x >> 16;
> -	x_intercept = bdi_setpoint + span;
> +	span = (thresh - wb_thresh + 8 * write_bw) * (u64)x >> 16;
> +	x_intercept = wb_setpoint + span;
>  
> -	if (bdi_dirty < x_intercept - span / 4) {
> -		pos_ratio = div64_u64(pos_ratio * (x_intercept - bdi_dirty),
> -				    x_intercept - bdi_setpoint + 1);
> +	if (wb_dirty < x_intercept - span / 4) {
> +		pos_ratio = div64_u64(pos_ratio * (x_intercept - wb_dirty),
> +				    x_intercept - wb_setpoint + 1);
>  	} else
>  		pos_ratio /= 4;
>  
>  	/*
> -	 * bdi reserve area, safeguard against dirty pool underrun and disk idle
> +	 * wb reserve area, safeguard against dirty pool underrun and disk idle
>  	 * It may push the desired control point of global dirty pages higher
>  	 * than setpoint.
>  	 */
> -	x_intercept = bdi_thresh / 2;
> -	if (bdi_dirty < x_intercept) {
> -		if (bdi_dirty > x_intercept / 8)
> -			pos_ratio = div_u64(pos_ratio * x_intercept, bdi_dirty);
> +	x_intercept = wb_thresh / 2;
> +	if (wb_dirty < x_intercept) {
> +		if (wb_dirty > x_intercept / 8)
> +			pos_ratio = div_u64(pos_ratio * x_intercept, wb_dirty);
>  		else
>  			pos_ratio *= 8;
>  	}
> @@ -943,17 +942,17 @@ static void global_update_bandwidth(unsigned long thresh,
>  }
>  
>  /*
> - * Maintain bdi->dirty_ratelimit, the base dirty throttle rate.
> + * Maintain wb->dirty_ratelimit, the base dirty throttle rate.
>   *
> - * Normal bdi tasks will be curbed at or below it in long term.
> + * Normal wb tasks will be curbed at or below it in long term.
>   * Obviously it should be around (write_bw / N) when there are N dd tasks.
>   */
>  static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
>  				      unsigned long thresh,
>  				      unsigned long bg_thresh,
>  				      unsigned long dirty,
> -				      unsigned long bdi_thresh,
> -				      unsigned long bdi_dirty,
> +				      unsigned long wb_thresh,
> +				      unsigned long wb_dirty,
>  				      unsigned long dirtied,
>  				      unsigned long elapsed)
>  {
> @@ -976,7 +975,7 @@ static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
>  	dirty_rate = (dirtied - wb->dirtied_stamp) * HZ / elapsed;
>  
>  	pos_ratio = wb_position_ratio(wb, thresh, bg_thresh, dirty,
> -				      bdi_thresh, bdi_dirty);
> +				      wb_thresh, wb_dirty);
>  	/*
>  	 * task_ratelimit reflects each dd's dirty rate for the past 200ms.
>  	 */
> @@ -986,7 +985,7 @@ static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
>  
>  	/*
>  	 * A linear estimation of the "balanced" throttle rate. The theory is,
> -	 * if there are N dd tasks, each throttled at task_ratelimit, the bdi's
> +	 * if there are N dd tasks, each throttled at task_ratelimit, the wb's
>  	 * dirty_rate will be measured to be (N * task_ratelimit). So the below
>  	 * formula will yield the balanced rate limit (write_bw / N).
>  	 *
> @@ -1025,7 +1024,7 @@ static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
>  	/*
>  	 * We could safely do this and return immediately:
>  	 *
> -	 *	bdi->dirty_ratelimit = balanced_dirty_ratelimit;
> +	 *	wb->dirty_ratelimit = balanced_dirty_ratelimit;
>  	 *
>  	 * However to get a more stable dirty_ratelimit, the below elaborated
>  	 * code makes use of task_ratelimit to filter out singular points and
> @@ -1059,22 +1058,22 @@ static void wb_update_dirty_ratelimit(struct bdi_writeback *wb,
>  	step = 0;
>  
>  	/*
> -	 * For strictlimit case, calculations above were based on bdi counters
> +	 * For strictlimit case, calculations above were based on wb counters
>  	 * and limits (starting from pos_ratio = wb_position_ratio() and up to
>  	 * balanced_dirty_ratelimit = task_ratelimit * write_bw / dirty_rate).
> -	 * Hence, to calculate "step" properly, we have to use bdi_dirty as
> -	 * "dirty" and bdi_setpoint as "setpoint".
> +	 * Hence, to calculate "step" properly, we have to use wb_dirty as
> +	 * "dirty" and wb_setpoint as "setpoint".
>  	 *
> -	 * We rampup dirty_ratelimit forcibly if bdi_dirty is low because
> -	 * it's possible that bdi_thresh is close to zero due to inactivity
> +	 * We rampup dirty_ratelimit forcibly if wb_dirty is low because
> +	 * it's possible that wb_thresh is close to zero due to inactivity
>  	 * of backing device (see the implementation of wb_dirty_limit()).
>  	 */
>  	if (unlikely(wb->bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
> -		dirty = bdi_dirty;
> -		if (bdi_dirty < 8)
> -			setpoint = bdi_dirty + 1;
> +		dirty = wb_dirty;
> +		if (wb_dirty < 8)
> +			setpoint = wb_dirty + 1;
>  		else
> -			setpoint = (bdi_thresh +
> +			setpoint = (wb_thresh +
>  				    wb_dirty_limit(wb, bg_thresh)) / 2;
>  	}
>  
> @@ -1116,8 +1115,8 @@ void __wb_update_bandwidth(struct bdi_writeback *wb,
>  			   unsigned long thresh,
>  			   unsigned long bg_thresh,
>  			   unsigned long dirty,
> -			   unsigned long bdi_thresh,
> -			   unsigned long bdi_dirty,
> +			   unsigned long wb_thresh,
> +			   unsigned long wb_dirty,
>  			   unsigned long start_time)
>  {
>  	unsigned long now = jiffies;
> @@ -1144,7 +1143,7 @@ void __wb_update_bandwidth(struct bdi_writeback *wb,
>  	if (thresh) {
>  		global_update_bandwidth(thresh, dirty, now);
>  		wb_update_dirty_ratelimit(wb, thresh, bg_thresh, dirty,
> -					  bdi_thresh, bdi_dirty,
> +					  wb_thresh, wb_dirty,
>  					  dirtied, elapsed);
>  	}
>  	wb_update_write_bandwidth(wb, elapsed, written);
> @@ -1159,15 +1158,15 @@ static void wb_update_bandwidth(struct bdi_writeback *wb,
>  				unsigned long thresh,
>  				unsigned long bg_thresh,
>  				unsigned long dirty,
> -				unsigned long bdi_thresh,
> -				unsigned long bdi_dirty,
> +				unsigned long wb_thresh,
> +				unsigned long wb_dirty,
>  				unsigned long start_time)
>  {
>  	if (time_is_after_eq_jiffies(wb->bw_time_stamp + BANDWIDTH_INTERVAL))
>  		return;
>  	spin_lock(&wb->list_lock);
>  	__wb_update_bandwidth(wb, thresh, bg_thresh, dirty,
> -			      bdi_thresh, bdi_dirty, start_time);
> +			      wb_thresh, wb_dirty, start_time);
>  	spin_unlock(&wb->list_lock);
>  }
>  
> @@ -1189,7 +1188,7 @@ static unsigned long dirty_poll_interval(unsigned long dirty,
>  }
>  
>  static unsigned long wb_max_pause(struct bdi_writeback *wb,
> -				      unsigned long bdi_dirty)
> +				  unsigned long wb_dirty)
>  {
>  	unsigned long bw = wb->avg_write_bandwidth;
>  	unsigned long t;
> @@ -1201,7 +1200,7 @@ static unsigned long wb_max_pause(struct bdi_writeback *wb,
>  	 *
>  	 * 8 serves as the safety ratio.
>  	 */
> -	t = bdi_dirty / (1 + bw / roundup_pow_of_two(1 + HZ / 8));
> +	t = wb_dirty / (1 + bw / roundup_pow_of_two(1 + HZ / 8));
>  	t++;
>  
>  	return min_t(unsigned long, t, MAX_PAUSE);
> @@ -1285,31 +1284,31 @@ static long wb_min_pause(struct bdi_writeback *wb,
>  static inline void wb_dirty_limits(struct bdi_writeback *wb,
>  				   unsigned long dirty_thresh,
>  				   unsigned long background_thresh,
> -				   unsigned long *bdi_dirty,
> -				   unsigned long *bdi_thresh,
> -				   unsigned long *bdi_bg_thresh)
> +				   unsigned long *wb_dirty,
> +				   unsigned long *wb_thresh,
> +				   unsigned long *wb_bg_thresh)
>  {
>  	unsigned long wb_reclaimable;
>  
>  	/*
> -	 * bdi_thresh is not treated as some limiting factor as
> +	 * wb_thresh is not treated as some limiting factor as
>  	 * dirty_thresh, due to reasons
> -	 * - in JBOD setup, bdi_thresh can fluctuate a lot
> +	 * - in JBOD setup, wb_thresh can fluctuate a lot
>  	 * - in a system with HDD and USB key, the USB key may somehow
> -	 *   go into state (bdi_dirty >> bdi_thresh) either because
> -	 *   bdi_dirty starts high, or because bdi_thresh drops low.
> +	 *   go into state (wb_dirty >> wb_thresh) either because
> +	 *   wb_dirty starts high, or because wb_thresh drops low.
>  	 *   In this case we don't want to hard throttle the USB key
> -	 *   dirtiers for 100 seconds until bdi_dirty drops under
> -	 *   bdi_thresh. Instead the auxiliary bdi control line in
> +	 *   dirtiers for 100 seconds until wb_dirty drops under
> +	 *   wb_thresh. Instead the auxiliary wb control line in
>  	 *   wb_position_ratio() will let the dirtier task progress
> -	 *   at some rate <= (write_bw / 2) for bringing down bdi_dirty.
> +	 *   at some rate <= (write_bw / 2) for bringing down wb_dirty.
>  	 */
> -	*bdi_thresh = wb_dirty_limit(wb, dirty_thresh);
> +	*wb_thresh = wb_dirty_limit(wb, dirty_thresh);
>  
> -	if (bdi_bg_thresh)
> -		*bdi_bg_thresh = dirty_thresh ? div_u64((u64)*bdi_thresh *
> -							background_thresh,
> -							dirty_thresh) : 0;
> +	if (wb_bg_thresh)
> +		*wb_bg_thresh = dirty_thresh ? div_u64((u64)*wb_thresh *
> +						       background_thresh,
> +						       dirty_thresh) : 0;
>  
>  	/*
>  	 * In order to avoid the stacked BDI deadlock we need
> @@ -1321,12 +1320,12 @@ static inline void wb_dirty_limits(struct bdi_writeback *wb,
>  	 * actually dirty; with m+n sitting in the percpu
>  	 * deltas.
>  	 */
> -	if (*bdi_thresh < 2 * wb_stat_error(wb)) {
> +	if (*wb_thresh < 2 * wb_stat_error(wb)) {
>  		wb_reclaimable = wb_stat_sum(wb, WB_RECLAIMABLE);
> -		*bdi_dirty = wb_reclaimable + wb_stat_sum(wb, WB_WRITEBACK);
> +		*wb_dirty = wb_reclaimable + wb_stat_sum(wb, WB_WRITEBACK);
>  	} else {
>  		wb_reclaimable = wb_stat(wb, WB_RECLAIMABLE);
> -		*bdi_dirty = wb_reclaimable + wb_stat(wb, WB_WRITEBACK);
> +		*wb_dirty = wb_reclaimable + wb_stat(wb, WB_WRITEBACK);
>  	}
>  }
>  
> @@ -1360,9 +1359,9 @@ static void balance_dirty_pages(struct address_space *mapping,
>  
>  	for (;;) {
>  		unsigned long now = jiffies;
> -		unsigned long uninitialized_var(bdi_thresh);
> +		unsigned long uninitialized_var(wb_thresh);
>  		unsigned long thresh;
> -		unsigned long uninitialized_var(bdi_dirty);
> +		unsigned long uninitialized_var(wb_dirty);
>  		unsigned long dirty;
>  		unsigned long bg_thresh;
>  
> @@ -1380,10 +1379,10 @@ static void balance_dirty_pages(struct address_space *mapping,
>  
>  		if (unlikely(strictlimit)) {
>  			wb_dirty_limits(wb, dirty_thresh, background_thresh,
> -					&bdi_dirty, &bdi_thresh, &bg_thresh);
> +					&wb_dirty, &wb_thresh, &bg_thresh);
>  
> -			dirty = bdi_dirty;
> -			thresh = bdi_thresh;
> +			dirty = wb_dirty;
> +			thresh = wb_thresh;
>  		} else {
>  			dirty = nr_dirty;
>  			thresh = dirty_thresh;
> @@ -1393,10 +1392,10 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		/*
>  		 * Throttle it only when the background writeback cannot
>  		 * catch-up. This avoids (excessively) small writeouts
> -		 * when the bdi limits are ramping up in case of !strictlimit.
> +		 * when the wb limits are ramping up in case of !strictlimit.
>  		 *
> -		 * In strictlimit case make decision based on the bdi counters
> -		 * and limits. Small writeouts when the bdi limits are ramping
> +		 * In strictlimit case make decision based on the wb counters
> +		 * and limits. Small writeouts when the wb limits are ramping
>  		 * up are the price we consciously pay for strictlimit-ing.
>  		 */
>  		if (dirty <= dirty_freerun_ceiling(thresh, bg_thresh)) {
> @@ -1412,24 +1411,23 @@ static void balance_dirty_pages(struct address_space *mapping,
>  
>  		if (!strictlimit)
>  			wb_dirty_limits(wb, dirty_thresh, background_thresh,
> -					&bdi_dirty, &bdi_thresh, NULL);
> +					&wb_dirty, &wb_thresh, NULL);
>  
> -		dirty_exceeded = (bdi_dirty > bdi_thresh) &&
> +		dirty_exceeded = (wb_dirty > wb_thresh) &&
>  				 ((nr_dirty > dirty_thresh) || strictlimit);
>  		if (dirty_exceeded && !wb->dirty_exceeded)
>  			wb->dirty_exceeded = 1;
>  
>  		wb_update_bandwidth(wb, dirty_thresh, background_thresh,
> -				    nr_dirty, bdi_thresh, bdi_dirty,
> -				    start_time);
> +				    nr_dirty, wb_thresh, wb_dirty, start_time);
>  
>  		dirty_ratelimit = wb->dirty_ratelimit;
>  		pos_ratio = wb_position_ratio(wb, dirty_thresh,
>  					      background_thresh, nr_dirty,
> -					      bdi_thresh, bdi_dirty);
> +					      wb_thresh, wb_dirty);
>  		task_ratelimit = ((u64)dirty_ratelimit * pos_ratio) >>
>  							RATELIMIT_CALC_SHIFT;
> -		max_pause = wb_max_pause(wb, bdi_dirty);
> +		max_pause = wb_max_pause(wb, wb_dirty);
>  		min_pause = wb_min_pause(wb, max_pause,
>  					 task_ratelimit, dirty_ratelimit,
>  					 &nr_dirtied_pause);
> @@ -1455,8 +1453,8 @@ static void balance_dirty_pages(struct address_space *mapping,
>  						  dirty_thresh,
>  						  background_thresh,
>  						  nr_dirty,
> -						  bdi_thresh,
> -						  bdi_dirty,
> +						  wb_thresh,
> +						  wb_dirty,
>  						  dirty_ratelimit,
>  						  task_ratelimit,
>  						  pages_dirtied,
> @@ -1484,8 +1482,8 @@ pause:
>  					  dirty_thresh,
>  					  background_thresh,
>  					  nr_dirty,
> -					  bdi_thresh,
> -					  bdi_dirty,
> +					  wb_thresh,
> +					  wb_dirty,
>  					  dirty_ratelimit,
>  					  task_ratelimit,
>  					  pages_dirtied,
> @@ -1508,15 +1506,15 @@ pause:
>  
>  		/*
>  		 * In the case of an unresponding NFS server and the NFS dirty
> -		 * pages exceeds dirty_thresh, give the other good bdi's a pipe
> +		 * pages exceeds dirty_thresh, give the other good wb's a pipe
>  		 * to go through, so that tasks on them still remain responsive.
>  		 *
>  		 * In theory 1 page is enough to keep the comsumer-producer
>  		 * pipe going: the flusher cleans 1 page => the task dirties 1
> -		 * more page. However bdi_dirty has accounting errors.  So use
> +		 * more page. However wb_dirty has accounting errors.  So use
>  		 * the larger and more IO friendly wb_stat_error.
>  		 */
> -		if (bdi_dirty <= wb_stat_error(wb))
> +		if (wb_dirty <= wb_stat_error(wb))
>  			break;
>  
>  		if (fatal_signal_pending(current))
> -- 
> 2.1.0
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3CE3E900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 09:23:55 -0400 (EDT)
Date: Wed, 17 Aug 2011 21:23:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110817132347.GA6628@localhost>
References: <20110816022006.348714319@intel.com>
 <20110816022328.811348370@intel.com>
 <20110816194112.GA25517@quack.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="d6Gm4EdcadzBjdND"
Content-Disposition: inline
In-Reply-To: <20110816194112.GA25517@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Jan,

On Wed, Aug 17, 2011 at 03:41:12AM +0800, Jan Kara wrote:
>   Hello Fengguang,
> 
>   this patch is much easier to read than in older versions! Good work!

Thank you :)

> > +static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
> > +					unsigned long thresh,
> > +					unsigned long bg_thresh,
> > +					unsigned long dirty,
> > +					unsigned long bdi_thresh,
> > +					unsigned long bdi_dirty)
> > +{
> > +	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
> > +	unsigned long limit = hard_dirty_limit(thresh);
> > +	unsigned long x_intercept;
> > +	unsigned long setpoint;		/* the target balance point */
> > +	unsigned long span;
> > +	long long pos_ratio;		/* for scaling up/down the rate limit */
> > +	long x;
> > +
> > +	if (unlikely(dirty >= limit))
> > +		return 0;
> > +
> > +	/*
> > +	 * global setpoint
> > +	 *
> > +	 *                         setpoint - dirty 3
> > +	 *        f(dirty) := 1 + (----------------)
> > +	 *                         limit - setpoint
> > +	 *
> > +	 * it's a 3rd order polynomial that subjects to
> > +	 *
> > +	 * (1) f(freerun)  = 2.0 => rampup base_rate reasonably fast
> > +	 * (2) f(setpoint) = 1.0 => the balance point
> > +	 * (3) f(limit)    = 0   => the hard limit
> > +	 * (4) df/dx       < 0	 => negative feedback control
> > +	 * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
> > +	 *     => fast response on large errors; small oscillation near setpoint
> > +	 */
> > +	setpoint = (freerun + limit) / 2;
> > +	x = div_s64((setpoint - dirty) << RATELIMIT_CALC_SHIFT,
> > +		    limit - setpoint + 1);
> > +	pos_ratio = x;
> > +	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> > +	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> > +	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
> > +
> > +	/*
> > +	 * bdi setpoint
> > +	 *
> > +	 *        f(dirty) := 1.0 + k * (dirty - setpoint)
> > +	 *
> > +	 * The main bdi control line is a linear function that subjects to
> > +	 *
> > +	 * (1) f(setpoint) = 1.0
> > +	 * (2) k = - 1 / (8 * write_bw)  (in single bdi case)
> > +	 *     or equally: x_intercept = setpoint + 8 * write_bw
> > +	 *
> > +	 * For single bdi case, the dirty pages are observed to fluctuate
> > +	 * regularly within range
> > +	 *        [setpoint - write_bw/2, setpoint + write_bw/2]
> > +	 * for various filesystems, where (2) can yield in a reasonable 12.5%
> > +	 * fluctuation range for pos_ratio.
> > +	 *
> > +	 * For JBOD case, bdi_thresh (not bdi_dirty!) could fluctuate up to its
> > +	 * own size, so move the slope over accordingly.
> > +	 */
> > +	if (unlikely(bdi_thresh > thresh))
> > +		bdi_thresh = thresh;
> > +	/*
> > +	 * scale global setpoint to bdi's:  setpoint *= bdi_thresh / thresh
> > +	 */
> > +	x = div_u64((u64)bdi_thresh << 16, thresh | 1);
> > +	setpoint = setpoint * (u64)x >> 16;
> > +	/*
> > +	 * Use span=(4*write_bw) in single bdi case as indicated by
> > +	 * (thresh - bdi_thresh ~= 0) and transit to bdi_thresh in JBOD case.
> > +	 */
> > +	span = div_u64((u64)bdi_thresh * (thresh - bdi_thresh) +
> > +		       (u64)(4 * bdi->avg_write_bandwidth) * bdi_thresh,
> > +		       thresh + 1);
>   I think you can slightly simplify this to:
> (thresh - bdi_thresh + 4 * bdi->avg_write_bandwidth) * (u64)x >> 16;

Good idea!

> > +	x_intercept = setpoint + 2 * span;
>   What if x_intercept >  bdi_thresh? Since 8*bdi->avg_write_bandwidth is
> easily 500 MB, that happens quite often I imagine?

That's fine because I no longer target "bdi_thresh" as some limiting
factor as the global "thresh". Due to it being unstable in small
memory JBOD systems, which is the big and unique problem in JBOD.

> > +
> > +	if (unlikely(bdi_dirty > setpoint + span)) {
> > +		if (unlikely(bdi_dirty > limit))
> > +			return 0;
>   Shouldn't this be bdi_thresh instead of limit? I understand this is a
> hard limit but with more bdis this condition is rather weak and almost
> never true.

Yeah, I mean @limit. @bdi_thresh is made weak in IO-less
balance_dirty_pages() in order to get reasonable smooth dirty rate in
the face of a fluctuating @bdi_thresh.

The tradeoff is to let bdi dirty pages fluctuate more or less freely,
as long as they don't drop low and risk IO queue underflow. The
attached patch tries to prevent the underflow (which is good but not
perfect).

> > +		if (x_intercept < limit) {
> > +			x_intercept = limit;	/* auxiliary control line */
> > +			setpoint += span;
> > +			pos_ratio >>= 1;
> > +		}
>   And here you stretch the control area upto the global dirty limit. I
> understand you maybe don't want to be really strict and cut control area at
> bdi_thresh but your choice looks like too benevolent - when you have
> several active bdi's with different speeds this will effectively erase
> difference between them, won't it? E.g. with 10 bdi's (x_intercept -
> bdi_dirty) / (x_intercept - setpoint) is going to be close to 1 unless
> bdi_dirty really heavily exceeds bdi_thresh.

Yes the auxiliary control line could be very flat (small slope).

However it's not normal for the bdi dirty pages to fall into the
range of auxiliary control line at all. And once it takes effect, 
the pos_ratio is at most 0.5 (which is the value at the connection
point with the main bdi control line) which is strong enough to pull
the dirty pages off the auxiliary bdi control line and into the scope
of main bdi control line.

The auxiliary control line is intended for bringing down the bdi_dirty
of the USB key before 250s (where the "pos bandwidth" line keeps low): 

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1UKEY+1HDD-3G/ext4-4dd-1M-8p-2945M-20%25-2.6.38-rc5-dt6+-2011-02-22-09-46/balance_dirty_pages-pages.png

After that the bdi_dirty will fluctuate around bdi_thresh and won't
grow high and step into the scope of the auxiliary control line.

> So wouldn't it be better to
> just make sure control area is reasonably large (e.g. at least 16 MB) to
> allow BDI to ramp up it's bdi_thresh but don't extend it upto global dirty
> limit?

In order to take bdi_thresh as some semi-strict limit, we need to make
it very stable at first..otherwise the whole control system may fluctuate
violently.

Thanks,
Fengguang

> > +	}
> > +	pos_ratio *= x_intercept - bdi_dirty;
> > +	do_div(pos_ratio, x_intercept - setpoint + 1);
> > +
> > +	return pos_ratio;
> > +}
> > +
> 
> 								Honza
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR

--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=bdi-reserve-area

Subject: writeback: dirty position control - bdi reserve area
Date: Thu Aug 04 22:16:46 CST 2011

Keep a minimal pool of dirty pages for each bdi, so that the disk IO
queues won't underrun.

It's particularly useful for JBOD and small memory system.

XXX:
When memory is small (in comparison to write bandwidth), this control
line may result in (pos_ratio > 1) at the setpoint and push the dirty
pages high. This is more or less intended because the bdi is in the
danger of IO queue underflow. However the global dirty pages, when
pushed close to limit, will eventually conteract our desire to push up
the low bdi_dirty. In low memory JBOD tests we do see disks
under-utilized from time to time.

One scheme that may completely fix this is to add a BDI_queue_empty to
indicate the block IO queue emptiness (but still there may be in flight
IOs on the driver/hardware side) and to unthrottle the tasks regardless
of the global limit on seeing BDI_queue_empty.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2011-08-16 09:06:46.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-16 09:06:50.000000000 +0800
@@ -488,6 +488,16 @@ unsigned long bdi_dirty_limit(struct bac
  *   0 +------------.------------------.----------------------*------------->
  *           freerun^          setpoint^                 limit^   dirty pages
  *
+ * (o) bdi reserve area
+ *
+ * The bdi reserve area tries to keep a reasonable number of dirty pages for
+ * preventing block queue underrun.
+ *
+ * reserve area, scale up rate as dirty pages drop low
+ * |<----------------------------------------------->|
+ * |-------------------------------------------------------*-------|----------
+ * 0                                           bdi setpoint^       ^bdi_thresh
+ *
  * (o) bdi control lines
  *
  * The control lines for the global/bdi setpoints both stretch up to @limit.
@@ -571,6 +581,19 @@ static unsigned long bdi_position_ratio(
 	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
 
 	/*
+	 * bdi reserve area, safeguard against dirty pool underrun and disk idle
+	 */
+	x_intercept = min(bdi->avg_write_bandwidth + 2 * MIN_WRITEBACK_PAGES,
+			  freerun);
+	if (bdi_dirty < x_intercept) {
+		if (bdi_dirty > x_intercept / 8) {
+			pos_ratio *= x_intercept;
+			do_div(pos_ratio, bdi_dirty);
+		} else
+			pos_ratio *= 8;
+	}
+
+	/*
 	 * bdi setpoint
 	 *
 	 *        f(dirty) := 1.0 + k * (dirty - setpoint)

--d6Gm4EdcadzBjdND--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

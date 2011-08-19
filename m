Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7FBA56B0169
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 22:06:58 -0400 (EDT)
Date: Thu, 18 Aug 2011 22:06:37 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110819020637.GA13597@redhat.com>
References: <20110816022006.348714319@intel.com>
 <20110816022329.190706384@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110816022329.190706384@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Aug 16, 2011 at 10:20:11AM +0800, Wu Fengguang wrote:

[..]
> +		if (dirty_exceeded && !bdi->dirty_exceeded)
>  			bdi->dirty_exceeded = 1;
>  
>  		bdi_update_bandwidth(bdi, dirty_thresh, background_thresh,
>  				     nr_dirty, bdi_thresh, bdi_dirty,
>  				     start_time);
>  
> -		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
> -		 * Unstable writes are a feature of certain networked
> -		 * filesystems (i.e. NFS) in which data may have been
> -		 * written to the server's write cache, but has not yet
> -		 * been flushed to permanent storage.
> -		 * Only move pages to writeback if this bdi is over its
> -		 * threshold otherwise wait until the disk writes catch
> -		 * up.
> -		 */
> -		trace_balance_dirty_start(bdi);
> -		if (bdi_nr_reclaimable > task_bdi_thresh) {
> -			pages_written += writeback_inodes_wb(&bdi->wb,
> -							     write_chunk);
> -			trace_balance_dirty_written(bdi, pages_written);
> -			if (pages_written >= write_chunk)
> -				break;		/* We've done our duty */
> +		if (unlikely(!writeback_in_progress(bdi)))
> +			bdi_start_background_writeback(bdi);
> +
> +		base_rate = bdi->dirty_ratelimit;
> +		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
> +					       background_thresh, nr_dirty,
> +					       bdi_thresh, bdi_dirty);
> +		if (unlikely(pos_ratio == 0)) {
> +			pause = MAX_PAUSE;
> +			goto pause;
>  		}
> +		task_ratelimit = (u64)base_rate *
> +					pos_ratio >> RATELIMIT_CALC_SHIFT;

Hi Fenguaang,

I am little confused here. I see that you have already taken pos_ratio
into account in bdi_update_dirty_ratelimit() and wondering why to take
that into account again in balance_diry_pages().

We calculated the pos_rate and balanced_rate and adjusted the
bdi->dirty_ratelimit accordingly in bdi_update_dirty_ratelimit().

So why are we adjusting this pos_ratio() adjusted limit again with
pos_ratio(). Doesn't it become effectively following (assuming
one is decreasing the dirty rate limit).

base_rate = bdi->dirty_ratelimit
pos_rate = base_rate * pos_ratio();

			  write_bw
balance_rate = pos_rate * --------
			  dirty_bw

delta = max(pos_rate, balance_rate)
bdi->dirty_ratelimit = bdi->dirty_ratelimit - delta;

task_ratelimit = bdi->dirty_ratelimit * pos_ratio().

So we have already taken into account pos_ratio() while calculating new
bdi->dirty_ratelimit. Do we need to take that into account again.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

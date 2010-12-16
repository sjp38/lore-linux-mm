Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4F66F6B0099
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 00:17:27 -0500 (EST)
Date: Thu, 16 Dec 2010 13:17:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 17/35] writeback: quit throttling when bdi dirty pages
 dropped low
Message-ID: <20101216051722.GA9093@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150328.407612632@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101213150328.407612632@intel.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch seems optional and won't improve things noticeably.
Even if we break out of the loop, the task will quickly return to
balance_dirty_pages() as long as the bdi is dirty_exceeded. So I'd
like to drop this patch for now.

Thanks,
Fengguang

On Mon, Dec 13, 2010 at 10:47:03PM +0800, Wu, Fengguang wrote:
> Tests show that bdi_thresh may take minutes to ramp up on a typical
> desktop. The time should be improvable but cannot be eliminated totally.
> So when (background_thresh + dirty_thresh)/2 is reached and
> balance_dirty_pages() starts to throttle the task, it will suddenly find
> the (still low and ramping up) bdi_thresh is exceeded _excessively_. Here
> we definitely don't want to stall the task for one minute (when it's
> writing to USB stick). So introduce an alternative way to break out of
> the loop when the bdi dirty/write pages has dropped by a reasonable
> amount.
> 
> It will at least pause for one loop before trying to break out.
> 
> The break is designed mainly to help the single task case. The break
> threshold is time for writing 125ms data, so that when the task slept
> for MAX_PAUSE=200ms, it will have good chance to break out. For NFS
> there may be only 1-2 completions of large COMMIT per second, in which
> case the task may still get stuck for 1s.
> 
> Note that this opens the chance that during normal operation, a huge
> number of slow dirtiers writing to a really slow device might manage to
> outrun bdi_thresh. But the risk is pretty low.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/page-writeback.c |   19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> --- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:16.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2010-12-13 21:46:16.000000000 +0800
> @@ -693,6 +693,7 @@ static void balance_dirty_pages(struct a
>  	long nr_dirty;
>  	long bdi_dirty;  /* = file_dirty + writeback + unstable_nfs */
>  	long avg_dirty;  /* smoothed bdi_dirty */
> +	long bdi_prev_dirty = 0;
>  	unsigned long background_thresh;
>  	unsigned long dirty_thresh;
>  	unsigned long bdi_thresh;
> @@ -749,6 +750,24 @@ static void balance_dirty_pages(struct a
>  
>  		bdi_update_bandwidth(bdi, start_time, bdi_dirty, bdi_thresh);
>  
> +		/*
> +		 * bdi_thresh takes time to ramp up from the initial 0,
> +		 * especially for slow devices.
> +		 *
> +		 * It's possible that at the moment dirty throttling starts,
> +		 *	bdi_dirty = nr_dirty
> +		 *		  = (background_thresh + dirty_thresh) / 2
> +		 *		  >> bdi_thresh
> +		 * Then the task could be blocked for many seconds to flush all
> +		 * the exceeded (bdi_dirty - bdi_thresh) pages. So offer a
> +		 * complementary way to break out of the loop when 125ms worth
> +		 * of dirty pages have been cleaned during our pause time.
> +		 */
> +		if (nr_dirty <= dirty_thresh &&
> +		    bdi_prev_dirty - bdi_dirty > (long)bdi->write_bandwidth / 8)
> +			break;
> +		bdi_prev_dirty = bdi_dirty;
> +
>  		avg_dirty = bdi->avg_dirty;
>  		if (avg_dirty < bdi_dirty || avg_dirty > task_thresh)
>  			avg_dirty = bdi_dirty;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

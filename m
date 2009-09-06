Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3612F6B0083
	for <linux-mm@kvack.org>; Sat,  5 Sep 2009 23:55:42 -0400 (EDT)
Date: Sun, 6 Sep 2009 11:55:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH] v2 mm: balance_dirty_pages.  reduce calls to
	global_page_state to reduce cache references
Message-ID: <20090906035537.GA16063@localhost>
References: <1252062330.2271.61.camel@castor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1252062330.2271.61.camel@castor>
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, "chris.mason" <chris.mason@oracle.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 04, 2009 at 07:05:30PM +0800, Richard Kennedy wrote:
> Reducing the number of times balance_dirty_pages calls global_page_state
> reduces the cache references and so improves write performance on a
> variety of workloads.
> 
> 'perf stats' of simple fio write tests shows the reduction in cache
> access.
> Where the test is fio 'write,mmap,600Mb,pre_read' on AMD AthlonX2 with
> 3Gb memory (dirty_threshold approx 600 Mb)
> running each test 10 times, dropping the fasted & slowest values then
> taking 
> the average & standard deviation
> 
> 		average (s.d.) in millions (10^6)
> 2.6.31-rc8	648.6 (14.6)
> +patch		620.1 (16.5)
> 
> Achieving this reduction is by dropping clip_bdi_dirty_limit as it  
> rereads the counters to apply the dirty_threshold and moving this check
> up into balance_dirty_pages where it has already read the counters.
> 
> Also by rearrange the for loop to only contain one copy of the limit
> tests allows the pdflush test after the loop to use the local copies of
> the counters rather than rereading them.
> 
> In the common case with no throttling it now calls global_page_state 5
> fewer times and bdi_stat 2 fewer.
> 
> This version includes the changes suggested by 
> Wu Fengguang <fengguang.wu@intel.com>

It seems that an redundant pages_written test can be reduced by

--- linux.orig/mm/page-writeback.c	2009-09-06 11:44:39.000000000 +0800
+++ linux/mm/page-writeback.c	2009-09-06 11:44:42.000000000 +0800
@@ -526,10 +526,6 @@ static void balance_dirty_pages(struct a
 		    (background_thresh + dirty_thresh) / 2)
 			break;
 
-		/* done enough? */
-		if (pages_written >= write_chunk)
-			break;
-
 		if (!bdi->dirty_exceeded)
 			bdi->dirty_exceeded = 1;
 
@@ -547,7 +543,7 @@ static void balance_dirty_pages(struct a
 			pages_written += write_chunk - wbc.nr_to_write;
 			/* don't wait if we've done enough */
 			if (pages_written >= write_chunk)
-				continue;
+				break;
 		}
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}

Otherwise the patch looks good to me. Thank you for the nice work!

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

> Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
> ----
> Thanks to everybody for the feedback & suggestions.
> This patch is against 2.6.31-rc8
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 81627eb..9581359 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -260,32 +260,6 @@ static void bdi_writeout_fraction(struct backing_dev_info *bdi,
>  	}
>  }
>  
> -/*
> - * Clip the earned share of dirty pages to that which is actually available.
> - * This avoids exceeding the total dirty_limit when the floating averages
> - * fluctuate too quickly.
> - */
> -static void clip_bdi_dirty_limit(struct backing_dev_info *bdi,
> -		unsigned long dirty, unsigned long *pbdi_dirty)
> -{
> -	unsigned long avail_dirty;
> -
> -	avail_dirty = global_page_state(NR_FILE_DIRTY) +
> -		 global_page_state(NR_WRITEBACK) +
> -		 global_page_state(NR_UNSTABLE_NFS) +
> -		 global_page_state(NR_WRITEBACK_TEMP);
> -
> -	if (avail_dirty < dirty)
> -		avail_dirty = dirty - avail_dirty;
> -	else
> -		avail_dirty = 0;
> -
> -	avail_dirty += bdi_stat(bdi, BDI_RECLAIMABLE) +
> -		bdi_stat(bdi, BDI_WRITEBACK);
> -
> -	*pbdi_dirty = min(*pbdi_dirty, avail_dirty);
> -}
> -
>  static inline void task_dirties_fraction(struct task_struct *tsk,
>  		long *numerator, long *denominator)
>  {
> @@ -478,7 +452,6 @@ get_dirty_limits(unsigned long *pbackground, unsigned long *pdirty,
>  			bdi_dirty = dirty * bdi->max_ratio / 100;
>  
>  		*pbdi_dirty = bdi_dirty;
> -		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
>  		task_dirty_limit(current, pbdi_dirty);
>  	}
>  }
> @@ -499,7 +472,7 @@ static void balance_dirty_pages(struct address_space *mapping)
>  	unsigned long bdi_thresh;
>  	unsigned long pages_written = 0;
>  	unsigned long write_chunk = sync_writeback_pages();
> -
> +	int dirty_exceeded;
>  	struct backing_dev_info *bdi = mapping->backing_dev_info;
>  
>  	for (;;) {
> @@ -512,16 +485,36 @@ static void balance_dirty_pages(struct address_space *mapping)
>  		};
>  
>  		get_dirty_limits(&background_thresh, &dirty_thresh,
> -				&bdi_thresh, bdi);
> +				 &bdi_thresh, bdi);
>  
>  		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> -					global_page_state(NR_UNSTABLE_NFS);
> -		nr_writeback = global_page_state(NR_WRITEBACK);
> +			global_page_state(NR_UNSTABLE_NFS);
> +		nr_writeback = global_page_state(NR_WRITEBACK) +
> +			global_page_state(NR_WRITEBACK_TEMP);
>  
> -		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> -		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> +		/*
> +		 * In order to avoid the stacked BDI deadlock we need
> +		 * to ensure we accurately count the 'dirty' pages when
> +		 * the threshold is low.
> +		 *
> +		 * Otherwise it would be possible to get thresh+n pages
> +		 * reported dirty, even though there are thresh-m pages
> +		 * actually dirty; with m+n sitting in the percpu
> +		 * deltas.
> +		 */
> +		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
> +			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
> +			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
> +		} else if (bdi_nr_reclaimable) {
> +			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> +			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> +		}
>  
> -		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> +		dirty_exceeded =
> +			(bdi_nr_reclaimable + bdi_nr_writeback >= bdi_thresh)
> +			|| (nr_reclaimable + nr_writeback >= dirty_thresh);
> +
> +		if (!dirty_exceeded)
>  			break;
>  
>  		/*
> @@ -530,7 +523,11 @@ static void balance_dirty_pages(struct address_space *mapping)
>  		 * when the bdi limits are ramping up.
>  		 */
>  		if (nr_reclaimable + nr_writeback <
> -				(background_thresh + dirty_thresh) / 2)
> +		    (background_thresh + dirty_thresh) / 2)
> +			break;
> +
> +		/* done enough? */
> +		if (pages_written >= write_chunk)
>  			break;
>  
>  		if (!bdi->dirty_exceeded)
> @@ -548,38 +545,14 @@ static void balance_dirty_pages(struct address_space *mapping)
>  		if (bdi_nr_reclaimable > bdi_thresh) {
>  			writeback_inodes(&wbc);
>  			pages_written += write_chunk - wbc.nr_to_write;
> -			get_dirty_limits(&background_thresh, &dirty_thresh,
> -				       &bdi_thresh, bdi);
> -		}
> -
> -		/*
> -		 * In order to avoid the stacked BDI deadlock we need
> -		 * to ensure we accurately count the 'dirty' pages when
> -		 * the threshold is low.
> -		 *
> -		 * Otherwise it would be possible to get thresh+n pages
> -		 * reported dirty, even though there are thresh-m pages
> -		 * actually dirty; with m+n sitting in the percpu
> -		 * deltas.
> -		 */
> -		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
> -			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
> -			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
> -		} else if (bdi_nr_reclaimable) {
> -			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> -			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> +			/* don't wait if we've done enough */
> +			if (pages_written >= write_chunk)
> +				continue;
>  		}
> -
> -		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> -			break;
> -		if (pages_written >= write_chunk)
> -			break;		/* We've done our duty */
> -
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  	}
>  
> -	if (bdi_nr_reclaimable + bdi_nr_writeback < bdi_thresh &&
> -			bdi->dirty_exceeded)
> +	if (!dirty_exceeded && bdi->dirty_exceeded)
>  		bdi->dirty_exceeded = 0;
>  
>  	if (writeback_in_progress(bdi))
> @@ -593,10 +566,8 @@ static void balance_dirty_pages(struct address_space *mapping)
>  	 * In normal mode, we start background writeout at the lower
>  	 * background_thresh, to keep the amount of dirty memory low.
>  	 */
> -	if ((laptop_mode && pages_written) ||
> -			(!laptop_mode && (global_page_state(NR_FILE_DIRTY)
> -					  + global_page_state(NR_UNSTABLE_NFS)
> -					  > background_thresh)))
> +	if ((laptop_mode && pages_written) || (!laptop_mode &&
> +	     (nr_reclaimable > background_thresh)))
>  		pdflush_operation(background_writeout, 0);
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

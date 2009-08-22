Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A96CF6B004D
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 22:52:02 -0400 (EDT)
Date: Sat, 22 Aug 2009 10:51:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: +
	mm-balance_dirty_pages-reduce-calls-to-global_page_state-to-reduce-c
	ache-references.patch added to -mm tree
Message-ID: <20090822025150.GB7798@localhost>
References: <200908212250.n7LMox3g029154@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200908212250.n7LMox3g029154@imap1.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "richard@rsk.demon.co.uk" <richard@rsk.demon.co.uk>, "a.p.zijlstra@chello.nl" <a.p.zijlstra@chello.nl>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "jens.axboe@oracle.com" <jens.axboe@oracle.com>, "mbligh@mbligh.org" <mbligh@mbligh.org>, "miklos@szeredi.hu" <miklos@szeredi.hu>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 22, 2009 at 06:50:59AM +0800, Andrew Morton wrote:
> 
> The patch titled
>      mm: balance_dirty_pages(): reduce calls to global_page_state to reduce cache references
> has been added to the -mm tree.  Its filename is
>      mm-balance_dirty_pages-reduce-calls-to-global_page_state-to-reduce-cache-references.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> See http://userweb.kernel.org/~akpm/stuff/added-to-mm.txt to find
> out what to do about this
> 
> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
> 
> ------------------------------------------------------
> Subject: mm: balance_dirty_pages(): reduce calls to global_page_state to reduce cache references
> From: Richard Kennedy <richard@rsk.demon.co.uk>
> 
> Reducing the number of times balance_dirty_pages calls global_page_state
> reduces the cache references and so improves write performance on a
> variety of workloads.
> 
> 'perf stats' of simple fio write tests shows the reduction in cache
> access.  Where the test is fio 'write,mmap,600Mb,pre_read' on AMD AthlonX2
> with 3Gb memory (dirty_threshold approx 600 Mb) running each test 10
> times, taking the average & standard deviation
> 
> 		average (s.d.) in millions (10^6)
> 2.6.31-rc6	661 (9.88)
> +patch		604 (4.19)
> 
> Achieving this reduction is by dropping clip_bdi_dirty_limit as it rereads
> the counters to apply the dirty_threshold and moving this check up into
> balance_dirty_pages where it has already read the counters.
> 
> Also by rearrange the for loop to only contain one copy of the limit tests
> allows the pdflush test after the loop to use the local copies of the
> counters rather than rereading then.
> 
> In the common case with no throttling it now calls global_page_state 5
> fewer times and bdi_stat 2 fewer.
> 
> I have tried to retain the existing behavior as much as possible, but have
> added NR_WRITEBACK_TEMP to nr_writeback.  This counter was used in
> clip_bdi_dirty_limit but not in balance_dirty_pages, grep suggests this is
> only used by FUSE but I haven't done any testing on that.  It does seem
> logical to count all the WRITEBACK pages when making the throttling
> decisions so this change should be more correct ;)
> 
> I have been running this patch for over a week and have had no problems
> with it and generally see improved disk write performance on a variety of
> tests & workloads, even in the worst cases performance is the same as the
> unpatched kernel.  I also tried this on a Intel ATOM 330 twincore system
> and saw similar improvements.
> 
> Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
> Cc: Chris Mason <chris.mason@oracle.com>
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Jens Axboe <jens.axboe@oracle.com>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Martin Bligh <mbligh@mbligh.org>
> Cc: Miklos Szeredi <miklos@szeredi.hu>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/page-writeback.c |  116 +++++++++++++++---------------------------
>  1 file changed, 43 insertions(+), 73 deletions(-)
> 
> diff -puN mm/page-writeback.c~mm-balance_dirty_pages-reduce-calls-to-global_page_state-to-reduce-cache-references mm/page-writeback.c
> --- a/mm/page-writeback.c~mm-balance_dirty_pages-reduce-calls-to-global_page_state-to-reduce-cache-references
> +++ a/mm/page-writeback.c
> @@ -249,32 +249,6 @@ static void bdi_writeout_fraction(struct
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
> @@ -465,7 +439,6 @@ get_dirty_limits(unsigned long *pbackgro
>  			bdi_dirty = dirty * bdi->max_ratio / 100;
>  
>  		*pbdi_dirty = bdi_dirty;
> -		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
>  		task_dirty_limit(current, pbdi_dirty);
>  	}
>  }
> @@ -499,45 +472,12 @@ static void balance_dirty_pages(struct a
>  		};
>  
>  		get_dirty_limits(&background_thresh, &dirty_thresh,
> -				&bdi_thresh, bdi);
> +				 &bdi_thresh, bdi);
>  
>  		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
> -					global_page_state(NR_UNSTABLE_NFS);
> -		nr_writeback = global_page_state(NR_WRITEBACK);
> -
> -		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
> -		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
> -
> -		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> -			break;
> -
> -		/*
> -		 * Throttle it only when the background writeback cannot
> -		 * catch-up. This avoids (excessively) small writeouts
> -		 * when the bdi limits are ramping up.
> -		 */
> -		if (nr_reclaimable + nr_writeback <
> -				(background_thresh + dirty_thresh) / 2)
> -			break;
> -
> -		if (!bdi->dirty_exceeded)
> -			bdi->dirty_exceeded = 1;
> -
> -		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
> -		 * Unstable writes are a feature of certain networked
> -		 * filesystems (i.e. NFS) in which data may have been
> -		 * written to the server's write cache, but has not yet
> -		 * been flushed to permanent storage.
> -		 * Only move pages to writeback if this bdi is over its
> -		 * threshold otherwise wait until the disk writes catch
> -		 * up.
> -		 */
> -		if (bdi_nr_reclaimable > bdi_thresh) {
> -			generic_sync_bdi_inodes(NULL, &wbc);
> -			pages_written += write_chunk - wbc.nr_to_write;
> -			get_dirty_limits(&background_thresh, &dirty_thresh,
> -				       &bdi_thresh, bdi);
> -		}
> +			global_page_state(NR_UNSTABLE_NFS);
> +		nr_writeback = global_page_state(NR_WRITEBACK) +
> +			global_page_state(NR_WRITEBACK_TEMP);
>  
>  		/*
>  		 * In order to avoid the stacked BDI deadlock we need
> @@ -557,16 +497,48 @@ static void balance_dirty_pages(struct a
>  			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
>  		}
>  
> -		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> -			break;
> -		if (pages_written >= write_chunk)
> -			break;		/* We've done our duty */

> +		/* always throttle if over threshold */
> +		if (nr_reclaimable + nr_writeback < dirty_thresh) {

That 'if' is a big behavior change. It effectively blocks every one
and canceled Peter's proportional throttling work: the less a process
dirtied, the less it should be throttled.

I'd propose to remove the above 'if' and liberate the following three 'if's.

> +
> +			if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> +				break;
> +
> +			/*
> +			 * Throttle it only when the background writeback cannot
> +			 * catch-up. This avoids (excessively) small writeouts
> +			 * when the bdi limits are ramping up.
> +			 */
> +			if (nr_reclaimable + nr_writeback <
> +			    (background_thresh + dirty_thresh) / 2)
> +				break;
> +
> +			/* done enough? */
> +			if (pages_written >= write_chunk)
> +				break;
> +		}
> +		if (!bdi->dirty_exceeded)
> +			bdi->dirty_exceeded = 1;
>  
> +		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
> +		 * Unstable writes are a feature of certain networked
> +		 * filesystems (i.e. NFS) in which data may have been
> +		 * written to the server's write cache, but has not yet
> +		 * been flushed to permanent storage.
> +		 * Only move pages to writeback if this bdi is over its
> +		 * threshold otherwise wait until the disk writes catch
> +		 * up.
> +		 */
> +		if (bdi_nr_reclaimable > bdi_thresh) {
> +			writeback_inodes(&wbc);
> +			pages_written += write_chunk - wbc.nr_to_write;

> +			if (wbc.nr_to_write == 0)
> +				continue;

What's the purpose of the above 2 lines?

Thanks,
Fengguang

> +		}
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  	}
>  
>  	if (bdi_nr_reclaimable + bdi_nr_writeback < bdi_thresh &&
> -			bdi->dirty_exceeded)
> +	    bdi->dirty_exceeded)
>  		bdi->dirty_exceeded = 0;
>  
>  	if (writeback_in_progress(bdi))
> @@ -580,10 +552,8 @@ static void balance_dirty_pages(struct a
>  	 * In normal mode, we start background writeout at the lower
>  	 * background_thresh, to keep the amount of dirty memory low.
>  	 */
> -	if ((laptop_mode && pages_written) ||
> -			(!laptop_mode && (global_page_state(NR_FILE_DIRTY)
> -					  + global_page_state(NR_UNSTABLE_NFS)
> -					  > background_thresh)))
> +	if ((laptop_mode && pages_written) || (!laptop_mode &&
> +	     (nr_reclaimable > background_thresh)))
>  		bdi_start_writeback(bdi, NULL, 0, WB_SYNC_NONE);
>  }
>  
> _
> 
> Patches currently in -mm which might be from richard@rsk.demon.co.uk are
> 
> mm-balance_dirty_pages-reduce-calls-to-global_page_state-to-reduce-cache-references.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

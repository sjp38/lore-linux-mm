Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id EA7C26B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 20:19:48 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ld10so1044408pab.34
        for <linux-mm@kvack.org>; Thu, 29 May 2014 17:19:48 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id cv2si3031817pbc.135.2014.05.29.17.19.46
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 17:19:47 -0700 (PDT)
Date: Fri, 30 May 2014 09:20:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140530002021.GM10092@bbox>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
 <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
 <20140529013007.GF6677@dastard>
 <20140529015830.GG6677@dastard>
 <20140529233638.GJ10092@bbox>
 <CA+55aFyvn_fTnWEmTCSGgfM18c21-YDU_s=FJP=grDDLQe+aDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyvn_fTnWEmTCSGgfM18c21-YDU_s=FJP=grDDLQe+aDA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

Hello Linus,

On Thu, May 29, 2014 at 05:05:17PM -0700, Linus Torvalds wrote:
> On Thu, May 29, 2014 at 4:36 PM, Minchan Kim <minchan@kernel.org> wrote:
> >
> > I did below hacky test to apply your idea and the result is overflow again.
> > So, again it would second stack expansion. Otherwise, we should prevent
> > swapout in direct reclaim.
> 
> So changing io_schedule() is bad, for the reasons I outlined elsewhere
> (we use it for wait_for_page*() - see sleep_on_page().
> 
> It's the congestion waiting where the io_schedule() should be avoided.
> 
> So maybe test a patch something like the attached.
> 
> NOTE! This is absolutely TOTALLY UNTESTED! It might do horrible
> horrible things. It seems to compile, but I have absolutely no reason
> to believe that it would work. I didn't actually test that this moves
> anything at all to kblockd. So think of it as a concept patch that
> *might* work, but as Dave said, there might also be other things that
> cause unplugging and need some tough love.
> 
>                    Linus

>  mm/backing-dev.c | 28 ++++++++++++++++++----------
>  mm/vmscan.c      |  4 +---
>  2 files changed, 19 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 09d9591b7708..cb26b24c2da2 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -11,6 +11,7 @@
>  #include <linux/writeback.h>
>  #include <linux/device.h>
>  #include <trace/events/writeback.h>
> +#include <linux/blkdev.h>
>  
>  static atomic_long_t bdi_seq = ATOMIC_LONG_INIT(0);
>  
> @@ -573,6 +574,21 @@ void set_bdi_congested(struct backing_dev_info *bdi, int sync)
>  }
>  EXPORT_SYMBOL(set_bdi_congested);
>  
> +static long congestion_timeout(int sync, long timeout)
> +{
> +	long ret;
> +	DEFINE_WAIT(wait);
> +	struct blk_plug *plug = current->plug;
> +	wait_queue_head_t *wqh = &congestion_wqh[sync];
> +
> +	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
> +	if (plug)
> +		blk_flush_plug_list(plug, true);
> +	ret = schedule_timeout(timeout);
> +	finish_wait(wqh, &wait);
> +	return ret;
> +}
> +
>  /**
>   * congestion_wait - wait for a backing_dev to become uncongested
>   * @sync: SYNC or ASYNC IO
> @@ -586,12 +602,8 @@ long congestion_wait(int sync, long timeout)
>  {
>  	long ret;
>  	unsigned long start = jiffies;
> -	DEFINE_WAIT(wait);
> -	wait_queue_head_t *wqh = &congestion_wqh[sync];
>  
> -	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
> -	ret = io_schedule_timeout(timeout);
> -	finish_wait(wqh, &wait);
> +	ret = congestion_timeout(sync,timeout);
>  
>  	trace_writeback_congestion_wait(jiffies_to_usecs(timeout),
>  					jiffies_to_usecs(jiffies - start));
> @@ -622,8 +634,6 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
>  {
>  	long ret;
>  	unsigned long start = jiffies;
> -	DEFINE_WAIT(wait);
> -	wait_queue_head_t *wqh = &congestion_wqh[sync];
>  
>  	/*
>  	 * If there is no congestion, or heavy congestion is not being
> @@ -643,9 +653,7 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
>  	}
>  
>  	/* Sleep until uncongested or a write happens */
> -	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
> -	ret = io_schedule_timeout(timeout);
> -	finish_wait(wqh, &wait);
> +	ret = congestion_timeout(sync, timeout);
>  
>  out:
>  	trace_writeback_wait_iff_congested(jiffies_to_usecs(timeout),
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 32c661d66a45..1e524000b83e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -989,9 +989,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			 * avoid risk of stack overflow but only writeback
>  			 * if many dirty pages have been encountered.
>  			 */
> -			if (page_is_file_cache(page) &&
> -					(!current_is_kswapd() ||
> -					 !zone_is_reclaim_dirty(zone))) {
> +			if (!current_is_kswapd() || !zone_is_reclaim_dirty(zone)) {
>  				/*
>  				 * Immediately reclaim when written back.
>  				 * Similar in principal to deactivate_page()

I guess this part which avoid swapout in direct reclaim would be key
if this patch were successful. But it could make anon pages rotate back
into inactive's head from tail in direct reclaim path until kswapd can
catch up. And kswapd kswapd can swap out anon pages from tail of inactive
LRU so I suspect it could make side-effect LRU churning.

Anyway, I will queue it into testing machine since Rusty's test is done.
Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

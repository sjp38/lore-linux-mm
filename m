Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DE0996B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 16:43:58 -0400 (EDT)
Date: Fri, 12 Aug 2011 22:43:49 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] writeback: Add a 'reason' to wb_writeback_work
Message-ID: <20110812204349.GA31255@quack.suse.cz>
References: <1313174707-4267-1-git-send-email-curtw@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313174707-4267-1-git-send-email-curtw@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri 12-08-11 11:45:06, Curt Wohlgemuth wrote:
> This creates a new 'reason' field in a wb_writeback_work
> structure, which unambiguously identifies who initiates
> writeback activity.  A 'wb_stats' enumeration has been added
> to writeback.h, to enumerate the possible reasons.
> 
> The 'writeback_work_class' tracepoint event class is updated
> to include the symbolic 'reason' in all trace events.
> 
> The 'writeback_queue_io' tracepoint now takes a work object,
> in order to print out the 'reason' for queue_io.
> 
> And the 'writeback_inodes_sbXXX' family of routines has had
> a wb_stats parameter added to them, so callers can specify
> why writeback is being started.
> 
> Signed-off-by: Curt Wohlgemuth <curtw@google.com>
  The patch looks good. Just two minor comments below. So you can
add:
  Acked-by: Jan Kara <jack@suse.cz>

> @@ -647,11 +651,12 @@ long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages)
>  		.nr_pages	= nr_pages,
>  		.sync_mode	= WB_SYNC_NONE,
>  		.range_cyclic	= 1,
> +		.reason		= WB_STAT_BALANCE_DIRTY,
>  	};
>  
>  	spin_lock(&wb->list_lock);
>  	if (list_empty(&wb->b_io))
> -		queue_io(wb, NULL);
> +		queue_io(wb, &work);
>  	__writeback_inodes_wb(wb, &work);
>  	spin_unlock(&wb->list_lock);
>  
  Umm, for consistency it would make more sense for writeback_inodes_wb()
to take reason argument as well. Also strictly speaking, this function has
two callers - balance_dirty_pages() and bdi_forker_thread()...

> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index d196074..53c995e 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -737,8 +737,9 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		 */
>  		trace_balance_dirty_start(bdi);
>  		if (bdi_nr_reclaimable > task_bdi_thresh) {
> -			pages_written += writeback_inodes_wb(&bdi->wb,
> -							     write_chunk);
> +			long wrote;
> +			wrote = writeback_inodes_wb(&bdi->wb, write_chunk);
> +			pages_written += wrote;
  What is this hunk for?

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

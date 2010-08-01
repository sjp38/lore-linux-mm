Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9DD8E600429
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 11:29:51 -0400 (EDT)
Received: by pzk33 with SMTP id 33so1294782pzk.14
        for <linux-mm@kvack.org>; Sun, 01 Aug 2010 08:29:39 -0700 (PDT)
Date: Mon, 2 Aug 2010 00:29:31 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/6] writeback: the kupdate expire timestamp should be
 a moving target
Message-ID: <20100801152931.GC8158@barrios-desktop>
References: <20100722050928.653312535@intel.com>
 <20100722061822.630779474@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722061822.630779474@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 01:09:30PM +0800, Wu Fengguang wrote:
> Dynamicly compute the dirty expire timestamp at queue_io() time.
> Also remove writeback_control.older_than_this which is no longer used.
> 
> writeback_control.older_than_this used to be determined at entrance to
> the kupdate writeback work. This _static_ timestamp may go stale if the
> kupdate work runs on and on. The flusher may then stuck with some old
> busy inodes, never considering newly expired inodes thereafter.
> 
> This has two possible problems:
> 
> - It is unfair for a large dirty inode to delay (for a long time) the
>   writeback of small dirty inodes.
> 
> - As time goes by, the large and busy dirty inode may contain only
>   _freshly_ dirtied pages. Ignoring newly expired dirty inodes risks
>   delaying the expired dirty pages to the end of LRU lists, triggering
>   the very bad pageout(). Neverthless this patch merely addresses part
>   of the problem.
> 
> CC: Jan Kara <jack@suse.cz>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c                |   24 +++++++++---------------
>  include/linux/writeback.h        |    2 --
>  include/trace/events/writeback.h |    6 +-----
>  mm/backing-dev.c                 |    1 -
>  mm/page-writeback.c              |    1 -
>  5 files changed, 10 insertions(+), 24 deletions(-)
> 
> --- linux-next.orig/fs/fs-writeback.c	2010-07-21 22:20:01.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2010-07-22 11:23:27.000000000 +0800
> @@ -216,16 +216,23 @@ static void move_expired_inodes(struct l
>  				struct list_head *dispatch_queue,
>  				struct writeback_control *wbc)
>  {
> +	unsigned long expire_interval = 0;
> +	unsigned long older_than_this;
>  	LIST_HEAD(tmp);
>  	struct list_head *pos, *node;
>  	struct super_block *sb = NULL;
>  	struct inode *inode;
>  	int do_sb_sort = 0;
>  
> +	if (wbc->for_kupdate) {
> +		expire_interval = msecs_to_jiffies(dirty_expire_interval * 10);
> +		older_than_this = jiffies - expire_interval;
> +	}
> +
>  	while (!list_empty(delaying_queue)) {
>  		inode = list_entry(delaying_queue->prev, struct inode, i_list);
> -		if (wbc->older_than_this &&
> -		    inode_dirtied_after(inode, *wbc->older_than_this))
> +		if (expire_interval &&
> +		    inode_dirtied_after(inode, older_than_this))
>  			break;
>  		if (sb && sb != inode->i_sb)
>  			do_sb_sort = 1;
> @@ -583,29 +590,19 @@ static inline bool over_bground_thresh(v
>   * Try to run once per dirty_writeback_interval.  But if a writeback event
>   * takes longer than a dirty_writeback_interval interval, then leave a
>   * one-second gap.
> - *
> - * older_than_this takes precedence over nr_to_write.  So we'll only write back
> - * all dirty pages if they are all attached to "old" mappings.
>   */
>  static long wb_writeback(struct bdi_writeback *wb,
>  			 struct wb_writeback_work *work)
>  {
>  	struct writeback_control wbc = {
>  		.sync_mode		= work->sync_mode,
> -		.older_than_this	= NULL,
>  		.for_kupdate		= work->for_kupdate,
>  		.for_background		= work->for_background,
>  		.range_cyclic		= work->range_cyclic,
>  	};
> -	unsigned long oldest_jif;
>  	long wrote = 0;
>  	struct inode *inode;
>  
> -	if (wbc.for_kupdate) {
> -		wbc.older_than_this = &oldest_jif;
> -		oldest_jif = jiffies -
> -				msecs_to_jiffies(dirty_expire_interval * 10);
> -	}
>  	if (!wbc.range_cyclic) {
>  		wbc.range_start = 0;
>  		wbc.range_end = LLONG_MAX;
> @@ -998,9 +995,6 @@ EXPORT_SYMBOL(__mark_inode_dirty);
>   * Write out a superblock's list of dirty inodes.  A wait will be performed
>   * upon no inodes, all inodes or the final one, depending upon sync_mode.
>   *
> - * If older_than_this is non-NULL, then only write out inodes which
> - * had their first dirtying at a time earlier than *older_than_this.
> - *
>   * If `bdi' is non-zero then we're being asked to writeback a specific queue.
>   * This function assumes that the blockdev superblock's inodes are backed by
>   * a variety of queues, so all inodes are searched.  For other superblocks,
> --- linux-next.orig/include/linux/writeback.h	2010-07-21 22:20:02.000000000 +0800
> +++ linux-next/include/linux/writeback.h	2010-07-22 11:23:27.000000000 +0800
> @@ -28,8 +28,6 @@ enum writeback_sync_modes {
>   */
>  struct writeback_control {
>  	enum writeback_sync_modes sync_mode;
> -	unsigned long *older_than_this;	/* If !NULL, only write back inodes
> -					   older than this */
>  	unsigned long wb_start;         /* Time writeback_inodes_wb was
>  					   called. This is needed to avoid
>  					   extra jobs and livelock */

In addtion, We shuld remove older_than_this in btrfs and reiser4. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

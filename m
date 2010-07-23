Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 82A89600365
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 14:16:58 -0400 (EDT)
Date: Fri, 23 Jul 2010 20:16:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/6] writeback: pass writeback_control down to
 move_expired_inodes()
Message-ID: <20100723181629.GD20540@quack.suse.cz>
References: <20100722050928.653312535@intel.com>
 <20100722061822.484666925@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722061822.484666925@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 22-07-10 13:09:29, Wu Fengguang wrote:
> This is to prepare for moving the dirty expire policy to move_expired_inodes().
> No behavior change.
  Looks OK.

Acked-by: Jan Kara <jack@suse.cz>

> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c |   16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> --- linux-next.orig/fs/fs-writeback.c	2010-07-21 20:12:38.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2010-07-21 20:14:38.000000000 +0800
> @@ -213,8 +213,8 @@ static bool inode_dirtied_after(struct i
>   * Move expired dirty inodes from @delaying_queue to @dispatch_queue.
>   */
>  static void move_expired_inodes(struct list_head *delaying_queue,
> -			       struct list_head *dispatch_queue,
> -				unsigned long *older_than_this)
> +				struct list_head *dispatch_queue,
> +				struct writeback_control *wbc)
>  {
>  	LIST_HEAD(tmp);
>  	struct list_head *pos, *node;
> @@ -224,8 +224,8 @@ static void move_expired_inodes(struct l
>  
>  	while (!list_empty(delaying_queue)) {
>  		inode = list_entry(delaying_queue->prev, struct inode, i_list);
> -		if (older_than_this &&
> -		    inode_dirtied_after(inode, *older_than_this))
> +		if (wbc->older_than_this &&
> +		    inode_dirtied_after(inode, *wbc->older_than_this))
>  			break;
>  		if (sb && sb != inode->i_sb)
>  			do_sb_sort = 1;
> @@ -257,10 +257,10 @@ static void move_expired_inodes(struct l
>   *                 => b_more_io inodes
>   *                 => remaining inodes in b_io => (dequeue for sync)
>   */
> -static void queue_io(struct bdi_writeback *wb, unsigned long *older_than_this)
> +static void queue_io(struct bdi_writeback *wb, struct writeback_control *wbc)
>  {
>  	list_splice_init(&wb->b_more_io, &wb->b_io);
> -	move_expired_inodes(&wb->b_dirty, &wb->b_io, older_than_this);
> +	move_expired_inodes(&wb->b_dirty, &wb->b_io, wbc);
>  }
>  
>  static int write_inode(struct inode *inode, struct writeback_control *wbc)
> @@ -519,7 +519,7 @@ void writeback_inodes_wb(struct bdi_writ
>  	wbc->wb_start = jiffies; /* livelock avoidance */
>  	spin_lock(&inode_lock);
>  	if (!wbc->for_kupdate || list_empty(&wb->b_io))
> -		queue_io(wb, wbc->older_than_this);
> +		queue_io(wb, wbc);
>  
>  	while (!list_empty(&wb->b_io)) {
>  		struct inode *inode = list_entry(wb->b_io.prev,
> @@ -548,7 +548,7 @@ static void __writeback_inodes_sb(struct
>  	wbc->wb_start = jiffies; /* livelock avoidance */
>  	spin_lock(&inode_lock);
>  	if (!wbc->for_kupdate || list_empty(&wb->b_io))
> -		queue_io(wb, wbc->older_than_this);
> +		queue_io(wb, wbc);
>  	writeback_sb_inodes(sb, wb, wbc, true);
>  	spin_unlock(&inode_lock);
>  }
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

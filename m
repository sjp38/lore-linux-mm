Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8156006B6
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 06:57:54 -0400 (EDT)
Date: Mon, 26 Jul 2010 11:57:37 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/6] writeback: sync expired inodes first in background
	writeback
Message-ID: <20100726105736.GM5300@csn.ul.ie>
References: <20100722050928.653312535@intel.com> <20100722061822.906037624@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100722061822.906037624@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 01:09:32PM +0800, Wu Fengguang wrote:
> A background flush work may run for ever. So it's reasonable for it to
> mimic the kupdate behavior of syncing old/expired inodes first.
> 
> The policy is
> - enqueue all newly expired inodes at each queue_io() time
> - retry with halfed expire interval until get some inodes to sync
> 
> CC: Jan Kara <jack@suse.cz>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Ok, intuitively this would appear to tie into pageout where we want
older inodes to be cleaned first by background flushers to limit the
number of dirty pages encountered by page reclaim. If this is accurate,
it should be detailed in the changelog.

> ---
>  fs/fs-writeback.c |   20 ++++++++++++++------
>  1 file changed, 14 insertions(+), 6 deletions(-)
> 
> --- linux-next.orig/fs/fs-writeback.c	2010-07-22 12:56:42.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2010-07-22 13:07:51.000000000 +0800
> @@ -217,14 +217,14 @@ static void move_expired_inodes(struct l
>  				struct writeback_control *wbc)
>  {
>  	unsigned long expire_interval = 0;
> -	unsigned long older_than_this;
> +	unsigned long older_than_this = 0; /* reset to kill gcc warning */
>  	LIST_HEAD(tmp);
>  	struct list_head *pos, *node;
>  	struct super_block *sb = NULL;
>  	struct inode *inode;
>  	int do_sb_sort = 0;
>  
> -	if (wbc->for_kupdate) {
> +	if (wbc->for_kupdate || wbc->for_background) {
>  		expire_interval = msecs_to_jiffies(dirty_expire_interval * 10);
>  		older_than_this = jiffies - expire_interval;
>  	}
> @@ -232,8 +232,15 @@ static void move_expired_inodes(struct l
>  	while (!list_empty(delaying_queue)) {
>  		inode = list_entry(delaying_queue->prev, struct inode, i_list);
>  		if (expire_interval &&
> -		    inode_dirtied_after(inode, older_than_this))
> -			break;
> +		    inode_dirtied_after(inode, older_than_this)) {
> +			if (wbc->for_background &&
> +			    list_empty(dispatch_queue) && list_empty(&tmp)) {
> +				expire_interval >>= 1;
> +				older_than_this = jiffies - expire_interval;
> +				continue;
> +			} else
> +				break;
> +		}

This needs a comment.

I think what it is saying is that if background flush is active but no
inodes are old enough, consider newer inodes. This is on the assumption
that page reclaim has encountered dirty pages and the dirty inodes are
still too young.

>  		if (sb && sb != inode->i_sb)
>  			do_sb_sort = 1;
>  		sb = inode->i_sb;
> @@ -521,7 +528,8 @@ void writeback_inodes_wb(struct bdi_writ
>  
>  	wbc->wb_start = jiffies; /* livelock avoidance */
>  	spin_lock(&inode_lock);
> -	if (!wbc->for_kupdate || list_empty(&wb->b_io))
> +
> +	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
>  		queue_io(wb, wbc);
>  
>  	while (!list_empty(&wb->b_io)) {
> @@ -550,7 +558,7 @@ static void __writeback_inodes_sb(struct
>  
>  	wbc->wb_start = jiffies; /* livelock avoidance */
>  	spin_lock(&inode_lock);
> -	if (!wbc->for_kupdate || list_empty(&wb->b_io))
> +	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
>  		queue_io(wb, wbc);
>  	writeback_sb_inodes(sb, wb, wbc, true);
>  	spin_unlock(&inode_lock);
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

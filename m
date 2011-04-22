Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B2FEC8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 17:13:09 -0400 (EDT)
Date: Fri, 22 Apr 2011 23:12:55 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110422211255.GB2977@quack.suse.cz>
References: <20110419125616.GA20059@localhost>
 <20110420012120.GK23985@dastard>
 <20110420025321.GA14398@localhost>
 <20110421004547.GD1814@dastard>
 <20110421020617.GB12191@localhost>
 <20110421030152.GG1814@dastard>
 <20110421035954.GA15461@localhost>
 <20110421041010.GA18710@localhost>
 <20110421160405.GB4476@quack.suse.cz>
 <20110422022459.GA6199@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110422022459.GA6199@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri 22-04-11 10:24:59, Wu Fengguang wrote:
> > 2) The intention of both bdi_flush_io() and balance_dirty_pages() is to
> > write .nr_to_write pages. So they should either do queue_io()
> > unconditionally (I kind of like that for simplicity) or they should requeue
> > once if they have not written enough - otherwise it could happen that they
> > are called just at the moment when b_io contains a single inode with a few
> > dirty pages and they end up doing almost nothing.
> 
> It makes much more sense to keep the policy consistent. When the
> flusher and the throttled tasks are both actively manipulating the
> shared lists but in different ways, how are we going to analyze the
> resulted mixture behavior?
> 
> Note that bdi_flush_io() and balance_dirty_pages() both have outer
> loops to retry writeout, so smallish b_io is not a problem at all.
  Well, it changes how balance_dirty_pages() behaves in some corner cases
(I'm not that much concerned about bdi_flush_io() because that is a last
resort thing anyway). But I see your point in consistency as well.

> > 3) I guess your patch does not compile because queue_io() is static ;).
> 
> Yeah, good spot~ :) Here is the updated patch. I feel like moving
> bdi_flush_io() to fs-writeback.c rather than exporting the low level
> queue_io() (and enable others to conveniently change the queue policy!).
> 
> balance_dirty_pages() cannot be moved.. so I plan to submit it after
> any IO-less merges. It's a cleanup patch after all.
Can't we just have a wrapper in fs/fs-writeback.c that will do:
     spin_lock(&bdi->wb.list_lock);
     if (list_empty(&bdi->wb.b_io))
             queue_io(&bdi->wb, &wbc);
     writeback_inodes_wb(&bdi->wb, &wbc);
     spin_unlock(&bdi->wb.list_lock);

And call it wherever we need? We can then also unexport
writeback_inodes_wb() which is not really a function someone would want to
call externally after your changes.

								Honza
> ---
> Subject: writeback: move queue_io() up
> Date: Thu Apr 21 12:06:32 CST 2011
> 
> Refactor code for more logical code layout.
> No behavior change. 
> 
> - kill __writeback_inodes_sb()
> - move bdi_flush_io() to fs-writeback.c
> - elevate queue_io() and locking up to wb_writeback() and bdi_flush_io()
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c         |   33 ++++++++++++++++++---------------
>  include/linux/writeback.h |    1 +
>  mm/backing-dev.c          |   12 ------------
>  3 files changed, 19 insertions(+), 27 deletions(-)
> 
> --- linux-next.orig/fs/fs-writeback.c	2011-04-21 20:11:53.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2011-04-21 21:11:02.000000000 +0800
> @@ -577,10 +577,6 @@ void writeback_inodes_wb(struct bdi_writ
>  
>  	if (!wbc->wb_start)
>  		wbc->wb_start = jiffies; /* livelock avoidance */
> -	spin_lock(&wb->list_lock);
> -
> -	if (list_empty(&wb->b_io))
> -		queue_io(wb, wbc);
>  
>  	while (!list_empty(&wb->b_io)) {
>  		struct inode *inode = wb_inode(wb->b_io.prev);
> @@ -596,20 +592,23 @@ void writeback_inodes_wb(struct bdi_writ
>  		if (ret)
>  			break;
>  	}
> -	spin_unlock(&wb->list_lock);
>  	/* Leave any unwritten inodes on b_io */
>  }
>  
> -static void __writeback_inodes_sb(struct super_block *sb,
> -		struct bdi_writeback *wb, struct writeback_control *wbc)
> +void bdi_flush_io(struct backing_dev_info *bdi)
>  {
> -	WARN_ON(!rwsem_is_locked(&sb->s_umount));
> +	struct writeback_control wbc = {
> +		.sync_mode		= WB_SYNC_NONE,
> +		.older_than_this	= NULL,
> +		.range_cyclic		= 1,
> +		.nr_to_write		= 1024,
> +	};
>  
> -	spin_lock(&wb->list_lock);
> -	if (list_empty(&wb->b_io))
> -		queue_io(wb, wbc);
> -	writeback_sb_inodes(sb, wb, wbc, true);
> -	spin_unlock(&wb->list_lock);
> +	spin_lock(&bdi->wb.list_lock);
> +	if (list_empty(&bdi->wb.b_io))
> +		queue_io(&bdi->wb, &wbc);
> +	writeback_inodes_wb(&bdi->wb, &wbc);
> +	spin_unlock(&bdi->wb.list_lock);
>  }
>  
>  /*
> @@ -674,7 +673,7 @@ static long wb_writeback(struct bdi_writ
>  	 * The intended call sequence for WB_SYNC_ALL writeback is:
>  	 *
>  	 *      wb_writeback()
> -	 *          __writeback_inodes_sb()     <== called only once
> +	 *          writeback_sb_inodes()       <== called only once
>  	 *              write_cache_pages()     <== called once for each inode
>  	 *                   (quickly) tag currently dirty pages
>  	 *                   (maybe slowly) sync all tagged pages
> @@ -722,10 +721,14 @@ static long wb_writeback(struct bdi_writ
>  
>  retry:
>  		trace_wbc_writeback_start(&wbc, wb->bdi);
> +		spin_lock(&wb->list_lock);
> +		if (list_empty(&wb->b_io))
> +			queue_io(wb, &wbc);
>  		if (work->sb)
> -			__writeback_inodes_sb(work->sb, wb, &wbc);
> +			writeback_sb_inodes(work->sb, wb, &wbc, true);
>  		else
>  			writeback_inodes_wb(wb, &wbc);
> +		spin_unlock(&wb->list_lock);
>  		trace_wbc_writeback_written(&wbc, wb->bdi);
>  
>  		work->nr_pages -= write_chunk - wbc.nr_to_write;
> --- linux-next.orig/mm/backing-dev.c	2011-04-21 20:11:52.000000000 +0800
> +++ linux-next/mm/backing-dev.c	2011-04-21 20:16:15.000000000 +0800
> @@ -260,18 +260,6 @@ int bdi_has_dirty_io(struct backing_dev_
>  	return wb_has_dirty_io(&bdi->wb);
>  }
>  
> -static void bdi_flush_io(struct backing_dev_info *bdi)
> -{
> -	struct writeback_control wbc = {
> -		.sync_mode		= WB_SYNC_NONE,
> -		.older_than_this	= NULL,
> -		.range_cyclic		= 1,
> -		.nr_to_write		= 1024,
> -	};
> -
> -	writeback_inodes_wb(&bdi->wb, &wbc);
> -}
> -
>  /*
>   * kupdated() used to do this. We cannot do it from the bdi_forker_thread()
>   * or we risk deadlocking on ->s_umount. The longer term solution would be
> --- linux-next.orig/include/linux/writeback.h	2011-04-21 20:20:20.000000000 +0800
> +++ linux-next/include/linux/writeback.h	2011-04-21 21:10:29.000000000 +0800
> @@ -56,6 +56,7 @@ struct writeback_control {
>   */	
>  struct bdi_writeback;
>  int inode_wait(void *);
> +void bdi_flush_io(struct backing_dev_info *bdi);
>  void writeback_inodes_sb(struct super_block *);
>  void writeback_inodes_sb_nr(struct super_block *, unsigned long nr);
>  int writeback_inodes_sb_if_idle(struct super_block *);
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

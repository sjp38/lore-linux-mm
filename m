Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D4B6B8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:04:13 -0400 (EDT)
Date: Thu, 21 Apr 2011 18:04:05 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110421160405.GB4476@quack.suse.cz>
References: <20110419073523.GF23985@dastard>
 <20110419095740.GC5257@quack.suse.cz>
 <20110419125616.GA20059@localhost>
 <20110420012120.GK23985@dastard>
 <20110420025321.GA14398@localhost>
 <20110421004547.GD1814@dastard>
 <20110421020617.GB12191@localhost>
 <20110421030152.GG1814@dastard>
 <20110421035954.GA15461@localhost>
 <20110421041010.GA18710@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110421041010.GA18710@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu 21-04-11 12:10:11, Wu Fengguang wrote:
> > > Still, given wb_writeback() is the only caller of both
> > > __writeback_inodes_sb and writeback_inodes_wb(), I'm wondering if
> > > moving the queue_io calls up into wb_writeback() would clean up this
> > > logic somewhat. I think Jan mentioned doing something like this as
> > > well elsewhere in the thread...
> > 
> > Unfortunately they call queue_io() inside the lock..
> 
> OK, let's try moving up the lock too. Do you like this change? :)
> 
> Thanks,
> Fengguang
> ---
>  fs/fs-writeback.c |   22 ++++++----------------
>  mm/backing-dev.c  |    4 ++++
>  2 files changed, 10 insertions(+), 16 deletions(-)
> 
> --- linux-next.orig/fs/fs-writeback.c	2011-04-21 12:04:02.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2011-04-21 12:05:54.000000000 +0800
> @@ -591,7 +591,6 @@ void writeback_inodes_wb(struct bdi_writ
>  
>  	if (!wbc->wb_start)
>  		wbc->wb_start = jiffies; /* livelock avoidance */
> -	spin_lock(&inode_wb_list_lock);
>  
>  	if (list_empty(&wb->b_io))
>  		queue_io(wb, wbc);
> @@ -610,22 +609,9 @@ void writeback_inodes_wb(struct bdi_writ
>  		if (ret)
>  			break;
>  	}
> -	spin_unlock(&inode_wb_list_lock);
>  	/* Leave any unwritten inodes on b_io */
>  }
>  
> -static void __writeback_inodes_sb(struct super_block *sb,
> -		struct bdi_writeback *wb, struct writeback_control *wbc)
> -{
> -	WARN_ON(!rwsem_is_locked(&sb->s_umount));
> -
> -	spin_lock(&inode_wb_list_lock);
> -	if (list_empty(&wb->b_io))
> -		queue_io(wb, wbc);
> -	writeback_sb_inodes(sb, wb, wbc, true);
> -	spin_unlock(&inode_wb_list_lock);
> -}
> -
>  static inline bool over_bground_thresh(void)
>  {
>  	unsigned long background_thresh, dirty_thresh;
> @@ -652,7 +638,7 @@ static unsigned long writeback_chunk_siz
>  	 * The intended call sequence for WB_SYNC_ALL writeback is:
>  	 *
>  	 *      wb_writeback()
> -	 *          __writeback_inodes_sb()     <== called only once
> +	 *          writeback_sb_inodes()       <== called only once
>  	 *              write_cache_pages()     <== called once for each inode
>  	 *                  (quickly) tag currently dirty pages
>  	 *                  (maybe slowly) sync all tagged pages
> @@ -742,10 +728,14 @@ static long wb_writeback(struct bdi_writ
>  
>  retry:
>  		trace_wbc_writeback_start(&wbc, wb->bdi);
> +		spin_lock(&inode_wb_list_lock);
> +		if (list_empty(&wb->b_io))
> +			queue_io(wb, wbc);
>  		if (work->sb)
> -			__writeback_inodes_sb(work->sb, wb, &wbc);
> +			writeback_sb_inodes(work->sb, wb, &wbc, true);
>  		else
>  			writeback_inodes_wb(wb, &wbc);
> +		spin_unlock(&inode_wb_list_lock);
>  		trace_wbc_writeback_written(&wbc, wb->bdi);
>  
>  		bdi_update_write_bandwidth(wb->bdi, wbc.wb_start);
> --- linux-next.orig/mm/backing-dev.c	2011-04-21 12:06:02.000000000 +0800
> +++ linux-next/mm/backing-dev.c	2011-04-21 12:06:31.000000000 +0800
> @@ -268,7 +268,11 @@ static void bdi_flush_io(struct backing_
>  		.nr_to_write		= 1024,
>  	};
>  
> +	spin_lock(&inode_wb_list_lock);
> +	if (list_empty(&wb->b_io))
> +		queue_io(wb, wbc);
>  	writeback_inodes_wb(&bdi->wb, &wbc);
> +	spin_unlock(&inode_wb_list_lock);
>  }
  Three notes here:
1) You are missing the call to writeback_inodes_wb() in
balance_dirty_pages() (the patch should really work for vanilla kernels).
2) The intention of both bdi_flush_io() and balance_dirty_pages() is to
write .nr_to_write pages. So they should either do queue_io()
unconditionally (I kind of like that for simplicity) or they should requeue
once if they have not written enough - otherwise it could happen that they
are called just at the moment when b_io contains a single inode with a few
dirty pages and they end up doing almost nothing.
3) I guess your patch does not compile because queue_io() is static ;).

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

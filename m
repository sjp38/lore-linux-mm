Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8FD9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:30:14 -0400 (EDT)
Date: Tue, 26 Apr 2011 16:30:07 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110426143007.GC5114@quack.suse.cz>
References: <20110420025321.GA14398@localhost>
 <20110421004547.GD1814@dastard>
 <20110421020617.GB12191@localhost>
 <20110421030152.GG1814@dastard>
 <20110421035954.GA15461@localhost>
 <20110421041010.GA18710@localhost>
 <20110421160405.GB4476@quack.suse.cz>
 <20110422022459.GA6199@localhost>
 <20110422211255.GB2977@quack.suse.cz>
 <20110426053706.GA17262@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110426053706.GA17262@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue 26-04-11 13:37:06, Wu Fengguang wrote:
> On Sat, Apr 23, 2011 at 05:12:55AM +0800, Jan Kara wrote:
> > On Fri 22-04-11 10:24:59, Wu Fengguang wrote:
> > > > 2) The intention of both bdi_flush_io() and balance_dirty_pages() is to
> > > > write .nr_to_write pages. So they should either do queue_io()
> > > > unconditionally (I kind of like that for simplicity) or they should requeue
> > > > once if they have not written enough - otherwise it could happen that they
> > > > are called just at the moment when b_io contains a single inode with a few
> > > > dirty pages and they end up doing almost nothing.
> > > 
> > > It makes much more sense to keep the policy consistent. When the
> > > flusher and the throttled tasks are both actively manipulating the
> > > shared lists but in different ways, how are we going to analyze the
> > > resulted mixture behavior?
> > > 
> > > Note that bdi_flush_io() and balance_dirty_pages() both have outer
> > > loops to retry writeout, so smallish b_io is not a problem at all.
> >   Well, it changes how balance_dirty_pages() behaves in some corner cases
> > (I'm not that much concerned about bdi_flush_io() because that is a last
> > resort thing anyway). But I see your point in consistency as well.
> > 
> > > > 3) I guess your patch does not compile because queue_io() is static ;).
> > > 
> > > Yeah, good spot~ :) Here is the updated patch. I feel like moving
> > > bdi_flush_io() to fs-writeback.c rather than exporting the low level
> > > queue_io() (and enable others to conveniently change the queue policy!).
> > > 
> > > balance_dirty_pages() cannot be moved.. so I plan to submit it after
> > > any IO-less merges. It's a cleanup patch after all.
> > Can't we just have a wrapper in fs/fs-writeback.c that will do:
> >      spin_lock(&bdi->wb.list_lock);
> >      if (list_empty(&bdi->wb.b_io))
> >              queue_io(&bdi->wb, &wbc);
> >      writeback_inodes_wb(&bdi->wb, &wbc);
> >      spin_unlock(&bdi->wb.list_lock);
> > 
> > And call it wherever we need? We can then also unexport
> > writeback_inodes_wb() which is not really a function someone would want to
> > call externally after your changes.
> 
> OK, this avoids the need to move bdi_flush_io(). Here is the updated
> patch, do you see any more problems?
  Yes, with this patch I think your change to the queueing logic is OK.
Thanks.

								Honza
> 
> Thanks,
> Fengguang
> ---
> Subject: writeback: elevate queue_io() into wb_writeback()
> Date: Thu Apr 21 12:06:32 CST 2011
> 
> Code refactor for more logical code layout.
> No behavior change.
> 
> - remove the mis-named __writeback_inodes_sb()
> 
> - wb_writeback()/writeback_inodes_wb() will decide when to queue_io()
>   before calling __writeback_inodes_wb()
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c |   27 ++++++++++++---------------
>  1 file changed, 12 insertions(+), 15 deletions(-)
> 
> --- linux-next.orig/fs/fs-writeback.c	2011-04-26 13:20:17.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2011-04-26 13:30:19.000000000 +0800
> @@ -570,17 +570,13 @@ static int writeback_sb_inodes(struct su
>  	return 1;
>  }
>  
> -void writeback_inodes_wb(struct bdi_writeback *wb,
> -		struct writeback_control *wbc)
> +static void __writeback_inodes_wb(struct bdi_writeback *wb,
> +				  struct writeback_control *wbc)
>  {
>  	int ret = 0;
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
> @@ -596,19 +592,16 @@ void writeback_inodes_wb(struct bdi_writ
>  		if (ret)
>  			break;
>  	}
> -	spin_unlock(&wb->list_lock);
>  	/* Leave any unwritten inodes on b_io */
>  }
>  
> -static void __writeback_inodes_sb(struct super_block *sb,
> -		struct bdi_writeback *wb, struct writeback_control *wbc)
> +void writeback_inodes_wb(struct bdi_writeback *wb,
> +		struct writeback_control *wbc)
>  {
> -	WARN_ON(!rwsem_is_locked(&sb->s_umount));
> -
>  	spin_lock(&wb->list_lock);
>  	if (list_empty(&wb->b_io))
>  		queue_io(wb, wbc);
> -	writeback_sb_inodes(sb, wb, wbc, true);
> +	__writeback_inodes_wb(wb, wbc);
>  	spin_unlock(&wb->list_lock);
>  }
>  
> @@ -674,7 +667,7 @@ static long wb_writeback(struct bdi_writ
>  	 * The intended call sequence for WB_SYNC_ALL writeback is:
>  	 *
>  	 *      wb_writeback()
> -	 *          __writeback_inodes_sb()     <== called only once
> +	 *          writeback_sb_inodes()       <== called only once
>  	 *              write_cache_pages()     <== called once for each inode
>  	 *                   (quickly) tag currently dirty pages
>  	 *                   (maybe slowly) sync all tagged pages
> @@ -722,10 +715,14 @@ static long wb_writeback(struct bdi_writ
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
> -			writeback_inodes_wb(wb, &wbc);
> +			__writeback_inodes_wb(wb, &wbc);
> +		spin_unlock(&wb->list_lock);
>  		trace_wbc_writeback_written(&wbc, wb->bdi);
>  
>  		work->nr_pages -= write_chunk - wbc.nr_to_write;
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

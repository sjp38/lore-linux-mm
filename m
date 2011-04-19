Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 889028D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 07:09:21 -0400 (EDT)
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.221.2])
	by mx2.suse.de (Postfix) with ESMTP id A50D786391
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 12:42:39 +0200 (CEST)
Date: Tue, 19 Apr 2011 11:47:24 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/6] writeback: introduce
 writeback_control.inodes_cleaned
Message-ID: <20110419094724.GB5257@quack.suse.cz>
References: <20110419030003.108796967@intel.com>
 <20110419030532.638670778@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419030532.638670778@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue 19-04-11 11:00:07, Wu Fengguang wrote:
> The flusher works on dirty inodes in batches, and may quit prematurely
> if the batch of inodes happen to be metadata-only dirtied: in this case
> wbc->nr_to_write won't be decreased at all, which stands for "no pages
> written" but also mis-interpreted as "no progress".
> 
> So introduce writeback_control.inodes_cleaned to count the inodes get
> cleaned.  A non-zero value means there are some progress on writeback,
> in which case more writeback can be tried.
> 
> about v1: The initial version was to count successful ->write_inode()
> calls.  However it leads to busy loops for sync() over NFS, because NFS
> ridiculously returns 0 (success) while at the same time redirties the
> inode.  The NFS case can be trivially fixed, however there may be more
> hidden bugs in other filesystems..
  OK, makes sense.
Acked-by: Jan Kara <jack@suse.cz>

								Honza
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c         |    4 ++++
>  include/linux/writeback.h |    1 +
>  2 files changed, 5 insertions(+)
> 
> --- linux-next.orig/fs/fs-writeback.c	2011-04-19 10:18:30.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2011-04-19 10:18:30.000000000 +0800
> @@ -473,6 +473,7 @@ writeback_single_inode(struct inode *ino
>  			 * No need to add it back to the LRU.
>  			 */
>  			list_del_init(&inode->i_wb_list);
> +			wbc->inodes_cleaned++;
>  		}
>  	}
>  	inode_sync_complete(inode);
> @@ -736,6 +737,7 @@ static long wb_writeback(struct bdi_writ
>  		wbc.more_io = 0;
>  		wbc.nr_to_write = write_chunk;
>  		wbc.pages_skipped = 0;
> +		wbc.inodes_cleaned = 0;
>  
>  		trace_wbc_writeback_start(&wbc, wb->bdi);
>  		if (work->sb)
> @@ -752,6 +754,8 @@ static long wb_writeback(struct bdi_writ
>  		 */
>  		if (wbc.nr_to_write <= 0)
>  			continue;
> +		if (wbc.inodes_cleaned)
> +			continue;
>  		/*
>  		 * Didn't write everything and we don't have more IO, bail
>  		 */
> --- linux-next.orig/include/linux/writeback.h	2011-04-19 10:18:17.000000000 +0800
> +++ linux-next/include/linux/writeback.h	2011-04-19 10:18:30.000000000 +0800
> @@ -34,6 +34,7 @@ struct writeback_control {
>  	long nr_to_write;		/* Write this many pages, and decrement
>  					   this for each page written */
>  	long pages_skipped;		/* Pages which were not written */
> +	long inodes_cleaned;		/* # of inodes cleaned */
>  
>  	/*
>  	 * For a_ops->writepages(): is start or end are non-zero then this is
> 
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

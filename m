Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 47AF9600429
	for <linux-mm@kvack.org>; Sun,  1 Aug 2010 11:34:34 -0400 (EDT)
Received: by pzk33 with SMTP id 33so1295731pzk.14
        for <linux-mm@kvack.org>; Sun, 01 Aug 2010 08:34:32 -0700 (PDT)
Date: Mon, 2 Aug 2010 00:34:24 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 3/6] writeback: kill writeback_control.more_io
Message-ID: <20100801153424.GA8204@barrios-desktop>
References: <20100722050928.653312535@intel.com>
 <20100722061822.763629019@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722061822.763629019@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 01:09:31PM +0800, Wu Fengguang wrote:
> When wbc.more_io was first introduced, it indicates whether there are
> at least one superblock whose s_more_io contains more IO work. Now with
> the per-bdi writeback, it can be replaced with a simple b_more_io test.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c                |    9 ++-------
>  include/linux/writeback.h        |    1 -
>  include/trace/events/writeback.h |    5 +----
>  3 files changed, 3 insertions(+), 12 deletions(-)
> 
> --- linux-next.orig/fs/fs-writeback.c	2010-07-22 11:23:27.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2010-07-22 12:56:42.000000000 +0800
> @@ -507,12 +507,8 @@ static int writeback_sb_inodes(struct su
>  		iput(inode);
>  		cond_resched();
>  		spin_lock(&inode_lock);
> -		if (wbc->nr_to_write <= 0) {
> -			wbc->more_io = 1;
> +		if (wbc->nr_to_write <= 0)
>  			return 1;
> -		}
> -		if (!list_empty(&wb->b_more_io))
> -			wbc->more_io = 1;
>  	}
>  	/* b_io is empty */
>  	return 1;
> @@ -622,7 +618,6 @@ static long wb_writeback(struct bdi_writ
>  		if (work->for_background && !over_bground_thresh())
>  			break;
>  
> -		wbc.more_io = 0;
>  		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
>  		wbc.pages_skipped = 0;
>  
> @@ -644,7 +639,7 @@ static long wb_writeback(struct bdi_writ
>  		/*
>  		 * Didn't write everything and we don't have more IO, bail
>  		 */
> -		if (!wbc.more_io)
> +		if (list_empty(&wb->b_more_io))
>  			break;
>  		/*
>  		 * Did we write something? Try for more
> --- linux-next.orig/include/linux/writeback.h	2010-07-22 11:23:27.000000000 +0800
> +++ linux-next/include/linux/writeback.h	2010-07-22 11:24:46.000000000 +0800
> @@ -49,7 +49,6 @@ struct writeback_control {
>  	unsigned for_background:1;	/* A background writeback */
>  	unsigned for_reclaim:1;		/* Invoked from the page allocator */
>  	unsigned range_cyclic:1;	/* range_start is cyclic */
> -	unsigned more_io:1;		/* more io to be dispatched */
>  };
>  
>  /*
> --- linux-next.orig/include/trace/events/writeback.h	2010-07-22 11:23:27.000000000 +0800
> +++ linux-next/include/trace/events/writeback.h	2010-07-22 11:24:46.000000000 +0800
> @@ -99,7 +99,6 @@ DECLARE_EVENT_CLASS(wbc_class,
>  		__field(int, for_background)
>  		__field(int, for_reclaim)
>  		__field(int, range_cyclic)
> -		__field(int, more_io)
>  		__field(long, range_start)
>  		__field(long, range_end)
>  	),
> @@ -113,13 +112,12 @@ DECLARE_EVENT_CLASS(wbc_class,
>  		__entry->for_background	= wbc->for_background;
>  		__entry->for_reclaim	= wbc->for_reclaim;
>  		__entry->range_cyclic	= wbc->range_cyclic;
> -		__entry->more_io	= wbc->more_io;
>  		__entry->range_start	= (long)wbc->range_start;
>  		__entry->range_end	= (long)wbc->range_end;
>  	),
>  
>  	TP_printk("bdi %s: towrt=%ld skip=%ld mode=%d kupd=%d "
> -		"bgrd=%d reclm=%d cyclic=%d more=%d "
> +		"bgrd=%d reclm=%d cyclic=%d "
>  		"start=0x%lx end=0x%lx",
>  		__entry->name,
>  		__entry->nr_to_write,
> @@ -129,7 +127,6 @@ DECLARE_EVENT_CLASS(wbc_class,
>  		__entry->for_background,
>  		__entry->for_reclaim,
>  		__entry->range_cyclic,
> -		__entry->more_io,
>  		__entry->range_start,
>  		__entry->range_end)
>  )
> 
> 
> --

include/trace/events/ext4.h also have more_io field. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

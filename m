Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 24486900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 12:36:52 -0400 (EDT)
Date: Mon, 29 Aug 2011 18:36:45 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/3 v3] writeback: Add writeback stats for pages written
Message-ID: <20110829163645.GG5672@quack.suse.cz>
References: <1314038327-22645-1-git-send-email-curtw@google.com>
 <1314038327-22645-3-git-send-email-curtw@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314038327-22645-3-git-send-email-curtw@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon 22-08-11 11:38:47, Curt Wohlgemuth wrote:
> Add a new file, /proc/writeback, which displays
> machine global data for how many pages were cleaned for
> which reasons.
  I'm not sure about the placement in /proc/writeback - maybe I'd be
happier if it was somewhere under /sys/kernel/debug but I don't really have
a better suggestion and I don't care that much either. Maybe Christoph or
Andrew have some idea?

...
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index bdda069..5168ac9 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -59,6 +59,7 @@ enum wb_reason {
>  	WB_REASON_TRY_TO_FREE_PAGES,
>  	WB_REASON_SYNC,
>  	WB_REASON_PERIODIC,
> +	WB_REASON_FDATAWRITE,
>  	WB_REASON_LAPTOP_TIMER,
>  	WB_REASON_FREE_MORE_MEM,
>  	WB_REASON_FS_FREE_SPACE,
> @@ -67,6 +68,7 @@ enum wb_reason {
>  	WB_REASON_MAX,
>  };
>  
> +
  The additional empty line doesn't make much sense here?

>  /*
>   * A control structure which tells the writeback code what to do.  These are
>   * always on the stack, and hence need no locking.  They are always initialised
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 474bcfe..6613391 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
...
> @@ -56,9 +60,77 @@ void bdi_lock_two(struct bdi_writeback *wb1, struct bdi_writeback *wb2)
>  	}
>  }
>  
> +
  And another empty line here?

> +static const char *wb_stats_labels[WB_REASON_MAX] = {
> +	[WB_REASON_BALANCE_DIRTY] = "page: balance_dirty_pages",
> +	[WB_REASON_BACKGROUND] = "page: background_writeout",
> +	[WB_REASON_TRY_TO_FREE_PAGES] = "page: try_to_free_pages",
> +	[WB_REASON_SYNC] = "page: sync",
> +	[WB_REASON_PERIODIC] = "page: periodic",
> +	[WB_REASON_FDATAWRITE] = "page: fdatawrite",
> +	[WB_REASON_LAPTOP_TIMER] = "page: laptop_periodic",
> +	[WB_REASON_FREE_MORE_MEM] = "page: free_more_memory",
> +	[WB_REASON_FS_FREE_SPACE] = "page: fs_free_space",
> +};
 I don't think it's good to have two enum->string translation tables for
reasons. That's prone to errors which is in fact proven by the fact that
you ommitted FORKER_THREAD reason here.
  
> @@ -157,6 +248,7 @@ static inline void bdi_debug_unregister(struct backing_dev_info *bdi)
>  }
>  #endif
>  
> +
  Another empty line here? You seem to like them ;)

>  static ssize_t read_ahead_kb_store(struct device *dev,
>  				  struct device_attribute *attr,
>  				  const char *buf, size_t count)

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

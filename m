Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 61DF18D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:41:37 -0500 (EST)
Date: Wed, 17 Nov 2010 12:41:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 12/13] writeback: add trace event for
 balance_dirty_pages()
Message-ID: <20101117044129.GA16203@localhost>
References: <20101117042720.033773013@intel.com>
 <20101117042850.725694164@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117042850.725694164@intel.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Sorry, there are some lags in the document.

On Wed, Nov 17, 2010 at 12:27:32PM +0800, Wu, Fengguang wrote:
> Here is an interesting test to verify the theory with balance_dirty_pages()
> tracing. On a partition that can do ~60MB/s, a sparse file is created and
> 4 rsync tasks with different write bandwidth started:
> 
> 	dd if=/dev/zero of=/mnt/1T bs=1M count=1 seek=1024000
> 	echo 1 > /debug/tracing/events/writeback/balance_dirty_pages/enable
> 
> 	rsync localhost:/mnt/1T /mnt/a --bwlimit 10000&
> 	rsync localhost:/mnt/1T /mnt/A --bwlimit 10000&
> 	rsync localhost:/mnt/1T /mnt/b --bwlimit 20000&
> 	rsync localhost:/mnt/1T /mnt/c --bwlimit 30000&
> 
> Trace outputs within 0.1 second, grouped by tasks:
> 
> rsync-3824  [004] 15002.076447: balance_dirty_pages: bdi=btrfs-2 weight=15% limit=130876 gap=5340 dirtied=192 pause=20
> 
> rsync-3822  [003] 15002.091701: balance_dirty_pages: bdi=btrfs-2 weight=15% limit=130777 gap=5113 dirtied=192 pause=20
> 
> rsync-3821  [006] 15002.004667: balance_dirty_pages: bdi=btrfs-2 weight=30% limit=129570 gap=3714 dirtied=64 pause=8
> rsync-3821  [006] 15002.012654: balance_dirty_pages: bdi=btrfs-2 weight=30% limit=129589 gap=3733 dirtied=64 pause=8
> rsync-3821  [006] 15002.021838: balance_dirty_pages: bdi=btrfs-2 weight=30% limit=129604 gap=3748 dirtied=64 pause=8
> rsync-3821  [004] 15002.091193: balance_dirty_pages: bdi=btrfs-2 weight=29% limit=129583 gap=3983 dirtied=64 pause=8
> rsync-3821  [004] 15002.102729: balance_dirty_pages: bdi=btrfs-2 weight=29% limit=129594 gap=3802 dirtied=64 pause=8
> rsync-3821  [000] 15002.109252: balance_dirty_pages: bdi=btrfs-2 weight=29% limit=129619 gap=3827 dirtied=64 pause=8
> 
> rsync-3823  [002] 15002.009029: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128762 gap=2842 dirtied=64 pause=12
> rsync-3823  [002] 15002.021598: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128813 gap=3021 dirtied=64 pause=12
> rsync-3823  [003] 15002.032973: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128805 gap=2885 dirtied=64 pause=12
> rsync-3823  [003] 15002.048800: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128823 gap=2967 dirtied=64 pause=12
> rsync-3823  [003] 15002.060728: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128821 gap=3221 dirtied=64 pause=12
> rsync-3823  [000] 15002.073152: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128825 gap=3225 dirtied=64 pause=12
> rsync-3823  [005] 15002.090111: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128782 gap=3214 dirtied=64 pause=12
> rsync-3823  [004] 15002.102520: balance_dirty_pages: bdi=btrfs-2 weight=39% limit=128764 gap=3036 dirtied=64 pause=12

The above lines are in the old output format, but you get the idea..

> +	/*
> +	 *           [..................soft throttling range.........]
> +	 *           ^                |<=========== bdi_gap =========>|
> +	 * background_thresh          |<== task_gap ==>|

That background_thresh should be global (background+dirty)/2.

> +	 * -------------------|-------+----------------|--------------|
> +	 *   (bdi_limit * 7/8)^       ^bdi_dirty       ^task_limit    ^bdi_limit
> +	 *
> +	 * Reasonable large gaps help produce smooth pause times.
> +	 */
> +	TP_printk("bdi=%s bdi_dirty=%lu bdi_limit=%lu task_limit=%lu "
> +		  "task_weight=%ld%% task_gap=%ld%% bdi_gap=%ld%% "
> +		  "pages_dirtied=%lu pause=%lu",
> +		  __entry->bdi,
> +		  __entry->bdi_dirty,
> +		  __entry->bdi_limit,
> +		  __entry->task_limit,
> +		  /* task weight: proportion of recent dirtied pages */
> +		  BDP_PERCENT(bdi_limit, task_limit, TASK_SOFT_DIRTY_LIMIT),
> +		  BDP_PERCENT(task_limit, bdi_dirty, TASK_SOFT_DIRTY_LIMIT),
> +		  BDP_PERCENT(bdi_limit, bdi_dirty, BDI_SOFT_DIRTY_LIMIT),
> +		  __entry->pages_dirtied,
> +		  __entry->pause
> +		  )
> +);

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

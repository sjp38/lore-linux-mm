Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AAA8E6B02A6
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 11:03:14 -0400 (EDT)
Date: Thu, 29 Jul 2010 17:02:41 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/5] writeback: prevent sync livelock with the
 sync_after timestamp
Message-ID: <20100729150241.GC12690@quack.suse.cz>
References: <20100729115142.102255590@intel.com>
 <20100729121423.471866750@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100729121423.471866750@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

  Hi Fengguang,

On Thu 29-07-10 19:51:45, Wu Fengguang wrote:
> The start time in writeback_inodes_wb() is not very useful because it
> slips at each invocation time. Preferrably one _constant_ time shall be
> used at the beginning to cover the whole sync() work.
> 
> The newly dirtied inodes are now guarded at the queue_io() time instead
> of the b_io walk time. This is more natural: non-empty b_io/b_more_io
> means "more work pending".
> 
> The timestamp is now grabbed the sync work submission time, and may be
> further optimized to the initial sync() call time.
  The patch seems to have some issues...

> +	if (wbc->for_sync) {
  For example this is never set. You only set wb->for_sync.

> +		expire_interval = 1;
> +		older_than_this = wbc->sync_after;
  And sync_after is never set either???

> -	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
> +	if (list_empty(&wb->b_io))
>  		queue_io(wb, wbc);
  And what is the purpose of this? It looks as an unrelated change to me.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

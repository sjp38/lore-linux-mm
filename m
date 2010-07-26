Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 607A76B024D
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 23:08:19 -0400 (EDT)
Date: Mon, 26 Jul 2010 11:08:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100726030813.GA7668@localhost>
References: <20100723094515.GD5043@localhost>
 <20100723105719.GE5300@csn.ul.ie>
 <20100725192955.40D5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100725192955.40D5.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

KOSAKI,

> My reviewing doesn't found any bug. however I think original thread have too many guess
> and we need to know reproduce way and confirm it.
> 
> At least, we need three confirms.
>  o original issue is still there?

As long as the root cause is still there :)

>  o DEF_PRIORITY/3 is best value?

There are no best value. I suspect the whole PAGEOUT_IO_SYNC and
wait_on_page_writeback() approach is a terrible workaround and should
be avoided as much as possible. This is why I lifted the bar from
DEF_PRIORITY/2 to DEF_PRIORITY/3.

wait_on_page_writeback() is bad because for a typical desktop, one
single call may block 1-10 seconds (remember we are under memory
pressure, which is almost always accompanied with busy disk IO, so
the page will wait noticeable time in the IO queue). To make it worse,
it is very possible there are 10 more dirty/writeback pages in the
isolated pages(dirty pages are often clustered). This ends up with
10-100 seconds stall time.

We do need some throttling under memory pressure. However stall time
more than 1s is not acceptable. A simple congestion_wait() may be
better, since it waits on _any_ IO completion (which will likely
release a set of PG_reclaim pages) rather than one specific IO
completion. This makes much smoother stall time.
wait_on_page_writeback() shall really be the last resort.
DEF_PRIORITY/3 means 1/16=6.25%, which is closer.

Since dirty/writeback pages are such a bad factor under memory
pressure, it may deserve to adaptively shrink dirty_limit as well.
When short on memory, why not reduce the dirty/writeback page cache?
This will not only consume memory, but also considerably improve IO
efficiency and responsiveness. When the LRU lists are scanned fast
(under memory pressure), it is likely lots of the dirty pages are
caught by pageout(). Reducing the number of dirty pages reduces the
pageout() invocations.

>  o Current approach have better performance than Wu's original proposal? (below)

I guess it will have better user experience :)

> Anyway, please feel free to use my reviewed-by tag.
 
Thanks,
Fengguang

> --- linux-next.orig/mm/vmscan.c	2010-06-24 14:32:03.000000000 +0800
> +++ linux-next/mm/vmscan.c	2010-07-22 16:12:34.000000000 +0800
> @@ -1650,7 +1650,7 @@ static void set_lumpy_reclaim_mode(int p
>  	 */
>  	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
>  		sc->lumpy_reclaim_mode = 1;
> -	else if (sc->order && priority < DEF_PRIORITY - 2)
> +	else if (sc->order && priority < DEF_PRIORITY / 2)
>  		sc->lumpy_reclaim_mode = 1;
>  	else
>  		sc->lumpy_reclaim_mode = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

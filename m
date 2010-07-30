Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7536C6B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 09:32:09 -0400 (EDT)
Date: Fri, 30 Jul 2010 14:31:50 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
Message-ID: <20100730133149.GF3571@csn.ul.ie>
References: <20100728071705.GA22964@localhost> <20100730131735.GZ16655@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100730131735.GZ16655@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 30, 2010 at 03:17:35PM +0200, Andrea Arcangeli wrote:
> On Wed, Jul 28, 2010 at 03:17:05PM +0800, Wu Fengguang wrote:
> > Fix "system goes unresponsive under memory pressure and lots of
> > dirty/writeback pages" bug.
> > 
> > 	http://lkml.org/lkml/2010/4/4/86
> > 
> > In the above thread, Andreas Mohr described that
> > 
> > 	Invoking any command locked up for minutes (note that I'm
> > 	talking about attempted additional I/O to the _other_,
> > 	_unaffected_ main system HDD - such as loading some shell
> > 	binaries -, NOT the external SSD18M!!).
> > 
> > This happens when the two conditions are both meet:
> > - under memory pressure
> > - writing heavily to a slow device
> > 
> > OOM also happens in Andreas' system. The OOM trace shows that 3
> > processes are stuck in wait_on_page_writeback() in the direct reclaim
> > path. One in do_fork() and the other two in unix_stream_sendmsg(). They
> > are blocked on this condition:
> > 
> > 	(sc->order && priority < DEF_PRIORITY - 2)
> > 
> > which was introduced in commit 78dc583d (vmscan: low order lumpy reclaim
> > also should use PAGEOUT_IO_SYNC) one year ago. That condition may be too
> > permissive. In Andreas' case, 512MB/1024 = 512KB. If the direct reclaim
> > for the order-1 fork() allocation runs into a range of 512KB
> > hard-to-reclaim LRU pages, it will be stalled.
> > 
> > It's a severe problem in three ways.
> 
> Lumpy reclaim just made the system totally unusable with frequent
> order 9 allocations.

Yes, it's very disruptive and has been for a while. It was not much of a
problem when resizing the static hugepage pool but is a disaster for
transparent huge pages.

> I nuked it long ago and replaced it with mem
> compaction. You may try aa.git to test how thing goes without lumpy
> reclaim. I recently also started to use mem compaction for order 1/2/3
> allocations as there's no point not to use it for them, and to call
> mem compaction from kswapd to satisfy order 2 GFP_ATOMIC in
> replacement of blind responsiveness-destroyer lumpy.
> 

A full-scale replacement is overkill but I can see why it would be done
in the short-term. There are times when lumpy reclaim is still needed -
specifically when the allocation failure is due to a lack of memory rather
than fragmentation. There will also be cases where compaction can't work
because there are too many movable pages  to move into too few pageblocks.

> Not sure why people insists on lumpy when we've memory compaction that
> won't alter the working set and it's more effective.
> 

Compaction is preferred, no doubt about it but lumpy reclaim cannot be
dismissed. I know lumpy reclaim is too disruptive and Kosaki noticed the same
and it's currently doing some pretty stupid things. There are a few ideas
knocking around publicly on how to reduce its impact while increasing its
effectiveness. I have a few old ideas knocking around as well that I just
need the time to get around to. I hope to get at it after the fuss over
writeback is addressed.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

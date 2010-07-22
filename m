Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EB7E66B02A8
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 04:52:19 -0400 (EDT)
Date: Thu, 22 Jul 2010 16:52:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100722085210.GA26714@localhost>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
 <20100719142145.GD12510@infradead.org>
 <20100719144046.GR13117@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100719144046.GR13117@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> Some insight on how the other writeback changes that are being floated
> around might affect the number of dirty pages reclaim encounters would also
> be helpful.

Here is an interesting related problem about the wait_on_page_writeback() call
inside shrink_page_list():

        http://lkml.org/lkml/2010/4/4/86

The problem is, wait_on_page_writeback() is called too early in the
direct reclaim path, which blocks many random/unrelated processes when
some slow (USB stick) writeback is on the way.

A simple dd can easily create a big range of dirty pages in the LRU
list. Therefore priority can easily go below (DEF_PRIORITY - 2) in a
typical desktop, which triggers the lumpy reclaim mode and hence
wait_on_page_writeback().

I proposed this patch at the time, which was confirmed to solve the problem:

--- linux-next.orig/mm/vmscan.c	2010-06-24 14:32:03.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-07-22 16:12:34.000000000 +0800
@@ -1650,7 +1650,7 @@ static void set_lumpy_reclaim_mode(int p
 	 */
 	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
 		sc->lumpy_reclaim_mode = 1;
-	else if (sc->order && priority < DEF_PRIORITY - 2)
+	else if (sc->order && priority < DEF_PRIORITY / 2)
 		sc->lumpy_reclaim_mode = 1;
 	else
 		sc->lumpy_reclaim_mode = 0;


However KOSAKI and Minchan raised concerns about raising the bar.
I guess this new patch is more problem oriented and acceptable:

--- linux-next.orig/mm/vmscan.c	2010-07-22 16:36:58.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-07-22 16:39:57.000000000 +0800
@@ -1217,7 +1217,8 @@ static unsigned long shrink_inactive_lis
 			count_vm_events(PGDEACTIVATE, nr_active);
 
 			nr_freed += shrink_page_list(&page_list, sc,
-							PAGEOUT_IO_SYNC);
+					priority < DEF_PRIORITY / 3 ?
+					PAGEOUT_IO_SYNC : PAGEOUT_IO_ASYNC);
 		}
 
 		nr_reclaimed += nr_freed;

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

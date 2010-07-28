Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6041E6B02A4
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 04:47:00 -0400 (EDT)
Date: Wed, 28 Jul 2010 16:46:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] vmscan: remove wait_on_page_writeback() from pageout()
Message-ID: <20100728084654.GA26776@localhost>
References: <20100728071705.GA22964@localhost>
 <AANLkTimaj6+MzY5Aa_xqi75zKy1fDOQV5QiQjdX8jgm7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimaj6+MzY5Aa_xqi75zKy1fDOQV5QiQjdX8jgm7@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andy Whitcroft <apw@shadowen.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

The wait_on_page_writeback() call inside pageout() is virtually dead code.

        shrink_inactive_list()
          shrink_page_list(PAGEOUT_IO_ASYNC)
            pageout(PAGEOUT_IO_ASYNC)
          shrink_page_list(PAGEOUT_IO_SYNC)
            pageout(PAGEOUT_IO_SYNC)

Because shrink_page_list/pageout(PAGEOUT_IO_SYNC) is always called after
a preceding shrink_page_list/pageout(PAGEOUT_IO_ASYNC), the first
pageout(ASYNC) converts dirty pages into writeback pages, the second
shrink_page_list(SYNC) waits on the clean of writeback pages before
calling pageout(SYNC). The second shrink_page_list(SYNC) can hardly run
into dirty pages for pageout(SYNC) unless in some race conditions.

And the wait page-by-page behavior of pageout(SYNC) will lead to very
long stall time if running into some range of dirty pages. So it's bad
idea anyway to call wait_on_page_writeback() inside pageout().

CC: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |   13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

--- linux-next.orig/mm/vmscan.c	2010-07-28 16:22:21.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-07-28 16:23:35.000000000 +0800
@@ -324,8 +324,7 @@ typedef enum {
  * pageout is called by shrink_page_list() for each dirty page.
  * Calls ->writepage().
  */
-static pageout_t pageout(struct page *page, struct address_space *mapping,
-						enum pageout_io sync_writeback)
+static pageout_t pageout(struct page *page, struct address_space *mapping)
 {
 	/*
 	 * If the page is dirty, only perform writeback if that write
@@ -384,14 +383,6 @@ static pageout_t pageout(struct page *pa
 			return PAGE_ACTIVATE;
 		}
 
-		/*
-		 * Wait on writeback if requested to. This happens when
-		 * direct reclaiming a large contiguous area and the
-		 * first attempt to free a range of pages fails.
-		 */
-		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
-			wait_on_page_writeback(page);
-
 		if (!PageWriteback(page)) {
 			/* synchronous write or broken a_ops? */
 			ClearPageReclaim(page);
@@ -727,7 +718,7 @@ static unsigned long shrink_page_list(st
 				goto keep_locked;
 
 			/* Page is dirty, try to write it out here */
-			switch (pageout(page, mapping, sync_writeback)) {
+			switch (pageout(page, mapping)) {
 			case PAGE_KEEP:
 				goto keep_locked;
 			case PAGE_ACTIVATE:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

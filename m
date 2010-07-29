From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/5] vmscan: transfer async file writeback to the flusher
Date: Thu, 29 Jul 2010 19:51:47 +0800
Message-ID: <20100729121423.754455334@intel.com>
References: <20100729115142.102255590@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1OeS90-0006ML-LO
	for glkm-linux-mm-2@m.gmane.org; Thu, 29 Jul 2010 14:23:26 +0200
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3AC6F6B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 08:23:19 -0400 (EDT)
Content-Disposition: inline; filename=vmscan-writeback-inode-page.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-Id: linux-mm.kvack.org

This relays all ASYNC file writeback IOs to the flusher threads.
The lesser SYNC pageout()s will work as before (as a last resort).

It's a minimal prototype implementation and barely runs without panic.
It potentially requires lots of more work to go stable. 

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/vmscan.c	2010-07-29 17:07:07.000000000 +0800
+++ linux-next/mm/vmscan.c	2010-07-29 17:09:16.000000000 +0800
@@ -379,6 +379,13 @@ static pageout_t pageout(struct page *pa
 	}
 	if (mapping->a_ops->writepage == NULL)
 		return PAGE_ACTIVATE;
+
+	if (sync_writeback == PAGEOUT_IO_ASYNC &&
+	    page_is_file_cache(page)) {
+		bdi_start_inode_writeback(mapping->host, page->index);
+		return PAGE_KEEP;
+	}
+
 	if (!may_write_to_queue(mapping->backing_dev_info))
 		return PAGE_KEEP;
 
@@ -1366,7 +1373,6 @@ shrink_inactive_list(unsigned long nr_to
 				list_add(&page->lru, &putback_list);
 			}
 
-			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 			/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

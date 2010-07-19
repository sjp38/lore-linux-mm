Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 932DE600365
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 09:11:40 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 7/8] writeback: sync old inodes first in background writeback
Date: Mon, 19 Jul 2010 14:11:29 +0100
Message-Id: <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Wu Fengguang <fengguang.wu@intel.com>

A background flush work may run for ever. So it's reasonable for it to
mimic the kupdate behavior of syncing old/expired inodes first.

This behavior also makes sense from the perspective of page reclaim.
File pages are added to the inactive list and promoted if referenced
after one recycling. If not referenced, it's very easy for pages to be
cleaned from reclaim context which is inefficient in terms of IO. If
background flush is cleaning pages, it's best it cleans old pages to
help minimise IO from reclaim.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/fs-writeback.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index d5be169..cc81c67 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -612,13 +612,14 @@ static long wb_writeback(struct bdi_writeback *wb,
 		.range_cyclic		= work->range_cyclic,
 	};
 	unsigned long oldest_jif;
+	int expire_interval = msecs_to_jiffies(dirty_expire_interval * 10);
+	int fg_rounds = 0;
 	long wrote = 0;
 	struct inode *inode;
 
-	if (wbc.for_kupdate) {
+	if (wbc.for_kupdate || wbc.for_background) {
 		wbc.older_than_this = &oldest_jif;
-		oldest_jif = jiffies -
-				msecs_to_jiffies(dirty_expire_interval * 10);
+		oldest_jif = jiffies - expire_interval;
 	}
 	if (!wbc.range_cyclic) {
 		wbc.range_start = 0;
@@ -649,6 +650,18 @@ static long wb_writeback(struct bdi_writeback *wb,
 		work->nr_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
 		wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
 
+		if (work->for_background && expire_interval &&
+		    ++fg_rounds && list_empty(&wb->b_io)) {
+			if (fg_rounds < 10)
+				expire_interval >>= 1;
+			if (expire_interval)
+				oldest_jif = jiffies - expire_interval;
+			else
+				wbc.older_than_this = 0;
+			fg_rounds = 0;
+			continue;
+		}
+
 		/*
 		 * If we consumed everything, see if we have more
 		 */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EEB8F8D0047
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 04:46:14 -0400 (EDT)
Message-Id: <20110420080918.383880412@intel.com>
Date: Wed, 20 Apr 2011 16:03:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/6] writeback: sync expired inodes first in background writeback
References: <20110420080336.441157866@intel.com>
Content-Disposition: inline; filename=writeback-moving-dirty-expired-background.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

A background flush work may run for ever. So it's reasonable for it to
mimic the kupdate behavior of syncing old/expired inodes first.

At each queue_io() time, first try enqueuing only newly expired inodes.
If there are zero expired inodes to work with, then relax the rule and
enqueue all dirty inodes.

This will help reduce the number of dirty pages encountered by page
reclaim, eg. the pageout() calls. Normally older inodes contain older
dirty pages, which are more close to the end of the LRU lists. So
syncing older inodes first helps reducing the dirty pages reached by
the page reclaim code.

More background: as Mel put it, "it makes sense to write old pages first
to reduce the chances page reclaim is initiating IO."

Rik also presented the situation with a graph:

LRU head                                 [*] dirty page
[                          *              *      * *  *  * * * * * *]

Ideally, most dirty pages should lie close to the LRU tail instead of
LRU head. That requires the flusher thread to sync old/expired inodes
first (as there are obvious correlations between inode age and page
age), and to give fair opportunities to newly expired inodes rather
than sticking with some large eldest inodes (as larger inodes have
weaker correlations in the inode<=>page ages).

This patch helps the flusher to meet both the above requirements.

Side effects: it might reduce the batch size and hence reduce
inode_wb_list_lock hold time, but in turn make the cluster-by-partition
logic in the same function less effective on reducing disk seeks.

v2: keep policy changes inside wb_writeback() and keep the
wbc.older_than_this visibility as suggested by Dave.

CC: Dave Chinner <david@fromorbit.com>
CC: Jan Kara <jack@suse.cz>
CC: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

--- linux-next.orig/fs/fs-writeback.c	2011-04-20 12:03:50.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-04-20 12:03:54.000000000 +0800
@@ -709,7 +709,7 @@ static long wb_writeback(struct bdi_writ
 		if (work->for_background && !over_bground_thresh())
 			break;
 
-		if (work->for_kupdate) {
+		if (work->for_kupdate || work->for_background) {
 			oldest_jif = jiffies -
 				msecs_to_jiffies(dirty_expire_interval * 10);
 			wbc.older_than_this = &oldest_jif;
@@ -720,6 +720,7 @@ static long wb_writeback(struct bdi_writ
 		wbc.pages_skipped = 0;
 		wbc.inodes_cleaned = 0;
 
+retry:
 		trace_wbc_writeback_start(&wbc, wb->bdi);
 		if (work->sb)
 			__writeback_inodes_sb(work->sb, wb, &wbc);
@@ -743,6 +744,19 @@ static long wb_writeback(struct bdi_writ
 		if (wbc.inodes_cleaned)
 			continue;
 		/*
+		 * background writeback will start with expired inodes, and
+		 * if none is found, fallback to all inodes. This order helps
+		 * reduce the number of dirty pages reaching the end of LRU
+		 * lists and cause trouble to the page reclaim.
+		 */
+		if (work->for_background &&
+		    wbc.older_than_this &&
+		    list_empty(&wb->b_io) &&
+		    list_empty(&wb->b_more_io)) {
+			wbc.older_than_this = NULL;
+			goto retry;
+		}
+		/*
 		 * No more inodes for IO, bail
 		 */
 		if (!wbc.more_io)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

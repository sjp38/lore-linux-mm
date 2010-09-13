Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D6A966B0162
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 09:08:19 -0400 (EDT)
Message-Id: <20100913130149.994322762@intel.com>
Date: Mon, 13 Sep 2010 20:31:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/4] writeback: quit background/periodic work when other works are enqueued
References: <20100913123110.372291929@intel.com>
Content-Disposition: inline; filename=mutt-wfg-t61-1000-16461-3447aada517764116f
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

 From: Jan Kara <jack@suse.cz>

Background writeback and kupdate-style writeback are easily livelockable
(from a definition of their target). This is inconvenient because it can
make sync(1) stall forever waiting on its queued work to be finished.
Fix the problem by interrupting background and kupdate writeback if there
is some other work to do. We can return to them after completing all the
queued work.

Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- linux-next.orig/fs/fs-writeback.c	2010-09-13 13:58:47.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-09-13 14:03:54.000000000 +0800
@@ -643,6 +643,14 @@ static long wb_writeback(struct bdi_writ
 			break;
 
 		/*
+		 * Background writeout and kupdate-style writeback are
+		 * easily livelockable. Stop them if there is other work
+		 * to do so that e.g. sync can proceed.
+		 */
+		if ((work->for_background || work->for_kupdate) &&
+		    !list_empty(&wb->bdi->work_list))
+			break;
+		/*
 		 * For background writeout, stop when we are below the
 		 * background dirty threshold
 		 */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

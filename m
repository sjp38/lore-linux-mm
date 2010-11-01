Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 126648D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 09:15:44 -0400 (EDT)
Date: Mon, 1 Nov 2010 20:22:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/2] writeback: stop background/kupdate works from
 livelocking other works
Message-ID: <20101101122252.GA10637@localhost>
References: <20100913123110.372291929@intel.com>
 <20100913130149.994322762@intel.com>
 <20100914124033.GA4874@quack.suse.cz>
 <20101101121408.GB9006@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101101121408.GB9006@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Jan Kara <jack@suse.cz>

Background writeback are easily livelockable (from a definition of their
target). This is inconvenient because it can make sync(1) stall forever waiting
on its queued work to be finished. Generally, when a flusher thread has
some work queued, someone submitted the work to achieve a goal more specific
than what background writeback does. So it makes sense to give it a priority
over a generic page cleaning.

Thus we interrupt background writeback if there is some other work to do. We
return to the background writeback after completing all the queued work.

Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- linux-next.orig/fs/fs-writeback.c	2010-11-01 19:50:22.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-01 19:56:54.000000000 +0800
@@ -664,6 +664,15 @@ static long wb_writeback(struct bdi_writ
 			break;
 
 		/*
+		 * Background writeout and kupdate-style writeback are
+		 * easily livelockable. Stop them if there is other work
+		 * to do so that e.g. sync can proceed.
+		 */
+		if ((work->for_background || work->for_kupdate) &&
+		    !list_empty(&wb->bdi->work_list))
+			break;
+
+		/*
 		 * For background writeout, stop when we are below the
 		 * background dirty threshold
 		 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

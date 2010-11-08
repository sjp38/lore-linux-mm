Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 334056B0089
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 18:19:39 -0500 (EST)
Message-Id: <20101108231726.993880740@intel.com>
Date: Tue, 09 Nov 2010 07:09:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/5] writeback: stop background/kupdate works from livelocking other works
References: <20101108230916.826791396@intel.com>
Content-Disposition: inline; filename=0002-mm-Stop-background-writeback-if-there-is-other-work-.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
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

--- linux-next.orig/fs/fs-writeback.c	2010-11-07 21:56:42.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-07 22:00:51.000000000 +0800
@@ -651,6 +651,15 @@ static long wb_writeback(struct bdi_writ
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

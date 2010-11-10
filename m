Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D622C6B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 21:44:55 -0500 (EST)
Message-Id: <20101110024223.847210776@intel.com>
Date: Wed, 10 Nov 2010 10:35:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/5] writeback: stop background/kupdate works from livelocking other works
References: <20101110023500.404859581@intel.com>
Content-Disposition: inline; filename=0002-mm-Stop-background-writeback-if-there-is-other-work-.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: Jan Kara <jack@suse.cz>

Background writeback is easily livelockable in a loop in wb_writeback()
by a process continuously re-dirtying pages (or continuously appending
to a file). This is in fact intended as the target of background
writeback is to write dirty pages it can find as long as we are over
dirty_background_threshold.

But the above behavior gets inconvenient at times because no other work
queued in the flusher thread's queue gets processed. In particular,
since e.g. sync(1) relies on flusher thread to do all the IO for it,
sync(1) can hang forever waiting for flusher thread to do the work.

Generally, when a flusher thread has some work queued, someone submitted
the work to achieve a goal more specific than what background writeback
does. Moreover by working on the specific work, we also reduce amount of
dirty pages which is exactly the target of background writeout. So it
makes sense to give specific work a priority over a generic page
cleaning.

Thus we interrupt background writeback if there is some other work to
do. We return to the background writeback after completing all the
queued work.

This may delay the writeback of expired inodes for a while, however the
expired inodes will eventually be flushed to disk as long as the other
works won't livelock.

Signed-off-by: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- linux-next.orig/fs/fs-writeback.c	2010-11-10 07:04:34.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-11-10 10:32:09.000000000 +0800
@@ -651,6 +651,16 @@ static long wb_writeback(struct bdi_writ
 			break;
 
 		/*
+		 * Background writeout and kupdate-style writeback may
+		 * run forever. Stop them if there is other work to do
+		 * so that e.g. sync can proceed. They'll be restarted
+		 * after the other works are all done.
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

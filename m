Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 204656B0083
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:01 -0400 (EDT)
Message-Id: <20100912155203.355459925@intel.com>
Date: Sun, 12 Sep 2010 23:49:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 05/17] writeback: quit throttling when signal pending
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=writeback-break-on-signal-pending.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

This allows quick response to Ctrl-C etc. for impatient users.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    3 +++
 1 file changed, 3 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2010-09-09 16:01:14.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-09-09 16:02:27.000000000 +0800
@@ -553,6 +553,9 @@ static void balance_dirty_pages(struct a
 		__set_current_state(TASK_INTERRUPTIBLE);
 		io_schedule_timeout(pause);
 
+		if (signal_pending(current))
+			break;
+
 check_exceeded:
 		/*
 		 * The bdi thresh is somehow "soft" limit derived from the


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

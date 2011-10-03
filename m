Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B0A9E9000DB
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:45:57 -0400 (EDT)
Message-Id: <20111003134537.301789823@intel.com>
Date: Mon, 03 Oct 2011 21:42:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 09/11] writeback: control dirty pause time
References: <20111003134228.090592370@intel.com>
Content-Disposition: inline; filename=max-pause-adaption
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

The dirty pause time shall ultimately be controlled by adjusting
nr_dirtied_pause, since there is relationship

	pause = pages_dirtied / task_ratelimit

Assuming

	pages_dirtied ~= nr_dirtied_pause
	task_ratelimit ~= dirty_ratelimit

We get

	nr_dirtied_pause ~= dirty_ratelimit * desired_pause

Here dirty_ratelimit is preferred over task_ratelimit because it's
more stable.

It's also important to limit possible large transitional errors:

- bw is changing quickly
- pages_dirtied << nr_dirtied_pause on entering dirty exceeded area
- pages_dirtied >> nr_dirtied_pause on btrfs (to be improved by a
  separate fix, but still expect non-trivial errors)

So we end up using the above formula inside clamp_val().

The best test case for this code is to run 100 "dd bs=4M" tasks on
btrfs and check its pause time distribution.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

--- linux-next.orig/mm/page-writeback.c	2011-10-03 17:35:57.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-10-03 17:39:27.000000000 +0800
@@ -1086,6 +1086,10 @@ static void balance_dirty_pages(struct a
 		task_ratelimit = (u64)dirty_ratelimit *
 					pos_ratio >> RATELIMIT_CALC_SHIFT;
 		pause = (HZ * pages_dirtied) / (task_ratelimit | 1);
+		if (unlikely(pause <= 0)) {
+			pause = 1; /* avoid resetting nr_dirtied_pause below */
+			break;
+		}
 		pause = min(pause, max_pause);
 
 pause:
@@ -1107,7 +1111,21 @@ pause:
 		bdi->dirty_exceeded = 0;
 
 	current->nr_dirtied = 0;
-	current->nr_dirtied_pause = dirty_poll_interval(nr_dirty, dirty_thresh);
+	if (pause == 0) { /* in freerun area */
+		current->nr_dirtied_pause =
+				dirty_poll_interval(nr_dirty, dirty_thresh);
+	} else if (pause <= max_pause / 4 &&
+		   pages_dirtied >= current->nr_dirtied_pause) {
+		current->nr_dirtied_pause = clamp_val(
+					dirty_ratelimit * (max_pause / 2) / HZ,
+					pages_dirtied + pages_dirtied / 8,
+					pages_dirtied * 4);
+	} else if (pause >= max_pause) {
+		current->nr_dirtied_pause = 1 | clamp_val(
+					dirty_ratelimit * (max_pause / 2) / HZ,
+					pages_dirtied / 4,
+					pages_dirtied - pages_dirtied / 8);
+	}
 
 	if (writeback_in_progress(bdi))
 		return;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

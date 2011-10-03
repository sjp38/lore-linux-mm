Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8B4CF9000D8
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:45:57 -0400 (EDT)
Message-Id: <20111003134537.434162395@intel.com>
Date: Mon, 03 Oct 2011 21:42:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/11] writeback: dirty position control - bdi reserve area
References: <20111003134228.090592370@intel.com>
Content-Disposition: inline; filename=bdi-reserve-area
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Keep a minimal pool of dirty pages for each bdi, so that the disk IO
queues won't underrun. Also gently increase a small bdi_thresh to avoid
it stuck in 0 for some light dirtied bdi.

It's particularly useful for JBOD and small memory system.

It may result in (pos_ratio > 1) at the setpoint and push the dirty
pages high. This is more or less intended because the bdi is in the
danger of IO queue underflow.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2011-10-03 21:05:48.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-10-03 21:05:51.000000000 +0800
@@ -599,6 +599,7 @@ static unsigned long bdi_position_ratio(
 	 */
 	if (unlikely(bdi_thresh > thresh))
 		bdi_thresh = thresh;
+	bdi_thresh = max(bdi_thresh, (limit - dirty) / 8);
 	/*
 	 * scale global setpoint to bdi's:
 	 *	bdi_setpoint = setpoint * bdi_thresh / thresh
@@ -622,6 +623,20 @@ static unsigned long bdi_position_ratio(
 	} else
 		pos_ratio /= 4;
 
+	/*
+	 * bdi reserve area, safeguard against dirty pool underrun and disk idle
+	 * It may push the desired control point of global dirty pages higher
+	 * than setpoint.
+	 */
+	x_intercept = bdi_thresh / 2;
+	if (bdi_dirty < x_intercept) {
+		if (bdi_dirty > x_intercept / 8) {
+			pos_ratio *= x_intercept;
+			do_div(pos_ratio, bdi_dirty);
+		} else
+			pos_ratio *= 8;
+	}
+
 	return pos_ratio;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

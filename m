Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8AD536B018D
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 22:13:28 -0400 (EDT)
Message-Id: <20110904020915.942753370@intel.com>
Date: Sun, 04 Sep 2011 09:53:15 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/18] writeback: dirty position control - bdi reserve area
References: <20110904015305.367445271@intel.com>
Content-Disposition: inline; filename=bdi-reserve-area
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Keep a minimal pool of dirty pages for each bdi, so that the disk IO
queues won't underrun.

It's particularly useful for JBOD and small memory system.

Note that this is not enough when memory is really tight (in comparison
to write bandwidth). It may result in (pos_ratio > 1) at the setpoint
and push the dirty pages high. This is more or less intended because the
bdi is in the danger of IO queue underflow. However the global dirty
pages, when pushed close to limit, will eventually conteract our desire
to push up the low bdi_dirty.

In low memory JBOD tests we do see disks under-utilized from time to
time. The additional fix may be to add a BDI_async_underrun flag to
indicate that the block write queue is running low and it's time to
quickly fill the queue by unthrottling the tasks regardless of the
global limit.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2011-08-26 20:12:19.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-26 20:13:21.000000000 +0800
@@ -487,6 +487,16 @@ unsigned long bdi_dirty_limit(struct bac
  *   0 +------------.------------------.----------------------*------------->
  *           freerun^          setpoint^                 limit^   dirty pages
  *
+ * (o) bdi reserve area
+ *
+ * The bdi reserve area tries to keep a reasonable number of dirty pages for
+ * preventing block queue underrun.
+ *
+ * reserve area, scale up rate as dirty pages drop low
+ * |<----------------------------------------------->|
+ * |-------------------------------------------------------*-------|----------
+ * 0                                           bdi setpoint^       ^bdi_thresh
+ *
  * (o) bdi control lines
  *
  * The control lines for the global/bdi setpoints both stretch up to @limit.
@@ -634,6 +644,22 @@ static unsigned long bdi_position_ratio(
 	pos_ratio *= x_intercept - bdi_dirty;
 	do_div(pos_ratio, x_intercept - bdi_setpoint + 1);
 
+	/*
+	 * bdi reserve area, safeguard against dirty pool underrun and disk idle
+	 *
+	 * It may push the desired control point of global dirty pages higher
+	 * than setpoint. It's not necessary in single-bdi case because a
+	 * minimal pool of @freerun dirty pages will already be guaranteed.
+	 */
+	x_intercept = min(write_bw, freerun);
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id ECF126B0188
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 22:13:26 -0400 (EDT)
Message-Id: <20110904020916.197826172@intel.com>
Date: Sun, 04 Sep 2011 09:53:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 12/18] writeback: balanced_rate cannot exceed write bandwidth
References: <20110904015305.367445271@intel.com>
Content-Disposition: inline; filename=ref-bw-up-bound
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add an upper limit to balanced_rate according to the below inequality.
This filters out some rare but huge singular points, which at least
enables more readable gnuplot figures.

When there are N dd dirtiers,

	balanced_dirty_ratelimit = write_bw / N

So it holds that

	balanced_dirty_ratelimit <= write_bw

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    5 +++++
 1 file changed, 5 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2011-08-29 19:14:22.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-29 19:20:36.000000000 +0800
@@ -828,6 +828,11 @@ static void bdi_update_dirty_ratelimit(s
 	 */
 	balanced_dirty_ratelimit = div_u64((u64)task_ratelimit * write_bw,
 					   dirty_rate | 1);
+	/*
+	 * balanced_dirty_ratelimit ~= (write_bw / N) <= write_bw
+	 */
+	if (unlikely(balanced_dirty_ratelimit > write_bw))
+		balanced_dirty_ratelimit = write_bw;
 
 	/*
 	 * We could safely do this and return immediately:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

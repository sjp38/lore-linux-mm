Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4C68D003D
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 17:31:29 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/5] mm: Properly reflect task dirty limits in dirty_exceeded logic
Date: Tue,  8 Mar 2011 23:31:12 +0100
Message-Id: <1299623475-5512-3-git-send-email-jack@suse.cz>
In-Reply-To: <1299623475-5512-1-git-send-email-jack@suse.cz>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>

We set bdi->dirty_exceeded (and thus ratelimiting code starts to
call balance_dirty_pages() every 8 pages) when a per-bdi limit is
exceeded or global limit is exceeded. But per-bdi limit also depends
on the task. Thus different tasks reach the limit on that bdi at
different levels of dirty pages. The result is that with current code
bdi->dirty_exceeded ping-ponged between 1 and 0 depending on which task
just got into balance_dirty_pages().

We fix the issue by clearing bdi->dirty_exceeded only when per-bdi amount
of dirty pages drops below the threshold (7/8 * bdi_dirty_limit) where task
limits already do not have any influence.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>
CC: Dave Chinner <david@fromorbit.com>
CC: Wu Fengguang <fengguang.wu@intel.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/page-writeback.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c472c1c..f388f70 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -275,12 +275,13 @@ static inline void task_dirties_fraction(struct task_struct *tsk,
  * effectively curb the growth of dirty pages. Light dirtiers with high enough
  * dirty threshold may never get throttled.
  */
+#define TASK_LIMIT_FRACTION 8
 static unsigned long task_dirty_limit(struct task_struct *tsk,
 				       unsigned long bdi_dirty)
 {
 	long numerator, denominator;
 	unsigned long dirty = bdi_dirty;
-	u64 inv = dirty >> 3;
+	u64 inv = dirty / TASK_LIMIT_FRACTION;
 
 	task_dirties_fraction(tsk, &numerator, &denominator);
 	inv *= numerator;
@@ -291,6 +292,12 @@ static unsigned long task_dirty_limit(struct task_struct *tsk,
 	return max(dirty, bdi_dirty/2);
 }
 
+/* Minimum limit for any task */
+static unsigned long task_min_dirty_limit(unsigned long bdi_dirty)
+{
+	return bdi_dirty - bdi_dirty / TASK_LIMIT_FRACTION;
+}
+
 /*
  *
  */
@@ -484,9 +491,11 @@ static void balance_dirty_pages(struct address_space *mapping,
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
+	unsigned long min_bdi_thresh = ULONG_MAX;
 	unsigned long pages_written = 0;
 	unsigned long pause = 1;
 	bool dirty_exceeded = false;
+	bool min_dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 
 	for (;;) {
@@ -513,6 +522,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 			break;
 
 		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
+		min_bdi_thresh = task_min_dirty_limit(bdi_thresh);
 		bdi_thresh = task_dirty_limit(current, bdi_thresh);
 
 		/*
@@ -542,6 +552,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 		dirty_exceeded =
 			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
 			|| (nr_reclaimable + nr_writeback > dirty_thresh);
+		min_dirty_exceeded =
+			(bdi_nr_reclaimable + bdi_nr_writeback > min_bdi_thresh)
+			|| (nr_reclaimable + nr_writeback > dirty_thresh);
 
 		if (!dirty_exceeded)
 			break;
@@ -579,7 +592,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 			pause = HZ / 10;
 	}
 
-	if (!dirty_exceeded && bdi->dirty_exceeded)
+	/* Clear dirty_exceeded flag only when no task can exceed the limit */
+	if (!min_dirty_exceeded && bdi->dirty_exceeded)
 		bdi->dirty_exceeded = 0;
 
 	if (writeback_in_progress(bdi))
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

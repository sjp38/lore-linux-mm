Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 366996B02A3
	for <linux-mm@kvack.org>; Fri, 22 May 2015 18:24:12 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so23404110qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:12 -0700 (PDT)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id 23si3907582qhy.21.2015.05.22.15.24.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 15:24:06 -0700 (PDT)
Received: by qkx62 with SMTP id 62so23320445qkx.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 15:24:06 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 14/19] writeback: move over_bground_thresh() to mm/page-writeback.c
Date: Fri, 22 May 2015 18:23:31 -0400
Message-Id: <1432333416-6221-15-git-send-email-tj@kernel.org>
In-Reply-To: <1432333416-6221-1-git-send-email-tj@kernel.org>
References: <1432333416-6221-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

and rename it to wb_over_bg_thresh().  The function is closely tied to
the dirty throttling mechanism implemented in page-writeback.c.  This
relocation will allow future updates necessary for cgroup writeback
support.

While at it, add function comment.

This is pure reorganization and doesn't introduce any behavioral
changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c         | 20 ++------------------
 include/linux/writeback.h |  1 +
 mm/page-writeback.c       | 23 +++++++++++++++++++++++
 3 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 51c8a5b..da35587 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1071,22 +1071,6 @@ static long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
 	return nr_pages - work.nr_pages;
 }
 
-static bool over_bground_thresh(struct bdi_writeback *wb)
-{
-	unsigned long background_thresh, dirty_thresh;
-
-	global_dirty_limits(&background_thresh, &dirty_thresh);
-
-	if (global_page_state(NR_FILE_DIRTY) +
-	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
-		return true;
-
-	if (wb_stat(wb, WB_RECLAIMABLE) > wb_calc_thresh(wb, background_thresh))
-		return true;
-
-	return false;
-}
-
 /*
  * Explicit flushing or periodic writeback of "old" data.
  *
@@ -1136,7 +1120,7 @@ static long wb_writeback(struct bdi_writeback *wb,
 		 * For background writeout, stop when we are below the
 		 * background dirty threshold
 		 */
-		if (work->for_background && !over_bground_thresh(wb))
+		if (work->for_background && !wb_over_bg_thresh(wb))
 			break;
 
 		/*
@@ -1227,7 +1211,7 @@ static unsigned long get_nr_dirty_pages(void)
 
 static long wb_check_background_flush(struct bdi_writeback *wb)
 {
-	if (over_bground_thresh(wb)) {
+	if (wb_over_bg_thresh(wb)) {
 
 		struct wb_writeback_work work = {
 			.nr_pages	= LONG_MAX,
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 5fdd4e1..b57c2786 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -207,6 +207,7 @@ unsigned long wb_calc_thresh(struct bdi_writeback *wb, unsigned long thresh);
 void wb_update_bandwidth(struct bdi_writeback *wb, unsigned long start_time);
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited(struct address_space *mapping);
+bool wb_over_bg_thresh(struct bdi_writeback *wb);
 
 typedef int (*writepage_t)(struct page *page, struct writeback_control *wbc,
 				void *data);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c8ac8ce..9d9a896 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1740,6 +1740,29 @@ void balance_dirty_pages_ratelimited(struct address_space *mapping)
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited);
 
+/**
+ * wb_over_bg_thresh - does @wb need to be written back?
+ * @wb: bdi_writeback of interest
+ *
+ * Determines whether background writeback should keep writing @wb or it's
+ * clean enough.  Returns %true if writeback should continue.
+ */
+bool wb_over_bg_thresh(struct bdi_writeback *wb)
+{
+	unsigned long background_thresh, dirty_thresh;
+
+	global_dirty_limits(&background_thresh, &dirty_thresh);
+
+	if (global_page_state(NR_FILE_DIRTY) +
+	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
+		return true;
+
+	if (wb_stat(wb, WB_RECLAIMABLE) > wb_calc_thresh(wb, background_thresh))
+		return true;
+
+	return false;
+}
+
 void throttle_vm_writeout(gfp_t gfp_mask)
 {
 	unsigned long background_thresh;
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

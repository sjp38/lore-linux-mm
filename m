Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id F11CF829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:20 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so22213938qkg.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:20 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id 53si3729359qgb.16.2015.05.22.14.15.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:20 -0700 (PDT)
Received: by qget53 with SMTP id t53so16189335qge.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:20 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 33/51] writeback: make bdi_has_dirty_io() take multiple bdi_writeback's into account
Date: Fri, 22 May 2015 17:13:47 -0400
Message-Id: <1432329245-5844-34-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

bdi_has_dirty_io() used to only reflect whether the root wb
(bdi_writeback) has dirty inodes.  For cgroup writeback support, it
needs to take all active wb's into account.  If any wb on the bdi has
dirty inodes, bdi_has_dirty_io() should return true.

To achieve that, as inode_wb_list_{move|del}_locked() now keep track
of the dirty state transition of each wb, the number of dirty wbs can
be counted in the bdi; however, bdi is already aggregating
wb->avg_write_bandwidth which can easily be guaranteed to be > 0 when
there are any dirty inodes by ensuring wb->avg_write_bandwidth can't
dip below 1.  bdi_has_dirty_io() can simply test whether
bdi->tot_write_bandwidth is zero or not.

While this bumps the value of wb->avg_write_bandwidth to one when it
used to be zero, this shouldn't cause any meaningful behavior
difference.

bdi_has_dirty_io() is made an inline function which tests whether
->tot_write_bandwidth is non-zero.  Also, WARN_ON_ONCE()'s on its
value are added to inode_wb_list_{move|del}_locked().

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c                |  5 +++--
 include/linux/backing-dev-defs.h |  8 ++++++--
 include/linux/backing-dev.h      | 10 +++++++++-
 mm/backing-dev.c                 |  5 -----
 mm/page-writeback.c              | 10 +++++++---
 5 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index bbccf68..c98d392 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -99,6 +99,7 @@ static bool wb_io_lists_populated(struct bdi_writeback *wb)
 		return false;
 	} else {
 		set_bit(WB_has_dirty_io, &wb->state);
+		WARN_ON_ONCE(!wb->avg_write_bandwidth);
 		atomic_long_add(wb->avg_write_bandwidth,
 				&wb->bdi->tot_write_bandwidth);
 		return true;
@@ -110,8 +111,8 @@ static void wb_io_lists_depopulated(struct bdi_writeback *wb)
 	if (wb_has_dirty_io(wb) && list_empty(&wb->b_dirty) &&
 	    list_empty(&wb->b_io) && list_empty(&wb->b_more_io)) {
 		clear_bit(WB_has_dirty_io, &wb->state);
-		atomic_long_sub(wb->avg_write_bandwidth,
-				&wb->bdi->tot_write_bandwidth);
+		WARN_ON_ONCE(atomic_long_sub_return(wb->avg_write_bandwidth,
+					&wb->bdi->tot_write_bandwidth) < 0);
 	}
 }
 
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index d631a61..8c857d7 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -98,7 +98,7 @@ struct bdi_writeback {
 	unsigned long dirtied_stamp;
 	unsigned long written_stamp;	/* pages written at bw_time_stamp */
 	unsigned long write_bandwidth;	/* the estimated write bandwidth */
-	unsigned long avg_write_bandwidth; /* further smoothed write bw */
+	unsigned long avg_write_bandwidth; /* further smoothed write bw, > 0 */
 
 	/*
 	 * The base dirty throttle rate, re-calculated on every 200ms.
@@ -142,7 +142,11 @@ struct backing_dev_info {
 	unsigned int min_ratio;
 	unsigned int max_ratio, max_prop_frac;
 
-	atomic_long_t tot_write_bandwidth; /* sum of active avg_write_bw */
+	/*
+	 * Sum of avg_write_bw of wbs with dirty inodes.  > 0 if there are
+	 * any dirty wbs, which is depended upon by bdi_has_dirty().
+	 */
+	atomic_long_t tot_write_bandwidth;
 
 	struct bdi_writeback wb;  /* the root writeback info for this bdi */
 	struct bdi_writeback_congested wb_congested; /* its congested state */
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 3c8403c..0839e44 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -29,7 +29,6 @@ void bdi_start_writeback(struct backing_dev_info *bdi, long nr_pages,
 			enum wb_reason reason);
 void bdi_start_background_writeback(struct backing_dev_info *bdi);
 void wb_workfn(struct work_struct *work);
-bool bdi_has_dirty_io(struct backing_dev_info *bdi);
 void wb_wakeup_delayed(struct bdi_writeback *wb);
 
 extern spinlock_t bdi_lock;
@@ -42,6 +41,15 @@ static inline bool wb_has_dirty_io(struct bdi_writeback *wb)
 	return test_bit(WB_has_dirty_io, &wb->state);
 }
 
+static inline bool bdi_has_dirty_io(struct backing_dev_info *bdi)
+{
+	/*
+	 * @bdi->tot_write_bandwidth is guaranteed to be > 0 if there are
+	 * any dirty wbs.  See wb_update_write_bandwidth().
+	 */
+	return atomic_long_read(&bdi->tot_write_bandwidth);
+}
+
 static inline void __add_wb_stat(struct bdi_writeback *wb,
 				 enum wb_stat_item item, s64 amount)
 {
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 161ddf1..d2f16fc9 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -256,11 +256,6 @@ static int __init default_bdi_init(void)
 }
 subsys_initcall(default_bdi_init);
 
-bool bdi_has_dirty_io(struct backing_dev_info *bdi)
-{
-	return wb_has_dirty_io(&bdi->wb);
-}
-
 /*
  * This function is used when the first inode for this wb is marked dirty. It
  * wakes-up the corresponding bdi thread which should then take care of the
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c95eb24..99b8846 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -881,9 +881,13 @@ static void wb_update_write_bandwidth(struct bdi_writeback *wb,
 		avg += (old - avg) >> 3;
 
 out:
-	if (wb_has_dirty_io(wb))
-		atomic_long_add(avg - wb->avg_write_bandwidth,
-				&wb->bdi->tot_write_bandwidth);
+	/* keep avg > 0 to guarantee that tot > 0 if there are dirty wbs */
+	avg = max(avg, 1LU);
+	if (wb_has_dirty_io(wb)) {
+		long delta = avg - wb->avg_write_bandwidth;
+		WARN_ON_ONCE(atomic_long_add_return(delta,
+					&wb->bdi->tot_write_bandwidth) <= 0);
+	}
 	wb->write_bandwidth = bw;
 	wb->avg_write_bandwidth = avg;
 }
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

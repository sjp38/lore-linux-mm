Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id B54226B0108
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 10:28:18 -0400 (EDT)
Message-Id: <20120328131153.382173637@intel.com>
Date: Wed, 28 Mar 2012 20:13:12 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 4/6] blk-cgroup: buffered write IO controller - bandwidth limit
References: <20120328121308.568545879@intel.com>
Content-Disposition: inline; filename=writeback-io-controller.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Wu Fengguang <fengguang.wu@intel.com>, Suresh Jayaraman <sjayaraman@suse.com>, Andrea Righi <andrea@betterlinux.com>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

A bare per-cgroup buffered write IO controller.

Basically, when there are N dd tasks running in the blkcg,
blkcg->dirty_ratelimit will be balanced around

	blkcg->buffered_write_bps / N

and each blkcg task will be throttled under

	blkcg->dirty_ratelimit
or 
	min(blkcg->dirty_ratelimit, bdi->dirty_ratelimit)
when there are other dirtier tasks in the system.

CC: Vivek Goyal <vgoyal@redhat.com>
CC: Andrea Righi <arighi@develer.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/blk-cgroup.h |   20 +++++++++++
 mm/page-writeback.c        |   59 +++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2012-03-28 15:36:16.414093131 +0800
+++ linux-next/mm/page-writeback.c	2012-03-28 15:40:25.446088022 +0800
@@ -1145,6 +1145,54 @@ static long bdi_min_pause(struct backing
 	return pages >= DIRTY_POLL_THRESH ? 1 + t / 2 : t;
 }
 
+#ifdef CONFIG_BLK_DEV_THROTTLING
+static void blkcg_update_dirty_ratelimit(struct blkio_cgroup *blkcg,
+					 unsigned long dirtied,
+					 unsigned long elapsed)
+{
+	unsigned long long bps = blkcg_buffered_write_bps(blkcg);
+	unsigned long long ratelimit;
+	unsigned long dirty_rate;
+
+	dirty_rate = (dirtied - blkcg->dirtied_stamp) * HZ;
+	dirty_rate /= elapsed;
+
+	ratelimit = blkcg->dirty_ratelimit;
+	ratelimit *= div_u64(bps, dirty_rate + 1);
+	ratelimit = min(ratelimit, bps);
+	ratelimit >>= PAGE_SHIFT;
+
+	blkcg->dirty_ratelimit = (blkcg->dirty_ratelimit + ratelimit) / 2 + 1;
+}
+
+void blkcg_update_bandwidth(struct blkio_cgroup *blkcg)
+{
+	unsigned long now = jiffies;
+	unsigned long dirtied;
+	unsigned long elapsed;
+
+	if (!blkcg)
+		return;
+	if (!spin_trylock(&blkcg->lock))
+		return;
+
+	elapsed = now - blkcg->bw_time_stamp;
+	dirtied = percpu_counter_read(&blkcg->nr_dirtied);
+
+	if (elapsed > MAX_PAUSE * 2)
+		goto snapshot;
+	if (elapsed <= MAX_PAUSE)
+		goto unlock;
+
+	blkcg_update_dirty_ratelimit(blkcg, dirtied, elapsed);
+snapshot:
+	blkcg->dirtied_stamp = dirtied;
+	blkcg->bw_time_stamp = now;
+unlock:
+	spin_unlock(&blkcg->lock);
+}
+#endif
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -1174,6 +1222,7 @@ static void balance_dirty_pages(struct a
 	unsigned long pos_ratio;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	unsigned long start_time = jiffies;
+	struct blkio_cgroup *blkcg = task_blkio_cgroup(current);
 
 	for (;;) {
 		unsigned long now = jiffies;
@@ -1198,6 +1247,8 @@ static void balance_dirty_pages(struct a
 		freerun = dirty_freerun_ceiling(dirty_thresh,
 						background_thresh);
 		if (nr_dirty <= freerun) {
+			if (blkcg_buffered_write_bps(blkcg))
+				goto blkcg_bps;
 			current->dirty_paused_when = now;
 			current->nr_dirtied = 0;
 			current->nr_dirtied_pause =
@@ -1263,6 +1314,14 @@ static void balance_dirty_pages(struct a
 			task_ratelimit = (u64)task_ratelimit *
 				blkcg_weight(blkcg) / BLKIO_WEIGHT_DEFAULT;
 
+		if (blkcg_buffered_write_bps(blkcg) &&
+		    task_ratelimit > blkcg_dirty_ratelimit(blkcg)) {
+blkcg_bps:
+			blkcg_update_bandwidth(blkcg);
+			dirty_ratelimit = blkcg_dirty_ratelimit(blkcg);
+			task_ratelimit = dirty_ratelimit;
+		}
+
 		max_pause = bdi_max_pause(bdi, bdi_dirty);
 		min_pause = bdi_min_pause(bdi, max_pause,
 					  task_ratelimit, dirty_ratelimit,
--- linux-next.orig/include/linux/blk-cgroup.h	2012-03-28 15:36:16.414093131 +0800
+++ linux-next/include/linux/blk-cgroup.h	2012-03-28 15:39:46.730088815 +0800
@@ -122,6 +122,10 @@ struct blkio_cgroup {
 	struct hlist_head blkg_list;
 	struct list_head policy_list; /* list of blkio_policy_node */
 	struct percpu_counter nr_dirtied;
+	unsigned long bw_time_stamp;
+	unsigned long dirtied_stamp;
+	unsigned long dirty_ratelimit;
+	unsigned long long buffered_write_bps;
 };
 
 struct blkio_group_stats {
@@ -217,6 +221,14 @@ static inline unsigned int blkcg_weight(
 {
 	return blkcg->weight;
 }
+static inline uint64_t blkcg_buffered_write_bps(struct blkio_cgroup *blkcg)
+{
+	return blkcg->buffered_write_bps;
+}
+static inline unsigned long blkcg_dirty_ratelimit(struct blkio_cgroup *blkcg)
+{
+	return blkcg->dirty_ratelimit;
+}
 
 typedef void (blkio_unlink_group_fn) (void *key, struct blkio_group *blkg);
 
@@ -272,6 +284,14 @@ static inline unsigned int blkcg_weight(
 {
 	return BLKIO_WEIGHT_DEFAULT;
 }
+static inline uint64_t blkcg_buffered_write_bps(struct blkio_cgroup *blkcg)
+{
+	return 0;
+}
+static inline unsigned long blkcg_dirty_ratelimit(struct blkio_cgroup *blkcg)
+{
+	return 0;
+}
 
 #endif
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

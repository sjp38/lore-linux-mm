Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AE57F8D003C
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 05:17:24 -0500 (EST)
From: Andrea Righi <arighi@develer.com>
Subject: [PATCH 2/3] blkio-throttle: infrastructure to throttle async io
Date: Mon, 28 Feb 2011 11:15:04 +0100
Message-Id: <1298888105-3778-3-git-send-email-arighi@develer.com>
In-Reply-To: <1298888105-3778-1-git-send-email-arighi@develer.com>
References: <1298888105-3778-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Righi <arighi@develer.com>

Add blk_throtl_async() to throttle async io writes.

The idea is to stop applications before they can generate too much dirty
pages in the page cache. Each time a chunk of pages is wrote in memory
we charge the current task / cgroup for the size of the pages dirtied.

If blkio limit are exceeded we also enforce throttling at this layer,
instead of throttling writes at the block IO layer, where it's not
possible to associate the pages with the process that dirtied them.

In this case throttling can be simply enforced via a
schedule_timeout_killable().

Also change some internal blkio function to make them more generic, and
allow to get the size and type of the IO operation without extracting
these information directly from a struct bio. In this way the same
functions can be used also in the contextes where a struct bio is not
yet created (e.g., writes in the page cache).

Signed-off-by: Andrea Righi <arighi@develer.com>
---
 block/blk-throttle.c   |  106 ++++++++++++++++++++++++++++++++----------------
 include/linux/blkdev.h |    6 +++
 2 files changed, 77 insertions(+), 35 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index a89043a..07ef429 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -449,9 +449,8 @@ throtl_trim_slice(struct throtl_data *td, struct throtl_grp *tg, bool rw)
 }
 
 static bool tg_with_in_iops_limit(struct throtl_data *td, struct throtl_grp *tg,
-		struct bio *bio, unsigned long *wait)
+		bool rw, size_t size, unsigned long *wait)
 {
-	bool rw = bio_data_dir(bio);
 	unsigned int io_allowed;
 	unsigned long jiffy_elapsed, jiffy_wait, jiffy_elapsed_rnd;
 	u64 tmp;
@@ -499,9 +498,8 @@ static bool tg_with_in_iops_limit(struct throtl_data *td, struct throtl_grp *tg,
 }
 
 static bool tg_with_in_bps_limit(struct throtl_data *td, struct throtl_grp *tg,
-		struct bio *bio, unsigned long *wait)
+		bool rw, size_t size, unsigned long *wait)
 {
-	bool rw = bio_data_dir(bio);
 	u64 bytes_allowed, extra_bytes, tmp;
 	unsigned long jiffy_elapsed, jiffy_wait, jiffy_elapsed_rnd;
 
@@ -517,14 +515,14 @@ static bool tg_with_in_bps_limit(struct throtl_data *td, struct throtl_grp *tg,
 	do_div(tmp, HZ);
 	bytes_allowed = tmp;
 
-	if (tg->bytes_disp[rw] + bio->bi_size <= bytes_allowed) {
+	if (tg->bytes_disp[rw] + size <= bytes_allowed) {
 		if (wait)
 			*wait = 0;
 		return 1;
 	}
 
 	/* Calc approx time to dispatch */
-	extra_bytes = tg->bytes_disp[rw] + bio->bi_size - bytes_allowed;
+	extra_bytes = tg->bytes_disp[rw] + size - bytes_allowed;
 	jiffy_wait = div64_u64(extra_bytes * HZ, tg->bps[rw]);
 
 	if (!jiffy_wait)
@@ -540,24 +538,11 @@ static bool tg_with_in_bps_limit(struct throtl_data *td, struct throtl_grp *tg,
 	return 0;
 }
 
-/*
- * Returns whether one can dispatch a bio or not. Also returns approx number
- * of jiffies to wait before this bio is with-in IO rate and can be dispatched
- */
 static bool tg_may_dispatch(struct throtl_data *td, struct throtl_grp *tg,
-				struct bio *bio, unsigned long *wait)
+				bool rw, size_t size, unsigned long *wait)
 {
-	bool rw = bio_data_dir(bio);
 	unsigned long bps_wait = 0, iops_wait = 0, max_wait = 0;
 
-	/*
- 	 * Currently whole state machine of group depends on first bio
-	 * queued in the group bio list. So one should not be calling
-	 * this function with a different bio if there are other bios
-	 * queued.
-	 */
-	BUG_ON(tg->nr_queued[rw] && bio != bio_list_peek(&tg->bio_lists[rw]));
-
 	/* If tg->bps = -1, then BW is unlimited */
 	if (tg->bps[rw] == -1 && tg->iops[rw] == -1) {
 		if (wait)
@@ -577,8 +562,8 @@ static bool tg_may_dispatch(struct throtl_data *td, struct throtl_grp *tg,
 			throtl_extend_slice(td, tg, rw, jiffies + throtl_slice);
 	}
 
-	if (tg_with_in_bps_limit(td, tg, bio, &bps_wait)
-	    && tg_with_in_iops_limit(td, tg, bio, &iops_wait)) {
+	if (tg_with_in_bps_limit(td, tg, rw, size, &bps_wait) &&
+			tg_with_in_iops_limit(td, tg, rw, size, &iops_wait)) {
 		if (wait)
 			*wait = 0;
 		return 1;
@@ -595,20 +580,37 @@ static bool tg_may_dispatch(struct throtl_data *td, struct throtl_grp *tg,
 	return 0;
 }
 
-static void throtl_charge_bio(struct throtl_grp *tg, struct bio *bio)
+/*
+ * Returns whether one can dispatch a bio or not. Also returns approx number
+ * of jiffies to wait before this bio is with-in IO rate and can be dispatched
+ */
+static bool tg_may_dispatch_bio(struct throtl_data *td, struct throtl_grp *tg,
+				struct bio *bio, unsigned long *wait)
 {
 	bool rw = bio_data_dir(bio);
-	bool sync = bio->bi_rw & REQ_SYNC;
 
+	/*
+	 * Currently whole state machine of group depends on first bio queued
+	 * in the group bio list. So one should not be calling this function
+	 * with a different bio if there are other bios queued.
+	 */
+	BUG_ON(tg->nr_queued[rw] && bio != bio_list_peek(&tg->bio_lists[rw]));
+
+	return tg_may_dispatch(td, tg, rw, bio->bi_size, wait);
+}
+
+static void
+throtl_charge_io(struct throtl_grp *tg, bool rw, bool sync, size_t size)
+{
 	/* Charge the bio to the group */
-	tg->bytes_disp[rw] += bio->bi_size;
+	tg->bytes_disp[rw] += size;
 	tg->io_disp[rw]++;
 
 	/*
 	 * TODO: This will take blkg->stats_lock. Figure out a way
 	 * to avoid this cost.
 	 */
-	blkiocg_update_dispatch_stats(&tg->blkg, bio->bi_size, rw, sync);
+	blkiocg_update_dispatch_stats(&tg->blkg, size, rw, sync);
 }
 
 static void throtl_add_bio_tg(struct throtl_data *td, struct throtl_grp *tg,
@@ -630,10 +632,10 @@ static void tg_update_disptime(struct throtl_data *td, struct throtl_grp *tg)
 	struct bio *bio;
 
 	if ((bio = bio_list_peek(&tg->bio_lists[READ])))
-		tg_may_dispatch(td, tg, bio, &read_wait);
+		tg_may_dispatch_bio(td, tg, bio, &read_wait);
 
 	if ((bio = bio_list_peek(&tg->bio_lists[WRITE])))
-		tg_may_dispatch(td, tg, bio, &write_wait);
+		tg_may_dispatch_bio(td, tg, bio, &write_wait);
 
 	min_wait = min(read_wait, write_wait);
 	disptime = jiffies + min_wait;
@@ -657,7 +659,8 @@ static void tg_dispatch_one_bio(struct throtl_data *td, struct throtl_grp *tg,
 	BUG_ON(td->nr_queued[rw] <= 0);
 	td->nr_queued[rw]--;
 
-	throtl_charge_bio(tg, bio);
+	throtl_charge_io(tg, bio_data_dir(bio),
+				bio->bi_rw & REQ_SYNC, bio->bi_size);
 	bio_list_add(bl, bio);
 	bio->bi_rw |= REQ_THROTTLED;
 
@@ -674,8 +677,8 @@ static int throtl_dispatch_tg(struct throtl_data *td, struct throtl_grp *tg,
 
 	/* Try to dispatch 75% READS and 25% WRITES */
 
-	while ((bio = bio_list_peek(&tg->bio_lists[READ]))
-		&& tg_may_dispatch(td, tg, bio, NULL)) {
+	while ((bio = bio_list_peek(&tg->bio_lists[READ])) &&
+			tg_may_dispatch_bio(td, tg, bio, NULL)) {
 
 		tg_dispatch_one_bio(td, tg, bio_data_dir(bio), bl);
 		nr_reads++;
@@ -684,8 +687,8 @@ static int throtl_dispatch_tg(struct throtl_data *td, struct throtl_grp *tg,
 			break;
 	}
 
-	while ((bio = bio_list_peek(&tg->bio_lists[WRITE]))
-		&& tg_may_dispatch(td, tg, bio, NULL)) {
+	while ((bio = bio_list_peek(&tg->bio_lists[WRITE])) &&
+			tg_may_dispatch_bio(td, tg, bio, NULL)) {
 
 		tg_dispatch_one_bio(td, tg, bio_data_dir(bio), bl);
 		nr_writes++;
@@ -998,6 +1001,9 @@ int blk_throtl_bio(struct request_queue *q, struct bio **biop)
 		bio->bi_rw &= ~REQ_THROTTLED;
 		return 0;
 	}
+	/* Async writes are ratelimited in blk_throtl_async() */
+	if (rw == WRITE && !(bio->bi_rw & REQ_DIRECT))
+		return 0;
 
 	spin_lock_irq(q->queue_lock);
 	tg = throtl_get_tg(td);
@@ -1018,8 +1024,9 @@ int blk_throtl_bio(struct request_queue *q, struct bio **biop)
 	}
 
 	/* Bio is with-in rate limit of group */
-	if (tg_may_dispatch(td, tg, bio, NULL)) {
-		throtl_charge_bio(tg, bio);
+	if (tg_may_dispatch_bio(td, tg, bio, NULL)) {
+		throtl_charge_io(tg, bio_data_dir(bio),
+				bio->bi_rw & REQ_SYNC, bio->bi_size);
 		goto out;
 	}
 
@@ -1044,6 +1051,35 @@ out:
 	return 0;
 }
 
+/*
+ * Enforce throttling on async i/o writes
+ */
+int blk_throtl_async(struct request_queue *q, size_t size)
+{
+	struct throtl_data *td = q->td;
+	struct throtl_grp *tg;
+	bool rw = 1;
+	unsigned long wait = 0;
+
+	spin_lock_irq(q->queue_lock);
+	tg = throtl_get_tg(td);
+	if (tg_may_dispatch(td, tg, rw, size, &wait))
+		throtl_charge_io(tg, rw, false, size);
+	else
+		throtl_log_tg(td, tg, "[%c] async. bdisp=%u sz=%u bps=%llu"
+				" iodisp=%u iops=%u queued=%d/%d",
+				rw == READ ? 'R' : 'W',
+				tg->bytes_disp[rw], size, tg->bps[rw],
+				tg->io_disp[rw], tg->iops[rw],
+				tg->nr_queued[READ], tg->nr_queued[WRITE]);
+	spin_unlock_irq(q->queue_lock);
+
+	if (wait >= throtl_slice)
+		schedule_timeout_killable(wait);
+
+	return 0;
+}
+
 int blk_throtl_init(struct request_queue *q)
 {
 	struct throtl_data *td;
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 4d18ff3..01c8241 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1136,6 +1136,7 @@ static inline uint64_t rq_io_start_time_ns(struct request *req)
 extern int blk_throtl_init(struct request_queue *q);
 extern void blk_throtl_exit(struct request_queue *q);
 extern int blk_throtl_bio(struct request_queue *q, struct bio **bio);
+extern int blk_throtl_async(struct request_queue *q, size_t size);
 extern void throtl_schedule_delayed_work(struct request_queue *q, unsigned long delay);
 extern void throtl_shutdown_timer_wq(struct request_queue *q);
 #else /* CONFIG_BLK_DEV_THROTTLING */
@@ -1144,6 +1145,11 @@ static inline int blk_throtl_bio(struct request_queue *q, struct bio **bio)
 	return 0;
 }
 
+static inline int blk_throtl_async(struct request_queue *q, size_t size)
+{
+	return 0;
+}
+
 static inline int blk_throtl_init(struct request_queue *q) { return 0; }
 static inline int blk_throtl_exit(struct request_queue *q) { return 0; }
 static inline void throtl_schedule_delayed_work(struct request_queue *q, unsigned long delay) {}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

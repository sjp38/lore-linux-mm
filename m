Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 849776B025F
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 07:45:30 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id q132so7848818lfe.1
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 04:45:30 -0700 (PDT)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [2a02:6b8:0:1630::180])
        by mx.google.com with ESMTPS id i16si583173lfj.132.2017.10.06.04.45.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 04:45:29 -0700 (PDT)
Subject: [PATCH RFC] blk-throttle: add feedback to cgroup writeback about
 throttled writes
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 06 Oct 2017 14:45:26 +0300
Message-ID: <150729032600.744699.6582090880216248200.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-block@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Throttler steals bio before allocating requests for them,
thus throttled writeback never reaches congestion.

This adds bit WB_write_throttled into per-cgroup bdi congestion control.
It's set when write bandwidth limit is exceeded and throttler has at least
one bio inside and cleared when last throttled bio is gone.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 block/blk-throttle.c             |    8 ++++++++
 include/linux/backing-dev-defs.h |   19 +++++++++++++++++++
 include/linux/backing-dev.h      |    6 ++++--
 3 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 0fea76aa0f3f..7ec0aaf9efa7 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -1145,6 +1145,10 @@ static void tg_dispatch_one_bio(struct throtl_grp *tg, bool rw)
 	bio = throtl_pop_queued(&sq->queued[rw], &tg_to_put);
 	sq->nr_queued[rw]--;
 
+	/* Last throttled @bio is gone, clear congestion bit. */
+	if (rw && !sq->nr_queued[rw])
+		clear_wb_throttled(tg_to_blkg(tg)->wb_congested);
+
 	throtl_charge_bio(tg, bio);
 
 	/*
@@ -2215,6 +2219,10 @@ bool blk_throtl_bio(struct request_queue *q, struct blkcg_gq *blkg,
 	 * its @tg's disptime is not in the future.
 	 */
 	if (tg->flags & THROTL_TG_WAS_EMPTY) {
+		/* Next write will be throttled, set congestion bit. */
+		if (rw && blkg)
+			set_wb_throttled(blkg->wb_congested);
+
 		tg_update_disptime(tg);
 		throtl_schedule_next_dispatch(tg->service_queue.parent_sq, true);
 	}
diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index 866c433e7d32..343107fd4eff 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -29,6 +29,7 @@ enum wb_state {
 enum wb_congested_state {
 	WB_async_congested,	/* The async (write) queue is getting full */
 	WB_sync_congested,	/* The sync queue is getting full */
+	WB_write_throttled,	/* Associated blkcg is throttled */
 };
 
 typedef int (congested_fn)(void *, int);
@@ -200,6 +201,16 @@ static inline void set_bdi_congested(struct backing_dev_info *bdi, int sync)
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 
+static inline void set_wb_throttled(struct bdi_writeback_congested *congested)
+{
+	set_bit(WB_write_throttled, &congested->state);
+}
+
+static inline void clear_wb_throttled(struct bdi_writeback_congested *congested)
+{
+	clear_bit(WB_write_throttled, &congested->state);
+}
+
 /**
  * wb_tryget - try to increment a wb's refcount
  * @wb: bdi_writeback to get
@@ -244,6 +255,14 @@ static inline bool wb_dying(struct bdi_writeback *wb)
 
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
+static inline void set_wb_throttled(struct bdi_writeback_congested *congested)
+{
+}
+
+static inline void clear_wb_throttled(struct bdi_writeback_congested *congested)
+{
+}
+
 static inline bool wb_tryget(struct bdi_writeback *wb)
 {
 	return true;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 854e1bdd0b2a..3619641b5ec5 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -460,13 +460,15 @@ static inline int inode_read_congested(struct inode *inode)
 
 static inline int inode_write_congested(struct inode *inode)
 {
-	return inode_congested(inode, 1 << WB_async_congested);
+	return inode_congested(inode, (1 << WB_async_congested) |
+				      (1 << WB_write_throttled));
 }
 
 static inline int inode_rw_congested(struct inode *inode)
 {
 	return inode_congested(inode, (1 << WB_sync_congested) |
-				      (1 << WB_async_congested));
+				      (1 << WB_async_congested) |
+				      (1 << WB_write_throttled));
 }
 
 static inline int bdi_congested(struct backing_dev_info *bdi, int cong_bits)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

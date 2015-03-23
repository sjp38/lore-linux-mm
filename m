Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 77ACD82995
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 01:25:56 -0400 (EDT)
Received: by qgf74 with SMTP id 74so11744729qgf.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:25:56 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com. [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id f74si11269805qge.28.2015.03.22.22.25.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 22:25:55 -0700 (PDT)
Received: by qgfa8 with SMTP id a8so138003602qgf.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 22:25:55 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/8] writeback: implement foreign cgroup inode detection
Date: Mon, 23 Mar 2015 01:25:39 -0400
Message-Id: <1427088344-17542-4-git-send-email-tj@kernel.org>
In-Reply-To: <1427088344-17542-1-git-send-email-tj@kernel.org>
References: <1427088344-17542-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

As concurrent write sharing of an inode is expected to be very rare
and memcg only tracks page ownership on first-use basis severely
confining the usefulness of such sharing, cgroup writeback tracks
ownership per-inode.  While the support for concurrent write sharing
of an inode is deemed unnecessary, an inode being written to by
different cgroups at different points in time is a lot more common,
and, more importantly, charging only by first-use can too readily lead
to grossly incorrect behaviors (single foreign page can lead to
gigabytes of writeback to be incorrectly attributed).

To resolve this issue, cgroup writeback detects the majority dirtier
of an inode and will transfer the ownership to it.  To avoid
unnnecessary oscillation, the detection mechanism keeps track of
history and gives out the switch verdict only if the foreign usage
pattern is stable over a certain amount of time and/or writeback
attempts.

The detection mechanism has fairly low space and computation overhead.
It adds 8 bytes to struct inode (one int and two u16's) and minimal
amount of calculation per IO.  The detection mechanism converges to
the correct answer usually in several seconds of IO time when there's
a clear majority dirtier.  Even when there isn't, it can reach an
acceptable answer fairly quickly under most circumstances.

Please see wb_detach_inode() for more details.

This patch only implements detection.  Following patches will
implement actual switching.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/buffer.c               |   4 +-
 fs/fs-writeback.c         | 168 +++++++++++++++++++++++++++++++++++++++++++++-
 fs/mpage.c                |   1 +
 include/linux/fs.h        |   5 ++
 include/linux/writeback.h |  16 +++++
 5 files changed, 191 insertions(+), 3 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index cb2c7ec..a404d8e 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3044,8 +3044,10 @@ static int submit_bh_wbc(int rw, struct buffer_head *bh,
 	 */
 	bio = bio_alloc(GFP_NOIO, 1);
 
-	if (wbc)
+	if (wbc) {
 		wbc_init_bio(wbc, bio);
+		wbc_account_io(wbc, bh->b_page, bh->b_size);
+	}
 
 	bio->bi_iter.bi_sector = bh->b_blocknr * (bh->b_size >> 9);
 	bio->bi_bdev = bh->b_bdev;
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index da87463..478d26e 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -201,6 +201,20 @@ static void wb_wait_for_completion(struct backing_dev_info *bdi,
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 
+/* parameters for foreign inode detection, see wb_detach_inode() */
+#define WB_FRN_TIME_SHIFT	13	/* 1s = 2^13, upto 8 secs w/ 16bit */
+#define WB_FRN_TIME_AVG_SHIFT	3	/* avg = avg * 7/8 + new * 1/8 */
+#define WB_FRN_TIME_CUT_DIV	2	/* ignore rounds < avg / 2 */
+#define WB_FRN_TIME_PERIOD	(2 * (1 << WB_FRN_TIME_SHIFT))	/* 2s */
+
+#define WB_FRN_HIST_SLOTS	16	/* inode->i_wb_frn_history is 16bit */
+#define WB_FRN_HIST_UNIT	(WB_FRN_TIME_PERIOD / WB_FRN_HIST_SLOTS)
+					/* each slot's duration is 2s / 16 */
+#define WB_FRN_HIST_THR_SLOTS	(WB_FRN_HIST_SLOTS / 2)
+					/* if foreign slots >= 8, switch */
+#define WB_FRN_HIST_MAX_SLOTS	(WB_FRN_HIST_THR_SLOTS / 2 + 1)
+					/* one round can affect upto 5 slots */
+
 void __inode_attach_wb(struct inode *inode, struct page *page)
 {
 	struct backing_dev_info *bdi = inode_to_bdi(inode);
@@ -245,24 +259,174 @@ void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
 				 struct inode *inode)
 {
 	wbc->wb = inode_to_wb(inode);
+	wbc->inode = inode;
+
+	wbc->wb_id = wbc->wb->memcg_css->id;
+	wbc->wb_lcand_id = inode->i_wb_frn_winner;
+	wbc->wb_tcand_id = 0;
+	wbc->wb_bytes = 0;
+	wbc->wb_lcand_bytes = 0;
+	wbc->wb_tcand_bytes = 0;
+
 	wb_get(wbc->wb);
 	spin_unlock(&inode->i_lock);
 }
 
 /**
- * wbc_detach_inode - disassociate wbc from its target inode
- * @wbc: writeback_control of interest
+ * wbc_detach_inode - disassociate wbc from inode and perform foreign detection
+ * @wbc: writeback_control of the just finished writeback
  *
  * To be called after a writeback attempt of an inode finishes and undoes
  * wbc_attach_and_unlock_inode().  Can be called under any context.
+ *
+ * As concurrent write sharing of an inode is expected to be very rare and
+ * memcg only tracks page ownership on first-use basis severely confining
+ * the usefulness of such sharing, cgroup writeback tracks ownership
+ * per-inode.  While the support for concurrent write sharing of an inode
+ * is deemed unnecessary, an inode being written to by different cgroups at
+ * different points in time is a lot more common, and, more importantly,
+ * charging only by first-use can too readily lead to grossly incorrect
+ * behaviors (single foreign page can lead to gigabytes of writeback to be
+ * incorrectly attributed).
+ *
+ * To resolve this issue, cgroup writeback detects the majority dirtier of
+ * an inode and transfers the ownership to it.  To avoid unnnecessary
+ * oscillation, the detection mechanism keeps track of history and gives
+ * out the switch verdict only if the foreign usage pattern is stable over
+ * a certain amount of time and/or writeback attempts.
+ *
+ * On each writeback attempt, @wbc tries to detect the majority writer
+ * using Boyer-Moore majority vote algorithm.  In addition to the byte
+ * count from the majority voting, it also counts the bytes written for the
+ * current wb and the last round's winner wb (max of last round's current
+ * wb, the winner from two rounds ago, and the last round's majority
+ * candidate).  Keeping track of the historical winner helps the algorithm
+ * to semi-reliably detect the most active writer even when it's not the
+ * absolute majority.
+ *
+ * Once the winner of the round is determined, whether the winner is
+ * foreign or not and how much IO time the round consumed is recorded in
+ * inode->i_wb_frn_history.  If the amount of recorded foreign IO time is
+ * over a certain threshold, the switch verdict is given.
  */
 void wbc_detach_inode(struct writeback_control *wbc)
 {
+	struct bdi_writeback *wb = wbc->wb;
+	struct inode *inode = wbc->inode;
+	u16 history = inode->i_wb_frn_history;
+	unsigned long avg_time = inode->i_wb_frn_avg_time;
+	unsigned long max_bytes, max_time;
+	int max_id;
+
+	/* pick the winner of this round */
+	if (wbc->wb_bytes >= wbc->wb_lcand_bytes &&
+	    wbc->wb_bytes >= wbc->wb_tcand_bytes) {
+		max_id = wbc->wb_id;
+		max_bytes = wbc->wb_bytes;
+	} else if (wbc->wb_lcand_bytes >= wbc->wb_tcand_bytes) {
+		max_id = wbc->wb_lcand_id;
+		max_bytes = wbc->wb_lcand_bytes;
+	} else {
+		max_id = wbc->wb_tcand_id;
+		max_bytes = wbc->wb_tcand_bytes;
+	}
+
+	/*
+	 * Calculate the amount of IO time the winner consumed and fold it
+	 * into the running average kept per inode.  If the consumed IO
+	 * time is lower than avag / WB_FRN_TIME_CUT_DIV, ignore it for
+	 * deciding whether to switch or not.  This is to prevent one-off
+	 * small dirtiers from skewing the verdict.
+	 */
+	max_time = DIV_ROUND_UP((max_bytes >> PAGE_SHIFT) << WB_FRN_TIME_SHIFT,
+				wb->avg_write_bandwidth);
+	if (avg_time)
+		avg_time += (max_time >> WB_FRN_TIME_AVG_SHIFT) -
+			    (avg_time >> WB_FRN_TIME_AVG_SHIFT);
+	else
+		avg_time = max_time;	/* immediate catch up on first run */
+
+	if (max_time >= avg_time / WB_FRN_TIME_CUT_DIV) {
+		int slots;
+
+		/*
+		 * The switch verdict is reached if foreign wb's consume
+		 * more than a certain proportion of IO time in a
+		 * WB_FRN_TIME_PERIOD.  This is loosely tracked by 16 slot
+		 * history mask where each bit represents one sixteenth of
+		 * the period.  Determine the number of slots to shift into
+		 * history from @max_time.
+		 */
+		slots = min(DIV_ROUND_UP(max_time, WB_FRN_HIST_UNIT),
+			    (unsigned long)WB_FRN_HIST_MAX_SLOTS);
+		history <<= slots;
+		if (wbc->wb_id != max_id)
+			history |= (1U << slots) - 1;
+
+		/*
+		 * Switch if the current wb isn't the consistent winner.
+		 * If there are multiple closely competing dirtiers, the
+		 * inode may switch across them repeatedly over time, which
+		 * is okay.  The main goal is avoiding keeping an inode on
+		 * the wrong wb for an extended period of time.
+		 */
+		if (hweight32(history) > WB_FRN_HIST_THR_SLOTS) {
+			/* switch */
+			max_id = 0;
+			avg_time = 0;
+			history = 0;
+		}
+	}
+
+	/*
+	 * Multiple instances of this function may race to update the
+	 * following fields but we don't mind occassional inaccuracies.
+	 */
+	inode->i_wb_frn_winner = max_id;
+	inode->i_wb_frn_avg_time = min(avg_time, (unsigned long)U16_MAX);
+	inode->i_wb_frn_history = history;
+
 	wb_put(wbc->wb);
 	wbc->wb = NULL;
 }
 
 /**
+ * wbc_account_io - account IO issued during writeback
+ * @wbc: writeback_control of the writeback in progress
+ * @page: page being written out
+ * @bytes: number of bytes being written out
+ *
+ * @bytes from @page are about to written out during the writeback
+ * controlled by @wbc.  Keep the book for foreign inode detection.  See
+ * wbc_detach_inode().
+ */
+void wbc_account_io(struct writeback_control *wbc, struct page *page,
+		    size_t bytes)
+{
+	int id;
+
+	rcu_read_lock();
+	id = mem_cgroup_css_from_page(page)->id;
+	rcu_read_unlock();
+
+	if (id == wbc->wb_id) {
+		wbc->wb_bytes += bytes;
+		return;
+	}
+
+	if (id == wbc->wb_lcand_id)
+		wbc->wb_lcand_bytes += bytes;
+
+	/* Boyer-Moore majority vote algorithm */
+	if (!wbc->wb_tcand_bytes)
+		wbc->wb_tcand_id = id;
+	if (id == wbc->wb_tcand_id)
+		wbc->wb_tcand_bytes += bytes;
+	else
+		wbc->wb_tcand_bytes -= min(bytes, wbc->wb_tcand_bytes);
+}
+
+/**
  * mapping_congested - test whether a mapping is congested for a task
  * @mapping: address space to test for congestion
  * @task: task to test congestion for
diff --git a/fs/mpage.c b/fs/mpage.c
index 388fde6..ca0244b 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -614,6 +614,7 @@ alloc_new:
 	 * the confused fail path above (OOM) will be very confused when
 	 * it finds all bh marked clean (i.e. it will not write anything)
 	 */
+	wbc_account_io(wbc, page, PAGE_SIZE);
 	length = first_unmapped << blkbits;
 	if (bio_add_page(bio, page, length, 0) < length) {
 		bio = mpage_bio_submit(WRITE, bio);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 4c740ca..6c3ea8a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -610,6 +610,11 @@ struct inode {
 	struct list_head	i_wb_list;	/* backing dev IO list */
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct bdi_writeback	*i_wb;		/* the associated cgroup wb */
+
+	/* foreign inode detection, see wbc_detach_inode() */
+	int			i_wb_frn_winner;
+	u16			i_wb_frn_avg_time;
+	u16			i_wb_frn_history;
 #endif
 	struct list_head	i_lru;		/* inode LRU list */
 	struct list_head	i_sb_list;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 7211baa..b16b8ba 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -88,6 +88,15 @@ struct writeback_control {
 	unsigned for_sync:1;		/* sync(2) WB_SYNC_ALL writeback */
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct bdi_writeback *wb;	/* wb this writeback is issued under */
+	struct inode *inode;		/* inode being written out */
+
+	/* foreign inode detection, see wbc_detach_inode() */
+	int wb_id;			/* current wb id */
+	int wb_lcand_id;		/* last foreign candidate wb id */
+	int wb_tcand_id;		/* this foreign candidate wb id */
+	size_t wb_bytes;		/* bytes written by current wb */
+	size_t wb_lcand_bytes;		/* bytes written by last candidate */
+	size_t wb_tcand_bytes;		/* bytes written by this candidate */
 #endif
 };
 
@@ -187,6 +196,8 @@ void wbc_attach_and_unlock_inode(struct writeback_control *wbc,
 				 struct inode *inode)
 	__releases(&inode->i_lock);
 void wbc_detach_inode(struct writeback_control *wbc);
+void wbc_account_io(struct writeback_control *wbc, struct page *page,
+		    size_t bytes);
 
 /**
  * inode_attach_wb - associate an inode with its wb
@@ -278,6 +289,11 @@ static inline void wbc_init_bio(struct writeback_control *wbc, struct bio *bio)
 {
 }
 
+static inline void wbc_account_io(struct writeback_control *wbc,
+				  struct page *page, size_t bytes)
+{
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

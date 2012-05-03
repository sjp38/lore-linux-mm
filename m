Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 27EB46B00ED
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:24:11 -0400 (EDT)
From: Venkatraman S <svenkatr@ti.com>
Subject: [PATCH v2 06/16] block: treat DMPG and SWAPIN requests as special
Date: Thu, 3 May 2012 19:53:05 +0530
Message-ID: <1336054995-22988-7-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk, Venkatraman S <svenkatr@ti.com>

From: Ilan Smith <ilan.smith@sandisk.com>

When exp_swapin and exp_dmpg are set, treat read requests
marked with DMPG and SWAPIN as high priority and move to
the front of the queue.

Signed-off-by: Ilan Smith <ilan.smith@sandisk.com>
Signed-off-by: Alex Lemberg <alex.lemberg@sandisk.com>
Signed-off-by: Venkatraman S <svenkatr@ti.com>
---
 block/blk-core.c |   18 ++++++++++++++++++
 block/elevator.c |   14 +++++++++++++-
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 1f61b74..7a1b98b 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1306,6 +1306,12 @@ void init_request_from_bio(struct request *req, struct bio *bio)
 	if (bio->bi_rw & REQ_RAHEAD)
 		req->cmd_flags |= REQ_FAILFAST_MASK;
 
+	if (bio_swapin(bio) && blk_queue_exp_swapin(req->q))
+		req->cmd_flags |= REQ_RW_SWAPIN | REQ_NOMERGE;
+
+	if (bio_dmpg(bio) && blk_queue_exp_dmpg(req->q))
+		req->cmd_flags |= REQ_RW_DMPG | REQ_NOMERGE;
+
 	req->errors = 0;
 	req->__sector = bio->bi_sector;
 	req->ioprio = bio_prio(bio);
@@ -1333,6 +1339,18 @@ void blk_queue_bio(struct request_queue *q, struct bio *bio)
 		goto get_rq;
 	}
 
+	if (bio_swapin(bio) && blk_queue_exp_swapin(q)) {
+		spin_lock_irq(q->queue_lock);
+		where = ELEVATOR_INSERT_FLUSH;
+		goto get_rq;
+	}
+
+	if (bio_dmpg(bio) && blk_queue_exp_dmpg(q)) {
+		spin_lock_irq(q->queue_lock);
+		where = ELEVATOR_INSERT_FLUSH;
+		goto get_rq;
+	}
+
 	/*
 	 * Check if we can merge with the plugged list before grabbing
 	 * any locks.
diff --git a/block/elevator.c b/block/elevator.c
index f016855..76d571b 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -367,7 +367,8 @@ void elv_dispatch_sort(struct request_queue *q, struct request *rq)
 	q->nr_sorted--;
 
 	boundary = q->end_sector;
-	stop_flags = REQ_SOFTBARRIER | REQ_STARTED;
+	stop_flags = REQ_SOFTBARRIER | REQ_STARTED
+		| REQ_RW_SWAPIN	| REQ_RW_DMPG ;
 	list_for_each_prev(entry, &q->queue_head) {
 		struct request *pos = list_entry_rq(entry);
 
@@ -585,6 +586,17 @@ void elv_quiesce_end(struct request_queue *q)
 
 void __elv_add_request(struct request_queue *q, struct request *rq, int where)
 {
+	unsigned int hpi_flags = REQ_RW_DMPG | REQ_RW_SWAPIN;
+
+	if (rq->cmd_flags & hpi_flags) {
+		/*
+		 * Insert swap-in or demand page requests at the front. This
+		 * causes them to be queued in the reversed order.
+		 */
+		where = ELEVATOR_INSERT_FRONT;
+	} else
+
+
 	trace_block_rq_insert(q, rq);
 
 	rq->q = q;
-- 
1.7.10.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

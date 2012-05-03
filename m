Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id E62EF6B00EC
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:24:51 -0400 (EDT)
From: Venkatraman S <svenkatr@ti.com>
Subject: [PATCH v2 14/16] mmc: block: Implement HPI invocation and handling logic.
Date: Thu, 3 May 2012 19:53:13 +0530
Message-ID: <1336054995-22988-15-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk, Venkatraman S <svenkatr@ti.com>

Intercept command which require high priority treatment.
If the ongoing command can be preempted according to JEDEC HPI
definition and sufficient window exist to complete an ongoing
request, invoke HPI and abort the current request, and issue
the high priority request.
Otherwise, process the command normally.

Signed-off-by: Venkatraman S <svenkatr@ti.com>
---
 drivers/mmc/card/block.c |  131 +++++++++++++++++++++++++++++++++++++++++++---
 drivers/mmc/card/queue.h |    1 +
 2 files changed, 124 insertions(+), 8 deletions(-)

diff --git a/drivers/mmc/card/block.c b/drivers/mmc/card/block.c
index 11833e4..3dd662b 100644
--- a/drivers/mmc/card/block.c
+++ b/drivers/mmc/card/block.c
@@ -1276,7 +1276,7 @@ static int mmc_blk_cmd_err(struct mmc_blk_data *md, struct mmc_card *card,
 	return ret;
 }
 
-static int mmc_blk_issue_rw_rq(struct mmc_queue *mq, struct request *rqc)
+static int mmc_blk_execute_rw_rq(struct mmc_queue *mq, struct request *rqc)
 {
 	struct mmc_blk_data *md = mq->data;
 	struct mmc_card *card = md->queue.card;
@@ -1285,22 +1285,31 @@ static int mmc_blk_issue_rw_rq(struct mmc_queue *mq, struct request *rqc)
 	enum mmc_blk_status status;
 	struct mmc_queue_req *mq_rq;
 	struct request *req;
-	struct mmc_async_req *areq;
+	struct mmc_async_req *prev_req, *cur_req;
 
 	if (!rqc && !mq->mqrq_prev->req)
 		return 0;
 
+	mq->mqrq_interrupted = NULL;
+
 	do {
 		if (rqc) {
 			mmc_blk_rw_rq_prep(mq->mqrq_cur, card, 0, mq);
-			areq = &mq->mqrq_cur->mmc_active;
-		} else
-			areq = NULL;
-		areq = mmc_start_req(card->host, areq, (int *) &status);
-		if (!areq)
+			cur_req = &mq->mqrq_cur->mmc_active;
+		} else {
+			cur_req = NULL;
+		}
+		prev_req = mmc_start_req(card->host, cur_req, (int *) &status);
+		if (!prev_req)
 			return 0;
 
-		mq_rq = container_of(areq, struct mmc_queue_req, mmc_active);
+		if (cur_req &&
+			cur_req->mrq->cmd->cmd_attr & MMC_CMD_PREEMPTIBLE) {
+			mq->mqrq_interrupted = mq->mqrq_cur;
+		}
+
+		mq_rq = container_of(prev_req,
+			struct mmc_queue_req, mmc_active);
 		brq = &mq_rq->brq;
 		req = mq_rq->req;
 		type = rq_data_dir(req) == READ ? MMC_BLK_READ : MMC_BLK_WRITE;
@@ -1406,6 +1415,112 @@ static int mmc_blk_issue_rw_rq(struct mmc_queue *mq, struct request *rqc)
 	return 0;
 }
 
+#define HPI_CHECK  (REQ_RW_SWAPIN | REQ_RW_DMPG)
+
+static bool mmc_can_do_foreground_hpi(struct mmc_queue *mq,
+			struct request *req, unsigned int thpi)
+{
+
+	/*
+	 * If some time has elapsed since the issuing of previous write
+	 * command, or if the size of the request was too small, there's
+	 * no point in preempting it. Check if it's worthwhile to preempt
+	 */
+	int time_elapsed = jiffies_to_msecs(jiffies -
+			mq->mqrq_cur->mmc_active.mrq->cmd->started_time);
+
+	if (time_elapsed <= thpi)
+			return true;
+
+	return false;
+}
+
+/*
+ * When a HPI command had been given for a foreground
+ * request, the host controller will finish the request,
+ * the completion request has to be handled differently
+ */
+static struct mmc_async_req *mmc_handle_aborted_request(struct mmc_queue *mq,
+	int hpi_err)
+{
+	struct mmc_async_req *areq;
+	struct mmc_request *mrq;
+	struct mmc_queue_req *mq_rq;
+	struct mmc_blk_data *md = mq->data;
+	struct request *req;
+
+	BUG_ON(!mq->mqrq_interrupted);
+
+	areq = &mq->mqrq_interrupted->mmc_active;
+	mrq = areq->mrq;
+
+	/* Error checking is TBD */
+	mq_rq = container_of(areq, struct mmc_queue_req, mmc_active);
+	req = mq_rq->req;
+	mmc_queue_bounce_post(mq_rq);
+
+	spin_lock_irq(&md->lock);
+	/*
+	 * TODO. Do the error translation as done in
+	 * blk_err_check here and propogate
+	 * the partial transfer status if applicable
+	 */
+	__blk_end_request(req, -EIO, 0);
+	spin_unlock_irq(&md->lock);
+	return areq;
+}
+
+static int mmc_blk_issue_rw_rq(struct mmc_queue *mq, struct request *req)
+{
+	int ret;
+	struct mmc_blk_data *md = mq->data;
+	struct mmc_card *card = md->queue.card;
+	struct mmc_async_req *areq;
+
+	if (req && md->flags & MMC_HPI_SUPPORT) {
+		if (!((req->cmd_flags & HPI_CHECK) && mq->mqrq_interrupted))
+			goto no_preempt;
+		if (!mmc_can_do_foreground_hpi(mq, req,
+			card->preempt_time_threshold))
+			goto no_preempt;
+
+		pr_debug("Pre-empting ongoing request %pK\n",
+			mq->mqrq_interrupted);
+
+		ret = mmc_preempt_foreground_request(card,
+			 mq->mqrq_interrupted->mmc_active.mrq);
+		if (ret)
+			/*
+			 * Couldn't execute HPI, or the request could
+			 * have been completed already. Go through
+			 * the normal route
+			 */
+			goto no_preempt;
+
+		areq = mmc_handle_aborted_request(mq, ret);
+		/*
+		 * Remove the request from the host controller's
+		 * request queue. This prevents normal error handling
+		 * and retry procedures from executing (we know the
+		 * request has been aborted anyway). This also helps to start
+		 * the urgent requests without doing the post processing
+		 * of the aborted request
+		 */
+		card->host->areq = NULL;
+		/*
+		 * Now the decks are clear to send the most urgent command.
+		 * As we've preempted the ongoing one already, the urgent
+		 * one can go through the normal queue and it won't face much
+		 * resistance - hence the intentional fall through
+		 */
+		BUG_ON(areq != &mq->mqrq_interrupted->mmc_active);
+
+	}
+no_preempt:
+	ret = mmc_blk_execute_rw_rq(mq, req);
+	return ret;
+}
+
 static int mmc_blk_issue_rq(struct mmc_queue *mq, struct request *req)
 {
 	int ret;
diff --git a/drivers/mmc/card/queue.h b/drivers/mmc/card/queue.h
index d2a1eb4..7bd599e 100644
--- a/drivers/mmc/card/queue.h
+++ b/drivers/mmc/card/queue.h
@@ -33,6 +33,7 @@ struct mmc_queue {
 	struct mmc_queue_req	mqrq[2];
 	struct mmc_queue_req	*mqrq_cur;
 	struct mmc_queue_req	*mqrq_prev;
+	struct mmc_queue_req	*mqrq_interrupted;
 };
 
 extern int mmc_init_queue(struct mmc_queue *, struct mmc_card *, spinlock_t *,
-- 
1.7.10.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

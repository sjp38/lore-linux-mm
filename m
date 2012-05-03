Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 9EB416B00E9
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:25:02 -0400 (EDT)
From: Venkatraman S <svenkatr@ti.com>
Subject: [PATCH v2 16/16] mmc: omap_hsmmc: Implement abort_req host_ops
Date: Thu, 3 May 2012 19:53:15 +0530
Message-ID: <1336054995-22988-17-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk, Venkatraman S <svenkatr@ti.com>

Provide the abort_req implementation for omap_hsmmc host.

When invoked, the host controller should stop the transfer
and end the ongoing request as early as possible.

If the aborted command is a data transfer command, dma setup is
aborted and a STOP command is issued. The transfer state is
marked as an error (except when the command has almost completed
while receiving the abort request, in which case finish the command
normally).

Signed-off-by: Venkatraman S <svenkatr@ti.com>
---
 drivers/mmc/host/omap_hsmmc.c |   55 ++++++++++++++++++++++++++++++++++++++---
 1 file changed, 51 insertions(+), 4 deletions(-)

diff --git a/drivers/mmc/host/omap_hsmmc.c b/drivers/mmc/host/omap_hsmmc.c
index d15b149..a4da478 100644
--- a/drivers/mmc/host/omap_hsmmc.c
+++ b/drivers/mmc/host/omap_hsmmc.c
@@ -177,6 +177,7 @@ struct omap_hsmmc_host {
 	int			reqs_blocked;
 	int			use_reg;
 	int			req_in_progress;
+	int			abort_in_progress;
 	unsigned int		flags;
 	struct omap_hsmmc_next	next_data;
 
@@ -982,6 +983,7 @@ static inline void omap_hsmmc_reset_controller_fsm(struct omap_hsmmc_host *host,
 static void omap_hsmmc_do_irq(struct omap_hsmmc_host *host, int status)
 {
 	struct mmc_data *data;
+	int err = 0;
 	int end_cmd = 0, end_trans = 0;
 
 	if (!host->req_in_progress) {
@@ -993,6 +995,11 @@ static void omap_hsmmc_do_irq(struct omap_hsmmc_host *host, int status)
 		return;
 	}
 
+	if (host->abort_in_progress) {
+		end_trans = 1;
+		end_cmd = 1;
+	}
+
 	data = host->data;
 	dev_dbg(mmc_dev(host->mmc), "IRQ Status is %x\n", status);
 
@@ -1021,7 +1028,7 @@ static void omap_hsmmc_do_irq(struct omap_hsmmc_host *host, int status)
 		if ((status & DATA_TIMEOUT) ||
 			(status & DATA_CRC)) {
 			if (host->data || host->response_busy) {
-				int err = (status & DATA_TIMEOUT) ?
+				err = (status & DATA_TIMEOUT) ?
 						-ETIMEDOUT : -EILSEQ;
 
 				if (host->data)
@@ -1045,10 +1052,13 @@ static void omap_hsmmc_do_irq(struct omap_hsmmc_host *host, int status)
 
 	OMAP_HSMMC_WRITE(host->base, STAT, status);
 
-	if (end_cmd || ((status & CC) && host->cmd))
+	if ((end_cmd || (status & CC)) && host->cmd)
 		omap_hsmmc_cmd_done(host, host->cmd);
-	if ((end_trans || (status & TC)) && host->mrq)
+	if ((end_trans || (status & TC)) && host->mrq) {
+		if (data)
+			data->error = err;
 		omap_hsmmc_xfer_done(host, data);
+	}
 }
 
 /*
@@ -1257,7 +1267,7 @@ static void omap_hsmmc_dma_cb(int lch, u16 ch_status, void *cb_data)
 	}
 
 	spin_lock_irqsave(&host->irq_lock, flags);
-	if (host->dma_ch < 0) {
+	if (host->dma_ch < 0 || host->abort_in_progress) {
 		spin_unlock_irqrestore(&host->irq_lock, flags);
 		return;
 	}
@@ -1478,6 +1488,40 @@ static void omap_hsmmc_pre_req(struct mmc_host *mmc, struct mmc_request *mrq,
 			mrq->data->host_cookie = 0;
 }
 
+static int omap_hsmmc_abort_req(struct mmc_host *mmc, struct mmc_request *req)
+{
+	struct omap_hsmmc_host *host = mmc_priv(mmc);
+	unsigned long flags;
+
+	if (!host->req_in_progress) {
+		dev_dbg(mmc_dev(host->mmc), "No request to abort\n");
+		return -EINVAL;
+	}
+	if (req && req != host->mrq) {
+		dev_dbg(mmc_dev(host->mmc), "Non matching abort request\n");
+		return -EINVAL;
+	}
+	spin_lock_irqsave(&host->irq_lock, flags);
+	host->abort_in_progress = 1;
+	omap_hsmmc_disable_irq(host);
+	spin_unlock_irqrestore(&host->irq_lock, flags);
+
+	host->response_busy = 0;
+
+	if (host->data) {
+		struct mmc_data *dat = host->data;
+		omap_hsmmc_dma_cleanup(host, -EIO);
+		dev_dbg(mmc_dev(host->mmc), "Aborting Transfer\n");
+		omap_hsmmc_xfer_done(host, dat);
+	} else if (host->cmd) {
+		dev_dbg(mmc_dev(host->mmc), "Aborting Command\n");
+		omap_hsmmc_cmd_done(host, host->cmd);
+	}
+
+	dev_dbg(mmc_dev(host->mmc), "Request %pK aborted\n", req);
+	return 0;
+
+}
 /*
  * Request function. for read/write operation
  */
@@ -1488,6 +1532,8 @@ static void omap_hsmmc_request(struct mmc_host *mmc, struct mmc_request *req)
 
 	BUG_ON(host->req_in_progress);
 	BUG_ON(host->dma_ch != -1);
+	host->abort_in_progress = 0;
+
 	if (host->protect_card) {
 		if (host->reqs_blocked < 3) {
 			/*
@@ -1664,6 +1710,7 @@ static const struct mmc_host_ops omap_hsmmc_ops = {
 	.disable = omap_hsmmc_disable_fclk,
 	.post_req = omap_hsmmc_post_req,
 	.pre_req = omap_hsmmc_pre_req,
+	.abort_req = omap_hsmmc_abort_req,
 	.request = omap_hsmmc_request,
 	.set_ios = omap_hsmmc_set_ios,
 	.get_cd = omap_hsmmc_get_cd,
-- 
1.7.10.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

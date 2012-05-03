Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 2EBAE6B00F3
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:24:35 -0400 (EDT)
From: Venkatraman S <svenkatr@ti.com>
Subject: [PATCH v2 11/16] mmc: core: Implement foreground request preemption procedure
Date: Thu, 3 May 2012 19:53:10 +0530
Message-ID: <1336054995-22988-12-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk, Venkatraman S <svenkatr@ti.com>

When invoked, ongoing command at the host controller should abort
and completion should be invoked.

It's quite possible that the interruption will race with the
successful completion of the command. If so, HPI is invoked
only when the low level driver sets an error flag for the
aborted request.

Signed-off-by: Venkatraman S <svenkatr@ti.com>
---
 drivers/mmc/core/core.c  |   32 ++++++++++++++++++++++++++++++++
 include/linux/mmc/core.h |    2 ++
 2 files changed, 34 insertions(+)

diff --git a/drivers/mmc/core/core.c b/drivers/mmc/core/core.c
index 3f0e927..e6430f8 100644
--- a/drivers/mmc/core/core.c
+++ b/drivers/mmc/core/core.c
@@ -466,6 +466,38 @@ out:
 }
 EXPORT_SYMBOL(mmc_interrupt_hpi);
 
+int mmc_preempt_foreground_request(struct mmc_card *card,
+	struct mmc_request *req)
+{
+	int ret;
+
+	ret = mmc_abort_req(card->host, req);
+	if (ret == -ENOSYS)
+		return ret;
+	/*
+	 * Whether or not abort was successful, the command is
+	 * still under the host controller's context.
+	 * Should wait for the completion to be returned.
+	 */
+	wait_for_completion(&req->completion);
+	/*
+	 * Checkpoint the aborted request.
+	 * If error is set, the request completed partially,
+	 * and the ext_csd field "CORRECTLY_PRG_SECTORS_NUM"
+	 * contains the number of blocks written to the device.
+	 * If error is not set, the request was completed
+	 * successfully and there is no need to try it again.
+	 */
+	if (req->data && req->data->error) {
+		mmc_interrupt_hpi(card);
+		/* TODO : Take out the CORRECTLY_PRG_SECTORS_NUM
+		 * from ext_csd and add it to the request */
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(mmc_preempt_foreground_request);
+
 /**
  *	mmc_wait_for_cmd - start a command and wait for completion
  *	@host: MMC host to start command
diff --git a/include/linux/mmc/core.h b/include/linux/mmc/core.h
index d86144e..e2d55c6 100644
--- a/include/linux/mmc/core.h
+++ b/include/linux/mmc/core.h
@@ -144,6 +144,8 @@ extern struct mmc_async_req *mmc_start_req(struct mmc_host *,
 extern int mmc_interrupt_hpi(struct mmc_card *);
 extern void mmc_wait_for_req(struct mmc_host *, struct mmc_request *);
 extern int mmc_wait_for_cmd(struct mmc_host *, struct mmc_command *, int);
+extern int mmc_preempt_foreground_request(struct mmc_card *card,
+	struct mmc_request *req);
 extern int mmc_app_cmd(struct mmc_host *, struct mmc_card *);
 extern int mmc_wait_for_app_cmd(struct mmc_host *, struct mmc_card *,
 	struct mmc_command *, int);
-- 
1.7.10.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

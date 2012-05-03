Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id E04676B00F0
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:24:20 -0400 (EDT)
From: Venkatraman S <svenkatr@ti.com>
Subject: [PATCH v2 08/16] mmc: core: add preemptibility tracking fields to mmc command
Date: Thu, 3 May 2012 19:53:07 +0530
Message-ID: <1336054995-22988-9-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk, Venkatraman S <svenkatr@ti.com>

Set a preemptibility command atrribute to MMC commands. This
can be later used by write (multi block), trim etc for
evaluating if a HPI is applicable.

Note the starting time of executing a command so a decision
can be made if it is too late for preemption.

Signed-off-by: Venkatraman S <svenkatr@ti.com>
---
 drivers/mmc/core/core.c  |    5 +++++
 include/linux/mmc/core.h |    4 ++++
 2 files changed, 9 insertions(+)

diff --git a/drivers/mmc/core/core.c b/drivers/mmc/core/core.c
index c4cd6fb..b4152ca 100644
--- a/drivers/mmc/core/core.c
+++ b/drivers/mmc/core/core.c
@@ -258,6 +258,11 @@ static int __mmc_start_req(struct mmc_host *host, struct mmc_request *mrq)
 		complete(&mrq->completion);
 		return -ENOMEDIUM;
 	}
+	if (mmc_is_preemptible_command(mrq->cmd))
+		mrq->cmd->cmd_attr |= MMC_CMD_PREEMPTIBLE;
+	else
+		mrq->cmd->cmd_attr &= ~MMC_CMD_PREEMPTIBLE;
+	mrq->cmd->started_time = jiffies;
 	mmc_start_request(host, mrq);
 	return 0;
 }
diff --git a/include/linux/mmc/core.h b/include/linux/mmc/core.h
index 680e256..d86144e 100644
--- a/include/linux/mmc/core.h
+++ b/include/linux/mmc/core.h
@@ -76,6 +76,10 @@ struct mmc_command {
  */
 #define mmc_cmd_type(cmd)	((cmd)->flags & MMC_CMD_MASK)
 
+	unsigned int		cmd_attr; /*Runtime attributes of the command */
+#define MMC_CMD_PREEMPTIBLE	BIT(0)
+#define MMC_CMD_PREEMPTED	BIT(1)
+	unsigned long		started_time;
 	unsigned int		retries;	/* max number of retries */
 	unsigned int		error;		/* command error */
 
-- 
1.7.10.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 6464C6B00F2
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:24:25 -0400 (EDT)
From: Venkatraman S <svenkatr@ti.com>
Subject: [PATCH v2 09/16] mmc: core: Add MMC abort interface
Date: Thu, 3 May 2012 19:53:08 +0530
Message-ID: <1336054995-22988-10-git-send-email-svenkatr@ti.com>
In-Reply-To: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk, Venkatraman S <svenkatr@ti.com>

HPI (and possibly other) procedures require that an ongoing
mmc request issued to a controller be aborted in the middle
of a transaction. Define a abort interface function to the
controller so that individual host controllers can safely
abort a request, stop the dma and cleanup their statemachine
etc. The implementation is controller dependant

Signed-off-by: Venkatraman S <svenkatr@ti.com>
---
 drivers/mmc/core/core.c  |    8 ++++++++
 include/linux/mmc/host.h |    1 +
 2 files changed, 9 insertions(+)

diff --git a/drivers/mmc/core/core.c b/drivers/mmc/core/core.c
index b4152ca..3f0e927 100644
--- a/drivers/mmc/core/core.c
+++ b/drivers/mmc/core/core.c
@@ -328,6 +328,14 @@ static void mmc_post_req(struct mmc_host *host, struct mmc_request *mrq,
 	}
 }
 
+static int mmc_abort_req(struct mmc_host *host, struct mmc_request *req)
+{
+	if (host->ops->abort_req)
+		return host->ops->abort_req(host, req);
+
+	return -ENOSYS;
+}
+
 /**
  *	mmc_start_req - start a non-blocking request
  *	@host: MMC host to start command
diff --git a/include/linux/mmc/host.h b/include/linux/mmc/host.h
index 0707d22..d700703 100644
--- a/include/linux/mmc/host.h
+++ b/include/linux/mmc/host.h
@@ -98,6 +98,7 @@ struct mmc_host_ops {
 			    int err);
 	void	(*pre_req)(struct mmc_host *host, struct mmc_request *req,
 			   bool is_first_req);
+	int	(*abort_req)(struct mmc_host *host, struct mmc_request *req);
 	void	(*request)(struct mmc_host *host, struct mmc_request *req);
 	/*
 	 * Avoid calling these three functions too often or in a "fast path",
-- 
1.7.10.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

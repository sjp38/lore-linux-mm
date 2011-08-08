Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB406B016D
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 16:08:21 -0400 (EDT)
Received: by eyh6 with SMTP id 6so3903278eyh.20
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 13:08:18 -0700 (PDT)
From: Per Forlin <per.forlin@linaro.org>
Subject: [PATCH --mmotm v5 2/3] mmc: core: add random fault injection
Date: Mon,  8 Aug 2011 22:07:28 +0200
Message-Id: <1312834049-29910-3-git-send-email-per.forlin@linaro.org>
In-Reply-To: <1312834049-29910-1-git-send-email-per.forlin@linaro.org>
References: <1312834049-29910-1-git-send-email-per.forlin@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>, akpm@linux-foundation.org, Linus Walleij <linus.ml.walleij@gmail.com>, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Chris Ball <cjb@laptop.org>
Cc: linux-doc@vger.kernel.org, linux-mmc@vger.kernel.org, linaro-dev@lists.linaro.org, linux-mm@kvack.org, Per Forlin <per.forlin@linaro.org>

This adds support to inject data errors after a completed host transfer.
The mmc core will return error even though the host transfer is successful.
This simple fault injection proved to be very useful to test the
non-blocking error handling in the mmc_blk_issue_rw_rq().
Random faults can also test how the host driver handles pre_req()
and post_req() in case of errors.

Signed-off-by: Per Forlin <per.forlin@linaro.org>
Acked-by: Akinobu Mita <akinobu.mita@gmail.com>
---
 drivers/mmc/core/core.c    |   44 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/mmc/core/debugfs.c |   24 ++++++++++++++++++++++++
 include/linux/mmc/host.h   |    7 +++++++
 lib/Kconfig.debug          |   11 +++++++++++
 4 files changed, 86 insertions(+), 0 deletions(-)

diff --git a/drivers/mmc/core/core.c b/drivers/mmc/core/core.c
index 89bdeae..a4996b0 100644
--- a/drivers/mmc/core/core.c
+++ b/drivers/mmc/core/core.c
@@ -25,6 +25,11 @@
 #include <linux/pm_runtime.h>
 #include <linux/suspend.h>
 
+#ifdef CONFIG_FAIL_MMC_REQUEST
+#include <linux/fault-inject.h>
+#include <linux/random.h>
+#endif
+
 #include <linux/mmc/card.h>
 #include <linux/mmc/host.h>
 #include <linux/mmc/mmc.h>
@@ -83,6 +88,43 @@ static void mmc_flush_scheduled_work(void)
 	flush_workqueue(workqueue);
 }
 
+#ifdef CONFIG_FAIL_MMC_REQUEST
+
+/*
+ * Internal function. Inject random data errors.
+ * If mmc_data is NULL no errors are injected.
+ */
+static void mmc_should_fail_request(struct mmc_host *host,
+				    struct mmc_request *mrq)
+{
+	struct mmc_command *cmd = mrq->cmd;
+	struct mmc_data *data = mrq->data;
+	static const int data_errors[] = {
+		-ETIMEDOUT,
+		-EILSEQ,
+		-EIO,
+	};
+
+	if (!data)
+		return;
+
+	if (cmd->error || data->error ||
+	    !should_fail(&host->fail_mmc_request, data->blksz * data->blocks))
+		return;
+
+	data->error = data_errors[random32() % ARRAY_SIZE(data_errors)];
+	data->bytes_xfered = (random32() % (data->bytes_xfered >> 9)) << 9;
+}
+
+#else /* CONFIG_FAIL_MMC_REQUEST */
+
+static void mmc_should_fail_request(struct mmc_host *host,
+				    struct mmc_request *mrq)
+{
+}
+
+#endif /* CONFIG_FAIL_MMC_REQUEST */
+
 /**
  *	mmc_request_done - finish processing an MMC request
  *	@host: MMC host which completed request
@@ -109,6 +151,8 @@ void mmc_request_done(struct mmc_host *host, struct mmc_request *mrq)
 		cmd->error = 0;
 		host->ops->request(host, mrq);
 	} else {
+		mmc_should_fail_request(host, mrq);
+
 		led_trigger_event(host->led, LED_OFF);
 
 		pr_debug("%s: req done (CMD%u): %d: %08x %08x %08x %08x\n",
diff --git a/drivers/mmc/core/debugfs.c b/drivers/mmc/core/debugfs.c
index f573753..548c2e7 100644
--- a/drivers/mmc/core/debugfs.c
+++ b/drivers/mmc/core/debugfs.c
@@ -13,6 +13,9 @@
 #include <linux/seq_file.h>
 #include <linux/slab.h>
 #include <linux/stat.h>
+#ifdef CONFIG_FAIL_MMC_REQUEST
+#include <linux/fault-inject.h>
+#endif
 
 #include <linux/mmc/card.h>
 #include <linux/mmc/host.h>
@@ -159,6 +162,20 @@ static int mmc_clock_opt_set(void *data, u64 val)
 	return 0;
 }
 
+#ifdef CONFIG_FAIL_MMC_REQUEST
+
+static DECLARE_FAULT_ATTR(fail_mmc_request);
+/*
+ * Internal function. Pass the boot param fail_mmc_request to
+ * the setup fault injection attributes routine.
+ */
+static int __init setup_fail_mmc_request(char *str)
+{
+	return setup_fault_attr(&fail_mmc_request, str);
+}
+__setup("fail_mmc_request=", setup_fail_mmc_request);
+#endif
+
 DEFINE_SIMPLE_ATTRIBUTE(mmc_clock_fops, mmc_clock_opt_get, mmc_clock_opt_set,
 	"%llu\n");
 
@@ -189,6 +206,13 @@ void mmc_add_host_debugfs(struct mmc_host *host)
 				root, &host->clk_delay))
 		goto err_node;
 #endif
+#ifdef CONFIG_FAIL_MMC_REQUEST
+	host->fail_mmc_request = fail_mmc_request;
+	if (IS_ERR(fault_create_debugfs_attr("fail_mmc_request",
+					     root,
+					     &host->fail_mmc_request)))
+		goto err_node;
+#endif
 	return;
 
 err_node:
diff --git a/include/linux/mmc/host.h b/include/linux/mmc/host.h
index 0f83858..ee472fe 100644
--- a/include/linux/mmc/host.h
+++ b/include/linux/mmc/host.h
@@ -12,6 +12,9 @@
 
 #include <linux/leds.h>
 #include <linux/sched.h>
+#ifdef CONFIG_FAIL_MMC_REQUEST
+#include <linux/fault-inject.h>
+#endif
 
 #include <linux/mmc/core.h>
 #include <linux/mmc/pm.h>
@@ -304,6 +307,10 @@ struct mmc_host {
 
 	struct mmc_async_req	*areq;		/* active async req */
 
+#ifdef CONFIG_FAIL_MMC_REQUEST
+	struct fault_attr	fail_mmc_request;
+#endif
+
 	unsigned long		private[0] ____cacheline_aligned;
 };
 
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 47879c7..ebff0c9 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1090,6 +1090,17 @@ config FAIL_IO_TIMEOUT
 	  Only works with drivers that use the generic timeout handling,
 	  for others it wont do anything.
 
+config FAIL_MMC_REQUEST
+	bool "Fault-injection capability for MMC IO"
+	select DEBUG_FS
+	depends on FAULT_INJECTION && MMC
+	help
+	  Provide fault-injection capability for MMC IO.
+	  This will make the mmc core return data errors. This is
+	  useful to test the error handling in the mmc block device
+	  and to test how the mmc host driver handles retries from
+	  the block device.
+
 config FAULT_INJECTION_DEBUG_FS
 	bool "Debugfs entries for fault-injection capabilities"
 	depends on FAULT_INJECTION && SYSFS && DEBUG_FS
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

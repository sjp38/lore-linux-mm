Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72EFD6B0266
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 04:03:33 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id g194-v6so14347844ybf.5
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 01:03:33 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id d2-v6si5227275ybq.469.2018.10.17.01.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 01:03:32 -0700 (PDT)
From: Prateek Patel <prpatel@nvidia.com>
Subject: [PATCH] kmemleak: Add config to select auto scan
Date: Wed, 17 Oct 2018 13:33:28 +0530
Message-ID: <1539763408-22085-1-git-send-email-prpatel@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-tegra@vger.kernel.org, snikam@nvidia.com, vdumpa@nvidia.com, talho@nvidia.com, swarren@nvidia.com, prpatel@nvidia.com, Sri Krishna
 chowdary <schowdary@nvidia.com>

From: Sri Krishna chowdary <schowdary@nvidia.com>

Kmemleak scan is cpu intensive and can stall user tasks at times.
To prevent this, add config DEBUG_KMEMLEAK_SCAN_ON to enable/disable
auto scan on boot up.
Also protect first_run with CONFIG_DEBUG_KMEMLEAK_SCAN_ON as this is
meant for only first automatic scan.

Signed-off-by: Sri Krishna chowdary <schowdary@nvidia.com>
Signed-off-by: Sachin Nikam <snikam@nvidia.com>
Signed-off-by: Prateek <prpatel@nvidia.com>
---
 lib/Kconfig.debug | 11 +++++++++++
 mm/kmemleak.c     |  6 ++++++
 2 files changed, 17 insertions(+)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index e5e7c03..9542852 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -593,6 +593,17 @@ config DEBUG_KMEMLEAK_DEFAULT_OFF
 	  Say Y here to disable kmemleak by default. It can then be enabled
 	  on the command line via kmemleak=on.
 
+config DEBUG_KMEMLEAK_SCAN_ON
+	bool "Enable kmemleak auto scan thread on boot up"
+	default y
+	depends on DEBUG_KMEMLEAK
+	help
+	  Kmemleak scan is cpu intensive and can stall user tasks at times.
+	  This option enables/disables automatic kmemleak scan at boot up.
+
+	  Say N here to disable kmemleak auto scan thread to stop automatic
+	  scanning.
+
 config DEBUG_STACK_USAGE
 	bool "Stack utilization instrumentation"
 	depends on DEBUG_KERNEL && !IA64
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 877de4f..ac53678 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1647,11 +1647,14 @@ static void kmemleak_scan(void)
  */
 static int kmemleak_scan_thread(void *arg)
 {
+#ifdef CONFIG_DEBUG_KMEMLEAK_SCAN_ON
 	static int first_run = 1;
+#endif
 
 	pr_info("Automatic memory scanning thread started\n");
 	set_user_nice(current, 10);
 
+#ifdef CONFIG_DEBUG_KMEMLEAK_SCAN_ON
 	/*
 	 * Wait before the first scan to allow the system to fully initialize.
 	 */
@@ -1661,6 +1664,7 @@ static int kmemleak_scan_thread(void *arg)
 		while (timeout && !kthread_should_stop())
 			timeout = schedule_timeout_interruptible(timeout);
 	}
+#endif
 
 	while (!kthread_should_stop()) {
 		signed long timeout = jiffies_scan_wait;
@@ -2141,9 +2145,11 @@ static int __init kmemleak_late_init(void)
 		return -ENOMEM;
 	}
 
+#ifdef CONFIG_DEBUG_KMEMLEAK_SCAN_ON
 	mutex_lock(&scan_mutex);
 	start_scan_thread();
 	mutex_unlock(&scan_mutex);
+#endif
 
 	pr_info("Kernel memory leak detector initialized\n");
 
-- 
2.1.4

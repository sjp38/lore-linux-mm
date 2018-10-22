Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0990B6B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 14:09:02 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id p18-v6so25576962ybe.0
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 11:09:02 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id a15-v6si4214299ybs.443.2018.10.22.11.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 11:09:00 -0700 (PDT)
From: Prateek Patel <prpatel@nvidia.com>
Subject: [PATCH V2] kmemleak: Add config to select auto scan
Date: Mon, 22 Oct 2018 23:38:43 +0530
Message-ID: <1540231723-7087-1-git-send-email-prpatel@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-tegra@vger.kernel.org, snikam@nvidia.com, vdumpa@nvidia.com, talho@nvidia.com, swarren@nvidia.com, prpatel@nvidia.com, Sri Krishna chowdary <schowdary@nvidia.com>

From: Sri Krishna chowdary <schowdary@nvidia.com>

Kmemleak scan can be cpu intensive and can stall user tasks at times.
To prevent this, add config DEBUG_KMEMLEAK_AUTO_SCAN to enable/disable
auto scan on boot up.
Also protect first_run with DEBUG_KMEMLEAK_AUTO_SCAN as this is meant
for only first automatic scan.

Signed-off-by: Sri Krishna chowdary <schowdary@nvidia.com>
Signed-off-by: Sachin Nikam <snikam@nvidia.com>
Signed-off-by: Prateek <prpatel@nvidia.com>
---
v2:
* change config name to DEBUG_KMEMLEAK_AUTO_SCAN from DEBUG_KMEMLEAK_SCAN_ON
* use IS_ENABLED(...) instead of #ifdef ...
* update commit message according to config name
---
 lib/Kconfig.debug | 15 +++++++++++++++
 mm/kmemleak.c     | 10 ++++++----
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index c958013..a14166d 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -593,6 +593,21 @@ config DEBUG_KMEMLEAK_DEFAULT_OFF
 	  Say Y here to disable kmemleak by default. It can then be enabled
 	  on the command line via kmemleak=on.
 
+config DEBUG_KMEMLEAK_AUTO_SCAN
+	bool "Enable kmemleak auto scan thread on boot up"
+	default y
+	depends on DEBUG_KMEMLEAK
+	help
+	  Depending on the cpu, kmemleak scan may be cpu intensive and can
+	  stall user tasks at times. This option enables/disables automatic
+	  kmemleak scan at boot up.
+
+	  Say N here to disable kmemleak auto scan thread to stop automatic
+	  scanning. Disabling this option disables automatic reporting of
+	  memory leaks.
+
+	  If unsure, say Y.
+
 config DEBUG_STACK_USAGE
 	bool "Stack utilization instrumentation"
 	depends on DEBUG_KERNEL && !IA64
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 877de4f..a614930 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1647,7 +1647,7 @@ static void kmemleak_scan(void)
  */
 static int kmemleak_scan_thread(void *arg)
 {
-	static int first_run = 1;
+	static int first_run = IS_ENABLED(CONFIG_DEBUG_KMEMLEAK_AUTO_SCAN);
 
 	pr_info("Automatic memory scanning thread started\n");
 	set_user_nice(current, 10);
@@ -2141,9 +2141,11 @@ static int __init kmemleak_late_init(void)
 		return -ENOMEM;
 	}
 
-	mutex_lock(&scan_mutex);
-	start_scan_thread();
-	mutex_unlock(&scan_mutex);
+	if (IS_ENABLED(CONFIG_DEBUG_KMEMLEAK_AUTO_SCAN)) {
+		mutex_lock(&scan_mutex);
+		start_scan_thread();
+		mutex_unlock(&scan_mutex);
+	}
 
 	pr_info("Kernel memory leak detector initialized\n");
 
-- 
2.1.4

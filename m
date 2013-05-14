Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 889E16B004D
	for <linux-mm@kvack.org>; Tue, 14 May 2013 14:20:55 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id hv10so927837vcb.20
        for <linux-mm@kvack.org>; Tue, 14 May 2013 11:20:54 -0700 (PDT)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 9/9] xen/tmem: Don't use self[ballooning|shrinking] if frontswap is off.
Date: Tue, 14 May 2013 14:09:26 -0400
Message-Id: <1368554966-30469-10-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
References: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bob.liu@oracle.com, dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xen-devel@lists.xensource.com
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

There is no point. We would just squeeze the guest to put more and
more pages in the swap disk without any purpose.

The only time it makes sense to use the selfballooning and shrinking
is when frontswap is being utilized.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 Documentation/kernel-parameters.txt |    3 ++-
 drivers/xen/tmem.c                  |    8 ++++++++
 drivers/xen/xen-selfballoon.c       |   15 ++++++---------
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 3de01ed..6e3b18a 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3014,7 +3014,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 
 	tmem.frontswap=0|1 [KNL, XEN]
 			Default is on (1). Disable the usage of the frontswap
-			API to send swap pages to the hypervisor.
+			API to send swap pages to the hypervisor. If disabled
+			the selfballooning and selfshrinking are force disabled.
 
 	tmem.selfballooning=0|1 [KNL, XEN]
 			Default is on (1). Disable the driving of swap pages
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index c1df0ff..18e8bd8 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -403,6 +403,14 @@ static int xen_tmem_init(void)
 	}
 #endif
 #ifdef CONFIG_XEN_SELFBALLOONING
+	/*
+	 * There is no point of driving pages to the swap system if they
+	 * aren't going anywhere in tmem universe.
+	 */
+	if (!frontswap) {
+		selfshrinking = false;
+		selfballooning = false;
+	}
 	xen_selfballoon_init(selfballooning, selfshrinking);
 #endif
 	return 0;
diff --git a/drivers/xen/xen-selfballoon.c b/drivers/xen/xen-selfballoon.c
index 5d637e2..f70984a8 100644
--- a/drivers/xen/xen-selfballoon.c
+++ b/drivers/xen/xen-selfballoon.c
@@ -53,15 +53,12 @@
  * System configuration note: Selfballooning should not be enabled on
  * systems without a sufficiently large swap device configured; for best
  * results, it is recommended that total swap be increased by the size
- * of the guest memory.  Also, while technically not required to be
- * configured, it is highly recommended that frontswap also be configured
- * and enabled when selfballooning is running.  So, selfballooning
- * is disabled by default if frontswap is not configured and can only
- * be enabled with the "tmem.selfballooning=1" kernel boot option; similarly
- * selfballooning is enabled by default if frontswap is configured and
- * can be disabled with the "tmem.selfballooning=0" kernel boot option.  Finally,
- * when frontswap is configured,frontswap-selfshrinking can be disabled
- * with the "tmem.selfshrink=0" kernel boot option.
+ * of the guest memory. Note, that selfballooning should be disabled by default
+ * if frontswap is not configured.  Similarly selfballooning should be enabled
+ * by default if frontswap is configured and can be disabled with the
+ * "tmem.selfballooning=0" kernel boot option.  Finally, when frontswap is
+ * configured, frontswap-selfshrinking can be disabled  with the
+ * "tmem.selfshrink=0" kernel boot option.
  *
  * Selfballooning is disallowed in domain0 and force-disabled.
  *
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

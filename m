Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 2722D6B0044
	for <linux-mm@kvack.org>; Tue, 14 May 2013 14:20:53 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id ht10so934328vcb.4
        for <linux-mm@kvack.org>; Tue, 14 May 2013 11:20:52 -0700 (PDT)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 7/9] xen/tmem: Remove the usage of 'noselfshrink' and use 'tmem.selfshrink' bool instead.
Date: Tue, 14 May 2013 14:09:24 -0400
Message-Id: <1368554966-30469-8-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
References: <1368554966-30469-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bob.liu@oracle.com, dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xen-devel@lists.xensource.com
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

As the 'tmem' driver is the one that actually sets whether
it will use it or not so might as well make tmem responsible
for this knob.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/xen/Kconfig           |    2 +-
 drivers/xen/xen-selfballoon.c |   15 ++-------------
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
index f03bf50..98e9744 100644
--- a/drivers/xen/Kconfig
+++ b/drivers/xen/Kconfig
@@ -22,7 +22,7 @@ config XEN_SELFBALLOONING
 	  ballooning is disabled by default but can be enabled with the
 	  'selfballooning' kernel boot parameter.  If FRONTSWAP is configured,
 	  frontswap-selfshrinking is enabled by default but can be disabled
-	  with the 'noselfshrink' kernel boot parameter; and self-ballooning
+	  with the 'tmem.selfshrink=0' kernel boot parameter; and self-ballooning
 	  is enabled by default but can be disabled with the 'noselfballooning'
 	  kernel boot parameter.  Note that systems without a sufficiently
 	  large swap device should not enable self-ballooning.
diff --git a/drivers/xen/xen-selfballoon.c b/drivers/xen/xen-selfballoon.c
index f2ef569..012f9d9 100644
--- a/drivers/xen/xen-selfballoon.c
+++ b/drivers/xen/xen-selfballoon.c
@@ -60,8 +60,8 @@
  * be enabled with the "selfballooning" kernel boot option; similarly
  * selfballooning is enabled by default if frontswap is configured and
  * can be disabled with the "noselfballooning" kernel boot option.  Finally,
- * when frontswap is configured, frontswap-selfshrinking can be disabled
- * with the "noselfshrink" kernel boot option.
+ * when frontswap is configured,frontswap-selfshrinking can be disabled
+ * with the "tmem.selfshrink=0" kernel boot option.
  *
  * Selfballooning is disallowed in domain0 and force-disabled.
  *
@@ -120,9 +120,6 @@ static DECLARE_DELAYED_WORK(selfballoon_worker, selfballoon_process);
 /* Enable/disable with sysfs. */
 static bool frontswap_selfshrinking __read_mostly;
 
-/* Enable/disable with kernel boot option. */
-static bool use_frontswap_selfshrink = true;
-
 /*
  * The default values for the following parameters were deemed reasonable
  * by experimentation, may be workload-dependent, and can all be
@@ -176,14 +173,6 @@ static void frontswap_selfshrink(void)
 	frontswap_shrink(tgt_frontswap_pages);
 }
 
-static int __init xen_nofrontswap_selfshrink_setup(char *s)
-{
-	use_frontswap_selfshrink = false;
-	return 1;
-}
-
-__setup("noselfshrink", xen_nofrontswap_selfshrink_setup);
-
 /* Disable with kernel boot option. */
 static bool use_selfballooning = true;
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

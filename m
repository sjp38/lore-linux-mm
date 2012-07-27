Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 6492C6B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 14:19:08 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 27 Jul 2012 12:19:07 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 50B2E3E40026
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 18:19:03 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6RIIpXJ101724
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 12:18:53 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6RIIooU010302
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 12:18:50 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 4/4] zcache: promote to drivers/mm/
Date: Fri, 27 Jul 2012 13:18:37 -0500
Message-Id: <1343413117-1989-5-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patchset promtes the zcache driver from staging to drivers/mm/.

zcache captures swap pages via frontswap and pages that fall
out of the page cache via cleancache and compress them in RAM,
providing a compressed RAM swap and a compressed second-chance
page cache.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/mm/Kconfig                           |   10 ++++++++++
 drivers/mm/Makefile                          |    1 +
 drivers/{staging => mm}/zcache/Makefile      |    0
 drivers/{staging => mm}/zcache/tmem.c        |    0
 drivers/{staging => mm}/zcache/tmem.h        |    0
 drivers/{staging => mm}/zcache/zcache-main.c |    0
 drivers/staging/Kconfig                      |    2 --
 drivers/staging/Makefile                     |    1 -
 drivers/staging/zcache/Kconfig               |   11 -----------
 9 files changed, 11 insertions(+), 14 deletions(-)
 create mode 100644 drivers/mm/Makefile
 rename drivers/{staging => mm}/zcache/Makefile (100%)
 rename drivers/{staging => mm}/zcache/tmem.c (100%)
 rename drivers/{staging => mm}/zcache/tmem.h (100%)
 rename drivers/{staging => mm}/zcache/zcache-main.c (100%)
 delete mode 100644 drivers/staging/zcache/Kconfig

diff --git a/drivers/mm/Kconfig b/drivers/mm/Kconfig
index e5b3743..22289c6 100644
--- a/drivers/mm/Kconfig
+++ b/drivers/mm/Kconfig
@@ -1,3 +1,13 @@
 menu "Memory management drivers"
 
+config ZCACHE
+	bool "Dynamic compression of swap pages and clean pagecache pages"
+	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && ZSMALLOC=y
+	select CRYPTO_LZO
+	default n
+	help
+	  Zcache uses compression and an in-kernel implementation of
+	  transcendent memory to store clean page cache pages and swap
+	  in RAM, providing a noticeable reduction in disk I/O.
+
 endmenu
diff --git a/drivers/mm/Makefile b/drivers/mm/Makefile
new file mode 100644
index 0000000..f36f509
--- /dev/null
+++ b/drivers/mm/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_ZCACHE)	+= zcache/
diff --git a/drivers/staging/zcache/Makefile b/drivers/mm/zcache/Makefile
similarity index 100%
rename from drivers/staging/zcache/Makefile
rename to drivers/mm/zcache/Makefile
diff --git a/drivers/staging/zcache/tmem.c b/drivers/mm/zcache/tmem.c
similarity index 100%
rename from drivers/staging/zcache/tmem.c
rename to drivers/mm/zcache/tmem.c
diff --git a/drivers/staging/zcache/tmem.h b/drivers/mm/zcache/tmem.h
similarity index 100%
rename from drivers/staging/zcache/tmem.h
rename to drivers/mm/zcache/tmem.h
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/mm/zcache/zcache-main.c
similarity index 100%
rename from drivers/staging/zcache/zcache-main.c
rename to drivers/mm/zcache/zcache-main.c
diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index b7f7bc7..0940d2e 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -76,8 +76,6 @@ source "drivers/staging/iio/Kconfig"
 
 source "drivers/staging/zram/Kconfig"
 
-source "drivers/staging/zcache/Kconfig"
-
 source "drivers/staging/wlags49_h2/Kconfig"
 
 source "drivers/staging/wlags49_h25/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index ad74bee..6e1c491 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -33,7 +33,6 @@ obj-$(CONFIG_IPACK_BUS)		+= ipack/
 obj-$(CONFIG_DX_SEP)            += sep/
 obj-$(CONFIG_IIO)		+= iio/
 obj-$(CONFIG_ZRAM)		+= zram/
-obj-$(CONFIG_ZCACHE)		+= zcache/
 obj-$(CONFIG_WLAGS49_H2)	+= wlags49_h2/
 obj-$(CONFIG_WLAGS49_H25)	+= wlags49_h25/
 obj-$(CONFIG_FB_SM7XX)		+= sm7xxfb/
diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
deleted file mode 100644
index 4881839..0000000
--- a/drivers/staging/zcache/Kconfig
+++ /dev/null
@@ -1,11 +0,0 @@
-config ZCACHE
-	bool "Dynamic compression of swap pages and clean pagecache pages"
-	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO=y && ZSMALLOC=y
-	select CRYPTO_LZO
-	default n
-	help
-	  Zcache doubles RAM efficiency while providing a significant
-	  performance boosts on many workloads.  Zcache uses
-	  compression and an in-kernel implementation of transcendent
-	  memory to store clean page cache pages and swap in RAM,
-	  providing a noticeable reduction in disk I/O.
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

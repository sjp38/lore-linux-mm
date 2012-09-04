Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id F15076B0070
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 16:04:24 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 4 Sep 2012 16:04:23 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 00CD7C90216
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 16:03:48 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q84K3kac122800
	for <linux-mm@kvack.org>; Tue, 4 Sep 2012 16:03:46 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q84K3k7V010859
	for <linux-mm@kvack.org>; Tue, 4 Sep 2012 16:03:46 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH v2 3/3] zcache: promote to drivers/mm/
Date: Tue,  4 Sep 2012 15:02:49 -0500
Message-Id: <1346788969-4100-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1346788969-4100-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1346788969-4100-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patchset promotes the zcache driver from staging to drivers/mm/.

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

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 5FE036B005A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 09:50:29 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 11/11] zcache: Coalesce all debug under CONFIG_ZCACHE2_DEBUG
Date: Mon,  5 Nov 2012 09:37:34 -0500
Message-Id: <1352126254-28933-12-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352126254-28933-1-git-send-email-konrad.wilk@oracle.com>
References: <1352126254-28933-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, ngupta@vflare.org, minchan@kernel.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, gregkh@linuxfoundation.org, devel@driverdev.osuosl.org
Cc: akpm@linux-foundation.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

and also define this extra attribute in the Kconfig entry.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/Kconfig       |    8 ++++++++
 drivers/staging/ramster/Makefile      |    2 +-
 drivers/staging/ramster/debug.h       |    2 +-
 drivers/staging/ramster/zcache-main.c |    8 +++-----
 4 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/ramster/Kconfig b/drivers/staging/ramster/Kconfig
index 9ce2590..24c8704 100644
--- a/drivers/staging/ramster/Kconfig
+++ b/drivers/staging/ramster/Kconfig
@@ -15,6 +15,14 @@ config ZCACHE2
 	  again in the future.  Until then, zcache2 is a single-node
 	  version of ramster.
 
+config ZCACHE2_DEBUG
+	bool "Enable debug statistics"
+	depends on DEBUG_FS && ZCACHE2
+	default n
+	help
+	  This is used to provide an debugfs directory with counters of
+	  how zcache2 is doing. You probably want to set this to 'N'.
+
 config RAMSTER
 	tristate "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
 	depends on CONFIGFS_FS && SYSFS && !HIGHMEM && ZCACHE2
diff --git a/drivers/staging/ramster/Makefile b/drivers/staging/ramster/Makefile
index 61f5050..d341a23 100644
--- a/drivers/staging/ramster/Makefile
+++ b/drivers/staging/ramster/Makefile
@@ -4,5 +4,5 @@ zcache-y	+=	ramster/ramster.o ramster/r2net.o
 zcache-y	+=	ramster/nodemanager.o ramster/tcp.o
 zcache-y	+=	ramster/heartbeat.o ramster/masklog.o
 endif
-zcache-y-$(CONFIG_ZCACHE_DEBUG)	+= debug.o
+zcache-y-$(CONFIG_ZCACHE2_DEBUG)	+= debug.o
 obj-$(CONFIG_MODULES)	+= zcache.o
diff --git a/drivers/staging/ramster/debug.h b/drivers/staging/ramster/debug.h
index 35af06d..51e3d74 100644
--- a/drivers/staging/ramster/debug.h
+++ b/drivers/staging/ramster/debug.h
@@ -1,4 +1,4 @@
-#ifdef CONFIG_ZCACHE_DEBUG
+#ifdef CONFIG_ZCACHE2_DEBUG
 
 /* we try to keep these statistics SMP-consistent */
 static ssize_t zcache_obj_count;
diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index d91868d..d58341a 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -308,7 +308,7 @@ static void zcache_free_page(struct page *page)
 		max_pageframes = curr_pageframes;
 	if (curr_pageframes < min_pageframes)
 		min_pageframes = curr_pageframes;
-#ifdef ZCACHE_DEBUG
+#ifdef CONFIG_ZCACHE2_DEBUG
 	if (curr_pageframes > 2L || curr_pageframes < -2L) {
 		/* pr_info here */
 	}
@@ -1561,9 +1561,7 @@ static int zcache_init(void)
 		namestr = "ramster";
 		ramster_register_pamops(&zcache_pamops);
 	}
-#ifdef CONFIG_DEBUG_FS
 	zcache_debugfs_init();
-#endif
 	if (zcache_enabled) {
 		unsigned int cpu;
 
@@ -1603,7 +1601,7 @@ static int zcache_init(void)
 		old_ops = zcache_cleancache_register_ops();
 		pr_info("%s: cleancache enabled using kernel transcendent "
 			"memory and compression buddies\n", namestr);
-#ifdef ZCACHE_DEBUG
+#ifdef CONFIG_ZCACHE2_DEBUG
 		pr_info("%s: cleancache: ignorenonactive = %d\n",
 			namestr, !disable_cleancache_ignore_nonactive);
 #endif
@@ -1618,7 +1616,7 @@ static int zcache_init(void)
 			frontswap_tmem_exclusive_gets(true);
 		pr_info("%s: frontswap enabled using kernel transcendent "
 			"memory and compression buddies\n", namestr);
-#ifdef ZCACHE_DEBUG
+#ifdef CONFIG_ZCACHE2_DEBUG
 		pr_info("%s: frontswap: excl gets = %d active only = %d\n",
 			namestr, frontswap_has_exclusive_gets,
 			!disable_frontswap_ignore_nonactive);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

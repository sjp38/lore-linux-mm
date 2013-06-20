Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id DE9356B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 04:29:20 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq13so6077698pab.11
        for <linux-mm@kvack.org>; Thu, 20 Jun 2013 01:29:20 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 2/2] zswap: update/document boot parameters
Date: Thu, 20 Jun 2013 16:29:09 +0800
Message-Id: <1371716949-9918-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: sjenning@linux.vnet.ibm.com, linux-mm@kvack.org, konrad.wilk@oracle.com, Bob Liu <bob.liu@oracle.com>

The current parameters of zswap are not straightforward.
Changed them to start with zswap* and documented them.

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 Documentation/kernel-parameters.txt |    8 ++++++++
 mm/zswap.c                          |   27 +++++++++++++++++++++++----
 2 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 2fe6e76..07642fd 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3367,6 +3367,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			Format:
 			<irq>,<irq_mask>,<io>,<full_duplex>,<do_sound>,<lockup_hack>[,<irq2>[,<irq3>[,<irq4>]]]
 
+	zswap 		Enable compressed cache for swap pages support which
+			is disabled by default.
+	zswapcompressor=
+			Select which compressor to be used by zswap.
+			The default compressor is lzo.
+	zswap_maxpool_percent=
+			Select how may percent of total memory can be used to
+			store comprssed pages. The default percent is 20%.
 ______________________________________________________________________
 
 TODO:
diff --git a/mm/zswap.c b/mm/zswap.c
index 7fe2b1b..8ec1360 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -77,17 +77,13 @@ static u64 zswap_duplicate_entry;
 **********************************/
 /* Enable/disable zswap (disabled by default, fixed at boot for now) */
 static bool zswap_enabled __read_mostly;
-module_param_named(enabled, zswap_enabled, bool, 0);
 
 /* Compressor to be used by zswap (fixed at boot for now) */
 #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
 static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
-module_param_named(compressor, zswap_compressor, charp, 0);
 
 /* The maximum percentage of memory that the compressed pool can occupy */
 static unsigned int zswap_max_pool_percent = 20;
-module_param_named(max_pool_percent,
-			zswap_max_pool_percent, uint, 0644);
 
 /*********************************
 * compression functions
@@ -914,6 +910,29 @@ static int __init zswap_debugfs_init(void)
 static void __exit zswap_debugfs_exit(void) { }
 #endif
 
+static int __init enable_zswap(char *s)
+{
+	zswap_enabled = true;
+	return 1;
+}
+__setup("zswap", enable_zswap);
+
+static int __init setup_zswap_compressor(char *s)
+{
+	strlcpy(zswap_compressor, s, sizeof(zswap_compressor));
+	zswap_enabled = true;
+	return 1;
+}
+__setup("zswapcompressor=", setup_zswap_compressor);
+
+static int __init setup_zswap_max_pool_percent(char *s)
+{
+	get_option(&s, &zswap_max_pool_percent);
+	zswap_enabled = true;
+	return 1;
+}
+__setup("zswap_maxpool_percent=", setup_zswap_max_pool_percent);
+
 /*********************************
 * module init and exit
 **********************************/
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

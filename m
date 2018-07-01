Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9616B0006
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 02:57:02 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e1-v6so7722478pld.23
        for <linux-mm@kvack.org>; Sat, 30 Jun 2018 23:57:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q10-v6sor3148552pgd.18.2018.06.30.23.57.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 30 Jun 2018 23:57:00 -0700 (PDT)
From: Will Ziener-Dignazio <wdignazio@gmail.com>
Subject: [PATCH] Add option to configure default zswap compressor algorithm.
Date: Sat, 30 Jun 2018 23:56:16 -0700
Message-Id: <20180701065616.3512-1-wdignazio@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@redhat.com
Cc: ddstreet@ieee.org, linux-mm@kvack.org, Will Ziener-Dignazio <wdignazio@gmail.com>

    - Add Kconfig option for default compressor algorithm
    - Add the deflate and LZ4 algorithms as default options

Signed-off-by: Will Ziener-Dignazio <wdignazio@gmail.com>
---
 mm/Kconfig | 35 ++++++++++++++++++++++++++++++++++-
 mm/zswap.c | 11 ++++++++++-
 2 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index ce95491abd6a..09df6650e96a 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -535,7 +535,6 @@ config MEM_SOFT_DIRTY
 config ZSWAP
 	bool "Compressed cache for swap pages (EXPERIMENTAL)"
 	depends on FRONTSWAP && CRYPTO=y
-	select CRYPTO_LZO
 	select ZPOOL
 	default n
 	help
@@ -552,6 +551,40 @@ config ZSWAP
 	  they have not be fully explored on the large set of potential
 	  configurations and workloads that exist.
 
+choice
+	prompt "Compressed cache cryptographic compression algorithm"
+	default ZSWAP_COMPRESSOR_DEFAULT_LZO
+	depends on ZSWAP
+	help
+	  The default cyptrographic compression algorithm to use for
+	  compressed swap pages.
+
+config ZSWAP_COMPRESSOR_DEFAULT_LZO
+	bool "lzo"
+	select CRYPTO_LZO
+	help
+	  This option sets the default zswap compression algorithm to LZO,
+	  the Lempel-Ziv-Oberhumer algorithm. This algorthm focuses on
+	  decompression speed, but has a lower compression ratio.
+
+config ZSWAP_COMPRESSOR_DEFAULT_DEFLATE
+	bool "deflate"
+	select CRYPTO_DEFLATE
+	help
+	  This option sets the default zswap compression algorithm to DEFLATE.
+	  This algorithm balances compression and decompression speed to
+	  compresstion ratio.
+
+config ZSWAP_COMPRESSOR_DEFAULT_LZ4
+	bool "lz4"
+	select CRYPTO_LZ4
+	help
+	  This option sets the default zswap compression algorithm to LZ4.
+	  This algorithm focuses on high compression speed, but has a lower
+	  compression ratio and decompression speed.
+
+endchoice
+
 config ZPOOL
 	tristate "Common API for compressed memory storage"
 	default n
diff --git a/mm/zswap.c b/mm/zswap.c
index 7d34e69507e3..30f9f25da4d0 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -91,7 +91,16 @@ static struct kernel_param_ops zswap_enabled_param_ops = {
 module_param_cb(enabled, &zswap_enabled_param_ops, &zswap_enabled, 0644);
 
 /* Crypto compressor to use */
-#define ZSWAP_COMPRESSOR_DEFAULT "lzo"
+#if defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZO)
+  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
+#elif defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_DEFLATE)
+  #define ZSWAP_COMPRESSOR_DEFAULT "deflate"
+#elif defined(CONFIG_ZSWAP_COMPRESSOR_DEFAULT_LZ4)
+  #define ZSWAP_COMPRESSOR_DEFAULT "lz4"
+#else
+  #error "Default zswap compression algorithm not defined."
+#endif
+
 static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
 static int zswap_compressor_param_set(const char *,
 				      const struct kernel_param *);
-- 
2.18.0

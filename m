Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE086B0038
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 16:06:44 -0400 (EDT)
Received: by ykbi184 with SMTP id i184so105736544ykb.2
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 13:06:44 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id i69si32973014qhc.73.2015.08.18.13.06.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 13:06:43 -0700 (PDT)
Received: by qgj62 with SMTP id 62so126334599qgj.2
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 13:06:42 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 2/2] zswap: use const max length for kparam names
Date: Tue, 18 Aug 2015 16:06:01 -0400
Message-Id: <1439928361-31294-2-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1439928361-31294-1-git-send-email-ddstreet@ieee.org>
References: <1439928361-31294-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, kbuild test robot <fengguang.wu@intel.com>, Dan Streetman <ddstreet@ieee.org>

Add ZSWAP_MAX_KPARAM_NAME define and change the "zpool" and "compressor"
kparams maxlen to use the define.  Update the param set function to
use a char[ZSWAP_MAX_KPARAM_NAME] instead of a variable-sized char[].

The kbuild test robot reported:

>> mm/zswap.c:759:1: warning: '__zswap_param_set' uses dynamic stack
>> allocation

which was a variable-sized char[] allocation on the stack:

  char str[kp->str->maxlen], *s;

This technically was ok, as there are only 2 possible kparams sent to
this function, and both of them have their maxlen set low (to 32 or 64),
but this patch simplifies and clarifies things by creating a single
define to use for the kparam maxlen and the size of the stack char[].

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zswap.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 4043df7..d74872e 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -80,12 +80,15 @@ static u64 zswap_duplicate_entry;
 static bool zswap_enabled;
 module_param_named(enabled, zswap_enabled, bool, 0644);
 
+/* This should be >= CRYPTO_MAX_ALG_NAME and ZPOOL_MAX_TYPE_NAME */
+#define ZSWAP_MAX_KPARAM_NAME 64
+
 /* Crypto compressor to use */
 #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
-static char zswap_compressor[CRYPTO_MAX_ALG_NAME] = ZSWAP_COMPRESSOR_DEFAULT;
+static char zswap_compressor[ZSWAP_MAX_KPARAM_NAME] = ZSWAP_COMPRESSOR_DEFAULT;
 static struct kparam_string zswap_compressor_kparam = {
 	.string =	zswap_compressor,
-	.maxlen =	sizeof(zswap_compressor),
+	.maxlen =	ZSWAP_MAX_KPARAM_NAME,
 };
 static int zswap_compressor_param_set(const char *,
 				      const struct kernel_param *);
@@ -98,10 +101,10 @@ module_param_cb(compressor, &zswap_compressor_param_ops,
 
 /* Compressed storage zpool to use */
 #define ZSWAP_ZPOOL_DEFAULT "zbud"
-static char zswap_zpool_type[32 /* arbitrary */] = ZSWAP_ZPOOL_DEFAULT;
+static char zswap_zpool_type[ZSWAP_MAX_KPARAM_NAME] = ZSWAP_ZPOOL_DEFAULT;
 static struct kparam_string zswap_zpool_kparam = {
 	.string =	zswap_zpool_type,
-	.maxlen =	sizeof(zswap_zpool_type),
+	.maxlen =	ZSWAP_MAX_KPARAM_NAME,
 };
 static int zswap_zpool_param_set(const char *, const struct kernel_param *);
 static struct kernel_param_ops zswap_zpool_param_ops = {
@@ -688,14 +691,12 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
 			     char *type, char *compressor)
 {
 	struct zswap_pool *pool, *put_pool = NULL;
-	char str[kp->str->maxlen], *s;
+	char str[ZSWAP_MAX_KPARAM_NAME], *s;
 	int ret;
 
-	/*
-	 * kp is either zswap_zpool_kparam or zswap_compressor_kparam, defined
-	 * at the top of this file, so maxlen is CRYPTO_MAX_ALG_NAME (64) or
-	 * 32 (arbitrary).
-	 */
+	if (WARN_ON(kp->str->maxlen > ZSWAP_MAX_KPARAM_NAME))
+		return -EINVAL;
+
 	strlcpy(str, val, kp->str->maxlen);
 	s = strim(str);
 
@@ -1228,6 +1229,9 @@ static int __init init_zswap(void)
 {
 	struct zswap_pool *pool;
 
+	BUILD_BUG_ON(ZSWAP_MAX_KPARAM_NAME < CRYPTO_MAX_ALG_NAME);
+	BUILD_BUG_ON(ZSWAP_MAX_KPARAM_NAME < ZPOOL_MAX_TYPE_NAME);
+
 	zswap_init_started = true;
 
 	if (zswap_entry_cache_create()) {
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

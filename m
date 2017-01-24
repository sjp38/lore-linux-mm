Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 097FE6B0280
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 15:03:27 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id o65so263317913yba.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:03:27 -0800 (PST)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id m6si5453205ybf.168.2017.01.24.12.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 12:03:26 -0800 (PST)
Received: by mail-yw0-x244.google.com with SMTP id v73so21773650ywg.1
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:03:26 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 3/3] zswap: clear compressor or zpool param if invalid at init
Date: Tue, 24 Jan 2017 15:02:59 -0500
Message-Id: <20170124200259.16191-4-ddstreet@ieee.org>
In-Reply-To: <20170124200259.16191-1-ddstreet@ieee.org>
References: <20170124200259.16191-1-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, Dan Streetman <dan.streetman@canonical.com>

If either the compressor and/or zpool param are invalid at boot, and
their default value is also invalid, set the param to the empty string
to indicate there is no compressor and/or zpool configured.  This allows
users to check the sysfs interface to see which param needs changing.

Signed-off-by: Dan Streetman <dan.streetman@canonical.com>
---
 mm/zswap.c | 49 +++++++++++++++++++++++++++++++++++++------------
 1 file changed, 37 insertions(+), 12 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 77cb847..9e8565d 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -76,6 +76,8 @@ static u64 zswap_duplicate_entry;
 * tunables
 **********************************/
 
+#define ZSWAP_PARAM_UNSET ""
+
 /* Enable/disable zswap (disabled by default) */
 static bool zswap_enabled;
 static int zswap_enabled_param_set(const char *,
@@ -501,6 +503,17 @@ static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
 	gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM;
 	int ret;
 
+	if (!zswap_has_pool) {
+		/* if either are unset, pool initialization failed, and we
+		 * need both params to be set correctly before trying to
+		 * create a pool.
+		 */
+		if (!strcmp(type, ZSWAP_PARAM_UNSET))
+			return NULL;
+		if (!strcmp(compressor, ZSWAP_PARAM_UNSET))
+			return NULL;
+	}
+
 	pool = kzalloc(sizeof(*pool), GFP_KERNEL);
 	if (!pool) {
 		pr_err("pool alloc failed\n");
@@ -550,28 +563,40 @@ static struct zswap_pool *zswap_pool_create(char *type, char *compressor)
 
 static __init struct zswap_pool *__zswap_pool_create_fallback(void)
 {
-	if (!crypto_has_comp(zswap_compressor, 0, 0)) {
-		if (!strcmp(zswap_compressor, ZSWAP_COMPRESSOR_DEFAULT)) {
-			pr_err("default compressor %s not available\n",
-			       zswap_compressor);
-			return NULL;
-		}
+	bool has_comp, has_zpool;
+
+	has_comp = crypto_has_comp(zswap_compressor, 0, 0);
+	if (!has_comp && strcmp(zswap_compressor, ZSWAP_COMPRESSOR_DEFAULT)) {
 		pr_err("compressor %s not available, using default %s\n",
 		       zswap_compressor, ZSWAP_COMPRESSOR_DEFAULT);
 		param_free_charp(&zswap_compressor);
 		zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
+		has_comp = crypto_has_comp(zswap_compressor, 0, 0);
 	}
-	if (!zpool_has_pool(zswap_zpool_type)) {
-		if (!strcmp(zswap_zpool_type, ZSWAP_ZPOOL_DEFAULT)) {
-			pr_err("default zpool %s not available\n",
-			       zswap_zpool_type);
-			return NULL;
-		}
+	if (!has_comp) {
+		pr_err("default compressor %s not available\n",
+		       zswap_compressor);
+		param_free_charp(&zswap_compressor);
+		zswap_compressor = ZSWAP_PARAM_UNSET;
+	}
+
+	has_zpool = zpool_has_pool(zswap_zpool_type);
+	if (!has_zpool && strcmp(zswap_zpool_type, ZSWAP_ZPOOL_DEFAULT)) {
 		pr_err("zpool %s not available, using default %s\n",
 		       zswap_zpool_type, ZSWAP_ZPOOL_DEFAULT);
 		param_free_charp(&zswap_zpool_type);
 		zswap_zpool_type = ZSWAP_ZPOOL_DEFAULT;
+		has_zpool = zpool_has_pool(zswap_zpool_type);
 	}
+	if (!has_zpool) {
+		pr_err("default zpool %s not available\n",
+		       zswap_zpool_type);
+		param_free_charp(&zswap_zpool_type);
+		zswap_zpool_type = ZSWAP_PARAM_UNSET;
+	}
+
+	if (!has_comp || !has_zpool)
+		return NULL;
 
 	return zswap_pool_create(zswap_zpool_type, zswap_compressor);
 }
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

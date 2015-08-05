Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9DA9003C7
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 09:47:08 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so29695458qge.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 06:47:08 -0700 (PDT)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id r88si5411252qkr.83.2015.08.05.06.47.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 06:47:07 -0700 (PDT)
Received: by qkdv3 with SMTP id v3so14832440qkd.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 06:47:07 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 3/3] zswap: change zpool/compressor at runtime
Date: Wed,  5 Aug 2015 09:46:43 -0400
Message-Id: <1438782403-29496-4-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

Update the zpool and compressor parameters to be changeable at runtime.
When changed, a new pool is created with the requested zpool/compressor,
and added as the current pool at the front of the pool list.  Previous
pools remain in the list only to remove existing compressed pages from.
The old pool(s) are removed once they become empty.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zswap.c | 135 +++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 122 insertions(+), 13 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index f8fcd7e..3eaff21 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -80,23 +80,39 @@ static u64 zswap_duplicate_entry;
 static bool zswap_enabled;
 module_param_named(enabled, zswap_enabled, bool, 0644);
 
-/* Compressor to be used by zswap (fixed at boot for now) */
+/* Crypto compressor to use */
 #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
-static char *zswap_compressor = ZSWAP_COMPRESSOR_DEFAULT;
-module_param_named(compressor, zswap_compressor, charp, 0444);
-
-/* The maximum percentage of memory that the compressed pool can occupy */
-static unsigned int zswap_max_pool_percent = 20;
-module_param_named(max_pool_percent,
-			zswap_max_pool_percent, uint, 0644);
+static char zswap_compressor[CRYPTO_MAX_ALG_NAME] = ZSWAP_COMPRESSOR_DEFAULT;
+static struct kparam_string zswap_compressor_kparam = {
+	.string =	zswap_compressor,
+	.maxlen =	sizeof(zswap_compressor),
+};
+static int zswap_compressor_param_set(const char *,
+				      const struct kernel_param *);
+static struct kernel_param_ops zswap_compressor_param_ops = {
+	.set =		zswap_compressor_param_set,
+	.get =		param_get_string,
+};
+module_param_cb(compressor, &zswap_compressor_param_ops,
+		&zswap_compressor_kparam, 0644);
 
-/* Compressed storage to use */
+/* Compressed storage zpool to use */
 #define ZSWAP_ZPOOL_DEFAULT "zbud"
-static char *zswap_zpool_type = ZSWAP_ZPOOL_DEFAULT;
-module_param_named(zpool, zswap_zpool_type, charp, 0444);
+static char zswap_zpool_type[32 /* arbitrary */] = ZSWAP_ZPOOL_DEFAULT;
+static struct kparam_string zswap_zpool_kparam = {
+	.string =	zswap_zpool_type,
+	.maxlen =	sizeof(zswap_zpool_type),
+};
+static int zswap_zpool_param_set(const char *, const struct kernel_param *);
+static struct kernel_param_ops zswap_zpool_param_ops = {
+	.set =	zswap_zpool_param_set,
+	.get =	param_get_string,
+};
+module_param_cb(zpool, &zswap_zpool_param_ops, &zswap_zpool_kparam, 0644);
 
-/* zpool is shared by all of zswap backend  */
-static struct zpool *zswap_pool;
+/* The maximum percentage of memory that the compressed pool can occupy */
+static unsigned int zswap_max_pool_percent = 20;
+module_param_named(max_pool_percent, zswap_max_pool_percent, uint, 0644);
 
 /*********************************
 * data structures
@@ -161,6 +177,9 @@ static LIST_HEAD(zswap_pools);
 /* protects zswap_pools list modification */
 static DEFINE_SPINLOCK(zswap_pools_lock);
 
+/* used by param callback function */
+static bool zswap_init_started;
+
 /*********************************
 * helpers and fwd declarations
 **********************************/
@@ -661,6 +680,94 @@ static void zswap_pool_put(struct zswap_pool *pool)
 	kref_put(&pool->kref, __zswap_pool_empty);
 }
 
+/*********************************
+* param callbacks
+**********************************/
+
+static int __zswap_param_set(const char *val, const struct kernel_param *kp,
+			     char *type, char *compressor)
+{
+	struct zswap_pool *pool, *put_pool = NULL;
+	char str[kp->str->maxlen], *s;
+	int ret;
+
+	strlcpy(str, val, kp->str->maxlen);
+	s = strim(str);
+
+	/* if this is load-time (pre-init) param setting,
+	 * don't create a pool; that's done during init.
+	 */
+	if (!zswap_init_started)
+		return param_set_copystring(s, kp);
+
+	/* no change required */
+	if (!strncmp(kp->str->string, s, kp->str->maxlen))
+		return 0;
+
+	if (!type) {
+		type = s;
+		if (!zpool_has_pool(type)) {
+			pr_err("zpool %s not available\n", type);
+			return -ENOENT;
+		}
+	} else if (!compressor) {
+		compressor = s;
+		if (!crypto_has_comp(compressor, 0, 0)) {
+			pr_err("compressor %s not available\n", compressor);
+			return -ENOENT;
+		}
+	}
+
+	spin_lock(&zswap_pools_lock);
+
+	pool = zswap_pool_find_get(type, compressor);
+	if (pool) {
+		zswap_pool_debug("using existing", pool);
+		list_del_rcu(&pool->list);
+	} else {
+		spin_unlock(&zswap_pools_lock);
+		pool = zswap_pool_create(type, compressor);
+		spin_lock(&zswap_pools_lock);
+	}
+
+	if (pool)
+		ret = param_set_copystring(s, kp);
+	else
+		ret = -EINVAL;
+
+	if (!ret) {
+		put_pool = zswap_pool_current();
+		list_add_rcu(&pool->list, &zswap_pools);
+	} else if (pool) {
+		/* add the possibly pre-existing pool to the end of the pools
+		 * list; if it's new (and empty) then it'll be removed and
+		 * destroyed by the put after we drop the lock
+		 */
+		list_add_tail_rcu(&pool->list, &zswap_pools);
+		put_pool = pool;
+	}
+
+	spin_unlock(&zswap_pools_lock);
+
+	/* drop the ref from either the old current pool,
+	 * or the new pool we failed to add
+	 */
+	if (put_pool)
+		zswap_pool_put(put_pool);
+
+	return ret;
+}
+
+static int zswap_compressor_param_set(const char *val,
+				      const struct kernel_param *kp)
+{
+	return __zswap_param_set(val, kp, zswap_zpool_type, NULL);
+}
+
+static int zswap_zpool_param_set(const char *val,
+				 const struct kernel_param *kp)
+{
+	return __zswap_param_set(val, kp, NULL, zswap_compressor);
 }
 
 /*********************************
@@ -1116,6 +1223,8 @@ static int __init init_zswap(void)
 {
 	struct zswap_pool *pool;
 
+	zswap_init_started = true;
+
 	if (zswap_entry_cache_create()) {
 		pr_err("entry cache creation failed\n");
 		goto cache_fail;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

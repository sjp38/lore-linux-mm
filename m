Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D26246B0253
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 10:59:07 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id f4so233681286qte.1
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 07:59:07 -0800 (PST)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id f186si1417613qka.137.2017.01.26.07.59.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 07:59:07 -0800 (PST)
Received: by mail-qt0-x242.google.com with SMTP id n13so39425604qtc.0
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 07:59:07 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zswap: don't param_set_charp while holding spinlock
Date: Thu, 26 Jan 2017 10:58:21 -0500
Message-Id: <20170126155821.4545-1-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

Change the zpool/compressor param callback function to release the
zswap_pools_lock spinlock before calling param_set_charp, since
that function may sleep when it calls kmalloc with GFP_KERNEL.

While this problem has existed for a while, I wasn't able to trigger
it using a tight loop changing either/both the zpool and compressor
params; I think it's very unlikely to be an issue on the stable kernels,
especially since most zswap users will change the compressor and/or
zpool from sysfs only one time each boot - or zero times, if they add
the params to the kernel boot.

Fixes: c99b42c3529e ("zswap: use charp for zswap param strings")
Reported-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Signed-off-by: Dan Streetman <dan.streetman@canonical.com>
---
Andrew, I'll leave it up to you if you want to send this to -stable;
personally I don't think it's needed.  For the stable kernels, only
the first hunk of the patch applies.

 mm/zswap.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 9e8565d..eedc278 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -704,18 +704,22 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
 	pool = zswap_pool_find_get(type, compressor);
 	if (pool) {
 		zswap_pool_debug("using existing", pool);
+		WARN_ON(pool == zswap_pool_current());
 		list_del_rcu(&pool->list);
-	} else {
-		spin_unlock(&zswap_pools_lock);
-		pool = zswap_pool_create(type, compressor);
-		spin_lock(&zswap_pools_lock);
 	}
 
+	spin_unlock(&zswap_pools_lock);
+
+	if (!pool)
+		pool = zswap_pool_create(type, compressor);
+
 	if (pool)
 		ret = param_set_charp(s, kp);
 	else
 		ret = -EINVAL;
 
+	spin_lock(&zswap_pools_lock);
+
 	if (!ret) {
 		put_pool = zswap_pool_current();
 		list_add_rcu(&pool->list, &zswap_pools);
@@ -727,7 +731,11 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
 		 */
 		list_add_tail_rcu(&pool->list, &zswap_pools);
 		put_pool = pool;
-	} else if (!zswap_has_pool) {
+	}
+
+	spin_unlock(&zswap_pools_lock);
+
+	if (!zswap_has_pool && !pool) {
 		/* if initial pool creation failed, and this pool creation also
 		 * failed, maybe both compressor and zpool params were bad.
 		 * Allow changing this param, so pool creation will succeed
@@ -738,8 +746,6 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
 		ret = param_set_charp(s, kp);
 	}
 
-	spin_unlock(&zswap_pools_lock);
-
 	/* drop the ref from either the old current pool,
 	 * or the new pool we failed to add
 	 */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

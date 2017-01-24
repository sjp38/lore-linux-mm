Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9384E6B027C
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 15:03:24 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id k15so166395648qtg.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:03:24 -0800 (PST)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id n73si13864395qke.243.2017.01.24.12.03.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 12:03:23 -0800 (PST)
Received: by mail-qt0-x243.google.com with SMTP id l7so27822864qtd.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:03:23 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 2/3] zswap: allow initialization at boot without pool
Date: Tue, 24 Jan 2017 15:02:58 -0500
Message-Id: <20170124200259.16191-3-ddstreet@ieee.org>
In-Reply-To: <20170124200259.16191-1-ddstreet@ieee.org>
References: <20170124200259.16191-1-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, Dan Streetman <dan.streetman@canonical.com>

Allow zswap to initialize at boot even if it can't create its pool
due to a failure to create a zpool and/or compressor.  Allow those
to be created later, from the sysfs module param interface.

Signed-off-by: Dan Streetman <dan.streetman@canonical.com>
---
 mm/zswap.c | 46 ++++++++++++++++++++++++++++++++++------------
 1 file changed, 34 insertions(+), 12 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index cabf09e..77cb847 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -185,6 +185,9 @@ static bool zswap_init_started;
 /* fatal error during init */
 static bool zswap_init_failed;
 
+/* init completed, but couldn't create the initial pool */
+static bool zswap_has_pool;
+
 /*********************************
 * helpers and fwd declarations
 **********************************/
@@ -424,7 +427,8 @@ static struct zswap_pool *__zswap_pool_current(void)
 	struct zswap_pool *pool;
 
 	pool = list_first_or_null_rcu(&zswap_pools, typeof(*pool), list);
-	WARN_ON(!pool);
+	WARN_ONCE(!pool && zswap_has_pool,
+		  "%s: no page storage pool!\n", __func__);
 
 	return pool;
 }
@@ -443,7 +447,7 @@ static struct zswap_pool *zswap_pool_current_get(void)
 	rcu_read_lock();
 
 	pool = __zswap_pool_current();
-	if (!pool || !zswap_pool_get(pool))
+	if (!zswap_pool_get(pool))
 		pool = NULL;
 
 	rcu_read_unlock();
@@ -459,7 +463,9 @@ static struct zswap_pool *zswap_pool_last_get(void)
 
 	list_for_each_entry_rcu(pool, &zswap_pools, list)
 		last = pool;
-	if (!WARN_ON(!last) && !zswap_pool_get(last))
+	WARN_ONCE(!last && zswap_has_pool,
+		  "%s: no page storage pool!\n", __func__);
+	if (!zswap_pool_get(last))
 		last = NULL;
 
 	rcu_read_unlock();
@@ -582,6 +588,9 @@ static void zswap_pool_destroy(struct zswap_pool *pool)
 
 static int __must_check zswap_pool_get(struct zswap_pool *pool)
 {
+	if (!pool)
+		return 0;
+
 	return kref_get_unless_zero(&pool->kref);
 }
 
@@ -639,7 +648,7 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
 	}
 
 	/* no change required */
-	if (!strcmp(s, *(char **)kp->arg))
+	if (!strcmp(s, *(char **)kp->arg) && zswap_has_pool)
 		return 0;
 
 	/* if this is load-time (pre-init) param setting,
@@ -685,6 +694,7 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
 	if (!ret) {
 		put_pool = zswap_pool_current();
 		list_add_rcu(&pool->list, &zswap_pools);
+		zswap_has_pool = true;
 	} else if (pool) {
 		/* add the possibly pre-existing pool to the end of the pools
 		 * list; if it's new (and empty) then it'll be removed and
@@ -692,6 +702,15 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
 		 */
 		list_add_tail_rcu(&pool->list, &zswap_pools);
 		put_pool = pool;
+	} else if (!zswap_has_pool) {
+		/* if initial pool creation failed, and this pool creation also
+		 * failed, maybe both compressor and zpool params were bad.
+		 * Allow changing this param, so pool creation will succeed
+		 * when the other param is changed. We already verified this
+		 * param is ok in the zpool_has_pool() or crypto_has_comp()
+		 * checks above.
+		 */
+		ret = param_set_charp(s, kp);
 	}
 
 	spin_unlock(&zswap_pools_lock);
@@ -724,6 +743,10 @@ static int zswap_enabled_param_set(const char *val,
 		pr_err("can't enable, initialization failed\n");
 		return -ENODEV;
 	}
+	if (!zswap_has_pool && zswap_init_started) {
+		pr_err("can't enable, no pool configured\n");
+		return -ENODEV;
+	}
 
 	return param_set_bool(val, kp);
 }
@@ -1205,22 +1228,21 @@ static int __init init_zswap(void)
 		goto hp_fail;
 
 	pool = __zswap_pool_create_fallback();
-	if (!pool) {
+	if (pool) {
+		pr_info("loaded using pool %s/%s\n", pool->tfm_name,
+			zpool_get_type(pool->zpool));
+		list_add(&pool->list, &zswap_pools);
+		zswap_has_pool = true;
+	} else {
 		pr_err("pool creation failed\n");
-		goto pool_fail;
+		zswap_enabled = false;
 	}
-	pr_info("loaded using pool %s/%s\n", pool->tfm_name,
-		zpool_get_type(pool->zpool));
-
-	list_add(&pool->list, &zswap_pools);
 
 	frontswap_register_ops(&zswap_frontswap_ops);
 	if (zswap_debugfs_init())
 		pr_warn("debugfs initialization failed\n");
 	return 0;
 
-pool_fail:
-	cpuhp_remove_state_nocalls(CPUHP_MM_ZSWP_POOL_PREPARE);
 hp_fail:
 	cpuhp_remove_state(CPUHP_MM_ZSWP_MEM_PREPARE);
 dstmem_fail:
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

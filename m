Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 73B8C6B025F
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 05:22:05 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id h69so784309lfb.8
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 02:22:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7sor3209160ljb.67.2017.12.20.02.22.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 02:22:03 -0800 (PST)
From: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Subject: [PATCH v3] mm/zsmalloc: simplify shrinker init/destroy
Date: Wed, 20 Dec 2017 13:21:49 +0300
Message-Id: <1513765309-19500-1-git-send-email-akaraliou.dev@gmail.com>
In-Reply-To: <06247d4c-82a7-ccf1-ad42-4ef751081011@gmail.com>
References: <06247d4c-82a7-ccf1-ad42-4ef751081011@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org
Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>, linux-mm@kvack.org

Structure zs_pool has special flag to indicate success of shrinker
initialization. unregister_shrinker() has improved and can detect
by itself whether actual deinitialization should be performed or not,
so extra flag becomes redundant.

Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/zsmalloc.c | 30 +++++++++++++-----------------
 1 file changed, 13 insertions(+), 17 deletions(-)

v2: Added include <linux/shrinker.h> as suggested by Sergey Senozhatsky.
v3: Improved comment regarding shrinker registration failure.
    Added patch from Andrew Morton to make zs_register_shrinker() void.

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 685049a..bed387b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -53,6 +53,7 @@
 #include <linux/mount.h>
 #include <linux/migrate.h>
 #include <linux/pagemap.h>
+#include <linux/shrinker.h>
 
 #define ZSPAGE_MAGIC	0x58
 
@@ -256,11 +257,7 @@ struct zs_pool {
 
 	/* Compact classes */
 	struct shrinker shrinker;
-	/*
-	 * To signify that register_shrinker() was successful
-	 * and unregister_shrinker() will not Oops.
-	 */
-	bool shrinker_enabled;
+
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct dentry *stat_dentry;
 #endif
@@ -2323,20 +2320,23 @@ static unsigned long zs_shrinker_count(struct shrinker *shrinker,
 
 static void zs_unregister_shrinker(struct zs_pool *pool)
 {
-	if (pool->shrinker_enabled) {
-		unregister_shrinker(&pool->shrinker);
-		pool->shrinker_enabled = false;
-	}
+	unregister_shrinker(&pool->shrinker);
 }
 
-static int zs_register_shrinker(struct zs_pool *pool)
+static void zs_register_shrinker(struct zs_pool *pool)
 {
 	pool->shrinker.scan_objects = zs_shrinker_scan;
 	pool->shrinker.count_objects = zs_shrinker_count;
 	pool->shrinker.batch = 0;
 	pool->shrinker.seeks = DEFAULT_SEEKS;
 
-	return register_shrinker(&pool->shrinker);
+	/*
+	 * Not critical since shrinker is only used to trigger internal
+	 * defragmentation of the pool which is pretty optional thing.  If
+	 * registration fails we still can use the pool normally and user can
+	 * trigger compaction manually. Thus, ignore return code.
+	 */
+	register_shrinker(&pool->shrinker);
 }
 
 /**
@@ -2424,12 +2424,8 @@ struct zs_pool *zs_create_pool(const char *name)
 	if (zs_register_migration(pool))
 		goto err;
 
-	/*
-	 * Not critical, we still can use the pool
-	 * and user can trigger compaction manually.
-	 */
-	if (zs_register_shrinker(pool) == 0)
-		pool->shrinker_enabled = true;
+	zs_register_shrinker(pool);
+
 	return pool;
 
 err:
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

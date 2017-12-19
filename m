Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B2E4B6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:49:45 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id f4so11173209wre.9
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 02:49:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 27sor2652989ljv.112.2017.12.19.02.49.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 02:49:44 -0800 (PST)
From: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Subject: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Date: Tue, 19 Dec 2017 13:49:12 +0300
Message-Id: <1513680552-9798-1-git-send-email-akaraliou.dev@gmail.com>
In-Reply-To: <20171219102213.GA435@jagdpanzerIV>
References: <20171219102213.GA435@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com
Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>, linux-mm@kvack.org

Structure zs_pool has special flag to indicate success of shrinker
initialization. unregister_shrinker() has improved and can detect
by itself whether actual deinitialization should be performed or not,
so extra flag becomes redundant.

Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>
---
 mm/zsmalloc.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

v2: Added include <linux/shrinker.h> as suggested by Sergey Senozhatsky.

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 685049a..628a1bc 100644
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
@@ -2323,10 +2320,7 @@ static unsigned long zs_shrinker_count(struct shrinker *shrinker,
 
 static void zs_unregister_shrinker(struct zs_pool *pool)
 {
-	if (pool->shrinker_enabled) {
-		unregister_shrinker(&pool->shrinker);
-		pool->shrinker_enabled = false;
-	}
+	unregister_shrinker(&pool->shrinker);
 }
 
 static int zs_register_shrinker(struct zs_pool *pool)
@@ -2428,8 +2422,8 @@ struct zs_pool *zs_create_pool(const char *name)
 	 * Not critical, we still can use the pool
 	 * and user can trigger compaction manually.
 	 */
-	if (zs_register_shrinker(pool) == 0)
-		pool->shrinker_enabled = true;
+	(void) zs_register_shrinker(pool);
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

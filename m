Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id E14F66B0262
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 11:39:38 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id u23so61391550vkb.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:39:38 -0700 (PDT)
Received: from mail-qg0-x244.google.com (mail-qg0-x244.google.com. [2607:f8b0:400d:c04::244])
        by mx.google.com with ESMTPS id d124si5175193qka.70.2016.04.28.08.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 08:39:38 -0700 (PDT)
Received: by mail-qg0-x244.google.com with SMTP id b14so5808293qge.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:39:38 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] mm/zsmalloc: don't fail if can't create debugfs info
Date: Thu, 28 Apr 2016 11:36:48 -0400
Message-Id: <1461857808-11030-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>, Dan Streetman <dan.streetman@canonical.com>

Change the return type of zs_pool_stat_create() to void, and
remove the logic to abort pool creation if the stat debugfs
dir/file could not be created.

The debugfs stat file is for debugging/information only, and doesn't
affect operation of zsmalloc; there is no reason to abort creating
the pool if the stat file can't be created.  This was seen with
zswap, which used the same name for all pool creations, which caused
zsmalloc to fail to create a second pool for zswap if
CONFIG_ZSMALLOC_STAT was enabled.

Cc: Dan Streetman <dan.streetman@canonical.com>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zsmalloc.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index e72efb1..25a7db2 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -567,17 +567,17 @@ static const struct file_operations zs_stat_size_ops = {
 	.release        = single_release,
 };
 
-static int zs_pool_stat_create(const char *name, struct zs_pool *pool)
+static void zs_pool_stat_create(const char *name, struct zs_pool *pool)
 {
 	struct dentry *entry;
 
 	if (!zs_stat_root)
-		return -ENODEV;
+		return;
 
 	entry = debugfs_create_dir(name, zs_stat_root);
 	if (!entry) {
 		pr_warn("debugfs dir <%s> creation failed\n", name);
-		return -ENOMEM;
+		return;
 	}
 	pool->stat_dentry = entry;
 
@@ -586,10 +586,8 @@ static int zs_pool_stat_create(const char *name, struct zs_pool *pool)
 	if (!entry) {
 		pr_warn("%s: debugfs file entry <%s> creation failed\n",
 				name, "classes");
-		return -ENOMEM;
+		return;
 	}
-
-	return 0;
 }
 
 static void zs_pool_stat_destroy(struct zs_pool *pool)
@@ -607,9 +605,8 @@ static void __exit zs_stat_exit(void)
 {
 }
 
-static inline int zs_pool_stat_create(const char *name, struct zs_pool *pool)
+static inline void zs_pool_stat_create(const char *name, struct zs_pool *pool)
 {
-	return 0;
 }
 
 static inline void zs_pool_stat_destroy(struct zs_pool *pool)
@@ -1956,8 +1953,8 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 
 	pool->flags = flags;
 
-	if (zs_pool_stat_create(name, pool))
-		goto err;
+	/* debug only, don't abort if it fails */
+	zs_pool_stat_create(name, pool);
 
 	/*
 	 * Not critical, we still can use the pool
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

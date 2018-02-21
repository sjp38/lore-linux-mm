Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6E316B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 14:51:48 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v186so1254616pfb.8
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 11:51:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d90-v6sor3199463pld.6.2018.02.21.11.51.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Feb 2018 11:51:47 -0800 (PST)
Date: Thu, 22 Feb 2018 01:23:07 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v3] mm: zsmalloc: Replace return type int with bool
Message-ID: <20180221195306.GA32070@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com
Cc: linux-mm@kvack.org

zs_register_migration() returns either 0 or 1.
So the return type int should be replaced with bool.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---

v2: Returning false in zs_register_migration() as return
    type is bool
v3: Return true/false correctly incase of success/failure

 mm/zsmalloc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index c301350..0215f3c 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -295,7 +295,7 @@ struct mapping_area {
 };

 #ifdef CONFIG_COMPACTION
-static int zs_register_migration(struct zs_pool *pool);
+static bool zs_register_migration(struct zs_pool *pool);
 static void zs_unregister_migration(struct zs_pool *pool);
 static void migrate_lock_init(struct zspage *zspage);
 static void migrate_read_lock(struct zspage *zspage);
@@ -306,7 +306,7 @@ struct mapping_area {
 #else
 static int zsmalloc_mount(void) { return 0; }
 static void zsmalloc_unmount(void) {}
-static int zs_register_migration(struct zs_pool *pool) { return 0; }
+static bool zs_register_migration(struct zs_pool *pool) { return false; }
 static void zs_unregister_migration(struct zs_pool *pool) {}
 static void migrate_lock_init(struct zspage *zspage) {}
 static void migrate_read_lock(struct zspage *zspage) {}
@@ -2101,17 +2101,17 @@ void zs_page_putback(struct page *page)
 	.putback_page = zs_page_putback,
 };

-static int zs_register_migration(struct zs_pool *pool)
+static bool zs_register_migration(struct zs_pool *pool)
 {
 	pool->inode = alloc_anon_inode(zsmalloc_mnt->mnt_sb);
 	if (IS_ERR(pool->inode)) {
 		pool->inode = NULL;
-		return 1;
+		return false;
 	}

 	pool->inode->i_mapping->private_data = pool;
 	pool->inode->i_mapping->a_ops = &zsmalloc_aops;
-	return 0;
+	return true;
 }

 static void zs_unregister_migration(struct zs_pool *pool)
@@ -2409,7 +2409,7 @@ struct zs_pool *zs_create_pool(const char *name)
 	/* debug only, don't abort if it fails */
 	zs_pool_stat_create(pool, name);

-	if (zs_register_migration(pool))
+	if (zs_register_migration(pool) == false)
 		goto err;

 	/*
--
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

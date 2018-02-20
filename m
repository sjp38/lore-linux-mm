Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D34566B000E
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 12:56:53 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id o66so5219672pfg.22
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 09:56:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2sor1155589pgt.275.2018.02.20.09.56.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Feb 2018 09:56:52 -0800 (PST)
Date: Tue, 20 Feb 2018 23:28:11 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v2] mm: zsmalloc: Replace return type int with bool
Message-ID: <20180220175811.GA28277@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com
Cc: linux-mm@kvack.org

zs_register_migration() returns either 0 or 1.
So the return type int should be replaced with bool.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---

v2: Returning false in zs_register_migration() as return
    type is bool

 mm/zsmalloc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index c301350..5fa2dfe 100644
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
+		return true;
 	}

 	pool->inode->i_mapping->private_data = pool;
 	pool->inode->i_mapping->a_ops = &zsmalloc_aops;
-	return 0;
+	return false;
 }

 static void zs_unregister_migration(struct zs_pool *pool)
--
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 128426B00AB
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:57:32 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 4/8] cleancache: Make cleancache_init use a pointer for the ops
Date: Wed, 14 Nov 2012 13:57:08 -0500
Message-Id: <1352919432-9699-5-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
References: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, akpm@linux-foundation.org, mgorman@suse.de
Cc: fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Instead of using a backend_registered to determine whether
a backend is enabled. This allows us to remove the
backend_register check and just do 'if (cleancache_ops)'

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 drivers/staging/ramster/zcache-main.c |    8 +++---
 drivers/staging/zcache/zcache-main.c  |    8 +++---
 drivers/xen/tmem.c                    |    6 ++--
 include/linux/cleancache.h            |    2 +-
 mm/cleancache.c                       |   43 +++++++++++++++-----------------
 5 files changed, 32 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 6c8959d..ed99170 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -1495,9 +1495,9 @@ static struct cleancache_ops zcache_cleancache_ops = {
 	.init_fs = zcache_cleancache_init_fs
 };
 
-struct cleancache_ops zcache_cleancache_register_ops(void)
+struct cleancache_ops *zcache_cleancache_register_ops(void)
 {
-	struct cleancache_ops old_ops =
+	struct cleancache_ops *old_ops =
 		cleancache_register_ops(&zcache_cleancache_ops);
 
 	return old_ops;
@@ -1781,7 +1781,7 @@ static int __init zcache_init(void)
 	}
 	zbud_init();
 	if (zcache_enabled && !disable_cleancache) {
-		struct cleancache_ops old_ops;
+		struct cleancache_ops *old_ops;
 
 		register_shrinker(&zcache_shrinker);
 		old_ops = zcache_cleancache_register_ops();
@@ -1791,7 +1791,7 @@ static int __init zcache_init(void)
 		pr_info("%s: cleancache: ignorenonactive = %d\n",
 			namestr, !disable_cleancache_ignore_nonactive);
 #endif
-		if (old_ops.init_fs != NULL)
+		if (old_ops)
 			pr_warn("%s: cleancache_ops overridden\n", namestr);
 	}
 	if (zcache_enabled && !disable_frontswap) {
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 3db38cb..f9ab874 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1811,9 +1811,9 @@ static struct cleancache_ops zcache_cleancache_ops = {
 	.init_fs = zcache_cleancache_init_fs
 };
 
-struct cleancache_ops zcache_cleancache_register_ops(void)
+struct cleancache_ops *zcache_cleancache_register_ops(void)
 {
-	struct cleancache_ops old_ops =
+	struct cleancache_ops *old_ops =
 		cleancache_register_ops(&zcache_cleancache_ops);
 
 	return old_ops;
@@ -2048,14 +2048,14 @@ static int __init zcache_init(void)
 
 #ifdef CONFIG_CLEANCACHE
 	if (zcache_enabled && use_cleancache) {
-		struct cleancache_ops old_ops;
+		struct cleancache_ops *old_ops;
 
 		zbud_init();
 		register_shrinker(&zcache_shrinker);
 		old_ops = zcache_cleancache_register_ops();
 		pr_info("zcache: cleancache enabled using kernel "
 			"transcendent memory and compression buddies\n");
-		if (old_ops.init_fs != NULL)
+		if (old_ops)
 			pr_warning("zcache: cleancache_ops overridden");
 	}
 #endif
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 4b02c07..15e776c 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -236,7 +236,7 @@ static int __init no_cleancache(char *s)
 }
 __setup("nocleancache", no_cleancache);
 
-static struct cleancache_ops __initdata tmem_cleancache_ops = {
+static struct cleancache_ops tmem_cleancache_ops = {
 	.put_page = tmem_cleancache_put_page,
 	.get_page = tmem_cleancache_get_page,
 	.invalidate_page = tmem_cleancache_flush_page,
@@ -392,9 +392,9 @@ static int __init xen_tmem_init(void)
 	BUG_ON(sizeof(struct cleancache_filekey) != sizeof(struct tmem_oid));
 	if (tmem_enabled && use_cleancache) {
 		char *s = "";
-		struct cleancache_ops old_ops =
+		struct cleancache_ops *old_ops =
 			cleancache_register_ops(&tmem_cleancache_ops);
-		if (old_ops.init_fs != NULL)
+		if (old_ops)
 			s = " (WARNING: cleancache_ops overridden)";
 		printk(KERN_INFO "cleancache enabled, RAM provided by "
 				 "Xen Transcendent Memory%s\n", s);
diff --git a/include/linux/cleancache.h b/include/linux/cleancache.h
index 42e55de..3af5ea8 100644
--- a/include/linux/cleancache.h
+++ b/include/linux/cleancache.h
@@ -33,7 +33,7 @@ struct cleancache_ops {
 	void (*invalidate_fs)(int);
 };
 
-extern struct cleancache_ops
+extern struct cleancache_ops *
 	cleancache_register_ops(struct cleancache_ops *ops);
 extern void __cleancache_init_fs(struct super_block *);
 extern void __cleancache_init_shared_fs(char *, struct super_block *);
diff --git a/mm/cleancache.c b/mm/cleancache.c
index 318a0ad..95f6618 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -32,7 +32,7 @@ EXPORT_SYMBOL(cleancache_enabled);
  * cleancache_ops is set by cleancache_ops_register to contain the pointers
  * to the cleancache "backend" implementation functions.
  */
-static struct cleancache_ops cleancache_ops __read_mostly;
+static struct cleancache_ops *cleancache_ops __read_mostly;
 
 /*
  * Counters available via /sys/kernel/debug/frontswap (if debugfs is
@@ -63,27 +63,24 @@ static int fs_poolid_map[MAX_INITIALIZABLE_FS];
 static int shared_fs_poolid_map[MAX_INITIALIZABLE_FS];
 
 static char *uuids[MAX_INITIALIZABLE_FS];
-static bool __read_mostly backend_registered;
 
 /*
  * register operations for cleancache, returning previous thus allowing
  * detection of multiple backends and possible nesting
  */
-struct cleancache_ops cleancache_register_ops(struct cleancache_ops *ops)
+struct cleancache_ops *cleancache_register_ops(struct cleancache_ops *ops)
 {
-	struct cleancache_ops old = cleancache_ops;
+	struct cleancache_ops *old = cleancache_ops;
 	int i;
 
-	cleancache_ops = *ops;
-
-	backend_registered = true;
 	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
 		if (fs_poolid_map[i] == FS_NO_BACKEND)
-			fs_poolid_map[i] = (*cleancache_ops.init_fs)(PAGE_SIZE);
+			fs_poolid_map[i] = ops->init_fs(PAGE_SIZE);
 		if (shared_fs_poolid_map[i] == FS_NO_BACKEND)
-			shared_fs_poolid_map[i] = (*cleancache_ops.init_shared_fs)
+			shared_fs_poolid_map[i] = ops->init_shared_fs
 					(uuids[i], PAGE_SIZE);
 	}
+	cleancache_ops = ops;
 	return old;
 }
 EXPORT_SYMBOL(cleancache_register_ops);
@@ -96,8 +93,8 @@ void __cleancache_init_fs(struct super_block *sb)
 	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
 		if (fs_poolid_map[i] == FS_UNKNOWN) {
 			sb->cleancache_poolid = i + FAKE_FS_POOLID_OFFSET;
-			if (backend_registered)
-				fs_poolid_map[i] = (*cleancache_ops.init_fs)(PAGE_SIZE);
+			if (cleancache_ops)
+				fs_poolid_map[i] = cleancache_ops->init_fs(PAGE_SIZE);
 			else
 				fs_poolid_map[i] = FS_NO_BACKEND;
 			break;
@@ -115,8 +112,8 @@ void __cleancache_init_shared_fs(char *uuid, struct super_block *sb)
 		if (shared_fs_poolid_map[i] == FS_UNKNOWN) {
 			sb->cleancache_poolid = i + FAKE_SHARED_FS_POOLID_OFFSET;
 			uuids[i] = uuid;
-			if (backend_registered)
-				shared_fs_poolid_map[i] = (*cleancache_ops.init_shared_fs)
+			if (cleancache_ops)
+				shared_fs_poolid_map[i] = cleancache_ops->init_shared_fs
 						(uuid, PAGE_SIZE);
 			else
 				shared_fs_poolid_map[i] = FS_NO_BACKEND;
@@ -178,7 +175,7 @@ int __cleancache_get_page(struct page *page)
 	int fake_pool_id;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!backend_registered) {
+	if (!cleancache_ops) {
 		cleancache_failed_gets++;
 		goto out;
 	}
@@ -193,7 +190,7 @@ int __cleancache_get_page(struct page *page)
 		goto out;
 
 	if (pool_id >= 0)
-		ret = (*cleancache_ops.get_page)(pool_id,
+		ret = cleancache_ops->get_page(pool_id,
 				key, page->index, page);
 	if (ret == 0)
 		cleancache_succ_gets++;
@@ -216,7 +213,7 @@ void __cleancache_put_page(struct page *page)
 	int fake_pool_id;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!backend_registered) {
+	if (!cleancache_ops) {
 		cleancache_puts++;
 		return;
 	}
@@ -230,7 +227,7 @@ void __cleancache_put_page(struct page *page)
 
 	if (pool_id >= 0 &&
 		cleancache_get_key(page->mapping->host, &key) >= 0) {
-		(*cleancache_ops.put_page)(pool_id, key, page->index, page);
+		cleancache_ops->put_page(pool_id, key, page->index, page);
 		cleancache_puts++;
 	}
 }
@@ -248,7 +245,7 @@ void __cleancache_invalidate_page(struct address_space *mapping,
 	int fake_pool_id = mapping->host->i_sb->cleancache_poolid;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!backend_registered)
+	if (!cleancache_ops)
 		return;
 
 	if (fake_pool_id >= 0) {
@@ -258,7 +255,7 @@ void __cleancache_invalidate_page(struct address_space *mapping,
 
 		VM_BUG_ON(!PageLocked(page));
 		if (cleancache_get_key(mapping->host, &key) >= 0) {
-			(*cleancache_ops.invalidate_page)(pool_id,
+			cleancache_ops->invalidate_page(pool_id,
 					key, page->index);
 			cleancache_invalidates++;
 		}
@@ -277,7 +274,7 @@ void __cleancache_invalidate_inode(struct address_space *mapping)
 	int fake_pool_id = mapping->host->i_sb->cleancache_poolid;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!backend_registered)
+	if (!cleancache_ops)
 		return;
 
 	if (fake_pool_id < 0)
@@ -286,7 +283,7 @@ void __cleancache_invalidate_inode(struct address_space *mapping)
 	pool_id = get_poolid_from_fake(fake_pool_id);
 
 	if (pool_id >= 0 && cleancache_get_key(mapping->host, &key) >= 0)
-		(*cleancache_ops.invalidate_inode)(pool_id, key);
+		cleancache_ops->invalidate_inode(pool_id, key);
 }
 EXPORT_SYMBOL(__cleancache_invalidate_inode);
 
@@ -312,8 +309,8 @@ void __cleancache_invalidate_fs(struct super_block *sb)
 		fs_poolid_map[index] = FS_UNKNOWN;
 	}
 	sb->cleancache_poolid = -1;
-	if (backend_registered)
-		(*cleancache_ops.invalidate_fs)(old_poolid);
+	if (cleancache_ops)
+		cleancache_ops->invalidate_fs(old_poolid);
 }
 EXPORT_SYMBOL(__cleancache_invalidate_fs);
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

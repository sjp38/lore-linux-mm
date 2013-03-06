Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 345696B0038
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 03:52:35 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id rp2so5707445pbb.34
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 00:52:34 -0800 (PST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH V2 06/11] cleancache: Make cleancache_init use a pointer for the ops
Date: Wed,  6 Mar 2013 16:51:25 +0800
Message-Id: <1362559890-16710-6-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
References: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, rcj@linux.vnet.ibm.com, ngupta@vflare.org, minchan@kernel.org, ric.masonn@gmail.com, Bob Liu <lliubbo@gmail.com>

From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Instead of using a backend_registered to determine whether
a backend is enabled. This allows us to remove the
backend_register check and just do 'if (cleancache_ops)'

[v1: Rebase on top of b97c4b430b0a405a57c78607b520d8000329e259
(ramster->zcache move]
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 drivers/staging/zcache/zcache-main.c |    8 ++---
 drivers/xen/tmem.c                   |    6 ++--
 include/linux/cleancache.h           |    2 +-
 mm/cleancache.c                      |   62 ++++++++++++++++++----------------
 4 files changed, 40 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 3365f59..3554987 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1694,9 +1694,9 @@ static struct cleancache_ops zcache_cleancache_ops = {
 	.init_fs = zcache_cleancache_init_fs
 };
 
-struct cleancache_ops zcache_cleancache_register_ops(void)
+struct cleancache_ops *zcache_cleancache_register_ops(void)
 {
-	struct cleancache_ops old_ops =
+	struct cleancache_ops *old_ops =
 		cleancache_register_ops(&zcache_cleancache_ops);
 
 	return old_ops;
@@ -1980,7 +1980,7 @@ static int __init zcache_init(void)
 	}
 	zbud_init();
 	if (zcache_enabled && !disable_cleancache) {
-		struct cleancache_ops old_ops;
+		struct cleancache_ops *old_ops;
 
 		register_shrinker(&zcache_shrinker);
 		old_ops = zcache_cleancache_register_ops();
@@ -1990,7 +1990,7 @@ static int __init zcache_init(void)
 		pr_info("%s: cleancache: ignorenonactive = %d\n",
 			namestr, !disable_cleancache_ignore_nonactive);
 #endif
-		if (old_ops.init_fs != NULL)
+		if (old_ops != NULL)
 			pr_warn("%s: cleancache_ops overridden\n", namestr);
 	}
 	if (zcache_enabled && !disable_frontswap) {
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
index f2e2907..8d8fb4e 100644
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
@@ -72,15 +72,14 @@ static DEFINE_MUTEX(poolid_mutex);
 /*
  * When set to false (default) all calls to the cleancache functions, except
  * the __cleancache_invalidate_fs and __cleancache_init_[shared|]fs are guarded
- * by the if (!backend_registered) return. This means multiple threads (from
- * different filesystems) will be checking backend_registered. The usage of a
+ * by the if (!cleancache_ops) return. This means multiple threads (from
+ * different filesystems) will be checking cleancache_ops. The usage of a
  * bool instead of a atomic_t or a bool guarded by a spinlock is OK - we are
  * OK if the time between the backend's have been initialized (and
- * backend_registered has been set to true) and when the filesystems start
+ * cleancache_ops has been set to not NULL) and when the filesystems start
  * actually calling the backends. The inverse (when unloading) is obviously
  * not good - but this shim does not do that (yet).
  */
-static bool backend_registered __read_mostly;
 
 /*
  * The backends and filesystems work all asynchronously. This is b/c the
@@ -90,13 +89,13 @@ static bool backend_registered __read_mostly;
  *		[shared_|]fs_poolid_map and uuids for.
  *
  *	b). user does I/Os -> we call the rest of __cleancache_* functions
- *		which return immediately as backend_registered is false.
+ *		which return immediately as cleancache_ops is false.
  *
  *	c). modprobe zcache -> cleancache_register_ops. We init the backend
- *		and set backend_registered to true, and for any fs_poolid_map
+ *		and set cleancache_ops to true, and for any fs_poolid_map
  *		(which is set by __cleancache_init_fs) we initialize the poolid.
  *
- *	d). user does I/Os -> now that backend_registered is true all the
+ *	d). user does I/Os -> now that cleancache_ops is true all the
  *		__cleancache_* functions can call the backend. They all check
  *		that fs_poolid_map is valid and if so invoke the backend.
  *
@@ -120,23 +119,26 @@ static bool backend_registered __read_mostly;
  * Register operations for cleancache, returning previous thus allowing
  * detection of multiple backends and possible nesting.
  */
-struct cleancache_ops cleancache_register_ops(struct cleancache_ops *ops)
+struct cleancache_ops *cleancache_register_ops(struct cleancache_ops *ops)
 {
-	struct cleancache_ops old = cleancache_ops;
+	struct cleancache_ops *old = cleancache_ops;
 	int i;
 
 	mutex_lock(&poolid_mutex);
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
-out:
+	/*
+	 * We MUST set cleancache_ops _after_ we have called the backends
+	 * init_fs or init_shared_fs functions. Otherwise the compiler might
+	 * re-order where cleancache_ops is set in this function.
+	 */
+	barrier();
+	cleancache_ops = ops;
 	mutex_unlock(&poolid_mutex);
 	return old;
 }
@@ -151,8 +153,8 @@ void __cleancache_init_fs(struct super_block *sb)
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
@@ -172,8 +174,8 @@ void __cleancache_init_shared_fs(char *uuid, struct super_block *sb)
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
@@ -240,7 +242,7 @@ int __cleancache_get_page(struct page *page)
 	int fake_pool_id;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!backend_registered) {
+	if (!cleancache_ops) {
 		cleancache_failed_gets++;
 		goto out;
 	}
@@ -255,7 +257,7 @@ int __cleancache_get_page(struct page *page)
 		goto out;
 
 	if (pool_id >= 0)
-		ret = (*cleancache_ops.get_page)(pool_id,
+		ret = cleancache_ops->get_page(pool_id,
 				key, page->index, page);
 	if (ret == 0)
 		cleancache_succ_gets++;
@@ -282,7 +284,7 @@ void __cleancache_put_page(struct page *page)
 	int fake_pool_id;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!backend_registered) {
+	if (!cleancache_ops) {
 		cleancache_puts++;
 		return;
 	}
@@ -296,7 +298,7 @@ void __cleancache_put_page(struct page *page)
 
 	if (pool_id >= 0 &&
 		cleancache_get_key(page->mapping->host, &key) >= 0) {
-		(*cleancache_ops.put_page)(pool_id, key, page->index, page);
+		cleancache_ops->put_page(pool_id, key, page->index, page);
 		cleancache_puts++;
 	}
 }
@@ -318,7 +320,7 @@ void __cleancache_invalidate_page(struct address_space *mapping,
 	int fake_pool_id = mapping->host->i_sb->cleancache_poolid;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!backend_registered)
+	if (!cleancache_ops)
 		return;
 
 	if (fake_pool_id >= 0) {
@@ -328,7 +330,7 @@ void __cleancache_invalidate_page(struct address_space *mapping,
 
 		VM_BUG_ON(!PageLocked(page));
 		if (cleancache_get_key(mapping->host, &key) >= 0) {
-			(*cleancache_ops.invalidate_page)(pool_id,
+			cleancache_ops->invalidate_page(pool_id,
 					key, page->index);
 			cleancache_invalidates++;
 		}
@@ -351,7 +353,7 @@ void __cleancache_invalidate_inode(struct address_space *mapping)
 	int fake_pool_id = mapping->host->i_sb->cleancache_poolid;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!backend_registered)
+	if (!cleancache_ops)
 		return;
 
 	if (fake_pool_id < 0)
@@ -360,7 +362,7 @@ void __cleancache_invalidate_inode(struct address_space *mapping)
 	pool_id = get_poolid_from_fake(fake_pool_id);
 
 	if (pool_id >= 0 && cleancache_get_key(mapping->host, &key) >= 0)
-		(*cleancache_ops.invalidate_inode)(pool_id, key);
+		cleancache_ops->invalidate_inode(pool_id, key);
 }
 EXPORT_SYMBOL(__cleancache_invalidate_inode);
 
@@ -387,8 +389,8 @@ void __cleancache_invalidate_fs(struct super_block *sb)
 		fs_poolid_map[index] = FS_UNKNOWN;
 	}
 	sb->cleancache_poolid = -1;
-	if (backend_registered)
-		(*cleancache_ops.invalidate_fs)(old_poolid);
+	if (cleancache_ops)
+		cleancache_ops->invalidate_fs(old_poolid);
 	mutex_unlock(&poolid_mutex);
 }
 EXPORT_SYMBOL(__cleancache_invalidate_fs);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

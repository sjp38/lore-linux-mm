Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 0355D6B0083
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 13:14:37 -0400 (EDT)
From: Andor Daam <andor.daam@googlemail.com>
Subject: [PATCH 2/2] cleancache: allow backends to register after cleancache initilaization
Date: Wed, 14 Mar 2012 18:13:28 +0100
Message-Id: <1331745208-1010-3-git-send-email-andor.daam@googlemail.com>
In-Reply-To: <1331745208-1010-1-git-send-email-andor.daam@googlemail.com>
References: <1331745208-1010-1-git-send-email-andor.daam@googlemail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, ilendir@googlemail.com, konrad.wilk@oracle.com, fschmaus@gmail.com, i4passt@lists.informatik.uni-erlangen.de, ngupta@vflare.org, Andor Daam <andor.daam@googlemail.com>

This patch allows backends to register to cleancache even after
filesystems were mounted. Calls to inif_fs and init_shared_fs are
remembered, fake poolids but no real tmem_pools created. On backend
registration the fake poolids are mapped to real poolids and respective
tmem_pools.

Signed-off-by: Stefan Hengelein <ilendir@googlemail.com>
Signed-off-by: Florian Schmaus <fschmaus@gmail.com>
Signed-off-by: Andor Daam <andor.daam@googlemail.com>
---
 mm/cleancache.c |  157 +++++++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 140 insertions(+), 17 deletions(-)

diff --git a/mm/cleancache.c b/mm/cleancache.c
index 5646c74..9f504b6 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -45,15 +45,42 @@ static u64 cleancache_puts;
 static u64 cleancache_invalidates;
 
 /*
+ * When no backend is registered all calls to init_fs and init_shard_fs
+ * are registered and fake poolids are given to the respective
+ * super block but no tmem_pools are created. When a backend
+ * registers with cleancache the previous calls to init_fs and
+ * init_shared_fs are executed to create tmem_pools and set the
+ * respective poolids. While no backend is registered all "puts",
+ * "gets" and "flushes" are ignored or fail.
+ */
+#define MAX_INITIALIZABLE_FS 32
+#define FAKE_FS_POOLID_OFFSET 1000
+#define FAKE_SHARED_FS_POOLID_OFFSET 2000
+static int fs_poolid_map[MAX_INITIALIZABLE_FS];
+static int shared_fs_poolid_map[MAX_INITIALIZABLE_FS];
+static char *uuids[MAX_INITIALIZABLE_FS];
+static int backend_registered;
+
+/*
  * register operations for cleancache, returning previous thus allowing
  * detection of multiple backends and possible nesting
  */
 struct cleancache_ops cleancache_register_ops(struct cleancache_ops *ops)
 {
 	struct cleancache_ops old = cleancache_ops;
+	int i;
 
 	cleancache_ops = *ops;
-	cleancache_enabled = 1;
+
+	backend_registered = 1;
+	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
+		if (fs_poolid_map[i] == -1)
+			fs_poolid_map[i] = (*cleancache_ops.init_fs)(PAGE_SIZE);
+		if (shared_fs_poolid_map[i] == -1)
+			shared_fs_poolid_map[i] =
+				(*cleancache_ops.init_shared_fs)
+					(uuids[i], PAGE_SIZE);
+	}
 	return old;
 }
 EXPORT_SYMBOL(cleancache_register_ops);
@@ -61,15 +88,42 @@ EXPORT_SYMBOL(cleancache_register_ops);
 /* Called by a cleancache-enabled filesystem at time of mount */
 void __cleancache_init_fs(struct super_block *sb)
 {
-	sb->cleancache_poolid = (*cleancache_ops.init_fs)(PAGE_SIZE);
+	int i;
+
+	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
+		if (fs_poolid_map[i] == -2) {
+			sb->cleancache_poolid =
+				i + FAKE_FS_POOLID_OFFSET;
+			if (backend_registered)
+				fs_poolid_map[i] =
+					(*cleancache_ops.init_fs)(PAGE_SIZE);
+			else
+				fs_poolid_map[i] = -1;
+			break;
+		}
+	}
 }
 EXPORT_SYMBOL(__cleancache_init_fs);
 
 /* Called by a cleancache-enabled clustered filesystem at time of mount */
 void __cleancache_init_shared_fs(char *uuid, struct super_block *sb)
 {
-	sb->cleancache_poolid =
-		(*cleancache_ops.init_shared_fs)(uuid, PAGE_SIZE);
+	int i;
+
+	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
+		if (shared_fs_poolid_map[i] == -2) {
+			sb->cleancache_poolid =
+				i + FAKE_SHARED_FS_POOLID_OFFSET;
+			uuids[i] = uuid;
+			if (backend_registered)
+				shared_fs_poolid_map[i] =
+					(*cleancache_ops.init_shared_fs)
+						(uuid, PAGE_SIZE);
+			else
+				shared_fs_poolid_map[i] = -1;
+			break;
+		}
+	}
 }
 EXPORT_SYMBOL(__cleancache_init_shared_fs);
 
@@ -101,6 +155,19 @@ static int cleancache_get_key(struct inode *inode,
 }
 
 /*
+ * Returns a pool_id that is associated with a given fake poolid.
+ */
+static int get_poolid_from_fake(int fake_pool_id)
+{
+	if (fake_pool_id >= FAKE_SHARED_FS_POOLID_OFFSET)
+		return shared_fs_poolid_map[fake_pool_id -
+			FAKE_SHARED_FS_POOLID_OFFSET];
+	else if (fake_pool_id >= FAKE_FS_POOLID_OFFSET)
+		return fs_poolid_map[fake_pool_id - FAKE_FS_POOLID_OFFSET];
+	return -1;
+}
+
+/*
  * "Get" data from cleancache associated with the poolid/inode/index
  * that were specified when the data was put to cleanache and, if
  * successful, use it to fill the specified page with data and return 0.
@@ -111,17 +178,26 @@ int __cleancache_get_page(struct page *page)
 {
 	int ret = -1;
 	int pool_id;
+	int fake_pool_id;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
+	if (!backend_registered) {
+		cleancache_failed_gets++;
+		goto out;
+	}
+
 	VM_BUG_ON(!PageLocked(page));
-	pool_id = page->mapping->host->i_sb->cleancache_poolid;
-	if (pool_id < 0)
+	fake_pool_id = page->mapping->host->i_sb->cleancache_poolid;
+	if (fake_pool_id < 0)
 		goto out;
+	pool_id = get_poolid_from_fake(fake_pool_id);
 
 	if (cleancache_get_key(page->mapping->host, &key) < 0)
 		goto out;
 
-	ret = (*cleancache_ops.get_page)(pool_id, key, page->index, page);
+	if (pool_id >= 0)
+		ret = (*cleancache_ops.get_page)(pool_id,
+				key, page->index, page);
 	if (ret == 0)
 		cleancache_succ_gets++;
 	else
@@ -140,12 +216,23 @@ EXPORT_SYMBOL(__cleancache_get_page);
 void __cleancache_put_page(struct page *page)
 {
 	int pool_id;
+	int fake_pool_id;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
+	if (!backend_registered) {
+		cleancache_puts++;
+		return;
+	}
+
 	VM_BUG_ON(!PageLocked(page));
-	pool_id = page->mapping->host->i_sb->cleancache_poolid;
+	fake_pool_id = page->mapping->host->i_sb->cleancache_poolid;
+	if (fake_pool_id < 0)
+		return;
+
+	pool_id = get_poolid_from_fake(fake_pool_id);
+
 	if (pool_id >= 0 &&
-	      cleancache_get_key(page->mapping->host, &key) >= 0) {
+		cleancache_get_key(page->mapping->host, &key) >= 0) {
 		(*cleancache_ops.put_page)(pool_id, key, page->index, page);
 		cleancache_puts++;
 	}
@@ -160,14 +247,22 @@ void __cleancache_invalidate_page(struct address_space *mapping,
 					struct page *page)
 {
 	/* careful... page->mapping is NULL sometimes when this is called */
-	int pool_id = mapping->host->i_sb->cleancache_poolid;
+	int pool_id;
+	int fake_pool_id = mapping->host->i_sb->cleancache_poolid;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (pool_id >= 0) {
+	if (!backend_registered)
+		return;
+
+	if (fake_pool_id >= 0) {
+		pool_id = get_poolid_from_fake(fake_pool_id);
+		if (pool_id < 0)
+			return;
+
 		VM_BUG_ON(!PageLocked(page));
 		if (cleancache_get_key(mapping->host, &key) >= 0) {
 			(*cleancache_ops.invalidate_page)(pool_id,
-							  key, page->index);
+					key, page->index);
 			cleancache_invalidates++;
 		}
 	}
@@ -181,9 +276,18 @@ EXPORT_SYMBOL(__cleancache_invalidate_page);
  */
 void __cleancache_invalidate_inode(struct address_space *mapping)
 {
-	int pool_id = mapping->host->i_sb->cleancache_poolid;
+	int pool_id;
+	int fake_pool_id = mapping->host->i_sb->cleancache_poolid;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
+	if (!backend_registered)
+		return;
+
+	if (fake_pool_id < 0)
+		return;
+
+	pool_id = get_poolid_from_fake(fake_pool_id);
+
 	if (pool_id >= 0 && cleancache_get_key(mapping->host, &key) >= 0)
 		(*cleancache_ops.invalidate_inode)(pool_id, key);
 }
@@ -196,16 +300,30 @@ EXPORT_SYMBOL(__cleancache_invalidate_inode);
  */
 void __cleancache_invalidate_fs(struct super_block *sb)
 {
-	if (sb->cleancache_poolid >= 0) {
-		int old_poolid = sb->cleancache_poolid;
-		sb->cleancache_poolid = -1;
-		(*cleancache_ops.invalidate_fs)(old_poolid);
+	int old_poolid;
+	int index;
+	int fake_pool_id = sb->cleancache_poolid;
+
+	if (fake_pool_id >= FAKE_SHARED_FS_POOLID_OFFSET) {
+		index = fake_pool_id - FAKE_SHARED_FS_POOLID_OFFSET;
+		old_poolid = shared_fs_poolid_map[index];
+		shared_fs_poolid_map[index] = -2;
+		uuids[index] = NULL;
+	} else if (fake_pool_id >= FAKE_FS_POOLID_OFFSET) {
+		index = fake_pool_id - FAKE_FS_POOLID_OFFSET;
+		old_poolid = fs_poolid_map[index];
+		fs_poolid_map[index] = -2;
 	}
+	sb->cleancache_poolid = -1;
+	if (backend_registered)
+		(*cleancache_ops.invalidate_fs)(old_poolid);
 }
 EXPORT_SYMBOL(__cleancache_invalidate_fs);
 
 static int __init init_cleancache(void)
 {
+	int i;
+
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *root = debugfs_create_dir("cleancache", NULL);
 	if (root == NULL)
@@ -217,6 +335,11 @@ static int __init init_cleancache(void)
 	debugfs_create_u64("invalidates", S_IRUGO,
 				root, &cleancache_invalidates);
 #endif
+	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
+		fs_poolid_map[i] = -2;
+		shared_fs_poolid_map[i] = -2;
+	}
+	cleancache_enabled = 1;
 	return 0;
 }
 module_init(init_cleancache)
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

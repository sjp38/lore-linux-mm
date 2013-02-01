Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id CC48D6B0028
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 15:23:34 -0500 (EST)
Received: by mail-ve0-f177.google.com with SMTP id m1so3238540ves.8
        for <linux-mm@kvack.org>; Fri, 01 Feb 2013 12:23:33 -0800 (PST)
From: Konrad Rzeszutek Wilk <konrad@kernel.org>
Subject: [PATCH 12/15] cleancache: Use static_key instead of cleancache_ops and cleancache_enabled.
Date: Fri,  1 Feb 2013 15:23:01 -0500
Message-Id: <1359750184-23408-13-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
References: <1359750184-23408-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

As ways to determine whether to allow certain functions to be
called.

This makes it easier to understand the code - the three functions
that can be called by the filesystem irregardless whether a backend is set or
not cleancache_init_fs, cleancache_init_shared_fs, and cleancache_invalidate_fs.

The rest of the cleancache functions end up being NOPs when the backend
has not yet registered.

Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 include/linux/cleancache.h | 16 +++++++++-----
 include/linux/frontswap.h  |  2 +-
 mm/cleancache.c            | 53 +++++++++++++++-------------------------------
 3 files changed, 29 insertions(+), 42 deletions(-)

diff --git a/include/linux/cleancache.h b/include/linux/cleancache.h
index dfa1ccb..09df0e4 100644
--- a/include/linux/cleancache.h
+++ b/include/linux/cleancache.h
@@ -42,9 +42,15 @@ extern void __cleancache_put_page(struct page *);
 extern void __cleancache_invalidate_page(struct address_space *, struct page *);
 extern void __cleancache_invalidate_inode(struct address_space *);
 extern void __cleancache_invalidate_fs(struct super_block *);
-extern int cleancache_enabled;
 
 #ifdef CONFIG_CLEANCACHE
+#include <linux/jump_label.h>
+extern struct static_key cleancache_key;
+
+static inline bool cleancache_enabled(void)
+{
+	return static_key_false(&cleancache_key);
+}
 static inline bool cleancache_fs_enabled(struct page *page)
 {
 	return page->mapping->host->i_sb->cleancache_poolid >= 0;
@@ -86,14 +92,14 @@ static inline int cleancache_get_page(struct page *page)
 {
 	int ret = -1;
 
-	if (cleancache_enabled && cleancache_fs_enabled(page))
+	if (cleancache_enabled() && cleancache_fs_enabled(page))
 		ret = __cleancache_get_page(page);
 	return ret;
 }
 
 static inline void cleancache_put_page(struct page *page)
 {
-	if (cleancache_enabled && cleancache_fs_enabled(page))
+	if (cleancache_enabled() && cleancache_fs_enabled(page))
 		__cleancache_put_page(page);
 }
 
@@ -101,13 +107,13 @@ static inline void cleancache_invalidate_page(struct address_space *mapping,
 					struct page *page)
 {
 	/* careful... page->mapping is NULL sometimes when this is called */
-	if (cleancache_enabled && cleancache_fs_enabled_mapping(mapping))
+	if (cleancache_enabled() && cleancache_fs_enabled_mapping(mapping))
 		__cleancache_invalidate_page(mapping, page);
 }
 
 static inline void cleancache_invalidate_inode(struct address_space *mapping)
 {
-	if (cleancache_enabled && cleancache_fs_enabled_mapping(mapping))
+	if (cleancache_enabled() && cleancache_fs_enabled_mapping(mapping))
 		__cleancache_invalidate_inode(mapping);
 }
 
diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 8d24167..612c176 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -113,7 +113,7 @@ static inline int frontswap_load(struct page *page)
 
 static inline void frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
-	if (frontswap_enabled)
+	if (static_key_false(&frontswap_key))
 		__frontswap_invalidate_page(type, offset);
 }
 
diff --git a/mm/cleancache.c b/mm/cleancache.c
index 5d8dbb9..de0b905 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -24,9 +24,17 @@
  * is not claimed (e.g. cleancache is config'ed on but remains
  * disabled), so is preferred to the slower alternative: a function
  * call that checks a non-global.
+ *
+ * When set to false (default) all calls to the cleancache functions, except
+ * the __cleancache_invalidate_fs and __cleancache_init_[shared|]fs are guarded
+ * by the if (cleancache_enabled()) return. This means multiple threads (from
+ * different filesystems) will be doing a NOP - b/c by default the
+ * cleancache_enabled() is returing false. The usage of a static_key allows
+ * us to patch up the code and allow the flood-gates to open when a backend
+ * has registered. Vice versa when unloading a backend.
  */
-int cleancache_enabled __read_mostly;
-EXPORT_SYMBOL(cleancache_enabled);
+struct static_key cleancache_key __read_mostly;
+EXPORT_SYMBOL(cleancache_key);
 
 /*
  * cleancache_ops is set by cleancache_ops_register to contain the pointers
@@ -70,18 +78,6 @@ static char *uuids[MAX_INITIALIZABLE_FS];
  */
 static DEFINE_MUTEX(poolid_mutex);
 /*
- * When set to false (default) all calls to the cleancache functions, except
- * the __cleancache_invalidate_fs and __cleancache_init_[shared|]fs are guarded
- * by the if (!cleancache_ops) return. This means multiple threads (from
- * different filesystems) will be checking cleancache_ops. The usage of a
- * bool instead of a atomic_t or a bool guarded by a spinlock is OK - we are
- * OK if the time between the backend's have been initialized (and
- * cleancache_ops has been set to not NULL) and when the filesystems start
- * actually calling the backends. The inverse (when unloading) is obviously
- * not good - but this shim does not do that (yet).
- */
-
-/*
  * The backends and filesystems work all asynchronously. This is b/c the
  * backends can be built as modules.
  * The usual sequence of events is:
@@ -89,13 +85,13 @@ static DEFINE_MUTEX(poolid_mutex);
  * 		[shared_|]fs_poolid_map and uuids for.
  *
  * 	b). user does I/Os -> we call the rest of __cleancache_* functions
- * 		which return immediately as cleancache_ops is NULL.
+ * 		which return immediately as cleancache_enabled() returns false.
  *
  * 	c). modprobe zcache -> cleancache_register_ops. We init the backend
  * 		and set cleancache_ops to the backend, and for any fs_poolid_map
  * 		(which is set by __cleancache_init_fs) we initialize the poolid.
  *
- * 	d). user does I/Os -> now that clean_ops is not NULL all the
+ * 	d). user does I/Os -> now that cleancache_enabled is turned to on, the
  * 		__cleancache_* functions can call the backend. They all check
  * 		that fs_poolid_map is valid and if so invoke the backend.
  *
@@ -111,8 +107,8 @@ static DEFINE_MUTEX(poolid_mutex);
  * of unmounting process).
  *
  * Note: The acute reader will notice that there is no "rmmod zcache" case.
- * This is b/c the functionality for that is not yet implemented and when
- * done, will require some extra locking not yet devised.
+ * This is b/c the functionality for that is not yet implemented in the
+ * backend. In here, it will require turning the cleancache_key off.
  */
 
 /*
@@ -139,6 +135,8 @@ struct cleancache_ops *cleancache_register_ops(struct cleancache_ops *ops)
 	 */
 	barrier();
 	cleancache_ops = ops;
+	if (!static_key_enabled(&cleancache_key))
+		static_key_slow_inc(&cleancache_key);
 	mutex_unlock(&poolid_mutex);
 	return old;
 }
@@ -242,11 +240,6 @@ int __cleancache_get_page(struct page *page)
 	int fake_pool_id;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!cleancache_ops) {
-		cleancache_failed_gets++;
-		goto out;
-	}
-
 	VM_BUG_ON(!PageLocked(page));
 	fake_pool_id = page->mapping->host->i_sb->cleancache_poolid;
 	if (fake_pool_id < 0)
@@ -284,11 +277,6 @@ void __cleancache_put_page(struct page *page)
 	int fake_pool_id;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!cleancache_ops) {
-		cleancache_puts++;
-		return;
-	}
-
 	VM_BUG_ON(!PageLocked(page));
 	fake_pool_id = page->mapping->host->i_sb->cleancache_poolid;
 	if (fake_pool_id < 0)
@@ -320,9 +308,6 @@ void __cleancache_invalidate_page(struct address_space *mapping,
 	int fake_pool_id = mapping->host->i_sb->cleancache_poolid;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!cleancache_ops)
-		return;
-
 	if (fake_pool_id >= 0) {
 		pool_id = get_poolid_from_fake(fake_pool_id);
 		if (pool_id < 0)
@@ -353,9 +338,6 @@ void __cleancache_invalidate_inode(struct address_space *mapping)
 	int fake_pool_id = mapping->host->i_sb->cleancache_poolid;
 	struct cleancache_filekey key = { .u.key = { 0 } };
 
-	if (!cleancache_ops)
-		return;
-
 	if (fake_pool_id < 0)
 		return;
 
@@ -389,7 +371,7 @@ void __cleancache_invalidate_fs(struct super_block *sb)
 		fs_poolid_map[index] = FS_UNKNOWN;
 	}
 	sb->cleancache_poolid = -1;
-	if (cleancache_ops)
+	if (cleancache_enabled())
 		cleancache_ops->invalidate_fs(old_poolid);
 	mutex_unlock(&poolid_mutex);
 }
@@ -414,7 +396,6 @@ static int __init init_cleancache(void)
 		fs_poolid_map[i] = FS_UNKNOWN;
 		shared_fs_poolid_map[i] = FS_UNKNOWN;
 	}
-	cleancache_enabled = 1;
 	return 0;
 }
 module_init(init_cleancache)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

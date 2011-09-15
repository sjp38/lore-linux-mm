Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1AE9000BD
	for <linux-mm@kvack.org>; Thu, 15 Sep 2011 17:35:07 -0400 (EDT)
Date: Thu, 15 Sep 2011 14:34:46 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V10 5/6] mm: cleancache: update to match akpm frontswap
	feedback
Message-ID: <20110915213446.GA26406@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V10 5/6] mm: cleancache: update to match akpm frontswap feedback

This is the fifth patch of six in the frontswap series; changes made to
frontswap due to feedback from akpm/others must also be made to cleancache
for consistency.  These are: (1) change sysfs to debugfs; (2) change
use of the term "flush" to "invalidate".  Note that some changes
for (2) are deferred to the next patch in this patchset in order to
coordinate with simultaneous required driver changes.

[v10: no change]
[v9: akpm@linux-foundation.org: sysfs->debugfs; no longer need Doc/ABI file]
[v9: akpm@linux-foundation.org: change "flush" to "invalidate", part 2]

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
Cc: Jan Beulich <JBeulich@novell.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Matthew Wilcox <matthew@wil.cx>
Cc: Chris Mason <chris.mason@oracle.com>
Cc: Rik Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

--- linux/mm/cleancache.c	2011-07-20 14:50:42.366996604 -0600
+++ frontswap-v10/mm/cleancache.c	2011-09-15 14:53:40.965694004 -0600
@@ -15,29 +15,34 @@
 #include <linux/fs.h>
 #include <linux/exportfs.h>
 #include <linux/mm.h>
+#include <linux/debugfs.h>
 #include <linux/cleancache.h>
 
 /*
  * This global enablement flag may be read thousands of times per second
- * by cleancache_get/put/flush even on systems where cleancache_ops
+ * by cleancache_get/put/invalidate even on systems where cleancache_ops
  * is not claimed (e.g. cleancache is config'ed on but remains
  * disabled), so is preferred to the slower alternative: a function
  * call that checks a non-global.
  */
-int cleancache_enabled;
+int cleancache_enabled __read_mostly;
 EXPORT_SYMBOL(cleancache_enabled);
 
 /*
  * cleancache_ops is set by cleancache_ops_register to contain the pointers
  * to the cleancache "backend" implementation functions.
  */
-static struct cleancache_ops cleancache_ops;
+static struct cleancache_ops cleancache_ops __read_mostly;
 
-/* useful stats available in /sys/kernel/mm/cleancache */
-static unsigned long cleancache_succ_gets;
-static unsigned long cleancache_failed_gets;
-static unsigned long cleancache_puts;
-static unsigned long cleancache_flushes;
+/*
+ * Counters available via /sys/kernel/debug/frontswap (if debugfs is
+ * properly configured.  These are for information only so are not protected
+ * against increment races.
+ */
+static u64 cleancache_succ_gets;
+static u64 cleancache_failed_gets;
+static u64 cleancache_puts;
+static u64 cleancache_invalidates;
 
 /*
  * register operations for cleancache, returning previous thus allowing
@@ -148,10 +153,11 @@ void __cleancache_put_page(struct page *
 EXPORT_SYMBOL(__cleancache_put_page);
 
 /*
- * Flush any data from cleancache associated with the poolid and the
+ * Invalidate any data from cleancache associated with the poolid and the
  * page's inode and page index so that a subsequent "get" will fail.
  */
-void __cleancache_flush_page(struct address_space *mapping, struct page *page)
+void __cleancache_invalidate_page(struct address_space *mapping,
+					struct page *page)
 {
 	/* careful... page->mapping is NULL sometimes when this is called */
 	int pool_id = mapping->host->i_sb->cleancache_poolid;
@@ -161,18 +167,18 @@ void __cleancache_flush_page(struct addr
 		VM_BUG_ON(!PageLocked(page));
 		if (cleancache_get_key(mapping->host, &key) >= 0) {
 			(*cleancache_ops.flush_page)(pool_id, key, page->index);
-			cleancache_flushes++;
+			cleancache_invalidates++;
 		}
 	}
 }
-EXPORT_SYMBOL(__cleancache_flush_page);
+EXPORT_SYMBOL(__cleancache_invalidate_page);
 
 /*
- * Flush all data from cleancache associated with the poolid and the
+ * Invalidate all data from cleancache associated with the poolid and the
  * mappings's inode so that all subsequent gets to this poolid/inode
  * will fail.
  */
-void __cleancache_flush_inode(struct address_space *mapping)
+void __cleancache_invalidate_inode(struct address_space *mapping)
 {
 	int pool_id = mapping->host->i_sb->cleancache_poolid;
 	struct cleancache_filekey key = { .u.key = { 0 } };
@@ -180,14 +186,14 @@ void __cleancache_flush_inode(struct add
 	if (pool_id >= 0 && cleancache_get_key(mapping->host, &key) >= 0)
 		(*cleancache_ops.flush_inode)(pool_id, key);
 }
-EXPORT_SYMBOL(__cleancache_flush_inode);
+EXPORT_SYMBOL(__cleancache_invalidate_inode);
 
 /*
  * Called by any cleancache-enabled filesystem at time of unmount;
  * note that pool_id is surrendered and may be reutrned by a subsequent
  * cleancache_init_fs or cleancache_init_shared_fs
  */
-void __cleancache_flush_fs(struct super_block *sb)
+void __cleancache_invalidate_fs(struct super_block *sb)
 {
 	if (sb->cleancache_poolid >= 0) {
 		int old_poolid = sb->cleancache_poolid;
@@ -195,50 +201,21 @@ void __cleancache_flush_fs(struct super_
 		(*cleancache_ops.flush_fs)(old_poolid);
 	}
 }
-EXPORT_SYMBOL(__cleancache_flush_fs);
-
-#ifdef CONFIG_SYSFS
-
-/* see Documentation/ABI/xxx/sysfs-kernel-mm-cleancache */
-
-#define CLEANCACHE_SYSFS_RO(_name) \
-	static ssize_t cleancache_##_name##_show(struct kobject *kobj, \
-				struct kobj_attribute *attr, char *buf) \
-	{ \
-		return sprintf(buf, "%lu\n", cleancache_##_name); \
-	} \
-	static struct kobj_attribute cleancache_##_name##_attr = { \
-		.attr = { .name = __stringify(_name), .mode = 0444 }, \
-		.show = cleancache_##_name##_show, \
-	}
-
-CLEANCACHE_SYSFS_RO(succ_gets);
-CLEANCACHE_SYSFS_RO(failed_gets);
-CLEANCACHE_SYSFS_RO(puts);
-CLEANCACHE_SYSFS_RO(flushes);
-
-static struct attribute *cleancache_attrs[] = {
-	&cleancache_succ_gets_attr.attr,
-	&cleancache_failed_gets_attr.attr,
-	&cleancache_puts_attr.attr,
-	&cleancache_flushes_attr.attr,
-	NULL,
-};
-
-static struct attribute_group cleancache_attr_group = {
-	.attrs = cleancache_attrs,
-	.name = "cleancache",
-};
-
-#endif /* CONFIG_SYSFS */
+EXPORT_SYMBOL(__cleancache_invalidate_fs);
 
 static int __init init_cleancache(void)
 {
-#ifdef CONFIG_SYSFS
-	int err;
-
-	err = sysfs_create_group(mm_kobj, &cleancache_attr_group);
-#endif /* CONFIG_SYSFS */
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *root = debugfs_create_dir("cleancache", NULL);
+	if (root == NULL)
+		return -ENXIO;
+	debugfs_create_u64("succ_gets", S_IRUGO, root, &cleancache_succ_gets);
+	debugfs_create_u64("failed_gets", S_IRUGO,
+				root, &cleancache_failed_gets);
+	debugfs_create_u64("puts", S_IRUGO, root, &cleancache_puts);
+	debugfs_create_u64("invalidates", S_IRUGO,
+				root, &cleancache_invalidates);
+#endif
 	return 0;
 }
 module_init(init_cleancache)
--- linux/include/linux/cleancache.h	2011-07-20 14:50:38.986877289 -0600
+++ frontswap-v10/include/linux/cleancache.h	2011-09-15 11:40:53.584807479 -0600
@@ -28,6 +28,11 @@ struct cleancache_ops {
 			pgoff_t, struct page *);
 	void (*put_page)(int, struct cleancache_filekey,
 			pgoff_t, struct page *);
+	/*
+	 * NOTE: per akpm, flush_page, flush_inode and flush_fs will be
+	 * renamed to invalidate_* in a later commit in which all
+	 * dependencies (i.e Xen, zcache) will be renamed simultaneously
+	 */
 	void (*flush_page)(int, struct cleancache_filekey, pgoff_t);
 	void (*flush_inode)(int, struct cleancache_filekey);
 	void (*flush_fs)(int);
@@ -39,9 +44,9 @@ extern void __cleancache_init_fs(struct 
 extern void __cleancache_init_shared_fs(char *, struct super_block *);
 extern int  __cleancache_get_page(struct page *);
 extern void __cleancache_put_page(struct page *);
-extern void __cleancache_flush_page(struct address_space *, struct page *);
-extern void __cleancache_flush_inode(struct address_space *);
-extern void __cleancache_flush_fs(struct super_block *);
+extern void __cleancache_invalidate_page(struct address_space *, struct page *);
+extern void __cleancache_invalidate_inode(struct address_space *);
+extern void __cleancache_invalidate_fs(struct super_block *);
 extern int cleancache_enabled;
 
 #ifdef CONFIG_CLEANCACHE
@@ -99,24 +104,24 @@ static inline void cleancache_put_page(s
 		__cleancache_put_page(page);
 }
 
-static inline void cleancache_flush_page(struct address_space *mapping,
+static inline void cleancache_invalidate_page(struct address_space *mapping,
 					struct page *page)
 {
 	/* careful... page->mapping is NULL sometimes when this is called */
 	if (cleancache_enabled && cleancache_fs_enabled_mapping(mapping))
-		__cleancache_flush_page(mapping, page);
+		__cleancache_invalidate_page(mapping, page);
 }
 
-static inline void cleancache_flush_inode(struct address_space *mapping)
+static inline void cleancache_invalidate_inode(struct address_space *mapping)
 {
 	if (cleancache_enabled && cleancache_fs_enabled_mapping(mapping))
-		__cleancache_flush_inode(mapping);
+		__cleancache_invalidate_inode(mapping);
 }
 
-static inline void cleancache_flush_fs(struct super_block *sb)
+static inline void cleancache_invalidate_fs(struct super_block *sb)
 {
 	if (cleancache_enabled)
-		__cleancache_flush_fs(sb);
+		__cleancache_invalidate_fs(sb);
 }
 
 #endif /* _LINUX_CLEANCACHE_H */
--- linux/fs/buffer.c	2011-07-20 14:50:37.505748163 -0600
+++ frontswap-v10/fs/buffer.c	2011-09-15 11:40:53.555688588 -0600
@@ -273,7 +273,7 @@ void invalidate_bdev(struct block_device
 	/* 99% of the time, we don't need to flush the cleancache on the bdev.
 	 * But, for the strange corners, lets be cautious
 	 */
-	cleancache_flush_inode(mapping);
+	cleancache_invalidate_inode(mapping);
 }
 EXPORT_SYMBOL(invalidate_bdev);
 
--- linux/fs/super.c	2011-08-08 08:19:25.338811404 -0600
+++ frontswap-v10/fs/super.c	2011-09-15 11:40:53.584007814 -0600
@@ -248,7 +248,7 @@ void deactivate_locked_super(struct supe
 {
 	struct file_system_type *fs = s->s_type;
 	if (atomic_dec_and_test(&s->s_active)) {
-		cleancache_flush_fs(s);
+		cleancache_invalidate_fs(s);
 		fs->kill_sb(s);
 
 		/* caches are now gone, we can safely kill the shrinker now */
--- linux/mm/truncate.c	2011-08-08 08:19:26.337689640 -0600
+++ frontswap-v10/mm/truncate.c	2011-09-15 11:40:53.626807311 -0600
@@ -52,7 +52,7 @@ void do_invalidatepage(struct page *page
 static inline void truncate_partial_page(struct page *page, unsigned partial)
 {
 	zero_user_segment(page, partial, PAGE_CACHE_SIZE);
-	cleancache_flush_page(page->mapping, page);
+	cleancache_invalidate_page(page->mapping, page);
 	if (page_has_private(page))
 		do_invalidatepage(page, partial);
 }
@@ -213,7 +213,7 @@ void truncate_inode_pages_range(struct a
 	pgoff_t end;
 	int i;
 
-	cleancache_flush_inode(mapping);
+	cleancache_invalidate_inode(mapping);
 	if (mapping->nrpages == 0)
 		return;
 
@@ -292,7 +292,7 @@ void truncate_inode_pages_range(struct a
 		mem_cgroup_uncharge_end();
 		index++;
 	}
-	cleancache_flush_inode(mapping);
+	cleancache_invalidate_inode(mapping);
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
 
@@ -444,7 +444,7 @@ int invalidate_inode_pages2_range(struct
 	int ret2 = 0;
 	int did_range_unmap = 0;
 
-	cleancache_flush_inode(mapping);
+	cleancache_invalidate_inode(mapping);
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index <= end && pagevec_lookup(&pvec, mapping, index,
@@ -500,7 +500,7 @@ int invalidate_inode_pages2_range(struct
 		cond_resched();
 		index++;
 	}
-	cleancache_flush_inode(mapping);
+	cleancache_invalidate_inode(mapping);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(invalidate_inode_pages2_range);
--- linux/mm/filemap.c	2011-09-15 09:43:02.660686843 -0600
+++ frontswap-v10/mm/filemap.c	2011-09-15 11:40:53.620798857 -0600
@@ -123,7 +123,7 @@ void __delete_from_page_cache(struct pag
 	if (PageUptodate(page) && PageMappedToDisk(page))
 		cleancache_put_page(page);
 	else
-		cleancache_flush_page(mapping, page);
+		cleancache_invalidate_page(mapping, page);
 
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
--- linux/Documentation/vm/cleancache.txt	2011-07-20 14:50:17.030148717 -0600
+++ frontswap-v10/Documentation/vm/cleancache.txt	2011-09-15 11:40:53.534913824 -0600
@@ -46,10 +46,11 @@ a negative return value indicates failur
 the pool id, a file key, and a page index into the file.  (The combination
 of a pool id, a file key, and an index is sometimes called a "handle".)
 A "get_page" will copy the page, if found, from cleancache into kernel memory.
-A "flush_page" will ensure the page no longer is present in cleancache;
-a "flush_inode" will flush all pages associated with the specified file;
-and, when a filesystem is unmounted, a "flush_fs" will flush all pages in
-all files specified by the given pool id and also surrender the pool id.
+An "invalidate_page" will ensure the page no longer is present in cleancache;
+an "invalidate_inode" will invalidate all pages associated with the specified
+file; and, when a filesystem is unmounted, an "invalidate_fs" will invalidate
+all pages in all files specified by the given pool id and also surrender
+the pool id.
 
 An "init_shared_fs", like init_fs, obtains a pool id but tells cleancache
 to treat the pool as shared using a 128-bit UUID as a key.  On systems
@@ -62,12 +63,12 @@ of the kernel (e.g. by "tools" that cont
 cleancache implementation can simply disable shared_init by always
 returning a negative value.
 
-If a get_page is successful on a non-shared pool, the page is flushed (thus
-making cleancache an "exclusive" cache).  On a shared pool, the page
-is NOT flushed on a successful get_page so that it remains accessible to
+If a get_page is successful on a non-shared pool, the page is invalidated
+(thus making cleancache an "exclusive" cache).  On a shared pool, the page
+is NOT invalidated on a successful get_page so that it remains accessible to
 other sharers.  The kernel is responsible for ensuring coherency between
 cleancache (shared or not), the page cache, and the filesystem, using
-cleancache flush operations as required.
+cleancache invalidate operations as required.
 
 Note that cleancache must enforce put-put-get coherency and get-get
 coherency.  For the former, if two puts are made to the same handle but
@@ -77,20 +78,20 @@ if a get for a given handle fails, subse
 never succeed unless preceded by a successful put with that handle.
 
 Last, cleancache provides no SMP serialization guarantees; if two
-different Linux threads are simultaneously putting and flushing a page
+different Linux threads are simultaneously putting and invalidating a page
 with the same handle, the results are indeterminate.  Callers must
 lock the page to ensure serial behavior.
 
 CLEANCACHE PERFORMANCE METRICS
 
-Cleancache monitoring is done by sysfs files in the
-/sys/kernel/mm/cleancache directory.  The effectiveness of cleancache
+If properly configured, monitoring of cleancache is done via debugfs in
+the /sys/kernel/debug/cleancache directory.  The effectiveness of cleancache
 can be measured (across all filesystems) with:
 
 succ_gets	- number of gets that were successful
 failed_gets	- number of gets that failed
 puts		- number of puts attempted (all "succeed")
-flushes		- number of flushes attempted
+invalidates	- number of invalidates attempted
 
 A backend implementatation may provide additional metrics.
 
@@ -143,7 +144,7 @@ systems.
 
 The core hooks for cleancache in VFS are in most cases a single line
 and the minimum set are placed precisely where needed to maintain
-coherency (via cleancache_flush operations) between cleancache,
+coherency (via cleancache_invalidate operations) between cleancache,
 the page cache, and disk.  All hooks compile into nothingness if
 cleancache is config'ed off and turn into a function-pointer-
 compare-to-NULL if config'ed on but no backend claims the ops
@@ -184,15 +185,15 @@ or for real kernel-addressable RAM, it m
 transcendent memory.
 
 4) Why is non-shared cleancache "exclusive"?  And where is the
-   page "flushed" after a "get"? (Minchan Kim)
+   page "invalidated" after a "get"? (Minchan Kim)
 
 The main reason is to free up space in transcendent memory and
-to avoid unnecessary cleancache_flush calls.  If you want inclusive,
+to avoid unnecessary cleancache_invalidate calls.  If you want inclusive,
 the page can be "put" immediately following the "get".  If
 put-after-get for inclusive becomes common, the interface could
-be easily extended to add a "get_no_flush" call.
+be easily extended to add a "get_no_invalidate" call.
 
-The flush is done by the cleancache backend implementation.
+The invalidate is done by the cleancache backend implementation.
 
 5) What's the performance impact?
 
@@ -222,7 +223,7 @@ Some points for a filesystem to consider
   as tmpfs should not enable cleancache)
 - To ensure coherency/correctness, the FS must ensure that all
   file removal or truncation operations either go through VFS or
-  add hooks to do the equivalent cleancache "flush" operations
+  add hooks to do the equivalent cleancache "invalidate" operations
 - To ensure coherency/correctness, either inode numbers must
   be unique across the lifetime of the on-disk file OR the
   FS must provide an "encode_fh" function.
@@ -243,11 +244,11 @@ If cleancache would use the inode virtua
 inode/filehandle, the pool id could be eliminated.  But, this
 won't work because cleancache retains pagecache data pages
 persistently even when the inode has been pruned from the
-inode unused list, and only flushes the data page if the file
+inode unused list, and only invalidates the data page if the file
 gets removed/truncated.  So if cleancache used the inode kva,
 there would be potential coherency issues if/when the inode
 kva is reused for a different file.  Alternately, if cleancache
-flushed the pages when the inode kva was freed, much of the value
+invalidated the pages when the inode kva was freed, much of the value
 of cleancache would be lost because the cache of pages in cleanache
 is potentially much larger than the kernel pagecache and is most
 useful if the pages survive inode cache removal.
--- linux/Documentation/ABI/testing/sysfs-kernel-mm-cleancache	2011-07-20 14:50:16.384143559 -0600
+++ frontswap-v10/Documentation/ABI/testing/sysfs-kernel-mm-cleancache	1969-12-31 17:00:00.000000000 -0700
@@ -1,11 +0,0 @@
-What:		/sys/kernel/mm/cleancache/
-Date:		April 2011
-Contact:	Dan Magenheimer <dan.magenheimer@oracle.com>
-Description:
-		/sys/kernel/mm/cleancache/ contains a number of files which
-		record a count of various cleancache operations
-		(sum across all filesystems):
-			succ_gets
-			failed_gets
-			puts
-			flushes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A683900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:19:10 -0400 (EDT)
Date: Thu, 14 Apr 2011 14:17:02 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V8 3/8] mm: cleancache core ops functions and config
Message-ID: <20110414211701.GA27742@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger.kernel@dilger.ca, tytso@mit.edu, mfasheh@suse.com, jlbec@evilplan.org, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, hch@infradead.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, torvalds@linux-foundation.org

[PATCH V8 3/8] mm: cleancache core ops functions and config

This third patch of eight in this cleancache series provides
the core code for cleancache that interfaces between the hooks in
VFS and individual filesystems and a cleancache backend.  It also
includes build and config patches.

Two new files are added: mm/cleancache.c and include/linux/cleancache.h.

Note that CONFIG_CLEANCACHE defaults to on; in systems that do
not provide a cleancache backend, all hooks devolve to a simple
check of a global enable flag, so performance impact should
be negligible but can be reduced to zero impact if config'ed off.

Details and a FAQ can be found in Documentation/vm/cleancache.txt

Credits: Cleancache_ops design derived from Jeremy Fitzhardinge
design for tmem

[v8: dan.magenheimer@oracle.com: fix exportfs call affecting btrfs]
[v8: akpm@linux-foundation.org: use static inline function, not macro]
[v7: dan.magenheimer@oracle.com: cleanup sysfs and remove cleancache prefix]
[v6: JBeulich@novell.com: robustly handle buggy fs encode_fh actor definition]
[v5: jeremy@goop.org: clean up global usage and static var names]
[v5: jeremy@goop.org: simplify init hook and any future fs init changes]
[v5: hch@infradead.org: cleaner non-global interface for ops registration]
[v4: adilger@sun.com: interface must support exportfs FS's]
[v4: hch@infradead.org: interface must support 64-bit FS on 32-bit kernel]
[v3: akpm@linux-foundation.org: use one ops struct to avoid pointer hops]
[v3: akpm@linux-foundation.org: document and ensure PageLocked reqts are met]
[v3: ngupta@vflare.org: fix success/fail codes, change funcs to void]
[v2: viro@ZenIV.linux.org.uk: use sane types]
Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Jeremy Fitzhardinge <jeremy@goop.org>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Acked-by: Al Viro <viro@ZenIV.linux.org.uk>
Acked-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Nitin Gupta <ngupta@vflare.org>
Acked-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Andreas Dilger <adilger@sun.com>
Acked-by: Jan Beulich <JBeulich@novell.com>
Cc: Matthew Wilcox <matthew@wil.cx>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Rik Van Riel <riel@redhat.com>
Cc: Chris Mason <chris.mason@oracle.com>
Cc: Ted Ts'o <tytso@mit.edu>
Cc: Mark Fasheh <mfasheh@suse.com>
Cc: Joel Becker <joel.becker@oracle.com>

---

Diffstat:
 include/linux/cleancache.h               |  122 ++++++++++
 mm/Kconfig                               |   23 +
 mm/Makefile                              |    1 
 mm/cleancache.c                          |  244 +++++++++++++++++++++
 4 files changed, 390 insertions(+)

--- linux-2.6.39-rc3/include/linux/cleancache.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.39-rc3-cleancache/include/linux/cleancache.h	2011-04-13 16:59:42.029957587 -0600
@@ -0,0 +1,122 @@
+#ifndef _LINUX_CLEANCACHE_H
+#define _LINUX_CLEANCACHE_H
+
+#include <linux/fs.h>
+#include <linux/exportfs.h>
+#include <linux/mm.h>
+
+#define CLEANCACHE_KEY_MAX 6
+
+/*
+ * cleancache requires every file with a page in cleancache to have a
+ * unique key unless/until the file is removed/truncated.  For some
+ * filesystems, the inode number is unique, but for "modern" filesystems
+ * an exportable filehandle is required (see exportfs.h)
+ */
+struct cleancache_filekey {
+	union {
+		ino_t ino;
+		__u32 fh[CLEANCACHE_KEY_MAX];
+		u32 key[CLEANCACHE_KEY_MAX];
+	} u;
+};
+
+struct cleancache_ops {
+	int (*init_fs)(size_t);
+	int (*init_shared_fs)(char *uuid, size_t);
+	int (*get_page)(int, struct cleancache_filekey,
+			pgoff_t, struct page *);
+	void (*put_page)(int, struct cleancache_filekey,
+			pgoff_t, struct page *);
+	void (*flush_page)(int, struct cleancache_filekey, pgoff_t);
+	void (*flush_inode)(int, struct cleancache_filekey);
+	void (*flush_fs)(int);
+};
+
+extern struct cleancache_ops
+	cleancache_register_ops(struct cleancache_ops *ops);
+extern void __cleancache_init_fs(struct super_block *);
+extern void __cleancache_init_shared_fs(char *, struct super_block *);
+extern int  __cleancache_get_page(struct page *);
+extern void __cleancache_put_page(struct page *);
+extern void __cleancache_flush_page(struct address_space *, struct page *);
+extern void __cleancache_flush_inode(struct address_space *);
+extern void __cleancache_flush_fs(struct super_block *);
+extern int cleancache_enabled;
+
+#ifdef CONFIG_CLEANCACHE
+static inline bool cleancache_fs_enabled(struct page *page)
+{
+	return page->mapping->host->i_sb->cleancache_poolid >= 0;
+}
+static inline bool cleancache_fs_enabled_mapping(struct address_space *mapping)
+{
+	return mapping->host->i_sb->cleancache_poolid >= 0;
+}
+#else
+#define cleancache_enabled (0)
+#define cleancache_fs_enabled(_page) (0)
+#define cleancache_fs_enabled_mapping(_page) (0)
+#endif
+
+/*
+ * The shim layer provided by these inline functions allows the compiler
+ * to reduce all cleancache hooks to nothingness if CONFIG_CLEANCACHE
+ * is disabled, to a single global variable check if CONFIG_CLEANCACHE
+ * is enabled but no cleancache "backend" has dynamically enabled it,
+ * and, for the most frequent cleancache ops, to a single global variable
+ * check plus a superblock element comparison if CONFIG_CLEANCACHE is enabled
+ * and a cleancache backend has dynamically enabled cleancache, but the
+ * filesystem referenced by that cleancache op has not enabled cleancache.
+ * As a result, CONFIG_CLEANCACHE can be enabled by default with essentially
+ * no measurable performance impact.
+ */
+
+static inline void cleancache_init_fs(struct super_block *sb)
+{
+	if (cleancache_enabled)
+		__cleancache_init_fs(sb);
+}
+
+static inline void cleancache_init_shared_fs(char *uuid, struct super_block *sb)
+{
+	if (cleancache_enabled)
+		__cleancache_init_shared_fs(uuid, sb);
+}
+
+static inline int cleancache_get_page(struct page *page)
+{
+	int ret = -1;
+
+	if (cleancache_enabled && cleancache_fs_enabled(page))
+		ret = __cleancache_get_page(page);
+	return ret;
+}
+
+static inline void cleancache_put_page(struct page *page)
+{
+	if (cleancache_enabled && cleancache_fs_enabled(page))
+		__cleancache_put_page(page);
+}
+
+static inline void cleancache_flush_page(struct address_space *mapping,
+					struct page *page)
+{
+	/* careful... page->mapping is NULL sometimes when this is called */
+	if (cleancache_enabled && cleancache_fs_enabled_mapping(mapping))
+		__cleancache_flush_page(mapping, page);
+}
+
+static inline void cleancache_flush_inode(struct address_space *mapping)
+{
+	if (cleancache_enabled && cleancache_fs_enabled_mapping(mapping))
+		__cleancache_flush_inode(mapping);
+}
+
+static inline void cleancache_flush_fs(struct super_block *sb)
+{
+	if (cleancache_enabled)
+		__cleancache_flush_fs(sb);
+}
+
+#endif /* _LINUX_CLEANCACHE_H */
--- linux-2.6.39-rc3/mm/cleancache.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.39-rc3-cleancache/mm/cleancache.c	2011-04-13 17:05:05.759132563 -0600
@@ -0,0 +1,244 @@
+/*
+ * Cleancache frontend
+ *
+ * This code provides the generic "frontend" layer to call a matching
+ * "backend" driver implementation of cleancache.  See
+ * Documentation/vm/cleancache.txt for more information.
+ *
+ * Copyright (C) 2009-2010 Oracle Corp. All rights reserved.
+ * Author: Dan Magenheimer
+ *
+ * This work is licensed under the terms of the GNU GPL, version 2.
+ */
+
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/exportfs.h>
+#include <linux/mm.h>
+#include <linux/cleancache.h>
+
+/*
+ * This global enablement flag may be read thousands of times per second
+ * by cleancache_get/put/flush even on systems where cleancache_ops
+ * is not claimed (e.g. cleancache is config'ed on but remains
+ * disabled), so is preferred to the slower alternative: a function
+ * call that checks a non-global.
+ */
+int cleancache_enabled;
+EXPORT_SYMBOL(cleancache_enabled);
+
+/*
+ * cleancache_ops is set by cleancache_ops_register to contain the pointers
+ * to the cleancache "backend" implementation functions.
+ */
+static struct cleancache_ops cleancache_ops;
+
+/* useful stats available in /sys/kernel/mm/cleancache */
+static unsigned long cleancache_succ_gets;
+static unsigned long cleancache_failed_gets;
+static unsigned long cleancache_puts;
+static unsigned long cleancache_flushes;
+
+/*
+ * register operations for cleancache, returning previous thus allowing
+ * detection of multiple backends and possible nesting
+ */
+struct cleancache_ops cleancache_register_ops(struct cleancache_ops *ops)
+{
+	struct cleancache_ops old = cleancache_ops;
+
+	cleancache_ops = *ops;
+	cleancache_enabled = 1;
+	return old;
+}
+EXPORT_SYMBOL(cleancache_register_ops);
+
+/* Called by a cleancache-enabled filesystem at time of mount */
+void __cleancache_init_fs(struct super_block *sb)
+{
+	sb->cleancache_poolid = (*cleancache_ops.init_fs)(PAGE_SIZE);
+}
+EXPORT_SYMBOL(__cleancache_init_fs);
+
+/* Called by a cleancache-enabled clustered filesystem at time of mount */
+void __cleancache_init_shared_fs(char *uuid, struct super_block *sb)
+{
+	sb->cleancache_poolid =
+		(*cleancache_ops.init_shared_fs)(uuid, PAGE_SIZE);
+}
+EXPORT_SYMBOL(__cleancache_init_shared_fs);
+
+/*
+ * If the filesystem uses exportable filehandles, use the filehandle as
+ * the key, else use the inode number.
+ */
+static int cleancache_get_key(struct inode *inode,
+			      struct cleancache_filekey *key)
+{
+	int (*fhfn)(struct dentry *, __u32 *fh, int *, int);
+	int len = 0, maxlen = CLEANCACHE_KEY_MAX;
+	struct super_block *sb = inode->i_sb;
+
+	key->u.ino = inode->i_ino;
+	if (sb->s_export_op != NULL) {
+		fhfn = sb->s_export_op->encode_fh;
+		if  (fhfn) {
+			struct dentry d;
+			d.d_inode = inode;
+			len = (*fhfn)(&d, &key->u.fh[0], &maxlen, 0);
+			if (len <= 0 || len == 255)
+				return -1;
+			if (maxlen > CLEANCACHE_KEY_MAX)
+				return -1;
+		}
+	}
+	return 0;
+}
+
+/*
+ * "Get" data from cleancache associated with the poolid/inode/index
+ * that were specified when the data was put to cleanache and, if
+ * successful, use it to fill the specified page with data and return 0.
+ * The pageframe is unchanged and returns -1 if the get fails.
+ * Page must be locked by caller.
+ */
+int __cleancache_get_page(struct page *page)
+{
+	int ret = -1;
+	int pool_id;
+	struct cleancache_filekey key = { .u.key = { 0 } };
+
+	VM_BUG_ON(!PageLocked(page));
+	pool_id = page->mapping->host->i_sb->cleancache_poolid;
+	if (pool_id < 0)
+		goto out;
+
+	if (cleancache_get_key(page->mapping->host, &key) < 0)
+		goto out;
+
+	ret = (*cleancache_ops.get_page)(pool_id, key, page->index, page);
+	if (ret == 0)
+		cleancache_succ_gets++;
+	else
+		cleancache_failed_gets++;
+out:
+	return ret;
+}
+EXPORT_SYMBOL(__cleancache_get_page);
+
+/*
+ * "Put" data from a page to cleancache and associate it with the
+ * (previously-obtained per-filesystem) poolid and the page's,
+ * inode and page index.  Page must be locked.  Note that a put_page
+ * always "succeeds", though a subsequent get_page may succeed or fail.
+ */
+void __cleancache_put_page(struct page *page)
+{
+	int pool_id;
+	struct cleancache_filekey key = { .u.key = { 0 } };
+
+	VM_BUG_ON(!PageLocked(page));
+	pool_id = page->mapping->host->i_sb->cleancache_poolid;
+	if (pool_id >= 0 &&
+	      cleancache_get_key(page->mapping->host, &key) >= 0) {
+		(*cleancache_ops.put_page)(pool_id, key, page->index, page);
+		cleancache_puts++;
+	}
+}
+EXPORT_SYMBOL(__cleancache_put_page);
+
+/*
+ * Flush any data from cleancache associated with the poolid and the
+ * page's inode and page index so that a subsequent "get" will fail.
+ */
+void __cleancache_flush_page(struct address_space *mapping, struct page *page)
+{
+	/* careful... page->mapping is NULL sometimes when this is called */
+	int pool_id = mapping->host->i_sb->cleancache_poolid;
+	struct cleancache_filekey key = { .u.key = { 0 } };
+
+	if (pool_id >= 0) {
+		VM_BUG_ON(!PageLocked(page));
+		if (cleancache_get_key(mapping->host, &key) >= 0) {
+			(*cleancache_ops.flush_page)(pool_id, key, page->index);
+			cleancache_flushes++;
+		}
+	}
+}
+EXPORT_SYMBOL(__cleancache_flush_page);
+
+/*
+ * Flush all data from cleancache associated with the poolid and the
+ * mappings's inode so that all subsequent gets to this poolid/inode
+ * will fail.
+ */
+void __cleancache_flush_inode(struct address_space *mapping)
+{
+	int pool_id = mapping->host->i_sb->cleancache_poolid;
+	struct cleancache_filekey key = { .u.key = { 0 } };
+
+	if (pool_id >= 0 && cleancache_get_key(mapping->host, &key) >= 0)
+		(*cleancache_ops.flush_inode)(pool_id, key);
+}
+EXPORT_SYMBOL(__cleancache_flush_inode);
+
+/*
+ * Called by any cleancache-enabled filesystem at time of unmount;
+ * note that pool_id is surrendered and may be reutrned by a subsequent
+ * cleancache_init_fs or cleancache_init_shared_fs
+ */
+void __cleancache_flush_fs(struct super_block *sb)
+{
+	if (sb->cleancache_poolid >= 0) {
+		int old_poolid = sb->cleancache_poolid;
+		sb->cleancache_poolid = -1;
+		(*cleancache_ops.flush_fs)(old_poolid);
+	}
+}
+EXPORT_SYMBOL(__cleancache_flush_fs);
+
+#ifdef CONFIG_SYSFS
+
+/* see Documentation/ABI/xxx/sysfs-kernel-mm-cleancache */
+
+#define CLEANCACHE_SYSFS_RO(_name) \
+	static ssize_t cleancache_##_name##_show(struct kobject *kobj, \
+				struct kobj_attribute *attr, char *buf) \
+	{ \
+		return sprintf(buf, "%lu\n", cleancache_##_name); \
+	} \
+	static struct kobj_attribute cleancache_##_name##_attr = { \
+		.attr = { .name = __stringify(_name), .mode = 0444 }, \
+		.show = cleancache_##_name##_show, \
+	}
+
+CLEANCACHE_SYSFS_RO(succ_gets);
+CLEANCACHE_SYSFS_RO(failed_gets);
+CLEANCACHE_SYSFS_RO(puts);
+CLEANCACHE_SYSFS_RO(flushes);
+
+static struct attribute *cleancache_attrs[] = {
+	&cleancache_succ_gets_attr.attr,
+	&cleancache_failed_gets_attr.attr,
+	&cleancache_puts_attr.attr,
+	&cleancache_flushes_attr.attr,
+	NULL,
+};
+
+static struct attribute_group cleancache_attr_group = {
+	.attrs = cleancache_attrs,
+	.name = "cleancache",
+};
+
+#endif /* CONFIG_SYSFS */
+
+static int __init init_cleancache(void)
+{
+#ifdef CONFIG_SYSFS
+	int err;
+
+	err = sysfs_create_group(mm_kobj, &cleancache_attr_group);
+#endif /* CONFIG_SYSFS */
+	return 0;
+}
+module_init(init_cleancache)
--- linux-2.6.39-rc3/mm/Kconfig	2011-04-11 18:21:51.000000000 -0600
+++ linux-2.6.39-rc3-cleancache/mm/Kconfig	2011-04-13 16:52:29.927862493 -0600
@@ -347,3 +347,26 @@ config NEED_PER_CPU_KM
 	depends on !SMP
 	bool
 	default y
+
+config CLEANCACHE
+	bool "Enable cleancache driver to cache clean pages if tmem is present"
+	default y
+	help
+	  Cleancache can be thought of as a page-granularity victim cache
+	  for clean pages that the kernel's pageframe replacement algorithm
+	  (PFRA) would like to keep around, but can't since there isn't enough
+	  memory.  So when the PFRA "evicts" a page, it first attempts to use
+	  cleancacne code to put the data contained in that page into
+	  "transcendent memory", memory that is not directly accessible or
+	  addressable by the kernel and is of unknown and possibly
+	  time-varying size.  And when a cleancache-enabled
+	  filesystem wishes to access a page in a file on disk, it first
+	  checks cleancache to see if it already contains it; if it does,
+	  the page is copied into the kernel and a disk access is avoided.
+	  When a transcendent memory driver is available (such as zcache or
+	  Xen transcendent memory), a significant I/O reduction
+	  may be achieved.  When none is available, all cleancache calls
+	  are reduced to a single pointer-compare-against-NULL resulting
+	  in a negligible performance hit.
+
+	  If unsure, say Y to enable cleancache
--- linux-2.6.39-rc3/mm/Makefile	2011-04-11 18:21:51.000000000 -0600
+++ linux-2.6.39-rc3-cleancache/mm/Makefile	2011-04-13 16:47:40.872852567 -0600
@@ -49,3 +49,4 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-f
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
+obj-$(CONFIG_CLEANCACHE) += cleancache.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

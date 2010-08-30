Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A937B6B01F2
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 18:33:21 -0400 (EDT)
Date: Mon, 30 Aug 2010 15:31:33 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V4 3/8] Cleancache: core ops functions and configuration
Message-ID: <20100830223133.GA1272@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com
List-ID: <linux-mm.kvack.org>

[PATCH V4 3/8] Cleancache: core ops functions and configuration

Cleancache core ops functions and configuration

Credits: Cleancache_ops design derived from Jeremy Fitzhardinge
design for tmem; sysfs code modelled after mm/ksm.c

Note that CONFIG_CLEANCACHE defaults to on; all hooks devolve
to a compare-function-pointer-to-NULL so performance impact should
be negligible, but can be reduced to zero impact if config'ed off.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 include/linux/cleancache.h               |  101 ++++++++++
 mm/Kconfig                               |   22 ++
 mm/Makefile                              |    1 
 mm/cleancache.c                          |  201 +++++++++++++++++++++
 4 files changed, 325 insertions(+)

--- linux-2.6.36-rc3/include/linux/cleancache.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-rc3-cleancache/include/linux/cleancache.h	2010-08-30 14:54:31.000000000 -0600
@@ -0,0 +1,101 @@
+#ifndef _LINUX_CLEANCACHE_H
+#define _LINUX_CLEANCACHE_H
+
+#include <linux/fs.h>
+#include <linux/exportfs.h>
+#include <linux/mm.h>
+
+#define CLEANCACHE_KEY_MAX 6
+
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
+extern struct cleancache_ops cleancache_ops;
+extern int __cleancache_get_page(struct page *);
+extern void __cleancache_put_page(struct page *);
+extern void __cleancache_flush_page(struct address_space *, struct page *);
+extern void __cleancache_flush_inode(struct address_space *);
+
+#ifdef CONFIG_CLEANCACHE
+#define cleancache_enabled (cleancache_ops.init_fs)
+#else
+#define cleancache_enabled (0)
+#endif
+
+/* called by a cleancache-enabled filesystem at time of mount */
+static inline int cleancache_init_fs(size_t pagesize)
+{
+	int ret = -1;
+
+	if (cleancache_enabled)
+		ret = (*cleancache_ops.init_fs)(pagesize);
+	return ret;
+}
+
+/* called by a cleancache-enabled clustered filesystem at time of mount */
+static inline int cleancache_init_shared_fs(char *uuid, size_t pagesize)
+{
+	int ret = -1;
+
+	if (cleancache_enabled)
+		ret = (*cleancache_ops.init_shared_fs)(uuid, pagesize);
+	return ret;
+}
+
+static inline int cleancache_get_page(struct page *page)
+{
+	int ret = -1;
+
+	if (cleancache_enabled)
+		ret = __cleancache_get_page(page);
+	return ret;
+}
+
+static inline void cleancache_put_page(struct page *page)
+{
+	if (cleancache_enabled)
+		__cleancache_put_page(page);
+}
+
+static inline void cleancache_flush_page(struct address_space *mapping,
+					struct page *page)
+{
+	if (cleancache_enabled)
+		__cleancache_flush_page(mapping, page);
+}
+
+static inline void cleancache_flush_inode(struct address_space *mapping)
+{
+	if (cleancache_enabled)
+		__cleancache_flush_inode(mapping);
+}
+
+/*
+ * called by any cleancache-enabled filesystem at time of unmount;
+ * note that pool_id is surrendered and may be returned by a subsequent
+ * cleancache_init_fs or cleancache_init_shared_fs
+ */
+static inline void cleancache_flush_fs(int pool_id)
+{
+	if (cleancache_enabled && pool_id >= 0)
+		(*cleancache_ops.flush_fs)(pool_id);
+}
+
+#endif /* _LINUX_CLEANCACHE_H */
--- linux-2.6.36-rc3/mm/cleancache.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-rc3-cleancache/mm/cleancache.c	2010-08-30 14:58:40.000000000 -0600
@@ -0,0 +1,201 @@
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
+ * cleancache_ops contains the pointers to the cleancache "backend"
+ * implementation functions.  This global variable may be checked thousands
+ * of times per second by cleancache_get/put/flush_page even on systems
+ * where cleancache_ops is not claimed (e.g. cleancache stays disabled),
+ * so is preferred to the slower alternative: a function call that
+ * checks a non-global.
+ */
+struct cleancache_ops cleancache_ops;
+
+/* useful stats available in /sys/kernel/mm/cleancache */
+static unsigned long succ_gets;
+static unsigned long failed_gets;
+static unsigned long puts;
+static unsigned long flushes;
+
+/*
+ * If the filesystem uses exportable filehandles, use the filehandle as
+ * the key, else use the inode number.
+ */
+static int get_key(struct inode *inode, struct cleancache_filekey *key)
+{
+	int (*fhfn)(struct dentry *, __u32 *fh, int *, int);
+	int maxlen = CLEANCACHE_KEY_MAX;
+	struct super_block *sb = inode->i_sb;
+	struct dentry *d;
+	
+	if (sb->s_export_op && (fhfn = sb->s_export_op->encode_fh)) {
+		d = list_first_entry(&inode->i_dentry, struct dentry, d_alias);
+		(void)(*fhfn)(d, &key->u.fh[0], &maxlen, 0); 
+		if (maxlen > CLEANCACHE_KEY_MAX)
+			return -1;
+	}
+	else
+		key->u.ino = inode->i_ino;
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
+	if (get_key(page->mapping->host,&key) < 0)
+		goto out;
+
+	ret = (*cleancache_ops.get_page)(pool_id, key, page->index, page);
+	if (ret == 0)
+		succ_gets++;
+	else
+		failed_gets++;
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
+	if (pool_id >= 0 && get_key(page->mapping->host,&key) >= 0) {
+		(*cleancache_ops.put_page)(pool_id, key, page->index, page);
+		puts++;
+	}
+}
+
+/*
+ * Flush any data from cleancache associated with the poolid and the
+ * page's inode and page index so that a subsequent "get" will fail.
+ */
+void __cleancache_flush_page(struct address_space *mapping, struct page *page)
+{
+	int pool_id = mapping->host->i_sb->cleancache_poolid;
+	struct cleancache_filekey key = { .u.key = { 0 } };
+
+	if (pool_id >= 0) {
+		VM_BUG_ON(!PageLocked(page));
+		if (get_key(page->mapping->host,&key) >= 0) {
+			(*cleancache_ops.flush_page)(pool_id, key, page->index);
+			flushes++;
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
+	if (pool_id >= 0 && get_key(mapping->host,&key) >= 0)
+		(*cleancache_ops.flush_inode)(pool_id, key);
+}
+EXPORT_SYMBOL(__cleancache_flush_inode);
+
+#ifdef CONFIG_SYSFS
+
+/* see Documentation/ABI/xxx/sysfs-kernel-mm-cleancache */
+
+#define CLEANCACHE_ATTR_RO(_name) \
+	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
+
+static ssize_t succ_gets_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", succ_gets);
+}
+CLEANCACHE_ATTR_RO(succ_gets);
+
+static ssize_t failed_gets_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", failed_gets);
+}
+CLEANCACHE_ATTR_RO(failed_gets);
+
+static ssize_t puts_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", puts);
+}
+CLEANCACHE_ATTR_RO(puts);
+
+static ssize_t flushes_show(struct kobject *kobj,
+			       struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", flushes);
+}
+CLEANCACHE_ATTR_RO(flushes);
+
+static struct attribute *cleancache_attrs[] = {
+	&succ_gets_attr.attr,
+	&failed_gets_attr.attr,
+	&puts_attr.attr,
+	&flushes_attr.attr,
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
--- linux-2.6.36-rc3/mm/Kconfig	2010-08-29 09:36:04.000000000 -0600
+++ linux-2.6.36-rc3-cleancache/mm/Kconfig	2010-08-30 09:20:43.000000000 -0600
@@ -301,3 +301,25 @@ config NOMMU_INITIAL_TRIM_EXCESS
 	  of 1 says that all excess pages should be trimmed.
 
 	  See Documentation/nommu-mmap.txt for more information.
+
+config CLEANCACHE
+	bool "Enable cleancache pseudo-RAM driver to cache clean pages"
+	default y
+	help
+ 	  Cleancache can be thought of as a page-granularity victim cache
+	  for clean pages that the kernel's pageframe replacement algorithm
+	  (PFRA) would like to keep around, but can't since there isn't enough
+	  memory.  So when the PFRA "evicts" a page, it first attempts to put
+	  it into a synchronous concurrency-safe page-oriented pseudo-RAM
+	  device (such as Xen's Transcendent Memory, aka "tmem") which is not
+	  directly accessible or addressable by the kernel and is of unknown
+	  (and possibly time-varying) size.  And when a cleancache-enabled
+	  filesystem wishes to access a page in a file on disk, it first
+	  checks cleancache to see if it already contains it; if it does,
+ 	  the page is copied into the kernel and a disk access is avoided.
+	  When a pseudo-RAM device is available, a significant I/O reduction
+	  may be achieved.  When none is available, all cleancache calls
+	  are reduced to a single pointer-compare-against-NULL resulting
+	  in a negligible performance hit.
+
+	  If unsure, say Y to enable cleancache
--- linux-2.6.36-rc3/mm/Makefile	2010-08-29 09:36:04.000000000 -0600
+++ linux-2.6.36-rc3-cleancache/mm/Makefile	2010-08-30 09:20:43.000000000 -0600
@@ -47,3 +47,4 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-f
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
+obj-$(CONFIG_CLEANCACHE) += cleancache.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0506B01BE
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 19:21:12 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:19:39 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V3 3/8] Cleancache: core ops functions and configuration
Message-ID: <20100621231939.GA19505@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com
List-ID: <linux-mm.kvack.org>

[PATCH V3 3/8] Cleancache: core ops functions and configuration

Cleancache core ops functions and configuration

Credits: Cleancache_ops design derived from Jeremy Fitzhardinge
design for tmem; sysfs code modelled after mm/ksm.c

Note that CONFIG_CLEANCACHE defaults to on; all hooks devolve
to a compare-function-pointer-to-NULL so performance impact should
be negligible, but can be reduced to zero impact if config'ed off.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 include/linux/cleancache.h               |   88 ++++++++++
 mm/Kconfig                               |   22 ++
 mm/Makefile                              |    1 
 mm/cleancache.c                          |  169 +++++++++++++++++++++
 4 files changed, 280 insertions(+)

--- linux-2.6.35-rc2/include/linux/cleancache.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.35-rc2-cleancache/include/linux/cleancache.h	2010-06-21 14:45:18.000000000 -0600
@@ -0,0 +1,88 @@
+#ifndef _LINUX_CLEANCACHE_H
+#define _LINUX_CLEANCACHE_H
+
+#include <linux/fs.h>
+#include <linux/mm.h>
+
+struct cleancache_ops {
+	int (*init_fs)(size_t);
+	int (*init_shared_fs)(char *uuid, size_t);
+	int (*get_page)(int, ino_t, pgoff_t, struct page *);
+	void (*put_page)(int, ino_t, pgoff_t, struct page *);
+	void (*flush_page)(int, ino_t, pgoff_t);
+	void (*flush_inode)(int, ino_t);
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
--- linux-2.6.35-rc2/mm/cleancache.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.35-rc2-cleancache/mm/cleancache.c	2010-06-11 10:32:35.000000000 -0600
@@ -0,0 +1,169 @@
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
+#include <linux/mm.h>
+#include <linux/cleancache.h>
+
+/*
+ * cleancache_ops contains the pointers to the cleancache "backend"
+ * implementation functions
+ */
+struct cleancache_ops cleancache_ops;
+EXPORT_SYMBOL(cleancache_ops);
+
+/* useful stats available in /sys/kernel/mm/cleancache */
+static unsigned long succ_gets;
+static unsigned long failed_gets;
+static unsigned long puts;
+static unsigned long flushes;
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
+
+	VM_BUG_ON(!PageLocked(page));
+	pool_id = page->mapping->host->i_sb->cleancache_poolid;
+	if (pool_id >= 0) {
+		ret = (*cleancache_ops.get_page)(pool_id,
+						 page->mapping->host->i_ino,
+						 page->index,
+						 page);
+		if (ret == 0)
+			succ_gets++;
+		else
+			failed_gets++;
+	}
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
+
+	VM_BUG_ON(!PageLocked(page));
+	pool_id = page->mapping->host->i_sb->cleancache_poolid;
+	if (pool_id >= 0) {
+		(*cleancache_ops.put_page)(pool_id, page->mapping->host->i_ino,
+					   page->index, page);
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
+
+	if (pool_id >= 0) {
+		VM_BUG_ON(!PageLocked(page));
+		(*cleancache_ops.flush_page)(pool_id, mapping->host->i_ino,
+					     page->index);
+		flushes++;
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
+
+	if (pool_id >= 0)
+		(*cleancache_ops.flush_inode)(pool_id, mapping->host->i_ino);
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
--- linux-2.6.35-rc2/mm/Kconfig	2010-06-05 21:43:24.000000000 -0600
+++ linux-2.6.35-rc2-cleancache/mm/Kconfig	2010-06-11 09:01:37.000000000 -0600
@@ -298,3 +298,25 @@ config NOMMU_INITIAL_TRIM_EXCESS
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
--- linux-2.6.35-rc2/mm/Makefile	2010-06-05 21:43:24.000000000 -0600
+++ linux-2.6.35-rc2-cleancache/mm/Makefile	2010-06-11 09:01:37.000000000 -0600
@@ -45,3 +45,4 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-f
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
+obj-$(CONFIG_CLEANCACHE) += cleancache.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

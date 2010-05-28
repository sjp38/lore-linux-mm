Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 065C56B01CB
	for <linux-mm@kvack.org>; Fri, 28 May 2010 13:36:46 -0400 (EDT)
Date: Fri, 28 May 2010 10:35:50 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V2 2/7] Cleancache (was Transcendent Memory): core files
Message-ID: <20100528173550.GA12219@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com
List-ID: <linux-mm.kvack.org>

[PATCH V2 2/7] Cleancache (was Transcendent Memory): core files

Cleancache core files.

Credits: Cleancache_ops design derived from Jeremy Fitzhardinge
design for tmem; sysfs code modelled after mm/ksm.c

Note that CONFIG_CLEANCACHE defaults to on; all hooks devolve
to a compare-pointer-to-NULL so performance impact should
be negligible, but can be reduced to zero impact if config'ed off.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Diffstat:
 include/linux/cleancache.h               |   90 +++++++++
 mm/Kconfig                               |   22 ++
 mm/Makefile                              |    1 
 mm/cleancache.c                          |  203 +++++++++++++++++++++
 4 files changed, 316 insertions(+)

--- linux-2.6.34/include/linux/cleancache.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.34-cleancache/include/linux/cleancache.h	2010-05-24 18:14:33.000000000 -0600
@@ -0,0 +1,90 @@
+#ifndef _LINUX_CLEANCACHE_H
+#define _LINUX_CLEANCACHE_H
+
+#include <linux/fs.h>
+#include <linux/mm.h>
+
+#define CLEANCACHE_GET_PAGE_SUCCESS 1
+
+struct cleancache_ops {
+	int (*init_fs)(size_t);
+	int (*init_shared_fs)(char *uuid, size_t);
+	int (*get_page)(int, ino_t, pgoff_t, struct page *);
+	int (*put_page)(int, ino_t, pgoff_t, struct page *);
+	int (*flush_page)(int, ino_t, pgoff_t);
+	int (*flush_inode)(int, ino_t);
+	void (*flush_fs)(int);
+};
+
+extern struct cleancache_ops *cleancache_ops;
+extern int __cleancache_get_page(struct page *);
+extern int __cleancache_put_page(struct page *);
+extern int __cleancache_flush_page(struct address_space *, struct page *);
+extern int __cleancache_flush_inode(struct address_space *);
+
+#ifndef CONFIG_CLEANCACHE
+#define cleancache_ops ((struct cleancache_ops *)NULL)
+#endif
+
+static inline int cleancache_init_fs(size_t pagesize)
+{
+	int ret = -1;
+
+	if (cleancache_ops)
+		ret = (*cleancache_ops->init_fs)(pagesize);
+	return ret;
+}
+
+static inline int cleancache_init_shared_fs(char *uuid, size_t pagesize)
+{
+	int ret = -1;
+
+	if (cleancache_ops)
+		ret = (*cleancache_ops->init_shared_fs)(uuid, pagesize);
+	return ret;
+}
+
+static inline int cleancache_get_page(struct page *page)
+{
+	int ret = 0;
+
+	if (cleancache_ops)
+		ret = __cleancache_get_page(page);
+	return ret;
+}
+
+static inline int cleancache_put_page(struct page *page)
+{
+	int ret = 0;
+
+	if (cleancache_ops)
+		ret = __cleancache_put_page(page);
+	return ret;
+}
+
+static inline int cleancache_flush_page(struct address_space *mapping,
+					struct page *page)
+{
+	int ret = 0;
+
+	if (cleancache_ops)
+		ret = __cleancache_flush_page(mapping, page);
+	return ret;
+}
+
+static inline int cleancache_flush_inode(struct address_space *mapping)
+{
+	int ret = 0;
+
+	if (cleancache_ops)
+		ret = __cleancache_flush_inode(mapping);
+	return ret;
+}
+
+static inline void cleancache_flush_fs(int pool_id)
+{
+	if (cleancache_ops && pool_id >= 0)
+		(*cleancache_ops->flush_fs)(pool_id);
+}
+
+#endif /* _LINUX_CLEANCACHE_H */
--- linux-2.6.34/mm/cleancache.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.34-cleancache/mm/cleancache.c	2010-05-24 18:07:11.000000000 -0600
@@ -0,0 +1,203 @@
+/* mm/cleancache.c
+
+ Copyright (C) 2009-2010 Oracle Corp. All rights reserved.
+ Author: Dan Magenheimer
+
+ Cleancache can be thought of as a page-granularity victim cache for clean
+ pages that the kernel's pageframe replacement algorithm (PFRA) would like
+ to keep around, but can't since there isn't enough memory.  So when the
+ PFRA "evicts" a page, it first attempts to put it into a synchronous
+ concurrency-safe page-oriented pseudo-RAM device (such as Xen's Transcendent
+ Memory, aka "tmem", or in-kernel compressed memory, aka "zmem", or other
+ RAM-like devices) which is not directly accessible or addressable by the
+ kernel and is of unknown and possibly time-varying size.  And when a
+ cleancache-enabled filesystem wishes to access a page in a file on disk,
+ it first checks cleancache to see if it already contains it; if it does,
+ the page is copied into the kernel and a disk access is avoided.
+ This pseudo-RAM device links itself to cleancache by setting the
+ cleancache_ops pointer appropriately and the functions it provides must
+ conform to certain semantics as follows:
+
+ Most important, cleancache is "ephemeral".  Pages which are copied into
+ cleancache have an indefinite lifetime which is completely unknowable
+ by the kernel and so may or may not still be in cleancache at any later time.
+ Thus, as its name implies, cleancache is not suitable for dirty pages.  The
+ pseudo-RAM has complete discretion over what pages to preserve and what
+ pages to discard and when.
+
+ A filesystem calls "init_fs" to obtain a pool id which, if positive, must be
+ saved in the filesystem's superblock; a negative return value indicates
+ failure.  A "put_page" will copy a (presumably about-to-be-evicted) page into
+ pseudo-RAM and associate it with the pool id, the file inode, and a page
+ index into the file.  (The combination of a pool id, an inode, and an index
+ is called a "handle".)  A "get_page" will copy the page, if found, from
+ pseudo-RAM into kernel memory.  A "flush_page" will ensure the page no longer
+ is present in pseudo-RAM; a "flush_inode" will flush all pages associated
+ with the specified inode; and a "flush_fs" will flush all pages in all
+ inodes specified by the given pool id.
+
+ A "init_shared_fs", like init, obtains a pool id but tells the pseudo-RAM
+ to treat the pool as shared using a 128-bit UUID as a key.  On systems
+ that may run multiple kernels (such as hard partitioned or virtualized
+ systems) that may share a clustered filesystem, and where the pseudo-RAM
+ may be shared among those kernels, calls to init_shared_fs that specify the
+ same UUID will receive the same pool id, thus allowing the pages to
+ be shared.  Note that any security requirements must be imposed outside
+ of the kernel (e.g. by "tools" that control the pseudo-RAM).  Or a
+ pseudo-RAM implementation can simply disable shared_init by always
+ returning a negative value.
+
+ If a get_page is successful on a non-shared pool, the page is flushed (thus
+ making cleancache an "exclusive" cache).  On a shared pool, the page
+ is NOT flushed on a successful get_page so that it remains accessible to
+ other sharers.  The kernel is responsible for ensuring coherency between
+ cleancache (shared or not), the page cache, and the filesystem, using
+ cleancache flush operations as required.
+
+ Note that the pseudo-RAM must enforce put-put-get coherency and get-get
+ coherency.  For the former, if two puts are made to the same handle but
+ with different data, say AAA by the first put and BBB by the second, a
+ subsequent get can never return the stale data (AAA).  For get-get coherency,
+ if a get for a given handle fails, subsequent gets for that handle will
+ never succeed unless preceded by a successful put with that handle.
+
+ Last, pseudo-RAM provides no SMP serialization guarantees; if two
+ different Linux threads are putting an flushing a page with the same
+ handle, the results are indeterminate.
+
+ */
+
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/cleancache.h>
+
+struct cleancache_ops *cleancache_ops;
+EXPORT_SYMBOL(cleancache_ops);
+
+/* useful stats available via /sys/kernel/mm/frontswap */
+static unsigned long succ_gets;
+static unsigned long failed_gets;
+static unsigned long puts;
+static unsigned long flushes;
+
+int __cleancache_get_page(struct page *page)
+{
+	int ret = 0;
+	int pool_id = page->mapping->host->i_sb->cleancache_poolid;
+
+	if (pool_id >= 0) {
+		ret = (*cleancache_ops->get_page)(pool_id,
+						  page->mapping->host->i_ino,
+						  page->index,
+						  page);
+		if (ret == CLEANCACHE_GET_PAGE_SUCCESS)
+			succ_gets++;
+		else
+			failed_gets++;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(__cleancache_get_page);
+
+int __cleancache_put_page(struct page *page)
+{
+	int ret = 0;
+	int pool_id = page->mapping->host->i_sb->cleancache_poolid;
+
+	if (pool_id >= 0) {
+		ret = (*cleancache_ops->put_page)(pool_id,
+						  page->mapping->host->i_ino,
+						  page->index,
+						  page);
+		puts++;
+	}
+	return ret;
+}
+
+int __cleancache_flush_page(struct address_space *mapping, struct page *page)
+{
+	int ret = 0;
+	int pool_id = mapping->host->i_sb->cleancache_poolid;
+
+	if (pool_id >= 0) {
+		ret = (*cleancache_ops->flush_page)(pool_id,
+						    mapping->host->i_ino,
+						    page->index);
+		flushes++;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(__cleancache_flush_page);
+
+int __cleancache_flush_inode(struct address_space *mapping)
+{
+	int ret = 0;
+	int pool_id = mapping->host->i_sb->cleancache_poolid;
+
+	if (pool_id >= 0) {
+		ret = (*cleancache_ops->flush_inode)(pool_id,
+						     mapping->host->i_ino);
+	}
+	return ret;
+}
+EXPORT_SYMBOL(__cleancache_flush_inode);
+
+#ifdef CONFIG_SYSFS
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
--- linux-2.6.34/mm/Kconfig	2010-05-16 15:17:36.000000000 -0600
+++ linux-2.6.34-cleancache/mm/Kconfig	2010-05-24 12:14:44.000000000 -0600
@@ -287,3 +287,25 @@ config NOMMU_INITIAL_TRIM_EXCESS
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
--- linux-2.6.34/mm/Makefile	2010-05-16 15:17:36.000000000 -0600
+++ linux-2.6.34-cleancache/mm/Makefile	2010-05-24 12:14:44.000000000 -0600
@@ -44,3 +44,4 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-f
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
+obj-$(CONFIG_CLEANCACHE) += cleancache.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

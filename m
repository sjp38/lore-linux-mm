Message-Id: <20080129154948.823761079@szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
Date: Tue, 29 Jan 2008 16:49:02 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 2/6] mm: bdi: export BDI attributes in sysfs
Content-Disposition: inline; filename=bdi-sysfs.patch
Sender: owner-linux-mm@kvack.org
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Kay Sievers <kay.sievers@vrfy.org>, Greg KH <greg@kroah.com>, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

Provide a place in sysfs (/sys/class/bdi) for the backing_dev_info
object.  This allows us to see and set the various BDI specific
variables.

In particular this properly exposes the read-ahead window for all
relevant users and /sys/block/<block>/queue/read_ahead_kb should be
deprecated.

With patient help from Kay Sievers and Greg KH

[mszeredi@suse.cz]

 - split off NFS and FUSE changes into separate patches
 - document new sysfs attributes under Documentation/ABI
 - do bdi_class_init as a core_initcall, otherwise the "default" BDI
   won't be initialized
 - remove bdi_init_fmt macro, it's not used very much

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Kay Sievers <kay.sievers@vrfy.org>
CC: Greg KH <greg@kroah.com>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>
Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/block/genhd.c
===================================================================
--- linux.orig/block/genhd.c	2008-01-29 13:02:41.000000000 +0100
+++ linux/block/genhd.c	2008-01-29 13:02:46.000000000 +0100
@@ -183,6 +183,8 @@ void add_disk(struct gendisk *disk)
 			    disk->minors, NULL, exact_match, exact_lock, disk);
 	register_disk(disk);
 	blk_register_queue(disk);
+	bdi_register(&disk->queue->backing_dev_info, NULL,
+		"blk-%s", disk->disk_name);
 }
 
 EXPORT_SYMBOL(add_disk);
@@ -191,6 +193,7 @@ EXPORT_SYMBOL(del_gendisk);	/* in partit
 void unlink_gendisk(struct gendisk *disk)
 {
 	blk_unregister_queue(disk);
+	bdi_unregister(&disk->queue->backing_dev_info);
 	blk_unregister_region(MKDEV(disk->major, disk->first_minor),
 			      disk->minors);
 }
Index: linux/include/linux/backing-dev.h
===================================================================
--- linux.orig/include/linux/backing-dev.h	2008-01-29 13:02:41.000000000 +0100
+++ linux/include/linux/backing-dev.h	2008-01-29 13:02:46.000000000 +0100
@@ -11,6 +11,8 @@
 #include <linux/percpu_counter.h>
 #include <linux/log2.h>
 #include <linux/proportions.h>
+#include <linux/kernel.h>
+#include <linux/device.h>
 #include <asm/atomic.h>
 
 struct page;
@@ -48,11 +50,17 @@ struct backing_dev_info {
 
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
+
+	struct device *dev;
 };
 
 int bdi_init(struct backing_dev_info *bdi);
 void bdi_destroy(struct backing_dev_info *bdi);
 
+int bdi_register(struct backing_dev_info *bdi, struct device *parent,
+		const char *fmt, ...);
+void bdi_unregister(struct backing_dev_info *bdi);
+
 static inline void __add_bdi_stat(struct backing_dev_info *bdi,
 		enum bdi_stat_item item, s64 amount)
 {
Index: linux/include/linux/writeback.h
===================================================================
--- linux.orig/include/linux/writeback.h	2008-01-29 13:02:41.000000000 +0100
+++ linux/include/linux/writeback.h	2008-01-29 13:02:46.000000000 +0100
@@ -113,6 +113,9 @@ struct file;
 int dirty_writeback_centisecs_handler(struct ctl_table *, int, struct file *,
 				      void __user *, size_t *, loff_t *);
 
+void get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
+		 struct backing_dev_info *bdi);
+
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 					unsigned long nr_pages_dirtied);
Index: linux/mm/backing-dev.c
===================================================================
--- linux.orig/mm/backing-dev.c	2008-01-29 13:02:41.000000000 +0100
+++ linux/mm/backing-dev.c	2008-01-29 13:03:23.000000000 +0100
@@ -4,12 +4,118 @@
 #include <linux/fs.h>
 #include <linux/sched.h>
 #include <linux/module.h>
+#include <linux/writeback.h>
+#include <linux/device.h>
+
+
+static struct class *bdi_class;
+
+static ssize_t read_ahead_kb_store(struct device *dev,
+				  struct device_attribute *attr,
+				  const char *buf, size_t count)
+{
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
+	char *end;
+
+	bdi->ra_pages = simple_strtoul(buf, &end, 10) >> (PAGE_SHIFT - 10);
+
+	return end - buf;
+}
+
+#define K(pages) ((pages) << (PAGE_SHIFT - 10))
+
+#define BDI_SHOW(name, expr)						\
+static ssize_t name##_show(struct device *dev,				\
+			   struct device_attribute *attr, char *page)	\
+{									\
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);		\
+									\
+	return snprintf(page, PAGE_SIZE-1, "%lld\n", (long long)expr);	\
+}
+
+BDI_SHOW(read_ahead_kb, K(bdi->ra_pages))
+
+BDI_SHOW(reclaimable_kb, K(bdi_stat(bdi, BDI_RECLAIMABLE)))
+BDI_SHOW(writeback_kb, K(bdi_stat(bdi, BDI_WRITEBACK)))
+
+static inline unsigned long get_dirty(struct backing_dev_info *bdi, int i)
+{
+	unsigned long thresh[3];
+
+	get_dirty_limits(&thresh[0], &thresh[1], &thresh[2], bdi);
+
+	return thresh[i];
+}
+
+BDI_SHOW(dirty_kb, K(get_dirty(bdi, 1)))
+BDI_SHOW(bdi_dirty_kb, K(get_dirty(bdi, 2)))
+
+#define __ATTR_RW(attr) __ATTR(attr, 0644, attr##_show, attr##_store)
+
+static struct device_attribute bdi_dev_attrs[] = {
+	__ATTR_RW(read_ahead_kb),
+	__ATTR_RO(reclaimable_kb),
+	__ATTR_RO(writeback_kb),
+	__ATTR_RO(dirty_kb),
+	__ATTR_RO(bdi_dirty_kb),
+	__ATTR_NULL,
+};
+
+static __init int bdi_class_init(void)
+{
+	bdi_class = class_create(THIS_MODULE, "bdi");
+	bdi_class->dev_attrs = bdi_dev_attrs;
+	return 0;
+}
+
+core_initcall(bdi_class_init);
+
+int bdi_register(struct backing_dev_info *bdi, struct device *parent,
+		const char *fmt, ...)
+{
+	char *name;
+	va_list args;
+	int ret = 0;
+	struct device *dev;
+
+	va_start(args, fmt);
+	name = kvasprintf(GFP_KERNEL, fmt, args);
+	va_end(args);
+
+	if (!name)
+		return -ENOMEM;
+
+	dev = device_create(bdi_class, parent, MKDEV(0, 0), name);
+	if (IS_ERR(dev)) {
+		ret = PTR_ERR(dev);
+		goto exit;
+	}
+
+	bdi->dev = dev;
+	dev_set_drvdata(bdi->dev, bdi);
+
+exit:
+	kfree(name);
+	return ret;
+}
+EXPORT_SYMBOL(bdi_register);
+
+void bdi_unregister(struct backing_dev_info *bdi)
+{
+	if (bdi->dev) {
+		device_unregister(bdi->dev);
+		bdi->dev = NULL;
+	}
+}
+EXPORT_SYMBOL(bdi_unregister);
 
 int bdi_init(struct backing_dev_info *bdi)
 {
 	int i;
 	int err;
 
+	bdi->dev = NULL;
+
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++) {
 		err = percpu_counter_init_irq(&bdi->bdi_stat[i], 0);
 		if (err)
@@ -33,6 +139,8 @@ void bdi_destroy(struct backing_dev_info
 {
 	int i;
 
+	bdi_unregister(bdi);
+
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_destroy(&bdi->bdi_stat[i]);
 
Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2008-01-29 13:02:41.000000000 +0100
+++ linux/mm/page-writeback.c	2008-01-29 13:02:46.000000000 +0100
@@ -304,7 +304,7 @@ static unsigned long determine_dirtyable
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
-static void
+void
 get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
 		 struct backing_dev_info *bdi)
 {
Index: linux/lib/percpu_counter.c
===================================================================
--- linux.orig/lib/percpu_counter.c	2008-01-29 13:02:41.000000000 +0100
+++ linux/lib/percpu_counter.c	2008-01-29 13:02:46.000000000 +0100
@@ -102,6 +102,7 @@ void percpu_counter_destroy(struct percp
 		return;
 
 	free_percpu(fbc->counters);
+	fbc->counters = NULL;
 #ifdef CONFIG_HOTPLUG_CPU
 	mutex_lock(&percpu_counters_lock);
 	list_del(&fbc->list);
Index: linux/mm/readahead.c
===================================================================
--- linux.orig/mm/readahead.c	2008-01-29 13:02:41.000000000 +0100
+++ linux/mm/readahead.c	2008-01-29 13:02:46.000000000 +0100
@@ -235,7 +235,13 @@ unsigned long max_sane_readahead(unsigne
 
 static int __init readahead_init(void)
 {
-	return bdi_init(&default_backing_dev_info);
+	int err;
+
+	err = bdi_init(&default_backing_dev_info);
+	if (!err)
+		bdi_register(&default_backing_dev_info, NULL, "default");
+
+	return err;
 }
 subsys_initcall(readahead_init);
 
Index: linux/Documentation/ABI/testing/sysfs-class-bdi
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/Documentation/ABI/testing/sysfs-class-bdi	2008-01-29 13:02:46.000000000 +0100
@@ -0,0 +1,50 @@
+What:		/sys/class/bdi/<bdi>/
+Date:		January 2008
+Contact:	Peter Zijlstra <a.p.zijlstra@chello.nl>
+Description:
+
+Provide a place in sysfs for the backing_dev_info object.
+This allows us to see and set the various BDI specific variables.
+
+The <bdi> identifyer can take the following forms:
+
+blk-NAME
+
+	Block devices, NAME is 'sda', 'loop0', etc...
+
+FSTYPE-MAJOR:MINOR
+
+	Non-block device backed filesystems which provide their own
+	BDI, such as NFS and FUSE.  MAJOR:MINOR is the value of st_dev
+	for files on this filesystem.
+
+default
+
+	The default backing dev, used for non-block device backed
+	filesystems which do not provide their own BDI.
+
+Files under /sys/class/bdi/<bdi>/
+---------------------------------
+
+read_ahead_kb (read-write)
+
+	Size of the read-ahead window in kilobytes
+
+reclaimable_kb (read-only)
+
+	Reclaimable (dirty or unstable) memory destined for writeback
+	to this device
+
+writeback_kb (read-only)
+
+	Memory currently under writeback to this device
+
+dirty_kb (read-only)
+
+	Global threshold for reclaimable + writeback memory
+
+bdi_dirty_kb (read-only)
+
+	Current threshold on this BDI for reclaimable + writeback
+	memory
+

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

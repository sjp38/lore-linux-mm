Message-Id: <20080202230231.403524972@szeredi.hu>
References: <20080202230111.346847183@szeredi.hu>
Date: Sun, 03 Feb 2008 00:01:14 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 3/3] mm: bdi: move statistics to debugfs
Content-Disposition: inline; filename=mm-bdi-move-statistics-to-debugfs.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Move BDI statistics to debugfs:

   /sys/kernel/debug/bdi/<bdi>/stats

Use postcore_initcall() to initialize the sysfs class and debugfs,
because debugfs is initialized in core_initcall().

Update descriptions in ABI documentation.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/include/linux/backing-dev.h
===================================================================
--- linux.orig/include/linux/backing-dev.h	2008-02-02 23:08:41.000000000 +0100
+++ linux/include/linux/backing-dev.h	2008-02-02 23:08:41.000000000 +0100
@@ -16,6 +16,7 @@
 #include <asm/atomic.h>
 
 struct page;
+struct dentry;
 
 /*
  * Bits in backing_dev_info.state
@@ -55,6 +56,11 @@ struct backing_dev_info {
 	unsigned int max_ratio, max_prop_frac;
 
 	struct device *dev;
+
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *debug_dir;
+	struct dentry *debug_stats;
+#endif
 };
 
 int bdi_init(struct backing_dev_info *bdi);
Index: linux/mm/backing-dev.c
===================================================================
--- linux.orig/mm/backing-dev.c	2008-02-02 23:08:41.000000000 +0100
+++ linux/mm/backing-dev.c	2008-02-02 23:12:47.000000000 +0100
@@ -10,6 +10,80 @@
 
 static struct class *bdi_class;
 
+#ifdef CONFIG_DEBUG_FS
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
+
+static struct dentry *bdi_debug_root;
+
+static void bdi_debug_init(void)
+{
+	bdi_debug_root = debugfs_create_dir("bdi", NULL);
+}
+
+static int bdi_debug_stats_show(struct seq_file *m, void *v)
+{
+	struct backing_dev_info *bdi = m->private;
+	long background_thresh;
+	long dirty_thresh;
+	long bdi_thresh;
+
+	get_dirty_limits(&background_thresh, &dirty_thresh, &bdi_thresh, bdi);
+
+#define K(x) ((x) << (PAGE_SHIFT - 10))
+	seq_printf(m,
+		   "BdiWriteback:     %8lu kB\n"
+		   "BdiReclaimable:   %8lu kB\n"
+		   "BdiDirtyThresh:   %8lu kB\n"
+		   "DirtyThresh:      %8lu kB\n"
+		   "BackgroundThresh: %8lu kB\n",
+		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
+		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
+		   K(bdi_thresh),
+		   K(dirty_thresh),
+		   K(background_thresh));
+#undef K
+
+	return 0;
+}
+
+static int bdi_debug_stats_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, bdi_debug_stats_show, inode->i_private);
+}
+
+static const struct file_operations bdi_debug_stats_fops = {
+	.open		= bdi_debug_stats_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
+{
+	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
+	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
+					       bdi, &bdi_debug_stats_fops);
+}
+
+static void bdi_debug_unregister(struct backing_dev_info *bdi)
+{
+	debugfs_remove(bdi->debug_stats);
+	debugfs_remove(bdi->debug_dir);
+}
+#else
+static inline void bdi_debug_init(void)
+{
+}
+static inline void bdi_debug_register(struct backing_dev_info *bdi,
+				      const char *name)
+{
+}
+static inline void bdi_debug_unregister(struct backing_dev_info *bdi)
+{
+}
+#endif
+
 static ssize_t read_ahead_kb_store(struct device *dev,
 				  struct device_attribute *attr,
 				  const char *buf, size_t count)
@@ -40,21 +114,6 @@ static ssize_t name##_show(struct device
 
 BDI_SHOW(read_ahead_kb, K(bdi->ra_pages))
 
-BDI_SHOW(reclaimable_kb, K(bdi_stat(bdi, BDI_RECLAIMABLE)))
-BDI_SHOW(writeback_kb, K(bdi_stat(bdi, BDI_WRITEBACK)))
-
-static inline unsigned long get_dirty(struct backing_dev_info *bdi, int i)
-{
-	unsigned long thresh[3];
-
-	get_dirty_limits(&thresh[0], &thresh[1], &thresh[2], bdi);
-
-	return thresh[i];
-}
-
-BDI_SHOW(dirty_kb, K(get_dirty(bdi, 1)))
-BDI_SHOW(bdi_dirty_kb, K(get_dirty(bdi, 2)))
-
 static ssize_t min_ratio_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
@@ -95,10 +154,6 @@ BDI_SHOW(max_ratio, bdi->max_ratio)
 
 static struct device_attribute bdi_dev_attrs[] = {
 	__ATTR_RW(read_ahead_kb),
-	__ATTR_RO(reclaimable_kb),
-	__ATTR_RO(writeback_kb),
-	__ATTR_RO(dirty_kb),
-	__ATTR_RO(bdi_dirty_kb),
 	__ATTR_RW(min_ratio),
 	__ATTR_RW(max_ratio),
 	__ATTR_NULL,
@@ -108,10 +163,11 @@ static __init int bdi_class_init(void)
 {
 	bdi_class = class_create(THIS_MODULE, "bdi");
 	bdi_class->dev_attrs = bdi_dev_attrs;
+	bdi_debug_init();
 	return 0;
 }
 
-core_initcall(bdi_class_init);
+postcore_initcall(bdi_class_init);
 
 int bdi_register(struct backing_dev_info *bdi, struct device *parent,
 		const char *fmt, ...)
@@ -136,6 +192,7 @@ int bdi_register(struct backing_dev_info
 
 	bdi->dev = dev;
 	dev_set_drvdata(bdi->dev, bdi);
+	bdi_debug_register(bdi, name);
 
 exit:
 	kfree(name);
@@ -152,6 +209,7 @@ EXPORT_SYMBOL(bdi_register_dev);
 void bdi_unregister(struct backing_dev_info *bdi)
 {
 	if (bdi->dev) {
+		bdi_debug_unregister(bdi);
 		device_unregister(bdi->dev);
 		bdi->dev = NULL;
 	}
Index: linux/Documentation/ABI/testing/sysfs-class-bdi
===================================================================
--- linux.orig/Documentation/ABI/testing/sysfs-class-bdi	2008-02-02 23:08:41.000000000 +0100
+++ linux/Documentation/ABI/testing/sysfs-class-bdi	2008-02-02 23:17:27.000000000 +0100
@@ -3,8 +3,8 @@ Date:		January 2008
 Contact:	Peter Zijlstra <a.p.zijlstra@chello.nl>
 Description:
 
-Provide a place in sysfs for the backing_dev_info object.
-This allows us to see and set the various BDI specific variables.
+Provide a place in sysfs for the backing_dev_info object.  This allows
+setting and retrieving various BDI specific variables.
 
 The <bdi> identifier can be either of the following:
 
@@ -26,34 +26,21 @@ read_ahead_kb (read-write)
 
 	Size of the read-ahead window in kilobytes
 
-reclaimable_kb (read-only)
-
-	Reclaimable (dirty or unstable) memory destined for writeback
-	to this device
-
-writeback_kb (read-only)
-
-	Memory currently under writeback to this device
-
-dirty_kb (read-only)
-
-	Global threshold for reclaimable + writeback memory
-
-bdi_dirty_kb (read-only)
-
-	Current threshold on this BDI for reclaimable + writeback
-	memory
-
 min_ratio (read-write)
 
-	Minimal percentage of global dirty threshold allocated to this
-	bdi.  If the value written to this file would make the the sum
-	of all min_ratio values exceed 100, then EINVAL is returned.
-	If min_ratio would become larger than the current max_ratio,
-	then also EINVAL is returned.  The default is zero
+	Under normal circumstances each device is given a part of the
+	total write-back cache that relates to its current average
+	writeout speed in relation to the other devices.
+
+	The 'min_ratio' parameter allows assigning a minimum
+	percentage of the write-back cache to a particular device.
+	For example, this is useful for providing a minimum QoS.
 
 max_ratio (read-write)
 
-	Maximal percentage of global dirty threshold allocated to this
-	bdi.  If max_ratio would become smaller than the current
-	min_ratio, then EINVAL is returned.  The default is 100
+	Allows limiting a particular device to use not more than the
+	given percentage of the write-back cache.  This is useful in
+	situations where we want to avoid one device taking all or
+	most of the write-back cache.  For example in case of an NFS
+	mount that is prone to get stuck, or a FUSE mount which cannot
+	be trusted to play fair.

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

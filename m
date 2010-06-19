Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1B5A76B01C7
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 20:30:57 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 2/3] writeback: per bdi monitoring
Date: Fri, 18 Jun 2010 17:30:14 -0700
Message-Id: <1276907415-504-3-git-send-email-mrubin@google.com>
In-Reply-To: <1276907415-504-1-git-send-email-mrubin@google.com>
References: <1276907415-504-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

To allow users and applications to gain visibility into the writeback
behaviour debugfs files are moved into /sys. bdi granularity
of visibility is important to root cause both rogue user apps and/or
kernel issues.

This patch converts bdi debug files of bdi into
/sys/block/<dev>/bdi/writeback.

    # cat /sys/class/block/sda/bdi/writeback
    BdiWriteback:             0 kB
    BdiReclaimable:          96 kB
    BdiDirtyThresh:     2117144 kB
    DirtyThresh:       12192420 kB
    BackgroundThresh:   1625656 kB
    WritebackThreads:         1
    WorkWaiting:              0
    InodesOnDirty:           37
    InodesOnIo:               0
    InodesOnMoreIo:           0
    wb_mask:                  1
    wb_cnt:                   1

Also it adds a sys file for the bdi state in
/sys/block/<block>/bdi/state. The file will expose the state of
the bdi in a comma separated list.

# cat /sys/class/block/sda/bdi/state
registered,sync_congested

TESTED:
Injected false states in the code stream to ensure the state file worked
correctly. Then removed false states.

Performed IO on different disks to see the correct writeback values
fluctuate and report what was expected.

Signed-off-by: Michael Rubin <mrubin@google.com>
---
 fs/fs-writeback.c           |   13 +++++
 include/linux/backing-dev.h |    1 +
 mm/backing-dev.c            |  126 +++++++++++++++++++------------------------
 3 files changed, 70 insertions(+), 70 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 1d1088f..62a899e 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -95,6 +95,19 @@ int writeback_in_progress(struct backing_dev_info *bdi)
 	return !list_empty(&bdi->work_list);
 }
 
+int writeback_work_waiting(struct backing_dev_info *bdi)
+{
+	struct bdi_work *work;
+	int nr_wb_work = 0;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(work, &bdi->work_list, list) {
+		nr_wb_work++;
+	}
+	rcu_read_unlock();
+	return nr_wb_work;
+}
+
 static void bdi_work_clear(struct bdi_work *work)
 {
 	clear_bit(WS_USED_B, &work->state);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index aee5f6c..e1fb11c 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -255,6 +255,7 @@ extern struct backing_dev_info noop_backing_dev_info;
 void default_unplug_io_fn(struct backing_dev_info *bdi, struct page *page);
 
 int writeback_in_progress(struct backing_dev_info *bdi);
+int writeback_work_waiting(struct backing_dev_info *bdi);
 
 static inline int bdi_congested(struct backing_dev_info *bdi, int bdi_bits)
 {
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 660a87a..9a89296 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -51,25 +51,52 @@ static void sync_supers_timer_fn(unsigned long);
 
 static void bdi_add_default_flusher_task(struct backing_dev_info *bdi);
 
-#ifdef CONFIG_DEBUG_FS
-#include <linux/debugfs.h>
-#include <linux/seq_file.h>
-
-static struct dentry *bdi_debug_root;
+static const char *bdi_state_labels[] = {
+	"pending",
+	"wb_alloc",
+	"async_congested",
+	"sync_congested",
+	"registered",
+};
 
-static void bdi_debug_init(void)
+static ssize_t state_show(struct device *dev, struct device_attribute *attr,
+			 char *page)
 {
-	bdi_debug_root = debugfs_create_dir("bdi", NULL);
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
+	int statebit, printed = 0;
+	int bufsize = PAGE_SIZE - 1;
+
+	/* Caching for consistency */
+	unsigned long state = ((1 << BDI_unused) - 1) & bdi->state;
+
+	if (state & 0)
+		return snprintf(page, bufsize, "No state\n");
+
+	for (statebit = 0; statebit < BDI_unused; statebit++) {
+		if (!test_bit(statebit, &state))
+			continue;
+		printed += snprintf(page + printed, bufsize - printed,
+				   "%s,", bdi_state_labels[statebit]);
+		if (printed >= bufsize) {
+			page[PAGE_SIZE - 1] = '\n';
+			return PAGE_SIZE;
+		}
+	}
+
+	page[printed - 1] = '\n';
+	return printed;
 }
 
-static int bdi_debug_stats_show(struct seq_file *m, void *v)
+
+static ssize_t writeback_show(struct device *dev, struct device_attribute *attr,
+				 char *page)
 {
-	struct backing_dev_info *bdi = m->private;
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
 	struct bdi_writeback *wb;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
-	unsigned long nr_dirty, nr_io, nr_more_io, nr_wb;
+	unsigned long nr_dirty, nr_io, nr_more_io, nr_wb, nr_wb_work;
 	struct inode *inode;
 
 	/*
@@ -90,70 +117,30 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	spin_unlock(&inode_lock);
 
 	get_dirty_limits(&background_thresh, &dirty_thresh, &bdi_thresh, bdi);
+	nr_wb_work = writeback_work_waiting(bdi);
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
-	seq_printf(m,
-		   "BdiWriteback:     %8lu kB\n"
-		   "BdiReclaimable:   %8lu kB\n"
-		   "BdiDirtyThresh:   %8lu kB\n"
-		   "DirtyThresh:      %8lu kB\n"
-		   "BackgroundThresh: %8lu kB\n"
-		   "WritebackThreads: %8lu\n"
-		   "b_dirty:          %8lu\n"
-		   "b_io:             %8lu\n"
-		   "b_more_io:        %8lu\n"
-		   "bdi_list:         %8u\n"
-		   "state:            %8lx\n"
-		   "wb_mask:          %8lx\n"
-		   "wb_list:          %8u\n"
-		   "wb_cnt:           %8u\n",
+	return snprintf(page, PAGE_SIZE-1,
+		   "BdiWriteback:      %8lu kB\n"
+		   "BdiReclaimable:    %8lu kB\n"
+		   "BdiDirtyThresh:    %8lu kB\n"
+		   "DirtyThresh:       %8lu kB\n"
+		   "BackgroundThresh:  %8lu kB\n"
+		   "WritebackThreads:  %8lu\n"
+		   "WorkWaiting:       %8lu\n"
+		   "InodesOnDirty:     %8lu\n"
+		   "InodesOnIo:        %8lu\n"
+		   "InodesOnMoreIo:    %8lu\n"
+		   "wb_mask:           %8lx\n"
+		   "wb_cnt:            %8u\n",
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
 		   K(bdi_thresh), K(dirty_thresh),
-		   K(background_thresh), nr_wb, nr_dirty, nr_io, nr_more_io,
-		   !list_empty(&bdi->bdi_list), bdi->state, bdi->wb_mask,
-		   !list_empty(&bdi->wb_list), bdi->wb_cnt);
+		   K(background_thresh), nr_wb, nr_wb_work,
+		   nr_dirty, nr_io, nr_more_io,
+		   bdi->wb_mask, bdi->wb_cnt);
 #undef K
-
-	return 0;
-}
-
-static int bdi_debug_stats_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, bdi_debug_stats_show, inode->i_private);
-}
-
-static const struct file_operations bdi_debug_stats_fops = {
-	.open		= bdi_debug_stats_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= single_release,
-};
-
-static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
-{
-	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
-	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
-					       bdi, &bdi_debug_stats_fops);
-}
-
-static void bdi_debug_unregister(struct backing_dev_info *bdi)
-{
-	debugfs_remove(bdi->debug_stats);
-	debugfs_remove(bdi->debug_dir);
-}
-#else
-static inline void bdi_debug_init(void)
-{
-}
-static inline void bdi_debug_register(struct backing_dev_info *bdi,
-				      const char *name)
-{
-}
-static inline void bdi_debug_unregister(struct backing_dev_info *bdi)
-{
 }
-#endif
 
 static ssize_t read_ahead_kb_store(struct device *dev,
 				  struct device_attribute *attr,
@@ -224,6 +211,8 @@ BDI_SHOW(max_ratio, bdi->max_ratio)
 #define __ATTR_RW(attr) __ATTR(attr, 0644, attr##_show, attr##_store)
 
 static struct device_attribute bdi_dev_attrs[] = {
+	__ATTR_RO(state),
+	__ATTR_RO(writeback),
 	__ATTR_RW(read_ahead_kb),
 	__ATTR_RW(min_ratio),
 	__ATTR_RW(max_ratio),
@@ -237,7 +226,6 @@ static __init int bdi_class_init(void)
 		return PTR_ERR(bdi_class);
 
 	bdi_class->dev_attrs = bdi_dev_attrs;
-	bdi_debug_init();
 	return 0;
 }
 postcore_initcall(bdi_class_init);
@@ -583,7 +571,6 @@ int bdi_register(struct backing_dev_info *bdi, struct device *parent,
 		}
 	}
 
-	bdi_debug_register(bdi, dev_name(dev));
 	set_bit(BDI_registered, &bdi->state);
 exit:
 	return ret;
@@ -651,7 +638,6 @@ void bdi_unregister(struct backing_dev_info *bdi)
 
 		if (!bdi_cap_flush_forker(bdi))
 			bdi_wb_shutdown(bdi);
-		bdi_debug_unregister(bdi);
 		device_unregister(bdi->dev);
 		bdi->dev = NULL;
 	}
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 50BF86B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 14:45:39 -0400 (EDT)
From: Curt Wohlgemuth <curtw@google.com>
Subject: [PATCH 2/2] writeback: Add writeback stats for pages written
Date: Fri, 12 Aug 2011 11:45:07 -0700
Message-Id: <1313174707-4267-2-git-send-email-curtw@google.com>
In-Reply-To: <1313174707-4267-1-git-send-email-curtw@google.com>
References: <1313174707-4267-1-git-send-email-curtw@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Curt Wohlgemuth <curtw@google.com>

Add a new file, /proc/writeback/stats, which displays
machine global data for how many pages were cleaned for
which reasons.  It also displays some additional counts for
various writeback events.

These data are also available for each BDI, in
/sys/block/<device>/bdi/writeback_stats .

Sample output:

   page: balance_dirty_pages           2561544
   page: background_writeout              5153
   page: try_to_free_pages                   0
   page: sync                                0
   page: kupdate                        102723
   page: fdatawrite                    1228779
   page: laptop_periodic                     0
   page: free_more_memory                    0
   page: fs_free_space                       0
   periodic writeback                      377
   single inode wait                         0
   writeback_wb wait                         1

Signed-off-by: Curt Wohlgemuth <curtw@google.com>
---

I'm not at all sure about the location of the per-BDI stat file; if
it would be better in <debugfs>/bdi/ , I'd be happy to change it.


 fs/fs-writeback.c           |   16 ++++-
 fs/proc/root.c              |    2 +
 include/linux/backing-dev.h |    6 ++
 include/linux/writeback.h   |   24 +++++++
 mm/backing-dev.c            |  152 +++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c                |    4 +
 mm/page-writeback.c         |    3 +
 7 files changed, 205 insertions(+), 2 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 40b4029..641fcc8 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -388,6 +388,8 @@ writeback_single_inode(struct inode *inode, struct bdi_writeback *wb,
 		/*
 		 * It's a data-integrity sync.  We must wait.
 		 */
+		bdi_writeback_stat_inc(inode->i_mapping->backing_dev_info,
+					WB_STAT_SINGLE_INODE_WAIT);
 		inode_wait_for_writeback(inode, wb);
 	}
 
@@ -543,6 +545,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 
 	while (!list_empty(&wb->b_io)) {
 		struct inode *inode = wb_inode(wb->b_io.prev);
+		long wrote_this_inode;
 
 		if (inode->i_sb != sb) {
 			if (work->sb) {
@@ -581,8 +584,10 @@ static long writeback_sb_inodes(struct super_block *sb,
 
 		writeback_single_inode(inode, wb, &wbc);
 
-		work->nr_pages -= write_chunk - wbc.nr_to_write;
-		wrote += write_chunk - wbc.nr_to_write;
+		wrote_this_inode = write_chunk - wbc.nr_to_write;
+
+		work->nr_pages -= wrote_this_inode;
+		wrote += wrote_this_inode;
 		if (!(inode->i_state & I_DIRTY))
 			wrote++;
 		if (wbc.pages_skipped) {
@@ -592,6 +597,9 @@ static long writeback_sb_inodes(struct super_block *sb,
 			 */
 			redirty_tail(inode, wb);
 		}
+		bdi_writeback_stat_add(wb->bdi,
+					work->reason,
+					wrote_this_inode);
 		spin_unlock(&inode->i_lock);
 		spin_unlock(&wb->list_lock);
 		iput(inode);
@@ -776,6 +784,9 @@ static long wb_writeback(struct bdi_writeback *wb,
 			trace_writeback_wait(wb->bdi, work);
 			inode = wb_inode(wb->b_more_io.prev);
 			spin_lock(&inode->i_lock);
+			bdi_writeback_stat_inc(
+					inode->i_mapping->backing_dev_info,
+					WB_STAT_WRITEBACK_WB_WAIT);
 			inode_wait_for_writeback(inode, wb);
 			spin_unlock(&inode->i_lock);
 		}
@@ -936,6 +947,7 @@ int bdi_writeback_thread(void *data)
 		 */
 		del_timer(&wb->wakeup_timer);
 
+		bdi_writeback_stat_inc(bdi, WB_STAT_PERIODIC);
 		pages_written = wb_do_writeback(wb, 0);
 
 		trace_writeback_pages_written(pages_written);
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 9a8a2b7..c0e2412 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -18,6 +18,7 @@
 #include <linux/bitops.h>
 #include <linux/mount.h>
 #include <linux/pid_namespace.h>
+#include <linux/backing-dev.h>
 
 #include "internal.h"
 
@@ -125,6 +126,7 @@ void __init proc_root_init(void)
 #endif
 	proc_mkdir("bus", NULL);
 	proc_sys_init();
+	proc_writeback_init();
 }
 
 static int proc_root_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 9da81ef..b97dd92 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -72,6 +72,7 @@ struct backing_dev_info {
 	char *name;
 
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
+	struct writeback_stats *wb_stat;
 
 	unsigned long bw_time_stamp;	/* last time write bw is updated */
 	unsigned long written_stamp;	/* pages written at bw_time_stamp */
@@ -190,6 +191,11 @@ static inline s64 bdi_stat_sum(struct backing_dev_info *bdi,
 	return sum;
 }
 
+void bdi_writeback_stat_inc(struct backing_dev_info *bdi, enum wb_stats stat);
+void bdi_writeback_stat_add(struct backing_dev_info *bdi, enum wb_stats stat,
+			    unsigned long value);
+void proc_writeback_init(void);
+
 extern void bdi_writeout_inc(struct backing_dev_info *bdi);
 
 /*
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 84d5354..8986922 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -59,13 +59,37 @@ enum wb_stats {
 	WB_STAT_TRY_TO_FREE_PAGES,
 	WB_STAT_SYNC,
 	WB_STAT_KUPDATE,
+	WB_STAT_FDATAWRITE,
 	WB_STAT_LAPTOP_TIMER,
 	WB_STAT_FREE_MORE_MEM,
 	WB_STAT_FS_FREE_SPACE,
 
+	/* These are event counts */
+	WB_STAT_PERIODIC,
+	WB_STAT_SINGLE_INODE_WAIT,
+	WB_STAT_WRITEBACK_WB_WAIT,
+
 	WB_STAT_MAX,
 };
 
+struct writeback_stats {
+	u64 stats[WB_STAT_MAX];
+};
+
+extern struct writeback_stats *writeback_sys_stats;
+
+static inline struct writeback_stats *writeback_stats_alloc(void)
+{
+	return alloc_percpu(struct writeback_stats);
+}
+
+static inline void writeback_stats_free(struct writeback_stats *stats)
+{
+	free_percpu(stats);
+}
+
+size_t writeback_stats_print(struct writeback_stats *, char *buf, size_t);
+
 /*
  * A control structure which tells the writeback code what to do.  These are
  * always on the stack, and hence need no locking.  They are always initialised
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index d6edf8d..a10eeb8 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -10,6 +10,7 @@
 #include <linux/module.h>
 #include <linux/writeback.h>
 #include <linux/device.h>
+#include <linux/proc_fs.h>
 #include <trace/events/writeback.h>
 
 static atomic_long_t bdi_seq = ATOMIC_LONG_INIT(0);
@@ -157,6 +158,13 @@ static inline void bdi_debug_unregister(struct backing_dev_info *bdi)
 }
 #endif
 
+static ssize_t writeback_stats_show(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
+	return writeback_stats_print(bdi->wb_stat, buf, PAGE_SIZE);
+}
+
 static ssize_t read_ahead_kb_store(struct device *dev,
 				  struct device_attribute *attr,
 				  const char *buf, size_t count)
@@ -229,6 +237,7 @@ static struct device_attribute bdi_dev_attrs[] = {
 	__ATTR_RW(read_ahead_kb),
 	__ATTR_RW(min_ratio),
 	__ATTR_RW(max_ratio),
+	__ATTR_RO(writeback_stats),
 	__ATTR_NULL,
 };
 
@@ -677,8 +686,13 @@ int bdi_init(struct backing_dev_info *bdi)
 
 	err = prop_local_init_percpu(&bdi->completions);
 
+	bdi->wb_stat = writeback_stats_alloc();
+	if (bdi->wb_stat == NULL)
+		err = -ENOMEM;
+
 	if (err) {
 err:
+		writeback_stats_free(bdi->wb_stat);
 		while (i--)
 			percpu_counter_destroy(&bdi->bdi_stat[i]);
 	}
@@ -711,6 +725,8 @@ void bdi_destroy(struct backing_dev_info *bdi)
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_destroy(&bdi->bdi_stat[i]);
 
+	writeback_stats_free(bdi->wb_stat);
+
 	prop_local_destroy_percpu(&bdi->completions);
 }
 EXPORT_SYMBOL(bdi_destroy);
@@ -853,3 +869,139 @@ out:
 	return ret;
 }
 EXPORT_SYMBOL(wait_iff_congested);
+
+void bdi_writeback_stat_add(struct backing_dev_info *bdi, enum wb_stats stat,
+			    unsigned long value)
+{
+	if (bdi) {
+		struct writeback_stats *stats = bdi->wb_stat;
+
+		BUG_ON(stat >= WB_STAT_MAX);
+		preempt_disable();
+		stats = per_cpu_ptr(stats, smp_processor_id());
+		stats->stats[stat] += value;
+		if (likely(writeback_sys_stats)) {
+			stats = per_cpu_ptr(writeback_sys_stats,
+					    smp_processor_id());
+			stats->stats[stat] += value;
+		}
+		preempt_enable();
+	}
+}
+
+void bdi_writeback_stat_inc(struct backing_dev_info *bdi, enum wb_stats stat)
+{
+	bdi_writeback_stat_add(bdi, stat, 1);
+}
+
+struct writeback_stats *writeback_sys_stats;
+
+enum writeback_op {
+	WB_STATS_OP,
+};
+
+static const char *wb_stats_labels[WB_STAT_MAX] = {
+	[WB_STAT_BALANCE_DIRTY] = "page: balance_dirty_pages",
+	[WB_STAT_BG_WRITEOUT] = "page: background_writeout",
+	[WB_STAT_TRY_TO_FREE_PAGES] = "page: try_to_free_pages",
+	[WB_STAT_SYNC] = "page: sync",
+	[WB_STAT_KUPDATE] = "page: kupdate",
+	[WB_STAT_FDATAWRITE] = "page: fdatawrite",
+	[WB_STAT_LAPTOP_TIMER] = "page: laptop_periodic",
+	[WB_STAT_FREE_MORE_MEM] = "page: free_more_memory",
+	[WB_STAT_FS_FREE_SPACE] = "page: fs_free_space",
+
+	[WB_STAT_PERIODIC] = "periodic writeback",
+	[WB_STAT_SINGLE_INODE_WAIT] = "single inode wait",
+	[WB_STAT_WRITEBACK_WB_WAIT] = "writeback_wb wait",
+};
+
+static void writeback_stats_collect(struct writeback_stats *src,
+			struct writeback_stats *target)
+{
+	int cpu;
+	for_each_online_cpu(cpu) {
+		int stat;
+		struct writeback_stats *stats = per_cpu_ptr(src, cpu);
+		for (stat = 0; stat < WB_STAT_MAX; stat++)
+			target->stats[stat] += stats->stats[stat];
+	}
+}
+
+static size_t writeback_stats_to_str(struct writeback_stats *stats,
+				    char *buf, size_t len)
+{
+	int bufsize = len - 1;
+	int i, printed = 0;
+	for (i = 0; i < WB_STAT_MAX; i++) {
+		const char *label = wb_stats_labels[i];
+		if (label == NULL)
+			continue;
+		printed += snprintf(buf + printed, bufsize - printed,
+				"%-32s %10llu\n", label, stats->stats[i]);
+		if (printed >= bufsize) {
+			buf[len - 1] = '\n';
+			return len;
+		}
+	}
+
+	buf[printed - 1] = '\n';
+	return printed;
+}
+
+size_t writeback_stats_print(struct writeback_stats *stats,
+			     char *buf, size_t len)
+{
+	struct writeback_stats total;
+	memset(&total, 0, sizeof(total));
+	writeback_stats_collect(stats, &total);
+	return writeback_stats_to_str(&total, buf, len);
+}
+
+
+static int writeback_seq_show(struct seq_file *m, void *data)
+{
+	char *buf;
+	size_t size;
+	switch ((enum writeback_op)m->private) {
+	case WB_STATS_OP:
+		size = seq_get_buf(m, &buf);
+		if (size == 0)
+			return 0;
+		size = writeback_stats_print(writeback_sys_stats, buf, size);
+		seq_commit(m, size);
+		break;
+	default:
+		break;
+	}
+
+	return 0;
+}
+
+static int writeback_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, writeback_seq_show, PDE(inode)->data);
+}
+
+static const struct file_operations writeback_ops = {
+	.open           = writeback_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = single_release,
+};
+
+
+void __init proc_writeback_init(void)
+{
+	struct proc_dir_entry *base_dir;
+	base_dir = proc_mkdir("writeback", NULL);
+	if (base_dir == NULL) {
+		printk(KERN_ERR "Creating /proc/writeback/ failed");
+		return;
+	}
+
+	writeback_sys_stats = alloc_percpu(struct writeback_stats);
+
+	proc_create_data("stats", S_IRUGO|S_IWUSR, base_dir,
+			&writeback_ops, (void *)WB_STATS_OP);
+}
diff --git a/mm/filemap.c b/mm/filemap.c
index 645a080..30cdf92 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -216,6 +216,10 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
 		return 0;
 
 	ret = do_writepages(mapping, &wbc);
+
+	bdi_writeback_stat_add(mapping->backing_dev_info,
+				WB_STAT_FDATAWRITE,
+				LONG_MAX - wbc.nr_to_write);
 	return ret;
 }
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 53c995e..90b1c54 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -740,6 +740,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 			long wrote;
 			wrote = writeback_inodes_wb(&bdi->wb, write_chunk);
 			pages_written += wrote;
+			bdi_writeback_stat_add(bdi,
+						WB_STAT_BALANCE_DIRTY,
+						wrote);
 			trace_balance_dirty_written(bdi, pages_written);
 			if (pages_written >= write_chunk)
 				break;		/* We've done our duty */
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB8E6B016B
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 14:39:17 -0400 (EDT)
From: Curt Wohlgemuth <curtw@google.com>
Subject: [PATCH 3/3 v3] writeback: Add writeback stats for pages written
Date: Mon, 22 Aug 2011 11:38:47 -0700
Message-Id: <1314038327-22645-3-git-send-email-curtw@google.com>
In-Reply-To: <1314038327-22645-1-git-send-email-curtw@google.com>
References: <1314038327-22645-1-git-send-email-curtw@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Curt Wohlgemuth <curtw@google.com>

Add a new file, /proc/writeback, which displays
machine global data for how many pages were cleaned for
which reasons.

These data are also available for each BDI, in
<debugfs mount point>/bdi/<device>/wbstats .

Sample output:

   page: balance_dirty_pages               708
   page: background_writeout           3705522
   page: try_to_free_pages                   0
   page: sync                                0
   page: periodic                       269589
   page: fdatawrite                     831528
   page: laptop_periodic                     0
   page: free_more_memory                    0
   page: fs_free_space                       0

Signed-off-by: Curt Wohlgemuth <curtw@google.com>
---

Changes since v2:

   - Global stats are now in /proc/writeback , not
     /proc/writeback/stats
   - Per-BDI stats are now in
        <debugfs mount point>/bdi/<device>/wbstats
     not in /sys/block/<device>/bdi/writeback_stats
   - Stats now only include pages written for each reason
   - All files are now non-writeable
             

I didn't address two issues raised by Fengguang from v2 of
this patch:

   - Global data could possibly go into /proc/vmstat, instead of
     into the new /proc/writeback file.
   - The form of the stats could be more useful if they specified
     more than just pages for each reason, but also (a) how many
     'work' items were used for each reason; and (b) how many
     chunks of pages were send for each reason.  E.g.:

                              pages  chunks  works  chunk_kb  work_kbps
       balance_dirty_pages     xx       xx     xx      
       background              xx
       sync

Fengguang, I think this might be useful, but it's a fairly
complex change, that I suspect would be better handled in a
separate patch.  What do you think?


 fs/fs-writeback.c           |   10 +++-
 fs/proc/root.c              |    2 +
 include/linux/backing-dev.h |   10 +++
 include/linux/writeback.h   |    2 +
 mm/backing-dev.c            |  143 ++++++++++++++++++++++++++++++++++++++++++-
 mm/filemap.c                |    4 +
 mm/page-writeback.c         |    7 ++-
 7 files changed, 174 insertions(+), 4 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index a004fcd..dc5ed10 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -542,6 +542,7 @@ static long writeback_sb_inodes(struct super_block *sb,
 
 	while (!list_empty(&wb->b_io)) {
 		struct inode *inode = wb_inode(wb->b_io.prev);
+		long wrote_this_inode;
 
 		if (inode->i_sb != sb) {
 			if (work->sb) {
@@ -580,8 +581,10 @@ static long writeback_sb_inodes(struct super_block *sb,
 
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
@@ -591,6 +594,9 @@ static long writeback_sb_inodes(struct super_block *sb,
 			 */
 			redirty_tail(inode, wb);
 		}
+		bdi_writeback_stat_add(wb->bdi,
+					work->reason,
+					wrote_this_inode);
 		spin_unlock(&inode->i_lock);
 		spin_unlock(&wb->list_lock);
 		iput(inode);
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
index ef85559..8899fec 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -44,6 +44,10 @@ enum bdi_stat_item {
 	NR_BDI_STAT_ITEMS
 };
 
+struct writeback_stats {
+	u64 stats[WB_REASON_MAX];
+};
+
 #define BDI_STAT_BATCH (8*(1+ilog2(nr_cpu_ids)))
 
 struct bdi_writeback {
@@ -72,6 +76,7 @@ struct backing_dev_info {
 	char *name;
 
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
+	struct writeback_stats *wb_stat;
 
 	unsigned long bw_time_stamp;	/* last time write bw is updated */
 	unsigned long written_stamp;	/* pages written at bw_time_stamp */
@@ -96,6 +101,7 @@ struct backing_dev_info {
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *debug_dir;
 	struct dentry *debug_stats;
+	struct dentry *debug_wbstats;
 #endif
 };
 
@@ -190,6 +196,10 @@ static inline s64 bdi_stat_sum(struct backing_dev_info *bdi,
 	return sum;
 }
 
+void bdi_writeback_stat_add(struct backing_dev_info *bdi,
+			    enum wb_reason reason, unsigned long value);
+void proc_writeback_init(void);
+
 extern void bdi_writeout_inc(struct backing_dev_info *bdi);
 
 /*
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index bdda069..5168ac9 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -59,6 +59,7 @@ enum wb_reason {
 	WB_REASON_TRY_TO_FREE_PAGES,
 	WB_REASON_SYNC,
 	WB_REASON_PERIODIC,
+	WB_REASON_FDATAWRITE,
 	WB_REASON_LAPTOP_TIMER,
 	WB_REASON_FREE_MORE_MEM,
 	WB_REASON_FS_FREE_SPACE,
@@ -67,6 +68,7 @@ enum wb_reason {
 	WB_REASON_MAX,
 };
 
+
 /*
  * A control structure which tells the writeback code what to do.  These are
  * always on the stack, and hence need no locking.  They are always initialised
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 474bcfe..6613391 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -10,6 +10,8 @@
 #include <linux/module.h>
 #include <linux/writeback.h>
 #include <linux/device.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <trace/events/writeback.h>
 
 static atomic_long_t bdi_seq = ATOMIC_LONG_INIT(0);
@@ -42,6 +44,8 @@ LIST_HEAD(bdi_pending_list);
 static struct task_struct *sync_supers_tsk;
 static struct timer_list sync_supers_timer;
 
+static struct writeback_stats *writeback_sys_stats;
+
 static int bdi_sync_supers(void *);
 static void sync_supers_timer_fn(unsigned long);
 
@@ -56,9 +60,77 @@ void bdi_lock_two(struct bdi_writeback *wb1, struct bdi_writeback *wb2)
 	}
 }
 
+
+static const char *wb_stats_labels[WB_REASON_MAX] = {
+	[WB_REASON_BALANCE_DIRTY] = "page: balance_dirty_pages",
+	[WB_REASON_BACKGROUND] = "page: background_writeout",
+	[WB_REASON_TRY_TO_FREE_PAGES] = "page: try_to_free_pages",
+	[WB_REASON_SYNC] = "page: sync",
+	[WB_REASON_PERIODIC] = "page: periodic",
+	[WB_REASON_FDATAWRITE] = "page: fdatawrite",
+	[WB_REASON_LAPTOP_TIMER] = "page: laptop_periodic",
+	[WB_REASON_FREE_MORE_MEM] = "page: free_more_memory",
+	[WB_REASON_FS_FREE_SPACE] = "page: fs_free_space",
+};
+
+static void writeback_stats_collect(struct writeback_stats *src,
+			struct writeback_stats *target)
+{
+	int cpu;
+	for_each_online_cpu(cpu) {
+		int stat;
+		struct writeback_stats *stats = per_cpu_ptr(src, cpu);
+		for (stat = 0; stat < WB_REASON_MAX; stat++)
+			target->stats[stat] += stats->stats[stat];
+	}
+}
+
+static size_t writeback_stats_to_str(struct writeback_stats *stats,
+				    char *buf, size_t len)
+{
+	int bufsize = len - 1;
+	int i, printed = 0;
+	for (i = 0; i < WB_REASON_MAX; i++) {
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
+static size_t writeback_stats_print(struct writeback_stats *stats,
+				     char *buf, size_t len)
+{
+	struct writeback_stats total;
+	memset(&total, 0, sizeof(total));
+	writeback_stats_collect(stats, &total);
+	return writeback_stats_to_str(&total, buf, len);
+}
+
+static int writeback_seq_show(struct seq_file *m, void *data)
+{
+	char *buf;
+	size_t size;
+	struct writeback_stats *stats = m->private;
+
+	size = seq_get_buf(m, &buf);
+	if (size == 0)
+		return 0;
+	size = writeback_stats_print(stats, buf, size);
+	seq_commit(m, size);
+	return 0;
+}
+
 #ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
-#include <linux/seq_file.h>
 
 static struct dentry *bdi_debug_root;
 
@@ -132,15 +204,34 @@ static const struct file_operations bdi_debug_stats_fops = {
 	.release	= single_release,
 };
 
+static int bdi_debug_wbstats_open(struct inode *inode, struct file *file)
+{
+	struct backing_dev_info *bdi = inode->i_private;
+	struct writeback_stats *stats = bdi->wb_stat;
+
+	return single_open(file, writeback_seq_show, (void *)stats);
+}
+
+static const struct file_operations bdi_debug_wbstats_fops = {
+	.open		= bdi_debug_wbstats_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
 {
 	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
 	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
 					       bdi, &bdi_debug_stats_fops);
+	bdi->debug_wbstats = debugfs_create_file("wbstats", 0444,
+						 bdi->debug_dir, bdi,
+						 &bdi_debug_wbstats_fops);
 }
 
 static void bdi_debug_unregister(struct backing_dev_info *bdi)
 {
+	debugfs_remove(bdi->debug_wbstats);
 	debugfs_remove(bdi->debug_stats);
 	debugfs_remove(bdi->debug_dir);
 }
@@ -157,6 +248,7 @@ static inline void bdi_debug_unregister(struct backing_dev_info *bdi)
 }
 #endif
 
+
 static ssize_t read_ahead_kb_store(struct device *dev,
 				  struct device_attribute *attr,
 				  const char *buf, size_t count)
@@ -678,8 +770,13 @@ int bdi_init(struct backing_dev_info *bdi)
 
 	err = prop_local_init_percpu(&bdi->completions);
 
+	bdi->wb_stat = alloc_percpu(struct writeback_stats);
+	if (bdi->wb_stat == NULL)
+		err = -ENOMEM;
+
 	if (err) {
 err:
+		free_percpu(bdi->wb_stat);
 		while (i--)
 			percpu_counter_destroy(&bdi->bdi_stat[i]);
 	}
@@ -712,6 +809,8 @@ void bdi_destroy(struct backing_dev_info *bdi)
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_destroy(&bdi->bdi_stat[i]);
 
+	free_percpu(bdi->wb_stat);
+
 	prop_local_destroy_percpu(&bdi->completions);
 }
 EXPORT_SYMBOL(bdi_destroy);
@@ -854,3 +953,45 @@ out:
 	return ret;
 }
 EXPORT_SYMBOL(wait_iff_congested);
+
+void bdi_writeback_stat_add(struct backing_dev_info *bdi,
+			    enum wb_reason reason, unsigned long value)
+{
+	if (bdi) {
+		struct writeback_stats *stats = bdi->wb_stat;
+
+		BUG_ON(reason >= WB_REASON_MAX);
+		preempt_disable();
+		stats = per_cpu_ptr(stats, smp_processor_id());
+		stats->stats[reason] += value;
+		if (likely(writeback_sys_stats)) {
+			stats = per_cpu_ptr(writeback_sys_stats,
+					    smp_processor_id());
+			stats->stats[reason] += value;
+		}
+		preempt_enable();
+	}
+}
+
+
+static int global_writeback_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, writeback_seq_show,
+					(void *)writeback_sys_stats);
+}
+
+static const struct file_operations global_writeback_ops = {
+	.open           = global_writeback_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = single_release,
+};
+
+
+void __init proc_writeback_init(void)
+{
+	writeback_sys_stats = alloc_percpu(struct writeback_stats);
+
+	proc_create_data("writeback", S_IRUGO, NULL,
+			&global_writeback_ops, NULL);
+}
diff --git a/mm/filemap.c b/mm/filemap.c
index 645a080..cc93a9c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -216,6 +216,10 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
 		return 0;
 
 	ret = do_writepages(mapping, &wbc);
+
+	bdi_writeback_stat_add(mapping->backing_dev_info,
+				WB_REASON_FDATAWRITE,
+				LONG_MAX - wbc.nr_to_write);
 	return ret;
 }
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0e78252..36bc09b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -737,9 +737,14 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 */
 		trace_balance_dirty_start(bdi);
 		if (bdi_nr_reclaimable > task_bdi_thresh) {
-			pages_written += writeback_inodes_wb(&bdi->wb,
+			long wrote;
+			wrote = writeback_inodes_wb(&bdi->wb,
 						write_chunk,
 						WB_REASON_BALANCE_DIRTY);
+			pages_written += wrote;
+			bdi_writeback_stat_add(bdi,
+						WB_REASON_BALANCE_DIRTY,
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

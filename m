Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 15D256B01C6
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 20:30:56 -0400 (EDT)
From: Michael Rubin <mrubin@google.com>
Subject: [PATCH 3/3] writeback: tracking subsystems causing writeback
Date: Fri, 18 Jun 2010 17:30:15 -0700
Message-Id: <1276907415-504-4-git-send-email-mrubin@google.com>
In-Reply-To: <1276907415-504-1-git-send-email-mrubin@google.com>
References: <1276907415-504-1-git-send-email-mrubin@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>
List-ID: <linux-mm.kvack.org>

Adding stats to indicate which subsystem is causing writeback.
Implemented as per cpu counters rather than tracepoints so we can gather
statistics continuously and cheaply.

Knowing what is the source of writeback acitivity can help tune and
debug applications.

The data is exported in bdi granularity at /sys/block/<dev>/bdi/writeback_stats.

    # cat /sys/block/sda/bdi/writeback_stats
    balance dirty pages                       0
    balance dirty pages waiting               0
    periodic writeback                    92024
    periodic writeback exited                 0
    laptop periodic                           0
    laptop or bg threshold                    0
    free more memory                          0
    try to free pages                       271
    syc_sync                                  6
    sync filesystem                           0

For the entire system you can find them at /sys/kernel/mm/writeback/stats.

    # cat /sys/kernel/mm/writeback/stats
    balance dirty pages                       0
    balance dirty pages waiting               0
    periodic writeback                    92892
    periodic writeback exited                13
    laptop periodic                           0
    laptop or bg threshold                    0
    free more memory                          0
    try to free pages                       271
    syc_sync                                  6
    sync filesystem                           0

Signed-off-by: Michael Rubin <mrubin@google.com>
---
 fs/buffer.c                 |    2 +-
 fs/fs-writeback.c           |   15 +++++---
 fs/sync.c                   |    2 +-
 include/linux/backing-dev.h |    8 ++++
 include/linux/writeback.h   |   50 +++++++++++++++++++++++++-
 mm/backing-dev.c            |   17 +++++++++
 mm/mm_init.c                |   82 ++++++++++++++++++++++++++++++++++++++++--
 mm/page-writeback.c         |   12 +++++--
 mm/vmscan.c                 |    3 +-
 9 files changed, 175 insertions(+), 16 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index d54812b..2a0ebe0 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -288,7 +288,7 @@ static void free_more_memory(void)
 	struct zone *zone;
 	int nid;
 
-	wakeup_flusher_threads(1024);
+	wakeup_flusher_threads(1024, WB_STAT_FREE_MORE_MEM);
 	yield();
 
 	for_each_online_node(nid) {
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 62a899e..56331b0 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -956,6 +956,7 @@ int bdi_writeback_task(struct bdi_writeback *wb)
 	long pages_written;
 
 	while (!kthread_should_stop()) {
+		bdi_writeback_stat_inc(wb->bdi, WB_STAT_PERIODIC);
 		pages_written = wb_do_writeback(wb, 0);
 
 		if (pages_written)
@@ -969,8 +970,11 @@ int bdi_writeback_task(struct bdi_writeback *wb)
 			 * recreated automatically.
 			 */
 			max_idle = max(5UL * 60 * HZ, wait_jiffies);
-			if (time_after(jiffies, max_idle + last_active))
+			if (time_after(jiffies, max_idle + last_active)) {
+				bdi_writeback_stat_inc(wb->bdi,
+						      WB_STAT_PERIODIC_EXIT);
 				break;
+			}
 		}
 
 		if (dirty_writeback_interval) {
@@ -994,7 +998,8 @@ int bdi_writeback_task(struct bdi_writeback *wb)
  * Schedule writeback for all backing devices. This does WB_SYNC_NONE
  * writeback, for integrity writeback see bdi_sync_writeback().
  */
-static void bdi_writeback_all(struct super_block *sb, long nr_pages)
+static void bdi_writeback_all(struct super_block *sb, long nr_pages,
+			      enum wb_stats stat)
 {
 	struct wb_writeback_args args = {
 		.sb		= sb,
@@ -1008,7 +1013,7 @@ static void bdi_writeback_all(struct super_block *sb, long nr_pages)
 	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
 		if (!bdi_has_dirty_io(bdi))
 			continue;
-
+		bdi_writeback_stat_inc(bdi, stat);
 		bdi_alloc_queue_work(bdi, &args);
 	}
 
@@ -1019,12 +1024,12 @@ static void bdi_writeback_all(struct super_block *sb, long nr_pages)
  * Start writeback of `nr_pages' pages.  If `nr_pages' is zero, write back
  * the whole world.
  */
-void wakeup_flusher_threads(long nr_pages)
+void wakeup_flusher_threads(long nr_pages, enum wb_stats stat)
 {
 	if (nr_pages == 0)
 		nr_pages = global_page_state(NR_FILE_DIRTY) +
 				global_page_state(NR_UNSTABLE_NFS);
-	bdi_writeback_all(NULL, nr_pages);
+	bdi_writeback_all(NULL, nr_pages, stat);
 }
 
 static noinline void block_dump___mark_inode_dirty(struct inode *inode)
diff --git a/fs/sync.c b/fs/sync.c
index 15aa6f0..6059e83 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -97,7 +97,7 @@ static void sync_filesystems(int wait)
  */
 SYSCALL_DEFINE0(sync)
 {
-	wakeup_flusher_threads(0);
+	wakeup_flusher_threads(0, WB_STAT_SYNC);
 	sync_filesystems(0);
 	sync_filesystems(1);
 	if (unlikely(laptop_mode))
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index e1fb11c..dfa7c78 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -72,6 +72,7 @@ struct backing_dev_info {
 	char *name;
 
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
+	struct writeback_stats *wb_stat;
 
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
@@ -184,6 +185,13 @@ static inline s64 bdi_stat_sum(struct backing_dev_info *bdi,
 	return sum;
 }
 
+static inline void bdi_writeback_stat_inc(struct backing_dev_info *bdi,
+					 enum wb_stats stat)
+{
+	if (bdi)
+		writeback_stats_inc(bdi->wb_stat, stat);
+}
+
 extern void bdi_writeout_inc(struct backing_dev_info *bdi);
 
 /*
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index d63ef8f..f874410 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -22,6 +22,54 @@ enum writeback_sync_modes {
 };
 
 /*
+ * why this writeback was initiated
+ */
+enum wb_stats {
+	WB_STAT_BALANCE_DIRTY,
+	WB_STAT_BALANCE_DIRTY_WAIT,
+	WB_STAT_PERIODIC,
+	WB_STAT_PERIODIC_EXIT,
+	WB_STAT_LAPTOP_TIMER,
+	WB_STAT_LAPTOP_BG,
+	WB_STAT_FREE_MORE_MEM,
+	WB_STAT_TRY_TO_FREE_PAGES,
+	WB_STAT_SYNC,
+	WB_STAT_SYNC_FS,
+	WB_STAT_MAX,
+};
+
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
+static inline void writeback_stats_inc(struct writeback_stats *stats, int stat)
+{
+	BUG_ON(stat >= WB_STAT_MAX);
+	preempt_disable();
+	stats = per_cpu_ptr(stats, smp_processor_id());
+	stats->stats[stat]++;
+	if (likely(writeback_sys_stats)) {
+		stats = per_cpu_ptr(writeback_sys_stats, smp_processor_id());
+		stats->stats[stat]++;
+	}
+	preempt_enable();
+}
+
+size_t writeback_stats_print(struct writeback_stats *, char *buf, size_t);
+
+/*
  * A control structure which tells the writeback code what to do.  These are
  * always on the stack, and hence need no locking.  They are always initialised
  * in a manner such that unspecified fields are set to zero.
@@ -68,7 +116,7 @@ int writeback_inodes_sb_if_idle(struct super_block *);
 void sync_inodes_sb(struct super_block *);
 void writeback_inodes_wbc(struct writeback_control *wbc);
 long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
-void wakeup_flusher_threads(long nr_pages);
+void wakeup_flusher_threads(long nr_pages, enum wb_stats);
 
 /* writeback.h requires fs.h; it, too, is not included from here. */
 static inline void wait_on_inode(struct inode *inode)
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 9a89296..83efc39 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -142,6 +142,13 @@ static ssize_t writeback_show(struct device *dev, struct device_attribute *attr,
 #undef K
 }
 
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
@@ -213,6 +220,7 @@ BDI_SHOW(max_ratio, bdi->max_ratio)
 static struct device_attribute bdi_dev_attrs[] = {
 	__ATTR_RO(state),
 	__ATTR_RO(writeback),
+	__ATTR_RO(writeback_stats),
 	__ATTR_RW(read_ahead_kb),
 	__ATTR_RW(min_ratio),
 	__ATTR_RW(max_ratio),
@@ -673,11 +681,18 @@ int bdi_init(struct backing_dev_info *bdi)
 			goto err;
 	}
 
+	bdi->wb_stat = writeback_stats_alloc();
+	if (bdi->wb_stat == NULL) {
+		err = -ENOMEM;
+		goto err;
+	}
+
 	bdi->dirty_exceeded = 0;
 	err = prop_local_init_percpu(&bdi->completions);
 
 	if (err) {
 err:
+		writeback_stats_free(bdi->wb_stat);
 		while (i--)
 			percpu_counter_destroy(&bdi->bdi_stat[i]);
 	}
@@ -709,6 +724,8 @@ void bdi_destroy(struct backing_dev_info *bdi)
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_destroy(&bdi->bdi_stat[i]);
 
+	writeback_stats_free(bdi->wb_stat);
+
 	prop_local_destroy_percpu(&bdi->completions);
 }
 EXPORT_SYMBOL(bdi_destroy);
diff --git a/mm/mm_init.c b/mm/mm_init.c
index 8f2ebdb..9ca5377 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -158,8 +158,74 @@ static ssize_t writeback_show(struct kobject *kobj,
 
 KERNEL_ATTR_RO(writeback);
 
+struct writeback_stats *writeback_sys_stats;
+
+static const char *wb_stats_labels[WB_STAT_MAX] = {
+	[WB_STAT_BALANCE_DIRTY] = "balance dirty pages",
+	[WB_STAT_BALANCE_DIRTY_WAIT] = "balance dirty pages waiting",
+	[WB_STAT_PERIODIC] = "periodic writeback",
+	[WB_STAT_PERIODIC_EXIT] = "periodic writeback exited",
+	[WB_STAT_LAPTOP_TIMER] = "laptop periodic",
+	[WB_STAT_LAPTOP_BG] = "laptop or bg threshold",
+	[WB_STAT_FREE_MORE_MEM] = "free more memory",
+	[WB_STAT_TRY_TO_FREE_PAGES] = "try to free pages",
+	[WB_STAT_SYNC] = "syc_sync",
+	[WB_STAT_SYNC_FS] = "sync filesystem",
+};
+
+static void writeback_stats_collect(struct writeback_stats *src,
+				    struct writeback_stats *target)
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
+				     char *buf, size_t len)
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
+static ssize_t stats_show(struct kobject *kobj,
+			  struct kobj_attribute *attr, char *buf)
+{
+	return writeback_stats_print(writeback_sys_stats, buf, PAGE_SIZE);
+}
+
+KERNEL_ATTR_RO(stats);
+
 static struct attribute *writeback_attrs[] = {
 	&writeback_attr.attr,
+	&stats_attr.attr,
 	NULL,
 };
 
@@ -177,11 +243,19 @@ static int mm_sysfs_writeback_init(void)
 		return -ENOMEM;
 
 	error = sysfs_create_group(writeback_kobj, &writeback_attr_group);
-	if (error) {
-		kobject_put(mm_kobj);
-		return -ENOMEM;
-	}
+	if (error)
+		goto err;
+
+	writeback_sys_stats = alloc_percpu(struct writeback_stats);
+	if (writeback_sys_stats == NULL)
+		goto stats_err;
 	return 0;
+
+stats_err:
+	sysfs_remove_group(writeback_kobj, &writeback_attr_group);
+err:
+	kobject_put(mm_kobj);
+	return -ENOMEM;
 }
 
 struct kobject *mm_kobj;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 4cea5c0..39d7ff2 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -537,6 +537,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * up.
 		 */
 		if (bdi_nr_reclaimable > bdi_thresh) {
+			bdi_writeback_stat_inc(bdi, WB_STAT_BALANCE_DIRTY);
 			writeback_inodes_wbc(&wbc);
 			pages_written += write_chunk - wbc.nr_to_write;
 			get_dirty_limits(&background_thresh, &dirty_thresh,
@@ -567,6 +568,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 			break;		/* We've done our duty */
 
 		__set_current_state(TASK_INTERRUPTIBLE);
+		bdi_writeback_stat_inc(bdi, WB_STAT_BALANCE_DIRTY_WAIT);
 		io_schedule_timeout(pause);
 
 		/*
@@ -596,8 +598,10 @@ static void balance_dirty_pages(struct address_space *mapping,
 	if ((laptop_mode && pages_written) ||
 	    (!laptop_mode && ((global_page_state(NR_FILE_DIRTY)
 			       + global_page_state(NR_UNSTABLE_NFS))
-					  > background_thresh)))
+					  > background_thresh))) {
+		bdi_writeback_stat_inc(bdi, WB_STAT_LAPTOP_BG);
 		bdi_start_writeback(bdi, NULL, 0);
+	}
 }
 
 void set_page_dirty_balance(struct page *page, int page_mkwrite)
@@ -700,14 +704,16 @@ void laptop_mode_timer_fn(unsigned long data)
 	struct request_queue *q = (struct request_queue *)data;
 	int nr_pages = global_page_state(NR_FILE_DIRTY) +
 		global_page_state(NR_UNSTABLE_NFS);
-
 	/*
 	 * We want to write everything out, not just down to the dirty
 	 * threshold
 	 */
 
-	if (bdi_has_dirty_io(&q->backing_dev_info))
+	if (bdi_has_dirty_io(&q->backing_dev_info)) {
+		writeback_stats_inc(q->backing_dev_info.wb_stat,
+				    WB_STAT_LAPTOP_TIMER);
 		bdi_start_writeback(&q->backing_dev_info, NULL, nr_pages);
+	}
 }
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c7e57c..ba6966e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1838,7 +1838,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
 		if (total_scanned > writeback_threshold) {
-			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);
+			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
+						WB_STAT_TRY_TO_FREE_PAGES);
 			sc->may_writepage = 1;
 		}
 
-- 
1.7.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

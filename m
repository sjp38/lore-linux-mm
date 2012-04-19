Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 90C3F6B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 01:34:19 -0400 (EDT)
Date: Thu, 19 Apr 2012 13:28:11 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Integrated IO controller for buffered+direct writes
Message-ID: <20120419052811.GA11543@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Disclaimer: this code has a lot of rough edges and assumes a simple
storage.  It's mainly to serve as a proof of concept and focuses on
getting the basic control algorithm out. It's generally working for
pure/mixed buffered/direct writes, except that it still assumes the
direct writes, if there are any, are aggressive ones. The exploration
stops here since I see no obvious way for this scheme to support
hierarchical cgroups.

Test results can be found in

	https://github.com/fengguang/io-controller-tests/blob/master/log/

The key ideas and comments can be found in two functions in the patch:
- cfq_scale_slice()
- blkcg_update_dirty_ratelimit()
The other changes are mainly supporting bits.

It adapts the existing interfaces
- blkio.throttle.write_bps_device 
- blkio.weight
from the semantics "for direct IO" to "for direct+buffered IO" (it
now handles write IO only, but should be trivial to cover reads). It
tries to do 1:1 split of direct:buffered writes inside the cgroup
which essentially implements intra-cgroup proportional weights.

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 block/blk-cgroup.c                    |   19 ++-
 block/blk-throttle.c                  |    2 +-
 block/cfq-iosched.c                   |   42 ++++-
 block/cfq.h                           |    2 +-
 fs/direct-io.c                        |    9 +
 include/linux/backing-dev.h           |   13 ++
 {block => include/linux}/blk-cgroup.h |   76 +++++++-
 include/trace/events/writeback.h      |   88 ++++++++-
 mm/backing-dev.c                      |    2 +
 mm/filemap.c                          |    1 +
 mm/page-writeback.c                   |  369 +++++++++++++++++++++++++++++++--
 11 files changed, 588 insertions(+), 35 deletions(-)
 rename {block => include/linux}/blk-cgroup.h (87%)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 126c341..56cb330 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -17,7 +17,7 @@
 #include <linux/err.h>
 #include <linux/blkdev.h>
 #include <linux/slab.h>
-#include "blk-cgroup.h"
+#include <linux/blk-cgroup.h>
 #include <linux/genhd.h>
 
 #define MAX_KEY_LEN 100
@@ -25,7 +25,11 @@
 static DEFINE_SPINLOCK(blkio_list_lock);
 static LIST_HEAD(blkio_list);
 
-struct blkio_cgroup blkio_root_cgroup = { .weight = 2*BLKIO_WEIGHT_DEFAULT };
+struct blkio_cgroup blkio_root_cgroup =
+{
+	.weight = 2*BLKIO_WEIGHT_DEFAULT,
+	.dio_weight = 2*BLKIO_WEIGHT_DEFAULT,
+};
 EXPORT_SYMBOL_GPL(blkio_root_cgroup);
 
 /* for encoding cft->private value on file */
@@ -1302,6 +1306,7 @@ static int blkio_weight_write(struct blkio_cgroup *blkcg, u64 val)
 	spin_lock(&blkio_list_lock);
 	spin_lock_irq(&blkcg->lock);
 	blkcg->weight = (unsigned int)val;
+	blkcg->dio_weight = (unsigned int)val;
 
 	hlist_for_each_entry(blkg, n, &blkcg->blkg_list, blkcg_node) {
 		pn = blkio_policy_search_node(blkcg, blkg->dev,
@@ -1564,6 +1569,8 @@ static void blkiocg_destroy(struct cgroup *cgroup)
 
 	free_css_id(&blkio_subsys, &blkcg->css);
 	rcu_read_unlock();
+	percpu_counter_destroy(&blkcg->nr_dirtied);
+	percpu_counter_destroy(&blkcg->nr_direct_write);
 	if (blkcg != &blkio_root_cgroup)
 		kfree(blkcg);
 }
@@ -1583,11 +1590,19 @@ static struct cgroup_subsys_state *blkiocg_create(struct cgroup *cgroup)
 		return ERR_PTR(-ENOMEM);
 
 	blkcg->weight = BLKIO_WEIGHT_DEFAULT;
+	blkcg->dio_weight = BLKIO_WEIGHT_DEFAULT;
+	blkcg->dirty_ratelimit = (100 << (20 - PAGE_SHIFT));
+	blkcg->balanced_dirty_ratelimit = (100 << (20 - PAGE_SHIFT));
+	blkcg->recent_dirtied_error = 1 << BLKCG_DIRTY_ERROR_SHIFT;
 done:
 	spin_lock_init(&blkcg->lock);
 	INIT_HLIST_HEAD(&blkcg->blkg_list);
 
 	INIT_LIST_HEAD(&blkcg->policy_list);
+
+	percpu_counter_init(&blkcg->nr_dirtied, 0);
+	percpu_counter_init(&blkcg->nr_direct_write, 0);
+
 	return &blkcg->css;
 }
 
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index f2ddb94..f004ccc 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -9,7 +9,7 @@
 #include <linux/blkdev.h>
 #include <linux/bio.h>
 #include <linux/blktrace_api.h>
-#include "blk-cgroup.h"
+#include <linux/blk-cgroup.h>
 #include "blk.h"
 
 /* Max dispatch from a group in 1 round */
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 3c38536..759c57a 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -541,12 +541,47 @@ cfq_prio_to_slice(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 	return cfq_prio_slice(cfqd, cfq_cfqq_sync(cfqq), cfqq->ioprio);
 }
 
-static inline u64 cfq_scale_slice(unsigned long delta, struct cfq_group *cfqg)
+extern unsigned int total_async_weight;
+
+static inline u64 cfq_scale_slice(unsigned long delta,
+				  struct cfq_group *cfqg,
+				  struct cfq_rb_root *st,
+				  bool sync)
 {
 	u64 d = delta << CFQ_SERVICE_SHIFT;
+	unsigned int weight = cfqg->weight;
+
+#ifdef CONFIG_BLK_CGROUP
+	struct blkio_cgroup *blkcg;
+
+	if (!sync && cfqg->blkg.blkcg_id == 1)
+		/*
+		 * weight for the flusher; assume no other IO in the root
+		 * cgroup for now
+		 */
+		weight = max_t(int, BLKIO_WEIGHT_MIN, total_async_weight);
+	else {
+		rcu_read_lock();
+		blkcg = task_blkio_cgroup(current);
+		if (time_is_after_eq_jiffies(blkcg->bw_time_stamp + HZ))
+			/*
+			 * weight for the direct IOs in this cgroup; the other
+			 * weight will be stealed into total_async_weight for
+			 * the async IOs, so that the flusher get proper disk
+			 * time to do async writers for duty of this cgroup.
+			 */
+			weight = blkcg->dio_weight;
+		rcu_read_unlock();
+	}
+
+	trace_printk("blkcg_id=%d charge=%lu %s_weight=%u weight=%u\n",
+		     (int)cfqg->blkg.blkcg_id, delta,
+		     sync ? "dio" : "async",
+		     weight, cfqg->weight);
+#endif
 
 	d = d * BLKIO_WEIGHT_DEFAULT;
-	do_div(d, cfqg->weight);
+	do_div(d, weight);
 	return d;
 }
 
@@ -989,7 +1024,8 @@ static void cfq_group_served(struct cfq_data *cfqd, struct cfq_group *cfqg,
 
 	/* Can't update vdisktime while group is on service tree */
 	cfq_group_service_tree_del(st, cfqg);
-	cfqg->vdisktime += cfq_scale_slice(charge, cfqg);
+	cfqg->vdisktime += cfq_scale_slice(charge, cfqg, st,
+					   cfq_cfqq_sync(cfqq));
 	/* If a new weight was requested, update now, off tree */
 	cfq_group_service_tree_add(st, cfqg);
 
diff --git a/block/cfq.h b/block/cfq.h
index 2a15592..e322f33 100644
--- a/block/cfq.h
+++ b/block/cfq.h
@@ -1,6 +1,6 @@
 #ifndef _CFQ_H
 #define _CFQ_H
-#include "blk-cgroup.h"
+#include <linux/blk-cgroup.h>
 
 #ifdef CONFIG_CFQ_GROUP_IOSCHED
 static inline void cfq_blkiocg_update_io_add_stats(struct blkio_group *blkg,
diff --git a/fs/direct-io.c b/fs/direct-io.c
index f4aadd1..e85e4da 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -37,6 +37,7 @@
 #include <linux/uio.h>
 #include <linux/atomic.h>
 #include <linux/prefetch.h>
+#include <linux/blk-cgroup.h>
 
 /*
  * How many user pages to map in one call to get_user_pages().  This determines
@@ -766,10 +767,18 @@ submit_page_section(struct dio *dio, struct dio_submit *sdio, struct page *page,
 	int ret = 0;
 
 	if (dio->rw & WRITE) {
+#ifdef CONFIG_BLK_DEV_THROTTLING
+		struct blkio_cgroup *blkcg = task_blkio_cgroup(current);
+		if (blkcg)
+			__percpu_counter_add(&blkcg->nr_direct_write, len,
+					     BDI_STAT_BATCH);
+#endif
 		/*
 		 * Read accounting is performed in submit_bio()
 		 */
 		task_io_account_write(len);
+		add_bdi_stat(dio->inode->i_mapping->backing_dev_info,
+			     BDI_DIRECT_WRITE, len);
 	}
 
 	/*
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index b1038bd..55bb537 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -42,6 +42,7 @@ enum bdi_stat_item {
 	BDI_WRITEBACK,
 	BDI_DIRTIED,
 	BDI_WRITTEN,
+	BDI_DIRECT_WRITE,
 	NR_BDI_STAT_ITEMS
 };
 
@@ -79,6 +80,8 @@ struct backing_dev_info {
 	unsigned long written_stamp;	/* pages written at bw_time_stamp */
 	unsigned long write_bandwidth;	/* the estimated write bandwidth */
 	unsigned long avg_write_bandwidth; /* further smoothed write bw */
+	unsigned long direct_write_stamp;
+	unsigned long direct_write_bandwidth;
 
 	/*
 	 * The base dirty throttle rate, re-calculated on every 200ms.
@@ -144,6 +147,16 @@ static inline void __add_bdi_stat(struct backing_dev_info *bdi,
 	__percpu_counter_add(&bdi->bdi_stat[item], amount, BDI_STAT_BATCH);
 }
 
+static inline void add_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item, s64 amount)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__add_bdi_stat(bdi, item, amount);
+	local_irq_restore(flags);
+}
+
 static inline void __inc_bdi_stat(struct backing_dev_info *bdi,
 		enum bdi_stat_item item)
 {
diff --git a/block/blk-cgroup.h b/include/linux/blk-cgroup.h
similarity index 87%
rename from block/blk-cgroup.h
rename to include/linux/blk-cgroup.h
index 6f3ace7..87082cc 100644
--- a/block/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -21,6 +21,10 @@ enum blkio_policy_id {
 	BLKIO_POLICY_THROTL,		/* Throttling */
 };
 
+#define BLKIO_WEIGHT_MIN	10
+#define BLKIO_WEIGHT_MAX	1000
+#define BLKIO_WEIGHT_DEFAULT	500
+
 /* Max limits for throttle policy */
 #define THROTL_IOPS_MAX		UINT_MAX
 
@@ -111,12 +115,34 @@ enum blkcg_file_name_throtl {
 	BLKIO_THROTL_io_serviced,
 };
 
+/* keep a history of ~50s (256 * 200ms) */
+#define BLKCG_RECENT_DIRTIED_BUCKETS	256
+
 struct blkio_cgroup {
 	struct cgroup_subsys_state css;
 	unsigned int weight;
+	unsigned int dio_weight;
 	spinlock_t lock;
 	struct hlist_head blkg_list;
 	struct list_head policy_list; /* list of blkio_policy_node */
+	struct percpu_counter nr_dirtied;
+	struct percpu_counter nr_direct_write;
+	unsigned long bw_time_stamp;
+	unsigned long dirtied_stamp;
+	unsigned long direct_write_stamp;
+	unsigned long dio_rate;
+	unsigned long dirty_rate;
+	unsigned long avg_dirty_rate;
+	unsigned long dirty_ratelimit;
+	unsigned long balanced_dirty_ratelimit;
+
+	/* optional feature: long term dirty error cancellation */
+	int recent_dirtied_error;
+	int recent_dirtied_index;
+	int recent_dirtied_sum;
+	int recent_dirtied_target_sum;
+	int recent_dirtied[BLKCG_RECENT_DIRTIED_BUCKETS];
+	int recent_dirtied_target[BLKCG_RECENT_DIRTIED_BUCKETS];
 };
 
 struct blkio_group_stats {
@@ -208,6 +234,29 @@ extern unsigned int blkcg_get_read_iops(struct blkio_cgroup *blkcg,
 extern unsigned int blkcg_get_write_iops(struct blkio_cgroup *blkcg,
 				     dev_t dev);
 
+extern struct blkio_cgroup blkio_root_cgroup;
+
+static inline bool blkcg_is_root(struct blkio_cgroup *blkcg)
+{
+	return blkcg == &blkio_root_cgroup;
+}
+static inline unsigned int blkcg_weight(struct blkio_cgroup *blkcg)
+{
+	return blkcg->weight;
+}
+static inline unsigned long blkcg_dirty_ratelimit(struct blkio_cgroup *blkcg)
+{
+	return blkcg->dirty_ratelimit;
+}
+
+#define BLKCG_DIRTY_ERROR_SHIFT 10
+static inline unsigned long blkcg_dirty_position(struct blkio_cgroup *blkcg,
+						 unsigned long pos_ratio)
+{
+	return pos_ratio * blkcg->recent_dirtied_error >>
+						BLKCG_DIRTY_ERROR_SHIFT;
+}
+
 typedef void (blkio_unlink_group_fn) (void *key, struct blkio_group *blkg);
 
 typedef void (blkio_update_group_weight_fn) (void *key,
@@ -247,6 +296,9 @@ static inline char *blkg_path(struct blkio_group *blkg)
 
 #else
 
+struct blkio_cgroup {
+};
+
 struct blkio_group {
 };
 
@@ -258,11 +310,26 @@ static inline void blkio_policy_unregister(struct blkio_policy_type *blkiop) { }
 
 static inline char *blkg_path(struct blkio_group *blkg) { return NULL; }
 
-#endif
+static inline bool blkcg_is_root(struct blkio_cgroup *blkcg)
+{
+	return true;
+}
+static inline unsigned int blkcg_weight(struct blkio_cgroup *blkcg)
+{
+	return BLKIO_WEIGHT_DEFAULT;
+}
+static inline unsigned long blkcg_dirty_ratelimit(struct blkio_cgroup *blkcg)
+{
+	return 0;
+}
 
-#define BLKIO_WEIGHT_MIN	10
-#define BLKIO_WEIGHT_MAX	1000
-#define BLKIO_WEIGHT_DEFAULT	500
+static inline unsigned long blkcg_dirty_position(struct blkio_cgroup *blkcg,
+						 unsigned long pos_ratio)
+{
+	return pos_ratio;
+}
+
+#endif
 
 #ifdef CONFIG_DEBUG_BLK_CGROUP
 void blkiocg_update_avg_queue_size_stats(struct blkio_group *blkg);
@@ -304,7 +371,6 @@ static inline void blkiocg_set_start_empty_time(struct blkio_group *blkg) {}
 #endif
 
 #if defined(CONFIG_BLK_CGROUP) || defined(CONFIG_BLK_CGROUP_MODULE)
-extern struct blkio_cgroup blkio_root_cgroup;
 extern struct blkio_cgroup *cgroup_to_blkio_cgroup(struct cgroup *cgroup);
 extern struct blkio_cgroup *task_blkio_cgroup(struct task_struct *tsk);
 extern void blkiocg_add_blkio_group(struct blkio_cgroup *blkcg,
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 7b81887..f04508c 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -248,6 +248,91 @@ TRACE_EVENT(global_dirty_state,
 
 #define KBps(x)			((x) << (PAGE_SHIFT - 10))
 
+TRACE_EVENT(blkcg_dirty_ratelimit,
+
+	TP_PROTO(struct backing_dev_info *bdi,
+		 unsigned long pps,
+		 unsigned long dirty_rate,
+		 unsigned long avg_dirty_rate,
+		 unsigned long task_ratelimit,
+		 unsigned long balanced_dirty_ratelimit,
+		 unsigned long dio_rate,
+		 unsigned long avg_dio_rate,
+		 unsigned int dio_weight,
+		 unsigned int async_weight,
+		 unsigned int total_async_weight,
+		 unsigned int recent_dirtied_error,
+		 unsigned int blkcg_id
+		 ),
+
+	TP_ARGS(bdi, pps, dirty_rate, avg_dirty_rate,
+		task_ratelimit, balanced_dirty_ratelimit,
+		dio_rate, avg_dio_rate, dio_weight, async_weight,
+		total_async_weight, recent_dirtied_error, blkcg_id),
+
+	TP_STRUCT__entry(
+		__array(char,		bdi, 32)
+		__field(unsigned long,	kbps)
+		__field(unsigned long,	dirty_rate)
+		__field(unsigned long,	avg_dirty_rate)
+		__field(unsigned long,	writeout_rate)
+		__field(unsigned long,	dirty_ratelimit)
+		__field(unsigned long,	task_ratelimit)
+		__field(unsigned long,	balanced_dirty_ratelimit)
+		__field(unsigned long,	dio_rate)
+		__field(unsigned long,	avg_dio_rate)
+		__field(unsigned int,	dio_weight)
+		__field(unsigned int,	async_weight)
+		__field(unsigned int,	total_async_weight)
+		__field(unsigned int,	recent_dirtied_error)
+		__field(unsigned int,	blkcg_id)
+	),
+
+	TP_fast_assign(
+		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
+		__entry->kbps = KBps(pps);
+		__entry->dirty_rate = KBps(dirty_rate);
+		__entry->avg_dirty_rate = KBps(avg_dirty_rate);
+		__entry->writeout_rate = KBps(bdi->avg_write_bandwidth);
+		__entry->task_ratelimit = KBps(task_ratelimit);
+		__entry->dirty_ratelimit = KBps(bdi->dirty_ratelimit);
+		__entry->balanced_dirty_ratelimit =
+					  KBps(balanced_dirty_ratelimit);
+		__entry->dio_rate = KBps(dio_rate);
+		__entry->avg_dio_rate = KBps(avg_dio_rate);
+		__entry->dio_weight = dio_weight;
+		__entry->async_weight = async_weight;
+		__entry->total_async_weight = total_async_weight;
+		__entry->recent_dirtied_error = recent_dirtied_error;
+		__entry->blkcg_id = blkcg_id;
+	),
+
+	TP_printk("bdi %s: kbps=%lu "
+		  "dirty_rate=%lu avg_dirty_rate=%lu bdi_writeout_rate=%lu "
+		  "bdi_dirty_ratelimit=%lu "
+		  "task_ratelimit=%lu "
+		  "balanced_dirty_ratelimit=%lu "
+		  "dio_rate=%lu avg_dio_rate=%lu "
+		  "dio_weight=%u async_weight=%u total_async_weight=%u "
+		  "dirty_error=%u blkcg_id=%u",
+		  __entry->bdi,
+		  __entry->kbps,
+		  __entry->dirty_rate,
+		  __entry->avg_dirty_rate,
+		  __entry->writeout_rate,
+		  __entry->dirty_ratelimit,
+		  __entry->task_ratelimit,
+		  __entry->balanced_dirty_ratelimit,
+		  __entry->dio_rate,
+		  __entry->avg_dio_rate,
+		  __entry->dio_weight,
+		  __entry->async_weight,
+		  __entry->total_async_weight,
+		  __entry->recent_dirtied_error,
+		  __entry->blkcg_id
+	)
+);
+
 TRACE_EVENT(bdi_dirty_ratelimit,
 
 	TP_PROTO(struct backing_dev_info *bdi,
@@ -269,7 +354,8 @@ TRACE_EVENT(bdi_dirty_ratelimit,
 	TP_fast_assign(
 		strlcpy(__entry->bdi, dev_name(bdi->dev), 32);
 		__entry->write_bw	= KBps(bdi->write_bandwidth);
-		__entry->avg_write_bw	= KBps(bdi->avg_write_bandwidth);
+		__entry->avg_write_bw	= KBps(bdi->avg_write_bandwidth +
+					       bdi->direct_write_bandwidth);
 		__entry->dirty_rate	= KBps(dirty_rate);
 		__entry->dirty_ratelimit = KBps(bdi->dirty_ratelimit);
 		__entry->task_ratelimit	= KBps(task_ratelimit);
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index dd8e2aa..b623358 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -99,6 +99,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "BackgroundThresh:   %10lu kB\n"
 		   "BdiDirtied:         %10lu kB\n"
 		   "BdiWritten:         %10lu kB\n"
+		   "BdiDirectWrite:     %10lu kB\n"
 		   "BdiWriteBandwidth:  %10lu kBps\n"
 		   "b_dirty:            %10lu\n"
 		   "b_io:               %10lu\n"
@@ -112,6 +113,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   K(background_thresh),
 		   (unsigned long) K(bdi_stat(bdi, BDI_DIRTIED)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN)),
+		   (unsigned long) K(bdi_stat(bdi, BDI_DIRECT_WRITE)),
 		   (unsigned long) K(bdi->write_bandwidth),
 		   nr_dirty,
 		   nr_io,
diff --git a/mm/filemap.c b/mm/filemap.c
index 79c4b2b..a945b71 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2294,6 +2294,7 @@ generic_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	}
 
 	written = mapping->a_ops->direct_IO(WRITE, iocb, iov, pos, *nr_segs);
+	inc_bdi_stat(mapping->backing_dev_info, BDI_DIRECT_WRITE);
 
 	/*
 	 * Finally, try again to invalidate clean pages which might have been
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 26adea8..f02c1bf 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -34,6 +34,7 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h> /* __set_page_dirty_buffers */
 #include <linux/pagevec.h>
+#include <linux/blk-cgroup.h>
 #include <trace/events/writeback.h>
 
 /*
@@ -736,13 +737,10 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
 	return pos_ratio;
 }
 
-static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
-				       unsigned long elapsed,
-				       unsigned long written)
+static unsigned long calc_bandwidth(unsigned long write_bandwidth,
+				    unsigned long pages, unsigned long elapsed)
 {
 	const unsigned long period = roundup_pow_of_two(3 * HZ);
-	unsigned long avg = bdi->avg_write_bandwidth;
-	unsigned long old = bdi->write_bandwidth;
 	u64 bw;
 
 	/*
@@ -752,26 +750,36 @@ static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
 	 * write_bandwidth = ---------------------------------------------------
 	 *                                          period
 	 */
-	bw = written - bdi->written_stamp;
-	bw *= HZ;
+	bw = pages * HZ;
 	if (unlikely(elapsed > period)) {
 		do_div(bw, elapsed);
-		avg = bw;
-		goto out;
+		return bw;
 	}
-	bw += (u64)bdi->write_bandwidth * (period - elapsed);
+	bw += (u64)write_bandwidth * (period - elapsed);
 	bw >>= ilog2(period);
 
+	return bw;
+}
+
+static void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
+				       unsigned long elapsed,
+				       unsigned long written)
+{
+	unsigned long avg = bdi->avg_write_bandwidth;
+	unsigned long old = bdi->write_bandwidth;
+	unsigned long bw;
+
+	bw = calc_bandwidth(old, written - bdi->written_stamp, elapsed);
+
 	/*
 	 * one more level of smoothing, for filtering out sudden spikes
 	 */
-	if (avg > old && old >= (unsigned long)bw)
+	if (avg > old && old >= bw)
 		avg -= (avg - old) >> 3;
 
-	if (avg < old && old <= (unsigned long)bw)
+	if (avg < old && old <= bw)
 		avg += (old - avg) >> 3;
 
-out:
 	bdi->write_bandwidth = bw;
 	bdi->avg_write_bandwidth = avg;
 }
@@ -864,6 +872,7 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 	 * when dirty pages are truncated by userspace or re-dirtied by FS.
 	 */
 	dirty_rate = (dirtied - bdi->dirtied_stamp) * HZ / elapsed;
+	dirty_rate += bdi->direct_write_bandwidth;
 
 	pos_ratio = bdi_position_ratio(bdi, thresh, bg_thresh, dirty,
 				       bdi_thresh, bdi_dirty);
@@ -904,13 +913,10 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 	 * the dirty count meet the setpoint, but also where the slope of
 	 * pos_ratio is most flat and hence task_ratelimit is least fluctuated.
 	 */
-	balanced_dirty_ratelimit = div_u64((u64)task_ratelimit * write_bw,
-					   dirty_rate | 1);
-	/*
-	 * balanced_dirty_ratelimit ~= (write_bw / N) <= write_bw
-	 */
-	if (unlikely(balanced_dirty_ratelimit > write_bw))
-		balanced_dirty_ratelimit = write_bw;
+	balanced_dirty_ratelimit =
+		div_u64((u64)task_ratelimit * write_bw +
+			(u64)dirty_ratelimit * bdi->direct_write_bandwidth,
+			dirty_rate | 1);
 
 	/*
 	 * We could safely do this and return immediately:
@@ -993,6 +999,7 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 	unsigned long elapsed = now - bdi->bw_time_stamp;
 	unsigned long dirtied;
 	unsigned long written;
+	unsigned long direct_written;
 
 	/*
 	 * rate-limit, only update once every 200ms.
@@ -1002,6 +1009,8 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 
 	dirtied = percpu_counter_read(&bdi->bdi_stat[BDI_DIRTIED]);
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
+	direct_written = percpu_counter_read(&bdi->bdi_stat[BDI_DIRECT_WRITE])
+							>> PAGE_CACHE_SHIFT;
 
 	/*
 	 * Skip quiet periods when disk bandwidth is under-utilized.
@@ -1010,17 +1019,23 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 	if (elapsed > HZ && time_before(bdi->bw_time_stamp, start_time))
 		goto snapshot;
 
+	bdi_update_write_bandwidth(bdi, elapsed, written);
+	bdi->direct_write_bandwidth =
+		calc_bandwidth(bdi->direct_write_bandwidth,
+			       direct_written - bdi->direct_write_stamp,
+			       elapsed);
+
 	if (thresh) {
 		global_update_bandwidth(thresh, dirty, now);
 		bdi_update_dirty_ratelimit(bdi, thresh, bg_thresh, dirty,
 					   bdi_thresh, bdi_dirty,
 					   dirtied, elapsed);
 	}
-	bdi_update_write_bandwidth(bdi, elapsed, written);
 
 snapshot:
 	bdi->dirtied_stamp = dirtied;
 	bdi->written_stamp = written;
+	bdi->direct_write_stamp = direct_written;
 	bdi->bw_time_stamp = now;
 }
 
@@ -1151,6 +1166,299 @@ static long bdi_min_pause(struct backing_dev_info *bdi,
 	return pages >= DIRTY_POLL_THRESH ? 1 + t / 2 : t;
 }
 
+
+static DEFINE_SPINLOCK(async_weight_lock);
+unsigned int total_async_weight;
+static unsigned int async_weight_val[100];
+static unsigned long async_weight_timestamp[100];
+
+#ifdef CONFIG_BLK_DEV_THROTTLING
+/*
+ * a quick hack for maintaining a sum over all active blkcg's async_weight.
+ *
+ * total_async_weight = sum(blkcg->async_weight)
+ *
+ * total_async_weight will be used as cfqg weight for the flusher.
+ */
+static void blkcg_update_async_weight(struct blkio_cgroup *blkcg,
+				      unsigned int async_weight)
+{
+	int i, j;
+
+	spin_lock(&async_weight_lock);
+	i = css_id(&blkcg->css);
+	if (i >= 100)
+		i = 99;
+	j = -async_weight_val[i];
+	async_weight_val[i] = async_weight;
+	async_weight_timestamp[i] = jiffies;
+	j += async_weight_val[i];
+	total_async_weight += j;
+	/*
+	 * retire async weights for the groups that went quiet.   Shall also
+	 * clear total_async_weight when no more buffered writes in the system.
+	 */
+	for (i = 0; i < 100; i++) {
+		if (!time_is_after_eq_jiffies(async_weight_timestamp[i] + HZ)) {
+			total_async_weight -= async_weight_val[i];
+			async_weight_val[i] = 0;
+		}
+	}
+	spin_unlock(&async_weight_lock);
+}
+
+/* optional feature: long term dirty error cancellation */
+static void blkcg_update_dirty_position(struct blkio_cgroup *blkcg,
+					struct backing_dev_info *bdi,
+					unsigned long pos_ratio,
+					unsigned long target,
+					unsigned long dirtied,
+					unsigned long elapsed)
+{
+	int i, j;
+	int recent_dirtied;
+
+	target = (target * pos_ratio * elapsed >> RATELIMIT_CALC_SHIFT) / HZ;
+	recent_dirtied = blkcg->dirtied_stamp ?
+					dirtied - blkcg->dirtied_stamp : 0;
+	i = blkcg->recent_dirtied_index;
+	blkcg->recent_dirtied_sum += recent_dirtied - blkcg->recent_dirtied[i];
+	blkcg->recent_dirtied_target_sum +=
+			target - blkcg->recent_dirtied_target[i];
+	blkcg->recent_dirtied[i] = recent_dirtied;
+	blkcg->recent_dirtied_target[i] = target;
+	if (++i >= BLKCG_RECENT_DIRTIED_BUCKETS)
+		i = 0;
+	blkcg->recent_dirtied_index = i;
+
+	i = blkcg->recent_dirtied_target_sum;
+	j = blkcg->recent_dirtied_target_sum - blkcg->recent_dirtied_sum;
+	j = clamp_val(j, -i/8, i/8);
+	blkcg->recent_dirtied_error = (1 << BLKCG_DIRTY_ERROR_SHIFT) +
+					(j << BLKCG_DIRTY_ERROR_SHIFT) / i;
+
+	trace_printk("recent_dirtied=%d/%d target=%lu/%d error=%d/%d\n",
+		     recent_dirtied, blkcg->recent_dirtied_sum,
+		     target, blkcg->recent_dirtied_target_sum,
+		     j, blkcg->recent_dirtied_error);
+}
+
+static void blkcg_update_dirty_ratelimit(struct blkio_cgroup *blkcg,
+					 struct backing_dev_info *bdi,
+					 unsigned long write_bps,
+					 unsigned long pos_ratio,
+					 unsigned long dirtied,
+					 unsigned long direct_written,
+					 unsigned long elapsed)
+{
+	unsigned long async_write_bps;
+	unsigned long blkcg_pos_ratio;
+	unsigned long ratelimit;
+	unsigned long dirty_rate;
+	unsigned long balanced_dirty_rate;
+	unsigned long task_ratelimit;
+	unsigned long dio_rate;
+	unsigned long step;
+	unsigned long x;
+	unsigned int dio_weight;
+	unsigned int async_weight;
+
+	blkcg_pos_ratio = blkcg_dirty_position(blkcg, pos_ratio);
+
+	dirty_rate = (dirtied - blkcg->dirtied_stamp) * HZ;
+	dirty_rate /= elapsed;
+	blkcg->dirty_rate = (blkcg->dirty_rate * 7 + dirty_rate) / 8,
+
+	dio_rate = (direct_written - blkcg->direct_write_stamp) * HZ;
+	dio_rate /= elapsed;
+	blkcg->dio_rate = (blkcg->dio_rate * 7 + dio_rate) / 8;
+
+	/*
+	 * write_bps will be the buffered+direct write rate limit for this
+	 * cgroup/bdi. It's computed by the proportional weight and/or
+	 * bandwidth throttle policies, whichever lower limit applies.
+	 *
+	 * If replace bdi->dirty_ratelimit with parent_blkcg->dirty_ratelimit,
+	 * it becomes a hirechichal control (may also need accounting changes).
+	 */
+	x = bdi->dirty_ratelimit * blkcg_weight(blkcg) / BLKIO_WEIGHT_DEFAULT;
+	if (!write_bps || write_bps > x)
+		write_bps = x;
+
+	/*
+	 * Target for 1:1 direct_IO:buffered_write split inside the cgroup.
+	 *
+	 * When there are both aggressive buffered and direct writers, we'll
+	 * grant half blkcg->weight to the global cgroup that holds the
+	 * flusher and another half for the direct IO inside the cgroup:
+	 *
+	 *	if (both agressive buffered and direct writers) {
+	 *		total_async_weight += blkcg->weight/2;
+	 *		blkcg->dio_weight = blkcg->weight/2;
+	 *	}
+	 *
+	 * Otherwise:
+	 *
+	 *	if (only aggressive buffered writers)
+	 *		total_async_weight += blkcg->weight;
+	 *
+	 *	if (only aggressive direct writers)
+	 *		blkcg->dio_weight = blkcg->weight;
+	 *
+	 * When the buffered and/or direct writers have long think times and
+	 * are self-throttled under (write_bps/2), it becomes tricky to
+	 * allocate the weight.
+	 *
+	 * It's fine to set
+	 *
+	 *	blkcg->dio_weight = blkcg->weight / 2;
+	 *
+	 * for a self-throttled direct writer. The extra weight simply won't be
+	 * utilized. The weight for the flusher will be:
+	 *
+	 *	total_async_weight += blkcg->weight *
+	 *	min(blkcg->dirty_rate, write_bps - blkcg->dio_rate) / write_bps;
+	 *
+	 * Unfortunately we don't know for sure whether the direct writer is
+	 * self-throttled. So that logic is not enabled currently.
+	 *
+	 * Self-throttled buffered dirtiers can be reliably detected and
+	 * handled easily this way:
+	 *
+	 *	blkcg->dio_weight = blkcg->weight *
+	 *			(write_bps - blkcg->dirty_rate) / write_bps;
+	 *	total_async_weight += blkcg->weight - blkcg->dio_weight;
+	 *
+	 * There will be no side effect if the direct writer happen to be
+	 * self-throttled and cannot utilize the allocated dio_weight.
+	 */
+
+	balanced_dirty_rate = div_u64((u64)blkcg->dirty_rate <<
+				      RATELIMIT_CALC_SHIFT, blkcg_pos_ratio + 1);
+	if (blkcg->dirty_ratelimit >= write_bps &&
+	    balanced_dirty_rate < write_bps / 2) {
+		/* self throttled buffered writes */
+		dio_weight = div_u64((u64)blkcg->weight *
+				     (write_bps - balanced_dirty_rate), write_bps);
+	} else {
+		dio_weight = blkcg->weight / 2;
+	}
+	blkcg->dio_weight = dio_weight;
+
+	if (!blkcg->dio_rate) {
+		/* no direct writes at all */
+		async_write_bps = write_bps;
+		async_weight = blkcg->weight;
+#if 0 // XXX: need some logic to detect this case, perhaps short lived cfqg?
+	} else if (dio is self-throttled under write_bps / 2)
+		async_write_bps = write_bps - blkcg->dio_rate;
+		async_weight = blkcg->weight * async_write_bps / write_bps;
+#endif
+	} else {
+		/* assume aggressive direct writes */
+		async_write_bps = write_bps / 2;
+		async_weight = blkcg->weight - dio_weight;
+	}
+
+	/*
+	 * add this blkcg's async_weight to the global total_async_weight for
+	 * use by the flusher
+	 */
+	blkcg_update_async_weight(blkcg, async_weight);
+
+	/* optional feature: long term dirty error cancellation */
+	blkcg_update_dirty_position(blkcg, bdi, pos_ratio,
+				    async_write_bps, dirtied, elapsed);
+
+	/*
+	 * given the async_write_bps target, calc the balanced dirty ratelimit
+	 * for the dirtier tasks inside the cgroup.
+	 */
+	task_ratelimit = blkcg->dirty_ratelimit * blkcg_pos_ratio >>
+							RATELIMIT_CALC_SHIFT;
+	ratelimit = div_u64((u64)task_ratelimit * async_write_bps,
+			    blkcg->dirty_rate + 1);
+	/*
+	 * update blkcg->dirty_ratelimit towards @ratelimit, limiting the step
+	 * size and filtering out noises
+	 */
+	step = 0;
+	if (blkcg->recent_dirtied_error > (1 << BLKCG_DIRTY_ERROR_SHIFT)) {
+		x = min(blkcg->balanced_dirty_ratelimit,
+			 min(ratelimit, task_ratelimit));
+		if (blkcg->dirty_ratelimit < x)
+			step = x - blkcg->dirty_ratelimit;
+	} else {
+		x = max(blkcg->balanced_dirty_ratelimit,
+			 max(ratelimit, task_ratelimit));
+		if (blkcg->dirty_ratelimit > x)
+			step = blkcg->dirty_ratelimit - x;
+	}
+	step >>= blkcg->dirty_ratelimit / (32 * step + 1);
+	step = (step + 7) / 8;
+	if (blkcg->dirty_ratelimit < ratelimit)
+		blkcg->dirty_ratelimit += step;
+	else
+		blkcg->dirty_ratelimit -= step;
+	blkcg->dirty_ratelimit++;	/* avoid stucking in 0 */
+	blkcg->dirty_ratelimit = min(blkcg->dirty_ratelimit, write_bps);
+	blkcg->balanced_dirty_ratelimit = ratelimit;
+
+	trace_blkcg_dirty_ratelimit(bdi, write_bps,
+				    dirty_rate, blkcg->dirty_rate,
+				    task_ratelimit, ratelimit,
+				    dio_rate, blkcg->dio_rate,
+				    dio_weight, async_weight, total_async_weight,
+				    blkcg->recent_dirtied_error,
+				    css_id(&blkcg->css));
+}
+
+void blkcg_update_bandwidth(struct blkio_cgroup *blkcg,
+			    struct backing_dev_info *bdi,
+			    unsigned long write_bps,
+			    unsigned long pos_ratio)
+{
+	unsigned long now = jiffies;
+	unsigned long elapsed = now - blkcg->bw_time_stamp;
+	unsigned long dirtied;
+	unsigned long direct_written;
+	unsigned long flags;
+
+	if (elapsed <= BANDWIDTH_INTERVAL)	/* avoid unnecessary locks */
+		return;
+
+	spin_lock_irqsave(&blkcg->lock, flags);
+
+	if (elapsed <= BANDWIDTH_INTERVAL)
+		goto unlock;
+
+	dirtied = percpu_counter_read(&blkcg->nr_dirtied);
+	direct_written = percpu_counter_read(&blkcg->nr_direct_write) >>
+							PAGE_CACHE_SHIFT;
+	if (elapsed > HZ)
+		goto snapshot;
+
+	blkcg_update_dirty_ratelimit(blkcg, bdi, write_bps, pos_ratio,
+				     dirtied, direct_written, elapsed);
+snapshot:
+	blkcg->dirtied_stamp = dirtied;
+	blkcg->direct_write_stamp = direct_written;
+	blkcg->bw_time_stamp = now;
+unlock:
+	spin_unlock_irqrestore(&blkcg->lock, flags);
+}
+
+#else
+
+void blkcg_update_bandwidth(struct blkio_cgroup *blkcg,
+			    struct backing_dev_info *bdi,
+			    unsigned long write_bps,
+			    unsigned long pos_ratio)
+{
+}
+
+#endif
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -1180,6 +1488,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 	unsigned long pos_ratio;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	unsigned long start_time = jiffies;
+	struct blkio_cgroup *blkcg = task_blkio_cgroup(current);
+	unsigned long blkcg_write_bps = blkcg_get_write_bps(blkcg, 0) >>
+							PAGE_CACHE_SHIFT;
 
 	for (;;) {
 		unsigned long now = jiffies;
@@ -1258,10 +1569,19 @@ static void balance_dirty_pages(struct address_space *mapping,
 				     nr_dirty, bdi_thresh, bdi_dirty,
 				     start_time);
 
-		dirty_ratelimit = bdi->dirty_ratelimit;
 		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
 					       background_thresh, nr_dirty,
 					       bdi_thresh, bdi_dirty);
+
+		if (blkcg_is_root(blkcg))
+			dirty_ratelimit = bdi->dirty_ratelimit;
+		else {
+			blkcg_update_bandwidth(blkcg, bdi,
+					       blkcg_write_bps, pos_ratio);
+			pos_ratio = blkcg_dirty_position(blkcg, pos_ratio);
+			dirty_ratelimit = blkcg_dirty_ratelimit(blkcg);
+		}
+
 		task_ratelimit = ((u64)dirty_ratelimit * pos_ratio) >>
 							RATELIMIT_CALC_SHIFT;
 		max_pause = bdi_max_pause(bdi, bdi_dirty);
@@ -1936,6 +2256,11 @@ int __set_page_dirty_no_writeback(struct page *page)
 void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
+#ifdef CONFIG_BLK_DEV_THROTTLING
+		struct blkio_cgroup *blkcg = task_blkio_cgroup(current);
+		if (blkcg)
+			__percpu_counter_add(&blkcg->nr_dirtied, 1, BDI_STAT_BATCH);
+#endif
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
-- 
1.7.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

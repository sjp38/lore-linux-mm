Message-Id: <20070911200015.989100000@chello.nl>
References: <20070911195350.825778000@chello.nl>
Date: Tue, 11 Sep 2007 21:54:13 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 23/23] debug: sysfs files for the current ratio/size/total
Content-Disposition: inline; filename=bdi_stat_debug.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Expose the per bdi dirty limits in sysfs

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 block/ll_rw_blk.c   |   81 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c |    4 +-
 2 files changed, 83 insertions(+), 2 deletions(-)

Index: linux-2.6/block/ll_rw_blk.c
===================================================================
--- linux-2.6.orig/block/ll_rw_blk.c
+++ linux-2.6/block/ll_rw_blk.c
@@ -4128,6 +4128,57 @@ static ssize_t queue_max_segments_store(
 
 	return ret;
 }
+
+extern void bdi_writeout_fraction(struct backing_dev_info *bdi,
+		long *numerator, long *denominator);
+
+static ssize_t queue_nr_cache_ratio_show(struct request_queue *q, char *page)
+{
+	long scale, div;
+
+	bdi_writeout_fraction(&q->backing_dev_info, &scale, &div);
+	scale *= 1024;
+	scale /= div;
+
+	return sprintf(page, "%ld\n", scale);
+}
+
+static ssize_t queue_nr_cache_num_show(struct request_queue *q, char *page)
+{
+	long scale, div;
+
+	bdi_writeout_fraction(&q->backing_dev_info, &scale, &div);
+
+	return sprintf(page, "%ld\n", scale);
+}
+
+static ssize_t queue_nr_cache_denom_show(struct request_queue *q, char *page)
+{
+	long scale, div;
+
+	bdi_writeout_fraction(&q->backing_dev_info, &scale, &div);
+
+	return sprintf(page, "%ld\n", div);
+}
+
+extern void
+get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
+		struct backing_dev_info *bdi);
+
+static ssize_t queue_nr_cache_size_show(struct request_queue *q, char *page)
+{
+	long background, dirty, bdi_dirty;
+	get_dirty_limits(&background, &dirty, &bdi_dirty, &q->backing_dev_info);
+	return sprintf(page, "%ld\n", bdi_dirty);
+}
+
+static ssize_t queue_nr_cache_total_show(struct request_queue *q, char *page)
+{
+	long background, dirty, bdi_dirty;
+	get_dirty_limits(&background, &dirty, &bdi_dirty, &q->backing_dev_info);
+	return sprintf(page, "%ld\n", dirty);
+}
+
 static struct queue_sysfs_entry queue_requests_entry = {
 	.attr = {.name = "nr_requests", .mode = S_IRUGO | S_IWUSR },
 	.show = queue_requests_show,
@@ -4167,6 +4218,31 @@ static struct queue_sysfs_entry queue_wr
 	.show = queue_nr_writeback_show,
 };
 
+static struct queue_sysfs_entry queue_cache_ratio_entry = {
+	.attr = {.name = "cache_ratio", .mode = S_IRUGO },
+	.show = queue_nr_cache_ratio_show,
+};
+
+static struct queue_sysfs_entry queue_cache_num_entry = {
+	.attr = {.name = "cache_num", .mode = S_IRUGO },
+	.show = queue_nr_cache_num_show,
+};
+
+static struct queue_sysfs_entry queue_cache_denom_entry = {
+	.attr = {.name = "cache_denom", .mode = S_IRUGO },
+	.show = queue_nr_cache_denom_show,
+};
+
+static struct queue_sysfs_entry queue_cache_size_entry = {
+	.attr = {.name = "cache_size", .mode = S_IRUGO },
+	.show = queue_nr_cache_size_show,
+};
+
+static struct queue_sysfs_entry queue_cache_total_entry = {
+	.attr = {.name = "cache_total", .mode = S_IRUGO },
+	.show = queue_nr_cache_total_show,
+};
+
 static struct queue_sysfs_entry queue_iosched_entry = {
 	.attr = {.name = "scheduler", .mode = S_IRUGO | S_IWUSR },
 	.show = elv_iosched_show,
@@ -4181,6 +4257,11 @@ static struct attribute *default_attrs[]
 	&queue_max_segments_entry.attr,
 	&queue_reclaimable_entry.attr,
 	&queue_writeback_entry.attr,
+	&queue_cache_ratio_entry.attr,
+	&queue_cache_num_entry.attr,
+	&queue_cache_denom_entry.attr,
+	&queue_cache_size_entry.attr,
+	&queue_cache_total_entry.attr,
 	&queue_iosched_entry.attr,
 	NULL,
 };
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -169,7 +169,7 @@ static inline void task_dirty_inc(struct
 /*
  * Obtain an accurate fraction of the BDI's portion.
  */
-static void bdi_writeout_fraction(struct backing_dev_info *bdi,
+void bdi_writeout_fraction(struct backing_dev_info *bdi,
 		long *numerator, long *denominator)
 {
 	if (bdi_cap_writeback_dirty(bdi)) {
@@ -291,7 +291,7 @@ static unsigned long determine_dirtyable
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
-static void
+void
 get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
 		 struct backing_dev_info *bdi)
 {

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

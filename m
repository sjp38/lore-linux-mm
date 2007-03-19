Message-Id: <20070319164320.873379417@programming.kicks-ass.net>
References: <20070319155737.653325176@programming.kicks-ass.net>
Date: Mon, 19 Mar 2007 16:57:43 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 6/6] mm: expose BDI statistics in sysfs.
Content-Disposition: inline; filename=bdi_stat_sysfs.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Expose the per BDI stats in /sys/block/<dev>/queue/*

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 block/ll_rw_blk.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

Index: linux-2.6/block/ll_rw_blk.c
===================================================================
--- linux-2.6.orig/block/ll_rw_blk.c
+++ linux-2.6/block/ll_rw_blk.c
@@ -3923,6 +3923,33 @@ static ssize_t queue_max_hw_sectors_show
 	return queue_var_show(max_hw_sectors_kb, (page));
 }
 
+static ssize_t queue_nr_dirty_show(struct request_queue *q, char *page)
+{
+	return sprintf(page, "%lu\n", bdi_stat(&q->backing_dev_info, BDI_DIRTY));
+}
+
+static ssize_t queue_nr_writeback_show(struct request_queue *q, char *page)
+{
+	return sprintf(page, "%lu\n", bdi_stat(&q->backing_dev_info, BDI_WRITEBACK));
+}
+
+static ssize_t queue_nr_unstable_show(struct request_queue *q, char *page)
+{
+	return sprintf(page, "%lu\n", bdi_stat(&q->backing_dev_info, BDI_UNSTABLE));
+}
+
+extern void get_writeout_scale(struct backing_dev_info *, int *, int *);
+
+static ssize_t queue_nr_cache_show(struct request_queue *q, char *page)
+{
+	int scale, div;
+
+	get_writeout_scale(&q->backing_dev_info, &scale, &div);
+	scale *= 1024;
+	scale /= div;
+
+	return sprintf(page, "%d\n", scale);
+}
 
 static struct queue_sysfs_entry queue_requests_entry = {
 	.attr = {.name = "nr_requests", .mode = S_IRUGO | S_IWUSR },
@@ -3947,6 +3974,26 @@ static struct queue_sysfs_entry queue_ma
 	.show = queue_max_hw_sectors_show,
 };
 
+static struct queue_sysfs_entry queue_dirty_entry = {
+	.attr = {.name = "dirty_pages", .mode = S_IRUGO },
+	.show = queue_nr_dirty_show,
+};
+
+static struct queue_sysfs_entry queue_writeback_entry = {
+	.attr = {.name = "writeback_pages", .mode = S_IRUGO },
+	.show = queue_nr_writeback_show,
+};
+
+static struct queue_sysfs_entry queue_unstable_entry = {
+	.attr = {.name = "unstable_pages", .mode = S_IRUGO },
+	.show = queue_nr_unstable_show,
+};
+
+static struct queue_sysfs_entry queue_cache_entry = {
+	.attr = {.name = "cache_ratio", .mode = S_IRUGO },
+	.show = queue_nr_cache_show,
+};
+
 static struct queue_sysfs_entry queue_iosched_entry = {
 	.attr = {.name = "scheduler", .mode = S_IRUGO | S_IWUSR },
 	.show = elv_iosched_show,
@@ -3958,6 +4005,10 @@ static struct attribute *default_attrs[]
 	&queue_ra_entry.attr,
 	&queue_max_hw_sectors_entry.attr,
 	&queue_max_sectors_entry.attr,
+	&queue_dirty_entry.attr,
+	&queue_writeback_entry.attr,
+	&queue_unstable_entry.attr,
+	&queue_cache_entry.attr,
 	&queue_iosched_entry.attr,
 	NULL,
 };

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

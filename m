Message-Id: <20070417071704.076707822@chello.nl>
References: <20070417071046.318415445@chello.nl>
Date: Tue, 17 Apr 2007 09:10:58 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 12/12] debug: expose BDI statistics in sysfs.
Content-Disposition: inline; filename=bdi_stat_debug.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

Expose the per BDI stats in /sys/block/<dev>/queue/*

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 block/ll_rw_blk.c   |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c |    2 +-
 2 files changed, 50 insertions(+), 1 deletion(-)

Index: linux-2.6/block/ll_rw_blk.c
===================================================================
--- linux-2.6.orig/block/ll_rw_blk.c	2007-04-12 17:35:03.000000000 +0200
+++ linux-2.6/block/ll_rw_blk.c	2007-04-12 17:36:49.000000000 +0200
@@ -3991,6 +3991,37 @@ static ssize_t queue_nr_unstable_show(st
 	return sprintf(page, "%lld\n", bdi_stat(&q->backing_dev_info, BDI_UNSTABLE));
 }
 
+extern void get_writeout_scale(struct backing_dev_info *, int *, int *);
+
+static ssize_t queue_nr_cache_ratio_show(struct request_queue *q, char *page)
+{
+	int scale, div;
+
+	get_writeout_scale(&q->backing_dev_info, &scale, &div);
+	scale *= 1024;
+	scale /= div;
+
+	return sprintf(page, "%d\n", scale);
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
@@ -4035,6 +4066,21 @@ static struct queue_sysfs_entry queue_un
 	.show = queue_nr_unstable_show,
 };
 
+static struct queue_sysfs_entry queue_cache_ratio_entry = {
+	.attr = {.name = "cache_ratio", .mode = S_IRUGO },
+	.show = queue_nr_cache_ratio_show,
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
@@ -4050,6 +4096,9 @@ static struct attribute *default_attrs[]
 	&queue_dirty_entry.attr,
 	&queue_writeback_entry.attr,
 	&queue_unstable_entry.attr,
+	&queue_cache_ratio_entry.attr,
+	&queue_cache_size_entry.attr,
+	&queue_cache_total_entry.attr,
 	&queue_iosched_entry.attr,
 	NULL,
 };
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-04-12 17:36:05.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2007-04-12 17:36:49.000000000 +0200
@@ -237,7 +237,7 @@ static unsigned long determine_dirtyable
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

Message-Id: <20070911200015.481511000@chello.nl>
References: <20070911195350.825778000@chello.nl>
Date: Tue, 11 Sep 2007 21:54:09 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 19/23] mm: expose BDI statistics in sysfs.
Content-Disposition: inline; filename=bdi_stat_sysfs.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Expose the per BDI stats in /sys/block/<dev>/queue/*

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 block/ll_rw_blk.c |   30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

Index: linux-2.6/block/ll_rw_blk.c
===================================================================
--- linux-2.6.orig/block/ll_rw_blk.c
+++ linux-2.6/block/ll_rw_blk.c
@@ -4098,6 +4098,24 @@ static ssize_t queue_max_segments_show(s
 	return queue_var_show(q->max_phys_segments, page);
 }
 
+static ssize_t queue_nr_reclaimable_show(struct request_queue *q, char *page)
+{
+	unsigned long long nr_reclaimable =
+		bdi_stat(&q->backing_dev_info, BDI_RECLAIMABLE);
+
+	return sprintf(page, "%llu\n",
+			nr_reclaimable >> (PAGE_CACHE_SHIFT - 10));
+}
+
+static ssize_t queue_nr_writeback_show(struct request_queue *q, char *page)
+{
+	unsigned long long nr_writeback =
+		bdi_stat(&q->backing_dev_info, BDI_WRITEBACK);
+
+	return sprintf(page, "%llu\n",
+			nr_writeback >> (PAGE_CACHE_SHIFT - 10));
+}
+
 static ssize_t queue_max_segments_store(struct request_queue *q,
 					const char *page, size_t count)
 {
@@ -4139,6 +4157,16 @@ static struct queue_sysfs_entry queue_ma
 	.store = queue_max_segments_store,
 };
 
+static struct queue_sysfs_entry queue_reclaimable_entry = {
+	.attr = {.name = "reclaimable_kb", .mode = S_IRUGO },
+	.show = queue_nr_reclaimable_show,
+};
+
+static struct queue_sysfs_entry queue_writeback_entry = {
+	.attr = {.name = "writeback_kb", .mode = S_IRUGO },
+	.show = queue_nr_writeback_show,
+};
+
 static struct queue_sysfs_entry queue_iosched_entry = {
 	.attr = {.name = "scheduler", .mode = S_IRUGO | S_IWUSR },
 	.show = elv_iosched_show,
@@ -4151,6 +4179,8 @@ static struct attribute *default_attrs[]
 	&queue_max_hw_sectors_entry.attr,
 	&queue_max_sectors_entry.attr,
 	&queue_max_segments_entry.attr,
+	&queue_reclaimable_entry.attr,
+	&queue_writeback_entry.attr,
 	&queue_iosched_entry.attr,
 	NULL,
 };

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

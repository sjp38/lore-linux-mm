Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 753EE6B0151
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:12 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j7so188828qaq.12
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:12 -0800 (PST)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id d108si59346322qgd.101.2015.01.06.13.27.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:11 -0800 (PST)
Received: by mail-qg0-f49.google.com with SMTP id f51so57154qge.36
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:11 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 23/45] writeback: make wakeup_flusher_threads() handle multiple bdi_writeback's
Date: Tue,  6 Jan 2015 16:26:00 -0500
Message-Id: <1420579582-8516-24-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

wakeup_flusher_threads() currently only starts writeback on the root
wb (bdi_writeback).  For cgroup writeback support, update the function
to wake up all wbs and distribute the number of pages to write
according to the proportion of each wb's write bandwidth, which is
implemented in wb_split_bdi_pages().

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c | 46 ++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 44 insertions(+), 2 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index c209ff1..8bf13e6 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -164,6 +164,34 @@ force_root:
 	dctx->wb = &bdi->wb;
 }
 
+/**
+ * wb_split_bdi_pages - split nr_pages to write according to bandwidth
+ * @wb: target bdi_writeback to split @nr_pages to
+ * @nr_pages: number of pages to write for the whole bdi
+ *
+ * Split @wb's portion of @nr_pages according to @wb's write bandwidth in
+ * relation to the total write bandwidth of all wb's w/ dirty inodes on
+ * @wb->bdi.
+ */
+static long wb_split_bdi_pages(struct bdi_writeback *wb, long nr_pages)
+{
+	unsigned long this_bw = wb->avg_write_bandwidth;
+	unsigned long tot_bw = atomic_long_read(&wb->bdi->tot_write_bandwidth);
+
+	if (nr_pages == LONG_MAX)
+		return LONG_MAX;
+
+	/*
+	 * This may be called on clean wb's and proportional distribution
+	 * may not make sense, just use the original @nr_pages in those
+	 * cases.  In general, we wanna err on the side of writing more.
+	 */
+	if (!tot_bw || this_bw >= tot_bw)
+		return nr_pages;
+	else
+		return DIV_ROUND_UP_ULL((u64)nr_pages * this_bw, tot_bw);
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
@@ -171,6 +199,11 @@ static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
 	dctx->wb = &dctx->mapping->backing_dev_info->wb;
 }
 
+static long wb_split_bdi_pages(struct bdi_writeback *wb, long nr_pages)
+{
+	return nr_pages;
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /**
@@ -1221,8 +1254,17 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
 		nr_pages = get_nr_dirty_pages();
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list)
-		wb_start_writeback(&bdi->wb, nr_pages, false, reason);
+	list_for_each_entry_rcu(bdi, &bdi_list, bdi_list) {
+		struct bdi_writeback *wb;
+		struct wb_iter iter;
+
+		if (!bdi_has_dirty_io(bdi))
+			continue;
+
+		bdi_for_each_wb(wb, bdi, &iter, 0)
+			wb_start_writeback(wb, wb_split_bdi_pages(wb, nr_pages),
+					   false, reason);
+	}
 	rcu_read_unlock();
 }
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

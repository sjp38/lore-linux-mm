Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0D045829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:37 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so22237337qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:36 -0700 (PDT)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id 194si3741035qhs.8.2015.05.22.14.15.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:36 -0700 (PDT)
Received: by qgfa63 with SMTP id a63so16284906qgf.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:36 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 41/51] writeback: make wakeup_flusher_threads() handle multiple bdi_writeback's
Date: Fri, 22 May 2015 17:13:55 -0400
Message-Id: <1432329245-5844-42-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

wakeup_flusher_threads() currently only starts writeback on the root
wb (bdi_writeback).  For cgroup writeback support, update the function
to wake up all wbs and distribute the number of pages to write
according to the proportion of each wb's write bandwidth, which is
implemented in wb_split_bdi_pages().

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 46 insertions(+), 2 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 92aaf64..508e10c 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -198,6 +198,41 @@ int inode_congested(struct inode *inode, int cong_bits)
 }
 EXPORT_SYMBOL_GPL(inode_congested);
 
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
+#else	/* CONFIG_CGROUP_WRITEBACK */
+
+static long wb_split_bdi_pages(struct bdi_writeback *wb, long nr_pages)
+{
+	return nr_pages;
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
@@ -1187,8 +1222,17 @@ void wakeup_flusher_threads(long nr_pages, enum wb_reason reason)
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
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

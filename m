Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 85A656B014F
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:08 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i8so76299qcq.11
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:08 -0800 (PST)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id k8si65704104qat.73.2015.01.06.13.27.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:07 -0800 (PST)
Received: by mail-qg0-f51.google.com with SMTP id i50so55668qgf.38
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:07 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 21/45] writeback: make writeback_in_progress() take bdi_writeback instead of backing_dev_info
Date: Tue,  6 Jan 2015 16:25:58 -0500
Message-Id: <1420579582-8516-22-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

writeback_in_progress() currently takes @bdi and returns whether
writeback is in progress on its root wb (bdi_writeback).  In
preparation for cgroup writeback support, make it take wb instead.
While at it, make it an inline function.

This patch doesn't make any functional difference.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c           | 15 +--------------
 include/linux/backing-dev.h | 12 +++++++++++-
 mm/page-writeback.c         |  4 ++--
 3 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 18d8e72..6ab113b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -53,19 +53,6 @@ struct wb_writeback_work {
 	struct completion *done;	/* set if the caller waits */
 };
 
-/**
- * writeback_in_progress - determine whether there is writeback in progress
- * @bdi: the device's backing_dev_info structure.
- *
- * Determine whether there is writeback waiting to be handled against a
- * backing device.
- */
-int writeback_in_progress(struct backing_dev_info *bdi)
-{
-	return test_bit(WB_writeback_running, &bdi->wb.state);
-}
-EXPORT_SYMBOL(writeback_in_progress);
-
 static inline struct inode *wb_inode(struct list_head *head)
 {
 	return list_entry(head, struct inode, i_wb_list);
@@ -1501,7 +1488,7 @@ int try_to_writeback_inodes_sb_nr(struct super_block *sb,
 				  unsigned long nr,
 				  enum wb_reason reason)
 {
-	if (writeback_in_progress(sb->s_bdi))
+	if (writeback_in_progress(&sb->s_bdi->wb))
 		return 1;
 
 	if (!down_read_trylock(&sb->s_umount))
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index c6278ee..953fa01 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -186,7 +186,17 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 extern struct backing_dev_info default_backing_dev_info;
 extern struct backing_dev_info noop_backing_dev_info;
 
-int writeback_in_progress(struct backing_dev_info *bdi);
+/**
+ * writeback_in_progress - determine whether there is writeback in progress
+ * @wb: bdi_writeback of interest
+ *
+ * Determine whether there is writeback waiting to be handled against a
+ * bdi_writeback.
+ */
+static inline bool writeback_in_progress(struct bdi_writeback *wb)
+{
+	return test_bit(WB_writeback_running, &wb->state);
+}
 
 static inline int wb_congested(struct bdi_writeback *wb, int bdi_bits)
 {
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 190e2a2..b250ee2 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1449,7 +1449,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 			break;
 		}
 
-		if (unlikely(!writeback_in_progress(bdi)))
+		if (unlikely(!writeback_in_progress(wb)))
 			bdi_start_background_writeback(bdi);
 
 		if (!strictlimit)
@@ -1568,7 +1568,7 @@ pause:
 	if (!dirty_exceeded && wb->dirty_exceeded)
 		wb->dirty_exceeded = 0;
 
-	if (writeback_in_progress(bdi))
+	if (writeback_in_progress(wb))
 		return;
 
 	/*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 800486B00C8
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:06:20 -0400 (EDT)
Received: by qkx62 with SMTP id 62so31198599qkx.0
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:06:20 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id f10si5131380qkf.112.2015.04.06.12.59.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 12:59:56 -0700 (PDT)
Received: by qku63 with SMTP id 63so30982894qku.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 12:59:56 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 38/49] writeback: make writeback_in_progress() take bdi_writeback instead of backing_dev_info
Date: Mon,  6 Apr 2015 15:58:27 -0400
Message-Id: <1428350318-8215-39-git-send-email-tj@kernel.org>
In-Reply-To: <1428350318-8215-1-git-send-email-tj@kernel.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

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
index de309fa..ddb3178 100644
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
@@ -1455,7 +1442,7 @@ int try_to_writeback_inodes_sb_nr(struct super_block *sb,
 				  unsigned long nr,
 				  enum wb_reason reason)
 {
-	if (writeback_in_progress(sb->s_bdi))
+	if (writeback_in_progress(&sb->s_bdi->wb))
 		return 1;
 
 	if (!down_read_trylock(&sb->s_umount))
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 0ff40c2..f04956c 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -156,7 +156,17 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 
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
 
 static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
 {
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 5458762..3a19641 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1455,7 +1455,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 			break;
 		}
 
-		if (unlikely(!writeback_in_progress(bdi)))
+		if (unlikely(!writeback_in_progress(wb)))
 			bdi_start_background_writeback(bdi);
 
 		if (!strictlimit)
@@ -1573,7 +1573,7 @@ pause:
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

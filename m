Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 912166B0109
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 14:30:00 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id dc16so16676517qab.36
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:30:00 -0800 (PST)
Received: from mail-qc0-x22c.google.com (mail-qc0-x22c.google.com. [2607:f8b0:400d:c01::22c])
        by mx.google.com with ESMTPS id s18si65384025qam.4.2015.01.06.11.29.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 11:29:52 -0800 (PST)
Received: by mail-qc0-f172.google.com with SMTP id m20so17470124qcx.31
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 11:29:52 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 16/16] writeback: move inode_to_bdi() to include/linux/backing-dev.h
Date: Tue,  6 Jan 2015 14:29:17 -0500
Message-Id: <1420572557-11572-17-git-send-email-tj@kernel.org>
In-Reply-To: <1420572557-11572-1-git-send-email-tj@kernel.org>
References: <1420572557-11572-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, Tejun Heo <tj@kernel.org>

inode_to_bdi() will be used by inline functions for the planned cgroup
writeback support.  Move it to include/linux/backing-dev.h.

This patch doesn't introduce any behavior changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c           | 10 ----------
 include/linux/backing-dev.h | 10 ++++++++++
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 41c9f1e..5130895 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -66,16 +66,6 @@ int writeback_in_progress(struct backing_dev_info *bdi)
 }
 EXPORT_SYMBOL(writeback_in_progress);
 
-static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
-{
-	struct super_block *sb = inode->i_sb;
-
-	if (sb_is_blkdev_sb(sb))
-		return inode->i_mapping->backing_dev_info;
-
-	return sb->s_bdi;
-}
-
 static inline struct inode *wb_inode(struct list_head *head)
 {
 	return list_entry(head, struct inode, i_wb_list);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 918f5c9..3c6fd34 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -253,4 +253,14 @@ static inline int bdi_sched_wait(void *word)
 	return 0;
 }
 
+static inline struct backing_dev_info *inode_to_bdi(struct inode *inode)
+{
+	struct super_block *sb = inode->i_sb;
+
+	if (sb_is_blkdev_sb(sb))
+		return inode->i_mapping->backing_dev_info;
+
+	return sb->s_bdi;
+}
+
 #endif		/* _LINUX_BACKING_DEV_H */
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id A0726829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:27 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so22234469qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:27 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id e109si1947609qgf.118.2015.05.22.14.15.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:27 -0700 (PDT)
Received: by qget53 with SMTP id t53so16190737qge.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:26 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 36/51] writeback: implement bdi_for_each_wb()
Date: Fri, 22 May 2015 17:13:50 -0400
Message-Id: <1432329245-5844-37-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

This will be used to implement bdi-wide operations which should be
distributed across all its cgroup bdi_writebacks.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 include/linux/backing-dev.h | 63 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 63 insertions(+)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 0839e44..c797980 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -383,6 +383,61 @@ static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
 	return inode->i_wb;
 }
 
+struct wb_iter {
+	int			start_blkcg_id;
+	struct radix_tree_iter	tree_iter;
+	void			**slot;
+};
+
+static inline struct bdi_writeback *__wb_iter_next(struct wb_iter *iter,
+						   struct backing_dev_info *bdi)
+{
+	struct radix_tree_iter *titer = &iter->tree_iter;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	if (iter->start_blkcg_id >= 0) {
+		iter->slot = radix_tree_iter_init(titer, iter->start_blkcg_id);
+		iter->start_blkcg_id = -1;
+	} else {
+		iter->slot = radix_tree_next_slot(iter->slot, titer, 0);
+	}
+
+	if (!iter->slot)
+		iter->slot = radix_tree_next_chunk(&bdi->cgwb_tree, titer, 0);
+	if (iter->slot)
+		return *iter->slot;
+	return NULL;
+}
+
+static inline struct bdi_writeback *__wb_iter_init(struct wb_iter *iter,
+						   struct backing_dev_info *bdi,
+						   int start_blkcg_id)
+{
+	iter->start_blkcg_id = start_blkcg_id;
+
+	if (start_blkcg_id)
+		return __wb_iter_next(iter, bdi);
+	else
+		return &bdi->wb;
+}
+
+/**
+ * bdi_for_each_wb - walk all wb's of a bdi in ascending blkcg ID order
+ * @wb_cur: cursor struct bdi_writeback pointer
+ * @bdi: bdi to walk wb's of
+ * @iter: pointer to struct wb_iter to be used as iteration buffer
+ * @start_blkcg_id: blkcg ID to start iteration from
+ *
+ * Iterate @wb_cur through the wb's (bdi_writeback's) of @bdi in ascending
+ * blkcg ID order starting from @start_blkcg_id.  @iter is struct wb_iter
+ * to be used as temp storage during iteration.  rcu_read_lock() must be
+ * held throughout iteration.
+ */
+#define bdi_for_each_wb(wb_cur, bdi, iter, start_blkcg_id)		\
+	for ((wb_cur) = __wb_iter_init(iter, bdi, start_blkcg_id);	\
+	     (wb_cur); (wb_cur) = __wb_iter_next(iter, bdi))
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline bool inode_cgwb_enabled(struct inode *inode)
@@ -445,6 +500,14 @@ static inline void wb_blkcg_offline(struct blkcg *blkcg)
 {
 }
 
+struct wb_iter {
+	int		next_id;
+};
+
+#define bdi_for_each_wb(wb_cur, bdi, iter, start_blkcg_id)		\
+	for ((iter)->next_id = (start_blkcg_id);			\
+	     ({	(wb_cur) = !(iter)->next_id++ ? &(bdi)->wb : NULL; }); )
+
 static inline int inode_congested(struct inode *inode, int cong_bits)
 {
 	return wb_congested(&inode_to_bdi(inode)->wb, cong_bits);
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

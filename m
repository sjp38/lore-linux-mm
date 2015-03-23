Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8C36B0070
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:56:23 -0400 (EDT)
Received: by qcbjx9 with SMTP id jx9so98009851qcb.0
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:56:23 -0700 (PDT)
Received: from mail-qc0-x233.google.com (mail-qc0-x233.google.com. [2607:f8b0:400d:c01::233])
        by mx.google.com with ESMTPS id x10si11236949qgx.9.2015.03.22.21.56.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:56:05 -0700 (PDT)
Received: by qcto4 with SMTP id o4so136682180qct.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:56:05 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 34/48] writeback: implement bdi_for_each_wb()
Date: Mon, 23 Mar 2015 00:54:45 -0400
Message-Id: <1427086499-15657-35-git-send-email-tj@kernel.org>
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

This will be used to implement bdi-wide operations which should be
distributed across all its cgroup bdi_writebacks.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 include/linux/backing-dev.h | 63 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 63 insertions(+)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 433b308..9dc4eea 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -384,6 +384,61 @@ static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
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
@@ -446,6 +501,14 @@ static inline void wb_blkcg_offline(struct blkcg *blkcg)
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
 static inline int mapping_congested(struct address_space *mapping,
 				    struct task_struct *task, int cong_bits)
 {
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

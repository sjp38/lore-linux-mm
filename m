Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id EF8996B00AD
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:56:10 -0400 (EDT)
Received: by qgf74 with SMTP id 74so11439883qgf.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:56:10 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id m8si11293851qck.0.2015.03.22.21.55.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:55:56 -0700 (PDT)
Received: by qgep97 with SMTP id p97so5690754qge.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:55 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 28/48] writeback: implement and use mapping_congested()
Date: Mon, 23 Mar 2015 00:54:39 -0400
Message-Id: <1427086499-15657-29-git-send-email-tj@kernel.org>
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

In several places, bdi_congested() and its wrappers are used to
determine whether more IOs should be issued.  With cgroup writeback
support, this question can't be answered solely based on the bdi
(backing_dev_info).  It's dependent on whether the filesystem and bdi
support cgroup writeback and the blkcg the asking task belongs to.

This patch implements mapping_congested() and its wrappers which take
@mapping and @task and determines the congestion state considering
cgroup writeback for the combination.  The new functions replace
bdi_*congested() calls in places where the query is about specific
mapping and task.

There are several filesystem users which also fit this criteria but
they should be updated when each filesystem implements cgroup
writeback support.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>
---
 fs/fs-writeback.c           | 39 +++++++++++++++++++++++++++++++++++++++
 include/linux/backing-dev.h | 27 +++++++++++++++++++++++++++
 mm/fadvise.c                |  2 +-
 mm/readahead.c              |  2 +-
 mm/vmscan.c                 | 12 ++++++------
 5 files changed, 74 insertions(+), 8 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 48db5e6..015f359 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -130,6 +130,45 @@ static void __wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
 	wb_queue_work(wb, work);
 }
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+
+/**
+ * mapping_congested - test whether a mapping is congested for a task
+ * @mapping: address space to test for congestion
+ * @task: task to test congestion for
+ * @cong_bits: mask of WB_[a]sync_congested bits to test
+ *
+ * Tests whether @mapping is congested for @task.  @cong_bits is the mask
+ * of congestion bits to test and the return value is the mask of set bits.
+ *
+ * If cgroup writeback is enabled for @mapping, its congestion state for
+ * @task is determined by whether the cgwb (cgroup bdi_writeback) for the
+ * blkcg of %current on @mapping->backing_dev_info is congested; otherwise,
+ * the root's congestion state is used.
+ */
+int mapping_congested(struct address_space *mapping,
+		      struct task_struct *task, int cong_bits)
+{
+	struct inode *inode = mapping->host;
+	struct backing_dev_info *bdi = inode_to_bdi(inode);
+	struct bdi_writeback *wb;
+	int ret = 0;
+
+	if (!inode || !inode_cgwb_enabled(inode))
+		return wb_congested(&bdi->wb, cong_bits);
+
+	rcu_read_lock();
+	wb = wb_find_current(bdi);
+	if (wb)
+		ret = wb_congested(wb, cong_bits);
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mapping_congested);
+
+#endif	/* CONFIG_CGROUP_WRITEBACK */
+
 /**
  * bdi_start_writeback - start writeback
  * @bdi: the backing device to write from
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 2c498a2..cfa23ab 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -230,6 +230,8 @@ struct bdi_writeback *wb_get_create(struct backing_dev_info *bdi,
 void __inode_attach_wb(struct inode *inode, struct page *page);
 void wb_memcg_offline(struct mem_cgroup *memcg);
 void wb_blkcg_offline(struct blkcg *blkcg);
+int mapping_congested(struct address_space *mapping, struct task_struct *task,
+		      int cong_bits);
 
 /**
  * inode_cgwb_enabled - test whether cgroup writeback is enabled on an inode
@@ -438,8 +440,33 @@ static inline void wb_blkcg_offline(struct blkcg *blkcg)
 {
 }
 
+static inline int mapping_congested(struct address_space *mapping,
+				    struct task_struct *task, int cong_bits)
+{
+	return wb_congested(&inode_to_bdi(mapping->host)->wb, cong_bits);
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
+static inline int mapping_read_congested(struct address_space *mapping,
+					 struct task_struct *task)
+{
+	return mapping_congested(mapping, task, 1 << WB_sync_congested);
+}
+
+static inline int mapping_write_congested(struct address_space *mapping,
+					  struct task_struct *task)
+{
+	return mapping_congested(mapping, task, 1 << WB_async_congested);
+}
+
+static inline int mapping_rw_congested(struct address_space *mapping,
+				       struct task_struct *task)
+{
+	return mapping_congested(mapping, task, (1 << WB_sync_congested) |
+						(1 << WB_async_congested));
+}
+
 static inline int bdi_congested(struct backing_dev_info *bdi, int cong_bits)
 {
 	return wb_congested(&bdi->wb, cong_bits);
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 4a3907c..174727c 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -115,7 +115,7 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 	case POSIX_FADV_NOREUSE:
 		break;
 	case POSIX_FADV_DONTNEED:
-		if (!bdi_write_congested(bdi))
+		if (!mapping_write_congested(mapping, current))
 			__filemap_fdatawrite_range(mapping, offset, endbyte,
 						   WB_SYNC_NONE);
 
diff --git a/mm/readahead.c b/mm/readahead.c
index 9356758..420a16a 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -541,7 +541,7 @@ page_cache_async_readahead(struct address_space *mapping,
 	/*
 	 * Defer asynchronous read-ahead on IO congestion.
 	 */
-	if (bdi_read_congested(inode_to_bdi(mapping->host)))
+	if (mapping_read_congested(mapping, current))
 		return;
 
 	/* do read-ahead */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7582f9f..9f8d3c0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -452,14 +452,14 @@ static inline int is_page_cache_freeable(struct page *page)
 	return page_count(page) - page_has_private(page) == 2;
 }
 
-static int may_write_to_queue(struct backing_dev_info *bdi,
-			      struct scan_control *sc)
+static int may_write_to_mapping(struct address_space *mapping,
+				struct scan_control *sc)
 {
 	if (current->flags & PF_SWAPWRITE)
 		return 1;
-	if (!bdi_write_congested(bdi))
+	if (!mapping_write_congested(mapping, current))
 		return 1;
-	if (bdi == current->backing_dev_info)
+	if (inode_to_bdi(mapping->host) == current->backing_dev_info)
 		return 1;
 	return 0;
 }
@@ -538,7 +538,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	}
 	if (mapping->a_ops->writepage == NULL)
 		return PAGE_ACTIVATE;
-	if (!may_write_to_queue(inode_to_bdi(mapping->host), sc))
+	if (!may_write_to_mapping(mapping, sc))
 		return PAGE_KEEP;
 
 	if (clear_page_dirty_for_io(page)) {
@@ -924,7 +924,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		mapping = page_mapping(page);
 		if (((dirty || writeback) && mapping &&
-		     bdi_write_congested(inode_to_bdi(mapping->host))) ||
+		     mapping_write_congested(mapping, current)) ||
 		    (writeback && PageReclaim(page)))
 			nr_congested++;
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

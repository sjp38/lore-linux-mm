Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 75DA36B013C
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:52 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id l89so53371qgf.40
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:52 -0800 (PST)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com. [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id k10si65721108qay.56.2015.01.06.13.26.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:51 -0800 (PST)
Received: by mail-qa0-f44.google.com with SMTP id bm13so227152qab.3
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:50 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 12/45] writeback: implement and use mapping_congested()
Date: Tue,  6 Jan 2015 16:25:49 -0500
Message-Id: <1420579582-8516-13-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

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
 fs/fs-writeback.c           | 34 ++++++++++++++++++++++++++++++++++
 include/linux/backing-dev.h | 27 +++++++++++++++++++++++++++
 mm/fadvise.c                |  2 +-
 mm/readahead.c              |  2 +-
 mm/vmscan.c                 | 12 ++++++------
 5 files changed, 69 insertions(+), 8 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 3b54835..43c1fb2 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -109,6 +109,40 @@ out_unlock:
 #ifdef CONFIG_CGROUP_WRITEBACK
 
 /**
+ * mapping_congested - test whether a mapping is congested for a task
+ * @mapping: address space to test for congestion
+ * @task: task to test congestion for
+ * @bdi_bits: mask of WB_[a]sync_congested bits to test
+ *
+ * Tests whether @mapping is congested for @task.  @bdi_bits is the mask of
+ * congestion bits to test and the return value is the mask of set bits.
+ *
+ * If cgroup writeback is enabled for @mapping, its congestion state for
+ * @task is determined by whether the cgwb (cgroup bdi_writeback) for the
+ * blkcg of %current on @mapping->backing_dev_info is congested; otherwise,
+ * the root's congestion state is used.
+ */
+int mapping_congested(struct address_space *mapping,
+		      struct task_struct *task, int bdi_bits)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	struct bdi_writeback *wb;
+	int ret = 0;
+
+	if (!mapping_cgwb_enabled(mapping))
+		return wb_congested(&bdi->wb, bdi_bits);
+
+	rcu_read_lock();
+	wb = cgwb_lookup(bdi, task_css(task, blkio_cgrp_id));
+	if (wb)
+		ret = wb_congested(wb, bdi_bits);
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mapping_congested);
+
+/**
  * init_cgwb_dirty_page_context - init cgwb part of dirty_context
  * @dctx: dirty_context being initialized
  *
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index be66668..0b1ac4b 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -263,6 +263,8 @@ void init_dirty_inode_context(struct dirty_context *dctx, struct inode *inode);
 void cgwb_blkcg_released(struct cgroup_subsys_state *blkcg_css);
 int __cgwb_create(struct backing_dev_info *bdi,
 		  struct cgroup_subsys_state *blkcg_css);
+int mapping_congested(struct address_space *mapping, struct task_struct *task,
+		      int bdi_bits);
 
 /**
  * mapping_cgwb_enabled - test whether cgroup writeback is enabled on a mapping
@@ -383,6 +385,12 @@ static inline void cgwb_blkcg_released(struct cgroup_subsys_state *blkcg_css)
 {
 }
 
+static inline int mapping_congested(struct address_space *mapping,
+				    struct task_struct *task, int bdi_bits)
+{
+	return wb_congested(&mapping->backing_dev_info->wb, bdi_bits);
+}
+
 static inline struct bdi_writeback *
 cgwb_lookup(struct backing_dev_info *bdi, struct cgroup_subsys_state *blkcg_css)
 {
@@ -408,6 +416,25 @@ static inline struct bdi_writeback *page_cgwb_wb(struct page *page)
 
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
 static inline int bdi_congested(struct backing_dev_info *bdi, int bdi_bits)
 {
 	return wb_congested(&bdi->wb, bdi_bits);
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 2ad7adf..c7347d7 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -113,7 +113,7 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 	case POSIX_FADV_NOREUSE:
 		break;
 	case POSIX_FADV_DONTNEED:
-		if (!bdi_write_congested(mapping->backing_dev_info))
+		if (!mapping_write_congested(mapping, current))
 			__filemap_fdatawrite_range(mapping, offset, endbyte,
 						   WB_SYNC_NONE);
 
diff --git a/mm/readahead.c b/mm/readahead.c
index 17b9172..beb930c 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -541,7 +541,7 @@ page_cache_async_readahead(struct address_space *mapping,
 	/*
 	 * Defer asynchronous read-ahead on IO congestion.
 	 */
-	if (bdi_read_congested(mapping->backing_dev_info))
+	if (mapping_read_congested(mapping, current))
 		return;
 
 	/* do read-ahead */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8772b..95b98c7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -411,14 +411,14 @@ static inline int is_page_cache_freeable(struct page *page)
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
+	if (mapping->backing_dev_info == current->backing_dev_info)
 		return 1;
 	return 0;
 }
@@ -497,7 +497,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	}
 	if (mapping->a_ops->writepage == NULL)
 		return PAGE_ACTIVATE;
-	if (!may_write_to_queue(mapping->backing_dev_info, sc))
+	if (!may_write_to_mapping(mapping, sc))
 		return PAGE_KEEP;
 
 	if (clear_page_dirty_for_io(page)) {
@@ -885,7 +885,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		mapping = page_mapping(page);
 		if (((dirty || writeback) && mapping &&
-		     bdi_write_congested(mapping->backing_dev_info)) ||
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

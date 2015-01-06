Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id AD88C6B0178
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:46 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id i8so77100qcq.11
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:46 -0800 (PST)
Received: from mail-qa0-x234.google.com (mail-qa0-x234.google.com. [2607:f8b0:400d:c00::234])
        by mx.google.com with ESMTPS id j4si2489583qaz.130.2015.01.06.13.27.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:45 -0800 (PST)
Received: by mail-qa0-f52.google.com with SMTP id v10so189170qac.11
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:45 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 42/45] writeback: make __filemap_fdatawrite_range() croup writeback aware
Date: Tue,  6 Jan 2015 16:26:19 -0500
Message-Id: <1420579582-8516-43-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

__filemap_fdatawrite_range() and its friends are used, among other
things, to implement fsync and coordinate buffered and direct IOs.
The function directly invokes do_writepages() bypassing the usual fs
writeback mechanism and thus currently doesn't respect cgroup
writeback.

This patch adds wb_writeback_work->mapping[_range_{start|end}] which
are used to instruct wb_writeback_work item to execute do_writepages()
on a single mapping.  A new function cgwb_do_writepages() is added
which splits do_writepages() to all dirtying wb's (bdi_writeback's)
using this new work type.  __filemap_fdatawrite_range() is updated to
use cgwb_do_writepages() instead of do_writepages().

cgwb_do_writepages() first tries direct do_writepages() on the current
blkcg as it's likely that the calling cgroup is trying to flush pages
that it dirtied.  If that doesn't write out all pages, it issues
single mappign work items to all wb's with dirty pages on the target
mapping.  It currently doesn't distribute wbc->nr_to_write according
to the bandwidth proportion of each wb.  If this ever becomes
necessary, implementing it shouldn't be too difficult.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c           | 149 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/backing-dev.h |   8 +++
 mm/filemap.c                |   2 +-
 3 files changed, 157 insertions(+), 2 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 2bb14d5..cea13fe 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -36,6 +36,9 @@
 
 struct wb_completion {
 	atomic_t		cnt;
+#ifdef CONFIG_CGROUP_WRITEBACK
+	int			mapping_ret;	/* used by works w/ ->mapping */
+#endif
 };
 
 /*
@@ -43,8 +46,19 @@ struct wb_completion {
  */
 struct wb_writeback_work {
 	long nr_pages;
+
 	struct super_block *sb;
 	unsigned long *older_than_this;
+
+	/*
+	 * If ->mapping is set, only that mapping is written out using
+	 * do_writepages().  ->mapping_range_{start|end} are meaningful
+	 * only in such cases.
+	 */
+	struct address_space *mapping;
+	loff_t mapping_range_start;
+	loff_t mapping_range_end;
+
 	enum writeback_sync_modes sync_mode;
 	unsigned int tagged_writepages:1;
 	unsigned int for_kupdate:1;
@@ -697,6 +711,133 @@ static inline bool wbc_skip_metadata(struct writeback_control *wbc)
 	return wbc->iwbl && !iwbl_is_root(wbc->iwbl);
 }
 
+static bool cgwb_do_writepages_split_work(struct inode_wb_link *iwbl,
+					  struct wb_writeback_work *base_work)
+{
+	struct bdi_writeback *wb = iwbl_to_wb(iwbl);
+
+	/* if DIRTY_PAGES isn't visible yet, neither is the dirty data */
+	if (!test_bit(IWBL_DIRTY_PAGES, &iwbl->data))
+		return true;
+
+	return wb_clone_and_queue_work(wb, base_work);
+}
+
+/**
+ * cgwb_do_writepages - cgroup-aware do_writepages()
+ * @mapping: address_space to write out
+ * @wbc: writeback_control in effect
+ *
+ * Write out pages from @mapping according to @wbc.  This function expects
+ * @mapping to be a file backed one.  If cgroup writeback is enabled, the
+ * writes are distributed across the cgroups which dirtied the pages;
+ * otherwise, this is equivalent to do_writepages().  Returns 0 on success,
+ * -errno on failre.
+ */
+int cgwb_do_writepages(struct address_space *mapping,
+		       struct writeback_control *wbc)
+{
+	DEFINE_WB_COMPLETION_ONSTACK(done);
+	struct inode *inode = mapping->host;
+	struct backing_dev_info *bdi = inode_to_bdi(inode);
+	struct wb_writeback_work base_work = {
+		.mapping		= mapping,
+		.mapping_range_start	= wbc->range_start,
+		.mapping_range_end	= wbc->range_end,
+		.nr_pages		= wbc->nr_to_write,
+		.sync_mode		= wbc->sync_mode,
+		.tagged_writepages	= wbc->tagged_writepages,
+		.for_kupdate		= wbc->for_kupdate,
+		.range_cyclic		= wbc->range_cyclic,
+		.for_background		= wbc->for_background,
+		.for_sync		= wbc->for_sync,
+		.done			= &done,
+	};
+	struct cgroup_subsys_state *blkcg_css;
+	struct inode_wb_link *iwbl;
+	struct inode_cgwb_link *icgwbl, *n;
+	int last_blkcg_id = 0, ret;
+
+	/*
+	 * The caller is likely flushing the pages it dirtied.  First look
+	 * up the current iwbl and perform do_writepages() directly on it.
+	 * If no page is skipped due to mismatching cgroup, there's nothing
+	 * more to do.
+	 */
+	blkcg_css = task_get_css(current, blkio_cgrp_id);
+	iwbl = iwbl_lookup(inode, blkcg_css);
+	if (iwbl) {
+		wbc_set_iwbl(wbc, iwbl);
+		wbc->iwbl_mismatch = 0;
+
+		ret = do_writepages(mapping, wbc);
+
+		css_put(blkcg_css);
+		if (ret || !wbc->iwbl_mismatch)
+			return ret;
+	} else {
+		css_put(blkcg_css);
+	}
+
+	/*
+	 * Split writes to all dirty iwbl's.  We don't yet implement
+	 * bandwidth-proportional distribution of nr_pages as the only
+	 * current caller, __filemap_fdatawrite_range(), always sets it to
+	 * LONG_MAX.  Implementing proportional distribution would require
+	 * a prepatory pass over dirty iwbl's to calculate the total write
+	 * bandwidth of the involved wb's.
+	 */
+	WARN_ON_ONCE(base_work.nr_pages != LONG_MAX);
+
+	if (!cgwb_do_writepages_split_work(&inode->i_wb_link, &base_work))
+		wb_wait_for_single_work(bdi, &base_work);
+restart_split:
+	rcu_read_lock();
+	inode_for_each_icgwbl(icgwbl, n, inode) {
+		struct inode_wb_link *iwbl = &icgwbl->iwbl;
+		int blkcg_id = iwbl_to_wb(iwbl)->blkcg_css->id;
+
+		if (blkcg_id <= last_blkcg_id)
+			continue;
+
+		if (!cgwb_do_writepages_split_work(iwbl, &base_work)) {
+			rcu_read_unlock();
+			wb_wait_for_single_work(bdi, &base_work);
+			goto restart_split;
+		}
+		last_blkcg_id = blkcg_id;
+	}
+	rcu_read_unlock();
+
+	wb_wait_for_completion(bdi, &done);
+	return done.mapping_ret;
+}
+
+static bool maybe_writeback_single_mapping(struct wb_writeback_work *work)
+{
+	struct wb_completion *done = work->done;
+	struct writeback_control wbc = {
+		.range_start		= work->mapping_range_start,
+		.range_end		= work->mapping_range_end,
+		.nr_to_write		= work->nr_pages,
+		.sync_mode		= work->sync_mode,
+		.tagged_writepages	= work->tagged_writepages,
+		.for_kupdate		= work->for_kupdate,
+		.range_cyclic		= work->range_cyclic,
+		.for_background		= work->for_background,
+		.for_sync		= work->for_sync,
+	};
+	int ret;
+
+	if (!work->mapping)
+		return false;
+
+	ret = do_writepages(work->mapping, &wbc);
+	if (done && ret)
+		done->mapping_ret = ret;
+	return true;
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
@@ -809,6 +950,11 @@ static inline bool wbc_skip_metadata(struct writeback_control *wbc)
 	return false;
 }
 
+static bool maybe_writeback_single_mapping(struct wb_writeback_work *work)
+{
+	return false;
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /**
@@ -1718,7 +1864,8 @@ static long wb_do_writeback(struct bdi_writeback *wb)
 
 		trace_writeback_exec(wb->bdi, work);
 
-		wrote += wb_writeback(wb, work);
+		if (!maybe_writeback_single_mapping(work))
+			wrote += wb_writeback(wb, work);
 
 		if (work->single_wait) {
 			WARN_ON_ONCE(work->auto_free);
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 173d218..2456efb 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -281,6 +281,8 @@ int __cgwb_create(struct backing_dev_info *bdi,
 		  struct cgroup_subsys_state *blkcg_css);
 struct inode_wb_link *iwbl_create(struct inode *inode,
 				  struct bdi_writeback *wb);
+int cgwb_do_writepages(struct address_space *mapping,
+		       struct writeback_control *wbc);
 int mapping_congested(struct address_space *mapping, struct task_struct *task,
 		      int bdi_bits);
 
@@ -787,6 +789,12 @@ static inline bool wbc_skip_page(struct writeback_control *wbc,
 	return false;
 }
 
+static inline int cgwb_do_writepages(struct address_space *mapping,
+				     struct writeback_control *wbc)
+{
+	return do_writepages(mapping, wbc);
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 static inline int mapping_read_congested(struct address_space *mapping,
diff --git a/mm/filemap.c b/mm/filemap.c
index faa577d..e858cd1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -284,7 +284,7 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
 	if (!mapping_cap_writeback_dirty(mapping))
 		return 0;
 
-	ret = do_writepages(mapping, &wbc);
+	ret = cgwb_do_writepages(mapping, &wbc);
 	return ret;
 }
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

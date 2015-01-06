Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id B16C46B0175
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:44 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id v10so189138qac.11
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:44 -0800 (PST)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com. [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id q1si65666393qcc.24.2015.01.06.13.27.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:43 -0800 (PST)
Received: by mail-qc0-f177.google.com with SMTP id x3so60372qcv.36
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:43 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 41/45] writeback: make __writeback_single_inode() cgroup writeback aware
Date: Tue,  6 Jan 2015 16:26:18 -0500
Message-Id: <1420579582-8516-42-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

Metadata is always dirtied against the root cgroup and should thus be
written out only by the root cgroup writeback.  This patch updates
__writeback_single_inode() so that it skips writing out metadata if
the writeback is for a non-root cgroup.  wbc_skip_metadata() is added
to decide whether to skip metadata writeback.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c | 29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index dbfd0b0..2bb14d5 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -684,6 +684,19 @@ static inline bool iwbl_still_has_dirty_pages(struct inode_wb_link *iwbl,
 	return test_bit(IWBL_DIRTY_PAGES, &iwbl->data);
 }
 
+/**
+ * wbc_skip_metadata - determine whether to skip writing out metadata
+ * @wbc: writeback_control in effect
+ *
+ * Called by __writeback_single_inode() to decide whether to skip writing
+ * out metadata.  Metadata is always dirtied against the root cgroup and
+ * should only be written out by the root.
+ */
+static inline bool wbc_skip_metadata(struct writeback_control *wbc)
+{
+	return wbc->iwbl && !iwbl_is_root(wbc->iwbl);
+}
+
 #else	/* CONFIG_CGROUP_WRITEBACK */
 
 static void init_cgwb_dirty_page_context(struct dirty_context *dctx)
@@ -791,6 +804,11 @@ static inline bool iwbl_still_has_dirty_pages(struct inode_wb_link *iwbl,
 	return mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY);
 }
 
+static inline bool wbc_skip_metadata(struct writeback_control *wbc)
+{
+	return false;
+}
+
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 
 /**
@@ -1128,6 +1146,7 @@ __writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 	struct address_space *mapping = inode->i_mapping;
 	struct inode_wb_link *iwbl = inode_writeback_iwbl(inode, wbc);
 	long nr_to_write = wbc->nr_to_write;
+	bool skip_metadata = wbc_skip_metadata(wbc);
 	unsigned dirty;
 	int ret;
 
@@ -1144,7 +1163,7 @@ __writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 	 * separate, external IO completion path and ->sync_fs for guaranteeing
 	 * inode metadata is written back correctly.
 	 */
-	if (wbc->sync_mode == WB_SYNC_ALL && !wbc->for_sync) {
+	if (wbc->sync_mode == WB_SYNC_ALL && !wbc->for_sync && !skip_metadata) {
 		int err = filemap_fdatawait(mapping);
 		if (ret == 0)
 			ret = err;
@@ -1157,8 +1176,12 @@ __writeback_single_inode(struct inode *inode, struct writeback_control *wbc)
 	 */
 	spin_lock(&inode->i_lock);
 
-	dirty = inode->i_state & I_DIRTY;
-	inode->i_state &= ~I_DIRTY;
+	if (skip_metadata)
+		dirty = inode->i_state & I_DIRTY_PAGES;
+	else
+		dirty = inode->i_state & I_DIRTY;
+
+	inode->i_state &= ~dirty;
 
 	/*
 	 * Paired with smp_mb() in __mark_inode_dirty_dctx().  This allows
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

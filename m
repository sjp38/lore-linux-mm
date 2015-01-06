Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id CF44F6B016B
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:27:35 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id x3so64831qcv.29
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:35 -0800 (PST)
Received: from mail-qa0-x22d.google.com (mail-qa0-x22d.google.com. [2607:f8b0:400d:c00::22d])
        by mx.google.com with ESMTPS id u5si65670899qas.116.2015.01.06.13.27.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:27:34 -0800 (PST)
Received: by mail-qa0-f45.google.com with SMTP id f12so223861qad.4
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:27:34 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 36/45] writeback: dirty inodes against their matching cgroup bdi_writeback's
Date: Tue,  6 Jan 2015 16:26:13 -0500
Message-Id: <1420579582-8516-37-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

mark_inode_dirty_dctx() always dirtied the inode against the root wb
(bdi_writeback).  The previous patches added all the infrastructure
necessary to attribute an inode against the wb of the dirtying cgroup.

On entry to mark_inode_dirty_dctx(), @dctx now carries the matching wb
and iwbl (inode_wb_link).  This patch updates mark_inode_dirty_dctx()
so that it uses the wb and iwbl from @dctx instead of unconditionally
using the root ones.

Currently, none of the filesystems has FS_CGROUP_WRITEBACK and all
pages will keep being dirtied against the root wb.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 fs/fs-writeback.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index df99b5b..dfcf5dd 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1734,8 +1734,9 @@ static noinline void block_dump___mark_inode_dirty(struct inode *inode)
 void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 {
 	struct inode *inode = dctx->inode;
+	struct inode_wb_link *iwbl = dctx->iwbl;
+	struct bdi_writeback *wb = dctx->wb;
 	struct super_block *sb = inode->i_sb;
-	struct backing_dev_info *bdi = NULL;
 
 	/*
 	 * Don't do this for I_DIRTY_PAGES - that doesn't actually
@@ -1764,7 +1765,6 @@ void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 
 	spin_lock(&inode->i_lock);
 	if ((inode->i_state & flags) != flags) {
-		struct inode_wb_link *iwbl = &inode->i_wb_link;
 		const int was_dirty = inode->i_state & I_DIRTY;
 
 		inode->i_state |= flags;
@@ -1794,19 +1794,17 @@ void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 		 */
 		if (!was_dirty) {
 			bool wakeup_bdi = false;
-			bdi = inode_to_bdi(inode);
 
 			spin_unlock(&inode->i_lock);
-			spin_lock(&bdi->wb.list_lock);
+			spin_lock(&wb->list_lock);
 
-			WARN(bdi_cap_writeback_dirty(bdi) &&
-			     !test_bit(WB_registered, &bdi->wb.state),
-			     "bdi-%s not registered\n", bdi->name);
+			WARN(bdi_cap_writeback_dirty(wb->bdi) &&
+			     !test_bit(WB_registered, &wb->state),
+			     "bdi-%s not registered\n", wb->bdi->name);
 
 			iwbl->dirtied_when = jiffies;
-			wakeup_bdi = iwbl_move_locked(iwbl, &bdi->wb,
-						      &bdi->wb.b_dirty);
-			spin_unlock(&bdi->wb.list_lock);
+			wakeup_bdi = iwbl_move_locked(iwbl, wb, &wb->b_dirty);
+			spin_unlock(&wb->list_lock);
 
 			/*
 			 * If this is the first dirty inode for this bdi,
@@ -1814,8 +1812,8 @@ void mark_inode_dirty_dctx(struct dirty_context *dctx, int flags)
 			 * to make sure background write-back happens
 			 * later.
 			 */
-			if (bdi_cap_writeback_dirty(bdi) && wakeup_bdi)
-				wb_wakeup_delayed(&bdi->wb);
+			if (bdi_cap_writeback_dirty(wb->bdi) && wakeup_bdi)
+				wb_wakeup_delayed(wb);
 			return;
 		}
 	}
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

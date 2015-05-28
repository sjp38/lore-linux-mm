Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 911896B0074
	for <linux-mm@kvack.org>; Thu, 28 May 2015 14:51:15 -0400 (EDT)
Received: by qcxw10 with SMTP id w10so18292038qcx.3
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:51:15 -0700 (PDT)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id i93si3241967qgd.126.2015.05.28.11.51.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 11:51:14 -0700 (PDT)
Received: by qcxw10 with SMTP id w10so18291892qcx.3
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:51:14 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 8/9] writeback: implement foreign cgroup inode bdi_writeback switching
Date: Thu, 28 May 2015 14:50:56 -0400
Message-Id: <1432839057-17609-9-git-send-email-tj@kernel.org>
In-Reply-To: <1432839057-17609-1-git-send-email-tj@kernel.org>
References: <1432839057-17609-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

As concurrent write sharing of an inode is expected to be very rare
and memcg only tracks page ownership on first-use basis severely
confining the usefulness of such sharing, cgroup writeback tracks
ownership per-inode.  While the support for concurrent write sharing
of an inode is deemed unnecessary, an inode being written to by
different cgroups at different points in time is a lot more common,
and, more importantly, charging only by first-use can too readily lead
to grossly incorrect behaviors (single foreign page can lead to
gigabytes of writeback to be incorrectly attributed).

To resolve this issue, cgroup writeback detects the majority dirtier
of an inode and transfers the ownership to it.  The previous patches
implemented the foreign condition detection mechanism and laid the
groundwork.  This patch implements the actual switching.

With the previously implemented [unlocked_]inode_to_wb_and_list_lock()
and wb stat transaction, grabbing wb->list_lock, inode->i_lock and
mapping->tree_lock gives us full exclusion against all wb operations
on the target inode.  inode_switch_wb_work_fn() grabs all the locks
and transfers the inode atomically along with its RECLAIMABLE and
WRITEBACK stats.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 fs/fs-writeback.c | 86 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 84 insertions(+), 2 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 6b99dee..5eeb24a 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -322,30 +322,112 @@ static void inode_switch_wbs_work_fn(struct work_struct *work)
 	struct inode_switch_wbs_context *isw =
 		container_of(work, struct inode_switch_wbs_context, work);
 	struct inode *inode = isw->inode;
+	struct address_space *mapping = inode->i_mapping;
+	struct bdi_writeback *old_wb = inode->i_wb;
 	struct bdi_writeback *new_wb = isw->new_wb;
+	struct radix_tree_iter iter;
+	bool switched = false;
+	void **slot;
 
 	/*
 	 * By the time control reaches here, RCU grace period has passed
 	 * since I_WB_SWITCH assertion and all wb stat update transactions
 	 * between unlocked_inode_to_wb_begin/end() are guaranteed to be
 	 * synchronizing against mapping->tree_lock.
+	 *
+	 * Grabbing old_wb->list_lock, inode->i_lock and mapping->tree_lock
+	 * gives us exclusion against all wb related operations on @inode
+	 * including IO list manipulations and stat updates.
 	 */
+	if (old_wb < new_wb) {
+		spin_lock(&old_wb->list_lock);
+		spin_lock_nested(&new_wb->list_lock, SINGLE_DEPTH_NESTING);
+	} else {
+		spin_lock(&new_wb->list_lock);
+		spin_lock_nested(&old_wb->list_lock, SINGLE_DEPTH_NESTING);
+	}
 	spin_lock(&inode->i_lock);
+	spin_lock_irq(&mapping->tree_lock);
+
+	/*
+	 * Once I_FREEING is visible under i_lock, the eviction path owns
+	 * the inode and we shouldn't modify ->i_wb_list.
+	 */
+	if (unlikely(inode->i_state & I_FREEING))
+		goto skip_switch;
 
+	/*
+	 * Count and transfer stats.  Note that PAGECACHE_TAG_DIRTY points
+	 * to possibly dirty pages while PAGECACHE_TAG_WRITEBACK points to
+	 * pages actually under underwriteback.
+	 */
+	radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter, 0,
+				   PAGECACHE_TAG_DIRTY) {
+		struct page *page = radix_tree_deref_slot_protected(slot,
+							&mapping->tree_lock);
+		if (likely(page) && PageDirty(page)) {
+			__dec_wb_stat(old_wb, WB_RECLAIMABLE);
+			__inc_wb_stat(new_wb, WB_RECLAIMABLE);
+		}
+	}
+
+	radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter, 0,
+				   PAGECACHE_TAG_WRITEBACK) {
+		struct page *page = radix_tree_deref_slot_protected(slot,
+							&mapping->tree_lock);
+		if (likely(page)) {
+			WARN_ON_ONCE(!PageWriteback(page));
+			__dec_wb_stat(old_wb, WB_WRITEBACK);
+			__inc_wb_stat(new_wb, WB_WRITEBACK);
+		}
+	}
+
+	wb_get(new_wb);
+
+	/*
+	 * Transfer to @new_wb's IO list if necessary.  The specific list
+	 * @inode was on is ignored and the inode is put on ->b_dirty which
+	 * is always correct including from ->b_dirty_time.  The transfer
+	 * preserves @inode->dirtied_when ordering.
+	 */
+	if (!list_empty(&inode->i_wb_list)) {
+		struct inode *pos;
+
+		inode_wb_list_del_locked(inode, old_wb);
+		inode->i_wb = new_wb;
+		list_for_each_entry(pos, &new_wb->b_dirty, i_wb_list)
+			if (time_after_eq(inode->dirtied_when,
+					  pos->dirtied_when))
+				break;
+		inode_wb_list_move_locked(inode, new_wb, pos->i_wb_list.prev);
+	} else {
+		inode->i_wb = new_wb;
+	}
+
+	/* ->i_wb_frn updates may race wbc_detach_inode() but doesn't matter */
 	inode->i_wb_frn_winner = 0;
 	inode->i_wb_frn_avg_time = 0;
 	inode->i_wb_frn_history = 0;
-
+	switched = true;
+skip_switch:
 	/*
 	 * Paired with load_acquire in unlocked_inode_to_wb_begin() and
 	 * ensures that the new wb is visible if they see !I_WB_SWITCH.
 	 */
 	smp_store_release(&inode->i_state, inode->i_state & ~I_WB_SWITCH);
 
+	spin_unlock_irq(&mapping->tree_lock);
 	spin_unlock(&inode->i_lock);
+	spin_unlock(&new_wb->list_lock);
+	spin_unlock(&old_wb->list_lock);
 
-	iput(inode);
+	if (switched) {
+		wb_wakeup(new_wb);
+		wb_put(old_wb);
+	}
 	wb_put(new_wb);
+
+	iput(inode);
 	kfree(isw);
 }
 
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

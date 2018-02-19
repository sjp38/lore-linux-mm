Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B05286B026C
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:10 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 67so630438pfg.0
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f17si3835788pge.270.2018.02.19.11.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:07 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 06/61] xfs: Rename xa_ elements to ail_
Date: Mon, 19 Feb 2018 11:45:01 -0800
Message-Id: <20180219194556.6575-7-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This is a simple rename, except that xa_ail becomes ail_head.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_buf_item.c    |  10 ++--
 fs/xfs/xfs_dquot.c       |   4 +-
 fs/xfs/xfs_dquot_item.c  |  11 ++--
 fs/xfs/xfs_inode_item.c  |  22 +++----
 fs/xfs/xfs_log.c         |   6 +-
 fs/xfs/xfs_log_recover.c |  80 ++++++++++++-------------
 fs/xfs/xfs_trans.c       |  18 +++---
 fs/xfs/xfs_trans_ail.c   | 152 +++++++++++++++++++++++------------------------
 fs/xfs/xfs_trans_buf.c   |   4 +-
 fs/xfs/xfs_trans_priv.h  |  42 ++++++-------
 10 files changed, 175 insertions(+), 174 deletions(-)

diff --git a/fs/xfs/xfs_buf_item.c b/fs/xfs/xfs_buf_item.c
index 270ddb4d2313..82ad270e390e 100644
--- a/fs/xfs/xfs_buf_item.c
+++ b/fs/xfs/xfs_buf_item.c
@@ -460,7 +460,7 @@ xfs_buf_item_unpin(
 			list_del_init(&bp->b_li_list);
 			bp->b_iodone = NULL;
 		} else {
-			spin_lock(&ailp->xa_lock);
+			spin_lock(&ailp->ail_lock);
 			xfs_trans_ail_delete(ailp, lip, SHUTDOWN_LOG_IO_ERROR);
 			xfs_buf_item_relse(bp);
 			ASSERT(bp->b_log_item == NULL);
@@ -1057,12 +1057,12 @@ xfs_buf_do_callbacks_fail(
 	lip = list_first_entry(&bp->b_li_list, struct xfs_log_item,
 			li_bio_list);
 	ailp = lip->li_ailp;
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	list_for_each_entry(lip, &bp->b_li_list, li_bio_list) {
 		if (lip->li_ops->iop_error)
 			lip->li_ops->iop_error(lip, bp);
 	}
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 }
 
 static bool
@@ -1226,7 +1226,7 @@ xfs_buf_iodone(
 	 *
 	 * Either way, AIL is useless if we're forcing a shutdown.
 	 */
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	xfs_trans_ail_delete(ailp, lip, SHUTDOWN_CORRUPT_INCORE);
 	xfs_buf_item_free(BUF_ITEM(lip));
 }
@@ -1246,7 +1246,7 @@ xfs_buf_resubmit_failed_buffers(
 	/*
 	 * Clear XFS_LI_FAILED flag from all items before resubmit
 	 *
-	 * XFS_LI_FAILED set/clear is protected by xa_lock, caller  this
+	 * XFS_LI_FAILED set/clear is protected by ail_lock, caller  this
 	 * function already have it acquired
 	 */
 	list_for_each_entry(lip, &bp->b_li_list, li_bio_list)
diff --git a/fs/xfs/xfs_dquot.c b/fs/xfs/xfs_dquot.c
index 43572f8a1b8e..c4041b676b7b 100644
--- a/fs/xfs/xfs_dquot.c
+++ b/fs/xfs/xfs_dquot.c
@@ -920,7 +920,7 @@ xfs_qm_dqflush_done(
 	     (lip->li_flags & XFS_LI_FAILED))) {
 
 		/* xfs_trans_ail_delete() drops the AIL lock. */
-		spin_lock(&ailp->xa_lock);
+		spin_lock(&ailp->ail_lock);
 		if (lip->li_lsn == qip->qli_flush_lsn) {
 			xfs_trans_ail_delete(ailp, lip, SHUTDOWN_CORRUPT_INCORE);
 		} else {
@@ -930,7 +930,7 @@ xfs_qm_dqflush_done(
 			 */
 			if (lip->li_flags & XFS_LI_FAILED)
 				xfs_clear_li_failed(lip);
-			spin_unlock(&ailp->xa_lock);
+			spin_unlock(&ailp->ail_lock);
 		}
 	}
 
diff --git a/fs/xfs/xfs_dquot_item.c b/fs/xfs/xfs_dquot_item.c
index 96eaa6933709..4b331e354da7 100644
--- a/fs/xfs/xfs_dquot_item.c
+++ b/fs/xfs/xfs_dquot_item.c
@@ -157,8 +157,9 @@ xfs_dquot_item_error(
 STATIC uint
 xfs_qm_dquot_logitem_push(
 	struct xfs_log_item	*lip,
-	struct list_head	*buffer_list) __releases(&lip->li_ailp->xa_lock)
-					      __acquires(&lip->li_ailp->xa_lock)
+	struct list_head	*buffer_list)
+		__releases(&lip->li_ailp->ail_lock)
+		__acquires(&lip->li_ailp->ail_lock)
 {
 	struct xfs_dquot	*dqp = DQUOT_ITEM(lip)->qli_dquot;
 	struct xfs_buf		*bp = lip->li_buf;
@@ -205,7 +206,7 @@ xfs_qm_dquot_logitem_push(
 		goto out_unlock;
 	}
 
-	spin_unlock(&lip->li_ailp->xa_lock);
+	spin_unlock(&lip->li_ailp->ail_lock);
 
 	error = xfs_qm_dqflush(dqp, &bp);
 	if (error) {
@@ -217,7 +218,7 @@ xfs_qm_dquot_logitem_push(
 		xfs_buf_relse(bp);
 	}
 
-	spin_lock(&lip->li_ailp->xa_lock);
+	spin_lock(&lip->li_ailp->ail_lock);
 out_unlock:
 	xfs_dqunlock(dqp);
 	return rval;
@@ -400,7 +401,7 @@ xfs_qm_qoffend_logitem_committed(
 	 * Delete the qoff-start logitem from the AIL.
 	 * xfs_trans_ail_delete() drops the AIL lock.
 	 */
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	xfs_trans_ail_delete(ailp, &qfs->qql_item, SHUTDOWN_LOG_IO_ERROR);
 
 	kmem_free(qfs->qql_item.li_lv_shadow);
diff --git a/fs/xfs/xfs_inode_item.c b/fs/xfs/xfs_inode_item.c
index d5037f060d6f..7666eae8844f 100644
--- a/fs/xfs/xfs_inode_item.c
+++ b/fs/xfs/xfs_inode_item.c
@@ -502,8 +502,8 @@ STATIC uint
 xfs_inode_item_push(
 	struct xfs_log_item	*lip,
 	struct list_head	*buffer_list)
-		__releases(&lip->li_ailp->xa_lock)
-		__acquires(&lip->li_ailp->xa_lock)
+		__releases(&lip->li_ailp->ail_lock)
+		__acquires(&lip->li_ailp->ail_lock)
 {
 	struct xfs_inode_log_item *iip = INODE_ITEM(lip);
 	struct xfs_inode	*ip = iip->ili_inode;
@@ -562,7 +562,7 @@ xfs_inode_item_push(
 	ASSERT(iip->ili_fields != 0 || XFS_FORCED_SHUTDOWN(ip->i_mount));
 	ASSERT(iip->ili_logged == 0 || XFS_FORCED_SHUTDOWN(ip->i_mount));
 
-	spin_unlock(&lip->li_ailp->xa_lock);
+	spin_unlock(&lip->li_ailp->ail_lock);
 
 	error = xfs_iflush(ip, &bp);
 	if (!error) {
@@ -571,7 +571,7 @@ xfs_inode_item_push(
 		xfs_buf_relse(bp);
 	}
 
-	spin_lock(&lip->li_ailp->xa_lock);
+	spin_lock(&lip->li_ailp->ail_lock);
 out_unlock:
 	xfs_iunlock(ip, XFS_ILOCK_SHARED);
 	return rval;
@@ -759,7 +759,7 @@ xfs_iflush_done(
 		bool			mlip_changed = false;
 
 		/* this is an opencoded batch version of xfs_trans_ail_delete */
-		spin_lock(&ailp->xa_lock);
+		spin_lock(&ailp->ail_lock);
 		list_for_each_entry(blip, &tmp, li_bio_list) {
 			if (INODE_ITEM(blip)->ili_logged &&
 			    blip->li_lsn == INODE_ITEM(blip)->ili_flush_lsn)
@@ -770,15 +770,15 @@ xfs_iflush_done(
 		}
 
 		if (mlip_changed) {
-			if (!XFS_FORCED_SHUTDOWN(ailp->xa_mount))
-				xlog_assign_tail_lsn_locked(ailp->xa_mount);
-			if (list_empty(&ailp->xa_ail))
-				wake_up_all(&ailp->xa_empty);
+			if (!XFS_FORCED_SHUTDOWN(ailp->ail_mount))
+				xlog_assign_tail_lsn_locked(ailp->ail_mount);
+			if (list_empty(&ailp->ail_head))
+				wake_up_all(&ailp->ail_empty);
 		}
-		spin_unlock(&ailp->xa_lock);
+		spin_unlock(&ailp->ail_lock);
 
 		if (mlip_changed)
-			xfs_log_space_wake(ailp->xa_mount);
+			xfs_log_space_wake(ailp->ail_mount);
 	}
 
 	/*
diff --git a/fs/xfs/xfs_log.c b/fs/xfs/xfs_log.c
index 3e5ba1ecc080..2f529fd7bf67 100644
--- a/fs/xfs/xfs_log.c
+++ b/fs/xfs/xfs_log.c
@@ -1149,7 +1149,7 @@ xlog_assign_tail_lsn_locked(
 	struct xfs_log_item	*lip;
 	xfs_lsn_t		tail_lsn;
 
-	assert_spin_locked(&mp->m_ail->xa_lock);
+	assert_spin_locked(&mp->m_ail->ail_lock);
 
 	/*
 	 * To make sure we always have a valid LSN for the log tail we keep
@@ -1172,9 +1172,9 @@ xlog_assign_tail_lsn(
 {
 	xfs_lsn_t		tail_lsn;
 
-	spin_lock(&mp->m_ail->xa_lock);
+	spin_lock(&mp->m_ail->ail_lock);
 	tail_lsn = xlog_assign_tail_lsn_locked(mp);
-	spin_unlock(&mp->m_ail->xa_lock);
+	spin_unlock(&mp->m_ail->ail_lock);
 
 	return tail_lsn;
 }
diff --git a/fs/xfs/xfs_log_recover.c b/fs/xfs/xfs_log_recover.c
index 00240c9ee72e..8d79838da2f6 100644
--- a/fs/xfs/xfs_log_recover.c
+++ b/fs/xfs/xfs_log_recover.c
@@ -3434,7 +3434,7 @@ xlog_recover_efi_pass2(
 	}
 	atomic_set(&efip->efi_next_extent, efi_formatp->efi_nextents);
 
-	spin_lock(&log->l_ailp->xa_lock);
+	spin_lock(&log->l_ailp->ail_lock);
 	/*
 	 * The EFI has two references. One for the EFD and one for EFI to ensure
 	 * it makes it into the AIL. Insert the EFI into the AIL directly and
@@ -3477,7 +3477,7 @@ xlog_recover_efd_pass2(
 	 * Search for the EFI with the id in the EFD format structure in the
 	 * AIL.
 	 */
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	lip = xfs_trans_ail_cursor_first(ailp, &cur, 0);
 	while (lip != NULL) {
 		if (lip->li_type == XFS_LI_EFI) {
@@ -3487,9 +3487,9 @@ xlog_recover_efd_pass2(
 				 * Drop the EFD reference to the EFI. This
 				 * removes the EFI from the AIL and frees it.
 				 */
-				spin_unlock(&ailp->xa_lock);
+				spin_unlock(&ailp->ail_lock);
 				xfs_efi_release(efip);
-				spin_lock(&ailp->xa_lock);
+				spin_lock(&ailp->ail_lock);
 				break;
 			}
 		}
@@ -3497,7 +3497,7 @@ xlog_recover_efd_pass2(
 	}
 
 	xfs_trans_ail_cursor_done(&cur);
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 
 	return 0;
 }
@@ -3530,7 +3530,7 @@ xlog_recover_rui_pass2(
 	}
 	atomic_set(&ruip->rui_next_extent, rui_formatp->rui_nextents);
 
-	spin_lock(&log->l_ailp->xa_lock);
+	spin_lock(&log->l_ailp->ail_lock);
 	/*
 	 * The RUI has two references. One for the RUD and one for RUI to ensure
 	 * it makes it into the AIL. Insert the RUI into the AIL directly and
@@ -3570,7 +3570,7 @@ xlog_recover_rud_pass2(
 	 * Search for the RUI with the id in the RUD format structure in the
 	 * AIL.
 	 */
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	lip = xfs_trans_ail_cursor_first(ailp, &cur, 0);
 	while (lip != NULL) {
 		if (lip->li_type == XFS_LI_RUI) {
@@ -3580,9 +3580,9 @@ xlog_recover_rud_pass2(
 				 * Drop the RUD reference to the RUI. This
 				 * removes the RUI from the AIL and frees it.
 				 */
-				spin_unlock(&ailp->xa_lock);
+				spin_unlock(&ailp->ail_lock);
 				xfs_rui_release(ruip);
-				spin_lock(&ailp->xa_lock);
+				spin_lock(&ailp->ail_lock);
 				break;
 			}
 		}
@@ -3590,7 +3590,7 @@ xlog_recover_rud_pass2(
 	}
 
 	xfs_trans_ail_cursor_done(&cur);
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 
 	return 0;
 }
@@ -3646,7 +3646,7 @@ xlog_recover_cui_pass2(
 	}
 	atomic_set(&cuip->cui_next_extent, cui_formatp->cui_nextents);
 
-	spin_lock(&log->l_ailp->xa_lock);
+	spin_lock(&log->l_ailp->ail_lock);
 	/*
 	 * The CUI has two references. One for the CUD and one for CUI to ensure
 	 * it makes it into the AIL. Insert the CUI into the AIL directly and
@@ -3687,7 +3687,7 @@ xlog_recover_cud_pass2(
 	 * Search for the CUI with the id in the CUD format structure in the
 	 * AIL.
 	 */
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	lip = xfs_trans_ail_cursor_first(ailp, &cur, 0);
 	while (lip != NULL) {
 		if (lip->li_type == XFS_LI_CUI) {
@@ -3697,9 +3697,9 @@ xlog_recover_cud_pass2(
 				 * Drop the CUD reference to the CUI. This
 				 * removes the CUI from the AIL and frees it.
 				 */
-				spin_unlock(&ailp->xa_lock);
+				spin_unlock(&ailp->ail_lock);
 				xfs_cui_release(cuip);
-				spin_lock(&ailp->xa_lock);
+				spin_lock(&ailp->ail_lock);
 				break;
 			}
 		}
@@ -3707,7 +3707,7 @@ xlog_recover_cud_pass2(
 	}
 
 	xfs_trans_ail_cursor_done(&cur);
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 
 	return 0;
 }
@@ -3765,7 +3765,7 @@ xlog_recover_bui_pass2(
 	}
 	atomic_set(&buip->bui_next_extent, bui_formatp->bui_nextents);
 
-	spin_lock(&log->l_ailp->xa_lock);
+	spin_lock(&log->l_ailp->ail_lock);
 	/*
 	 * The RUI has two references. One for the RUD and one for RUI to ensure
 	 * it makes it into the AIL. Insert the RUI into the AIL directly and
@@ -3806,7 +3806,7 @@ xlog_recover_bud_pass2(
 	 * Search for the BUI with the id in the BUD format structure in the
 	 * AIL.
 	 */
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	lip = xfs_trans_ail_cursor_first(ailp, &cur, 0);
 	while (lip != NULL) {
 		if (lip->li_type == XFS_LI_BUI) {
@@ -3816,9 +3816,9 @@ xlog_recover_bud_pass2(
 				 * Drop the BUD reference to the BUI. This
 				 * removes the BUI from the AIL and frees it.
 				 */
-				spin_unlock(&ailp->xa_lock);
+				spin_unlock(&ailp->ail_lock);
 				xfs_bui_release(buip);
-				spin_lock(&ailp->xa_lock);
+				spin_lock(&ailp->ail_lock);
 				break;
 			}
 		}
@@ -3826,7 +3826,7 @@ xlog_recover_bud_pass2(
 	}
 
 	xfs_trans_ail_cursor_done(&cur);
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 
 	return 0;
 }
@@ -4659,9 +4659,9 @@ xlog_recover_process_efi(
 	if (test_bit(XFS_EFI_RECOVERED, &efip->efi_flags))
 		return 0;
 
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 	error = xfs_efi_recover(mp, efip);
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 
 	return error;
 }
@@ -4677,9 +4677,9 @@ xlog_recover_cancel_efi(
 
 	efip = container_of(lip, struct xfs_efi_log_item, efi_item);
 
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 	xfs_efi_release(efip);
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 }
 
 /* Recover the RUI if necessary. */
@@ -4699,9 +4699,9 @@ xlog_recover_process_rui(
 	if (test_bit(XFS_RUI_RECOVERED, &ruip->rui_flags))
 		return 0;
 
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 	error = xfs_rui_recover(mp, ruip);
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 
 	return error;
 }
@@ -4717,9 +4717,9 @@ xlog_recover_cancel_rui(
 
 	ruip = container_of(lip, struct xfs_rui_log_item, rui_item);
 
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 	xfs_rui_release(ruip);
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 }
 
 /* Recover the CUI if necessary. */
@@ -4740,9 +4740,9 @@ xlog_recover_process_cui(
 	if (test_bit(XFS_CUI_RECOVERED, &cuip->cui_flags))
 		return 0;
 
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 	error = xfs_cui_recover(mp, cuip, dfops);
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 
 	return error;
 }
@@ -4758,9 +4758,9 @@ xlog_recover_cancel_cui(
 
 	cuip = container_of(lip, struct xfs_cui_log_item, cui_item);
 
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 	xfs_cui_release(cuip);
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 }
 
 /* Recover the BUI if necessary. */
@@ -4781,9 +4781,9 @@ xlog_recover_process_bui(
 	if (test_bit(XFS_BUI_RECOVERED, &buip->bui_flags))
 		return 0;
 
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 	error = xfs_bui_recover(mp, buip, dfops);
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 
 	return error;
 }
@@ -4799,9 +4799,9 @@ xlog_recover_cancel_bui(
 
 	buip = container_of(lip, struct xfs_bui_log_item, bui_item);
 
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 	xfs_bui_release(buip);
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 }
 
 /* Is this log item a deferred action intent? */
@@ -4889,7 +4889,7 @@ xlog_recover_process_intents(
 #endif
 
 	ailp = log->l_ailp;
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	lip = xfs_trans_ail_cursor_first(ailp, &cur, 0);
 #if defined(DEBUG) || defined(XFS_WARN)
 	last_lsn = xlog_assign_lsn(log->l_curr_cycle, log->l_curr_block);
@@ -4943,7 +4943,7 @@ xlog_recover_process_intents(
 	}
 out:
 	xfs_trans_ail_cursor_done(&cur);
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 	if (error)
 		xfs_defer_cancel(&dfops);
 	else
@@ -4966,7 +4966,7 @@ xlog_recover_cancel_intents(
 	struct xfs_ail		*ailp;
 
 	ailp = log->l_ailp;
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	lip = xfs_trans_ail_cursor_first(ailp, &cur, 0);
 	while (lip != NULL) {
 		/*
@@ -5000,7 +5000,7 @@ xlog_recover_cancel_intents(
 	}
 
 	xfs_trans_ail_cursor_done(&cur);
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 	return error;
 }
 
diff --git a/fs/xfs/xfs_trans.c b/fs/xfs/xfs_trans.c
index 86f92df32c42..ec6b01834705 100644
--- a/fs/xfs/xfs_trans.c
+++ b/fs/xfs/xfs_trans.c
@@ -803,8 +803,8 @@ xfs_log_item_batch_insert(
 {
 	int	i;
 
-	spin_lock(&ailp->xa_lock);
-	/* xfs_trans_ail_update_bulk drops ailp->xa_lock */
+	spin_lock(&ailp->ail_lock);
+	/* xfs_trans_ail_update_bulk drops ailp->ail_lock */
 	xfs_trans_ail_update_bulk(ailp, cur, log_items, nr_items, commit_lsn);
 
 	for (i = 0; i < nr_items; i++) {
@@ -847,9 +847,9 @@ xfs_trans_committed_bulk(
 	struct xfs_ail_cursor	cur;
 	int			i = 0;
 
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	xfs_trans_ail_cursor_last(ailp, &cur, commit_lsn);
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 
 	/* unpin all the log items */
 	for (lv = log_vector; lv; lv = lv->lv_next ) {
@@ -869,7 +869,7 @@ xfs_trans_committed_bulk(
 		 * object into the AIL as we are in a shutdown situation.
 		 */
 		if (aborted) {
-			ASSERT(XFS_FORCED_SHUTDOWN(ailp->xa_mount));
+			ASSERT(XFS_FORCED_SHUTDOWN(ailp->ail_mount));
 			lip->li_ops->iop_unpin(lip, 1);
 			continue;
 		}
@@ -883,11 +883,11 @@ xfs_trans_committed_bulk(
 			 * not affect the AIL cursor the bulk insert path is
 			 * using.
 			 */
-			spin_lock(&ailp->xa_lock);
+			spin_lock(&ailp->ail_lock);
 			if (XFS_LSN_CMP(item_lsn, lip->li_lsn) > 0)
 				xfs_trans_ail_update(ailp, lip, item_lsn);
 			else
-				spin_unlock(&ailp->xa_lock);
+				spin_unlock(&ailp->ail_lock);
 			lip->li_ops->iop_unpin(lip, 0);
 			continue;
 		}
@@ -905,9 +905,9 @@ xfs_trans_committed_bulk(
 	if (i)
 		xfs_log_item_batch_insert(ailp, &cur, log_items, i, commit_lsn);
 
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	xfs_trans_ail_cursor_done(&cur);
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 }
 
 /*
diff --git a/fs/xfs/xfs_trans_ail.c b/fs/xfs/xfs_trans_ail.c
index cef89f7127d3..d4a2445215e6 100644
--- a/fs/xfs/xfs_trans_ail.c
+++ b/fs/xfs/xfs_trans_ail.c
@@ -40,7 +40,7 @@ xfs_ail_check(
 {
 	xfs_log_item_t	*prev_lip;
 
-	if (list_empty(&ailp->xa_ail))
+	if (list_empty(&ailp->ail_head))
 		return;
 
 	/*
@@ -48,11 +48,11 @@ xfs_ail_check(
 	 */
 	ASSERT((lip->li_flags & XFS_LI_IN_AIL) != 0);
 	prev_lip = list_entry(lip->li_ail.prev, xfs_log_item_t, li_ail);
-	if (&prev_lip->li_ail != &ailp->xa_ail)
+	if (&prev_lip->li_ail != &ailp->ail_head)
 		ASSERT(XFS_LSN_CMP(prev_lip->li_lsn, lip->li_lsn) <= 0);
 
 	prev_lip = list_entry(lip->li_ail.next, xfs_log_item_t, li_ail);
-	if (&prev_lip->li_ail != &ailp->xa_ail)
+	if (&prev_lip->li_ail != &ailp->ail_head)
 		ASSERT(XFS_LSN_CMP(prev_lip->li_lsn, lip->li_lsn) >= 0);
 
 
@@ -69,10 +69,10 @@ static xfs_log_item_t *
 xfs_ail_max(
 	struct xfs_ail  *ailp)
 {
-	if (list_empty(&ailp->xa_ail))
+	if (list_empty(&ailp->ail_head))
 		return NULL;
 
-	return list_entry(ailp->xa_ail.prev, xfs_log_item_t, li_ail);
+	return list_entry(ailp->ail_head.prev, xfs_log_item_t, li_ail);
 }
 
 /*
@@ -84,7 +84,7 @@ xfs_ail_next(
 	struct xfs_ail  *ailp,
 	xfs_log_item_t  *lip)
 {
-	if (lip->li_ail.next == &ailp->xa_ail)
+	if (lip->li_ail.next == &ailp->ail_head)
 		return NULL;
 
 	return list_first_entry(&lip->li_ail, xfs_log_item_t, li_ail);
@@ -105,11 +105,11 @@ xfs_ail_min_lsn(
 	xfs_lsn_t	lsn = 0;
 	xfs_log_item_t	*lip;
 
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	lip = xfs_ail_min(ailp);
 	if (lip)
 		lsn = lip->li_lsn;
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 
 	return lsn;
 }
@@ -124,11 +124,11 @@ xfs_ail_max_lsn(
 	xfs_lsn_t       lsn = 0;
 	xfs_log_item_t  *lip;
 
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	lip = xfs_ail_max(ailp);
 	if (lip)
 		lsn = lip->li_lsn;
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 
 	return lsn;
 }
@@ -146,7 +146,7 @@ xfs_trans_ail_cursor_init(
 	struct xfs_ail_cursor	*cur)
 {
 	cur->item = NULL;
-	list_add_tail(&cur->list, &ailp->xa_cursors);
+	list_add_tail(&cur->list, &ailp->ail_cursors);
 }
 
 /*
@@ -194,7 +194,7 @@ xfs_trans_ail_cursor_clear(
 {
 	struct xfs_ail_cursor	*cur;
 
-	list_for_each_entry(cur, &ailp->xa_cursors, list) {
+	list_for_each_entry(cur, &ailp->ail_cursors, list) {
 		if (cur->item == lip)
 			cur->item = (struct xfs_log_item *)
 					((uintptr_t)cur->item | 1);
@@ -222,7 +222,7 @@ xfs_trans_ail_cursor_first(
 		goto out;
 	}
 
-	list_for_each_entry(lip, &ailp->xa_ail, li_ail) {
+	list_for_each_entry(lip, &ailp->ail_head, li_ail) {
 		if (XFS_LSN_CMP(lip->li_lsn, lsn) >= 0)
 			goto out;
 	}
@@ -241,7 +241,7 @@ __xfs_trans_ail_cursor_last(
 {
 	xfs_log_item_t		*lip;
 
-	list_for_each_entry_reverse(lip, &ailp->xa_ail, li_ail) {
+	list_for_each_entry_reverse(lip, &ailp->ail_head, li_ail) {
 		if (XFS_LSN_CMP(lip->li_lsn, lsn) <= 0)
 			return lip;
 	}
@@ -310,7 +310,7 @@ xfs_ail_splice(
 	if (lip)
 		list_splice(list, &lip->li_ail);
 	else
-		list_splice(list, &ailp->xa_ail);
+		list_splice(list, &ailp->ail_head);
 }
 
 /*
@@ -335,17 +335,17 @@ xfsaild_push_item(
 	 * If log item pinning is enabled, skip the push and track the item as
 	 * pinned. This can help induce head-behind-tail conditions.
 	 */
-	if (XFS_TEST_ERROR(false, ailp->xa_mount, XFS_ERRTAG_LOG_ITEM_PIN))
+	if (XFS_TEST_ERROR(false, ailp->ail_mount, XFS_ERRTAG_LOG_ITEM_PIN))
 		return XFS_ITEM_PINNED;
 
-	return lip->li_ops->iop_push(lip, &ailp->xa_buf_list);
+	return lip->li_ops->iop_push(lip, &ailp->ail_buf_list);
 }
 
 static long
 xfsaild_push(
 	struct xfs_ail		*ailp)
 {
-	xfs_mount_t		*mp = ailp->xa_mount;
+	xfs_mount_t		*mp = ailp->ail_mount;
 	struct xfs_ail_cursor	cur;
 	xfs_log_item_t		*lip;
 	xfs_lsn_t		lsn;
@@ -360,30 +360,30 @@ xfsaild_push(
 	 * buffers the last time we ran, force the log first and wait for it
 	 * before pushing again.
 	 */
-	if (ailp->xa_log_flush && ailp->xa_last_pushed_lsn == 0 &&
-	    (!list_empty_careful(&ailp->xa_buf_list) ||
+	if (ailp->ail_log_flush && ailp->ail_last_pushed_lsn == 0 &&
+	    (!list_empty_careful(&ailp->ail_buf_list) ||
 	     xfs_ail_min_lsn(ailp))) {
-		ailp->xa_log_flush = 0;
+		ailp->ail_log_flush = 0;
 
 		XFS_STATS_INC(mp, xs_push_ail_flush);
 		xfs_log_force(mp, XFS_LOG_SYNC);
 	}
 
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 
-	/* barrier matches the xa_target update in xfs_ail_push() */
+	/* barrier matches the ail_target update in xfs_ail_push() */
 	smp_rmb();
-	target = ailp->xa_target;
-	ailp->xa_target_prev = target;
+	target = ailp->ail_target;
+	ailp->ail_target_prev = target;
 
-	lip = xfs_trans_ail_cursor_first(ailp, &cur, ailp->xa_last_pushed_lsn);
+	lip = xfs_trans_ail_cursor_first(ailp, &cur, ailp->ail_last_pushed_lsn);
 	if (!lip) {
 		/*
 		 * If the AIL is empty or our push has reached the end we are
 		 * done now.
 		 */
 		xfs_trans_ail_cursor_done(&cur);
-		spin_unlock(&ailp->xa_lock);
+		spin_unlock(&ailp->ail_lock);
 		goto out_done;
 	}
 
@@ -404,7 +404,7 @@ xfsaild_push(
 			XFS_STATS_INC(mp, xs_push_ail_success);
 			trace_xfs_ail_push(lip);
 
-			ailp->xa_last_pushed_lsn = lsn;
+			ailp->ail_last_pushed_lsn = lsn;
 			break;
 
 		case XFS_ITEM_FLUSHING:
@@ -423,7 +423,7 @@ xfsaild_push(
 			trace_xfs_ail_flushing(lip);
 
 			flushing++;
-			ailp->xa_last_pushed_lsn = lsn;
+			ailp->ail_last_pushed_lsn = lsn;
 			break;
 
 		case XFS_ITEM_PINNED:
@@ -431,7 +431,7 @@ xfsaild_push(
 			trace_xfs_ail_pinned(lip);
 
 			stuck++;
-			ailp->xa_log_flush++;
+			ailp->ail_log_flush++;
 			break;
 		case XFS_ITEM_LOCKED:
 			XFS_STATS_INC(mp, xs_push_ail_locked);
@@ -468,10 +468,10 @@ xfsaild_push(
 		lsn = lip->li_lsn;
 	}
 	xfs_trans_ail_cursor_done(&cur);
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 
-	if (xfs_buf_delwri_submit_nowait(&ailp->xa_buf_list))
-		ailp->xa_log_flush++;
+	if (xfs_buf_delwri_submit_nowait(&ailp->ail_buf_list))
+		ailp->ail_log_flush++;
 
 	if (!count || XFS_LSN_CMP(lsn, target) >= 0) {
 out_done:
@@ -481,7 +481,7 @@ xfsaild_push(
 		 * AIL before we start the next scan from the start of the AIL.
 		 */
 		tout = 50;
-		ailp->xa_last_pushed_lsn = 0;
+		ailp->ail_last_pushed_lsn = 0;
 	} else if (((stuck + flushing) * 100) / count > 90) {
 		/*
 		 * Either there is a lot of contention on the AIL or we are
@@ -494,7 +494,7 @@ xfsaild_push(
 		 * the restart to issue a log force to unpin the stuck items.
 		 */
 		tout = 20;
-		ailp->xa_last_pushed_lsn = 0;
+		ailp->ail_last_pushed_lsn = 0;
 	} else {
 		/*
 		 * Assume we have more work to do in a short while.
@@ -536,26 +536,26 @@ xfsaild(
 			break;
 		}
 
-		spin_lock(&ailp->xa_lock);
+		spin_lock(&ailp->ail_lock);
 
 		/*
 		 * Idle if the AIL is empty and we are not racing with a target
 		 * update. We check the AIL after we set the task to a sleep
-		 * state to guarantee that we either catch an xa_target update
+		 * state to guarantee that we either catch an ail_target update
 		 * or that a wake_up resets the state to TASK_RUNNING.
 		 * Otherwise, we run the risk of sleeping indefinitely.
 		 *
-		 * The barrier matches the xa_target update in xfs_ail_push().
+		 * The barrier matches the ail_target update in xfs_ail_push().
 		 */
 		smp_rmb();
 		if (!xfs_ail_min(ailp) &&
-		    ailp->xa_target == ailp->xa_target_prev) {
-			spin_unlock(&ailp->xa_lock);
+		    ailp->ail_target == ailp->ail_target_prev) {
+			spin_unlock(&ailp->ail_lock);
 			freezable_schedule();
 			tout = 0;
 			continue;
 		}
-		spin_unlock(&ailp->xa_lock);
+		spin_unlock(&ailp->ail_lock);
 
 		if (tout)
 			freezable_schedule_timeout(msecs_to_jiffies(tout));
@@ -592,8 +592,8 @@ xfs_ail_push(
 	xfs_log_item_t	*lip;
 
 	lip = xfs_ail_min(ailp);
-	if (!lip || XFS_FORCED_SHUTDOWN(ailp->xa_mount) ||
-	    XFS_LSN_CMP(threshold_lsn, ailp->xa_target) <= 0)
+	if (!lip || XFS_FORCED_SHUTDOWN(ailp->ail_mount) ||
+	    XFS_LSN_CMP(threshold_lsn, ailp->ail_target) <= 0)
 		return;
 
 	/*
@@ -601,10 +601,10 @@ xfs_ail_push(
 	 * the XFS_AIL_PUSHING_BIT.
 	 */
 	smp_wmb();
-	xfs_trans_ail_copy_lsn(ailp, &ailp->xa_target, &threshold_lsn);
+	xfs_trans_ail_copy_lsn(ailp, &ailp->ail_target, &threshold_lsn);
 	smp_wmb();
 
-	wake_up_process(ailp->xa_task);
+	wake_up_process(ailp->ail_task);
 }
 
 /*
@@ -630,18 +630,18 @@ xfs_ail_push_all_sync(
 	struct xfs_log_item	*lip;
 	DEFINE_WAIT(wait);
 
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	while ((lip = xfs_ail_max(ailp)) != NULL) {
-		prepare_to_wait(&ailp->xa_empty, &wait, TASK_UNINTERRUPTIBLE);
-		ailp->xa_target = lip->li_lsn;
-		wake_up_process(ailp->xa_task);
-		spin_unlock(&ailp->xa_lock);
+		prepare_to_wait(&ailp->ail_empty, &wait, TASK_UNINTERRUPTIBLE);
+		ailp->ail_target = lip->li_lsn;
+		wake_up_process(ailp->ail_task);
+		spin_unlock(&ailp->ail_lock);
 		schedule();
-		spin_lock(&ailp->xa_lock);
+		spin_lock(&ailp->ail_lock);
 	}
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 
-	finish_wait(&ailp->xa_empty, &wait);
+	finish_wait(&ailp->ail_empty, &wait);
 }
 
 /*
@@ -672,7 +672,7 @@ xfs_trans_ail_update_bulk(
 	struct xfs_ail_cursor	*cur,
 	struct xfs_log_item	**log_items,
 	int			nr_items,
-	xfs_lsn_t		lsn) __releases(ailp->xa_lock)
+	xfs_lsn_t		lsn) __releases(ailp->ail_lock)
 {
 	xfs_log_item_t		*mlip;
 	int			mlip_changed = 0;
@@ -705,13 +705,13 @@ xfs_trans_ail_update_bulk(
 		xfs_ail_splice(ailp, cur, &tmp, lsn);
 
 	if (mlip_changed) {
-		if (!XFS_FORCED_SHUTDOWN(ailp->xa_mount))
-			xlog_assign_tail_lsn_locked(ailp->xa_mount);
-		spin_unlock(&ailp->xa_lock);
+		if (!XFS_FORCED_SHUTDOWN(ailp->ail_mount))
+			xlog_assign_tail_lsn_locked(ailp->ail_mount);
+		spin_unlock(&ailp->ail_lock);
 
-		xfs_log_space_wake(ailp->xa_mount);
+		xfs_log_space_wake(ailp->ail_mount);
 	} else {
-		spin_unlock(&ailp->xa_lock);
+		spin_unlock(&ailp->ail_lock);
 	}
 }
 
@@ -756,13 +756,13 @@ void
 xfs_trans_ail_delete(
 	struct xfs_ail		*ailp,
 	struct xfs_log_item	*lip,
-	int			shutdown_type) __releases(ailp->xa_lock)
+	int			shutdown_type) __releases(ailp->ail_lock)
 {
-	struct xfs_mount	*mp = ailp->xa_mount;
+	struct xfs_mount	*mp = ailp->ail_mount;
 	bool			mlip_changed;
 
 	if (!(lip->li_flags & XFS_LI_IN_AIL)) {
-		spin_unlock(&ailp->xa_lock);
+		spin_unlock(&ailp->ail_lock);
 		if (!XFS_FORCED_SHUTDOWN(mp)) {
 			xfs_alert_tag(mp, XFS_PTAG_AILDELETE,
 	"%s: attempting to delete a log item that is not in the AIL",
@@ -776,13 +776,13 @@ xfs_trans_ail_delete(
 	if (mlip_changed) {
 		if (!XFS_FORCED_SHUTDOWN(mp))
 			xlog_assign_tail_lsn_locked(mp);
-		if (list_empty(&ailp->xa_ail))
-			wake_up_all(&ailp->xa_empty);
+		if (list_empty(&ailp->ail_head))
+			wake_up_all(&ailp->ail_empty);
 	}
 
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 	if (mlip_changed)
-		xfs_log_space_wake(ailp->xa_mount);
+		xfs_log_space_wake(ailp->ail_mount);
 }
 
 int
@@ -795,16 +795,16 @@ xfs_trans_ail_init(
 	if (!ailp)
 		return -ENOMEM;
 
-	ailp->xa_mount = mp;
-	INIT_LIST_HEAD(&ailp->xa_ail);
-	INIT_LIST_HEAD(&ailp->xa_cursors);
-	spin_lock_init(&ailp->xa_lock);
-	INIT_LIST_HEAD(&ailp->xa_buf_list);
-	init_waitqueue_head(&ailp->xa_empty);
+	ailp->ail_mount = mp;
+	INIT_LIST_HEAD(&ailp->ail_head);
+	INIT_LIST_HEAD(&ailp->ail_cursors);
+	spin_lock_init(&ailp->ail_lock);
+	INIT_LIST_HEAD(&ailp->ail_buf_list);
+	init_waitqueue_head(&ailp->ail_empty);
 
-	ailp->xa_task = kthread_run(xfsaild, ailp, "xfsaild/%s",
-			ailp->xa_mount->m_fsname);
-	if (IS_ERR(ailp->xa_task))
+	ailp->ail_task = kthread_run(xfsaild, ailp, "xfsaild/%s",
+			ailp->ail_mount->m_fsname);
+	if (IS_ERR(ailp->ail_task))
 		goto out_free_ailp;
 
 	mp->m_ail = ailp;
@@ -821,6 +821,6 @@ xfs_trans_ail_destroy(
 {
 	struct xfs_ail	*ailp = mp->m_ail;
 
-	kthread_stop(ailp->xa_task);
+	kthread_stop(ailp->ail_task);
 	kmem_free(ailp);
 }
diff --git a/fs/xfs/xfs_trans_buf.c b/fs/xfs/xfs_trans_buf.c
index 653ce379d36b..a5d9dfc45d98 100644
--- a/fs/xfs/xfs_trans_buf.c
+++ b/fs/xfs/xfs_trans_buf.c
@@ -431,8 +431,8 @@ xfs_trans_brelse(
 	 * If the fs has shutdown and we dropped the last reference, it may fall
 	 * on us to release a (possibly dirty) bli if it never made it to the
 	 * AIL (e.g., the aborted unpin already happened and didn't release it
-	 * due to our reference). Since we're already shutdown and need xa_lock,
-	 * just force remove from the AIL and release the bli here.
+	 * due to our reference). Since we're already shutdown and need
+	 * ail_lock, just force remove from the AIL and release the bli here.
 	 */
 	if (XFS_FORCED_SHUTDOWN(tp->t_mountp) && freed) {
 		xfs_trans_ail_remove(&bip->bli_item, SHUTDOWN_LOG_IO_ERROR);
diff --git a/fs/xfs/xfs_trans_priv.h b/fs/xfs/xfs_trans_priv.h
index b317a3644c00..be24b0c8a332 100644
--- a/fs/xfs/xfs_trans_priv.h
+++ b/fs/xfs/xfs_trans_priv.h
@@ -65,17 +65,17 @@ struct xfs_ail_cursor {
  * Eventually we need to drive the locking in here as well.
  */
 struct xfs_ail {
-	struct xfs_mount	*xa_mount;
-	struct task_struct	*xa_task;
-	struct list_head	xa_ail;
-	xfs_lsn_t		xa_target;
-	xfs_lsn_t		xa_target_prev;
-	struct list_head	xa_cursors;
-	spinlock_t		xa_lock;
-	xfs_lsn_t		xa_last_pushed_lsn;
-	int			xa_log_flush;
-	struct list_head	xa_buf_list;
-	wait_queue_head_t	xa_empty;
+	struct xfs_mount	*ail_mount;
+	struct task_struct	*ail_task;
+	struct list_head	ail_head;
+	xfs_lsn_t		ail_target;
+	xfs_lsn_t		ail_target_prev;
+	struct list_head	ail_cursors;
+	spinlock_t		ail_lock;
+	xfs_lsn_t		ail_last_pushed_lsn;
+	int			ail_log_flush;
+	struct list_head	ail_buf_list;
+	wait_queue_head_t	ail_empty;
 };
 
 /*
@@ -84,7 +84,7 @@ struct xfs_ail {
 void	xfs_trans_ail_update_bulk(struct xfs_ail *ailp,
 				struct xfs_ail_cursor *cur,
 				struct xfs_log_item **log_items, int nr_items,
-				xfs_lsn_t lsn) __releases(ailp->xa_lock);
+				xfs_lsn_t lsn) __releases(ailp->ail_lock);
 /*
  * Return a pointer to the first item in the AIL.  If the AIL is empty, then
  * return NULL.
@@ -93,7 +93,7 @@ static inline struct xfs_log_item *
 xfs_ail_min(
 	struct xfs_ail  *ailp)
 {
-	return list_first_entry_or_null(&ailp->xa_ail, struct xfs_log_item,
+	return list_first_entry_or_null(&ailp->ail_head, struct xfs_log_item,
 					li_ail);
 }
 
@@ -101,14 +101,14 @@ static inline void
 xfs_trans_ail_update(
 	struct xfs_ail		*ailp,
 	struct xfs_log_item	*lip,
-	xfs_lsn_t		lsn) __releases(ailp->xa_lock)
+	xfs_lsn_t		lsn) __releases(ailp->ail_lock)
 {
 	xfs_trans_ail_update_bulk(ailp, NULL, &lip, 1, lsn);
 }
 
 bool xfs_ail_delete_one(struct xfs_ail *ailp, struct xfs_log_item *lip);
 void xfs_trans_ail_delete(struct xfs_ail *ailp, struct xfs_log_item *lip,
-		int shutdown_type) __releases(ailp->xa_lock);
+		int shutdown_type) __releases(ailp->ail_lock);
 
 static inline void
 xfs_trans_ail_remove(
@@ -117,12 +117,12 @@ xfs_trans_ail_remove(
 {
 	struct xfs_ail		*ailp = lip->li_ailp;
 
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	/* xfs_trans_ail_delete() drops the AIL lock */
 	if (lip->li_flags & XFS_LI_IN_AIL)
 		xfs_trans_ail_delete(ailp, lip, shutdown_type);
 	else
-		spin_unlock(&ailp->xa_lock);
+		spin_unlock(&ailp->ail_lock);
 }
 
 void			xfs_ail_push(struct xfs_ail *, xfs_lsn_t);
@@ -149,9 +149,9 @@ xfs_trans_ail_copy_lsn(
 	xfs_lsn_t	*src)
 {
 	ASSERT(sizeof(xfs_lsn_t) == 8);	/* don't lock if it shrinks */
-	spin_lock(&ailp->xa_lock);
+	spin_lock(&ailp->ail_lock);
 	*dst = *src;
-	spin_unlock(&ailp->xa_lock);
+	spin_unlock(&ailp->ail_lock);
 }
 #else
 static inline void
@@ -172,7 +172,7 @@ xfs_clear_li_failed(
 	struct xfs_buf	*bp = lip->li_buf;
 
 	ASSERT(lip->li_flags & XFS_LI_IN_AIL);
-	lockdep_assert_held(&lip->li_ailp->xa_lock);
+	lockdep_assert_held(&lip->li_ailp->ail_lock);
 
 	if (lip->li_flags & XFS_LI_FAILED) {
 		lip->li_flags &= ~XFS_LI_FAILED;
@@ -186,7 +186,7 @@ xfs_set_li_failed(
 	struct xfs_log_item	*lip,
 	struct xfs_buf		*bp)
 {
-	lockdep_assert_held(&lip->li_ailp->xa_lock);
+	lockdep_assert_held(&lip->li_ailp->ail_lock);
 
 	if (!(lip->li_flags & XFS_LI_FAILED)) {
 		xfs_buf_hold(bp);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

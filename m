Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3666B0078
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:51 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/13] VM: Split out the accounting of unstable writes from BDI_RECLAIMABLE
Date: Wed, 10 Feb 2010 12:03:21 -0500
Message-Id: <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <peterz@infradead.org>

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Acked-by: Jan Kara <jack@suse.cz>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c              |    6 +++---
 include/linux/backing-dev.h |    3 ++-
 mm/backing-dev.c            |    6 ++++--
 mm/filemap.c                |    2 +-
 mm/page-writeback.c         |   16 ++++++++++------
 mm/truncate.c               |    2 +-
 6 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7b54b8b..d5411e2 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -440,7 +440,7 @@ nfs_mark_request_commit(struct nfs_page *req)
 			NFS_PAGE_TAG_COMMIT);
 	spin_unlock(&inode->i_lock);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_UNSTABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
 
@@ -451,7 +451,7 @@ nfs_clear_request_commit(struct nfs_page *req)
 
 	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
 		dec_zone_page_state(page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
+		dec_bdi_stat(page->mapping->backing_dev_info, BDI_UNSTABLE);
 		return 1;
 	}
 	return 0;
@@ -1322,7 +1322,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 		nfs_mark_request_commit(req);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
-				BDI_RECLAIMABLE);
+				BDI_UNSTABLE);
 		nfs_clear_page_tag_locked(req);
 	}
 	return -ENOMEM;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index fcbc26a..42c3e2a 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -36,7 +36,8 @@ enum bdi_state {
 typedef int (congested_fn)(void *, int);
 
 enum bdi_stat_item {
-	BDI_RECLAIMABLE,
+	BDI_DIRTY,
+	BDI_UNSTABLE,
 	BDI_WRITEBACK,
 	NR_BDI_STAT_ITEMS
 };
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 0e8ca03..88f3655 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -88,7 +88,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	seq_printf(m,
 		   "BdiWriteback:     %8lu kB\n"
-		   "BdiReclaimable:   %8lu kB\n"
+		   "BdiDirty:         %8lu kB\n"
+		   "BdiUnstable:      %8lu kB\n"
 		   "BdiDirtyThresh:   %8lu kB\n"
 		   "DirtyThresh:      %8lu kB\n"
 		   "BackgroundThresh: %8lu kB\n"
@@ -102,7 +103,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "wb_list:          %8u\n"
 		   "wb_cnt:           %8u\n",
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
-		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
+		   (unsigned long) K(bdi_stat(bdi, BDI_DIRTY)),
+		   (unsigned long) K(bdi_stat(bdi, BDI_UNSTABLE)),
 		   K(bdi_thresh), K(dirty_thresh),
 		   K(background_thresh), nr_wb, nr_dirty, nr_io, nr_more_io,
 		   !list_empty(&bdi->bdi_list), bdi->state, bdi->wb_mask,
diff --git a/mm/filemap.c b/mm/filemap.c
index 698ea80..a016561 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -136,7 +136,7 @@ void __remove_from_page_cache(struct page *page)
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
 		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
 	}
 }
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0b19943..23d3fc6 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -272,7 +272,8 @@ static void clip_bdi_dirty_limit(struct backing_dev_info *bdi,
 	else
 		avail_dirty = 0;
 
-	avail_dirty += bdi_stat(bdi, BDI_RECLAIMABLE) +
+	avail_dirty += bdi_stat(bdi, BDI_DIRTY) +
+		bdi_stat(bdi, BDI_UNSTABLE) +
 		bdi_stat(bdi, BDI_WRITEBACK);
 
 	*pbdi_dirty = min(*pbdi_dirty, avail_dirty);
@@ -509,7 +510,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 					global_page_state(NR_UNSTABLE_NFS);
 		nr_writeback = global_page_state(NR_WRITEBACK);
 
-		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
+		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
+				     bdi_stat(bdi, BDI_UNSTABLE);
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 
 		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
@@ -554,10 +556,12 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * deltas.
 		 */
 		if (bdi_thresh < 2*bdi_stat_error(bdi)) {
-			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_RECLAIMABLE);
+			bdi_nr_reclaimable = bdi_stat_sum(bdi, BDI_DIRTY) +
+					     bdi_stat_sum(bdi, BDI_UNSTABLE);
 			bdi_nr_writeback = bdi_stat_sum(bdi, BDI_WRITEBACK);
 		} else if (bdi_nr_reclaimable) {
-			bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
+			bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
+					     bdi_stat(bdi, BDI_UNSTABLE);
 			bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
@@ -1079,7 +1083,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
-		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
 		task_dirty_inc(current);
 		task_io_account_write(PAGE_CACHE_SIZE);
 	}
@@ -1255,7 +1259,7 @@ int clear_page_dirty_for_io(struct page *page)
 		if (TestClearPageDirty(page)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
-					BDI_RECLAIMABLE);
+					BDI_DIRTY);
 			return 1;
 		}
 		return 0;
diff --git a/mm/truncate.c b/mm/truncate.c
index e87e372..2466e0c 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -75,7 +75,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 		if (mapping && mapping_cap_account_dirty(mapping)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
-					BDI_RECLAIMABLE);
+					BDI_DIRTY);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
 		}
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

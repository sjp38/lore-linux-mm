Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 595C76B008A
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:54 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/13] VM/NFS: The VM must tell the filesystem when to free reclaimable pages
Date: Wed, 10 Feb 2010 12:03:25 -0500
Message-Id: <1265821413-21618-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

balance_dirty_pages() should really tell the filesystem whether or not it
has an excess of actual dirty pages, or whether it would be more useful to
start freeing up the unstable writes.

Assume that if the number of unstable writes is more than 1/2 the number of
reclaimable pages, then we should force NFS to free up the former.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Acked-by: Jan Kara <jack@suse.cz>
Acked-by: Peter Zijlstra <peterz@infradead.org>
---
 fs/nfs/write.c            |    2 +-
 include/linux/writeback.h |    5 +++++
 mm/page-writeback.c       |   12 ++++++++++--
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ed032c0..2f1d9a6 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1415,7 +1415,7 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 	/* Don't commit yet if this is a non-blocking flush and there are
 	 * outstanding writes for this mapping.
 	 */
-	if (wbc->sync_mode != WB_SYNC_ALL &&
+	if (!wbc->force_commit_unstable && wbc->sync_mode != WB_SYNC_ALL &&
 	    radix_tree_tagged(&NFS_I(inode)->nfs_page_tree,
 		    NFS_PAGE_TAG_LOCKED))
 		goto out_mark_dirty;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 76e8903..8229139 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -62,6 +62,11 @@ struct writeback_control {
 	 * so we use a single control to update them
 	 */
 	unsigned no_nrwrite_index_update:1;
+	/*
+	 * The following is used by balance_dirty_pages() to
+	 * force NFS to commit unstable pages.
+	 */
+	unsigned force_commit_unstable:1;
 };
 
 /*
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c06739b..6a0aec7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -503,6 +503,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 			.nr_to_write	= write_chunk,
 			.range_cyclic	= 1,
 		};
+		long bdi_nr_unstable = 0;
 
 		get_dirty_limits(&background_thresh, &dirty_thresh,
 				&bdi_thresh, bdi);
@@ -512,8 +513,10 @@ static void balance_dirty_pages(struct address_space *mapping,
 		nr_writeback = global_page_state(NR_WRITEBACK);
 
 		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY);
-		if (bdi_cap_account_unstable(bdi))
-			bdi_nr_reclaimable += bdi_stat(bdi, BDI_UNSTABLE);
+		if (bdi_cap_account_unstable(bdi)) {
+			bdi_nr_unstable = bdi_stat(bdi, BDI_UNSTABLE);
+			bdi_nr_reclaimable += bdi_nr_unstable;
+		}
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 
 		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
@@ -541,6 +544,11 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * up.
 		 */
 		if (bdi_nr_reclaimable > bdi_thresh) {
+			wbc.force_commit_unstable = 0;
+			/* Force NFS to also free up unstable writes. */
+			if (bdi_nr_unstable > bdi_nr_reclaimable / 2)
+				wbc.force_commit_unstable = 1;
+
 			writeback_inodes_wbc(&wbc);
 			pages_written += write_chunk - wbc.nr_to_write;
 			get_dirty_limits(&background_thresh, &dirty_thresh,
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

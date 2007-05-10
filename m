Message-Id: <20070510101129.394378283@chello.nl>
References: <20070510100839.621199408@chello.nl>
Date: Thu, 10 May 2007 12:08:48 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 09/15] mm: count reclaimable pages per BDI
Content-Disposition: inline; filename=bdi_stat_reclaimable.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

Count per BDI reclaimable pages; nr_reclaimable = nr_dirty + nr_unstable.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/buffer.c                 |    2 ++
 fs/nfs/write.c              |    7 +++++++
 include/linux/backing-dev.h |    1 +
 mm/page-writeback.c         |    4 ++++
 mm/truncate.c               |    2 ++
 5 files changed, 16 insertions(+)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2007-04-24 21:18:29.000000000 +0200
+++ linux-2.6/fs/buffer.c	2007-04-25 08:20:10.000000000 +0200
@@ -734,6 +734,8 @@ int __set_page_dirty_buffers(struct page
 	if (page->mapping) {	/* Race with truncate? */
 		if (mapping_cap_account_dirty(mapping)) {
 			__inc_zone_page_state(page, NR_FILE_DIRTY);
+			__inc_bdi_stat(mapping->backing_dev_info,
+					BDI_RECLAIMABLE);
 			task_io_account_write(PAGE_CACHE_SIZE);
 		}
 		radix_tree_tag_set(&mapping->page_tree,
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-04-24 21:18:30.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2007-04-25 08:20:10.000000000 +0200
@@ -828,6 +828,8 @@ int __set_page_dirty_nobuffers(struct pa
 			BUG_ON(mapping2 != mapping);
 			if (mapping_cap_account_dirty(mapping)) {
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
+				__inc_bdi_stat(mapping->backing_dev_info,
+						BDI_RECLAIMABLE);
 				task_io_account_write(PAGE_CACHE_SIZE);
 			}
 			radix_tree_tag_set(&mapping->page_tree,
@@ -961,6 +963,8 @@ int clear_page_dirty_for_io(struct page 
 		 */
 		if (TestClearPageDirty(page)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
+			dec_bdi_stat(mapping->backing_dev_info,
+					BDI_RECLAIMABLE);
 			return 1;
 		}
 		return 0;
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c	2007-04-24 21:18:30.000000000 +0200
+++ linux-2.6/mm/truncate.c	2007-04-25 08:20:10.000000000 +0200
@@ -72,6 +72,8 @@ void cancel_dirty_page(struct page *page
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
+			dec_bdi_stat(mapping->backing_dev_info,
+					BDI_RECLAIMABLE);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
 		}
Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c	2007-04-25 08:17:04.000000000 +0200
+++ linux-2.6/fs/nfs/write.c	2007-04-25 08:20:29.000000000 +0200
@@ -454,6 +454,7 @@ nfs_mark_request_commit(struct nfs_page 
 	set_bit(PG_NEED_COMMIT, &(req)->wb_flags);
 	spin_unlock(&nfsi->req_lock);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
 
@@ -552,6 +553,8 @@ static void nfs_cancel_commit_list(struc
 	while(!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+				BDI_RECLAIMABLE);
 		nfs_list_remove_request(req);
 		clear_bit(PG_NEED_COMMIT, &(req)->wb_flags);
 		nfs_inode_remove_request(req);
@@ -1269,6 +1272,8 @@ nfs_commit_list(struct inode *inode, str
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+				BDI_RECLAIMABLE);
 		nfs_clear_page_writeback(req);
 	}
 	return -ENOMEM;
@@ -1294,6 +1299,8 @@ static void nfs_commit_done(struct rpc_t
 		nfs_list_remove_request(req);
 		clear_bit(PG_NEED_COMMIT, &(req)->wb_flags);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
+		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+				BDI_RECLAIMABLE);
 
 		dprintk("NFS: commit (%s/%Ld %d@%Ld)",
 			req->wb_context->dentry->d_inode->i_sb->s_id,
Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h	2007-04-25 08:20:03.000000000 +0200
+++ linux-2.6/include/linux/backing-dev.h	2007-04-25 08:20:10.000000000 +0200
@@ -27,6 +27,7 @@ enum bdi_state {
 typedef int (congested_fn)(void *, int);
 
 enum bdi_stat_item {
+	BDI_RECLAIMABLE,
 	NR_BDI_STAT_ITEMS
 };
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

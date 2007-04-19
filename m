Subject: Re: [PATCH 09/12] mm: count unstable pages per BDI
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1177006362.2934.13.camel@lappy>
References: <20070417071046.318415445@chello.nl>
	 <20070417071703.710381113@chello.nl>
	 <E1Heafy-0006ia-00@dorka.pomaz.szeredi.hu> <1177006362.2934.13.camel@lappy>
Content-Type: text/plain
Date: Thu, 19 Apr 2007 20:46:46 +0200
Message-Id: <1177008406.2934.19.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-04-19 at 20:12 +0200, Peter Zijlstra wrote:
> On Thu, 2007-04-19 at 19:44 +0200, Miklos Szeredi wrote:
> > > Count per BDI unstable pages.
> > > 
> > 
> > I'm wondering, is it really worth having this category separate from
> > per BDI brity pages?
> > 
> > With the exception of the export to sysfs, always the sum of unstable
> > + dirty is used.
> 
> I guess you are right, but it offends my sense of aesthetics to break
> symmetry with the zone statistics. However, it has the added advantage
> of only needing 2 deltas as well.

I guess, this should do.

---
 fs/buffer.c                 |    2 +-
 fs/nfs/write.c              |   11 +++++++----
 include/linux/backing-dev.h |    3 +--
 mm/page-writeback.c         |   16 +++++++---------
 mm/truncate.c               |    2 +-
 5 files changed, 17 insertions(+), 17 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2007-04-19 19:59:26.000000000 +0200
+++ linux-2.6/fs/buffer.c	2007-04-19 20:35:39.000000000 +0200
@@ -733,7 +733,7 @@ int __set_page_dirty_buffers(struct page
 	if (page->mapping) {	/* Race with truncate? */
 		if (mapping_cap_account_dirty(mapping)) {
 			__inc_zone_page_state(page, NR_FILE_DIRTY);
-			__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
+			__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIM);
 			task_io_account_write(PAGE_CACHE_SIZE);
 		}
 		radix_tree_tag_set(&mapping->page_tree,
Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c	2007-04-19 19:59:26.000000000 +0200
+++ linux-2.6/fs/nfs/write.c	2007-04-19 20:39:03.000000000 +0200
@@ -456,7 +456,7 @@ nfs_mark_request_commit(struct nfs_page 
 	nfsi->ncommit++;
 	spin_unlock(&nfsi->req_lock);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_UNSTABLE);
+	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIM);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
 #endif
@@ -518,7 +518,8 @@ static void nfs_cancel_commit_list(struc
 	while(!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_UNSTABLE);
+		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+				BDI_RECLAIM);
 		nfs_list_remove_request(req);
 		nfs_inode_remove_request(req);
 		nfs_unlock_request(req);
@@ -1247,7 +1248,8 @@ nfs_commit_list(struct inode *inode, str
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_UNSTABLE);
+		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+				BDI_RECLAIM);
 		nfs_clear_page_writeback(req);
 	}
 	return -ENOMEM;
@@ -1272,7 +1274,8 @@ static void nfs_commit_done(struct rpc_t
 		req = nfs_list_entry(data->pages.next);
 		nfs_list_remove_request(req);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
-		dec_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_UNSTABLE);
+		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
+				BDI_RECLAIM);
 
 		dprintk("NFS: commit (%s/%Ld %d@%Ld)",
 			req->wb_context->dentry->d_inode->i_sb->s_id,
Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h	2007-04-19 19:59:26.000000000 +0200
+++ linux-2.6/include/linux/backing-dev.h	2007-04-19 20:39:24.000000000 +0200
@@ -26,9 +26,8 @@ enum bdi_state {
 typedef int (congested_fn)(void *, int);
 
 enum bdi_stat_item {
-	BDI_DIRTY,
+	BDI_RECLAIM,
 	BDI_WRITEBACK,
-	BDI_UNSTABLE,
 	BDI_WRITEOUT,
 	NR_BDI_STAT_ITEMS
 };
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-04-19 20:00:09.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2007-04-19 20:40:29.000000000 +0200
@@ -300,8 +300,7 @@ static void balance_dirty_pages(struct a
 
 		get_dirty_limits(&background_thresh, &dirty_thresh,
 				&bdi_thresh, bdi);
-		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
-					bdi_stat(bdi, BDI_UNSTABLE);
+		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIM);
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
 		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
 				break;
@@ -321,16 +320,14 @@ static void balance_dirty_pages(struct a
 			get_dirty_limits(&background_thresh, &dirty_thresh,
 				       &bdi_thresh, bdi);
 
-			if (bdi_thresh < 3*bdi_stat_delta()) {
+			if (bdi_thresh < 2*bdi_stat_delta()) {
 				bdi_nr_reclaimable =
-					bdi_stat_sum(bdi, BDI_DIRTY) +
-					bdi_stat_sum(bdi, BDI_UNSTABLE);
+					bdi_stat_sum(bdi, BDI_RECLAIM);
 				bdi_nr_writeback =
 					bdi_stat_sum(bdi, BDI_WRITEBACK);
 			} else {
 				bdi_nr_reclaimable =
-					bdi_stat(bdi, BDI_DIRTY) +
-					bdi_stat(bdi, BDI_UNSTABLE);
+					bdi_stat(bdi, BDI_RECLAIM);
 				bdi_nr_writeback =
 					bdi_stat(bdi, BDI_WRITEBACK);
 			}
@@ -907,7 +904,8 @@ int __set_page_dirty_nobuffers(struct pa
 			BUG_ON(mapping2 != mapping);
 			if (mapping_cap_account_dirty(mapping)) {
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
-				__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
+				__inc_bdi_stat(mapping->backing_dev_info,
+						BDI_RECLAIM);
 				task_io_account_write(PAGE_CACHE_SIZE);
 			}
 			radix_tree_tag_set(&mapping->page_tree,
@@ -1034,7 +1032,7 @@ int clear_page_dirty_for_io(struct page 
 			set_page_dirty(page);
 		if (TestClearPageDirty(page)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
+			dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIM);
 			return 1;
 		}
 		return 0;
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c	2007-04-19 19:59:26.000000000 +0200
+++ linux-2.6/mm/truncate.c	2007-04-19 20:40:36.000000000 +0200
@@ -71,7 +71,7 @@ void cancel_dirty_page(struct page *page
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
+			dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIM);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

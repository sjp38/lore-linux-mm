Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B17A15F0047
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:17:05 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v2 06/11] memcg: add kernel calls for memcg dirty page stats
Date: Fri, 15 Oct 2010 14:14:34 -0700
Message-Id: <1287177279-30876-7-git-send-email-gthelen@google.com>
In-Reply-To: <1287177279-30876-1-git-send-email-gthelen@google.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Add calls into memcg dirty page accounting.  Notify memcg when pages
transition between clean, file dirty, writeback, and unstable nfs.
This allows the memory controller to maintain an accurate view of
the amount of its memory that is dirty.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrea Righi <arighi@develer.com>
---
 fs/nfs/write.c      |    4 ++++
 mm/filemap.c        |    1 +
 mm/page-writeback.c |    4 ++++
 mm/truncate.c       |    1 +
 4 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 4c14c17..a3c39f7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -450,6 +450,7 @@ nfs_mark_request_commit(struct nfs_page *req)
 			NFS_PAGE_TAG_COMMIT);
 	nfsi->ncommit++;
 	spin_unlock(&inode->i_lock);
+	mem_cgroup_inc_page_stat(req->wb_page, MEMCG_NR_FILE_UNSTABLE_NFS);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
@@ -461,6 +462,7 @@ nfs_clear_request_commit(struct nfs_page *req)
 	struct page *page = req->wb_page;
 
 	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_UNSTABLE_NFS);
 		dec_zone_page_state(page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 		return 1;
@@ -1316,6 +1318,8 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req);
+		mem_cgroup_dec_page_stat(req->wb_page,
+					 MEMCG_NR_FILE_UNSTABLE_NFS);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
 				BDI_RECLAIMABLE);
diff --git a/mm/filemap.c b/mm/filemap.c
index 49b2d2e..f6bd6f2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -146,6 +146,7 @@ void __remove_from_page_cache(struct page *page)
 	 * having removed the page entirely.
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 	}
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b840afa..820eb66 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1114,6 +1114,7 @@ int __set_page_dirty_no_writeback(struct page *page)
 void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
@@ -1303,6 +1304,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 * for more comments.
 		 */
 		if (TestClearPageDirty(page)) {
+			mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
@@ -1333,6 +1335,7 @@ int test_clear_page_writeback(struct page *page)
 				__dec_bdi_stat(bdi, BDI_WRITEBACK);
 				__bdi_writeout_inc(bdi);
 			}
+			mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_WRITEBACK);
 		}
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
@@ -1360,6 +1363,7 @@ int test_set_page_writeback(struct page *page)
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi))
 				__inc_bdi_stat(bdi, BDI_WRITEBACK);
+			mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_WRITEBACK);
 		}
 		if (!PageDirty(page))
 			radix_tree_tag_clear(&mapping->page_tree,
diff --git a/mm/truncate.c b/mm/truncate.c
index cd94607..54cca83 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -76,6 +76,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 	if (TestClearPageDirty(page)) {
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
+			mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

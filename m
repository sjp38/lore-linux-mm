Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC6F900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 12:16:37 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v9 04/13] memcg: add kernel calls for memcg dirty page stats
Date: Wed, 17 Aug 2011 09:14:56 -0700
Message-Id: <1313597705-6093-5-git-send-email-gthelen@google.com>
In-Reply-To: <1313597705-6093-1-git-send-email-gthelen@google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>

Add calls into memcg dirty page accounting.  Notify memcg when pages
transition between clean, file dirty, writeback, and unstable nfs.  This
allows the memory controller to maintain an accurate view of the amount
of its memory that is dirty.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrea Righi <andrea@betterlinux.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 fs/nfs/write.c      |    4 ++++
 mm/filemap.c        |    1 +
 mm/page-writeback.c |    4 ++++
 mm/truncate.c       |    1 +
 4 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b39b37f8..f033983 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -449,6 +449,7 @@ nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg)
 	nfsi->ncommit++;
 	spin_unlock(&inode->i_lock);
 	pnfs_mark_request_commit(req, lseg);
+	mem_cgroup_inc_page_stat(req->wb_page, MEMCG_NR_FILE_UNSTABLE_NFS);
 	inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 	inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
@@ -460,6 +461,7 @@ nfs_clear_request_commit(struct nfs_page *req)
 	struct page *page = req->wb_page;
 
 	if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_UNSTABLE_NFS);
 		dec_zone_page_state(page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(page->mapping->backing_dev_info, BDI_RECLAIMABLE);
 		return 1;
@@ -1408,6 +1410,8 @@ void nfs_retry_commit(struct list_head *page_list,
 		req = nfs_list_entry(page_list->next);
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req, lseg);
+		mem_cgroup_dec_page_stat(req->wb_page,
+					 MEMCG_NR_FILE_UNSTABLE_NFS);
 		dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
 		dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
 			     BDI_RECLAIMABLE);
diff --git a/mm/filemap.c b/mm/filemap.c
index 645a080..acf2382 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -142,6 +142,7 @@ void __delete_from_page_cache(struct page *page)
 	 * having removed the page entirely.
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 	}
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 938d943..b1f2390 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1328,6 +1328,7 @@ int __set_page_dirty_no_writeback(struct page *page)
 void account_page_dirtied(struct page *page, struct address_space *mapping)
 {
 	if (mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
@@ -1344,6 +1345,7 @@ EXPORT_SYMBOL(account_page_dirtied);
  */
 void account_page_writeback(struct page *page)
 {
+	mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_WRITEBACK);
 	inc_zone_page_state(page, NR_WRITEBACK);
 }
 EXPORT_SYMBOL(account_page_writeback);
@@ -1526,6 +1528,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 * for more comments.
 		 */
 		if (TestClearPageDirty(page)) {
+			mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
@@ -1562,6 +1565,7 @@ int test_clear_page_writeback(struct page *page)
 		ret = TestClearPageWriteback(page);
 	}
 	if (ret) {
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_WRITEBACK);
 		dec_zone_page_state(page, NR_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITTEN);
 	}
diff --git a/mm/truncate.c b/mm/truncate.c
index b40ac6d..bb85b76 100644
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
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id B1A0E6B009B
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 00:56:00 -0400 (EDT)
Received: by qgez102 with SMTP id z102so48341625qge.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:56:00 -0700 (PDT)
Received: from mail-qg0-x235.google.com (mail-qg0-x235.google.com. [2607:f8b0:400d:c04::235])
        by mx.google.com with ESMTPS id a8si11273227qce.17.2015.03.22.21.55.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 21:55:48 -0700 (PDT)
Received: by qgez102 with SMTP id z102so48339489qge.3
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 21:55:48 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 23/48] writeback: attribute stats to the matching per-cgroup bdi_writeback
Date: Mon, 23 Mar 2015 00:54:34 -0400
Message-Id: <1427086499-15657-24-git-send-email-tj@kernel.org>
In-Reply-To: <1427086499-15657-1-git-send-email-tj@kernel.org>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

Until now, all WB_* stats were accounted against the root wb
(bdi_writeback), now that multiple wb (bdi_writeback) support is in
place, let's attributes the stats to the respective per-cgroup wb's.

As no filesystem has FS_CGROUP_WRITEBACK yet, this doesn't lead to
visible behavior differences.

v2: Updated for per-inode wb association.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 mm/filemap.c        |  2 +-
 mm/page-writeback.c | 22 ++++++++++++++--------
 mm/truncate.c       |  6 ++++--
 3 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index a2b098b..64698fa 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -215,7 +215,7 @@ void __delete_from_page_cache(struct page *page, void *shadow,
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
 		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_wb_stat(&inode_to_bdi(mapping->host)->wb, WB_RECLAIMABLE);
+		dec_wb_stat(inode_to_wb(mapping->host), WB_RECLAIMABLE);
 	}
 }
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 10624e3..d5635cf 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2175,10 +2175,13 @@ EXPORT_SYMBOL(__set_page_dirty_nobuffers);
 void account_page_redirty(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
+
 	if (mapping && mapping_cap_account_dirty(mapping)) {
+		struct bdi_writeback *wb = inode_to_wb(mapping->host);
+
 		current->nr_dirtied--;
 		dec_zone_page_state(page, NR_DIRTIED);
-		dec_wb_stat(&inode_to_bdi(mapping->host)->wb, WB_DIRTIED);
+		dec_wb_stat(wb, WB_DIRTIED);
 	}
 }
 EXPORT_SYMBOL(account_page_redirty);
@@ -2324,8 +2327,7 @@ int clear_page_dirty_for_io(struct page *page)
 		if (TestClearPageDirty(page)) {
 			mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_wb_stat(&inode_to_bdi(mapping->host)->wb,
-				    WB_RECLAIMABLE);
+			dec_wb_stat(inode_to_wb(mapping->host), WB_RECLAIMABLE);
 			ret = 1;
 		}
 		mem_cgroup_end_page_stat(memcg);
@@ -2343,7 +2345,8 @@ int test_clear_page_writeback(struct page *page)
 
 	memcg = mem_cgroup_begin_page_stat(page);
 	if (mapping) {
-		struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
+		struct inode *inode = mapping->host;
+		struct backing_dev_info *bdi = inode_to_bdi(inode);
 		unsigned long flags;
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
@@ -2353,8 +2356,10 @@ int test_clear_page_writeback(struct page *page)
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi)) {
-				__dec_wb_stat(&bdi->wb, WB_WRITEBACK);
-				__wb_writeout_inc(&bdi->wb);
+				struct bdi_writeback *wb = inode_to_wb(inode);
+
+				__dec_wb_stat(wb, WB_WRITEBACK);
+				__wb_writeout_inc(wb);
 			}
 		}
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
@@ -2378,7 +2383,8 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 
 	memcg = mem_cgroup_begin_page_stat(page);
 	if (mapping) {
-		struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
+		struct inode *inode = mapping->host;
+		struct backing_dev_info *bdi = inode_to_bdi(inode);
 		unsigned long flags;
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
@@ -2388,7 +2394,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi))
-				__inc_wb_stat(&bdi->wb, WB_WRITEBACK);
+				__inc_wb_stat(inode_to_wb(inode), WB_WRITEBACK);
 		}
 		if (!PageDirty(page))
 			radix_tree_tag_clear(&mapping->page_tree,
diff --git a/mm/truncate.c b/mm/truncate.c
index df16f8c..fe2d769 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -113,11 +113,13 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 	memcg = mem_cgroup_begin_page_stat(page);
 	if (TestClearPageDirty(page)) {
 		struct address_space *mapping = page->mapping;
+
 		if (mapping && mapping_cap_account_dirty(mapping)) {
+			struct bdi_writeback *wb = inode_to_wb(mapping->host);
+
 			mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_wb_stat(&inode_to_bdi(mapping->host)->wb,
-				    WB_RECLAIMABLE);
+			dec_wb_stat(wb, WB_RECLAIMABLE);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
 		}
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

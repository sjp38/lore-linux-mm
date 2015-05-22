Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id A1F5D829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:15:04 -0400 (EDT)
Received: by qget53 with SMTP id t53so16185390qge.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:04 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id f8si281802qkh.5.2015.05.22.14.15.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:15:04 -0700 (PDT)
Received: by qkgv12 with SMTP id v12so22226743qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:15:03 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 25/51] writeback: attribute stats to the matching per-cgroup bdi_writeback
Date: Fri, 22 May 2015 17:13:39 -0400
Message-Id: <1432329245-5844-26-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Tejun Heo <tj@kernel.org>

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
 mm/page-writeback.c | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 9b95cf8..4d0a9da 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2130,7 +2130,7 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 	if (mapping_cap_account_dirty(mapping)) {
 		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_wb_stat(&inode_to_bdi(mapping->host)->wb, WB_RECLAIMABLE);
+		dec_wb_stat(inode_to_wb(mapping->host), WB_RECLAIMABLE);
 		task_io_account_cancelled_write(PAGE_CACHE_SIZE);
 	}
 }
@@ -2191,10 +2191,13 @@ EXPORT_SYMBOL(__set_page_dirty_nobuffers);
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
@@ -2373,8 +2376,7 @@ int clear_page_dirty_for_io(struct page *page)
 		if (TestClearPageDirty(page)) {
 			mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_wb_stat(&inode_to_bdi(mapping->host)->wb,
-				    WB_RECLAIMABLE);
+			dec_wb_stat(inode_to_wb(mapping->host), WB_RECLAIMABLE);
 			ret = 1;
 		}
 		mem_cgroup_end_page_stat(memcg);
@@ -2392,7 +2394,8 @@ int test_clear_page_writeback(struct page *page)
 
 	memcg = mem_cgroup_begin_page_stat(page);
 	if (mapping) {
-		struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
+		struct inode *inode = mapping->host;
+		struct backing_dev_info *bdi = inode_to_bdi(inode);
 		unsigned long flags;
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
@@ -2402,8 +2405,10 @@ int test_clear_page_writeback(struct page *page)
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
@@ -2427,7 +2432,8 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 
 	memcg = mem_cgroup_begin_page_stat(page);
 	if (mapping) {
-		struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
+		struct inode *inode = mapping->host;
+		struct backing_dev_info *bdi = inode_to_bdi(inode);
 		unsigned long flags;
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
@@ -2437,7 +2443,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi))
-				__inc_wb_stat(&bdi->wb, WB_WRITEBACK);
+				__inc_wb_stat(inode_to_wb(inode), WB_WRITEBACK);
 		}
 		if (!PageDirty(page))
 			radix_tree_tag_clear(&mapping->page_tree,
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

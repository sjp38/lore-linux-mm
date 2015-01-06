Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 31C2A6B012F
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:43 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id c9so62297qcz.33
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:43 -0800 (PST)
Received: from mail-qa0-x22e.google.com (mail-qa0-x22e.google.com. [2607:f8b0:400d:c00::22e])
        by mx.google.com with ESMTPS id l10si65714053qgf.74.2015.01.06.13.26.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:42 -0800 (PST)
Received: by mail-qa0-f46.google.com with SMTP id w8so218482qac.5
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:41 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 07/45] writeback: attribute stats to the matching per-cgroup bdi_writeback
Date: Tue,  6 Jan 2015 16:25:44 -0500
Message-Id: <1420579582-8516-8-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

Until now, all WB_* stats were accounted against the root wb
(bdi_writeback), now that multiple wb (bdi_writeback) support is in
place, let's attributes the stats to the respective per-cgroup wb's.

WB_RECLAIMABLE and WB_DIRTIED are attributed to the page's dirty cgwb
(per-cgroup wb) and WB_WRITEBACK to writeback cgwb.
__test_set_page_writeback() is updated so that dirty cgwb association
takes place before WB_WRITEBACK increment so that the latter can make
use of the association.

As no filesystem has FS_CGROUP_WRITEBACK yet, this doesn't lead to
visible behavior differences.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
---
 mm/filemap.c        |  2 +-
 mm/page-writeback.c | 18 ++++++++++++------
 mm/truncate.c       |  3 +--
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 98a6675..faa577d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -211,7 +211,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
 		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_wb_stat(&mapping->backing_dev_info->wb, WB_RECLAIMABLE);
+		dec_wb_stat(page_cgwb_dirty(page), WB_RECLAIMABLE);
 		page_blkcg_detach_dirty(page);
 	}
 }
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 6475504..d1fea3a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2159,10 +2159,13 @@ EXPORT_SYMBOL(__set_page_dirty_nobuffers);
 void account_page_redirty(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
+
 	if (mapping && mapping_cap_account_dirty(mapping)) {
+		struct bdi_writeback *wb = page_cgwb_dirty(page);
+
 		current->nr_dirtied--;
 		dec_zone_page_state(page, NR_DIRTIED);
-		dec_wb_stat(&mapping->backing_dev_info->wb, WB_DIRTIED);
+		dec_wb_stat(wb, WB_DIRTIED);
 	}
 }
 EXPORT_SYMBOL(account_page_redirty);
@@ -2300,9 +2303,10 @@ int clear_page_dirty_for_io(struct page *page)
 		 * exclusion.
 		 */
 		if (TestClearPageDirty(page)) {
+			struct bdi_writeback *wb = page_cgwb_dirty(page);
+
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_wb_stat(&mapping->backing_dev_info->wb,
-				    WB_RECLAIMABLE);
+			dec_wb_stat(wb, WB_RECLAIMABLE);
 			page_blkcg_detach_dirty(page);
 			return 1;
 		}
@@ -2330,9 +2334,11 @@ int test_clear_page_writeback(struct page *page)
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi)) {
-				__dec_wb_stat(&bdi->wb, WB_WRITEBACK);
+				struct bdi_writeback *wb = page_cgwb_wb(page);
+
+				__dec_wb_stat(wb, WB_WRITEBACK);
 				page_blkcg_detach_wb(page);
-				__wb_writeout_inc(&bdi->wb);
+				__wb_writeout_inc(wb);
 			}
 		}
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
@@ -2366,8 +2372,8 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
 			if (bdi_cap_account_writeback(bdi)) {
-				__inc_wb_stat(&bdi->wb, WB_WRITEBACK);
 				page_blkcg_attach_wb(page);
+				__inc_wb_stat(page_cgwb_wb(page), WB_WRITEBACK);
 			}
 		}
 		if (!PageDirty(page))
diff --git a/mm/truncate.c b/mm/truncate.c
index caae624..1658e34 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -112,8 +112,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_wb_stat(&mapping->backing_dev_info->wb,
-				    WB_RECLAIMABLE);
+			dec_wb_stat(page_cgwb_dirty(page), WB_RECLAIMABLE);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
 			page_blkcg_detach_dirty(page);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

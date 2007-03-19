Message-Id: <20070319164319.915668869@programming.kicks-ass.net>
References: <20070319155737.653325176@programming.kicks-ass.net>
Date: Mon, 19 Mar 2007 16:57:39 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 2/6] mm: count dirty pages per BDI
Content-Disposition: inline; filename=bdi_stat_dirty.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Count per BDI dirty pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/buffer.c                 |    1 +
 include/linux/backing-dev.h |    1 +
 mm/page-writeback.c         |    2 ++
 mm/truncate.c               |    1 +
 4 files changed, 5 insertions(+)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -732,6 +732,7 @@ int __set_page_dirty_buffers(struct page
 	if (page->mapping) {	/* Race with truncate? */
 		if (mapping_cap_account_dirty(mapping)) {
 			__inc_zone_page_state(page, NR_FILE_DIRTY);
+			__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
 			task_io_account_write(PAGE_CACHE_SIZE);
 		}
 		radix_tree_tag_set(&mapping->page_tree,
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -766,6 +766,7 @@ int __set_page_dirty_nobuffers(struct pa
 			BUG_ON(mapping2 != mapping);
 			if (mapping_cap_account_dirty(mapping)) {
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
+				__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
 				task_io_account_write(PAGE_CACHE_SIZE);
 			}
 			radix_tree_tag_set(&mapping->page_tree,
@@ -892,6 +893,7 @@ int clear_page_dirty_for_io(struct page 
 			set_page_dirty(page);
 		if (TestClearPageDirty(page)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
+			dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
 			return 1;
 		}
 		return 0;
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -71,6 +71,7 @@ void cancel_dirty_page(struct page *page
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
+			dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
 		}
Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h
+++ linux-2.6/include/linux/backing-dev.h
@@ -23,6 +23,7 @@ enum bdi_state {
 };
 
 enum bdi_stat_item {
+	BDI_DIRTY,
 	NR_BDI_STAT_ITEMS
 };
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

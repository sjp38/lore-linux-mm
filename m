Message-Id: <20070803125237.072937000@chello.nl>
References: <20070803123712.987126000@chello.nl>
Date: Fri, 03 Aug 2007 14:37:30 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 17/23] mm: count writeback pages per BDI
Content-Disposition: inline; filename=bdi_stat_writeback.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Count per BDI writeback pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/backing-dev.h |    1 +
 mm/page-writeback.c         |   12 ++++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -981,14 +981,18 @@ int test_clear_page_writeback(struct pag
 	int ret;
 
 	if (mapping) {
+		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
 
 		write_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestClearPageWriteback(page);
-		if (ret)
+		if (ret) {
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
+			if (bdi_cap_writeback_dirty(bdi))
+				__dec_bdi_stat(bdi, BDI_WRITEBACK);
+		}
 		write_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
 		ret = TestClearPageWriteback(page);
@@ -1004,14 +1008,18 @@ int test_set_page_writeback(struct page 
 	int ret;
 
 	if (mapping) {
+		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
 
 		write_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestSetPageWriteback(page);
-		if (!ret)
+		if (!ret) {
 			radix_tree_tag_set(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
+			if (bdi_cap_writeback_dirty(bdi))
+				__inc_bdi_stat(bdi, BDI_WRITEBACK);
+		}
 		if (!PageDirty(page))
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h
+++ linux-2.6/include/linux/backing-dev.h
@@ -28,6 +28,7 @@ typedef int (congested_fn)(void *, int);
 
 enum bdi_stat_item {
 	BDI_RECLAIMABLE,
+	BDI_WRITEBACK,
 	NR_BDI_STAT_ITEMS
 };
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

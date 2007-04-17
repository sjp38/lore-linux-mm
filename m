Message-Id: <20070417071702.693712447@chello.nl>
References: <20070417071046.318415445@chello.nl>
Date: Tue, 17 Apr 2007 09:10:47 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 01/12] revert per-backing_dev-dirty-and-writeback-page-accounting
Content-Disposition: inline; filename=revert.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

For ease of application..

---
 block/ll_rw_blk.c           |   29 -----------------------------
 fs/buffer.c                 |    1 -
 include/linux/backing-dev.h |    2 --
 mm/page-writeback.c         |   13 ++-----------
 mm/truncate.c               |    1 -
 5 files changed, 2 insertions(+), 44 deletions(-)

Index: linux-2.6/block/ll_rw_blk.c
===================================================================
--- linux-2.6.orig/block/ll_rw_blk.c	2007-04-10 16:30:55.000000000 +0200
+++ linux-2.6/block/ll_rw_blk.c	2007-04-10 16:35:24.000000000 +0200
@@ -201,8 +201,6 @@ EXPORT_SYMBOL(blk_queue_softirq_done);
  **/
 void blk_queue_make_request(request_queue_t * q, make_request_fn * mfn)
 {
-	struct backing_dev_info *bdi = &q->backing_dev_info;
-
 	/*
 	 * set defaults
 	 */
@@ -210,8 +208,6 @@ void blk_queue_make_request(request_queu
 	blk_queue_max_phys_segments(q, MAX_PHYS_SEGMENTS);
 	blk_queue_max_hw_segments(q, MAX_HW_SEGMENTS);
 	q->make_request_fn = mfn;
-	atomic_long_set(&bdi->nr_dirty, 0);
-	atomic_long_set(&bdi->nr_writeback, 0);
 	blk_queue_max_sectors(q, SAFE_MAX_SECTORS);
 	blk_queue_hardsect_size(q, 512);
 	blk_queue_dma_alignment(q, 511);
@@ -3978,19 +3974,6 @@ static ssize_t queue_max_hw_sectors_show
 	return queue_var_show(max_hw_sectors_kb, (page));
 }
 
-static ssize_t queue_nr_dirty_show(struct request_queue *q, char *page)
-{
-	return sprintf(page, "%lu\n",
-		atomic_long_read(&q->backing_dev_info.nr_dirty));
-
-}
-
-static ssize_t queue_nr_writeback_show(struct request_queue *q, char *page)
-{
-	return sprintf(page, "%lu\n",
-		atomic_long_read(&q->backing_dev_info.nr_writeback));
-
-}
 
 static struct queue_sysfs_entry queue_requests_entry = {
 	.attr = {.name = "nr_requests", .mode = S_IRUGO | S_IWUSR },
@@ -4021,16 +4004,6 @@ static struct queue_sysfs_entry queue_ma
 	.show = queue_max_hw_sectors_show,
 };
 
-static struct queue_sysfs_entry queue_nr_dirty_entry = {
-	.attr = {.name = "nr_dirty", .mode = S_IRUGO },
-	.show = queue_nr_dirty_show,
-};
-
-static struct queue_sysfs_entry queue_nr_writeback_entry = {
-	.attr = {.name = "nr_writeback", .mode = S_IRUGO },
-	.show = queue_nr_writeback_show,
-};
-
 static struct queue_sysfs_entry queue_iosched_entry = {
 	.attr = {.name = "scheduler", .mode = S_IRUGO | S_IWUSR },
 	.show = elv_iosched_show,
@@ -4043,8 +4016,6 @@ static struct attribute *default_attrs[]
 	&queue_initial_ra_entry.attr,
 	&queue_max_hw_sectors_entry.attr,
 	&queue_max_sectors_entry.attr,
-	&queue_nr_dirty_entry.attr,
-	&queue_nr_writeback_entry.attr,
 	&queue_iosched_entry.attr,
 	NULL,
 };
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2007-04-10 16:30:15.000000000 +0200
+++ linux-2.6/fs/buffer.c	2007-04-10 16:35:03.000000000 +0200
@@ -740,7 +740,6 @@ int __set_page_dirty_buffers(struct page
 	if (page->mapping) {	/* Race with truncate? */
 		if (mapping_cap_account_dirty(mapping)) {
 			__inc_zone_page_state(page, NR_FILE_DIRTY);
-			atomic_long_inc(&mapping->backing_dev_info->nr_dirty);
 			task_io_account_write(PAGE_CACHE_SIZE);
 		}
 		radix_tree_tag_set(&mapping->page_tree,
Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h	2007-04-10 16:30:55.000000000 +0200
+++ linux-2.6/include/linux/backing-dev.h	2007-04-10 16:35:03.000000000 +0200
@@ -30,8 +30,6 @@ struct backing_dev_info {
 	unsigned long ra_thrash_bytes;	/* estimated thrashing threshold */
 	unsigned long state;	/* Always use atomic bitops on this */
 	unsigned int capabilities; /* Device capabilities */
-	atomic_long_t nr_dirty;	/* Pages dirty against this BDI */
-	atomic_long_t nr_writeback;/* Pages under writeback against this BDI */
 	congested_fn *congested_fn; /* Function pointer if device is md/dm */
 	void *congested_data;	/* Pointer to aux data for congested func */
 	void (*unplug_io_fn)(struct backing_dev_info *, struct page *);
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-04-10 16:30:15.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2007-04-10 16:35:03.000000000 +0200
@@ -828,8 +828,6 @@ int __set_page_dirty_nobuffers(struct pa
 			BUG_ON(mapping2 != mapping);
 			if (mapping_cap_account_dirty(mapping)) {
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
-				atomic_long_inc(&mapping->backing_dev_info->
-						nr_dirty);
 				task_io_account_write(PAGE_CACHE_SIZE);
 			}
 			radix_tree_tag_set(&mapping->page_tree,
@@ -963,7 +961,6 @@ int clear_page_dirty_for_io(struct page 
 		 */
 		if (TestClearPageDirty(page)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-			atomic_long_dec(&mapping->backing_dev_info->nr_dirty);
 			return 1;
 		}
 		return 0;
@@ -982,13 +979,10 @@ int test_clear_page_writeback(struct pag
 
 		write_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestClearPageWriteback(page);
-		if (ret) {
+		if (ret)
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-			atomic_long_dec(&mapping->backing_dev_info->
-					nr_writeback);
-		}
 		write_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
 		ret = TestClearPageWriteback(page);
@@ -1008,13 +1002,10 @@ int test_set_page_writeback(struct page 
 
 		write_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestSetPageWriteback(page);
-		if (!ret) {
+		if (!ret)
 			radix_tree_tag_set(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-			atomic_long_inc(&mapping->backing_dev_info->
-					nr_writeback);
-		}
 		if (!PageDirty(page))
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c	2007-04-10 16:30:15.000000000 +0200
+++ linux-2.6/mm/truncate.c	2007-04-10 16:35:03.000000000 +0200
@@ -70,7 +70,6 @@ void cancel_dirty_page(struct page *page
 	if (TestClearPageDirty(page)) {
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
-			atomic_long_dec(&mapping->backing_dev_info->nr_dirty);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

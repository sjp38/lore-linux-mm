Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 76D8C8D003B
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 04:19:00 -0400 (EDT)
From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Subject: [PATCH] nilfs2: get rid of private page allocator
Date: Mon,  4 Apr 2011 17:06:30 +0900
Message-Id: <1301904390-5129-1-git-send-email-konishi.ryusuke@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nilfs@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>

Previously, nilfs was cloning pages for mmapped region to freeze their
data and ensure consistency of checksum during writeback cycles.  A
private page allocator was used for this page cloning.  But, we no
longer need to do that since clear_page_dirty_for_io function sets up
pte so that vm_ops->page_mkwrite function is called right before the
mmapped pages are modified and nilfs_page_mkwrite function can safely
wait for the pages to be written back to disk.

So, this stops making a copy of mmapped pages during writeback, and
eliminates the private page allocation and deallocation functions from
nilfs.

Signed-off-by: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
---
 fs/nilfs2/file.c    |    1 -
 fs/nilfs2/page.c    |   53 +-----------------
 fs/nilfs2/page.h    |    4 -
 fs/nilfs2/segbuf.c  |   12 ----
 fs/nilfs2/segment.c |  153 ++++++---------------------------------------------
 fs/nilfs2/segment.h |    2 -
 6 files changed, 18 insertions(+), 207 deletions(-)

diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index 397e732..d7eeca6 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -111,7 +111,6 @@ static int nilfs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	nilfs_transaction_commit(inode->i_sb);
 
  mapped:
-	SetPageChecked(page);
 	wait_on_page_writeback(page);
 	return VM_FAULT_LOCKED;
 }
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index 9d2dc6b..992bef7 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -37,8 +37,7 @@
 
 #define NILFS_BUFFER_INHERENT_BITS  \
 	((1UL << BH_Uptodate) | (1UL << BH_Mapped) | (1UL << BH_NILFS_Node) | \
-	 (1UL << BH_NILFS_Volatile) | (1UL << BH_NILFS_Allocated) | \
-	 (1UL << BH_NILFS_Checked))
+	 (1UL << BH_NILFS_Volatile) | (1UL << BH_NILFS_Checked))
 
 static struct buffer_head *
 __nilfs_get_page_block(struct page *page, unsigned long block, pgoff_t index,
@@ -217,56 +216,6 @@ void nilfs_page_bug(struct page *page)
 }
 
 /**
- * nilfs_alloc_private_page - allocate a private page with buffer heads
- *
- * Return Value: On success, a pointer to the allocated page is returned.
- * On error, NULL is returned.
- */
-struct page *nilfs_alloc_private_page(struct block_device *bdev, int size,
-				      unsigned long state)
-{
-	struct buffer_head *bh, *head, *tail;
-	struct page *page;
-
-	page = alloc_page(GFP_NOFS); /* page_count of the returned page is 1 */
-	if (unlikely(!page))
-		return NULL;
-
-	lock_page(page);
-	head = alloc_page_buffers(page, size, 0);
-	if (unlikely(!head)) {
-		unlock_page(page);
-		__free_page(page);
-		return NULL;
-	}
-
-	bh = head;
-	do {
-		bh->b_state = (1UL << BH_NILFS_Allocated) | state;
-		tail = bh;
-		bh->b_bdev = bdev;
-		bh = bh->b_this_page;
-	} while (bh);
-
-	tail->b_this_page = head;
-	attach_page_buffers(page, head);
-
-	return page;
-}
-
-void nilfs_free_private_page(struct page *page)
-{
-	BUG_ON(!PageLocked(page));
-	BUG_ON(page->mapping);
-
-	if (page_has_buffers(page) && !try_to_free_buffers(page))
-		NILFS_PAGE_BUG(page, "failed to free page");
-
-	unlock_page(page);
-	__free_page(page);
-}
-
-/**
  * nilfs_copy_page -- copy the page with buffers
  * @dst: destination page
  * @src: source page
diff --git a/fs/nilfs2/page.h b/fs/nilfs2/page.h
index f06b79a..f827afa 100644
--- a/fs/nilfs2/page.h
+++ b/fs/nilfs2/page.h
@@ -38,7 +38,6 @@ enum {
 	BH_NILFS_Redirected,
 };
 
-BUFFER_FNS(NILFS_Allocated, nilfs_allocated)	/* nilfs private buffers */
 BUFFER_FNS(NILFS_Node, nilfs_node)		/* nilfs node buffers */
 BUFFER_FNS(NILFS_Volatile, nilfs_volatile)
 BUFFER_FNS(NILFS_Checked, nilfs_checked)	/* buffer is verified */
@@ -54,9 +53,6 @@ void nilfs_forget_buffer(struct buffer_head *);
 void nilfs_copy_buffer(struct buffer_head *, struct buffer_head *);
 int nilfs_page_buffers_clean(struct page *);
 void nilfs_page_bug(struct page *);
-struct page *nilfs_alloc_private_page(struct block_device *, int,
-				      unsigned long);
-void nilfs_free_private_page(struct page *);
 
 int nilfs_copy_dirty_pages(struct address_space *, struct address_space *);
 void nilfs_copy_back_pages(struct address_space *, struct address_space *);
diff --git a/fs/nilfs2/segbuf.c b/fs/nilfs2/segbuf.c
index 2853ff2..410ec2b 100644
--- a/fs/nilfs2/segbuf.c
+++ b/fs/nilfs2/segbuf.c
@@ -254,18 +254,6 @@ static void nilfs_release_buffers(struct list_head *list)
 
 	list_for_each_entry_safe(bh, n, list, b_assoc_buffers) {
 		list_del_init(&bh->b_assoc_buffers);
-		if (buffer_nilfs_allocated(bh)) {
-			struct page *clone_page = bh->b_page;
-
-			/* remove clone page */
-			brelse(bh);
-			page_cache_release(clone_page); /* for each bh */
-			if (page_count(clone_page) <= 2) {
-				lock_page(clone_page);
-				nilfs_free_private_page(clone_page);
-			}
-			continue;
-		}
 		brelse(bh);
 	}
 }
diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
index 5deeadd..abbfab9 100644
--- a/fs/nilfs2/segment.c
+++ b/fs/nilfs2/segment.c
@@ -1556,83 +1556,24 @@ static int nilfs_segctor_assign(struct nilfs_sc_info *sci, int mode)
 	return 0;
 }
 
-static int
-nilfs_copy_replace_page_buffers(struct page *page, struct list_head *out)
-{
-	struct page *clone_page;
-	struct buffer_head *bh, *head, *bh2;
-	void *kaddr;
-
-	bh = head = page_buffers(page);
-
-	clone_page = nilfs_alloc_private_page(bh->b_bdev, bh->b_size, 0);
-	if (unlikely(!clone_page))
-		return -ENOMEM;
-
-	bh2 = page_buffers(clone_page);
-	kaddr = kmap_atomic(page, KM_USER0);
-	do {
-		if (list_empty(&bh->b_assoc_buffers))
-			continue;
-		get_bh(bh2);
-		page_cache_get(clone_page); /* for each bh */
-		memcpy(bh2->b_data, kaddr + bh_offset(bh), bh2->b_size);
-		bh2->b_blocknr = bh->b_blocknr;
-		list_replace(&bh->b_assoc_buffers, &bh2->b_assoc_buffers);
-		list_add_tail(&bh->b_assoc_buffers, out);
-	} while (bh = bh->b_this_page, bh2 = bh2->b_this_page, bh != head);
-	kunmap_atomic(kaddr, KM_USER0);
-
-	if (!TestSetPageWriteback(clone_page))
-		account_page_writeback(clone_page);
-	unlock_page(clone_page);
-
-	return 0;
-}
-
-static int nilfs_test_page_to_be_frozen(struct page *page)
-{
-	struct address_space *mapping = page->mapping;
-
-	if (!mapping || !mapping->host || S_ISDIR(mapping->host->i_mode))
-		return 0;
-
-	if (page_mapped(page)) {
-		ClearPageChecked(page);
-		return 1;
-	}
-	return PageChecked(page);
-}
-
-static int nilfs_begin_page_io(struct page *page, struct list_head *out)
+static void nilfs_begin_page_io(struct page *page)
 {
 	if (!page || PageWriteback(page))
 		/* For split b-tree node pages, this function may be called
 		   twice.  We ignore the 2nd or later calls by this check. */
-		return 0;
+		return;
 
 	lock_page(page);
 	clear_page_dirty_for_io(page);
 	set_page_writeback(page);
 	unlock_page(page);
-
-	if (nilfs_test_page_to_be_frozen(page)) {
-		int err = nilfs_copy_replace_page_buffers(page, out);
-		if (unlikely(err))
-			return err;
-	}
-	return 0;
 }
 
-static int nilfs_segctor_prepare_write(struct nilfs_sc_info *sci,
-				       struct page **failed_page)
+static void nilfs_segctor_prepare_write(struct nilfs_sc_info *sci)
 {
 	struct nilfs_segment_buffer *segbuf;
 	struct page *bd_page = NULL, *fs_page = NULL;
-	struct list_head *list = &sci->sc_copied_buffers;
-	int err;
 
-	*failed_page = NULL;
 	list_for_each_entry(segbuf, &sci->sc_segbufs, sb_list) {
 		struct buffer_head *bh;
 
@@ -1662,11 +1603,7 @@ static int nilfs_segctor_prepare_write(struct nilfs_sc_info *sci,
 				break;
 			}
 			if (bh->b_page != fs_page) {
-				err = nilfs_begin_page_io(fs_page, list);
-				if (unlikely(err)) {
-					*failed_page = fs_page;
-					goto out;
-				}
+				nilfs_begin_page_io(fs_page);
 				fs_page = bh->b_page;
 			}
 		}
@@ -1677,11 +1614,7 @@ static int nilfs_segctor_prepare_write(struct nilfs_sc_info *sci,
 		set_page_writeback(bd_page);
 		unlock_page(bd_page);
 	}
-	err = nilfs_begin_page_io(fs_page, list);
-	if (unlikely(err))
-		*failed_page = fs_page;
- out:
-	return err;
+	nilfs_begin_page_io(fs_page);
 }
 
 static int nilfs_segctor_write(struct nilfs_sc_info *sci,
@@ -1694,24 +1627,6 @@ static int nilfs_segctor_write(struct nilfs_sc_info *sci,
 	return ret;
 }
 
-static void __nilfs_end_page_io(struct page *page, int err)
-{
-	if (!err) {
-		if (!nilfs_page_buffers_clean(page))
-			__set_page_dirty_nobuffers(page);
-		ClearPageError(page);
-	} else {
-		__set_page_dirty_nobuffers(page);
-		SetPageError(page);
-	}
-
-	if (buffer_nilfs_allocated(page_buffers(page))) {
-		if (TestClearPageWriteback(page))
-			dec_zone_page_state(page, NR_WRITEBACK);
-	} else
-		end_page_writeback(page);
-}
-
 static void nilfs_end_page_io(struct page *page, int err)
 {
 	if (!page)
@@ -1738,40 +1653,19 @@ static void nilfs_end_page_io(struct page *page, int err)
 		return;
 	}
 
-	__nilfs_end_page_io(page, err);
-}
-
-static void nilfs_clear_copied_buffers(struct list_head *list, int err)
-{
-	struct buffer_head *bh, *head;
-	struct page *page;
-
-	while (!list_empty(list)) {
-		bh = list_entry(list->next, struct buffer_head,
-				b_assoc_buffers);
-		page = bh->b_page;
-		page_cache_get(page);
-		head = bh = page_buffers(page);
-		do {
-			if (!list_empty(&bh->b_assoc_buffers)) {
-				list_del_init(&bh->b_assoc_buffers);
-				if (!err) {
-					set_buffer_uptodate(bh);
-					clear_buffer_dirty(bh);
-					clear_buffer_delay(bh);
-					clear_buffer_nilfs_volatile(bh);
-				}
-				brelse(bh); /* for b_assoc_buffers */
-			}
-		} while ((bh = bh->b_this_page) != head);
-
-		__nilfs_end_page_io(page, err);
-		page_cache_release(page);
+	if (!err) {
+		if (!nilfs_page_buffers_clean(page))
+			__set_page_dirty_nobuffers(page);
+		ClearPageError(page);
+	} else {
+		__set_page_dirty_nobuffers(page);
+		SetPageError(page);
 	}
+
+	end_page_writeback(page);
 }
 
-static void nilfs_abort_logs(struct list_head *logs, struct page *failed_page,
-			     int err)
+static void nilfs_abort_logs(struct list_head *logs, int err)
 {
 	struct nilfs_segment_buffer *segbuf;
 	struct page *bd_page = NULL, *fs_page = NULL;
@@ -1801,8 +1695,6 @@ static void nilfs_abort_logs(struct list_head *logs, struct page *failed_page,
 			}
 			if (bh->b_page != fs_page) {
 				nilfs_end_page_io(fs_page, err);
-				if (fs_page && fs_page == failed_page)
-					return;
 				fs_page = bh->b_page;
 			}
 		}
@@ -1821,12 +1713,11 @@ static void nilfs_segctor_abort_construction(struct nilfs_sc_info *sci,
 
 	list_splice_tail_init(&sci->sc_write_logs, &logs);
 	ret = nilfs_wait_on_logs(&logs);
-	nilfs_abort_logs(&logs, NULL, ret ? : err);
+	nilfs_abort_logs(&logs, ret ? : err);
 
 	list_splice_tail_init(&sci->sc_segbufs, &logs);
 	nilfs_cancel_segusage(&logs, nilfs->ns_sufile);
 	nilfs_free_incomplete_logs(&logs, nilfs);
-	nilfs_clear_copied_buffers(&sci->sc_copied_buffers, err);
 
 	if (sci->sc_stage.flags & NILFS_CF_SUFREED) {
 		ret = nilfs_sufile_cancel_freev(nilfs->ns_sufile,
@@ -1920,8 +1811,6 @@ static void nilfs_segctor_complete_write(struct nilfs_sc_info *sci)
 
 	nilfs_end_page_io(fs_page, 0);
 
-	nilfs_clear_copied_buffers(&sci->sc_copied_buffers, 0);
-
 	nilfs_drop_collected_inodes(&sci->sc_dirty_files);
 
 	if (nilfs_doing_gc())
@@ -2024,7 +1913,6 @@ static void nilfs_segctor_drop_written_files(struct nilfs_sc_info *sci,
 static int nilfs_segctor_do_construct(struct nilfs_sc_info *sci, int mode)
 {
 	struct the_nilfs *nilfs = sci->sc_super->s_fs_info;
-	struct page *failed_page;
 	int err;
 
 	sci->sc_stage.scnt = NILFS_ST_INIT;
@@ -2079,11 +1967,7 @@ static int nilfs_segctor_do_construct(struct nilfs_sc_info *sci, int mode)
 		nilfs_segctor_update_segusage(sci, nilfs->ns_sufile);
 
 		/* Write partial segments */
-		err = nilfs_segctor_prepare_write(sci, &failed_page);
-		if (err) {
-			nilfs_abort_logs(&sci->sc_segbufs, failed_page, err);
-			goto failed_to_write;
-		}
+		nilfs_segctor_prepare_write(sci);
 
 		nilfs_add_checksums_on_logs(&sci->sc_segbufs,
 					    nilfs->ns_crc_seed);
@@ -2685,7 +2569,6 @@ static struct nilfs_sc_info *nilfs_segctor_new(struct super_block *sb,
 	INIT_LIST_HEAD(&sci->sc_segbufs);
 	INIT_LIST_HEAD(&sci->sc_write_logs);
 	INIT_LIST_HEAD(&sci->sc_gc_inodes);
-	INIT_LIST_HEAD(&sci->sc_copied_buffers);
 	init_timer(&sci->sc_timer);
 
 	sci->sc_interval = HZ * NILFS_SC_DEFAULT_TIMEOUT;
@@ -2739,8 +2622,6 @@ static void nilfs_segctor_destroy(struct nilfs_sc_info *sci)
 	if (flag || !nilfs_segctor_confirm(sci))
 		nilfs_segctor_write_out(sci);
 
-	WARN_ON(!list_empty(&sci->sc_copied_buffers));
-
 	if (!list_empty(&sci->sc_dirty_files)) {
 		nilfs_warning(sci->sc_super, __func__,
 			      "dirty file(s) after the final construction\n");
diff --git a/fs/nilfs2/segment.h b/fs/nilfs2/segment.h
index 6c02a86..38a1d00 100644
--- a/fs/nilfs2/segment.h
+++ b/fs/nilfs2/segment.h
@@ -92,7 +92,6 @@ struct nilfs_segsum_pointer {
  * @sc_nblk_inc: Block count of current generation
  * @sc_dirty_files: List of files to be written
  * @sc_gc_inodes: List of GC inodes having blocks to be written
- * @sc_copied_buffers: List of copied buffers (buffer heads) to freeze data
  * @sc_freesegs: array of segment numbers to be freed
  * @sc_nfreesegs: number of segments on @sc_freesegs
  * @sc_dsync_inode: inode whose data pages are written for a sync operation
@@ -136,7 +135,6 @@ struct nilfs_sc_info {
 
 	struct list_head	sc_dirty_files;
 	struct list_head	sc_gc_inodes;
-	struct list_head	sc_copied_buffers;
 
 	__u64		       *sc_freesegs;
 	size_t			sc_nfreesegs;
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

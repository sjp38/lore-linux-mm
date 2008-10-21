Date: Tue, 21 Oct 2008 13:21:37 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081021112137.GB12329@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

IO error handling in the core mm/fs still doesn't seem perfect, but with
the recent round of patches and this one, it should be getting on the
right track.

I kind of get the feeling some people would rather forget about all this
and brush it under the carpet. Hopefully I'm mistaken, but if anybody
disagrees with my assertion that error handling, and data integrity
semantics are first-class correctness issues, and therefore are more
important than all other non-correctness problems... speak now and let's
discuss that, please.

Otherwise, unless anybody sees obvious problems with this, hopefully it
can go into -mm for some wider testing (I've tested it with a few filesystems
so far and no immediate problems)

Thanks,
Nick
--

- Don't clear PageUptodate or buffer_uptodate on write failure (this could go
  BUG in the VM, and really, the data in the page is still the most uptodate
  even if we can't write it back to disk). If we decide to invalidate a page on
  write failure (silly, because then the app can't retry the write), the
  correct way to invalidate a page is via the pagecache invalidation calls,
  which will do the right thing with mapped pages for example.
- Don't assume !PageUptodate == EIO. Pages can be invalidated or reclaimed,
  in which case the read should be retried.
- Haven't gone through filesystems yet, but this gets core code into better 
  shape.
- Warnings or bugs can come about because we have !uptodate pages mapped into
  page tables, !uptodate && dirty pages or buffers, etc.

  example:
  WARNING: at /home/npiggin/usr/src/linux-2.6/fs/buffer.c:1185 mark_buffer_dirty+0x7a/0xc0()
Call Trace:
  bd541ca8:  [<60033b76>] warn_on_slowpath+0x56/0x80
  bd541cd8:  [<6004aa37>] wake_up_bit+0x27/0x40
  bd541cf8:  [<600a6fd2>] __writeback_single_inode+0xf2/0x360
  bd541d28:  [<60053f13>] debug_mutex_free_waiter+0x23/0x50
  bd541d48:  [<601f6ea9>] __mutex_lock_slowpath+0x149/0x220
  bd541db8:  [<600688a0>] pdflush+0x0/0x1c0
  bd541dc8:  [<600ac51a>] mark_buffer_dirty+0x7a/0xc0
  bd541de8:  [<600d8125>] ext2_write_super+0x45/0x90
  bd541e08:  [<6008c846>] sync_supers+0x76/0xc0
  bd541e28:  [<600682b0>] wb_kupdate+0x30/0x110
  bd541e98:  [<600688a0>] pdflush+0x0/0x1c0
  bd541ea8:  [<6006898c>] pdflush+0xec/0x1c0
  bd541eb8:  [<60068280>] wb_kupdate+0x0/0x110
  bd541f08:  [<6004a628>] kthread+0x58/0x90
  bd541f48:  [<60025b47>] run_kernel_thread+0x47/0x50
  bd541f58:  [<6004a5d0>] kthread+0x0/0x90
  bd541f98:  [<60025b28>] run_kernel_thread+0x28/0x50
  bd541fc8:  [<600166f7>] new_thread_handler+0x67/0xa0

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1147,20 +1147,17 @@ readpage:
 			error = lock_page_killable(page);
 			if (unlikely(error))
 				goto readpage_error;
-			if (!PageUptodate(page)) {
-				if (page->mapping == NULL) {
-					/*
-					 * invalidate_inode_pages got it
-					 */
-					unlock_page(page);
-					page_cache_release(page);
-					goto find_page;
-				}
+			if (PageError(page)) {
 				unlock_page(page);
 				shrink_readahead_size_eio(filp, ra);
 				error = -EIO;
 				goto readpage_error;
 			}
+			if (!PageUptodate(page) || !page->mapping) {
+				unlock_page(page);
+				page_cache_release(page);
+				goto find_page;
+			}
 			unlock_page(page);
 		}
 
@@ -1576,7 +1573,7 @@ page_not_uptodate:
 	error = mapping->a_ops->readpage(file, page);
 	if (!error) {
 		wait_on_page_locked(page);
-		if (!PageUptodate(page))
+		if (unlikely(PageError(page)))
 			error = -EIO;
 	}
 	page_cache_release(page);
@@ -1701,6 +1698,7 @@ retry:
 		unlock_page(page);
 		goto out;
 	}
+	ClearPageError(page);
 	err = filler(data, page);
 	if (err < 0) {
 		page_cache_release(page);
@@ -1722,7 +1720,7 @@ EXPORT_SYMBOL(read_cache_page_async);
  * Read into the page cache. If a page already exists, and PageUptodate() is
  * not set, try to fill the page then wait for it to become unlocked.
  *
- * If the page does not get brought uptodate, return -EIO.
+ * If the page IO fails, return -EIO.
  */
 struct page *read_cache_page(struct address_space *mapping,
 				pgoff_t index,
@@ -1735,7 +1733,7 @@ struct page *read_cache_page(struct addr
 	if (IS_ERR(page))
 		goto out;
 	wait_on_page_locked(page);
-	if (!PageUptodate(page)) {
+	if (PageError(page)) {
 		page_cache_release(page);
 		page = ERR_PTR(-EIO);
 	}
@@ -2052,6 +2050,9 @@ again:
 			 *
 			 * Instead, we have to bring it uptodate here.
 			 */
+			if (PageError(page))
+				return -EIO;
+
 			ret = aops->readpage(file, page);
 			page_cache_release(page);
 			if (ret) {
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -2336,10 +2336,11 @@ static int do_swap_page(struct mm_struct
 	if (unlikely(!pte_same(*page_table, orig_pte)))
 		goto out_nomap;
 
-	if (unlikely(!PageUptodate(page))) {
+	if (unlikely(!PageError(page))) {
 		ret = VM_FAULT_SIGBUS;
 		goto out_nomap;
 	}
+	VM_BUG_ON(!PageUptodate(page)); /* page_io.c should guarantee this */
 
 	/* The page isn't present yet, go ahead with the fault. */
 
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -1278,7 +1278,7 @@ repeat:
 			page_cache_release(swappage);
 			goto repeat;
 		}
-		if (!PageUptodate(swappage)) {
+		if (PageError(swappage)) {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			unlock_page(swappage);
@@ -1286,6 +1286,11 @@ repeat:
 			error = -EIO;
 			goto failed;
 		}
+		/*
+		 * swap cache doesn't get invalidated, so if not error it
+		 * should be uptodate
+		 */
+		VM_BUG_ON(!PageUptodate(swappage));
 
 		if (filepage) {
 			shmem_swp_set(info, entry, 0);
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -121,8 +121,11 @@ static void __end_buffer_read_notouch(st
 	if (uptodate) {
 		set_buffer_uptodate(bh);
 	} else {
-		/* This happens, due to failed READA attempts. */
-		clear_buffer_uptodate(bh);
+		if (buffer_uptodate(bh)) {
+			WARN_ON_ONCE(1);
+			/* This happens, due to failed READA attempts. */
+			clear_buffer_uptodate(bh);
+		}
 	}
 	unlock_buffer(bh);
 }
@@ -142,7 +145,10 @@ void end_buffer_write_sync(struct buffer
 	char b[BDEVNAME_SIZE];
 
 	if (uptodate) {
-		set_buffer_uptodate(bh);
+		if (!buffer_uptodate(bh)) {
+			WARN_ON_ONCE(1);
+			set_buffer_uptodate(bh);
+		}
 	} else {
 		if (!buffer_eopnotsupp(bh) && printk_ratelimit()) {
 			buffer_io_error(bh);
@@ -151,7 +157,6 @@ void end_buffer_write_sync(struct buffer
 				       bdevname(bh->b_bdev, b));
 		}
 		set_buffer_write_io_error(bh);
-		clear_buffer_uptodate(bh);
 	}
 	unlock_buffer(bh);
 	put_bh(bh);
@@ -393,7 +398,10 @@ static void end_buffer_async_read(struct
 	if (uptodate) {
 		set_buffer_uptodate(bh);
 	} else {
-		clear_buffer_uptodate(bh);
+		if (buffer_uptodate(bh)) {
+			WARN_ON_ONCE(1);
+			clear_buffer_uptodate(bh);
+		}
 		if (printk_ratelimit())
 			buffer_io_error(bh);
 		SetPageError(page);
@@ -453,7 +461,10 @@ static void end_buffer_async_write(struc
 
 	page = bh->b_page;
 	if (uptodate) {
-		set_buffer_uptodate(bh);
+		if (!buffer_uptodate(bh)) {
+			WARN_ON_ONCE(1);
+			set_buffer_uptodate(bh);
+		}
 	} else {
 		if (printk_ratelimit()) {
 			buffer_io_error(bh);
@@ -463,7 +474,6 @@ static void end_buffer_async_write(struc
 		}
 		set_bit(AS_EIO, &page->mapping->flags);
 		set_buffer_write_io_error(bh);
-		clear_buffer_uptodate(bh);
 		SetPageError(page);
 	}
 
@@ -1998,8 +2008,6 @@ int block_write_begin(struct file *file,
 
 	status = __block_prepare_write(inode, page, start, end, get_block);
 	if (unlikely(status)) {
-		ClearPageUptodate(page);
-
 		if (ownpage) {
 			unlock_page(page);
 			page_cache_release(page);
@@ -2372,10 +2380,7 @@ int block_prepare_write(struct page *pag
 			get_block_t *get_block)
 {
 	struct inode *inode = page->mapping->host;
-	int err = __block_prepare_write(inode, page, from, to, get_block);
-	if (err)
-		ClearPageUptodate(page);
-	return err;
+	return __block_prepare_write(inode, page, from, to, get_block);
 }
 
 int block_commit_write(struct page *page, unsigned from, unsigned to)
@@ -2752,16 +2757,19 @@ has_buffers:
 
 	/* Ok, it's mapped. Make sure it's up-to-date */
 	if (!PageUptodate(page)) {
+again:
 		err = mapping->a_ops->readpage(NULL, page);
 		if (err) {
 			page_cache_release(page);
 			goto out;
 		}
 		lock_page(page);
-		if (!PageUptodate(page)) {
+		if (!PageError(page)) {
 			err = -EIO;
 			goto unlock;
 		}
+		if (!PageUptodate(page))
+			goto again;
 		if (page_has_buffers(page))
 			goto has_buffers;
 	}
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -112,11 +112,16 @@ static int page_cache_pipe_buf_confirm(s
 		/*
 		 * Uh oh, read-error from disk.
 		 */
-		if (!PageUptodate(page)) {
+		if (PageError(page)) {
 			err = -EIO;
 			goto error;
 		}
 
+		if (!PageUptodate(page)) {
+			err = -ENODATA;
+			goto error;
+		}
+
 		/*
 		 * Page is ok afterall, we are done.
 		 */
Index: linux-2.6/fs/mpage.c
===================================================================
--- linux-2.6.orig/fs/mpage.c
+++ linux-2.6/fs/mpage.c
@@ -53,7 +53,11 @@ static void mpage_end_io_read(struct bio
 		if (uptodate) {
 			SetPageUptodate(page);
 		} else {
-			ClearPageUptodate(page);
+			if (PageUptodate(page)) {
+				/* let's get rid of this case ASAP */
+				WARN_ON_ONCE(1);
+				ClearPageUptodate(page);
+			}
 			SetPageError(page);
 		}
 		unlock_page(page);
Index: linux-2.6/mm/page_io.c
===================================================================
--- linux-2.6.orig/mm/page_io.c
+++ linux-2.6/mm/page_io.c
@@ -77,7 +77,10 @@ void end_swap_bio_read(struct bio *bio, 
 
 	if (!uptodate) {
 		SetPageError(page);
-		ClearPageUptodate(page);
+		if (PageUptodate(page)) {
+			WARN_ON_ONCE(1);
+			ClearPageUptodate(page);
+		}
 		printk(KERN_ALERT "Read-error on swap-device (%u:%u:%Lu)\n",
 				imajor(bio->bi_bdev->bd_inode),
 				iminor(bio->bi_bdev->bd_inode),
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -936,8 +936,10 @@ retry:
 				unlock_page(page);
 				ret = 0;
 			}
-			if (ret || (--nr_to_write <= 0))
+			if (ret || (--nr_to_write <= 0)) {
 				done = 1;
+				break;
+			}
 			if (wbc->nonblocking && bdi_write_congested(bdi)) {
 				wbc->encountered_congestion = 1;
 				done = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

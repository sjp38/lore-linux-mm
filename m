Subject: PATCH: truncate_inode_pages fix (this time against ac5)
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 30 May 2000 18:47:24 +0200
Message-ID: <yttr9akdlyb.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Alexander Viro <viro@math.psu.edu>
List-ID: <linux-mm.kvack.org>

Hi
        I have just re-diff my patch against 2.4.0-test1-ac5.  It is
        the same that the one that I sent before.  The only difference
        is that I reverse a change from riel patch in shrink_mmap (we
        need to call __remove_inode_pages with the page cache_lock
        held.

        I am still waiting for comments of the patch for the
        filesystems people (hint, hint, hint...), before transform
        everything to support also partial truncates.

I am very interested in *success/failure* reports.  The system works
stable here, without that patch I get the BUG in inode.c pretty easily
here.

Later, Juan.

Note for Alan: if you continue with the riel patch, please apply this
      one, it fixes the BUG in inode.c that more people are seeing.
      At least include the spinlock change.


> Hi
>         the actual truncate_inode_pages can actually *write* part of
> the file that has just been truncated.  That makes that things doesn't
> work.  I can trigger the BUG in fs:/inode.c:clear_inode using mmap002
> and riel aging patch in 2.4.0-test1.  The BUG triggered is:

>	if (inode->i_data.nrpages)
>		BUG();

> The problem is that inode->i_data.nrpages can become negative. I have
> got here -6 truncating a file of 384MB.

> This patch deals with this problem, and try to do truncate_inode_pages
> safe.

> Notice that the function only works for truncate complete files, I
> have left the old function for the partial case.  If people think that
> this function is OK, I will incorporate the partial case.  I have no
> done it because I want feedback from the MM people and the FS people,
> and the algorithms for complete files are cleaner.

> I would like to now if it is possible to have a locked buffer without
> the page being locked, i.e.  If I can manipulate the buffers in one
> page without locking them when I have the page lock. (I don't think
> so, and then I have to lock also buffers).

> With this patch things are rock solid here.

> This patch does:

> - defines a new function: discard_buffer, it will lock the buffer
>  (waiting if needed) and remove the buffer from all the queues.
>  It is like unmap_buffer, but makes sure that we don't do any IO
>  and that we remove the buffer from all the lists.

> - defines a new function: block_destroy_buffers: it is a mix of
>   block_flushpage and do_try_to_free_pages.  It will make all the
>   buffers in that page disappear calling discard_buffer.  Notice the
>   way that we iterate through all the buffer heads.  I think that it
>   is not racy, but I would like to hear comments from people than know
>   more about buffer heads handling.

> - It changes __remove_inode_pages to check that there are not buffers
>   in that page.  Users of the function must make sure about that.  It
>   changes all the callers of the function satisfy that requirement.

> - I change invalidate_inode_pages (again).  Now block_destroy_buffers
>   can wait, then we are *civilized* citizens and drop any lock that
>   we have before call that block_destroy_buffers, and reaquire later.

> - It has my *old* rewrite of truncate_inode_pages to use two auxiliary
>   functions and lock the same way for the partial page and for the
>   rest.  (That code is wrong anyway, pass to the next function).

> - The new function truncate_inode_pages, that is a copy of
>   invalidate_inodes, but we wait for locked pages.

> Comments, please??

> I am very interested in the coments from the fs-people.  What they
> think about the locking that I am using in the buffer.c file.

Acknowledgement:  This patch would have not been possible without the comments of
                arjan, bcrl, davej, riel and RogerL, .... in
                #kernelnewbies (irc.openprojects.net).  They did a lot
                of review of previous versions of the patch.  The
                errors are mine, but good ideas come from discussions
                with them :)


diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude ac5/fs/buffer.c testing2/fs/buffer.c
--- ac5/fs/buffer.c	Wed May 24 01:22:59 2000
+++ testing2/fs/buffer.c	Tue May 30 17:25:27 2000
@@ -1281,6 +1281,56 @@
 	}
 }
 
+/**
+ * discard_buffer - discard that buffer without doing any IO
+ * @bh: buffer to discard
+ * 
+ * This function removes a buffer from all the queues, without doing
+ * any IO, we are not interested in the contents of the buffer.  This
+ * function can block if the buffer is locked.
+ */
+static struct buffer_head *discard_buffer(struct buffer_head * bh)
+{
+	int index = BUFSIZE_INDEX(bh->b_size);
+	struct buffer_head *next;
+
+	/* grab the lru lock here to block bdflush. */
+	atomic_inc(&bh->b_count);
+	lock_buffer(bh);
+	next = bh->b_this_page;
+	clear_bit(BH_Uptodate, &bh->b_state);
+	clear_bit(BH_Mapped, &bh->b_state);
+	clear_bit(BH_Req, &bh->b_state);
+	clear_bit(BH_New, &bh->b_state);
+
+	spin_lock(&lru_list_lock);
+	write_lock(&hash_table_lock);
+	spin_lock(&free_list[index].lock);
+	spin_lock(&unused_list_lock);
+
+	if (!atomic_dec_and_test(&bh->b_count))
+		BUG();
+
+	__hash_unlink(bh);
+	/* The bunffer can be either on the regular
+	 * queues or on the free list..
+	 */
+	if (bh->b_dev != B_FREE)
+		__remove_from_queues(bh);
+	else
+		__remove_from_free_list(bh, index);
+	__put_unused_buffer_head(bh);	
+	spin_unlock(&unused_list_lock);
+	write_unlock(&hash_table_lock);
+	spin_unlock(&free_list[index].lock);
+	spin_unlock(&lru_list_lock);
+	/* We can unlock the buffer, we have just returned it.
+	 * Ditto for the counter 
+         */
+	return next;
+}
+
+
 /*
  * We don't have to release all buffers here, but
  * we have to be sure that no dirty buffer is left
@@ -1313,24 +1363,43 @@
 		bh = next;
 	} while (bh != head);
 
-	/*
-	 * subtle. We release buffer-heads only if this is
-	 * the 'final' flushpage. We have invalidated the get_block
-	 * cached value unconditionally, so real IO is not
-	 * possible anymore.
-	 *
-	 * If the free doesn't work out, the buffers can be
-	 * left around - they just turn into anonymous buffers
-	 * instead.
-	 */
-	if (!offset) {
-		if (!try_to_free_buffers(page, 0)) {
-			atomic_inc(&buffermem_pages);
-			return 0;
-		}
-	}
-
 	return 1;
+}
+
+/**
+ * block_destroy_buffers - Will destroy the contents of all the
+ * buffers in this page
+ * @page: page to examine the buffers
+ *
+ * This function destroy all the buffers in one page without making
+ * any IO.  The function can block due to the fact that discad_bufferr
+ * can block.
+ */
+void block_destroy_buffers(struct page *page)
+{
+	struct buffer_head  *bh, *head;
+
+	if (!PageLocked(page))
+		BUG();
+	if (!page->buffers)
+		return;
+
+	head = page->buffers;
+	bh = head;
+	do {
+		/* We need to get the next buffer from discard buffer
+		 * because discard buffer can block and anybody else
+		 * can change the buffer list under our feet.
+		 */
+		bh = discard_buffer(bh);
+	}while (bh != head);
+
+	/* Wake up anyone waiting for buffer heads */
+	wake_up(&buffer_wait);
+
+	/* And free the page */
+	page->buffers = NULL;
+	page_cache_release(page);
 }
 
 static void create_empty_buffers(struct page *page, struct inode *inode, unsigned long blocksize)
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude ac5/fs/inode.c testing2/fs/inode.c
--- ac5/fs/inode.c	Wed May 24 01:22:59 2000
+++ testing2/fs/inode.c	Tue May 30 17:25:27 2000
@@ -322,7 +322,7 @@
 
 		inode = list_entry(inode_entry, struct inode, i_list);
 		if (inode->i_data.nrpages)
-			truncate_inode_pages(&inode->i_data, 0);
+			truncate_all_inode_pages(&inode->i_data);
 		clear_inode(inode);
 		destroy_inode(inode);
 	}
@@ -768,7 +768,7 @@
 				spin_unlock(&inode_lock);
 
 				if (inode->i_data.nrpages)
-					truncate_inode_pages(&inode->i_data, 0);
+					truncate_all_inode_pages(&inode->i_data);
 
 				destroy = 1;
 				if (op && op->delete_inode) {
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude ac5/include/linux/fs.h testing2/include/linux/fs.h
--- ac5/include/linux/fs.h	Tue May 30 17:21:32 2000
+++ testing2/include/linux/fs.h	Tue May 30 17:29:19 2000
@@ -1113,6 +1113,7 @@
 
 /* Generic buffer handling for block filesystems.. */
 extern int block_flushpage(struct page *, unsigned long);
+extern void block_destroy_buffers(struct page *);
 extern int block_symlink(struct inode *, const char *, int);
 extern int block_write_full_page(struct page*, get_block_t*);
 extern int block_read_full_page(struct page*, get_block_t*);
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude ac5/include/linux/mm.h testing2/include/linux/mm.h
--- ac5/include/linux/mm.h	Tue May 30 17:21:32 2000
+++ testing2/include/linux/mm.h	Tue May 30 17:29:19 2000
@@ -462,6 +462,7 @@
 extern unsigned long page_unuse(struct page *);
 extern int shrink_mmap(int, int);
 extern void truncate_inode_pages(struct address_space *, loff_t);
+extern void truncate_all_inode_pages(struct address_space *);
 
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_swapout(struct page * page, struct file *file);
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude ac5/mm/filemap.c testing2/mm/filemap.c
--- ac5/mm/filemap.c	Tue May 30 17:21:32 2000
+++ testing2/mm/filemap.c	Tue May 30 18:06:20 2000
@@ -90,10 +90,16 @@
 /*
  * Remove a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
- * is safe.
+ * is safe. We need that the page don't have any buffers.
  */
 static inline void __remove_inode_page(struct page *page)
 {
+	if (!PageLocked(page))
+		PAGE_BUG(page);
+
+	if (page->buffers)
+		BUG();
+
 	remove_page_from_inode_queue(page);
 	remove_page_from_hash_queue(page);
 	page->mapping = NULL;
@@ -101,9 +107,6 @@
 
 void remove_inode_page(struct page *page)
 {
-	if (!PageLocked(page))
-		PAGE_BUG(page);
-
 	spin_lock(&pagecache_lock);
 	__remove_inode_page(page);
 	spin_unlock(&pagecache_lock);
@@ -116,14 +119,13 @@
  * This function only removes the unlocked pages, if you want to
  * remove all the pages of one inode, you must call truncate_inode_pages.
  */
-
 void invalidate_inode_pages(struct inode * inode)
 {
 	struct list_head *head, *curr;
 	struct page * page;
 
 	head = &inode->i_mapping->pages;
-
+repeat:
 	spin_lock(&pagecache_lock);
 	spin_lock(&pagemap_lru_lock);
 	curr = head->next;
@@ -135,20 +137,61 @@
 		/* We cannot invalidate a locked page */
 		if (TryLockPage(page))
 			continue;
-
-		__lru_cache_del(page);
+		if (page->buffers) {
+			page_cache_get(page);
+			spin_unlock(&pagemap_lru_lock);
+			spin_unlock(&pagecache_lock);			
+			block_destroy_buffers(page);
+			remove_inode_page(page);
+			lru_cache_del(page);
+			page_cache_release(page);
+			UnlockPage(page);
+			page_cache_release(page);
+			goto repeat;
+		}
 		__remove_inode_page(page);
+		__lru_cache_del(page);
 		UnlockPage(page);
 		page_cache_release(page);
 	}
-
 	spin_unlock(&pagemap_lru_lock);
 	spin_unlock(&pagecache_lock);
 }
 
-/*
+static inline void truncate_partial_page(struct page *page, unsigned partial)
+{
+	memclear_highpage_flush(page, partial, PAGE_CACHE_SIZE-partial);
+				
+	if (page->buffers)
+		block_flushpage(page, partial);
+
+}
+
+static inline void truncate_complete_page(struct page *page)
+{
+	if (page->buffers)
+		block_destroy_buffers(page);
+	lru_cache_del(page);
+	
+	/*
+	 * We remove the page from the page cache _after_ we have
+	 * destroyed all buffer-cache references to it. Otherwise some
+	 * other process might think this inode page is not in the
+	 * page cache and creates a buffer-cache alias to it causing
+	 * all sorts of fun problems ...  
+	 */
+	remove_inode_page(page);
+	page_cache_release(page);
+}
+
+/**
+ * truncate_inode_pages - truncate *all* the pages from an offset
+ * @mapping: mapping to truncate
+ * @lstart: offset from with to truncate
+ *
  * Truncate the page cache at a set offset, removing the pages
  * that are beyond that offset (and zeroing out partial pages).
+ * If any page is locked we wait for it to become unlocked.
  */
 void truncate_inode_pages(struct address_space * mapping, loff_t lstart)
 {
@@ -168,11 +211,10 @@
 
 		page = list_entry(curr, struct page, list);
 		curr = curr->next;
-
 		offset = page->index;
 
-		/* page wholly truncated - free it */
-		if (offset >= start) {
+		/* Is one of the pages to truncate? */
+		if ((offset >= start) || (partial && (offset + 1) == start)) {
 			if (TryLockPage(page)) {
 				page_cache_get(page);
 				spin_unlock(&pagecache_lock);
@@ -183,22 +225,14 @@
 			page_cache_get(page);
 			spin_unlock(&pagecache_lock);
 
-			if (!page->buffers || block_flushpage(page, 0))
-				lru_cache_del(page);
-
-			/*
-			 * We remove the page from the page cache
-			 * _after_ we have destroyed all buffer-cache
-			 * references to it. Otherwise some other process
-			 * might think this inode page is not in the
-			 * page cache and creates a buffer-cache alias
-			 * to it causing all sorts of fun problems ...
-			 */
-			remove_inode_page(page);
+			if (partial && (offset + 1) == start) {
+				truncate_partial_page(page, partial);
+				partial = 0;
+			} else 
+				truncate_complete_page(page);
 
 			UnlockPage(page);
 			page_cache_release(page);
-			page_cache_release(page);
 
 			/*
 			 * We have done things without the pagecache lock,
@@ -209,38 +243,59 @@
 			 */
 			goto repeat;
 		}
-		/*
-		 * there is only one partial page possible.
-		 */
-		if (!partial)
-			continue;
+	}
+	spin_unlock(&pagecache_lock);
+}
 
-		/* and it's the one preceeding the first wholly truncated page */
-		if ((offset + 1) != start)
-			continue;
+/**
+ * truncate_all_inode_pages - truncate *all* the pages
+ * @mapping: mapping to truncate
+ *
+ * Truncate all the inode pages.  If any page is locked we wait for it
+ * to become unlocked. This function can block.
+ */
+void truncate_all_inode_pages(struct address_space * mapping)
+{
+	struct list_head *head, *curr;
+	struct page * page;
+
+	head = &mapping->pages;
+repeat:
+	spin_lock(&pagecache_lock);
+	spin_lock(&pagemap_lru_lock);
+	curr = head->next;
+
+	while (curr != head) {
+		page = list_entry(curr, struct page, list);
+		curr = curr->next;
 
-		/* partial truncate, clear end of page */
 		if (TryLockPage(page)) {
+			page_cache_get(page);
+			spin_unlock(&pagemap_lru_lock);
+			spin_unlock(&pagecache_lock);
+			wait_on_page(page);
+			page_cache_release(page);
+			goto repeat;
+		}
+		if (page->buffers) {
+			page_cache_get(page);
+			spin_unlock(&pagemap_lru_lock);
 			spin_unlock(&pagecache_lock);
+			block_destroy_buffers(page);
+			remove_inode_page(page);
+			lru_cache_del(page);
+			page_cache_release(page);
+			UnlockPage(page);
+			page_cache_release(page);
 			goto repeat;
 		}
-		page_cache_get(page);
-		spin_unlock(&pagecache_lock);
-
-		memclear_highpage_flush(page, partial, PAGE_CACHE_SIZE-partial);
-		if (page->buffers)
-			block_flushpage(page, partial);
-
-		partial = 0;
-
-		/*
-		 * we have dropped the spinlock so we have to
-		 * restart.
-		 */
+		__lru_cache_del(page);
+		__remove_inode_page(page);
 		UnlockPage(page);
 		page_cache_release(page);
-		goto repeat;
 	}
+
+	spin_unlock(&pagemap_lru_lock);
 	spin_unlock(&pagecache_lock);
 }
 
@@ -352,8 +407,8 @@
 		/* is it a page-cache page? */
 		if (page->mapping) {
 			if (!PageDirty(page) && !pgcache_under_min()) {
-				spin_unlock(&pagecache_lock);
 				__remove_inode_page(page);
+				spin_unlock(&pagecache_lock);
 				goto made_inode_progress;
 			}
 			goto cache_unlock_continue;
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude ac5/mm/swap_state.c testing2/mm/swap_state.c
--- ac5/mm/swap_state.c	Tue May 30 17:21:32 2000
+++ testing2/mm/swap_state.c	Tue May 30 17:25:27 2000
@@ -103,9 +103,10 @@
 	if (!PageLocked(page))
 		BUG();
 
-	if (block_flushpage(page, 0))
-		lru_cache_del(page);
+	if (page->buffers)
+ 		block_destroy_buffers(page);
 
+	lru_cache_del(page);
 	__delete_from_swap_cache(page);
 	page_cache_release(page);
 }

   

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

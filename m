Subject: PATCH: deferred writes of mmaped pages [WIP] (1st try)
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 08 Jun 2000 01:16:06 +0200
Message-ID: <yttem69ccax.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu, lkml <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi
        This is a first version of making deferred writes when we hit a
        dirty page belonging to a file in swap_out.  It is unfinished
        work, I am posting it because:
              - people asked for it
              - I would like to receive feedback about the ideas

        Note that is a Work in progress and I will do more
        improvements before asking for inclusion.

        The important idea is that we want to limit the amount of IO
        that is generated for each page that we need, that is
        difficult with the existing scheme when we are doing IO in
        several swap routines.  The first try was to start
        asynchronously several writes of buffers in shrink_mmap and
        then wait for some of them to perform.  Next was the deferred
        swap, we found a dirty anon page in swap_out, we mark it as
        dirty and we will swap that page in shrink_mmap.  Now is the
        turn of pages from the file-system.

The patch does:
- The patch is against 2.4.0-test1-ac10.
- Use a new field in the page structure to store the file that we want
  to write.  Just now it stores the file for all the pages, it is
  needed only for file-systems that are not of disk.  I will do that
  optimization later.
- It modifies truncate*page and invalidate*page to support the use of
  this new field.  
- It modifies try_to_swap_out to mark pages as dirty instead of start
  the write asynchronously.
- It modifies shrink_mmap to start the write of dirty pages, working
  now also for pages in the page cache.

After I have been chatting with Ben LaHaise, he has suggested, instead
of using especial code for NFS pages and block pages to change/add a
new function to address_operations to do the swapout in
try_to_swap_pages  and the writepage in shrink_mmap.  That would
simplify a lot the code and will make it very easy to add more
pages/caches to the scheme, obvious candidates are the SHM pages and
the swap_cache (thinking about the last ones).  Comments about the
idea?  If nobody is against that I will begin doing something about
that tomorrow.

The other question is what the people think about this movement that
makes the transition easy towards an scheme using several queues like
the one proposed by Rik.

I have tested this code and it works rock solid.  It hangs with
mmap002 over NFS, but then I repeat the test without my patches and
mmap002 also hangs the computer with stock ac10.

I will like to hear suggestions/comments/reports of success/failures.

I begin this patch thinking that it will reduce the stalls running big
*dirtier* of pages, i.e. dd of a cdrom to hd, mmap002 and similar,
but the stalls are similar.  I am investigating yet on that,
suggestions here are also welcome.

Later, Juan.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/include/linux/mm.h working/include/linux/mm.h
--- base/include/linux/mm.h	Wed Jun  7 03:50:19 2000
+++ working/include/linux/mm.h	Wed Jun  7 04:02:04 2000
@@ -154,6 +154,7 @@
 	unsigned long virtual; /* nonzero if kmapped */
 	struct zone_struct *zone;
 	unsigned int age;
+	struct file *file;
 } mem_map_t;
 
 #define get_page(p)		atomic_inc(&(p)->count)
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/filemap.c working/mm/filemap.c
--- base/mm/filemap.c	Tue Jun  6 23:36:42 2000
+++ working/mm/filemap.c	Wed Jun  7 17:37:31 2000
@@ -65,8 +65,8 @@
 		(*p)->pprev_hash = &page->next_hash;
 	*p = page;
 	page->pprev_hash = p;
-	if (page->buffers)
-		PAGE_BUG(page);
+//	if (page->buffers)
+//		PAGE_BUG(page);
 }
 
 static inline void remove_page_from_hash_queue(struct page * page)
@@ -102,6 +102,10 @@
 	if (page->buffers)
 		BUG();
 
+	if (page->file)
+		BUG();
+
+	ClearPageDirty(page);
 	remove_page_from_inode_queue(page);
 	remove_page_from_hash_queue(page);
 	page->mapping = NULL;
@@ -129,6 +133,7 @@
 	struct page * page;
 
 	head = &inode->i_mapping->pages;
+repeat:
 	spin_lock(&pagecache_lock);
 	spin_lock(&pagemap_lru_lock);
 	curr = head->next;
@@ -144,6 +149,18 @@
 		if (page->buffers) 
 			BUG();
 
+		if (page->file){
+			struct file *file = page->file;
+			page_cache_get(page);
+			spin_unlock(&pagemap_lru_lock);
+			spin_unlock(&pagecache_lock);
+			page->file=NULL;
+			page_cache_release(page);
+			UnlockPage(page);
+			fput(file);
+			page_cache_release(page);
+			goto repeat;
+		}
 		__remove_inode_page(page);
 		__lru_cache_del(page);
 		UnlockPage(page);
@@ -272,18 +289,26 @@
 			page_cache_release(page);
 			goto repeat;
 		}
-		if (page->buffers) {
+
+		if (page->buffers || page->file) {
 			page_cache_get(page);
 			spin_unlock(&pagemap_lru_lock);
 			spin_unlock(&pagecache_lock);
-			block_destroy_buffers(page);
-			remove_inode_page(page);
-			lru_cache_del(page);
-			page_cache_release(page);
+			if (page->buffers)
+				block_destroy_buffers(page);
+			if (page->file){
+				struct file *file = page->file;
+				page->file = NULL;
+				UnlockPage(page);
+				fput(file);
+				page_cache_release(page);
+				goto repeat;
+			}
 			UnlockPage(page);
 			page_cache_release(page);
 			goto repeat;
 		}
+
 		__lru_cache_del(page);
 		__remove_inode_page(page);
 		UnlockPage(page);
@@ -352,6 +377,8 @@
 		 */
 		if (page->buffers) {
 			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty-- < 0));
+			if (nr_dirty < 0) 
+				nr_dirty = priority;
 			if (!try_to_free_buffers(page, wait))
 				goto unlock_continue;
 			/* page was locked, inode can't go away under us */
@@ -394,10 +421,13 @@
 			}
 			/* PageDeferswap -> we swap out the page now. */
 			if (gfp_mask & __GFP_IO) {
+				int wait = (nr_dirty-- < 0);
+				if (nr_dirty < 0) 
+					nr_dirty = priority;
 				spin_unlock(&pagecache_lock);
 				/* Do NOT unlock the page ... brw_page does. */
 				ClearPageDirty(page);
-				rw_swap_page(WRITE, page, 0);
+				rw_swap_page(WRITE, page, wait);
 				spin_lock(&pagemap_lru_lock);
 				page_cache_release(page);
 				goto dispose_continue;
@@ -407,7 +437,34 @@
 
 		/* is it a page-cache page? */
 		if (page->mapping) {
-			if (!PageDirty(page) && !pgcache_under_min()) {
+			if (PageDirty(page)) {
+				if (gfp_mask & __GFP_IO) {
+					int wait = (nr_dirty-- < 0);
+					if (nr_dirty < 0) 
+						nr_dirty = priority;
+					spin_unlock(&pagecache_lock);
+					ClearPageDirty(page);
+					page->mapping->a_ops->writepage(page->file, page);
+					if (wait)
+						page->mapping->a_ops->sync_page(page);
+ 
+					UnlockPage(page);
+					spin_lock(&pagemap_lru_lock);
+					page_cache_release(page);
+					goto dispose_continue;
+				}
+				goto cache_unlock_continue;
+			} else if (!pgcache_under_min()) {
+				if (page->file) {
+					struct file *file = page->file;
+					spin_unlock(&pagecache_lock);
+					page->file=NULL;
+					UnlockPage(page);
+					fput(file);
+					spin_lock(&pagemap_lru_lock);
+					page_cache_release(page);
+					goto dispose_continue;
+ 				}
 				__remove_inode_page(page);
 				spin_unlock(&pagecache_lock);
 				goto made_inode_progress;
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/mremap.c working/mm/mremap.c
--- base/mm/mremap.c	Wed Apr 26 18:16:39 2000
+++ working/mm/mremap.c	Wed Jun  7 02:20:34 2000
@@ -144,7 +144,7 @@
 			vmlist_modify_lock(current->mm);
 			insert_vm_struct(current->mm, new_vma);
 			merge_segments(current->mm, new_vma->vm_start, new_vma->vm_end);
-			vmlist_modify_unlock(vma->vm_mm);
+			vmlist_modify_unlock(current->mm);
 			do_munmap(current->mm, addr, old_len);
 			current->mm->total_vm += new_len >> PAGE_SHIFT;
 			if (new_vma->vm_flags & VM_LOCKED) {
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/page_alloc.c working/mm/page_alloc.c
--- base/mm/page_alloc.c	Tue Jun  6 23:36:42 2000
+++ working/mm/page_alloc.c	Wed Jun  7 02:20:34 2000
@@ -95,6 +95,8 @@
 		BUG();
 	if (PageDirty(page))
 		BUG();
+	if (page->file)
+		BUG();
 
 	zone = page->zone;
 
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/swap_state.c working/mm/swap_state.c
--- base/mm/swap_state.c	Tue Jun  6 23:36:42 2000
+++ working/mm/swap_state.c	Wed Jun  7 03:22:57 2000
@@ -73,7 +73,6 @@
 		PAGE_BUG(page);
 
 	PageClearSwapCache(page);
-	ClearPageDirty(page);
 	remove_inode_page(page);
 }
 
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/mm/vmscan.c working/mm/vmscan.c
--- base/mm/vmscan.c	Tue Jun  6 23:36:42 2000
+++ working/mm/vmscan.c	Wed Jun  7 18:58:20 2000
@@ -145,21 +145,32 @@
 	 * That would get rid of a lot of problems.
 	 */
 	flush_cache_page(vma, address);
+	
 	if (vma->vm_ops && (swapout = vma->vm_ops->swapout)) {
-		int error;
 		struct file *file = vma->vm_file;
-		if (file) get_file(file);
-		pte_clear(page_table);
-		vma->vm_mm->rss--;
-		flush_tlb_page(vma, address);
-		vmlist_access_unlock(vma->vm_mm);
-		error = swapout(page, file);
-		UnlockPage(page);
-		if (file) fput(file);
-		if (!error)
-			goto out_free_success;
-		page_cache_release(page);
-		return error;
+		if (page->mapping) {
+			if (!page->file) {
+				get_file(file);
+ 				page->file = file;
+			}
+			pte_clear(page_table);
+			goto deferred_write;
+		} else {
+			int error;
+			printk("What kind of page is that?");
+			if (file) get_file(file);
+			pte_clear(page_table);
+			vma->vm_mm->rss--;
+			flush_tlb_page(vma, address);
+			vmlist_access_unlock(vma->vm_mm);
+			error = swapout(page, file);
+			UnlockPage(page);
+			if (file) fput(file);
+			if (!error)
+				goto out_free_success;
+			page_cache_release(page);
+			return error;
+		}
 	}
 
 	/*
@@ -179,16 +190,14 @@
 
 	/* Add it to the swap cache */
 	add_to_swap_cache(page, entry);
-
+	set_pte(page_table, swp_entry_to_pte(entry));
+deferred_write:
 	/* Put the swap entry into the pte after the page is in swapcache */
 	vma->vm_mm->rss--;
-	set_pte(page_table, swp_entry_to_pte(entry));
-	flush_tlb_page(vma, address);
 	vmlist_access_unlock(vma->vm_mm);
+	flush_tlb_page(vma, address);
 
-	/* OK, do a physical asynchronous write to swap.  */
-	// rw_swap_page(WRITE, page, 0);
-	/* Let shrink_mmap handle this swapout. */
+	/* Set the page for deferred write */
 	SetPageDirty(page);
 	UnlockPage(page);
 


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

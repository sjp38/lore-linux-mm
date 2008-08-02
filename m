Date: Sat, 2 Aug 2008 12:01:03 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] convert TestSetPageLocked to trylock_page
Message-ID: <20080802100103.GA14757@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Just wondering if we can do this please?

Again: out of tree patches literally should require just a couple of renames
to solve the conflict. A simple script could fix a complete stack of patches.

--
mm: rename page trylock

Converting page lock to new locking bitops requires a change of page flag
operation naming, so we might as well convert it to something nicer
(!TestSetPageLocked_Lock => trylock_page, SetPageLocked => set_page_locked).

This also facilitates lockdeping of page lock.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 drivers/scsi/sg.c           |    2 +-
 fs/afs/write.c              |    2 +-
 fs/cifs/file.c              |    2 +-
 fs/jbd/commit.c             |    4 ++--
 fs/jbd2/commit.c            |    2 +-
 fs/reiserfs/journal.c       |    2 +-
 fs/splice.c                 |    2 +-
 fs/xfs/linux-2.6/xfs_aops.c |    4 ++--
 include/linux/page-flags.h  |    2 +-
 include/linux/pagemap.h     |   27 +++++++++++++++++++++------
 mm/filemap.c                |   12 ++++++------
 mm/memory.c                 |    2 +-
 mm/migrate.c                |    4 ++--
 mm/rmap.c                   |    2 +-
 mm/shmem.c                  |    4 ++--
 mm/swap.c                   |    2 +-
 mm/swap_state.c             |    8 ++++----
 mm/swapfile.c               |    2 +-
 mm/truncate.c               |    4 ++--
 mm/vmscan.c                 |    4 ++--
 20 files changed, 54 insertions(+), 39 deletions(-)

Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -250,29 +250,6 @@ static inline struct page *read_mapping_
 	return read_cache_page(mapping, index, filler, data);
 }
 
-int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
-				pgoff_t index, gfp_t gfp_mask);
-int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
-				pgoff_t index, gfp_t gfp_mask);
-extern void remove_from_page_cache(struct page *page);
-extern void __remove_from_page_cache(struct page *page);
-
-/*
- * Like add_to_page_cache_locked, but used to add newly allocated pages:
- * the page is new, so we can just run SetPageLocked() against it.
- */
-static inline int add_to_page_cache(struct page *page,
-		struct address_space *mapping, pgoff_t offset, gfp_t gfp_mask)
-{
-	int error;
-
-	SetPageLocked(page);
-	error = add_to_page_cache_locked(page, mapping, offset, gfp_mask);
-	if (unlikely(error))
-		ClearPageLocked(page);
-	return error;
-}
-
 /*
  * Return byte-offset into filesystem object for page.
  */
@@ -294,13 +271,28 @@ extern int __lock_page_killable(struct p
 extern void __lock_page_nosync(struct page *page);
 extern void unlock_page(struct page *page);
 
+static inline void set_page_locked(struct page *page)
+{
+	set_bit(PG_locked, &page->flags);
+}
+
+static inline void clear_page_locked(struct page *page)
+{
+	clear_bit(PG_locked, &page->flags);
+}
+
+static inline int trylock_page(struct page *page)
+{
+	return !test_and_set_bit(PG_locked, &page->flags);
+}
+
 /*
  * lock_page may only be called if we have the page's inode pinned.
  */
 static inline void lock_page(struct page *page)
 {
 	might_sleep();
-	if (TestSetPageLocked(page))
+	if (!trylock_page(page))
 		__lock_page(page);
 }
 
@@ -312,7 +304,7 @@ static inline void lock_page(struct page
 static inline int lock_page_killable(struct page *page)
 {
 	might_sleep();
-	if (TestSetPageLocked(page))
+	if (!trylock_page(page))
 		return __lock_page_killable(page);
 	return 0;
 }
@@ -324,7 +316,7 @@ static inline int lock_page_killable(str
 static inline void lock_page_nosync(struct page *page)
 {
 	might_sleep();
-	if (TestSetPageLocked(page))
+	if (!trylock_page(page))
 		__lock_page_nosync(page);
 }
 	
@@ -409,4 +401,27 @@ static inline int fault_in_pages_readabl
 	return ret;
 }
 
+int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
+				pgoff_t index, gfp_t gfp_mask);
+int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
+				pgoff_t index, gfp_t gfp_mask);
+extern void remove_from_page_cache(struct page *page);
+extern void __remove_from_page_cache(struct page *page);
+
+/*
+ * Like add_to_page_cache_locked, but used to add newly allocated pages:
+ * the page is new, so we can just run set_page_locked() against it.
+ */
+static inline int add_to_page_cache(struct page *page,
+		struct address_space *mapping, pgoff_t offset, gfp_t gfp_mask)
+{
+	int error;
+
+	set_page_locked(page);
+	error = add_to_page_cache_locked(page, mapping, offset, gfp_mask);
+	if (unlikely(error))
+		clear_page_locked(page);
+	return error;
+}
+
 #endif /* _LINUX_PAGEMAP_H */
Index: linux-2.6/drivers/scsi/sg.c
===================================================================
--- linux-2.6.orig/drivers/scsi/sg.c
+++ linux-2.6/drivers/scsi/sg.c
@@ -1747,7 +1747,7 @@ st_map_user_pages(struct scatterlist *sg
                  */
 		flush_dcache_page(pages[i]);
 		/* ?? Is locking needed? I don't think so */
-		/* if (TestSetPageLocked(pages[i]))
+		/* if (!trylock_page(pages[i]))
 		   goto out_unlock; */
         }
 
Index: linux-2.6/fs/cifs/file.c
===================================================================
--- linux-2.6.orig/fs/cifs/file.c
+++ linux-2.6/fs/cifs/file.c
@@ -1280,7 +1280,7 @@ retry:
 
 			if (first < 0)
 				lock_page(page);
-			else if (TestSetPageLocked(page))
+			else if (!trylock_page(page))
 				break;
 
 			if (unlikely(page->mapping != mapping)) {
Index: linux-2.6/fs/jbd/commit.c
===================================================================
--- linux-2.6.orig/fs/jbd/commit.c
+++ linux-2.6/fs/jbd/commit.c
@@ -63,7 +63,7 @@ static void release_buffer_page(struct b
 		goto nope;
 
 	/* OK, it's a truncated page */
-	if (TestSetPageLocked(page))
+	if (!trylock_page(page))
 		goto nope;
 
 	page_cache_get(page);
@@ -446,7 +446,7 @@ void journal_commit_transaction(journal_
 			spin_lock(&journal->j_list_lock);
 		}
 		if (unlikely(!buffer_uptodate(bh))) {
-			if (TestSetPageLocked(bh->b_page)) {
+			if (!trylock_page(bh->b_page)) {
 				spin_unlock(&journal->j_list_lock);
 				lock_page(bh->b_page);
 				spin_lock(&journal->j_list_lock);
Index: linux-2.6/fs/jbd2/commit.c
===================================================================
--- linux-2.6.orig/fs/jbd2/commit.c
+++ linux-2.6/fs/jbd2/commit.c
@@ -67,7 +67,7 @@ static void release_buffer_page(struct b
 		goto nope;
 
 	/* OK, it's a truncated page */
-	if (TestSetPageLocked(page))
+	if (!trylock_page(page))
 		goto nope;
 
 	page_cache_get(page);
Index: linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_aops.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
@@ -675,7 +675,7 @@ xfs_probe_cluster(
 			} else
 				pg_offset = PAGE_CACHE_SIZE;
 
-			if (page->index == tindex && !TestSetPageLocked(page)) {
+			if (page->index == tindex && trylock_page(page)) {
 				pg_len = xfs_probe_page(page, pg_offset, mapped);
 				unlock_page(page);
 			}
@@ -759,7 +759,7 @@ xfs_convert_page(
 
 	if (page->index != tindex)
 		goto fail;
-	if (TestSetPageLocked(page))
+	if (!trylock_page(page))
 		goto fail;
 	if (PageWriteback(page))
 		goto fail_unlock_page;
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -163,7 +163,7 @@ static inline int Page##uname(struct pag
 
 struct page;	/* forward declaration */
 
-PAGEFLAG(Locked, locked) TESTSCFLAG(Locked, locked)
+TESTPAGEFLAG(Locked, locked)
 PAGEFLAG(Error, error)
 PAGEFLAG(Referenced, referenced) TESTCLEARFLAG(Referenced, referenced)
 PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1789,7 +1789,7 @@ static int do_wp_page(struct mm_struct *
 	 * not dirty accountable.
 	 */
 	if (PageAnon(old_page)) {
-		if (!TestSetPageLocked(old_page)) {
+		if (trylock_page(old_page)) {
 			reuse = can_share_swap_page(old_page);
 			unlock_page(old_page);
 		}
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -605,7 +605,7 @@ static int move_to_new_page(struct page 
 	 * establishing additional references. We are the only one
 	 * holding a reference to the new page at this point.
 	 */
-	if (TestSetPageLocked(newpage))
+	if (!trylock_page(newpage))
 		BUG();
 
 	/* Prepare mapping for the new page.*/
@@ -667,7 +667,7 @@ static int unmap_and_move(new_page_t get
 	BUG_ON(charge);
 
 	rc = -EAGAIN;
-	if (TestSetPageLocked(page)) {
+	if (!trylock_page(page)) {
 		if (!force)
 			goto move_newpage;
 		lock_page(page);
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -422,7 +422,7 @@ int page_referenced(struct page *page, i
 			referenced += page_referenced_anon(page, mem_cont);
 		else if (is_locked)
 			referenced += page_referenced_file(page, mem_cont);
-		else if (TestSetPageLocked(page))
+		else if (!trylock_page(page))
 			referenced++;
 		else {
 			if (page->mapping)
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -1265,7 +1265,7 @@ repeat:
 		}
 
 		/* We have to do this with page locked to prevent races */
-		if (TestSetPageLocked(swappage)) {
+		if (!trylock_page(swappage)) {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			wait_on_page_locked(swappage);
@@ -1329,7 +1329,7 @@ repeat:
 		shmem_swp_unmap(entry);
 		filepage = find_get_page(mapping, idx);
 		if (filepage &&
-		    (!PageUptodate(filepage) || TestSetPageLocked(filepage))) {
+		    (!PageUptodate(filepage) || !trylock_page(filepage))) {
 			spin_unlock(&info->lock);
 			wait_on_page_locked(filepage);
 			page_cache_release(filepage);
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c
+++ linux-2.6/mm/swap.c
@@ -444,7 +444,7 @@ void pagevec_strip(struct pagevec *pvec)
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
 
-		if (PagePrivate(page) && !TestSetPageLocked(page)) {
+		if (PagePrivate(page) && trylock_page(page)) {
 			if (PagePrivate(page))
 				try_to_release_page(page, 0);
 			unlock_page(page);
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -201,7 +201,7 @@ void delete_from_swap_cache(struct page 
  */
 static inline void free_swap_cache(struct page *page)
 {
-	if (PageSwapCache(page) && !TestSetPageLocked(page)) {
+	if (PageSwapCache(page) && trylock_page(page)) {
 		remove_exclusive_swap_page(page);
 		unlock_page(page);
 	}
@@ -302,9 +302,9 @@ struct page *read_swap_cache_async(swp_e
 		 * re-using the just freed swap entry for an existing page.
 		 * May fail (-ENOMEM) if radix-tree node allocation failed.
 		 */
-		SetPageLocked(new_page);
+		set_page_locked(new_page);
 		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
-		if (!err) {
+		if (likely(!err)) {
 			/*
 			 * Initiate read into locked page and return.
 			 */
@@ -312,7 +312,7 @@ struct page *read_swap_cache_async(swp_e
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}
-		ClearPageLocked(new_page);
+		clear_page_locked(new_page);
 		swap_free(entry);
 	} while (err != -ENOMEM);
 
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -403,7 +403,7 @@ void free_swap_and_cache(swp_entry_t ent
 	if (p) {
 		if (swap_entry_free(p, swp_offset(entry)) == 1) {
 			page = find_get_page(&swapper_space, entry.val);
-			if (page && unlikely(TestSetPageLocked(page))) {
+			if (page && unlikely(!trylock_page(page))) {
 				page_cache_release(page);
 				page = NULL;
 			}
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -188,7 +188,7 @@ void truncate_inode_pages_range(struct a
 			if (page_index > next)
 				next = page_index;
 			next++;
-			if (TestSetPageLocked(page))
+			if (!trylock_page(page))
 				continue;
 			if (PageWriteback(page)) {
 				unlock_page(page);
@@ -281,7 +281,7 @@ unsigned long __invalidate_mapping_pages
 			pgoff_t index;
 			int lock_failed;
 
-			lock_failed = TestSetPageLocked(page);
+			lock_failed = !trylock_page(page);
 
 			/*
 			 * We really shouldn't be looking at the ->index of an
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -496,7 +496,7 @@ static unsigned long shrink_page_list(st
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
-		if (TestSetPageLocked(page))
+		if (!trylock_page(page))
 			goto keep;
 
 		VM_BUG_ON(PageActive(page));
@@ -582,7 +582,7 @@ static unsigned long shrink_page_list(st
 				 * A synchronous write - probably a ramdisk.  Go
 				 * ahead and try to reclaim the page.
 				 */
-				if (TestSetPageLocked(page))
+				if (!trylock_page(page))
 					goto keep;
 				if (PageDirty(page) || PageWriteback(page))
 					goto keep_locked;
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -558,14 +558,14 @@ EXPORT_SYMBOL(wait_on_page_bit);
  * But that's OK - sleepers in wait_on_page_writeback() just go back to sleep.
  *
  * The first mb is necessary to safely close the critical section opened by the
- * TestSetPageLocked(), the second mb is necessary to enforce ordering between
- * the clear_bit and the read of the waitqueue (to avoid SMP races with a
- * parallel wait_on_page_locked()).
+ * test_and_set_bit() to lock the page; the second mb is necessary to enforce
+ * ordering between the clear_bit and the read of the waitqueue (to avoid SMP
+ * races with a parallel wait_on_page_locked()).
  */
 void unlock_page(struct page *page)
 {
 	smp_mb__before_clear_bit();
-	if (!TestClearPageLocked(page))
+	if (!test_and_clear_bit(PG_locked, &page->flags))
 		BUG();
 	smp_mb__after_clear_bit(); 
 	wake_up_page(page, PG_locked);
@@ -931,7 +931,7 @@ grab_cache_page_nowait(struct address_sp
 	struct page *page = find_get_page(mapping, index);
 
 	if (page) {
-		if (!TestSetPageLocked(page))
+		if (trylock_page(page))
 			return page;
 		page_cache_release(page);
 		return NULL;
@@ -1027,7 +1027,7 @@ find_page:
 			if (inode->i_blkbits == PAGE_CACHE_SHIFT ||
 					!mapping->a_ops->is_partially_uptodate)
 				goto page_not_up_to_date;
-			if (TestSetPageLocked(page))
+			if (!trylock_page(page))
 				goto page_not_up_to_date;
 			if (!mapping->a_ops->is_partially_uptodate(page,
 								desc, offset))
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -371,7 +371,7 @@ __generic_file_splice_read(struct file *
 			 * for an in-flight io page
 			 */
 			if (flags & SPLICE_F_NONBLOCK) {
-				if (TestSetPageLocked(page)) {
+				if (!trylock_page(page)) {
 					error = -EAGAIN;
 					break;
 				}
Index: linux-2.6/fs/afs/write.c
===================================================================
--- linux-2.6.orig/fs/afs/write.c
+++ linux-2.6/fs/afs/write.c
@@ -404,7 +404,7 @@ static int afs_write_back_from_locked_pa
 			page = pages[loop];
 			if (page->index > wb->last)
 				break;
-			if (TestSetPageLocked(page))
+			if (!trylock_page(page))
 				break;
 			if (!PageDirty(page) ||
 			    page_private(page) != (unsigned long) wb) {
Index: linux-2.6/fs/reiserfs/journal.c
===================================================================
--- linux-2.6.orig/fs/reiserfs/journal.c
+++ linux-2.6/fs/reiserfs/journal.c
@@ -627,7 +627,7 @@ static int journal_list_still_alive(stru
 static void release_buffer_page(struct buffer_head *bh)
 {
 	struct page *page = bh->b_page;
-	if (!page->mapping && !TestSetPageLocked(page)) {
+	if (!page->mapping && trylock_page(page)) {
 		page_cache_get(page);
 		put_bh(bh);
 		if (!page->mapping)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

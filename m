Date: Sat, 10 Nov 2007 06:12:22 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/2] mm: page trylock rename
Message-ID: <20071110051222.GA16018@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Hi,

OK minus the memory barrier changes for now. Can we possibly please
get these into 2.6.24?

--
mm: rename page trylock

Converting page lock to new locking bitops requires a change of page flag
operation naming, so we might as well convert it to something nicer
(!TestSetPageLocked => trylock_page, SetPageLocked => set_page_locked).

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 drivers/scsi/sg.c           |    2 +-
 fs/afs/write.c              |    2 +-
 fs/cifs/file.c              |    2 +-
 fs/jbd/commit.c             |    2 +-
 fs/jbd2/commit.c            |    2 +-
 fs/reiserfs/journal.c       |    2 +-
 fs/splice.c                 |    2 +-
 fs/xfs/linux-2.6/xfs_aops.c |    4 ++--
 include/linux/page-flags.h  |    8 --------
 include/linux/pagemap.h     |   19 +++++++++++++++++--
 mm/filemap.c                |   12 ++++++------
 mm/memory.c                 |    2 +-
 mm/migrate.c                |    4 ++--
 mm/rmap.c                   |    2 +-
 mm/shmem.c                  |    4 ++--
 mm/swap.c                   |    2 +-
 mm/swap_state.c             |    6 +++---
 mm/swapfile.c               |    2 +-
 mm/truncate.c               |    4 ++--
 mm/vmscan.c                 |    4 ++--
 20 files changed, 47 insertions(+), 40 deletions(-)

Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -160,13 +160,28 @@ extern void FASTCALL(__lock_page(struct 
 extern void FASTCALL(__lock_page_nosync(struct page *page));
 extern void FASTCALL(unlock_page(struct page *page));
 
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
 
@@ -177,7 +192,7 @@ static inline void lock_page(struct page
 static inline void lock_page_nosync(struct page *page)
 {
 	might_sleep();
-	if (TestSetPageLocked(page))
+	if (!trylock_page(page))
 		__lock_page_nosync(page);
 }
 	
Index: linux-2.6/drivers/scsi/sg.c
===================================================================
--- linux-2.6.orig/drivers/scsi/sg.c
+++ linux-2.6/drivers/scsi/sg.c
@@ -1714,7 +1714,7 @@ st_map_user_pages(struct scatterlist *sg
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
@@ -1251,7 +1251,7 @@ retry:
 
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
Index: linux-2.6/fs/jbd2/commit.c
===================================================================
--- linux-2.6.orig/fs/jbd2/commit.c
+++ linux-2.6/fs/jbd2/commit.c
@@ -63,7 +63,7 @@ static void release_buffer_page(struct b
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
@@ -659,7 +659,7 @@ xfs_probe_cluster(
 			} else
 				pg_offset = PAGE_CACHE_SIZE;
 
-			if (page->index == tindex && !TestSetPageLocked(page)) {
+			if (page->index == tindex && trylock_page(page)) {
 				pg_len = xfs_probe_page(page, pg_offset, mapped);
 				unlock_page(page);
 			}
@@ -743,7 +743,7 @@ xfs_convert_page(
 
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
@@ -113,14 +113,6 @@
  */
 #define PageLocked(page)		\
 		test_bit(PG_locked, &(page)->flags)
-#define SetPageLocked(page)		\
-		set_bit(PG_locked, &(page)->flags)
-#define TestSetPageLocked(page)		\
-		test_and_set_bit(PG_locked, &(page)->flags)
-#define ClearPageLocked(page)		\
-		clear_bit(PG_locked, &(page)->flags)
-#define TestClearPageLocked(page)	\
-		test_and_clear_bit(PG_locked, &(page)->flags)
 
 #define PageError(page)		test_bit(PG_error, &(page)->flags)
 #define SetPageError(page)	set_bit(PG_error, &(page)->flags)
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1559,7 +1559,7 @@ static int do_wp_page(struct mm_struct *
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
@@ -569,7 +569,7 @@ static int move_to_new_page(struct page 
 	 * establishing additional references. We are the only one
 	 * holding a reference to the new page at this point.
 	 */
-	if (TestSetPageLocked(newpage))
+	if (!trylock_page(newpage))
 		BUG();
 
 	/* Prepare mapping for the new page.*/
@@ -622,7 +622,7 @@ static int unmap_and_move(new_page_t get
 		goto move_newpage;
 
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
@@ -401,7 +401,7 @@ int page_referenced(struct page *page, i
 			referenced += page_referenced_anon(page);
 		else if (is_locked)
 			referenced += page_referenced_file(page);
-		else if (TestSetPageLocked(page))
+		else if (!trylock_page(page))
 			referenced++;
 		else {
 			if (page->mapping)
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -1182,7 +1182,7 @@ repeat:
 		}
 
 		/* We have to do this with page locked to prevent races */
-		if (TestSetPageLocked(swappage)) {
+		if (!trylock_page(swappage)) {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			wait_on_page_locked(swappage);
@@ -1241,7 +1241,7 @@ repeat:
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
@@ -455,7 +455,7 @@ void pagevec_strip(struct pagevec *pvec)
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
@@ -104,13 +104,13 @@ static int add_to_swap_cache(struct page
 		INC_CACHE_INFO(noent_race);
 		return -ENOENT;
 	}
-	SetPageLocked(page);
+	set_page_locked(page);
 	error = __add_to_swap_cache(page, entry, GFP_KERNEL);
 	/*
 	 * Anon pages are already on the LRU, we don't run lru_cache_add here.
 	 */
 	if (error) {
-		ClearPageLocked(page);
+		clear_page_locked(page);
 		swap_free(entry);
 		if (error == -EEXIST)
 			INC_CACHE_INFO(exist_race);
@@ -255,7 +255,7 @@ int move_from_swap_cache(struct page *pa
  */
 static inline void free_swap_cache(struct page *page)
 {
-	if (PageSwapCache(page) && !TestSetPageLocked(page)) {
+	if (PageSwapCache(page) && trylock_page(page)) {
 		remove_exclusive_swap_page(page);
 		unlock_page(page);
 	}
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -401,7 +401,7 @@ void free_swap_and_cache(swp_entry_t ent
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
@@ -189,7 +189,7 @@ void truncate_inode_pages_range(struct a
 			if (page_index > next)
 				next = page_index;
 			next++;
-			if (TestSetPageLocked(page))
+			if (!trylock_page(page))
 				continue;
 			if (PageWriteback(page)) {
 				unlock_page(page);
@@ -282,7 +282,7 @@ unsigned long __invalidate_mapping_pages
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
@@ -461,7 +461,7 @@ static unsigned long shrink_page_list(st
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
-		if (TestSetPageLocked(page))
+		if (!trylock_page(page))
 			goto keep;
 
 		VM_BUG_ON(PageActive(page));
@@ -547,7 +547,7 @@ static unsigned long shrink_page_list(st
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
@@ -433,7 +433,7 @@ int filemap_write_and_wait_range(struct 
  * @gfp_mask:	page allocation mode
  *
  * This function is used to add newly allocated pagecache pages;
- * the page is new, so we can just run SetPageLocked() against it.
+ * the page is new, so we can just run set_page_locked() against it.
  * The other page state flags were set by rmqueue().
  *
  * This function does not add the page to the LRU.  The caller must do that.
@@ -448,7 +448,7 @@ int add_to_page_cache(struct page *page,
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
 		if (!error) {
 			page_cache_get(page);
-			SetPageLocked(page);
+			set_page_locked(page);
 			page->mapping = mapping;
 			page->index = offset;
 			mapping->nrpages++;
@@ -530,14 +530,14 @@ EXPORT_SYMBOL(wait_on_page_bit);
  * But that's OK - sleepers in wait_on_page_writeback() just go back to sleep.
  *
  * The first mb is necessary to safely close the critical section opened by the
- * TestSetPageLocked(), the second mb is necessary to enforce ordering between
+ * trylock_page(), the second mb is necessary to enforce ordering between
  * the clear_bit and the read of the waitqueue (to avoid SMP races with a
  * parallel wait_on_page_locked()).
  */
 void fastcall unlock_page(struct page *page)
 {
 	smp_mb__before_clear_bit();
-	if (!TestClearPageLocked(page))
+	if (!test_and_clear_bit(PG_locked, &page->flags))
 		BUG();
 	smp_mb__after_clear_bit(); 
 	wake_up_page(page, PG_locked);
@@ -629,7 +629,7 @@ repeat:
 	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page) {
 		page_cache_get(page);
-		if (TestSetPageLocked(page)) {
+		if (!trylock_page(page)) {
 			read_unlock_irq(&mapping->tree_lock);
 			__lock_page(page);
 
@@ -801,7 +801,7 @@ grab_cache_page_nowait(struct address_sp
 	struct page *page = find_get_page(mapping, index);
 
 	if (page) {
-		if (!TestSetPageLocked(page))
+		if (trylock_page(page))
 			return page;
 		page_cache_release(page);
 		return NULL;
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -364,7 +364,7 @@ __generic_file_splice_read(struct file *
 			 * for an in-flight io page
 			 */
 			if (flags & SPLICE_F_NONBLOCK) {
-				if (TestSetPageLocked(page))
+				if (!trylock_page(page))
 					break;
 			} else
 				lock_page(page);
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
@@ -629,7 +629,7 @@ static int journal_list_still_alive(stru
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

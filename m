From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16994.40699.267629.21475@gargle.gargle.HOWL>
Date: Sun, 17 Apr 2005 21:38:03 +0400
Subject: [PATCH]: VM 7/8 cluster pageout
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

Implement pageout clustering at the VM level.

With this patch VM scanner calls pageout_cluster() instead of
->writepage(). pageout_cluster() tries to find a group of dirty pages around
target page, called "pivot" page of the cluster. If group of suitable size is
found, ->writepages() is called for it, otherwise page_cluster() falls back
to ->writepage().

This is supposed to help in work-loads with significant page-out of
file-system pages from tail of the inactive list (for example, heavy dirtying
through mmap), because file system usually writes multiple pages more
efficiently. Should also be advantageous for file-systems doing delayed
allocation, as in this case they will allocate whole extents at once.

Few points:

 - swap-cache pages are not clustered (although they can be, but by
   page->private rather than page->index)

 - only kswapd do clustering, because direct reclaim path should be low
   latency.

 - this patch adds new fields to struct writeback_control and expects
   ->writepages() to interpret them. This is needed, because pageout_cluster()
   calls ->writepages() with pivot page already locked, so that ->writepages()
   is allowed to only trylock other pages in the cluster.

   Besides, rather rough plumbing (wbc->pivot_ret field) is added to check
   whether ->writepages() failed to write pivot page for any reason (in latter
   case page_cluster() falls back to ->writepage()).

   Only mpage_writepages() was updated to honor these new fields, but
   all in-tree ->writepages() implementations seem to call
   mpage_writepages(). (Except reiser4, of course, for which I'll send a
   (trivial) patch, if necessary).

Signed-off-by: Nikita Danilov <nikita@clusterfs.com>


 fs/mpage.c                |  118 +++++++++++++++++++++-------------------------
 include/linux/writeback.h |    6 ++
 mm/vmscan.c               |   72 +++++++++++++++++++++++++++-
 3 files changed, 133 insertions(+), 63 deletions(-)

diff -puN mm/vmscan.c~cluster-pageout mm/vmscan.c
--- bk-linux/mm/vmscan.c~cluster-pageout	2005-04-17 17:52:52.000000000 +0400
+++ bk-linux-nikita/mm/vmscan.c	2005-04-17 17:52:52.000000000 +0400
@@ -349,6 +349,76 @@ static void send_page_to_kaiod(struct pa
 	spin_unlock(&kaio_queue_lock);
 }
 
+enum {
+	PAGE_CLUSTER_WING = 16,
+	PAGE_CLUSTER_SIZE = 2 * PAGE_CLUSTER_WING,
+};
+
+enum {
+	PIVOT_RET_MAGIC = 42
+};
+
+static int pageout_cluster(struct page *page, struct address_space *mapping,
+			   struct writeback_control *wbc)
+{
+	pgoff_t punct;
+	pgoff_t start;
+	pgoff_t end;
+	struct page *opage = page;
+
+	if (PageSwapCache(page) || !current_is_kswapd())
+		return mapping->a_ops->writepage(page, wbc);
+
+	wbc->pivot = page;
+	punct = page->index;
+	read_lock_irq(&mapping->tree_lock);
+	for (start = punct - 1;
+	     start < punct && punct - start <= PAGE_CLUSTER_WING; -- start) {
+		page = radix_tree_lookup(&mapping->page_tree, start);
+		if (page == NULL || !PageDirty(page))
+			/*
+			 * no suitable page, stop cluster at this point
+			 */
+			break;
+		if ((start % PAGE_CLUSTER_SIZE) == 0)
+			/*
+			 * we reached aligned page.
+			 */
+			-- start;
+			break;
+	}
+	++ start;
+	for (end = punct + 1;
+	     end > punct && end - start < PAGE_CLUSTER_SIZE; ++ end) {
+		/*
+		 * XXX nikita: consider find_get_pages_tag()
+		 */
+		page = radix_tree_lookup(&mapping->page_tree, end);
+		if (page == NULL || !PageDirty(page))
+			/*
+			 * no suitable page, stop cluster at this point
+			 */
+			break;
+	}
+	read_unlock_irq(&mapping->tree_lock);
+	-- end;
+	wbc->pivot_ret = PIVOT_RET_MAGIC; /* magic */
+	if (end > start) {
+		wbc->start = ((loff_t)start) << PAGE_CACHE_SHIFT;
+		wbc->end   = ((loff_t)end) << PAGE_CACHE_SHIFT;
+		wbc->end  += PAGE_CACHE_SIZE - 1;
+		wbc->nr_to_write = end - start + 1;
+		do_writepages(mapping, wbc);
+	}
+	if (wbc->pivot_ret == PIVOT_RET_MAGIC)
+		/*
+		 * single page, or ->writepages() skipped pivot for any
+		 * reason: just call ->writepage()
+		 */
+		wbc->pivot_ret = mapping->a_ops->writepage(opage, wbc);
+	return wbc->pivot_ret;
+}
+
 /*
  * Called by shrink_list() for each dirty page. Calls ->writepage().
  */
@@ -434,7 +504,7 @@ static pageout_t pageout(struct page *pa
 
 		ClearPageSkipped(page);
 		SetPageReclaim(page);
-		res = mapping->a_ops->writepage(page, &wbc);
+		res = pageout_cluster(page, mapping, &wbc);
 
 		if (res < 0)
 			handle_write_error(mapping, page, res);
diff -puN include/linux/writeback.h~cluster-pageout include/linux/writeback.h
--- bk-linux/include/linux/writeback.h~cluster-pageout	2005-04-17 17:52:52.000000000 +0400
+++ bk-linux-nikita/include/linux/writeback.h	2005-04-17 17:52:52.000000000 +0400
@@ -55,6 +55,12 @@ struct writeback_control {
 	unsigned encountered_congestion:1;	/* An output: a queue is full */
 	unsigned for_kupdate:1;			/* A kupdate writeback */
 	unsigned for_reclaim:1;			/* Invoked from the page allocator */
+	/* if non-NULL, page already locked by ->writepages()
+	 * caller. ->writepages() should use trylock on all other pages it
+	 * submits for IO */
+	struct page *pivot;
+	/* if ->pivot is not NULL, result for pivot page is stored here */
+	int pivot_ret;
 };
 
 /*
diff -puN fs/mpage.c~cluster-pageout fs/mpage.c
--- bk-linux/fs/mpage.c~cluster-pageout	2005-04-17 17:52:52.000000000 +0400
+++ bk-linux-nikita/fs/mpage.c	2005-04-17 17:52:52.000000000 +0400
@@ -391,7 +391,6 @@ __mpage_writepage(struct bio *bio, struc
 	sector_t *last_block_in_bio, int *ret, struct writeback_control *wbc,
 	writepage_t writepage_fn)
 {
-	struct address_space *mapping = page->mapping;
 	struct inode *inode = page->mapping->host;
 	const unsigned blkbits = inode->i_blkbits;
 	unsigned long end_index;
@@ -409,6 +408,7 @@ __mpage_writepage(struct bio *bio, struc
 	struct buffer_head map_bh;
 	loff_t i_size = i_size_read(inode);
 
+	*ret = 0;
 	if (page_has_buffers(page)) {
 		struct buffer_head *head = page_buffers(page);
 		struct buffer_head *bh = head;
@@ -582,30 +582,22 @@ alloc_new:
 confused:
 	if (bio)
 		bio = mpage_bio_submit(WRITE, bio);
-
-	if (writepage_fn) {
-		*ret = (*writepage_fn)(page, wbc);
-	} else {
-		*ret = -EAGAIN;
-		goto out;
-	}
-	/*
-	 * The caller has a ref on the inode, so *mapping is stable
-	 */
-	if (*ret) {
-		if (*ret == -ENOSPC)
-			set_bit(AS_ENOSPC, &mapping->flags);
-		else
-			set_bit(AS_EIO, &mapping->flags);
-	}
 out:
 	return bio;
 }
 
+static void handle_writepage_error(int err, struct address_space *mapping)
+{
+	if (unlikely(err == -ENOSPC))
+		set_bit(AS_ENOSPC, &mapping->flags);
+	else if (unlikely(err != 0))
+		set_bit(AS_EIO, &mapping->flags);
+}
+
 /**
  * mpage_writepages - walk the list of dirty pages of the given
  * address space and writepage() all of them.
- * 
+ *
  * @mapping: address space structure to write
  * @wbc: subtract the number of written pages from *@wbc->nr_to_write
  * @get_block: the filesystem's block mapper function.
@@ -682,51 +674,53 @@ retry:
 		for (i = 0; i < nr_pages; i++) {
 			struct page *page = pvec.pages[i];
 
-			/*
-			 * At this point we hold neither mapping->tree_lock nor
-			 * lock on the page itself: the page may be truncated or
-			 * invalidated (changing page->mapping to NULL), or even
-			 * swizzled back from swapper_space to tmpfs file
-			 * mapping
-			 */
-
-			lock_page(page);
+			if (page != wbc->pivot) {
+				/*
+				 * At this point we hold neither
+				 * mapping->tree_lock nor lock on the page
+				 * itself: the page may be truncated or
+				 * invalidated (changing page->mapping to
+				 * NULL), or even swizzled back from
+				 * swapper_space to tmpfs file mapping
+				 */
 
-			if (unlikely(page->mapping != mapping)) {
-				unlock_page(page);
-				continue;
-			}
+				if (wbc->pivot != NULL) {
+					if (unlikely(TestSetPageLocked(page)))
+						continue;
+				} else
+					lock_page(page);
+
+				if (unlikely(page->mapping != mapping)) {
+					unlock_page(page);
+					continue;
+				}
 
-			if (unlikely(is_range) && page->index > end) {
-				done = 1;
-				unlock_page(page);
-				continue;
-			}
+				if (unlikely(is_range) && page->index > end) {
+					done = 1;
+					unlock_page(page);
+					continue;
+				}
 
-			if (wbc->sync_mode != WB_SYNC_NONE)
-				wait_on_page_writeback(page);
+				if (wbc->sync_mode != WB_SYNC_NONE)
+					wait_on_page_writeback(page);
 
-			if (PageWriteback(page) ||
-					!clear_page_dirty_for_io(page)) {
-				unlock_page(page);
-				continue;
+				if (PageWriteback(page) ||
+				    !clear_page_dirty_for_io(page)) {
+					unlock_page(page);
+					continue;
+				}
 			}
 
-			if (writepage) {
+			if (writepage)
 				ret = (*writepage)(page, wbc);
-				if (ret) {
-					if (ret == -ENOSPC)
-						set_bit(AS_ENOSPC,
-							&mapping->flags);
-					else
-						set_bit(AS_EIO,
-							&mapping->flags);
-				}
-			} else {
+			else
 				bio = __mpage_writepage(bio, page, get_block,
-						&last_block_in_bio, &ret, wbc,
-						writepage_fn);
-			}
+							&last_block_in_bio,
+							&ret, wbc,
+							writepage_fn);
+			handle_writepage_error(ret, page->mapping);
+			if (page == wbc->pivot)
+				wbc->pivot_ret = ret;
 			if (ret || (--(wbc->nr_to_write) <= 0))
 				done = 1;
 			if (wbc->nonblocking && bdi_write_congested(bdi)) {
@@ -766,7 +760,7 @@ int mpage_writepage(struct page *page, g
 			&last_block_in_bio, &ret, wbc, NULL);
 	if (bio)
 		mpage_bio_submit(WRITE, bio);
-
+	handle_writepage_error(ret, page->mapping);
 	return ret;
 }
 EXPORT_SYMBOL(mpage_writepage);

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

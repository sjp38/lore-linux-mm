Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 62FE86B004D
	for <linux-mm@kvack.org>; Sat, 12 May 2012 08:19:34 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6143417pbb.14
        for <linux-mm@kvack.org>; Sat, 12 May 2012 05:19:33 -0700 (PDT)
Date: Sat, 12 May 2012 05:19:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 8/10] tmpfs: undo fallocation on failure
In-Reply-To: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1205120517330.28861@eggly.anvils>
References: <alpine.LSU.2.00.1205120447380.28861@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Cong Wang <amwang@redhat.com>, Kay Sievers <kay@vrfy.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

In the previous episode, we left the already-fallocated pages attached
to the file when shmem_fallocate() fails part way through.

Now try to do better, by extending the earlier optimization of !Uptodate
pages (then always under page lock) to !Uptodate pages (outside of page
lock), representing fallocated pages.  And don't waste time clearing
them at the time of fallocate(), leave that until later if necessary.

Adapt shmem_truncate_range() to shmem_undo_range(), so that a failing
fallocate can recognize and remove precisely those !Uptodate allocations
which it added (and were not independently allocated by racing tasks).

But unless we start playing with swapfile.c and memcontrol.c too, once
one of our fallocated pages reaches shmem_writepage(), we do then have
to instantiate it as an ordinarily allocated page, before swapping out.
This is unsatisfactory, but improved in the next episode.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |  105 ++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 72 insertions(+), 33 deletions(-)

--- 3045N.orig/mm/shmem.c	2012-05-05 10:46:45.312062979 -0700
+++ 3045N/mm/shmem.c	2012-05-05 10:46:53.860063201 -0700
@@ -89,7 +89,8 @@ enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
 	SGP_DIRTY,	/* like SGP_CACHE, but set new page dirty */
-	SGP_WRITE,	/* may exceed i_size, may allocate page */
+	SGP_WRITE,	/* may exceed i_size, may allocate !Uptodate page */
+	SGP_FALLOC,	/* like SGP_WRITE, but make existing page Uptodate */
 };
 
 #ifdef CONFIG_TMPFS
@@ -427,8 +428,10 @@ void shmem_unlock_mapping(struct address
 
 /*
  * Remove range of pages and swap entries from radix tree, and free them.
+ * If !unfalloc, truncate or punch hole; if unfalloc, undo failed fallocate.
  */
-void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
+static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
+								 bool unfalloc)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -462,6 +465,8 @@ void shmem_truncate_range(struct inode *
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
+				if (unfalloc)
+					continue;
 				nr_swaps_freed += !shmem_free_swap(mapping,
 								index, page);
 				continue;
@@ -469,9 +474,11 @@ void shmem_truncate_range(struct inode *
 
 			if (!trylock_page(page))
 				continue;
-			if (page->mapping == mapping) {
-				VM_BUG_ON(PageWriteback(page));
-				truncate_inode_page(mapping, page);
+			if (!unfalloc || !PageUptodate(page)) {
+				if (page->mapping == mapping) {
+					VM_BUG_ON(PageWriteback(page));
+					truncate_inode_page(mapping, page);
+				}
 			}
 			unlock_page(page);
 		}
@@ -517,12 +524,12 @@ void shmem_truncate_range(struct inode *
 				min(end - index, (pgoff_t)PAGEVEC_SIZE),
 							pvec.pages, indices);
 		if (!pvec.nr) {
-			if (index == start)
+			if (index == start || unfalloc)
 				break;
 			index = start;
 			continue;
 		}
-		if (index == start && indices[0] >= end) {
+		if ((index == start || unfalloc) && indices[0] >= end) {
 			shmem_deswap_pagevec(&pvec);
 			pagevec_release(&pvec);
 			break;
@@ -536,15 +543,19 @@ void shmem_truncate_range(struct inode *
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
+				if (unfalloc)
+					continue;
 				nr_swaps_freed += !shmem_free_swap(mapping,
 								index, page);
 				continue;
 			}
 
 			lock_page(page);
-			if (page->mapping == mapping) {
-				VM_BUG_ON(PageWriteback(page));
-				truncate_inode_page(mapping, page);
+			if (!unfalloc || !PageUptodate(page)) {
+				if (page->mapping == mapping) {
+					VM_BUG_ON(PageWriteback(page));
+					truncate_inode_page(mapping, page);
+				}
 			}
 			unlock_page(page);
 		}
@@ -558,7 +569,11 @@ void shmem_truncate_range(struct inode *
 	info->swapped -= nr_swaps_freed;
 	shmem_recalc_inode(inode);
 	spin_unlock(&info->lock);
+}
 
+void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
+{
+	shmem_undo_range(inode, lstart, lend, false);
 	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
 }
 EXPORT_SYMBOL_GPL(shmem_truncate_range);
@@ -771,6 +786,18 @@ static int shmem_writepage(struct page *
 		WARN_ON_ONCE(1);	/* Still happens? Tell us about it! */
 		goto redirty;
 	}
+
+	/*
+	 * This is somewhat ridiculous, but without plumbing a SWAP_MAP_FALLOC
+	 * value into swapfile.c, the only way we can correctly account for a
+	 * fallocated page arriving here is now to initialize it and write it.
+	 */
+	if (!PageUptodate(page)) {
+		clear_highpage(page);
+		flush_dcache_page(page);
+		SetPageUptodate(page);
+	}
+
 	swap = get_swap_page();
 	if (!swap.val)
 		goto redirty;
@@ -994,6 +1021,7 @@ static int shmem_getpage_gfp(struct inod
 	swp_entry_t swap;
 	int error;
 	int once = 0;
+	int alloced = 0;
 
 	if (index > (MAX_LFS_FILESIZE >> PAGE_CACHE_SHIFT))
 		return -EFBIG;
@@ -1005,19 +1033,21 @@ repeat:
 		page = NULL;
 	}
 
-	if (sgp != SGP_WRITE &&
+	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
 	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
 		error = -EINVAL;
 		goto failed;
 	}
 
+	/* fallocated page? */
+	if (page && !PageUptodate(page)) {
+		if (sgp != SGP_READ)
+			goto clear;
+		unlock_page(page);
+		page_cache_release(page);
+		page = NULL;
+	}
 	if (page || (sgp == SGP_READ && !swap.val)) {
-		/*
-		 * Once we can get the page lock, it must be uptodate:
-		 * if there were an error in reading back from swap,
-		 * the page would not be inserted into the filecache.
-		 */
-		BUG_ON(page && !PageUptodate(page));
 		*pagep = page;
 		return 0;
 	}
@@ -1114,9 +1144,18 @@ repeat:
 		inode->i_blocks += BLOCKS_PER_PAGE;
 		shmem_recalc_inode(inode);
 		spin_unlock(&info->lock);
+		alloced = true;
 
 		/*
-		 * Let SGP_WRITE caller clear ends if write does not fill page
+		 * Let SGP_FALLOC use the SGP_WRITE optimization on a new page.
+		 */
+		if (sgp == SGP_FALLOC)
+			sgp = SGP_WRITE;
+clear:
+		/*
+		 * Let SGP_WRITE caller clear ends if write does not fill page;
+		 * but SGP_FALLOC on a page fallocated earlier must initialize
+		 * it now, lest undo on failure cancel our earlier guarantee.
 		 */
 		if (sgp != SGP_WRITE) {
 			clear_highpage(page);
@@ -1128,10 +1167,13 @@ repeat:
 	}
 
 	/* Perhaps the file has been truncated since we checked */
-	if (sgp != SGP_WRITE &&
+	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
 	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
 		error = -EINVAL;
-		goto trunc;
+		if (alloced)
+			goto trunc;
+		else
+			goto failed;
 	}
 	*pagep = page;
 	return 0;
@@ -1140,6 +1182,7 @@ repeat:
 	 * Error recovery.
 	 */
 trunc:
+	info = SHMEM_I(inode);
 	ClearPageDirty(page);
 	delete_from_page_cache(page);
 	spin_lock(&info->lock);
@@ -1147,6 +1190,7 @@ trunc:
 	inode->i_blocks -= BLOCKS_PER_PAGE;
 	spin_unlock(&info->lock);
 decused:
+	sbinfo = SHMEM_SB(inode->i_sb);
 	if (sbinfo->max_blocks)
 		percpu_counter_add(&sbinfo->used_blocks, -1);
 unacct:
@@ -1645,25 +1689,20 @@ static long shmem_fallocate(struct file
 		if (signal_pending(current))
 			error = -EINTR;
 		else
-			error = shmem_getpage(inode, index, &page, SGP_WRITE,
+			error = shmem_getpage(inode, index, &page, SGP_FALLOC,
 									NULL);
 		if (error) {
-			/*
-			 * We really ought to free what we allocated so far,
-			 * but it would be wrong to free pages allocated
-			 * earlier, or already now in use: i_mutex does not
-			 * exclude all cases.  We do not know what to free.
-			 */
+			/* Remove the !PageUptodate pages we added */
+			shmem_undo_range(inode,
+				(loff_t)start << PAGE_CACHE_SHIFT,
+				(loff_t)index << PAGE_CACHE_SHIFT, true);
 			goto ctime;
 		}
 
-		if (!PageUptodate(page)) {
-			clear_highpage(page);
-			flush_dcache_page(page);
-			SetPageUptodate(page);
-		}
 		/*
-		 * set_page_dirty so that memory pressure will swap rather
+		 * If !PageUptodate, leave it that way so that freeable pages
+		 * can be recognized if we need to rollback on error later.
+		 * But set_page_dirty so that memory pressure will swap rather
 		 * than free the pages we are allocating (and SGP_CACHE pages
 		 * might still be clean: we now need to mark those dirty too).
 		 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

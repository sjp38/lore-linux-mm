Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 393216B0253
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 22:38:22 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id tt10so79576785pab.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:38:22 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id we2si17916651pac.127.2016.03.31.19.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 19:38:20 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id e128so62033293pfe.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 19:38:20 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 2/2] mm: Real pagecache iterators
Date: Thu, 31 Mar 2016 18:38:11 -0800
Message-Id: <1459478291-29982-2-git-send-email-kent.overstreet@gmail.com>
In-Reply-To: <1459478291-29982-1-git-send-email-kent.overstreet@gmail.com>
References: <20160401023510.GA28762@kmo-pixel>
 <1459478291-29982-1-git-send-email-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kent Overstreet <kent.overstreet@gmail.com>

Introduce for_each_pagecache_page() and related macros, with the goal of
replacing most/all uses of pagevec_lookup().

For the most part this shouldn't be a functional change. The one functional
difference with the new macros is that they now take an @end parameter, so we're
able to avoid grabbing pages in __find_get_pages() that we'll never use.

This patch only does some of the conversions, the ones I was able to easily test
myself - the conversions are mechanical but tricky enough they generally warrent
testing.

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/ext4/inode.c         | 261 ++++++++++++++++++++----------------------------
 include/linux/pagevec.h |  67 ++++++++++++-
 mm/filemap.c            |  76 +++++++++-----
 mm/page-writeback.c     | 148 +++++++++++----------------
 mm/swap.c               |  33 +-----
 mm/truncate.c           | 259 +++++++++++++++++------------------------------
 6 files changed, 380 insertions(+), 464 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index dab84a2530..c4d73f67b5 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1605,11 +1605,10 @@ struct mpage_da_data {
 static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 				       bool invalidate)
 {
-	int nr_pages, i;
 	pgoff_t index, end;
-	struct pagevec pvec;
+	struct pagecache_iter iter;
+	struct page *page;
 	struct inode *inode = mpd->inode;
-	struct address_space *mapping = inode->i_mapping;
 
 	/* This is necessary when next_page == 0. */
 	if (mpd->first_page >= mpd->next_page)
@@ -1624,25 +1623,14 @@ static void mpage_release_unused_pages(struct mpage_da_data *mpd,
 		ext4_es_remove_extent(inode, start, last - start + 1);
 	}
 
-	pagevec_init(&pvec, 0);
-	while (index <= end) {
-		nr_pages = pagevec_lookup(&pvec, mapping, index, PAGEVEC_SIZE);
-		if (nr_pages == 0)
-			break;
-		for (i = 0; i < nr_pages; i++) {
-			struct page *page = pvec.pages[i];
-			if (page->index > end)
-				break;
-			BUG_ON(!PageLocked(page));
-			BUG_ON(PageWriteback(page));
-			if (invalidate) {
-				block_invalidatepage(page, 0, PAGE_CACHE_SIZE);
-				ClearPageUptodate(page);
-			}
-			unlock_page(page);
+	for_each_pagecache_page(&iter, inode->i_mapping, index, end, page) {
+		BUG_ON(!PageLocked(page));
+		BUG_ON(PageWriteback(page));
+		if (invalidate) {
+			block_invalidatepage(page, 0, PAGE_CACHE_SIZE);
+			ClearPageUptodate(page);
 		}
-		index = pvec.pages[nr_pages - 1]->index + 1;
-		pagevec_release(&pvec);
+		unlock_page(page);
 	}
 }
 
@@ -2209,8 +2197,8 @@ static int mpage_process_page_bufs(struct mpage_da_data *mpd,
  */
 static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 {
-	struct pagevec pvec;
-	int nr_pages, i;
+	struct pagecache_iter iter;
+	struct page *page;
 	struct inode *inode = mpd->inode;
 	struct buffer_head *head, *bh;
 	int bpp_bits = PAGE_CACHE_SHIFT - inode->i_blkbits;
@@ -2224,67 +2212,55 @@ static int mpage_map_and_submit_buffers(struct mpage_da_data *mpd)
 	lblk = start << bpp_bits;
 	pblock = mpd->map.m_pblk;
 
-	pagevec_init(&pvec, 0);
-	while (start <= end) {
-		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, start,
-					  PAGEVEC_SIZE);
-		if (nr_pages == 0)
-			break;
-		for (i = 0; i < nr_pages; i++) {
-			struct page *page = pvec.pages[i];
-
-			if (page->index > end)
-				break;
-			/* Up to 'end' pages must be contiguous */
-			BUG_ON(page->index != start);
-			bh = head = page_buffers(page);
-			do {
-				if (lblk < mpd->map.m_lblk)
-					continue;
-				if (lblk >= mpd->map.m_lblk + mpd->map.m_len) {
-					/*
-					 * Buffer after end of mapped extent.
-					 * Find next buffer in the page to map.
-					 */
-					mpd->map.m_len = 0;
-					mpd->map.m_flags = 0;
-					/*
-					 * FIXME: If dioread_nolock supports
-					 * blocksize < pagesize, we need to make
-					 * sure we add size mapped so far to
-					 * io_end->size as the following call
-					 * can submit the page for IO.
-					 */
-					err = mpage_process_page_bufs(mpd, head,
-								      bh, lblk);
-					pagevec_release(&pvec);
-					if (err > 0)
-						err = 0;
-					return err;
-				}
-				if (buffer_delay(bh)) {
-					clear_buffer_delay(bh);
-					bh->b_blocknr = pblock++;
-				}
-				clear_buffer_unwritten(bh);
-			} while (lblk++, (bh = bh->b_this_page) != head);
-
-			/*
-			 * FIXME: This is going to break if dioread_nolock
-			 * supports blocksize < pagesize as we will try to
-			 * convert potentially unmapped parts of inode.
-			 */
-			mpd->io_submit.io_end->size += PAGE_CACHE_SIZE;
-			/* Page fully mapped - let IO run! */
-			err = mpage_submit_page(mpd, page);
-			if (err < 0) {
-				pagevec_release(&pvec);
+	for_each_pagecache_page(&iter, inode->i_mapping, start, end, page) {
+		/* Up to 'end' pages must be contiguous */
+		BUG_ON(page->index != start);
+		bh = head = page_buffers(page);
+		do {
+			if (lblk < mpd->map.m_lblk)
+				continue;
+			if (lblk >= mpd->map.m_lblk + mpd->map.m_len) {
+				/*
+				 * Buffer after end of mapped extent. Find next
+				 * buffer in the page to map.
+				 */
+				mpd->map.m_len = 0;
+				mpd->map.m_flags = 0;
+				/*
+				 * FIXME: If dioread_nolock supports blocksize <
+				 * pagesize, we need to make sure we add size
+				 * mapped so far to io_end->size as the
+				 * following call can submit the page for IO.
+				 */
+				err = mpage_process_page_bufs(mpd, head,
+							      bh, lblk);
+				pagecache_iter_release(&iter);
+				if (err > 0)
+					err = 0;
 				return err;
 			}
-			start++;
+			if (buffer_delay(bh)) {
+				clear_buffer_delay(bh);
+				bh->b_blocknr = pblock++;
+			}
+			clear_buffer_unwritten(bh);
+		} while (lblk++, (bh = bh->b_this_page) != head);
+
+		/*
+		 * FIXME: This is going to break if dioread_nolock supports
+		 * blocksize < pagesize as we will try to convert potentially
+		 * unmapped parts of inode.
+		 */
+		mpd->io_submit.io_end->size += PAGE_CACHE_SIZE;
+		/* Page fully mapped - let IO run! */
+		err = mpage_submit_page(mpd, page);
+		if (err < 0) {
+			pagecache_iter_release(&iter);
+			return err;
 		}
-		pagevec_release(&pvec);
+		start++;
 	}
+
 	/* Extent fully mapped and matches with page boundary. We are done. */
 	mpd->map.m_len = 0;
 	mpd->map.m_flags = 0;
@@ -2485,13 +2461,10 @@ static int ext4_da_writepages_trans_blocks(struct inode *inode)
 static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 {
 	struct address_space *mapping = mpd->inode->i_mapping;
-	struct pagevec pvec;
-	unsigned int nr_pages;
+	struct pagecache_iter iter;
+	struct page *page;
 	long left = mpd->wbc->nr_to_write;
-	pgoff_t index = mpd->first_page;
-	pgoff_t end = mpd->last_page;
-	int tag;
-	int i, err = 0;
+	int tag, err = 0;
 	int blkbits = mpd->inode->i_blkbits;
 	ext4_lblk_t lblk;
 	struct buffer_head *head;
@@ -2501,81 +2474,59 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
 	else
 		tag = PAGECACHE_TAG_DIRTY;
 
-	pagevec_init(&pvec, 0);
 	mpd->map.m_len = 0;
-	mpd->next_page = index;
-	while (index <= end) {
-		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
-			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
-		if (nr_pages == 0)
-			goto out;
-
-		for (i = 0; i < nr_pages; i++) {
-			struct page *page = pvec.pages[i];
+	mpd->next_page = mpd->first_page;
 
-			/*
-			 * At this point, the page may be truncated or
-			 * invalidated (changing page->mapping to NULL), or
-			 * even swizzled back from swapper_space to tmpfs file
-			 * mapping. However, page->index will not change
-			 * because we have a reference on the page.
-			 */
-			if (page->index > end)
-				goto out;
-
-			/*
-			 * Accumulated enough dirty pages? This doesn't apply
-			 * to WB_SYNC_ALL mode. For integrity sync we have to
-			 * keep going because someone may be concurrently
-			 * dirtying pages, and we might have synced a lot of
-			 * newly appeared dirty pages, but have not synced all
-			 * of the old dirty pages.
-			 */
-			if (mpd->wbc->sync_mode == WB_SYNC_NONE && left <= 0)
-				goto out;
-
-			/* If we can't merge this page, we are done. */
-			if (mpd->map.m_len > 0 && mpd->next_page != page->index)
-				goto out;
+	for_each_pagecache_tag(&iter, mapping, tag, mpd->first_page,
+			       mpd->last_page, page) {
+		/*
+		 * Accumulated enough dirty pages? This doesn't apply to
+		 * WB_SYNC_ALL mode. For integrity sync we have to keep going
+		 * because someone may be concurrently dirtying pages, and we
+		 * might have synced a lot of newly appeared dirty pages, but
+		 * have not synced all of the old dirty pages.
+		 */
+		if (mpd->wbc->sync_mode == WB_SYNC_NONE && left <= 0)
+			break;
 
-			lock_page(page);
-			/*
-			 * If the page is no longer dirty, or its mapping no
-			 * longer corresponds to inode we are writing (which
-			 * means it has been truncated or invalidated), or the
-			 * page is already under writeback and we are not doing
-			 * a data integrity writeback, skip the page
-			 */
-			if (!PageDirty(page) ||
-			    (PageWriteback(page) &&
-			     (mpd->wbc->sync_mode == WB_SYNC_NONE)) ||
-			    unlikely(page->mapping != mapping)) {
-				unlock_page(page);
-				continue;
-			}
+		/* If we can't merge this page, we are done. */
+		if (mpd->map.m_len > 0 && mpd->next_page != page->index)
+			break;
 
-			wait_on_page_writeback(page);
-			BUG_ON(PageWriteback(page));
-
-			if (mpd->map.m_len == 0)
-				mpd->first_page = page->index;
-			mpd->next_page = page->index + 1;
-			/* Add all dirty buffers to mpd */
-			lblk = ((ext4_lblk_t)page->index) <<
-				(PAGE_CACHE_SHIFT - blkbits);
-			head = page_buffers(page);
-			err = mpage_process_page_bufs(mpd, head, head, lblk);
-			if (err <= 0)
-				goto out;
-			err = 0;
-			left--;
+		lock_page(page);
+		/*
+		 * If the page is no longer dirty, or its mapping no longer
+		 * corresponds to inode we are writing (which means it has been
+		 * truncated or invalidated), or the page is already under
+		 * writeback and we are not doing a data integrity writeback,
+		 * skip the page
+		 */
+		if (!PageDirty(page) ||
+		    (PageWriteback(page) &&
+		     (mpd->wbc->sync_mode == WB_SYNC_NONE)) ||
+		    unlikely(page->mapping != mapping)) {
+			unlock_page(page);
+			continue;
 		}
-		pagevec_release(&pvec);
-		cond_resched();
+
+		wait_on_page_writeback(page);
+		BUG_ON(PageWriteback(page));
+
+		if (mpd->map.m_len == 0)
+			mpd->first_page = page->index;
+		mpd->next_page = page->index + 1;
+		/* Add all dirty buffers to mpd */
+		lblk = ((ext4_lblk_t)page->index) <<
+			(PAGE_CACHE_SHIFT - blkbits);
+		head = page_buffers(page);
+		err = mpage_process_page_bufs(mpd, head, head, lblk);
+		if (err <= 0)
+			break;
+		err = 0;
+		left--;
 	}
-	return 0;
-out:
-	pagevec_release(&pvec);
+	pagecache_iter_release(&iter);
+
 	return err;
 }
 
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index b45d391b45..e60d74148d 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -22,10 +22,6 @@ struct pagevec {
 
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec);
-unsigned pagevec_lookup_entries(struct pagevec *pvec,
-				struct address_space *mapping,
-				pgoff_t start, unsigned nr_entries,
-				pgoff_t *indices);
 void pagevec_remove_exceptionals(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
@@ -69,4 +65,67 @@ static inline void pagevec_release(struct pagevec *pvec)
 		__pagevec_release(pvec);
 }
 
+struct pagecache_iter {
+	unsigned	nr;
+	unsigned	idx;
+	pgoff_t		index;
+	struct page	*pages[PAGEVEC_SIZE];
+	pgoff_t		indices[PAGEVEC_SIZE];
+};
+
+static inline void pagecache_iter_init(struct pagecache_iter *iter,
+				       pgoff_t start)
+{
+	iter->nr	= 0;
+	iter->idx	= 0;
+	iter->index	= start;
+}
+
+void __pagecache_iter_release(struct pagecache_iter *iter);
+
+/**
+ * pagecache_iter_release - release cached pages from pagacache_iter
+ *
+ * Must be called if breaking out of for_each_pagecache_page() etc. early - not
+ * needed if pagecache_iter_next() returned NULL and loop terminated normally
+ */
+static inline void pagecache_iter_release(struct pagecache_iter *iter)
+{
+	if (iter->nr)
+		__pagecache_iter_release(iter);
+}
+
+struct page *pagecache_iter_next(struct pagecache_iter *iter,
+				 struct address_space *mapping,
+				 pgoff_t end, pgoff_t *index,
+				 unsigned flags);
+
+#define __pagecache_iter_for_each(_iter, _mapping, _start, _end,	\
+				  _page, _index, _flags)		\
+	for (pagecache_iter_init((_iter), (_start));			\
+	     ((_page) = pagecache_iter_next((_iter), (_mapping),	\
+			(_end), (_index), (_flags)));)
+
+#define for_each_pagecache_page(_iter, _mapping, _start, _end, _page)	\
+	__pagecache_iter_for_each((_iter), (_mapping), (_start), (_end),\
+			(_page), NULL, 0)
+
+#define for_each_pagecache_page_contig(_iter, _mapping, _start, _end, _page)\
+	__pagecache_iter_for_each((_iter), (_mapping), (_start), (_end),\
+			(_page), NULL, RADIX_TREE_ITER_CONTIG)
+
+#define for_each_pagecache_tag(_iter, _mapping, _tag, _start, _end, _page)\
+	__pagecache_iter_for_each((_iter), (_mapping), (_start), (_end),\
+			(_page), NULL, RADIX_TREE_ITER_TAGGED|(_tag))
+
+#define for_each_pagecache_entry(_iter, _mapping, _start, _end, _page, _index)\
+	__pagecache_iter_for_each((_iter), (_mapping), (_start), (_end),\
+			(_page), &(_index), RADIX_TREE_ITER_EXCEPTIONAL)
+
+#define for_each_pagecache_entry_tag(_iter, _mapping, _tag,		\
+				     _start, _end, _page, _index)	\
+	__pagecache_iter_for_each((_iter), (_mapping), (_start), (_end),\
+			(_page), &(_index), RADIX_TREE_ITER_EXCEPTIONAL|\
+			RADIX_TREE_ITER_TAGGED|(_tag))
+
 #endif /* _LINUX_PAGEVEC_H */
diff --git a/mm/filemap.c b/mm/filemap.c
index 81ce03fbc1..11fbc97f8e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -352,35 +352,20 @@ EXPORT_SYMBOL(filemap_flush);
 static int __filemap_fdatawait_range(struct address_space *mapping,
 				     loff_t start_byte, loff_t end_byte)
 {
-	pgoff_t index = start_byte >> PAGE_CACHE_SHIFT;
+	pgoff_t start = start_byte >> PAGE_CACHE_SHIFT;
 	pgoff_t end = end_byte >> PAGE_CACHE_SHIFT;
-	struct pagevec pvec;
-	int nr_pages;
+	struct pagecache_iter iter;
+	struct page *page;
 	int ret = 0;
 
 	if (end_byte < start_byte)
 		goto out;
 
-	pagevec_init(&pvec, 0);
-	while ((index <= end) &&
-			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
-			PAGECACHE_TAG_WRITEBACK,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1)) != 0) {
-		unsigned i;
-
-		for (i = 0; i < nr_pages; i++) {
-			struct page *page = pvec.pages[i];
-
-			/* until radix tree lookup accepts end_index */
-			if (page->index > end)
-				continue;
-
-			wait_on_page_writeback(page);
-			if (TestClearPageError(page))
-				ret = -EIO;
-		}
-		pagevec_release(&pvec);
-		cond_resched();
+	for_each_pagecache_tag(&iter, mapping, PAGECACHE_TAG_WRITEBACK,
+			       start, end, page) {
+		wait_on_page_writeback(page);
+		if (TestClearPageError(page))
+			ret = -EIO;
 	}
 out:
 	return ret;
@@ -1315,6 +1300,51 @@ no_entry:
 }
 EXPORT_SYMBOL(__find_get_pages);
 
+void __pagecache_iter_release(struct pagecache_iter *iter)
+{
+	lru_add_drain();
+	release_pages(iter->pages, iter->nr, 0);
+	iter->nr	= 0;
+	iter->idx	= 0;
+}
+EXPORT_SYMBOL(__pagecache_iter_release);
+
+/**
+ * pagecache_iter_next - get next page from pagecache iterator and advance
+ * iterator
+ * @iter:	The iterator to advance
+ * @mapping:	The address_space to search
+ * @end:	Page cache index to stop at (inclusive)
+ * @index:	if non NULL, index of page or entry will be returned here
+ * @flags:	radix tree iter flags and tag for __find_get_pages()
+ */
+struct page *pagecache_iter_next(struct pagecache_iter *iter,
+				 struct address_space *mapping,
+				 pgoff_t end, pgoff_t *index,
+				 unsigned flags)
+{
+	struct page *page;
+
+	if (iter->idx >= iter->nr) {
+		pagecache_iter_release(iter);
+		cond_resched();
+
+		iter->nr = __find_get_pages(mapping, iter->index, end,
+					    PAGEVEC_SIZE, iter->pages,
+					    iter->indices, flags);
+		if (!iter->nr)
+			return NULL;
+	}
+
+	iter->index	= iter->indices[iter->idx] + 1;
+	if (index)
+		*index	= iter->indices[iter->idx];
+	page		= iter->pages[iter->idx];
+	iter->idx++;
+	return page;
+}
+EXPORT_SYMBOL(pagecache_iter_next);
+
 /*
  * CD/DVDs are error prone. When a medium error occurs, the driver may fail
  * a _large_ part of the i/o request. Imagine the worst scenario:
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 11ff8f7586..2eb2e93313 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2154,10 +2154,10 @@ int write_cache_pages(struct address_space *mapping,
 		      struct writeback_control *wbc, writepage_t writepage,
 		      void *data)
 {
+	struct pagecache_iter iter;
+	struct page *page;
 	int ret = 0;
 	int done = 0;
-	struct pagevec pvec;
-	int nr_pages;
 	pgoff_t uninitialized_var(writeback_index);
 	pgoff_t index;
 	pgoff_t end;		/* Inclusive */
@@ -2166,7 +2166,6 @@ int write_cache_pages(struct address_space *mapping,
 	int range_whole = 0;
 	int tag;
 
-	pagevec_init(&pvec, 0);
 	if (wbc->range_cyclic) {
 		writeback_index = mapping->writeback_index; /* prev offset */
 		index = writeback_index;
@@ -2189,105 +2188,80 @@ int write_cache_pages(struct address_space *mapping,
 retry:
 	if (wbc->sync_mode == WB_SYNC_ALL || wbc->tagged_writepages)
 		tag_pages_for_writeback(mapping, index, end);
-	done_index = index;
-	while (!done && (index <= end)) {
-		int i;
-
-		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index, tag,
-			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
-		if (nr_pages == 0)
-			break;
 
-		for (i = 0; i < nr_pages; i++) {
-			struct page *page = pvec.pages[i];
-
-			/*
-			 * At this point, the page may be truncated or
-			 * invalidated (changing page->mapping to NULL), or
-			 * even swizzled back from swapper_space to tmpfs file
-			 * mapping. However, page->index will not change
-			 * because we have a reference on the page.
-			 */
-			if (page->index > end) {
-				/*
-				 * can't be range_cyclic (1st pass) because
-				 * end == -1 in that case.
-				 */
-				done = 1;
-				break;
-			}
+	done_index = index;
 
-			done_index = page->index;
+	for_each_pagecache_tag(&iter, mapping, tag, index, end, page) {
+		done_index = page->index;
 
-			lock_page(page);
+		lock_page(page);
 
-			/*
-			 * Page truncated or invalidated. We can freely skip it
-			 * then, even for data integrity operations: the page
-			 * has disappeared concurrently, so there could be no
-			 * real expectation of this data interity operation
-			 * even if there is now a new, dirty page at the same
-			 * pagecache address.
-			 */
-			if (unlikely(page->mapping != mapping)) {
+		/*
+		 * Page truncated or invalidated. We can freely skip it
+		 * then, even for data integrity operations: the page
+		 * has disappeared concurrently, so there could be no
+		 * real expectation of this data interity operation
+		 * even if there is now a new, dirty page at the same
+		 * pagecache address.
+		 */
+		if (unlikely(page->mapping != mapping)) {
 continue_unlock:
-				unlock_page(page);
-				continue;
-			}
-
-			if (!PageDirty(page)) {
-				/* someone wrote it for us */
-				goto continue_unlock;
-			}
+			unlock_page(page);
+			continue;
+		}
 
-			if (PageWriteback(page)) {
-				if (wbc->sync_mode != WB_SYNC_NONE)
-					wait_on_page_writeback(page);
-				else
-					goto continue_unlock;
-			}
+		if (!PageDirty(page)) {
+			/* someone wrote it for us */
+			goto continue_unlock;
+		}
 
-			BUG_ON(PageWriteback(page));
-			if (!clear_page_dirty_for_io(page))
+		if (PageWriteback(page)) {
+			if (wbc->sync_mode != WB_SYNC_NONE)
+				wait_on_page_writeback(page);
+			else
 				goto continue_unlock;
+		}
 
-			trace_wbc_writepage(wbc, inode_to_bdi(mapping->host));
-			ret = (*writepage)(page, wbc, data);
-			if (unlikely(ret)) {
-				if (ret == AOP_WRITEPAGE_ACTIVATE) {
-					unlock_page(page);
-					ret = 0;
-				} else {
-					/*
-					 * done_index is set past this page,
-					 * so media errors will not choke
-					 * background writeout for the entire
-					 * file. This has consequences for
-					 * range_cyclic semantics (ie. it may
-					 * not be suitable for data integrity
-					 * writeout).
-					 */
-					done_index = page->index + 1;
-					done = 1;
-					break;
-				}
-			}
+		BUG_ON(PageWriteback(page));
+		if (!clear_page_dirty_for_io(page))
+			goto continue_unlock;
 
-			/*
-			 * We stop writing back only if we are not doing
-			 * integrity sync. In case of integrity sync we have to
-			 * keep going until we have written all the pages
-			 * we tagged for writeback prior to entering this loop.
-			 */
-			if (--wbc->nr_to_write <= 0 &&
-			    wbc->sync_mode == WB_SYNC_NONE) {
+		trace_wbc_writepage(wbc, inode_to_bdi(mapping->host));
+		ret = (*writepage)(page, wbc, data);
+		if (unlikely(ret)) {
+			if (ret == AOP_WRITEPAGE_ACTIVATE) {
+				unlock_page(page);
+				ret = 0;
+			} else {
+				/*
+				 * done_index is set past this page,
+				 * so media errors will not choke
+				 * background writeout for the entire
+				 * file. This has consequences for
+				 * range_cyclic semantics (ie. it may
+				 * not be suitable for data integrity
+				 * writeout).
+				 */
+				done_index = page->index + 1;
 				done = 1;
 				break;
 			}
 		}
-		pagevec_release(&pvec);
-		cond_resched();
+
+		/*
+		 * We stop writing back only if we are not doing
+		 * integrity sync. In case of integrity sync we have to
+		 * keep going until we have written all the pages
+		 * we tagged for writeback prior to entering this loop.
+		 */
+		if (--wbc->nr_to_write <= 0 &&
+		    wbc->sync_mode == WB_SYNC_NONE) {
+			done = 1;
+			break;
+		}
 	}
+	pagecache_iter_release(&iter);
+
 	if (!cycled && !done) {
 		/*
 		 * range_cyclic:
diff --git a/mm/swap.c b/mm/swap.c
index 09fe5e9771..f48cedeb1c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -718,6 +718,9 @@ void release_pages(struct page **pages, int nr, bool cold)
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
+		if (radix_tree_exceptional_entry(page))
+			continue;
+
 		/*
 		 * Make sure the IRQ-safe lock-holding time does not get
 		 * excessive with a continuous string of pages from the
@@ -857,36 +860,6 @@ void __pagevec_lru_add(struct pagevec *pvec)
 EXPORT_SYMBOL(__pagevec_lru_add);
 
 /**
- * pagevec_lookup_entries - gang pagecache lookup
- * @pvec:	Where the resulting entries are placed
- * @mapping:	The address_space to search
- * @start:	The starting entry index
- * @nr_entries:	The maximum number of entries
- * @indices:	The cache indices corresponding to the entries in @pvec
- *
- * pagevec_lookup_entries() will search for and return a group of up
- * to @nr_entries pages and shadow entries in the mapping.  All
- * entries are placed in @pvec.  pagevec_lookup_entries() takes a
- * reference against actual pages in @pvec.
- *
- * The search returns a group of mapping-contiguous entries with
- * ascending indexes.  There may be holes in the indices due to
- * not-present entries.
- *
- * pagevec_lookup_entries() returns the number of entries which were
- * found.
- */
-unsigned pagevec_lookup_entries(struct pagevec *pvec,
-				struct address_space *mapping,
-				pgoff_t start, unsigned nr_pages,
-				pgoff_t *indices)
-{
-	pvec->nr = find_get_entries(mapping, start, nr_pages,
-				    pvec->pages, indices);
-	return pagevec_count(pvec);
-}
-
-/**
  * pagevec_remove_exceptionals - pagevec exceptionals pruning
  * @pvec:	The pagevec to prune
  *
diff --git a/mm/truncate.c b/mm/truncate.c
index 7598b552ae..dca55e4b97 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -231,10 +231,10 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	pgoff_t		end;		/* exclusive */
 	unsigned int	partial_start;	/* inclusive */
 	unsigned int	partial_end;	/* exclusive */
-	struct pagevec	pvec;
-	pgoff_t		indices[PAGEVEC_SIZE];
-	pgoff_t		index;
-	int		i;
+	struct pagecache_iter iter;
+	struct page *page;
+	pgoff_t index;
+	bool found;
 
 	cleancache_invalidate_inode(mapping);
 	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
@@ -250,51 +250,36 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	 * start of the range and 'partial_end' at the end of the range.
 	 * Note that 'end' is exclusive while 'lend' is inclusive.
 	 */
-	start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	start = round_up(lstart, PAGE_CACHE_SIZE) >> PAGE_CACHE_SHIFT;
 	if (lend == -1)
 		/*
-		 * lend == -1 indicates end-of-file so we have to set 'end'
-		 * to the highest possible pgoff_t and since the type is
-		 * unsigned we're using -1.
+		 * lend == -1 indicates end-of-file so we have to set 'end' to
+		 * the highest possible pgoff_t
 		 */
-		end = -1;
+		end = ULONG_MAX;
 	else
 		end = (lend + 1) >> PAGE_CACHE_SHIFT;
 
-	pagevec_init(&pvec, 0);
-	index = start;
-	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE),
-			indices)) {
-		for (i = 0; i < pagevec_count(&pvec); i++) {
-			struct page *page = pvec.pages[i];
-
-			/* We rely upon deletion not changing page->index */
-			index = indices[i];
-			if (index >= end)
-				break;
+	if (start >= end)
+		goto do_partial;
 
-			if (radix_tree_exceptional_entry(page)) {
-				clear_exceptional_entry(mapping, index, page);
-				continue;
-			}
+	for_each_pagecache_entry(&iter, mapping, start, end - 1, page, index) {
+		if (radix_tree_exceptional_entry(page)) {
+			clear_exceptional_entry(mapping, index, page);
+			continue;
+		}
 
-			if (!trylock_page(page))
-				continue;
-			WARN_ON(page->index != index);
-			if (PageWriteback(page)) {
-				unlock_page(page);
-				continue;
-			}
-			truncate_inode_page(mapping, page);
+		if (!trylock_page(page))
+			continue;
+		WARN_ON(page->index != index);
+		if (PageWriteback(page)) {
 			unlock_page(page);
+			continue;
 		}
-		pagevec_remove_exceptionals(&pvec);
-		pagevec_release(&pvec);
-		cond_resched();
-		index++;
+		truncate_inode_page(mapping, page);
+		unlock_page(page);
 	}
-
+do_partial:
 	if (partial_start) {
 		struct page *page = find_lock_page(mapping, start - 1);
 		if (page) {
@@ -334,34 +319,12 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	if (start >= end)
 		return;
 
-	index = start;
-	for ( ; ; ) {
-		cond_resched();
-		if (!pagevec_lookup_entries(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE), indices)) {
-			/* If all gone from start onwards, we're done */
-			if (index == start)
-				break;
-			/* Otherwise restart to make sure all gone */
-			index = start;
-			continue;
-		}
-		if (index == start && indices[0] >= end) {
-			/* All gone out of hole to be punched, we're done */
-			pagevec_remove_exceptionals(&pvec);
-			pagevec_release(&pvec);
-			break;
-		}
-		for (i = 0; i < pagevec_count(&pvec); i++) {
-			struct page *page = pvec.pages[i];
-
-			/* We rely upon deletion not changing page->index */
-			index = indices[i];
-			if (index >= end) {
-				/* Restart punch to make sure all gone */
-				index = start - 1;
-				break;
-			}
+	do {
+		found = false;
+
+		for_each_pagecache_entry(&iter, mapping, start,
+					 end - 1, page, index) {
+			found = true;
 
 			if (radix_tree_exceptional_entry(page)) {
 				clear_exceptional_entry(mapping, index, page);
@@ -374,10 +337,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
-		pagevec_remove_exceptionals(&pvec);
-		pagevec_release(&pvec);
-		index++;
-	}
+	} while (found);
+
 	cleancache_invalidate_inode(mapping);
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
@@ -463,48 +424,32 @@ EXPORT_SYMBOL(truncate_inode_pages_final);
 unsigned long invalidate_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t end)
 {
-	pgoff_t indices[PAGEVEC_SIZE];
-	struct pagevec pvec;
-	pgoff_t index = start;
+	struct pagecache_iter iter;
+	struct page *page;
+	pgoff_t index;
 	unsigned long ret;
 	unsigned long count = 0;
-	int i;
-
-	pagevec_init(&pvec, 0);
-	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
-			indices)) {
-		for (i = 0; i < pagevec_count(&pvec); i++) {
-			struct page *page = pvec.pages[i];
 
-			/* We rely upon deletion not changing page->index */
-			index = indices[i];
-			if (index > end)
-				break;
-
-			if (radix_tree_exceptional_entry(page)) {
-				clear_exceptional_entry(mapping, index, page);
-				continue;
-			}
-
-			if (!trylock_page(page))
-				continue;
-			WARN_ON(page->index != index);
-			ret = invalidate_inode_page(page);
-			unlock_page(page);
-			/*
-			 * Invalidation is a hint that the page is no longer
-			 * of interest and try to speed up its reclaim.
-			 */
-			if (!ret)
-				deactivate_file_page(page);
-			count += ret;
+	for_each_pagecache_entry(&iter, mapping, start, end, page, index) {
+		if (radix_tree_exceptional_entry(page)) {
+			clear_exceptional_entry(mapping, index, page);
+			continue;
 		}
-		pagevec_remove_exceptionals(&pvec);
-		pagevec_release(&pvec);
-		cond_resched();
-		index++;
+
+		if (!trylock_page(page))
+			continue;
+		WARN_ON(page->index != index);
+		ret = invalidate_inode_page(page);
+		unlock_page(page);
+		/*
+		 * Invalidation is a hint that the page is no longer
+		 * of interest and try to speed up its reclaim.
+		 */
+		if (!ret)
+			deactivate_file_page(page);
+		count += ret;
 	}
+
 	return count;
 }
 EXPORT_SYMBOL(invalidate_mapping_pages);
@@ -568,75 +513,59 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
 int invalidate_inode_pages2_range(struct address_space *mapping,
 				  pgoff_t start, pgoff_t end)
 {
-	pgoff_t indices[PAGEVEC_SIZE];
-	struct pagevec pvec;
+	struct pagecache_iter iter;
+	struct page *page;
 	pgoff_t index;
-	int i;
 	int ret = 0;
 	int ret2 = 0;
 	int did_range_unmap = 0;
 
 	cleancache_invalidate_inode(mapping);
-	pagevec_init(&pvec, 0);
-	index = start;
-	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
-			indices)) {
-		for (i = 0; i < pagevec_count(&pvec); i++) {
-			struct page *page = pvec.pages[i];
-
-			/* We rely upon deletion not changing page->index */
-			index = indices[i];
-			if (index > end)
-				break;
 
-			if (radix_tree_exceptional_entry(page)) {
-				clear_exceptional_entry(mapping, index, page);
-				continue;
-			}
+	for_each_pagecache_entry(&iter, mapping, start, end, page, index) {
+		if (radix_tree_exceptional_entry(page)) {
+			clear_exceptional_entry(mapping, index, page);
+			continue;
+		}
 
-			lock_page(page);
-			WARN_ON(page->index != index);
-			if (page->mapping != mapping) {
-				unlock_page(page);
-				continue;
-			}
-			wait_on_page_writeback(page);
-			if (page_mapped(page)) {
-				if (!did_range_unmap) {
-					/*
-					 * Zap the rest of the file in one hit.
-					 */
-					unmap_mapping_range(mapping,
-					   (loff_t)index << PAGE_CACHE_SHIFT,
-					   (loff_t)(1 + end - index)
-							 << PAGE_CACHE_SHIFT,
-					    0);
-					did_range_unmap = 1;
-				} else {
-					/*
-					 * Just zap this page
-					 */
-					unmap_mapping_range(mapping,
-					   (loff_t)index << PAGE_CACHE_SHIFT,
-					   PAGE_CACHE_SIZE, 0);
-				}
-			}
-			BUG_ON(page_mapped(page));
-			ret2 = do_launder_page(mapping, page);
-			if (ret2 == 0) {
-				if (!invalidate_complete_page2(mapping, page))
-					ret2 = -EBUSY;
-			}
-			if (ret2 < 0)
-				ret = ret2;
+		lock_page(page);
+		WARN_ON(page->index != index);
+		if (page->mapping != mapping) {
 			unlock_page(page);
+			continue;
 		}
-		pagevec_remove_exceptionals(&pvec);
-		pagevec_release(&pvec);
-		cond_resched();
-		index++;
+		wait_on_page_writeback(page);
+		if (page_mapped(page)) {
+			if (!did_range_unmap) {
+				/*
+				 * Zap the rest of the file in one hit.
+				 */
+				unmap_mapping_range(mapping,
+				   (loff_t)index << PAGE_CACHE_SHIFT,
+				   (loff_t)(1 + end - index)
+						 << PAGE_CACHE_SHIFT,
+				    0);
+				did_range_unmap = 1;
+			} else {
+				/*
+				 * Just zap this page
+				 */
+				unmap_mapping_range(mapping,
+				   (loff_t)index << PAGE_CACHE_SHIFT,
+				   PAGE_CACHE_SIZE, 0);
+			}
+		}
+		BUG_ON(page_mapped(page));
+		ret2 = do_launder_page(mapping, page);
+		if (ret2 == 0) {
+			if (!invalidate_complete_page2(mapping, page))
+				ret2 = -EBUSY;
+		}
+		if (ret2 < 0)
+			ret = ret2;
+		unlock_page(page);
 	}
+
 	cleancache_invalidate_inode(mapping);
 	return ret;
 }
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F88F6B0294
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z11-v6so6701409pfn.1
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c16-v6si12988657pli.269.2018.06.16.19.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:36 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 67/74] dax: Convert dax writeback to XArray
Date: Sat, 16 Jun 2018 19:00:45 -0700
Message-Id: <20180617020052.4759-68-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Use XArray iteration instead of a pagevec.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 fs/dax.c | 130 ++++++++++++++++++++++++++-----------------------------
 1 file changed, 62 insertions(+), 68 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index fe5cc4470d99..08595ffde566 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -973,11 +973,9 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
 	i_mmap_unlock_read(mapping);
 }
 
-static int dax_writeback_one(struct dax_device *dax_dev,
-		struct address_space *mapping, pgoff_t index, void *entry)
+static int dax_writeback_one(struct xa_state *xas, struct dax_device *dax_dev,
+		struct address_space *mapping, void *entry)
 {
-	struct radix_tree_root *pages = &mapping->i_pages;
-	void *entry2, **slot;
 	unsigned long pfn;
 	long ret = 0;
 	size_t size;
@@ -989,29 +987,35 @@ static int dax_writeback_one(struct dax_device *dax_dev,
 	if (WARN_ON(!xa_is_value(entry)))
 		return -EIO;
 
-	xa_lock_irq(pages);
-	entry2 = get_unlocked_mapping_entry(mapping, index, &slot);
-	/* Entry got punched out / reallocated? */
-	if (!entry2 || WARN_ON_ONCE(!xa_is_value(entry2)))
-		goto put_unlocked;
-	/*
-	 * Entry got reallocated elsewhere? No need to writeback. We have to
-	 * compare pfns as we must not bail out due to difference in lockbit
-	 * or entry type.
-	 */
-	if (dax_to_pfn(entry2) != dax_to_pfn(entry))
-		goto put_unlocked;
-	if (WARN_ON_ONCE(dax_is_empty_entry(entry) ||
-				dax_is_zero_entry(entry))) {
-		ret = -EIO;
-		goto put_unlocked;
+	if (unlikely(dax_is_locked(entry))) {
+		void *old_entry = entry;
+
+		entry = get_unlocked_entry(xas);
+
+		/* Entry got punched out / reallocated? */
+		if (!entry || WARN_ON_ONCE(!xa_is_value(entry)))
+			goto put_unlocked;
+		/*
+		 * Entry got reallocated elsewhere? No need to writeback.
+		 * We have to compare pfns as we must not bail out due to
+		 * difference in lockbit or entry type.
+		 */
+		if (dax_to_pfn(old_entry) != dax_to_pfn(entry))
+			goto put_unlocked;
+		if (WARN_ON_ONCE(dax_is_empty_entry(entry) ||
+					dax_is_zero_entry(entry))) {
+			ret = -EIO;
+			goto put_unlocked;
+		}
+
+		/* Another fsync thread may have already done this entry */
+		if (!xas_get_tag(xas, PAGECACHE_TAG_TOWRITE))
+			goto put_unlocked;
 	}
 
-	/* Another fsync thread may have already written back this entry */
-	if (!radix_tree_tag_get(pages, index, PAGECACHE_TAG_TOWRITE))
-		goto put_unlocked;
 	/* Lock the entry to serialize with page faults */
-	entry = lock_slot(mapping, slot);
+	dax_lock_entry(xas, entry);
+
 	/*
 	 * We can clear the tag now but we have to be careful so that concurrent
 	 * dax_writeback_one() calls for the same index cannot finish before we
@@ -1019,8 +1023,8 @@ static int dax_writeback_one(struct dax_device *dax_dev,
 	 * at the entry only under the i_pages lock and once they do that
 	 * they will see the entry locked and wait for it to unlock.
 	 */
-	radix_tree_tag_clear(pages, index, PAGECACHE_TAG_TOWRITE);
-	xa_unlock_irq(pages);
+	xas_clear_tag(xas, PAGECACHE_TAG_TOWRITE);
+	xas_unlock_irq(xas);
 
 	/*
 	 * Even if dax_writeback_mapping_range() was given a wbc->range_start
@@ -1032,7 +1036,7 @@ static int dax_writeback_one(struct dax_device *dax_dev,
 	pfn = dax_to_pfn(entry);
 	size = PAGE_SIZE << dax_entry_order(entry);
 
-	dax_entry_mkclean(mapping, index, pfn);
+	dax_entry_mkclean(mapping, xas->xa_index, pfn);
 	dax_flush(dax_dev, page_address(pfn_to_page(pfn)), size);
 	/*
 	 * After we have flushed the cache, we can clear the dirty tag. There
@@ -1040,16 +1044,18 @@ static int dax_writeback_one(struct dax_device *dax_dev,
 	 * the pfn mappings are writeprotected and fault waits for mapping
 	 * entry lock.
 	 */
-	xa_lock_irq(pages);
-	radix_tree_tag_clear(pages, index, PAGECACHE_TAG_DIRTY);
-	xa_unlock_irq(pages);
-	trace_dax_writeback_one(mapping->host, index, size >> PAGE_SHIFT);
-	put_locked_mapping_entry(mapping, index);
+	xas_reset(xas);
+	xas_lock_irq(xas);
+	xas_store(xas, entry);
+	xas_clear_tag(xas, PAGECACHE_TAG_DIRTY);
+	dax_wake_entry(xas, entry, false);
+
+	trace_dax_writeback_one(mapping->host, xas->xa_index,
+			size >> PAGE_SHIFT);
 	return ret;
 
  put_unlocked:
-	put_unlocked_mapping_entry(mapping, index, entry2);
-	xa_unlock_irq(pages);
+	put_unlocked_entry(xas, entry);
 	return ret;
 }
 
@@ -1061,13 +1067,13 @@ static int dax_writeback_one(struct dax_device *dax_dev,
 int dax_writeback_mapping_range(struct address_space *mapping,
 		struct block_device *bdev, struct writeback_control *wbc)
 {
+	XA_STATE(xas, &mapping->i_pages, wbc->range_start >> PAGE_SHIFT);
 	struct inode *inode = mapping->host;
-	pgoff_t start_index, end_index;
-	pgoff_t indices[PAGEVEC_SIZE];
+	pgoff_t end_index = wbc->range_end >> PAGE_SHIFT;
 	struct dax_device *dax_dev;
-	struct pagevec pvec;
-	bool done = false;
-	int i, ret = 0;
+	void *entry;
+	int ret = 0;
+	unsigned int scanned = 0;
 
 	if (WARN_ON_ONCE(inode->i_blkbits != PAGE_SHIFT))
 		return -EIO;
@@ -1079,41 +1085,29 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 	if (!dax_dev)
 		return -EIO;
 
-	start_index = wbc->range_start >> PAGE_SHIFT;
-	end_index = wbc->range_end >> PAGE_SHIFT;
-
-	trace_dax_writeback_range(inode, start_index, end_index);
-
-	tag_pages_for_writeback(mapping, start_index, end_index);
+	trace_dax_writeback_range(inode, xas.xa_index, end_index);
 
-	pagevec_init(&pvec);
-	while (!done) {
-		pvec.nr = find_get_entries_tag(mapping, start_index,
-				PAGECACHE_TAG_TOWRITE, PAGEVEC_SIZE,
-				pvec.pages, indices);
+	tag_pages_for_writeback(mapping, xas.xa_index, end_index);
 
-		if (pvec.nr == 0)
+	xas_lock_irq(&xas);
+	xas_for_each_tagged(&xas, entry, end_index, PAGECACHE_TAG_TOWRITE) {
+		ret = dax_writeback_one(&xas, dax_dev, mapping, entry);
+		if (ret < 0) {
+			mapping_set_error(mapping, ret);
 			break;
-
-		for (i = 0; i < pvec.nr; i++) {
-			if (indices[i] > end_index) {
-				done = true;
-				break;
-			}
-
-			ret = dax_writeback_one(dax_dev, mapping, indices[i],
-					pvec.pages[i]);
-			if (ret < 0) {
-				mapping_set_error(mapping, ret);
-				goto out;
-			}
 		}
-		start_index = indices[pvec.nr - 1] + 1;
+		if (++scanned % XA_CHECK_SCHED)
+			continue;
+
+		xas_pause(&xas);
+		xas_unlock_irq(&xas);
+		cond_resched();
+		xas_lock_irq(&xas);
 	}
-out:
+	xas_unlock_irq(&xas);
 	put_dax(dax_dev);
-	trace_dax_writeback_range_done(inode, start_index, end_index);
-	return (ret < 0 ? ret : 0);
+	trace_dax_writeback_range_done(inode, xas.xa_index, end_index);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(dax_writeback_mapping_range);
 
-- 
2.17.1

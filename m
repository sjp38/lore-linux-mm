Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 842B56B0023
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:13:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 61-v6so7586051plz.20
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:13:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 89-v6si7772056pla.572.2018.04.14.07.13.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:28 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 17/63] page cache: Convert hole search to XArray
Date: Sat, 14 Apr 2018 07:12:30 -0700
Message-Id: <20180414141316.7167-18-willy@infradead.org>
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The page cache offers the ability to search for a miss in the previous or
next N locations.  Rather than teach the XArray about the page cache's
definition of a miss, use xas_prev() and xas_next() to search the page
array.  This should be more efficient as it does not have to start the
lookup from the top for each index.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/nfs/blocklayout/blocklayout.c |   2 +-
 include/linux/pagemap.h          |   4 +-
 mm/filemap.c                     | 110 ++++++++++++++-----------------
 mm/readahead.c                   |   4 +-
 4 files changed, 55 insertions(+), 65 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 7cb5c38c19e4..961901685007 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -895,7 +895,7 @@ static u64 pnfs_num_cont_bytes(struct inode *inode, pgoff_t idx)
 	end = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
 	if (end != inode->i_mapping->nrpages) {
 		rcu_read_lock();
-		end = page_cache_next_hole(mapping, idx + 1, ULONG_MAX);
+		end = page_cache_next_gap(mapping, idx + 1, ULONG_MAX);
 		rcu_read_unlock();
 	}
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index b1bd2186e6d2..2f5d2d3ebaac 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -241,9 +241,9 @@ static inline gfp_t readahead_gfp_mask(struct address_space *x)
 
 typedef int filler_t(void *, struct page *);
 
-pgoff_t page_cache_next_hole(struct address_space *mapping,
+pgoff_t page_cache_next_gap(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan);
-pgoff_t page_cache_prev_hole(struct address_space *mapping,
+pgoff_t page_cache_prev_gap(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan);
 
 #define FGP_ACCESSED		0x00000001
diff --git a/mm/filemap.c b/mm/filemap.c
index 82c8b14f77d3..f692000b0729 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1326,86 +1326,76 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 }
 
 /**
- * page_cache_next_hole - find the next hole (not-present entry)
- * @mapping: mapping
- * @index: index
- * @max_scan: maximum range to search
- *
- * Search the set [index, min(index+max_scan-1, MAX_INDEX)] for the
- * lowest indexed hole.
- *
- * Returns: the index of the hole if found, otherwise returns an index
- * outside of the set specified (in which case 'return - index >=
- * max_scan' will be true). In rare cases of index wrap-around, 0 will
- * be returned.
- *
- * page_cache_next_hole may be called under rcu_read_lock. However,
- * like radix_tree_gang_lookup, this will not atomically search a
- * snapshot of the tree at a single point in time. For example, if a
- * hole is created at index 5, then subsequently a hole is created at
- * index 10, page_cache_next_hole covering both indexes may return 10
- * if called under rcu_read_lock.
+ * page_cache_next_gap() - Find the next gap in the page cache.
+ * @mapping: Mapping.
+ * @index: Index.
+ * @max_scan: Maximum range to search.
+ *
+ * Search the range [index, min(index + max_scan - 1, ULONG_MAX)] for the
+ * gap with the lowest index.
+ *
+ * This function may be called under the rcu_read_lock.  However, this will
+ * not atomically search a snapshot of the cache at a single point in time.
+ * For example, if a gap is created at index 5, then subsequently a gap is
+ * created at index 10, page_cache_next_gap covering both indices may
+ * return 10 if called under the rcu_read_lock.
+ *
+ * Return: The index of the gap if found, otherwise an index outside the
+ * range specified (in which case 'return - index >= max_scan' will be true).
+ * In the rare case of index wrap-around, 0 will be returned.
  */
-pgoff_t page_cache_next_hole(struct address_space *mapping,
+pgoff_t page_cache_next_gap(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan)
 {
-	unsigned long i;
+	XA_STATE(xas, &mapping->i_pages, index);
 
-	for (i = 0; i < max_scan; i++) {
-		struct page *page;
-
-		page = radix_tree_lookup(&mapping->i_pages, index);
-		if (!page || xa_is_value(page))
+	while (max_scan--) {
+		void *entry = xas_next(&xas);
+		if (!entry || xa_is_value(entry))
 			break;
-		index++;
-		if (index == 0)
+		if (xas.xa_index == 0)
 			break;
 	}
 
-	return index;
+	return xas.xa_index;
 }
-EXPORT_SYMBOL(page_cache_next_hole);
+EXPORT_SYMBOL(page_cache_next_gap);
 
 /**
- * page_cache_prev_hole - find the prev hole (not-present entry)
- * @mapping: mapping
- * @index: index
- * @max_scan: maximum range to search
- *
- * Search backwards in the range [max(index-max_scan+1, 0), index] for
- * the first hole.
- *
- * Returns: the index of the hole if found, otherwise returns an index
- * outside of the set specified (in which case 'index - return >=
- * max_scan' will be true). In rare cases of wrap-around, ULONG_MAX
- * will be returned.
- *
- * page_cache_prev_hole may be called under rcu_read_lock. However,
- * like radix_tree_gang_lookup, this will not atomically search a
- * snapshot of the tree at a single point in time. For example, if a
- * hole is created at index 10, then subsequently a hole is created at
- * index 5, page_cache_prev_hole covering both indexes may return 5 if
- * called under rcu_read_lock.
+ * page_cache_prev_gap() - Find the next gap in the page cache.
+ * @mapping: Mapping.
+ * @index: Index.
+ * @max_scan: Maximum range to search.
+ *
+ * Search the range [max(index - max_scan + 1, 0), index] for the
+ * gap with the highest index.
+ *
+ * This function may be called under the rcu_read_lock.  However, this will
+ * not atomically search a snapshot of the cache at a single point in time.
+ * For example, if a gap is created at index 10, then subsequently a gap is
+ * created at index 5, page_cache_prev_gap() covering both indices may
+ * return 5 if called under the rcu_read_lock.
+ *
+ * Return: The index of the gap if found, otherwise an index outside the
+ * range specified (in which case 'index - return >= max_scan' will be true).
+ * In the rare case of wrap-around, ULONG_MAX will be returned.
  */
-pgoff_t page_cache_prev_hole(struct address_space *mapping,
+pgoff_t page_cache_prev_gap(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan)
 {
-	unsigned long i;
-
-	for (i = 0; i < max_scan; i++) {
-		struct page *page;
+	XA_STATE(xas, &mapping->i_pages, index);
 
-		page = radix_tree_lookup(&mapping->i_pages, index);
-		if (!page || xa_is_value(page))
+	while (max_scan--) {
+		void *entry = xas_prev(&xas);
+		if (!entry || xa_is_value(entry))
 			break;
-		index--;
-		if (index == ULONG_MAX)
+		if (xas.xa_index == ULONG_MAX)
 			break;
 	}
 
-	return index;
+	return xas.xa_index;
 }
-EXPORT_SYMBOL(page_cache_prev_hole);
+EXPORT_SYMBOL(page_cache_prev_gap);
 
 /**
  * find_get_entry - find and get a page cache entry
diff --git a/mm/readahead.c b/mm/readahead.c
index 3ac9ca63f686..c7ddcf60ac6d 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -329,7 +329,7 @@ static pgoff_t count_history_pages(struct address_space *mapping,
 	pgoff_t head;
 
 	rcu_read_lock();
-	head = page_cache_prev_hole(mapping, offset - 1, max);
+	head = page_cache_prev_gap(mapping, offset - 1, max);
 	rcu_read_unlock();
 
 	return offset - 1 - head;
@@ -417,7 +417,7 @@ ondemand_readahead(struct address_space *mapping,
 		pgoff_t start;
 
 		rcu_read_lock();
-		start = page_cache_next_hole(mapping, offset + 1, max_pages);
+		start = page_cache_next_gap(mapping, offset + 1, max_pages);
 		rcu_read_unlock();
 
 		if (!start || start - offset > max_pages)
-- 
2.17.0

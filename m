Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id B45436B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 20:16:48 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id x188so25883422pfb.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 17:16:48 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id qc8si9569pac.39.2016.03.08.17.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 17:16:47 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id bj10so25167182pad.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 17:16:47 -0800 (PST)
Date: Tue, 8 Mar 2016 16:16:43 -0900
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH] mm: Refactor find_get_pages() & friends
Message-ID: <20160309011643.GA23179@kmo-pixel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Collapse redundant implementations of various gang pagecache lookup - this is
also prep work for pagecache iterator work

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/pagemap.h    | 142 +++++++++++++++++--
 include/linux/radix-tree.h |  49 ++-----
 mm/filemap.c               | 331 +++++----------------------------------------
 3 files changed, 174 insertions(+), 348 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 92395a0a7d..12cb653423 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -352,18 +352,136 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
 struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
-unsigned find_get_entries(struct address_space *mapping, pgoff_t start,
-			  unsigned int nr_entries, struct page **entries,
-			  pgoff_t *indices);
-unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
-			unsigned int nr_pages, struct page **pages);
-unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
-			       unsigned int nr_pages, struct page **pages);
-unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
-			int tag, unsigned int nr_pages, struct page **pages);
-unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
-			int tag, unsigned int nr_entries,
-			struct page **entries, pgoff_t *indices);
+
+unsigned __find_get_pages(struct address_space *mapping,
+			  pgoff_t start, pgoff_t end,
+			  unsigned nr_entries, struct page **entries,
+			  pgoff_t *indices, unsigned flags);
+
+/**
+ * find_get_entries - gang pagecache lookup
+ * @mapping:	The address_space to search
+ * @start:	The starting page cache index
+ * @nr_entries:	The maximum number of entries
+ * @entries:	Where the resulting entries are placed
+ * @indices:	The cache indices corresponding to the entries in @entries
+ *
+ * find_get_entries() will search for and return a group of up to
+ * @nr_entries entries in the mapping.  The entries are placed at
+ * @entries.  find_get_entries() takes a reference against any actual
+ * pages it returns.
+ *
+ * The search returns a group of mapping-contiguous page cache entries
+ * with ascending indexes.  There may be holes in the indices due to
+ * not-present pages.
+ *
+ * Any shadow entries of evicted pages, or swap entries from
+ * shmem/tmpfs, are included in the returned array.
+ *
+ * find_get_entries() returns the number of pages and shadow entries
+ * which were found.
+ */
+static inline unsigned find_get_entries(struct address_space *mapping,
+			pgoff_t start, unsigned nr_entries,
+			struct page **entries, pgoff_t *indices)
+{
+	return __find_get_pages(mapping, start, ULONG_MAX,
+				nr_entries, entries, indices,
+				RADIX_TREE_ITER_EXCEPTIONAL);
+}
+
+/**
+ * find_get_pages - gang pagecache lookup
+ * @mapping:	The address_space to search
+ * @start:	The starting page index
+ * @nr_pages:	The maximum number of pages
+ * @pages:	Where the resulting pages are placed
+ *
+ * find_get_pages() will search for and return a group of up to
+ * @nr_pages pages in the mapping.  The pages are placed at @pages.
+ * find_get_pages() takes a reference against the returned pages.
+ *
+ * The search returns a group of mapping-contiguous pages with ascending
+ * indexes.  There may be holes in the indices due to not-present pages.
+ *
+ * find_get_pages() returns the number of pages which were found.
+ */
+static inline unsigned find_get_pages(struct address_space *mapping,
+			pgoff_t start, unsigned nr_pages,
+			struct page **pages)
+{
+	return __find_get_pages(mapping, start, ULONG_MAX,
+				nr_pages, pages, NULL, 0);
+}
+
+/**
+ * find_get_pages_contig - gang contiguous pagecache lookup
+ * @mapping:	The address_space to search
+ * @start:	The starting page index
+ * @nr_pages:	The maximum number of pages
+ * @pages:	Where the resulting pages are placed
+ *
+ * find_get_pages_contig() works exactly like find_get_pages(), except
+ * that the returned number of pages are guaranteed to be contiguous.
+ *
+ * find_get_pages_contig() returns the number of pages which were found.
+ */
+static inline unsigned find_get_pages_contig(struct address_space *mapping,
+			pgoff_t start, unsigned nr_pages,
+			struct page **pages)
+{
+	return __find_get_pages(mapping, start, ULONG_MAX,
+				nr_pages, pages, NULL,
+				RADIX_TREE_ITER_CONTIG);
+}
+
+/**
+ * find_get_pages_tag - find and return pages that match @tag
+ * @mapping:	the address_space to search
+ * @index:	the starting page index
+ * @tag:	the tag index
+ * @nr_pages:	the maximum number of pages
+ * @pages:	where the resulting pages are placed
+ *
+ * Like find_get_pages, except we only return pages which are tagged with
+ * @tag.   We update @index to index the next page for the traversal.
+ */
+static inline unsigned find_get_pages_tag(struct address_space *mapping,
+			pgoff_t *index, int tag,
+			unsigned nr_pages, struct page **pages)
+{
+	unsigned ret;
+
+	ret = __find_get_pages(mapping, *index, ULONG_MAX,
+			       nr_pages, pages, NULL,
+			       RADIX_TREE_ITER_TAGGED|tag);
+	if (ret)
+		*index = pages[ret - 1]->index + 1;
+
+	return ret;
+}
+
+/**
+ * find_get_entries_tag - find and return entries that match @tag
+ * @mapping:	the address_space to search
+ * @start:	the starting page cache index
+ * @tag:	the tag index
+ * @nr_entries:	the maximum number of entries
+ * @entries:	where the resulting entries are placed
+ * @indices:	the cache indices corresponding to the entries in @entries
+ *
+ * Like find_get_entries, except we only return entries which are tagged with
+ * @tag.
+ */
+static inline unsigned find_get_entries_tag(struct address_space *mapping,
+			pgoff_t start, int tag, unsigned nr_entries,
+			struct page **entries, pgoff_t *indices)
+{
+	return __find_get_pages(mapping, start, ULONG_MAX,
+				nr_entries, entries, indices,
+				RADIX_TREE_ITER_EXCEPTIONAL|
+				RADIX_TREE_ITER_TAGGED|tag);
+}
 
 struct page *grab_cache_page_write_begin(struct address_space *mapping,
 			pgoff_t index, unsigned flags);
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 7c88ad156a..c0c4dbf615 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -338,6 +338,8 @@ struct radix_tree_iter {
 #define RADIX_TREE_ITER_TAG_MASK	0x00FF	/* tag index in lower byte */
 #define RADIX_TREE_ITER_TAGGED		0x0100	/* lookup tagged slots */
 #define RADIX_TREE_ITER_CONTIG		0x0200	/* stop at first hole */
+#define RADIX_TREE_ITER_EXCEPTIONAL	0x0400	/* include exceptional entries */
+						/* used by __find_get_pages() */
 
 /**
  * radix_tree_iter_init - initialize radix tree iterator
@@ -435,33 +437,10 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 	return NULL;
 }
 
-/**
- * radix_tree_for_each_chunk - iterate over chunks
- *
- * @slot:	the void** variable for pointer to chunk first slot
- * @root:	the struct radix_tree_root pointer
- * @iter:	the struct radix_tree_iter pointer
- * @start:	iteration starting index
- * @flags:	RADIX_TREE_ITER_* and tag index
- *
- * Locks can be released and reacquired between iterations.
- */
-#define radix_tree_for_each_chunk(slot, root, iter, start, flags)	\
+#define __radix_tree_for_each_slot(slot, root, iter, start, flags)	\
 	for (slot = radix_tree_iter_init(iter, start) ;			\
-	      (slot = radix_tree_next_chunk(root, iter, flags)) ;)
-
-/**
- * radix_tree_for_each_chunk_slot - iterate over slots in one chunk
- *
- * @slot:	the void** variable, at the beginning points to chunk first slot
- * @iter:	the struct radix_tree_iter pointer
- * @flags:	RADIX_TREE_ITER_*, should be constant
- *
- * This macro is designed to be nested inside radix_tree_for_each_chunk().
- * @slot points to the radix tree slot, @iter->index contains its index.
- */
-#define radix_tree_for_each_chunk_slot(slot, iter, flags)		\
-	for (; slot ; slot = radix_tree_next_slot(slot, iter, flags))
+	     slot || (slot = radix_tree_next_chunk(root, iter, flags));	\
+	     slot = radix_tree_next_slot(slot, iter, flags))
 
 /**
  * radix_tree_for_each_slot - iterate over non-empty slots
@@ -474,9 +453,7 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
  * @slot points to radix tree slot, @iter->index contains its index.
  */
 #define radix_tree_for_each_slot(slot, root, iter, start)		\
-	for (slot = radix_tree_iter_init(iter, start) ;			\
-	     slot || (slot = radix_tree_next_chunk(root, iter, 0)) ;	\
-	     slot = radix_tree_next_slot(slot, iter, 0))
+	__radix_tree_for_each_slot(slot, root, iter, start, 0)
 
 /**
  * radix_tree_for_each_contig - iterate over contiguous slots
@@ -489,11 +466,8 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
  * @slot points to radix tree slot, @iter->index contains its index.
  */
 #define radix_tree_for_each_contig(slot, root, iter, start)		\
-	for (slot = radix_tree_iter_init(iter, start) ;			\
-	     slot || (slot = radix_tree_next_chunk(root, iter,		\
-				RADIX_TREE_ITER_CONTIG)) ;		\
-	     slot = radix_tree_next_slot(slot, iter,			\
-				RADIX_TREE_ITER_CONTIG))
+	__radix_tree_for_each_slot(slot, root, iter, start,		\
+			      RADIX_TREE_ITER_CONTIG)
 
 /**
  * radix_tree_for_each_tagged - iterate over tagged slots
@@ -507,10 +481,7 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
  * @slot points to radix tree slot, @iter->index contains its index.
  */
 #define radix_tree_for_each_tagged(slot, root, iter, start, tag)	\
-	for (slot = radix_tree_iter_init(iter, start) ;			\
-	     slot || (slot = radix_tree_next_chunk(root, iter,		\
-			      RADIX_TREE_ITER_TAGGED | tag)) ;		\
-	     slot = radix_tree_next_slot(slot, iter,			\
-				RADIX_TREE_ITER_TAGGED))
+	__radix_tree_for_each_slot(slot, root, iter, start,		\
+			      RADIX_TREE_ITER_TAGGED|tag)
 
 #endif /* _LINUX_RADIX_TREE_H */
diff --git a/mm/filemap.c b/mm/filemap.c
index bc943867d6..09dc7b493c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1211,109 +1211,48 @@ no_page:
 EXPORT_SYMBOL(pagecache_get_page);
 
 /**
- * find_get_entries - gang pagecache lookup
+ * __find_get_pages - gang pagecache lookup, internal mechanism
  * @mapping:	The address_space to search
  * @start:	The starting page cache index
+ * @end:	Page cache index to stop at (inclusive)
  * @nr_entries:	The maximum number of entries
  * @entries:	Where the resulting entries are placed
- * @indices:	The cache indices corresponding to the entries in @entries
+ * @indices:	If non NULL, indices of corresponding entries placed here
+ * @flags:	radix tree iter flags and tag (if supplied)
  *
- * find_get_entries() will search for and return a group of up to
- * @nr_entries entries in the mapping.  The entries are placed at
- * @entries.  find_get_entries() takes a reference against any actual
- * pages it returns.
+ * Don't use directly - see wrappers in pagemap.h
  *
- * The search returns a group of mapping-contiguous page cache entries
- * with ascending indexes.  There may be holes in the indices due to
- * not-present pages.
+ * Possible values for flags (may be used in combination):
  *
- * Any shadow entries of evicted pages, or swap entries from
- * shmem/tmpfs, are included in the returned array.
- *
- * find_get_entries() returns the number of pages and shadow entries
- * which were found.
+ * 0:				find_get_pages()
+ * RADIX_TREE_ITER_TAGGED|tag:	find_get_pages_tag()
+ * RADIX_TREE_ITER_CONTIG:	find_get_pages_contig()
+ * RADIX_TREE_ITER_EXCEPTIONAL:	find_get_entries()
  */
-unsigned find_get_entries(struct address_space *mapping,
-			  pgoff_t start, unsigned int nr_entries,
-			  struct page **entries, pgoff_t *indices)
-{
-	void **slot;
-	unsigned int ret = 0;
-	struct radix_tree_iter iter;
-
-	if (!nr_entries)
-		return 0;
-
-	rcu_read_lock();
-restart:
-	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		struct page *page;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		if (unlikely(!page))
-			continue;
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page))
-				goto restart;
-			/*
-			 * A shadow entry of a recently evicted page, a swap
-			 * entry from shmem/tmpfs or a DAX entry.  Return it
-			 * without attempting to raise page count.
-			 */
-			goto export;
-		}
-		if (!page_cache_get_speculative(page))
-			goto repeat;
-
-		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			page_cache_release(page);
-			goto repeat;
-		}
-export:
-		indices[ret] = iter.index;
-		entries[ret] = page;
-		if (++ret == nr_entries)
-			break;
-	}
-	rcu_read_unlock();
-	return ret;
-}
-
-/**
- * find_get_pages - gang pagecache lookup
- * @mapping:	The address_space to search
- * @start:	The starting page index
- * @nr_pages:	The maximum number of pages
- * @pages:	Where the resulting pages are placed
- *
- * find_get_pages() will search for and return a group of up to
- * @nr_pages pages in the mapping.  The pages are placed at @pages.
- * find_get_pages() takes a reference against the returned pages.
- *
- * The search returns a group of mapping-contiguous pages with ascending
- * indexes.  There may be holes in the indices due to not-present pages.
- *
- * find_get_pages() returns the number of pages which were found.
- */
-unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
-			    unsigned int nr_pages, struct page **pages)
+unsigned __find_get_pages(struct address_space *mapping,
+			  pgoff_t start, pgoff_t end,
+			  unsigned nr_entries, struct page **entries,
+			  pgoff_t *indices, unsigned flags)
 {
 	struct radix_tree_iter iter;
 	void **slot;
 	unsigned ret = 0;
 
-	if (unlikely(!nr_pages))
+	if (unlikely(!nr_entries || start > end))
 		return 0;
 
 	rcu_read_lock();
 restart:
-	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+	__radix_tree_for_each_slot(slot, &mapping->page_tree,
+				   &iter, start, flags) {
 		struct page *page;
+
+		if (iter.index > end)
+			break;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
-			continue;
+			goto no_entry;
 
 		if (radix_tree_exception(page)) {
 			if (radix_tree_deref_retry(page)) {
@@ -1322,82 +1261,18 @@ repeat:
 				 * when entry at index 0 moves out of or back
 				 * to root: none yet gotten, safe to restart.
 				 */
-				WARN_ON(iter.index);
 				goto restart;
 			}
+
 			/*
 			 * A shadow entry of a recently evicted page,
 			 * or a swap entry from shmem/tmpfs.  Skip
 			 * over it.
 			 */
-			continue;
-		}
+			if (flags & RADIX_TREE_ITER_EXCEPTIONAL)
+				goto export;
 
-		if (!page_cache_get_speculative(page))
-			goto repeat;
-
-		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			page_cache_release(page);
-			goto repeat;
-		}
-
-		pages[ret] = page;
-		if (++ret == nr_pages)
-			break;
-	}
-
-	rcu_read_unlock();
-	return ret;
-}
-
-/**
- * find_get_pages_contig - gang contiguous pagecache lookup
- * @mapping:	The address_space to search
- * @index:	The starting page index
- * @nr_pages:	The maximum number of pages
- * @pages:	Where the resulting pages are placed
- *
- * find_get_pages_contig() works exactly like find_get_pages(), except
- * that the returned number of pages are guaranteed to be contiguous.
- *
- * find_get_pages_contig() returns the number of pages which were found.
- */
-unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
-			       unsigned int nr_pages, struct page **pages)
-{
-	struct radix_tree_iter iter;
-	void **slot;
-	unsigned int ret = 0;
-
-	if (unlikely(!nr_pages))
-		return 0;
-
-	rcu_read_lock();
-restart:
-	radix_tree_for_each_contig(slot, &mapping->page_tree, &iter, index) {
-		struct page *page;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		/* The hole, there no reason to continue */
-		if (unlikely(!page))
-			break;
-
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				/*
-				 * Transient condition which can only trigger
-				 * when entry at index 0 moves out of or back
-				 * to root: none yet gotten, safe to restart.
-				 */
-				goto restart;
-			}
-			/*
-			 * A shadow entry of a recently evicted page,
-			 * or a swap entry from shmem/tmpfs.  Stop
-			 * looking for contiguous pages.
-			 */
-			break;
+			goto no_entry;
 		}
 
 		if (!page_cache_get_speculative(page))
@@ -1414,164 +1289,26 @@ repeat:
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page->index != iter.index) {
+		if ((flags & RADIX_TREE_ITER_CONTIG) &&
+		    (page->mapping == NULL || page->index != iter.index)) {
 			page_cache_release(page);
 			break;
 		}
-
-		pages[ret] = page;
-		if (++ret == nr_pages)
-			break;
-	}
-	rcu_read_unlock();
-	return ret;
-}
-EXPORT_SYMBOL(find_get_pages_contig);
-
-/**
- * find_get_pages_tag - find and return pages that match @tag
- * @mapping:	the address_space to search
- * @index:	the starting page index
- * @tag:	the tag index
- * @nr_pages:	the maximum number of pages
- * @pages:	where the resulting pages are placed
- *
- * Like find_get_pages, except we only return pages which are tagged with
- * @tag.   We update @index to index the next page for the traversal.
- */
-unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
-			int tag, unsigned int nr_pages, struct page **pages)
-{
-	struct radix_tree_iter iter;
-	void **slot;
-	unsigned ret = 0;
-
-	if (unlikely(!nr_pages))
-		return 0;
-
-	rcu_read_lock();
-restart:
-	radix_tree_for_each_tagged(slot, &mapping->page_tree,
-				   &iter, *index, tag) {
-		struct page *page;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		if (unlikely(!page))
-			continue;
-
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				/*
-				 * Transient condition which can only trigger
-				 * when entry at index 0 moves out of or back
-				 * to root: none yet gotten, safe to restart.
-				 */
-				goto restart;
-			}
-			/*
-			 * A shadow entry of a recently evicted page.
-			 *
-			 * Those entries should never be tagged, but
-			 * this tree walk is lockless and the tags are
-			 * looked up in bulk, one radix tree node at a
-			 * time, so there is a sizable window for page
-			 * reclaim to evict a page we saw tagged.
-			 *
-			 * Skip over it.
-			 */
-			continue;
-		}
-
-		if (!page_cache_get_speculative(page))
-			goto repeat;
-
-		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			page_cache_release(page);
-			goto repeat;
-		}
-
-		pages[ret] = page;
-		if (++ret == nr_pages)
-			break;
-	}
-
-	rcu_read_unlock();
-
-	if (ret)
-		*index = pages[ret - 1]->index + 1;
-
-	return ret;
-}
-EXPORT_SYMBOL(find_get_pages_tag);
-
-/**
- * find_get_entries_tag - find and return entries that match @tag
- * @mapping:	the address_space to search
- * @start:	the starting page cache index
- * @tag:	the tag index
- * @nr_entries:	the maximum number of entries
- * @entries:	where the resulting entries are placed
- * @indices:	the cache indices corresponding to the entries in @entries
- *
- * Like find_get_entries, except we only return entries which are tagged with
- * @tag.
- */
-unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
-			int tag, unsigned int nr_entries,
-			struct page **entries, pgoff_t *indices)
-{
-	void **slot;
-	unsigned int ret = 0;
-	struct radix_tree_iter iter;
-
-	if (!nr_entries)
-		return 0;
-
-	rcu_read_lock();
-restart:
-	radix_tree_for_each_tagged(slot, &mapping->page_tree,
-				   &iter, start, tag) {
-		struct page *page;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		if (unlikely(!page))
-			continue;
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				/*
-				 * Transient condition which can only trigger
-				 * when entry at index 0 moves out of or back
-				 * to root: none yet gotten, safe to restart.
-				 */
-				goto restart;
-			}
-
-			/*
-			 * A shadow entry of a recently evicted page, a swap
-			 * entry from shmem/tmpfs or a DAX entry.  Return it
-			 * without attempting to raise page count.
-			 */
-			goto export;
-		}
-		if (!page_cache_get_speculative(page))
-			goto repeat;
-
-		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			page_cache_release(page);
-			goto repeat;
-		}
 export:
-		indices[ret] = iter.index;
+		if (indices)
+			indices[ret] = iter.index;
 		entries[ret] = page;
 		if (++ret == nr_entries)
 			break;
+		continue;
+no_entry:
+		if (flags & RADIX_TREE_ITER_CONTIG)
+			break;
 	}
 	rcu_read_unlock();
 	return ret;
 }
-EXPORT_SYMBOL(find_get_entries_tag);
+EXPORT_SYMBOL(__find_get_pages);
 
 /*
  * CD/DVDs are error prone. When a medium error occurs, the driver may fail
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

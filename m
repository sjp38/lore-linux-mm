Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 689366B0034
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 18:44:45 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/9] mm: filemap: move radix tree hole searching here
Date: Tue,  6 Aug 2013 18:44:04 -0400
Message-Id: <1375829050-12654-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
References: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

The radix tree hole searching code is only used for page cache, for
example the readahead code trying to get a a picture of the area
surrounding a fault.

It sufficed to rely on the radix tree definition of holes, which is
"empty tree slot".  But this is about to change, though, as shadow
page descriptors will be stored in the page cache after the actual
pages get evicted from memory.

Move the functions over to mm/filemap.c and make them native page
cache operations, where they can later be adapted to handle the new
definition of "page cache hole".

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/nfs/blocklayout/blocklayout.c |  2 +-
 include/linux/pagemap.h          |  5 +++
 include/linux/radix-tree.h       |  4 ---
 lib/radix-tree.c                 | 75 ---------------------------------------
 mm/filemap.c                     | 76 ++++++++++++++++++++++++++++++++++++++++
 mm/readahead.c                   |  4 +--
 6 files changed, 84 insertions(+), 82 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index e242bbf..fdb74cb 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1220,7 +1220,7 @@ static u64 pnfs_num_cont_bytes(struct inode *inode, pgoff_t idx)
 	end = DIV_ROUND_UP(i_size_read(inode), PAGE_CACHE_SIZE);
 	if (end != NFS_I(inode)->npages) {
 		rcu_read_lock();
-		end = radix_tree_next_hole(&mapping->page_tree, idx + 1, ULONG_MAX);
+		end = page_cache_next_hole(mapping, idx + 1, ULONG_MAX);
 		rcu_read_unlock();
 	}
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e3dea75..c73130c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -243,6 +243,11 @@ static inline struct page *page_cache_alloc_readahead(struct address_space *x)
 
 typedef int filler_t(void *, struct page *);
 
+pgoff_t page_cache_next_hole(struct address_space *mapping,
+			     pgoff_t index, unsigned long max_scan);
+pgoff_t page_cache_prev_hole(struct address_space *mapping,
+			     pgoff_t index, unsigned long max_scan);
+
 extern struct page * find_get_page(struct address_space *mapping,
 				pgoff_t index);
 extern struct page * find_lock_page(struct address_space *mapping,
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 1bf0a9c..e8be53e 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -227,10 +227,6 @@ radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 unsigned int radix_tree_gang_lookup_slot(struct radix_tree_root *root,
 			void ***results, unsigned long *indices,
 			unsigned long first_index, unsigned int max_items);
-unsigned long radix_tree_next_hole(struct radix_tree_root *root,
-				unsigned long index, unsigned long max_scan);
-unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
-				unsigned long index, unsigned long max_scan);
 int radix_tree_preload(gfp_t gfp_mask);
 int radix_tree_maybe_preload(gfp_t gfp_mask);
 void radix_tree_init(void);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 60b202b..912e67b 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -946,81 +946,6 @@ next:
 }
 EXPORT_SYMBOL(radix_tree_range_tag_if_tagged);
 
-
-/**
- *	radix_tree_next_hole    -    find the next hole (not-present entry)
- *	@root:		tree root
- *	@index:		index key
- *	@max_scan:	maximum range to search
- *
- *	Search the set [index, min(index+max_scan-1, MAX_INDEX)] for the lowest
- *	indexed hole.
- *
- *	Returns: the index of the hole if found, otherwise returns an index
- *	outside of the set specified (in which case 'return - index >= max_scan'
- *	will be true). In rare cases of index wrap-around, 0 will be returned.
- *
- *	radix_tree_next_hole may be called under rcu_read_lock. However, like
- *	radix_tree_gang_lookup, this will not atomically search a snapshot of
- *	the tree at a single point in time. For example, if a hole is created
- *	at index 5, then subsequently a hole is created at index 10,
- *	radix_tree_next_hole covering both indexes may return 10 if called
- *	under rcu_read_lock.
- */
-unsigned long radix_tree_next_hole(struct radix_tree_root *root,
-				unsigned long index, unsigned long max_scan)
-{
-	unsigned long i;
-
-	for (i = 0; i < max_scan; i++) {
-		if (!radix_tree_lookup(root, index))
-			break;
-		index++;
-		if (index == 0)
-			break;
-	}
-
-	return index;
-}
-EXPORT_SYMBOL(radix_tree_next_hole);
-
-/**
- *	radix_tree_prev_hole    -    find the prev hole (not-present entry)
- *	@root:		tree root
- *	@index:		index key
- *	@max_scan:	maximum range to search
- *
- *	Search backwards in the range [max(index-max_scan+1, 0), index]
- *	for the first hole.
- *
- *	Returns: the index of the hole if found, otherwise returns an index
- *	outside of the set specified (in which case 'index - return >= max_scan'
- *	will be true). In rare cases of wrap-around, ULONG_MAX will be returned.
- *
- *	radix_tree_next_hole may be called under rcu_read_lock. However, like
- *	radix_tree_gang_lookup, this will not atomically search a snapshot of
- *	the tree at a single point in time. For example, if a hole is created
- *	at index 10, then subsequently a hole is created at index 5,
- *	radix_tree_prev_hole covering both indexes may return 5 if called under
- *	rcu_read_lock.
- */
-unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
-				   unsigned long index, unsigned long max_scan)
-{
-	unsigned long i;
-
-	for (i = 0; i < max_scan; i++) {
-		if (!radix_tree_lookup(root, index))
-			break;
-		index--;
-		if (index == ULONG_MAX)
-			break;
-	}
-
-	return index;
-}
-EXPORT_SYMBOL(radix_tree_prev_hole);
-
 /**
  *	radix_tree_gang_lookup - perform multiple lookup on a radix tree
  *	@root:		radix tree root
diff --git a/mm/filemap.c b/mm/filemap.c
index ae5cc01..e7833d2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -688,6 +688,82 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 }
 
 /**
+ * page_cache_next_hole - find the next hole (not-present entry)
+ * @mapping: mapping
+ * @index: index
+ * @max_scan: maximum range to search
+ *
+ * Search the set [index, min(index+max_scan-1, MAX_INDEX)] for the
+ * lowest indexed hole.
+ *
+ * Returns: the index of the hole if found, otherwise returns an index
+ * outside of the set specified (in which case 'return - index >=
+ * max_scan' will be true). In rare cases of index wrap-around, 0 will
+ * be returned.
+ *
+ * page_cache_next_hole may be called under rcu_read_lock. However,
+ * like radix_tree_gang_lookup, this will not atomically search a
+ * snapshot of the tree at a single point in time. For example, if a
+ * hole is created at index 5, then subsequently a hole is created at
+ * index 10, page_cache_next_hole covering both indexes may return 10
+ * if called under rcu_read_lock.
+ */
+pgoff_t page_cache_next_hole(struct address_space *mapping,
+			     pgoff_t index, unsigned long max_scan)
+{
+	unsigned long i;
+
+	for (i = 0; i < max_scan; i++) {
+		if (!radix_tree_lookup(&mapping->page_tree, index))
+			break;
+		index++;
+		if (index == 0)
+			break;
+	}
+
+	return index;
+}
+EXPORT_SYMBOL(page_cache_next_hole);
+
+/**
+ * page_cache_prev_hole - find the prev hole (not-present entry)
+ * @mapping: mapping
+ * @index: index
+ * @max_scan: maximum range to search
+ *
+ * Search backwards in the range [max(index-max_scan+1, 0), index] for
+ * the first hole.
+ *
+ * Returns: the index of the hole if found, otherwise returns an index
+ * outside of the set specified (in which case 'index - return >=
+ * max_scan' will be true). In rare cases of wrap-around, ULONG_MAX
+ * will be returned.
+ *
+ * page_cache_prev_hole may be called under rcu_read_lock. However,
+ * like radix_tree_gang_lookup, this will not atomically search a
+ * snapshot of the tree at a single point in time. For example, if a
+ * hole is created at index 10, then subsequently a hole is created at
+ * index 5, page_cache_prev_hole covering both indexes may return 5 if
+ * called under rcu_read_lock.
+ */
+pgoff_t page_cache_prev_hole(struct address_space *mapping,
+			     pgoff_t index, unsigned long max_scan)
+{
+	unsigned long i;
+
+	for (i = 0; i < max_scan; i++) {
+		if (!radix_tree_lookup(&mapping->page_tree, index))
+			break;
+		index--;
+		if (index == ULONG_MAX)
+			break;
+	}
+
+	return index;
+}
+EXPORT_SYMBOL(page_cache_prev_hole);
+
+/**
  * find_get_page - find and get a page reference
  * @mapping: the address_space to search
  * @offset: the page index
diff --git a/mm/readahead.c b/mm/readahead.c
index 829a77c..01f4cae 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -351,7 +351,7 @@ static pgoff_t count_history_pages(struct address_space *mapping,
 	pgoff_t head;
 
 	rcu_read_lock();
-	head = radix_tree_prev_hole(&mapping->page_tree, offset - 1, max);
+	head = page_cache_prev_hole(mapping, offset - 1, max);
 	rcu_read_unlock();
 
 	return offset - 1 - head;
@@ -430,7 +430,7 @@ ondemand_readahead(struct address_space *mapping,
 		pgoff_t start;
 
 		rcu_read_lock();
-		start = radix_tree_next_hole(&mapping->page_tree, offset+1,max);
+		start = page_cache_next_hole(mapping, offset + 1, max);
 		rcu_read_unlock();
 
 		if (!start || start - offset > max)
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

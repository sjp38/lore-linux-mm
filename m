Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 97C476B13F1
	for <linux-mm@kvack.org>; Sat, 11 Feb 2012 02:44:16 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so3945717bkt.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 23:44:16 -0800 (PST)
Subject: [PATCH 6/4] shmem: simplify shmem_truncate_range
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 11 Feb 2012 11:44:08 +0400
Message-ID: <20120211074356.30852.88524.stgit@zurg>
In-Reply-To: <20120210193249.6492.18768.stgit@zurg>
References: <20120210193249.6492.18768.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>

find_get_pages() now can skip unlimited count of exeptional entries,
so truncate_inode_pages_range() can truncate pages from shmem inodes.
Thus shmem_truncate_range() can be simplified.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/shmem.c |  199 +++++++++++++++---------------------------------------------
 1 files changed, 49 insertions(+), 150 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 709e3d8..b981fa9 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -302,57 +302,6 @@ static int shmem_add_to_page_cache(struct page *page,
 }
 
 /*
- * Like find_get_pages, but collecting swap entries as well as pages.
- */
-static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
-					pgoff_t start, unsigned int nr_pages,
-					struct page **pages, pgoff_t *indices)
-{
-	unsigned int i;
-	unsigned int ret;
-	unsigned int nr_found;
-
-	rcu_read_lock();
-restart:
-	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
-				(void ***)pages, indices, start, nr_pages);
-	ret = 0;
-	for (i = 0; i < nr_found; i++) {
-		struct page *page;
-repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
-		if (unlikely(!page))
-			continue;
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page))
-				goto restart;
-			/*
-			 * Otherwise, we must be storing a swap entry
-			 * here as an exceptional entry: so return it
-			 * without attempting to raise page count.
-			 */
-			goto export;
-		}
-		if (!page_cache_get_speculative(page))
-			goto repeat;
-
-		/* Has the page moved? */
-		if (unlikely(page != *((void **)pages[i]))) {
-			page_cache_release(page);
-			goto repeat;
-		}
-export:
-		indices[ret] = indices[i];
-		pages[ret] = page;
-		ret++;
-	}
-	if (unlikely(!ret && nr_found))
-		goto restart;
-	rcu_read_unlock();
-	return ret;
-}
-
-/*
  * Remove swap entry from radix tree, free the swap and its page cache.
  */
 static int shmem_free_swap(struct address_space *mapping,
@@ -369,21 +318,6 @@ static int shmem_free_swap(struct address_space *mapping,
 }
 
 /*
- * Pagevec may contain swap entries, so shuffle up pages before releasing.
- */
-static void shmem_deswap_pagevec(struct pagevec *pvec)
-{
-	int i, j;
-
-	for (i = 0, j = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-		if (!radix_tree_exceptional_entry(page))
-			pvec->pages[j++] = page;
-	}
-	pvec->nr = j;
-}
-
-/*
  * SysV IPC SHM_UNLOCK restore Unevictable pages to their evictable lists.
  */
 void shmem_unlock_mapping(struct address_space *mapping)
@@ -406,6 +340,50 @@ void shmem_unlock_mapping(struct address_space *mapping)
 }
 
 /*
+ * Remove range of swap entries from radix tree, and free them.
+ */
+static long shmem_truncate_swap_range(struct address_space *mapping,
+				      pgoff_t start, pgoff_t end)
+{
+	struct radix_tree_iter iter;
+	void **slot, *data, *radswaps[PAGEVEC_SIZE];
+	unsigned long indices[PAGEVEC_SIZE];
+	long nr_swaps_freed = 0;
+	int i, nr;
+
+next:
+	rcu_read_lock();
+	nr = 0;
+restart:
+	radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter,
+						start, SHMEM_TAG_SWAP) {
+		if (iter.index > end)
+			break;
+		data = radix_tree_deref_slot(slot);
+		if (!data || !radix_tree_exception(data))
+			continue;
+		if (radix_tree_deref_retry(data))
+			goto restart;
+		radswaps[nr] = data;
+		indices[nr] = iter.index;
+		if (++nr == PAGEVEC_SIZE)
+			break;
+	}
+	rcu_read_unlock();
+
+	for ( i = 0 ; i < nr ; i++ ) {
+		if (!shmem_free_swap(mapping, indices[i], radswaps[i]))
+			nr_swaps_freed++;
+		start = indices[i] + 1;
+	}
+
+	if (nr == PAGEVEC_SIZE && start)
+		goto next;
+
+	return nr_swaps_freed;
+}
+
+/*
  * Remove range of pages and swap entries from radix tree, and free them.
  */
 void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
@@ -415,52 +393,11 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 	pgoff_t start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
 	pgoff_t end = (lend >> PAGE_CACHE_SHIFT);
-	struct pagevec pvec;
-	pgoff_t indices[PAGEVEC_SIZE];
 	long nr_swaps_freed = 0;
-	pgoff_t index;
-	int i;
 
 	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
 
-	pagevec_init(&pvec, 0);
-	index = start;
-	while (index <= end) {
-		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
-							pvec.pages, indices);
-		if (!pvec.nr)
-			break;
-		mem_cgroup_uncharge_start();
-		for (i = 0; i < pagevec_count(&pvec); i++) {
-			struct page *page = pvec.pages[i];
-
-			index = indices[i];
-			if (index > end)
-				break;
-
-			if (radix_tree_exceptional_entry(page)) {
-				nr_swaps_freed += !shmem_free_swap(mapping,
-								index, page);
-				continue;
-			}
-
-			if (!trylock_page(page))
-				continue;
-			if (page->mapping == mapping) {
-				VM_BUG_ON(PageWriteback(page));
-				truncate_inode_page(mapping, page);
-			}
-			unlock_page(page);
-		}
-		shmem_deswap_pagevec(&pvec);
-		pagevec_release(&pvec);
-		mem_cgroup_uncharge_end();
-		cond_resched();
-		index++;
-	}
-
-	if (partial) {
+	if (IS_ENABLED(CONFIG_SWAP) && partial) {
 		struct page *page = NULL;
 		shmem_getpage(inode, start - 1, &page, SGP_READ, NULL);
 		if (page) {
@@ -469,51 +406,13 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 			unlock_page(page);
 			page_cache_release(page);
 		}
+		lstart += PAGE_CACHE_SIZE - partial;
 	}
 
-	index = start;
-	for ( ; ; ) {
-		cond_resched();
-		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
-							pvec.pages, indices);
-		if (!pvec.nr) {
-			if (index == start)
-				break;
-			index = start;
-			continue;
-		}
-		if (index == start && indices[0] > end) {
-			shmem_deswap_pagevec(&pvec);
-			pagevec_release(&pvec);
-			break;
-		}
-		mem_cgroup_uncharge_start();
-		for (i = 0; i < pagevec_count(&pvec); i++) {
-			struct page *page = pvec.pages[i];
-
-			index = indices[i];
-			if (index > end)
-				break;
+	truncate_inode_pages_range(mapping, lstart, lend);
 
-			if (radix_tree_exceptional_entry(page)) {
-				nr_swaps_freed += !shmem_free_swap(mapping,
-								index, page);
-				continue;
-			}
-
-			lock_page(page);
-			if (page->mapping == mapping) {
-				VM_BUG_ON(PageWriteback(page));
-				truncate_inode_page(mapping, page);
-			}
-			unlock_page(page);
-		}
-		shmem_deswap_pagevec(&pvec);
-		pagevec_release(&pvec);
-		mem_cgroup_uncharge_end();
-		index++;
-	}
+	if (IS_ENABLED(CONFIG_SWAP))
+		nr_swaps_freed = shmem_truncate_swap_range(mapping, start, end);
 
 	spin_lock(&info->lock);
 	info->swapped -= nr_swaps_freed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

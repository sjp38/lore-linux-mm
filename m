Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D774C6B0083
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 06:51:27 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p5EApPWc006080
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:51:25 -0700
Received: from pzk26 (pzk26.prod.google.com [10.243.19.154])
	by wpaz9.hot.corp.google.com with ESMTP id p5EApBms002487
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:51:24 -0700
Received: by pzk26 with SMTP id 26so3100105pzk.24
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:51:19 -0700 (PDT)
Date: Tue, 14 Jun 2011 03:51:07 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 6/12] tmpfs: convert shmem_truncate_range to radix-swap
In-Reply-To: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106140349500.29206@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Disable the toy swapping implementation in shmem_writepage() - it's
hard to support two schemes at once - and convert shmem_truncate_range()
to a lockless gang lookup of swap entries along with pages, freeing both.

Since the second loop tightens its noose until all entries of either
kind have been squeezed out (and we shall make sure that there's not
an instant when neither is visible), there is no longer a need for
yet another pass below.

shmem_radix_tree_replace() compensates for the lockless lookup by
checking that the expected entry is in place, under lock, before
replacing it.  Here it just deletes, but will be used in later
patches to substitute swap entry for page or page for swap entry.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |  192 ++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 146 insertions(+), 46 deletions(-)

--- linux.orig/mm/shmem.c	2011-06-13 13:28:44.330878656 -0700
+++ linux/mm/shmem.c	2011-06-13 13:29:36.311136453 -0700
@@ -238,6 +238,111 @@ static swp_entry_t shmem_get_swap(struct
 		info->i_direct[index] : (swp_entry_t){0};
 }
 
+/*
+ * Replace item expected in radix tree by a new item, while holding tree lock.
+ */
+static int shmem_radix_tree_replace(struct address_space *mapping,
+			pgoff_t index, void *expected, void *replacement)
+{
+	void **pslot;
+	void *item = NULL;
+
+	VM_BUG_ON(!expected);
+	pslot = radix_tree_lookup_slot(&mapping->page_tree, index);
+	if (pslot)
+		item = radix_tree_deref_slot_protected(pslot,
+							&mapping->tree_lock);
+	if (item != expected)
+		return -ENOENT;
+	if (replacement)
+		radix_tree_replace_slot(pslot, replacement);
+	else
+		radix_tree_delete(&mapping->page_tree, index);
+	return 0;
+}
+
+/*
+ * Like find_get_pages, but collecting swap entries as well as pages.
+ */
+static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
+					pgoff_t start, unsigned int nr_pages,
+					struct page **pages, pgoff_t *indices)
+{
+	unsigned int i;
+	unsigned int ret;
+	unsigned int nr_found;
+
+	rcu_read_lock();
+restart:
+	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
+				(void ***)pages, indices, start, nr_pages);
+	ret = 0;
+	for (i = 0; i < nr_found; i++) {
+		struct page *page;
+repeat:
+		page = radix_tree_deref_slot((void **)pages[i]);
+		if (unlikely(!page))
+			continue;
+		if (radix_tree_exception(page)) {
+			if (radix_tree_exceptional_entry(page))
+				goto export;
+			/* radix_tree_deref_retry(page) */
+			goto restart;
+		}
+		if (!page_cache_get_speculative(page))
+			goto repeat;
+
+		/* Has the page moved? */
+		if (unlikely(page != *((void **)pages[i]))) {
+			page_cache_release(page);
+			goto repeat;
+		}
+export:
+		indices[ret] = indices[i];
+		pages[ret] = page;
+		ret++;
+	}
+	if (unlikely(!ret && nr_found))
+		goto restart;
+	rcu_read_unlock();
+	return ret;
+}
+
+/*
+ * Remove swap entry from radix tree, free the swap and its page cache.
+ */
+static int shmem_free_swap(struct address_space *mapping,
+			   pgoff_t index, void *radswap)
+{
+	int error;
+
+	spin_lock_irq(&mapping->tree_lock);
+	error = shmem_radix_tree_replace(mapping, index, radswap, NULL);
+	spin_unlock_irq(&mapping->tree_lock);
+	if (!error)
+		free_swap_and_cache(radix_to_swp_entry(radswap));
+	return error;
+}
+
+/*
+ * Pagevec may contain swap entries, so shuffle up pages before releasing.
+ */
+static void shmem_pagevec_release(struct pagevec *pvec)
+{
+	int i, j;
+
+	for (i = 0, j = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		if (!radix_tree_exceptional_entry(page))
+			pvec->pages[j++] = page;
+	}
+	pvec->nr = j;
+	pagevec_release(pvec);
+}
+
+/*
+ * Remove range of pages and swap entries from radix tree, and free them.
+ */
 void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 {
 	struct address_space *mapping = inode->i_mapping;
@@ -246,36 +351,44 @@ void shmem_truncate_range(struct inode *
 	unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
 	pgoff_t end = (lend >> PAGE_CACHE_SHIFT);
 	struct pagevec pvec;
+	pgoff_t indices[PAGEVEC_SIZE];
+	long nr_swaps_freed = 0;
 	pgoff_t index;
-	swp_entry_t swap;
 	int i;
 
 	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
 
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index <= end && pagevec_lookup(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+	while (index <= end) {
+		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
+							pvec.pages, indices);
+		if (!pvec.nr)
+			break;
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			/* We rely upon deletion not changing page->index */
-			index = page->index;
+			index = indices[i];
 			if (index > end)
 				break;
 
-			if (!trylock_page(page))
+			if (radix_tree_exceptional_entry(page)) {
+				nr_swaps_freed += !shmem_free_swap(mapping,
+								index, page);
 				continue;
-			WARN_ON(page->index != index);
-			if (PageWriteback(page)) {
-				unlock_page(page);
+			}
+
+			if (!trylock_page(page))
 				continue;
+			if (page->mapping == mapping) {
+				VM_BUG_ON(PageWriteback(page));
+				truncate_inode_page(mapping, page);
 			}
-			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
-		pagevec_release(&pvec);
+		shmem_pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
 		index++;
@@ -295,59 +408,47 @@ void shmem_truncate_range(struct inode *
 	index = start;
 	for ( ; ; ) {
 		cond_resched();
-		if (!pagevec_lookup(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
+							pvec.pages, indices);
+		if (!pvec.nr) {
 			if (index == start)
 				break;
 			index = start;
 			continue;
 		}
-		if (index == start && pvec.pages[0]->index > end) {
-			pagevec_release(&pvec);
+		if (index == start && indices[0] > end) {
+			shmem_pagevec_release(&pvec);
 			break;
 		}
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			/* We rely upon deletion not changing page->index */
-			index = page->index;
+			index = indices[i];
 			if (index > end)
 				break;
 
+			if (radix_tree_exceptional_entry(page)) {
+				nr_swaps_freed += !shmem_free_swap(mapping,
+								index, page);
+				continue;
+			}
+
 			lock_page(page);
-			WARN_ON(page->index != index);
-			wait_on_page_writeback(page);
-			truncate_inode_page(mapping, page);
+			if (page->mapping == mapping) {
+				VM_BUG_ON(PageWriteback(page));
+				truncate_inode_page(mapping, page);
+			}
 			unlock_page(page);
 		}
-		pagevec_release(&pvec);
+		shmem_pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		index++;
 	}
 
-	if (end > SHMEM_NR_DIRECT)
-		end = SHMEM_NR_DIRECT;
-
 	spin_lock(&info->lock);
-	for (index = start; index < end; index++) {
-		swap = shmem_get_swap(info, index);
-		if (swap.val) {
-			free_swap_and_cache(swap);
-			shmem_put_swap(info, index, (swp_entry_t){0});
-			info->swapped--;
-		}
-	}
-
-	if (mapping->nrpages) {
-		spin_unlock(&info->lock);
-		/*
-		 * A page may have meanwhile sneaked in from swap.
-		 */
-		truncate_inode_pages_range(mapping, lstart, lend);
-		spin_lock(&info->lock);
-	}
-
+	info->swapped -= nr_swaps_freed;
 	shmem_recalc_inode(inode);
 	spin_unlock(&info->lock);
 
@@ -552,11 +653,10 @@ static int shmem_writepage(struct page *
 	}
 
 	/*
-	 * Just for this patch, we have a toy implementation,
-	 * which can swap out only the first SHMEM_NR_DIRECT pages:
-	 * for simple demonstration of where we need to think about swap.
+	 * Disable even the toy swapping implementation, while we convert
+	 * functions one by one to having swap entries in the radix tree.
 	 */
-	if (index >= SHMEM_NR_DIRECT)
+	if (index < ULONG_MAX)
 		goto redirty;
 
 	swap = get_swap_page();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

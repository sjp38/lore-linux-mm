Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 43C216B13F4
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 02:55:17 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id zs2so7019093bkb.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 23:55:16 -0800 (PST)
Subject: [PATCH 4/4] radix-tree: use iterators in find_get_pages* functions
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 07 Feb 2012 11:55:12 +0400
Message-ID: <20120207075512.29797.44234.stgit@zurg>
In-Reply-To: <20120207074905.29797.60353.stgit@zurg>
References: <20120207074905.29797.60353.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org

This patch replaces radix_tree_gang_lookup_slot() and
radix_tree_gang_lookup_tag_slot() in page-cache lookup functions with brand-new
radix-tree direct iterating. This avoids the double-scanning and pointers copying.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/filemap.c |   75 ++++++++++++++++++++++++++++++++++------------------------
 mm/shmem.c   |   23 +++++++++++-------
 2 files changed, 58 insertions(+), 40 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index b662757..518223b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -811,23 +811,25 @@ EXPORT_SYMBOL(find_or_create_page);
 unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 			    unsigned int nr_pages, struct page **pages)
 {
-	unsigned int i;
 	unsigned int ret;
 	unsigned int nr_found, nr_skip;
+	struct radix_tree_iter iter;
+	void **slot;
+
+	if (!nr_pages)
+		return 0;
 
 	rcu_read_lock();
 restart:
-	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
-				(void ***)pages, NULL, start, nr_pages);
-	ret = 0;
-	nr_skip = 0;
-	for (i = 0; i < nr_found; i++) {
+	nr_found = nr_skip = ret = 0;
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
 		struct page *page;
 repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
+		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
 			continue;
 
+		nr_found++;
 		if (radix_tree_exception(page)) {
 			if (radix_tree_deref_retry(page)) {
 				/*
@@ -835,7 +837,7 @@ repeat:
 				 * when entry at index 0 moves out of or back
 				 * to root: none yet gotten, safe to restart.
 				 */
-				WARN_ON(start | i);
+				WARN_ON(iter.index);
 				goto restart;
 			}
 			/*
@@ -851,13 +853,14 @@ repeat:
 			goto repeat;
 
 		/* Has the page moved? */
-		if (unlikely(page != *((void **)pages[i]))) {
+		if (unlikely(page != *slot)) {
 			page_cache_release(page);
 			goto repeat;
 		}
 
 		pages[ret] = page;
-		ret++;
+		if (++ret == nr_pages)
+			goto out;
 	}
 
 	/*
@@ -866,6 +869,7 @@ repeat:
 	 */
 	if (unlikely(!ret && nr_found > nr_skip))
 		goto restart;
+out:
 	rcu_read_unlock();
 	return ret;
 }
@@ -885,21 +889,23 @@ repeat:
 unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 			       unsigned int nr_pages, struct page **pages)
 {
-	unsigned int i;
+	struct radix_tree_iter iter;
 	unsigned int ret;
-	unsigned int nr_found;
+	void **slot;
+
+	if (!nr_pages)
+		return 0;
 
 	rcu_read_lock();
 restart:
-	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
-				(void ***)pages, NULL, index, nr_pages);
 	ret = 0;
-	for (i = 0; i < nr_found; i++) {
+	radix_tree_for_each_contig(slot, &mapping->page_tree, &iter, index) {
 		struct page *page;
 repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
+		page = radix_tree_deref_slot(slot);
+		/* The hole, there no reason to continue */
 		if (unlikely(!page))
-			continue;
+			goto out;
 
 		if (radix_tree_exception(page)) {
 			if (radix_tree_deref_retry(page)) {
@@ -915,14 +921,14 @@ repeat:
 			 * here as an exceptional entry: so stop looking for
 			 * contiguous pages.
 			 */
-			break;
+			goto out;
 		}
 
 		if (!page_cache_get_speculative(page))
 			goto repeat;
 
 		/* Has the page moved? */
-		if (unlikely(page != *((void **)pages[i]))) {
+		if (unlikely(page != *slot)) {
 			page_cache_release(page);
 			goto repeat;
 		}
@@ -932,15 +938,16 @@ repeat:
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page->index != index) {
+		if (page->mapping == NULL || page->index != iter.index) {
 			page_cache_release(page);
-			break;
+			goto out;
 		}
 
 		pages[ret] = page;
-		ret++;
-		index++;
+		if (++ret == nr_pages)
+			goto out;
 	}
+out:
 	rcu_read_unlock();
 	return ret;
 }
@@ -960,22 +967,26 @@ EXPORT_SYMBOL(find_get_pages_contig);
 unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 			int tag, unsigned int nr_pages, struct page **pages)
 {
-	unsigned int i;
 	unsigned int ret;
 	unsigned int nr_found;
+	struct radix_tree_iter iter;
+	void **slot;
+
+	if (!nr_pages)
+		return 0;
 
 	rcu_read_lock();
 restart:
-	nr_found = radix_tree_gang_lookup_tag_slot(&mapping->page_tree,
-				(void ***)pages, *index, nr_pages, tag);
-	ret = 0;
-	for (i = 0; i < nr_found; i++) {
+	nr_found = ret = 0;
+	radix_tree_for_each_tagged(slot, &mapping->page_tree,
+				   &iter, *index, tag) {
 		struct page *page;
 repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
+		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
 			continue;
 
+		nr_found++;
 		if (radix_tree_exception(page)) {
 			if (radix_tree_deref_retry(page)) {
 				/*
@@ -996,13 +1007,14 @@ repeat:
 			goto repeat;
 
 		/* Has the page moved? */
-		if (unlikely(page != *((void **)pages[i]))) {
+		if (unlikely(page != *slot)) {
 			page_cache_release(page);
 			goto repeat;
 		}
 
 		pages[ret] = page;
-		ret++;
+		if (++ret == nr_pages)
+			goto out;
 	}
 
 	/*
@@ -1011,6 +1023,7 @@ repeat:
 	 */
 	if (unlikely(!ret && nr_found))
 		goto restart;
+out:
 	rcu_read_unlock();
 
 	if (ret)
diff --git a/mm/shmem.c b/mm/shmem.c
index 269d049..5033319 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -316,21 +316,24 @@ static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
 					pgoff_t start, unsigned int nr_pages,
 					struct page **pages, pgoff_t *indices)
 {
-	unsigned int i;
 	unsigned int ret;
 	unsigned int nr_found;
+	struct radix_tree_iter iter;
+	void **slot;
+
+	if (!nr_pages)
+		return 0;
 
 	rcu_read_lock();
 restart:
-	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
-				(void ***)pages, indices, start, nr_pages);
-	ret = 0;
-	for (i = 0; i < nr_found; i++) {
+	nr_found = ret = 0;
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
 		struct page *page;
 repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
+		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
 			continue;
+		nr_found++;
 		if (radix_tree_exception(page)) {
 			if (radix_tree_deref_retry(page))
 				goto restart;
@@ -345,17 +348,19 @@ repeat:
 			goto repeat;
 
 		/* Has the page moved? */
-		if (unlikely(page != *((void **)pages[i]))) {
+		if (unlikely(page != *slot)) {
 			page_cache_release(page);
 			goto repeat;
 		}
 export:
-		indices[ret] = indices[i];
+		indices[ret] = iter.index;
 		pages[ret] = page;
-		ret++;
+		if (++ret == nr_pages)
+			goto out;
 	}
 	if (unlikely(!ret && nr_found))
 		goto restart;
+out:
 	rcu_read_unlock();
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

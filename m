Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 708BB6B1407
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 14:25:53 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so3571094bkt.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 11:25:52 -0800 (PST)
Subject: [PATCH v2 3/3] radix-tree: use iterators in find_get_pages* functions
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 10 Feb 2012 23:25:50 +0400
Message-ID: <20120210192550.5881.10867.stgit@zurg>
In-Reply-To: <20120210191611.5881.12646.stgit@zurg>
References: <20120210191611.5881.12646.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

This patch replaces radix_tree_gang_lookup_slot() and
radix_tree_gang_lookup_tag_slot() in page-cache lookup functions with brand-new
radix-tree direct iterating. This avoids the double-scanning and pointers copying.

Iterator don't stop after nr_pages page-get fails in a row, it continue lookup
till the radix-tree end. Thus we can safely remove these restart conditions.

Unfortunately, old implementation didn't forbid nr_pages == 0, this corner case
does not fit into new code, so there appears extra check at the begining.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/filemap.c |   86 ++++++++++++++++++++++++++--------------------------------
 1 files changed, 38 insertions(+), 48 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index b662757..7625251 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -811,20 +811,19 @@ EXPORT_SYMBOL(find_or_create_page);
 unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 			    unsigned int nr_pages, struct page **pages)
 {
-	unsigned int i;
-	unsigned int ret;
-	unsigned int nr_found, nr_skip;
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned ret = 0;
+
+	if (unlikely(!nr_pages))
+		return 0;
 
 	rcu_read_lock();
 restart:
-	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
-				(void ***)pages, NULL, start, nr_pages);
-	ret = 0;
-	nr_skip = 0;
-	for (i = 0; i < nr_found; i++) {
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
 		struct page *page;
 repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
+		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
 			continue;
 
@@ -835,7 +834,7 @@ repeat:
 				 * when entry at index 0 moves out of or back
 				 * to root: none yet gotten, safe to restart.
 				 */
-				WARN_ON(start | i);
+				WARN_ON(iter.index);
 				goto restart;
 			}
 			/*
@@ -843,7 +842,6 @@ repeat:
 			 * here as an exceptional entry: so skip over it -
 			 * we only reach this from invalidate_mapping_pages().
 			 */
-			nr_skip++;
 			continue;
 		}
 
@@ -851,21 +849,16 @@ repeat:
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
+			break;
 	}
 
-	/*
-	 * If all entries were removed before we could secure them,
-	 * try again, because callers stop trying once 0 is returned.
-	 */
-	if (unlikely(!ret && nr_found > nr_skip))
-		goto restart;
 	rcu_read_unlock();
 	return ret;
 }
@@ -885,21 +878,22 @@ repeat:
 unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 			       unsigned int nr_pages, struct page **pages)
 {
-	unsigned int i;
-	unsigned int ret;
-	unsigned int nr_found;
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned int ret = 0;
+
+	if (unlikely(!nr_pages))
+		return 0;
 
 	rcu_read_lock();
 restart:
-	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
-				(void ***)pages, NULL, index, nr_pages);
-	ret = 0;
-	for (i = 0; i < nr_found; i++) {
+	radix_tree_for_each_contig(slot, &mapping->page_tree, &iter, index) {
 		struct page *page;
 repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
+		page = radix_tree_deref_slot(slot);
+		/* The hole, there no reason to continue */
 		if (unlikely(!page))
-			continue;
+			break;
 
 		if (radix_tree_exception(page)) {
 			if (radix_tree_deref_retry(page)) {
@@ -922,7 +916,7 @@ repeat:
 			goto repeat;
 
 		/* Has the page moved? */
-		if (unlikely(page != *((void **)pages[i]))) {
+		if (unlikely(page != *slot)) {
 			page_cache_release(page);
 			goto repeat;
 		}
@@ -932,14 +926,14 @@ repeat:
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page->index != index) {
+		if (page->mapping == NULL || page->index != iter.index) {
 			page_cache_release(page);
 			break;
 		}
 
 		pages[ret] = page;
-		ret++;
-		index++;
+		if (++ret == nr_pages)
+			break;
 	}
 	rcu_read_unlock();
 	return ret;
@@ -960,19 +954,20 @@ EXPORT_SYMBOL(find_get_pages_contig);
 unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 			int tag, unsigned int nr_pages, struct page **pages)
 {
-	unsigned int i;
-	unsigned int ret;
-	unsigned int nr_found;
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned ret = 0;
+
+	if (unlikely(!nr_pages))
+		return 0;
 
 	rcu_read_lock();
 restart:
-	nr_found = radix_tree_gang_lookup_tag_slot(&mapping->page_tree,
-				(void ***)pages, *index, nr_pages, tag);
-	ret = 0;
-	for (i = 0; i < nr_found; i++) {
+	radix_tree_for_each_tagged(slot, &mapping->page_tree,
+				   &iter, *index, tag) {
 		struct page *page;
 repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
+		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
 			continue;
 
@@ -996,21 +991,16 @@ repeat:
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
+			break;
 	}
 
-	/*
-	 * If all entries were removed before we could secure them,
-	 * try again, because callers stop trying once 0 is returned.
-	 */
-	if (unlikely(!ret && nr_found))
-		goto restart;
 	rcu_read_unlock();
 
 	if (ret)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

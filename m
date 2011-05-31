Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 49A7F6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:52:42 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p4V0qc87029019
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:52:39 -0700
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by kpbe18.cbf.corp.google.com with ESMTP id p4V0qaOc027116
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:52:37 -0700
Received: by pvh11 with SMTP id 11so2139200pvh.8
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:52:36 -0700 (PDT)
Date: Mon, 30 May 2011 17:52:37 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 12/14] mm: consistent truncate and invalidate loops
In-Reply-To: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105301751100.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Make the pagevec_lookup loops in truncate_inode_pages_range(),
invalidate_mapping_pages() and invalidate_inode_pages2_range()
more consistent with each other.

They were relying upon page->index of an unlocked page, but apologizing
for it: accept it, embrace it, add comments and WARN_ONs, and simplify
the index handling.

invalidate_inode_pages2_range() had special handling for a wrapped
page->index + 1 = 0 case; but MAX_LFS_FILESIZE doesn't let us anywhere
near there, and a corrupt page->index in the radix_tree could cause
more trouble than that would catch.  Remove that wrapped handling.

invalidate_inode_pages2_range() uses min() to limit the pagevec_lookup
when near the end of the range: copy that into the other two, although
it's less useful than you might think (it limits the use of the buffer,
rather than the indices looked up).

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/filemap.c  |    2 
 mm/truncate.c |  110 ++++++++++++++++++++----------------------------
 2 files changed, 49 insertions(+), 63 deletions(-)

--- linux.orig/mm/filemap.c	2011-05-30 14:26:54.000000000 -0700
+++ linux/mm/filemap.c	2011-05-30 14:57:02.130905988 -0700
@@ -131,6 +131,7 @@ void __delete_from_page_cache(struct pag
 
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
+	/* Leave page->index set: truncation lookup relies upon it */
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	if (PageSwapBacked(page))
@@ -486,6 +487,7 @@ int add_to_page_cache_locked(struct page
 			spin_unlock_irq(&mapping->tree_lock);
 		} else {
 			page->mapping = NULL;
+			/* Leave page->index set: truncation relies upon it */
 			spin_unlock_irq(&mapping->tree_lock);
 			mem_cgroup_uncharge_cache_page(page);
 			page_cache_release(page);
--- linux.orig/mm/truncate.c	2011-05-30 14:51:03.000000000 -0700
+++ linux/mm/truncate.c	2011-05-30 15:01:01.660093602 -0700
@@ -199,9 +199,6 @@ int invalidate_inode_page(struct page *p
  * The first pass will remove most pages, so the search cost of the second pass
  * is low.
  *
- * When looking at page->index outside the page lock we need to be careful to
- * copy it into a local to avoid races (it could change at any time).
- *
  * We pass down the cache-hot hint to the page freeing code.  Even if the
  * mapping is large, it is probably the case that the final pages are the most
  * recently touched, and freeing happens in ascending file offset order.
@@ -210,10 +207,10 @@ void truncate_inode_pages_range(struct a
 				loff_t lstart, loff_t lend)
 {
 	const pgoff_t start = (lstart + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
-	pgoff_t end;
 	const unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
 	struct pagevec pvec;
-	pgoff_t next;
+	pgoff_t index;
+	pgoff_t end;
 	int i;
 
 	cleancache_flush_inode(mapping);
@@ -224,24 +221,21 @@ void truncate_inode_pages_range(struct a
 	end = (lend >> PAGE_CACHE_SHIFT);
 
 	pagevec_init(&pvec, 0);
-	next = start;
-	while (next <= end &&
-	       pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+	index = start;
+	while (index <= end && pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
-			pgoff_t page_index = page->index;
 
-			if (page_index > end) {
-				next = page_index;
+			/* We rely upon deletion not changing page->index */
+			index = page->index;
+			if (index > end)
 				break;
-			}
 
-			if (page_index > next)
-				next = page_index;
-			next++;
 			if (!trylock_page(page))
 				continue;
+			WARN_ON(page->index != index);
 			if (PageWriteback(page)) {
 				unlock_page(page);
 				continue;
@@ -252,6 +246,7 @@ void truncate_inode_pages_range(struct a
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
+		index++;
 	}
 
 	if (partial) {
@@ -264,13 +259,14 @@ void truncate_inode_pages_range(struct a
 		}
 	}
 
-	next = start;
+	index = start;
 	for ( ; ; ) {
 		cond_resched();
-		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
-			if (next == start)
+		if (!pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+			if (index == start)
 				break;
-			next = start;
+			index = start;
 			continue;
 		}
 		if (pvec.pages[0]->index > end) {
@@ -281,18 +277,20 @@ void truncate_inode_pages_range(struct a
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			if (page->index > end)
+			/* We rely upon deletion not changing page->index */
+			index = page->index;
+			if (index > end)
 				break;
+
 			lock_page(page);
+			WARN_ON(page->index != index);
 			wait_on_page_writeback(page);
 			truncate_inode_page(mapping, page);
-			if (page->index > next)
-				next = page->index;
-			next++;
 			unlock_page(page);
 		}
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
+		index++;
 	}
 	cleancache_flush_inode(mapping);
 }
@@ -328,36 +326,27 @@ unsigned long invalidate_mapping_pages(s
 		pgoff_t start, pgoff_t end)
 {
 	struct pagevec pvec;
-	pgoff_t next = start;
+	pgoff_t index = start;
 	unsigned long ret;
 	unsigned long count = 0;
 	int i;
 
 	cleancache_flush_inode(mapping);
 	pagevec_init(&pvec, 0);
-	while (next <= end &&
-			pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+	while (index <= end && pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
-			pgoff_t index;
-			int lock_failed;
-
-			lock_failed = !trylock_page(page);
 
-			/*
-			 * We really shouldn't be looking at the ->index of an
-			 * unlocked page.  But we're not allowed to lock these
-			 * pages.  So we rely upon nobody altering the ->index
-			 * of this (pinned-by-us) page.
-			 */
+			/* We rely upon deletion not changing page->index */
 			index = page->index;
-			if (index > next)
-				next = index;
-			next++;
-			if (lock_failed)
-				continue;
+			if (index > end)
+				break;
 
+			if (!trylock_page(page))
+				continue;
+			WARN_ON(page->index != index);
 			ret = invalidate_inode_page(page);
 			unlock_page(page);
 			/*
@@ -367,12 +356,11 @@ unsigned long invalidate_mapping_pages(s
 			if (!ret)
 				deactivate_page(page);
 			count += ret;
-			if (next > end)
-				break;
 		}
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
+		index++;
 	}
 	cleancache_flush_inode(mapping);
 	return count;
@@ -439,37 +427,32 @@ int invalidate_inode_pages2_range(struct
 				  pgoff_t start, pgoff_t end)
 {
 	struct pagevec pvec;
-	pgoff_t next;
+	pgoff_t index;
 	int i;
 	int ret = 0;
 	int ret2 = 0;
 	int did_range_unmap = 0;
-	int wrapped = 0;
 
 	cleancache_flush_inode(mapping);
 	pagevec_init(&pvec, 0);
-	next = start;
-	while (next <= end && !wrapped &&
-		pagevec_lookup(&pvec, mapping, next,
-			min(end - next, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+	index = start;
+	while (index <= end && pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
-			pgoff_t page_index;
+
+			/* We rely upon deletion not changing page->index */
+			index = page->index;
+			if (index > end)
+				break;
 
 			lock_page(page);
+			WARN_ON(page->index != index);
 			if (page->mapping != mapping) {
 				unlock_page(page);
 				continue;
 			}
-			page_index = page->index;
-			next = page_index + 1;
-			if (next == 0)
-				wrapped = 1;
-			if (page_index > end) {
-				unlock_page(page);
-				break;
-			}
 			wait_on_page_writeback(page);
 			if (page_mapped(page)) {
 				if (!did_range_unmap) {
@@ -477,9 +460,9 @@ int invalidate_inode_pages2_range(struct
 					 * Zap the rest of the file in one hit.
 					 */
 					unmap_mapping_range(mapping,
-					   (loff_t)page_index<<PAGE_CACHE_SHIFT,
-					   (loff_t)(end - page_index + 1)
-							<< PAGE_CACHE_SHIFT,
+					   (loff_t)index << PAGE_CACHE_SHIFT,
+					   (loff_t)(1 + end - index)
+							 << PAGE_CACHE_SHIFT,
 					    0);
 					did_range_unmap = 1;
 				} else {
@@ -487,8 +470,8 @@ int invalidate_inode_pages2_range(struct
 					 * Just zap this page
 					 */
 					unmap_mapping_range(mapping,
-					  (loff_t)page_index<<PAGE_CACHE_SHIFT,
-					  PAGE_CACHE_SIZE, 0);
+					   (loff_t)index << PAGE_CACHE_SHIFT,
+					   PAGE_CACHE_SIZE, 0);
 				}
 			}
 			BUG_ON(page_mapped(page));
@@ -504,6 +487,7 @@ int invalidate_inode_pages2_range(struct
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
+		index++;
 	}
 	cleancache_flush_inode(mapping);
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

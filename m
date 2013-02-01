Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 39EFB6B0008
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 01:14:03 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: shmem: use new radix tree iterator
Date: Fri,  1 Feb 2013 01:13:58 -0500
Message-Id: <1359699238-7327-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In shmem_find_get_pages_and_swap, use the faster radix tree iterator
construct from 78c1d78 "radix-tree: introduce bit-optimized iterator".

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/shmem.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index a368a1c..c5dc8ae 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -336,19 +336,19 @@ static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
 					pgoff_t start, unsigned int nr_pages,
 					struct page **pages, pgoff_t *indices)
 {
-	unsigned int i;
-	unsigned int ret;
-	unsigned int nr_found;
+	void **slot;
+	unsigned int ret = 0;
+	struct radix_tree_iter iter;
+
+	if (!nr_pages)
+		return 0;
 
 	rcu_read_lock();
 restart:
-	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
-				(void ***)pages, indices, start, nr_pages);
-	ret = 0;
-	for (i = 0; i < nr_found; i++) {
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
 		struct page *page;
 repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
+		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
 			continue;
 		if (radix_tree_exception(page)) {
@@ -365,17 +365,16 @@ static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
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
+			break;
 	}
-	if (unlikely(!ret && nr_found))
-		goto restart;
 	rcu_read_unlock();
 	return ret;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

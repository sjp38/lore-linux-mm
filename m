Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ADAF48D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 05:49:28 -0500 (EST)
Received: by pvc30 with SMTP id 30so858430pvc.14
        for <linux-mm@kvack.org>; Sun, 06 Feb 2011 02:49:26 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v4 6/6] Change __remove_from_page_cache
Date: Sun,  6 Feb 2011 19:48:05 +0900
Message-Id: <5bd48329d286d68ecef1f8856ccffdbc9b81f827.1296987110.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1296987110.git.minchan.kim@gmail.com>
References: <cover.1296987110.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1296987110.git.minchan.kim@gmail.com>
References: <cover.1296987110.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>

Now we renamed remove_from_page_cache with delete_from_page_cache.
As consistency of __remove_from_swap_cache and remove_from_swap_cache,
We change internal page cache handling function name, too.

Cc: Christoph Hellwig <hch@infradead.org>
Acked-by: Hugh Dickins <hughd@google.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/pagemap.h |    2 +-
 mm/filemap.c            |    8 ++++----
 mm/memory-failure.c     |    2 +-
 mm/truncate.c           |    2 +-
 mm/vmscan.c             |    2 +-
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 631b1b6..e407601 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -455,7 +455,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
-extern void __remove_from_page_cache(struct page *page);
+extern void __delete_from_page_cache(struct page *page);
 extern void delete_from_page_cache(struct page *page);
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 5f3a389..351571f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -109,11 +109,11 @@
  */
 
 /*
- * Remove a page from the page cache and free it. Caller has to make
+ * Delete a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.  The caller must hold the mapping's tree_lock.
  */
-void __remove_from_page_cache(struct page *page)
+void __delete_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
 
@@ -166,7 +166,7 @@ void delete_from_page_cache(struct page *page)
 
 	freepage = mapping->a_ops->freepage;
 	spin_lock_irq(&mapping->tree_lock);
-	__remove_from_page_cache(page);
+	__delete_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 
@@ -453,7 +453,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		new->index = offset;
 
 		spin_lock_irq(&mapping->tree_lock);
-		__remove_from_page_cache(old);
+		__delete_from_page_cache(old);
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
 		BUG_ON(error);
 		mapping->nrpages++;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 0207c2f..f15ceea 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1130,7 +1130,7 @@ int __memory_failure(unsigned long pfn, int trapno, int flags)
 
 	/*
 	 * Now take care of user space mappings.
-	 * Abort on fail: __remove_from_page_cache() assumes unmapped page.
+	 * Abort on fail: __delete_from_page_cache() assumes unmapped page.
 	 */
 	if (hwpoison_user_mappings(p, pfn, trapno) != SWAP_SUCCESS) {
 		printk(KERN_ERR "MCE %#lx: cannot unmap page, give up\n", pfn);
diff --git a/mm/truncate.c b/mm/truncate.c
index faf65a5..94be6c0 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -394,7 +394,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 
 	clear_page_mlock(page);
 	BUG_ON(page_has_private(page));
-	__remove_from_page_cache(page);
+	__delete_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 148c6e6..43bfc4e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -514,7 +514,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 
 		freepage = mapping->a_ops->freepage;
 
-		__remove_from_page_cache(page);
+		__delete_from_page_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_cache_page(page);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

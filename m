Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5AAD66B0081
	for <linux-mm@kvack.org>; Tue,  1 May 2012 04:43:19 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/5] mm + fs: store shadow pages in page cache
Date: Tue,  1 May 2012 10:41:51 +0200
Message-Id: <1335861713-4573-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Reclaim will be leaving shadow entries in the page cache radix tree
upon evicting the real page.  As those pages are found from the LRU,
an iput() can lead to the inode being freed concurrently.  At this
point, reclaim must no longer install shadow pages because the inode
freeing code needs to ensure the page tree is really empty.

Add an address_space flag, AS_EXITING, that the inode freeing code
sets under the tree lock before doing the final truncate.  Reclaim
will check for this flag before installing shadow pages.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/inode.c              |    4 ++++
 include/linux/pagemap.h |   13 ++++++++++++-
 mm/filemap.c            |   14 ++++++++++----
 mm/truncate.c           |    2 +-
 mm/vmscan.c             |    2 +-
 5 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 645731f..9be6bac 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -541,6 +541,10 @@ static void evict(struct inode *inode)
 
 	inode_sb_list_del(inode);
 
+	spin_lock_irq(&inode->i_data.tree_lock);
+	mapping_set_exiting(&inode->i_data);
+	spin_unlock_irq(&inode->i_data.tree_lock);
+
 	if (op->evict_inode) {
 		op->evict_inode(inode);
 	} else {
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index aba5b91..c1abb88 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -24,6 +24,7 @@ enum mapping_flags {
 	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
+	AS_EXITING	= __GFP_BITS_SHIFT + 4, /* inode is being evicted */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -53,6 +54,16 @@ static inline int mapping_unevictable(struct address_space *mapping)
 	return !!mapping;
 }
 
+static inline void mapping_set_exiting(struct address_space *mapping)
+{
+	set_bit(AS_EXITING, &mapping->flags);
+}
+
+static inline int mapping_exiting(struct address_space *mapping)
+{
+	return test_bit(AS_EXITING, &mapping->flags);
+}
+
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
 	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
@@ -458,7 +469,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 extern void delete_from_page_cache(struct page *page);
-extern void __delete_from_page_cache(struct page *page);
+extern void __delete_from_page_cache(struct page *page, void *shadow);
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index b8af34a..4ca12a3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -111,7 +111,7 @@
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.  The caller must hold the mapping's tree_lock.
  */
-void __delete_from_page_cache(struct page *page)
+void __delete_from_page_cache(struct page *page, void *shadow)
 {
 	struct address_space *mapping = page->mapping;
 
@@ -125,7 +125,13 @@ void __delete_from_page_cache(struct page *page)
 	else
 		cleancache_flush_page(mapping, page);
 
-	radix_tree_delete(&mapping->page_tree, page->index);
+	if (shadow && !mapping_exiting(mapping)) {
+		void **slot;
+
+		slot = radix_tree_lookup_slot(&mapping->page_tree, page->index);
+		radix_tree_replace_slot(slot, shadow);
+	} else
+		radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
 	mapping->nrpages--;
@@ -164,7 +170,7 @@ void delete_from_page_cache(struct page *page)
 
 	freepage = mapping->a_ops->freepage;
 	spin_lock_irq(&mapping->tree_lock);
-	__delete_from_page_cache(page);
+	__delete_from_page_cache(page, NULL);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 
@@ -411,7 +417,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		new->index = offset;
 
 		spin_lock_irq(&mapping->tree_lock);
-		__delete_from_page_cache(old);
+		__delete_from_page_cache(old, NULL);
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
 		BUG_ON(error);
 		mapping->nrpages++;
diff --git a/mm/truncate.c b/mm/truncate.c
index d8c8964..0f6f700 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -433,7 +433,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 
 	clear_page_mlock(page);
 	BUG_ON(page_has_private(page));
-	__delete_from_page_cache(page);
+	__delete_from_page_cache(page, NULL);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c52b235..44d81f5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -585,7 +585,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 
 		freepage = mapping->a_ops->freepage;
 
-		__delete_from_page_cache(page);
+		__delete_from_page_cache(page, NULL);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_cache_page(page);
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

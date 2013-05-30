Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 786C26B0039
	for <linux-mm@kvack.org>; Thu, 30 May 2013 14:04:47 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 06/10] mm + fs: store shadow entries in page cache
Date: Thu, 30 May 2013 14:04:02 -0400
Message-Id: <1369937046-27666-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
References: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

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
 fs/inode.c              |  7 ++++++-
 fs/nilfs2/inode.c       |  4 ++--
 include/linux/fs.h      |  1 +
 include/linux/pagemap.h | 13 ++++++++++++-
 mm/filemap.c            | 16 ++++++++++++----
 mm/truncate.c           |  5 +++--
 mm/vmscan.c             |  2 +-
 7 files changed, 37 insertions(+), 11 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index a898b3d..3bd7916 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -509,6 +509,7 @@ void clear_inode(struct inode *inode)
 	 */
 	spin_lock_irq(&inode->i_data.tree_lock);
 	BUG_ON(inode->i_data.nrpages);
+	BUG_ON(inode->i_data.nrshadows);
 	spin_unlock_irq(&inode->i_data.tree_lock);
 	BUG_ON(!list_empty(&inode->i_data.private_list));
 	BUG_ON(!(inode->i_state & I_FREEING));
@@ -551,10 +552,14 @@ static void evict(struct inode *inode)
 	 */
 	inode_wait_for_writeback(inode);
 
+	spin_lock_irq(&inode->i_data.tree_lock);
+	mapping_set_exiting(&inode->i_data);
+	spin_unlock_irq(&inode->i_data.tree_lock);
+
 	if (op->evict_inode) {
 		op->evict_inode(inode);
 	} else {
-		if (inode->i_data.nrpages)
+		if (inode->i_data.nrpages || inode->i_data.nrshadows)
 			truncate_inode_pages(&inode->i_data, 0);
 		clear_inode(inode);
 	}
diff --git a/fs/nilfs2/inode.c b/fs/nilfs2/inode.c
index 6b49f14..fbc3f00 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -747,7 +747,7 @@ void nilfs_evict_inode(struct inode *inode)
 	int ret;
 
 	if (inode->i_nlink || !ii->i_root || unlikely(is_bad_inode(inode))) {
-		if (inode->i_data.nrpages)
+		if (inode->i_data.nrpages || inode->i_data.nrshadows)
 			truncate_inode_pages(&inode->i_data, 0);
 		clear_inode(inode);
 		nilfs_clear_inode(inode);
@@ -755,7 +755,7 @@ void nilfs_evict_inode(struct inode *inode)
 	}
 	nilfs_transaction_begin(sb, &ti, 0); /* never fails */
 
-	if (inode->i_data.nrpages)
+	if (inode->i_data.nrpages || inode->i_data.nrshadows)
 		truncate_inode_pages(&inode->i_data, 0);
 
 	/* TODO: some of the following operations may fail.  */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2c28271..5bf1d99 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -413,6 +413,7 @@ struct address_space {
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
+	unsigned long		nrshadows;	/* number of shadow entries */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index a972341..258eb38 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -25,6 +25,7 @@ enum mapping_flags {
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
 	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
+	AS_EXITING	= __GFP_BITS_SHIFT + 5, /* inode is being evicted */
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
@@ -69,6 +70,16 @@ static inline int mapping_balloon(struct address_space *mapping)
 	return mapping && test_bit(AS_BALLOON_MAP, &mapping->flags);
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
@@ -547,7 +558,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 extern void delete_from_page_cache(struct page *page);
-extern void __delete_from_page_cache(struct page *page);
+extern void __delete_from_page_cache(struct page *page, void *shadow);
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index df9a1db..dd0835e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -109,7 +109,7 @@
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.  The caller must hold the mapping's tree_lock.
  */
-void __delete_from_page_cache(struct page *page)
+void __delete_from_page_cache(struct page *page, void *shadow)
 {
 	struct address_space *mapping = page->mapping;
 
@@ -123,7 +123,14 @@ void __delete_from_page_cache(struct page *page)
 	else
 		cleancache_invalidate_page(mapping, page);
 
-	radix_tree_delete(&mapping->page_tree, page->index);
+	if (shadow) {
+		void **slot;
+
+		slot = radix_tree_lookup_slot(&mapping->page_tree, page->index);
+		radix_tree_replace_slot(slot, shadow);
+		mapping->nrshadows++;
+	} else
+		radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
 	mapping->nrpages--;
@@ -162,7 +169,7 @@ void delete_from_page_cache(struct page *page)
 
 	freepage = mapping->a_ops->freepage;
 	spin_lock_irq(&mapping->tree_lock);
-	__delete_from_page_cache(page);
+	__delete_from_page_cache(page, NULL);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 
@@ -409,7 +416,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		new->index = offset;
 
 		spin_lock_irq(&mapping->tree_lock);
-		__delete_from_page_cache(old);
+		__delete_from_page_cache(old, NULL);
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
 		BUG_ON(error);
 		mapping->nrpages++;
@@ -442,6 +449,7 @@ static int page_cache_insert(struct address_space *mapping, pgoff_t offset,
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
 		radix_tree_replace_slot(slot, page);
+		mapping->nrshadows--;
 		return 0;
 	}
 	return radix_tree_insert(&mapping->page_tree, offset, page);
diff --git a/mm/truncate.c b/mm/truncate.c
index d6ec30c..c1a5147 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -35,7 +35,8 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	 * without the tree itself locked.  These unlocked entries
 	 * need verification under the tree lock.
 	 */
-	radix_tree_delete_item(&mapping->page_tree, index, page);
+	if (radix_tree_delete_item(&mapping->page_tree, index, page) == page)
+		mapping->nrshadows--;
 	spin_unlock_irq(&mapping->tree_lock);
 }
 
@@ -434,7 +435,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 		goto failed;
 
 	BUG_ON(page_has_private(page));
-	__delete_from_page_cache(page);
+	__delete_from_page_cache(page, NULL);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 669fba3..ff0d92f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -498,7 +498,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 
 		freepage = mapping->a_ops->freepage;
 
-		__delete_from_page_cache(page);
+		__delete_from_page_cache(page, NULL);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_cache_page(page);
 
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

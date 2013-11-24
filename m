Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6D30A6B0044
	for <linux-mm@kvack.org>; Sun, 24 Nov 2013 18:39:28 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id w11so1641006bkz.1
        for <linux-mm@kvack.org>; Sun, 24 Nov 2013 15:39:27 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id a9si8750003bko.132.2013.11.24.15.39.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 24 Nov 2013 15:39:27 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/9] mm + fs: store shadow entries in page cache
Date: Sun, 24 Nov 2013 18:38:25 -0500
Message-Id: <1385336308-27121-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

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
 fs/block_dev.c          |  2 +-
 fs/inode.c              | 18 +++++++++++++++++-
 fs/nilfs2/inode.c       |  4 ++--
 include/linux/fs.h      |  1 +
 include/linux/pagemap.h | 13 ++++++++++++-
 mm/filemap.c            | 23 +++++++++++++++++++----
 mm/truncate.c           |  7 ++++---
 mm/vmscan.c             |  2 +-
 8 files changed, 57 insertions(+), 13 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 1e86823..391ffe5 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -83,7 +83,7 @@ void kill_bdev(struct block_device *bdev)
 {
 	struct address_space *mapping = bdev->bd_inode->i_mapping;
 
-	if (mapping->nrpages == 0)
+	if (mapping->nrpages == 0 && mapping->nrshadows == 0)
 		return;
 
 	invalidate_bh_lrus();
diff --git a/fs/inode.c b/fs/inode.c
index b33ba8e..7858fb7 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -503,6 +503,7 @@ void clear_inode(struct inode *inode)
 	 */
 	spin_lock_irq(&inode->i_data.tree_lock);
 	BUG_ON(inode->i_data.nrpages);
+	BUG_ON(inode->i_data.nrshadows);
 	spin_unlock_irq(&inode->i_data.tree_lock);
 	BUG_ON(!list_empty(&inode->i_data.private_list));
 	BUG_ON(!(inode->i_state & I_FREEING));
@@ -545,10 +546,25 @@ static void evict(struct inode *inode)
 	 */
 	inode_wait_for_writeback(inode);
 
+	/*
+	 * Page reclaim can not do iput() and thus can race with the
+	 * inode teardown.  Tell it when the address space is exiting,
+	 * so that it does not install eviction information after the
+	 * final truncate has begun.
+	 *
+	 * As truncation uses a lockless tree lookup, acquire the
+	 * spinlock to make sure any ongoing tree modification that
+	 * does not see AS_EXITING is completed before starting the
+	 * final truncate.
+	 */
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
index 7e350c5..42fcbe3 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -783,7 +783,7 @@ void nilfs_evict_inode(struct inode *inode)
 	int ret;
 
 	if (inode->i_nlink || !ii->i_root || unlikely(is_bad_inode(inode))) {
-		if (inode->i_data.nrpages)
+		if (inode->i_data.nrpages || inode->i_data.nrshadows)
 			truncate_inode_pages(&inode->i_data, 0);
 		clear_inode(inode);
 		nilfs_clear_inode(inode);
@@ -791,7 +791,7 @@ void nilfs_evict_inode(struct inode *inode)
 	}
 	nilfs_transaction_begin(sb, &ti, 0); /* never fails */
 
-	if (inode->i_data.nrpages)
+	if (inode->i_data.nrpages || inode->i_data.nrshadows)
 		truncate_inode_pages(&inode->i_data, 0);
 
 	/* TODO: some of the following operations may fail.  */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3f40547..9bfa5a5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -416,6 +416,7 @@ struct address_space {
 	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
 	/* Protected by tree_lock together with the radix tree */
 	unsigned long		nrpages;	/* number of total pages */
+	unsigned long		nrshadows;	/* number of shadow entries */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index b6854b7..f132fdf 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -25,6 +25,7 @@ enum mapping_flags {
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
 	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
+	AS_EXITING	= __GFP_BITS_SHIFT + 5, /* final truncate in progress */
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
index 007b49d..9761f6a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -107,12 +107,25 @@
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
+static void page_cache_tree_delete(struct address_space *mapping,
+				   struct page *page, void *shadow)
+{
+	if (shadow) {
+		void **slot;
+
+		slot = radix_tree_lookup_slot(&mapping->page_tree, page->index);
+		radix_tree_replace_slot(slot, shadow);
+		mapping->nrshadows++;
+	} else
+		radix_tree_delete(&mapping->page_tree, page->index);
+}
+
 /*
  * Delete a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.  The caller must hold the mapping's tree_lock.
  */
-void __delete_from_page_cache(struct page *page)
+void __delete_from_page_cache(struct page *page, void *shadow)
 {
 	struct address_space *mapping = page->mapping;
 
@@ -127,7 +140,8 @@ void __delete_from_page_cache(struct page *page)
 	else
 		cleancache_invalidate_page(mapping, page);
 
-	radix_tree_delete(&mapping->page_tree, page->index);
+	page_cache_tree_delete(mapping, page, shadow);
+
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
 	mapping->nrpages--;
@@ -166,7 +180,7 @@ void delete_from_page_cache(struct page *page)
 
 	freepage = mapping->a_ops->freepage;
 	spin_lock_irq(&mapping->tree_lock);
-	__delete_from_page_cache(page);
+	__delete_from_page_cache(page, NULL);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 
@@ -426,7 +440,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		new->index = offset;
 
 		spin_lock_irq(&mapping->tree_lock);
-		__delete_from_page_cache(old);
+		__delete_from_page_cache(old, NULL);
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
 		BUG_ON(error);
 		mapping->nrpages++;
@@ -459,6 +473,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
 		radix_tree_replace_slot(slot, page);
+		mapping->nrshadows--;
 		return 0;
 	}
 	return radix_tree_insert(&mapping->page_tree, page->index, page);
diff --git a/mm/truncate.c b/mm/truncate.c
index b0f4d4b..cbd0167 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -35,7 +35,8 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	 * without the tree itself locked.  These unlocked entries
 	 * need verification under the tree lock.
 	 */
-	radix_tree_delete_item(&mapping->page_tree, index, entry);
+	if (radix_tree_delete_item(&mapping->page_tree, index, entry) == entry)
+		mapping->nrshadows--;
 	spin_unlock_irq(&mapping->tree_lock);
 }
 
@@ -229,7 +230,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	int		i;
 
 	cleancache_invalidate_inode(mapping);
-	if (mapping->nrpages == 0)
+	if (mapping->nrpages == 0 && mapping->nrshadows == 0)
 		return;
 
 	/* Offsets within partial pages */
@@ -483,7 +484,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 		goto failed;
 
 	BUG_ON(page_has_private(page));
-	__delete_from_page_cache(page);
+	__delete_from_page_cache(page, NULL);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index eea668d..b954b31 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -554,7 +554,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 
 		freepage = mapping->a_ops->freepage;
 
-		__delete_from_page_cache(page);
+		__delete_from_page_cache(page, NULL);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_cache_page(page);
 
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 6 Mar 2007 13:49:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [7/16] change caller's gfp_mask
Message-Id: <20070306134946.bc3453a2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Changes callers of GFP_HIGHUSER to use GFP_HIGH_MOVABLE if it can
some of alloc_zeroed_user_highpage are changed to
alloc_zeroed_user_high_movable.

I think I need more study in this area.

Signed-Off-By: KAMEZAWA Hiruyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/inode.c         |    6 +++++-
 fs/namei.c         |    1 +
 fs/ramfs/inode.c   |    1 +
 mm/filemap.c       |    2 +-
 mm/memory.c        |    8 ++++----
 mm/mempolicy.c     |    4 ++--
 mm/migrate.c       |    2 +-
 mm/shmem.c         |    5 ++++-
 mm/swap_prefetch.c |    2 +-
 mm/swap_state.c    |    2 +-
 10 files changed, 21 insertions(+), 12 deletions(-)

Index: devel-tree-2.6.20-mm2/fs/inode.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/fs/inode.c
+++ devel-tree-2.6.20-mm2/fs/inode.c
@@ -145,7 +145,7 @@ static struct inode *alloc_inode(struct 
 		mapping->a_ops = &empty_aops;
  		mapping->host = inode;
 		mapping->flags = 0;
-		mapping_set_gfp_mask(mapping, GFP_HIGHUSER);
+		mapping_set_gfp_mask(mapping, GFP_HIGH_MOVABLE);
 		mapping->assoc_mapping = NULL;
 		mapping->backing_dev_info = &default_backing_dev_info;
 
@@ -522,6 +522,10 @@ repeat:
  *	@sb: superblock
  *
  *	Allocates a new inode for given superblock.
+ *	Newly allocated inode's gfp_flag is set to GFP_HIGH_MOVABLE(default).
+ *	If fs doesn't support page migration, is hould be overriden
+ *	by GFP_HIGHUSER.
+ *	mapping_set_gfp_mask() can be used for this purpose.
  */
 struct inode *new_inode(struct super_block *sb)
 {
Index: devel-tree-2.6.20-mm2/fs/ramfs/inode.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/fs/ramfs/inode.c
+++ devel-tree-2.6.20-mm2/fs/ramfs/inode.c
@@ -61,6 +61,7 @@ struct inode *ramfs_get_inode(struct sup
 		inode->i_blocks = 0;
 		inode->i_mapping->a_ops = &ramfs_aops;
 		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
+		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		switch (mode & S_IFMT) {
 		default:
Index: devel-tree-2.6.20-mm2/mm/memory.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/memory.c
+++ devel-tree-2.6.20-mm2/mm/memory.c
@@ -1761,11 +1761,11 @@ gotten:
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
 	if (old_page == ZERO_PAGE(address)) {
-		new_page = alloc_zeroed_user_highpage(vma, address);
+		new_page = alloc_zeroed_user_highmovable(vma, address);
 		if (!new_page)
 			goto oom;
 	} else {
-		new_page = alloc_page_vma(GFP_HIGHUSER, vma, address);
+		new_page = alloc_page_vma(GFP_HIGH_MOVABLE, vma, address);
 		if (!new_page)
 			goto oom;
 		cow_user_page(new_page, old_page, address, vma);
@@ -2283,7 +2283,7 @@ static int do_anonymous_page(struct mm_s
 
 		if (unlikely(anon_vma_prepare(vma)))
 			goto oom;
-		page = alloc_zeroed_user_highpage(vma, address);
+		page = alloc_zeroed_user_highmovable(vma, address);
 		if (!page)
 			goto oom;
 
@@ -2384,7 +2384,7 @@ retry:
 
 			if (unlikely(anon_vma_prepare(vma)))
 				goto oom;
-			page = alloc_page_vma(GFP_HIGHUSER, vma, address);
+			page = alloc_page_vma(GFP_HIGH_MOVABLE, vma, address);
 			if (!page)
 				goto oom;
 			copy_user_highpage(page, new_page, address, vma);
Index: devel-tree-2.6.20-mm2/mm/mempolicy.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/mempolicy.c
+++ devel-tree-2.6.20-mm2/mm/mempolicy.c
@@ -603,7 +603,7 @@ static void migrate_page_add(struct page
 
 static struct page *new_node_page(struct page *page, unsigned long node, int **x)
 {
-	return alloc_pages_node(node, GFP_HIGHUSER, 0);
+	return alloc_pages_node(node, GFP_HIGH_MOVABLE, 0);
 }
 
 /*
@@ -719,7 +719,7 @@ static struct page *new_vma_page(struct 
 {
 	struct vm_area_struct *vma = (struct vm_area_struct *)private;
 
-	return alloc_page_vma(GFP_HIGHUSER, vma, page_address_in_vma(page, vma));
+	return alloc_page_vma(GFP_HIGH_MOVABLE, vma, page_address_in_vma(page, vma));
 }
 #else
 
Index: devel-tree-2.6.20-mm2/mm/migrate.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/migrate.c
+++ devel-tree-2.6.20-mm2/mm/migrate.c
@@ -755,7 +755,7 @@ static struct page *new_page_node(struct
 
 	*result = &pm->status;
 
-	return alloc_pages_node(pm->node, GFP_HIGHUSER | GFP_THISNODE, 0);
+	return alloc_pages_node(pm->node, GFP_HIGH_MOVABLE | GFP_THISNODE, 0);
 }
 
 /*
Index: devel-tree-2.6.20-mm2/mm/shmem.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/shmem.c
+++ devel-tree-2.6.20-mm2/mm/shmem.c
@@ -93,8 +93,11 @@ static inline struct page *shmem_dir_all
 	 * The above definition of ENTRIES_PER_PAGE, and the use of
 	 * BLOCKS_PER_PAGE on indirect pages, assume PAGE_CACHE_SIZE:
 	 * might be reconsidered if it ever diverges from PAGE_SIZE.
+	 *
+	 * shmem's dir is not movable page.
 	 */
-	return alloc_pages(gfp_mask, PAGE_CACHE_SHIFT-PAGE_SHIFT);
+	return alloc_pages(gfp_mask & ~__GFP_MOVABLE,
+				PAGE_CACHE_SHIFT-PAGE_SHIFT);
 }
 
 static inline void shmem_dir_free(struct page *page)
Index: devel-tree-2.6.20-mm2/mm/swap_prefetch.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/swap_prefetch.c
+++ devel-tree-2.6.20-mm2/mm/swap_prefetch.c
@@ -204,7 +204,7 @@ static enum trickle_return trickle_swap_
 	 * Get a new page to read from swap. We have already checked the
 	 * watermarks so __alloc_pages will not call on reclaim.
 	 */
-	page = alloc_pages_node(node, GFP_HIGHUSER & ~__GFP_WAIT, 0);
+	page = alloc_pages_node(node, GFP_HIGH_MOVABLE & ~__GFP_WAIT, 0);
 	if (unlikely(!page)) {
 		ret = TRICKLE_DELAY;
 		goto out;
Index: devel-tree-2.6.20-mm2/mm/swap_state.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/swap_state.c
+++ devel-tree-2.6.20-mm2/mm/swap_state.c
@@ -340,7 +340,7 @@ struct page *read_swap_cache_async(swp_e
 		 * Get a new page to read into from swap.
 		 */
 		if (!new_page) {
-			new_page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
+			new_page = alloc_page_vma(GFP_HIGH_MOVABLE, vma, addr);
 			if (!new_page)
 				break;		/* Out of memory */
 		}
Index: devel-tree-2.6.20-mm2/fs/namei.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/fs/namei.c
+++ devel-tree-2.6.20-mm2/fs/namei.c
@@ -2691,6 +2691,7 @@ int __page_symlink(struct inode *inode, 
 	int err;
 	char *kaddr;
 
+	gfp_mask &= ~(__GFP_MOVABLE);
 retry:
 	err = -ENOMEM;
 	page = find_or_create_page(mapping, 0, gfp_mask);
Index: devel-tree-2.6.20-mm2/mm/filemap.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/mm/filemap.c
+++ devel-tree-2.6.20-mm2/mm/filemap.c
@@ -423,7 +423,7 @@ int filemap_write_and_wait_range(struct 
 int add_to_page_cache(struct page *page, struct address_space *mapping,
 		pgoff_t offset, gfp_t gfp_mask)
 {
-	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	int error = radix_tree_preload(gfp_mask & ~(__GFP_HIGHMEM | __GFP_MOVABLE));
 
 	if (error == 0) {
 		write_lock_irq(&mapping->tree_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

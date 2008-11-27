Date: Thu, 27 Nov 2008 18:14:18 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/2] mm: pagecache allocation gfp fixes
In-Reply-To: <20081127101837.GJ28285@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0811271749100.17307@blonde.site>
References: <20081127093401.GE28285@wotan.suse.de>
 <84144f020811270152i5d5c50a8i9dbd78aa4a7da646@mail.gmail.com>
 <20081127101837.GJ28285@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Nov 2008, Nick Piggin wrote:
> On Thu, Nov 27, 2008 at 11:52:40AM +0200, Pekka Enberg wrote:
> > > -               err = add_to_page_cache_lru(page, mapping, index, gfp_mask);
> > > +               err = add_to_page_cache_lru(page, mapping, index,
> > > +                       (gfp_mask & (__GFP_FS|__GFP_IO|__GFP_WAIT|__GFP_HIGH)));
> > 
> > Can we use GFP_RECLAIM_MASK here? I mean, surely we need to pass
> > __GFP_NOFAIL, for example, down to radix_tree_preload() et al?

I certainly agree with Pekka's suggestion to use GFP_RECLAIM_MASK.

> 
> Updated patch.

I'm not sure about it.  I came here before 2.6.25, not yet got around
to submitting, I went in the opposite direction.  What drove me was an
irritation at the growing number of & ~__GFP_HIGHMEMs (after adding a
couple myself in shmem.c).  At the least, I think we ought to change
those to & GFP_RECLAIM_MASKs (it seems we don't have one, but can
imagine a block driver that wants GFP_DMA or GFP_DMA32 for pagecache:
there's no reason to alloc its kernel-internal data structures for DMA).

My patch went the opposite direction to yours, in that I was pushing
down the GFP_RECLAIM_MASKing into lib/radix-tree.c and mm/memcontrol.c
(but that now doesn't kmalloc for itself, so no longer needs the mask).

I'm not sure which way is the right way: you can say I'm inconsistent
not to push it down into slab/sleb/slib/slob/slub itself, but I've a
notion that someone might object to any extra intrns in their hotpaths.

My design principle, I think, was to minimize the line length of
the maximum number of source lines: you may believe in other
design principles of higher value.

Updating it quickly to 2.6.28-rc6, built but untested, here's mine.
I'm not saying it's the right approach and yours wrong, just please
consider it before deciding on which way to go.

I've left in the hunk from fs/buffer.c in case you can decipher it,
I think that's what held me up from submitting: I've never worked
out since whether that change is a profound insight into reality
here, or just a blind attempt to reduce the line length.

 fs/buffer.c      |    3 +--
 lib/radix-tree.c |    5 +++--
 mm/filemap.c     |   11 ++++++-----
 mm/shmem.c       |    4 ++--
 mm/swap_state.c  |    2 +-
 5 files changed, 13 insertions(+), 12 deletions(-)

--- 2.6.28-rc6/fs/buffer.c	2008-10-24 09:28:16.000000000 +0100
+++ linux/fs/buffer.c	2008-11-27 13:30:58.000000000 +0000
@@ -1031,8 +1031,7 @@ grow_dev_page(struct block_device *bdev,
 	struct page *page;
 	struct buffer_head *bh;
 
-	page = find_or_create_page(inode->i_mapping, index,
-		(mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS)|__GFP_MOVABLE);
+	page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
 	if (!page)
 		return NULL;
 
--- 2.6.28-rc6/lib/radix-tree.c	2008-10-09 23:13:53.000000000 +0100
+++ linux/lib/radix-tree.c	2008-11-27 13:30:58.000000000 +0000
@@ -85,7 +85,7 @@ DEFINE_PER_CPU(struct radix_tree_preload
 
 static inline gfp_t root_gfp_mask(struct radix_tree_root *root)
 {
-	return root->gfp_mask & __GFP_BITS_MASK;
+	return root->gfp_mask & GFP_RECLAIM_MASK;
 }
 
 static inline void tag_set(struct radix_tree_node *node, unsigned int tag,
@@ -211,7 +211,8 @@ int radix_tree_preload(gfp_t gfp_mask)
 	rtp = &__get_cpu_var(radix_tree_preloads);
 	while (rtp->nr < ARRAY_SIZE(rtp->nodes)) {
 		preempt_enable();
-		node = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
+		node = kmem_cache_alloc(radix_tree_node_cachep,
+					gfp_mask & GFP_RECLAIM_MASK);
 		if (node == NULL)
 			goto out;
 		preempt_disable();
--- 2.6.28-rc6/mm/filemap.c	2008-11-02 23:17:56.000000000 +0000
+++ linux/mm/filemap.c	2008-11-27 13:30:58.000000000 +0000
@@ -459,12 +459,11 @@ int add_to_page_cache_locked(struct page
 
 	VM_BUG_ON(!PageLocked(page));
 
-	error = mem_cgroup_cache_charge(page, current->mm,
-					gfp_mask & ~__GFP_HIGHMEM);
+	error = mem_cgroup_cache_charge(page, current->mm, gfp_mask);
 	if (error)
 		goto out;
 
-	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	error = radix_tree_preload(gfp_mask);
 	if (error == 0) {
 		page_cache_get(page);
 		page->mapping = mapping;
@@ -942,6 +941,7 @@ struct page *
 grab_cache_page_nowait(struct address_space *mapping, pgoff_t index)
 {
 	struct page *page = find_get_page(mapping, index);
+	gfp_t gfp_mask;
 
 	if (page) {
 		if (trylock_page(page))
@@ -949,8 +949,9 @@ grab_cache_page_nowait(struct address_sp
 		page_cache_release(page);
 		return NULL;
 	}
-	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS);
-	if (page && add_to_page_cache_lru(page, mapping, index, GFP_KERNEL)) {
+	gfp_mask = mapping_gfp_mask(mapping) & ~__GFP_FS;
+	page = __page_cache_alloc(gfp_mask);
+	if (page && add_to_page_cache_lru(page, mapping, index, gfp_mask)) {
 		page_cache_release(page);
 		page = NULL;
 	}
--- 2.6.28-rc6/mm/shmem.c	2008-11-02 23:17:56.000000000 +0000
+++ linux/mm/shmem.c	2008-11-27 13:30:58.000000000 +0000
@@ -1214,7 +1214,7 @@ repeat:
 		 * Try to preload while we can wait, to not make a habit of
 		 * draining atomic reserves; but don't latch on to this cpu.
 		 */
-		error = radix_tree_preload(gfp & ~__GFP_HIGHMEM);
+		error = radix_tree_preload(gfp);
 		if (error)
 			goto failed;
 		radix_tree_preload_end();
@@ -1371,7 +1371,7 @@ repeat:
 
 			/* Precharge page while we can wait, compensate after */
 			error = mem_cgroup_cache_charge(filepage, current->mm,
-							gfp & ~__GFP_HIGHMEM);
+							gfp);
 			if (error) {
 				page_cache_release(filepage);
 				shmem_unacct_blocks(info->flags, 1);
--- 2.6.28-rc6/mm/swap_state.c	2008-10-24 09:28:26.000000000 +0100
+++ linux/mm/swap_state.c	2008-11-27 13:30:58.000000000 +0000
@@ -305,7 +305,7 @@ struct page *read_swap_cache_async(swp_e
 		 */
 		__set_page_locked(new_page);
 		SetPageSwapBacked(new_page);
-		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
+		err = add_to_swap_cache(new_page, entry, gfp_mask);
 		if (likely(!err)) {
 			/*
 			 * Initiate read into locked page and return.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

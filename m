Date: Thu, 8 Nov 2007 01:43:04 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] radix-tree: avoid atomic allocations for preloaded insertions
Message-ID: <20071108004304.GD3227@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

OK, here's this patch again. This time I come with real failures on real
systems (in this case, David is running some 'dd' pagecache throughput
tests).

I haven't got him to retest it yet, but I think the idea is just a no-brainer.
We significantly reduce maximum tree_lock(W) hold time, and we reduce the
amount of GFP_ATOMIC allocations.

--

Most pagecache (and some other) radix tree insertions have the great
opportunity to preallocate a few nodes with relaxed gfp flags. But
the preallocation is squandered when it comes time to allocate a node,
we default to first attempting a GFP_ATOMIC allocation -- that doesn't
normally fail, but it can eat into atomic memory reserves that we
don't need to be using.

Another upshot of this is that it removes the sometimes highly contended
zone->lock from underneath tree_lock.

David Miller reports seeing this allocation fail on a highly threaded
sparc64 system when running a parallel 'dd' test:

[527319.459981] dd: page allocation failure. order:0, mode:0x20
[527319.460403] Call Trace:
[527319.460568]  [00000000004b71e0] __slab_alloc+0x1b0/0x6a8
[527319.460636]  [00000000004b7bbc] kmem_cache_alloc+0x4c/0xa8
[527319.460698]  [000000000055309c] radix_tree_node_alloc+0x20/0x90
[527319.460763]  [0000000000553238] radix_tree_insert+0x12c/0x260
[527319.460830]  [0000000000495cd0] add_to_page_cache+0x38/0xb0
[527319.460893]  [00000000004e4794] mpage_readpages+0x6c/0x134
[527319.460955]  [000000000049c7fc] __do_page_cache_readahead+0x170/0x280
[527319.461028]  [000000000049cc88] ondemand_readahead+0x208/0x214
[527319.461094]  [0000000000496018] do_generic_mapping_read+0xe8/0x428
[527319.461152]  [0000000000497948] generic_file_aio_read+0x108/0x170
[527319.461217]  [00000000004badac] do_sync_read+0x88/0xd0
[527319.461292]  [00000000004bb5cc] vfs_read+0x78/0x10c
[527319.461361]  [00000000004bb920] sys_read+0x34/0x60
[527319.461424]  [0000000000406294] linux_sparc_syscall32+0x3c/0x40

The calltrace is significant: __do_page_cache_readahead allocates a number
of pages with GFP_KERNEL, and hence it should have reclaimed sufficient
memory to satisfy GFP_ATOMIC allocations. However after the list of pages
goes to mpage_readpages, there can be significant intervals (including
disk IO) before all the pages are inserted into the radix-tree. So the
reserves can easily be depleted at that point.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -95,12 +95,10 @@ static inline gfp_t root_gfp_mask(struct
 static struct radix_tree_node *
 radix_tree_node_alloc(struct radix_tree_root *root)
 {
-	struct radix_tree_node *ret;
+	struct radix_tree_node *ret = NULL;
 	gfp_t gfp_mask = root_gfp_mask(root);
 
-	ret = kmem_cache_alloc(radix_tree_node_cachep,
-				set_migrateflags(gfp_mask, __GFP_RECLAIMABLE));
-	if (ret == NULL && !(gfp_mask & __GFP_WAIT)) {
+	if (!(gfp_mask & __GFP_WAIT)) {
 		struct radix_tree_preload *rtp;
 
 		rtp = &__get_cpu_var(radix_tree_preloads);
@@ -110,6 +108,10 @@ radix_tree_node_alloc(struct radix_tree_
 			rtp->nr--;
 		}
 	}
+	if (ret == NULL)
+		ret = kmem_cache_alloc(radix_tree_node_cachep,
+				set_migrateflags(gfp_mask, __GFP_RECLAIMABLE));
+
 	BUG_ON(radix_tree_is_indirect_ptr(ret));
 	return ret;
 }
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -65,7 +65,6 @@ generic_file_direct_IO(int rw, struct ki
  *    ->private_lock		(__free_pte->__set_page_dirty_buffers)
  *      ->swap_lock		(exclusive_swap_page, others)
  *        ->mapping->tree_lock
- *          ->zone.lock
  *
  *  ->i_mutex
  *    ->i_mmap_lock		(truncate->unmap_mapping_range)
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -36,7 +36,6 @@
  *                 mapping->tree_lock (widely used, in set_page_dirty,
  *                           in arch-dependent flush_dcache_mmap_lock,
  *                           within inode_lock in __sync_single_inode)
- *                   zone->lock (within radix tree node alloc)
  */
 
 #include <linux/mm.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

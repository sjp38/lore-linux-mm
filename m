Date: Thu, 8 Nov 2007 07:54:34 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded insertions
Message-ID: <20071108065434.GA28216@wotan.suse.de>
References: <20071108004304.GD3227@wotan.suse.de> <20071107170923.6cf3c389.akpm@linux-foundation.org> <20071108013723.GF3227@wotan.suse.de> <20071107190254.4e65812a.akpm@linux-foundation.org> <20071108031645.GI3227@wotan.suse.de> <20071107201242.390aec38.akpm@linux-foundation.org> <20071108045404.GJ3227@wotan.suse.de> <20071107210204.62070047.akpm@linux-foundation.org> <20071108054445.GA20162@wotan.suse.de> <20071107220200.85e9cb59.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071107220200.85e9cb59.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Wed, Nov 07, 2007 at 10:02:00PM -0800, Andrew Morton wrote:
> > On Thu, 8 Nov 2007 06:44:46 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > > > I don't really know about getting that kmem_cache_alloc out of there.
> > > > For radix trees that are protected by sleeping locks, you don't actually
> > > > need to disable preempt and you can do sleeping allocations there.
> > > 
> > > If the radix tree's gfp_mask is GFP_ATOMIC, radix_tree_insert() can require
> > > that the preloads be full.
> > 
> > So we can put that invariant check in radix_tree_insert(),
> 
> Well, ultimately.  If we do that right now the powerpc irq management will
> trigger it.  But it deserves to ;)
> 
> > and I could
> > refactor / comment the radix_tree_node_alloc a bit so that it is clearer?
> 
> Please.

OK, here is this version. It won't be possible to put invariants in until
other code gets cleaned up... I had a shot at NFS...

---

Most pagecache (and some other) radix tree insertions have the great
opportunity to preallocate a few nodes with relaxed gfp flags. But
the preallocation is squandered when it comes time to allocate a node,
we default to first attempting a GFP_ATOMIC allocation -- that doesn't
normally fail, but it can eat into atomic memory reserves that we
don't need to be using.

Another upshot of this is that it removes the sometimes highly contended
zone->lock from underneath tree_lock. Pagecache insertions are always
performed with a radix tree preload, and after this change, such a situation
will never fall back to kmem_cache_alloc within radix_tree_node_alloc.

David Miller reports seeing this allocation fail on a highly threaded
sparc64 system:

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
reserves can easily be depleted at that point. The patch is confirmed to
fix the problem.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -95,14 +95,17 @@ static inline gfp_t root_gfp_mask(struct
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
 
+		/*
+		 * Provided the caller has preloaded here, we will always
+		 * succeed in getting a node here (and never reach
+		 * kmem_cache_alloc)
+		 */
 		rtp = &__get_cpu_var(radix_tree_preloads);
 		if (rtp->nr) {
 			ret = rtp->nodes[rtp->nr - 1];
@@ -110,6 +113,10 @@ radix_tree_node_alloc(struct radix_tree_
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

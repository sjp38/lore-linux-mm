Date: Thu, 10 Jan 2008 18:42:38 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Remove set_migrateflags()
Message-ID: <Pine.LNX.4.64.0801101841570.23644@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

set_migrateflagsi() sole purpose is to set migrate flags on slab allocations.
However, the migrate flags must set on slab creation as agreed upon when the
antifrag logic was reviewed. Otherwise some slabs of a slabcache will end up
in the unmovable and others in the reclaimable section depending on what
flags was active when a new slab was allocated.

This likely slid in somehow when antifrag was merged. Remove it.

The buffer_heads are always allocated with __GFP_RECLAIMABLE because
the SLAB_RECLAIM_ACCOUNT option is set.

The set_migrateflags() never had any effect.

Radix tree allocations are not reclaimable. And thus setting __GFP_RECLAIMABLE
is a bit strange. We could set SLAB_RECLAIM_ACCOUNT on radix tree slab
creation if we want those to be placed in the reclaimable section.
Then we are sure that the radix tree slabs are consistently placed in the
reclaimable section and then the radix tree slabs will also be accounted as
such.

The simple removal of set_migrateflags() here will place the allocations
in the unmovable section.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/buffer.c         |    4 ++--
 include/linux/gfp.h |    6 ------
 lib/radix-tree.c    |    6 ++----
 3 files changed, 4 insertions(+), 12 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2008-01-09 23:52:30.401723074 -0800
+++ linux-2.6/fs/buffer.c	2008-01-10 18:24:08.000545183 -0800
@@ -3169,8 +3169,8 @@ static void recalc_bh_state(void)
 	
 struct buffer_head *alloc_buffer_head(gfp_t gfp_flags)
 {
-	struct buffer_head *ret = kmem_cache_zalloc(bh_cachep,
-				set_migrateflags(gfp_flags, __GFP_RECLAIMABLE));
+	struct buffer_head *ret = kmem_cache_zalloc(bh_cachep, gfp_flags);
+
 	if (ret) {
 		INIT_LIST_HEAD(&ret->b_assoc_buffers);
 		get_cpu_var(bh_accounting).nr++;
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c	2008-01-09 23:52:30.421723289 -0800
+++ linux-2.6/lib/radix-tree.c	2008-01-10 00:18:22.913856382 -0800
@@ -98,8 +98,7 @@ radix_tree_node_alloc(struct radix_tree_
 	struct radix_tree_node *ret;
 	gfp_t gfp_mask = root_gfp_mask(root);
 
-	ret = kmem_cache_alloc(radix_tree_node_cachep,
-				set_migrateflags(gfp_mask, __GFP_RECLAIMABLE));
+	ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 	if (ret == NULL && !(gfp_mask & __GFP_WAIT)) {
 		struct radix_tree_preload *rtp;
 
@@ -143,8 +142,7 @@ int radix_tree_preload(gfp_t gfp_mask)
 	rtp = &__get_cpu_var(radix_tree_preloads);
 	while (rtp->nr < ARRAY_SIZE(rtp->nodes)) {
 		preempt_enable();
-		node = kmem_cache_alloc(radix_tree_node_cachep,
-				set_migrateflags(gfp_mask, __GFP_RECLAIMABLE));
+		node = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 		if (node == NULL)
 			goto out;
 		preempt_disable();
Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2008-01-10 18:21:19.543702140 -0800
+++ linux-2.6/include/linux/gfp.h	2008-01-10 18:21:30.747757986 -0800
@@ -144,12 +144,6 @@ static inline enum zone_type gfp_zone(gf
 	return base + ZONE_NORMAL;
 }
 
-static inline gfp_t set_migrateflags(gfp_t gfp, gfp_t migrate_flags)
-{
-	BUG_ON((gfp & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
-	return (gfp & ~(GFP_MOVABLE_MASK)) | migrate_flags;
-}
-
 /*
  * There is only one page-allocator function, and two main namespaces to
  * it. The alloc_page*() variants return 'struct page *' and as such

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

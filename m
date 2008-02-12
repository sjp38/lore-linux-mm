Date: Mon, 11 Feb 2008 16:16:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Remove set_migrateflags()
Message-ID: <Pine.LNX.4.64.0802111613400.30007@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: mel@skynet.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Migrate flags must be set on slab creation as agreed upon when the 
antifrag logic was reviewed. Otherwise some slabs of a slabcache will end 
up in the unmovable and others in the reclaimable section depending on 
which flag was active when a new slab page was allocated.

This likely slid in somehow when antifrag was merged. Remove it.

The buffer_heads are always allocated with __GFP_RECLAIMABLE because the 
SLAB_RECLAIM_ACCOUNT option is set. The set_migrateflags() never had any 
effect there.

Radix tree allocations are not directly reclaimable but they are allocated 
with __GFP_RECLAIMABLE set on each allocation. We now set 
SLAB_RECLAIM_ACCOUNT on radix tree slab creation making sure that radix 
tree slabs are consistently placed in the reclaimable section. Radix tree 
slabs will also be accounted as such.

There is then no user left of set_migratepages. So remove it.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/buffer.c         |    3 +--
 include/linux/gfp.h |    6 ------
 lib/radix-tree.c    |    9 ++++-----
 3 files changed, 5 insertions(+), 13 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2008-02-08 13:22:14.000000000 -0800
+++ linux-2.6/fs/buffer.c	2008-02-11 15:53:51.000000000 -0800
@@ -3169,8 +3169,7 @@ static void recalc_bh_state(void)
 	
 struct buffer_head *alloc_buffer_head(gfp_t gfp_flags)
 {
-	struct buffer_head *ret = kmem_cache_alloc(bh_cachep,
-				set_migrateflags(gfp_flags, __GFP_RECLAIMABLE));
+	struct buffer_head *ret = kmem_cache_alloc(bh_cachep, gfp_flags);
 	if (ret) {
 		INIT_LIST_HEAD(&ret->b_assoc_buffers);
 		get_cpu_var(bh_accounting).nr++;
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c	2008-02-07 19:07:05.000000000 -0800
+++ linux-2.6/lib/radix-tree.c	2008-02-11 15:55:19.000000000 -0800
@@ -114,8 +114,7 @@ radix_tree_node_alloc(struct radix_tree_
 		}
 	}
 	if (ret == NULL)
-		ret = kmem_cache_alloc(radix_tree_node_cachep,
-				set_migrateflags(gfp_mask, __GFP_RECLAIMABLE));
+		ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 
 	BUG_ON(radix_tree_is_indirect_ptr(ret));
 	return ret;
@@ -150,8 +149,7 @@ int radix_tree_preload(gfp_t gfp_mask)
 	rtp = &__get_cpu_var(radix_tree_preloads);
 	while (rtp->nr < ARRAY_SIZE(rtp->nodes)) {
 		preempt_enable();
-		node = kmem_cache_alloc(radix_tree_node_cachep,
-				set_migrateflags(gfp_mask, __GFP_RECLAIMABLE));
+		node = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 		if (node == NULL)
 			goto out;
 		preempt_disable();
@@ -1098,7 +1096,8 @@ void __init radix_tree_init(void)
 {
 	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
 			sizeof(struct radix_tree_node), 0,
-			SLAB_PANIC, radix_tree_node_ctor);
+			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
+			radix_tree_node_ctor);
 	radix_tree_init_maxindex();
 	hotcpu_notifier(radix_tree_callback, 0);
 }
Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2008-02-07 19:07:05.000000000 -0800
+++ linux-2.6/include/linux/gfp.h	2008-02-11 15:53:12.000000000 -0800
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

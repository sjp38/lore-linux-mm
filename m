Date: Wed, 29 Aug 2007 10:50:39 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] radix-tree: be a nice citizen
Message-ID: <20070829085039.GA32236@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

ISTR that last time I sent you a patch to do the same thing, you
had some objections. I can't remember what they were though, but
I guess you didn't end up merging it.

I was reminded by the problem after seeing an atomic allocation
failure trace from pagecache radix tree inesrtion.


Most pagecache (and some other) radix tree insertions have the great
opportunity to preallocate a few nodes with relaxed gfp flags. But
the preallocation is squandered when it comes time to allocate a node,
we default to first attempting a GFP_ATOMIC allocation -- that doesn't
normally fail, but it can eat into atomic memory reserves that we
don't need to be using.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -90,11 +90,10 @@ static inline gfp_t root_gfp_mask(struct
 static struct radix_tree_node *
 radix_tree_node_alloc(struct radix_tree_root *root)
 {
-	struct radix_tree_node *ret;
+	struct radix_tree_node *ret = NULL;
 	gfp_t gfp_mask = root_gfp_mask(root);
 
-	ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
-	if (ret == NULL && !(gfp_mask & __GFP_WAIT)) {
+	if (!(gfp_mask & __GFP_WAIT)) {
 		struct radix_tree_preload *rtp;
 
 		rtp = &__get_cpu_var(radix_tree_preloads);
@@ -104,6 +103,8 @@ radix_tree_node_alloc(struct radix_tree_
 			rtp->nr--;
 		}
 	}
+	if (ret == NULL)
+		ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 	BUG_ON(radix_tree_is_direct_ptr(ret));
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

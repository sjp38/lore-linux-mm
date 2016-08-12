Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D27628296C
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:39:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so6140196pfd.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:39:21 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sj4si10055422pab.213.2016.08.12.11.38.59
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 08/41] Revert "radix-tree: implement radix_tree_maybe_preload_order()"
Date: Fri, 12 Aug 2016 21:37:51 +0300
Message-Id: <1471027104-115213-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This reverts commit 356e1c23292a4f63cfdf1daf0e0ddada51f32de8.

After conversion of huge tmpfs to multi-order entries, we don't need
this anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/radix-tree.h |  1 -
 lib/radix-tree.c           | 74 ----------------------------------------------
 2 files changed, 75 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index c4cea311d901..7a271f662320 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -290,7 +290,6 @@ unsigned int radix_tree_gang_lookup_slot(struct radix_tree_root *root,
 			unsigned long first_index, unsigned int max_items);
 int radix_tree_preload(gfp_t gfp_mask);
 int radix_tree_maybe_preload(gfp_t gfp_mask);
-int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order);
 void radix_tree_init(void);
 void *radix_tree_tag_set(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 89092c4011b8..aa23643814a5 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -38,9 +38,6 @@
 #include <linux/preempt.h>		/* in_interrupt() */
 
 
-/* Number of nodes in fully populated tree of given height */
-static unsigned long height_to_maxnodes[RADIX_TREE_MAX_PATH + 1] __read_mostly;
-
 /*
  * Radix tree node cache.
  */
@@ -427,51 +424,6 @@ int radix_tree_split_preload(unsigned int old_order, unsigned int new_order,
 #endif
 
 /*
- * The same as function above, but preload number of nodes required to insert
- * (1 << order) continuous naturally-aligned elements.
- */
-int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order)
-{
-	unsigned long nr_subtrees;
-	int nr_nodes, subtree_height;
-
-	/* Preloading doesn't help anything with this gfp mask, skip it */
-	if (!gfpflags_allow_blocking(gfp_mask)) {
-		preempt_disable();
-		return 0;
-	}
-
-	/*
-	 * Calculate number and height of fully populated subtrees it takes to
-	 * store (1 << order) elements.
-	 */
-	nr_subtrees = 1 << order;
-	for (subtree_height = 0; nr_subtrees > RADIX_TREE_MAP_SIZE;
-			subtree_height++)
-		nr_subtrees >>= RADIX_TREE_MAP_SHIFT;
-
-	/*
-	 * The worst case is zero height tree with a single item at index 0 and
-	 * then inserting items starting at ULONG_MAX - (1 << order).
-	 *
-	 * This requires RADIX_TREE_MAX_PATH nodes to build branch from root to
-	 * 0-index item.
-	 */
-	nr_nodes = RADIX_TREE_MAX_PATH;
-
-	/* Plus branch to fully populated subtrees. */
-	nr_nodes += RADIX_TREE_MAX_PATH - subtree_height;
-
-	/* Root node is shared. */
-	nr_nodes--;
-
-	/* Plus nodes required to build subtrees. */
-	nr_nodes += nr_subtrees * height_to_maxnodes[subtree_height];
-
-	return __radix_tree_preload(gfp_mask, nr_nodes);
-}
-
-/*
  * The maximum index which can be stored in a radix tree
  */
 static inline unsigned long shift_maxindex(unsigned int shift)
@@ -1850,31 +1802,6 @@ radix_tree_node_ctor(void *arg)
 	INIT_LIST_HEAD(&node->private_list);
 }
 
-static __init unsigned long __maxindex(unsigned int height)
-{
-	unsigned int width = height * RADIX_TREE_MAP_SHIFT;
-	int shift = RADIX_TREE_INDEX_BITS - width;
-
-	if (shift < 0)
-		return ~0UL;
-	if (shift >= BITS_PER_LONG)
-		return 0UL;
-	return ~0UL >> shift;
-}
-
-static __init void radix_tree_init_maxnodes(void)
-{
-	unsigned long height_to_maxindex[RADIX_TREE_MAX_PATH + 1];
-	unsigned int i, j;
-
-	for (i = 0; i < ARRAY_SIZE(height_to_maxindex); i++)
-		height_to_maxindex[i] = __maxindex(i);
-	for (i = 0; i < ARRAY_SIZE(height_to_maxnodes); i++) {
-		for (j = i; j > 0; j--)
-			height_to_maxnodes[i] += height_to_maxindex[j - 1] + 1;
-	}
-}
-
 static int radix_tree_callback(struct notifier_block *nfb,
 				unsigned long action, void *hcpu)
 {
@@ -1901,6 +1828,5 @@ void __init radix_tree_init(void)
 			sizeof(struct radix_tree_node), 0,
 			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
 			radix_tree_node_ctor);
-	radix_tree_init_maxnodes();
 	hotcpu_notifier(radix_tree_callback, 0);
 }
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

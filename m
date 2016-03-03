Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE67828E2
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 11:53:15 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 124so17850098pfg.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 08:53:15 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id id7si5517923pad.196.2016.03.03.08.52.56
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 08:52:56 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 23/29] radix-tree: implement radix_tree_maybe_preload_order()
Date: Thu,  3 Mar 2016 19:52:13 +0300
Message-Id: <1457023939-98083-24-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The new helper is similar to radix_tree_maybe_preload(), but tries to
preload number of nodes required to insert (1 << order) continuous
naturally-aligned elements.

This is required to push huge pages into pagecache.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/radix-tree.h |  1 +
 lib/radix-tree.c           | 68 ++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 61 insertions(+), 8 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 32623d26b62a..20b626160430 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -288,6 +288,7 @@ unsigned int radix_tree_gang_lookup_slot(struct radix_tree_root *root,
 			unsigned long first_index, unsigned int max_items);
 int radix_tree_preload(gfp_t gfp_mask);
 int radix_tree_maybe_preload(gfp_t gfp_mask);
+int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order);
 void radix_tree_init(void);
 void *radix_tree_tag_set(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 224b369f5a5e..84d417665ddc 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -42,6 +42,9 @@
  */
 static unsigned long height_to_maxindex[RADIX_TREE_MAX_PATH + 1] __read_mostly;
 
+/* Number of nodes in fully populated tree of given height */
+static unsigned long height_to_maxnodes[RADIX_TREE_MAX_PATH + 1] __read_mostly;
+
 /*
  * Radix tree node cache.
  */
@@ -261,7 +264,7 @@ radix_tree_node_free(struct radix_tree_node *node)
  * To make use of this facility, the radix tree must be initialised without
  * __GFP_DIRECT_RECLAIM being passed to INIT_RADIX_TREE().
  */
-static int __radix_tree_preload(gfp_t gfp_mask)
+static int __radix_tree_preload(gfp_t gfp_mask, int nr)
 {
 	struct radix_tree_preload *rtp;
 	struct radix_tree_node *node;
@@ -269,14 +272,14 @@ static int __radix_tree_preload(gfp_t gfp_mask)
 
 	preempt_disable();
 	rtp = this_cpu_ptr(&radix_tree_preloads);
-	while (rtp->nr < RADIX_TREE_PRELOAD_SIZE) {
+	while (rtp->nr < nr) {
 		preempt_enable();
 		node = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
 		if (node == NULL)
 			goto out;
 		preempt_disable();
 		rtp = this_cpu_ptr(&radix_tree_preloads);
-		if (rtp->nr < RADIX_TREE_PRELOAD_SIZE) {
+		if (rtp->nr < nr) {
 			node->private_data = rtp->nodes;
 			rtp->nodes = node;
 			rtp->nr++;
@@ -302,7 +305,7 @@ int radix_tree_preload(gfp_t gfp_mask)
 {
 	/* Warn on non-sensical use... */
 	WARN_ON_ONCE(!gfpflags_allow_blocking(gfp_mask));
-	return __radix_tree_preload(gfp_mask);
+	return __radix_tree_preload(gfp_mask, RADIX_TREE_PRELOAD_SIZE);
 }
 EXPORT_SYMBOL(radix_tree_preload);
 
@@ -314,7 +317,7 @@ EXPORT_SYMBOL(radix_tree_preload);
 int radix_tree_maybe_preload(gfp_t gfp_mask)
 {
 	if (gfpflags_allow_blocking(gfp_mask))
-		return __radix_tree_preload(gfp_mask);
+		return __radix_tree_preload(gfp_mask, RADIX_TREE_PRELOAD_SIZE);
 	/* Preloading doesn't help anything with this gfp mask, skip it */
 	preempt_disable();
 	return 0;
@@ -322,6 +325,51 @@ int radix_tree_maybe_preload(gfp_t gfp_mask)
 EXPORT_SYMBOL(radix_tree_maybe_preload);
 
 /*
+ * The same as function above, but preload number of nodes required to insert
+ * (1 << order) continuous naturally-aligned elements.
+ */
+int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order)
+{
+	unsigned long nr_subtrees;
+	int nr_nodes, subtree_height;
+
+	/* Preloading doesn't help anything with this gfp mask, skip it */
+	if (!gfpflags_allow_blocking(gfp_mask)) {
+		preempt_disable();
+		return 0;
+	}
+
+	/*
+	 * Calculate number and height of fully populated subtrees it takes to
+	 * store (1 << order) elements.
+	 */
+	nr_subtrees = 1 << order;
+	for (subtree_height = 0; nr_subtrees > RADIX_TREE_MAP_SIZE;
+			subtree_height++)
+		nr_subtrees >>= RADIX_TREE_MAP_SHIFT;
+
+	/*
+	 * The worst case is zero height tree with a single item at index 0 and
+	 * then inserting items starting at ULONG_MAX - (1 << order).
+	 *
+	 * This requires RADIX_TREE_MAX_PATH nodes to build branch from root to
+	 * 0-index item.
+	 */
+	nr_nodes = RADIX_TREE_MAX_PATH;
+
+	/* Plus branch to fully populated subtrees. */
+	nr_nodes += RADIX_TREE_MAX_PATH - subtree_height;
+
+	/* Root node is shared. */
+	nr_nodes--;
+
+	/* Plus nodes required to build subtrees. */
+	nr_nodes += nr_subtrees * height_to_maxnodes[subtree_height];
+
+	return __radix_tree_preload(gfp_mask, nr_nodes);
+}
+
+/*
  *	Return the maximum key which can be store into a
  *	radix tree with height HEIGHT.
  */
@@ -1472,12 +1520,16 @@ static __init unsigned long __maxindex(unsigned int height)
 	return ~0UL >> shift;
 }
 
-static __init void radix_tree_init_maxindex(void)
+static __init void radix_tree_init_arrays(void)
 {
-	unsigned int i;
+	unsigned int i, j;
 
 	for (i = 0; i < ARRAY_SIZE(height_to_maxindex); i++)
 		height_to_maxindex[i] = __maxindex(i);
+	for (i = 0; i < ARRAY_SIZE(height_to_maxnodes); i++) {
+		for (j = i; j > 0; j--)
+			height_to_maxnodes[i] += height_to_maxindex[j - 1] + 1;
+	}
 }
 
 static int radix_tree_callback(struct notifier_block *nfb,
@@ -1507,6 +1559,6 @@ void __init radix_tree_init(void)
 			sizeof(struct radix_tree_node), 0,
 			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
 			radix_tree_node_ctor);
-	radix_tree_init_maxindex();
+	radix_tree_init_arrays();
 	hotcpu_notifier(radix_tree_callback, 0);
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

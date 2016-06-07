Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 893886B0268
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 07:01:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u67so79010416pfu.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 04:01:24 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id d7si9413920pac.77.2016.06.07.04.01.02
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 04:01:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased 18/32] radix-tree: implement radix_tree_maybe_preload_order()
Date: Tue,  7 Jun 2016 14:00:32 +0300
Message-Id: <1465297246-98985-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The new helper is similar to radix_tree_maybe_preload(), but tries to
preload number of nodes required to insert (1 << order) continuous
naturally-aligned elements.

This is required to push huge pages into pagecache.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/radix-tree.h |  1 +
 lib/radix-tree.c           | 84 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 80 insertions(+), 5 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index cb4b7e8cee81..084965cf90fc 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -291,6 +291,7 @@ unsigned int radix_tree_gang_lookup_slot(struct radix_tree_root *root,
 			unsigned long first_index, unsigned int max_items);
 int radix_tree_preload(gfp_t gfp_mask);
 int radix_tree_maybe_preload(gfp_t gfp_mask);
+int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order);
 void radix_tree_init(void);
 void *radix_tree_tag_set(struct radix_tree_root *root,
 			unsigned long index, unsigned int tag);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 8b7d8459bb9d..61b8fb529cef 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -38,6 +38,9 @@
 #include <linux/preempt.h>		/* in_interrupt() */
 
 
+/* Number of nodes in fully populated tree of given height */
+static unsigned long height_to_maxnodes[RADIX_TREE_MAX_PATH + 1] __read_mostly;
+
 /*
  * Radix tree node cache.
  */
@@ -342,7 +345,7 @@ radix_tree_node_free(struct radix_tree_node *node)
  * To make use of this facility, the radix tree must be initialised without
  * __GFP_DIRECT_RECLAIM being passed to INIT_RADIX_TREE().
  */
-static int __radix_tree_preload(gfp_t gfp_mask)
+static int __radix_tree_preload(gfp_t gfp_mask, int nr)
 {
 	struct radix_tree_preload *rtp;
 	struct radix_tree_node *node;
@@ -350,14 +353,14 @@ static int __radix_tree_preload(gfp_t gfp_mask)
 
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
@@ -383,7 +386,7 @@ int radix_tree_preload(gfp_t gfp_mask)
 {
 	/* Warn on non-sensical use... */
 	WARN_ON_ONCE(!gfpflags_allow_blocking(gfp_mask));
-	return __radix_tree_preload(gfp_mask);
+	return __radix_tree_preload(gfp_mask, RADIX_TREE_PRELOAD_SIZE);
 }
 EXPORT_SYMBOL(radix_tree_preload);
 
@@ -395,7 +398,7 @@ EXPORT_SYMBOL(radix_tree_preload);
 int radix_tree_maybe_preload(gfp_t gfp_mask)
 {
 	if (gfpflags_allow_blocking(gfp_mask))
-		return __radix_tree_preload(gfp_mask);
+		return __radix_tree_preload(gfp_mask, RADIX_TREE_PRELOAD_SIZE);
 	/* Preloading doesn't help anything with this gfp mask, skip it */
 	preempt_disable();
 	return 0;
@@ -403,6 +406,51 @@ int radix_tree_maybe_preload(gfp_t gfp_mask)
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
  * The maximum index which can be stored in a radix tree
  */
 static inline unsigned long shift_maxindex(unsigned int shift)
@@ -1571,6 +1619,31 @@ radix_tree_node_ctor(void *arg)
 	INIT_LIST_HEAD(&node->private_list);
 }
 
+static __init unsigned long __maxindex(unsigned int height)
+{
+	unsigned int width = height * RADIX_TREE_MAP_SHIFT;
+	int shift = RADIX_TREE_INDEX_BITS - width;
+
+	if (shift < 0)
+		return ~0UL;
+	if (shift >= BITS_PER_LONG)
+		return 0UL;
+	return ~0UL >> shift;
+}
+
+static __init void radix_tree_init_maxnodes(void)
+{
+	unsigned long height_to_maxindex[RADIX_TREE_MAX_PATH + 1];
+	unsigned int i, j;
+
+	for (i = 0; i < ARRAY_SIZE(height_to_maxindex); i++)
+		height_to_maxindex[i] = __maxindex(i);
+	for (i = 0; i < ARRAY_SIZE(height_to_maxnodes); i++) {
+		for (j = i; j > 0; j--)
+			height_to_maxnodes[i] += height_to_maxindex[j - 1] + 1;
+	}
+}
+
 static int radix_tree_callback(struct notifier_block *nfb,
 				unsigned long action, void *hcpu)
 {
@@ -1597,5 +1670,6 @@ void __init radix_tree_init(void)
 			sizeof(struct radix_tree_node), 0,
 			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
 			radix_tree_node_ctor);
+	radix_tree_init_maxnodes();
 	hotcpu_notifier(radix_tree_callback, 0);
 }
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

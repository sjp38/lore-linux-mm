Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C165F6B02A5
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:02 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id c21so252650920ioj.5
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:02 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id 21si41602917ioj.91.2016.11.28.11.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:39 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 25/33] radix-tree: Add radix_tree_split_preload()
Date: Mon, 28 Nov 2016 13:51:03 -0800
Message-Id: <1480369871-5271-60-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Calculate how many nodes we need to allocate to split an old_order entry
into multiple entries, each of size new_order.  The test suite checks that
we allocated exactly the right number of nodes; neither too many (checked
by rtp->nr == 0), nor too few (checked by comparing nr_allocated before
and after the call to radix_tree_split()).

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h            |  1 +
 lib/radix-tree.c                      | 24 +++++++++++++++++++-
 tools/testing/radix-tree/multiorder.c | 42 +++++++++++++++++++++++++++++++++--
 tools/testing/radix-tree/test.h       |  5 +++++
 4 files changed, 69 insertions(+), 3 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 1f4b561..5dea8f6 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -345,6 +345,7 @@ static inline void radix_tree_preload_end(void)
 	preempt_enable();
 }
 
+int radix_tree_split_preload(unsigned old_order, unsigned new_order, gfp_t);
 int radix_tree_split(struct radix_tree_root *, unsigned long index,
 			unsigned new_order);
 int radix_tree_join(struct radix_tree_root *, unsigned long index,
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 704201b..9d24bec 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -367,7 +367,7 @@ radix_tree_node_free(struct radix_tree_node *node)
  * To make use of this facility, the radix tree must be initialised without
  * __GFP_DIRECT_RECLAIM being passed to INIT_RADIX_TREE().
  */
-static int __radix_tree_preload(gfp_t gfp_mask, int nr)
+static int __radix_tree_preload(gfp_t gfp_mask, unsigned nr)
 {
 	struct radix_tree_preload *rtp;
 	struct radix_tree_node *node;
@@ -433,6 +433,28 @@ int radix_tree_maybe_preload(gfp_t gfp_mask)
 }
 EXPORT_SYMBOL(radix_tree_maybe_preload);
 
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+/*
+ * Preload with enough objects to ensure that we can split a single entry
+ * of order @old_order into many entries of size @new_order
+ */
+int radix_tree_split_preload(unsigned int old_order, unsigned int new_order,
+							gfp_t gfp_mask)
+{
+	unsigned top = 1 << (old_order % RADIX_TREE_MAP_SHIFT);
+	unsigned layers = (old_order / RADIX_TREE_MAP_SHIFT) -
+				(new_order / RADIX_TREE_MAP_SHIFT);
+	unsigned nr = 0;
+
+	WARN_ON_ONCE(!gfpflags_allow_blocking(gfp_mask));
+	BUG_ON(new_order >= old_order);
+
+	while (layers--)
+		nr = nr * RADIX_TREE_MAP_SIZE + 1;
+	return __radix_tree_preload(gfp_mask, top * nr);
+}
+#endif
+
 /*
  * The same as function above, but preload number of nodes required to insert
  * (1 << order) continuous naturally-aligned elements.
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index fa6effe..5421f01 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -389,35 +389,67 @@ static void multiorder_join(void)
 	}
 }
 
+static void check_mem(unsigned old_order, unsigned new_order, unsigned alloc)
+{
+	struct radix_tree_preload *rtp = &radix_tree_preloads;
+	if (rtp->nr != 0)
+		printf("split(%u %u) remaining %u\n", old_order, new_order,
+							rtp->nr);
+	/*
+	 * Can't check for equality here as some nodes may have been
+	 * RCU-freed while we ran.  But we should never finish with more
+	 * nodes allocated since they should have all been preloaded.
+	 */
+	if (nr_allocated > alloc)
+		printf("split(%u %u) allocated %u %u\n", old_order, new_order,
+							alloc, nr_allocated);
+}
+
 static void __multiorder_split(int old_order, int new_order)
 {
-	RADIX_TREE(tree, GFP_KERNEL);
+	RADIX_TREE(tree, GFP_ATOMIC);
 	void **slot;
 	struct radix_tree_iter iter;
 	struct radix_tree_node *node;
 	void *item;
+	unsigned alloc;
+
+	radix_tree_preload(GFP_KERNEL);
+	assert(item_insert_order(&tree, 0, old_order) == 0);
+	radix_tree_preload_end();
+
+	/* Wipe out the preloaded cache or it'll confuse check_mem() */
+	radix_tree_cpu_dead(0);
 
-	item_insert_order(&tree, 0, old_order);
 	radix_tree_tag_set(&tree, 0, 2);
+
+	radix_tree_split_preload(old_order, new_order, GFP_KERNEL);
+	alloc = nr_allocated;
 	radix_tree_split(&tree, 0, new_order);
+	check_mem(old_order, new_order, alloc);
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
 		radix_tree_iter_replace(&tree, &iter, slot,
 					item_create(iter.index, new_order));
 	}
+	radix_tree_preload_end();
 
 	item_kill_tree(&tree);
 
+	radix_tree_preload(GFP_KERNEL);
 	__radix_tree_insert(&tree, 0, old_order, (void *)0x12);
+	radix_tree_preload_end();
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item == (void *)0x12);
 	assert(node->exceptional > 0);
 
+	radix_tree_split_preload(old_order, new_order, GFP_KERNEL);
 	radix_tree_split(&tree, 0, new_order);
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
 		radix_tree_iter_replace(&tree, &iter, slot,
 					item_create(iter.index, new_order));
 	}
+	radix_tree_preload_end();
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item != (void *)0x12);
@@ -425,16 +457,20 @@ static void __multiorder_split(int old_order, int new_order)
 
 	item_kill_tree(&tree);
 
+	radix_tree_preload(GFP_KERNEL);
 	__radix_tree_insert(&tree, 0, old_order, (void *)0x12);
+	radix_tree_preload_end();
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item == (void *)0x12);
 	assert(node->exceptional > 0);
 
+	radix_tree_split_preload(old_order, new_order, GFP_KERNEL);
 	radix_tree_split(&tree, 0, new_order);
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
 		radix_tree_iter_replace(&tree, &iter, slot, (void *)0x16);
 	}
+	radix_tree_preload_end();
 
 	item = __radix_tree_lookup(&tree, 0, &node, NULL);
 	assert(item == (void *)0x16);
@@ -471,4 +507,6 @@ void multiorder_checks(void)
 	multiorder_tagged_iteration();
 	multiorder_join();
 	multiorder_split();
+
+	radix_tree_cpu_dead(0);
 }
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index e11e4d2..7c2611c 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -52,3 +52,8 @@ int root_tag_get(struct radix_tree_root *root, unsigned int tag);
 unsigned long node_maxindex(struct radix_tree_node *);
 unsigned long shift_maxindex(unsigned int shift);
 int radix_tree_cpu_dead(unsigned int cpu);
+struct radix_tree_preload {
+	unsigned nr;
+	struct radix_tree_node *nodes;
+};
+extern struct radix_tree_preload radix_tree_preloads;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

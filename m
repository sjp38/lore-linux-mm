Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 316766B02FB
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:26:06 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g187so70603207itc.2
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:26:06 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id v129si230048itd.79.2016.11.16.14.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:04 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 12/29] radix-tree: Add radix_tree_split_preload()
Date: Wed, 16 Nov 2016 16:17:15 -0800
Message-Id: <1479341856-30320-51-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Calculate how many nodes we need to allocate to split an old_order entry
into multiple entries, each of size new_order.  The test suite checks that
we allocated exactly the right number of nodes; neither too many (checked
by rtp->nr == 0), nor too few (checked by comparing nr_allocated before
and after the call to radix_tree_split()).

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h            |  1 +
 lib/radix-tree.c                      | 24 +++++++++++++++++++++++-
 tools/testing/radix-tree/multiorder.c | 32 ++++++++++++++++++++++++++++++--
 tools/testing/radix-tree/test.h       |  5 +++++
 4 files changed, 59 insertions(+), 3 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index f5518f1..8ffb051 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -319,6 +319,7 @@ static inline void radix_tree_preload_end(void)
 	preempt_enable();
 }
 
+int radix_tree_split_preload(unsigned old_order, unsigned new_order, gfp_t);
 int radix_tree_split(struct radix_tree_root *, unsigned long index,
 			unsigned new_order);
 int radix_tree_join(struct radix_tree_root *, unsigned long index,
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index eaf0f353..6d73575 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -344,7 +344,7 @@ radix_tree_node_free(struct radix_tree_node *node)
  * To make use of this facility, the radix tree must be initialised without
  * __GFP_DIRECT_RECLAIM being passed to INIT_RADIX_TREE().
  */
-static int __radix_tree_preload(gfp_t gfp_mask, int nr)
+static int __radix_tree_preload(gfp_t gfp_mask, unsigned nr)
 {
 	struct radix_tree_preload *rtp;
 	struct radix_tree_node *node;
@@ -410,6 +410,28 @@ int radix_tree_maybe_preload(gfp_t gfp_mask)
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
index d9e8155..25e0463 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -356,18 +356,46 @@ static void multiorder_join(void)
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
+	unsigned alloc;
+
+	radix_tree_preload(GFP_KERNEL);
+	assert(item_insert_order(&tree, 0, old_order) == 0);
+	radix_tree_preload_end();
+
+	/* Wipe out the preloaded cache or it'll confuse check_mem() */
+	radix_tree_callback(NULL, CPU_DEAD, NULL);
 
-	item_insert_order(&tree, 0, old_order);
 	radix_tree_tag_set(&tree, 0, 2);
+
+	radix_tree_split_preload(old_order, new_order, GFP_KERNEL);
+	alloc = nr_allocated;
 	radix_tree_split(&tree, 0, new_order);
+	check_mem(old_order, new_order, alloc);
 	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
 		radix_tree_replace_slot(slot, item_create(iter.index));
 	}
+	radix_tree_preload_end();
 
 	item_kill_tree(&tree);
 }
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index f2dc35f..33d2b6b 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -49,3 +49,8 @@ unsigned long node_maxindex(struct radix_tree_node *);
 unsigned long shift_maxindex(unsigned int shift);
 int radix_tree_callback(struct notifier_block *nfb,
 			unsigned long action, void *hcpu);
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

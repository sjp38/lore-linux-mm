Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 112EB6B025E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:13:57 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id tz10so20143130pab.3
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:13:57 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id p187si17912762pfg.145.2016.10.24.17.13.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:13:56 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 05/43] radix-tree: Add radix_tree_split_preload()
Date: Tue, 25 Oct 2016 03:13:04 +0300
Message-Id: <20161025001342.76126-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Calculate how many nodes we need to allocate to split an old_order entry
into multiple entries, each of size new_order.  The test suite checks that
we allocated exactly the right number of nodes; neither too many (checked
by rtp->nr == 0), nor too few (checked by comparing nr_allocated before
and after the call to radix_tree_split()).

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/radix-tree.h            |  1 +
 lib/radix-tree.c                      | 22 ++++++++++++++++++++++
 tools/testing/radix-tree/multiorder.c | 28 ++++++++++++++++++++++++++--
 tools/testing/radix-tree/test.h       |  9 +++++++++
 4 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index f5518f1fe3d7..8ffb0518ae9a 100644
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
index c1b835c979ed..d36cff71d225 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
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
index d9e81553c682..1cac86e74bdc 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -356,18 +356,42 @@ static void multiorder_join(void)
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
 
-	item_insert_order(&tree, 0, old_order);
+	radix_tree_preload(GFP_KERNEL);
+	assert(item_insert_order(&tree, 0, old_order) == 0);
+	radix_tree_callback(NULL, CPU_DEAD, NULL);
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
index 217fb2403f09..91ed0e3bd275 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -2,6 +2,8 @@
 #include <linux/types.h>
 #include <linux/radix-tree.h>
 #include <linux/rcupdate.h>
+#include <linux/notifier.h>
+#include <linux/cpu.h>
 
 struct item {
 	unsigned long index;
@@ -44,3 +46,10 @@ void radix_tree_dump(struct radix_tree_root *root);
 int root_tag_get(struct radix_tree_root *root, unsigned int tag);
 unsigned long node_maxindex(struct radix_tree_node *);
 unsigned long shift_maxindex(unsigned int shift);
+int radix_tree_callback(struct notifier_block *nfb,
+			unsigned long action, void *hcpu);
+struct radix_tree_preload {
+	unsigned nr;
+	struct radix_tree_node *nodes;
+};
+extern struct radix_tree_preload radix_tree_preloads;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

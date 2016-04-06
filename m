Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC75828DF
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:22:16 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id n1so41123124pfn.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:22:16 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v13si6883234pas.199.2016.04.06.14.21.54
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:54 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 18/30] radix-tree: Fix multiorder BUG_ON in radix_tree_insert
Date: Wed,  6 Apr 2016 17:21:27 -0400
Message-Id: <1459977699-2349-19-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

These BUG_ON tests are to ensure that all the tags are clear when
inserting a new entry.  If we insert a multiorder entry, we'll end up
looking at the tags for a different node, and so the BUG_ON can end up
triggering spuriously.

Also, we now have three tags, not two, so check all three are clear,
and check all the root tags with a single call to BUG_ON since the bits
are stored contiguously.

Include a test-case to ensure this problem does not reoccur.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c                      | 16 ++++++++++++----
 tools/testing/radix-tree/multiorder.c | 13 +++++++++++++
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 2ca2b416b476..33f91f207587 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -165,6 +165,11 @@ static inline int root_tag_get(struct radix_tree_root *root, unsigned int tag)
 	return (__force unsigned)root->gfp_mask & (1 << (tag + __GFP_BITS_SHIFT));
 }
 
+static inline unsigned root_tags_get(struct radix_tree_root *root)
+{
+	return (__force unsigned)root->gfp_mask >> __GFP_BITS_SHIFT;
+}
+
 /*
  * Returns 1 if any slot in the node has this tag set.
  * Otherwise returns 0.
@@ -604,12 +609,15 @@ int __radix_tree_insert(struct radix_tree_root *root, unsigned long index,
 	rcu_assign_pointer(*slot, item);
 
 	if (node) {
+		unsigned shift = ((node->path - 1) & RADIX_TREE_HEIGHT_MASK) *
+					RADIX_TREE_MAP_SHIFT;
+		unsigned offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		node->count++;
-		BUG_ON(tag_get(node, 0, index & RADIX_TREE_MAP_MASK));
-		BUG_ON(tag_get(node, 1, index & RADIX_TREE_MAP_MASK));
+		BUG_ON(tag_get(node, 0, offset));
+		BUG_ON(tag_get(node, 1, offset));
+		BUG_ON(tag_get(node, 2, offset));
 	} else {
-		BUG_ON(root_tag_get(root, 0));
-		BUG_ON(root_tag_get(root, 1));
+		BUG_ON(root_tags_get(root));
 	}
 
 	return 0;
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index cfe718c78eb6..606bfe04b104 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -46,6 +46,17 @@ static void multiorder_check(unsigned long index, int order)
 		item_check_absent(&tree, i);
 }
 
+static void multiorder_insert_bug(void)
+{
+	RADIX_TREE(tree, GFP_KERNEL);
+
+	item_insert(&tree, 0);
+	radix_tree_tag_set(&tree, 0, 0);
+	item_insert_order(&tree, 3 << 6, 6);
+
+	item_kill_tree(&tree);
+}
+
 void multiorder_checks(void)
 {
 	int i;
@@ -55,4 +66,6 @@ void multiorder_checks(void)
 		multiorder_check(0, i);
 		multiorder_check((1UL << i) + 1, i);
 	}
+
+	multiorder_insert_bug();
 }
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

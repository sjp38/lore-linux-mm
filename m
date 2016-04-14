Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A88176B0260
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:21:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so131186346pfe.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:21:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id n79si7712052pfi.149.2016.04.14.07.21.47
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:21:47 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 18/29] radix-tree: Fix multiorder BUG_ON in radix_tree_insert
Date: Thu, 14 Apr 2016 10:16:39 -0400
Message-Id: <1460643410-30196-19-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

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
 lib/radix-tree.c                      | 14 ++++++++++----
 tools/testing/radix-tree/multiorder.c | 12 ++++++++++++
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index f14ada9..ff46042 100644
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
@@ -604,12 +609,13 @@ int __radix_tree_insert(struct radix_tree_root *root, unsigned long index,
 	rcu_assign_pointer(*slot, item);
 
 	if (node) {
+		unsigned offset = get_slot_offset(node, slot);
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
index 71f34a0..0a311a5 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -81,6 +81,17 @@ static void multiorder_shrink(unsigned long index, int order)
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
@@ -94,4 +105,5 @@ void multiorder_checks(void)
 	for (i = 0; i < 15; i++)
 		multiorder_shrink((1UL << (i + RADIX_TREE_MAP_SHIFT)), i);
 
+	multiorder_insert_bug();
 }
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

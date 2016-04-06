Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id F216F6B0269
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:28:29 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id 184so41318836pff.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:28:29 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id be6si6929002pad.31.2016.04.06.14.21.52
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:52 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 14/30] radix-tree: Fix extending the tree for multi-order entries at offset 0
Date: Wed,  6 Apr 2016 17:21:23 -0400
Message-Id: <1459977699-2349-15-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

The current code will insert entries at each level, as if we're going
to add a new entry at the bottom level, so we then get an -EEXIST when
we try to insert the entry into the tree.  The best way to fix this is
to not check 'order' when inserting into an empty tree.

We still need to 'extend' the tree to the height necessary for the
maximum index corresponding to this entry, so pass that value to
radix_tree_extend() rather than the index we're asked to create, or we
won't create a tree that's deep enough.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index b3a7e6cd5773..abe7730a63af 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -432,7 +432,7 @@ static unsigned radix_tree_load_root(struct radix_tree_root *root,
  *	Extend a radix tree so it can store key @index.
  */
 static int radix_tree_extend(struct radix_tree_root *root,
-				unsigned long index, unsigned order)
+				unsigned long index)
 {
 	struct radix_tree_node *node;
 	struct radix_tree_node *slot;
@@ -444,7 +444,7 @@ static int radix_tree_extend(struct radix_tree_root *root,
 	while (index > radix_tree_maxindex(height))
 		height++;
 
-	if ((root->rnode == NULL) && (order == 0)) {
+	if (root->rnode == NULL) {
 		root->height = height;
 		goto out;
 	}
@@ -467,7 +467,7 @@ static int radix_tree_extend(struct radix_tree_root *root,
 		node->count = 1;
 		node->parent = NULL;
 		slot = root->rnode;
-		if (radix_tree_is_indirect_ptr(slot) && newheight > 1) {
+		if (radix_tree_is_indirect_ptr(slot)) {
 			slot = indirect_to_ptr(slot);
 			slot->parent = node;
 			slot = ptr_to_indirect(slot);
@@ -478,7 +478,7 @@ static int radix_tree_extend(struct radix_tree_root *root,
 		root->height = newheight;
 	} while (height > root->height);
 out:
-	return 0;
+	return height * RADIX_TREE_MAP_SHIFT;
 }
 
 /**
@@ -503,20 +503,26 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			void ***slotp)
 {
 	struct radix_tree_node *node = NULL, *slot;
+	unsigned long maxindex;
 	unsigned int height, shift, offset;
-	int error;
+	unsigned long max = index | ((1UL << order) - 1);
+
+	shift = radix_tree_load_root(root, &slot, &maxindex);
 
 	/* Make sure the tree is high enough.  */
-	if (index > radix_tree_maxindex(root->height)) {
-		error = radix_tree_extend(root, index, order);
-		if (error)
+	if (max > maxindex) {
+		int error = radix_tree_extend(root, max);
+		if (error < 0)
 			return error;
+		shift = error;
+		slot = root->rnode;
+		if (order == shift) {
+			shift += RADIX_TREE_MAP_SHIFT;
+			root->height++;
+		}
 	}
 
-	slot = root->rnode;
-
 	height = root->height;
-	shift = height * RADIX_TREE_MAP_SHIFT;
 
 	offset = 0;			/* uninitialised var warning */
 	while (shift > order) {
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

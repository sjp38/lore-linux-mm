Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 233356B025E
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:37 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so92835900pac.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:37 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id z4si10947975par.198.2016.04.14.07.17.31
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:31 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 14/29] radix-tree: Fix extending the tree for multi-order entries at offset 0
Date: Thu, 14 Apr 2016 10:16:35 -0400
Message-Id: <1460643410-30196-15-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

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
index 272ce81..f13ddbb 100644
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

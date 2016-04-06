Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D3ADA6B0276
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:29:40 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bx7so24376132pad.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:29:40 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id o68si6894186pfj.173.2016.04.06.14.21.54
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:54 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 17/30] radix-tree: Rewrite __radix_tree_lookup
Date: Wed,  6 Apr 2016 17:21:26 -0400
Message-Id: <1459977699-2349-18-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

Use the new multi-order support functions to rewrite __radix_tree_lookup()

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 45 +++++++++++++++++----------------------------
 1 file changed, 17 insertions(+), 28 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 3dc52433a9cc..2ca2b416b476 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -634,44 +634,33 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 			  struct radix_tree_node **nodep, void ***slotp)
 {
 	struct radix_tree_node *node, *parent;
-	unsigned int height, shift;
+	unsigned long maxindex;
+	unsigned int shift;
 	void **slot;
 
-	node = rcu_dereference_raw(root->rnode);
-	if (node == NULL)
+ restart:
+	parent = NULL;
+	slot = (void **)&root->rnode;
+	shift = radix_tree_load_root(root, &node, &maxindex);
+	if (index > maxindex)
 		return NULL;
 
-	if (!radix_tree_is_indirect_ptr(node)) {
-		if (index > 0)
-			return NULL;
-
-		if (nodep)
-			*nodep = NULL;
-		if (slotp)
-			*slotp = (void **)&root->rnode;
-		return node;
-	}
-	node = indirect_to_ptr(node);
-
-	height = node->path & RADIX_TREE_HEIGHT_MASK;
-	if (index > radix_tree_maxindex(height))
-		return NULL;
-
-	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
+	for (;;) {
+		unsigned offset;
 
-	do {
-		parent = node;
-		slot = node->slots + ((index >> shift) & RADIX_TREE_MAP_MASK);
-		node = rcu_dereference_raw(*slot);
-		if (node == NULL)
+		if (!node)
 			return NULL;
+		if (node == RADIX_TREE_RETRY)
+			goto restart;
 		if (!radix_tree_is_indirect_ptr(node))
 			break;
-		node = indirect_to_ptr(node);
 
+		parent = indirect_to_ptr(node);
 		shift -= RADIX_TREE_MAP_SHIFT;
-		height--;
-	} while (height > 0);
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		offset = radix_tree_descend(parent, &node, offset);
+		slot = parent->slots + offset;
+	}
 
 	if (nodep)
 		*nodep = parent;
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

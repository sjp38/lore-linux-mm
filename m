Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BDB6A6B0279
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:22:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so131196884pfe.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:22:02 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 128si12390657pfu.156.2016.04.14.07.21.58
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:21:58 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 17/29] radix-tree: Rewrite __radix_tree_lookup
Date: Thu, 14 Apr 2016 10:16:38 -0400
Message-Id: <1460643410-30196-18-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

Use the new multi-order support functions to rewrite __radix_tree_lookup()

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 48 ++++++++++++++++--------------------------------
 1 file changed, 16 insertions(+), 32 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index a1ba417..f14ada9 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -634,44 +634,28 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 			  struct radix_tree_node **nodep, void ***slotp)
 {
 	struct radix_tree_node *node, *parent;
-	unsigned int height, shift;
+	unsigned long maxindex;
+	unsigned int shift;
 	void **slot;
 
-	node = rcu_dereference_raw(root->rnode);
-	if (node == NULL)
-		return NULL;
-
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
+ restart:
+	parent = NULL;
+	slot = (void **)&root->rnode;
+	shift = radix_tree_load_root(root, &node, &maxindex);
+	if (index > maxindex)
 		return NULL;
 
-	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
-
-	do {
-		parent = node;
-		slot = node->slots + ((index >> shift) & RADIX_TREE_MAP_MASK);
-		node = rcu_dereference_raw(*slot);
-		if (node == NULL)
-			return NULL;
-		if (!radix_tree_is_indirect_ptr(node))
-			break;
-		node = indirect_to_ptr(node);
+	while (radix_tree_is_indirect_ptr(node)) {
+		unsigned offset;
 
+		if (node == RADIX_TREE_RETRY)
+			goto restart;
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 492756B0281
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:37:35 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id dx6so50526313pad.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:37:35 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 77si11496472pfq.237.2016.04.14.07.37.29
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:29 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 12/19] radix-tree: Change naming conventions in radix_tree_shrink
Date: Thu, 14 Apr 2016 10:37:15 -0400
Message-Id: <1460644642-30642-13-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

Use the more standard 'node' and 'child' instead of 'to_free' and 'slot'.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 145dcb1..094dfc0 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1396,37 +1396,37 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root)
 	bool shrunk = false;
 
 	for (;;) {
-		struct radix_tree_node *to_free = root->rnode;
-		struct radix_tree_node *slot;
+		struct radix_tree_node *node = root->rnode;
+		struct radix_tree_node *child;
 
-		if (!radix_tree_is_internal_node(to_free))
+		if (!radix_tree_is_internal_node(node))
 			break;
-		to_free = entry_to_node(to_free);
+		node = entry_to_node(node);
 
 		/*
 		 * The candidate node has more than one child, or its child
 		 * is not at the leftmost slot, or the child is a multiorder
 		 * entry, we cannot shrink.
 		 */
-		if (to_free->count != 1)
+		if (node->count != 1)
 			break;
-		slot = to_free->slots[0];
-		if (!slot)
+		child = node->slots[0];
+		if (!child)
 			break;
-		if (!radix_tree_is_internal_node(slot) && to_free->shift)
+		if (!radix_tree_is_internal_node(child) && node->shift)
 			break;
 
-		if (radix_tree_is_internal_node(slot))
-			entry_to_node(slot)->parent = NULL;
+		if (radix_tree_is_internal_node(child))
+			entry_to_node(child)->parent = NULL;
 
 		/*
 		 * We don't need rcu_assign_pointer(), since we are simply
 		 * moving the node from one part of the tree to another: if it
 		 * was safe to dereference the old pointer to it
-		 * (to_free->slots[0]), it will be safe to dereference the new
+		 * (node->slots[0]), it will be safe to dereference the new
 		 * one (root->rnode) as far as dependent read barriers go.
 		 */
-		root->rnode = slot;
+		root->rnode = child;
 
 		/*
 		 * We have a dilemma here. The node's slot[0] must not be
@@ -1446,10 +1446,10 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root)
 		 * also results in a stale slot). So tag the slot as indirect
 		 * to force callers to retry.
 		 */
-		if (!radix_tree_is_internal_node(slot))
-			to_free->slots[0] = RADIX_TREE_RETRY;
+		if (!radix_tree_is_internal_node(child))
+			node->slots[0] = RADIX_TREE_RETRY;
 
-		radix_tree_node_free(to_free);
+		radix_tree_node_free(node);
 		shrunk = true;
 	}
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

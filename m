Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5110C6B027F
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:30:12 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id 184so41341602pff.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:30:12 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v13si6883234pas.199.2016.04.06.14.21.54
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:54 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 15/30] radix-tree: Fix several shrinking bugs with multiorder entries
Date: Wed,  6 Apr 2016 17:21:24 -0400
Message-Id: <1459977699-2349-16-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

Setting the indirect bit on the user data entry used to be unambiguous
because the tree walking code knew not to expect internal nodes in the
last level of the tree.  Multiorder entries can appear at any level of
the tree, and a leaf with the indirect bit set is indistinguishable from
a pointer to a node.

Introduce a special entry (RADIX_TREE_RETRY) which is neither a valid
user entry, nor a valid pointer to a node.  The radix_tree_deref_retry()
function continues to work the same way, but tree walking code can
distinguish it from a pointer to a node.

Also fix the condition for setting slot->parent to NULL; it does not
matter what height the tree is, it only matters whether slot is an
indirect pointer.  Move this code above the comment which is referring
to the assignment to root->rnode.

Also fix the condition for preventing the tree from shrinking to a single
entry if it's a multiorder entry.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index abe7730a63af..3dc52433a9cc 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -80,6 +80,8 @@ static inline void *indirect_to_ptr(void *ptr)
 	return (void *)((unsigned long)ptr & ~RADIX_TREE_INDIRECT_PTR);
 }
 
+#define RADIX_TREE_RETRY	ptr_to_indirect(NULL)
+
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
 /* Sibling slots point directly to another slot in the same node */
 static inline bool is_sibling_entry(struct radix_tree_node *parent, void *node)
@@ -1443,6 +1445,14 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 		slot = to_free->slots[0];
 		if (!slot)
 			break;
+		if (!radix_tree_is_indirect_ptr(slot) && (root->height > 1))
+			break;
+
+		if (radix_tree_is_indirect_ptr(slot)) {
+			slot = indirect_to_ptr(slot);
+			slot->parent = NULL;
+			slot = ptr_to_indirect(slot);
+		}
 
 		/*
 		 * We don't need rcu_assign_pointer(), since we are simply
@@ -1451,14 +1461,6 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 		 * (to_free->slots[0]), it will be safe to dereference the new
 		 * one (root->rnode) as far as dependent read barriers go.
 		 */
-		if (root->height > 1) {
-			if (!radix_tree_is_indirect_ptr(slot))
-				break;
-
-			slot = indirect_to_ptr(slot);
-			slot->parent = NULL;
-			slot = ptr_to_indirect(slot);
-		}
 		root->rnode = slot;
 		root->height--;
 
@@ -1480,9 +1482,8 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 		 * also results in a stale slot). So tag the slot as indirect
 		 * to force callers to retry.
 		 */
-		if (root->height == 0)
-			*((unsigned long *)&to_free->slots[0]) |=
-						RADIX_TREE_INDIRECT_PTR;
+		if (!radix_tree_is_indirect_ptr(slot))
+			to_free->slots[0] = RADIX_TREE_RETRY;
 
 		radix_tree_node_free(to_free);
 	}
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

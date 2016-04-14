Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 415DC6B0280
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:37:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u190so132281379pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:37:33 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 77si11496472pfq.237.2016.04.14.07.37.29
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:29 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 05/19] radix-tree: Remove a use of root->height from delete_node
Date: Thu, 14 Apr 2016 10:37:08 -0400
Message-Id: <1460644642-30642-6-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

If radix_tree_shrink returns whether it managed to shrink, then
__radix_tree_delete_node doesn't ned to query the tree to find out
whether it did any work or not.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index e963823..f85c8f5 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1416,8 +1416,10 @@ unsigned long radix_tree_locate_item(struct radix_tree_root *root, void *item)
  *	radix_tree_shrink    -    shrink height of a radix tree to minimal
  *	@root		radix tree root
  */
-static inline void radix_tree_shrink(struct radix_tree_root *root)
+static inline bool radix_tree_shrink(struct radix_tree_root *root)
 {
+	bool shrunk = false;
+
 	/* try to shrink tree height */
 	while (root->height > 0) {
 		struct radix_tree_node *to_free = root->rnode;
@@ -1477,7 +1479,10 @@ static inline void radix_tree_shrink(struct radix_tree_root *root)
 			to_free->slots[0] = RADIX_TREE_RETRY;
 
 		radix_tree_node_free(to_free);
+		shrunk = true;
 	}
+
+	return shrunk;
 }
 
 /**
@@ -1500,11 +1505,8 @@ bool __radix_tree_delete_node(struct radix_tree_root *root,
 		struct radix_tree_node *parent;
 
 		if (node->count) {
-			if (node == indirect_to_ptr(root->rnode)) {
-				radix_tree_shrink(root);
-				if (root->height == 0)
-					deleted = true;
-			}
+			if (node == indirect_to_ptr(root->rnode))
+				deleted |= radix_tree_shrink(root);
 			return deleted;
 		}
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

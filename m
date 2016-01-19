Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EA5A06B0256
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 09:25:51 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id n128so176176613pfn.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 06:25:51 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v86si47916903pfi.16.2016.01.19.06.25.41
        for <linux-mm@kvack.org>;
        Tue, 19 Jan 2016 06:25:41 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 6/8] radix_tree: Loop based on shift count, not height
Date: Tue, 19 Jan 2016 09:25:31 -0500
Message-Id: <1453213533-6040-7-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

When we introduce entries that can cover multiple indices, we will need
to stop in __radix_tree_create based on the shift, not the height.  Split
out for ease of bisect.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 422a92a..869be33 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -407,10 +407,10 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 	slot = indirect_to_ptr(root->rnode);
 
 	height = root->height;
-	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
+	shift = height * RADIX_TREE_MAP_SHIFT;
 
 	offset = 0;			/* uninitialised var warning */
-	while (height > 0) {
+	while (shift > 0) {
 		if (slot == NULL) {
 			/* Have to add a child node.  */
 			slot = radix_tree_node_alloc(root);
@@ -429,11 +429,11 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 		}
 
 		/* Go a level down */
+		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		node = slot;
 		slot = node->slots[offset];
 		slot = indirect_to_ptr(slot);
-		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
 	}
 
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

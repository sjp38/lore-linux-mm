Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id A00106B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:27:43 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id fe3so40537146pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:27:43 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rl12si6929207pab.36.2016.04.06.14.21.54
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:55 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 26/30] radix-tree: Fix radix_tree_create for sibling entries
Date: Wed,  6 Apr 2016 17:21:35 -0400
Message-Id: <1459977699-2349-27-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

If the radix tree user attempted to insert a colliding entry with an
existing multiorder entry, then radix_tree_create() could encounter
a sibling entry when walking down the tree to look for a slot.
Use radix_tree_descend() to fix the problem, and add a test-case to make
sure the problem doesn't come back in future.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c                      | 4 ++--
 tools/testing/radix-tree/multiorder.c | 5 +++++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index d894654b5ecc..4291f344cb95 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -548,9 +548,9 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 		/* Go a level down */
 		height--;
 		shift -= RADIX_TREE_MAP_SHIFT;
-		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 		node = indirect_to_ptr(slot);
-		slot = node->slots[offset];
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		offset = radix_tree_descend(node, &slot, offset);
 	}
 
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index de3d0e96f987..0229e6fb590f 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -135,6 +135,11 @@ static void multiorder_check(unsigned long index, int order)
 		item_check_absent(&tree, i);
 	for (i = max; i < 2*max; i++)
 		item_check_absent(&tree, i);
+	for (i = min; i < max; i++) {
+		static void *entry = (void *)
+					(0xA0 | RADIX_TREE_EXCEPTIONAL_ENTRY);
+		assert(radix_tree_insert(&tree, i, entry) == -EEXIST);
+	}
 
 	assert(item_delete(&tree, index) != 0);
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

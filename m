Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1DAC828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u190so131318763pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:53 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 78si7713939pfq.236.2016.04.14.07.17.34
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:34 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 25/29] radix-tree: Fix radix_tree_create for sibling entries
Date: Thu, 14 Apr 2016 10:16:46 -0400
Message-Id: <1460643410-30196-26-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

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
index b1ca744..9b5d8a9 100644
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
index 1b6fc9b..fc93457 100644
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

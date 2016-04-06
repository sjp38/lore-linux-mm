Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDE26B025F
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:27:54 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id fe3so40539662pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:27:54 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id o68si6894186pfj.173.2016.04.06.14.21.55
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:55 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 29/30] radix-tree: Fix radix_tree_dump() for multi-order entries
Date: Wed,  6 Apr 2016 17:21:38 -0400
Message-Id: <1459977699-2349-30-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Matthew Wilcox <willy@linux.intel.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

 - Print which indices are covered by every leaf entry
 - Print sibling entries
 - Print the node pointer instead of the slot entry
 - Build by default in userspace, and make it accessible to the test-suite

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c                | 46 +++++++++++++++++++++++++----------------
 tools/testing/radix-tree/test.h |  1 +
 2 files changed, 29 insertions(+), 18 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index fa7842cb814e..0402c4f1a344 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -215,27 +215,36 @@ radix_tree_find_next_bit(const unsigned long *addr,
 	return size;
 }
 
-#if 0
-static void dump_node(void *slot, int height, int offset)
+#ifndef __KERNEL__
+static void dump_node(struct radix_tree_node *node, unsigned offset,
+				unsigned shift, unsigned long index)
 {
-	struct radix_tree_node *node;
 	int i;
 
-	if (!slot)
-		return;
-
-	if (height == 0) {
-		pr_debug("radix entry %p offset %d\n", slot, offset);
-		return;
-	}
-
-	node = indirect_to_ptr(slot);
 	pr_debug("radix node: %p offset %d tags %lx %lx %lx path %x count %d parent %p\n",
-		slot, offset, node->tags[0][0], node->tags[1][0],
-		node->tags[2][0], node->path, node->count, node->parent);
-
-	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++)
-		dump_node(node->slots[i], height - 1, i);
+		node, offset,
+		node->tags[0][0], node->tags[1][0], node->tags[2][0],
+		node->path, node->count, node->parent);
+
+	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
+		unsigned long first = index | (i << shift);
+		unsigned long last = first | ((1 << shift) - 1);
+		void *entry = node->slots[i];
+		if (!entry)
+			continue;
+		if (is_sibling_entry(node, entry)) {
+			pr_debug("radix sblng %p offset %d val %p indices %ld-%ld\n",
+					entry, i,
+					*(void **)indirect_to_ptr(entry),
+					first, last);
+		} else if (!radix_tree_is_indirect_ptr(entry)) {
+			pr_debug("radix entry %p offset %d indices %ld-%ld\n",
+					entry, offset, first, last);
+		} else {
+			dump_node(indirect_to_ptr(entry), i,
+					shift - RADIX_TREE_MAP_SHIFT, first);
+		}
+	}
 }
 
 /* For debug */
@@ -246,7 +255,8 @@ static void radix_tree_dump(struct radix_tree_root *root)
 			root->gfp_mask >> __GFP_BITS_SHIFT);
 	if (!radix_tree_is_indirect_ptr(root->rnode))
 		return;
-	dump_node(root->rnode, root->height, 0);
+	dump_node(indirect_to_ptr(root->rnode), 0,
+				(root->height - 1) * RADIX_TREE_MAP_SHIFT, 0);
 }
 #endif
 
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 53cb595db44a..67217c93fe95 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -40,5 +40,6 @@ extern int nr_allocated;
 
 /* Normally private parts of lib/radix-tree.c */
 void *indirect_to_ptr(void *ptr);
+void radix_tree_dump(struct radix_tree_root *root);
 int root_tag_get(struct radix_tree_root *root, unsigned int tag);
 unsigned long radix_tree_maxindex(unsigned int height);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

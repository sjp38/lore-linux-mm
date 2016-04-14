Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54A9F6B0261
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t124so131176270pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id w13si4753111pas.206.2016.04.14.07.17.32
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:32 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 28/29] radix-tree: Fix radix_tree_dump() for multi-order entries
Date: Thu, 14 Apr 2016 10:16:49 -0400
Message-Id: <1460643410-30196-29-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
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
 lib/radix-tree.c                | 48 +++++++++++++++++++++++++----------------
 tools/testing/radix-tree/test.h |  1 +
 2 files changed, 30 insertions(+), 19 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 4113ae2..9fe5b83 100644
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
-	int i;
-
-	if (!slot)
-		return;
-
-	if (height == 0) {
-		pr_debug("radix entry %p offset %d\n", slot, offset);
-		return;
-	}
+	unsigned long i;
 
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
+		unsigned long last = first | ((1UL << shift) - 1);
+		void *entry = node->slots[i];
+		if (!entry)
+			continue;
+		if (is_sibling_entry(node, entry)) {
+			pr_debug("radix sblng %p offset %ld val %p indices %ld-%ld\n",
+					entry, i,
+					*(void **)indirect_to_ptr(entry),
+					first, last);
+		} else if (!radix_tree_is_indirect_ptr(entry)) {
+			pr_debug("radix entry %p offset %ld indices %ld-%ld\n",
+					entry, i, first, last);
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
index 53cb595..67217c9 100644
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA256B0255
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 09:25:50 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 65so176193739pff.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 06:25:50 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id s7si45978258pfi.10.2016.01.19.06.25.41
        for <linux-mm@kvack.org>;
        Tue, 19 Jan 2016 06:25:41 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 8/8] radix_tree: Add radix_tree_dump
Date: Tue, 19 Jan 2016 09:25:33 -0500
Message-Id: <1453213533-6040-9-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

This is debug code which is #if 0 out.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index be19e4d..a25f635 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -174,6 +174,41 @@ radix_tree_find_next_bit(const unsigned long *addr,
 	return size;
 }
 
+#if 0
+static void dump_node(void *slot, int height, int offset)
+{
+	struct radix_tree_node *node;
+	int i;
+
+	if (!slot)
+		return;
+
+	if (height == 0) {
+		pr_debug("radix entry %p offset %d\n", slot, offset);
+		return;
+	}
+
+	node = indirect_to_ptr(slot);
+	pr_debug("radix node: %p offset %d tags %lx %lx %lx path %x count %d parent %p\n",
+		slot, offset, node->tags[0][0], node->tags[1][0],
+		node->tags[2][0], node->path, node->count, node->parent);
+
+	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++)
+		dump_node(node->slots[i], height - 1, i);
+}
+
+/* For debug */
+static void radix_tree_dump(struct radix_tree_root *root)
+{
+	pr_debug("radix root: %p height %d rnode %p tags %x\n",
+			root, root->height, root->rnode,
+			root->gfp_mask >> __GFP_BITS_SHIFT);
+	if (!radix_tree_is_indirect_ptr(root->rnode))
+		return;
+	dump_node(root->rnode, root->height, 0);
+}
+#endif
+
 /*
  * This assumes that the caller has performed appropriate preallocation, and
  * that the caller has pinned this thread of control to the current CPU.
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

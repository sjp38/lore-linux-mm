Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1DAAF6B029C
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:24:05 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id l8so76525779iti.6
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:24:05 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id f204si238973ioa.132.2016.11.16.14.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:04 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 17/29] radix-tree: Improve dump output
Date: Wed, 16 Nov 2016 16:17:20 -0800
Message-Id: <1479341856-30320-56-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@infradead.org>

Print the indices of the entries as unsigned (instead of signed) integers
and print the parent node of each entry to help navigate around larger
trees where the layout is not quite so obvious.  Print the indices
covered by a node.  Rearrange the order of fields printed so the indices
and parents line up for each type of entry.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 lib/radix-tree.c | 50 +++++++++++++++++++++++++-------------------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 2c3fac4..09c5f1d 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -214,15 +214,29 @@ radix_tree_find_next_bit(struct radix_tree_node *node, unsigned int tag,
 	return RADIX_TREE_MAP_SIZE;
 }
 
+/*
+ * The maximum index which can be stored in a radix tree
+ */
+static inline unsigned long shift_maxindex(unsigned int shift)
+{
+	return (RADIX_TREE_MAP_SIZE << shift) - 1;
+}
+
+static inline unsigned long node_maxindex(struct radix_tree_node *node)
+{
+	return shift_maxindex(node->shift);
+}
+
 #ifndef __KERNEL__
 static void dump_node(struct radix_tree_node *node, unsigned long index)
 {
 	unsigned long i;
 
-	pr_debug("radix node: %p offset %d tags %lx %lx %lx shift %d count %d parent %p\n",
-		node, node->offset,
+	pr_debug("radix node: %p offset %d indices %lu-%lu parent %p tags %lx %lx %lx shift %d count %d\n",
+		node, node->offset, index, index | node_maxindex(node),
+		node->parent,
 		node->tags[0][0], node->tags[1][0], node->tags[2][0],
-		node->shift, node->count, node->parent);
+		node->shift, node->count);
 
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		unsigned long first = index | (i << node->shift);
@@ -231,16 +245,15 @@ static void dump_node(struct radix_tree_node *node, unsigned long index)
 		if (!entry)
 			continue;
 		if (entry == RADIX_TREE_RETRY) {
-			pr_debug("radix retry offset %ld indices %ld-%ld\n",
-					i, first, last);
-		} else if (is_sibling_entry(node, entry)) {
-			pr_debug("radix sblng %p offset %ld val %p indices %ld-%ld\n",
-					entry, i,
-					*(void **)entry_to_node(entry),
-					first, last);
+			pr_debug("radix retry offset %ld indices %lu-%lu parent %p\n",
+					i, first, last, node);
 		} else if (!radix_tree_is_internal_node(entry)) {
-			pr_debug("radix entry %p offset %ld indices %ld-%ld\n",
-					entry, i, first, last);
+			pr_debug("radix entry %p offset %ld indices %lu-%lu parent %p\n",
+					entry, i, first, last, node);
+		} else if (is_sibling_entry(node, entry)) {
+			pr_debug("radix sblng %p offset %ld indices %lu-%lu parent %p val %p\n",
+					entry, i, first, last, node,
+					*(void **)entry_to_node(entry));
 		} else {
 			dump_node(entry_to_node(entry), first);
 		}
@@ -477,19 +490,6 @@ int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order)
 	return __radix_tree_preload(gfp_mask, nr_nodes);
 }
 
-/*
- * The maximum index which can be stored in a radix tree
- */
-static inline unsigned long shift_maxindex(unsigned int shift)
-{
-	return (RADIX_TREE_MAP_SIZE << shift) - 1;
-}
-
-static inline unsigned long node_maxindex(struct radix_tree_node *node)
-{
-	return shift_maxindex(node->shift);
-}
-
 static unsigned radix_tree_load_root(struct radix_tree_root *root,
 		struct radix_tree_node **nodep, unsigned long *maxindex)
 {
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

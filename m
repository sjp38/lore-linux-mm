Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 644046B02EC
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 15:07:54 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id m203so260974557iom.6
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 12:07:54 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id e19si41509893ioj.160.2016.11.28.12.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 12:07:53 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 18/33] radix-tree: Improve dump output
Date: Mon, 28 Nov 2016 13:50:22 -0800
Message-Id: <1480369871-5271-19-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@infradead.org>

Print the indices of the entries as unsigned (instead of signed) integers
and print the parent node of each entry to help navigate around larger
trees where the layout is not quite so obvious.  Print the indices
covered by a node.  Rearrange the order of fields printed so the indices
and parents line up for each type of entry.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 lib/radix-tree.c | 49 ++++++++++++++++++++++++++-----------------------
 1 file changed, 26 insertions(+), 23 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 01ed70b..49b320e 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -213,15 +213,29 @@ radix_tree_find_next_bit(struct radix_tree_node *node, unsigned int tag,
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
 
-	pr_debug("radix node: %p offset %d tags %lx %lx %lx shift %d count %d exceptional %d parent %p\n",
-		node, node->offset,
+	pr_debug("radix node: %p offset %d indices %lu-%lu parent %p tags %lx %lx %lx shift %d count %d exceptional %d\n",
+		node, node->offset, index, index | node_maxindex(node),
+		node->parent,
 		node->tags[0][0], node->tags[1][0], node->tags[2][0],
-		node->shift, node->count, node->exceptional, node->parent);
+		node->shift, node->count, node->exceptional);
 
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		unsigned long first = index | (i << node->shift);
@@ -229,14 +243,16 @@ static void dump_node(struct radix_tree_node *node, unsigned long index)
 		void *entry = node->slots[i];
 		if (!entry)
 			continue;
-		if (is_sibling_entry(node, entry)) {
-			pr_debug("radix sblng %p offset %ld val %p indices %ld-%ld\n",
-					entry, i,
-					*(void **)entry_to_node(entry),
-					first, last);
+		if (entry == RADIX_TREE_RETRY) {
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
@@ -454,19 +470,6 @@ int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order)
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

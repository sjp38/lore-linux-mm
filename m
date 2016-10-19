Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id F02B26B0261
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:24:50 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x79so13321967lff.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:24:50 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o4si3141376lff.240.2016.10.19.10.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 10:24:49 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/5] lib: radix-tree: native accounting and tracking of special entries
Date: Wed, 19 Oct 2016 13:24:26 -0400
Message-Id: <20161019172428.7649-4-hannes@cmpxchg.org>
In-Reply-To: <20161019172428.7649-1-hannes@cmpxchg.org>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Add an internal tag to identify special entries that are accounted in
node->special in addition to node->count.

With this in place, the next patch can restore refault detection in
single-page files. It will also move the shadow count from the upper
bits of count to the new special counter, and then shrink count to a
char as well; the growth of struct radix_tree_node is temporary.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/radix-tree.h | 10 ++++++----
 lib/radix-tree.c           | 14 ++++++++++----
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 756b2909467e..2e1c9added23 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -68,7 +68,8 @@ enum radix_tree_tags {
 	/* Freely allocatable radix tree user tags */
 	RADIX_TREE_NR_USER_TAGS = 3,
 	/* Radix tree internal tags */
-	RADIX_TREE_NR_TAGS = RADIX_TREE_NR_USER_TAGS,
+	RADIX_TREE_TAG_SPECIAL = RADIX_TREE_NR_USER_TAGS,
+	RADIX_TREE_NR_TAGS,
 };
 
 #ifndef RADIX_TREE_MAP_SHIFT
@@ -90,9 +91,10 @@ enum radix_tree_tags {
 #define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
 
 struct radix_tree_node {
-	unsigned char	shift;	/* Bits remaining in each slot */
-	unsigned char	offset;	/* Slot offset in parent */
-	unsigned int	count;
+	unsigned char	shift;		/* Bits remaining in each slot */
+	unsigned char	offset;		/* Slot offset in parent */
+	unsigned int	count;		/* Total entry count */
+	unsigned char	special;	/* Special entry count */
 	union {
 		struct {
 			/* Used when ascending tree */
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index bb6ddfb60557..e58cff1d97ed 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -220,10 +220,10 @@ static void dump_node(struct radix_tree_node *node, unsigned long index)
 {
 	unsigned long i;
 
-	pr_debug("radix node: %p offset %d tags %lx %lx %lx shift %d count %d parent %p\n",
+	pr_debug("radix node: %p offset %d tags %lx %lx %lx shift %d count %d special %d parent %p\n",
 		node, node->offset,
 		node->tags[0][0], node->tags[1][0], node->tags[2][0],
-		node->shift, node->count, node->parent);
+		node->shift, node->count, node->special, node->parent);
 
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		unsigned long first = index | (i << node->shift);
@@ -522,9 +522,15 @@ static int radix_tree_extend(struct radix_tree_root *root,
 		node->offset = 0;
 		node->count = 1;
 		node->parent = NULL;
-		if (radix_tree_is_internal_node(slot))
-			entry_to_node(slot)->parent = node;
 		node->slots[0] = slot;
+		/* Extending an existing node or root->rnode? */
+		if (radix_tree_is_internal_node(slot)) {
+			entry_to_node(slot)->parent = node;
+		} else {
+			/* Moving a special root->rnode to a node */
+			if (root_tag_get(root, RADIX_TREE_TAG_SPECIAL))
+				node->special = 1;
+		}
 		slot = node_to_entry(node);
 		rcu_assign_pointer(root->rnode, slot);
 		shift += RADIX_TREE_MAP_SHIFT;
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

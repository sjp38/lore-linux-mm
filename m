Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 92BC16B010E
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 17:57:51 -0400 (EDT)
From: Rik van Riel <riel@surriel.com>
Subject: [PATCH -mm v2 04/11] rbtree: add helpers to find nearest uncle node
Date: Thu, 21 Jun 2012 17:57:08 -0400
Message-Id: <1340315835-28571-5-git-send-email-riel@surriel.com>
In-Reply-To: <1340315835-28571-1-git-send-email-riel@surriel.com>
References: <1340315835-28571-1-git-send-email-riel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>, Rik van Riel <riel@redhat.com>

It is useful to search an augmented rbtree based on the augmented
data, ie. not using the sort key as the primary search criterium.
However, we may still need to limit our search to a sub-part of the
whole tree, using the sort key as limiters where we can search.

In that case, we may need to stop searching in one part of the tree,
and continue the search at the nearest (great-?)uncle node in a particular
direction.

Add helper functions to find the nearest uncle node.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
 include/linux/rbtree.h |    4 ++++
 lib/rbtree.c           |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 661288d..a74b74b 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -169,6 +169,10 @@ extern struct rb_node *rb_prev(const struct rb_node *);
 extern struct rb_node *rb_first(const struct rb_root *);
 extern struct rb_node *rb_last(const struct rb_root *);
 
+/* Find the prev or next uncle of a node in the desired direction. */
+extern struct rb_node *rb_find_prev_uncle(struct rb_node *);
+extern struct rb_node *rb_find_next_uncle(struct rb_node *);
+
 /* Fast replacement of a single node without remove/rebalance/add/rebalance */
 extern void rb_replace_node(struct rb_node *victim, struct rb_node *new, 
 			    struct rb_root *root);
diff --git a/lib/rbtree.c b/lib/rbtree.c
index d417556..08c16d8 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -437,6 +437,52 @@ struct rb_node *rb_prev(const struct rb_node *node)
 }
 EXPORT_SYMBOL(rb_prev);
 
+/*
+ * rb_find_{prev,next}_uncle - Find the nearest "uncle" node in a direction
+ *
+ * An "uncle" node is a sibling node of a parent or grandparent. These
+ * functions walk up the tree to the nearest uncle of this node in the
+ * desired direction.
+ *
+ *                 G
+ *                / \
+ *               P   U
+ *                \
+ *                 N
+ * This is necessary when searching for something in a bounded subset
+ * of an augmented rbtree, when the primary search criterium is the
+ * augmented data, and not the sort key.
+ */
+struct rb_node *rb_find_prev_uncle(struct rb_node *node)
+{
+	struct rb_node *prev;
+
+	while ((prev = node) && (node = rb_parent(node))) {
+		if (prev == node->rb_left)
+			continue;
+
+		if (node->rb_left)
+			return node->rb_left;
+	}
+
+	return NULL;
+}
+
+struct rb_node *rb_find_next_uncle(struct rb_node *node)
+{
+	struct rb_node *prev;
+
+	while ((prev = node) && (node = rb_parent(node))) {
+		if (prev == node->rb_right)
+			continue;
+
+		if (node->rb_right)
+			return node->rb_right;
+	}
+
+	return NULL;
+}
+
 void rb_replace_node(struct rb_node *victim, struct rb_node *new,
 		     struct rb_root *root)
 {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 28F146B0078
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:32:59 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so5512005pbb.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:32:58 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 08/12] rbtree: low level optimizations in rb_insert_color()
Date: Thu, 12 Jul 2012 17:31:53 -0700
Message-Id: <1342139517-3451-9-git-send-email-walken@google.com>
In-Reply-To: <1342139517-3451-1-git-send-email-walken@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

- Use the newly introduced rb_set_parent_color() function to flip the color
  of nodes whose parent is already known.
- Optimize rb_parent() when the node is known to be red - there is no need
  to mask out the color in that case.
- Flipping gparent's color to red requires us to fetch its rb_parent_color
  field, so we can reuse it as the parent value for the next loop iteration.
- Do not use __rb_rotate_left() and __rb_rotate_right() to handle tree
  rotations: we already have pointers to all relevant nodes, and know their
  colors (either because we want to adjust it, or because we've tested it,
  or we can deduce it as black due to the node proximity to a known red node).
  So we can generate more efficient code by making use of the node pointers
  we already have, and setting both the parent and color attributes for
  nodes all at once. Also in Case 2, some node attributes don't have to
  be set because we know another tree rotation (Case 3) will always follow
  and override them.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 lib/rbtree.c |  166 +++++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 131 insertions(+), 35 deletions(-)

diff --git a/lib/rbtree.c b/lib/rbtree.c
index d0be5fc..41cf19b 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -23,6 +23,25 @@
 #include <linux/rbtree.h>
 #include <linux/export.h>
 
+/*
+ * red-black trees properties:  http://en.wikipedia.org/wiki/Rbtree
+ *
+ *  1) A node is either red or black
+ *  2) The root is black
+ *  3) All leaves (NULL) are black
+ *  4) Both children of every red node are black
+ *  5) Every simple path from root to leaves contains the same number
+ *     of black nodes.
+ *
+ *  4 and 5 give the O(log n) guarantee, since 4 implies you cannot have two
+ *  consecutive red nodes in a path and every red node is therefore followed by
+ *  a black. So if B is the number of black nodes on every simple path (as per
+ *  5), then the longest possible path due to 4 is 2B.
+ *
+ *  We shall indicate color with case, where black nodes are uppercase and red
+ *  nodes will be lowercase.
+ */
+
 #define	RB_RED		0
 #define	RB_BLACK	1
 
@@ -41,6 +60,17 @@ static inline void rb_set_color(struct rb_node *rb, int color)
 	rb->__rb_parent_color = (rb->__rb_parent_color & ~1) | color;
 }
 
+static inline void rb_set_parent_color(struct rb_node *rb,
+				       struct rb_node *p, int color)
+{
+	rb->__rb_parent_color = (unsigned long)p | color;
+}
+
+static inline struct rb_node *rb_red_parent(struct rb_node *red)
+{
+	return (struct rb_node *)red->__rb_parent_color;
+}
+
 static void __rb_rotate_left(struct rb_node *node, struct rb_root *root)
 {
 	struct rb_node *right = node->rb_right;
@@ -87,9 +117,30 @@ static void __rb_rotate_right(struct rb_node *node, struct rb_root *root)
 	rb_set_parent(node, left);
 }
 
+/*
+ * Helper function for rotations:
+ * - old's parent and color get assigned to new
+ * - old gets assigned new as a parent and 'color' as a color.
+ */
+static inline void
+__rb_rotate_set_parents(struct rb_node *old, struct rb_node *new,
+			struct rb_root *root, int color)
+{
+	struct rb_node *parent = rb_parent(old);
+	new->__rb_parent_color = old->__rb_parent_color;
+	rb_set_parent_color(old, new, color);
+	if (parent) {
+		if (parent->rb_left == old)
+			parent->rb_left = new;
+		else
+			parent->rb_right = new;
+	} else
+		root->rb_node = new;
+}
+
 void rb_insert_color(struct rb_node *node, struct rb_root *root)
 {
-	struct rb_node *parent, *gparent;
+	struct rb_node *parent = rb_red_parent(node), *gparent, *tmp;
 
 	while (true) {
 		/*
@@ -99,59 +150,104 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 		 * Otherwise, take some corrective action as we don't
 		 * want a red root or two consecutive red nodes.
 		 */
-		parent = rb_parent(node);
 		if (!parent) {
-			rb_set_black(node);
+			rb_set_parent_color(node, NULL, RB_BLACK);
 			break;
 		} else if (rb_is_black(parent))
 			break;
 
-		gparent = rb_parent(parent);
-
-		if (parent == gparent->rb_left)
-		{
-			{
-				register struct rb_node *uncle = gparent->rb_right;
-				if (uncle && rb_is_red(uncle))
-				{
-					rb_set_black(uncle);
-					rb_set_black(parent);
-					rb_set_red(gparent);
-					node = gparent;
-					continue;
-				}
+		gparent = rb_red_parent(parent);
+
+		if (parent == gparent->rb_left) {
+			tmp = gparent->rb_right;
+			if (tmp && rb_is_red(tmp)) {
+				/*
+				 * Case 1 - color flips
+				 *
+				 *       G            g
+				 *      / \          / \
+				 *     p   u  -->   P   U
+				 *    /            /
+				 *   n            N
+				 *
+				 * However, since g's parent might be red, and
+				 * 4) does not allow this, we need to recurse
+				 * at g.
+				 */
+				rb_set_parent_color(tmp, gparent, RB_BLACK);
+				rb_set_parent_color(parent, gparent, RB_BLACK);
+				node = gparent;
+				parent = rb_parent(node);
+				rb_set_parent_color(node, parent, RB_RED);
+				continue;
 			}
 
 			if (parent->rb_right == node) {
-				__rb_rotate_left(parent, root);
+				/*
+				 * Case 2 - left rotate at parent
+				 *
+				 *      G             G
+				 *     / \           / \
+				 *    p   U  -->    n   U
+				 *     \           /
+				 *      n         p
+				 *
+				 * This still leaves us in violation of 4), the
+				 * continuation into Case 3 will fix that.
+				 */
+				parent->rb_right = tmp = node->rb_left;
+				node->rb_left = parent;
+				if (tmp)
+					rb_set_parent_color(tmp, parent,
+							    RB_BLACK);
+				rb_set_parent_color(parent, node, RB_RED);
 				parent = node;
 			}
 
-			rb_set_black(parent);
-			rb_set_red(gparent);
-			__rb_rotate_right(gparent, root);
+			/*
+			 * Case 3 - right rotate at gparent
+			 *
+			 *        G           P
+			 *       / \         / \
+			 *      p   U  -->  n   g
+			 *     /                 \
+			 *    n                   U
+			 */
+			gparent->rb_left = tmp = parent->rb_right;
+			parent->rb_right = gparent;
+			if (tmp)
+				rb_set_parent_color(tmp, gparent, RB_BLACK);
+			__rb_rotate_set_parents(gparent, parent, root, RB_RED);
 			break;
 		} else {
-			{
-				register struct rb_node *uncle = gparent->rb_left;
-				if (uncle && rb_is_red(uncle))
-				{
-					rb_set_black(uncle);
-					rb_set_black(parent);
-					rb_set_red(gparent);
-					node = gparent;
-					continue;
-				}
+			tmp = gparent->rb_left;
+			if (tmp && rb_is_red(tmp)) {
+				/* Case 1 - color flips */
+				rb_set_parent_color(tmp, gparent, RB_BLACK);
+				rb_set_parent_color(parent, gparent, RB_BLACK);
+				node = gparent;
+				parent = rb_parent(node);
+				rb_set_parent_color(node, parent, RB_RED);
+				continue;
 			}
 
 			if (parent->rb_left == node) {
-				__rb_rotate_right(parent, root);
+				/* Case 2 - right rotate at parent */
+				parent->rb_left = tmp = node->rb_right;
+				node->rb_right = parent;
+				if (tmp)
+					rb_set_parent_color(tmp, parent,
+							    RB_BLACK);
+				rb_set_parent_color(parent, node, RB_RED);
 				parent = node;
 			}
 
-			rb_set_black(parent);
-			rb_set_red(gparent);
-			__rb_rotate_left(gparent, root);
+			/* Case 3 - left rotate at gparent */
+			gparent->rb_right = tmp = parent->rb_left;
+			parent->rb_left = gparent;
+			if (tmp)
+				rb_set_parent_color(tmp, gparent, RB_BLACK);
+			__rb_rotate_set_parents(gparent, parent, root, RB_RED);
 			break;
 		}
 	}
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

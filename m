Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 6FBC16B004D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 21:54:14 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so14336209pbb.14
        for <linux-mm@kvack.org>; Mon, 23 Jul 2012 18:54:13 -0700 (PDT)
Date: Mon, 23 Jul 2012 18:54:10 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH 5/6] rbtree: faster augmented erase
Message-ID: <20120724015410.GA9690@google.com>
References: <1342787467-5493-1-git-send-email-walken@google.com>
 <1342787467-5493-6-git-send-email-walken@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342787467-5493-6-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Add an augmented tree rotation callback to __rb_erase_color(), so that
augmented tree information can be maintained while rebalancing.

Also introduce rb_erase_augmented(), which is a version of rb_erase()
with augmented tree callbacks. We need three callbacks here: one to
copy the subtree's augmented value after stitching in a new node as
the subtree root (rb_erase_augmented cases 2 and 3), one to propagate
the augmented values up after removing a node, and one to pass up to
__rb_erase_color() to handle rebalancing.

Things are set up so that rb_erase() uses dummy do-nothing callbacks,
which get inlined and eliminated by the compiler, and also inlines the
__rb_erase_color() call so as to generate similar code than before
(once again, the compiler somehow generates smaller code than before
with all that inlining, but the speed seems to be on par). For the
augmented version rb_erase_augmented(), however, we use partial
inlining: we want rb_erase_augmented() and its augmented copy and
propagation callbacks to get inlined together, but we still call into
a generic __rb_erase_color() (passing a non-inlined callback function)
for the rebalancing work. This is intended to strike a reasonable
compromise between speed and compiled code size.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/rbtree.h          |    5 --
 include/linux/rbtree_internal.h |  137 +++++++++++++++++++++++++++++++++++++
 lib/rbtree.c                    |  141 ++++++---------------------------------
 lib/rbtree_test.c               |   31 ++++++---
 4 files changed, 180 insertions(+), 134 deletions(-)
 create mode 100644 include/linux/rbtree_internal.h

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 1364b81..bf836a2 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -61,11 +61,6 @@ struct rb_root {
 extern void rb_insert_color(struct rb_node *, struct rb_root *);
 extern void rb_erase(struct rb_node *, struct rb_root *);
 
-typedef void rb_augment_rotate(struct rb_node *old, struct rb_node *new);
-
-extern void rb_insert_augmented(struct rb_node *node, struct rb_root *root,
-				rb_augment_rotate *augment);
-
 typedef void (*rb_augment_f)(struct rb_node *node, void *data);
 
 extern void rb_augment_insert(struct rb_node *node,
diff --git a/include/linux/rbtree_internal.h b/include/linux/rbtree_internal.h
new file mode 100644
index 0000000..82d2864
--- /dev/null
+++ b/include/linux/rbtree_internal.h
@@ -0,0 +1,137 @@
+#ifndef _LINUX_RBTREE_INTERNAL_H
+#define _LINUX_RBTREE_INTERNAL_H
+
+#define	RB_RED		0
+#define	RB_BLACK	1
+
+#define rb_color(r)   ((r)->__rb_parent_color & 1)
+#define rb_is_red(r)   (!rb_color(r))
+#define rb_is_black(r) rb_color(r)
+
+static inline void rb_set_parent(struct rb_node *rb, struct rb_node *p)
+{
+	rb->__rb_parent_color = rb_color(rb) | (unsigned long)p;
+}
+
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
+typedef void rb_augment_rotate(struct rb_node *old, struct rb_node *new);
+typedef void rb_augment_copy(struct rb_node *old, struct rb_node *new);
+typedef void rb_augment_propagate(struct rb_node *node, struct rb_node *stop);
+
+extern void rb_insert_augmented(struct rb_node *node, struct rb_root *root,
+				rb_augment_rotate *augment);
+extern void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
+			     struct rb_root *root, rb_augment_rotate *augment);
+
+static inline void
+rb_erase_augmented(struct rb_node *node, struct rb_root *root,
+		   rb_augment_copy *augment_copy,
+		   rb_augment_propagate *augment_propagate,
+		   rb_augment_rotate *augment_rotate)
+{
+	struct rb_node *parent = rb_parent(node);
+	struct rb_node *child = node->rb_right;
+	struct rb_node *tmp = node->rb_left;
+	bool black;
+
+	if (!tmp) {
+		/* Case 1: node to erase has no more than 1 child (easy!) */
+		if (child)
+one_child:
+			rb_set_parent(child, parent);
+		if (parent) {
+			if (parent->rb_left == node)
+				parent->rb_left = child;
+			else
+				parent->rb_right = child;
+		} else
+			root->rb_node = child;
+
+		tmp = parent;
+		black = rb_is_black(node);
+	} else if (!child) {
+		/* Still case 1, but this time the child is node->rb_left */
+		child = tmp;
+		goto one_child;
+	} else {
+		struct rb_node *old = node;
+
+		/*
+		 * Old is the node we want to erase. It's got left and right
+		 * children, which makes things difficult. Let's find the
+		 * next node in the tree to have it fill old's position.
+		 */
+		node = node->rb_right;
+		while ((tmp = node->rb_left) != NULL)
+			node = tmp;
+
+		/* Graft node (old's successor) under old's parent. */
+		if (parent) {
+			if (parent->rb_left == old)
+				parent->rb_left = node;
+			else
+				parent->rb_right = node;
+		} else
+			root->rb_node = node;
+
+		parent = rb_parent(node);
+		black = rb_is_black(node);
+		node->__rb_parent_color = old->__rb_parent_color;
+		augment_copy(old, node);
+
+		/*
+		 * Node doesn't have a left child, since it is old's successor,
+		 * so we can take old's left child and graft it under node.
+		 */
+		node->rb_left = tmp = old->rb_left;
+		rb_set_parent(tmp, node);
+
+		child = node->rb_right;
+		if (parent == old) {
+			/*
+			 * Case 2: old is node's parent (we are done!)
+			 *
+			 *    (o)          (n)
+			 *    / \          / \
+			 *  (x) (n)  ->  (x) (c)
+			 *        \
+			 *        (c)
+			 */
+			parent = tmp = node;
+		} else {
+			/*
+			 * Case 3: old is node's ancestor but not its parent
+			 *
+			 *    (o)          (n)
+			 *    / \          / \
+			 *  (x) (y)  ->  (x) (y)
+			 *      /            /
+			 *    (n)          (c)
+			 *      \
+			 *      (c)
+			 */
+			node->rb_right = tmp = old->rb_right;
+			parent->rb_left = child;
+			rb_set_parent(tmp, node);
+			if (child)
+				rb_set_parent(child, parent);
+			augment_propagate(parent, node);
+			tmp = node;
+		}
+	}
+	augment_propagate(tmp, NULL);
+	if (black)
+		__rb_erase_color(child, parent, root, augment_rotate);
+}
+
+#endif	/* _LINUX_RBTREE_INTERNAL_H */
diff --git a/lib/rbtree.c b/lib/rbtree.c
index a6ae4c5..90349ec 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -22,6 +22,7 @@
 */
 
 #include <linux/rbtree.h>
+#include <linux/rbtree_internal.h>
 #include <linux/export.h>
 
 /*
@@ -44,29 +45,6 @@
  *  parentheses and have some accompanying text comment.
  */
 
-#define	RB_RED		0
-#define	RB_BLACK	1
-
-#define rb_color(r)   ((r)->__rb_parent_color & 1)
-#define rb_is_red(r)   (!rb_color(r))
-#define rb_is_black(r) rb_color(r)
-
-static inline void rb_set_parent(struct rb_node *rb, struct rb_node *p)
-{
-	rb->__rb_parent_color = rb_color(rb) | (unsigned long)p;
-}
-
-static inline void rb_set_parent_color(struct rb_node *rb,
-				       struct rb_node *p, int color)
-{
-	rb->__rb_parent_color = (unsigned long)p | color;
-}
-
-static inline struct rb_node *rb_red_parent(struct rb_node *red)
-{
-	return (struct rb_node *)red->__rb_parent_color;
-}
-
 /*
  * Helper function for rotations:
  * - old's parent and color get assigned to new
@@ -213,15 +191,8 @@ inline void rb_insert_augmented(struct rb_node *node, struct rb_root *root,
 }
 EXPORT_SYMBOL(rb_insert_augmented);
 
-static inline void dummy(struct rb_node *old, struct rb_node *new) {}
-
-void rb_insert_color(struct rb_node *node, struct rb_root *root) {
-	rb_insert_augmented(node, root, dummy);
-}
-EXPORT_SYMBOL(rb_insert_color);
-
-static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
-			     struct rb_root *root)
+inline void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
+			     struct rb_root *root, rb_augment_rotate *augment)
 {
 	struct rb_node *sibling, *tmp1, *tmp2;
 
@@ -258,6 +229,7 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
 				rb_set_parent_color(tmp1, parent, RB_BLACK);
 				__rb_rotate_set_parents(parent, sibling, root,
 							RB_RED);
+				augment(parent, sibling);
 				sibling = tmp1;
 			}
 			tmp1 = sibling->rb_right;
@@ -304,6 +276,7 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
 				if (tmp1)
 					rb_set_parent_color(tmp1, sibling,
 							    RB_BLACK);
+				augment(sibling, tmp2);
 				tmp1 = sibling;
 				sibling = tmp2;
 			}
@@ -326,6 +299,7 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
 				rb_set_parent(tmp2, parent);
 			__rb_rotate_set_parents(parent, sibling, root,
 						RB_BLACK);
+			augment(parent, sibling);
 			break;
 		} else {
 			sibling = parent->rb_left;
@@ -336,6 +310,7 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
 				rb_set_parent_color(tmp1, parent, RB_BLACK);
 				__rb_rotate_set_parents(parent, sibling, root,
 							RB_RED);
+				augment(parent, sibling);
 				sibling = tmp1;
 			}
 			tmp1 = sibling->rb_left;
@@ -356,6 +331,7 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
 				if (tmp1)
 					rb_set_parent_color(tmp1, sibling,
 							    RB_BLACK);
+				augment(sibling, tmp2);
 				tmp1 = sibling;
 				sibling = tmp2;
 			}
@@ -367,101 +343,26 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
 				rb_set_parent(tmp2, parent);
 			__rb_rotate_set_parents(parent, sibling, root,
 						RB_BLACK);
+			augment(parent, sibling);
 			break;
 		}
 	}
 }
+EXPORT_SYMBOL(__rb_erase_color);
 
-void rb_erase(struct rb_node *node, struct rb_root *root)
-{
-	struct rb_node *parent = rb_parent(node);
-	struct rb_node *child = node->rb_right;
-	struct rb_node *tmp = node->rb_left;
-	bool black;
-
-	if (!tmp) {
-		/* Case 1: node to erase has no more than 1 child (easy!) */
-		if (child)
-one_child:
-			rb_set_parent(child, parent);
-		if (parent) {
-			if (parent->rb_left == node)
-				parent->rb_left = child;
-			else
-				parent->rb_right = child;
-		} else
-			root->rb_node = child;
-
-		black = rb_is_black(node);
-	} else if (!child) {
-		/* Still case 1, but this time the child is node->rb_left */
-		child = tmp;
-		goto one_child;
-	} else {
-		struct rb_node *old = node;
+static inline void dummy_rotate(struct rb_node *old, struct rb_node *new) {}
+static inline void dummy_copy(struct rb_node *old, struct rb_node *new) {}
+static inline void dummy_propagate(struct rb_node *node, struct rb_node *stop) {}
 
-		/*
-		 * Old is the node we want to erase. It's got left and right
-		 * children, which makes things difficult. Let's find the
-		 * next node in the tree to have it fill old's position.
-		 */
-		node = node->rb_right;
-		while ((tmp = node->rb_left) != NULL)
-			node = tmp;
-
-		/* Graft node (old's successor) under old's parent. */
-		if (parent) {
-			if (parent->rb_left == old)
-				parent->rb_left = node;
-			else
-				parent->rb_right = node;
-		} else
-			root->rb_node = node;
-
-		parent = rb_parent(node);
-		black = rb_is_black(node);
-		node->__rb_parent_color = old->__rb_parent_color;
-
-		/*
-		 * Node doesn't have a left child, since it is old's successor,
-		 * so we can take old's left child and graft it under node.
-		 */
-		node->rb_left = tmp = old->rb_left;
-		rb_set_parent(tmp, node);
+void rb_insert_color(struct rb_node *node, struct rb_root *root) {
+	rb_insert_augmented(node, root, dummy_rotate);
+}
+EXPORT_SYMBOL(rb_insert_color);
 
-		child = node->rb_right;
-		if (parent == old) {
-			/*
-			 * Case 2: old is node's parent (we are done!)
-			 *
-			 *    (o)          (n)
-			 *    / \          / \
-			 *  (x) (n)  ->  (x) (c)
-			 *        \
-			 *        (c)
-			 */
-			parent = node;
-		} else {
-			/*
-			 * Case 3: old is node's ancestor but not its parent
-			 *
-			 *    (o)          (n)
-			 *    / \          / \
-			 *  (x) (y)  ->  (x) (y)
-			 *      /            /
-			 *    (n)          (c)
-			 *      \
-			 *      (c)
-			 */
-			node->rb_right = tmp = old->rb_right;
-			parent->rb_left = child;
-			rb_set_parent(tmp, node);
-			if (child)
-				rb_set_parent(child, parent);
-		}
-	}
-	if (black)
-		__rb_erase_color(child, parent, root);
+void rb_erase(struct rb_node *node, struct rb_root *root)
+{
+	rb_erase_augmented(node, root, dummy_copy, dummy_propagate,
+			   dummy_rotate);
 }
 EXPORT_SYMBOL(rb_erase);
 
diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
index 7ccc1e0..278dbfc 100644
--- a/lib/rbtree_test.c
+++ b/lib/rbtree_test.c
@@ -1,5 +1,6 @@
 #include <linux/module.h>
 #include <linux/rbtree.h>
+#include <linux/rbtree_internal.h>
 #include <linux/random.h>
 #include <asm/timex.h>
 
@@ -61,12 +62,6 @@ static inline u32 augment_recompute(struct test_node *node)
 	return max;
 }
 
-static void augment_callback(struct rb_node *rb, void *unused)
-{
-	struct test_node *node = rb_entry(rb, struct test_node, rb);
-	node->augmented = augment_recompute(node);
-}
-
 static void augment_rotate(struct rb_node *rb_old, struct rb_node *rb_new)
 {
 	struct test_node *old = rb_entry(rb_old, struct test_node, rb);
@@ -100,11 +95,29 @@ static void insert_augmented(struct test_node *node, struct rb_root *root)
 	rb_insert_augmented(&node->rb, root, augment_rotate);
 }
 
+static inline void augment_copy(struct rb_node *rb_old, struct rb_node *rb_new)
+{
+	struct test_node *old = rb_entry(rb_old, struct test_node, rb);
+	struct test_node *new = rb_entry(rb_new, struct test_node, rb);
+	new->augmented = old->augmented;
+}
+
+static inline void augment_propagate(struct rb_node *rb, struct rb_node *stop)
+{
+	while (rb != stop) {
+		struct test_node *node = rb_entry(rb, struct test_node, rb);
+		u32 augmented = augment_recompute(node);
+		if (node->augmented == augmented)
+			break;
+		node->augmented = augmented;
+		rb = rb_parent(&node->rb);
+	}
+}
+
 static void erase_augmented(struct test_node *node, struct rb_root *root)
 {
-	struct rb_node *deepest = rb_augment_erase_begin(&node->rb);
-	rb_erase(&node->rb, root);
-	rb_augment_erase_end(deepest, augment_callback, NULL);
+	rb_erase_augmented(&node->rb, root, augment_copy, augment_propagate,
+			   augment_rotate);
 }
 
 static void init(void)
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

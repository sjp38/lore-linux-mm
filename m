Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 255586B0062
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 09:23:55 -0400 (EDT)
Message-ID: <1342012996.3462.154.camel@twins>
Subject: Re: [PATCH 00/13] rbtree updates
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 11 Jul 2012 15:23:16 +0200
In-Reply-To: <1341876923-12469-1-git-send-email-walken@google.com>
References: <1341876923-12469-1-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org


Looks nice.. How about something like the below on top.. I couldn't
immediately find a sane reason for the grand-parent to always be red in
the insertion case.

---
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -23,6 +23,25 @@
 #include <linux/rbtree.h>
 #include <linux/export.h>
=20
+/*
+ * red-black trees properties:  http://en.wikipedia.org/wiki/Rbtree
+ *
+ *  1) A node is either red or black
+ *  2) The root is black
+ *  3) All leaves (NULL) are black
+ *  4) Both children of every red node are black
+ *  5) Every simple path from a given node to any of its descendant leaves
+ *     contains the same number of black nodes.
+ *
+ *  4 and 5 give the O(log n) guarantee, since 4 implies you cannot have t=
wo
+ *  consecutive red nodes in a path and every red node is therefore follow=
ed by
+ *  a black. So if B is the number of black nodes on every simple path (as=
 per
+ *  5), then the longest possible path due to 4 is 2B.
+ *
+ *  We shall indicate color with case, where black nodes are uppercase and=
 red
+ *  nodes will be lowercase.
+ */
+
 #define	RB_RED		0
 #define	RB_BLACK	1
=20
@@ -85,12 +104,27 @@ void rb_insert_color(struct rb_node *nod
 		} else if (rb_is_black(parent))
 			break;
=20
+		/*
+		 * XXX
+		 */
 		gparent =3D rb_red_parent(parent);
=20
 		if (parent =3D=3D gparent->rb_left) {
 			tmp =3D gparent->rb_right;
 			if (tmp && rb_is_red(tmp)) {
-				/* Case 1 - color flips */
+				/*=20
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
 				rb_set_parent_color(tmp, gparent, RB_BLACK);
 				rb_set_parent_color(parent, gparent, RB_BLACK);
 				node =3D gparent;
@@ -100,17 +134,35 @@ void rb_insert_color(struct rb_node *nod
 			}
=20
 			if (parent->rb_right =3D=3D node) {
-				/* Case 2 - left rotate at parent */
+				/*=20
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
 				parent->rb_right =3D tmp =3D node->rb_left;
 				node->rb_left =3D parent;
 				if (tmp)
-					rb_set_parent_color(tmp, parent,
-							    RB_BLACK);
+					rb_set_parent_color(tmp, parent, RB_BLACK);
 				rb_set_parent_color(parent, node, RB_RED);
 				parent =3D node;
 			}
=20
-			/* Case 3 - right rotate at gparent */
+			/*=20
+			 * Case 3 - right rotate at gparent
+			 *
+			 *        G           P
+			 *       / \         / \
+			 *      p   U  -->  n   g
+			 *     /                 \
+			 *    n                   U
+			 */
 			gparent->rb_left =3D tmp =3D parent->rb_right;
 			parent->rb_right =3D gparent;
 			if (tmp)
@@ -134,8 +186,7 @@ void rb_insert_color(struct rb_node *nod
 				parent->rb_left =3D tmp =3D node->rb_right;
 				node->rb_right =3D parent;
 				if (tmp)
-					rb_set_parent_color(tmp, parent,
-							    RB_BLACK);
+					rb_set_parent_color(tmp, parent, RB_BLACK);
 				rb_set_parent_color(parent, node, RB_RED);
 				parent =3D node;
 			}
@@ -175,43 +226,75 @@ static void __rb_erase_color(struct rb_n
 		} else if (parent->rb_left =3D=3D node) {
 			sibling =3D parent->rb_right;
 			if (rb_is_red(sibling)) {
-				/* Case 1 - left rotate at parent */
+				/*=20
+				 * Case 1 - left rotate at parent
+				 *
+				 *     P               S
+				 *    / \             / \
+				 *   N   s    -->    p   Sr
+				 *      / \         / \
+				 *     Sl  Sr      N   Sl
+				 */
 				parent->rb_right =3D tmp1 =3D sibling->rb_left;
 				sibling->rb_left =3D parent;
 				rb_set_parent_color(tmp1, parent, RB_BLACK);
-				__rb_rotate_set_parents(parent, sibling, root,
-							RB_RED);
+				__rb_rotate_set_parents(parent, sibling, root, RB_RED);
 				sibling =3D tmp1;
 			}
 			tmp1 =3D sibling->rb_right;
 			if (!tmp1 || rb_is_black(tmp1)) {
 				tmp2 =3D sibling->rb_left;
 				if (!tmp2 || rb_is_black(tmp2)) {
-					/* Case 2 - sibling color flip */
-					rb_set_parent_color(sibling, parent,
-							    RB_RED);
+					/*=20
+					 * Case 2 - sibling color flip
+					 *
+					 *     P             P
+					 *    / \           / \
+					 *   N   S    -->  N   s
+					 *      / \           / \
+					 *     Sl  Sr        Sl  Sr
+					 *
+					 * This leaves us violating 5), recurse at p.
+					 */
+					rb_set_parent_color(sibling, parent, RB_RED);
 					node =3D parent;
 					parent =3D rb_parent(node);
 					continue;
 				}
-				/* Case 3 - right rotate at sibling */
+				/*=20
+				 * Case 3 - right rotate at sibling=20
+				 *
+				 *    P             P
+				 *   / \           / \
+				 *  N   S    -->  N   sl
+				 *     / \           / \
+				 *    sl  Sr        1   S
+				 *   / \               / \
+				 *  1   2             2   Sr
+				 */
 				sibling->rb_left =3D tmp1 =3D tmp2->rb_right;
 				tmp2->rb_right =3D sibling;
 				parent->rb_right =3D tmp2;
 				if (tmp1)
-					rb_set_parent_color(tmp1, sibling,
-							    RB_BLACK);
+					rb_set_parent_color(tmp1, sibling, RB_BLACK);
 				tmp1 =3D sibling;
 				sibling =3D tmp2;
 			}
-			/* Case 4 - left rotate at parent + color flips */
+			/*=20
+			 * Case 4 - left rotate at parent + color flips=20
+			 *
+			 *       P               S
+			 *      / \             / \
+			 *     N   S     -->   P   Sr
+			 *        / \         / \
+			 *       Sl  Sr      N   Sl
+			 */
 			parent->rb_right =3D tmp2 =3D sibling->rb_left;
 			sibling->rb_left =3D parent;
 			rb_set_parent_color(tmp1, sibling, RB_BLACK);
 			if (tmp2)
 				rb_set_parent(tmp2, parent);
-			__rb_rotate_set_parents(parent, sibling, root,
-						RB_BLACK);
+			__rb_rotate_set_parents(parent, sibling, root, RB_BLACK);
 			break;
 		} else {
 			sibling =3D parent->rb_left;
@@ -220,8 +303,7 @@ static void __rb_erase_color(struct rb_n
 				parent->rb_left =3D tmp1 =3D sibling->rb_right;
 				sibling->rb_right =3D parent;
 				rb_set_parent_color(tmp1, parent, RB_BLACK);
-				__rb_rotate_set_parents(parent, sibling, root,
-							RB_RED);
+				__rb_rotate_set_parents(parent, sibling, root, RB_RED);
 				sibling =3D tmp1;
 			}
 			tmp1 =3D sibling->rb_left;
@@ -229,8 +311,7 @@ static void __rb_erase_color(struct rb_n
 				tmp2 =3D sibling->rb_right;
 				if (!tmp2 || rb_is_black(tmp2)) {
 					/* Case 2 - sibling color flip */
-					rb_set_parent_color(sibling, parent,
-							    RB_RED);
+					rb_set_parent_color(sibling, parent, RB_RED);
 					node =3D parent;
 					parent =3D rb_parent(node);
 					continue;
@@ -240,8 +321,7 @@ static void __rb_erase_color(struct rb_n
 				tmp2->rb_left =3D sibling;
 				parent->rb_left =3D tmp2;
 				if (tmp1)
-					rb_set_parent_color(tmp1, sibling,
-							    RB_BLACK);
+					rb_set_parent_color(tmp1, sibling, RB_BLACK);
 				tmp1 =3D sibling;
 				sibling =3D tmp2;
 			}
@@ -251,8 +331,7 @@ static void __rb_erase_color(struct rb_n
 			rb_set_parent_color(tmp1, sibling, RB_BLACK);
 			if (tmp2)
 				rb_set_parent(tmp2, parent);
-			__rb_rotate_set_parents(parent, sibling, root,
-						RB_BLACK);
+			__rb_rotate_set_parents(parent, sibling, root, RB_BLACK);
 			break;
 		}
 	}
@@ -267,8 +346,7 @@ void rb_erase(struct rb_node *node, stru
 		child =3D node->rb_right;
 	else if (!node->rb_right)
 		child =3D node->rb_left;
-	else
-	{
+	else {
 		struct rb_node *old =3D node, *left;
=20
 		node =3D node->rb_right;
@@ -310,17 +388,15 @@ void rb_erase(struct rb_node *node, stru
=20
 	if (child)
 		rb_set_parent(child, parent);
-	if (parent)
-	{
+	if (parent) {
 		if (parent->rb_left =3D=3D node)
 			parent->rb_left =3D child;
 		else
 			parent->rb_right =3D child;
-	}
-	else
+	} else
 		root->rb_node =3D child;
=20
- color:
+color:
 	if (color =3D=3D RB_BLACK)
 		__rb_erase_color(child, parent, root);
 }
@@ -433,8 +509,10 @@ struct rb_node *rb_next(const struct rb_
 	if (RB_EMPTY_NODE(node))
 		return NULL;
=20
-	/* If we have a right-hand child, go down and then left as far
-	   as we can. */
+	/*=20
+	 * If we have a right-hand child, go down and then left as far as we
+	 * can.=20
+	 */
 	if (node->rb_right) {
 		node =3D node->rb_right;=20
 		while (node->rb_left)
@@ -442,12 +520,13 @@ struct rb_node *rb_next(const struct rb_
 		return (struct rb_node *)node;
 	}
=20
-	/* No right-hand children.  Everything down and left is
-	   smaller than us, so any 'next' node must be in the general
-	   direction of our parent. Go up the tree; any time the
-	   ancestor is a right-hand child of its parent, keep going
-	   up. First time it's a left-hand child of its parent, said
-	   parent is our 'next' node. */
+	/*=20
+	 * No right-hand children. Everything down and left is smaller than
+	 * us, so any 'next' node must be in the general direction of our
+	 * parent. Go up the tree; any time the ancestor is a right-hand child
+	 * of its parent, keep going up. First time it's a left-hand child of
+	 * its parent, said parent is our 'next' node.=20
+	 */=20
 	while ((parent =3D rb_parent(node)) && node =3D=3D parent->rb_right)
 		node =3D parent;
=20
@@ -462,8 +541,10 @@ struct rb_node *rb_prev(const struct rb_
 	if (RB_EMPTY_NODE(node))
 		return NULL;
=20
-	/* If we have a left-hand child, go down and then right as far
-	   as we can. */
+	/*=20
+	 * If we have a left-hand child, go down and then right as far as we
+	 * can.=20
+	 */
 	if (node->rb_left) {
 		node =3D node->rb_left;=20
 		while (node->rb_right)
@@ -471,8 +552,10 @@ struct rb_node *rb_prev(const struct rb_
 		return (struct rb_node *)node;
 	}
=20
-	/* No left-hand children. Go up till we find an ancestor which
-	   is a right-hand child of its parent */
+	/*
+	 * No left-hand children. Go up till we find an ancestor which is a
+	 * right-hand child of its parent=20
+	 */
 	while ((parent =3D rb_parent(node)) && node =3D=3D parent->rb_left)
 		node =3D parent;
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

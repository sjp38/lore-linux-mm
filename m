Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 77F806B006E
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 18:34:41 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so77012ghr.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 15:34:40 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 6/9] rbtree: low level optimizations in rb_erase()
Date: Thu,  2 Aug 2012 15:34:15 -0700
Message-Id: <1343946858-8170-7-git-send-email-walken@google.com>
In-Reply-To: <1343946858-8170-1-git-send-email-walken@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Various minor optimizations in rb_erase():
- Avoid multiple loading of node->__rb_parent_color when computing parent
  and color information (possibly not in close sequence, as there might
  be further branches in the algorithm)
- In the 1-child subcase of case 1, copy the __rb_parent_color field from
  the erased node to the child instead of recomputing it from the desired
  parent and color
- When searching for the erased node's successor, differentiate between
  cases 2 and 3 based on whether any left links were followed. This avoids
  a condition later down.
- In case 3, keep a pointer to the erased node's right child so we don't
  have to refetch it later to adjust its parent.
- In the no-childs subcase of cases 2 and 3, place the rebalance assigment
  last so that the compiler can remove the following if(rebalance) test.

Also, added some comments to illustrate cases 2 and 3.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 lib/rbtree.c |   97 +++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 63 insertions(+), 34 deletions(-)

diff --git a/lib/rbtree.c b/lib/rbtree.c
index 80b0925..12d9147 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -47,9 +47,14 @@
 #define	RB_RED		0
 #define	RB_BLACK	1
 
-#define rb_color(r)   ((r)->__rb_parent_color & 1)
-#define rb_is_red(r)   (!rb_color(r))
-#define rb_is_black(r) rb_color(r)
+#define __rb_parent(pc)    ((struct rb_node *)(pc & ~3))
+
+#define __rb_color(pc)     ((pc) & 1)
+#define __rb_is_black(pc)  __rb_color(pc)
+#define __rb_is_red(pc)    (!__rb_color(pc))
+#define rb_color(rb)       __rb_color((rb)->__rb_parent_color)
+#define rb_is_red(rb)      __rb_is_red((rb)->__rb_parent_color)
+#define rb_is_black(rb)    __rb_is_black((rb)->__rb_parent_color)
 
 static inline void rb_set_black(struct rb_node *rb)
 {
@@ -378,6 +383,7 @@ void rb_erase(struct rb_node *node, struct rb_root *root)
 {
 	struct rb_node *child = node->rb_right, *tmp = node->rb_left;
 	struct rb_node *parent, *rebalance;
+	unsigned long pc;
 
 	if (!tmp) {
 		/*
@@ -387,51 +393,74 @@ void rb_erase(struct rb_node *node, struct rb_root *root)
 		 * and node must be black due to 4). We adjust colors locally
 		 * so as to bypass __rb_erase_color() later on.
 		 */
-
-		parent = rb_parent(node);
+		pc = node->__rb_parent_color;
+		parent = __rb_parent(pc);
 		__rb_change_child(node, child, parent, root);
 		if (child) {
-			rb_set_parent_color(child, parent, RB_BLACK);
+			child->__rb_parent_color = pc;
 			rebalance = NULL;
-		} else {
-			rebalance = rb_is_black(node) ? parent : NULL;
-		}
+		} else
+			rebalance = __rb_is_black(pc) ? parent : NULL;
 	} else if (!child) {
 		/* Still case 1, but this time the child is node->rb_left */
-		parent = rb_parent(node);
+		tmp->__rb_parent_color = pc = node->__rb_parent_color;
+		parent = __rb_parent(pc);
 		__rb_change_child(node, tmp, parent, root);
-		rb_set_parent_color(tmp, parent, RB_BLACK);
 		rebalance = NULL;
 	} else {
-		struct rb_node *old = node, *left;
-
-		node = child;
-		while ((left = node->rb_left) != NULL)
-			node = left;
-
-		__rb_change_child(old, node, rb_parent(old), root);
-
-		child = node->rb_right;
-		parent = rb_parent(node);
-
-		if (parent == old) {
-			parent = node;
+		struct rb_node *successor = child, *child2;
+		tmp = child->rb_left;
+		if (!tmp) {
+			/*
+			 * Case 2: node's successor is its right child
+			 *
+			 *    (n)          (s)
+			 *    / \          / \
+			 *  (x) (s)  ->  (x) (c)
+			 *        \
+			 *        (c)
+			 */
+			parent = child;
+			child2 = child->rb_right;
 		} else {
-			parent->rb_left = child;
-
-			node->rb_right = old->rb_right;
-			rb_set_parent(old->rb_right, node);
+			/* Case 3: node's successor is leftmost under its
+			 * right child subtree
+			 *
+			 *    (n)          (s)
+			 *    / \          / \
+			 *  (x) (y)  ->  (x) (y)
+			 *      /            /
+			 *    (p)          (p)
+			 *    /            /
+			 *  (s)          (c)
+			 *    \
+			 *    (c)
+			 */
+			do {
+				parent = successor;
+				successor = tmp;
+				tmp = tmp->rb_left;
+			} while (tmp);
+			parent->rb_left = child2 = successor->rb_right;
+			successor->rb_right = child;
+			rb_set_parent(child, successor);
 		}
 
-		if (child) {
-			rb_set_parent_color(child, parent, RB_BLACK);
+		successor->rb_left = tmp = node->rb_left;
+		rb_set_parent(tmp, successor);
+
+		pc = node->__rb_parent_color;
+		tmp = __rb_parent(pc);
+		__rb_change_child(node, successor, tmp, root);
+		if (child2) {
+			successor->__rb_parent_color = pc;
+			rb_set_parent_color(child2, parent, RB_BLACK);
 			rebalance = NULL;
 		} else {
-			rebalance = rb_is_black(node) ? parent : NULL;
+			unsigned long pc2 = successor->__rb_parent_color;
+			successor->__rb_parent_color = pc;
+			rebalance = __rb_is_black(pc2) ? parent : NULL;
 		}
-		node->__rb_parent_color = old->__rb_parent_color;
-		node->rb_left = old->rb_left;
-		rb_set_parent(old->rb_left, node);
 	}
 
 	if (rebalance)
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

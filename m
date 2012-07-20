Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 1ACA26B006C
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 08:31:43 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so7647111pbb.14
        for <linux-mm@kvack.org>; Fri, 20 Jul 2012 05:31:42 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 4/6] rbtree: faster augmented insert
Date: Fri, 20 Jul 2012 05:31:05 -0700
Message-Id: <1342787467-5493-5-git-send-email-walken@google.com>
In-Reply-To: <1342787467-5493-1-git-send-email-walken@google.com>
References: <1342787467-5493-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Introduce rb_insert_augmented(), which is a version of rb_insert_color()
with an added callback on tree rotations. This can be used for insertion
into an augmented tree: the handcoded search phase must be updated to
maintain the augmented information on insertion, and then the rbtree
coloring/rebalancing algorithms keep it up to date.

rb_insert_color() is now a special case of rb_insert_augmented() with
a do-nothing callback. I used inlining to optimize out the callback,
with the intent that this would generate the same code as previously
for rb_insert_augmented(). This didn't fully work, as my compiler output
is now *smaller* than before for that function. Speed wise, they seem
comparable though.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/rbtree.h |    5 +++++
 lib/rbtree.c           |   14 +++++++++++++-
 lib/rbtree_test.c      |   31 +++++++++++++++++++++++--------
 3 files changed, 41 insertions(+), 9 deletions(-)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index bf836a2..1364b81 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -61,6 +61,11 @@ struct rb_root {
 extern void rb_insert_color(struct rb_node *, struct rb_root *);
 extern void rb_erase(struct rb_node *, struct rb_root *);
 
+typedef void rb_augment_rotate(struct rb_node *old, struct rb_node *new);
+
+extern void rb_insert_augmented(struct rb_node *node, struct rb_root *root,
+				rb_augment_rotate *augment);
+
 typedef void (*rb_augment_f)(struct rb_node *node, void *data);
 
 extern void rb_augment_insert(struct rb_node *node,
diff --git a/lib/rbtree.c b/lib/rbtree.c
index 8b111cc..a6ae4c5 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -88,7 +88,8 @@ __rb_rotate_set_parents(struct rb_node *old, struct rb_node *new,
 		root->rb_node = new;
 }
 
-void rb_insert_color(struct rb_node *node, struct rb_root *root)
+inline void rb_insert_augmented(struct rb_node *node, struct rb_root *root,
+				rb_augment_rotate *augment)
 {
 	struct rb_node *parent = rb_red_parent(node), *gparent, *tmp;
 
@@ -152,6 +153,7 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 					rb_set_parent_color(tmp, parent,
 							    RB_BLACK);
 				rb_set_parent_color(parent, node, RB_RED);
+				augment(parent, node);
 				parent = node;
 				tmp = node->rb_right;
 			}
@@ -170,6 +172,7 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 			if (tmp)
 				rb_set_parent_color(tmp, gparent, RB_BLACK);
 			__rb_rotate_set_parents(gparent, parent, root, RB_RED);
+			augment(gparent, parent);
 			break;
 		} else {
 			tmp = gparent->rb_left;
@@ -192,6 +195,7 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 					rb_set_parent_color(tmp, parent,
 							    RB_BLACK);
 				rb_set_parent_color(parent, node, RB_RED);
+				augment(parent, node);
 				parent = node;
 				tmp = node->rb_left;
 			}
@@ -202,10 +206,18 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 			if (tmp)
 				rb_set_parent_color(tmp, gparent, RB_BLACK);
 			__rb_rotate_set_parents(gparent, parent, root, RB_RED);
+			augment(gparent, parent);
 			break;
 		}
 	}
 }
+EXPORT_SYMBOL(rb_insert_augmented);
+
+static inline void dummy(struct rb_node *old, struct rb_node *new) {}
+
+void rb_insert_color(struct rb_node *node, struct rb_root *root) {
+	rb_insert_augmented(node, root, dummy);
+}
 EXPORT_SYMBOL(rb_insert_color);
 
 static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
diff --git a/lib/rbtree_test.c b/lib/rbtree_test.c
index 2dfafe4..5ace332 100644
--- a/lib/rbtree_test.c
+++ b/lib/rbtree_test.c
@@ -67,22 +67,37 @@ static void augment_callback(struct rb_node *rb, void *unused)
 	node->augmented = augment_recompute(node);
 }
 
+static void augment_rotate(struct rb_node *rb_old, struct rb_node *rb_new)
+{
+	struct test_node *old = rb_entry(rb_old, struct test_node, rb);
+	struct test_node *new = rb_entry(rb_new, struct test_node, rb);
+
+	/* Rotation doesn't change subtree's augmented value */
+	new->augmented = old->augmented;
+	old->augmented = augment_recompute(old);
+}
+
 static void insert_augmented(struct test_node *node, struct rb_root *root)
 {
-	struct rb_node **new = &root->rb_node, *parent = NULL;
+	struct rb_node **new = &root->rb_node, *rb_parent = NULL;
 	u32 key = node->key;
+	u32 val = node->val;
+	struct test_node *parent;
 
 	while (*new) {
-		parent = *new;
-		if (key < rb_entry(parent, struct test_node, rb)->key)
-			new = &parent->rb_left;
+		rb_parent = *new;
+		parent = rb_entry(rb_parent, struct test_node, rb);
+		if (parent->augmented < val)
+			parent->augmented = val;
+		if (key < parent->key)
+			new = &parent->rb.rb_left;
 		else
-			new = &parent->rb_right;
+			new = &parent->rb.rb_right;
 	}
 
-	rb_link_node(&node->rb, parent, new);
-	rb_insert_color(&node->rb, root);
-	rb_augment_insert(&node->rb, augment_callback, NULL);
+	node->augmented = val;
+	rb_link_node(&node->rb, rb_parent, new);
+	rb_insert_augmented(&node->rb, root, augment_rotate);
 }
 
 static void erase_augmented(struct test_node *node, struct rb_root *root)
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

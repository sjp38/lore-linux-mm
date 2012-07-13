Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 27A006B0071
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:32:42 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so5512005pbb.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:32:41 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 04/12] rbtree: move some implementation details from rbtree.h to rbtree.c
Date: Thu, 12 Jul 2012 17:31:49 -0700
Message-Id: <1342139517-3451-5-git-send-email-walken@google.com>
In-Reply-To: <1342139517-3451-1-git-send-email-walken@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

rbtree users must use the documented APIs to manipulate the tree
structure.  Low-level helpers to manipulate node colors and parenthood
are not part of that API, so move them to lib/rbtree.c

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/rbtree.h |   34 +++++++++-------------------------
 lib/rbtree.c           |   20 +++++++++++++++++++-
 2 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 2049087..bf836a2 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -32,37 +32,19 @@
 #include <linux/kernel.h>
 #include <linux/stddef.h>
 
-struct rb_node
-{
-	unsigned long  rb_parent_color;
-#define	RB_RED		0
-#define	RB_BLACK	1
+struct rb_node {
+	unsigned long  __rb_parent_color;
 	struct rb_node *rb_right;
 	struct rb_node *rb_left;
 } __attribute__((aligned(sizeof(long))));
     /* The alignment might seem pointless, but allegedly CRIS needs it */
 
-struct rb_root
-{
+struct rb_root {
 	struct rb_node *rb_node;
 };
 
 
-#define rb_parent(r)   ((struct rb_node *)((r)->rb_parent_color & ~3))
-#define rb_color(r)   ((r)->rb_parent_color & 1)
-#define rb_is_red(r)   (!rb_color(r))
-#define rb_is_black(r) rb_color(r)
-#define rb_set_red(r)  do { (r)->rb_parent_color &= ~1; } while (0)
-#define rb_set_black(r)  do { (r)->rb_parent_color |= 1; } while (0)
-
-static inline void rb_set_parent(struct rb_node *rb, struct rb_node *p)
-{
-	rb->rb_parent_color = (rb->rb_parent_color & 3) | (unsigned long)p;
-}
-static inline void rb_set_color(struct rb_node *rb, int color)
-{
-	rb->rb_parent_color = (rb->rb_parent_color & ~1) | color;
-}
+#define rb_parent(r)   ((struct rb_node *)((r)->__rb_parent_color & ~3))
 
 #define RB_ROOT	(struct rb_root) { NULL, }
 #define	rb_entry(ptr, type, member) container_of(ptr, type, member)
@@ -70,8 +52,10 @@ static inline void rb_set_color(struct rb_node *rb, int color)
 #define RB_EMPTY_ROOT(root)  ((root)->rb_node == NULL)
 
 /* 'empty' nodes are nodes that are known not to be inserted in an rbree */
-#define RB_EMPTY_NODE(node)  ((node)->rb_parent_color == (unsigned long)(node))
-#define RB_CLEAR_NODE(node)  ((node)->rb_parent_color = (unsigned long)(node))
+#define RB_EMPTY_NODE(node)  \
+	((node)->__rb_parent_color == (unsigned long)(node))
+#define RB_CLEAR_NODE(node)  \
+	((node)->__rb_parent_color = (unsigned long)(node))
 
 
 extern void rb_insert_color(struct rb_node *, struct rb_root *);
@@ -98,7 +82,7 @@ extern void rb_replace_node(struct rb_node *victim, struct rb_node *new,
 static inline void rb_link_node(struct rb_node * node, struct rb_node * parent,
 				struct rb_node ** rb_link)
 {
-	node->rb_parent_color = (unsigned long )parent;
+	node->__rb_parent_color = (unsigned long)parent;
 	node->rb_left = node->rb_right = NULL;
 
 	*rb_link = node;
diff --git a/lib/rbtree.c b/lib/rbtree.c
index fe43c8c..ccada9a 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -23,6 +23,24 @@
 #include <linux/rbtree.h>
 #include <linux/export.h>
 
+#define	RB_RED		0
+#define	RB_BLACK	1
+
+#define rb_color(r)   ((r)->__rb_parent_color & 1)
+#define rb_is_red(r)   (!rb_color(r))
+#define rb_is_black(r) rb_color(r)
+#define rb_set_red(r)  do { (r)->__rb_parent_color &= ~1; } while (0)
+#define rb_set_black(r)  do { (r)->__rb_parent_color |= 1; } while (0)
+
+static inline void rb_set_parent(struct rb_node *rb, struct rb_node *p)
+{
+	rb->__rb_parent_color = rb_color(rb) | (unsigned long)p;
+}
+static inline void rb_set_color(struct rb_node *rb, int color)
+{
+	rb->__rb_parent_color = (rb->__rb_parent_color & ~1) | color;
+}
+
 static void __rb_rotate_left(struct rb_node *node, struct rb_root *root)
 {
 	struct rb_node *right = node->rb_right;
@@ -255,7 +273,7 @@ void rb_erase(struct rb_node *node, struct rb_root *root)
 			rb_set_parent(old->rb_right, node);
 		}
 
-		node->rb_parent_color = old->rb_parent_color;
+		node->__rb_parent_color = old->__rb_parent_color;
 		node->rb_left = old->rb_left;
 		rb_set_parent(old->rb_left, node);
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

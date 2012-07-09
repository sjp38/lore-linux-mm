Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 91F1E6B0080
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 19:35:54 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so24193846pbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 16:35:54 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 09/13] rbtree: optimize color flips and parent fetching in rb_insert_color()
Date: Mon,  9 Jul 2012 16:35:19 -0700
Message-Id: <1341876923-12469-10-git-send-email-walken@google.com>
In-Reply-To: <1341876923-12469-1-git-send-email-walken@google.com>
References: <1341876923-12469-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

- Use the newly introduced rb_set_parent_color() function to flip the color
  of nodes whose parent is already known.
- Optimize rb_parent() when the node is known to be red - there is no need
  to mask out the color in that case.
- Flipping gparent's color to red requires us to fetch its rb_parent_color
  field, so we can reuse it as the parent value for the next loop iteration.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 lib/rbtree.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/lib/rbtree.c b/lib/rbtree.c
index f668886..56369d8 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -47,6 +47,11 @@ static inline void rb_set_parent_color(struct rb_node *rb,
 	rb->rb_parent_color = (unsigned long)p | color;
 }
 
+static inline struct rb_node *rb_red_parent(struct rb_node *red)
+{
+	return (struct rb_node *)red->rb_parent_color;
+}
+
 static void __rb_rotate_left(struct rb_node *node, struct rb_root *root)
 {
 	struct rb_node *right = node->rb_right;
@@ -116,7 +121,7 @@ __rb_rotate_set_parents(struct rb_node *old, struct rb_node *new,
 
 void rb_insert_color(struct rb_node *node, struct rb_root *root)
 {
-	struct rb_node *parent, *gparent, *tmp;
+	struct rb_node *parent = rb_red_parent(node), *gparent, *tmp;
 
 	while (true) {
 		/*
@@ -126,23 +131,23 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
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
+		gparent = rb_red_parent(parent);
 
 		if (parent == gparent->rb_left) {
 			tmp = gparent->rb_right;
 			if (tmp && rb_is_red(tmp)) {
 				/* Case 1 - color flips */
-				rb_set_black(tmp);
-				rb_set_black(parent);
-				rb_set_red(gparent);
+				rb_set_parent_color(tmp, gparent, RB_BLACK);
+				rb_set_parent_color(parent, gparent, RB_BLACK);
 				node = gparent;
+				parent = rb_parent(node);
+				rb_set_parent_color(node, parent, RB_RED);
 				continue;
 			}
 
@@ -168,10 +173,11 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 			tmp = gparent->rb_left;
 			if (tmp && rb_is_red(tmp)) {
 				/* Case 1 - color flips */
-				rb_set_black(tmp);
-				rb_set_black(parent);
-				rb_set_red(gparent);
+				rb_set_parent_color(tmp, gparent, RB_BLACK);
+				rb_set_parent_color(parent, gparent, RB_BLACK);
 				node = gparent;
+				parent = rb_parent(node);
+				rb_set_parent_color(node, parent, RB_RED);
 				continue;
 			}
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

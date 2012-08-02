Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 226846B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 18:34:35 -0400 (EDT)
Received: by mail-yx0-f169.google.com with SMTP id r5so78993yen.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 15:34:34 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 2/9] rbtree: optimize fetching of sibling node
Date: Thu,  2 Aug 2012 15:34:11 -0700
Message-Id: <1343946858-8170-3-git-send-email-walken@google.com>
In-Reply-To: <1343946858-8170-1-git-send-email-walken@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

When looking to fetch a node's sibling, we went through a sequence of:
- check if node is the parent's left child
- if it is, then fetch the parent's right child

This can be replaced with:
- fetch the parent's right child as an assumed sibling
- check that node is NOT the fetched child

This avoids fetching the parent's left child when node is actually
that child. Saves a bit on code size, though it doesn't seem to make
a large difference in speed.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 lib/rbtree.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/lib/rbtree.c b/lib/rbtree.c
index 0892670..61cdd0e 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -107,8 +107,8 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 
 		gparent = rb_red_parent(parent);
 
-		if (parent == gparent->rb_left) {
-			tmp = gparent->rb_right;
+		tmp = gparent->rb_right;
+		if (parent != tmp) {	/* parent == gparent->rb_left */
 			if (tmp && rb_is_red(tmp)) {
 				/*
 				 * Case 1 - color flips
@@ -131,7 +131,8 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 				continue;
 			}
 
-			if (parent->rb_right == node) {
+			tmp = parent->rb_right;
+			if (node == tmp) {
 				/*
 				 * Case 2 - left rotate at parent
 				 *
@@ -151,6 +152,7 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 							    RB_BLACK);
 				rb_set_parent_color(parent, node, RB_RED);
 				parent = node;
+				tmp = node->rb_right;
 			}
 
 			/*
@@ -162,7 +164,7 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 			 *     /                 \
 			 *    n                   U
 			 */
-			gparent->rb_left = tmp = parent->rb_right;
+			gparent->rb_left = tmp;  /* == parent->rb_right */
 			parent->rb_right = gparent;
 			if (tmp)
 				rb_set_parent_color(tmp, gparent, RB_BLACK);
@@ -180,7 +182,8 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 				continue;
 			}
 
-			if (parent->rb_left == node) {
+			tmp = parent->rb_left;
+			if (node == tmp) {
 				/* Case 2 - right rotate at parent */
 				parent->rb_left = tmp = node->rb_right;
 				node->rb_right = parent;
@@ -189,10 +192,11 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 							    RB_BLACK);
 				rb_set_parent_color(parent, node, RB_RED);
 				parent = node;
+				tmp = node->rb_left;
 			}
 
 			/* Case 3 - left rotate at gparent */
-			gparent->rb_right = tmp = parent->rb_left;
+			gparent->rb_right = tmp;  /* == parent->rb_left */
 			parent->rb_left = gparent;
 			if (tmp)
 				rb_set_parent_color(tmp, gparent, RB_BLACK);
@@ -223,8 +227,9 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
 			break;
 		} else if (!parent) {
 			break;
-		} else if (parent->rb_left == node) {
-			sibling = parent->rb_right;
+		}
+		sibling = parent->rb_right;
+		if (node != sibling) {	/* node == parent->rb_left */
 			if (rb_is_red(sibling)) {
 				/*
 				 * Case 1 - left rotate at parent
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

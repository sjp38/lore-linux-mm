Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 477C56B0062
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 18:34:38 -0400 (EDT)
Received: by yhr47 with SMTP id 47so71191yhr.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 15:34:37 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 4/9] rbtree: place easiest case first in rb_erase()
Date: Thu,  2 Aug 2012 15:34:13 -0700
Message-Id: <1343946858-8170-5-git-send-email-walken@google.com>
In-Reply-To: <1343946858-8170-1-git-send-email-walken@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

In rb_erase, move the easy case (node to erase has no more than
1 child) first. I feel the code reads easier that way.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 lib/rbtree.c |   35 ++++++++++++++++++-----------------
 1 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/lib/rbtree.c b/lib/rbtree.c
index de89a61..bde1b5c 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -368,17 +368,28 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
 
 void rb_erase(struct rb_node *node, struct rb_root *root)
 {
-	struct rb_node *child, *parent;
+	struct rb_node *child = node->rb_right, *tmp = node->rb_left;
+	struct rb_node *parent;
 	int color;
 
-	if (!node->rb_left)
-		child = node->rb_right;
-	else if (!node->rb_right)
-		child = node->rb_left;
-	else {
+	if (!tmp) {
+	case1:
+		/* Case 1: node to erase has no more than 1 child (easy!) */
+
+		parent = rb_parent(node);
+		color = rb_color(node);
+
+		if (child)
+			rb_set_parent(child, parent);
+		__rb_change_child(node, child, parent, root);
+	} else if (!child) {
+		/* Still case 1, but this time the child is node->rb_left */
+		child = tmp;
+		goto case1;
+	} else {
 		struct rb_node *old = node, *left;
 
-		node = node->rb_right;
+		node = child;
 		while ((left = node->rb_left) != NULL)
 			node = left;
 
@@ -402,18 +413,8 @@ void rb_erase(struct rb_node *node, struct rb_root *root)
 		node->__rb_parent_color = old->__rb_parent_color;
 		node->rb_left = old->rb_left;
 		rb_set_parent(old->rb_left, node);
-
-		goto color;
 	}
 
-	parent = rb_parent(node);
-	color = rb_color(node);
-
-	if (child)
-		rb_set_parent(child, parent);
-	__rb_change_child(node, child, parent, root);
-
-color:
 	if (color == RB_BLACK)
 		__rb_erase_color(child, parent, root);
 }
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

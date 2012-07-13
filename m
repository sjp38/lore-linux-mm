Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 1817D6B007B
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:33:02 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so5512005pbb.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:33:01 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 09/12] rbtree: adjust node color in __rb_erase_color() only when necessary
Date: Thu, 12 Jul 2012 17:31:54 -0700
Message-Id: <1342139517-3451-10-git-send-email-walken@google.com>
In-Reply-To: <1342139517-3451-1-git-send-email-walken@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

In __rb_erase_color(), we were always setting a node to black after
exiting the main loop. And in one case, after fixing up the tree to
satisfy all rbtree invariants, we were setting the current node to root
just to guarantee a loop exit, at which point the root would be set to
black. However this is not necessary, as the root of an rbtree is already
known to be black. The only case where the color flip is required is when
we exit the loop due to the current node being red, and it's easiest to
just do the flip at that point instead of doing it after the loop.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 lib/rbtree.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/lib/rbtree.c b/lib/rbtree.c
index 41cf19b..baf7c83 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -259,10 +259,22 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
 {
 	struct rb_node *other;
 
-	while ((!node || rb_is_black(node)) && node != root->rb_node)
-	{
-		if (parent->rb_left == node)
-		{
+	while (true) {
+		/*
+		 * Loop invariant: all leaf paths going through node have a
+		 * black node count that is 1 lower than other leaf paths.
+		 *
+		 * If node is red, we can flip it to black to adjust.
+		 * If node is the root, all leaf paths go through it.
+		 * Otherwise, we need to adjust the tree through color flips
+		 * and tree rotations as per one of the 4 cases below.
+		 */
+		if (node && rb_is_red(node)) {
+			rb_set_black(node);
+			break;
+		} else if (!parent) {
+			break;
+		} else if (parent->rb_left == node) {
 			other = parent->rb_right;
 			if (rb_is_red(other))
 			{
@@ -291,12 +303,9 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
 				rb_set_black(parent);
 				rb_set_black(other->rb_right);
 				__rb_rotate_left(parent, root);
-				node = root->rb_node;
 				break;
 			}
-		}
-		else
-		{
+		} else {
 			other = parent->rb_left;
 			if (rb_is_red(other))
 			{
@@ -325,13 +334,10 @@ static void __rb_erase_color(struct rb_node *node, struct rb_node *parent,
 				rb_set_black(parent);
 				rb_set_black(other->rb_left);
 				__rb_rotate_right(parent, root);
-				node = root->rb_node;
 				break;
 			}
 		}
 	}
-	if (node)
-		rb_set_black(node);
 }
 
 void rb_erase(struct rb_node *node, struct rb_root *root)
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

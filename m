Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 95B186B0075
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:32:55 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so5512005pbb.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:32:55 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 07/12] rbtree: adjust root color in rb_insert_color() only when necessary
Date: Thu, 12 Jul 2012 17:31:52 -0700
Message-Id: <1342139517-3451-8-git-send-email-walken@google.com>
In-Reply-To: <1342139517-3451-1-git-send-email-walken@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

The root node of an rbtree must always be black. However, rb_insert_color()
only needs to maintain this invariant when it has been broken - that is,
when it exits the loop due to the current (red) node being the root.
In all other cases (exiting after tree rotations, or exiting due to
an existing black parent) the invariant is already satisfied, so there
is no need to adjust the root node color.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 lib/rbtree.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/lib/rbtree.c b/lib/rbtree.c
index 12abb8a..d0be5fc 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -91,8 +91,21 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 {
 	struct rb_node *parent, *gparent;
 
-	while ((parent = rb_parent(node)) && rb_is_red(parent))
-	{
+	while (true) {
+		/*
+		 * Loop invariant: node is red
+		 *
+		 * If there is a black parent, we are done.
+		 * Otherwise, take some corrective action as we don't
+		 * want a red root or two consecutive red nodes.
+		 */
+		parent = rb_parent(node);
+		if (!parent) {
+			rb_set_black(node);
+			break;
+		} else if (rb_is_black(parent))
+			break;
+
 		gparent = rb_parent(parent);
 
 		if (parent == gparent->rb_left)
@@ -142,8 +155,6 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 			break;
 		}
 	}
-
-	rb_set_black(root->rb_node);
 }
 EXPORT_SYMBOL(rb_insert_color);
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

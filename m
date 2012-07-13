Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 4C18F6B0073
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:32:52 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so3647214ghr.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:32:51 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 06/12] rbtree: break out of rb_insert_color loop after tree rotation
Date: Thu, 12 Jul 2012 17:31:51 -0700
Message-Id: <1342139517-3451-7-git-send-email-walken@google.com>
In-Reply-To: <1342139517-3451-1-git-send-email-walken@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

It is a well known property of rbtrees that insertion never requires
more than two tree rotations.  In our implementation, after one loop
iteration identified one or two necessary tree rotations, we would iterate
and look for more.  However at that point the node's parent would always
be black, which would cause us to exit the loop.

We can make the code flow more obvious by just adding a break statement
after the tree rotations, where we know we are done.  Additionally, in the
cases where two tree rotations are necessary, we don't have to update the
'node' pointer as it wouldn't be used until the next loop iteration, which
we now avoid due to this break statement.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 lib/rbtree.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/lib/rbtree.c b/lib/rbtree.c
index ccada9a..12abb8a 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -109,18 +109,15 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 				}
 			}
 
-			if (parent->rb_right == node)
-			{
-				register struct rb_node *tmp;
+			if (parent->rb_right == node) {
 				__rb_rotate_left(parent, root);
-				tmp = parent;
 				parent = node;
-				node = tmp;
 			}
 
 			rb_set_black(parent);
 			rb_set_red(gparent);
 			__rb_rotate_right(gparent, root);
+			break;
 		} else {
 			{
 				register struct rb_node *uncle = gparent->rb_left;
@@ -134,18 +131,15 @@ void rb_insert_color(struct rb_node *node, struct rb_root *root)
 				}
 			}
 
-			if (parent->rb_left == node)
-			{
-				register struct rb_node *tmp;
+			if (parent->rb_left == node) {
 				__rb_rotate_right(parent, root);
-				tmp = parent;
 				parent = node;
-				node = tmp;
 			}
 
 			rb_set_black(parent);
 			rb_set_red(gparent);
 			__rb_rotate_left(gparent, root);
+			break;
 		}
 	}
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

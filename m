Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 732FA6B0068
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:32:34 -0400 (EDT)
Received: by yhr47 with SMTP id 47so3879971yhr.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:32:33 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 02/12] rbtree: empty nodes have no color
Date: Thu, 12 Jul 2012 17:31:47 -0700
Message-Id: <1342139517-3451-3-git-send-email-walken@google.com>
In-Reply-To: <1342139517-3451-1-git-send-email-walken@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Empty nodes have no color.  We can make use of this property to
simplify the code emitted by the RB_EMPTY_NODE and RB_CLEAR_NODE
macros.  Also, we can get rid of the rb_init_node function which had
been introduced by commit 88d19cf37952a7e1e38b2bf87a00f0e857e63180
to avoid some issue with the empty node's color not being initialized.

I'm not sure what the RB_EMPTY_NODE checks in rb_prev() / rb_next()
are doing there, though. axboe introduced them in commit 10fd48f2376d.
The way I see it, the 'empty node' abstraction is only used by rbtree
users to flag nodes that they haven't inserted in any rbtree, so asking
the predecessor or successor of such nodes doesn't make any sense.

One final rb_init_node() caller was recently added in sysctl code
to implement faster sysctl name lookups. This code doesn't make use
of RB_EMPTY_NODE at all, and from what I could see it only called
rb_init_node() under the mistaken assumption that such initialization
was required before node insertion.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 fs/proc/proc_sysctl.c      |    4 +---
 include/linux/rbtree.h     |   15 +++++----------
 include/linux/timerqueue.h |    2 +-
 lib/rbtree.c               |    4 ++--
 4 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 21d836f..33aea86 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -168,10 +168,8 @@ static void init_header(struct ctl_table_header *head,
 	head->node = node;
 	if (node) {
 		struct ctl_table *entry;
-		for (entry = table; entry->procname; entry++, node++) {
-			rb_init_node(&node->node);
+		for (entry = table; entry->procname; entry++, node++)
 			node->header = head;
-		}
 	}
 }
 
diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index e6a8077..2049087 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -67,17 +67,12 @@ static inline void rb_set_color(struct rb_node *rb, int color)
 #define RB_ROOT	(struct rb_root) { NULL, }
 #define	rb_entry(ptr, type, member) container_of(ptr, type, member)
 
-#define RB_EMPTY_ROOT(root)	((root)->rb_node == NULL)
-#define RB_EMPTY_NODE(node)	(rb_parent(node) == node)
-#define RB_CLEAR_NODE(node)	(rb_set_parent(node, node))
+#define RB_EMPTY_ROOT(root)  ((root)->rb_node == NULL)
+
+/* 'empty' nodes are nodes that are known not to be inserted in an rbree */
+#define RB_EMPTY_NODE(node)  ((node)->rb_parent_color == (unsigned long)(node))
+#define RB_CLEAR_NODE(node)  ((node)->rb_parent_color = (unsigned long)(node))
 
-static inline void rb_init_node(struct rb_node *rb)
-{
-	rb->rb_parent_color = 0;
-	rb->rb_right = NULL;
-	rb->rb_left = NULL;
-	RB_CLEAR_NODE(rb);
-}
 
 extern void rb_insert_color(struct rb_node *, struct rb_root *);
 extern void rb_erase(struct rb_node *, struct rb_root *);
diff --git a/include/linux/timerqueue.h b/include/linux/timerqueue.h
index 5088727..a520fd7 100644
--- a/include/linux/timerqueue.h
+++ b/include/linux/timerqueue.h
@@ -39,7 +39,7 @@ struct timerqueue_node *timerqueue_getnext(struct timerqueue_head *head)
 
 static inline void timerqueue_init(struct timerqueue_node *node)
 {
-	rb_init_node(&node->node);
+	RB_CLEAR_NODE(&node->node);
 }
 
 static inline void timerqueue_init_head(struct timerqueue_head *head)
diff --git a/lib/rbtree.c b/lib/rbtree.c
index d417556..fe43c8c 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -387,7 +387,7 @@ struct rb_node *rb_next(const struct rb_node *node)
 {
 	struct rb_node *parent;
 
-	if (rb_parent(node) == node)
+	if (RB_EMPTY_NODE(node))
 		return NULL;
 
 	/* If we have a right-hand child, go down and then left as far
@@ -416,7 +416,7 @@ struct rb_node *rb_prev(const struct rb_node *node)
 {
 	struct rb_node *parent;
 
-	if (rb_parent(node) == node)
+	if (RB_EMPTY_NODE(node))
 		return NULL;
 
 	/* If we have a left-hand child, go down and then right as far
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

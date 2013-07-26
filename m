Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id DFB2E6B003A
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:41 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 26 Jul 2013 15:14:20 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id B5BB51FF001B
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 15:08:54 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6QLEGrK150224
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 15:14:16 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6QLEFcB006407
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 15:14:16 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 1/5] rbtree: add postorder iteration functions
Date: Fri, 26 Jul 2013 14:13:39 -0700
Message-Id: <1374873223-25557-2-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Add postorder iteration functions for rbtree. These are useful for
safely freeing an entire rbtree without modifying the tree at all.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/rbtree.h |  4 ++++
 lib/rbtree.c           | 40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 0022c1b..2879e96 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -68,6 +68,10 @@ extern struct rb_node *rb_prev(const struct rb_node *);
 extern struct rb_node *rb_first(const struct rb_root *);
 extern struct rb_node *rb_last(const struct rb_root *);
 
+/* Postorder iteration - always visit the parent after it's children */
+extern struct rb_node *rb_first_postorder(const struct rb_root *);
+extern struct rb_node *rb_next_postorder(const struct rb_node *);
+
 /* Fast replacement of a single node without remove/rebalance/add/rebalance */
 extern void rb_replace_node(struct rb_node *victim, struct rb_node *new, 
 			    struct rb_root *root);
diff --git a/lib/rbtree.c b/lib/rbtree.c
index c0e31fe..65f4eff 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -518,3 +518,43 @@ void rb_replace_node(struct rb_node *victim, struct rb_node *new,
 	*new = *victim;
 }
 EXPORT_SYMBOL(rb_replace_node);
+
+static struct rb_node *rb_left_deepest_node(const struct rb_node *node)
+{
+	for (;;) {
+		if (node->rb_left)
+			node = node->rb_left;
+		else if (node->rb_right)
+			node = node->rb_right;
+		else
+			return (struct rb_node *)node;
+	}
+}
+
+struct rb_node *rb_next_postorder(const struct rb_node *node)
+{
+	const struct rb_node *parent;
+	if (!node)
+		return NULL;
+	parent = rb_parent(node);
+
+	/* If we're sitting on node, we've already seen our children */
+	if (parent && node == parent->rb_left && parent->rb_right) {
+		/* If we are the parent's left node, go to the parent's right
+		 * node then all the way down to the left */
+		return rb_left_deepest_node(parent->rb_right);
+	} else
+		/* Otherwise we are the parent's right node, and the parent
+		 * should be next */
+		return (struct rb_node *)parent;
+}
+EXPORT_SYMBOL(rb_next_postorder);
+
+struct rb_node *rb_first_postorder(const struct rb_root *root)
+{
+	if (!root->rb_node)
+		return NULL;
+
+	return rb_left_deepest_node(root->rb_node);
+}
+EXPORT_SYMBOL(rb_first_postorder);
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

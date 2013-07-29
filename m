Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 622D36B0078
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:19:42 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 29 Jul 2013 15:19:41 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id CF5F56E803F
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:19:33 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6TJJcHE116944
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:19:38 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6TJJcNV027624
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 16:19:38 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 1/5] rbtree: add postorder iteration functions
Date: Mon, 29 Jul 2013 12:19:26 -0700
Message-Id: <1375125570-9401-2-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1375125570-9401-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1375125570-9401-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Add postorder iteration functions for rbtree. These are useful for
safely freeing an entire rbtree without modifying the tree at all.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
Reviewed-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 include/linux/rbtree.h |  4 ++++
 lib/rbtree.c           | 40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 0022c1b..c467151 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -68,6 +68,10 @@ extern struct rb_node *rb_prev(const struct rb_node *);
 extern struct rb_node *rb_first(const struct rb_root *);
 extern struct rb_node *rb_last(const struct rb_root *);
 
+/* Postorder iteration - always visit the parent after its children */
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

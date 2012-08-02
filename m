Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id A6F1E6B0073
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 18:34:45 -0400 (EDT)
Received: by mail-yw0-f41.google.com with SMTP id 47so71180yhr.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 15:34:45 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 9/9] rbtree: remove prior augmented rbtree implementation
Date: Thu,  2 Aug 2012 15:34:18 -0700
Message-Id: <1343946858-8170-10-git-send-email-walken@google.com>
In-Reply-To: <1343946858-8170-1-git-send-email-walken@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

convert arch/x86/mm/pat_rbtree.c to the proposed augmented rbtree api
and remove the old augmented rbtree implementation.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 arch/x86/mm/pat_rbtree.c |   65 +++++++++++++++++++++++++++++------------
 include/linux/rbtree.h   |    8 -----
 lib/rbtree.c             |   71 ----------------------------------------------
 3 files changed, 46 insertions(+), 98 deletions(-)

diff --git a/arch/x86/mm/pat_rbtree.c b/arch/x86/mm/pat_rbtree.c
index 8acaddd..7e1515b 100644
--- a/arch/x86/mm/pat_rbtree.c
+++ b/arch/x86/mm/pat_rbtree.c
@@ -54,29 +54,57 @@ static u64 get_subtree_max_end(struct rb_node *node)
 	return ret;
 }
 
-/* Update 'subtree_max_end' for a node, based on node and its children */
-static void memtype_rb_augment_cb(struct rb_node *node, void *__unused)
+static u64 compute_subtree_max_end(struct memtype *data)
 {
-	struct memtype *data;
-	u64 max_end, child_max_end;
-
-	if (!node)
-		return;
-
-	data = container_of(node, struct memtype, rb);
-	max_end = data->end;
+	u64 max_end = data->end, child_max_end;
 
-	child_max_end = get_subtree_max_end(node->rb_right);
+	child_max_end = get_subtree_max_end(data->rb.rb_right);
 	if (child_max_end > max_end)
 		max_end = child_max_end;
 
-	child_max_end = get_subtree_max_end(node->rb_left);
+	child_max_end = get_subtree_max_end(data->rb.rb_left);
 	if (child_max_end > max_end)
 		max_end = child_max_end;
 
-	data->subtree_max_end = max_end;
+	return max_end;
+}
+
+/* Update 'subtree_max_end' for node and its parents */
+static void memtype_rb_propagate_cb(struct rb_node *node, struct rb_node *stop)
+{
+	while (node != stop) {
+		struct memtype *data = container_of(node, struct memtype, rb);
+		u64 subtree_max_end = compute_subtree_max_end(data);
+		if (data->subtree_max_end == subtree_max_end)
+			break;
+		data->subtree_max_end = subtree_max_end;
+		node = rb_parent(&data->rb);
+	}
+}
+
+static void memtype_rb_copy_cb(struct rb_node *old, struct rb_node *new)
+{
+	struct memtype *old_data = container_of(old, struct memtype, rb);
+	struct memtype *new_data = container_of(new, struct memtype, rb);
+
+	new_data->subtree_max_end = old_data->subtree_max_end;
 }
 
+/* Update 'subtree_max_end' after tree rotation. old and new are the
+ * former and current subtree roots */
+static void memtype_rb_rotate_cb(struct rb_node *old, struct rb_node *new)
+{
+	struct memtype *old_data = container_of(old, struct memtype, rb);
+	struct memtype *new_data = container_of(new, struct memtype, rb);
+
+	new_data->subtree_max_end = old_data->subtree_max_end;
+	old_data->subtree_max_end = compute_subtree_max_end(old_data);
+}
+
+static const struct rb_augment_callbacks memtype_rb_augment_cb = {
+	memtype_rb_propagate_cb, memtype_rb_copy_cb, memtype_rb_rotate_cb
+};
+
 /* Find the first (lowest start addr) overlapping range from rb tree */
 static struct memtype *memtype_rb_lowest_match(struct rb_root *root,
 				u64 start, u64 end)
@@ -179,15 +207,17 @@ static void memtype_rb_insert(struct rb_root *root, struct memtype *newdata)
 		struct memtype *data = container_of(*node, struct memtype, rb);
 
 		parent = *node;
+		if (data->subtree_max_end < newdata->end)
+			data->subtree_max_end = newdata->end;
 		if (newdata->start <= data->start)
 			node = &((*node)->rb_left);
 		else if (newdata->start > data->start)
 			node = &((*node)->rb_right);
 	}
 
+	newdata->subtree_max_end = newdata->end;
 	rb_link_node(&newdata->rb, parent, node);
-	rb_insert_color(&newdata->rb, root);
-	rb_augment_insert(&newdata->rb, memtype_rb_augment_cb, NULL);
+	rb_insert_augmented(&newdata->rb, root, &memtype_rb_augment_cb);
 }
 
 int rbt_memtype_check_insert(struct memtype *new, unsigned long *ret_type)
@@ -209,16 +239,13 @@ int rbt_memtype_check_insert(struct memtype *new, unsigned long *ret_type)
 
 struct memtype *rbt_memtype_erase(u64 start, u64 end)
 {
-	struct rb_node *deepest;
 	struct memtype *data;
 
 	data = memtype_rb_exact_match(&memtype_rbroot, start, end);
 	if (!data)
 		goto out;
 
-	deepest = rb_augment_erase_begin(&data->rb);
-	rb_erase(&data->rb, &memtype_rbroot);
-	rb_augment_erase_end(deepest, memtype_rb_augment_cb, NULL);
+	rb_erase_augmented(&data->rb, &memtype_rbroot, &memtype_rb_augment_cb);
 out:
 	return data;
 }
diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index c902eb9..4ace31b 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -80,14 +80,6 @@ rb_insert_augmented(struct rb_node *node, struct rb_root *root,
 }
 
 
-typedef void (*rb_augment_f)(struct rb_node *node, void *data);
-
-extern void rb_augment_insert(struct rb_node *node,
-			      rb_augment_f func, void *data);
-extern struct rb_node *rb_augment_erase_begin(struct rb_node *node);
-extern void rb_augment_erase_end(struct rb_node *node,
-				 rb_augment_f func, void *data);
-
 /* Find logical next and previous nodes in a tree */
 extern struct rb_node *rb_next(const struct rb_node *);
 extern struct rb_node *rb_prev(const struct rb_node *);
diff --git a/lib/rbtree.c b/lib/rbtree.c
index 11c11e9..e45eed1 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -537,77 +537,6 @@ void rb_erase_augmented(struct rb_node *node, struct rb_root *root,
 }
 EXPORT_SYMBOL(rb_erase_augmented);
 
-static void rb_augment_path(struct rb_node *node, rb_augment_f func, void *data)
-{
-	struct rb_node *parent;
-
-up:
-	func(node, data);
-	parent = rb_parent(node);
-	if (!parent)
-		return;
-
-	if (node == parent->rb_left && parent->rb_right)
-		func(parent->rb_right, data);
-	else if (parent->rb_left)
-		func(parent->rb_left, data);
-
-	node = parent;
-	goto up;
-}
-
-/*
- * after inserting @node into the tree, update the tree to account for
- * both the new entry and any damage done by rebalance
- */
-void rb_augment_insert(struct rb_node *node, rb_augment_f func, void *data)
-{
-	if (node->rb_left)
-		node = node->rb_left;
-	else if (node->rb_right)
-		node = node->rb_right;
-
-	rb_augment_path(node, func, data);
-}
-EXPORT_SYMBOL(rb_augment_insert);
-
-/*
- * before removing the node, find the deepest node on the rebalance path
- * that will still be there after @node gets removed
- */
-struct rb_node *rb_augment_erase_begin(struct rb_node *node)
-{
-	struct rb_node *deepest;
-
-	if (!node->rb_right && !node->rb_left)
-		deepest = rb_parent(node);
-	else if (!node->rb_right)
-		deepest = node->rb_left;
-	else if (!node->rb_left)
-		deepest = node->rb_right;
-	else {
-		deepest = rb_next(node);
-		if (deepest->rb_right)
-			deepest = deepest->rb_right;
-		else if (rb_parent(deepest) != node)
-			deepest = rb_parent(deepest);
-	}
-
-	return deepest;
-}
-EXPORT_SYMBOL(rb_augment_erase_begin);
-
-/*
- * after removal, update the tree to account for the removed entry
- * and any rebalance damage.
- */
-void rb_augment_erase_end(struct rb_node *node, rb_augment_f func, void *data)
-{
-	if (node)
-		rb_augment_path(node, func, data);
-}
-EXPORT_SYMBOL(rb_augment_erase_end);
-
 /*
  * This function returns the first node (in sort order) of the tree.
  */
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

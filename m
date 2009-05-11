Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E7DD46B003D
	for <linux-mm@kvack.org>; Sun, 10 May 2009 22:05:53 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so1148305wah.22
        for <linux-mm@kvack.org>; Sun, 10 May 2009 19:05:57 -0700 (PDT)
Message-ID: <4A0787B5.8060103@gmail.com>
Date: Mon, 11 May 2009 10:04:37 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] lib : do code optimization for radix_tree_lookup() and radix_tree_lookup_slot()
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nickpiggin@yahoo.com.au, clameter@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 I think radix_tree_lookup() and radix_tree_lookup_slot() have too much 
same code except the return value.
 I introduce the function radix_tree_lookup_element() to do the real work.

/*
 * is_slot == 1 : search for the slot.
 * is_slot == 0 : search for the node.
 */
  static void * radix_tree_lookup_element(struct radix_tree_root *root, 
unsigned long index, int is_slot);

Signed-off-by: Huang Shijie <shijie8@gmail.com>

----

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 4bb42a0..176fd96 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -351,20 +351,12 @@ int radix_tree_insert(struct radix_tree_root *root,
 }
 EXPORT_SYMBOL(radix_tree_insert);
 
-/**
- *    radix_tree_lookup_slot    -    lookup a slot in a radix tree
- *    @root:        radix tree root
- *    @index:        index key
- *
- *    Returns:  the slot corresponding to the position @index in the
- *    radix tree @root. This is useful for update-if-exists operations.
- *
- *    This function can be called under rcu_read_lock iff the slot is not
- *    modified by radix_tree_replace_slot, otherwise it must be called
- *    exclusive from other writers. Any dereference of the slot must be 
done
- *    using radix_tree_deref_slot.
+/*
+ * is_slot == 1 : search for the slot.
+ * is_slot == 0 : search for the node.
  */
-void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned 
long index)
+static void * radix_tree_lookup_element(struct radix_tree_root *root,
+                    unsigned long index, int is_slot)
 {
     unsigned int height, shift;
     struct radix_tree_node *node, **slot;
@@ -376,7 +368,7 @@ void **radix_tree_lookup_slot(struct radix_tree_root 
*root, unsigned long index)
     if (!radix_tree_is_indirect_ptr(node)) {
         if (index > 0)
             return NULL;
-        return (void **)&root->rnode;
+        return is_slot ? (void *)&root->rnode : node;
     }
     node = radix_tree_indirect_to_ptr(node);
 
@@ -397,7 +389,25 @@ void **radix_tree_lookup_slot(struct 
radix_tree_root *root, unsigned long index)
         height--;
     } while (height > 0);
 
-    return (void **)slot;
+    return is_slot ? (void *)slot : node;
+}
+
+/**
+ *    radix_tree_lookup_slot    -    lookup a slot in a radix tree
+ *    @root:        radix tree root
+ *    @index:        index key
+ *
+ *    Returns:  the slot corresponding to the position @index in the
+ *    radix tree @root. This is useful for update-if-exists operations.
+ *
+ *    This function can be called under rcu_read_lock iff the slot is not
+ *    modified by radix_tree_replace_slot, otherwise it must be called
+ *    exclusive from other writers. Any dereference of the slot must be 
done
+ *    using radix_tree_deref_slot.
+ */
+void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned 
long index)
+{
+    return (void**)radix_tree_lookup_element(root, index, 1);
 }
 EXPORT_SYMBOL(radix_tree_lookup_slot);
 
@@ -415,38 +425,7 @@ EXPORT_SYMBOL(radix_tree_lookup_slot);
  */
 void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
 {
-    unsigned int height, shift;
-    struct radix_tree_node *node, **slot;
-
-    node = rcu_dereference(root->rnode);
-    if (node == NULL)
-        return NULL;
-
-    if (!radix_tree_is_indirect_ptr(node)) {
-        if (index > 0)
-            return NULL;
-        return node;
-    }
-    node = radix_tree_indirect_to_ptr(node);
-
-    height = node->height;
-    if (index > radix_tree_maxindex(height))
-        return NULL;
-
-    shift = (height-1) * RADIX_TREE_MAP_SHIFT;
-
-    do {
-        slot = (struct radix_tree_node **)
-            (node->slots + ((index>>shift) & RADIX_TREE_MAP_MASK));
-        node = rcu_dereference(*slot);
-        if (node == NULL)
-            return NULL;
-
-        shift -= RADIX_TREE_MAP_SHIFT;
-        height--;
-    } while (height > 0);
-
-    return node;
+    return radix_tree_lookup_element(root, index, 0);
 }
 EXPORT_SYMBOL(radix_tree_lookup);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

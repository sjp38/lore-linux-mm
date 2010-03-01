From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 13/16] radixtree: introduce radix_tree_lookup_leaf_node()
Date: Mon, 01 Mar 2010 13:27:04 +0800
Message-ID: <20100301053622.084130183@intel.com>
References: <20100301052651.857984880@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NlyKT-00050P-Ad
	for glkm-linux-mm-2@m.gmane.org; Mon, 01 Mar 2010 06:38:05 +0100
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8ABA66B007D
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 00:37:57 -0500 (EST)
Content-Disposition: inline; filename=radixtree-radix_tree_lookup_leaf_node.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

This will be used by the pagecache context based read-ahead/read-around
heuristic to quickly check one pagecache range:
- if there is any hole
- if there is any pages

Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/radix-tree.h |    2 +
 lib/radix-tree.c           |   37 ++++++++++++++++++++++++++---------
 2 files changed, 30 insertions(+), 9 deletions(-)

--- linux.orig/lib/radix-tree.c	2010-02-27 12:59:22.000000000 +0800
+++ linux/lib/radix-tree.c	2010-02-27 13:00:09.000000000 +0800
@@ -359,19 +359,20 @@ EXPORT_SYMBOL(radix_tree_insert);
  * is_slot == 0 : search for the node.
  */
 static void *radix_tree_lookup_element(struct radix_tree_root *root,
-				unsigned long index, int is_slot)
+				unsigned long index, int is_slot, int level)
 {
 	unsigned int height, shift;
-	struct radix_tree_node *node, **slot;
+	struct radix_tree_node *node;
+	struct radix_tree_node **slot = &root->rnode;
 
 	node = rcu_dereference(root->rnode);
 	if (node == NULL)
 		return NULL;
 
 	if (!radix_tree_is_indirect_ptr(node)) {
-		if (index > 0)
+		if (index > 0 || level > 0)
 			return NULL;
-		return is_slot ? (void *)&root->rnode : node;
+		goto out;
 	}
 	node = radix_tree_indirect_to_ptr(node);
 
@@ -381,7 +382,7 @@ static void *radix_tree_lookup_element(s
 
 	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
 
-	do {
+	while (height > level) {
 		slot = (struct radix_tree_node **)
 			(node->slots + ((index>>shift) & RADIX_TREE_MAP_MASK));
 		node = rcu_dereference(*slot);
@@ -390,9 +391,10 @@ static void *radix_tree_lookup_element(s
 
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;
-	} while (height > 0);
+	}
 
-	return is_slot ? (void *)slot:node;
+out:
+	return is_slot ? (void *)slot : node;
 }
 
 /**
@@ -410,7 +412,7 @@ static void *radix_tree_lookup_element(s
  */
 void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
 {
-	return (void **)radix_tree_lookup_element(root, index, 1);
+	return (void **)radix_tree_lookup_element(root, index, 1, 0);
 }
 EXPORT_SYMBOL(radix_tree_lookup_slot);
 
@@ -428,11 +430,28 @@ EXPORT_SYMBOL(radix_tree_lookup_slot);
  */
 void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
 {
-	return radix_tree_lookup_element(root, index, 0);
+	return radix_tree_lookup_element(root, index, 0, 0);
 }
 EXPORT_SYMBOL(radix_tree_lookup);
 
 /**
+ *	radix_tree_lookup_leaf_node    -    lookup leaf node on a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *
+ *	Lookup the leaf node that covers @index in the radix tree @root.
+ *	Return NULL if the node does not exist, or is the special root node.
+ *
+ *	The typical usage is to check the value of node->count, which shall be
+ *	performed inside rcu_read_lock to prevent the node from being freed.
+ */
+struct radix_tree_node *
+radix_tree_lookup_leaf_node(struct radix_tree_root *root, unsigned long index)
+{
+	return radix_tree_lookup_element(root, index, 0, 1);
+}
+
+/**
  *	radix_tree_tag_set - set a tag on a radix tree node
  *	@root:		radix tree root
  *	@index:		index key
--- linux.orig/include/linux/radix-tree.h	2010-02-27 12:59:22.000000000 +0800
+++ linux/include/linux/radix-tree.h	2010-02-27 12:59:23.000000000 +0800
@@ -158,6 +158,8 @@ static inline void radix_tree_replace_sl
 int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
 void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
+struct radix_tree_node *
+radix_tree_lookup_leaf_node(struct radix_tree_root *root, unsigned long index);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
 unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

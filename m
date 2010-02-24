From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 13/15] radixtree: speed up the search for hole
Date: Wed, 24 Feb 2010 11:10:14 +0800
Message-ID: <20100224031055.460494682@intel.com>
References: <20100224031001.026464755@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Nk7ft-0006JX-La
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Feb 2010 04:12:33 +0100
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0D6756B0082
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 22:12:21 -0500 (EST)
Content-Disposition: inline; filename=radixtree-scan-hole-fast.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Replace the hole scan functions with more fast versions:
	- radix_tree_next_hole(root, index, max_scan)
	- radix_tree_prev_hole(root, index, max_scan)

Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 lib/radix-tree.c |   67 +++++++++++++++++++++++++++++++++++++--------
 1 file changed, 56 insertions(+), 11 deletions(-)

--- linux.orig/lib/radix-tree.c	2010-02-24 10:44:49.000000000 +0800
+++ linux/lib/radix-tree.c	2010-02-24 10:44:50.000000000 +0800
@@ -647,18 +647,41 @@ EXPORT_SYMBOL(radix_tree_tag_get);
  *	under rcu_read_lock.
  */
 unsigned long radix_tree_next_hole(struct radix_tree_root *root,
-				unsigned long index, unsigned long max_scan)
+				   unsigned long index, unsigned long max_scan)
 {
-	unsigned long i;
+	struct radix_tree_node *node;
+	unsigned long origin = index;
+	int i;
+
+	node = rcu_dereference(root->rnode);
+	if (node == NULL)
+		return index;
+
+	if (!radix_tree_is_indirect_ptr(node))
+		return index ? index : 1;
 
-	for (i = 0; i < max_scan; i++) {
-		if (!radix_tree_lookup(root, index))
+	while (index - origin < max_scan) {
+		node = radix_tree_lookup_leaf_node(root, index);
+		if (!node)
 			break;
-		index++;
-		if (index == 0)
+
+		if (node->count == RADIX_TREE_MAP_SIZE) {
+			index = (index | RADIX_TREE_MAP_MASK) + 1;
+			goto check_overflow;
+		}
+
+		for (i = index & RADIX_TREE_MAP_MASK;
+		     i < RADIX_TREE_MAP_SIZE;
+		     i++, index++)
+			if (rcu_dereference(node->slots[i]) == NULL)
+				goto out;
+
+check_overflow:
+		if (unlikely(index == 0))
 			break;
 	}
 
+out:
 	return index;
 }
 EXPORT_SYMBOL(radix_tree_next_hole);
@@ -686,16 +709,38 @@ EXPORT_SYMBOL(radix_tree_next_hole);
 unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
 				   unsigned long index, unsigned long max_scan)
 {
-	unsigned long i;
+	struct radix_tree_node *node;
+	unsigned long origin = index;
+	int i;
+
+	node = rcu_dereference(root->rnode);
+	if (node == NULL)
+		return index;
+
+	if (!radix_tree_is_indirect_ptr(node))
+		return index ? index : ULONG_MAX;
 
-	for (i = 0; i < max_scan; i++) {
-		if (!radix_tree_lookup(root, index))
+	while (origin - index < max_scan) {
+		node = radix_tree_lookup_leaf_node(root, index);
+		if (!node)
 			break;
-		index--;
-		if (index == LONG_MAX)
+
+		if (node->count == RADIX_TREE_MAP_SIZE) {
+			index = (index - RADIX_TREE_MAP_SIZE) |
+					 RADIX_TREE_MAP_MASK;
+			goto check_underflow;
+		}
+
+		for (i = index & RADIX_TREE_MAP_MASK; i >= 0; i--, index--)
+			if (rcu_dereference(node->slots[i]) == NULL)
+				goto out;
+
+check_underflow:
+		if (unlikely(index == ULONG_MAX))
 			break;
 	}
 
+out:
 	return index;
 }
 EXPORT_SYMBOL(radix_tree_prev_hole);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

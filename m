Received: from neuman.interaccess.com (neuman.interaccess.com [207.70.126.130])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA02122
	for <linux-mm@kvack.org>; Wed, 17 Mar 1999 00:03:23 -0500
Message-ID: <36EF3786.8A20FA58@interaccess.com>
Date: Tue, 16 Mar 1999 23:03:02 -0600
From: "Paul F. Dietz" <dietz@interaccess.com>
MIME-Version: 1.0
Subject: small patch to mm/mmap_avl.c: fixed
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@fvger.rugers.edu
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Some lines got wrapped.  Here's the unscrewed-up version.

==========================================
--- linux-backup/mm/mmap_avl.c	Thu Mar 11 06:34:07 1999
+++ linux/mm/mmap_avl.c	Sun Mar 14 20:56:06 1999
@@ -84,9 +84,10 @@
  * nodes[0]..nodes[k-1] such that
  * nodes[0] is the root and nodes[i+1] = nodes[i]->{vm_avl_left|vm_avl_right}.
  */
-static void avl_rebalance (struct vm_area_struct *** nodeplaces_ptr, int count)
+static void avl_rebalance (struct vm_area_struct *** nodeplaces_ptr,
+			   struct vm_area_struct *** nodeplaces_base)
 {
-	for ( ; count > 0 ; count--) {
+	while (nodeplaces_ptr > nodeplaces_base) {
 		struct vm_area_struct ** nodeplace = *--nodeplaces_ptr;
 		struct vm_area_struct * node = *nodeplace;
 		struct vm_area_struct * nodeleft = node->vm_avl_left;
@@ -166,13 +167,12 @@
 	vm_avl_key_t key = new_node->vm_avl_key;
 	struct vm_area_struct ** nodeplace = ptree;
 	struct vm_area_struct ** stack[avl_maxheight];
-	int stack_count = 0;
-	struct vm_area_struct *** stack_ptr = &stack[0]; /* = &stack[stackcount] */
+	struct vm_area_struct *** stack_ptr = &stack[0];
 	for (;;) {
 		struct vm_area_struct * node = *nodeplace;
 		if (node == vm_avl_empty)
 			break;
-		*stack_ptr++ = nodeplace; stack_count++;
+		*stack_ptr++ = nodeplace;
 		if (key < node->vm_avl_key)
 			nodeplace = &node->vm_avl_left;
 		else
@@ -182,7 +182,7 @@
 	new_node->vm_avl_right = vm_avl_empty;
 	new_node->vm_avl_height = 1;
 	*nodeplace = new_node;
-	avl_rebalance(stack_ptr,stack_count);
+	avl_rebalance(stack_ptr,&stack[0]);
 }
 
 /* Insert a node into a tree, and
@@ -194,14 +194,13 @@
 	vm_avl_key_t key = new_node->vm_avl_key;
 	struct vm_area_struct ** nodeplace = ptree;
 	struct vm_area_struct ** stack[avl_maxheight];
-	int stack_count = 0;
-	struct vm_area_struct *** stack_ptr = &stack[0]; /* = &stack[stackcount] */
+	struct vm_area_struct *** stack_ptr = &stack[0];
 	*to_the_left = *to_the_right = NULL;
 	for (;;) {
 		struct vm_area_struct * node = *nodeplace;
 		if (node == vm_avl_empty)
 			break;
-		*stack_ptr++ = nodeplace; stack_count++;
+		*stack_ptr++ = nodeplace;
 		if (key < node->vm_avl_key) {
 			*to_the_right = node;
 			nodeplace = &node->vm_avl_left;
@@ -214,7 +213,7 @@
 	new_node->vm_avl_right = vm_avl_empty;
 	new_node->vm_avl_height = 1;
 	*nodeplace = new_node;
-	avl_rebalance(stack_ptr,stack_count);
+	avl_rebalance(stack_ptr,&stack[0]);
 }
 
 /* Removes a node out of a tree. */
@@ -223,8 +222,7 @@
 	vm_avl_key_t key = node_to_delete->vm_avl_key;
 	struct vm_area_struct ** nodeplace = ptree;
 	struct vm_area_struct ** stack[avl_maxheight];
-	int stack_count = 0;
-	struct vm_area_struct *** stack_ptr = &stack[0]; /* = &stack[stackcount] */
+	struct vm_area_struct *** stack_ptr = &stack[0];
 	struct vm_area_struct ** nodeplace_to_delete;
 	for (;;) {
 		struct vm_area_struct * node = *nodeplace;
@@ -235,7 +233,7 @@
 			return;
 		}
 #endif
-		*stack_ptr++ = nodeplace; stack_count++;
+		*stack_ptr++ = nodeplace;
 		if (key == node->vm_avl_key)
 			break;
 		if (key < node->vm_avl_key)
@@ -247,7 +245,7 @@
 	/* Have to remove node_to_delete = *nodeplace_to_delete. */
 	if (node_to_delete->vm_avl_left == vm_avl_empty) {
 		*nodeplace_to_delete = node_to_delete->vm_avl_right;
-		stack_ptr--; stack_count--;
+		stack_ptr--;
 	} else {
 		struct vm_area_struct *** stack_ptr_to_delete = stack_ptr;
 		struct vm_area_struct ** nodeplace = &node_to_delete->vm_avl_left;
@@ -256,7 +254,7 @@
 			node = *nodeplace;
 			if (node->vm_avl_right == vm_avl_empty)
 				break;
-			*stack_ptr++ = nodeplace; stack_count++;
+			*stack_ptr++ = nodeplace;
 			nodeplace = &node->vm_avl_right;
 		}
 		*nodeplace = node->vm_avl_left;
@@ -267,7 +265,7 @@
 		*nodeplace_to_delete = node; /* replace node_to_delete */
 		*stack_ptr_to_delete = &node->vm_avl_left; /* replace &node_to_delete->vm_avl_left */
 	}
-	avl_rebalance(stack_ptr,stack_count);
+	avl_rebalance(stack_ptr,&stack[0]);
 }
 
 #ifdef DEBUG_AVL
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

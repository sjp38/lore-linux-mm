Message-ID: <4317F1A2.8030605@yahoo.com.au>
Date: Fri, 02 Sep 2005 16:30:58 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 2.6.13] lockless pagecache 4/7
References: <4317F071.1070403@yahoo.com.au> <4317F0F9.1080602@yahoo.com.au> <4317F136.4040601@yahoo.com.au> <4317F17F.5050306@yahoo.com.au>
In-Reply-To: <4317F17F.5050306@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------090202060603040101050109"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090202060603040101050109
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

4/7

-- 
SUSE Labs, Novell Inc.


--------------090202060603040101050109
Content-Type: text/plain;
 name="radix-tree-lookup_slot.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="radix-tree-lookup_slot.patch"

From: Hans Reiser <reiser@namesys.com>

Reiser4 uses radix trees to solve a trouble reiser4_readdir has serving nfs
requests.

Unfortunately, radix tree api lacks an operation suitable for modifying
existing entry.  This patch adds radix_tree_lookup_slot which returns pointer
to found item within the tree.  That location can be then updated.

Index: linux-2.6/include/linux/radix-tree.h
===================================================================
--- linux-2.6.orig/include/linux/radix-tree.h
+++ linux-2.6/include/linux/radix-tree.h
@@ -46,6 +46,7 @@ do {									\
 
 int radix_tree_insert(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
+void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
 unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -276,14 +276,8 @@ int radix_tree_insert(struct radix_tree_
 }
 EXPORT_SYMBOL(radix_tree_insert);
 
-/**
- *	radix_tree_lookup    -    perform lookup operation on a radix tree
- *	@root:		radix tree root
- *	@index:		index key
- *
- *	Lookup the item at the position @index in the radix tree @root.
- */
-void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
+static inline void **__lookup_slot(struct radix_tree_root *root,
+				   unsigned long index)
 {
 	unsigned int height, shift;
 	struct radix_tree_node **slot;
@@ -306,7 +300,36 @@ void *radix_tree_lookup(struct radix_tre
 		height--;
 	}
 
-	return *slot;
+	return (void **)slot;
+}
+
+/**
+ *	radix_tree_lookup_slot    -    lookup a slot in a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *
+ *	Lookup the slot corresponding to the position @index in the radix tree
+ *	@root. This is useful for update-if-exists operations.
+ */
+void **radix_tree_lookup_slot(struct radix_tree_root *root, unsigned long index)
+{
+	return __lookup_slot(root, index);
+}
+EXPORT_SYMBOL(radix_tree_lookup_slot);
+
+/**
+ *	radix_tree_lookup    -    perform lookup operation on a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *
+ *	Lookup the item at the position @index in the radix tree @root.
+ */
+void *radix_tree_lookup(struct radix_tree_root *root, unsigned long index)
+{
+	void **slot;
+
+	slot = __lookup_slot(root, index);
+	return slot != NULL ? *slot : NULL;
 }
 EXPORT_SYMBOL(radix_tree_lookup);
 

--------------090202060603040101050109--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

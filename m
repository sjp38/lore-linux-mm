Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1AF96B026D
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:38 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id 143so7977765ybe.18
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g193si1446335ywb.36.2017.12.15.14.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:37 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 06/78] xarray: Change definition of sibling entries
Date: Fri, 15 Dec 2017 14:03:38 -0800
Message-Id: <20171215220450.7899-7-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Instead of storing a pointer to the slot containing the canonical entry,
store the offset of the slot.  Produces slightly more efficient code
(~300 bytes) and simplifies the implementation.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h | 82 ++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/radix-tree.c       | 65 +++++++++++----------------------------
 2 files changed, 100 insertions(+), 47 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 49fffc354431..f175350560fd 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -49,6 +49,17 @@ static inline bool xa_is_value(const void *entry)
 	return (unsigned long)entry & 1;
 }
 
+/**
+ * xa_is_internal() - Is the entry an internal entry?
+ * @entry: Entry retrieved from the XArray
+ *
+ * Return: %true if the entry is an internal entry.
+ */
+static inline bool xa_is_internal(const void *entry)
+{
+	return ((unsigned long)entry & 3) == 2;
+}
+
 #define xa_trylock(xa)		spin_trylock(&(xa)->xa_lock)
 #define xa_lock(xa)		spin_lock(&(xa)->xa_lock)
 #define xa_unlock(xa)		spin_unlock(&(xa)->xa_lock)
@@ -61,4 +72,75 @@ static inline bool xa_is_value(const void *entry)
 #define xa_unlock_irqrestore(xa, flags) \
 				spin_unlock_irqrestore(&(xa)->xa_lock, flags)
 
+/* Everything below here is the Advanced API.  Proceed with caution. */
+
+/*
+ * The xarray is constructed out of a set of 'chunks' of pointers.  Choosing
+ * the best chunk size requires some tradeoffs.  A power of two recommends
+ * itself so that we can walk the tree based purely on shifts and masks.
+ * Generally, the larger the better; as the number of slots per level of the
+ * tree increases, the less tall the tree needs to be.  But that needs to be
+ * balanced against the memory consumption of each node.  On a 64-bit system,
+ * xa_node is currently 576 bytes, and we get 7 of them per 4kB page.  If we
+ * doubled the number of slots per node, we'd get only 3 nodes per 4kB page.
+ */
+#ifndef XA_CHUNK_SHIFT
+#define XA_CHUNK_SHIFT		(CONFIG_BASE_SMALL ? 4 : 6)
+#endif
+#define XA_CHUNK_SIZE		(1UL << XA_CHUNK_SHIFT)
+#define XA_CHUNK_MASK		(XA_CHUNK_SIZE - 1)
+
+/*
+ * Internal entries have the bottom two bits set to the value 10b.  Most
+ * internal entries are pointers to the next node in the tree.  Since the
+ * kernel unmaps page 0 to trap NULL pointer dereferences, we can use values
+ * 0-1023 for special purposes.  Values 0-62 are used for sibling
+ * entries.  Value 256 is used for the retry entry.
+ */
+
+/* Private */
+static inline void *xa_mk_internal(unsigned long v)
+{
+	return (void *)((v << 2) | 2);
+}
+
+/* Private */
+static inline unsigned long xa_to_internal(const void *entry)
+{
+	return (unsigned long)entry >> 2;
+}
+
+/* Private */
+static inline bool xa_is_node(const void *entry)
+{
+	return xa_is_internal(entry) && (unsigned long)entry > 4096;
+}
+
+/* Private */
+static inline void *xa_mk_sibling(unsigned int offset)
+{
+	return xa_mk_internal(offset);
+}
+
+/* Private */
+static inline unsigned long xa_to_sibling(const void *entry)
+{
+	return xa_to_internal(entry);
+}
+
+/**
+ * xa_is_sibling() - Is the entry a sibling entry?
+ * @entry: Entry retrieved from the XArray
+ *
+ * Return: %true if the entry is a sibling entry.
+ */
+static inline bool xa_is_sibling(const void *entry)
+{
+	return IS_ENABLED(CONFIG_RADIX_TREE_MULTIORDER) &&
+		xa_is_internal(entry) &&
+		(entry < xa_mk_sibling(XA_CHUNK_SIZE - 1));
+}
+
+#define XA_RETRY_ENTRY		xa_mk_internal(256)
+
 #endif /* _LINUX_XARRAY_H */
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index cda7a730e591..0a7a21dd9398 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -37,6 +37,7 @@
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
 #include <linux/string.h>
+#include <linux/xarray.h>
 
 
 /* Number of nodes in fully populated tree of given height */
@@ -97,24 +98,7 @@ static inline void *node_to_entry(void *ptr)
 	return (void *)((unsigned long)ptr | RADIX_TREE_INTERNAL_NODE);
 }
 
-#define RADIX_TREE_RETRY	node_to_entry(NULL)
-
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-/* Sibling slots point directly to another slot in the same node */
-static inline
-bool is_sibling_entry(const struct radix_tree_node *parent, void *node)
-{
-	void __rcu **ptr = node;
-	return (parent->slots <= ptr) &&
-			(ptr < parent->slots + RADIX_TREE_MAP_SIZE);
-}
-#else
-static inline
-bool is_sibling_entry(const struct radix_tree_node *parent, void *node)
-{
-	return false;
-}
-#endif
+#define RADIX_TREE_RETRY	XA_RETRY_ENTRY
 
 static inline unsigned long
 get_slot_offset(const struct radix_tree_node *parent, void __rcu **slot)
@@ -128,16 +112,10 @@ static unsigned int radix_tree_descend(const struct radix_tree_node *parent,
 	unsigned int offset = (index >> parent->shift) & RADIX_TREE_MAP_MASK;
 	void __rcu **entry = rcu_dereference_raw(parent->slots[offset]);
 
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-	if (radix_tree_is_internal_node(entry)) {
-		if (is_sibling_entry(parent, entry)) {
-			void __rcu **sibentry;
-			sibentry = (void __rcu **) entry_to_node(entry);
-			offset = get_slot_offset(parent, sibentry);
-			entry = rcu_dereference_raw(*sibentry);
-		}
+	if (xa_is_sibling(entry)) {
+		offset = xa_to_sibling(entry);
+		entry = rcu_dereference_raw(parent->slots[offset]);
 	}
-#endif
 
 	*nodep = (void *)entry;
 	return offset;
@@ -299,10 +277,10 @@ static void dump_node(struct radix_tree_node *node, unsigned long index)
 		} else if (!radix_tree_is_internal_node(entry)) {
 			pr_debug("radix entry %p offset %ld indices %lu-%lu parent %p\n",
 					entry, i, first, last, node);
-		} else if (is_sibling_entry(node, entry)) {
+		} else if (xa_is_sibling(entry)) {
 			pr_debug("radix sblng %p offset %ld indices %lu-%lu parent %p val %p\n",
 					entry, i, first, last, node,
-					*(void **)entry_to_node(entry));
+					node->slots[xa_to_sibling(entry)]);
 		} else {
 			dump_node(entry_to_node(entry), first);
 		}
@@ -872,8 +850,7 @@ static void radix_tree_free_nodes(struct radix_tree_node *node)
 
 	for (;;) {
 		void *entry = rcu_dereference_raw(child->slots[offset]);
-		if (radix_tree_is_internal_node(entry) &&
-					!is_sibling_entry(child, entry)) {
+		if (xa_is_node(entry)) {
 			child = entry_to_node(entry);
 			offset = 0;
 			continue;
@@ -895,7 +872,7 @@ static void radix_tree_free_nodes(struct radix_tree_node *node)
 static inline int insert_entries(struct radix_tree_node *node,
 		void __rcu **slot, void *item, unsigned order, bool replace)
 {
-	struct radix_tree_node *child;
+	void *sibling;
 	unsigned i, n, tag, offset, tags = 0;
 
 	if (node) {
@@ -913,7 +890,7 @@ static inline int insert_entries(struct radix_tree_node *node,
 		offset = offset & ~(n - 1);
 		slot = &node->slots[offset];
 	}
-	child = node_to_entry(slot);
+	sibling = xa_mk_sibling(offset);
 
 	for (i = 0; i < n; i++) {
 		if (slot[i]) {
@@ -930,7 +907,7 @@ static inline int insert_entries(struct radix_tree_node *node,
 	for (i = 0; i < n; i++) {
 		struct radix_tree_node *old = rcu_dereference_raw(slot[i]);
 		if (i) {
-			rcu_assign_pointer(slot[i], child);
+			rcu_assign_pointer(slot[i], sibling);
 			for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 				if (tags & (1 << tag))
 					tag_clear(node, tag, offset + i);
@@ -940,9 +917,7 @@ static inline int insert_entries(struct radix_tree_node *node,
 				if (tags & (1 << tag))
 					tag_set(node, tag, offset);
 		}
-		if (radix_tree_is_internal_node(old) &&
-					!is_sibling_entry(node, old) &&
-					(old != RADIX_TREE_RETRY))
+		if (xa_is_node(old))
 			radix_tree_free_nodes(old);
 		if (xa_is_value(old))
 			node->exceptional--;
@@ -1101,10 +1076,10 @@ static inline void replace_sibling_entries(struct radix_tree_node *node,
 				void __rcu **slot, int count, int exceptional)
 {
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
-	void *ptr = node_to_entry(slot);
-	unsigned offset = get_slot_offset(node, slot) + 1;
+	unsigned offset = get_slot_offset(node, slot);
+	void *ptr = xa_mk_sibling(offset);
 
-	while (offset < RADIX_TREE_MAP_SIZE) {
+	while (++offset < RADIX_TREE_MAP_SIZE) {
 		if (rcu_dereference_raw(node->slots[offset]) != ptr)
 			break;
 		if (count < 0) {
@@ -1112,7 +1087,6 @@ static inline void replace_sibling_entries(struct radix_tree_node *node,
 			node->count--;
 		}
 		node->exceptional += exceptional;
-		offset++;
 	}
 #endif
 }
@@ -1311,8 +1285,7 @@ int radix_tree_split(struct radix_tree_root *root, unsigned long index,
 			tags |= 1 << tag;
 
 	for (end = offset + 1; end < RADIX_TREE_MAP_SIZE; end++) {
-		if (!is_sibling_entry(parent,
-				rcu_dereference_raw(parent->slots[end])))
+		if (!xa_is_sibling(rcu_dereference_raw(parent->slots[end])))
 			break;
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 			if (tags & (1 << tag))
@@ -1608,11 +1581,9 @@ static void set_iter_tags(struct radix_tree_iter *iter,
 static void __rcu **skip_siblings(struct radix_tree_node **nodep,
 			void __rcu **slot, struct radix_tree_iter *iter)
 {
-	void *sib = node_to_entry(slot - 1);
-
 	while (iter->index < iter->next_index) {
 		*nodep = rcu_dereference_raw(*slot);
-		if (*nodep && *nodep != sib)
+		if (*nodep && !xa_is_sibling(*nodep))
 			return slot;
 		slot++;
 		iter->index = __radix_tree_iter_add(iter, 1);
@@ -1763,7 +1734,7 @@ void __rcu **radix_tree_next_chunk(const struct radix_tree_root *root,
 				while (++offset	< RADIX_TREE_MAP_SIZE) {
 					void *slot = rcu_dereference_raw(
 							node->slots[offset]);
-					if (is_sibling_entry(node, slot))
+					if (xa_is_sibling(slot))
 						continue;
 					if (slot)
 						break;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

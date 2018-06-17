Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 511266B02DE
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:03:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 69-v6so4150956pgg.0
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:03:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k72-v6si11500556pfj.141.2018.06.16.19.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:07 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 05/74] xarray: Change definition of sibling entries
Date: Sat, 16 Jun 2018 18:59:43 -0700
Message-Id: <20180617020052.4759-6-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Instead of storing a pointer to the slot containing the canonical entry,
store the offset of the slot.  Produces slightly more efficient code
(~300 bytes) and simplifies the implementation.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Josef Bacik <jbacik@fb.com>
---
 include/linux/xarray.h | 93 ++++++++++++++++++++++++++++++++++++++++++
 lib/radix-tree.c       | 64 +++++++++--------------------
 2 files changed, 112 insertions(+), 45 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index e6ead6c81458..1ac55c05de14 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -22,6 +22,12 @@
  * x1: Value entry
  *
  * Attempting to store internal entries in the XArray is a bug.
+ *
+ * Most internal entries are pointers to the next node in the tree.
+ * The following internal entries have a special meaning:
+ *
+ * 0-62: Sibling entries
+ * 256: Retry entry
  */
 
 #define BITS_PER_XA_VALUE	(BITS_PER_LONG - 1)
@@ -63,6 +69,42 @@ static inline bool xa_is_value(const void *entry)
 	return (unsigned long)entry & 1;
 }
 
+/*
+ * xa_mk_internal() - Create an internal entry.
+ * @v: Value to turn into an internal entry.
+ *
+ * Context: Any context.
+ * Return: An XArray internal entry corresponding to this value.
+ */
+static inline void *xa_mk_internal(unsigned long v)
+{
+	return (void *)((v << 2) | 2);
+}
+
+/*
+ * xa_to_internal() - Extract the value from an internal entry.
+ * @entry: XArray entry.
+ *
+ * Context: Any context.
+ * Return: The value which was stored in the internal entry.
+ */
+static inline unsigned long xa_to_internal(const void *entry)
+{
+	return (unsigned long)entry >> 2;
+}
+
+/*
+ * xa_is_internal() - Is the entry an internal entry?
+ * @entry: XArray entry.
+ *
+ * Context: Any context.
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
@@ -75,4 +117,55 @@ static inline bool xa_is_value(const void *entry)
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
index fa43dcdc1f6a..22ca63cb3204 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -38,6 +38,7 @@
 #include <linux/rcupdate.h>
 #include <linux/slab.h>
 #include <linux/string.h>
+#include <linux/xarray.h>
 
 
 /* Number of nodes in fully populated tree of given height */
@@ -98,24 +99,7 @@ static inline void *node_to_entry(void *ptr)
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
@@ -129,16 +113,10 @@ static unsigned int radix_tree_descend(const struct radix_tree_node *parent,
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
@@ -300,10 +278,10 @@ static void dump_node(struct radix_tree_node *node, unsigned long index)
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
@@ -873,8 +851,7 @@ static void radix_tree_free_nodes(struct radix_tree_node *node)
 
 	for (;;) {
 		void *entry = rcu_dereference_raw(child->slots[offset]);
-		if (radix_tree_is_internal_node(entry) &&
-					!is_sibling_entry(child, entry)) {
+		if (xa_is_node(entry)) {
 			child = entry_to_node(entry);
 			offset = 0;
 			continue;
@@ -896,7 +873,7 @@ static void radix_tree_free_nodes(struct radix_tree_node *node)
 static inline int insert_entries(struct radix_tree_node *node,
 		void __rcu **slot, void *item, unsigned order, bool replace)
 {
-	struct radix_tree_node *child;
+	void *sibling;
 	unsigned i, n, tag, offset, tags = 0;
 
 	if (node) {
@@ -914,7 +891,7 @@ static inline int insert_entries(struct radix_tree_node *node,
 		offset = offset & ~(n - 1);
 		slot = &node->slots[offset];
 	}
-	child = node_to_entry(slot);
+	sibling = xa_mk_sibling(offset);
 
 	for (i = 0; i < n; i++) {
 		if (slot[i]) {
@@ -931,7 +908,7 @@ static inline int insert_entries(struct radix_tree_node *node,
 	for (i = 0; i < n; i++) {
 		struct radix_tree_node *old = rcu_dereference_raw(slot[i]);
 		if (i) {
-			rcu_assign_pointer(slot[i], child);
+			rcu_assign_pointer(slot[i], sibling);
 			for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 				if (tags & (1 << tag))
 					tag_clear(node, tag, offset + i);
@@ -941,9 +918,7 @@ static inline int insert_entries(struct radix_tree_node *node,
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
@@ -1102,10 +1077,10 @@ static inline void replace_sibling_entries(struct radix_tree_node *node,
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
@@ -1113,7 +1088,6 @@ static inline void replace_sibling_entries(struct radix_tree_node *node,
 			node->count--;
 		}
 		node->exceptional += exceptional;
-		offset++;
 	}
 #endif
 }
@@ -1312,8 +1286,7 @@ int radix_tree_split(struct radix_tree_root *root, unsigned long index,
 			tags |= 1 << tag;
 
 	for (end = offset + 1; end < RADIX_TREE_MAP_SIZE; end++) {
-		if (!is_sibling_entry(parent,
-				rcu_dereference_raw(parent->slots[end])))
+		if (!xa_is_sibling(rcu_dereference_raw(parent->slots[end])))
 			break;
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 			if (tags & (1 << tag))
@@ -1611,7 +1584,7 @@ static void __rcu **skip_siblings(struct radix_tree_node **nodep,
 {
 	while (iter->index < iter->next_index) {
 		*nodep = rcu_dereference_raw(*slot);
-		if (*nodep && !is_sibling_entry(iter->node, *nodep))
+		if (*nodep && !xa_is_sibling(*nodep))
 			return slot;
 		slot++;
 		iter->index = __radix_tree_iter_add(iter, 1);
@@ -1762,7 +1735,7 @@ void __rcu **radix_tree_next_chunk(const struct radix_tree_root *root,
 				while (++offset	< RADIX_TREE_MAP_SIZE) {
 					void *slot = rcu_dereference_raw(
 							node->slots[offset]);
-					if (is_sibling_entry(node, slot))
+					if (xa_is_sibling(slot))
 						continue;
 					if (slot)
 						break;
@@ -2283,6 +2256,7 @@ void __init radix_tree_init(void)
 
 	BUILD_BUG_ON(RADIX_TREE_MAX_TAGS + __GFP_BITS_SHIFT > 32);
 	BUILD_BUG_ON(ROOT_IS_IDR & ~GFP_ZONEMASK);
+	BUILD_BUG_ON(XA_CHUNK_SIZE > 255);
 	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
 			sizeof(struct radix_tree_node), 0,
 			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
-- 
2.17.1

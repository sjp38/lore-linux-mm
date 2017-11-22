Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82E656B0275
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:19 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t77so4840047pfe.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s78si15820584pfj.225.2017.11.22.13.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:17 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 21/62] xarray: Add xa_get_tag, xa_set_tag and xa_clear_tag
Date: Wed, 22 Nov 2017 13:06:58 -0800
Message-Id: <20171122210739.29916-22-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

XArray tags are slightly more strongly typed than the radix tree tags,
but occupy the same bits.  This commit also adds the xas_ family of tag
operations, for cases where the caller is already holding the lock, and
xa_tagged() to ask whether any array member has a particular tag set.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  38 +++++++-
 lib/radix-tree.c       |  52 +++++-----
 lib/xarray.c           | 250 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 313 insertions(+), 27 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 0e736d2db049..ab6b1f5e685a 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -48,6 +48,7 @@
 
 #include <linux/bug.h>
 #include <linux/compiler.h>
+#include <linux/gfp.h>
 #include <linux/kernel.h>
 #include <linux/rcupdate.h>
 #include <linux/spinlock.h>
@@ -82,6 +83,33 @@ struct xarray {
 
 void *xa_load(struct xarray *, unsigned long index);
 
+typedef unsigned __bitwise xa_tag_t;
+#define XA_TAG_0		((__force xa_tag_t)0U)
+#define XA_TAG_1		((__force xa_tag_t)1U)
+#define XA_TAG_2		((__force xa_tag_t)2U)
+#define XA_NO_TAG		((__force xa_tag_t)4U)
+
+#define XA_TAG_MAX		XA_TAG_2
+#define XA_FREE_TAG		XA_TAG_0
+#define XA_FLAGS_TAG(tag)	((__force gfp_t)((2U << __GFP_BITS_SHIFT) << \
+				(__force unsigned)(tag)))
+
+/**
+ * xa_tagged() - Inquire whether any entry in this array has a tag set
+ * @xa: Array
+ * @tag: Tag value
+ *
+ * Return: True if any entry has this tag set, false if no entry does.
+ */
+static inline bool xa_tagged(const struct xarray *xa, xa_tag_t tag)
+{
+	return xa->xa_flags & XA_FLAGS_TAG(tag);
+}
+
+bool xa_get_tag(struct xarray *, unsigned long index, xa_tag_t);
+void *xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
+void *xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
+
 #define BITS_PER_XA_VALUE	(BITS_PER_LONG - 1)
 
 /**
@@ -133,6 +161,10 @@ static inline bool xa_is_value(void *entry)
 				spin_unlock_irqrestore(&(xa)->xa_lock, flags)
 #define xa_lock_held(xa)	lockdep_is_held(&(xa)->xa_lock)
 
+/* Versions of the normal API which require the caller to hold the xa_lock */
+void *__xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
+void *__xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
+
 #ifdef XA_DEBUG
 void xa_dump(const struct xarray *);
 void xa_dump_node(const struct xa_node *);
@@ -175,7 +207,7 @@ struct xa_node {
 	unsigned char	offset;		/* Slot offset in parent */
 	unsigned char	count;		/* Total entry count */
 	unsigned char	exceptional;	/* Exceptional entry count */
-	struct xa_node *parent;		/* Used when ascending tree */
+	struct xa_node __rcu *parent;	/* Used when ascending tree */
 	struct xarray *	root;		/* The tree we belong to */
 	union {
 		struct list_head private_list;	/* For tree user */
@@ -355,6 +387,10 @@ static inline bool xas_retry(struct xa_state *xas, void *entry)
 
 void *xas_load(struct xarray *, struct xa_state *);
 
+bool xas_get_tag(const struct xarray *, const struct xa_state *, xa_tag_t);
+void xas_set_tag(struct xarray *, const struct xa_state *, xa_tag_t);
+void xas_clear_tag(struct xarray *, const struct xa_state *, xa_tag_t);
+
 /**
  * xas_reload() - Refetch an entry from the xarray.
  * @xa: XArray.
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 930eb7d298d7..711a6d9b79fc 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -126,19 +126,19 @@ static inline gfp_t root_gfp_mask(const struct radix_tree_root *root)
 	return root->xa_flags & __GFP_BITS_MASK;
 }
 
-static inline void tag_set(struct radix_tree_node *node, unsigned int tag,
+static inline void rtag_set(struct radix_tree_node *node, unsigned int tag,
 		int offset)
 {
 	__set_bit(offset, node->tags[tag]);
 }
 
-static inline void tag_clear(struct radix_tree_node *node, unsigned int tag,
+static inline void rtag_clear(struct radix_tree_node *node, unsigned int tag,
 		int offset)
 {
 	__clear_bit(offset, node->tags[tag]);
 }
 
-static inline int tag_get(const struct radix_tree_node *node, unsigned int tag,
+static inline int rtag_get(const struct radix_tree_node *node, unsigned int tag,
 		int offset)
 {
 	return test_bit(offset, node->tags[tag]);
@@ -617,14 +617,14 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 		if (is_idr(root)) {
 			all_tag_set(node, IDR_FREE);
 			if (!root_tag_get(root, IDR_FREE)) {
-				tag_clear(node, IDR_FREE, 0);
+				rtag_clear(node, IDR_FREE, 0);
 				root_tag_set(root, IDR_FREE);
 			}
 		} else {
 			/* Propagate the aggregated tag info to the new child */
 			for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
 				if (root_tag_get(root, tag))
-					tag_set(node, tag, 0);
+					rtag_set(node, tag, 0);
 			}
 		}
 
@@ -689,7 +689,7 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
 		 * one (root->xa_head) as far as dependent read barriers go.
 		 */
 		root->xa_head = (void __rcu *)child;
-		if (is_idr(root) && !tag_get(node, IDR_FREE, 0))
+		if (is_idr(root) && !rtag_get(node, IDR_FREE, 0))
 			root_tag_clear(root, IDR_FREE);
 
 		/*
@@ -896,7 +896,7 @@ static inline int insert_entries(struct radix_tree_node *node,
 			if (replace) {
 				node->count--;
 				for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
-					if (tag_get(node, tag, offset + i))
+					if (rtag_get(node, tag, offset + i))
 						tags |= 1 << tag;
 			} else
 				return -EEXIST;
@@ -909,12 +909,12 @@ static inline int insert_entries(struct radix_tree_node *node,
 			rcu_assign_pointer(slot[i], sibling);
 			for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 				if (tags & (1 << tag))
-					tag_clear(node, tag, offset + i);
+					rtag_clear(node, tag, offset + i);
 		} else {
 			rcu_assign_pointer(slot[i], item);
 			for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 				if (tags & (1 << tag))
-					tag_set(node, tag, offset);
+					rtag_set(node, tag, offset);
 		}
 		if (xa_is_node(old))
 			radix_tree_free_nodes(old);
@@ -972,9 +972,9 @@ int __radix_tree_insert(struct radix_tree_root *root, unsigned long index,
 
 	if (node) {
 		unsigned offset = get_slot_offset(node, slot);
-		BUG_ON(tag_get(node, 0, offset));
-		BUG_ON(tag_get(node, 1, offset));
-		BUG_ON(tag_get(node, 2, offset));
+		BUG_ON(rtag_get(node, 0, offset));
+		BUG_ON(rtag_get(node, 1, offset));
+		BUG_ON(rtag_get(node, 2, offset));
 	} else {
 		BUG_ON(root_tags_get(root));
 	}
@@ -1110,7 +1110,7 @@ static bool node_tag_get(const struct radix_tree_root *root,
 				unsigned int tag, unsigned int offset)
 {
 	if (node)
-		return tag_get(node, tag, offset);
+		return rtag_get(node, tag, offset);
 	return root_tag_get(root, tag);
 }
 
@@ -1280,7 +1280,7 @@ int radix_tree_split(struct radix_tree_root *root, unsigned long index,
 	offset = get_slot_offset(parent, slot);
 
 	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
-		if (tag_get(parent, tag, offset))
+		if (rtag_get(parent, tag, offset))
 			tags |= 1 << tag;
 
 	for (end = offset + 1; end < RADIX_TREE_MAP_SIZE; end++) {
@@ -1288,7 +1288,7 @@ int radix_tree_split(struct radix_tree_root *root, unsigned long index,
 			break;
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 			if (tags & (1 << tag))
-				tag_set(parent, tag, end);
+				rtag_set(parent, tag, end);
 		/* rcu_assign_pointer ensures tags are set before RETRY */
 		rcu_assign_pointer(parent->slots[end], RADIX_TREE_RETRY);
 	}
@@ -1319,7 +1319,7 @@ int radix_tree_split(struct radix_tree_root *root, unsigned long index,
 							node_to_entry(child));
 				for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 					if (tags & (1 << tag))
-						tag_set(node, tag, offset);
+						rtag_set(node, tag, offset);
 			}
 
 			node = child;
@@ -1333,7 +1333,7 @@ int radix_tree_split(struct radix_tree_root *root, unsigned long index,
 
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 			if (tags & (1 << tag))
-				tag_set(node, tag, offset);
+				rtag_set(node, tag, offset);
 		offset += n;
 
 		while (offset == RADIX_TREE_MAP_SIZE) {
@@ -1363,9 +1363,9 @@ static void node_tag_set(struct radix_tree_root *root,
 				unsigned int tag, unsigned int offset)
 {
 	while (node) {
-		if (tag_get(node, tag, offset))
+		if (rtag_get(node, tag, offset))
 			return;
-		tag_set(node, tag, offset);
+		rtag_set(node, tag, offset);
 		offset = node->offset;
 		node = node->parent;
 	}
@@ -1403,8 +1403,8 @@ void *radix_tree_tag_set(struct radix_tree_root *root,
 		offset = radix_tree_descend(parent, &node, index);
 		BUG_ON(!node);
 
-		if (!tag_get(parent, tag, offset))
-			tag_set(parent, tag, offset);
+		if (!rtag_get(parent, tag, offset))
+			rtag_set(parent, tag, offset);
 	}
 
 	/* set the root's tag bit */
@@ -1432,9 +1432,9 @@ static void node_tag_clear(struct radix_tree_root *root,
 				unsigned int tag, unsigned int offset)
 {
 	while (node) {
-		if (!tag_get(node, tag, offset))
+		if (!rtag_get(node, tag, offset))
 			return;
-		tag_clear(node, tag, offset);
+		rtag_clear(node, tag, offset);
 		if (any_tag_set(node, tag))
 			return;
 
@@ -1532,7 +1532,7 @@ int radix_tree_tag_get(const struct radix_tree_root *root,
 		parent = entry_to_node(node);
 		offset = radix_tree_descend(parent, &node, index);
 
-		if (!tag_get(parent, tag, offset))
+		if (!rtag_get(parent, tag, offset))
 			return 0;
 		if (node == RADIX_TREE_RETRY)
 			break;
@@ -1721,7 +1721,7 @@ void __rcu **radix_tree_next_chunk(const struct radix_tree_root *root,
 		offset = radix_tree_descend(node, &child, index);
 
 		if ((flags & RADIX_TREE_ITER_TAGGED) ?
-				!tag_get(node, tag, offset) : !child) {
+				!rtag_get(node, tag, offset) : !child) {
 			/* Hole detected */
 			if (flags & RADIX_TREE_ITER_CONTIG)
 				return NULL;
@@ -2143,7 +2143,7 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 
 		node = entry_to_node(child);
 		offset = radix_tree_descend(node, &child, start);
-		if (!tag_get(node, IDR_FREE, offset)) {
+		if (!rtag_get(node, IDR_FREE, offset)) {
 			offset = radix_tree_find_next_bit(node, IDR_FREE,
 							offset + 1);
 			start = next_index(start, node, offset);
diff --git a/lib/xarray.c b/lib/xarray.c
index 1f7d30a8b61f..fbc7de5a224f 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -33,6 +33,53 @@
  * @entry refers to something stored in a slot in the xarray
  */
 
+static inline struct xa_node *xa_parent(struct xarray *xa,
+					const struct xa_node *node)
+{
+	return rcu_dereference_check(node->parent, xa_lock_held(xa));
+}
+
+static inline struct xa_node *xa_parent_locked(struct xarray *xa,
+					const struct xa_node *node)
+{
+	return rcu_dereference_protected(node->parent, xa_lock_held(xa));
+}
+
+static inline void xa_tag_set(struct xarray *xa, xa_tag_t tag)
+{
+	if (!(xa->xa_flags & XA_FLAGS_TAG(tag)))
+		xa->xa_flags |= XA_FLAGS_TAG(tag);
+}
+
+static inline void xa_tag_clear(struct xarray *xa, xa_tag_t tag)
+{
+	if (xa->xa_flags & XA_FLAGS_TAG(tag))
+		xa->xa_flags &= ~(XA_FLAGS_TAG(tag));
+}
+
+static inline bool tag_get(const struct xa_node *node, unsigned int offset,
+				xa_tag_t tag)
+{
+	return test_bit(offset, node->tags[(__force unsigned)tag]);
+}
+
+static inline void tag_set(struct xa_node *node, unsigned int offset,
+				xa_tag_t tag)
+{
+	__set_bit(offset, node->tags[(__force unsigned)tag]);
+}
+
+static inline void tag_clear(struct xa_node *node, unsigned int offset,
+				xa_tag_t tag)
+{
+	__clear_bit(offset, node->tags[(__force unsigned)tag]);
+}
+
+static inline bool tag_any_set(struct xa_node *node, xa_tag_t tag)
+{
+	return !bitmap_empty(node->tags[(__force unsigned)tag], XA_CHUNK_SIZE);
+}
+
 /* extracts the offset within this node from the index */
 static unsigned int get_offset(unsigned long index, struct xa_node *node)
 {
@@ -114,6 +161,89 @@ void *xas_load(struct xarray *xa, struct xa_state *xas)
 }
 EXPORT_SYMBOL_GPL(xas_load);
 
+/**
+ * xas_get_tag() - Returns the state of this tag.
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ * @tag: Tag number.
+ *
+ * Return: true if the tag is set, false if the tag is clear or @xas
+ * is in an error state.
+ */
+bool xas_get_tag(const struct xarray *xa, const struct xa_state *xas,
+			xa_tag_t tag)
+{
+	if (xas_invalid(xas))
+		return false;
+	if (!xas->xa_node)
+		return xa_tagged(xa, tag);
+	return tag_get(xas->xa_node, xas->xa_offset, tag);
+}
+EXPORT_SYMBOL_GPL(xas_get_tag);
+
+/**
+ * xas_set_tag() - Sets the tag on this entry and its parents.
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ * @tag: Tag number.
+ *
+ * Sets the specified tag on this entry, and walks up the tree setting it
+ * on all the ancestor entries.  Does nothing if @xas has not been walked to
+ * an entry, or is in an error state.
+ */
+void xas_set_tag(struct xarray *xa, const struct xa_state *xas, xa_tag_t tag)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset = xas->xa_offset;
+
+	if (xas_invalid(xas))
+		return;
+
+	while (node) {
+		if (tag_get(node, offset, tag))
+			return;
+		tag_set(node, offset, tag);
+		offset = node->offset;
+		node = xa_parent_locked(xa, node);
+	}
+
+	if (!xa_tagged(xa, tag))
+		xa_tag_set(xa, tag);
+}
+EXPORT_SYMBOL_GPL(xas_set_tag);
+
+/**
+ * xas_clear_tag() - Clears the tag on this entry and its parents.
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ * @tag: Tag number.
+ *
+ * Clears the specified tag on this entry, and walks back to the head
+ * attempting to clear it on all the ancestor entries.  Does nothing if
+ * @xas has not been walked to an entry, or is in an error state.
+ */
+void xas_clear_tag(struct xarray *xa, const struct xa_state *xas, xa_tag_t tag)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset = xas->xa_offset;
+
+	if (xas_invalid(xas))
+		return;
+
+	while (node) {
+		tag_clear(node, offset, tag);
+		if (tag_any_set(node, tag))
+			return;
+
+		offset = node->offset;
+		node = xa_parent_locked(xa, node);
+	}
+
+	if (xa_tagged(xa, tag))
+		xa_tag_clear(xa, tag);
+}
+EXPORT_SYMBOL_GPL(xas_clear_tag);
+
 /**
  * xa_load() - Load an entry from an XArray.
  * @xa: XArray.
@@ -135,3 +265,123 @@ void *xa_load(struct xarray *xa, unsigned long index)
 	return entry;
 }
 EXPORT_SYMBOL(xa_load);
+
+/**
+ * __xa_set_tag() - Set this tag on this entry.
+ * @xa: XArray.
+ * @index: Index of entry.
+ * @tag: Tag number.
+ *
+ * Attempting to set a tag on a NULL entry does not succeed.
+ * This function expects the xa_lock to be held on entry.
+ *
+ * Return: The entry at this index.
+ */
+void *__xa_set_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	XA_STATE(xas, index);
+	void *entry = xas_load(xa, &xas);
+
+	if (entry)
+		xas_set_tag(xa, &xas, tag);
+
+	return entry;
+}
+EXPORT_SYMBOL_GPL(__xa_set_tag);
+
+/**
+ * __xa_clear_tag() - Clear this tag on this entry.
+ * @xa: XArray.
+ * @index: Index of entry.
+ * @tag: Tag number.
+ *
+ * This function expects the xa_lock to be held on entry.
+ *
+ * Return: The entry at this index.
+ */
+void *__xa_clear_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	XA_STATE(xas, index);
+	void *entry = xas_load(xa, &xas);
+
+	if (entry)
+		xas_clear_tag(xa, &xas, tag);
+
+	return entry;
+}
+EXPORT_SYMBOL_GPL(__xa_clear_tag);
+
+/**
+ * xa_get_tag() - Inquire whether this tag is set on this entry.
+ * @xa: XArray.
+ * @index: Index of entry.
+ * @tag: Tag number.
+ *
+ * This function uses the RCU read lock, so the result may be out of date
+ * by the time it returns.  If you need the result to be stable, use a lock.
+ *
+ * Return: True if the entry at @index has this tag set, false if it doesn't.
+ */
+bool xa_get_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	XA_STATE(xas, index);
+	void *entry;
+
+	rcu_read_lock();
+	entry = xas_start(xa, &xas);
+	while (xas_get_tag(xa, &xas, tag)) {
+		if (!xa_is_node(entry))
+			goto found;
+		entry = xas_descend(xa, &xas, xa_to_node(entry));
+	}
+	rcu_read_unlock();
+	return false;
+ found:
+	rcu_read_unlock();
+	return true;
+}
+EXPORT_SYMBOL(xa_get_tag);
+
+/**
+ * xa_set_tag() - Set this tag on this entry.
+ * @xa: XArray.
+ * @index: Index of entry.
+ * @tag: Tag number.
+ *
+ * Attempting to set a tag on a NULL entry does not succeed.
+ *
+ * Return: The entry at this index.
+ */
+void *xa_set_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	unsigned long flags;
+	void *entry;
+
+	xa_lock_irqsave(xa, flags);
+	entry = __xa_set_tag(xa, index, tag);
+	xa_unlock_irqrestore(xa, flags);
+
+	return entry;
+}
+EXPORT_SYMBOL(xa_set_tag);
+
+/**
+ * xa_clear_tag() - Clear this tag on this entry.
+ * @xa: XArray.
+ * @index: Index of entry.
+ * @tag: Tag number.
+ *
+ * Return: The entry at this index.
+ */
+void *xa_clear_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	unsigned long flags;
+	void *entry;
+
+	xa_lock_irqsave(xa, flags);
+	entry = __xa_clear_tag(xa, index, tag);
+	xa_unlock_irqrestore(xa, flags);
+
+	return entry;
+}
+EXPORT_SYMBOL(xa_clear_tag);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

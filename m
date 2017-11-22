Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4984C6B02C7
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:19 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id z184so17301825pgd.0
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b4si10688764plb.2.2017.11.22.13.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 24/62] xarray: Add xa_for_each
Date: Wed, 22 Nov 2017 13:07:01 -0800
Message-Id: <20171122210739.29916-25-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This iterator allows the user to efficiently walk a range of the array,
executing the loop body once for each non-NULL entry in that range.
This commit also includes xa_find() and xa_next() which are helper
functions for xa_for_each() but may also be useful in their own right.

In the xas family of functions, we also have xas_for_each(),
xas_find(), xas_next(), xas_pause() and xas_jump().  xas_pause() allows
a xas_for_each() iteration to be resumed later from the next element
and xas_jump() allows an iteration to be resumed from a specified index.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h |  96 +++++++++++++++++++++++++++
 lib/radix-tree.c       |   4 +-
 lib/xarray.c           | 173 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 271 insertions(+), 2 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 274dd7530e40..08ddad60a43d 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -130,6 +130,35 @@ bool xa_get_tag(struct xarray *, unsigned long index, xa_tag_t);
 void *xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
 void *xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
 
+void *xa_find(struct xarray *xa, unsigned long *index, unsigned long max);
+void *xa_next(struct xarray *xa, unsigned long *index, unsigned long max);
+
+/**
+ * xa_for_each() - Iterate over a portion of an XArray.
+ * @xa: XArray,
+ * @entry: Entry retrieved from array.
+ * @index: Index of @entry.
+ * @max: Maximum index to retrieve from array.
+ *
+ * Initialise @index to the minimum index you want to retrieve from
+ * the array.  During the iteration, @entry will have the value of the
+ * entry stored in @xa at @index.  The iteration will skip all NULL
+ * entries in the array.  You may modify @index during the
+ * iteration if you want to skip indices.  It is safe to modify the
+ * array during the iteration.  At the end of the iteration, @entry will
+ * be set to NULL and @index will have a value less than or equal to max.
+ *
+ * xa_for_each() is O(n.log(n)) while xas_for_each() is O(n).  You have
+ * to handle your own locking with xas_for_each(), and if you have to unlock
+ * after each iteration, it will also end up being O(n.log(n)).  xa_for_each()
+ * will spin if it hits a retry entry; if you intend to see retry entries,
+ * you should use the xas_for_each() iterator instead.  The xas_for_each()
+ * iterator will expand into more inline code than xa_for_each().
+ */
+#define xa_for_each(xa, entry, index, max) \
+	for (entry = xa_find(xa, &index, max); entry; \
+	     entry = xa_next(xa, &index, max))
+
 #define BITS_PER_XA_VALUE	(BITS_PER_LONG - 1)
 
 /**
@@ -391,6 +420,11 @@ static inline bool xas_valid(const struct xa_state *xas)
 	return !xas_invalid(xas);
 }
 
+static inline bool xas_not_node(struct xa_node *node)
+{
+	return (unsigned long)node < 4096;
+}
+
 /**
  * xas_retry() - Handle a retry entry.
  * @xas: XArray operation state.
@@ -413,6 +447,7 @@ static inline bool xas_retry(struct xa_state *xas, void *entry)
 void *xas_load(struct xarray *, struct xa_state *);
 void *xas_store(struct xarray *, struct xa_state *, void *entry);
 void *xas_create(struct xarray *, struct xa_state *);
+void *xas_find(struct xarray *, struct xa_state *, unsigned long max);
 
 bool xas_get_tag(const struct xarray *, const struct xa_state *, xa_tag_t);
 void xas_set_tag(struct xarray *, const struct xa_state *, xa_tag_t);
@@ -421,6 +456,7 @@ void xas_init_tags(struct xarray *, const struct xa_state *);
 
 void xas_destroy(struct xa_state *);
 bool xas_nomem(struct xa_state *, gfp_t);
+void xas_pause(struct xa_state *);
 
 /**
  * xas_reload() - Refetch an entry from the xarray.
@@ -475,4 +511,64 @@ static inline void xas_set_order(struct xa_state *xas, unsigned long index,
 	xas->xa_sibs = (1 << (order % XA_CHUNK_SHIFT)) - 1;
 	xas->xa_node = XAS_RESTART;
 }
+
+/* Skip over any of these entries when iterating */
+static inline bool xa_iter_skip(void *entry)
+{
+	return unlikely(!entry ||
+			(xa_is_internal(entry) && entry < XA_RETRY_ENTRY));
+}
+
+/**
+ * xas_next() - Advance iterator to next present entry.
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ * @max: Highest index to return.
+ *
+ * xas_next() is an inline function to optimise xarray traversal for speed.
+ * It is equivalent to calling xas_find(), and will call xas_find() for all
+ * the hard cases.
+ *
+ * Return: The next present entry after the one currently referred to by @xas.
+ */
+static inline void *xas_next(struct xarray *xa, struct xa_state *xas,
+					unsigned long max)
+{
+	struct xa_node *node = xas->xa_node;
+	void *entry;
+
+	if (unlikely(xas_not_node(node) || node->shift))
+		return xas_find(xa, xas, max);
+
+	do {
+		if (unlikely(xas->xa_index >= max))
+			return xas_find(xa, xas, max);
+		if (unlikely(xas->xa_offset == XA_CHUNK_MASK))
+			return xas_find(xa, xas, max);
+		xas->xa_index++;
+		xas->xa_offset++;
+		entry = xa_entry(xa, node, xas->xa_offset);
+	} while (xa_iter_skip(entry));
+
+	return entry;
+}
+
+/**
+ * xas_for_each() - Iterate over a range of an XArray
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ * @entry: Entry retrieved from array.
+ * @max: Maximum index to retrieve from array.
+ *
+ * The loop body will be executed for each entry present in the xarray
+ * between the current xas position and @max.  @entry will be set to
+ * the entry retrieved from the xarray.  It is safe to delete entries
+ * from the array in the loop body.  You should hold either the RCU lock
+ * or the xa_lock while iterating.  If you need to drop the lock, call
+ * xas_pause() first.
+ */
+#define xas_for_each(xa, xas, entry, max) \
+	for (entry = xas_find(xa, xas, max); entry; \
+	     entry = xas_next(xa, xas, max))
+
 #endif /* _LINUX_XARRAY_H */
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 507e1842255b..29b38d447497 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -247,7 +247,7 @@ static inline unsigned long node_maxindex(const struct radix_tree_node *node)
 	return shift_maxindex(node->shift);
 }
 
-static unsigned long next_index(unsigned long index,
+static unsigned long rnext_index(unsigned long index,
 				const struct radix_tree_node *node,
 				unsigned long offset)
 {
@@ -2146,7 +2146,7 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 		if (!rtag_get(node, IDR_FREE, offset)) {
 			offset = radix_tree_find_next_bit(node, IDR_FREE,
 							offset + 1);
-			start = next_index(start, node, offset);
+			start = rnext_index(start, node, offset);
 			if (start > max)
 				return ERR_PTR(-ENOSPC);
 			while (offset == RADIX_TREE_MAP_SIZE) {
diff --git a/lib/xarray.c b/lib/xarray.c
index 82f39d86fc76..5409048e8b44 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -91,12 +91,24 @@ static inline bool tag_any_set(struct xa_node *node, xa_tag_t tag)
 	tag = (__force xa_tag_t)((__force unsigned)(tag) + 1); \
 } while (0)
 
+/* Returns the index of the next slot in this node.  @index may be unaligned. */
+static unsigned long next_index(unsigned long index, struct xa_node *node)
+{
+	return round_up(index + 1, 1UL << node->shift);
+}
+
 /* extracts the offset within this node from the index */
 static unsigned int get_offset(unsigned long index, struct xa_node *node)
 {
 	return (index >> node->shift) & XA_CHUNK_MASK;
 }
 
+static void xas_add(struct xa_state *xas, unsigned long val)
+{
+	xas->xa_index += (val << xas->xa_node->shift);
+	xas->xa_offset += val;
+}
+
 /*
  * Starts a walk.  If the @xas is already valid, we assume that it's on
  * the right path and just return where we've got to.  If we're in an
@@ -759,6 +771,103 @@ void xas_init_tags(struct xarray *xa, const struct xa_state *xas)
 }
 EXPORT_SYMBOL_GPL(xas_init_tags);
 
+/**
+ * xas_pause() - Pause a walk to drop a lock.
+ * @xas: XArray operation state.
+ *
+ * Some users need to pause a walk and drop the lock they're holding in
+ * order to yield to a higher priority thread or carry out an operation
+ * on an entry.  Those users should call this function before they drop
+ * the lock.  It resets the @xas to be suitable for the next iteration
+ * of the loop after the user has reacquired the lock.  If most entries
+ * found during a walk require you to call xas_pause(), the xa_for_each()
+ * iterator may be more appropriate.
+ *
+ * Note that xas_pause() only works for forward iteration.  If a user needs
+ * to pause a reverse iteration, we will need a xas_pause_rev().
+ */
+void xas_pause(struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_node;
+
+	if (node) {
+		unsigned int offset = xas->xa_offset;
+		xas->xa_index = next_index(xas->xa_index, node);
+		while (++offset < XA_CHUNK_SIZE) {
+			if (!xa_is_sibling(xa_entry(node->root, node, offset)))
+				break;
+			xas->xa_index += 1UL << node->shift;
+		}
+	} else {
+		xas->xa_index++;
+	}
+	xas->xa_node = XAS_RESTART;
+}
+EXPORT_SYMBOL_GPL(xas_pause);
+
+/**
+ * xas_find() - Find the next present entry in the XArray.
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ * @max: Highest index to return.
+ *
+ * If the xas has not yet been walked to an entry, return the entry
+ * which has an index >= xas.xa_index.  If it has been walked, the entry
+ * currently being pointed at has been processed, and so we move to the
+ * next entry.
+ *
+ * If no entry is found and the array is smaller than @max, @xas is
+ * set to the restart state and xas->xa_index is set to the smallest index
+ * not yet in the array.  This allows @xas to be immediately passed to
+ * xas_create().
+ *
+ * Return: The entry, if found, otherwise NULL.
+ */
+void *xas_find(struct xarray *xa, struct xa_state *xas, unsigned long max)
+{
+	void *entry;
+
+	if (xas_error(xas))
+		return NULL;
+
+	if (xas->xa_node == XAS_RESTART) {
+		entry = xas_load(xa, xas);
+		if (entry || xas_not_node(xas->xa_node))
+			return entry;
+	} else if (!xas->xa_node) {
+		xas->xa_index = 1;
+		xas->xa_node = XAS_RESTART;
+		return NULL;
+	}
+
+	xas->xa_index = next_index(xas->xa_index, xas->xa_node);
+	xas->xa_offset++;
+
+	while (xas->xa_node && (xas->xa_index <= max)) {
+		if (unlikely(xas->xa_offset == XA_CHUNK_SIZE)) {
+			xas->xa_offset = xas->xa_node->offset + 1;
+			xas->xa_node = xa_parent(xa, xas->xa_node);
+			continue;
+		}
+
+		entry = xa_entry(xa, xas->xa_node, xas->xa_offset);
+		if (xa_is_node(entry)) {
+			xas->xa_node = xa_to_node(entry);
+			xas->xa_offset = 0;
+			continue;
+		}
+		if (!xa_iter_skip(entry))
+			return entry;
+
+		xas_add(xas, 1);
+	}
+
+	if (!xas->xa_node)
+		xas->xa_node = XAS_RESTART;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(xas_find);
+
 /**
  * xa_load() - Load an entry from an XArray.
  * @xa: XArray.
@@ -975,3 +1084,67 @@ void *xa_clear_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
 	return entry;
 }
 EXPORT_SYMBOL(xa_clear_tag);
+
+/**
+ * xa_find() - Search the XArray for a present entry.
+ * @xa: XArray.
+ * @indexp: Pointer to an index.
+ * @max: Maximum index to search to.
+ *
+ * Finds the entry in the xarray with the lowest index that is between
+ * *@indexp and max, inclusive.  If an entry is found, updates @indexp to
+ * be the index of the pointer.  This function is protected by the RCU read
+ * lock, so it may not find all entries if called in a loop.  It will not
+ * return an %XA_RETRY_ENTRY; if you need to see retry entries, use xas_next().
+ *
+ * Return: The entry, if found, otherwise NULL.
+ */
+void *xa_find(struct xarray *xa, unsigned long *indexp, unsigned long max)
+{
+	XA_STATE(xas, *indexp);
+	void *entry;
+
+	rcu_read_lock();
+	do {
+		entry = xas_find(xa, &xas, max);
+	} while (xas_retry(&xas, entry));
+	rcu_read_unlock();
+
+	if (entry)
+		*indexp = xas.xa_index;
+	return entry;
+}
+EXPORT_SYMBOL(xa_find);
+
+/**
+ * xa_next() - Search the XArray for a present entry.
+ * @xa: XArray.
+ * @indexp: Pointer to an index.
+ * @max: Maximum index to search to.
+ *
+ * Finds the entry in @xa with the lowest index that is above *@indexp and
+ * less than or equal to @max.  If an entry is found, updates @indexp to be
+ * the index of the pointer.  This function is protected by the RCU read
+ * lock, so it may not find all entries if called in a loop.  It will not
+ * return an %XA_RETRY_ENTRY; if you need to see retry entries, use xas_next().
+ *
+ * Return: The pointer, if found, otherwise NULL.
+ */
+void *xa_next(struct xarray *xa, unsigned long *indexp, unsigned long max)
+{
+	XA_STATE(xas, *indexp + 1);
+	void *entry;
+
+	rcu_read_lock();
+	do {
+		entry = xas_find(xa, &xas, max);
+		if (xas.xa_index <= *indexp)
+			entry = xas_next(xa, &xas, max);
+	} while (xas_retry(&xas, entry));
+	rcu_read_unlock();
+
+	if (entry)
+		*indexp = xas.xa_index;
+	return entry;
+}
+EXPORT_SYMBOL(xa_next);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

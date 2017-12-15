Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 097DB6B029A
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:06:05 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id k186so16508194ith.1
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:06:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x70si5237852ioi.296.2017.12.15.14.06.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:06:03 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 14/78] xarray: Add xa_for_each
Date: Fri, 15 Dec 2017 14:03:46 -0800
Message-Id: <20171215220450.7899-15-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

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
 include/linux/xarray.h                 | 111 ++++++++++++++++++++++
 lib/radix-tree.c                       |   4 +-
 lib/xarray.c                           | 166 +++++++++++++++++++++++++++++++++
 tools/testing/radix-tree/xarray-test.c | 114 ++++++++++++++++++++++
 4 files changed, 393 insertions(+), 2 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 56db23edac82..c4eef03ad12d 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -138,6 +138,35 @@ bool xa_get_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
 
+void *xa_find(struct xarray *xa, unsigned long *index, unsigned long max);
+void *xa_find_after(struct xarray *xa, unsigned long *index, unsigned long max);
+
+/**
+ * xa_for_each() - Iterate over a portion of an XArray.
+ * @xa: XArray.
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
+	     entry = xa_find_after(xa, &index, max))
+
 #define BITS_PER_XA_VALUE	(BITS_PER_LONG - 1)
 
 /**
@@ -577,6 +606,12 @@ static inline bool xas_valid(const struct xa_state *xas)
 	return !xas_invalid(xas);
 }
 
+/* True if the pointer is something other than a node */
+static inline bool xas_not_node(struct xa_node *node)
+{
+	return ((unsigned long)node & 3) || !node;
+}
+
 /* True if the node represents head-of-tree, RESTART or BOUNDS */
 static inline bool xas_top(struct xa_node *node)
 {
@@ -605,6 +640,7 @@ static inline bool xas_retry(struct xa_state *xas, const void *entry)
 void *xas_load(struct xa_state *);
 void *xas_store(struct xa_state *, void *entry);
 void *xas_create(struct xa_state *);
+void *xas_find(struct xa_state *, unsigned long max);
 
 bool xas_get_tag(const struct xa_state *, xa_tag_t);
 void xas_set_tag(const struct xa_state *, xa_tag_t);
@@ -612,6 +648,7 @@ void xas_clear_tag(const struct xa_state *, xa_tag_t);
 void xas_init_tags(const struct xa_state *);
 
 bool xas_nomem(struct xa_state *, gfp_t);
+void xas_pause(struct xa_state *);
 
 /**
  * xas_reload() - Refetch an entry from the xarray.
@@ -684,6 +721,80 @@ static inline void xas_set_update(struct xa_state *xas, xa_update_node_t update)
 	xas->xa_update = update;
 }
 
+/* Skip over any of these entries when iterating */
+static inline bool xa_iter_skip(const void *entry)
+{
+	return unlikely(!entry ||
+			(xa_is_internal(entry) && entry < XA_RETRY_ENTRY));
+}
+
+/*
+ * node->shift is always 0 for the inline iterators unless we're processing
+ * a multi-index entry.
+ */
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+#define xa_node_shift(node)	node->shift
+#else
+#define xa_node_shift(node)	0
+#endif
+
+/**
+ * xas_next_entry() - Advance iterator to next present entry.
+ * @xas: XArray operation state.
+ * @max: Highest index to return.
+ *
+ * xas_next_entry() is an inline function to optimise xarray traversal for
+ * speed.  It is equivalent to calling xas_find(), and will call xas_find()
+ * for all the hard cases.
+ *
+ * Return: The next present entry after the one currently referred to by @xas.
+ */
+static inline void *xas_next_entry(struct xa_state *xas, unsigned long max)
+{
+	struct xa_node *node = xas->xa_node;
+	void *entry;
+
+	if (unlikely(xas_not_node(node) || xa_node_shift(node)))
+		return xas_find(xas, max);
+
+	do {
+		if (unlikely(xas->xa_index >= max))
+			return xas_find(xas, max);
+		if (unlikely(xas->xa_offset == XA_CHUNK_MASK))
+			return xas_find(xas, max);
+		xas->xa_index++;
+		xas->xa_offset++;
+		entry = xa_entry(xas->xa, node, xas->xa_offset);
+	} while (xa_iter_skip(entry));
+
+	return entry;
+}
+
+/*
+ * If iterating while holding a lock, drop the lock and reschedule
+ * every %XA_CHECK_SCHED loops.
+ */
+enum {
+	XA_CHECK_SCHED = 4096,
+};
+
+/**
+ * xas_for_each() - Iterate over a range of an XArray
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
+#define xas_for_each(xas, entry, max) \
+	for (entry = xas_find(xas, max); entry; \
+	     entry = xas_next_entry(xas, max))
+
 /* Internal functions, mostly shared between radix-tree.c, xarray.c and idr.c */
 void xas_destroy(struct xa_state *);
 
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index cf95247a9e1b..36e24dde6356 100644
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
@@ -2103,7 +2103,7 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 		if (!rtag_get(node, IDR_FREE, offset)) {
 			offset = radix_tree_find_next_bit(node, IDR_FREE,
 							offset + 1);
-			start = next_index(start, node, offset);
+			start = rnext_index(start, node, offset);
 			if (start > max)
 				return ERR_PTR(-ENOSPC);
 			while (offset == RADIX_TREE_MAP_SIZE) {
diff --git a/lib/xarray.c b/lib/xarray.c
index ef3340471e5c..4d8962d2341c 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -91,6 +91,12 @@ static unsigned int get_offset(unsigned long index, struct xa_node *node)
 	return (index >> node->shift) & XA_CHUNK_MASK;
 }
 
+static void xas_add(struct xa_state *xas, unsigned long val)
+{
+	xas->xa_index += (val << xas->xa_node->shift);
+	xas->xa_offset += val;
+}
+
 static void *set_bounds(struct xa_state *xas)
 {
 	xas->xa_node = XAS_BOUNDS;
@@ -796,6 +802,101 @@ void xas_init_tags(const struct xa_state *xas)
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
+	if (xas_invalid(xas))
+		return;
+
+	if (node) {
+		unsigned int offset = xas->xa_offset;
+		while (++offset < XA_CHUNK_SIZE) {
+			if (!xa_is_sibling(xa_entry(xas->xa, node, offset)))
+				break;
+		}
+		xas->xa_index += (offset - xas->xa_offset) << node->shift;
+	} else {
+		xas->xa_index++;
+	}
+	xas->xa_node = XAS_RESTART;
+}
+EXPORT_SYMBOL_GPL(xas_pause);
+
+/**
+ * xas_find() - Find the next present entry in the XArray.
+ * @xas: XArray operation state.
+ * @max: Highest index to return.
+ *
+ * If the xas has not yet been walked to an entry, return the entry
+ * which has an index >= xas.xa_index.  If it has been walked, the entry
+ * currently being pointed at has been processed, and so we move to the
+ * next entry.
+ *
+ * If no entry is found and the array is smaller than @max, the iterator
+ * is set to the smallest index not yet in the array.  This allows @xas
+ * to be immediately passed to xas_create().
+ *
+ * Return: The entry, if found, otherwise NULL.
+ */
+void *xas_find(struct xa_state *xas, unsigned long max)
+{
+	void *entry;
+
+	if (xas_error(xas))
+		return NULL;
+
+	if (!xas->xa_node) {
+		xas->xa_index = 1;
+		return set_bounds(xas);
+	} else if (xas_top(xas->xa_node)) {
+		entry = xas_load(xas);
+		if (entry || xas_not_node(xas->xa_node))
+			return entry;
+	}
+
+	xas_add(xas, 1);
+
+	while (xas->xa_node && (xas->xa_index <= max)) {
+		if (unlikely(xas->xa_offset == XA_CHUNK_SIZE)) {
+			xas->xa_offset = xas->xa_node->offset + 1;
+			xas->xa_node = xa_parent(xas->xa, xas->xa_node);
+			continue;
+		}
+
+		entry = xa_entry(xas->xa, xas->xa_node, xas->xa_offset);
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
+		xas->xa_node = XAS_BOUNDS;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(xas_find);
+
 /**
  * __xa_init() - Initialise an empty XArray with flags.
  * @xa: XArray.
@@ -1086,6 +1187,71 @@ void xa_clear_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
 }
 EXPORT_SYMBOL(xa_clear_tag);
 
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
+ * return an %XA_RETRY_ENTRY; if you need to see retry entries, use xas_find().
+ *
+ * Return: The entry, if found, otherwise NULL.
+ */
+void *xa_find(struct xarray *xa, unsigned long *indexp, unsigned long max)
+{
+	XA_STATE(xas, xa, *indexp);
+	void *entry;
+
+	rcu_read_lock();
+	do {
+		entry = xas_find(&xas, max);
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
+ * xa_find_after() - Search the XArray for a present entry.
+ * @xa: XArray.
+ * @indexp: Pointer to an index.
+ * @max: Maximum index to search to.
+ *
+ * Finds the entry in @xa with the lowest index that is above *@indexp and
+ * less than or equal to @max.  If an entry is found, updates @indexp to be
+ * the index of the pointer.  This function is protected by the RCU read
+ * lock, so it may miss entries which are being simultaneously added.  It
+ * will not return an %XA_RETRY_ENTRY; if you need to see retry entries,
+ * use xas_find().
+ *
+ * Return: The pointer, if found, otherwise NULL.
+ */
+void *xa_find_after(struct xarray *xa, unsigned long *indexp, unsigned long max)
+{
+	XA_STATE(xas, xa, *indexp + 1);
+	void *entry;
+
+	rcu_read_lock();
+	do {
+		entry = xas_find(&xas, max);
+		if (*indexp >= xas.xa_index)
+			entry = xas_next_entry(&xas, max);
+	} while (xas_retry(&xas, entry));
+	rcu_read_unlock();
+
+	if (entry)
+		*indexp = xas.xa_index;
+	return entry;
+}
+EXPORT_SYMBOL(xa_find_after);
+
 #ifdef XA_DEBUG
 void xa_dump_node(const struct xa_node *node)
 {
diff --git a/tools/testing/radix-tree/xarray-test.c b/tools/testing/radix-tree/xarray-test.c
index 416f1bbb6943..10de5d3d977a 100644
--- a/tools/testing/radix-tree/xarray-test.c
+++ b/tools/testing/radix-tree/xarray-test.c
@@ -49,6 +49,72 @@ void check_xa_tag(struct xarray *xa)
 	assert(xa_get_tag(xa, 0, XA_TAG_0) == false);
 }
 
+/* Check that putting the xas into an error state works correctly */
+void check_xas_error(struct xarray *xa)
+{
+	XA_STATE(xas, xa, 0);
+
+	assert(xa_store(xa, 1, xa_mk_value(1), GFP_KERNEL) == 0);
+	assert(xa_load(xa, 1) == xa_mk_value(1));
+
+	assert(xas_error(&xas) == 0);
+
+	xas_set_err(&xas, -ENOTTY);
+	assert(xas_error(&xas) == -ENOTTY);
+
+	xas_set_err(&xas, -ENOSPC);
+	assert(xas_error(&xas) == -ENOSPC);
+
+	xas_set_err(&xas, -ENOMEM);
+	assert(xas_error(&xas) == -ENOMEM);
+
+	assert(xas_load(&xas) == NULL);
+	assert(xas_store(&xas, &xas) == NULL);
+	assert(xas_load(&xas) == NULL);
+
+	assert(xas.xa_index == 0);
+	assert(xas_next(&xas) == NULL);
+	assert(xas.xa_index == 0);
+
+	assert(xas_prev(&xas) == NULL);
+	assert(xas.xa_index == 0);
+
+	xas_retry(&xas, XA_RETRY_ENTRY);
+	assert(xas_error(&xas) == 0);
+
+	assert(xas_find(&xas, ULONG_MAX) == xa_mk_value(1));
+	assert(xas.xa_index == 1);
+	assert(xas_error(&xas) == 0);
+
+	assert(xas_find(&xas, ULONG_MAX) == NULL);
+	assert(xas.xa_index > 1);
+	assert(xas_error(&xas) == 0);
+	assert(xas.xa_node == XAS_BOUNDS);
+}
+
+void check_xas_retry(struct xarray *xa)
+{
+	XA_STATE(xas, xa, 0);
+
+	xa_store(xa, 0, xa_mk_value(0), GFP_KERNEL);
+	xa_store(xa, 1, xa_mk_value(1), GFP_KERNEL);
+
+	assert(xas_find(&xas, ULONG_MAX) == xa_mk_value(0));
+	xa_erase(xa, 1);
+	assert(xa_is_retry(xas_reload(&xas)));
+	assert(!xas_retry(&xas, NULL));
+	assert(!xas_retry(&xas, xa_mk_value(0)));
+	assert(xas_retry(&xas, XA_RETRY_ENTRY));
+	assert(xas.xa_node == XAS_RESTART);
+	assert(xas_next_entry(&xas, ULONG_MAX) == xa_mk_value(0));
+	assert(xas.xa_node == NULL);
+
+	xa_store(xa, 1, xa_mk_value(1), GFP_KERNEL);
+	assert(xa_is_internal(xas_reload(&xas)));
+	xas.xa_node = XAS_RESTART;
+	assert(xas_next_entry(&xas, ULONG_MAX) == xa_mk_value(0));
+}
+
 void check_xa_load(struct xarray *xa)
 {
 	unsigned long i, j;
@@ -147,6 +213,42 @@ void check_multi_store(struct xarray *xa)
 	}
 }
 
+void check_find(struct xarray *xa)
+{
+	unsigned long index;
+	xa_store_order(xa, 12, 2, xa_mk_value(12));
+	xa_store(xa, 16, xa_mk_value(16), GFP_KERNEL);
+
+	index = 0;
+	assert(xa_find(xa, &index, ULONG_MAX) == xa_mk_value(12));
+	assert(index == 12);
+	index = 13;
+	assert(xa_find(xa, &index, ULONG_MAX) == xa_mk_value(12));
+	assert(index >= 12 && index < 16);
+	assert(xa_find_after(xa, &index, ULONG_MAX) == xa_mk_value(16));
+	assert(index == 16);
+}
+
+void check_xas_delete(struct xarray *xa)
+{
+	XA_STATE(xas, xa, 0);
+	void *entry;
+	unsigned long i, j;
+
+	for (i = 0; i < 200; i++) {
+		for (j = i; j < 2 * i + 5; j++) {
+			xa_store(xa, j, xa_mk_value(j), GFP_KERNEL);
+		}
+		xas_set(&xas, 0);
+		j = i;
+		xas_for_each(&xas, entry, ULONG_MAX) {
+			assert(entry == xa_mk_value(j));
+			xas_store(&xas, NULL);
+			j++;
+		}
+	}
+}
+
 void xarray_checks(void)
 {
 	DEFINE_XARRAY(array);
@@ -157,6 +259,12 @@ void xarray_checks(void)
 	check_xa_tag(&array);
 	item_kill_tree(&array);
 
+	check_xas_error(&array);
+	item_kill_tree(&array);
+
+	check_xas_retry(&array);
+	item_kill_tree(&array);
+
 	check_xa_load(&array);
 	item_kill_tree(&array);
 
@@ -165,6 +273,12 @@ void xarray_checks(void)
 
 	check_multi_store(&array);
 	item_kill_tree(&array);
+
+	check_find(&array);
+	item_kill_tree(&array);
+
+	check_xas_delete(&array);
+	item_kill_tree(&array);
 }
 
 int __weak main(void)
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

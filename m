Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B12BA6B02C9
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:43:50 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id h18so1637498pfi.2
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:43:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v204si867325pgb.639.2017.12.05.16.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:42:09 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 17/73] xarray: Add xas_next and xas_prev
Date: Tue,  5 Dec 2017 16:41:03 -0800
Message-Id: <20171206004159.3755-18-willy@infradead.org>
In-Reply-To: <20171206004159.3755-1-willy@infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

These two functions move the xas index by one position, and adjust the
rest of the iterator state to match it.  This is more efficient than
calling xas_set() as it keeps the iterator at the leaves of the tree
instead of walking the iterator from the root each time.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h                 |  71 ++++++++++-
 lib/xarray.c                           |  74 ++++++++++++
 tools/testing/radix-tree/xarray-test.c | 214 +++++++++++++++++++++++++++++++++
 3 files changed, 357 insertions(+), 2 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index b648c1b93d9f..416708ace115 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -549,6 +549,12 @@ static inline bool xas_not_node(struct xa_node *node)
 	return (unsigned long)node < 4096;
 }
 
+/* True if the node represents RESTART or an error */
+static inline bool xas_frozen(struct xa_node *node)
+{
+	return (unsigned long)node & 1;
+}
+
 /* True if the node represents head-of-tree, RESTART or BOUNDS */
 static inline bool xas_top(struct xa_node *node)
 {
@@ -664,8 +670,8 @@ static inline bool xa_iter_skip(void *entry)
 }
 
 /*
- * node->shift is always 0 for the inline iterators unless we're processing
- * a multi-index entry.
+ * node->shift is always 0 for next_entry and next_tag unless we're processing
+ * a multi-index entry.  It can be non-0 for next/prev, so it's not used there.
  */
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
 #define xa_node_shift(node)	node->shift
@@ -673,6 +679,67 @@ static inline bool xa_iter_skip(void *entry)
 #define xa_node_shift(node)	0
 #endif
 
+void *__xas_next(struct xa_state *);
+void *__xas_prev(struct xa_state *);
+
+/**
+ * xas_prev() - Move iterator to previous index.
+ * @xas: XArray operation state.
+ *
+ * If the @xas was in an error state, it will remain in an error state
+ * and this function will return %NULL.  If the @xas has never been walked,
+ * it will have the effect of calling xas_load().  Otherwise one will be
+ * subtracted from the index and the state will be walked to the correct
+ * location in the array for the next operation.
+ *
+ * If the iterator was referencing index 0, this function wraps
+ * around to %ULONG_MAX.
+ *
+ * Return: The entry at the new index.  This may be %NULL or an internal
+ * entry, although it should never be a node entry.
+ */
+static inline void *xas_prev(struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_node;
+
+	if (unlikely(xas_not_node(node) || node->shift ||
+				xas->xa_offset == 0))
+		return __xas_prev(xas);
+
+	xas->xa_index--;
+	xas->xa_offset--;
+	return xa_entry(xas->xa, node, xas->xa_offset);
+}
+
+/**
+ * xas_next() - Move state to next index.
+ * @xas: XArray operation state.
+ *
+ * If the @xas was in an error state, it will remain in an error state
+ * and this function will return %NULL.  If the @xas has never been walked,
+ * it will have the effect of calling xas_load().  Otherwise one will be
+ * added to the index and the state will be walked to the correct
+ * location in the array for the next operation.
+ *
+ * If the iterator was referencing index %ULONG_MAX, this function wraps
+ * around to 0.
+ *
+ * Return: The entry at the new index.  This may be %NULL or an internal
+ * entry, although it should never be a node entry.
+ */
+static inline void *xas_next(struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_node;
+
+	if (unlikely(xas_not_node(node) || node->shift ||
+				xas->xa_offset == XA_CHUNK_MASK))
+		return __xas_next(xas);
+
+	xas->xa_index++;
+	xas->xa_offset++;
+	return xa_entry(xas->xa, node, xas->xa_offset);
+}
+
 /**
  * xas_next_entry() - Advance iterator to next present entry.
  * @xas: XArray operation state.
diff --git a/lib/xarray.c b/lib/xarray.c
index f3875b251b41..8c6e83d10554 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -799,6 +799,80 @@ void xas_pause(struct xa_state *xas)
 }
 EXPORT_SYMBOL_GPL(xas_pause);
 
+/*
+ * __xas_prev() - Find the previous entry in the XArray.
+ * @xas: XArray operation state.
+ *
+ * Helper function for xas_prev() which handles all the complex cases
+ * out of line.
+ */
+void *__xas_prev(struct xa_state *xas)
+{
+	void *entry;
+
+	if (!xas_frozen(xas->xa_node))
+		xas->xa_index--;
+	if (xas_not_node(xas->xa_node))
+		return xas_load(xas);
+
+	if (xas->xa_offset != get_offset(xas->xa_index, xas->xa_node))
+		xas->xa_offset--;
+
+	while (xas->xa_offset == 255) {
+		xas->xa_offset = xas->xa_node->offset - 1;
+		xas->xa_node = xa_parent(xas->xa, xas->xa_node);
+		if (!xas->xa_node)
+			return set_bounds(xas);
+	}
+
+	for (;;) {
+		entry = xa_entry(xas->xa, xas->xa_node, xas->xa_offset);
+		if (!xa_is_node(entry))
+			return entry;
+
+		xas->xa_node = xa_to_node(entry);
+		xas->xa_offset = get_offset(xas->xa_index, xas->xa_node);
+	}
+}
+EXPORT_SYMBOL_GPL(__xas_prev);
+
+/*
+ * __xas_next() - Find the next entry in the XArray.
+ * @xas: XArray operation state.
+ *
+ * Helper function for xas_next() which handles all the complex cases
+ * out of line.
+ */
+void *__xas_next(struct xa_state *xas)
+{
+	void *entry;
+
+	if (!xas_frozen(xas->xa_node))
+		xas->xa_index++;
+	if (xas_not_node(xas->xa_node))
+		return xas_load(xas);
+
+	if (xas->xa_offset != get_offset(xas->xa_index, xas->xa_node))
+		xas->xa_offset++;
+
+	while (xas->xa_offset == XA_CHUNK_SIZE) {
+		xas->xa_offset = xas->xa_node->offset + 1;
+		xas->xa_node = xa_parent(xas->xa, xas->xa_node);
+		if (!xas->xa_node)
+			return set_bounds(xas);
+	}
+
+	for (;;) {
+		entry = xa_entry(xas->xa, xas->xa_node, xas->xa_offset);
+		if (!xa_is_node(entry))
+			return entry;
+
+		xas->xa_node = xa_to_node(entry);
+		xas->xa_offset = get_offset(xas->xa_index, xas->xa_node);
+	}
+}
+EXPORT_SYMBOL_GPL(__xas_next);
+
 /**
  * xas_find() - Find the next present entry in the XArray.
  * @xas: XArray operation state.
diff --git a/tools/testing/radix-tree/xarray-test.c b/tools/testing/radix-tree/xarray-test.c
index cc5d0b7a1edf..0946eef351e2 100644
--- a/tools/testing/radix-tree/xarray-test.c
+++ b/tools/testing/radix-tree/xarray-test.c
@@ -79,6 +79,104 @@ void check_xas_error(struct xarray *xa)
 	assert(xas.xa_node == XAS_BOUNDS);
 }
 
+void check_xas_pause(struct xarray *xa)
+{
+	XA_STATE(xas, xa, 0);
+	void *entry;
+	unsigned int seen;
+
+	xa_store(xa, 0, xa_mk_value(0), GFP_KERNEL);
+	xa_set_tag(xa, 0, XA_TAG_0);
+
+	seen = 0;
+	rcu_read_lock();
+	xas_for_each_tag(&xas, entry, ULONG_MAX, XA_TAG_0) {
+		if (!seen++) {
+			xa_store(xa, 1, xa_mk_value(1), GFP_KERNEL);
+			xa_set_tag(xa, 1, XA_TAG_0);
+		}
+	}
+	rcu_read_unlock();
+	/* We don't see an entry that was added after we started */
+	assert(seen == 1);
+
+	seen = 0;
+	xas_set(&xas, 0);
+	rcu_read_lock();
+	xas_for_each_tag(&xas, entry, ULONG_MAX, XA_TAG_0) {
+		if (!seen++)
+			xa_erase(xa, 1);
+	}
+	rcu_read_unlock();
+	assert(seen == 1);
+
+	seen = 0;
+	xas_set(&xas, 0);
+	rcu_read_lock();
+	xas_for_each(&xas, entry, ULONG_MAX) {
+		if (!seen++)
+			xa_store(xa, 1, xa_mk_value(1), GFP_KERNEL);
+	}
+	rcu_read_unlock();
+	assert(seen == 1);
+
+	seen = 0;
+	xas_set(&xas, 0);
+	rcu_read_lock();
+	xas_for_each(&xas, entry, ULONG_MAX) {
+		if (!seen++)
+			xa_erase(xa, 1);
+	}
+	rcu_read_unlock();
+	assert(seen == 1);
+
+	seen = 0;
+	xas_set(&xas, 0);
+	rcu_read_lock();
+	for (entry = xas_load(&xas); entry; entry = xas_next(&xas)) {
+		if (!seen++)
+			xa_store(xa, 1, xa_mk_value(1), GFP_KERNEL);
+	}
+	rcu_read_unlock();
+	assert(seen == 2);
+
+	seen = 0;
+	xas_set(&xas, 0);
+	rcu_read_lock();
+	for (entry = xas_load(&xas); entry; entry = xas_next(&xas)) {
+		if (!seen++)
+			xa_erase(xa, 1);
+	}
+	rcu_read_unlock();
+	assert(seen == 1);
+
+	xa_store(xa, 1, xa_mk_value(1), GFP_KERNEL);
+	seen = 0;
+	xas_set(&xas, 0);
+	xas_for_each(&xas, entry, ULONG_MAX) {
+		if (!seen++)
+			xas_pause(&xas);
+	}
+	assert(seen == 2);
+
+	seen = 0;
+	xas_set(&xas, 0);
+	for (entry = xas_load(&xas); entry; entry = xas_next(&xas)) {
+		if (!seen++)
+			xas_pause(&xas);
+	}
+	assert(seen == 2);
+
+	seen = 0;
+	xas_set(&xas, 0);
+	xa_set_tag(xa, 1, XA_TAG_0);
+	xas_for_each_tag(&xas, entry, ULONG_MAX, XA_TAG_0) {
+		if (!seen++)
+			xas_pause(&xas);
+	}
+	assert(seen == 2);
+}
+
 void check_xas_retry(struct xarray *xa)
 {
 	XA_STATE(xas, xa, 0);
@@ -216,9 +314,109 @@ void check_find(struct xarray *xa)
 	assert(index == 16);
 }
 
+void check_move_small(struct xarray *xa, unsigned long idx)
+{
+	XA_STATE(xas, xa, 0);
+	unsigned long i;
+
+	xa_store(xa, 0, xa_mk_value(0), GFP_KERNEL);
+	xa_store(xa, idx, xa_mk_value(idx), GFP_KERNEL);
+
+	for (i = 0; i < idx * 4; i++) {
+		void *entry = xas_next(&xas);
+		if (i <= idx)
+			assert(xas.xa_node != XAS_RESTART);
+		assert(xas.xa_index == i);
+		if (i == 0 || i == idx)
+			assert(entry == xa_mk_value(i));
+		else
+			assert(entry == NULL);
+	}
+	xas_next(&xas);
+	assert(xas.xa_index == i);
+
+	do {
+		void *entry = xas_prev(&xas);
+		i--;
+		if (i <= idx)
+			assert(xas.xa_node != XAS_RESTART);
+		assert(xas.xa_index == i);
+		if (i == 0 || i == idx)
+			assert(entry == xa_mk_value(i));
+		else
+			assert(entry == NULL);
+	} while (i > 0);
+
+	xas_set(&xas, ULONG_MAX);
+	assert(xas_next(&xas) == NULL);
+	assert(xas.xa_index == ULONG_MAX);
+	assert(xas_next(&xas) == xa_mk_value(0));
+	assert(xas.xa_index == 0);
+	assert(xas_prev(&xas) == NULL);
+	assert(xas.xa_index == ULONG_MAX);
+}
+
+void check_move(struct xarray *xa)
+{
+	XA_STATE(xas, xa, (1 << 16) - 1);
+	unsigned long i;
+
+	for (i = 0; i < (1 << 16); i++) {
+		xa_store(xa, i, xa_mk_value(i), GFP_KERNEL);
+	}
+
+	do {
+		void *entry = xas_prev(&xas);
+		i--;
+		assert(entry == xa_mk_value(i));
+		assert(i == xas.xa_index);
+	} while (i != 0);
+
+	assert(xas_prev(&xas) == NULL);
+	assert(xas.xa_index == ULONG_MAX);
+
+	do {
+		void *entry = xas_next(&xas);
+		assert(entry == xa_mk_value(i));
+		assert(i == xas.xa_index);
+		i++;
+	} while (i < (1 << 16));
+
+	for (i = (1 << 8); i < (1 << 15); i++) {
+		xa_erase(xa, i);
+	}
+
+	i = xas.xa_index;
+
+	do {
+		void *entry = xas_prev(&xas);
+		i--;
+		if ((i < (1 << 8)) || (i >= (1 << 15)))
+			assert(entry == xa_mk_value(i));
+		else
+			assert(entry == NULL);
+		assert(i == xas.xa_index);
+	} while (i != 0);
+
+	assert(xas_prev(&xas) == NULL);
+	assert(xas.xa_index == ULONG_MAX);
+
+	do {
+		void *entry = xas_next(&xas);
+		if ((i < (1 << 8)) || (i >= (1 << 15)))
+			assert(entry == xa_mk_value(i));
+		else
+			assert(entry == NULL);
+		assert(i == xas.xa_index);
+		i++;
+	} while (i < (1 << 16));
+
+}
+
 void xarray_checks(void)
 {
 	DEFINE_XARRAY(array);
+	unsigned long i;
 
 	check_xa_tag(&array);
 	item_kill_tree(&array);
@@ -229,6 +427,9 @@ void xarray_checks(void)
 	check_xas_retry(&array);
 	item_kill_tree(&array);
 
+	check_xas_pause(&array);
+	item_kill_tree(&array);
+
 	check_xa_load(&array);
 	item_kill_tree(&array);
 
@@ -240,6 +441,19 @@ void xarray_checks(void)
 
 	check_find(&array);
 	item_kill_tree(&array);
+
+	for (i = 0; i < 16; i++) {
+		check_move_small(&array, 1UL << i);
+		item_kill_tree(&array);
+	}
+
+	for (i = 2; i < 16; i++) {
+		check_move_small(&array, (1UL << i) - 1);
+		item_kill_tree(&array);
+	}
+
+	check_move(&array);
+	item_kill_tree(&array);
 }
 
 int __weak main(void)
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

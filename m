Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20BC06B02D6
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:08:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z9-v6so10264588pfe.23
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:08:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r25-v6si29027027pff.24.2018.06.11.07.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:06:46 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 15/72] xarray: Add xas_next and xas_prev
Date: Mon, 11 Jun 2018 07:05:42 -0700
Message-Id: <20180611140639.17215-16-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

These two functions move the xas index by one position, and adjust the
rest of the iterator state to match it.  This is more efficient than
calling xas_set() as it keeps the iterator at the leaves of the tree
instead of walking the iterator from the root each time.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h                 |  67 +++++++
 lib/xarray.c                           |  74 +++++++
 tools/testing/radix-tree/xarray-test.c | 261 ++++++++++++++++++++++++-
 3 files changed, 401 insertions(+), 1 deletion(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 6273dd222fda..dd941454bb5b 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -700,6 +700,12 @@ static inline bool xas_not_node(struct xa_node *node)
 	return ((unsigned long)node & 3) || !node;
 }
 
+/* True if the node represents RESTART or an error */
+static inline bool xas_frozen(struct xa_node *node)
+{
+	return (unsigned long)node & 2;
+}
+
 /* True if the node represents head-of-tree, RESTART or BOUNDS */
 static inline bool xas_top(struct xa_node *node)
 {
@@ -958,6 +964,67 @@ enum {
 	for (entry = xas_find_tagged(xas, max, tag); entry; \
 	     entry = xas_next_tagged(xas, max, tag))
 
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
+ * entry.
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
+ * entry.
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
 /* Internal functions, mostly shared between radix-tree.c, xarray.c and idr.c */
 void xas_destroy(struct xa_state *);
 
diff --git a/lib/xarray.c b/lib/xarray.c
index c505084ad43a..3b2c2f2240bf 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -877,6 +877,80 @@ void xas_pause(struct xa_state *xas)
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
+		xas_set_offset(xas);
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
+		xas_set_offset(xas);
+	}
+}
+EXPORT_SYMBOL_GPL(__xas_next);
+
 /**
  * xas_find() - Find the next present entry in the XArray.
  * @xas: XArray operation state.
diff --git a/tools/testing/radix-tree/xarray-test.c b/tools/testing/radix-tree/xarray-test.c
index 24eb1bda4a79..eeafbf8c948c 100644
--- a/tools/testing/radix-tree/xarray-test.c
+++ b/tools/testing/radix-tree/xarray-test.c
@@ -53,6 +53,147 @@ void check_xa_tag(struct xarray *xa)
 	xa_store(xa, 0, NULL, 0);
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
+	xas_for_each_tagged(&xas, entry, ULONG_MAX, XA_TAG_0) {
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
+	xas_for_each_tagged(&xas, entry, ULONG_MAX, XA_TAG_0) {
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
+	xas_for_each_tagged(&xas, entry, ULONG_MAX, XA_TAG_0) {
+		if (!seen++)
+			xas_pause(&xas);
+	}
+	assert(seen == 2);
+}
+
 void check_xas_retry(struct xarray *xa)
 {
 	XA_STATE(xas, xa, 0);
@@ -65,7 +206,7 @@ void check_xas_retry(struct xarray *xa)
 	assert(xa_is_retry(xas_reload(&xas)));
 	assert(!xas_retry(&xas, NULL));
 	assert(!xas_retry(&xas, xa_mk_value(0)));
-	assert(xas_retry(&xas, XA_RETRY_ENTRY));
+	xas_reset(&xas);
 	assert(xas.xa_node == XAS_RESTART);
 	assert(xas_next_entry(&xas, ULONG_MAX) == xa_mk_value(0));
 	assert(xas.xa_node == NULL);
@@ -269,9 +410,108 @@ void check_xas_delete(struct xarray *xa)
 	}
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
+}
+
 void xarray_checks(void)
 {
 	DEFINE_XARRAY(array);
+	unsigned long i;
 
 	check_xa_err(&array);
 	item_kill_tree(&array);
@@ -279,9 +519,15 @@ void xarray_checks(void)
 	check_xa_tag(&array);
 	item_kill_tree(&array);
 
+	check_xas_error(&array);
+	item_kill_tree(&array);
+
 	check_xas_retry(&array);
 	item_kill_tree(&array);
 
+	check_xas_pause(&array);
+	item_kill_tree(&array);
+
 	check_xa_load(&array);
 	item_kill_tree(&array);
 
@@ -295,6 +541,19 @@ void xarray_checks(void)
 	check_find(&array);
 	check_xas_delete(&array);
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
2.17.1

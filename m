Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id F23206B0007
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:00 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d6-v6so4740225plo.15
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 65-v6si11492208pfo.229.2018.06.16.19.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:00:58 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 16/74] xarray: Step through an XArray
Date: Sat, 16 Jun 2018 18:59:54 -0700
Message-Id: <20180617020052.4759-17-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

The xas_next and xas_prev functions move the xas index by one position,
and adjust the rest of the iterator state to match it.  This is more
efficient than calling xas_set() as it keeps the iterator at the leaves
of the tree instead of walking the iterator from the root each time.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/xarray.h |  67 +++++++++++++++++++++++++
 lib/test_xarray.c      | 109 +++++++++++++++++++++++++++++++++++++++++
 lib/xarray.c           |  74 ++++++++++++++++++++++++++++
 3 files changed, 250 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index fa36a0670988..921d41034d7d 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -719,6 +719,12 @@ static inline bool xas_not_node(struct xa_node *node)
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
@@ -977,6 +983,67 @@ enum {
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
 
diff --git a/lib/test_xarray.c b/lib/test_xarray.c
index a6a3705165ca..e74ade12c663 100644
--- a/lib/test_xarray.c
+++ b/lib/test_xarray.c
@@ -384,6 +384,114 @@ static void check_find(struct xarray *xa)
 	check_multi_find(xa);
 }
 
+static void check_move_small(struct xarray *xa, unsigned long idx)
+{
+	XA_STATE(xas, xa, 0);
+	unsigned long i;
+
+	xa_store_value(xa, 0, GFP_KERNEL);
+	xa_store_value(xa, idx, GFP_KERNEL);
+
+	for (i = 0; i < idx * 4; i++) {
+		void *entry = xas_next(&xas);
+		if (i <= idx)
+			XA_BUG_ON(xa, xas.xa_node == XAS_RESTART);
+		XA_BUG_ON(xa, xas.xa_index != i);
+		if (i == 0 || i == idx)
+			XA_BUG_ON(xa, entry != xa_mk_value(i));
+		else
+			XA_BUG_ON(xa, entry != NULL);
+	}
+	xas_next(&xas);
+	XA_BUG_ON(xa, xas.xa_index != i);
+
+	do {
+		void *entry = xas_prev(&xas);
+		i--;
+		if (i <= idx)
+			XA_BUG_ON(xa, xas.xa_node == XAS_RESTART);
+		XA_BUG_ON(xa, xas.xa_index != i);
+		if (i == 0 || i == idx)
+			XA_BUG_ON(xa, entry != xa_mk_value(i));
+		else
+			XA_BUG_ON(xa, entry != NULL);
+	} while (i > 0);
+
+	xas_set(&xas, ULONG_MAX);
+	XA_BUG_ON(xa, xas_next(&xas) != NULL);
+	XA_BUG_ON(xa, xas.xa_index != ULONG_MAX);
+	XA_BUG_ON(xa, xas_next(&xas) != xa_mk_value(0));
+	XA_BUG_ON(xa, xas.xa_index != 0);
+	XA_BUG_ON(xa, xas_prev(&xas) != NULL);
+	XA_BUG_ON(xa, xas.xa_index != ULONG_MAX);
+
+	xa_erase_value(xa, 0);
+	xa_erase_value(xa, idx);
+	XA_BUG_ON(xa, !xa_empty(xa));
+}
+
+static void check_move(struct xarray *xa)
+{
+	XA_STATE(xas, xa, (1 << 16) - 1);
+	unsigned long i;
+
+	for (i = 0; i < (1 << 16); i++)
+		XA_BUG_ON(xa, xa_store_value(xa, i, GFP_KERNEL) != NULL);
+
+	do {
+		void *entry = xas_prev(&xas);
+		i--;
+		XA_BUG_ON(xa, entry != xa_mk_value(i));
+		XA_BUG_ON(xa, i != xas.xa_index);
+	} while (i != 0);
+
+	XA_BUG_ON(xa, xas_prev(&xas) != NULL);
+	XA_BUG_ON(xa, xas.xa_index != ULONG_MAX);
+
+	do {
+		void *entry = xas_next(&xas);
+		XA_BUG_ON(xa, entry != xa_mk_value(i));
+		XA_BUG_ON(xa, i != xas.xa_index);
+		i++;
+	} while (i < (1 << 16));
+
+	for (i = (1 << 8); i < (1 << 15); i++)
+		xa_erase_value(xa, i);
+
+	i = xas.xa_index;
+
+	do {
+		void *entry = xas_prev(&xas);
+		i--;
+		if ((i < (1 << 8)) || (i >= (1 << 15)))
+			XA_BUG_ON(xa, entry != xa_mk_value(i));
+		else
+			XA_BUG_ON(xa, entry != NULL);
+		XA_BUG_ON(xa, i != xas.xa_index);
+	} while (i != 0);
+
+	XA_BUG_ON(xa, xas_prev(&xas) != NULL);
+	XA_BUG_ON(xa, xas.xa_index != ULONG_MAX);
+
+	do {
+		void *entry = xas_next(&xas);
+		if ((i < (1 << 8)) || (i >= (1 << 15)))
+			XA_BUG_ON(xa, entry != xa_mk_value(i));
+		else
+			XA_BUG_ON(xa, entry != NULL);
+		XA_BUG_ON(xa, i != xas.xa_index);
+		i++;
+	} while (i < (1 << 16));
+
+	xa_destroy(xa);
+
+	for (i = 0; i < 16; i++)
+		check_move_small(xa, 1UL << i);
+
+	for (i = 2; i < 16; i++)
+		check_move_small(xa, (1UL << i) - 1);
+}
+
 static int xarray_checks(void)
 {
 	DEFINE_XARRAY(array);
@@ -397,6 +505,7 @@ static int xarray_checks(void)
 	check_cmpxchg(&array);
 	check_multi_store(&array);
 	check_find(&array);
+	check_move(&array);
 
 	printk("XArray: %u of %u tests passed\n", tests_passed, tests_run);
 	return (tests_run != tests_passed) ? 0 : -EINVAL;
diff --git a/lib/xarray.c b/lib/xarray.c
index e90ba76404ae..ab1b6786711e 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -863,6 +863,80 @@ void xas_pause(struct xa_state *xas)
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
-- 
2.17.1

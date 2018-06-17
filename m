Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25E926B0006
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:02:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y26-v6so6681529pfn.14
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:02:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 2-v6si11313272pfj.6.2018.06.16.19.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:02 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 13/74] xarray: Add XArray iterators
Date: Sat, 16 Jun 2018 18:59:51 -0700
Message-Id: <20180617020052.4759-14-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

The xa_for_each iterator allows the user to efficiently walk a range
of the array, executing the loop body once for each entry in that
range that matches the filter.  This commit also includes xa_find()
and xa_find_above() which are helper functions for xa_for_each() but
may also be useful in their own right.

In the xas family of functions, we have xas_for_each(), xas_find(),
xas_next_entry(), xas_for_each_tagged(), xas_find_tagged(),
xas_next_tagged() and xas_pause().

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/xarray.h | 169 +++++++++++++++++++++++++
 lib/test_xarray.c      | 128 +++++++++++++++++++
 lib/xarray.c           | 274 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 571 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 94b7f454a6a0..0790b3b098f0 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -223,6 +223,10 @@ void *xa_cmpxchg(struct xarray *, unsigned long index,
 bool xa_get_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
+void *xa_find(struct xarray *xa, unsigned long *index,
+		unsigned long max, xa_tag_t) __attribute__((nonnull(2)));
+void *xa_find_after(struct xarray *xa, unsigned long *index,
+		unsigned long max, xa_tag_t) __attribute__((nonnull(2)));
 
 /**
  * xa_init() - Initialise an empty XArray.
@@ -307,6 +311,35 @@ static inline int xa_insert(struct xarray *xa, unsigned long index,
 	return -EEXIST;
 }
 
+/**
+ * xa_for_each() - Iterate over a portion of an XArray.
+ * @xa: XArray.
+ * @entry: Entry retrieved from array.
+ * @index: Index of @entry.
+ * @max: Maximum index to retrieve from array.
+ * @filter: Selection criterion.
+ *
+ * Initialise @index to the lowest index you want to retrieve from the
+ * array.  During the iteration, @entry will have the value of the entry
+ * stored in @xa at @index.  The iteration will skip all entries in the
+ * array which do not match @filter.  You may modify @index during the
+ * iteration if you want to skip or reprocess indices.  It is safe to modify
+ * the array during the iteration.  At the end of the iteration, @entry will
+ * be set to NULL and @index will have a value less than or equal to max.
+ *
+ * xa_for_each() is O(n.log(n)) while xas_for_each() is O(n).  You have
+ * to handle your own locking with xas_for_each(), and if you have to unlock
+ * after each iteration, it will also end up being O(n.log(n)).  xa_for_each()
+ * will spin if it hits a retry entry; if you intend to see retry entries,
+ * you should use the xas_for_each() iterator instead.  The xas_for_each()
+ * iterator will expand into more inline code than xa_for_each().
+ *
+ * Context: Any context.  Takes and releases the RCU lock.
+ */
+#define xa_for_each(xa, entry, index, max, filter) \
+	for (entry = xa_find(xa, &index, max, filter); entry; \
+	     entry = xa_find_after(xa, &index, max, filter))
+
 #define xa_trylock(xa)		spin_trylock(&(xa)->xa_lock)
 #define xa_lock(xa)		spin_lock(&(xa)->xa_lock)
 #define xa_unlock(xa)		spin_unlock(&(xa)->xa_lock)
@@ -726,13 +759,16 @@ static inline bool xas_retry(struct xa_state *xas, const void *entry)
 
 void *xas_load(struct xa_state *);
 void *xas_store(struct xa_state *, void *entry);
+void *xas_find(struct xa_state *, unsigned long max);
 
 bool xas_get_tag(const struct xa_state *, xa_tag_t);
 void xas_set_tag(const struct xa_state *, xa_tag_t);
 void xas_clear_tag(const struct xa_state *, xa_tag_t);
+void *xas_find_tagged(struct xa_state *, unsigned long max, xa_tag_t);
 void xas_init_tags(const struct xa_state *);
 
 bool xas_nomem(struct xa_state *, gfp_t);
+void xas_pause(struct xa_state *);
 
 /**
  * xas_reload() - Refetch an entry from the xarray.
@@ -805,6 +841,139 @@ static inline void xas_set_update(struct xa_state *xas, xa_update_node_t update)
 	xas->xa_update = update;
 }
 
+/* Skip over any of these entries when iterating */
+static inline bool xa_iter_skip(const void *entry)
+{
+	return unlikely(!entry ||
+			(xa_is_internal(entry) && entry < XA_RETRY_ENTRY));
+}
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
+	if (unlikely(xas_not_node(node) || node->shift))
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
+/* Private */
+static inline unsigned int xas_find_chunk(struct xa_state *xas, bool advance,
+		xa_tag_t tag)
+{
+	unsigned long *addr = xas->xa_node->tags[(__force unsigned)tag];
+	unsigned int offset = xas->xa_offset;
+
+	if (advance)
+		offset++;
+	if (XA_CHUNK_SIZE == BITS_PER_LONG) {
+		if (offset < XA_CHUNK_SIZE) {
+			unsigned long data = *addr & (~0UL << offset);
+			if (data)
+				return __ffs(data);
+		}
+		return XA_CHUNK_SIZE;
+	}
+
+	return find_next_bit(addr, XA_CHUNK_SIZE, offset);
+}
+
+/**
+ * xas_next_tagged() - Advance iterator to next tagged entry.
+ * @xas: XArray operation state.
+ * @max: Highest index to return.
+ * @tag: Tag to search for.
+ *
+ * xas_next_tagged() is an inline function to optimise xarray traversal for
+ * speed.  It is equivalent to calling xas_find_tagged(), and will call
+ * xas_find_tagged() for all the hard cases.
+ *
+ * Return: The next tagged entry after the one currently referred to by @xas.
+ */
+static inline void *xas_next_tagged(struct xa_state *xas, unsigned long max,
+								xa_tag_t tag)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset;
+
+	if (unlikely(xas_not_node(node) || node->shift))
+		return xas_find_tagged(xas, max, tag);
+	offset = xas_find_chunk(xas, true, tag);
+	xas->xa_offset = offset;
+	xas->xa_index = (xas->xa_index & ~XA_CHUNK_MASK) + offset;
+	if (xas->xa_index > max)
+		return NULL;
+	if (offset == XA_CHUNK_SIZE)
+		return xas_find_tagged(xas, max, tag);
+	return xa_entry(xas->xa, node, offset);
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
+ * xas_for_each() - Iterate over a range of an XArray.
+ * @xas: XArray operation state.
+ * @entry: Entry retrieved from the array.
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
+/**
+ * xas_for_each_tagged() - Iterate over a range of an XArray.
+ * @xas: XArray operation state.
+ * @entry: Entry retrieved from the array.
+ * @max: Maximum index to retrieve from array.
+ * @tag: Tag to search for.
+ *
+ * The loop body will be executed for each tagged entry in the xarray
+ * between the current xas position and @max.  @entry will be set to
+ * the entry retrieved from the xarray.  It is safe to delete entries
+ * from the array in the loop body.  You should hold either the RCU lock
+ * or the xa_lock while iterating.  If you need to drop the lock, call
+ * xas_pause() first.
+ */
+#define xas_for_each_tagged(xas, entry, max, tag) \
+	for (entry = xas_find_tagged(xas, max, tag); entry; \
+	     entry = xas_next_tagged(xas, max, tag))
+
 /* Internal functions, mostly shared between radix-tree.c, xarray.c and idr.c */
 void xas_destroy(struct xa_state *);
 
diff --git a/lib/test_xarray.c b/lib/test_xarray.c
index 35fca5e23cbc..a6a3705165ca 100644
--- a/lib/test_xarray.c
+++ b/lib/test_xarray.c
@@ -73,6 +73,31 @@ static void check_xa_err(struct xarray *xa)
 //	XA_BUG_ON(xa, xa_err(xa_store(xa, 0, xa_mk_internal(0), 0)) != -EINVAL);
 }
 
+static void check_xas_retry(struct xarray *xa)
+{
+	XA_STATE(xas, xa, 0);
+
+	xa_store_value(xa, 0, GFP_KERNEL);
+	xa_store_value(xa, 1, GFP_KERNEL);
+
+	XA_BUG_ON(xa, xas_find(&xas, ULONG_MAX) != xa_mk_value(0));
+	xa_erase_value(xa, 1);
+	XA_BUG_ON(xa, !xa_is_retry(xas_reload(&xas)));
+	XA_BUG_ON(xa, xas_retry(&xas, NULL));
+	XA_BUG_ON(xa, xas_retry(&xas, xa_mk_value(0)));
+	xas_reset(&xas);
+	XA_BUG_ON(xa, xas.xa_node != XAS_RESTART);
+	XA_BUG_ON(xa, xas_next_entry(&xas, ULONG_MAX) != xa_mk_value(0));
+	XA_BUG_ON(xa, xas.xa_node != NULL);
+
+	XA_BUG_ON(xa, xa_store_value(xa, 1, GFP_KERNEL) != NULL);
+	XA_BUG_ON(xa, !xa_is_internal(xas_reload(&xas)));
+	xas.xa_node = XAS_RESTART;
+	XA_BUG_ON(xa, xas_next_entry(&xas, ULONG_MAX) != xa_mk_value(0));
+	xa_erase_value(xa, 0);
+	xa_erase_value(xa, 1);
+}
+
 static void check_xa_load(struct xarray *xa)
 {
 	unsigned long i, j;
@@ -200,6 +225,37 @@ static void check_cmpxchg(struct xarray *xa)
 	XA_BUG_ON(xa, !xa_empty(xa));
 }
 
+static void check_xas_erase(struct xarray *xa)
+{
+	XA_STATE(xas, xa, 0);
+	void *entry;
+	unsigned long i, j;
+
+	for (i = 0; i < 200; i++) {
+		for (j = i; j < 2 * i + 17; j++) {
+			xas_set(&xas, j);
+			do {
+				xas_store(&xas, xa_mk_value(j));
+			} while (xas_nomem(&xas, GFP_KERNEL));
+		}
+
+		xas_set(&xas, ULONG_MAX);
+		do {
+			xas_store(&xas, xa_mk_value(0));
+		} while (xas_nomem(&xas, GFP_KERNEL));
+		xas_store(&xas, NULL);
+
+		xas_set(&xas, 0);
+		j = i;
+		xas_for_each(&xas, entry, ULONG_MAX) {
+			XA_BUG_ON(xa, entry != xa_mk_value(j));
+			xas_store(&xas, NULL);
+			j++;
+		}
+		XA_BUG_ON(xa, !xa_empty(xa));
+	}
+}
+
 static void check_multi_store(struct xarray *xa)
 {
 	unsigned long i, j, k;
@@ -259,16 +315,88 @@ static void check_multi_store(struct xarray *xa)
 	}
 }
 
+static void check_multi_find(struct xarray *xa)
+{
+	unsigned long index;
+
+	xa_store_order(xa, 12, 2, xa_mk_value(12), GFP_KERNEL);
+	XA_BUG_ON(xa, xa_store_value(xa, 16, GFP_KERNEL) != NULL);
+
+	index = 0;
+	XA_BUG_ON(xa, xa_find(xa, &index, ULONG_MAX, XA_PRESENT) !=
+			xa_mk_value(12));
+	XA_BUG_ON(xa, index != 12);
+	index = 13;
+	XA_BUG_ON(xa, xa_find(xa, &index, ULONG_MAX, XA_PRESENT) !=
+			xa_mk_value(12));
+	XA_BUG_ON(xa, (index < 12) || (index >= 16));
+	XA_BUG_ON(xa, xa_find_after(xa, &index, ULONG_MAX, XA_PRESENT) !=
+			xa_mk_value(16));
+	XA_BUG_ON(xa, index != 16);
+
+	xa_erase_value(xa, 12);
+	xa_erase_value(xa, 16);
+	XA_BUG_ON(xa, !xa_empty(xa));
+}
+
+static void check_find(struct xarray *xa)
+{
+	unsigned long i, j, k;
+
+	XA_BUG_ON(xa, !xa_empty(xa));
+
+	for (i = 0; i < 100; i++) {
+		XA_BUG_ON(xa, xa_store_value(xa, i, GFP_KERNEL) != NULL);
+		xa_set_tag(xa, i, XA_TAG_0);
+		for (j = 0; j < i; j++) {
+			XA_BUG_ON(xa, xa_store_value(xa, j, GFP_KERNEL) !=
+					NULL);
+			xa_set_tag(xa, j, XA_TAG_0);
+			for (k = 0; k < 100; k++) {
+				unsigned long index = k;
+				void *entry = xa_find(xa, &index, ULONG_MAX,
+								XA_PRESENT);
+				if (k <= j)
+					XA_BUG_ON(xa, index != j);
+				else if (k <= i)
+					XA_BUG_ON(xa, index != i);
+				else
+					XA_BUG_ON(xa, entry != NULL);
+
+				index = k;
+				entry = xa_find(xa, &index, ULONG_MAX,
+								XA_TAG_0);
+				if (k <= j)
+					XA_BUG_ON(xa, index != j);
+				else if (k <= i)
+					XA_BUG_ON(xa, index != i);
+				else
+					XA_BUG_ON(xa, entry != NULL);
+			}
+			xa_erase_value(xa, j);
+			XA_BUG_ON(xa, xa_get_tag(xa, j, XA_TAG_0));
+			XA_BUG_ON(xa, !xa_get_tag(xa, i, XA_TAG_0));
+		}
+		xa_erase_value(xa, i);
+		XA_BUG_ON(xa, xa_get_tag(xa, i, XA_TAG_0));
+	}
+	XA_BUG_ON(xa, !xa_empty(xa));
+	check_multi_find(xa);
+}
+
 static int xarray_checks(void)
 {
 	DEFINE_XARRAY(array);
 
 	check_xa_err(&array);
+	check_xas_retry(&array);
 	check_xa_load(&array);
 	check_xa_tag(&array);
 	check_xa_shrink(&array);
+	check_xas_erase(&array);
 	check_cmpxchg(&array);
 	check_multi_store(&array);
+	check_find(&array);
 
 	printk("XArray: %u of %u tests passed\n", tests_passed, tests_run);
 	return (tests_run != tests_passed) ? 0 : -EINVAL;
diff --git a/lib/xarray.c b/lib/xarray.c
index 1a3a256cbb37..8756ca22363e 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -103,6 +103,11 @@ static unsigned int get_offset(unsigned long index, struct xa_node *node)
 	return (index >> node->shift) & XA_CHUNK_MASK;
 }
 
+static void xas_set_offset(struct xa_state *xas)
+{
+	xas->xa_offset = get_offset(xas->xa_index, xas->xa_node);
+}
+
 /* move the index either forwards (find) or backwards (sibling slot) */
 static void xas_move_index(struct xa_state *xas, unsigned long offset)
 {
@@ -111,6 +116,12 @@ static void xas_move_index(struct xa_state *xas, unsigned long offset)
 	xas->xa_index += offset << shift;
 }
 
+static void xas_advance(struct xa_state *xas)
+{
+	xas->xa_offset++;
+	xas_move_index(xas, xas->xa_offset);
+}
+
 static void *set_bounds(struct xa_state *xas)
 {
 	xas->xa_node = XAS_BOUNDS;
@@ -816,6 +827,191 @@ void xas_init_tags(const struct xa_state *xas)
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
+ * to be immediately passed to xas_store().
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
+	xas_advance(xas);
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
+		xas_advance(xas);
+	}
+
+	if (!xas->xa_node)
+		xas->xa_node = XAS_BOUNDS;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(xas_find);
+
+/**
+ * xas_find_tagged() - Find the next tagged entry in the XArray.
+ * @xas: XArray operation state.
+ * @max: Highest index to return.
+ * @tag: Tag number to search for.
+ *
+ * If the xas has not yet been walked to an entry, return the tagged entry
+ * which has an index >= xas.xa_index.  If it has been walked, the entry
+ * currently being pointed at has been processed, and so we move to the
+ * next tagged entry.
+ *
+ * If no tagged entry is found and the array is smaller than @max, @xas is
+ * set to the bounds state and xas->xa_index is set to the smallest index
+ * not yet in the array.  This allows @xas to be immediately passed to
+ * xas_store().
+ *
+ * Return: The entry, if found, otherwise %NULL.
+ */
+void *xas_find_tagged(struct xa_state *xas, unsigned long max, xa_tag_t tag)
+{
+	bool advance = true;
+	unsigned int offset;
+	void *entry;
+
+	if (xas_error(xas))
+		return NULL;
+
+	if (!xas->xa_node) {
+		xas->xa_index = 1;
+		goto out;
+	} else if (xas_top(xas->xa_node)) {
+		advance = false;
+		entry = xa_head(xas->xa);
+		if (xas->xa_index > max_index(entry))
+			goto out;
+		if (!xa_is_node(entry)) {
+			if (xa_tagged(xas->xa, tag)) {
+				xas->xa_node = NULL;
+				return entry;
+			}
+			xas->xa_index = 1;
+			goto out;
+		}
+		xas->xa_node = xa_to_node(entry);
+		xas->xa_offset = xas->xa_index >> xas->xa_node->shift;
+	}
+
+	while (xas->xa_index <= max) {
+		if (unlikely(xas->xa_offset == XA_CHUNK_SIZE)) {
+			xas->xa_offset = xas->xa_node->offset + 1;
+			xas->xa_node = xa_parent(xas->xa, xas->xa_node);
+			if (!xas->xa_node)
+				break;
+			advance = false;
+			continue;
+		}
+
+		if (!advance) {
+			entry = xa_entry(xas->xa, xas->xa_node, xas->xa_offset);
+			if (xa_is_sibling(entry)) {
+				xas->xa_offset = xa_to_sibling(entry);
+				xas_move_index(xas, xas->xa_offset);
+			}
+		}
+
+		offset = xas_find_chunk(xas, advance, tag);
+		if (offset > xas->xa_offset) {
+			advance = false;
+			xas_move_index(xas, offset);
+			xas->xa_offset = offset;
+			if (offset == XA_CHUNK_SIZE)
+				continue;
+			if (xas->xa_index > max)
+				break;
+		}
+
+		entry = xa_entry(xas->xa, xas->xa_node, xas->xa_offset);
+		if (!xa_is_node(entry))
+			return entry;
+		xas->xa_node = xa_to_node(entry);
+		xas_set_offset(xas);
+	}
+
+ out:
+	if (!xas->xa_node)
+		xas->xa_node = XAS_BOUNDS;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(xas_find_tagged);
+
 /**
  * xa_init_flags() - Initialise an empty XArray with flags.
  * @xa: XArray.
@@ -1139,6 +1335,84 @@ void xa_clear_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
 }
 EXPORT_SYMBOL(xa_clear_tag);
 
+/**
+ * xa_find() - Search the XArray for an entry.
+ * @xa: XArray.
+ * @indexp: Pointer to an index.
+ * @max: Maximum index to search to.
+ * @filter: Selection criterion.
+ *
+ * Finds the entry in @xa which matches the @filter, and has the lowest
+ * index that is at least @indexp and no more than @max.
+ * If an entry is found, @indexp is updated to be the index of the entry.
+ * This function is protected by the RCU read lock, so it may not find
+ * entries which are being simultaneously added.  It will not return an
+ * %XA_RETRY_ENTRY; if you need to see retry entries, use xas_find().
+ *
+ * Context: Any context.  Takes and releases the RCU lock.
+ * Return: The entry, if found, otherwise NULL.
+ */
+void *xa_find(struct xarray *xa, unsigned long *indexp,
+			unsigned long max, xa_tag_t filter)
+{
+	XA_STATE(xas, xa, *indexp);
+	void *entry;
+
+	rcu_read_lock();
+	do {
+		if ((__force unsigned int)filter < XA_MAX_TAGS)
+			entry = xas_find_tagged(&xas, max, filter);
+		else
+			entry = xas_find(&xas, max);
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
+ * @filter: Selection criterion.
+ *
+ * Finds the entry in @xa which matches the @filter and has the lowest
+ * index that is above @indexp and no more than @max.
+ * If an entry is found, @indexp is updated to be the index of the entry.
+ * This function is protected by the RCU read lock, so it may miss entries
+ * which are being simultaneously added.  It will not return an
+ * %XA_RETRY_ENTRY; if you need to see retry entries, use xas_find().
+ *
+ * Context: Any context.  Takes and releases the RCU lock.
+ * Return: The pointer, if found, otherwise NULL.
+ */
+void *xa_find_after(struct xarray *xa, unsigned long *indexp,
+			unsigned long max, xa_tag_t filter)
+{
+	XA_STATE(xas, xa, *indexp + 1);
+	void *entry;
+
+	rcu_read_lock();
+	do {
+		if ((__force unsigned int)filter < XA_MAX_TAGS)
+			entry = xas_find_tagged(&xas, max, filter);
+		else
+			entry = xas_find(&xas, max);
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
-- 
2.17.1

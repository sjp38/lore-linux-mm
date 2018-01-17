Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE3166B025E
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:24:03 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p89so15092205pfk.5
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:24:03 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o7si4599391pgf.315.2018.01.17.12.22.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:22:32 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 12/99] xarray: Add xa_for_each
Date: Wed, 17 Jan 2018 12:20:36 -0800
Message-Id: <20180117202203.19756-13-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This iterator allows the user to efficiently walk a range of the array,
executing the loop body once for each entry in that range that matches
the filter.  This commit also includes xa_find() and xa_find_above()
which are helper functions for xa_for_each() but may also be useful in
their own right.

In the xas family of functions, we also have xas_for_each(), xas_find(),
xas_next_entry(), xas_for_each_tag(), xas_find_tag(), xas_next_tag()
and xas_pause().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h                 | 171 +++++++++++++++++++++
 lib/xarray.c                           | 272 +++++++++++++++++++++++++++++++++
 tools/testing/radix-tree/test.c        |  13 ++
 tools/testing/radix-tree/test.h        |   1 +
 tools/testing/radix-tree/xarray-test.c | 122 +++++++++++++++
 5 files changed, 579 insertions(+)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index fc9ab3b13e60..fcd7ef68933a 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -215,6 +215,10 @@ void *xa_cmpxchg(struct xarray *, unsigned long index,
 bool xa_get_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
+void *xa_find(struct xarray *xa, unsigned long *index,
+		unsigned long max, xa_tag_t) __attribute__((nonnull(2)));
+void *xa_find_after(struct xarray *xa, unsigned long *index,
+		unsigned long max, xa_tag_t) __attribute__((nonnull(2)));
 
 /**
  * xa_init() - Initialise an empty XArray.
@@ -266,6 +270,33 @@ static inline bool xa_tagged(const struct xarray *xa, xa_tag_t tag)
 	return xa->xa_flags & XA_FLAGS_TAG(tag);
 }
 
+/**
+ * xa_for_each() - Iterate over a portion of an XArray.
+ * @xa: XArray.
+ * @entry: Entry retrieved from array.
+ * @index: Index of @entry.
+ * @max: Maximum index to retrieve from array.
+ * @filter: Selection criterion.
+ *
+ * Initialise @index to the minimum index you want to retrieve from
+ * the array.  During the iteration, @entry will have the value of the
+ * entry stored in @xa at @index.  The iteration will skip all entries in
+ * the array which do not match @filter.  You may modify @index during the
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
+ */
+#define xa_for_each(xa, entry, index, max, filter) \
+	for (entry = xa_find(xa, &index, max, filter); entry; \
+	     entry = xa_find_after(xa, &index, max, filter))
+
 /**
  * xa_insert() - Store this entry in the XArray unless another entry is
  *			already present.
@@ -620,6 +651,12 @@ static inline bool xas_valid(const struct xa_state *xas)
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
@@ -648,13 +685,16 @@ static inline bool xas_retry(struct xa_state *xas, const void *entry)
 void *xas_load(struct xa_state *);
 void *xas_store(struct xa_state *, void *entry);
 void *xas_create(struct xa_state *);
+void *xas_find(struct xa_state *, unsigned long max);
 
 bool xas_get_tag(const struct xa_state *, xa_tag_t);
 void xas_set_tag(const struct xa_state *, xa_tag_t);
 void xas_clear_tag(const struct xa_state *, xa_tag_t);
+void *xas_find_tag(struct xa_state *, unsigned long max, xa_tag_t);
 void xas_init_tags(const struct xa_state *);
 
 bool xas_nomem(struct xa_state *, gfp_t);
+void xas_pause(struct xa_state *);
 
 /**
  * xas_reload() - Refetch an entry from the xarray.
@@ -727,6 +767,137 @@ static inline void xas_set_update(struct xa_state *xas, xa_update_node_t update)
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
+		unsigned long data = *addr & (~0UL << offset);
+		if (data)
+			return __ffs(data);
+		return XA_CHUNK_SIZE;
+	}
+
+	return find_next_bit(addr, XA_CHUNK_SIZE, offset);
+}
+
+/**
+ * xas_next_tag() - Advance iterator to next tagged entry.
+ * @xas: XArray operation state.
+ * @max: Highest index to return.
+ * @tag: Tag to search for.
+ *
+ * xas_next_tag() is an inline function to optimise xarray traversal for
+ * speed.  It is equivalent to calling xas_find_tag(), and will call
+ * xas_find_tag() for all the hard cases.
+ *
+ * Return: The next tagged entry after the one currently referred to by @xas.
+ */
+static inline void *xas_next_tag(struct xa_state *xas, unsigned long max,
+								xa_tag_t tag)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset;
+
+	if (unlikely(xas_not_node(node) || node->shift))
+		return xas_find_tag(xas, max, tag);
+	offset = xas_find_chunk(xas, true, tag);
+	xas->xa_offset = offset;
+	xas->xa_index = (xas->xa_index & ~XA_CHUNK_MASK) + offset;
+	if (xas->xa_index > max)
+		return NULL;
+	if (offset == XA_CHUNK_SIZE)
+		return xas_find_tag(xas, max, tag);
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
+/**
+ * xas_for_each_tag() - Iterate over a range of an XArray
+ * @xas: XArray operation state.
+ * @entry: Entry retrieved from array.
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
+#define xas_for_each_tag(xas, entry, max, tag) \
+	for (entry = xas_find_tag(xas, max, tag); entry; \
+	     entry = xas_next_tag(xas, max, tag))
+
 /* Internal functions, mostly shared between radix-tree.c, xarray.c and idr.c */
 void xas_destroy(struct xa_state *);
 
diff --git a/lib/xarray.c b/lib/xarray.c
index d925a98fb9b8..3e6be0a07525 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -91,6 +91,11 @@ static unsigned int get_offset(unsigned long index, struct xa_node *node)
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
@@ -99,6 +104,12 @@ static void xas_move_index(struct xa_state *xas, unsigned long offset)
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
@@ -791,6 +802,191 @@ void xas_init_tags(const struct xa_state *xas)
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
+ * xas_find_tag() - Find the next tagged entry in the XArray.
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
+ * xas_create().
+ *
+ * Return: The entry, if found, otherwise %NULL.
+ */
+void *xas_find_tag(struct xa_state *xas, unsigned long max, xa_tag_t tag)
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
+EXPORT_SYMBOL_GPL(xas_find_tag);
+
 /**
  * xa_init_flags() - Initialise an empty XArray with flags.
  * @xa: XArray.
@@ -1096,6 +1292,82 @@ void xa_clear_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
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
+			entry = xas_find_tag(&xas, max, filter);
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
+			entry = xas_find_tag(&xas, max, filter);
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
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index f151588d04a0..e9b4a4ed9bf5 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -244,6 +244,19 @@ unsigned long find_item(struct radix_tree_root *root, void *item)
 	return found;
 }
 
+static LIST_HEAD(item_nodes);
+
+void item_update_node(struct xa_node *node)
+{
+	if (node->count) {
+		if (list_empty(&node->private_list))
+			list_add(&node->private_list, &item_nodes);
+	} else {
+		if (!list_empty(&node->private_list))
+			list_del_init(&node->private_list);
+        }
+}
+
 static int verify_node(struct radix_tree_node *slot, unsigned int tag,
 			int tagged)
 {
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index ffd162645c11..f97cacd1422d 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -30,6 +30,7 @@ void item_gang_check_present(struct radix_tree_root *root,
 void item_full_scan(struct radix_tree_root *root, unsigned long start,
 			unsigned long nr, int chunk);
 void item_kill_tree(struct radix_tree_root *root);
+void item_update_node(struct xa_node *node);
 
 int tag_tagged_items(struct radix_tree_root *, pthread_mutex_t *,
 			unsigned long start, unsigned long end, unsigned batch,
diff --git a/tools/testing/radix-tree/xarray-test.c b/tools/testing/radix-tree/xarray-test.c
index d6a969d999d9..26b25be81656 100644
--- a/tools/testing/radix-tree/xarray-test.c
+++ b/tools/testing/radix-tree/xarray-test.c
@@ -49,6 +49,29 @@ void check_xa_tag(struct xarray *xa)
 	assert(xa_get_tag(xa, 0, XA_TAG_0) == false);
 }
 
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
@@ -142,6 +165,98 @@ void check_multi_store(struct xarray *xa)
 	}
 }
 
+void check_multi_find(struct xarray *xa)
+{
+	unsigned long index;
+	xa_store_order(xa, 12, 2, xa_mk_value(12), GFP_KERNEL);
+	xa_store(xa, 16, xa_mk_value(16), GFP_KERNEL);
+
+	index = 0;
+	assert(xa_find(xa, &index, ULONG_MAX, XA_PRESENT) == xa_mk_value(12));
+	assert(index == 12);
+	index = 13;
+	assert(xa_find(xa, &index, ULONG_MAX, XA_PRESENT) == xa_mk_value(12));
+	assert(index >= 12 && index < 16);
+	assert(xa_find_after(xa, &index, ULONG_MAX, XA_PRESENT) == xa_mk_value(16));
+	assert(index == 16);
+	xa_erase(xa, 12);
+	xa_erase(xa, 16);
+	assert(xa_empty(xa));
+}
+
+void check_find(struct xarray *xa)
+{
+	unsigned long i, j, k;
+
+	assert(xa_empty(xa));
+
+	for (i = 0; i < 100; i++) {
+		xa_store(xa, i, xa_mk_value(i), GFP_KERNEL);
+		xa_set_tag(xa, i, XA_TAG_0);
+		for (j = 0; j < i; j++) {
+			xa_store(xa, j, xa_mk_value(j), GFP_KERNEL);
+			xa_set_tag(xa, j, XA_TAG_0);
+			for (k = 0; k < 100; k++) {
+				unsigned long index = k;
+				void *entry = xa_find(xa, &index, ULONG_MAX,
+								XA_PRESENT);
+				if (k <= j)
+					assert(index == j);
+				else if (k <= i)
+					assert(index == i);
+				else
+					assert(entry == NULL);
+
+				index = k;
+				entry = xa_find(xa, &index, ULONG_MAX,
+								XA_TAG_0);
+				if (k <= j)
+					assert(index == j);
+				else if (k <= i)
+					assert(index == i);
+				else
+					assert(entry == NULL);
+			}
+			xa_erase(xa, j);
+		}
+		xa_erase(xa, i);
+	}
+	assert(xa_empty(xa));
+	check_multi_find(xa);
+}
+
+void check_xas_delete(struct xarray *xa)
+{
+	XA_STATE(xas, xa, 0);
+	void *entry;
+	unsigned long i, j;
+
+	xas_set_update(&xas, item_update_node);
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
+			assert(entry == xa_mk_value(j));
+			xas_store(&xas, NULL);
+			j++;
+		}
+		assert(xa_empty(xa));
+	}
+}
+
 void xarray_checks(void)
 {
 	DEFINE_XARRAY(array);
@@ -152,6 +267,9 @@ void xarray_checks(void)
 	check_xa_tag(&array);
 	item_kill_tree(&array);
 
+	check_xas_retry(&array);
+	item_kill_tree(&array);
+
 	check_xa_load(&array);
 	item_kill_tree(&array);
 
@@ -161,6 +279,10 @@ void xarray_checks(void)
 	check_cmpxchg(&array);
 	check_multi_store(&array);
 	item_kill_tree(&array);
+
+	check_find(&array);
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

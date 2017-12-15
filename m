Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 913F96B029C
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:06:09 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id k186so16508386ith.1
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:06:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w16si5934681ita.32.2017.12.15.14.06.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:06:07 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 12/78] xarray: Add xa_store
Date: Fri, 15 Dec 2017 14:03:44 -0800
Message-Id: <20171215220450.7899-13-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

xa_store() differs from radix_tree_insert() in that it will overwrite an
existing element in the array rather than returning an error.  This is
the behaviour which most users want, and those that want more complex
behaviour generally want to use the xas family of routines anyway.

For memory allocation, xa_store() will first attempt to request memory
from the slab allocator; if memory is not immediately available, it will
drop the xa_lock and allocate memory, keeping a pointer in the xa_state.
It does not use the per-CPU cache, although those will continue to exist
until all radix tree users are converted to the xarray.

This patch also includes xa_erase() and __xa_erase() for a streamlined
way to store NULL.  Since there is no need to allocate memory in order
to store a NULL in the XArray, we do not need to trouble the user with
deciding what memory allocation flags to use.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h                    | 124 +++++-
 lib/radix-tree.c                          |   4 +-
 lib/xarray.c                              | 643 ++++++++++++++++++++++++++++++
 tools/include/linux/spinlock.h            |   6 +
 tools/testing/radix-tree/linux/kernel.h   |   4 +
 tools/testing/radix-tree/linux/rcupdate.h |   1 +
 tools/testing/radix-tree/xarray-test.c    | 127 +++++-
 7 files changed, 904 insertions(+), 5 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 16d896861e33..05873095bc7f 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -74,6 +74,34 @@ static inline void xa_init(struct xarray *xa)
 }
 
 void *xa_load(struct xarray *, unsigned long index);
+void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
+
+/**
+ * xa_erase() - Erase this entry from the XArray.
+ * @xa: XArray.
+ * @index: Index of entry.
+ *
+ * This function is the equivalent of calling xa_store() with %NULL as
+ * the third argument.  The XArray does not need to allocate memory, so
+ * the user does not need to provide GFP flags.
+ *
+ * Return: The entry which used to be at this index.
+ */
+static inline void *xa_erase(struct xarray *xa, unsigned long index)
+{
+	return xa_store(xa, index, NULL, 0);
+}
+
+/**
+ * xa_empty() - Determine if an array has any present entries.
+ * @xa: XArray.
+ *
+ * Return: %true if the array contains only NULL pointers.
+ */
+static inline bool xa_empty(const struct xarray *xa)
+{
+	return xa->xa_head == NULL;
+}
 
 typedef unsigned __bitwise xa_tag_t;
 #define XA_TAG_0		((__force xa_tag_t)0U)
@@ -83,9 +111,15 @@ typedef unsigned __bitwise xa_tag_t;
 
 #define XA_TAG_MAX		XA_TAG_2
 #define XA_FREE_TAG		XA_TAG_0
+#define XA_FLAGS_TRACK_FREE	((__force gfp_t)(1U << __GFP_BITS_SHIFT))
 #define XA_FLAGS_TAG(tag)	((__force gfp_t)((2U << __GFP_BITS_SHIFT) << \
 				(__force unsigned)(tag)))
 
+static inline bool xa_track_free(const struct xarray *xa)
+{
+	return xa->xa_flags & XA_FLAGS_TRACK_FREE;
+}
+
 /**
  * xa_tagged() - Inquire whether any entry in this array has a tag set
  * @xa: Array
@@ -194,7 +228,23 @@ static inline int xa_err(void *entry)
 #define xa_unlock_irqrestore(xa, flags) \
 				spin_unlock_irqrestore(&(xa)->xa_lock, flags)
 
-/* Versions of the normal API which require the caller to hold the xa_lock */
+enum xa_ctx {
+	XA_CTX_PRC,
+	XA_CTX_BH,
+	XA_CTX_IRQ,
+};
+
+/*
+ * Versions of the normal API which require the caller to hold the xa_lock.
+ * If the GFP flags allow it, will drop the lock in order to allocate
+ * memory, then reacquire it afterwards.
+ */
+void *__xa_erase(struct xarray *, unsigned long index);
+void *___xa_store(struct xarray *, unsigned long index,
+		void *entry, gfp_t, enum xa_ctx);
+#define __xa_store(x, i, e, g)		___xa_store(x, i, e, g, XA_CTX_PRC)
+#define __xa_store_bh(x, i, e, g)	___xa_store(x, i, e, g, XA_CTX_BH)
+#define __xa_store_irq(x, i, e, g)	___xa_store(x, i, e, g, XA_CTX_IRQ)
 void __xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
 void __xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
 
@@ -290,6 +340,10 @@ static inline void *xa_entry_locked(struct xarray *xa,
  * kernel unmaps page 0 to trap NULL pointer dereferences, we can use values
  * 0-1023 for special purposes.  Values 0-62 are used for sibling
  * entries.  Value 256 is used for the retry entry.
+ *
+ * Errors are also represented as internal entries, but use the negative
+ * space (-4094 to -2).  They're never stored in the slots array; only
+ * generated by the normal API.
  */
 
 /* Private */
@@ -304,6 +358,12 @@ static inline unsigned long xa_to_internal(const void *entry)
 	return (unsigned long)entry >> 2;
 }
 
+/* Private */
+static inline void *xa_mk_node(const struct xa_node *node)
+{
+	return (void *)((unsigned long)node | 2);
+}
+
 /* Private */
 static inline struct xa_node *xa_to_node(const void *entry)
 {
@@ -484,6 +544,12 @@ static inline bool xas_valid(const struct xa_state *xas)
 	return !xas_invalid(xas);
 }
 
+/* True if the node represents head-of-tree, RESTART or BOUNDS */
+static inline bool xas_top(struct xa_node *node)
+{
+	return node <= XAS_RESTART;
+}
+
 /**
  * xas_retry() - Handle a retry entry.
  * @xas: XArray operation state.
@@ -504,10 +570,15 @@ static inline bool xas_retry(struct xa_state *xas, const void *entry)
 }
 
 void *xas_load(struct xa_state *);
+void *xas_store(struct xa_state *, void *entry);
+void *xas_create(struct xa_state *);
 
 bool xas_get_tag(const struct xa_state *, xa_tag_t);
 void xas_set_tag(const struct xa_state *, xa_tag_t);
 void xas_clear_tag(const struct xa_state *, xa_tag_t);
+void xas_init_tags(const struct xa_state *);
+
+bool xas_nomem(struct xa_state *, gfp_t);
 
 /**
  * xas_reload() - Refetch an entry from the xarray.
@@ -532,4 +603,55 @@ static inline void *xas_reload(struct xa_state *xas)
 	return xa_head(xas->xa);
 }
 
+/**
+ * xas_set() - Set up XArray operation state for a different index.
+ * @xas: XArray operation state.
+ * @index: New index into the XArray.
+ *
+ * Move the operation state to refer to a different index.  This will
+ * have the effect of starting a walk from the top; see xas_next()
+ * to move to an adjacent index.
+ */
+static inline void xas_set(struct xa_state *xas, unsigned long index)
+{
+	xas->xa_index = index;
+	xas->xa_node = XAS_RESTART;
+}
+
+/**
+ * xas_set_order() - Set up XArray operation state for a multislot entry.
+ * @xas: XArray operation state.
+ * @index: Target of the operation.
+ * @order: Entry occupies 2^@order indices.
+ */
+static inline void xas_set_order(struct xa_state *xas, unsigned long index,
+					unsigned int order)
+{
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	xas->xa_index = (index >> order) << order;
+	xas->xa_shift = order - (order % XA_CHUNK_SHIFT);
+	xas->xa_sibs = (1 << (order % XA_CHUNK_SHIFT)) - 1;
+	xas->xa_node = XAS_RESTART;
+#else
+	BUG_ON(order > 0);
+	xas_set(xas, index);
+#endif
+}
+
+/**
+ * xas_set_update() - Set up XArray operation state for a callback.
+ * @xas: XArray operation state.
+ * @update: Function to call when updating a node.
+ *
+ * The XArray can notify a caller after it has updated an xa_node.
+ * This is advanced functionality and is only needed by the page cache.
+ */
+static inline void xas_set_update(struct xa_state *xas, xa_update_node_t update)
+{
+	xas->xa_update = update;
+}
+
+/* Internal functions, mostly shared between radix-tree.c, xarray.c and idr.c */
+void xas_destroy(struct xa_state *);
+
 #endif /* _LINUX_XARRAY_H */
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index d9e93b828ed0..cf95247a9e1b 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -46,7 +46,7 @@ static unsigned long height_to_maxnodes[RADIX_TREE_MAX_PATH + 1] __read_mostly;
 /*
  * Radix tree node cache.
  */
-static struct kmem_cache *radix_tree_node_cachep;
+struct kmem_cache *radix_tree_node_cachep;
 
 /*
  * The radix tree is variable-height, so an insert operation not only has
@@ -364,7 +364,7 @@ radix_tree_node_alloc(gfp_t gfp_mask, struct radix_tree_node *parent,
 	return ret;
 }
 
-static void radix_tree_node_rcu_free(struct rcu_head *head)
+void radix_tree_node_rcu_free(struct rcu_head *head)
 {
 	struct radix_tree_node *node =
 			container_of(head, struct radix_tree_node, rcu_head);
diff --git a/lib/xarray.c b/lib/xarray.c
index f380e92e7d17..64f88ce23392 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -7,6 +7,8 @@
 
 #include <linux/bitmap.h>
 #include <linux/export.h>
+#include <linux/list.h>
+#include <linux/slab.h>
 #include <linux/xarray.h>
 
 /*
@@ -69,11 +71,20 @@ static inline void tag_clear(struct xa_node *node, unsigned int offset,
 	__clear_bit(offset, node->tags[(__force unsigned)tag]);
 }
 
+static inline void tag_set_all(struct xa_node *node, xa_tag_t tag)
+{
+	bitmap_fill(node->tags[(__force unsigned)tag], XA_CHUNK_SIZE);
+}
+
 static inline bool tag_any_set(struct xa_node *node, xa_tag_t tag)
 {
 	return !bitmap_empty(node->tags[(__force unsigned)tag], XA_CHUNK_SIZE);
 }
 
+#define tag_inc(tag) do { \
+	tag = (__force xa_tag_t)((__force unsigned)(tag) + 1); \
+} while (0)
+
 /* extracts the offset within this node from the index */
 static unsigned int get_offset(unsigned long index, struct xa_node *node)
 {
@@ -162,6 +173,522 @@ void *xas_load(struct xa_state *xas)
 }
 EXPORT_SYMBOL_GPL(xas_load);
 
+/* Move the radix tree node cache here */
+extern struct kmem_cache *radix_tree_node_cachep;
+extern void radix_tree_node_rcu_free(struct rcu_head *head);
+
+static void xa_node_free(struct xa_node *node)
+{
+	XA_BUG_ON(node, !list_empty(&node->private_list));
+	call_rcu(&node->rcu_head, radix_tree_node_rcu_free);
+}
+
+/*
+ * xas_destroy() - Free any resources allocated during the XArray operation.
+ * @xas: XArray operation state.
+ *
+ * This function is now internal-only (and will be made static once
+ * idr_preload() is removed).
+ */
+void xas_destroy(struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_alloc;
+
+	if (!node)
+		return;
+	XA_BUG_ON(node, !list_empty(&node->private_list));
+	kmem_cache_free(radix_tree_node_cachep, node);
+	xas->xa_alloc = NULL;
+}
+
+/**
+ * xas_nomem() - Allocate memory if needed.
+ * @xas: XArray operation state.
+ * @gfp: Memory allocation flags.
+ *
+ * If we need to add new nodes to the XArray, we try to allocate memory
+ * with GFP_NOWAIT while holding the lock, which will usually succeed.
+ * If it fails, @xas is flagged as needing memory to continue.  The caller
+ * should drop the lock and call xas_nomem().  If xas_nomem() succeeds,
+ * the caller should retry the operation.
+ *
+ * Forward progress is guaranteed as one node is allocated here and
+ * stored in the xa_state where it will be found by xas_alloc().  More
+ * nodes will likely be found in the slab allocator, but we do not tie
+ * them up here.
+ *
+ * Return: true if memory was needed, and was successfully allocated.
+ */
+bool xas_nomem(struct xa_state *xas, gfp_t gfp)
+{
+	if (xas->xa_node != XA_ERROR(-ENOMEM)) {
+		xas_destroy(xas);
+		return false;
+	}
+	xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
+	if (!xas->xa_alloc)
+		return false;
+	XA_BUG_ON(xas->xa_alloc, !list_empty(&xas->xa_alloc->private_list));
+	xas->xa_node = XAS_RESTART;
+	return true;
+}
+EXPORT_SYMBOL_GPL(xas_nomem);
+
+/*
+ * __xas_nomem() - Drop locks and allocate memory if needed.
+ * @xas: XArray operation state.
+ * @gfp: Memory allocation flags.
+ *
+ * Internal variant of xas_nomem().
+ *
+ * Return: true if memory was needed, and was successfully allocated.
+ */
+static bool __xas_nomem(struct xa_state *xas, gfp_t gfp, enum xa_ctx ctx)
+	__must_hold(xas->xa->xa_lock)
+{
+	if (xas->xa_node != XA_ERROR(-ENOMEM)) {
+		xas_destroy(xas);
+		return false;
+	}
+	if (gfpflags_allow_blocking(gfp)) {
+		if (ctx == XA_CTX_IRQ)
+			xas_unlock_irq(xas);
+		else if (ctx == XA_CTX_BH)
+			xas_unlock_bh(xas);
+		else
+			xas_unlock(xas);
+		xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
+		if (ctx == XA_CTX_IRQ)
+			xas_lock_irq(xas);
+		else if (ctx == XA_CTX_BH)
+			xas_lock_bh(xas);
+		else
+			xas_lock(xas);
+	} else {
+		xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
+	}
+	if (!xas->xa_alloc)
+		return false;
+	XA_BUG_ON(xas->xa_alloc, !list_empty(&xas->xa_alloc->private_list));
+	xas->xa_node = XAS_RESTART;
+	return true;
+}
+
+static void *xas_alloc(struct xa_state *xas, unsigned int shift)
+{
+	struct xa_node *parent = xas->xa_node;
+	struct xa_node *node = xas->xa_alloc;
+
+	if (xas_invalid(xas))
+		return NULL;
+
+	if (node) {
+		xas->xa_alloc = NULL;
+	} else {
+		node = kmem_cache_alloc(radix_tree_node_cachep,
+					GFP_NOWAIT | __GFP_NOWARN);
+		if (!node) {
+			xas_set_err(xas, -ENOMEM);
+			return NULL;
+		}
+	}
+
+	if (parent) {
+		node->offset = xas->xa_offset;
+		parent->count++;
+		XA_BUG_ON(node, parent->count > XA_CHUNK_SIZE);
+	}
+	XA_BUG_ON(node, shift > BITS_PER_LONG);
+	XA_BUG_ON(node, !list_empty(&node->private_list));
+	node->shift = shift;
+	node->count = 0;
+	node->nr_values = 0;
+	RCU_INIT_POINTER(node->parent, xas->xa_node);
+	node->array = xas->xa;
+
+	return node;
+}
+
+/*
+ * Use this to calculate the maximum index that will need to be created
+ * in order to add the entry described by @xas.  Because we cannot store a
+ * multiple-index entry at index 0, the calculation is a little more complex
+ * than you might expect.
+ */
+static unsigned long xas_max(struct xa_state *xas)
+{
+	unsigned long mask, max = xas->xa_index;
+
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	if (xas->xa_shift || xas->xa_sibs) {
+		mask = (((xas->xa_sibs + 1UL) << xas->xa_shift) - 1);
+		max |= mask;
+		if (mask == max)
+			max++;
+	}
+#endif
+
+	return max;
+}
+
+/* The maximum index that can be contained in the array without expanding it */
+static unsigned long max_index(void *entry)
+{
+	if (!xa_is_node(entry))
+		return 0;
+	return (XA_CHUNK_SIZE << xa_to_node(entry)->shift) - 1;
+}
+
+static void xas_shrink(struct xa_state *xas)
+{
+	struct xarray *xa = xas->xa;
+	struct xa_node *node = xas->xa_node;
+
+	for (;;) {
+		void *entry;
+
+		XA_BUG_ON(node, node->count > XA_CHUNK_SIZE);
+		if (node->count != 1)
+			break;
+		entry = xa_entry_locked(xa, node, 0);
+		if (!entry)
+			break;
+		if (!xa_is_node(entry) && node->shift)
+			break;
+		xas->xa_node = XAS_BOUNDS;
+
+		RCU_INIT_POINTER(xa->xa_head, entry);
+		if (xa_track_free(xa) && !tag_get(node, 0, XA_FREE_TAG))
+			xa_tag_clear(xa, XA_FREE_TAG);
+
+		node->count = 0;
+		node->nr_values = 0;
+		if (!xa_is_node(entry))
+			RCU_INIT_POINTER(node->slots[0], XA_RETRY_ENTRY);
+		XA_BUG_ON(node, !list_empty(&node->private_list));
+		xa_node_free(node);
+		if (!xa_is_node(entry))
+			break;
+		node = xa_to_node(entry);
+		if (xas->xa_update)
+			xas->xa_update(node);
+		else
+			XA_BUG_ON(node, !list_empty(&node->private_list));
+	}
+}
+
+/*
+ * xas_delete_node() - Attempt to delete an xa_node
+ * @xas: Array operation state.
+ *
+ * Attempts to delete the @xas->xa_node.  This will fail if xa->node has
+ * a non-zero reference count.
+ */
+static void xas_delete_node(struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_node;
+
+	for (;;) {
+		struct xa_node *parent;
+
+		XA_BUG_ON(node, node->count > XA_CHUNK_SIZE);
+		if (node->count)
+			break;
+
+		parent = xa_parent_locked(xas->xa, node);
+		xas->xa_node = parent;
+		xas->xa_offset = node->offset;
+		XA_BUG_ON(node, !list_empty(&node->private_list));
+		xa_node_free(node);
+
+		if (!parent) {
+			xas->xa->xa_head = NULL;
+			xas->xa_node = XAS_BOUNDS;
+			return;
+		}
+
+		parent->slots[xas->xa_offset] = NULL;
+		parent->count--;
+		XA_BUG_ON(parent, parent->count > XA_CHUNK_SIZE);
+		node = parent;
+		if (xas->xa_update)
+			xas->xa_update(node);
+		else
+			XA_BUG_ON(node, !list_empty(&node->private_list));
+	}
+
+	if (!node->parent)
+		xas_shrink(xas);
+}
+
+/**
+ * xas_free_nodes() - Free this node and all nodes that it references
+ * @xas: Array operation state.
+ * @top: Node to free
+ *
+ * This node has been removed from the tree.  We must now free it and all
+ * of its subnodes.  There may be RCU walkers with references into the tree,
+ * so we must replace all entries with retry markers.
+ */
+static void xas_free_nodes(struct xa_state *xas, struct xa_node *top)
+{
+	unsigned int offset = 0;
+	struct xa_node *node = top;
+
+	for (;;) {
+		void *entry = xa_entry_locked(xas->xa, node, offset);
+
+		if (xa_is_node(entry)) {
+			node = xa_to_node(entry);
+			offset = 0;
+			continue;
+		}
+		if (entry)
+			RCU_INIT_POINTER(node->slots[offset], XA_RETRY_ENTRY);
+		offset++;
+		while (offset == XA_CHUNK_SIZE) {
+			struct xa_node *parent = xa_parent_locked(xas->xa, node);
+
+			offset = node->offset + 1;
+			node->count = 0;
+			node->nr_values = 0;
+			if (xas->xa_update)
+				xas->xa_update(node);
+			XA_BUG_ON(node, !list_empty(&node->private_list));
+			xa_node_free(node);
+			if (node == top)
+				return;
+			node = parent;
+		}
+	}
+}
+
+/*
+ * xas_expand adds nodes to the head of the tree until it has reached
+ * sufficient height to be able to contain @xas->xa_index
+ */
+static int xas_expand(struct xa_state *xas, void *head)
+{
+	struct xarray *xa = xas->xa;
+	struct xa_node *node = NULL;
+	unsigned int shift = 0;
+	unsigned long max = xas_max(xas);
+
+	if (!head) {
+		if (max == 0)
+			return 0;
+		while ((max >> shift) >= XA_CHUNK_SIZE)
+			shift += XA_CHUNK_SHIFT;
+		return shift + XA_CHUNK_SHIFT;
+	} else if (xa_is_node(head)) {
+		node = xa_to_node(head);
+		shift = node->shift + XA_CHUNK_SHIFT;
+	}
+	xas->xa_node = NULL;
+
+	while (max > max_index(head)) {
+		xa_tag_t tag = 0;
+
+		XA_BUG_ON(node, shift > BITS_PER_LONG);
+		node = xas_alloc(xas, shift);
+		if (!node)
+			return -ENOMEM;
+
+		node->count = 1;
+		if (xa_is_value(head))
+			node->nr_values = 1;
+		RCU_INIT_POINTER(node->slots[0], head);
+
+		/* Propagate the aggregated tag info to the new child */
+		if (xa_track_free(xa)) {
+			tag_set_all(node, XA_FREE_TAG);
+			if (!xa_tagged(xa, XA_FREE_TAG)) {
+				tag_clear(node, 0, XA_FREE_TAG);
+				xa_tag_set(xa, XA_FREE_TAG);
+			}
+			tag_inc(tag);
+		}
+		for (;;) {
+			if (xa_tagged(xa, tag))
+				tag_set(node, 0, tag);
+			if (tag == XA_TAG_MAX)
+				break;
+			tag_inc(tag);
+		}
+
+		/*
+		 * Now that the new node is fully initialised, we can add
+		 * it to the tree
+		 */
+		if (xa_is_node(head)) {
+			xa_to_node(head)->offset = 0;
+			rcu_assign_pointer(xa_to_node(head)->parent, node);
+		}
+		head = xa_mk_node(node);
+		rcu_assign_pointer(xa->xa_head, head);
+
+		shift += XA_CHUNK_SHIFT;
+	}
+
+	xas->xa_node = node;
+	return shift;
+}
+
+/**
+ * xas_create() - Create a slot to store an entry in.
+ * @xas: XArray operation state.
+ *
+ * Most users will not need to call this function directly, as it is called
+ * by xas_store().  It is useful for doing conditional store operations
+ * (see the xa_cmpxchg() implementation for an example).
+ *
+ * Return: If the slot already existed, returns the contents of this slot.
+ * If the slot was newly created, returns NULL.  If it failed to create the
+ * slot, returns NULL and indicates the error in @xas.
+ */
+void *xas_create(struct xa_state *xas)
+{
+	struct xarray *xa = xas->xa;
+	void *entry;
+	void __rcu **slot;
+	struct xa_node *node = xas->xa_node;
+	int shift;
+	unsigned int order = xas->xa_shift;
+
+	if (xas_top(node)) {
+		entry = xa_head_locked(xa);
+		xas->xa_node = NULL;
+		shift = xas_expand(xas, entry);
+		if (shift < 0)
+			return NULL;
+		entry = xa_head_locked(xa);
+		slot = &xa->xa_head;
+	} else if (xas_error(xas)) {
+		return NULL;
+	} else if (node) {
+		unsigned int offset = xas->xa_offset;
+
+		shift = node->shift;
+		entry = xa_entry_locked(xa, node, offset);
+		slot = &node->slots[offset];
+	} else {
+		shift = 0;
+		entry = xa_head_locked(xa);
+		slot = &xa->xa_head;
+	}
+
+	while (shift > order) {
+		shift -= XA_CHUNK_SHIFT;
+		if (!entry) {
+			node = xas_alloc(xas, shift);
+			if (!node)
+				break;
+			if (xa_track_free(xa))
+				tag_set_all(node, XA_FREE_TAG);
+			rcu_assign_pointer(*slot, xa_mk_node(node));
+		} else if (xa_is_node(entry)) {
+			node = xa_to_node(entry);
+		} else {
+			break;
+		}
+		entry = xas_descend(xas, node);
+		slot = &node->slots[xas->xa_offset];
+	}
+
+	return entry;
+}
+EXPORT_SYMBOL_GPL(xas_create);
+
+static void store_siblings(struct xa_state *xas,
+				void *entry, int *countp, int *valuesp)
+{
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	struct xa_node *node = xas->xa_node;
+	unsigned int sibs, offset = xas->xa_offset;
+	void *sibling = entry ? xa_mk_sibling(offset) : NULL;
+	void *real = entry;
+
+	if (!entry)
+		sibs = XA_CHUNK_MASK - offset;
+	else if (xas->xa_shift < node->shift)
+		sibs = 0;
+	else
+		sibs = xas->xa_sibs;
+
+	while (sibs--) {
+		void *next = xa_entry(xas->xa, node, ++offset);
+
+		if (!xa_is_sibling(next)) {
+			if (!entry)
+				break;
+			real = next;
+		}
+		RCU_INIT_POINTER(node->slots[offset], sibling);
+		if (xa_is_node(next))
+			xas_free_nodes(xas, xa_to_node(next));
+		*countp += !next - !entry;
+		*valuesp += !xa_is_value(real) - !xa_is_value(entry);
+	}
+#endif
+}
+
+/**
+ * xas_store() - Store this entry in the XArray.
+ * @xas: XArray operation state.
+ * @entry: New entry.
+ *
+ * Return: The old entry at this index.
+ */
+void *xas_store(struct xa_state *xas, void *entry)
+{
+	struct xa_node *node;
+	int count, values;
+	void *curr;
+
+	if (entry)
+		curr = xas_create(xas);
+	else
+		curr = xas_load(xas);
+	if (xas_invalid(xas))
+		return curr;
+	if ((curr == entry) && !xas->xa_sibs)
+		return curr;
+
+	node = xas->xa_node;
+	if (!entry)
+		xas_init_tags(xas);
+	/*
+	 * Must clear the tags before setting the entry to NULL otherwise
+	 * xas_for_each_tag may find a NULL entry and stop early.
+	 */
+	if (node)
+		rcu_assign_pointer(node->slots[xas->xa_offset], entry);
+	else
+		rcu_assign_pointer(xas->xa->xa_head, entry);
+
+	values = !xa_is_value(curr) - !xa_is_value(entry);
+	count = !curr - !entry;
+	if (xa_is_node(curr))
+		xas_free_nodes(xas, xa_to_node(curr));
+
+	if (node) {
+		store_siblings(xas, entry, &count, &values);
+		node->count += count;
+		XA_BUG_ON(node, node->count > XA_CHUNK_SIZE);
+		node->nr_values += values;
+		XA_BUG_ON(node, node->nr_values > XA_CHUNK_SIZE);
+		if ((count || values) && xas->xa_update)
+			xas->xa_update(node);
+		else
+			XA_BUG_ON(node, !list_empty(&node->private_list));
+		if (count < 0)
+			xas_delete_node(xas);
+	}
+
+	return curr;
+}
+EXPORT_SYMBOL_GPL(xas_store);
+
 /**
  * xas_get_tag() - Returns the state of this tag.
  * @xas: XArray operation state.
@@ -241,6 +768,34 @@ void xas_clear_tag(const struct xa_state *xas, xa_tag_t tag)
 }
 EXPORT_SYMBOL_GPL(xas_clear_tag);
 
+/**
+ * xas_init_tags() - Initialise all tags for the entry
+ * @xas: Array operations state.
+ *
+ * Initialise all tags for the entry specified by @xas.  If we're tracking
+ * free entries with a tag, we need to set it on all entries.  All other
+ * tags are cleared.
+ *
+ * This implementation is not as efficient as it could be; we may walk
+ * up the tree multiple times.
+ */
+void xas_init_tags(const struct xa_state *xas)
+{
+	xa_tag_t tag = 0;
+
+	if (xa_track_free(xas->xa)) {
+		xas_set_tag(xas, XA_FREE_TAG);
+		tag_inc(tag);
+	}
+	for (;;) {
+		xas_clear_tag(xas, tag);
+		if (tag == XA_TAG_MAX)
+			break;
+		tag_inc(tag);
+	}
+}
+EXPORT_SYMBOL_GPL(xas_init_tags);
+
 /**
  * __xa_init() - Initialise an empty XArray with flags.
  * @xa: XArray.
@@ -278,6 +833,94 @@ void *xa_load(struct xarray *xa, unsigned long index)
 }
 EXPORT_SYMBOL(xa_load);
 
+static void *xas_result(struct xa_state *xas, void *curr)
+{
+	XA_BUG_ON(xas->xa_node, xa_is_internal(curr));
+	if (xas_error(xas))
+		curr = xas->xa_node;
+	return curr;
+}
+
+/**
+ * __xa_erase() - Erase this entry from the XArray while locked.
+ * @xa: XArray.
+ * @index: Index into array.
+ *
+ * If the entry at this index is a multi-index entry then all indices will
+ * be erased, and the entry will no longer be a multi-index entry.
+ * This function expects the xa_lock to be held on entry.
+ *
+ * Return: The old entry at this index.
+ */
+void *__xa_erase(struct xarray *xa, unsigned long index)
+{
+	XA_STATE(xas, xa, index);
+	return xas_result(&xas, xas_store(&xas, NULL));
+}
+EXPORT_SYMBOL_GPL(__xa_erase);
+
+/**
+ * xa_store() - Store this entry in the XArray.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @entry: New entry.
+ * @gfp: Allocation flags.
+ *
+ * Stores almost always succeed.  The notable exceptions:
+ *  - Attempted to store a reserved pointer entry (-EINVAL)
+ *  - Ran out of memory trying to allocate new nodes (-ENOMEM)
+ *
+ * Storing into an existing multislot entry updates the entry of every index.
+ *
+ * Return: The old entry at this index or xa_err() if an error happened.
+ */
+void *xa_store(struct xarray *xa, unsigned long index, void *entry, gfp_t gfp)
+{
+	XA_STATE(xas, xa, index);
+	void *curr;
+
+	if (WARN_ON_ONCE(xa_is_internal(entry)))
+		return XA_ERROR(-EINVAL);
+
+	do {
+		xas_lock(&xas);
+		curr = xas_store(&xas, entry);
+		xas_unlock(&xas);
+	} while (xas_nomem(&xas, gfp));
+
+	return xas_result(&xas, curr);
+}
+EXPORT_SYMBOL(xa_store);
+
+/*
+ * ___xa_store() - Store this entry in the XArray.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @entry: New entry.
+ * @gfp: Allocation flags.
+ * @lock_type: Lock acquisition type.
+ *
+ * Internal implementation detail.
+ *
+ * Return: The old entry at this index or xa_err() if an error happened.
+ */
+void *___xa_store(struct xarray *xa, unsigned long index, void *entry,
+			gfp_t gfp, enum xa_ctx ctx)
+{
+	XA_STATE(xas, xa, index);
+	void *curr;
+
+	if (WARN_ON_ONCE(xa_is_internal(entry)))
+		return XA_ERROR(-EINVAL);
+
+	do {
+		curr = xas_store(&xas, entry);
+	} while (__xas_nomem(&xas, gfp, ctx));
+
+	return xas_result(&xas, curr);
+}
+EXPORT_SYMBOL(___xa_store);
+
 /**
  * __xa_set_tag() - Set this tag on this entry while locked.
  * @xa: XArray.
diff --git a/tools/include/linux/spinlock.h b/tools/include/linux/spinlock.h
index 34fed5c38da2..85a009001109 100644
--- a/tools/include/linux/spinlock.h
+++ b/tools/include/linux/spinlock.h
@@ -10,6 +10,12 @@
 #define __SPIN_LOCK_UNLOCKED(x)	(pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER
 #define spin_lock_init(x)	pthread_mutex_init(x, NULL);
 
+#define spin_lock(x)			pthread_mutex_lock(x)
+#define spin_unlock(x)			pthread_mutex_unlock(x)
+#define spin_lock_bh(x)			pthread_mutex_lock(x)
+#define spin_unlock_bh(x)		pthread_mutex_unlock(x)
+#define spin_lock_irq(x)		pthread_mutex_lock(x)
+#define spin_unlock_irq(x)		pthread_mutex_unlock(x)
 #define spin_lock_irqsave(x, f)		(void)f, pthread_mutex_lock(x)
 #define spin_unlock_irqrestore(x, f)	(void)f, pthread_mutex_unlock(x)
 
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index 426f32f28547..4069bf565e3c 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -17,4 +17,8 @@
 #define pr_debug printk
 #define pr_cont printk
 
+#define __acquires(x)
+#define __releases(x)
+#define __must_hold(x)
+
 #endif /* _KERNEL_H */
diff --git a/tools/testing/radix-tree/linux/rcupdate.h b/tools/testing/radix-tree/linux/rcupdate.h
index 25010bf86c1d..fd280b070fdb 100644
--- a/tools/testing/radix-tree/linux/rcupdate.h
+++ b/tools/testing/radix-tree/linux/rcupdate.h
@@ -7,5 +7,6 @@
 #define rcu_dereference_raw(p) rcu_dereference(p)
 #define rcu_dereference_protected(p, cond) rcu_dereference(p)
 #define rcu_dereference_check(p, cond) rcu_dereference(p)
+#define RCU_INIT_POINTER(p, v)	(p) = (v)
 
 #endif
diff --git a/tools/testing/radix-tree/xarray-test.c b/tools/testing/radix-tree/xarray-test.c
index 3f8f19cb3739..416f1bbb6943 100644
--- a/tools/testing/radix-tree/xarray-test.c
+++ b/tools/testing/radix-tree/xarray-test.c
@@ -19,6 +19,36 @@
 
 #include "test.h"
 
+void check_xa_err(struct xarray *xa)
+{
+	assert(xa_err(xa_store(xa, 0, xa_mk_value(0), GFP_NOWAIT)) == 0);
+	assert(xa_err(xa_store(xa, 0, NULL, 0)) == 0);
+	assert(xa_err(xa_store(xa, 1, xa_mk_value(1), GFP_NOWAIT)) == -ENOMEM);
+	assert(xa_err(xa_store(xa, 1, xa_mk_value(1), GFP_NOWAIT)) == -ENOMEM);
+	assert(xa_err(xa_store(xa, 1, xa_mk_value(1), GFP_KERNEL)) == 0);
+	assert(xa_err(xa_store(xa, 1, xa_mk_value(0), GFP_KERNEL)) == 0);
+	assert(xa_err(xa_store(xa, 1, NULL, 0)) == 0);
+// kills the test-suite :-(
+//     assert(xa_err(xa_store(xa, 0, xa_mk_internal(0), 0)) == -EINVAL);
+}
+
+void check_xa_tag(struct xarray *xa)
+{
+	assert(xa_get_tag(xa, 0, XA_TAG_0) == false);
+	xa_set_tag(xa, 0, XA_TAG_0);
+	assert(xa_get_tag(xa, 0, XA_TAG_0) == false);
+	assert(xa_store(xa, 0, xa, GFP_KERNEL) == NULL);
+	assert(xa_get_tag(xa, 0, XA_TAG_0) == false);
+	xa_set_tag(xa, 0, XA_TAG_0);
+	assert(xa_get_tag(xa, 0, XA_TAG_0) == true);
+	assert(xa_get_tag(xa, 1, XA_TAG_0) == false);
+	assert(xa_store(xa, 0, NULL, GFP_KERNEL) == xa);
+	assert(xa_empty(xa));
+	assert(xa_get_tag(xa, 0, XA_TAG_0) == false);
+	xa_set_tag(xa, 0, XA_TAG_0);
+	assert(xa_get_tag(xa, 0, XA_TAG_0) == false);
+}
+
 void check_xa_load(struct xarray *xa)
 {
 	unsigned long i, j;
@@ -31,16 +61,109 @@ void check_xa_load(struct xarray *xa)
 			else
 				assert(!entry);
 		}
-		radix_tree_insert(xa, i, xa_mk_value(i));
+		xa_store(xa, i, xa_mk_value(i), GFP_KERNEL);
+	}
+}
+
+void check_xa_shrink(struct xarray *xa)
+{
+	XA_STATE(xas, xa, 1);
+	struct xa_node *node;
+
+	xa_store(xa, 0, xa_mk_value(0), GFP_KERNEL);
+	xa_store(xa, 1, xa_mk_value(1), GFP_KERNEL);
+
+	assert(xas_load(&xas) == xa_mk_value(1));
+	node = xas.xa_node;
+	assert(node->slots[0] == xa_mk_value(0));
+	rcu_read_lock();
+	xas_store(&xas, NULL);
+	assert(xas.xa_node == XAS_BOUNDS);
+	assert(node->slots[0] == XA_RETRY_ENTRY);
+	rcu_read_unlock();
+	assert(xa_load(xa, 0) == xa_mk_value(0));
+}
+
+static void *xa_store_order(struct xarray *xa, unsigned long index,
+				unsigned order, void *entry)
+{
+	XA_STATE(xas, xa, 0);
+	void *curr;
+
+	xas_set_order(&xas, index, order);
+	do {
+		curr = xas_store(&xas, entry);
+	} while (xas_nomem(&xas, GFP_KERNEL));
+
+	return curr;
+}
+
+void check_multi_store(struct xarray *xa)
+{
+	unsigned long i, j, k;
+
+	xa_store_order(xa, 0, 1, xa_mk_value(0));
+	assert(xa_load(xa, 0) == xa_mk_value(0));
+	assert(xa_load(xa, 1) == xa_mk_value(0));
+	assert(xa_load(xa, 2) == NULL);
+	assert(xa_to_node(xa_head(xa))->count == 2);
+	assert(xa_to_node(xa_head(xa))->nr_values == 2);
+
+	xa_store(xa, 3, xa, GFP_KERNEL);
+	assert(xa_load(xa, 0) == xa_mk_value(0));
+	assert(xa_load(xa, 1) == xa_mk_value(0));
+	assert(xa_load(xa, 2) == NULL);
+	assert(xa_to_node(xa_head(xa))->count == 3);
+	assert(xa_to_node(xa_head(xa))->nr_values == 2);
+
+	xa_store_order(xa, 0, 2, xa_mk_value(1));
+	assert(xa_load(xa, 0) == xa_mk_value(1));
+	assert(xa_load(xa, 1) == xa_mk_value(1));
+	assert(xa_load(xa, 2) == xa_mk_value(1));
+	assert(xa_load(xa, 3) == xa_mk_value(1));
+	assert(xa_load(xa, 4) == NULL);
+	assert(xa_to_node(xa_head(xa))->count == 4);
+	assert(xa_to_node(xa_head(xa))->nr_values == 4);
+
+	xa_store_order(xa, 0, 64, NULL);
+	assert(xa_empty(xa));
+
+	for (i = 0; i < 60; i++) {
+		for (j = 0; j < 60; j++) {
+			xa_store_order(xa, 0, i, xa_mk_value(i));
+			xa_store_order(xa, 0, j, xa_mk_value(j));
+
+			for (k = 0; k < 60; k++) {
+				void *entry = xa_load(xa, (1UL << k) - 1);
+				if ((i < k) && (j < k))
+					assert(entry == NULL);
+				else
+					assert(entry == xa_mk_value(j));
+			}
+
+			xa_erase(xa, 0);
+			assert(xa_empty(xa));
+		}
 	}
 }
 
 void xarray_checks(void)
 {
-	RADIX_TREE(array, GFP_KERNEL);
+	DEFINE_XARRAY(array);
+
+	check_xa_err(&array);
+	item_kill_tree(&array);
+
+	check_xa_tag(&array);
+	item_kill_tree(&array);
 
 	check_xa_load(&array);
+	item_kill_tree(&array);
+
+	check_xa_shrink(&array);
+	item_kill_tree(&array);
 
+	check_multi_store(&array);
 	item_kill_tree(&array);
 }
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

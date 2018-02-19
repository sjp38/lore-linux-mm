Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 368AA6B027F
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:46:16 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id w19so5828001pgv.4
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:46:16 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m12si137309pgd.292.2018.02.19.11.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Feb 2018 11:46:13 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v7 17/61] xarray: Add xa_store
Date: Mon, 19 Feb 2018 11:45:12 -0800
Message-Id: <20180219194556.6575-18-willy@infradead.org>
In-Reply-To: <20180219194556.6575-1-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

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
 include/linux/xarray.h                    | 109 +++++
 lib/radix-tree.c                          |   4 +-
 lib/xarray.c                              | 648 ++++++++++++++++++++++++++++++
 tools/include/linux/spinlock.h            |   2 +
 tools/testing/radix-tree/linux/kernel.h   |   4 +
 tools/testing/radix-tree/linux/lockdep.h  |  11 +
 tools/testing/radix-tree/linux/rcupdate.h |   1 +
 tools/testing/radix-tree/test.c           |  32 ++
 tools/testing/radix-tree/test.h           |   5 +
 tools/testing/radix-tree/xarray-test.c    | 113 +++++-
 10 files changed, 925 insertions(+), 4 deletions(-)
 create mode 100644 tools/testing/radix-tree/linux/lockdep.h

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 1cf012256eab..38e290df2ff0 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -157,10 +157,17 @@ typedef unsigned __bitwise xa_tag_t;
 #define XA_PRESENT		((__force xa_tag_t)8U)
 #define XA_TAG_MAX		XA_TAG_2
 
+enum xa_lock_type {
+	XA_LOCK_IRQ = 1,
+	XA_LOCK_BH = 2,
+};
+
 /*
  * Values for xa_flags.  The radix tree stores its GFP flags in the xa_flags,
  * and we remain compatible with that.
  */
+#define XA_FLAGS_LOCK_IRQ	((__force gfp_t)XA_LOCK_IRQ)
+#define XA_FLAGS_LOCK_BH	((__force gfp_t)XA_LOCK_BH)
 #define XA_FLAGS_TAG(tag)	((__force gfp_t)((1U << __GFP_BITS_SHIFT) << \
 						(__force unsigned)(tag)))
 
@@ -210,6 +217,7 @@ struct xarray {
 
 void xa_init_flags(struct xarray *, gfp_t flags);
 void *xa_load(struct xarray *, unsigned long index);
+void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
 bool xa_get_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
 void xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
@@ -227,6 +235,35 @@ static inline void xa_init(struct xarray *xa)
 	xa_init_flags(xa, 0);
 }
 
+/**
+ * xa_erase() - Erase this entry from the XArray.
+ * @xa: XArray.
+ * @index: Index of entry.
+ *
+ * This function is the equivalent of calling xa_store() with %NULL as
+ * the third argument.  The XArray does not need to allocate memory, so
+ * the user does not need to provide GFP flags.
+ *
+ * Context: Process context.  Takes and releases the xa_lock.
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
+ * Context: Any context.
+ * Return: %true if the array contains only NULL pointers.
+ */
+static inline bool xa_empty(const struct xarray *xa)
+{
+	return xa->xa_head == NULL;
+}
+
 /**
  * xa_tagged() - Inquire whether any entry in this array has a tag set
  * @xa: Array
@@ -254,7 +291,11 @@ static inline bool xa_tagged(const struct xarray *xa, xa_tag_t tag)
 
 /*
  * Versions of the normal API which require the caller to hold the xa_lock.
+ * If the GFP flags allow it, will drop the lock in order to allocate
+ * memory, then reacquire it afterwards.
  */
+void *__xa_erase(struct xarray *, unsigned long index);
+void *__xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
 void __xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
 void __xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
 
@@ -350,6 +391,12 @@ static inline void *xa_entry_locked(struct xarray *xa,
 						lockdep_is_held(&xa->xa_lock));
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
@@ -534,6 +581,12 @@ static inline bool xas_valid(const struct xa_state *xas)
 	return !xas_invalid(xas);
 }
 
+/* True if the node represents head-of-tree, RESTART or BOUNDS */
+static inline bool xas_top(struct xa_node *node)
+{
+	return node <= XAS_RESTART;
+}
+
 /**
  * xas_reset() - Reset an XArray operation state.
  * @xas: XArray operation state.
@@ -570,10 +623,15 @@ static inline bool xas_retry(struct xa_state *xas, const void *entry)
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
@@ -598,4 +656,55 @@ static inline void *xas_reload(struct xa_state *xas)
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
index d3cb26104589..05bd8172b148 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -47,7 +47,7 @@ static unsigned long height_to_maxnodes[RADIX_TREE_MAX_PATH + 1] __read_mostly;
 /*
  * Radix tree node cache.
  */
-static struct kmem_cache *radix_tree_node_cachep;
+struct kmem_cache *radix_tree_node_cachep;
 
 /*
  * The radix tree is variable-height, so an insert operation not only has
@@ -365,7 +365,7 @@ radix_tree_node_alloc(gfp_t gfp_mask, struct radix_tree_node *parent,
 	return ret;
 }
 
-static void radix_tree_node_rcu_free(struct rcu_head *head)
+void radix_tree_node_rcu_free(struct rcu_head *head)
 {
 	struct radix_tree_node *node =
 			container_of(head, struct radix_tree_node, rcu_head);
diff --git a/lib/xarray.c b/lib/xarray.c
index ca25a7a4a4fa..9e50804f168c 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -7,6 +7,8 @@
 
 #include <linux/bitmap.h>
 #include <linux/export.h>
+#include <linux/list.h>
+#include <linux/slab.h>
 #include <linux/xarray.h>
 
 /*
@@ -39,6 +41,11 @@ static inline struct xa_node *xa_parent_locked(struct xarray *xa,
 						lockdep_is_held(&xa->xa_lock));
 }
 
+static inline unsigned int xa_lock_type(const struct xarray *xa)
+{
+	return (__force unsigned int)xa->xa_flags & 3;
+}
+
 static inline void xa_tag_set(struct xarray *xa, xa_tag_t tag)
 {
 	if (!(xa->xa_flags & XA_FLAGS_TAG(tag)))
@@ -74,6 +81,10 @@ static inline bool node_any_tag(struct xa_node *node, xa_tag_t tag)
 	return !bitmap_empty(node->tags[(__force unsigned)tag], XA_CHUNK_SIZE);
 }
 
+#define tag_inc(tag) do { \
+	tag = (__force xa_tag_t)((__force unsigned)(tag) + 1); \
+} while (0)
+
 /* extracts the offset within this node from the index */
 static unsigned int get_offset(unsigned long index, struct xa_node *node)
 {
@@ -168,6 +179,515 @@ void *xas_load(struct xa_state *xas)
 }
 EXPORT_SYMBOL_GPL(xas_load);
 
+/* Move the radix tree node cache here */
+extern struct kmem_cache *radix_tree_node_cachep;
+extern void radix_tree_node_rcu_free(struct rcu_head *head);
+
+#define XA_RCU_FREE	((struct xarray *)1)
+
+static void xa_node_free(struct xa_node *node)
+{
+	XA_NODE_BUG_ON(node, !list_empty(&node->private_list));
+	node->array = XA_RCU_FREE;
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
+	XA_NODE_BUG_ON(node, !list_empty(&node->private_list));
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
+	XA_NODE_BUG_ON(xas->xa_alloc, !list_empty(&xas->xa_alloc->private_list));
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
+static bool __xas_nomem(struct xa_state *xas, gfp_t gfp)
+	__must_hold(xas->xa->xa_lock)
+{
+	unsigned int lock_type = xa_lock_type(xas->xa);
+
+	if (xas->xa_node != XA_ERROR(-ENOMEM)) {
+		xas_destroy(xas);
+		return false;
+	}
+	if (gfpflags_allow_blocking(gfp)) {
+		if (lock_type == XA_LOCK_IRQ)
+			xas_unlock_irq(xas);
+		else if (lock_type == XA_LOCK_BH)
+			xas_unlock_bh(xas);
+		else
+			xas_unlock(xas);
+		xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
+		if (lock_type == XA_LOCK_IRQ)
+			xas_lock_irq(xas);
+		else if (lock_type == XA_LOCK_BH)
+			xas_lock_bh(xas);
+		else
+			xas_lock(xas);
+	} else {
+		xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
+	}
+	if (!xas->xa_alloc)
+		return false;
+	XA_NODE_BUG_ON(xas->xa_alloc, !list_empty(&xas->xa_alloc->private_list));
+	xas->xa_node = XAS_RESTART;
+	return true;
+}
+
+static void xas_update(struct xa_state *xas, struct xa_node *node)
+{
+	if (xas->xa_update)
+		xas->xa_update(node);
+	else
+		XA_NODE_BUG_ON(node, !list_empty(&node->private_list));
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
+		XA_NODE_BUG_ON(node, parent->count > XA_CHUNK_SIZE);
+		xas_update(xas, parent);
+	}
+	XA_NODE_BUG_ON(node, shift > BITS_PER_LONG);
+	XA_NODE_BUG_ON(node, !list_empty(&node->private_list));
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
+	unsigned long max = xas->xa_index;
+
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	if (xas->xa_shift || xas->xa_sibs) {
+		unsigned long mask;
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
+		XA_NODE_BUG_ON(node, node->count > XA_CHUNK_SIZE);
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
+
+		node->count = 0;
+		node->nr_values = 0;
+		if (!xa_is_node(entry))
+			RCU_INIT_POINTER(node->slots[0], XA_RETRY_ENTRY);
+		xas_update(xas, node);
+		xa_node_free(node);
+		if (!xa_is_node(entry))
+			break;
+		node = xa_to_node(entry);
+		node->parent = NULL;
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
+		XA_NODE_BUG_ON(node, node->count > XA_CHUNK_SIZE);
+		if (node->count)
+			break;
+
+		parent = xa_parent_locked(xas->xa, node);
+		xas->xa_node = parent;
+		xas->xa_offset = node->offset;
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
+		XA_NODE_BUG_ON(parent, parent->count > XA_CHUNK_SIZE);
+		node = parent;
+		xas_update(xas, node);
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
+			struct xa_node *parent;
+
+			parent = xa_parent_locked(xas->xa, node);
+			offset = node->offset + 1;
+			node->count = 0;
+			node->nr_values = 0;
+			xas_update(xas, node);
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
+		XA_NODE_BUG_ON(node, shift > BITS_PER_LONG);
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
+		for (;;) {
+			if (xa_tagged(xa, tag))
+				node_set_tag(node, 0, tag);
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
+		xas_update(xas, node);
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
+static void store_siblings(struct xa_state *xas, void *entry, void *curr,
+				int *countp, int *valuesp)
+{
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	struct xa_node *node = xas->xa_node;
+	unsigned int sibs, offset = xas->xa_offset;
+	void *sibling = entry ? xa_mk_sibling(offset) : NULL;
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
+			curr = next;
+		}
+		RCU_INIT_POINTER(node->slots[offset], sibling);
+		if (xa_is_node(next))
+			xas_free_nodes(xas, xa_to_node(next));
+		*countp += !next - !entry;
+		*valuesp += !xa_is_value(curr) - !xa_is_value(entry);
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
+		store_siblings(xas, entry, curr, &count, &values);
+		node->count += count;
+		XA_NODE_BUG_ON(node, node->count > XA_CHUNK_SIZE);
+		node->nr_values += values;
+		XA_NODE_BUG_ON(node, node->nr_values > XA_CHUNK_SIZE);
+		if (count || values)
+			xas_update(xas, node);
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
@@ -247,6 +767,30 @@ void xas_clear_tag(const struct xa_state *xas, xa_tag_t tag)
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
  * xa_init_flags() - Initialise an empty XArray with flags.
  * @xa: XArray.
@@ -260,9 +804,19 @@ EXPORT_SYMBOL_GPL(xas_clear_tag);
  */
 void xa_init_flags(struct xarray *xa, gfp_t flags)
 {
+	unsigned int lock_type;
+	static struct lock_class_key xa_lock_irq;
+	static struct lock_class_key xa_lock_bh;
+
 	spin_lock_init(&xa->xa_lock);
 	xa->xa_flags = flags;
 	xa->xa_head = NULL;
+
+	lock_type = xa_lock_type(xa);
+	if (lock_type == XA_LOCK_IRQ)
+		lockdep_set_class(&xa->xa_lock, &xa_lock_irq);
+	else if (lock_type == XA_LOCK_BH)
+		lockdep_set_class(&xa->xa_lock, &xa_lock_bh);
 }
 EXPORT_SYMBOL(xa_init_flags);
 
@@ -289,6 +843,100 @@ void *xa_load(struct xarray *xa, unsigned long index)
 }
 EXPORT_SYMBOL(xa_load);
 
+static void *xas_result(struct xa_state *xas, void *curr)
+{
+	XA_NODE_BUG_ON(xas->xa_node, xa_is_internal(curr));
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
+ * Context: Any context.  Expects xa_lock to be held on entry.  May
+ * release and reacquire xa_lock if @gfp flags permit.
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
+ * @gfp: Memory allocation flags.
+ *
+ * After this function returns, loads from this index will return @entry.
+ * Storing into an existing multislot entry updates the entry of every index.
+ * The tags associated with @index are unaffected unless @entry is %NULL.
+ *
+ * Context: Process context.  Takes and releases the xa_lock.  May sleep
+ * if the @gfp flags permit.
+ * Return: The old entry at this index on success, xa_err(-EINVAL) if @entry
+ * cannot be stored in an XArray, or xa_err(-ENOMEM) if memory allocation
+ * failed.
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
+/**
+ * __xa_store() - Store this entry in the XArray.
+ * @xa: XArray.
+ * @index: Index into array.
+ * @entry: New entry.
+ * @gfp: Memory allocation flags.
+ *
+ * You must already be holding the xa_lock when calling this function.
+ * It will drop the lock if needed to allocate memory, and then reacquire
+ * it afterwards.
+ *
+ * Context: Any context.  Expects xa_lock to be held on entry.  May
+ * release and reacquire xa_lock if @gfp flags permit.
+ * Return: The old entry at this index or xa_err() if an error happened.
+ */
+void *__xa_store(struct xarray *xa, unsigned long index, void *entry, gfp_t gfp)
+{
+	XA_STATE(xas, xa, index);
+	void *curr;
+
+	if (WARN_ON_ONCE(xa_is_internal(entry)))
+		return XA_ERROR(-EINVAL);
+
+	do {
+		curr = xas_store(&xas, entry);
+	} while (__xas_nomem(&xas, gfp));
+
+	return xas_result(&xas, curr);
+}
+EXPORT_SYMBOL(__xa_store);
+
 /**
  * __xa_set_tag() - Set this tag on this entry while locked.
  * @xa: XArray.
diff --git a/tools/include/linux/spinlock.h b/tools/include/linux/spinlock.h
index 85a009001109..f900a2b7509d 100644
--- a/tools/include/linux/spinlock.h
+++ b/tools/include/linux/spinlock.h
@@ -37,4 +37,6 @@ static inline bool arch_spin_is_locked(arch_spinlock_t *mutex)
 	return true;
 }
 
+#include <linux/lockdep.h>
+
 #endif
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index 5d06ac75a14d..4568248222ae 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -18,4 +18,8 @@
 #define pr_debug printk
 #define pr_cont printk
 
+#define __acquires(x)
+#define __releases(x)
+#define __must_hold(x)
+
 #endif /* _KERNEL_H */
diff --git a/tools/testing/radix-tree/linux/lockdep.h b/tools/testing/radix-tree/linux/lockdep.h
new file mode 100644
index 000000000000..565fccdfe6e9
--- /dev/null
+++ b/tools/testing/radix-tree/linux/lockdep.h
@@ -0,0 +1,11 @@
+#ifndef _LINUX_LOCKDEP_H
+#define _LINUX_LOCKDEP_H
+struct lock_class_key {
+	unsigned int a;
+};
+
+static inline void lockdep_set_class(spinlock_t *lock,
+					struct lock_class_key *key)
+{
+}
+#endif /* _LINUX_LOCKDEP_H */
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
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index 6e1cc2040817..f151588d04a0 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -8,6 +8,38 @@
 
 #include "test.h"
 
+void *xa_store_order(struct xarray *xa, unsigned long index, unsigned order,
+			void *entry, gfp_t gfp)
+{
+	XA_STATE(xas, xa, 0);
+	void *curr;
+
+	xas_set_order(&xas, index, order);
+	do {
+		curr = xas_store(&xas, entry);
+	} while (xas_nomem(&xas, gfp));
+
+	return curr;
+}
+
+int xa_insert_order(struct xarray *xa, unsigned long index, unsigned order,
+			void *entry, gfp_t gfp)
+{
+	XA_STATE(xas, xa, 0);
+	void *curr;
+
+	xas_set_order(&xas, index, order);
+	do {
+		curr = xas_create(&xas);
+		if (!curr)
+			xas_store(&xas, entry);
+	} while (xas_nomem(&xas, gfp));
+
+	if (xas_error(&xas))
+		return xas_error(&xas);
+	return curr ? -EEXIST : 0;
+}
+
 struct item *
 item_tag_set(struct radix_tree_root *root, unsigned long index, int tag)
 {
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index d9c031dbeb1a..ffd162645c11 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -4,6 +4,11 @@
 #include <linux/radix-tree.h>
 #include <linux/rcupdate.h>
 
+void *xa_store_order(struct xarray *, unsigned long index, unsigned order,
+			void *entry, gfp_t);
+int xa_insert_order(struct xarray *, unsigned long index, unsigned order,
+			void *entry, gfp_t);
+
 struct item {
 	unsigned long index;
 	unsigned int order;
diff --git a/tools/testing/radix-tree/xarray-test.c b/tools/testing/radix-tree/xarray-test.c
index 3f8f19cb3739..5defd0b9f85c 100644
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
@@ -31,16 +61,95 @@ void check_xa_load(struct xarray *xa)
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
+void check_multi_store(struct xarray *xa)
+{
+	unsigned long i, j, k;
+
+	xa_store_order(xa, 0, 1, xa_mk_value(0), GFP_KERNEL);
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
+	xa_store_order(xa, 0, 2, xa_mk_value(1), GFP_KERNEL);
+	assert(xa_load(xa, 0) == xa_mk_value(1));
+	assert(xa_load(xa, 1) == xa_mk_value(1));
+	assert(xa_load(xa, 2) == xa_mk_value(1));
+	assert(xa_load(xa, 3) == xa_mk_value(1));
+	assert(xa_load(xa, 4) == NULL);
+	assert(xa_to_node(xa_head(xa))->count == 4);
+	assert(xa_to_node(xa_head(xa))->nr_values == 4);
+
+	xa_store_order(xa, 0, 64, NULL, GFP_KERNEL);
+	assert(xa_empty(xa));
+
+	for (i = 0; i < 60; i++) {
+		for (j = 0; j < 60; j++) {
+			xa_store_order(xa, 0, i, xa_mk_value(i), GFP_KERNEL);
+			xa_store_order(xa, 0, j, xa_mk_value(j), GFP_KERNEL);
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
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

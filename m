Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EEE96B027C
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:20 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id h21so13397578pfk.14
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y11si13991248pgp.97.2017.11.22.13.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:17 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 22/62] xarray: Add xa_store
Date: Wed, 22 Nov 2017 13:06:59 -0800
Message-Id: <20171122210739.29916-23-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

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

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h                    |  58 ++++
 lib/radix-tree.c                          |   4 +-
 lib/xarray.c                              | 552 ++++++++++++++++++++++++++++++
 tools/testing/radix-tree/linux/rcupdate.h |   1 +
 tools/testing/radix-tree/xarray-test.c    |  66 ++++
 5 files changed, 679 insertions(+), 2 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index ab6b1f5e685a..5e975c512018 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -82,6 +82,18 @@ struct xarray {
 #define DEFINE_XARRAY(name) struct xarray name = XARRAY_INIT(name)
 
 void *xa_load(struct xarray *, unsigned long index);
+void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
+
+/**
+ * xa_empty() - Determine if an array has any present entries
+ * @xa: Array
+ *
+ * Return: True if the array has no entries in it.
+ */
+static inline bool xa_empty(const struct xarray *xa)
+{
+	return xa->xa_head == NULL;
+}
 
 typedef unsigned __bitwise xa_tag_t;
 #define XA_TAG_0		((__force xa_tag_t)0U)
@@ -91,9 +103,15 @@ typedef unsigned __bitwise xa_tag_t;
 
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
@@ -263,6 +281,11 @@ static inline bool xa_is_internal(void *entry)
 	return ((unsigned long)entry & 3) == 2;
 }
 
+static inline void *xa_mk_node(struct xa_node *node)
+{
+	return (void *)((unsigned long)node | 2);
+}
+
 static inline struct xa_node *xa_to_node(void *entry)
 {
 	return (struct xa_node *)((unsigned long)entry & ~3UL);
@@ -386,10 +409,16 @@ static inline bool xas_retry(struct xa_state *xas, void *entry)
 }
 
 void *xas_load(struct xarray *, struct xa_state *);
+void *xas_store(struct xarray *, struct xa_state *, void *entry);
+void *xas_create(struct xarray *, struct xa_state *);
 
 bool xas_get_tag(const struct xarray *, const struct xa_state *, xa_tag_t);
 void xas_set_tag(struct xarray *, const struct xa_state *, xa_tag_t);
 void xas_clear_tag(struct xarray *, const struct xa_state *, xa_tag_t);
+void xas_init_tags(struct xarray *, const struct xa_state *);
+
+void xas_destroy(struct xa_state *);
+bool xas_nomem(struct xa_state *, gfp_t);
 
 /**
  * xas_reload() - Refetch an entry from the xarray.
@@ -415,4 +444,33 @@ static inline void *xas_reload(struct xarray *xa, struct xa_state *xas)
 	return xa_head(xa);
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
+	xas->xa_index = (index >> order) << order;
+	xas->xa_shift = order - (order % XA_CHUNK_SHIFT);
+	xas->xa_sibs = (1 << (order % XA_CHUNK_SHIFT)) - 1;
+	xas->xa_node = XAS_RESTART;
+}
 #endif /* _LINUX_XARRAY_H */
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 711a6d9b79fc..507e1842255b 100644
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
@@ -407,7 +407,7 @@ radix_tree_node_alloc(gfp_t gfp_mask, struct radix_tree_node *parent,
 	return ret;
 }
 
-static void radix_tree_node_rcu_free(struct rcu_head *head)
+void radix_tree_node_rcu_free(struct rcu_head *head)
 {
 	struct radix_tree_node *node =
 			container_of(head, struct radix_tree_node, rcu_head);
diff --git a/lib/xarray.c b/lib/xarray.c
index fbc7de5a224f..a3f4f4ab673f 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -12,9 +12,11 @@
  * more details.
  */
 
+#include <linux/bitmap.h>
 #include <linux/export.h>
 #include <linux/gfp.h>
 #include <linux/radix-tree.h>
+#include <linux/slab.h>
 #include <linux/xarray.h>
 
 /*
@@ -75,11 +77,20 @@ static inline void tag_clear(struct xa_node *node, unsigned int offset,
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
@@ -161,6 +172,481 @@ void *xas_load(struct xarray *xa, struct xa_state *xas)
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
+/**
+ * xas_destroy() - Free any resources allocated during the XArray operation.
+ * @xas: XArray operation state.
+ *
+ * If the operation only involved read accesses to the XArray or modifying
+ * existing data in the XArray, there is no need to call this function
+ * (eg xa_set_tag()).  However, if you may have allocated memory (for
+ * example by calling xas_nomem()), then call this function.
+ *
+ * This function does not reinitialise the state, so you may continue to
+ * call xas_error(), and you would want to call xas_init() before reusing
+ * this structure.  It only releases any resources.
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
+EXPORT_SYMBOL_GPL(xas_destroy);
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
+	if (xas->xa_node != XAS_ERROR(ENOMEM))
+		return false;
+	xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
+	if (!xas->xa_alloc)
+		return false;
+	XA_BUG_ON(xas->xa_alloc, !list_empty(&xas->xa_alloc->private_list));
+	xas->xa_node = XAS_RESTART;
+	return true;
+}
+EXPORT_SYMBOL_GPL(xas_nomem);
+
+static void *xas_alloc(struct xarray *xa, struct xa_state *xas,
+			unsigned int shift)
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
+			xas_set_err(xas, ENOMEM);
+			return NULL;
+		}
+	}
+
+	if (xas->xa_node) {
+		node->offset = xas->xa_offset;
+		parent->count++;
+		XA_BUG_ON(node, parent->count > XA_CHUNK_SIZE);
+	}
+	XA_BUG_ON(node, shift > BITS_PER_LONG);
+	XA_BUG_ON(node, !list_empty(&node->private_list));
+	node->shift = shift;
+	node->count = 0;
+	node->exceptional = 0;
+	RCU_INIT_POINTER(node->parent, xas->xa_node);
+	node->root = xa;
+
+	return node;
+}
+
+/*
+ * Use this to calculate the maximum index that will need to be created
+ * in order to add the entry described by @xas.  Because we cannot store a
+ * multiple-slot entry at index 0, the calculation is a little more complex
+ * than you might expect.
+ */
+static unsigned long xas_max(struct xa_state *xas)
+{
+	unsigned long mask, max = xas->xa_index;
+
+	if (xas->xa_shift || xas->xa_sibs) {
+		mask = (((xas->xa_sibs + 1UL) << xas->xa_shift) - 1);
+		max |= mask;
+		if (mask == max)
+			max++;
+	}
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
+static void xas_shrink(struct xarray *xa, const struct xa_state *xas)
+{
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
+
+		RCU_INIT_POINTER(xa->xa_head, entry);
+		if (xa_track_free(xa) && !tag_get(node, 0, XA_FREE_TAG))
+			xa_tag_clear(xa, XA_FREE_TAG);
+
+		node->count = 0;
+		node->exceptional = 0;
+		if (xa_is_node(entry))
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
+ * @xa: Array
+ * @xas: Array operation state.
+ *
+ * Attempts to delete the @xas->xa_node.  This will fail if xa->node has
+ * a non-zero reference count.
+ */
+static void xas_delete_node(struct xarray *xa, struct xa_state *xas)
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
+		parent = xa_parent_locked(xa, node);
+		xas->xa_node = parent;
+		xas->xa_offset = node->offset;
+		XA_BUG_ON(node, !list_empty(&node->private_list));
+		xa_node_free(node);
+
+		if (!parent) {
+			xa->xa_head = NULL;
+			xas->xa_node = XAS_RESTART;
+			return;
+		}
+
+		parent->slots[xas->xa_offset] = NULL;
+		parent->count--;
+		XA_BUG_ON(node, parent->count > XA_CHUNK_SIZE);
+		node = parent;
+		if (xas->xa_update)
+			xas->xa_update(node);
+		else
+			XA_BUG_ON(node, !list_empty(&node->private_list));
+	}
+
+	if (!node->parent)
+		xas_shrink(xa, xas);
+}
+
+/**
+ * xas_free_nodes() - Free this node and all nodes that it references
+ * @xa: Array
+ * @xas: Array operation state.
+ * @top: Node to free
+ *
+ * This node has been removed from the tree.  We must now free it and all
+ * of its subnodes.  There may be RCU walkers with references into the tree,
+ * so we must replace all entries with retry markers.
+ */
+static void xas_free_nodes(struct xarray *xa, struct xa_state *xas,
+		struct xa_node *top)
+{
+	unsigned int offset = 0;
+	struct xa_node *node = top;
+
+	for (;;) {
+		void *entry = xa_entry_locked(xa, node, offset);
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
+			struct xa_node *parent = xa_parent_locked(xa, node);
+
+			offset = node->offset + 1;
+			node->count = 0;
+			node->exceptional = 0;
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
+static int xas_expand(struct xarray *xa, struct xa_state *xas, void *head)
+{
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
+		node = xas_alloc(xa, xas, shift);
+		if (!node)
+			return -ENOMEM;
+
+		node->count = 1;
+		if (xa_is_value(head))
+			node->exceptional = 1;
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
+ * @xa: XArray.
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
+void *xas_create(struct xarray *xa, struct xa_state *xas)
+{
+	void *entry;
+	void __rcu **slot;
+	struct xa_node *node = xas->xa_node;
+	int shift;
+	unsigned int order = xas->xa_shift;
+
+	if (node == XAS_RESTART) {
+		entry = xa_head_locked(xa);
+		xas->xa_node = NULL;
+		shift = xas_expand(xa, xas, entry);
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
+			node = xas_alloc(xa, xas, shift);
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
+		entry = xas_descend(xa, xas, node);
+		slot = &node->slots[xas->xa_offset];
+	}
+
+	return entry;
+}
+EXPORT_SYMBOL_GPL(xas_create);
+
+static void store_siblings(struct xarray *xa, struct xa_state *xas,
+				void *entry, int *countp, int *valuesp)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int sibs, offset = xas->xa_offset;
+	void *sibling = entry ? xa_mk_sibling(offset) : NULL;
+	void *real = entry;
+
+	if (!entry)
+		sibs = XA_CHUNK_SIZE;
+	else if (xas->xa_shift < node->shift)
+		sibs = 0;
+	else
+		sibs = xas->xa_sibs;
+
+	while (sibs--) {
+		void *next = xa_entry(xa, node, ++offset);
+
+		if (!xa_is_sibling(next)) {
+			if (!entry)
+				break;
+			real = next;
+		}
+		RCU_INIT_POINTER(node->slots[offset], sibling);
+		if (xa_is_node(next))
+			xas_free_nodes(xa, xas, xa_to_node(next));
+		*countp += !next - !entry;
+		*valuesp += !xa_is_value(real) - !xa_is_value(entry);
+	}
+}
+
+/**
+ * xas_store() - Store this entry in the XArray.
+ * @xa: XArray.
+ * @xas: XArray operation state.
+ * @entry: New entry.
+ *
+ * Return: The old entry at this index.
+ */
+void *xas_store(struct xarray *xa, struct xa_state *xas, void *entry)
+{
+	struct xa_node *node;
+	int count, values;
+	void *curr;
+
+	if (entry)
+		curr = xas_create(xa, xas);
+	else
+		curr = xas_load(xa, xas);
+	if (xas_invalid(xas))
+		return curr;
+	if ((curr == entry) && !xas->xa_sibs)
+		return curr;
+
+	node = xas->xa_node;
+	if (node)
+		rcu_assign_pointer(node->slots[xas->xa_offset], entry);
+	else
+		rcu_assign_pointer(xa->xa_head, entry);
+	if (!entry)
+		xas_init_tags(xa, xas);
+
+	values = !xa_is_value(curr) - !xa_is_value(entry);
+	count = !curr - !entry;
+	if (xa_is_node(curr))
+		xas_free_nodes(xa, xas, xa_to_node(curr));
+
+	if (node) {
+		store_siblings(xa, xas, entry, &count, &values);
+		node->count += count;
+		XA_BUG_ON(node, node->count > XA_CHUNK_SIZE);
+		node->exceptional += values;
+		XA_BUG_ON(node, node->exceptional > XA_CHUNK_SIZE);
+		if ((count || values) && xas->xa_update)
+			xas->xa_update(node);
+		else
+			XA_BUG_ON(node, !list_empty(&node->private_list));
+		if (count < 0)
+			xas_delete_node(xa, xas);
+	}
+
+	return curr;
+}
+EXPORT_SYMBOL_GPL(xas_store);
+
 /**
  * xas_get_tag() - Returns the state of this tag.
  * @xa: XArray.
@@ -244,6 +730,35 @@ void xas_clear_tag(struct xarray *xa, const struct xa_state *xas, xa_tag_t tag)
 }
 EXPORT_SYMBOL_GPL(xas_clear_tag);
 
+/**
+ * xas_init_tags() - Initialise all tags for the entry
+ * @xa: Array
+ * @xas: Array operations state.
+ *
+ * Initialise all tags for the entry specified by @xas.  If we're tracking
+ * free entries with a tag, we need to set it on all entries.  All other
+ * tags are cleared.
+ *
+ * This implementation is not as efficient as it could be; we may walk
+ * up the tree multiple times.
+ */
+void xas_init_tags(struct xarray *xa, const struct xa_state *xas)
+{
+	xa_tag_t tag = 0;
+
+	if (xa_track_free(xa)) {
+		xas_set_tag(xa, xas, XA_FREE_TAG);
+		tag_inc(tag);
+	}
+	for (;;) {
+		xas_clear_tag(xa, xas, tag);
+		if (tag == XA_TAG_MAX)
+			break;
+		tag_inc(tag);
+	}
+}
+EXPORT_SYMBOL_GPL(xas_init_tags);
+
 /**
  * xa_load() - Load an entry from an XArray.
  * @xa: XArray.
@@ -266,6 +781,43 @@ void *xa_load(struct xarray *xa, unsigned long index)
 }
 EXPORT_SYMBOL(xa_load);
 
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
+ * Return: The old entry at this index or ERR_PTR() if an error happened.
+ */
+void *xa_store(struct xarray *xa, unsigned long index, void *entry, gfp_t gfp)
+{
+	XA_STATE(xas, index);
+	unsigned long flags;
+	void *curr;
+
+	if (WARN_ON_ONCE(xa_is_internal(entry)))
+		return ERR_PTR(-EINVAL);
+
+	do {
+		xa_lock_irqsave(xa, flags);
+		curr = xas_store(xa, &xas, entry);
+		xa_unlock_irqrestore(xa, flags);
+	} while (xas_nomem(&xas, gfp));
+	xas_destroy(&xas);
+
+	if (xas_error(&xas))
+		curr = ERR_PTR(xas_error(&xas));
+	return curr;
+}
+EXPORT_SYMBOL(xa_store);
+
 /**
  * __xa_set_tag() - Set this tag on this entry.
  * @xa: XArray.
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
index 3f8f19cb3739..8412d7818152 100644
--- a/tools/testing/radix-tree/xarray-test.c
+++ b/tools/testing/radix-tree/xarray-test.c
@@ -35,12 +35,78 @@ void check_xa_load(struct xarray *xa)
 	}
 }
 
+static void *xa_store_order(struct xarray *xa, unsigned long index,
+				unsigned order, void *entry)
+{
+	XA_STATE(xas, 0);
+	void *curr;
+
+	xas_set_order(&xas, index, order);
+	do {
+		curr = xas_store(xa, &xas, entry);
+	} while (xas_nomem(&xas, GFP_KERNEL));
+	xas_destroy(&xas);
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
+	assert(xa_to_node(xa_head(xa))->exceptional == 2);
+
+	xa_store(xa, 3, xa, GFP_KERNEL);
+	assert(xa_load(xa, 0) == xa_mk_value(0));
+	assert(xa_load(xa, 1) == xa_mk_value(0));
+	assert(xa_load(xa, 2) == NULL);
+	assert(xa_to_node(xa_head(xa))->count == 3);
+	assert(xa_to_node(xa_head(xa))->exceptional == 2);
+
+	xa_store_order(xa, 0, 2, xa_mk_value(1));
+	assert(xa_load(xa, 0) == xa_mk_value(1));
+	assert(xa_load(xa, 1) == xa_mk_value(1));
+	assert(xa_load(xa, 2) == xa_mk_value(1));
+	assert(xa_load(xa, 3) == xa_mk_value(1));
+	assert(xa_load(xa, 4) == NULL);
+	assert(xa_to_node(xa_head(xa))->count == 4);
+	assert(xa_to_node(xa_head(xa))->exceptional == 4);
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
+			xa_store(xa, 0, NULL, GFP_KERNEL);
+			assert(xa_empty(xa));
+		}
+	}
+}
+
 void xarray_checks(void)
 {
 	RADIX_TREE(array, GFP_KERNEL);
 
 	check_xa_load(&array);
+	item_kill_tree(&array);
 
+	check_multi_store(&array);
 	item_kill_tree(&array);
 }
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

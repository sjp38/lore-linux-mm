Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 776CF6B02AF
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:43:39 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y62so1633807pfd.3
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:43:39 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z8si891919pgs.167.2017.12.05.16.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:42:10 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 09/73] xarray: Add xa_load
Date: Tue,  5 Dec 2017 16:40:55 -0800
Message-Id: <20171206004159.3755-10-willy@infradead.org>
In-Reply-To: <20171206004159.3755-1-willy@infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This first function in the XArray API brings with it a lot of support
infrastructure.  The advanced API is based around the xa_state which is
a more capable version of the radix_tree_iter.

As the test-suite demonstrates, it is possible to use the xarray and
radix tree APIs on the same data structure.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h                      | 235 ++++++++++++++++++++++++++++
 lib/radix-tree.c                            |  43 -----
 lib/xarray.c                                | 160 +++++++++++++++++++
 tools/testing/radix-tree/.gitignore         |   1 +
 tools/testing/radix-tree/Makefile           |   7 +-
 tools/testing/radix-tree/linux/radix-tree.h |   1 -
 tools/testing/radix-tree/linux/rcupdate.h   |   1 +
 tools/testing/radix-tree/linux/xarray.h     |   1 +
 tools/testing/radix-tree/xarray-test.c      |  56 +++++++
 9 files changed, 459 insertions(+), 46 deletions(-)
 create mode 100644 tools/testing/radix-tree/xarray-test.c

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 1aff0069458b..af52ba75e6a3 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -21,6 +21,8 @@
 #include <linux/bug.h>
 #include <linux/compiler.h>
 #include <linux/kconfig.h>
+#include <linux/kernel.h>
+#include <linux/rcupdate.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
@@ -67,6 +69,8 @@ static inline void xa_init(struct xarray *xa)
 	__xa_init(xa, 0);
 }
 
+void *xa_load(struct xarray *, unsigned long index);
+
 #define BITS_PER_XA_VALUE	(BITS_PER_LONG - 1)
 
 /**
@@ -158,6 +162,46 @@ struct xa_node {
 	unsigned long	tags[XA_MAX_TAGS][XA_TAG_LONGS];
 };
 
+#ifdef XA_DEBUG
+void xa_dump(const struct xarray *);
+void xa_dump_node(const struct xa_node *);
+#define XA_BUG_ON(node, x) do { \
+		if ((x) && (node)) \
+			xa_dump_node(node); \
+		BUG_ON(x); \
+	} while (0)
+#else
+#define XA_BUG_ON(node, x)	do { } while (0)
+#endif
+
+/* Private */
+static inline void *xa_head(struct xarray *xa)
+{
+	return rcu_dereference_check(xa->xa_head, xa_lock_held(xa));
+}
+
+/* Private */
+static inline void *xa_head_locked(struct xarray *xa)
+{
+	return rcu_dereference_protected(xa->xa_head, xa_lock_held(xa));
+}
+
+/* Private */
+static inline void *xa_entry(struct xarray *xa,
+				const struct xa_node *node, unsigned int offset)
+{
+	XA_BUG_ON(node, offset >= XA_CHUNK_SIZE);
+	return rcu_dereference_check(node->slots[offset], xa_lock_held(xa));
+}
+
+/* Private */
+static inline void *xa_entry_locked(struct xarray *xa,
+				const struct xa_node *node, unsigned int offset)
+{
+	XA_BUG_ON(node, offset >= XA_CHUNK_SIZE);
+	return rcu_dereference_protected(node->slots[offset], xa_lock_held(xa));
+}
+
 /*
  * Internal entries have the bottom two bits set to the value 10b.  Most
  * internal entries are pointers to the next node in the tree.  Since the
@@ -189,6 +233,12 @@ static inline bool xa_is_internal(void *entry)
 	return ((unsigned long)entry & 3) == 2;
 }
 
+/* Private */
+static inline struct xa_node *xa_to_node(void *entry)
+{
+	return (struct xa_node *)((unsigned long)entry & ~3UL);
+}
+
 /* Private */
 static inline bool xa_is_node(void *entry)
 {
@@ -222,4 +272,189 @@ static inline bool xa_is_sibling(void *entry)
 
 #define XA_RETRY_ENTRY		xa_mk_internal(256)
 
+/**
+ * xa_is_retry() - Is the entry a retry entry?
+ * @entry: Entry retrieved from the XArray
+ *
+ * Return: %true if the entry is a retry entry.
+ */
+static inline bool xa_is_retry(void *entry)
+{
+	return unlikely(entry == XA_RETRY_ENTRY);
+}
+
+/**
+ * typedef xa_update_node_t - A callback function from the XArray.
+ * @node: The node which is being processed
+ *
+ * This function is called every time the XArray updates the count of
+ * present and value entries in a node.  It allows advanced users to
+ * maintain the private_list in the node.
+ */
+typedef void (*xa_update_node_t)(struct xa_node *node);
+
+/*
+ * The xa_state is opaque to its users.  It contains various different pieces
+ * of state involved in the current operation on the XArray.  It should be
+ * declared on the stack and passed between the various internal routines.
+ * The various elements in it should not be accessed directly, but only
+ * through the provided accessor functions.  The below documentation is for
+ * the benefit of those working on the code, not for users of the XArray.
+ *
+ * @xa_node usually points to the xa_node containing the slot we're operating
+ * on (and @xa_offset is the offset in the slots array).  If there is a
+ * single entry in the array at index 0, there are no allocated xa_nodes to
+ * point to, and so we store %NULL in @xa_node.  @xa_node is set to
+ * the value %XAS_RESTART if the xa_state is not walked to the correct
+ * position in the tree of nodes for this operation.  If an error occurs
+ * during an operation, it is set to an %XAS_ERROR value.  If we run off the
+ * end of the allocated nodes, it is set to %XAS_BOUNDS.
+ */
+struct xa_state {
+	struct xarray *xa;
+	unsigned long xa_index;
+	unsigned char xa_shift;
+	unsigned char xa_sibs;
+	unsigned char xa_offset;
+	unsigned char xa_pad;		/* Helps gcc generate better code */
+	struct xa_node *xa_node;
+	struct xa_node *xa_alloc;
+	xa_update_node_t xa_update;
+};
+
+/*
+ * We encode errnos in the xas->xa_node.  If an error has happened, we need to
+ * drop the lock to fix it, and once we've done so the xa_state is invalid.
+ */
+#define XAS_ERROR(errno) ((struct xa_node *)(((unsigned long)errno << 1) | 1))
+#define XAS_RESTART	 XAS_ERROR(0)
+#define XAS_BOUNDS	 ((struct xa_node *)2UL)
+
+#define __XA_STATE(array, index)  {			\
+	.xa = array,					\
+	.xa_index = index,				\
+	.xa_shift = 0,					\
+	.xa_sibs = 0,					\
+	.xa_offset = 0,					\
+	.xa_pad = 0,					\
+	.xa_node = XAS_RESTART,				\
+	.xa_alloc = NULL,				\
+	.xa_update = NULL				\
+}
+
+/**
+ * XA_STATE() - Declare an XArray operation state.
+ * @name: Name of this operation state (usually xas).
+ * @index: Initial index of interest.
+ *
+ * Declare and initialise an xa_state on the stack.
+ */
+#define XA_STATE(name, array, index)			\
+	struct xa_state name = __XA_STATE(array, index)
+
+#define xas_tagged(xas, tag)	xa_tagged((xas)->xa, (tag))
+#define xas_trylock(xas)	xa_trylock((xas)->xa)
+#define xas_lock(xas)		xa_lock((xas)->xa)
+#define xas_unlock(xas)		xa_unlock((xas)->xa)
+#define xas_lock_bh(xas)	xa_lock_bh((xas)->xa)
+#define xas_unlock_bh(xas)	xa_unlock_bh((xas)->xa)
+#define xas_lock_irq(xas)	xa_lock_irq((xas)->xa)
+#define xas_unlock_irq(xas)	xa_unlock_irq((xas)->xa)
+#define xas_lock_irqsave(xas, flags) \
+				xa_lock_irqsave((xas)->xa, flags)
+#define xas_unlock_irqrestore(xas, flags) \
+				xa_unlock_irqrestore((xas)->xa, flags)
+
+/**
+ * xas_error() - Return an errno stored in the xa_state.
+ * @xas: XArray operation state.
+ *
+ * Return: 0 if no error has been noted.  A negative errno if one has.
+ */
+static inline int xas_error(const struct xa_state *xas)
+{
+	unsigned long v = (unsigned long)xas->xa_node;
+	return (v & 1) ? -(v >> 1) : 0;
+}
+
+/**
+ * xas_set_err() - Note an error in the xa_state.
+ * @xas: XArray operation state.
+ * @err: Negative error number.
+ *
+ * You can call this function with @err set to 0 to take the xa_state
+ * out of the error state.  The next operation will walk it to the correct
+ * location.
+ */
+static inline void xas_set_err(struct xa_state *xas, long err)
+{
+	xas->xa_node = XAS_ERROR(-err);
+}
+
+/**
+ * xas_invalid() - Is the xas in a retry or error state?
+ * @xas: XArray operation state.
+ *
+ * Return: %true if the xas cannot be used for operations.
+ */
+static inline bool xas_invalid(const struct xa_state *xas)
+{
+	return (unsigned long)xas->xa_node & 3;
+}
+
+/**
+ * xas_valid() - Is the xas a valid cursor into the array?
+ * @xas: XArray operation state.
+ *
+ * Return: %true if the xas can be used for operations.
+ */
+static inline bool xas_valid(const struct xa_state *xas)
+{
+	return !xas_invalid(xas);
+}
+
+/**
+ * xas_retry() - Handle a retry entry.
+ * @xas: XArray operation state.
+ * @entry: Entry from xarray.
+ *
+ * An RCU-protected read may see a retry entry as a side-effect of a
+ * simultaneous modification.  This function sets up the @xas to retry
+ * the walk from the head of the array.
+ *
+ * Return: true if the operation needs to be retried.
+ */
+static inline bool xas_retry(struct xa_state *xas, void *entry)
+{
+	if (!xa_is_retry(entry))
+		return false;
+	xas->xa_node = XAS_RESTART;
+	return true;
+}
+
+void *xas_load(struct xa_state *);
+
+/**
+ * xas_reload() - Refetch an entry from the xarray.
+ * @xas: XArray operation state.
+ *
+ * Use this function to check that a previously loaded entry still has
+ * the same value.  This is useful for the lockless pagecache lookup where
+ * we walk the array with only the RCU lock to protect us, lock the page,
+ * then check that the page hasn't moved since we looked it up.
+ *
+ * The caller guarantees that @xas is still valid.  If it may be in an
+ * error or restart state, call xas_load() instead.
+ *
+ * Return: The entry at this location in the xarray.
+ */
+static inline void *xas_reload(struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_node;
+
+	if (node)
+		return xa_entry(xas->xa, node, xas->xa_offset);
+	return xa_head(xas->xa);
+}
+
 #endif /* _LINUX_XARRAY_H */
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 930eb7d298d7..a919c60b10a4 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -255,49 +255,6 @@ static unsigned long next_index(unsigned long index,
 }
 
 #ifndef __KERNEL__
-static void dump_node(struct radix_tree_node *node, unsigned long index)
-{
-	unsigned long i;
-
-	pr_debug("radix node: %p offset %d indices %lu-%lu parent %p tags %lx %lx %lx shift %d count %d exceptional %d\n",
-		node, node->offset, index, index | node_maxindex(node),
-		node->parent,
-		node->tags[0][0], node->tags[1][0], node->tags[2][0],
-		node->shift, node->count, node->exceptional);
-
-	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
-		unsigned long first = index | (i << node->shift);
-		unsigned long last = first | ((1UL << node->shift) - 1);
-		void *entry = node->slots[i];
-		if (!entry)
-			continue;
-		if (entry == RADIX_TREE_RETRY) {
-			pr_debug("radix retry offset %ld indices %lu-%lu parent %p\n",
-					i, first, last, node);
-		} else if (!radix_tree_is_internal_node(entry)) {
-			pr_debug("radix entry %p offset %ld indices %lu-%lu parent %p\n",
-					entry, i, first, last, node);
-		} else if (xa_is_sibling(entry)) {
-			pr_debug("radix sblng %p offset %ld indices %lu-%lu parent %p val %p\n",
-					entry, i, first, last, node,
-					node->slots[xa_to_sibling(entry)]);
-		} else {
-			dump_node(entry_to_node(entry), first);
-		}
-	}
-}
-
-/* For debug */
-static void radix_tree_dump(struct radix_tree_root *root)
-{
-	pr_debug("radix root: %p xa_head %p tags %x\n",
-			root, root->xa_head,
-			root->xa_flags >> ROOT_TAG_SHIFT);
-	if (!radix_tree_is_internal_node(root->xa_head))
-		return;
-	dump_node(entry_to_node(root->xa_head), 0);
-}
-
 static void dump_ida_node(void *entry, unsigned long index)
 {
 	unsigned long i;
diff --git a/lib/xarray.c b/lib/xarray.c
index 67ddcb3e630c..2f77e4c5d0b8 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -31,6 +31,94 @@
  * @entry refers to something stored in a slot in the xarray
  */
 
+/* extracts the offset within this node from the index */
+static unsigned int get_offset(unsigned long index, struct xa_node *node)
+{
+	return (index >> node->shift) & XA_CHUNK_MASK;
+}
+
+static void *set_bounds(struct xa_state *xas)
+{
+	xas->xa_node = XAS_BOUNDS;
+	return NULL;
+}
+
+/*
+ * Starts a walk.  If the @xas is already valid, we assume that it's on
+ * the right path and just return where we've got to.  If we're in an
+ * error state, return NULL.  If the index is outside the current scope
+ * of the xarray, return NULL without changing @xas->xa_node.  Otherwise
+ * set @xas->xa_node to NULL and return the current head of the array.
+ */
+static void *xas_start(struct xa_state *xas)
+{
+	void *entry;
+
+	if (xas_valid(xas))
+		return xas_reload(xas);
+	if (xas_error(xas))
+		return NULL;
+
+	entry = xa_head(xas->xa);
+	if (!xa_is_node(entry)) {
+		if (xas->xa_index)
+			return set_bounds(xas);
+	} else {
+		if ((xas->xa_index >> xa_to_node(entry)->shift) > XA_CHUNK_MASK)
+			return set_bounds(xas);
+	}
+
+	xas->xa_node = NULL;
+	return entry;
+}
+
+static void *xas_descend(struct xa_state *xas, struct xa_node *node)
+{
+	unsigned int offset = get_offset(xas->xa_index, node);
+	void *entry = xa_entry(xas->xa, node, offset);
+
+	if (xa_is_sibling(entry)) {
+		offset = xa_to_sibling(entry);
+		entry = xa_entry(xas->xa, node, offset);
+		/* Move xa_index to the first index of this entry */
+		xas->xa_index = (((xas->xa_index >> node->shift) &
+				  ~XA_CHUNK_MASK) | offset) << node->shift;
+	}
+
+	xas->xa_node = node;
+	xas->xa_offset = offset;
+	return entry;
+}
+
+/**
+ * xas_load() - Load an entry from the XArray (advanced).
+ * @xas: XArray operation state.
+ *
+ * Usually walks the @xas to the appropriate state to load the entry stored
+ * at xa_index.  However, it will do nothing and return NULL  if @xas is
+ * holding an error.  If the xa_shift indicates we're operating on a
+ * multislot entry, it will terminate early and potentially return an
+ * internal entry.  xas_load() will never expand the tree (see xas_create()).
+ *
+ * The caller should hold the xa_lock or the RCU lock.
+ *
+ * Return: Usually an entry in the XArray, but see description for exceptions.
+ */
+void *xas_load(struct xa_state *xas)
+{
+	void *entry = xas_start(xas);
+
+	while (xa_is_node(entry)) {
+		struct xa_node *node = xa_to_node(entry);
+
+		if (xas->xa_shift > node->shift)
+			break;
+		entry = xas_descend(xas, node);
+	}
+	return entry;
+}
+EXPORT_SYMBOL_GPL(xas_load);
+
 /**
  * __xa_init() - Initialise an empty XArray.
  * @xa: XArray.
@@ -45,3 +133,75 @@ void __xa_init(struct xarray *xa, gfp_t flags)
 	xa->xa_head = NULL;
 }
 EXPORT_SYMBOL(__xa_init);
+
+/**
+ * xa_load() - Load an entry from an XArray.
+ * @xa: XArray.
+ * @index: index into array.
+ *
+ * Return: The entry at @index in @xa.
+ */
+void *xa_load(struct xarray *xa, unsigned long index)
+{
+	XA_STATE(xas, xa, index);
+	void *entry;
+
+	rcu_read_lock();
+	do {
+		entry = xas_load(&xas);
+	} while (xas_retry(&xas, entry));
+	rcu_read_unlock();
+
+	return entry;
+}
+EXPORT_SYMBOL(xa_load);
+
+#ifdef XA_DEBUG
+void xa_dump_entry(void *entry, unsigned long index)
+{
+	if (!entry)
+		return;
+
+	if (xa_is_value(entry))
+		printk("%lu: value %#lx\n", index, xa_to_value(entry));
+	else if (!xa_is_internal(entry))
+		printk("%lu: %p\n", index, entry);
+	else if (xa_is_node(entry)) {
+		unsigned long i;
+		struct xa_node *node = xa_to_node(entry);
+		printk("node %p %s %d parent %p shift %d count %d "
+			"exceptional %d tags %lx %lx %lx indices %lu-%lu\n",
+			node, node->parent ? "offset" : "max", node->offset,
+			node->parent, node->shift, node->count,
+			node->exceptional,
+			node->tags[0][0], node->tags[1][0], node->tags[2][0],
+			index, index |
+			(((unsigned long)XA_CHUNK_SIZE << node->shift) - 1));
+		for (i = 0; i < XA_CHUNK_SIZE; i++)
+			xa_dump_entry(node->slots[i],
+					index + (i << node->shift));
+	} else if (xa_is_retry(entry))
+		printk("%lu: retry (%ld)\n", index, xa_to_internal(entry));
+	else if (xa_is_sibling(entry))
+		printk("%lu: sibling (%ld)\n", index, xa_to_sibling(entry));
+	else
+		printk("%lu: UNKNOWN ENTRY (%p)\n", index, entry);
+}
+
+void xa_dump_node(const struct xa_node *node)
+{
+	printk("xadn: node %p %s %d parent %p shift %d count %d "
+		"exceptional %d array %p list %p %p tags %lx %lx %lx\n",
+		node, node->parent ? "offset" : "max", node->offset,
+		node->parent, node->shift, node->count,
+		node->exceptional, node->root, node->private_list.prev,
+		node->private_list.next,
+		node->tags[0][0], node->tags[1][0], node->tags[2][0]);
+}
+
+void xa_dump(const struct xarray *xa)
+{
+	printk("xarray: %p %x %p\n", xa, xa->xa_flags, xa->xa_head);
+	xa_dump_entry(xa->xa_head, 0);
+}
+#endif
diff --git a/tools/testing/radix-tree/.gitignore b/tools/testing/radix-tree/.gitignore
index 8d4df7a72a8e..833136896b91 100644
--- a/tools/testing/radix-tree/.gitignore
+++ b/tools/testing/radix-tree/.gitignore
@@ -5,3 +5,4 @@ main
 multiorder
 radix-tree.c
 xarray.c
+xarray-test
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index 3868bc189199..749ef734a87c 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -3,10 +3,11 @@
 CFLAGS += -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE -fsanitize=address
 LDFLAGS += -fsanitize=address
 LDLIBS+= -lpthread -lurcu
-TARGETS = main idr-test multiorder
+TARGETS = main idr-test multiorder xarray-test
 CORE_OFILES := xarray.o radix-tree.o idr.o linux.o test.o find_bit.o
 OFILES = main.o $(CORE_OFILES) regression1.o regression2.o regression3.o \
-	 tag_check.o multiorder.o idr-test.o iteration_check.o benchmark.o
+	 tag_check.o multiorder.o idr-test.o iteration_check.o benchmark.o \
+	 xarray-test.o
 
 ifndef SHIFT
 	SHIFT=3
@@ -23,6 +24,8 @@ main:	$(OFILES)
 
 idr-test: idr-test.o $(CORE_OFILES)
 
+xarray-test: idr-test.o $(CORE_OFILES)
+
 multiorder: multiorder.o $(CORE_OFILES)
 
 clean:
diff --git a/tools/testing/radix-tree/linux/radix-tree.h b/tools/testing/radix-tree/linux/radix-tree.h
index 40c9671ee365..36fb716d5557 100644
--- a/tools/testing/radix-tree/linux/radix-tree.h
+++ b/tools/testing/radix-tree/linux/radix-tree.h
@@ -5,7 +5,6 @@
 #include "generated/map-shift.h"
 #include "linux/bug.h"
 #include "../../../../include/linux/radix-tree.h"
-#include <linux/xarray.h>
 
 extern int kmalloc_verbose;
 extern int test_verbose;
diff --git a/tools/testing/radix-tree/linux/rcupdate.h b/tools/testing/radix-tree/linux/rcupdate.h
index 73ed33658203..25010bf86c1d 100644
--- a/tools/testing/radix-tree/linux/rcupdate.h
+++ b/tools/testing/radix-tree/linux/rcupdate.h
@@ -6,5 +6,6 @@
 
 #define rcu_dereference_raw(p) rcu_dereference(p)
 #define rcu_dereference_protected(p, cond) rcu_dereference(p)
+#define rcu_dereference_check(p, cond) rcu_dereference(p)
 
 #endif
diff --git a/tools/testing/radix-tree/linux/xarray.h b/tools/testing/radix-tree/linux/xarray.h
index df3812cda376..3eaf9596c2a6 100644
--- a/tools/testing/radix-tree/linux/xarray.h
+++ b/tools/testing/radix-tree/linux/xarray.h
@@ -1,2 +1,3 @@
 #include "generated/map-shift.h"
+#define XA_DEBUG
 #include "../../../../include/linux/xarray.h"
diff --git a/tools/testing/radix-tree/xarray-test.c b/tools/testing/radix-tree/xarray-test.c
new file mode 100644
index 000000000000..3f8f19cb3739
--- /dev/null
+++ b/tools/testing/radix-tree/xarray-test.c
@@ -0,0 +1,56 @@
+/*
+ * xarray-test.c: Test the XArray API
+ * Copyright (c) 2017 Microsoft Corporation <mawilcox@microsoft.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+#include <linux/bitmap.h>
+#include <linux/xarray.h>
+#include <linux/slab.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+
+#include "test.h"
+
+void check_xa_load(struct xarray *xa)
+{
+	unsigned long i, j;
+
+	for (i = 0; i < 1024; i++) {
+		for (j = 0; j < 1024; j++) {
+			void *entry = xa_load(xa, j);
+			if (j < i)
+				assert(xa_to_value(entry) == j);
+			else
+				assert(!entry);
+		}
+		radix_tree_insert(xa, i, xa_mk_value(i));
+	}
+}
+
+void xarray_checks(void)
+{
+	RADIX_TREE(array, GFP_KERNEL);
+
+	check_xa_load(&array);
+
+	item_kill_tree(&array);
+}
+
+int __weak main(void)
+{
+	radix_tree_init();
+	xarray_checks();
+	radix_tree_cpu_dead(1);
+	rcu_barrier();
+	if (nr_allocated)
+		printf("nr_allocated = %d\n", nr_allocated);
+	return 0;
+}
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

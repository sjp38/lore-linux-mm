Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2804B6B025F
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:22:33 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n187so15059727pfn.10
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:22:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k7si4583227pgk.685.2018.01.17.12.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:22:30 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 05/99] xarray: Add definition of struct xarray
Date: Wed, 17 Jan 2018 12:20:29 -0800
Message-Id: <20180117202203.19756-6-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This is a direct replacement for struct radix_tree_root.  Some of the
struct members have changed name; convert those, and use a #define so
that radix_tree users continue to work without change.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/radix-tree.h               | 33 ++++----------
 include/linux/xarray.h                   | 59 +++++++++++++++++++++++++
 lib/Makefile                             |  2 +-
 lib/idr.c                                |  4 +-
 lib/radix-tree.c                         | 75 ++++++++++++++++----------------
 lib/xarray.c                             | 42 ++++++++++++++++++
 tools/include/linux/spinlock.h           |  1 +
 tools/testing/radix-tree/.gitignore      |  1 +
 tools/testing/radix-tree/Makefile        |  8 +++-
 tools/testing/radix-tree/linux/bug.h     |  1 +
 tools/testing/radix-tree/linux/kconfig.h |  1 +
 tools/testing/radix-tree/linux/xarray.h  |  2 +
 tools/testing/radix-tree/multiorder.c    |  6 +--
 tools/testing/radix-tree/test.c          |  6 +--
 14 files changed, 168 insertions(+), 73 deletions(-)
 create mode 100644 lib/xarray.c
 create mode 100644 tools/testing/radix-tree/linux/kconfig.h
 create mode 100644 tools/testing/radix-tree/linux/xarray.h

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 87f35fe00e55..c8a33e9e9a3c 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -30,6 +30,9 @@
 #include <linux/types.h>
 #include <linux/xarray.h>
 
+/* Keep unconverted code working */
+#define radix_tree_root		xarray
+
 /*
  * The bottom two bits of the slot determine how the remaining bits in the
  * slot are interpreted:
@@ -59,10 +62,7 @@ static inline bool radix_tree_is_internal_node(void *ptr)
 
 #define RADIX_TREE_MAX_TAGS 3
 
-#ifndef RADIX_TREE_MAP_SHIFT
-#define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
-#endif
-
+#define RADIX_TREE_MAP_SHIFT	XA_CHUNK_SHIFT
 #define RADIX_TREE_MAP_SIZE	(1UL << RADIX_TREE_MAP_SHIFT)
 #define RADIX_TREE_MAP_MASK	(RADIX_TREE_MAP_SIZE-1)
 
@@ -95,36 +95,21 @@ struct radix_tree_node {
 	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
 };
 
-/* The IDR tag is stored in the low bits of the GFP flags */
+/* The IDR tag is stored in the low bits of xa_flags */
 #define ROOT_IS_IDR	((__force gfp_t)4)
-/* The top bits of gfp_mask are used to store the root tags */
+/* The top bits of xa_flags are used to store the root tags */
 #define ROOT_TAG_SHIFT	(__GFP_BITS_SHIFT)
 
-struct radix_tree_root {
-	spinlock_t		xa_lock;
-	gfp_t			gfp_mask;
-	struct radix_tree_node	__rcu *rnode;
-};
-
-#define RADIX_TREE_INIT(name, mask)	{				\
-	.xa_lock = __SPIN_LOCK_UNLOCKED(name.xa_lock),			\
-	.gfp_mask = (mask),						\
-	.rnode = NULL,							\
-}
+#define RADIX_TREE_INIT(name, mask)	XARRAY_INIT_FLAGS(name, mask)
 
 #define RADIX_TREE(name, mask) \
 	struct radix_tree_root name = RADIX_TREE_INIT(name, mask)
 
-#define INIT_RADIX_TREE(root, mask)					\
-do {									\
-	spin_lock_init(&(root)->xa_lock);				\
-	(root)->gfp_mask = (mask);					\
-	(root)->rnode = NULL;						\
-} while (0)
+#define INIT_RADIX_TREE(root, mask) xa_init_flags(root, mask)
 
 static inline bool radix_tree_empty(const struct radix_tree_root *root)
 {
-	return root->rnode == NULL;
+	return root->xa_head == NULL;
 }
 
 /**
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index c308152fde7f..3d2f1fafb7ec 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -10,6 +10,8 @@
  */
 
 #include <linux/bug.h>
+#include <linux/compiler.h>
+#include <linux/kconfig.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
@@ -99,6 +101,63 @@ static inline bool xa_is_internal(const void *entry)
 	return ((unsigned long)entry & 3) == 2;
 }
 
+/**
+ * struct xarray - The anchor of the XArray.
+ * @xa_lock: Lock that protects the contents of the XArray.
+ *
+ * To use the xarray, define it statically or embed it in your data structure.
+ * It is a very small data structure, so it does not usually make sense to
+ * allocate it separately and keep a pointer to it in your data structure.
+ *
+ * You may use the xa_lock to protect your own data structures as well.
+ */
+/*
+ * If all of the entries in the array are NULL, @xa_head is a NULL pointer.
+ * If the only non-NULL entry in the array is at index 0, @xa_head is that
+ * entry.  If any other entry in the array is non-NULL, @xa_head points
+ * to an @xa_node.
+ */
+struct xarray {
+	spinlock_t	xa_lock;
+/* private: The rest of the data structure is not to be used directly. */
+	gfp_t		xa_flags;
+	void __rcu *	xa_head;
+};
+
+#define XARRAY_INIT_FLAGS(name, flags) {			\
+	.xa_lock = __SPIN_LOCK_UNLOCKED(name.xa_lock),		\
+	.xa_flags = flags,					\
+	.xa_head = NULL,					\
+}
+
+#define XARRAY_INIT(name) XARRAY_INIT_FLAGS(name, 0)
+
+/**
+ * DEFINE_XARRAY() - Define an XArray
+ * @name: A string that names your XArray
+ *
+ * This is intended for file scope definitions of XArrays.  It declares
+ * and initialises an empty XArray with the chosen name.  It is equivalent
+ * to calling xa_init() on the array, but it does the initialisation at
+ * compiletime instead of runtime.
+ */
+#define DEFINE_XARRAY(name) struct xarray name = XARRAY_INIT(name)
+#define DEFINE_XARRAY_FLAGS(name, flags) \
+			struct xarray name = XARRAY_INIT_FLAGS(name, flags)
+
+void xa_init_flags(struct xarray *, gfp_t flags);
+
+/**
+ * xa_init() - Initialise an empty XArray.
+ * @xa: XArray.
+ *
+ * An empty XArray is full of NULL entries.
+ */
+static inline void xa_init(struct xarray *xa)
+{
+	xa_init_flags(xa, 0);
+}
+
 #define xa_trylock(xa)		spin_trylock(&(xa)->xa_lock)
 #define xa_lock(xa)		spin_lock(&(xa)->xa_lock)
 #define xa_unlock(xa)		spin_unlock(&(xa)->xa_lock)
diff --git a/lib/Makefile b/lib/Makefile
index d11c48ec8ffd..6aa523acc7c1 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -18,7 +18,7 @@ KCOV_INSTRUMENT_debugobjects.o := n
 KCOV_INSTRUMENT_dynamic_debug.o := n
 
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
-	 rbtree.o radix-tree.o dump_stack.o timerqueue.o\
+	 rbtree.o radix-tree.o dump_stack.o timerqueue.o xarray.o \
 	 idr.o int_sqrt.o extable.o \
 	 sha1.o chacha20.o irq_regs.o argv_split.o \
 	 flex_proportions.o ratelimit.o show_mem.o \
diff --git a/lib/idr.c b/lib/idr.c
index 48c53890adc0..b9aa08e198a2 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -35,8 +35,8 @@ int idr_alloc_ul(struct idr *idr, void *ptr, unsigned long *nextid,
 	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
 		return -EINVAL;
 
-	if (WARN_ON_ONCE(!(idr->idr_rt.gfp_mask & ROOT_IS_IDR)))
-		idr->idr_rt.gfp_mask |= IDR_RT_MARKER;
+	if (WARN_ON_ONCE(!(idr->idr_rt.xa_flags & ROOT_IS_IDR)))
+		idr->idr_rt.xa_flags |= IDR_RT_MARKER;
 
 	radix_tree_iter_init(&iter, *nextid);
 	slot = idr_get_free(&idr->idr_rt, &iter, gfp, max);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index f16f63d15edc..126eeb06cfef 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -123,7 +123,7 @@ static unsigned int radix_tree_descend(const struct radix_tree_node *parent,
 
 static inline gfp_t root_gfp_mask(const struct radix_tree_root *root)
 {
-	return root->gfp_mask & ((__GFP_BITS_MASK >> 4) << 4);
+	return root->xa_flags & ((__GFP_BITS_MASK >> 4) << 4);
 }
 
 static inline void tag_set(struct radix_tree_node *node, unsigned int tag,
@@ -146,32 +146,32 @@ static inline int tag_get(const struct radix_tree_node *node, unsigned int tag,
 
 static inline void root_tag_set(struct radix_tree_root *root, unsigned tag)
 {
-	root->gfp_mask |= (__force gfp_t)(1 << (tag + ROOT_TAG_SHIFT));
+	root->xa_flags |= (__force gfp_t)(1 << (tag + ROOT_TAG_SHIFT));
 }
 
 static inline void root_tag_clear(struct radix_tree_root *root, unsigned tag)
 {
-	root->gfp_mask &= (__force gfp_t)~(1 << (tag + ROOT_TAG_SHIFT));
+	root->xa_flags &= (__force gfp_t)~(1 << (tag + ROOT_TAG_SHIFT));
 }
 
 static inline void root_tag_clear_all(struct radix_tree_root *root)
 {
-	root->gfp_mask &= (1 << ROOT_TAG_SHIFT) - 1;
+	root->xa_flags &= (__force gfp_t)((1 << ROOT_TAG_SHIFT) - 1);
 }
 
 static inline int root_tag_get(const struct radix_tree_root *root, unsigned tag)
 {
-	return (__force int)root->gfp_mask & (1 << (tag + ROOT_TAG_SHIFT));
+	return (__force int)root->xa_flags & (1 << (tag + ROOT_TAG_SHIFT));
 }
 
 static inline unsigned root_tags_get(const struct radix_tree_root *root)
 {
-	return (__force unsigned)root->gfp_mask >> ROOT_TAG_SHIFT;
+	return (__force unsigned)root->xa_flags >> ROOT_TAG_SHIFT;
 }
 
 static inline bool is_idr(const struct radix_tree_root *root)
 {
-	return !!(root->gfp_mask & ROOT_IS_IDR);
+	return !!(root->xa_flags & ROOT_IS_IDR);
 }
 
 /*
@@ -290,12 +290,12 @@ static void dump_node(struct radix_tree_node *node, unsigned long index)
 /* For debug */
 static void radix_tree_dump(struct radix_tree_root *root)
 {
-	pr_debug("radix root: %p rnode %p tags %x\n",
-			root, root->rnode,
-			root->gfp_mask >> ROOT_TAG_SHIFT);
-	if (!radix_tree_is_internal_node(root->rnode))
+	pr_debug("radix root: %p xa_head %p tags %x\n",
+			root, root->xa_head,
+			root->xa_flags >> ROOT_TAG_SHIFT);
+	if (!radix_tree_is_internal_node(root->xa_head))
 		return;
-	dump_node(entry_to_node(root->rnode), 0);
+	dump_node(entry_to_node(root->xa_head), 0);
 }
 
 static void dump_ida_node(void *entry, unsigned long index)
@@ -339,9 +339,9 @@ static void dump_ida_node(void *entry, unsigned long index)
 static void ida_dump(struct ida *ida)
 {
 	struct radix_tree_root *root = &ida->ida_rt;
-	pr_debug("ida: %p node %p free %d\n", ida, root->rnode,
-				root->gfp_mask >> ROOT_TAG_SHIFT);
-	dump_ida_node(root->rnode, 0);
+	pr_debug("ida: %p node %p free %d\n", ida, root->xa_head,
+				root->xa_flags >> ROOT_TAG_SHIFT);
+	dump_ida_node(root->xa_head, 0);
 }
 #endif
 
@@ -575,7 +575,7 @@ int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order)
 static unsigned radix_tree_load_root(const struct radix_tree_root *root,
 		struct radix_tree_node **nodep, unsigned long *maxindex)
 {
-	struct radix_tree_node *node = rcu_dereference_raw(root->rnode);
+	struct radix_tree_node *node = rcu_dereference_raw(root->xa_head);
 
 	*nodep = node;
 
@@ -604,7 +604,7 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 	while (index > shift_maxindex(maxshift))
 		maxshift += RADIX_TREE_MAP_SHIFT;
 
-	entry = rcu_dereference_raw(root->rnode);
+	entry = rcu_dereference_raw(root->xa_head);
 	if (!entry && (!is_idr(root) || root_tag_get(root, IDR_FREE)))
 		goto out;
 
@@ -632,7 +632,7 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 		if (radix_tree_is_internal_node(entry)) {
 			entry_to_node(entry)->parent = node;
 		} else if (xa_is_value(entry)) {
-			/* Moving an exceptional root->rnode to a node */
+			/* Moving an exceptional root->xa_head to a node */
 			node->exceptional = 1;
 		}
 		/*
@@ -641,7 +641,7 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 		 */
 		node->slots[0] = (void __rcu *)entry;
 		entry = node_to_entry(node);
-		rcu_assign_pointer(root->rnode, entry);
+		rcu_assign_pointer(root->xa_head, entry);
 		shift += RADIX_TREE_MAP_SHIFT;
 	} while (shift <= maxshift);
 out:
@@ -658,7 +658,7 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
 	bool shrunk = false;
 
 	for (;;) {
-		struct radix_tree_node *node = rcu_dereference_raw(root->rnode);
+		struct radix_tree_node *node = rcu_dereference_raw(root->xa_head);
 		struct radix_tree_node *child;
 
 		if (!radix_tree_is_internal_node(node))
@@ -686,9 +686,9 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
 		 * moving the node from one part of the tree to another: if it
 		 * was safe to dereference the old pointer to it
 		 * (node->slots[0]), it will be safe to dereference the new
-		 * one (root->rnode) as far as dependent read barriers go.
+		 * one (root->xa_head) as far as dependent read barriers go.
 		 */
-		root->rnode = (void __rcu *)child;
+		root->xa_head = (void __rcu *)child;
 		if (is_idr(root) && !tag_get(node, IDR_FREE, 0))
 			root_tag_clear(root, IDR_FREE);
 
@@ -736,9 +736,8 @@ static bool delete_node(struct radix_tree_root *root,
 
 		if (node->count) {
 			if (node_to_entry(node) ==
-					rcu_dereference_raw(root->rnode))
-				deleted |= radix_tree_shrink(root,
-								update_node);
+					rcu_dereference_raw(root->xa_head))
+				deleted |= radix_tree_shrink(root, update_node);
 			return deleted;
 		}
 
@@ -753,7 +752,7 @@ static bool delete_node(struct radix_tree_root *root,
 			 */
 			if (!is_idr(root))
 				root_tag_clear_all(root);
-			root->rnode = NULL;
+			root->xa_head = NULL;
 		}
 
 		WARN_ON_ONCE(!list_empty(&node->private_list));
@@ -778,7 +777,7 @@ static bool delete_node(struct radix_tree_root *root,
  *	at position @index in the radix tree @root.
  *
  *	Until there is more than one item in the tree, no nodes are
- *	allocated and @root->rnode is used as a direct slot instead of
+ *	allocated and @root->xa_head is used as a direct slot instead of
  *	pointing to a node, in which case *@nodep will be NULL.
  *
  *	Returns -ENOMEM, or 0 for success.
@@ -788,7 +787,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			void __rcu ***slotp)
 {
 	struct radix_tree_node *node = NULL, *child;
-	void __rcu **slot = (void __rcu **)&root->rnode;
+	void __rcu **slot = (void __rcu **)&root->xa_head;
 	unsigned long maxindex;
 	unsigned int shift, offset = 0;
 	unsigned long max = index | ((1UL << order) - 1);
@@ -804,7 +803,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 		if (error < 0)
 			return error;
 		shift = error;
-		child = rcu_dereference_raw(root->rnode);
+		child = rcu_dereference_raw(root->xa_head);
 	}
 
 	while (shift > order) {
@@ -995,7 +994,7 @@ EXPORT_SYMBOL(__radix_tree_insert);
  *	tree @root.
  *
  *	Until there is more than one item in the tree, no nodes are
- *	allocated and @root->rnode is used as a direct slot instead of
+ *	allocated and @root->xa_head is used as a direct slot instead of
  *	pointing to a node, in which case *@nodep will be NULL.
  */
 void *__radix_tree_lookup(const struct radix_tree_root *root,
@@ -1008,7 +1007,7 @@ void *__radix_tree_lookup(const struct radix_tree_root *root,
 
  restart:
 	parent = NULL;
-	slot = (void __rcu **)&root->rnode;
+	slot = (void __rcu **)&root->xa_head;
 	radix_tree_load_root(root, &node, &maxindex);
 	if (index > maxindex)
 		return NULL;
@@ -1160,9 +1159,9 @@ void __radix_tree_replace(struct radix_tree_root *root,
 	/*
 	 * This function supports replacing exceptional entries and
 	 * deleting entries, but that needs accounting against the
-	 * node unless the slot is root->rnode.
+	 * node unless the slot is root->xa_head.
 	 */
-	WARN_ON_ONCE(!node && (slot != (void __rcu **)&root->rnode) &&
+	WARN_ON_ONCE(!node && (slot != (void __rcu **)&root->xa_head) &&
 			(count || exceptional));
 	replace_slot(slot, item, node, count, exceptional);
 
@@ -1714,7 +1713,7 @@ void __rcu **radix_tree_next_chunk(const struct radix_tree_root *root,
 		iter->tags = 1;
 		iter->node = NULL;
 		__set_iter_shift(iter, 0);
-		return (void __rcu **)&root->rnode;
+		return (void __rcu **)&root->xa_head;
 	}
 
 	do {
@@ -2108,7 +2107,7 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 			      unsigned long max)
 {
 	struct radix_tree_node *node = NULL, *child;
-	void __rcu **slot = (void __rcu **)&root->rnode;
+	void __rcu **slot = (void __rcu **)&root->xa_head;
 	unsigned long maxindex, start = iter->next_index;
 	unsigned int shift, offset = 0;
 
@@ -2124,7 +2123,7 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 		if (error < 0)
 			return ERR_PTR(error);
 		shift = error;
-		child = rcu_dereference_raw(root->rnode);
+		child = rcu_dereference_raw(root->xa_head);
 	}
 
 	while (shift) {
@@ -2187,10 +2186,10 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
  */
 void idr_destroy(struct idr *idr)
 {
-	struct radix_tree_node *node = rcu_dereference_raw(idr->idr_rt.rnode);
+	struct radix_tree_node *node = rcu_dereference_raw(idr->idr_rt.xa_head);
 	if (radix_tree_is_internal_node(node))
 		radix_tree_free_nodes(node);
-	idr->idr_rt.rnode = NULL;
+	idr->idr_rt.xa_head = NULL;
 	root_tag_set(&idr->idr_rt, IDR_FREE);
 }
 EXPORT_SYMBOL(idr_destroy);
diff --git a/lib/xarray.c b/lib/xarray.c
new file mode 100644
index 000000000000..c56b0f858e10
--- /dev/null
+++ b/lib/xarray.c
@@ -0,0 +1,42 @@
+/* SPDX-License-Identifier: GPL-2.0+ */
+/*
+ * XArray implementation
+ * Copyright (c) 2017 Microsoft Corporation
+ * Author: Matthew Wilcox <mawilcox@microsoft.com>
+ */
+
+#include <linux/export.h>
+#include <linux/xarray.h>
+
+/*
+ * Coding conventions in this file:
+ *
+ * @xa is used to refer to the entire xarray.
+ * @xas is the 'xarray operation state'.  It may be either a pointer to
+ * an xa_state, or an xa_state stored on the stack.  This is an unfortunate
+ * ambiguity.
+ * @index is the index of the entry being operated on
+ * @tag is an xa_tag_t; a small number indicating one of the tag bits.
+ * @node refers to an xa_node; usually the primary one being operated on by
+ * this function.
+ * @offset is the index into the slots array inside an xa_node.
+ * @parent refers to the @xa_node closer to the head than @node.
+ * @entry refers to something stored in a slot in the xarray
+ */
+
+/**
+ * xa_init_flags() - Initialise an empty XArray with flags.
+ * @xa: XArray.
+ * @flags: XA_FLAG values.
+ *
+ * If you need to initialise an XArray with special flags (eg you need
+ * to take the lock from interrupt context), use this function instead
+ * of xa_init().
+ */
+void xa_init_flags(struct xarray *xa, gfp_t flags)
+{
+	spin_lock_init(&xa->xa_lock);
+	xa->xa_flags = flags;
+	xa->xa_head = NULL;
+}
+EXPORT_SYMBOL(xa_init_flags);
diff --git a/tools/include/linux/spinlock.h b/tools/include/linux/spinlock.h
index b21b586b9854..34fed5c38da2 100644
--- a/tools/include/linux/spinlock.h
+++ b/tools/include/linux/spinlock.h
@@ -8,6 +8,7 @@
 #define spinlock_t		pthread_mutex_t
 #define DEFINE_SPINLOCK(x)	pthread_mutex_t x = PTHREAD_MUTEX_INITIALIZER;
 #define __SPIN_LOCK_UNLOCKED(x)	(pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER
+#define spin_lock_init(x)	pthread_mutex_init(x, NULL);
 
 #define spin_lock_irqsave(x, f)		(void)f, pthread_mutex_lock(x)
 #define spin_unlock_irqrestore(x, f)	(void)f, pthread_mutex_unlock(x)
diff --git a/tools/testing/radix-tree/.gitignore b/tools/testing/radix-tree/.gitignore
index d4706c0ffceb..8d4df7a72a8e 100644
--- a/tools/testing/radix-tree/.gitignore
+++ b/tools/testing/radix-tree/.gitignore
@@ -4,3 +4,4 @@ idr-test
 main
 multiorder
 radix-tree.c
+xarray.c
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index fa7ee369b3c9..3868bc189199 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -4,7 +4,7 @@ CFLAGS += -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE -fsanitize=address
 LDFLAGS += -fsanitize=address
 LDLIBS+= -lpthread -lurcu
 TARGETS = main idr-test multiorder
-CORE_OFILES := radix-tree.o idr.o linux.o test.o find_bit.o
+CORE_OFILES := xarray.o radix-tree.o idr.o linux.o test.o find_bit.o
 OFILES = main.o $(CORE_OFILES) regression1.o regression2.o regression3.o \
 	 tag_check.o multiorder.o idr-test.o iteration_check.o benchmark.o
 
@@ -33,9 +33,13 @@ vpath %.c ../../lib
 $(OFILES): Makefile *.h */*.h generated/map-shift.h \
 	../../include/linux/*.h \
 	../../include/asm/*.h \
+	../../../include/linux/xarray.h \
 	../../../include/linux/radix-tree.h \
 	../../../include/linux/idr.h
 
+xarray.c: ../../../lib/xarray.c
+	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
+
 radix-tree.c: ../../../lib/radix-tree.c
 	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
 
@@ -46,6 +50,6 @@ idr.c: ../../../lib/idr.c
 
 mapshift:
 	@if ! grep -qws $(SHIFT) generated/map-shift.h; then		\
-		echo "#define RADIX_TREE_MAP_SHIFT $(SHIFT)" >		\
+		echo "#define XA_CHUNK_SHIFT $(SHIFT)" >		\
 				generated/map-shift.h;			\
 	fi
diff --git a/tools/testing/radix-tree/linux/bug.h b/tools/testing/radix-tree/linux/bug.h
index 23b8ed52f8c8..03dc8a57eb99 100644
--- a/tools/testing/radix-tree/linux/bug.h
+++ b/tools/testing/radix-tree/linux/bug.h
@@ -1 +1,2 @@
+#include <stdio.h>
 #include "asm/bug.h"
diff --git a/tools/testing/radix-tree/linux/kconfig.h b/tools/testing/radix-tree/linux/kconfig.h
new file mode 100644
index 000000000000..6c8675859913
--- /dev/null
+++ b/tools/testing/radix-tree/linux/kconfig.h
@@ -0,0 +1 @@
+#include "../../../../include/linux/kconfig.h"
diff --git a/tools/testing/radix-tree/linux/xarray.h b/tools/testing/radix-tree/linux/xarray.h
new file mode 100644
index 000000000000..df3812cda376
--- /dev/null
+++ b/tools/testing/radix-tree/linux/xarray.h
@@ -0,0 +1,2 @@
+#include "generated/map-shift.h"
+#include "../../../../include/linux/xarray.h"
diff --git a/tools/testing/radix-tree/multiorder.c b/tools/testing/radix-tree/multiorder.c
index 684e76f79f4a..24293a2fd82d 100644
--- a/tools/testing/radix-tree/multiorder.c
+++ b/tools/testing/radix-tree/multiorder.c
@@ -191,13 +191,13 @@ static void multiorder_shrink(unsigned long index, int order)
 
 	assert(item_insert_order(&tree, 0, order) == 0);
 
-	node = tree.rnode;
+	node = tree.xa_head;
 
 	assert(item_insert(&tree, index) == 0);
-	assert(node != tree.rnode);
+	assert(node != tree.xa_head);
 
 	assert(item_delete(&tree, index) != 0);
-	assert(node == tree.rnode);
+	assert(node == tree.xa_head);
 
 	for (i = 0; i < max; i++) {
 		struct item *item = item_lookup(&tree, i);
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index 0d69c49177c6..6e1cc2040817 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -262,7 +262,7 @@ static int verify_node(struct radix_tree_node *slot, unsigned int tag,
 
 void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag)
 {
-	struct radix_tree_node *node = root->rnode;
+	struct radix_tree_node *node = root->xa_head;
 	if (!radix_tree_is_internal_node(node))
 		return;
 	verify_node(node, tag, !!root_tag_get(root, tag));
@@ -292,13 +292,13 @@ void item_kill_tree(struct radix_tree_root *root)
 		}
 	}
 	assert(radix_tree_gang_lookup(root, (void **)items, 0, 32) == 0);
-	assert(root->rnode == NULL);
+	assert(root->xa_head == NULL);
 }
 
 void tree_verify_min_height(struct radix_tree_root *root, int maxindex)
 {
 	unsigned shift;
-	struct radix_tree_node *node = root->rnode;
+	struct radix_tree_node *node = root->xa_head;
 	if (!radix_tree_is_internal_node(node)) {
 		assert(maxindex == 0);
 		return;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

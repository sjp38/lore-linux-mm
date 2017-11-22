Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93C9E6B02C1
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:10:12 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q7so2745484pgr.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:10:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q75si15564392pfg.61.2017.11.22.13.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:17 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 20/62] xarray: Add xa_load
Date: Wed, 22 Nov 2017 13:06:57 -0800
Message-Id: <20171122210739.29916-21-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This first function in the XArray API brings with it a lot of support
infrastructure.  The advanced API is based around the xa_state which is
a more capable version of the radix_tree_iter.

As the test-suite demonstrates, it is possible to use the xarray and
radix tree APIs on the same data structure.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h                      | 165 ++++++++++++++++++++++++++++
 lib/Makefile                                |   2 +-
 lib/xarray.c                                | 137 +++++++++++++++++++++++
 tools/testing/radix-tree/.gitignore         |   2 +
 tools/testing/radix-tree/Makefile           |  12 +-
 tools/testing/radix-tree/linux/radix-tree.h |   1 -
 tools/testing/radix-tree/linux/rcupdate.h   |   1 +
 tools/testing/radix-tree/linux/xarray.h     |   2 +
 tools/testing/radix-tree/xarray-test.c      |  56 ++++++++++
 9 files changed, 373 insertions(+), 5 deletions(-)
 create mode 100644 lib/xarray.c
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray-test.c

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 1513a9e85580..0e736d2db049 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -46,7 +46,10 @@
  * The advanced API is more flexible but has fewer safeguards.
  */
 
+#include <linux/bug.h>
 #include <linux/compiler.h>
+#include <linux/kernel.h>
+#include <linux/rcupdate.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
@@ -77,6 +80,8 @@ struct xarray {
 
 #define DEFINE_XARRAY(name) struct xarray name = XARRAY_INIT(name)
 
+void *xa_load(struct xarray *, unsigned long index);
+
 #define BITS_PER_XA_VALUE	(BITS_PER_LONG - 1)
 
 /**
@@ -128,6 +133,18 @@ static inline bool xa_is_value(void *entry)
 				spin_unlock_irqrestore(&(xa)->xa_lock, flags)
 #define xa_lock_held(xa)	lockdep_is_held(&(xa)->xa_lock)
 
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
 /*
  * The xarray is constructed out of a set of 'chunks' of pointers.  Choosing
  * the best chunk size requires some tradeoffs.  A power of two recommends
@@ -168,6 +185,30 @@ struct xa_node {
 	unsigned long	tags[XA_MAX_TAGS][XA_TAG_LONGS];
 };
 
+static inline void *xa_head(struct xarray *xa)
+{
+	return rcu_dereference_check(xa->xa_head, xa_lock_held(xa));
+}
+
+static inline void *xa_head_locked(struct xarray *xa)
+{
+	return rcu_dereference_protected(xa->xa_head, xa_lock_held(xa));
+}
+
+static inline void *xa_entry(struct xarray *xa,
+				const struct xa_node *node, unsigned int offset)
+{
+	XA_BUG_ON(node, offset >= XA_CHUNK_SIZE);
+	return rcu_dereference_check(node->slots[offset], xa_lock_held(xa));
+}
+
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
@@ -190,6 +231,11 @@ static inline bool xa_is_internal(void *entry)
 	return ((unsigned long)entry & 3) == 2;
 }
 
+static inline struct xa_node *xa_to_node(void *entry)
+{
+	return (struct xa_node *)((unsigned long)entry & ~3UL);
+}
+
 static inline bool xa_is_node(void *entry)
 {
 	return xa_is_internal(entry) && (unsigned long)entry > 4096;
@@ -214,4 +260,123 @@ static inline bool xa_is_sibling(void *entry)
 
 #define XA_RETRY_ENTRY		xa_mk_internal(256)
 
+static inline bool xa_is_retry(void *entry)
+{
+	return unlikely(entry == XA_RETRY_ENTRY);
+}
+
+typedef void (*xa_update_node_t)(struct xa_node *);
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
+ * on (and @xa_offset is the offset in the slots array).  However, it can
+ * also have the value NULL if there is a single entry at index 0; it can
+ * have the value XAS_RESTART if the xa_state has not yet been walked to
+ * the correct position in the tree, and it can have an XAS_ERROR value to
+ * encode any error which may have occurred during the operation.
+ */
+struct xa_state {
+	unsigned long xa_index;
+	unsigned char xa_shift;
+	unsigned char xa_sibs;
+	unsigned char xa_offset;
+	struct xa_node *xa_node;
+	struct xa_node *xa_alloc;
+	xa_update_node_t xa_update;
+};
+
+/*
+ * We encode errnos in the xas->xa_node.  If an error has happened, we need to
+ * drop the lock to fix it, and once we've done so the xa_state is invalid.
+ */
+#define XAS_ERROR(errno)	((struct xa_node *)((errno << 1) | 1))
+#define XAS_RESTART		XAS_ERROR(0)
+
+#define __XA_STATE(index)	(struct xa_state) {	\
+	.xa_index = index,				\
+	.xa_shift = 0,					\
+	.xa_sibs = 0,					\
+	.xa_offset = 0,					\
+	.xa_node = XAS_RESTART,				\
+	.xa_alloc = NULL,				\
+	.xa_update = NULL				\
+}
+
+#define XA_STATE(name, index)				\
+	struct xa_state name = __XA_STATE(index)
+
+static inline int xas_error(const struct xa_state *xas)
+{
+	unsigned long v = (unsigned long)xas->xa_node;
+	return (v & 1) ? -(v >> 1) : 0;
+}
+
+static inline void xas_set_err(struct xa_state *xas, unsigned long err)
+{
+	XA_BUG_ON(NULL, err > MAX_ERRNO || !err);
+	xas->xa_node = XAS_ERROR(err);
+}
+
+static inline bool xas_invalid(const struct xa_state *xas)
+{
+	return (unsigned long)xas->xa_node & 1;
+}
+
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
+void *xas_load(struct xarray *, struct xa_state *);
+
+/**
+ * xas_reload() - Refetch an entry from the xarray.
+ * @xa: XArray.
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
+static inline void *xas_reload(struct xarray *xa, struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_node;
+
+	if (node)
+		return xa_entry(xa, node, xas->xa_offset);
+	return xa_head(xa);
+}
+
 #endif /* _LINUX_XARRAY_H */
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
diff --git a/lib/xarray.c b/lib/xarray.c
new file mode 100644
index 000000000000..1f7d30a8b61f
--- /dev/null
+++ b/lib/xarray.c
@@ -0,0 +1,137 @@
+/*
+ * XArray implementation
+ * Copyright (c) 2017 Microsoft Corporation
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
+
+#include <linux/export.h>
+#include <linux/gfp.h>
+#include <linux/radix-tree.h>
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
+/* extracts the offset within this node from the index */
+static unsigned int get_offset(unsigned long index, struct xa_node *node)
+{
+	return (index >> node->shift) & XA_CHUNK_MASK;
+}
+
+/*
+ * Starts a walk.  If the @xas is already valid, we assume that it's on
+ * the right path and just return where we've got to.  If we're in an
+ * error state, return NULL.  If the index is outside the current scope
+ * of the xarray, return NULL without changing @xas->xa_node.  Otherwise
+ * set @xas->xa_node to NULL and return the current head of the array.
+ */
+static void *xas_start(struct xarray *xa, struct xa_state *xas)
+{
+	void *entry;
+
+	if (xas_valid(xas))
+		return xas_reload(xa, xas);
+	if (xas_error(xas))
+		return NULL;
+
+	entry = xa_head(xa);
+	if (!xa_is_node(entry)) {
+		if (xas->xa_index)
+			return NULL;
+	} else {
+		if ((xas->xa_index >> xa_to_node(entry)->shift) > XA_CHUNK_MASK)
+			return NULL;
+	}
+
+	xas->xa_node = NULL;
+	return entry;
+}
+
+static void *xas_descend(struct xarray *xa, struct xa_state *xas,
+			struct xa_node *node)
+{
+	unsigned int offset = get_offset(xas->xa_index, node);
+	void *entry = xa_entry(xa, node, offset);
+
+	if (xa_is_sibling(entry)) {
+		offset = xa_to_sibling(entry);
+		entry = xa_entry(xa, node, offset);
+	}
+
+	xas->xa_node = node;
+	xas->xa_offset = offset;
+	return entry;
+}
+
+/**
+ * xas_load() - Load an entry from the XArray (advanced).
+ * @xa: XArray.
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
+void *xas_load(struct xarray *xa, struct xa_state *xas)
+{
+	void *entry = xas_start(xa, xas);
+
+	while (xa_is_node(entry)) {
+		struct xa_node *node = xa_to_node(entry);
+
+		if (xas->xa_shift > node->shift)
+			break;
+		entry = xas_descend(xa, xas, node);
+	}
+	return entry;
+}
+EXPORT_SYMBOL_GPL(xas_load);
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
+	XA_STATE(xas, index);
+	void *entry;
+
+	rcu_read_lock();
+	do {
+		entry = xas_load(xa, &xas);
+	} while (xas_retry(&xas, entry));
+	rcu_read_unlock();
+
+	return entry;
+}
+EXPORT_SYMBOL(xa_load);
diff --git a/tools/testing/radix-tree/.gitignore b/tools/testing/radix-tree/.gitignore
index d4706c0ffceb..833136896b91 100644
--- a/tools/testing/radix-tree/.gitignore
+++ b/tools/testing/radix-tree/.gitignore
@@ -4,3 +4,5 @@ idr-test
 main
 multiorder
 radix-tree.c
+xarray.c
+xarray-test
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index ebb12224e258..d0ef117941e6 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -3,10 +3,11 @@
 CFLAGS += -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE -fsanitize=address
 LDFLAGS += -fsanitize=address
 LDLIBS+= -lpthread -lurcu
-TARGETS = main idr-test multiorder
-CORE_OFILES := radix-tree.o idr.o linux.o test.o find_bit.o
+TARGETS = main idr-test multiorder xarray-test
+CORE_OFILES := radix-tree.o idr.o xarray.o linux.o test.o find_bit.o
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
@@ -42,6 +45,9 @@ radix-tree.c: ../../../lib/radix-tree.c
 idr.c: ../../../lib/idr.c
 	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
 
+xarray.c: ../../../lib/xarray.c
+	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
+
 .PHONY: mapshift
 
 mapshift:
diff --git a/tools/testing/radix-tree/linux/radix-tree.h b/tools/testing/radix-tree/linux/radix-tree.h
index de3f655caca3..24f13d27a8da 100644
--- a/tools/testing/radix-tree/linux/radix-tree.h
+++ b/tools/testing/radix-tree/linux/radix-tree.h
@@ -4,7 +4,6 @@
 
 #include "generated/map-shift.h"
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
new file mode 100644
index 000000000000..4440878501c4
--- /dev/null
+++ b/tools/testing/radix-tree/linux/xarray.h
@@ -0,0 +1,2 @@
+#include "../generated/map-shift.h"
+#include "../../../../include/linux/xarray.h"
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

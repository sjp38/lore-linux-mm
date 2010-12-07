Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 94E8F6B0088
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 13:07:59 -0500 (EST)
Date: Tue, 7 Dec 2010 10:06:53 -0800
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V0 1/4] kztmem: simplified radix tree data structure support
Message-ID: <20101207180653.GA28115@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, mel@csn.ul.ie, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

[PATCH V0 1/4] kztmem: simplified radix tree data structure support

The radix-tree code in lib has become increasingly specialized
largely because it is very critical to kernel mm operations.
Tmem does not need some of the features of radix-tree and
does need some additional features.  So, at the risk of
getting a code reuse lecture from akpm, I forked the code,
made it somewhat more "s"imple and more generic
and created a separate "sadix-tree.[ch]".  This isnt
laziness (at least not ALL laziness); the different code
is serving very different objectives.  Ideally there would
be one very generic data structure library (like rbtree)
that both radix-tree and sadix-tree share, but it wasn't
immediately obvious how to move radix-tree to sit on
top of that and I, a mere mortal, am *definitely* not
qualified to babysit the bug tail that would likely result.

Anyway, there's probably a dozen places in the kernel
where a measly couple of hundreds of lines are duplicated
to implement a similar but not-quite-identical algorithm.
While we clearly would like to avoid that and you would
love to flame over my choice... move along, these are not
the droids you are looking for.

But seriously, if you have ideas on how current radix-tree
code can easily be used with little or no loss of performance
and space, please let me know.

And, if you are akpm, I surrender: Insert code reuse lecture here.

The differences:

o Don't want or need RCU.  There may be a huge number of
  objects with a low probability that any one object will be
  accessed concurrently, so locking is done at the object
  level not at the page level.  So this version rolls back
  to a pre-RCU 2.6.18 base.
o Don't want or need tags for each entry.  Waste of space
  and complexity for tmem, so they're gone.
o The whole point of tmem is to manage memory more efficiently.
  That's hard when libraries allocate memory willy-nilly.
  So this version uses callbacks for allocating nodes so
  the caller can do bookkeeping.
o There was no way to efficiently destroy an entire radix-tree,
  so I added a sadix_tree_destroy (including a recursive helper
  function).
o The init function must be called explicitly.
o Some routines are not needed by tmem so I tossed em.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

---

Diffstat:
 drivers/staging/kztmem/sadix-tree.c      |  349 +++++++++++++++++++++
 drivers/staging/kztmem/sadix-tree.h      |   82 ++++
 2 files changed, 431 insertions(+)

--- linux-2.6.36/drivers/staging/kztmem/sadix-tree.c	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-kztmem/drivers/staging/kztmem/sadix-tree.c	2010-12-02 12:02:19.000000000 -0700
@@ -0,0 +1,349 @@
+/*
+ * Copyright (C) 2001 Momchil Velikov
+ * Portions Copyright (C) 2001 Christoph Hellwig
+ * Copyright (C) 2005 SGI, Christoph Lameter <clameter@sgi.com>
+ * Copyright (C) 2009-2010 simplified/adapted for transcendent memory ("tmem")
+ *      by Dan Magenheimer <dan.magenheimer@oracle.com>, as follows:
+ *
+ * o Linux 2.6.18 source used (prior to read-copy-update addition)
+ * o constants and data structures moved out to sadix-tree.h header
+ * o tagging code removed
+ * o sadix_tree_insert has func parameter for dynamic data struct allocation
+ * o sadix_tree_destroy added (including recursive helper function)
+ * o __init functions must be called explicitly
+ * o sadix_tree_lookup_slot, __lookup and sadix_tree_gang_lookup unused/removed
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2, or (at
+ * your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include "sadix-tree.h"
+
+static unsigned long height_to_maxindex[SADIX_TREE_MAX_PATH + 1];
+
+/*
+ * Return the maximum key which can be store into a
+ * radix tree with height HEIGHT.
+ */
+static inline unsigned long sadix_tree_maxindex(unsigned int height)
+{
+	return height_to_maxindex[height];
+}
+
+/*
+ * Extend a radix tree so it can store key @index.
+ */
+static int sadix_tree_extend(struct sadix_tree_root *root, unsigned long index,
+				struct sadix_tree_node *(*node_alloc)(void *),
+				void *arg)
+{
+	struct sadix_tree_node *node;
+	unsigned int height;
+
+	/* Figure out what the height should be.  */
+	height = root->height + 1;
+	if (index > sadix_tree_maxindex(height))
+		while (index > sadix_tree_maxindex(height))
+			height++;
+
+	if (root->rnode == NULL) {
+		root->height = height;
+		goto out;
+	}
+
+	do {
+		node = node_alloc(arg);
+		if (!node)
+			return -ENOMEM;
+
+		/* Increase the height.  */
+		node->slots[0] = root->rnode;
+
+		node->count = 1;
+		root->rnode = node;
+		root->height++;
+	} while (height > root->height);
+out:
+	return 0;
+}
+
+/**
+ * sadix_tree_insert    -    insert into a radix tree
+ * @root:  radix tree root
+ * @index:  index key
+ * @item:  item to insert
+ *
+ * Insert an item into the radix tree at position @index.
+ */
+int sadix_tree_insert(struct sadix_tree_root *root, unsigned long index,
+			void *item,
+			struct sadix_tree_node *(*node_alloc)(void *),
+			void *arg)
+{
+	struct sadix_tree_node *node = NULL, *slot;
+	unsigned int height, shift;
+	int offset;
+	int error;
+
+	/* Make sure the tree is high enough.  */
+	if (index > sadix_tree_maxindex(root->height)) {
+		error = sadix_tree_extend(root, index, node_alloc, arg);
+		if (error)
+			return error;
+	}
+
+	slot = root->rnode;
+	height = root->height;
+	shift = (height-1) * SADIX_TREE_MAP_SHIFT;
+
+	offset = 0;   /* uninitialised var warning */
+	while (height > 0) {
+		if (slot == NULL) {
+			/* Have to add a child node.  */
+			slot = node_alloc(arg);
+			if (!slot)
+				return -ENOMEM;
+			if (node) {
+
+				node->slots[offset] = slot;
+				node->count++;
+			} else
+				root->rnode = slot;
+		}
+
+		/* Go a level down */
+		offset = (index >> shift) & SADIX_TREE_MAP_MASK;
+		node = slot;
+		slot = node->slots[offset];
+		shift -= SADIX_TREE_MAP_SHIFT;
+		height--;
+	}
+
+	if (slot != NULL)
+		return -EEXIST;
+
+	if (node) {
+		node->count++;
+		node->slots[offset] = item;
+	} else {
+		root->rnode = item;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(sadix_tree_insert);
+
+static inline void **__lookup_slot(struct sadix_tree_root *root,
+					unsigned long index)
+{
+	unsigned int height, shift;
+	struct sadix_tree_node **slot;
+
+	height = root->height;
+
+	if (index > sadix_tree_maxindex(height))
+		return NULL;
+
+	if (height == 0 && root->rnode)
+		return (void **)&root->rnode;
+
+	shift = (height-1) * SADIX_TREE_MAP_SHIFT;
+	slot = &root->rnode;
+
+	while (height > 0) {
+		if (*slot == NULL)
+			return NULL;
+
+		slot = (struct sadix_tree_node **)
+			((*slot)->slots +
+			 ((index >> shift) & SADIX_TREE_MAP_MASK));
+		shift -= SADIX_TREE_MAP_SHIFT;
+		height--;
+	}
+
+	return (void **)slot;
+}
+
+/**
+ * sadix_tree_lookup    -    perform lookup operation on a radix tree
+ * @root:  radix tree root
+ * @index:  index key
+ *
+ * Lookup the item at the position @index in the radix tree @root.
+ */
+void *sadix_tree_lookup(struct sadix_tree_root *root, unsigned long index)
+{
+	void **slot;
+
+	slot = __lookup_slot(root, index);
+	return slot != NULL ? *slot : NULL;
+}
+EXPORT_SYMBOL(sadix_tree_lookup);
+
+/**
+ * sadix_tree_shrink    -    shrink height of a radix tree to minimal
+ * @root  radix tree root
+ */
+static inline void sadix_tree_shrink(struct sadix_tree_root *root,
+				void (*node_free)(struct sadix_tree_node *))
+{
+	/* try to shrink tree height */
+	while (root->height > 0 &&
+		   root->rnode->count == 1 &&
+		   root->rnode->slots[0]) {
+		struct sadix_tree_node *to_free = root->rnode;
+
+		root->rnode = to_free->slots[0];
+		root->height--;
+		to_free->slots[0] = NULL;
+		to_free->count = 0;
+		node_free(to_free);
+	}
+}
+
+/**
+ * sadix_tree_delete    -    delete an item from a radix tree
+ * @root:  radix tree root
+ * @index:  index key
+ *
+ * Remove the item at @index from the radix tree rooted at @root.
+ *
+ * Returns the address of the deleted item, or NULL if it was not present.
+ */
+void *sadix_tree_delete(struct sadix_tree_root *root, unsigned long index,
+			void(*node_free)(struct sadix_tree_node *))
+{
+	struct sadix_tree_path path[SADIX_TREE_MAX_PATH + 1], *pathp = path;
+	struct sadix_tree_node *slot = NULL;
+	unsigned int height, shift;
+	int offset;
+
+	height = root->height;
+	if (index > sadix_tree_maxindex(height))
+		goto out;
+
+	slot = root->rnode;
+	if (height == 0 && root->rnode) {
+		root->rnode = NULL;
+		goto out;
+	}
+
+	shift = (height - 1) * SADIX_TREE_MAP_SHIFT;
+	pathp->node = NULL;
+
+	do {
+		if (slot == NULL)
+			goto out;
+
+		pathp++;
+		offset = (index >> shift) & SADIX_TREE_MAP_MASK;
+		pathp->offset = offset;
+		pathp->node = slot;
+		slot = slot->slots[offset];
+		shift -= SADIX_TREE_MAP_SHIFT;
+		height--;
+	} while (height > 0);
+
+	if (slot == NULL)
+		goto out;
+
+	/* Now free the nodes we do not need anymore */
+	while (pathp->node) {
+		pathp->node->slots[pathp->offset] = NULL;
+		pathp->node->count--;
+
+		if (pathp->node->count) {
+			if (pathp->node == root->rnode)
+				sadix_tree_shrink(root, node_free);
+			goto out;
+		}
+
+		/* Node with zero slots in use so free it */
+		node_free(pathp->node);
+
+		pathp--;
+	}
+	root->height = 0;
+	root->rnode = NULL;
+
+out:
+	return slot;
+}
+EXPORT_SYMBOL(sadix_tree_delete);
+
+static void
+sadix_tree_node_destroy(struct sadix_tree_node *node, unsigned int height,
+			void (*slot_free)(void *, void *),
+			void (*node_free)(struct sadix_tree_node *),
+			void *slot_extra)
+{
+	int i;
+
+	if (height == 0)
+		return;
+	for (i = 0; i < SADIX_TREE_MAP_SIZE; i++) {
+		if (node->slots[i]) {
+			if (height == 1) {
+				slot_free(node->slots[i], slot_extra);
+				node->slots[i] = NULL;
+				continue;
+			}
+			sadix_tree_node_destroy(node->slots[i], height-1,
+				slot_free, node_free, slot_extra);
+			node_free(node->slots[i]);
+			node->slots[i] = NULL;
+		}
+	}
+}
+
+void sadix_tree_destroy(struct sadix_tree_root *root,
+			void (*slot_free)(void *, void *),
+			void (*node_free)(struct sadix_tree_node *),
+			void *slot_extra)
+{
+	if (root->rnode == NULL)
+		return;
+	if (root->height == 0)
+		slot_free(root->rnode, slot_extra);
+	else {
+		sadix_tree_node_destroy(root->rnode, root->height,
+				slot_free, node_free, slot_extra);
+		node_free(root->rnode);
+		root->height = 0;
+	}
+	root->rnode = NULL;
+	/* caller must delete root if desired */
+}
+EXPORT_SYMBOL(sadix_tree_destroy);
+
+static unsigned long __init __maxindex(unsigned int height)
+{
+	unsigned int tmp = height * SADIX_TREE_MAP_SHIFT;
+	unsigned long index = (~0UL >> (SADIX_TREE_INDEX_BITS - tmp - 1)) >> 1;
+
+	if (tmp >= SADIX_TREE_INDEX_BITS)
+		index = ~0UL;
+	return index;
+}
+
+void __init sadix_tree_init(void)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(height_to_maxindex); i++)
+		height_to_maxindex[i] = __maxindex(i);
+}
--- linux-2.6.36/drivers/staging/kztmem/sadix-tree.h	1969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.36-kztmem/drivers/staging/kztmem/sadix-tree.h	2010-12-02 12:02:44.000000000 -0700
@@ -0,0 +1,82 @@
+/*
+ * Copyright (C) 2001 Momchil Velikov
+ * Portions Copyright (C) 2001 Christoph Hellwig
+ * Copyright (C) 2009-2010 simplified/adapted for transcendent memory ("tmem")
+ *      by Dan Magenheimer <dan.magenheimer@oracle.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2, or (at
+ * your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#ifndef _LINUX_SADIX_TREE_H
+#define _LINUX_SADIX_TREE_H
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+
+/* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
+struct sadix_tree_root {
+	unsigned int height;
+	struct sadix_tree_node *rnode;
+};
+
+#define SADIX_TREE_MAP_SHIFT 6
+
+#define SADIX_TREE_MAP_SIZE (1UL << SADIX_TREE_MAP_SHIFT)
+#define SADIX_TREE_MAP_MASK (SADIX_TREE_MAP_SIZE-1)
+
+#define SADIX_TREE_TAG_LONGS \
+	((SADIX_TREE_MAP_SIZE + BITS_PER_LONG - 1) / BITS_PER_LONG)
+
+struct sadix_tree_node {
+	unsigned int count;
+	void *slots[SADIX_TREE_MAP_SIZE];
+};
+
+struct sadix_tree_path {
+	struct sadix_tree_node *node;
+	int offset;
+};
+
+#define SADIX_TREE_INDEX_BITS (8 /* CHAR_BIT */ * sizeof(unsigned long))
+#define SADIX_TREE_MAX_PATH (SADIX_TREE_INDEX_BITS/SADIX_TREE_MAP_SHIFT + 2)
+
+
+#define SADIX_TREE_INIT(mask) \
+	{	 \
+		.height = 0, \
+		.rnode = NULL, \
+	}
+
+#define SADIX_TREE(name, mask) \
+	struct sadix_tree_root name = SADIX_TREE_INIT(mask)
+
+#define INIT_SADIX_TREE(root, mask) \
+	do { \
+		(root)->height = 0; \
+		(root)->rnode = NULL; \
+	} while (0)
+
+int sadix_tree_insert(struct sadix_tree_root *root, unsigned long index,
+			void *item,
+			struct sadix_tree_node *(*node_alloc)(void *),
+			void *arg);
+void *sadix_tree_lookup(struct sadix_tree_root *, unsigned long);
+void sadix_tree_destroy(struct sadix_tree_root *root,
+			void (*slot_free)(void *, void *),
+			void (*node_free)(struct sadix_tree_node *), void *);
+void *sadix_tree_delete(struct sadix_tree_root *root, unsigned long index,
+			void(*node_free)(struct sadix_tree_node *));
+void sadix_tree_init(void);
+
+#endif /* _LINUX_SADIX_TREE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 312D46B008A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:58:30 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LC500JD931DUQ20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:25 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LC50012X31C14@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 15:58:25 +0000 (GMT)
Date: Fri, 19 Nov 2010 16:58:04 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [RFCv6 06/13] mm: cma: Best-fit algorithm added
In-reply-to: <cover.1290172312.git.m.nazarewicz@samsung.com>
Message-id: 
 <b82ec382957f8846aedcb83f650aa1b48e5b87a8.1290172312.git.m.nazarewicz@samsung.com>
References: <cover.1290172312.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: mina86@mina86.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Bryan Huntsman <bryanh@codeaurora.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Johan Mossberg <johan.xx.mossberg@stericsson.com>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Marcus LORENTZON <marcus.xm.lorentzon@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>, Russell King <linux@arm.linux.org.uk>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, dipankar@in.ibm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This commits adds a best-fit algorithm to the set of
algorithms supported by the CMA.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/Kconfig        |   16 ++-
 mm/Makefile       |    1 +
 mm/cma-best-fit.c |  372 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 388 insertions(+), 1 deletions(-)
 create mode 100644 mm/cma-best-fit.c

diff --git a/mm/Kconfig b/mm/Kconfig
index a5480ea..5ad2471 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -332,10 +332,13 @@ config CLEANCACHE
 
 	  If unsure, say Y to enable cleancache
 
+config CMA_HAS_ALLOCATOR
+	bool
+
 config CMA
 	bool "Contiguous Memory Allocator framework"
 	# Currently there is only one allocator so force it on
-	select CMA_GENERIC_ALLOCATOR
+	select CMA_GENERIC_ALLOCATOR if !CMA_HAS_ALLOCATOR
 	help
 	  This enables the Contiguous Memory Allocator framework which
 	  allows drivers to allocate big physically-contiguous blocks of
@@ -391,3 +394,14 @@ config CMA_GENERIC_ALLOCATOR
 	  implementations: the first-fit, bitmap-based algorithm or
 	  a best-fit, red-black tree-based algorithm.  The algorithm can
 	  be changed under "Library routines".
+
+config CMA_BEST_FIT
+	bool "CMA best-fit allocator"
+	depends on CMA
+	select CMA_HAS_ALLOCATOR
+	help
+	  This is a best-fit algorithm running in O(n log n) time where
+	  n is the number of existing holes (which is never greater then
+	  the number of allocated regions and usually much smaller).  It
+	  allocates area from the smallest hole that is big enough for
+	  allocation in question.
diff --git a/mm/Makefile b/mm/Makefile
index c6a84f1..2cb2569 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -44,3 +44,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_CMA) += cma.o
+obj-$(CONFIG_CMA_BEST_FIT) += cma-best-fit.o
diff --git a/mm/cma-best-fit.c b/mm/cma-best-fit.c
new file mode 100644
index 0000000..5ed1168
--- /dev/null
+++ b/mm/cma-best-fit.c
@@ -0,0 +1,372 @@
+/*
+ * Contiguous Memory Allocator framework: Best Fit allocator
+ * Copyright (c) 2010 by Samsung Electronics.
+ * Written by Michal Nazarewicz (m.nazarewicz@samsung.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of the
+ * License or (at your optional) any later version of the license.
+ */
+
+#define pr_fmt(fmt) "cma: bf: " fmt
+
+#ifdef CONFIG_CMA_DEBUG
+#  define DEBUG
+#endif
+
+#include <linux/errno.h>       /* Error numbers */
+#include <linux/slab.h>        /* kmalloc() */
+
+#include <linux/cma.h>         /* CMA structures */
+
+
+/************************* Data Types *************************/
+
+struct cma_bf_node {
+	unsigned long v;
+	struct rb_node n;
+};
+
+union cma_bf_item {
+	struct cma chunk;
+	struct {
+		struct cma_bf_node start, size;
+	};
+};
+
+struct cma_bf_private {
+	struct rb_root by_start_root;
+	struct rb_root by_size_root;
+	bool warned;
+};
+
+
+/************************* Basic Tree Manipulation *************************/
+
+static int  cma_bf_node_add(struct cma_bf_node *node, struct rb_root *root,
+			    bool unique)
+{
+	struct rb_node **link = &root->rb_node, *parent = NULL;
+	const unsigned long v = node->v;
+
+	while (*link) {
+		struct cma_bf_node *n;
+		parent = *link;
+		n = rb_entry(parent, struct cma_bf_node, n);
+
+		if (unlikely(unique && v == n->v))
+			return -EBUSY;
+
+		link = v <= n->v ? &parent->rb_left : &parent->rb_right;
+	}
+
+	rb_link_node(&node->n, parent, link);
+	rb_insert_color(&node->n, root);
+
+	return 0;
+}
+
+static void cma_bf_node_del(struct cma_bf_node *node, struct rb_root *root)
+{
+	rb_erase(&node->n, root);
+}
+
+static int  cma_bf_item_add_by_start(union cma_bf_item *item,
+				     struct cma_bf_private *prv)
+{
+	int ret = cma_bf_node_add(&item->start, &prv->by_start_root, true);
+	if (WARN_ON(ret && !prv->warned))
+		prv->warned = true;
+	return ret;
+}
+
+static void cma_bf_item_del_by_start(union cma_bf_item *item,
+				     struct cma_bf_private *prv)
+{
+	cma_bf_node_del(&item->start, &prv->by_start_root);
+}
+
+static void cma_bf_item_add_by_size(union cma_bf_item *item,
+				    struct cma_bf_private *prv)
+{
+	cma_bf_node_add(&item->size, &prv->by_size_root, false);
+}
+
+static void cma_bf_item_del_by_size(union cma_bf_item *item,
+				    struct cma_bf_private *prv)
+{
+	cma_bf_node_del(&item->size, &prv->by_size_root);
+}
+
+
+/************************* Device API *************************/
+
+static int cma_bf_init(struct cma_region *reg)
+{
+	struct cma_bf_private *prv;
+	union cma_bf_item *item;
+
+	prv = kzalloc(sizeof *prv, GFP_KERNEL);
+	if (unlikely(!prv))
+		return -ENOMEM;
+
+	item = kzalloc(sizeof *item, GFP_KERNEL);
+	if (unlikely(!item)) {
+		kfree(prv);
+		return -ENOMEM;
+	}
+
+	item->start.v = reg->start;
+	item->size.v  = reg->size;
+
+	rb_root_init(&prv->by_start_root, &item->start.n);
+	rb_root_init(&prv->by_size_root, &item->size.n);
+	prv->warned = false;
+
+	reg->private_data = prv;
+	return 0;
+}
+
+static void cma_bf_cleanup(struct cma_region *reg)
+{
+	struct cma_bf_private *prv = reg->private_data;
+	union cma_bf_item *item =
+		rb_entry(prv->by_start_root.rb_node,
+			 union cma_bf_item, start.n);
+
+	/* There should be only one item. */
+	WARN_ON(!prv->warned &&
+		(!item ||
+		 item->start.n.rb_left || item->start.n.rb_right ||
+		 item->size.n.rb_left || item->size.n.rb_right));
+
+	kfree(item);
+	kfree(prv);
+}
+
+struct cma *cma_bf_alloc(struct cma_region *reg,
+			 size_t size, unsigned long alignment)
+{
+	struct cma_bf_private *prv = reg->private_data;
+	struct rb_node *node = prv->by_size_root.rb_node;
+	union cma_bf_item *hole = NULL, *item;
+	unsigned long start;
+	int ret;
+
+	/* First find hole that is large enough */
+	while (node) {
+		union cma_bf_item *item =
+			rb_entry(node, union cma_bf_item, size.n);
+
+		if (item->size.v < size) {
+			node = node->rb_right;
+		} else if (item->size.v >= size) {
+			node = node->rb_left;
+			hole = item;
+		}
+	}
+	if (!hole)
+		return ERR_PTR(-ENOMEM);
+
+	/* Now look for items which can satisfy alignment requirements */
+	for (;;) {
+		unsigned long end = hole->start.v + hole->size.v;
+		start = ALIGN(hole->start.v, alignment);
+		if (start < end && end - start >= size)
+			break;
+
+		node = rb_next(node);
+		if (!node)
+			return ERR_PTR(-ENOMEM);
+
+		hole = rb_entry(node, union cma_bf_item, size.n);
+	}
+
+	/* And finally, take part of the hole */
+
+	/*
+	 * There are three cases:
+	 * 1. the chunk takes the whole hole,
+	 * 2. the chunk is at the beginning or at the end of the hole, or
+	 * 3. the chunk is in the middle of the hole.
+	 */
+
+	/* Case 1, the whole hole */
+	if (size == hole->size.v) {
+		ret = __cma_grab(reg, start, size);
+		if (ret)
+			return ERR_PTR(ret);
+
+		cma_bf_item_del_by_start(hole, prv);
+		cma_bf_item_del_by_size(hole, prv);
+
+		hole->chunk.phys = start;
+		hole->chunk.size = size;
+		return &hole->chunk;
+	}
+
+	/* Allocate (so we can test early if ther's enough memory) */
+	item = kmalloc(sizeof *item, GFP_KERNEL);
+	if (unlikely(!item))
+		return ERR_PTR(-ENOMEM);
+
+	/* Case 3, in the middle */
+	if (start != hole->start.v &&
+	    start + size != hole->start.v + hole->size.v) {
+		union cma_bf_item *tail;
+
+		/*
+		 * Space between the end of the chunk and the end of
+		 * the region, ie. space left after the end of the
+		 * chunk.  If this is dividable by alignment we can
+		 * move the chunk to the end of the hole.
+		 */
+		unsigned long left =
+			hole->start.v + hole->size.v - (start + size);
+		if ((left & (alignment - 1)) == 0) {
+			start += left;
+			/* And so, we have reduced problem to case 2. */
+			goto case_2;
+		}
+
+		/*
+		 * We are going to add a hole at the end.  This way,
+		 * we will reduce the problem to case 2 -- the chunk
+		 * will be at the end of a reduced hole.
+		 */
+		tail = kmalloc(sizeof *tail, GFP_KERNEL);
+		if (unlikely(!tail)) {
+			kfree(item);
+			return ERR_PTR(-ENOMEM);
+		}
+
+		tail->start.v = start + size;
+		tail->size.v  =
+			hole->start.v + hole->size.v - tail->start.v;
+
+		if (cma_bf_item_add_by_start(tail, prv))
+			/*
+			 * Things are broken beyond repair...  Abort
+			 * inserting the hole but continue with the
+			 * item.  We will loose some memory but we're
+			 * screwed anyway.
+			 */
+			kfree(tail);
+		else
+			cma_bf_item_add_by_size(tail, prv);
+
+		/*
+		 * It's important that we first insert the new hole in
+		 * the tree sorted by size and later reduce the size
+		 * of the old hole.  We will update the position of
+		 * the old hole in the rb tree in code that handles
+		 * case 2.
+		 */
+		hole->size.v = tail->start.v - hole->start.v;
+
+		/* Go to case 2 */
+	}
+
+	/* Case 2, at the beginning or at the end */
+case_2:
+	/* No need to update the tree; order preserved. */
+	if (start == hole->start.v)
+		hole->start.v += size;
+
+	/* Alter hole's size */
+	hole->size.v -= size;
+	cma_bf_item_del_by_size(hole, prv);
+	cma_bf_item_add_by_size(hole, prv);
+
+	item->chunk.phys = start;
+	item->chunk.size = size;
+	return &item->chunk;
+}
+
+static void cma_bf_free(struct cma_chunk *chunk)
+{
+	struct cma_bf_private *prv = reg->private_data;
+	union cma_bf_item *prev;
+	struct rb_node *node;
+	int twice;
+
+	{
+		unsigned long start = item->chunk.phys;
+		unsigned long size  = item->chunk.size;
+		item->start.v = start;
+		item->size.v = size;
+	}
+
+	/* Add new hole */
+	if (cma_bf_item_add_by_start(item, prv)) {
+		/*
+		 * We're screwed...  Just free the item and forget
+		 * about it.  Things are broken beyond repair so no
+		 * sense in trying to recover.
+		 */
+		kfree(item);
+		return;
+	}
+
+	cma_bf_item_add_by_size(item, prv);
+
+	/* Merge with prev or next sibling */
+	twice = 2;
+	node = rb_prev(&item->start.n);
+	if (unlikely(!node))
+		goto next;
+	prev = rb_entry(node, union cma_bf_item, start.n);
+
+	for (;;) {
+		if (prev->start.v + prev->size.v == item->start.v) {
+			/* Remove previous hole from trees */
+			cma_bf_item_del_by_start(prev, prv);
+			cma_bf_item_del_by_size(prev, prv);
+
+			/* Alter this hole */
+			item->start.v  = prev->start.v;
+			item->size.v += prev->size.v;
+			cma_bf_item_del_by_size(item, prv);
+			cma_bf_item_del_by_size(item, prv);
+			/*
+			 * No need to update the by start trees as we
+			 * do not break sequence order.
+			 */
+
+			/* Free prev hole */
+			kfree(prev);
+		}
+
+next:
+		if (!--twice)
+			break;
+
+		node = rb_next(&item->start.n);
+		if (unlikely(!node))
+			break;
+		prev = item;
+		item = rb_entry(node, union cma_bf_item, start.n);
+	}
+}
+
+{
+	__cma_ungrab(chunk->reg, chunk->phys, chunk->size);
+	__cma_bf_free(chunk->reg, 
+		      container_of(chunk, union cma_bf_item, chunk));
+}
+
+/************************* Register *************************/
+
+static int cma_bf_module_init(void)
+{
+	static struct cma_allocator alloc = {
+		.name    = "bf",
+		.init    = cma_bf_init,
+		.cleanup = cma_bf_cleanup,
+		.alloc   = cma_bf_alloc,
+		.free    = cma_bf_free,
+	};
+	return cma_allocator_register(&alloc);
+}
+module_init(cma_bf_module_init);
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

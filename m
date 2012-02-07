Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id D45CD6B13F2
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 02:55:07 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id zs2so7019093bkb.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 23:55:07 -0800 (PST)
Subject: [PATCH 2/4] radix-tree: introduce bit-optimized iterator
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 07 Feb 2012 11:55:04 +0400
Message-ID: <20120207075504.29797.98116.stgit@zurg>
In-Reply-To: <20120207074905.29797.60353.stgit@zurg>
References: <20120207074905.29797.60353.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org

This patch implements clean, simple and effective radix-tree iteration routine.
Iterating is divided into two loops: the outer loop iterates though radix tree
chunks on leaf nodes, the nested loop iterates through slots in one chunk.

Main iterator function radix_tree_next_chunk() returns pointer to first slot,
and stores in the struct radix_tree_iter index of next-to-last slot.
For tagged-iterating it also constuct bitmask of tags for retunted chunk.
Thus nested-loop has enough information for iteration.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/radix-tree.h |  129 ++++++++++++++++++++++++++++++++++++++++++++
 lib/radix-tree.c           |  107 ++++++++++++++++++++++++++++++++++++
 2 files changed, 236 insertions(+), 0 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 07e360b..c31b895 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -2,6 +2,7 @@
  * Copyright (C) 2001 Momchil Velikov
  * Portions Copyright (C) 2001 Christoph Hellwig
  * Copyright (C) 2006 Nick Piggin
+ * Copyright (C) 2012 Konstantin Khlebnikov
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License as
@@ -256,4 +257,132 @@ static inline void radix_tree_preload_end(void)
 	preempt_enable();
 }
 
+struct radix_tree_iter {
+	unsigned long		index;		/* current slot index */
+	unsigned long		next_index;	/* next chunk first index */
+	unsigned long		tags;		/* bitmask for tag-iterating */
+};
+
+static inline void radix_tree_iter_start(struct radix_tree_iter *iter,
+					 unsigned long start)
+{
+	iter->index = start;
+	iter->next_index = 1; /* any non-zero */
+}
+
+#define RADIX_TREE_ITER_TAG_MASK	0x00FF
+#define RADIX_TREE_ITER_TAGGED		0x0100	/* search tagged */
+#define RADIX_TREE_ITER_CONTIG		0x0200	/* stop at first hole  */
+
+void **radix_tree_next_chunk(struct radix_tree_root *root,
+			     struct radix_tree_iter *iter, unsigned flags);
+
+/**
+ * radix_tree_next_tag - find next tagged slot in chunk
+ *
+ * @slot	pointer to slot pointer
+ * @iter	iterator state
+ *
+ * Eats iter->tags and bumps *slot and iter->index to next tagged slot
+ * Returns true if something found, and false otherwise
+ */
+static inline bool radix_tree_next_tag(void ***slot,
+				       struct radix_tree_iter *iter)
+{
+	unsigned long offset;
+
+	if (likely(iter->tags & 1ul))
+		return true;
+	if (unlikely(!iter->tags)) {
+		iter->index = iter->next_index;
+		return false;
+	}
+	offset = __ffs(iter->tags);
+	iter->tags >>= offset;
+	iter->index += offset;
+	*slot += offset;
+	return true;
+}
+
+/**
+ * radix_tree_for_each_chunk - iterate over all slot chunks
+ *
+ * @slot:	the void** for pointer to first slot
+ * @root	the struct radix_tree_root pointer
+ * @iter	the struct radix_tree_iter pointer
+ * @start	starting index
+ * @flags	RADIX_TREE_ITER_* and tag index
+ */
+#define radix_tree_for_each_chunk(slot, root, iter, start, flags)	\
+	for ( radix_tree_iter_start(iter, start) ;			\
+	      (slot = radix_tree_next_chunk(root, iter, flags)) ; )
+
+/**
+ * radix_tree_for_each_chunk_slot - iterate over all slots in one chunk
+ *
+ * @slot:	the void** for pointer to slot
+ * @iter	the struct radix_tree_iter pointer
+ */
+#define radix_tree_for_each_chunk_slot(slot, iter)	\
+	for ( ; (iter)->index != (iter)->next_index ;	\
+		(iter)->index++, slot++ )
+
+/**
+ * radix_tree_for_each_chunk_tagged_slot - iterate over all tagged slots
+ *					   in one chunk
+ *
+ * @slot:	the void** for pointer to slot
+ * @iter	the struct radix_tree_iter pointer
+ */
+#define radix_tree_for_each_chunk_tagged_slot(slot, iter)	\
+	for ( ; radix_tree_next_tag(&slot, iter) ;		\
+		(iter)->tags >>= 1, (iter)->index++, slot++ )
+
+/**
+ * radix_tree_for_each_slot - iterate over all non-empty slots
+ *
+ * @slot:	the void** for pointer to slot
+ * @root	the struct radix_tree_root pointer
+ * @iter	the struct radix_tree_iter pointer
+ * @start	starting index
+ *
+ * This is double-loop, break does not work.
+ */
+#define radix_tree_for_each_slot(slot, root, iter, start)	\
+	radix_tree_for_each_chunk(slot, root, iter, start, 0)	\
+		radix_tree_for_each_chunk_slot(slot, iter)	\
+			if (!*slot) { continue; } else
+
+/**
+ * radix_tree_for_each_contig - iterate over all contiguous non-empty slots
+ *
+ * @slot:	the void** for pointer to slot
+ * @root	the struct radix_tree_root pointer
+ * @iter	the struct radix_tree_iter pointer
+ * @start	starting index
+ *
+ * This is double-loop, break does not work.
+ */
+#define radix_tree_for_each_contig(slot, root, iter, start)	\
+	radix_tree_for_each_chunk(slot, root, iter, start,	\
+					RADIX_TREE_ITER_CONTIG)	\
+		radix_tree_for_each_chunk_slot(slot, iter)	\
+			if (!*slot) { (iter)->next_index = 0; break; } else
+
+/**
+ * radix_tree_for_each_tagged - iterate over all tagged slots
+ *
+ * @slot:	the void** for pointer to slot
+ * @root	the struct radix_tree_root pointer
+ * @iter	the struct radix_tree_iter pointer
+ * @start	starting index
+ * @tag		tag index
+ *
+ * This is double-loop, break does not work.
+ */
+#define radix_tree_for_each_tagged(slot, root, iter, start, tag)\
+	radix_tree_for_each_chunk(slot, root, iter, start,	\
+				RADIX_TREE_ITER_TAGGED | tag)	\
+		radix_tree_for_each_chunk_tagged_slot(slot, iter)
+
 #endif /* _LINUX_RADIX_TREE_H */
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index dc63d08..32e2bfa 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -3,6 +3,7 @@
  * Portions Copyright (C) 2001 Christoph Hellwig
  * Copyright (C) 2005 SGI, Christoph Lameter
  * Copyright (C) 2006 Nick Piggin
+ * Copyright (C) 2012 Konstantin Khlebnikov
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License as
@@ -613,6 +614,112 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 EXPORT_SYMBOL(radix_tree_tag_get);
 
 /**
+ * radix_tree_next_chunk - find next slots chunk for iteration
+ *
+ * @root:		radix tree root
+ * @iter:		iterator state
+ * @flags		RADIX_TREE_ITER_* flags and tag index
+ *
+ * Returns pointer to first slots, or NULL if there no more left
+ */
+void **radix_tree_next_chunk(struct radix_tree_root *root,
+			     struct radix_tree_iter *iter, unsigned flags)
+{
+	unsigned tag = flags & RADIX_TREE_ITER_TAG_MASK;
+	struct radix_tree_node *rnode, *node;
+	unsigned long index, i;
+	unsigned shift;
+
+	/* Overflow after ~0ul, or break in contiguous iteration */
+	if (!iter->next_index)
+		return NULL;
+
+	if ((flags & RADIX_TREE_ITER_TAGGED) && !root_tag_get(root, tag))
+		return NULL;
+
+	index = iter->index;
+
+	rnode = rcu_dereference_raw(root->rnode);
+	if (radix_tree_is_indirect_ptr(rnode)) {
+		rnode = indirect_to_ptr(rnode);
+	} else if (rnode && !index) {
+		/* Single-slot tree */
+		iter->tags = 1;
+		iter->next_index = 1;
+		return (void **)&root->rnode;
+	} else
+		return NULL;
+
+restart:
+	shift = (rnode->height - 1) * RADIX_TREE_MAP_SHIFT;
+	i = index >> shift;
+
+	/* Index ouside of the tree */
+	if (i >= RADIX_TREE_MAP_SIZE)
+		return NULL;
+
+	node = rnode;
+	while (1) {
+		if ((flags & RADIX_TREE_ITER_TAGGED) ?
+				!test_bit(i, node->tags[tag]) :
+				!node->slots[i]) {
+			/* Hole detected */
+			if (flags & RADIX_TREE_ITER_CONTIG)
+				return NULL;
+
+			if (flags & RADIX_TREE_ITER_TAGGED)
+				i = __find_next_bit(node->tags[tag],
+						RADIX_TREE_MAP_SIZE, i + 1);
+			else
+				while (++i < RADIX_TREE_MAP_SIZE &&
+						!node->slots[i]);
+
+			index &= ~((RADIX_TREE_MAP_SIZE << shift) - 1);
+			index += i << shift;
+			/* Overflow after ~0UL */
+			if (!index)
+				return NULL;
+			if (i == RADIX_TREE_MAP_SIZE)
+				goto restart;
+		}
+
+		/* This is leaf-node */
+		if (!shift)
+			break;
+
+		node = rcu_dereference_raw(node->slots[i]);
+		if (node == NULL)
+			goto restart;
+		shift -= RADIX_TREE_MAP_SHIFT;
+		i = (index >> shift) & RADIX_TREE_MAP_MASK;
+	}
+
+	iter->index = index;
+	iter->next_index = (index | RADIX_TREE_MAP_MASK) + 1;
+
+	/* Construct iter->tags bitmask from node->tags[tag] array */
+	if (flags & RADIX_TREE_ITER_TAGGED) {
+		unsigned tag_long, tag_bit;
+
+		tag_long = i / BITS_PER_LONG;
+		tag_bit  = i % BITS_PER_LONG;
+		iter->tags = node->tags[tag][tag_long] >> tag_bit;
+		/* This never happens if RADIX_TREE_TAG_LONGS == 1 */
+		if (tag_long < RADIX_TREE_TAG_LONGS - 1) {
+			/* Pick tags from next element */
+			if (tag_bit)
+				iter->tags |= node->tags[tag][tag_long + 1] <<
+						(BITS_PER_LONG - tag_bit);
+			/* Clip chunk size, here only BITS_PER_LONG tags */
+			iter->next_index = index + BITS_PER_LONG;
+		}
+	}
+
+	return node->slots + i;
+}
+EXPORT_SYMBOL(radix_tree_next_chunk);
+
+/**
  * radix_tree_range_tag_if_tagged - for each item in given range set given
  *				   tag if item has another tag set
  * @root:		radix tree root

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

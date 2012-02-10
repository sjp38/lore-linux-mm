Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id C668C6B13FF
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 14:25:45 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so3571094bkt.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 11:25:45 -0800 (PST)
Subject: [PATCH v2 1/3] radix-tree: introduce bit-optimized iterator
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 10 Feb 2012 23:25:42 +0400
Message-ID: <20120210192542.5881.91143.stgit@zurg>
In-Reply-To: <20120210191611.5881.12646.stgit@zurg>
References: <20120210191611.5881.12646.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

This patch implements clean, simple and effective radix-tree iteration routine.

Iterating divided into two phases:
* lookup next chunk in radix-tree leaf node
* iterating through slots in this chunk

Main iterator function radix_tree_next_chunk() returns pointer to first slot,
and stores in the struct radix_tree_iter index of next-to-last slot.
For tagged-iterating it also constuct bitmask of tags for retunted chunk.
All additional logic implemented as static-inline functions and macroses.

Also patch adds radix_tree_find_next_bit() static-inline variant of
find_next_bit() optimized for small constant size arrays, because
find_next_bit() too heavy for searching in an array with one/two long elements.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/radix-tree.h |  139 ++++++++++++++++++++++++++++++++++++++++++
 lib/radix-tree.c           |  147 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 286 insertions(+), 0 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 07e360b..f59d6c8 100644
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
@@ -256,4 +257,142 @@ static inline void radix_tree_preload_end(void)
 	preempt_enable();
 }
 
+struct radix_tree_iter {
+	unsigned long	index;		/* current index, do not overflow it */
+	unsigned long	next_index;	/* next-to-last index for this chunk */
+	unsigned long	tags;		/* bitmask for tag-iterating */
+};
+
+#define RADIX_TREE_ITER_TAG_MASK	0x00FF	/* tag index in lower byte */
+#define RADIX_TREE_ITER_TAGGED		0x0100	/* lookup tagged slots */
+#define RADIX_TREE_ITER_CONTIG		0x0200	/* stop at first hole */
+
+void **radix_tree_next_chunk(struct radix_tree_root *root,
+			     struct radix_tree_iter *iter, unsigned flags);
+
+static inline
+void **radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start)
+{
+	iter->index = 0; /* to bypass next_index overflow protection */
+	iter->next_index = start;
+	return NULL;
+}
+
+static inline unsigned long radix_tree_chunk_size(struct radix_tree_iter *iter)
+{
+	return iter->next_index - iter->index;
+}
+
+/**
+ * radix_tree_next_slot - find next slot in chunk
+ *
+ * @slot	pointer to slot
+ * @iter	iterator state
+ * @flags	RADIX_TREE_ITER_*
+ *
+ * Returns pointer to next slot, or NULL if no more left.
+ */
+static __always_inline
+void **radix_tree_next_slot(void **slot, struct radix_tree_iter *iter,
+			    unsigned flags)
+{
+	unsigned size, offset;
+
+	size = radix_tree_chunk_size(iter) - 1;
+	if (flags & RADIX_TREE_ITER_TAGGED) {
+		iter->tags >>= 1;
+		if (likely(iter->tags & 1ul)) {
+			iter->index++;
+			return slot + 1;
+		}
+		if ((flags & RADIX_TREE_ITER_CONTIG) && size)
+			return NULL;
+		if (likely(iter->tags)) {
+			offset = __ffs(iter->tags);
+			iter->tags >>= offset;
+			iter->index += offset + 1;
+			return slot + offset + 1;
+		}
+	} else {
+		while (size--) {
+			slot++;
+			iter->index++;
+			if (likely(*slot))
+				return slot;
+			if (flags & RADIX_TREE_ITER_CONTIG)
+				return NULL;
+		}
+	}
+	return NULL;
+}
+
+/**
+ * radix_tree_for_each_chunk - iterate over chunks
+ *
+ * @slot:	the void** for pointer to chunk first slot
+ * @root	the struct radix_tree_root pointer
+ * @iter	the struct radix_tree_iter pointer
+ * @start	starting index
+ * @flags	RADIX_TREE_ITER_* and tag index
+ *
+ * Locks can be released and reasquired between iterations.
+ */
+#define radix_tree_for_each_chunk(slot, root, iter, start, flags)	\
+	for ( slot = radix_tree_iter_init(iter, start) ;		\
+	      (slot = radix_tree_next_chunk(root, iter, flags)) ; )
+
+/**
+ * radix_tree_for_each_chunk_slot - iterate over slots in one chunk
+ *
+ * @slot:	the void** for pointer to slot
+ * @iter	the struct radix_tree_iter pointer
+ * @flags	RADIX_TREE_ITER_*
+ */
+#define radix_tree_for_each_chunk_slot(slot, iter, flags)	\
+	for ( ; slot ; slot = radix_tree_next_slot(slot, iter, flags) )
+
+/**
+ * radix_tree_for_each_slot - iterate over all slots
+ *
+ * @slot:	the void** for pointer to slot
+ * @root	the struct radix_tree_root pointer
+ * @iter	the struct radix_tree_iter pointer
+ * @start	starting index
+ */
+#define radix_tree_for_each_slot(slot, root, iter, start)	\
+	for ( slot = radix_tree_iter_init(iter, start) ;	\
+	      slot || (slot = radix_tree_next_chunk(root, iter, 0)) ; \
+	      slot = radix_tree_next_slot(slot, iter, 0) )
+
+/**
+ * radix_tree_for_each_contig - iterate over all contiguous slots
+ *
+ * @slot:	the void** for pointer to slot
+ * @root	the struct radix_tree_root pointer
+ * @iter	the struct radix_tree_iter pointer
+ * @start	starting index
+ */
+#define radix_tree_for_each_contig(slot, root, iter, start)		\
+	for ( slot = radix_tree_iter_init(iter, start) ;		\
+	      slot || (slot = radix_tree_next_chunk(root, iter,		\
+				RADIX_TREE_ITER_CONTIG)) ;		\
+	      slot = radix_tree_next_slot(slot, iter,			\
+				RADIX_TREE_ITER_CONTIG) )
+
+/**
+ * radix_tree_for_each_tagged - iterate over all tagged slots
+ *
+ * @slot:	the void** for pointer to slot
+ * @root	the struct radix_tree_root pointer
+ * @iter	the struct radix_tree_iter pointer
+ * @start	starting index
+ * @tag		tag index
+ */
+#define radix_tree_for_each_tagged(slot, root, iter, start, tag)	\
+	for ( slot = radix_tree_iter_init(iter, start) ;		\
+	      slot || (slot = radix_tree_next_chunk(root, iter,		\
+			      RADIX_TREE_ITER_TAGGED | tag)) ;		\
+	      slot = radix_tree_next_slot(slot, iter,			\
+				RADIX_TREE_ITER_TAGGED) )
+
 #endif /* _LINUX_RADIX_TREE_H */
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index dc63d08..7545d39 100644
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
@@ -146,6 +147,41 @@ static inline int any_tag_set(struct radix_tree_node *node, unsigned int tag)
 	}
 	return 0;
 }
+
+/**
+ * radix_tree_find_next_bit - find the next set bit in a memory region
+ * @addr: The address to base the search on
+ * @size: The bitmap size in bits
+ * @offset: The bitnumber to start searching at
+ *
+ * Unrollable variant of find_next_bit() for constant size arrays.
+ * Tail bits starting from size to roundup(size, BITS_PER_LONG) must be zero.
+ * Returns next bit offset, or size if nothing found.
+ */
+static inline unsigned long radix_tree_find_next_bit(const unsigned long *addr,
+		unsigned long size, unsigned long offset)
+{
+	if (!__builtin_constant_p(size))
+		return find_next_bit(addr, size, offset);
+
+	if (offset < size) {
+		unsigned long tmp;
+
+		addr += offset / BITS_PER_LONG;
+		tmp = *addr >> (offset % BITS_PER_LONG);
+		if (tmp)
+			return __ffs(tmp) + offset;
+		offset = (offset + BITS_PER_LONG) & ~(BITS_PER_LONG - 1);
+		while (offset < size) {
+			tmp = *++addr;
+			if (tmp)
+				return __ffs(tmp) + offset;
+			offset += BITS_PER_LONG;
+		}
+	}
+	return size;
+}
+
 /*
  * This assumes that the caller has performed appropriate preallocation, and
  * that the caller has pinned this thread of control to the current CPU.
@@ -613,6 +649,117 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 EXPORT_SYMBOL(radix_tree_tag_get);
 
 /**
+ * radix_tree_next_chunk - find next chunk of slots for iteration
+ *
+ * @root:		radix tree root
+ * @iter:		iterator state
+ * @flags		RADIX_TREE_ITER_* flags and tag index
+ *
+ * Returns pointer to first slots in chunk, or NULL if there no more left
+ */
+void **radix_tree_next_chunk(struct radix_tree_root *root,
+			     struct radix_tree_iter *iter, unsigned flags)
+{
+	unsigned shift, tag = flags & RADIX_TREE_ITER_TAG_MASK;
+	struct radix_tree_node *rnode, *node;
+	unsigned long i, index;
+
+	if ((flags & RADIX_TREE_ITER_TAGGED) && !root_tag_get(root, tag))
+		return NULL;
+
+	/*
+	 * Catch next_index overflow after ~0UL.
+	 * iter->index can be zero only at the beginning.
+	 * Because RADIX_TREE_MAP_SHIFT < BITS_PER_LONG we cannot
+	 * oveflow iter->next_index in single step.
+	 */
+	index = iter->next_index;
+	if (!index && iter->index)
+		return NULL;
+
+	rnode = rcu_dereference_raw(root->rnode);
+	if (radix_tree_is_indirect_ptr(rnode)) {
+		rnode = indirect_to_ptr(rnode);
+	} else if (rnode && !index) {
+		/* Single-slot tree */
+		iter->index = 0;
+		iter->next_index = 1;
+		iter->tags = 1;
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
+				i = radix_tree_find_next_bit(node->tags[tag],
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
+	/* Update the iterator state */
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

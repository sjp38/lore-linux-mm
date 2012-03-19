Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id CCA2B6B00E9
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 01:19:21 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so5633707bkw.14
        for <linux-mm@kvack.org>; Sun, 18 Mar 2012 22:19:20 -0700 (PDT)
Subject: [PATCH v3] radix-tree: introduce bit-optimized iterator
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 19 Mar 2012 09:19:08 +0400
Message-ID: <20120319051817.5031.91749.stgit@zurg>
In-Reply-To: <20120210192542.5881.91143.stgit@zurg>
References: <20120210192542.5881.91143.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch implements clean, simple and effective radix-tree iteration routine.

Iterating divided into two phases:
* search for the next chunk of slots in radix-tree leaf node
* iterate through slots in this chunk

Main iterator function radix_tree_next_chunk() returns pointer to first slot,
and stores in the struct radix_tree_iter index and next-to-last slot for chunk.
For tagged-iterating it also construct bit-mask of tags for slots in chunk.
All additional logic implemented as static-inline functions and macroses.

Also patch adds radix_tree_find_next_bit() static-inline variant of
find_next_bit() optimized for small constant size arrays, because
find_next_bit() too heavy for searching in an array with one/two long elements.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

---
v3: No functional changes: renaming variables, updating comments, fixing style errors.
---
 include/linux/radix-tree.h |  195 ++++++++++++++++++++++++++++++++++++++++++++
 lib/radix-tree.c           |  151 ++++++++++++++++++++++++++++++++++
 2 files changed, 346 insertions(+), 0 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index e9a4823..240673f 100644
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
@@ -257,4 +258,198 @@ static inline void radix_tree_preload_end(void)
 	preempt_enable();
 }
 
+/**
+ * struct radix_tree_iter - radix tree iterator state
+ *
+ * @index:	index of current slot
+ * @next_index:	next-to-last index for this chunk
+ * @tags:	bit-mask for tag-iterating
+ *
+ * Radix tree iterator works in terms of "chunks" of slots.
+ * Chunk is sub-interval of slots contained in one radix tree leaf node.
+ * It described by pointer to its first slot and struct radix_tree_iter
+ * which holds chunk position in tree and its size. For tagged iterating
+ * radix_tree_iter also holds slots' bit-mask for one chosen radix tree tag.
+ */
+struct radix_tree_iter {
+	unsigned long	index;
+	unsigned long	next_index;
+	unsigned long	tags;
+};
+
+#define RADIX_TREE_ITER_TAG_MASK	0x00FF	/* tag index in lower byte */
+#define RADIX_TREE_ITER_TAGGED		0x0100	/* lookup tagged slots */
+#define RADIX_TREE_ITER_CONTIG		0x0200	/* stop at first hole */
+
+/**
+ * radix_tree_iter_init - initialize radix tree iterator
+ *
+ * @iter:	pointer to iterator state
+ * @start:	iteration starting index
+ * Returns:	NULL
+ */
+static __always_inline void **
+radix_tree_iter_init(struct radix_tree_iter *iter, unsigned long start)
+{
+	/*
+	 * Leave iter->tags unitialized. radix_tree_next_chunk()
+	 * anyway fill it in case successful tagged chunk lookup.
+	 * At unsuccessful or non-tagged lookup nobody cares about it.
+	 *
+	 * Set index to zero to bypass next_index overflow protection.
+	 * See comment inside radix_tree_next_chunk() for details.
+	 */
+	iter->index = 0;
+	iter->next_index = start;
+	return NULL;
+}
+
+/**
+ * radix_tree_next_chunk - find next chunk of slots for iteration
+ *
+ * @root:	radix tree root
+ * @iter:	iterator state
+ * @flags:	RADIX_TREE_ITER_* flags and tag index
+ * Returns:	pointer to chunk first slot, or NULL if there no more left
+ *
+ * This function lookup next chunk in the radix tree starting from
+ * @iter->next_index, it returns pointer to chunk first slot.
+ * Also it fills @iter with data about chunk: position in the tree (index),
+ * its end (next_index), and construct bit mask for tagged iterating (tags).
+ */
+void **radix_tree_next_chunk(struct radix_tree_root *root,
+			     struct radix_tree_iter *iter, unsigned flags);
+
+/**
+ * radix_tree_chunk_size - get current chunk size
+ *
+ * @iter:	pointer to radix tree iterator
+ * Returns:	current chunk size
+ */
+static __always_inline unsigned
+radix_tree_chunk_size(struct radix_tree_iter *iter)
+{
+	return iter->next_index - iter->index;
+}
+
+/**
+ * radix_tree_next_slot - find next slot in chunk
+ *
+ * @slot:	pointer to current slot
+ * @iter:	pointer to interator state
+ * @flags:	RADIX_TREE_ITER_*, should be constant
+ * Returns:	pointer to next slot, or NULL if there no more left
+ *
+ * This function updates @iter->index in case successful lookup.
+ * For tagged lookup it also eats @iter->tags.
+ */
+static __always_inline void **
+radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
+{
+	if (flags & RADIX_TREE_ITER_TAGGED) {
+		iter->tags >>= 1;
+		if (likely(iter->tags & 1ul)) {
+			iter->index++;
+			return slot + 1;
+		}
+		if (!(flags & RADIX_TREE_ITER_CONTIG) && likely(iter->tags)) {
+			unsigned offset = __ffs(iter->tags);
+
+			iter->tags >>= offset;
+			iter->index += offset + 1;
+			return slot + offset + 1;
+		}
+	} else {
+		unsigned size = radix_tree_chunk_size(iter) - 1;
+
+		while (size--) {
+			slot++;
+			iter->index++;
+			if (likely(*slot))
+				return slot;
+			if (flags & RADIX_TREE_ITER_CONTIG)
+				break;
+		}
+	}
+	return NULL;
+}
+
+/**
+ * radix_tree_for_each_chunk - iterate over chunks
+ *
+ * @slot:	the void** variable for pointer to chunk first slot
+ * @root:	the struct radix_tree_root pointer
+ * @iter:	the struct radix_tree_iter pointer
+ * @start:	iteration starting index
+ * @flags:	RADIX_TREE_ITER_* and tag index
+ *
+ * Locks can be released and reacquired between iterations.
+ */
+#define radix_tree_for_each_chunk(slot, root, iter, start, flags)	\
+	for (slot = radix_tree_iter_init(iter, start) ;			\
+	      (slot = radix_tree_next_chunk(root, iter, flags)) ;)
+
+/**
+ * radix_tree_for_each_chunk_slot - iterate over slots in one chunk
+ *
+ * @slot:	the void** variable, at the beginning points to chunk first slot
+ * @iter:	the struct radix_tree_iter pointer
+ * @flags:	RADIX_TREE_ITER_*, should be constant
+ *
+ * This macro supposed to be nested inside radix_tree_for_each_chunk().
+ * @slot points to radix tree slot, @iter->index contains its index.
+ */
+#define radix_tree_for_each_chunk_slot(slot, iter, flags)		\
+	for (; slot ; slot = radix_tree_next_slot(slot, iter, flags))
+
+/**
+ * radix_tree_for_each_slot - iterate over non-empty slots
+ *
+ * @slot:	the void** variable for pointer to slot
+ * @root:	the struct radix_tree_root pointer
+ * @iter:	the struct radix_tree_iter pointer
+ * @start:	iteration starting index
+ *
+ * @slot points to radix tree slot, @iter->index contains its index.
+ */
+#define radix_tree_for_each_slot(slot, root, iter, start)		\
+	for (slot = radix_tree_iter_init(iter, start) ;			\
+	     slot || (slot = radix_tree_next_chunk(root, iter, 0)) ;	\
+	     slot = radix_tree_next_slot(slot, iter, 0))
+
+/**
+ * radix_tree_for_each_contig - iterate over contiguous slots
+ *
+ * @slot:	the void** variable for pointer to slot
+ * @root:	the struct radix_tree_root pointer
+ * @iter:	the struct radix_tree_iter pointer
+ * @start:	iteration starting index
+ *
+ * @slot points to radix tree slot, @iter->index contains its index.
+ */
+#define radix_tree_for_each_contig(slot, root, iter, start)		\
+	for (slot = radix_tree_iter_init(iter, start) ;			\
+	     slot || (slot = radix_tree_next_chunk(root, iter,		\
+				RADIX_TREE_ITER_CONTIG)) ;		\
+	     slot = radix_tree_next_slot(slot, iter,			\
+				RADIX_TREE_ITER_CONTIG))
+
+/**
+ * radix_tree_for_each_tagged - iterate over tagged slots
+ *
+ * @slot:	the void** variable for pointer to slot
+ * @root:	the struct radix_tree_root pointer
+ * @iter:	the struct radix_tree_iter pointer
+ * @start:	iteration starting index
+ * @tag:	tag index
+ *
+ * @slot points to radix tree slot, @iter->index contains its index.
+ */
+#define radix_tree_for_each_tagged(slot, root, iter, start, tag)	\
+	for (slot = radix_tree_iter_init(iter, start) ;			\
+	     slot || (slot = radix_tree_next_chunk(root, iter,		\
+			      RADIX_TREE_ITER_TAGGED | tag)) ;		\
+	     slot = radix_tree_next_slot(slot, iter,			\
+				RADIX_TREE_ITER_TAGGED))
+
 #endif /* _LINUX_RADIX_TREE_H */
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 3e69c2b..0226e22 100644
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
@@ -146,6 +147,43 @@ static inline int any_tag_set(struct radix_tree_node *node, unsigned int tag)
 	}
 	return 0;
 }
+
+/**
+ * radix_tree_find_next_bit - find the next set bit in a memory region
+ *
+ * @addr: The address to base the search on
+ * @size: The bitmap size in bits
+ * @offset: The bitnumber to start searching at
+ *
+ * Unrollable variant of find_next_bit() for constant size arrays.
+ * Tail bits starting from size to roundup(size, BITS_PER_LONG) must be zero.
+ * Returns next bit offset, or size if nothing found.
+ */
+static __always_inline unsigned long
+radix_tree_find_next_bit(const unsigned long *addr,
+			 unsigned long size, unsigned long offset)
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
@@ -613,6 +651,119 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 EXPORT_SYMBOL(radix_tree_tag_get);
 
 /**
+ * radix_tree_next_chunk - find next chunk of slots for iteration
+ *
+ * @root:	radix tree root
+ * @iter:	iterator state
+ * @flags:	RADIX_TREE_ITER_* flags and tag index
+ * Returns:	pointer to chunk first slot, or NULL if iteration is over
+ */
+void **radix_tree_next_chunk(struct radix_tree_root *root,
+			     struct radix_tree_iter *iter, unsigned flags)
+{
+	unsigned shift, tag = flags & RADIX_TREE_ITER_TAG_MASK;
+	struct radix_tree_node *rnode, *node;
+	unsigned long index, offset;
+
+	if ((flags & RADIX_TREE_ITER_TAGGED) && !root_tag_get(root, tag))
+		return NULL;
+
+	/*
+	 * Catch next_index overflow after ~0UL. iter->index never overflows
+	 * during iterating, it can be zero only at the beginning.
+	 * And we cannot overflow iter->next_index in single step,
+	 * because RADIX_TREE_MAP_SHIFT < BITS_PER_LONG.
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
+	offset = index >> shift;
+
+	/* Index outside of the tree */
+	if (offset >= RADIX_TREE_MAP_SIZE)
+		return NULL;
+
+	node = rnode;
+	while (1) {
+		if ((flags & RADIX_TREE_ITER_TAGGED) ?
+				!test_bit(offset, node->tags[tag]) :
+				!node->slots[offset]) {
+			/* Hole detected */
+			if (flags & RADIX_TREE_ITER_CONTIG)
+				return NULL;
+
+			if (flags & RADIX_TREE_ITER_TAGGED)
+				offset = radix_tree_find_next_bit(
+						node->tags[tag],
+						RADIX_TREE_MAP_SIZE,
+						offset + 1);
+			else
+				while (++offset	< RADIX_TREE_MAP_SIZE) {
+					if (node->slots[offset])
+						break;
+				}
+			index &= ~((RADIX_TREE_MAP_SIZE << shift) - 1);
+			index += offset << shift;
+			/* Overflow after ~0UL */
+			if (!index)
+				return NULL;
+			if (offset == RADIX_TREE_MAP_SIZE)
+				goto restart;
+		}
+
+		/* This is leaf-node */
+		if (!shift)
+			break;
+
+		node = rcu_dereference_raw(node->slots[offset]);
+		if (node == NULL)
+			goto restart;
+		shift -= RADIX_TREE_MAP_SHIFT;
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+	}
+
+	/* Update the iterator state */
+	iter->index = index;
+	iter->next_index = (index | RADIX_TREE_MAP_MASK) + 1;
+
+	/* Construct iter->tags bit-mask from node->tags[tag] array */
+	if (flags & RADIX_TREE_ITER_TAGGED) {
+		unsigned tag_long, tag_bit;
+
+		tag_long = offset / BITS_PER_LONG;
+		tag_bit  = offset % BITS_PER_LONG;
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
+	return node->slots + offset;
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

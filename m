Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 1E9526B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 15:36:47 -0400 (EDT)
Received: by dakn40 with SMTP id n40so3508733dak.9
        for <linux-mm@kvack.org>; Wed, 14 Mar 2012 12:36:46 -0700 (PDT)
Date: Wed, 14 Mar 2012 12:36:11 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/4] radix-tree: iterating general cleanup
In-Reply-To: <20120314075109.GA32717@infradead.org>
Message-ID: <alpine.LSU.2.00.1203141210290.3870@eggly.anvils>
References: <20120207074905.29797.60353.stgit@zurg> <20120314073629.GA17016@infradead.org> <4F604D81.1060607@openvz.org> <20120314075109.GA32717@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 14 Mar 2012, Christoph Hellwig wrote:
> On Wed, Mar 14, 2012 at 11:49:21AM +0400, Konstantin Khlebnikov wrote:
> > Christoph Hellwig wrote:
> > >Any updates on this series?
> > 
> > I had sent "[PATCH v2 0/3] radix-tree: general iterator" February 10, there is no more updates after that.
> > I just checked v2 on top "next-20120314" -- looks like all ok.
> 
> this was more a question to the MM maintainers if this is getting
> merged or if there were any further comments.

I haven't studied the code at all - I'm afraid Konstantin is rather
more productive than I can keep up with, and other bugs and patches
appeared to be more urgent and important.

But I have included that work in most of my testing for four weeks now,
and observed no problems whatever from it.  And I made a patch for the
radix-tree test harness which akpm curates, to update its radix-tree.c
to Konstantin's: those tests ran perfectly on 64-bit and on 32-bit.
That patch to rtth appended below.

(I do have, or expect to have once I study them, reservations about
his subsequent changes to radix-tree usage in mm/shmem.c; and even
if I end up agreeing with his changes, would prefer to hold them off
until after the tmpfs fallocation mods are in - other work which
had to yield to higher priorities, ready but not yet commented.)

> 
> We'd really like to have this interface to simplify some code in XFS.

That's useful info: let's raise its priority, and hope that someone
faster than me (not a narrow category...) gets to review it.

Hugh

[PATCH] rtth: update to KK's radix-tree iterator

Signed-off-by: Hugh Dickins <hughd@google.com>

--- rtth/Makefile.0	2012-02-17 19:38:02.611537166 -0800
+++ rtth/Makefile	2012-02-17 20:32:31.351614457 -0800
@@ -2,7 +2,8 @@
 CFLAGS += -I. -g -Wall -D_LGPL_SOURCE
 LDFLAGS += -lpthread -lurcu
 TARGETS = main
-OFILES = main.o radix-tree.o linux.o test.o tag_check.o regression1.o regression2.o
+OFILES = main.o radix-tree.o linux.o test.o tag_check.o find_next_bit.o \
+	 regression1.o regression2.o
 
 targets: $(TARGETS)
 
--- rtth/find_next_bit.c.0	2012-02-17 21:07:53.556625068 -0800
+++ rtth/find_next_bit.c	2012-02-17 20:34:54.159617936 -0800
@@ -0,0 +1,57 @@
+/* find_next_bit.c: fallback find next bit implementation
+ *
+ * Copyright (C) 2004 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/types.h>
+#include <linux/bitops.h>
+
+#define BITOP_WORD(nr)		((nr) / BITS_PER_LONG)
+
+/*
+ * Find the next set bit in a memory region.
+ */
+unsigned long find_next_bit(const unsigned long *addr, unsigned long size,
+			    unsigned long offset)
+{
+	const unsigned long *p = addr + BITOP_WORD(offset);
+	unsigned long result = offset & ~(BITS_PER_LONG-1);
+	unsigned long tmp;
+
+	if (offset >= size)
+		return size;
+	size -= result;
+	offset %= BITS_PER_LONG;
+	if (offset) {
+		tmp = *(p++);
+		tmp &= (~0UL << offset);
+		if (size < BITS_PER_LONG)
+			goto found_first;
+		if (tmp)
+			goto found_middle;
+		size -= BITS_PER_LONG;
+		result += BITS_PER_LONG;
+	}
+	while (size & ~(BITS_PER_LONG-1)) {
+		if ((tmp = *(p++)))
+			goto found_middle;
+		result += BITS_PER_LONG;
+		size -= BITS_PER_LONG;
+	}
+	if (!size)
+		return result;
+	tmp = *p;
+
+found_first:
+	tmp &= (~0UL >> (BITS_PER_LONG - size));
+	if (tmp == 0UL)		/* Are any bits set? */
+		return result + size;	/* Nope. */
+found_middle:
+	return result + __ffs(tmp);
+}
--- rtth/linux/bitops.h.0	2012-02-17 19:38:02.615537110 -0800
+++ rtth/linux/bitops.h	2012-02-17 20:36:19.431619931 -0800
@@ -108,4 +108,43 @@ static inline int test_bit(int nr, const
 	return 1UL & (addr[BITOP_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
 }
 
+/**
+ * __ffs - find first bit in word.
+ * @word: The word to search
+ *
+ * Undefined if no bit exists, so code should check against 0 first.
+ */
+static inline unsigned long __ffs(unsigned long word)
+{
+	int num = 0;
+
+	if ((word & 0xffffffff) == 0) {
+		num += 32;
+		word >>= 32;
+	}
+	if ((word & 0xffff) == 0) {
+		num += 16;
+		word >>= 16;
+	}
+	if ((word & 0xff) == 0) {
+		num += 8;
+		word >>= 8;
+	}
+	if ((word & 0xf) == 0) {
+		num += 4;
+		word >>= 4;
+	}
+	if ((word & 0x3) == 0) {
+		num += 2;
+		word >>= 2;
+	}
+	if ((word & 0x1) == 0)
+		num += 1;
+	return num;
+}
+
+unsigned long find_next_bit(const unsigned long *addr,
+			    unsigned long size,
+			    unsigned long offset);
+
 #endif /* _ASM_GENERIC_BITOPS_NON_ATOMIC_H_ */
--- rtth/linux/kernel.h.0	2010-08-25 13:30:45.000000000 -0700
+++ rtth/linux/kernel.h	2012-02-17 20:21:04.607598241 -0800
@@ -14,6 +14,7 @@
 #define panic(expr)
 #define printk printf
 #define __force
+#define likely(c) (c)
 #define unlikely(c) (c)
 #define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
 
--- rtth/linux/radix-tree.h.0	2012-02-17 19:38:02.615537110 -0800
+++ rtth/linux/radix-tree.h	2012-02-17 20:21:36.911599007 -0800
@@ -2,6 +2,7 @@
  * Copyright (C) 2001 Momchil Velikov
  * Portions Copyright (C) 2001 Christoph Hellwig
  * Copyright (C) 2006 Nick Piggin
+ * Copyright (C) 2012 Konstantin Khlebnikov
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License as
@@ -23,6 +24,7 @@
 #include <linux/preempt.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
+#include <linux/bitops.h>
 #include <linux/rcupdate.h>
 
 /*
@@ -258,4 +260,142 @@ static inline void radix_tree_preload_en
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
--- rtth/radix-tree.c.0	2012-02-17 19:40:59.307536275 -0800
+++ rtth/radix-tree.c	2012-02-17 19:44:11.083545685 -0800
@@ -3,6 +3,7 @@
  * Portions Copyright (C) 2001 Christoph Hellwig
  * Copyright (C) 2005 SGI, Christoph Lameter
  * Copyright (C) 2006 Nick Piggin
+ * Copyright (C) 2012 Konstantin Khlebnikov
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License as
@@ -146,6 +147,41 @@ static inline int any_tag_set(struct rad
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
@@ -613,6 +649,117 @@ int radix_tree_tag_get(struct radix_tree
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
@@ -817,57 +964,6 @@ unsigned long radix_tree_prev_hole(struc
 }
 EXPORT_SYMBOL(radix_tree_prev_hole);
 
-static unsigned int
-__lookup(struct radix_tree_node *slot, void ***results, unsigned long *indices,
-	unsigned long index, unsigned int max_items, unsigned long *next_index)
-{
-	unsigned int nr_found = 0;
-	unsigned int shift, height;
-	unsigned long i;
-
-	height = slot->height;
-	if (height == 0)
-		goto out;
-	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
-
-	for ( ; height > 1; height--) {
-		i = (index >> shift) & RADIX_TREE_MAP_MASK;
-		for (;;) {
-			if (slot->slots[i] != NULL)
-				break;
-			index &= ~((1UL << shift) - 1);
-			index += 1UL << shift;
-			if (index == 0)
-				goto out;	/* 32-bit wraparound */
-			i++;
-			if (i == RADIX_TREE_MAP_SIZE)
-				goto out;
-		}
-
-		shift -= RADIX_TREE_MAP_SHIFT;
-		slot = rcu_dereference_raw(slot->slots[i]);
-		if (slot == NULL)
-			goto out;
-	}
-
-	/* Bottom level: grab some items */
-	for (i = index & RADIX_TREE_MAP_MASK; i < RADIX_TREE_MAP_SIZE; i++) {
-		if (slot->slots[i]) {
-			results[nr_found] = &(slot->slots[i]);
-			if (indices)
-				indices[nr_found] = index;
-			if (++nr_found == max_items) {
-				index++;
-				goto out;
-			}
-		}
-		index++;
-	}
-out:
-	*next_index = index;
-	return nr_found;
-}
-
 /**
  *	radix_tree_gang_lookup - perform multiple lookup on a radix tree
  *	@root:		radix tree root
@@ -891,48 +987,19 @@ unsigned int
 radix_tree_gang_lookup(struct radix_tree_root *root, void **results,
 			unsigned long first_index, unsigned int max_items)
 {
-	unsigned long max_index;
-	struct radix_tree_node *node;
-	unsigned long cur_index = first_index;
-	unsigned int ret;
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned int ret = 0;
 
-	node = rcu_dereference_raw(root->rnode);
-	if (!node)
+	if (unlikely(!max_items))
 		return 0;
 
-	if (!radix_tree_is_indirect_ptr(node)) {
-		if (first_index > 0)
-			return 0;
-		results[0] = node;
-		return 1;
-	}
-	node = indirect_to_ptr(node);
-
-	max_index = radix_tree_maxindex(node->height);
-
-	ret = 0;
-	while (ret < max_items) {
-		unsigned int nr_found, slots_found, i;
-		unsigned long next_index;	/* Index of next search */
-
-		if (cur_index > max_index)
-			break;
-		slots_found = __lookup(node, (void ***)results + ret, NULL,
-				cur_index, max_items - ret, &next_index);
-		nr_found = 0;
-		for (i = 0; i < slots_found; i++) {
-			struct radix_tree_node *slot;
-			slot = *(((void ***)results)[ret + i]);
-			if (!slot)
-				continue;
-			results[ret + nr_found] =
-				indirect_to_ptr(rcu_dereference_raw(slot));
-			nr_found++;
-		}
-		ret += nr_found;
-		if (next_index == 0)
+	radix_tree_for_each_slot(slot, root, &iter, first_index) {
+		results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
+		if (!results[ret])
+			continue;
+		if (++ret == max_items)
 			break;
-		cur_index = next_index;
 	}
 
 	return ret;
@@ -962,112 +1029,25 @@ radix_tree_gang_lookup_slot(struct radix
 			void ***results, unsigned long *indices,
 			unsigned long first_index, unsigned int max_items)
 {
-	unsigned long max_index;
-	struct radix_tree_node *node;
-	unsigned long cur_index = first_index;
-	unsigned int ret;
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned int ret = 0;
 
-	node = rcu_dereference_raw(root->rnode);
-	if (!node)
+	if (unlikely(!max_items))
 		return 0;
 
-	if (!radix_tree_is_indirect_ptr(node)) {
-		if (first_index > 0)
-			return 0;
-		results[0] = (void **)&root->rnode;
+	radix_tree_for_each_slot(slot, root, &iter, first_index) {
+		results[ret] = slot;
 		if (indices)
-			indices[0] = 0;
-		return 1;
-	}
-	node = indirect_to_ptr(node);
-
-	max_index = radix_tree_maxindex(node->height);
-
-	ret = 0;
-	while (ret < max_items) {
-		unsigned int slots_found;
-		unsigned long next_index;	/* Index of next search */
-
-		if (cur_index > max_index)
+			indices[ret] = iter.index;
+		if (++ret == max_items)
 			break;
-		slots_found = __lookup(node, results + ret,
-				indices ? indices + ret : NULL,
-				cur_index, max_items - ret, &next_index);
-		ret += slots_found;
-		if (next_index == 0)
-			break;
-		cur_index = next_index;
 	}
 
 	return ret;
 }
 EXPORT_SYMBOL(radix_tree_gang_lookup_slot);
 
-/*
- * FIXME: the two tag_get()s here should use find_next_bit() instead of
- * open-coding the search.
- */
-static unsigned int
-__lookup_tag(struct radix_tree_node *slot, void ***results, unsigned long index,
-	unsigned int max_items, unsigned long *next_index, unsigned int tag)
-{
-	unsigned int nr_found = 0;
-	unsigned int shift, height;
-
-	height = slot->height;
-	if (height == 0)
-		goto out;
-	shift = (height-1) * RADIX_TREE_MAP_SHIFT;
-
-	while (height > 0) {
-		unsigned long i = (index >> shift) & RADIX_TREE_MAP_MASK ;
-
-		for (;;) {
-			if (tag_get(slot, tag, i))
-				break;
-			index &= ~((1UL << shift) - 1);
-			index += 1UL << shift;
-			if (index == 0)
-				goto out;	/* 32-bit wraparound */
-			i++;
-			if (i == RADIX_TREE_MAP_SIZE)
-				goto out;
-		}
-		height--;
-		if (height == 0) {	/* Bottom level: grab some items */
-			unsigned long j = index & RADIX_TREE_MAP_MASK;
-
-			for ( ; j < RADIX_TREE_MAP_SIZE; j++) {
-				index++;
-				if (!tag_get(slot, tag, j))
-					continue;
-				/*
-				 * Even though the tag was found set, we need to
-				 * recheck that we have a non-NULL node, because
-				 * if this lookup is lockless, it may have been
-				 * subsequently deleted.
-				 *
-				 * Similar care must be taken in any place that
-				 * lookup ->slots[x] without a lock (ie. can't
-				 * rely on its value remaining the same).
-				 */
-				if (slot->slots[j]) {
-					results[nr_found++] = &(slot->slots[j]);
-					if (nr_found == max_items)
-						goto out;
-				}
-			}
-		}
-		shift -= RADIX_TREE_MAP_SHIFT;
-		slot = rcu_dereference_raw(slot->slots[i]);
-		if (slot == NULL)
-			break;
-	}
-out:
-	*next_index = index;
-	return nr_found;
-}
-
 /**
  *	radix_tree_gang_lookup_tag - perform multiple lookup on a radix tree
  *	                             based on a tag
@@ -1086,52 +1066,19 @@ radix_tree_gang_lookup_tag(struct radix_
 		unsigned long first_index, unsigned int max_items,
 		unsigned int tag)
 {
-	struct radix_tree_node *node;
-	unsigned long max_index;
-	unsigned long cur_index = first_index;
-	unsigned int ret;
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned int ret = 0;
 
-	/* check the root's tag bit */
-	if (!root_tag_get(root, tag))
+	if (unlikely(!max_items))
 		return 0;
 
-	node = rcu_dereference_raw(root->rnode);
-	if (!node)
-		return 0;
-
-	if (!radix_tree_is_indirect_ptr(node)) {
-		if (first_index > 0)
-			return 0;
-		results[0] = node;
-		return 1;
-	}
-	node = indirect_to_ptr(node);
-
-	max_index = radix_tree_maxindex(node->height);
-
-	ret = 0;
-	while (ret < max_items) {
-		unsigned int nr_found, slots_found, i;
-		unsigned long next_index;	/* Index of next search */
-
-		if (cur_index > max_index)
-			break;
-		slots_found = __lookup_tag(node, (void ***)results + ret,
-				cur_index, max_items - ret, &next_index, tag);
-		nr_found = 0;
-		for (i = 0; i < slots_found; i++) {
-			struct radix_tree_node *slot;
-			slot = *(((void ***)results)[ret + i]);
-			if (!slot)
-				continue;
-			results[ret + nr_found] =
-				indirect_to_ptr(rcu_dereference_raw(slot));
-			nr_found++;
-		}
-		ret += nr_found;
-		if (next_index == 0)
+	radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
+		results[ret] = indirect_to_ptr(rcu_dereference_raw(*slot));
+		if (!results[ret])
+			continue;
+		if (++ret == max_items)
 			break;
-		cur_index = next_index;
 	}
 
 	return ret;
@@ -1156,42 +1103,17 @@ radix_tree_gang_lookup_tag_slot(struct r
 		unsigned long first_index, unsigned int max_items,
 		unsigned int tag)
 {
-	struct radix_tree_node *node;
-	unsigned long max_index;
-	unsigned long cur_index = first_index;
-	unsigned int ret;
+	struct radix_tree_iter iter;
+	void **slot;
+	unsigned int ret = 0;
 
-	/* check the root's tag bit */
-	if (!root_tag_get(root, tag))
+	if (unlikely(!max_items))
 		return 0;
 
-	node = rcu_dereference_raw(root->rnode);
-	if (!node)
-		return 0;
-
-	if (!radix_tree_is_indirect_ptr(node)) {
-		if (first_index > 0)
-			return 0;
-		results[0] = (void **)&root->rnode;
-		return 1;
-	}
-	node = indirect_to_ptr(node);
-
-	max_index = radix_tree_maxindex(node->height);
-
-	ret = 0;
-	while (ret < max_items) {
-		unsigned int slots_found;
-		unsigned long next_index;	/* Index of next search */
-
-		if (cur_index > max_index)
-			break;
-		slots_found = __lookup_tag(node, results + ret,
-				cur_index, max_items - ret, &next_index, tag);
-		ret += slots_found;
-		if (next_index == 0)
+	radix_tree_for_each_tagged(slot, root, &iter, first_index, tag) {
+		results[ret] = slot;
+		if (++ret == max_items)
 			break;
-		cur_index = next_index;
 	}
 
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

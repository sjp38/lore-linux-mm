Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id CAF73830CD
	for <linux-mm@kvack.org>; Sat, 27 Aug 2016 10:16:15 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id e7so70524062lfe.0
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 07:16:15 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id g6si11522182lfd.337.2016.08.27.07.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Aug 2016 07:16:14 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id 33so5059128lfw.3
        for <linux-mm@kvack.org>; Sat, 27 Aug 2016 07:16:13 -0700 (PDT)
Subject: [PATCH RFC 2/4] lib/radix-tree: remove sibling entries
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Sat, 27 Aug 2016 17:16:09 +0300
Message-ID: <147230736246.10044.9648014093546992468.stgit@zurg>
In-Reply-To: <147230727479.9957.1087787722571077339.stgit@zurg>
References: <147230727479.9957.1087787722571077339.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

Current implementation stores huge entry as "canonical" head entry with
tail of "sibling" entries which points backward to the head. Iterator
jumps back and forward when sees them. This complication is required for
THP in page-cache because struct page can tell it start index and size.

This patch removes support of sibling entries but keeps part that allows
store data pointers in non-leaf slots. Huge pages will be stored as range
of slots which points to the head page.

This allows to simplify fast-path in radix_tree_next_chunk(): huge entry
is reported as single-slot chunk for any index within range.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 include/linux/radix-tree.h |   75 ++++-----------------
 lib/radix-tree.c           |  158 +++++++++++++-------------------------------
 2 files changed, 60 insertions(+), 173 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index af33e8d93ec3..1721ddbf981d 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -37,8 +37,8 @@
  * 10 - exceptional entry
  * 11 - this bit combination is currently unused/reserved
  *
- * The internal entry may be a pointer to the next level in the tree, a
- * sibling entry, or an indicator that the entry in this slot has been moved
+ * The internal entry may be a pointer to the next level in the tree
+ * or an indicator that the entry in this slot has been moved
  * to another location in the tree and the lookup should be restarted.  While
  * NULL fits the 'data pointer' pattern, it means that there is no entry in
  * the tree for this index (no matter what level of the tree it is found at).
@@ -265,13 +265,7 @@ static inline void radix_tree_replace_slot(void **pslot, void *item)
 int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			unsigned order, struct radix_tree_node **nodep,
 			void ***slotp);
-int __radix_tree_insert(struct radix_tree_root *, unsigned long index,
-			unsigned order, void *);
-static inline int radix_tree_insert(struct radix_tree_root *root,
-			unsigned long index, void *entry)
-{
-	return __radix_tree_insert(root, index, 0, entry);
-}
+int radix_tree_insert(struct radix_tree_root *, unsigned long index, void *);
 void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
 			  struct radix_tree_node **nodep, void ***slotp);
 void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
@@ -354,7 +348,6 @@ radix_tree_truncate_range(struct radix_tree_root *root,
  * @index:	index of current slot
  * @next_index:	one beyond the last index for this chunk
  * @tags:	bit-mask for tag-iterating
- * @shift:	shift for the node that holds our slots
  *
  * This radix tree iterator works in terms of "chunks" of slots.  A chunk is a
  * subinterval of slots contained within one radix tree leaf node.  It is
@@ -367,20 +360,8 @@ struct radix_tree_iter {
 	unsigned long	index;
 	unsigned long	next_index;
 	unsigned long	tags;
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-	unsigned int	shift;
-#endif
 };
 
-static inline unsigned int iter_shift(struct radix_tree_iter *iter)
-{
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-	return iter->shift;
-#else
-	return 0;
-#endif
-}
-
 #define RADIX_TREE_ITER_TAG_MASK	0x00FF	/* tag index in lower byte */
 #define RADIX_TREE_ITER_TAGGED		0x0100	/* lookup tagged slots */
 #define RADIX_TREE_ITER_CONTIG		0x0200	/* stop at first hole */
@@ -441,12 +422,6 @@ void **radix_tree_iter_retry(struct radix_tree_iter *iter)
 	return NULL;
 }
 
-static inline unsigned long
-__radix_tree_iter_add(struct radix_tree_iter *iter, unsigned long slots)
-{
-	return iter->index + (slots << iter_shift(iter));
-}
-
 /**
  * radix_tree_iter_next - resume iterating when the chunk may be invalid
  * @iter:	iterator state
@@ -458,7 +433,7 @@ __radix_tree_iter_add(struct radix_tree_iter *iter, unsigned long slots)
 static inline __must_check
 void **radix_tree_iter_next(struct radix_tree_iter *iter)
 {
-	iter->next_index = __radix_tree_iter_add(iter, 1);
+	iter->next_index = iter->index + 1;
 	iter->tags = 0;
 	return NULL;
 }
@@ -489,7 +464,7 @@ void **radix_tree_iter_jump(struct radix_tree_iter *iter, unsigned long index)
 static __always_inline long
 radix_tree_chunk_size(struct radix_tree_iter *iter)
 {
-	return (iter->next_index - iter->index) >> iter_shift(iter);
+	return iter->next_index - iter->index;
 }
 
 static inline struct radix_tree_node *entry_to_node(void *ptr)
@@ -508,6 +483,9 @@ static inline struct radix_tree_node *entry_to_node(void *ptr)
  * This function updates @iter->index in the case of a successful lookup.
  * For tagged lookup it also eats @iter->tags.
  *
+ * Please keep this fast-path as small as possible. Complicated logic is hidden
+ * inside radix_tree_next_chunk() which prepares chunks for this funciton.
+ *
  * There are several cases where 'slot' can be passed in as NULL to this
  * function.  These cases result from the use of radix_tree_iter_next() or
  * radix_tree_iter_retry().  In these cases we don't end up dereferencing
@@ -520,49 +498,24 @@ static __always_inline void **
 radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 {
 	if (flags & RADIX_TREE_ITER_TAGGED) {
-		void *canon = slot;
-
 		iter->tags >>= 1;
-		if (unlikely(!iter->tags))
-			return NULL;
-		while (IS_ENABLED(CONFIG_RADIX_TREE_MULTIORDER) &&
-					radix_tree_is_internal_node(slot[1])) {
-			if (entry_to_node(slot[1]) == canon) {
-				iter->tags >>= 1;
-				iter->index = __radix_tree_iter_add(iter, 1);
-				slot++;
-				continue;
-			}
-			iter->next_index = __radix_tree_iter_add(iter, 1);
-			return NULL;
-		}
 		if (likely(iter->tags & 1ul)) {
-			iter->index = __radix_tree_iter_add(iter, 1);
+			iter->index++;
 			return slot + 1;
 		}
-		if (!(flags & RADIX_TREE_ITER_CONTIG)) {
+		if (!(flags & RADIX_TREE_ITER_CONTIG) && likely(iter->tags)) {
 			unsigned offset = __ffs(iter->tags);
 
 			iter->tags >>= offset;
-			iter->index = __radix_tree_iter_add(iter, offset + 1);
+			iter->index += offset + 1;
 			return slot + offset + 1;
 		}
 	} else {
-		long count = radix_tree_chunk_size(iter);
-		void *canon = slot;
+		long size = radix_tree_chunk_size(iter);
 
-		while (--count > 0) {
+		while (--size > 0) {
 			slot++;
-			iter->index = __radix_tree_iter_add(iter, 1);
-
-			if (IS_ENABLED(CONFIG_RADIX_TREE_MULTIORDER) &&
-			    radix_tree_is_internal_node(*slot)) {
-				if (entry_to_node(*slot) == canon)
-					continue;
-				iter->next_index = iter->index;
-				break;
-			}
-
+			iter->index++;
 			if (likely(*slot))
 				return slot;
 			if (flags & RADIX_TREE_ITER_CONTIG) {
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index c46a60065a77..234f1ddbd7a9 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -77,21 +77,6 @@ static inline void *node_to_entry(void *ptr)
 
 #define RADIX_TREE_RETRY	node_to_entry(NULL)
 
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-/* Sibling slots point directly to another slot in the same node */
-static inline bool is_sibling_entry(struct radix_tree_node *parent, void *node)
-{
-	void **ptr = node;
-	return (parent->slots <= ptr) &&
-			(ptr < parent->slots + RADIX_TREE_MAP_SIZE);
-}
-#else
-static inline bool is_sibling_entry(struct radix_tree_node *parent, void *node)
-{
-	return false;
-}
-#endif
-
 static inline unsigned long get_slot_offset(struct radix_tree_node *parent,
 						 void **slot)
 {
@@ -104,16 +89,6 @@ static unsigned int radix_tree_descend(struct radix_tree_node *parent,
 	unsigned int offset = (index >> parent->shift) & RADIX_TREE_MAP_MASK;
 	void **entry = rcu_dereference_raw(parent->slots[offset]);
 
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-	if (radix_tree_is_internal_node(entry)) {
-		unsigned long siboff = get_slot_offset(parent, entry);
-		if (siboff < RADIX_TREE_MAP_SIZE) {
-			offset = siboff;
-			entry = rcu_dereference_raw(parent->slots[offset]);
-		}
-	}
-#endif
-
 	*nodep = (void *)entry;
 	return offset;
 }
@@ -232,12 +207,7 @@ static void dump_node(struct radix_tree_node *node, unsigned long index)
 		void *entry = node->slots[i];
 		if (!entry)
 			continue;
-		if (is_sibling_entry(node, entry)) {
-			pr_debug("radix sblng %p offset %ld val %p indices %ld-%ld\n",
-					entry, i,
-					*(void **)entry_to_node(entry),
-					first, last);
-		} else if (!radix_tree_is_internal_node(entry)) {
+		if (!radix_tree_is_internal_node(entry)) {
 			pr_debug("radix entry %p offset %ld indices %ld-%ld\n",
 					entry, i, first, last);
 		} else {
@@ -596,25 +566,6 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 		slot = &node->slots[offset];
 	}
 
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-	/* Insert pointers to the canonical entry */
-	if (order > shift) {
-		unsigned i, n = 1 << (order - shift);
-		offset = offset & ~(n - 1);
-		slot = &node->slots[offset];
-		child = node_to_entry(slot);
-		for (i = 0; i < n; i++) {
-			if (slot[i])
-				return -EEXIST;
-		}
-
-		for (i = 1; i < n; i++) {
-			rcu_assign_pointer(slot[i], child);
-			node->count++;
-		}
-	}
-#endif
-
 	if (nodep)
 		*nodep = node;
 	if (slotp)
@@ -623,16 +574,15 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 }
 
 /**
- *	__radix_tree_insert    -    insert into a radix tree
+ *	radix_tree_insert    -    insert into a radix tree
  *	@root:		radix tree root
  *	@index:		index key
- *	@order:		key covers the 2^order indices around index
  *	@item:		item to insert
  *
  *	Insert an item into the radix tree at position @index.
  */
-int __radix_tree_insert(struct radix_tree_root *root, unsigned long index,
-			unsigned order, void *item)
+int radix_tree_insert(struct radix_tree_root *root, unsigned long index,
+		      void *item)
 {
 	struct radix_tree_node *node;
 	void **slot;
@@ -640,7 +590,7 @@ int __radix_tree_insert(struct radix_tree_root *root, unsigned long index,
 
 	BUG_ON(radix_tree_is_internal_node(item));
 
-	error = __radix_tree_create(root, index, order, &node, &slot);
+	error = __radix_tree_create(root, index, 0, &node, &slot);
 	if (error)
 		return error;
 	if (*slot != NULL)
@@ -659,7 +609,7 @@ int __radix_tree_insert(struct radix_tree_root *root, unsigned long index,
 
 	return 0;
 }
-EXPORT_SYMBOL(__radix_tree_insert);
+EXPORT_SYMBOL(radix_tree_insert);
 
 /**
  *	__radix_tree_lookup	-	lookup an item in a radix tree
@@ -895,14 +845,6 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 }
 EXPORT_SYMBOL(radix_tree_tag_get);
 
-static inline void __set_iter_shift(struct radix_tree_iter *iter,
-					unsigned int shift)
-{
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-	iter->shift = shift;
-#endif
-}
-
 /**
  * radix_tree_next_chunk - find next chunk of slots for iteration
  *
@@ -914,9 +856,10 @@ static inline void __set_iter_shift(struct radix_tree_iter *iter,
 void **radix_tree_next_chunk(struct radix_tree_root *root,
 			     struct radix_tree_iter *iter, unsigned flags)
 {
-	unsigned tag = flags & RADIX_TREE_ITER_TAG_MASK;
-	struct radix_tree_node *node, *child;
+	unsigned int shift, tag = flags & RADIX_TREE_ITER_TAG_MASK;
 	unsigned long index, offset, maxindex;
+	struct radix_tree_node *node;
+	void *entry;
 
 	if ((flags & RADIX_TREE_ITER_TAGGED) && !root_tag_get(root, tag))
 		return NULL;
@@ -934,28 +877,27 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 	if (!index && iter->index)
 		return NULL;
 
- restart:
-	radix_tree_load_root(root, &child, &maxindex);
+restart:
+	shift = radix_tree_load_root(root, &node, &maxindex);
 	if (index > maxindex)
 		return NULL;
-	if (!child)
-		return NULL;
 
-	if (!radix_tree_is_internal_node(child)) {
+	if (!maxindex) {
 		/* Single-slot tree */
-		iter->index = index;
-		iter->next_index = maxindex + 1;
-		iter->tags = 1;
-		__set_iter_shift(iter, 0);
+		iter->index = 0;
+		iter->next_index = 1;
+		iter->tags = 0;
 		return (void **)&root->rnode;
 	}
 
-	do {
-		node = entry_to_node(child);
-		offset = radix_tree_descend(node, &child, index);
+	node = entry_to_node(node);
+	while (1) {
+		shift -= RADIX_TREE_MAP_SHIFT;
+		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
+		entry = rcu_dereference_raw(node->slots[offset]);
 
 		if ((flags & RADIX_TREE_ITER_TAGGED) ?
-				!tag_get(node, tag, offset) : !child) {
+				!tag_get(node, tag, offset) : !entry) {
 			/* Hole detected */
 			if (flags & RADIX_TREE_ITER_CONTIG)
 				return NULL;
@@ -967,30 +909,42 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 						offset + 1);
 			else
 				while (++offset	< RADIX_TREE_MAP_SIZE) {
-					void *slot = node->slots[offset];
-					if (is_sibling_entry(node, slot))
-						continue;
-					if (slot)
+					if (node->slots[offset])
 						break;
 				}
-			index &= ~node_maxindex(node);
-			index += offset << node->shift;
+
+			index &= ~shift_maxindex(shift);
+			index += offset << shift;
 			/* Overflow after ~0UL */
 			if (!index)
 				return NULL;
 			if (offset == RADIX_TREE_MAP_SIZE)
 				goto restart;
-			child = rcu_dereference_raw(node->slots[offset]);
+			entry = rcu_dereference_raw(node->slots[offset]);
 		}
 
-		if ((child == NULL) || (child == RADIX_TREE_RETRY))
+		/* This is leaf-node */
+		if (!shift)
+			break;
+
+		/* Non-leaf data entry */
+		if (!radix_tree_is_internal_node(entry)) {
+			/* Report as a single slot chunk */
+			iter->index = index;
+			iter->next_index = index + 1;
+			iter->tags = 0;
+			return node->slots + offset;
+		}
+
+		node = entry_to_node(entry);
+		/* RADIX_TREE_RETRY */
+		if (!node)
 			goto restart;
-	} while (radix_tree_is_internal_node(child));
+	}
 
 	/* Update the iterator state */
-	iter->index = (index &~ node_maxindex(node)) | (offset << node->shift);
-	iter->next_index = (index | node_maxindex(node)) + 1;
-	__set_iter_shift(iter, node->shift);
+	iter->index = index;
+	iter->next_index = (index | RADIX_TREE_MAP_MASK) + 1;
 
 	/* Construct iter->tags bit-mask from node->tags[tag] array */
 	if (flags & RADIX_TREE_ITER_TAGGED) {
@@ -1319,7 +1273,6 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 			goto next;
 		if (!tag_get(node, iftag, offset))
 			goto next;
-		/* Sibling slots never have tags set on them */
 		if (radix_tree_is_internal_node(child)) {
 			node = entry_to_node(child);
 			continue;
@@ -1341,7 +1294,7 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 				break;
 			tag_set(parent, settag, offset);
 		}
- next:
+next:
 		/* Go to next entry in node */
 		index = ((index >> node->shift) + 1) << node->shift;
 		/* Overflow can happen when last_index is ~0UL... */
@@ -1357,8 +1310,6 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 			node = node->parent;
 			offset = (index >> node->shift) & RADIX_TREE_MAP_MASK;
 		}
-		if (is_sibling_entry(node, node->slots[offset]))
-			goto next;
 		if (tagged >= nr_to_tag)
 			break;
 	}
@@ -1574,8 +1525,6 @@ static unsigned long __locate(struct radix_tree_node *slot, void *item,
 				continue;
 			}
 			node = entry_to_node(node);
-			if (is_sibling_entry(slot, node))
-				continue;
 			slot = node;
 			break;
 		}
@@ -1750,20 +1699,6 @@ bool __radix_tree_delete_node(struct radix_tree_root *root,
 	return deleted;
 }
 
-static inline void delete_sibling_entries(struct radix_tree_node *node,
-					void *ptr, unsigned offset)
-{
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
-	int i;
-	for (i = 1; offset + i < RADIX_TREE_MAP_SIZE; i++) {
-		if (node->slots[offset + i] != ptr)
-			break;
-		node->slots[offset + i] = NULL;
-		node->count--;
-	}
-#endif
-}
-
 /**
  *	radix_tree_delete_item    -    delete an item from a radix tree
  *	@root:		radix tree root
@@ -1803,7 +1738,6 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 		node_tag_clear(root, node, tag, offset);
 
-	delete_sibling_entries(node, node_to_entry(slot), offset);
 	node->slots[offset] = NULL;
 	node->count--;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

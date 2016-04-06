Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 85E516B0270
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:29:02 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id c20so41271878pfc.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:29:02 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id r86si6878769pfb.219.2016.04.06.14.21.54
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:54 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 19/30] radix-tree: add support for multi-order iterating
Date: Wed,  6 Apr 2016 17:21:28 -0400
Message-Id: <1459977699-2349-20-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

This enables the macros radix_tree_for_each_slot() and friends to be
used with multi-order entries.

The way that this works is that we treat all entries in a given slots[]
array as a single chunk.  If the index given to radix_tree_next_chunk()
happens to point us to a sibling entry, we will back up iter->index so
that it points to the canonical entry, and that will be the place where
we start our iteration.

As we're processing a chunk in radix_tree_next_slot(), we process
canonical entries, skip over sibling entries, and restart the chunk
lookup if we find a non-sibling indirect pointer.  This drops back to
the radix_tree_next_chunk() code, which will re-walk the tree and look
for another chunk.

This allows us to properly handle multi-order entries mixed with other
entries that are at various heights in the radix tree.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h                    | 66 +++++++++++++++++++++++----
 lib/radix-tree.c                              | 60 +++++++++++++-----------
 tools/testing/radix-tree/generated/autoconf.h |  3 ++
 tools/testing/radix-tree/linux/kernel.h       |  5 +-
 4 files changed, 95 insertions(+), 39 deletions(-)
 create mode 100644 tools/testing/radix-tree/generated/autoconf.h

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index e1512a607709..1d6686638591 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -330,8 +330,9 @@ static inline void radix_tree_preload_end(void)
  * struct radix_tree_iter - radix tree iterator state
  *
  * @index:	index of current slot
- * @next_index:	next-to-last index for this chunk
+ * @next_index:	one beyond the last index for this chunk
  * @tags:	bit-mask for tag-iterating
+ * @shift:	shift for the node that holds our slots
  *
  * This radix tree iterator works in terms of "chunks" of slots.  A chunk is a
  * subinterval of slots contained within one radix tree leaf node.  It is
@@ -344,6 +345,9 @@ struct radix_tree_iter {
 	unsigned long	index;
 	unsigned long	next_index;
 	unsigned long	tags;
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	unsigned int	shift;
+#endif
 };
 
 #define RADIX_TREE_ITER_TAG_MASK	0x00FF	/* tag index in lower byte */
@@ -405,6 +409,16 @@ void **radix_tree_iter_retry(struct radix_tree_iter *iter)
 	return NULL;
 }
 
+static inline unsigned long
+__radix_tree_iter_add(struct radix_tree_iter *iter, unsigned long slots)
+{
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	return iter->index + (slots << iter->shift);
+#else
+	return iter->index + slots;
+#endif
+}
+
 /**
  * radix_tree_iter_next - resume iterating when the chunk may be invalid
  * @iter:	iterator state
@@ -416,7 +430,7 @@ void **radix_tree_iter_retry(struct radix_tree_iter *iter)
 static inline __must_check
 void **radix_tree_iter_next(struct radix_tree_iter *iter)
 {
-	iter->next_index = iter->index + 1;
+	iter->next_index = __radix_tree_iter_add(iter, 1);
 	iter->tags = 0;
 	return NULL;
 }
@@ -430,7 +444,16 @@ void **radix_tree_iter_next(struct radix_tree_iter *iter)
 static __always_inline long
 radix_tree_chunk_size(struct radix_tree_iter *iter)
 {
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	return (iter->next_index - iter->index) >> iter->shift;
+#else
 	return iter->next_index - iter->index;
+#endif
+}
+
+static inline void *indirect_to_ptr(void *ptr)
+{
+	return (void *)((unsigned long)ptr & ~RADIX_TREE_INDIRECT_PTR);
 }
 
 /**
@@ -448,24 +471,51 @@ static __always_inline void **
 radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 {
 	if (flags & RADIX_TREE_ITER_TAGGED) {
+		void *canon = slot;
+
 		iter->tags >>= 1;
+		if (unlikely(!iter->tags))
+			return NULL;
+		while (IS_ENABLED(CONFIG_RADIX_TREE_MULTIORDER) &&
+					radix_tree_is_indirect_ptr(slot[1])) {
+			if (indirect_to_ptr(slot[1]) == canon) {
+				iter->tags >>= 1;
+				iter->index = __radix_tree_iter_add(iter, 1);
+				slot++;
+				continue;
+			}
+			iter->next_index = __radix_tree_iter_add(iter, 1);
+			return NULL;
+		}
 		if (likely(iter->tags & 1ul)) {
-			iter->index++;
+			iter->index = __radix_tree_iter_add(iter, 1);
 			return slot + 1;
 		}
-		if (!(flags & RADIX_TREE_ITER_CONTIG) && likely(iter->tags)) {
+		if (!(flags & RADIX_TREE_ITER_CONTIG)) {
 			unsigned offset = __ffs(iter->tags);
 
 			iter->tags >>= offset;
-			iter->index += offset + 1;
+			iter->index = __radix_tree_iter_add(iter, offset + 1);
 			return slot + offset + 1;
 		}
 	} else {
-		long size = radix_tree_chunk_size(iter);
+		long count = radix_tree_chunk_size(iter);
+		void *canon = slot;
 
-		while (--size > 0) {
+		while (--count > 0) {
 			slot++;
-			iter->index++;
+			iter->index = __radix_tree_iter_add(iter, 1);
+
+			if (IS_ENABLED(CONFIG_RADIX_TREE_MULTIORDER) &&
+			    radix_tree_is_indirect_ptr(*slot)) {
+				if (indirect_to_ptr(*slot) == canon)
+					continue;
+				else {
+					iter->next_index = iter->index;
+					break;
+				}
+			}
+
 			if (likely(*slot))
 				return slot;
 			if (flags & RADIX_TREE_ITER_CONTIG) {
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 33f91f207587..efcb8ed4b96b 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -75,11 +75,6 @@ static inline void *ptr_to_indirect(void *ptr)
 	return (void *)((unsigned long)ptr | RADIX_TREE_INDIRECT_PTR);
 }
 
-static inline void *indirect_to_ptr(void *ptr)
-{
-	return (void *)((unsigned long)ptr & ~RADIX_TREE_INDIRECT_PTR);
-}
-
 #define RADIX_TREE_RETRY	ptr_to_indirect(NULL)
 
 #ifdef CONFIG_RADIX_TREE_MULTIORDER
@@ -892,6 +887,13 @@ int radix_tree_tag_get(struct radix_tree_root *root,
 }
 EXPORT_SYMBOL(radix_tree_tag_get);
 
+static inline void __set_iter_shift(struct radix_tree_iter*iter, unsigned shift)
+{
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	iter->shift = shift;
+#endif
+}
+
 /**
  * radix_tree_next_chunk - find next chunk of slots for iteration
  *
@@ -905,7 +907,7 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 {
 	unsigned shift, tag = flags & RADIX_TREE_ITER_TAG_MASK;
 	struct radix_tree_node *rnode, *node;
-	unsigned long index, offset, height;
+	unsigned long index, offset, maxindex;
 
 	if ((flags & RADIX_TREE_ITER_TAGGED) && !root_tag_get(root, tag))
 		return NULL;
@@ -923,33 +925,39 @@ void **radix_tree_next_chunk(struct radix_tree_root *root,
 	if (!index && iter->index)
 		return NULL;
 
-	rnode = rcu_dereference_raw(root->rnode);
+restart:
+	shift = radix_tree_load_root(root, &rnode, &maxindex);
+	if (index > maxindex)
+		return NULL;
+
 	if (radix_tree_is_indirect_ptr(rnode)) {
 		rnode = indirect_to_ptr(rnode);
-	} else if (rnode && !index) {
+	} else if (rnode) {
 		/* Single-slot tree */
-		iter->index = 0;
-		iter->next_index = 1;
+		iter->index = index;
+		iter->next_index = maxindex + 1;
 		iter->tags = 1;
+		__set_iter_shift(iter, shift);
 		return (void **)&root->rnode;
 	} else
 		return NULL;
 
-restart:
-	height = rnode->path & RADIX_TREE_HEIGHT_MASK;
-	shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
+	shift -= RADIX_TREE_MAP_SHIFT;
 	offset = index >> shift;
 
-	/* Index outside of the tree */
-	if (offset >= RADIX_TREE_MAP_SIZE)
-		return NULL;
-
 	node = rnode;
 	while (1) {
 		struct radix_tree_node *slot;
+		unsigned new_off = radix_tree_descend(node, &slot, offset);
+
+		if (new_off < offset) {
+			offset = new_off;
+			index &= ~((RADIX_TREE_MAP_SIZE << shift) - 1);
+			index |= offset << shift;
+		}
+
 		if ((flags & RADIX_TREE_ITER_TAGGED) ?
-				!test_bit(offset, node->tags[tag]) :
-				!node->slots[offset]) {
+				!tag_get(node, tag, offset) : !slot) {
 			/* Hole detected */
 			if (flags & RADIX_TREE_ITER_CONTIG)
 				return NULL;
@@ -971,25 +979,23 @@ restart:
 				return NULL;
 			if (offset == RADIX_TREE_MAP_SIZE)
 				goto restart;
+			slot = rcu_dereference_raw(node->slots[offset]);
 		}
 
-		/* This is leaf-node */
-		if (!shift)
-			break;
-
-		slot = rcu_dereference_raw(node->slots[offset]);
-		if (slot == NULL)
+		if ((slot == NULL) || (slot == RADIX_TREE_RETRY))
 			goto restart;
 		if (!radix_tree_is_indirect_ptr(slot))
 			break;
+
 		node = indirect_to_ptr(slot);
 		shift -= RADIX_TREE_MAP_SHIFT;
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
 	}
 
 	/* Update the iterator state */
-	iter->index = index;
-	iter->next_index = (index | RADIX_TREE_MAP_MASK) + 1;
+	iter->index = index & ~((1 << shift) - 1);
+	iter->next_index = (index | ((RADIX_TREE_MAP_SIZE << shift) - 1)) + 1;
+	__set_iter_shift(iter, shift);
 
 	/* Construct iter->tags bit-mask from node->tags[tag] array */
 	if (flags & RADIX_TREE_ITER_TAGGED) {
diff --git a/tools/testing/radix-tree/generated/autoconf.h b/tools/testing/radix-tree/generated/autoconf.h
new file mode 100644
index 000000000000..ad18cf5a2a3a
--- /dev/null
+++ b/tools/testing/radix-tree/generated/autoconf.h
@@ -0,0 +1,3 @@
+#define CONFIG_RADIX_TREE_MULTIORDER 1
+#define CONFIG_SHMEM 1
+#define CONFIG_SWAP 1
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index 8ea0ed450810..be98a47b4e1b 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -8,10 +8,7 @@
 #include <limits.h>
 
 #include "../../include/linux/compiler.h"
-
-#define CONFIG_RADIX_TREE_MULTIORDER
-#define CONFIG_SHMEM
-#define CONFIG_SWAP
+#include "../../../include/linux/kconfig.h"
 
 #define RADIX_TREE_MAP_SHIFT	3
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

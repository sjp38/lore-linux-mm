Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 37B426B026C
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:20 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id s75so17164923pgs.12
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id o6si14543522pgn.138.2017.11.22.13.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 32/62] ida: Convert to using xarray
Date: Wed, 22 Nov 2017 13:07:09 -0800
Message-Id: <20171122210739.29916-33-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Use the xarray infrstructure like we used the radix tree infrastructure.
This lets us get rid of idr_get_free() from the radix tree code.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/idr.h        |   8 +-
 include/linux/radix-tree.h |   4 -
 lib/idr.c                  | 239 +++++++++++++++++++++++----------------------
 lib/radix-tree.c           |  86 +---------------
 4 files changed, 128 insertions(+), 209 deletions(-)

diff --git a/include/linux/idr.h b/include/linux/idr.h
index 57945eb0792a..8f62f7ba79fd 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -170,11 +170,11 @@ struct ida_bitmap {
 DECLARE_PER_CPU(struct ida_bitmap *, ida_bitmap);
 
 struct ida {
-	struct radix_tree_root	ida_rt;
+	struct xarray	idxa;
 };
 
 #define IDA_INIT(name)	{						\
-	.ida_rt = RADIX_TREE_INIT(name, IDR_INIT_FLAGS | GFP_NOWAIT),	\
+	.idxa = __XARRAY_INIT(name.idxa, IDR_INIT_FLAGS)		\
 }
 #define DEFINE_IDA(name)	struct ida name = IDA_INIT(name)
 
@@ -189,7 +189,7 @@ void ida_simple_remove(struct ida *ida, unsigned int id);
 
 static inline void ida_init(struct ida *ida)
 {
-	INIT_RADIX_TREE(&ida->ida_rt, IDR_INIT_FLAGS | GFP_NOWAIT);
+	__xa_init(&ida->idxa, IDR_INIT_FLAGS);
 }
 
 /**
@@ -206,6 +206,6 @@ static inline int ida_get_new(struct ida *ida, int *p_id)
 
 static inline bool ida_is_empty(const struct ida *ida)
 {
-	return radix_tree_empty(&ida->ida_rt);
+	return xa_empty(&ida->idxa);
 }
 #endif /* _LINUX_IDR_H */
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 1da1fb01e993..3e1c7ef06a0b 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -310,10 +310,6 @@ int radix_tree_split(struct radix_tree_root *, unsigned long index,
 int radix_tree_join(struct radix_tree_root *, unsigned long index,
 			unsigned new_order, void *);
 
-void __rcu **idr_get_free(struct radix_tree_root *root,
-			      struct radix_tree_iter *iter, gfp_t gfp,
-			      unsigned long max);
-
 enum {
 	RADIX_TREE_ITER_TAG_MASK = 0x0f,	/* tag index in lower nybble */
 	RADIX_TREE_ITER_TAGGED   = 0x10,	/* lookup tagged slots */
diff --git a/lib/idr.c b/lib/idr.c
index 713b19e6f1b3..574dcade0c4b 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -6,7 +6,6 @@
 #include <linux/xarray.h>
 
 DEFINE_PER_CPU(struct ida_bitmap *, ida_bitmap);
-static DEFINE_SPINLOCK(simple_ida_lock);
 
 /* In radix-tree.c temporarily */
 extern bool idr_nomem(struct xa_state *, gfp_t);
@@ -277,104 +276,114 @@ EXPORT_SYMBOL_GPL(idr_replace);
 
 #define IDA_MAX (0x80000000U / IDA_BITMAP_BITS - 1)
 
+static struct ida_bitmap *alloc_ida_bitmap(void)
+{
+	struct ida_bitmap *bitmap = this_cpu_xchg(ida_bitmap, NULL);
+	if (bitmap)
+		memset(bitmap, 0, sizeof(*bitmap));
+	return bitmap;
+}
+
+static void free_ida_bitmap(struct ida_bitmap *bitmap)
+{
+	if (this_cpu_cmpxchg(ida_bitmap, NULL, bitmap))
+		kfree(bitmap);
+}
+
 /**
  * ida_get_new_above - allocate new ID above or equal to a start id
  * @ida: ida handle
  * @start: id to start search at
  * @id: pointer to the allocated handle
  *
- * Allocate new ID above or equal to @start.  It should be called
- * with any required locks to ensure that concurrent calls to
- * ida_get_new_above() / ida_get_new() / ida_remove() are not allowed.
- * Consider using ida_simple_get() if you do not have complex locking
- * requirements.
+ * Allocate new ID above or equal to @start.  The ida has its own lock,
+ * although you may wish to provide your own locking around it.
  *
  * If memory is required, it will return %-EAGAIN, you should unlock
  * and go back to the ida_pre_get() call.  If the ida is full, it will
  * return %-ENOSPC.  On success, it will return 0.
  *
- * @id returns a value in the range @start ... %0x7fffffff.
+ * @id returns a value in the range @start ... %INT_MAX.
  */
 int ida_get_new_above(struct ida *ida, int start, int *id)
 {
-	struct radix_tree_root *root = &ida->ida_rt;
-	void __rcu **slot;
-	struct radix_tree_iter iter;
+	unsigned long flags;
+	unsigned long index = start / IDA_BITMAP_BITS;
+	unsigned int bit = start % IDA_BITMAP_BITS;
+	XA_STATE(xas, index);
 	struct ida_bitmap *bitmap;
-	unsigned long index;
-	unsigned bit;
-	int new;
-
-	index = start / IDA_BITMAP_BITS;
-	bit = start % IDA_BITMAP_BITS;
-
-	slot = radix_tree_iter_init(&iter, index);
-	for (;;) {
-		if (slot)
-			slot = radix_tree_next_slot(slot, &iter,
-						RADIX_TREE_ITER_TAGGED);
-		if (!slot) {
-			slot = idr_get_free(root, &iter, GFP_NOWAIT, IDA_MAX);
-			if (IS_ERR(slot)) {
-				if (slot == ERR_PTR(-ENOMEM))
-					return -EAGAIN;
-				return PTR_ERR(slot);
-			}
-		}
-		if (iter.index > index)
-			bit = 0;
-		new = iter.index * IDA_BITMAP_BITS;
-		bitmap = rcu_dereference_raw(*slot);
-		if (xa_is_value(bitmap)) {
-			unsigned long tmp = xa_to_value(bitmap);
-			int vbit = find_next_zero_bit(&tmp, BITS_PER_XA_VALUE,
-							bit);
-			if (vbit < BITS_PER_XA_VALUE) {
-				tmp |= 1UL << vbit;
-				rcu_assign_pointer(*slot, xa_mk_value(tmp));
-				*id = new + vbit;
-				return 0;
-			}
-			bitmap = this_cpu_xchg(ida_bitmap, NULL);
-			if (!bitmap)
-				return -EAGAIN;
-			memset(bitmap, 0, sizeof(*bitmap));
-			bitmap->bitmap[0] = tmp;
-			rcu_assign_pointer(*slot, bitmap);
-		}
+	unsigned int new;
+
+	xa_lock_irqsave(&ida->idxa, flags);
+retry:
+	bitmap = xas_find_tag(&ida->idxa, &xas, IDA_MAX, XA_FREE_TAG);
+	if (xas.xa_index > IDA_MAX)
+		goto nospc;
+	if (xas.xa_index > index)
+		bit = 0;
+	new = xas.xa_index * IDA_BITMAP_BITS;
+	if (xa_is_value(bitmap)) {
+		unsigned long value = xa_to_value(bitmap);
+		if (bit < BITS_PER_XA_VALUE) {
+			unsigned long tmp = value | ((1UL << bit) - 1);
+			bit = ffz(tmp);
 
-		if (bitmap) {
-			bit = find_next_zero_bit(bitmap->bitmap,
-							IDA_BITMAP_BITS, bit);
-			new += bit;
-			if (new < 0)
-				return -ENOSPC;
-			if (bit == IDA_BITMAP_BITS)
-				continue;
-
-			__set_bit(bit, bitmap->bitmap);
-			if (bitmap_full(bitmap->bitmap, IDA_BITMAP_BITS))
-				radix_tree_iter_tag_clear(root, &iter,
-								XA_FREE_TAG);
-		} else {
-			new += bit;
-			if (new < 0)
-				return -ENOSPC;
 			if (bit < BITS_PER_XA_VALUE) {
-				bitmap = xa_mk_value(1UL << bit);
-			} else {
-				bitmap = this_cpu_xchg(ida_bitmap, NULL);
-				if (!bitmap)
-					return -EAGAIN;
-				memset(bitmap, 0, sizeof(*bitmap));
-				__set_bit(bit, bitmap->bitmap);
+				value |= (1UL << bit);
+				xas_store(&ida->idxa, &xas, xa_mk_value(value));
+				new += bit;
+				goto unlock;
 			}
-			radix_tree_iter_replace(root, &iter, slot, bitmap);
 		}
 
-		*id = new;
-		return 0;
+		bitmap = alloc_ida_bitmap();
+		if (!bitmap)
+			goto nomem;
+		bitmap->bitmap[0] = value;
+		new += bit;
+		__set_bit(bit, bitmap->bitmap);
+		xas_store(&ida->idxa, &xas, bitmap);
+		if (xas_error(&xas))
+			free_ida_bitmap(bitmap);
+	} else if (bitmap) {
+		bit = find_next_zero_bit(bitmap->bitmap, IDA_BITMAP_BITS, bit);
+		if (bit == IDA_BITMAP_BITS)
+			goto retry;
+		new += bit;
+		if (new > INT_MAX)
+			goto nospc;
+		__set_bit(bit, bitmap->bitmap);
+		if (bitmap_full(bitmap->bitmap, IDA_BITMAP_BITS))
+			xas_clear_tag(&ida->idxa, &xas, XA_FREE_TAG);
+	} else if (bit < BITS_PER_XA_VALUE) {
+		new += bit;
+		bitmap = xa_mk_value(1UL << bit);
+		xas_store(&ida->idxa, &xas, bitmap);
+	} else {
+		bitmap = alloc_ida_bitmap();
+		if (!bitmap)
+			goto nomem;
+		new += bit;
+		__set_bit(bit, bitmap->bitmap);
+		xas_store(&ida->idxa, &xas, bitmap);
+		if (xas_error(&xas))
+			free_ida_bitmap(bitmap);
 	}
+
+	if (idr_nomem(&xas, GFP_NOWAIT))
+		goto retry;
+unlock:
+	xa_unlock_irqrestore(&ida->idxa, flags);
+	if (xas_error(&xas) == -ENOMEM)
+		return -EAGAIN;
+	*id = new;
+	return 0;
+nospc:
+	xa_unlock_irqrestore(&ida->idxa, flags);
+	return -ENOSPC;
+nomem:
+	xa_unlock_irqrestore(&ida->idxa, flags);
+	return -EAGAIN;
 }
 EXPORT_SYMBOL(ida_get_new_above);
 
@@ -382,45 +391,44 @@ EXPORT_SYMBOL(ida_get_new_above);
  * ida_remove - Free the given ID
  * @ida: ida handle
  * @id: ID to free
- *
- * This function should not be called at the same time as ida_get_new_above().
  */
 void ida_remove(struct ida *ida, int id)
 {
+	unsigned long flags;
 	unsigned long index = id / IDA_BITMAP_BITS;
-	unsigned offset = id % IDA_BITMAP_BITS;
+	unsigned bit = id % IDA_BITMAP_BITS;
+	XA_STATE(xas, index);
 	struct ida_bitmap *bitmap;
-	unsigned long *btmp;
-	struct radix_tree_iter iter;
-	void __rcu **slot;
 
-	slot = radix_tree_iter_lookup(&ida->ida_rt, &iter, index);
-	if (!slot)
+	xa_lock_irqsave(&ida->idxa, flags);
+	bitmap = xas_load(&ida->idxa, &xas);
+	if (!bitmap)
 		goto err;
-
-	bitmap = rcu_dereference_raw(*slot);
 	if (xa_is_value(bitmap)) {
-		btmp = (unsigned long *)slot;
-		offset += 1; /* Intimate knowledge of the xa_data encoding */
-		if (offset >= BITS_PER_LONG)
+		unsigned long v = xa_to_value(bitmap);
+		if (bit >= BITS_PER_XA_VALUE)
 			goto err;
+		if (!(v & (1UL << bit)))
+			goto err;
+		v &= ~(1UL << bit);
+		if (v)
+			bitmap = xa_mk_value(v);
+		else
+			bitmap = NULL;
+		xas_store(&ida->idxa, &xas, bitmap);
 	} else {
-		btmp = bitmap->bitmap;
-	}
-	if (!test_bit(offset, btmp))
-		goto err;
-
-	__clear_bit(offset, btmp);
-	radix_tree_iter_tag_set(&ida->ida_rt, &iter, XA_FREE_TAG);
-	if (xa_is_value(bitmap)) {
-		if (xa_to_value(rcu_dereference_raw(*slot)) == 0)
-			radix_tree_iter_delete(&ida->ida_rt, &iter, slot);
-	} else if (bitmap_empty(btmp, IDA_BITMAP_BITS)) {
-		kfree(bitmap);
-		radix_tree_iter_delete(&ida->ida_rt, &iter, slot);
+		if (!__test_and_clear_bit(bit, bitmap->bitmap))
+			goto err;
+		if (bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {
+			kfree(bitmap);
+			xas_store(&ida->idxa, &xas, NULL);
+		}
 	}
+	xas_set_tag(&ida->idxa, &xas, XA_FREE_TAG);
+	xa_unlock_irqrestore(&ida->idxa, flags);
 	return;
  err:
+	xa_unlock_irqrestore(&ida->idxa, flags);
 	WARN(1, "ida_remove called for id=%d which is not allocated.\n", id);
 }
 EXPORT_SYMBOL(ida_remove);
@@ -430,21 +438,21 @@ EXPORT_SYMBOL(ida_remove);
  * @ida: ida handle
  *
  * Calling this function releases all resources associated with an IDA.  When
- * this call returns, the IDA is empty and can be reused or freed.  The caller
- * should not allow ida_remove() or ida_get_new_above() to be called at the
- * same time.
+ * this call returns, the IDA is empty and can be reused or freed.
  */
 void ida_destroy(struct ida *ida)
 {
-	struct radix_tree_iter iter;
-	void __rcu **slot;
+	XA_STATE(xas, 0);
+	unsigned long flags;
+	struct ida_bitmap *bitmap;
 
-	radix_tree_for_each_slot(slot, &ida->ida_rt, &iter, 0) {
-		struct ida_bitmap *bitmap = rcu_dereference_raw(*slot);
+	xa_lock_irqsave(&ida->idxa, flags);
+	xas_for_each(&ida->idxa, &xas, bitmap, ULONG_MAX) {
 		if (!xa_is_value(bitmap))
 			kfree(bitmap);
-		radix_tree_iter_delete(&ida->ida_rt, &iter, slot);
+		xas_store(&ida->idxa, &xas, NULL);
 	}
+	xa_unlock_irqrestore(&ida->idxa, flags);
 }
 EXPORT_SYMBOL(ida_destroy);
 
@@ -468,7 +476,6 @@ int ida_simple_get(struct ida *ida, unsigned int start, unsigned int end,
 {
 	int ret, id;
 	unsigned int max;
-	unsigned long flags;
 
 	BUG_ON((int)start < 0);
 	BUG_ON((int)end < 0);
@@ -484,7 +491,6 @@ int ida_simple_get(struct ida *ida, unsigned int start, unsigned int end,
 	if (!ida_pre_get(ida, gfp_mask))
 		return -ENOMEM;
 
-	spin_lock_irqsave(&simple_ida_lock, flags);
 	ret = ida_get_new_above(ida, start, &id);
 	if (!ret) {
 		if (id > max) {
@@ -494,7 +500,6 @@ int ida_simple_get(struct ida *ida, unsigned int start, unsigned int end,
 			ret = id;
 		}
 	}
-	spin_unlock_irqrestore(&simple_ida_lock, flags);
 
 	if (unlikely(ret == -EAGAIN))
 		goto again;
@@ -515,11 +520,7 @@ EXPORT_SYMBOL(ida_simple_get);
  */
 void ida_simple_remove(struct ida *ida, unsigned int id)
 {
-	unsigned long flags;
-
 	BUG_ON((int)id < 0);
-	spin_lock_irqsave(&simple_ida_lock, flags);
 	ida_remove(ida, id);
-	spin_unlock_irqrestore(&simple_ida_lock, flags);
 }
 EXPORT_SYMBOL(ida_simple_remove);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 3fbc0751b181..f261fb2a92d2 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -247,13 +247,6 @@ static inline unsigned long node_maxindex(const struct radix_tree_node *node)
 	return shift_maxindex(node->shift);
 }
 
-static unsigned long rnext_index(unsigned long index,
-				const struct radix_tree_node *node,
-				unsigned long offset)
-{
-	return (index & ~node_maxindex(node)) + (offset << node->shift);
-}
-
 #ifndef __KERNEL__
 static void dump_node(struct radix_tree_node *node, unsigned long index)
 {
@@ -338,10 +331,10 @@ static void dump_ida_node(void *entry, unsigned long index)
 
 static void ida_dump(struct ida *ida)
 {
-	struct radix_tree_root *root = &ida->ida_rt;
-	pr_debug("ida: %p node %p free %d\n", ida, root->xa_head,
-				root->xa_flags >> ROOT_TAG_SHIFT);
-	dump_ida_node(root->xa_head, 0);
+	struct xarray *xa = &ida->idxa;
+	pr_debug("ida: %p node %p free %d\n", ida, xa->xa_head,
+				xa->xa_flags >> ROOT_TAG_SHIFT);
+	dump_ida_node(xa->xa_head, 0);
 }
 #endif
 
@@ -2124,77 +2117,6 @@ int ida_pre_get(struct ida *ida, gfp_t gfp)
 }
 EXPORT_SYMBOL(ida_pre_get);
 
-void __rcu **idr_get_free(struct radix_tree_root *root,
-			      struct radix_tree_iter *iter, gfp_t gfp,
-			      unsigned long max)
-{
-	struct radix_tree_node *node = NULL, *child;
-	void __rcu **slot = (void __rcu **)&root->xa_head;
-	unsigned long maxindex, start = iter->next_index;
-	unsigned int shift, offset = 0;
-
- grow:
-	shift = radix_tree_load_root(root, &child, &maxindex);
-	if (!radix_tree_tagged(root, XA_FREE_TAG))
-		start = max(start, maxindex + 1);
-	if (start > max)
-		return ERR_PTR(-ENOSPC);
-
-	if (start > maxindex) {
-		int error = radix_tree_extend(root, gfp, start, shift);
-		if (error < 0)
-			return ERR_PTR(error);
-		shift = error;
-		child = rcu_dereference_raw(root->xa_head);
-	}
-
-	while (shift) {
-		shift -= RADIX_TREE_MAP_SHIFT;
-		if (child == NULL) {
-			/* Have to add a child node.  */
-			child = radix_tree_node_alloc(gfp, node, root, shift,
-							offset, 0, 0);
-			if (!child)
-				return ERR_PTR(-ENOMEM);
-			all_tag_set(child, XA_FREE_TAG);
-			rcu_assign_pointer(*slot, node_to_entry(child));
-			if (node)
-				node->count++;
-		} else if (!radix_tree_is_internal_node(child))
-			break;
-
-		node = entry_to_node(child);
-		offset = radix_tree_descend(node, &child, start);
-		if (!rtag_get(node, XA_FREE_TAG, offset)) {
-			offset = radix_tree_find_next_bit(node, XA_FREE_TAG,
-							offset + 1);
-			start = rnext_index(start, node, offset);
-			if (start > max)
-				return ERR_PTR(-ENOSPC);
-			while (offset == RADIX_TREE_MAP_SIZE) {
-				offset = node->offset + 1;
-				node = node->parent;
-				if (!node)
-					goto grow;
-				shift = node->shift;
-			}
-			child = rcu_dereference_raw(node->slots[offset]);
-		}
-		slot = &node->slots[offset];
-	}
-
-	iter->index = start;
-	if (node)
-		iter->next_index = 1 + min(max, (start | node_maxindex(node)));
-	else
-		iter->next_index = 1;
-	iter->node = node;
-	__set_iter_shift(iter, shift);
-	set_iter_tags(iter, node, offset, XA_FREE_TAG);
-
-	return slot;
-}
-
 static void
 radix_tree_node_ctor(void *arg)
 {
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

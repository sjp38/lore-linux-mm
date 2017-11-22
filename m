Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6126F6B0033
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:09:44 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r23so7461906pfg.17
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:09:44 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p14si13813075pgu.569.2017.11.22.13.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:18 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 31/62] Convert IDR to use xarray
Date: Wed, 22 Nov 2017 13:07:08 -0800
Message-Id: <20171122210739.29916-32-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The one thing the IDR can do which the XArray cannot is allocate an
entry and store a NULL pointer there.  The radix tree was modified to
have this ability, but it added a lot of complexity.  Instead, we
introduce the 'Skip entry', which will read back from the XArray as
NULL through the normal API and will be skipped when iterating, but
will keep a slot allocated.  The only way to store a skip entry in the
xarray is through the advanced API, so unaware users should be
unaffected by it.

The idr_for_each_entry_ul() iterator becomes an alias for xa_for_each(),
so we drop the idr_get_next_ul() function as it has no users.

The exported IDR API was a weird mix of GPL-only and general symbols;
I converted them all to GPL as there was no way to use the IDR API
without being GPL.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/idr.h    |  93 +++++++++++++++++---------------
 include/linux/xarray.h |  18 +++++--
 lib/idr.c              | 143 ++++++++++++++++++++++---------------------------
 lib/radix-tree.c       |  75 +++++++++++++-------------
 lib/xarray.c           |   4 ++
 5 files changed, 170 insertions(+), 163 deletions(-)

diff --git a/include/linux/idr.h b/include/linux/idr.h
index 3c3346441cbc..57945eb0792a 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -9,62 +9,71 @@
  * tables.
  */
 
-#ifndef __IDR_H__
-#define __IDR_H__
+#ifndef _LINUX_IDR_H
+#define _LINUX_IDR_H
 
 #include <linux/radix-tree.h>
 #include <linux/gfp.h>
 #include <linux/percpu.h>
+#include <linux/xarray.h>
 
 struct idr {
-	struct radix_tree_root	idr_rt;
+	struct xarray	idxa;
 };
 
-/*
- * The IDR API does not expose the tagging functionality of the radix tree
- * to users.  Use tag 0 to track whether a node has free space below it.
- */
-#define IDR_FREE	0
-
-/* Set the IDR flag and the IDR_FREE tag */
-#define IDR_RT_MARKER		((__force gfp_t)(3 << __GFP_BITS_SHIFT))
+#define IDR_INIT_FLAGS		XA_FLAGS_TRACK_FREE | XA_FLAGS_TAG(0)
 
 #define IDR_INIT(name)							\
 {									\
-	.idr_rt = RADIX_TREE_INIT(name, IDR_RT_MARKER)			\
+	.idxa = __XARRAY_INIT(name.idxa, IDR_INIT_FLAGS)		\
 }
 #define DEFINE_IDR(name)	struct idr name = IDR_INIT(name)
 
+static inline void idr_init(struct idr *idr)
+{
+	__xa_init(&idr->idxa, IDR_INIT_FLAGS);
+}
+
 /**
  * DOC: idr sync
- * idr synchronization (stolen from radix-tree.h)
+ * idr synchronization
  *
- * idr_find() is able to be called locklessly, using RCU. The caller must
- * ensure calls to this function are made within rcu_read_lock() regions.
- * Other readers (lock-free or otherwise) and modifications may be running
- * concurrently.
+ * The IDR manages its own locking, using irqsafe spinlocks for operations
+ * which modify the IDR and RCU for operations which do not.  The user of
+ * the IDR may choose to wrap accesses to it in a lock if it needs to
+ * guarantee the IDR does not change during a read access.  The easiest way
+ * to do this is to grab the same lock the IDR uses for write accesses
+ * using one of the idr_lock() wrappers.
  *
- * It is still required that the caller manage the synchronization and
- * lifetimes of the items. So if RCU lock-free lookups are used, typically
- * this would mean that the items have their own locks, or are amenable to
- * lock-free access; and that the items are freed by RCU (or only freed after
- * having been deleted from the idr tree *and* a synchronize_rcu() grace
- * period).
+ * The caller must still manage the synchronization and lifetimes of the
+ * items. So if RCU lock-free lookups are used, typically this would mean
+ * that the items have their own locks, or are amenable to lock-free access;
+ * and that the items are freed by RCU (or only freed after having been
+ * deleted from the IDR *and* a synchronize_rcu() grace period has elapsed).
  */
 
-void idr_preload(gfp_t gfp_mask);
+#define idr_lock(idr)		xa_lock(&(idr)->idxa)
+#define idr_unlock(idr)		xa_unlock(&(idr)->idxa)
+#define idr_lock_bh(idr)	xa_lock_bh(&(idr)->idxa)
+#define idr_unlock_bh(idr)	xa_unlock_bh(&(idr)->idxa)
+#define idr_lock_irq(idr)	xa_lock_irq(&(idr)->idxa)
+#define idr_unlock_irq(idr)	xa_unlock_irq(&(idr)->idxa)
+#define idr_lock_irqsave(idr, flags) \
+				xa_lock_irqsave(&(idr)->idxa, flags)
+#define idr_unlock_irqrestore(idr, flags) \
+				xa_unlock_irqrestore(&(idr)->idxa, flags)
+
+void idr_preload(gfp_t);
 
 int idr_alloc(struct idr *, void *, int start, int end, gfp_t);
 int __must_check idr_alloc_ul(struct idr *, void *, unsigned long *nextid,
 			unsigned long max, gfp_t);
 int idr_alloc_cyclic(struct idr *, int *cursor, void *entry,
 			int start, int end, gfp_t);
-int idr_for_each(const struct idr *,
+int idr_for_each(struct idr *,
 		 int (*fn)(int id, void *p, void *data), void *data);
 void *idr_get_next(struct idr *, int *nextid);
-void *idr_get_next_ul(struct idr *, unsigned long *nextid);
 void *idr_replace(struct idr *, void *, unsigned long id);
-void idr_destroy(struct idr *);
 
 static inline int __must_check idr_alloc_u32(struct idr *idr, void *ptr,
 				u32 *nextid, unsigned long max, gfp_t gfp)
@@ -77,22 +86,21 @@ static inline int __must_check idr_alloc_u32(struct idr *idr, void *ptr,
 
 static inline void *idr_remove(struct idr *idr, unsigned long id)
 {
-	return radix_tree_delete_item(&idr->idr_rt, id, NULL);
+	return xa_store(&idr->idxa, id, NULL, GFP_NOWAIT);
 }
 
-static inline void idr_init(struct idr *idr)
+static inline bool idr_is_empty(const struct idr *idr)
 {
-	INIT_RADIX_TREE(&idr->idr_rt, IDR_RT_MARKER);
+	return xa_empty(&idr->idxa);
 }
 
-static inline bool idr_is_empty(const struct idr *idr)
+static inline void idr_destroy(struct idr *idr)
 {
-	return radix_tree_empty(&idr->idr_rt) &&
-		radix_tree_tagged(&idr->idr_rt, IDR_FREE);
+	xa_destroy(&idr->idxa);
 }
 
 /**
- * idr_preload_end - end preload section started with idr_preload()
+ * idr_preload_end() - end preload section started with idr_preload()
  *
  * Each idr_preload() should be matched with an invocation of this
  * function.  See idr_preload() for details.
@@ -103,7 +111,7 @@ static inline void idr_preload_end(void)
 }
 
 /**
- * idr_find - return pointer for given id
+ * idr_find() - return pointer for given id
  * @idr: idr handle
  * @id: lookup key
  *
@@ -111,12 +119,11 @@ static inline void idr_preload_end(void)
  * return indicates that @id is not valid or you passed %NULL in
  * idr_get_new().
  *
- * This function can be called under rcu_read_lock(), given that the leaf
- * pointers lifetimes are correctly managed.
+ * This function is protected by the RCU read lock.
  */
-static inline void *idr_find(const struct idr *idr, unsigned long id)
+static inline void *idr_find(struct idr *idr, unsigned long id)
 {
-	return radix_tree_lookup(&idr->idr_rt, id);
+	return xa_load(&idr->idxa, id);
 }
 
 /**
@@ -132,7 +139,7 @@ static inline void *idr_find(const struct idr *idr, unsigned long id)
 #define idr_for_each_entry(idr, entry, id)			\
 	for (id = 0; ((entry) = idr_get_next(idr, &(id))) != NULL; ++id)
 #define idr_for_each_entry_ul(idr, entry, id)			\
-	for (id = 0; ((entry) = idr_get_next_ul(idr, &(id))) != NULL; ++id)
+	xa_for_each(&(idr)->idxa, entry, id, ULONG_MAX)
 
 /**
  * idr_for_each_entry_continue - continue iteration over an idr's elements of a given type
@@ -167,7 +174,7 @@ struct ida {
 };
 
 #define IDA_INIT(name)	{						\
-	.ida_rt = RADIX_TREE_INIT(name, IDR_RT_MARKER | GFP_NOWAIT),	\
+	.ida_rt = RADIX_TREE_INIT(name, IDR_INIT_FLAGS | GFP_NOWAIT),	\
 }
 #define DEFINE_IDA(name)	struct ida name = IDA_INIT(name)
 
@@ -182,7 +189,7 @@ void ida_simple_remove(struct ida *ida, unsigned int id);
 
 static inline void ida_init(struct ida *ida)
 {
-	INIT_RADIX_TREE(&ida->ida_rt, IDR_RT_MARKER | GFP_NOWAIT);
+	INIT_RADIX_TREE(&ida->ida_rt, IDR_INIT_FLAGS | GFP_NOWAIT);
 }
 
 /**
@@ -201,4 +208,4 @@ static inline bool ida_is_empty(const struct ida *ida)
 {
 	return radix_tree_empty(&ida->ida_rt);
 }
-#endif /* __IDR_H__ */
+#endif /* _LINUX_IDR_H */
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 8ab6c4468c21..8d7cd70beb8e 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -362,7 +362,13 @@ static inline bool xa_is_sibling(void *entry)
 		(entry < xa_mk_sibling(XA_CHUNK_SIZE - 1));
 }
 
-#define XA_RETRY_ENTRY		xa_mk_internal(256)
+#define XA_SKIP_ENTRY		xa_mk_internal(256)
+#define XA_RETRY_ENTRY		xa_mk_internal(257)
+
+static inline bool xa_is_skip(void *entry)
+{
+	return unlikely(entry == XA_SKIP_ENTRY);
+}
 
 static inline bool xa_is_retry(void *entry)
 {
@@ -444,18 +450,20 @@ static inline bool xas_not_node(struct xa_node *node)
 }
 
 /**
- * xas_retry() - Handle a retry entry.
+ * xas_retry() - Retry the operation if appropriate.
  * @xas: XArray operation state.
  * @entry: Entry from xarray.
  *
- * An RCU-protected read may see a retry entry as a side-effect of a
- * simultaneous modification.  This function sets up the @xas to retry
- * the walk from the head of the array.
+ * The advanced functions may sometimes return an internal entry, such as
+ * a retry entry or a skip entry.  This function sets up the @xas to restart
+ * the walk from the head of the array if needed.
  *
  * Return: true if the operation needs to be retried.
  */
 static inline bool xas_retry(struct xa_state *xas, void *entry)
 {
+	if (xa_is_skip(entry))
+		return true;
 	if (!xa_is_retry(entry))
 		return false;
 	xas->xa_node = XAS_RESTART;
diff --git a/lib/idr.c b/lib/idr.c
index 50201b5c46e9..713b19e6f1b3 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -8,6 +8,9 @@
 DEFINE_PER_CPU(struct ida_bitmap *, ida_bitmap);
 static DEFINE_SPINLOCK(simple_ida_lock);
 
+/* In radix-tree.c temporarily */
+extern bool idr_nomem(struct xa_state *, gfp_t);
+
 /**
  * idr_alloc_ul() - allocate a large ID
  * @idr: idr handle
@@ -29,30 +32,36 @@ static DEFINE_SPINLOCK(simple_ida_lock);
 int idr_alloc_ul(struct idr *idr, void *ptr, unsigned long *nextid,
 			unsigned long max, gfp_t gfp)
 {
-	struct radix_tree_iter iter;
-	void __rcu **slot;
+	XA_STATE(xas, *nextid);
+	unsigned long flags;
+	int err;
 
-	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
+	if (WARN_ON_ONCE(xa_is_internal(ptr)))
 		return -EINVAL;
-
-	if (WARN_ON_ONCE(!(idr->idr_rt.xa_flags & ROOT_IS_IDR)))
-		idr->idr_rt.xa_flags |= IDR_RT_MARKER;
-
-	radix_tree_iter_init(&iter, *nextid);
-	slot = idr_get_free(&idr->idr_rt, &iter, gfp, max);
-	if (IS_ERR(slot))
-		return PTR_ERR(slot);
-
-	radix_tree_iter_replace(&idr->idr_rt, &iter, slot, ptr);
-	radix_tree_iter_tag_clear(&idr->idr_rt, &iter, IDR_FREE);
-
-	*nextid = iter.index;
-	return 0;
+	if (!ptr)
+		ptr = XA_SKIP_ENTRY;
+
+	do {
+		xa_lock_irqsave(&idr->idxa, flags);
+		xas_find_tag(&idr->idxa, &xas, max, XA_FREE_TAG);
+		if (xas.xa_index > max)
+			xas_set_err(&xas, ENOSPC);
+		xas_store(&idr->idxa, &xas, ptr);
+		xas_clear_tag(&idr->idxa, &xas, XA_FREE_TAG);
+		xa_unlock_irqrestore(&idr->idxa, flags);
+	} while (idr_nomem(&xas, gfp));
+
+	err = xas_error(&xas);
+	if (!err)
+		*nextid = xas.xa_index;
+	xas_destroy(&xas);
+
+	return err;
 }
 EXPORT_SYMBOL_GPL(idr_alloc_ul);
 
 /**
- * idr_alloc - allocate an id
+ * idr_alloc() - allocate an id
  * @idr: idr handle
  * @ptr: pointer to be associated with the new id
  * @start: the minimum id (inclusive)
@@ -117,10 +126,10 @@ int idr_alloc_cyclic(struct idr *idr, int *cursor, void *ptr,
 
 	return id;
 }
-EXPORT_SYMBOL(idr_alloc_cyclic);
+EXPORT_SYMBOL_GPL(idr_alloc_cyclic);
 
 /**
- * idr_for_each - iterate through all stored pointers
+ * idr_for_each() - iterate through all stored pointers
  * @idr: idr handle
  * @fn: function to be called for each pointer
  * @data: data passed to callback function
@@ -136,69 +145,41 @@ EXPORT_SYMBOL(idr_alloc_cyclic);
  * seen and deleted entries may be seen, but adding and removing entries
  * will not cause other entries to be skipped, nor spurious ones to be seen.
  */
-int idr_for_each(const struct idr *idr,
+int idr_for_each(struct idr *idr,
 		int (*fn)(int id, void *p, void *data), void *data)
 {
-	struct radix_tree_iter iter;
-	void __rcu **slot;
+	unsigned long i = 0;
+	void *p;
 
-	radix_tree_for_each_slot(slot, &idr->idr_rt, &iter, 0) {
-		int ret = fn(iter.index, rcu_dereference_raw(*slot), data);
+	xa_for_each(&idr->idxa, p, i, INT_MAX) {
+		int ret = fn(i, p, data);
 		if (ret)
 			return ret;
 	}
 
 	return 0;
 }
-EXPORT_SYMBOL(idr_for_each);
-
-/**
- * idr_get_next - Find next populated entry
- * @idr: idr handle
- * @nextid: Pointer to lowest possible ID to return
- *
- * Returns the next populated entry in the tree with an ID greater than
- * or equal to the value pointed to by @nextid.  On exit, @nextid is updated
- * to the ID of the found value.  To use in a loop, the value pointed to by
- * nextid must be incremented by the user.
- */
-void *idr_get_next(struct idr *idr, int *nextid)
-{
-	struct radix_tree_iter iter;
-	void __rcu **slot;
-
-	slot = radix_tree_iter_find(&idr->idr_rt, &iter, *nextid);
-	if (!slot)
-		return NULL;
-
-	*nextid = iter.index;
-	return rcu_dereference_raw(*slot);
-}
-EXPORT_SYMBOL(idr_get_next);
+EXPORT_SYMBOL_GPL(idr_for_each);
 
 /**
- * idr_get_next_ul - Find next populated entry
+ * idr_get_next() - Find next populated entry
  * @idr: idr handle
- * @nextid: Pointer to lowest possible ID to return
+ * @id: Pointer to lowest possible ID to return
  *
  * Returns the next populated entry in the tree with an ID greater than
  * or equal to the value pointed to by @nextid.  On exit, @nextid is updated
  * to the ID of the found value.  To use in a loop, the value pointed to by
  * nextid must be incremented by the user.
  */
-void *idr_get_next_ul(struct idr *idr, unsigned long *nextid)
+void *idr_get_next(struct idr *idr, int *id)
 {
-	struct radix_tree_iter iter;
-	void __rcu **slot;
+	unsigned long index = *id;
+	void *entry = xa_find(&idr->idxa, &index, INT_MAX);
 
-	slot = radix_tree_iter_find(&idr->idr_rt, &iter, *nextid);
-	if (!slot)
-		return NULL;
-
-	*nextid = iter.index;
-	return rcu_dereference_raw(*slot);
+	*id = index;
+	return entry;
 }
-EXPORT_SYMBOL(idr_get_next_ul);
+EXPORT_SYMBOL_GPL(idr_get_next);
 
 /**
  * idr_replace - replace pointer for given id
@@ -216,22 +197,28 @@ EXPORT_SYMBOL(idr_get_next_ul);
  */
 void *idr_replace(struct idr *idr, void *ptr, unsigned long id)
 {
-	struct radix_tree_node *node;
-	void __rcu **slot = NULL;
-	void *entry;
+	XA_STATE(xas, id);
+	unsigned long flags;
+	void *curr;
 
-	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
+	if (WARN_ON_ONCE(xa_is_internal(ptr)))
 		return ERR_PTR(-EINVAL);
-
-	entry = __radix_tree_lookup(&idr->idr_rt, id, &node, &slot);
-	if (!slot || radix_tree_tag_get(&idr->idr_rt, id, IDR_FREE))
-		return ERR_PTR(-ENOENT);
-
-	__radix_tree_replace(&idr->idr_rt, node, slot, ptr, NULL);
-
-	return entry;
+	if (!ptr)
+		ptr = XA_SKIP_ENTRY;
+
+	xa_lock_irqsave(&idr->idxa, flags);
+	curr = xas_load(&idr->idxa, &xas);
+	if (curr)
+		xas_store(&idr->idxa, &xas, ptr);
+	else
+		curr = ERR_PTR(-ENOENT);
+	xa_unlock_irqrestore(&idr->idxa, flags);
+
+	if (xa_is_skip(curr))
+		return NULL;
+	return curr;
 }
-EXPORT_SYMBOL(idr_replace);
+EXPORT_SYMBOL_GPL(idr_replace);
 
 /**
  * DOC: IDA description
@@ -262,7 +249,7 @@ EXPORT_SYMBOL(idr_replace);
  * Developer's notes:
  *
  * The IDA uses the functionality provided by the IDR & radix tree to store
- * bitmaps in each entry.  The IDR_FREE tag means there is at least one bit
+ * bitmaps in each entry.  The XA_FREE_TAG tag means there is at least one bit
  * free, unlike the IDR where it means at least one entry is free.
  *
  * I considered telling the radix tree that each slot is an order-10 node
@@ -368,7 +355,7 @@ int ida_get_new_above(struct ida *ida, int start, int *id)
 			__set_bit(bit, bitmap->bitmap);
 			if (bitmap_full(bitmap->bitmap, IDA_BITMAP_BITS))
 				radix_tree_iter_tag_clear(root, &iter,
-								IDR_FREE);
+								XA_FREE_TAG);
 		} else {
 			new += bit;
 			if (new < 0)
@@ -424,7 +411,7 @@ void ida_remove(struct ida *ida, int id)
 		goto err;
 
 	__clear_bit(offset, btmp);
-	radix_tree_iter_tag_set(&ida->ida_rt, &iter, IDR_FREE);
+	radix_tree_iter_tag_set(&ida->ida_rt, &iter, XA_FREE_TAG);
 	if (xa_is_value(bitmap)) {
 		if (xa_to_value(rcu_dereference_raw(*slot)) == 0)
 			radix_tree_iter_delete(&ida->ida_rt, &iter, slot);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 29b38d447497..3fbc0751b181 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -572,6 +572,28 @@ int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order)
 	return __radix_tree_preload(gfp_mask, nr_nodes);
 }
 
+/* Once the IDR users abandon the preload API, we can use xas_nomem */
+bool idr_nomem(struct xa_state *xas, gfp_t gfp)
+{
+	if (xas->xa_node != XAS_ERROR(ENOMEM))
+		return false;
+	xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep,
+						gfp | __GFP_NOWARN);
+	if (!xas->xa_alloc) {
+		struct radix_tree_preload *rtp;
+
+		rtp = this_cpu_ptr(&radix_tree_preloads);
+		if (!rtp->nr)
+			return false;
+		xas->xa_alloc = rtp->nodes;
+		rtp->nodes = xas->xa_alloc->parent;
+		rtp->nr--;
+	}
+
+	xas->xa_node = XAS_RESTART;
+	return true;
+}
+
 static unsigned radix_tree_load_root(const struct radix_tree_root *root,
 		struct radix_tree_node **nodep, unsigned long *maxindex)
 {
@@ -605,7 +627,7 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 		maxshift += RADIX_TREE_MAP_SHIFT;
 
 	entry = rcu_dereference_raw(root->xa_head);
-	if (!entry && (!is_idr(root) || root_tag_get(root, IDR_FREE)))
+	if (!entry && (!is_idr(root) || root_tag_get(root, XA_FREE_TAG)))
 		goto out;
 
 	do {
@@ -615,10 +637,10 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 			return -ENOMEM;
 
 		if (is_idr(root)) {
-			all_tag_set(node, IDR_FREE);
-			if (!root_tag_get(root, IDR_FREE)) {
-				rtag_clear(node, IDR_FREE, 0);
-				root_tag_set(root, IDR_FREE);
+			all_tag_set(node, XA_FREE_TAG);
+			if (!root_tag_get(root, XA_FREE_TAG)) {
+				rtag_clear(node, XA_FREE_TAG, 0);
+				root_tag_set(root, XA_FREE_TAG);
 			}
 		} else {
 			/* Propagate the aggregated tag info to the new child */
@@ -689,8 +711,8 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
 		 * one (root->xa_head) as far as dependent read barriers go.
 		 */
 		root->xa_head = (void __rcu *)child;
-		if (is_idr(root) && !rtag_get(node, IDR_FREE, 0))
-			root_tag_clear(root, IDR_FREE);
+		if (is_idr(root) && !rtag_get(node, XA_FREE_TAG, 0))
+			root_tag_clear(root, XA_FREE_TAG);
 
 		/*
 		 * We have a dilemma here. The node's slot[0] must not be
@@ -1117,7 +1139,7 @@ static bool node_tag_get(const struct radix_tree_root *root,
 /*
  * IDR users want to be able to store NULL in the tree, so if the slot isn't
  * free, don't adjust the count, even if it's transitioning between NULL and
- * non-NULL.  For the IDA, we mark slots as being IDR_FREE while they still
+ * non-NULL.  For the IDA, we mark slots as being XA_FREE_TAG while they still
  * have empty bits, but it only stores NULL in slots when they're being
  * deleted.
  */
@@ -1127,7 +1149,7 @@ static int calculate_count(struct radix_tree_root *root,
 {
 	if (is_idr(root)) {
 		unsigned offset = get_slot_offset(node, slot);
-		bool free = node_tag_get(root, node, IDR_FREE, offset);
+		bool free = node_tag_get(root, node, XA_FREE_TAG, offset);
 		if (!free)
 			return 0;
 		if (!old)
@@ -1958,7 +1980,7 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
 	int tag;
 
 	if (is_idr(root))
-		node_tag_set(root, node, IDR_FREE, offset);
+		node_tag_set(root, node, XA_FREE_TAG, offset);
 	else
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 			node_tag_clear(root, node, tag, offset);
@@ -2006,7 +2028,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 	void *entry;
 
 	entry = __radix_tree_lookup(root, index, &node, &slot);
-	if (!entry && (!is_idr(root) || node_tag_get(root, node, IDR_FREE,
+	if (!entry && (!is_idr(root) || node_tag_get(root, node, XA_FREE_TAG,
 						get_slot_offset(node, slot))))
 		return NULL;
 
@@ -2113,7 +2135,7 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 
  grow:
 	shift = radix_tree_load_root(root, &child, &maxindex);
-	if (!radix_tree_tagged(root, IDR_FREE))
+	if (!radix_tree_tagged(root, XA_FREE_TAG))
 		start = max(start, maxindex + 1);
 	if (start > max)
 		return ERR_PTR(-ENOSPC);
@@ -2134,7 +2156,7 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 							offset, 0, 0);
 			if (!child)
 				return ERR_PTR(-ENOMEM);
-			all_tag_set(child, IDR_FREE);
+			all_tag_set(child, XA_FREE_TAG);
 			rcu_assign_pointer(*slot, node_to_entry(child));
 			if (node)
 				node->count++;
@@ -2143,8 +2165,8 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 
 		node = entry_to_node(child);
 		offset = radix_tree_descend(node, &child, start);
-		if (!rtag_get(node, IDR_FREE, offset)) {
-			offset = radix_tree_find_next_bit(node, IDR_FREE,
+		if (!rtag_get(node, XA_FREE_TAG, offset)) {
+			offset = radix_tree_find_next_bit(node, XA_FREE_TAG,
 							offset + 1);
 			start = rnext_index(start, node, offset);
 			if (start > max)
@@ -2168,32 +2190,11 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 		iter->next_index = 1;
 	iter->node = node;
 	__set_iter_shift(iter, shift);
-	set_iter_tags(iter, node, offset, IDR_FREE);
+	set_iter_tags(iter, node, offset, XA_FREE_TAG);
 
 	return slot;
 }
 
-/**
- * idr_destroy - release all internal memory from an IDR
- * @idr: idr handle
- *
- * After this function is called, the IDR is empty, and may be reused or
- * the data structure containing it may be freed.
- *
- * A typical clean-up sequence for objects stored in an idr tree will use
- * idr_for_each() to free all objects, if necessary, then idr_destroy() to
- * free the memory used to keep track of those objects.
- */
-void idr_destroy(struct idr *idr)
-{
-	struct radix_tree_node *node = rcu_dereference_raw(idr->idr_rt.xa_head);
-	if (radix_tree_is_internal_node(node))
-		radix_tree_free_nodes(node);
-	idr->idr_rt.xa_head = NULL;
-	root_tag_set(&idr->idr_rt, IDR_FREE);
-}
-EXPORT_SYMBOL(idr_destroy);
-
 static void
 radix_tree_node_ctor(void *arg)
 {
diff --git a/lib/xarray.c b/lib/xarray.c
index 38e5fe39bb97..4990ff18db9d 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1078,6 +1078,8 @@ void *xa_load(struct xarray *xa, unsigned long index)
 	rcu_read_lock();
 	do {
 		entry = xas_load(xa, &xas);
+		if (xa_is_skip(entry))
+			entry = NULL;
 	} while (xas_retry(&xas, entry));
 	rcu_read_unlock();
 
@@ -1113,6 +1115,8 @@ void *xa_store(struct xarray *xa, unsigned long index, void *entry, gfp_t gfp)
 		xa_lock_irqsave(xa, flags);
 		curr = xas_store(xa, &xas, entry);
 		xa_unlock_irqrestore(xa, flags);
+		if (xa_is_skip(curr))
+			curr = NULL;
 	} while (xas_nomem(&xas, gfp));
 	xas_destroy(&xas);
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5796B038A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:13:56 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x66so21749488pfb.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:13:56 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b189si2403388pga.296.2017.02.28.10.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 10:13:52 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 2/2] XArray: Convert IDR and add test suite
Date: Tue, 28 Feb 2017 10:13:43 -0800
Message-Id: <20170228181343.16588-3-willy@infradead.org>
In-Reply-To: <20170228181343.16588-1-willy@infradead.org>
References: <20170228181343.16588-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

The test suite for the xarray is still quite modest, but converting
the IDR and the IDA to use the xarray lets me use the IDR & IDA test
suites to test the xarray.  They have been very helpful in finding bugs
(and poor design decisions).

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/idr.h                            | 136 ++-----
 lib/idr.c                                      | 503 +++++++++++++++----------
 lib/radix-tree.c                               | 169 +--------
 tools/include/asm/bug.h                        |   4 +
 tools/include/linux/kernel.h                   |   1 +
 tools/include/linux/spinlock.h                 |   7 +-
 tools/testing/radix-tree/.gitignore            |   4 +-
 tools/testing/radix-tree/Makefile              |  34 +-
 tools/testing/radix-tree/{idr-test.c => idr.c} |  37 +-
 tools/testing/radix-tree/linux.c               |   2 +-
 tools/testing/radix-tree/linux/radix-tree.h    |   5 -
 tools/testing/radix-tree/linux/rcupdate.h      |   2 +
 tools/testing/radix-tree/linux/xarray.h        |   1 +
 tools/testing/radix-tree/test.c                |  59 +--
 tools/testing/radix-tree/test.h                |  48 ++-
 tools/testing/radix-tree/xarray.c              | 241 ++++++++++++
 16 files changed, 712 insertions(+), 541 deletions(-)
 rename tools/testing/radix-tree/{idr-test.c => idr.c} (91%)
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray.c

diff --git a/include/linux/idr.h b/include/linux/idr.h
index bf70b3ef0a07..681cc6e7591f 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -9,100 +9,58 @@
  * tables.
  */
 
-#ifndef __IDR_H__
-#define __IDR_H__
+#ifndef _LINUX_IDR_H
+#define _LINUX_IDR_H
 
-#include <linux/radix-tree.h>
+#include <linux/xarray.h>
 #include <linux/gfp.h>
 #include <linux/percpu.h>
+#include <linux/preempt.h>
 
 struct idr {
-	struct radix_tree_root	idr_rt;
-	unsigned int		idr_next;
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
-
-#define IDR_INIT							\
-{									\
-	.idr_rt = RADIX_TREE_INIT(IDR_RT_MARKER)			\
-}
-#define DEFINE_IDR(name)	struct idr name = IDR_INIT
-
-/**
- * idr_get_cursor - Return the current position of the cyclic allocator
- * @idr: idr handle
- *
- * The value returned is the value that will be next returned from
- * idr_alloc_cyclic() if it is free (otherwise the search will start from
- * this position).
- */
-static inline unsigned int idr_get_cursor(const struct idr *idr)
-{
-	return READ_ONCE(idr->idr_next);
-}
-
-/**
- * idr_set_cursor - Set the current position of the cyclic allocator
- * @idr: idr handle
- * @val: new position
- *
- * The next call to idr_alloc_cyclic() will return @val if it is free
- * (otherwise the search will start from this position).
- */
-static inline void idr_set_cursor(struct idr *idr, unsigned int val)
-{
-	WRITE_ONCE(idr->idr_next, val);
+#define IDR_INIT(name)					\
+{							\
+	.idxa = XARRAY_FREE_INIT(name.idxa)		\
 }
+#define DEFINE_IDR(name)	struct idr name = IDR_INIT(name)
+#define idr_init(idr) do {				\
+	*(idr) = IDR_INIT(#idr)				\
+} while (0)
 
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
+ * the IDR may choose to wrap accesses to it in another lock if it needs
+ * to guarantee the IDR does not change during a read access.
  *
- * It is still required that the caller manage the synchronization and
- * lifetimes of the items. So if RCU lock-free lookups are used, typically
- * this would mean that the items have their own locks, or are amenable to
- * lock-free access; and that the items are freed by RCU (or only freed after
- * having been deleted from the idr tree *and* a synchronize_rcu() grace
- * period).
+ * The caller must still manage the synchronization and lifetimes of the
+ * items.  So if RCU lock-free lookups are used, typically this would mean
+ * that the items have their own locks, or are amenable to lock-free access;
+ * and that the items are freed by RCU (or only freed after having been
+ * deleted from the IDR *and* a synchronize_rcu() grace period).
  */
 
-void idr_preload(gfp_t gfp_mask);
+void idr_preload(gfp_t);
 int idr_alloc(struct idr *, void *entry, int start, int end, gfp_t);
-int idr_alloc_cyclic(struct idr *, void *entry, int start, int end, gfp_t);
+int idr_alloc_cyclic(struct idr *, int *cursor, void *entry,
+		int start, int end, gfp_t);
+void *idr_find(const struct idr *, int id);
 int idr_for_each(const struct idr *,
 		 int (*fn)(int id, void *p, void *data), void *data);
-void *idr_get_next(struct idr *, int *nextid);
+void *idr_get_next(const struct idr *, int *nextid);
 void *idr_replace(struct idr *, void *, int id);
+void *idr_remove(struct idr *, int id);
 void idr_destroy(struct idr *);
 
-static inline void *idr_remove(struct idr *idr, int id)
-{
-	return radix_tree_delete_item(&idr->idr_rt, id, NULL);
-}
-
-static inline void idr_init(struct idr *idr)
-{
-	INIT_RADIX_TREE(&idr->idr_rt, IDR_RT_MARKER);
-	idr->idr_next = 0;
-}
-
 static inline bool idr_is_empty(const struct idr *idr)
 {
-	return radix_tree_empty(&idr->idr_rt) &&
-		radix_tree_tagged(&idr->idr_rt, IDR_FREE);
+	return xa_empty(&idr->idxa);
 }
 
 /**
@@ -117,23 +75,6 @@ static inline void idr_preload_end(void)
 }
 
 /**
- * idr_find - return pointer for given id
- * @idr: idr handle
- * @id: lookup key
- *
- * Return the pointer given the id it has been registered with.  A %NULL
- * return indicates that @id is not valid or you passed %NULL in
- * idr_get_new().
- *
- * This function can be called under rcu_read_lock(), given that the leaf
- * pointers lifetimes are correctly managed.
- */
-static inline void *idr_find(const struct idr *idr, int id)
-{
-	return radix_tree_lookup(&idr->idr_rt, id);
-}
-
-/**
  * idr_for_each_entry - iterate over an idr's elements of a given type
  * @idr:     idr handle
  * @entry:   the type * to use as cursor
@@ -175,13 +116,13 @@ struct ida_bitmap {
 DECLARE_PER_CPU(struct ida_bitmap *, ida_bitmap);
 
 struct ida {
-	struct radix_tree_root	ida_rt;
+	struct xarray idxa;
 };
 
-#define IDA_INIT	{						\
-	.ida_rt = RADIX_TREE_INIT(IDR_RT_MARKER | GFP_NOWAIT),		\
+#define IDA_INIT(name)	{				\
+	.idxa = XARRAY_FREE_INIT(name.idxa)		\
 }
-#define DEFINE_IDA(name)	struct ida name = IDA_INIT
+#define DEFINE_IDA(name)	struct ida name = IDA_INIT(name)
 
 int ida_pre_get(struct ida *ida, gfp_t gfp_mask);
 int ida_get_new_above(struct ida *ida, int starting_id, int *p_id);
@@ -190,12 +131,7 @@ void ida_destroy(struct ida *ida);
 
 int ida_simple_get(struct ida *ida, unsigned int start, unsigned int end,
 		   gfp_t gfp_mask);
-void ida_simple_remove(struct ida *ida, unsigned int id);
-
-static inline void ida_init(struct ida *ida)
-{
-	INIT_RADIX_TREE(&ida->ida_rt, IDR_RT_MARKER | GFP_NOWAIT);
-}
+#define ida_simple_remove(ida, id) ida_remove(ida, id);
 
 /**
  * ida_get_new - allocate new ID
@@ -211,6 +147,6 @@ static inline int ida_get_new(struct ida *ida, int *p_id)
 
 static inline bool ida_is_empty(const struct ida *ida)
 {
-	return radix_tree_empty(&ida->ida_rt);
+	return xa_empty(&ida->idxa);
 }
-#endif /* __IDR_H__ */
+#endif /* __LINUX_IDR_H */
diff --git a/lib/idr.c b/lib/idr.c
index b13682bb0a1c..c280f0ee9440 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -1,14 +1,94 @@
+#define XA_ADVANCED
+
 #include <linux/bitmap.h>
+#include <linux/err.h>
 #include <linux/export.h>
 #include <linux/idr.h>
+#include <linux/percpu.h>
+#include <linux/preempt.h>
+#include <linux/radix-tree.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/xarray.h>
 
 DEFINE_PER_CPU(struct ida_bitmap *, ida_bitmap);
-static DEFINE_SPINLOCK(simple_ida_lock);
+
+static inline void *idr_null(void *entry)
+{
+	return entry == XA_IDR_NULL ? NULL : entry;
+}
+
+/* Until we get the IDR preload API fixed */
+struct radix_tree_preload {
+	unsigned nr;
+	struct radix_tree_node *nodes;
+};
+DECLARE_PER_CPU(struct radix_tree_preload, radix_tree_preloads);
+
+static bool idr_nomem(struct xa_state *xas, gfp_t gfp)
+{
+	struct radix_tree_preload *rtp;
+
+	BUILD_BUG_ON(sizeof(struct radix_tree_node) != sizeof(struct xa_node));
+	if (xas->xa_node != ERR_PTR(-ENOMEM))
+		return false;
+	xas->xa_alloc = kmem_cache_alloc(xa_node_cache, gfp | __GFP_NOWARN);
+	if (xas->xa_alloc)
+		goto alloc;
+
+	rtp = this_cpu_ptr(&radix_tree_preloads);
+	if (!rtp->nr)
+		return false;
+	xas->xa_alloc = (struct xa_node *)rtp->nodes;
+	rtp->nodes = (struct radix_tree_node *)xas->xa_alloc->parent;
+	rtp->nr--;
+
+alloc:
+	xas->xa_node = XA_WALK_RESTART;
+	return true;
+}
+
+static int __idr_alloc(struct idr *idr, void *ptr, int start, int min,
+		int end, gfp_t gfp)
+{
+	struct xa_state xas;
+	unsigned long flags;
+	void *entry;
+	int id;
+	unsigned long max = (end > 0) ? end - 1 : INT_MAX;
+
+	if (WARN_ON_ONCE(xa_is_internal(ptr)))
+		return -EINVAL;
+	if (!ptr)
+		ptr = XA_IDR_NULL;
+
+	xas_init(&xas, start);
+	do {
+		xa_lock_irqsave(&idr->idxa, flags);
+		entry = xas_find_tag(&idr->idxa, &xas, max, XA_FREE_TAG);
+		if (entry == XA_WALK_END) {
+			if ((xas.xa_index > max) && (min < start)) {
+				xas_jump(&xas, min);
+				entry = xas_find_tag(&idr->idxa, &xas, max,
+							XA_FREE_TAG);
+			}
+			if (xas.xa_index > max)
+				xas_set_err(&xas, -ENOSPC);
+		}
+		xas_store(&idr->idxa, &xas, ptr);
+		xa_unlock_irqrestore(&idr->idxa, flags);
+	} while (idr_nomem(&xas, gfp));
+
+	id = xas.xa_index;
+	if (IS_ERR(xas.xa_node))
+		id = PTR_ERR(xas.xa_node);
+	xas_destroy(&xas);
+
+	return id;
+}
 
 /**
- * idr_alloc - allocate an id
+ * idr_alloc() - allocate an id
  * @idr: idr handle
  * @ptr: pointer to be associated with the new id
  * @start: the minimum id (inclusive)
@@ -21,34 +101,16 @@ static DEFINE_SPINLOCK(simple_ida_lock);
  * Note that @end is treated as max when <= 0.  This is to always allow
  * using @start + N as @end as long as N is inside integer range.
  *
- * Simultaneous modifications to the @idr are not allowed and should be
- * prevented by the user, usually with a lock.  idr_alloc() may be called
- * concurrently with read-only accesses to the @idr, such as idr_find() and
- * idr_for_each_entry().
+ * Protected by the irqsafe spinlock
  */
 int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
 {
-	void __rcu **slot;
-	struct radix_tree_iter iter;
-
-	if (WARN_ON_ONCE(start < 0))
-		return -EINVAL;
-	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
-		return -EINVAL;
-
-	radix_tree_iter_init(&iter, start);
-	slot = idr_get_free(&idr->idr_rt, &iter, gfp, end);
-	if (IS_ERR(slot))
-		return PTR_ERR(slot);
-
-	radix_tree_iter_replace(&idr->idr_rt, &iter, slot, ptr);
-	radix_tree_iter_tag_clear(&idr->idr_rt, &iter, IDR_FREE);
-	return iter.index;
+	return __idr_alloc(idr, ptr, start, start, end, gfp);
 }
 EXPORT_SYMBOL_GPL(idr_alloc);
 
 /**
- * idr_alloc_cyclic - allocate new idr entry in a cyclical fashion
+ * idr_alloc_cyclic() - allocate new idr entry in a cyclical fashion
  * @idr: idr handle
  * @ptr: pointer to be associated with the new id
  * @start: the minimum id (inclusive)
@@ -58,27 +120,43 @@ EXPORT_SYMBOL_GPL(idr_alloc);
  * Allocates an ID larger than the last ID allocated if one is available.
  * If not, it will attempt to allocate the smallest ID that is larger or
  * equal to @start.
+ *
+ * Protected by the irqsafe spinlock
  */
-int idr_alloc_cyclic(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
+int idr_alloc_cyclic(struct idr *idr, int *cursor, void *ptr,
+		int start, int end, gfp_t gfp)
 {
-	int id, curr = idr->idr_next;
+	int curr = *cursor;
+	int id;
 
 	if (curr < start)
 		curr = start;
-
-	id = idr_alloc(idr, ptr, curr, end, gfp);
-	if ((id == -ENOSPC) && (curr > start))
-		id = idr_alloc(idr, ptr, start, curr, gfp);
+	id = __idr_alloc(idr, ptr, curr, start, end, gfp);
 
 	if (id >= 0)
-		idr->idr_next = id + 1U;
-
+		*cursor = id + 1U;
 	return id;
 }
-EXPORT_SYMBOL(idr_alloc_cyclic);
 
 /**
- * idr_for_each - iterate through all stored pointers
+ * idr_find() - return pointer for given id
+ * @idr: idr handle
+ * @id: lookup key
+ *
+ * Return the pointer given the id it has been registered with.  A %NULL
+ * return indicates that @id is not valid or you passed %NULL in
+ * idr_get_new().
+ *
+ * This function is protected by the RCU read lock.
+ */
+void *idr_find(const struct idr *idr, int id)
+{
+	return idr_null(xa_load(&idr->idxa, id));
+}
+EXPORT_SYMBOL(idr_find);
+
+/**
+ * idr_for_each() - iterate through all stored pointers
  * @idr: idr handle
  * @fn: function to be called for each pointer
  * @data: data passed to callback function
@@ -89,19 +167,19 @@ EXPORT_SYMBOL(idr_alloc_cyclic);
  * If @fn returns anything other than %0, the iteration stops and that
  * value is returned from this function.
  *
- * idr_for_each() can be called concurrently with idr_alloc() and
- * idr_remove() if protected by RCU.  Newly added entries may not be
- * seen and deleted entries may be seen, but adding and removing entries
- * will not cause other entries to be skipped, nor spurious ones to be seen.
+ * This iteration is protected by the RCU lock.  That means that the
+ * callback function may not sleep.  If your callback function must sleep,
+ * then you will have to use a mutex to prevent allocation / removal from
+ * modifying the IDR while the callback function is sleeping.
  */
 int idr_for_each(const struct idr *idr,
-		int (*fn)(int id, void *p, void *data), void *data)
+		int (*fn)(int id, void *ptr, void *data), void *data)
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
@@ -111,7 +189,7 @@ int idr_for_each(const struct idr *idr,
 EXPORT_SYMBOL(idr_for_each);
 
 /**
- * idr_get_next - Find next populated entry
+ * idr_get_next() - Find next populated entry
  * @idr: idr handle
  * @nextid: Pointer to lowest possible ID to return
  *
@@ -119,55 +197,88 @@ EXPORT_SYMBOL(idr_for_each);
  * or equal to the value pointed to by @nextid.  On exit, @nextid is updated
  * to the ID of the found value.  To use in a loop, the value pointed to by
  * nextid must be incremented by the user.
+ *
+ * Protects itself with the irqsafe spinlock.
  */
-void *idr_get_next(struct idr *idr, int *nextid)
+void *idr_get_next(const struct idr *idr, int *id)
 {
-	struct radix_tree_iter iter;
-	void __rcu **slot;
-
-	slot = radix_tree_iter_find(&idr->idr_rt, &iter, *nextid);
-	if (!slot)
-		return NULL;
+	unsigned long index = *id;
+	void *entry = xa_find(&idr->idxa, &index, INT_MAX);
 
-	*nextid = iter.index;
-	return rcu_dereference_raw(*slot);
+	*id = index;
+	return entry;
 }
 EXPORT_SYMBOL(idr_get_next);
 
 /**
- * idr_replace - replace pointer for given id
+ * idr_replace() - replace pointer for given id
  * @idr: idr handle
  * @ptr: New pointer to associate with the ID
  * @id: Lookup key
  *
  * Replace the pointer registered with an ID and return the old value.
- * This function can be called under the RCU read lock concurrently with
- * idr_alloc() and idr_remove() (as long as the ID being removed is not
- * the one being replaced!).
+ * This function takes the irqsafe spinlock.
  *
- * Returns: 0 on success.  %-ENOENT indicates that @id was not found.
+ * Return: 0 on success.  %-ENOENT indicates that @id was not found.
  * %-EINVAL indicates that @id or @ptr were not valid.
  */
 void *idr_replace(struct idr *idr, void *ptr, int id)
 {
-	struct radix_tree_node *node;
-	void __rcu **slot = NULL;
-	void *entry;
+	struct xa_state xas;
+	unsigned long flags;
+	void *curr;
 
-	if (WARN_ON_ONCE(id < 0))
-		return ERR_PTR(-EINVAL);
-	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
+	if (WARN_ON_ONCE(xa_is_internal(ptr)))
 		return ERR_PTR(-EINVAL);
+	if (!ptr)
+		ptr = XA_IDR_NULL;
+
+	xas_init(&xas, id);
+	xa_lock_irqsave(&idr->idxa, flags);
+	curr = xas_load(&idr->idxa, &xas);
+	if (curr && curr != XA_WALK_END)
+		curr = idr_null(xas_store(&idr->idxa, &xas, ptr));
+	else
+		curr = ERR_PTR(-ENOENT);
+	xa_unlock_irqrestore(&idr->idxa, flags);
+
+	return curr;
+}
+EXPORT_SYMBOL(idr_replace);
+
+/**
+ * idr_remove() - Free an allocated ID
+ * @idr: idr handle
+ * @id: Lookup key
+ *
+ * This function protects itself with the irqsafe spinlock.
+ *
+ * Return: The previous pointer associated with this ID.
+ */
+void *idr_remove(struct idr *idr, int id)
+{
+	return idr_null(xa_store(&idr->idxa, id, NULL, GFP_NOWAIT));
+}
+EXPORT_SYMBOL(idr_remove);
+
+/* Move to xarray.c? */
+static void xa_destroy(struct xarray *xa)
+{
+	struct xa_state xas;
+	unsigned long flags;
 
-	entry = __radix_tree_lookup(&idr->idr_rt, id, &node, &slot);
-	if (!slot || radix_tree_tag_get(&idr->idr_rt, id, IDR_FREE))
-		return ERR_PTR(-ENOENT);
+	xas_init_order(&xas, 0, BITS_PER_LONG);
 
-	__radix_tree_replace(&idr->idr_rt, node, slot, ptr, NULL, NULL);
+	xa_lock_irqsave(xa, flags);
+	xas_store(xa, &xas, NULL);
+	xa_unlock_irqrestore(xa, flags);
+}
 
-	return entry;
+void idr_destroy(struct idr *idr)
+{
+	xa_destroy(&idr->idxa);
 }
-EXPORT_SYMBOL(idr_replace);
+EXPORT_SYMBOL(idr_destroy);
 
 /**
  * DOC: IDA description
@@ -181,9 +292,7 @@ EXPORT_SYMBOL(idr_replace);
  *
  * If you have more complex locking requirements, use a loop around
  * ida_pre_get() and ida_get_new() to allocate a new ID.  Then use
- * ida_remove() to free an ID.  You must make sure that ida_get_new() and
- * ida_remove() cannot be called at the same time as each other for the
- * same IDA.
+ * ida_remove() to free an ID.
  *
  * You can also use ida_get_new_above() if you need an ID to be allocated
  * above a particular number.  ida_destroy() can be used to dispose of an
@@ -197,28 +306,20 @@ EXPORT_SYMBOL(idr_replace);
 /*
  * Developer's notes:
  *
- * The IDA uses the functionality provided by the IDR & radix tree to store
- * bitmaps in each entry.  The IDR_FREE tag means there is at least one bit
+ * The IDA uses the functionality provided by the xarray to store bitmaps
+ * in each entry.  The XA_FREE_TAG tag means there is at least one bit
  * free, unlike the IDR where it means at least one entry is free.
  *
- * I considered telling the radix tree that each slot is an order-10 node
- * and storing the bit numbers in the radix tree, but the radix tree can't
+ * I considered telling the xarray that each slot is an order-10 node
+ * and storing the bit numbers in the xarray, but the xarray can't
  * allow a single multiorder entry at index 0, which would significantly
  * increase memory consumption for the IDA.  So instead we divide the index
- * by the number of bits in the leaf bitmap before doing a radix tree lookup.
+ * by the number of bits in the leaf bitmap before doing an xarray load.
  *
  * As an optimisation, if there are only a few low bits set in any given
- * leaf, instead of allocating a 128-byte bitmap, we use the 'exceptional
- * entry' functionality of the radix tree to store BITS_PER_LONG - 2 bits
- * directly in the entry.  By being really tricksy, we could store
- * BITS_PER_LONG - 1 bits, but there're diminishing returns after optimising
- * for 0-3 allocated IDs.
- *
- * We allow the radix tree 'exceptional' count to get out of date.  Nothing
- * in the IDA nor the radix tree code checks it.  If it becomes important
- * to maintain an accurate exceptional count, switch the rcu_assign_pointer()
- * calls to radix_tree_iter_replace() which will correct the exceptional
- * count.
+ * entry, instead of allocating a 128-byte bitmap, we use the 'exceptional
+ * entry' functionality of the xarray to store BITS_PER_LONG - 1 bits
+ * directly in the entry.
  *
  * The IDA always requires a lock to alloc/free.  If we add a 'test_bit'
  * equivalent, it will still need locking.  Going to RCU lookup would require
@@ -230,7 +331,7 @@ EXPORT_SYMBOL(idr_replace);
 #define IDA_MAX (0x80000000U / IDA_BITMAP_BITS)
 
 /**
- * ida_get_new_above - allocate new ID above or equal to a start id
+ * ida_get_new_above() - allocate new ID above or equal to a start id
  * @ida: ida handle
  * @start: id to start search at
  * @id: pointer to the allocated handle
@@ -249,52 +350,55 @@ EXPORT_SYMBOL(idr_replace);
  */
 int ida_get_new_above(struct ida *ida, int start, int *id)
 {
-	struct radix_tree_root *root = &ida->ida_rt;
-	void __rcu **slot;
-	struct radix_tree_iter iter;
+	struct xarray *xa = &ida->idxa;
+	struct xa_state xas;
+	unsigned long flags;
 	struct ida_bitmap *bitmap;
 	unsigned long index;
 	unsigned bit, ebit;
 	int new;
+	bool retry;
 
 	index = start / IDA_BITMAP_BITS;
 	bit = start % IDA_BITMAP_BITS;
-	ebit = bit + RADIX_TREE_EXCEPTIONAL_SHIFT;
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
-		if (iter.index > index) {
+	ebit = bit + 1;
+
+	xas_init(&xas, index);
+	xa_lock_irqsave(xa, flags);
+	do {
+		retry = false;
+		bitmap = xas_find_tag(xa, &xas, IDA_MAX, XA_FREE_TAG);
+		if (xas.xa_index > IDA_MAX)
+			goto nospc;
+		if (xas.xa_index > index) {
 			bit = 0;
-			ebit = RADIX_TREE_EXCEPTIONAL_SHIFT;
+			ebit = 1;
 		}
-		new = iter.index * IDA_BITMAP_BITS;
-		bitmap = rcu_dereference_raw(*slot);
-		if (radix_tree_exception(bitmap)) {
+		new = xas.xa_index * IDA_BITMAP_BITS;
+		if (bitmap == XA_WALK_END) {
+			bitmap = NULL;
+		} else if (xa_is_exceptional(bitmap)) {
 			unsigned long tmp = (unsigned long)bitmap;
 			ebit = find_next_zero_bit(&tmp, BITS_PER_LONG, ebit);
 			if (ebit < BITS_PER_LONG) {
 				tmp |= 1UL << ebit;
-				rcu_assign_pointer(*slot, (void *)tmp);
-				*id = new + ebit - RADIX_TREE_EXCEPTIONAL_SHIFT;
-				return 0;
+				xas_store(xa, &xas, (void *)tmp);
+				xas_set_tag(xa, &xas, XA_FREE_TAG); /* Hmm */
+				bit = ebit - 1;
+				new += bit;
+				continue;
 			}
 			bitmap = this_cpu_xchg(ida_bitmap, NULL);
-			if (!bitmap)
-				return -EAGAIN;
+			if (!bitmap) {
+				bitmap = ERR_PTR(-EAGAIN);
+				break;
+			}
 			memset(bitmap, 0, sizeof(*bitmap));
-			bitmap->bitmap[0] = tmp >> RADIX_TREE_EXCEPTIONAL_SHIFT;
-			rcu_assign_pointer(*slot, bitmap);
+			bitmap->bitmap[0] = tmp >> 1;
+			xas_store(xa, &xas, bitmap);
+			if (xas_error(&xas))
+				bitmap = this_cpu_xchg(ida_bitmap, bitmap);
+			xas_set_tag(xa, &xas, XA_FREE_TAG); /* Hmm */
 		}
 
 		if (bitmap) {
@@ -302,113 +406,133 @@ int ida_get_new_above(struct ida *ida, int start, int *id)
 							IDA_BITMAP_BITS, bit);
 			new += bit;
 			if (new < 0)
-				return -ENOSPC;
-			if (bit == IDA_BITMAP_BITS)
+				goto nospc;
+			if (bit == IDA_BITMAP_BITS) {
+				retry = true;
+				xas_jump(&xas, xas.xa_index + 1);
 				continue;
+			}
 
 			__set_bit(bit, bitmap->bitmap);
 			if (bitmap_full(bitmap->bitmap, IDA_BITMAP_BITS))
-				radix_tree_iter_tag_clear(root, &iter,
-								IDR_FREE);
+				xas_clear_tag(xa, &xas, XA_FREE_TAG);
+			break;
 		} else {
 			new += bit;
 			if (new < 0)
-				return -ENOSPC;
+				goto nospc;
 			if (ebit < BITS_PER_LONG) {
-				bitmap = (void *)((1UL << ebit) |
-						RADIX_TREE_EXCEPTIONAL_ENTRY);
-				radix_tree_iter_replace(root, &iter, slot,
-						bitmap);
-				*id = new;
-				return 0;
+				bitmap = xa_mk_exceptional(1UL << bit);
+				xas_store(xa, &xas, bitmap);
+				xas_set_tag(xa, &xas, XA_FREE_TAG); /* Hmm */
+				continue;
 			}
 			bitmap = this_cpu_xchg(ida_bitmap, NULL);
-			if (!bitmap)
-				return -EAGAIN;
+			if (!bitmap) {
+				bitmap = ERR_PTR(-EAGAIN);
+				break;
+			}
 			memset(bitmap, 0, sizeof(*bitmap));
 			__set_bit(bit, bitmap->bitmap);
-			radix_tree_iter_replace(root, &iter, slot, bitmap);
+			xas_store(xa, &xas, bitmap);
+			if (xas_error(&xas))
+				bitmap = this_cpu_xchg(ida_bitmap, bitmap);
+			xas_set_tag(xa, &xas, XA_FREE_TAG); /* Hmm */
 		}
-
-		*id = new;
-		return 0;
-	}
+	} while (retry || idr_nomem(&xas, GFP_NOWAIT));
+	xa_unlock_irqrestore(xa, flags);
+
+	if (IS_ERR(bitmap))
+		return PTR_ERR(bitmap);
+	if (xas_error(&xas) == -ENOMEM)
+		return -EAGAIN;
+	*id = new;
+	return 0;
+nospc:
+	xa_unlock_irqrestore(xa, flags);
+	return -ENOSPC;
 }
 EXPORT_SYMBOL(ida_get_new_above);
 
 /**
- * ida_remove - Free the given ID
+ * ida_remove() - Free the given ID
  * @ida: ida handle
  * @id: ID to free
  *
- * This function should not be called at the same time as ida_get_new_above().
+ * This function is protected by the irqsafe spinlock.
  */
 void ida_remove(struct ida *ida, int id)
 {
-	unsigned long index = id / IDA_BITMAP_BITS;
-	unsigned offset = id % IDA_BITMAP_BITS;
+	struct xarray *xa = &ida->idxa;
+	struct xa_state xas;
+	unsigned long flags;
 	struct ida_bitmap *bitmap;
+	unsigned long index = id / IDA_BITMAP_BITS;
+	unsigned bit = id % IDA_BITMAP_BITS;
 	unsigned long *btmp;
-	struct radix_tree_iter iter;
-	void __rcu **slot;
 
-	slot = radix_tree_iter_lookup(&ida->ida_rt, &iter, index);
-	if (!slot)
+	xas_init(&xas, index);
+	xa_lock_irqsave(xa, flags);
+	bitmap = xas_load(xa, &xas);
+	if (bitmap == XA_WALK_END)
 		goto err;
-
-	bitmap = rcu_dereference_raw(*slot);
-	if (radix_tree_exception(bitmap)) {
-		btmp = (unsigned long *)slot;
-		offset += RADIX_TREE_EXCEPTIONAL_SHIFT;
-		if (offset >= BITS_PER_LONG)
+	if (xa_is_exceptional(bitmap)) {
+		btmp = (unsigned long *)&bitmap;
+		bit++;
+		if (bit >= BITS_PER_LONG)
 			goto err;
 	} else {
 		btmp = bitmap->bitmap;
 	}
-	if (!test_bit(offset, btmp))
-		goto err;
 
-	__clear_bit(offset, btmp);
-	radix_tree_iter_tag_set(&ida->ida_rt, &iter, IDR_FREE);
-	if (radix_tree_exception(bitmap)) {
-		if (rcu_dereference_raw(*slot) ==
-					(void *)RADIX_TREE_EXCEPTIONAL_ENTRY)
-			radix_tree_iter_delete(&ida->ida_rt, &iter, slot);
+	if (!test_bit(bit, btmp))
+		goto err;
+	__clear_bit(bit, btmp);
+	if (xa_is_exceptional(bitmap)) {
+		if (xa_exceptional_value(bitmap) == 0)
+			bitmap = NULL;
+		xas_store(xa, &xas, bitmap);
+		xas_set_tag(xa, &xas, XA_FREE_TAG); /* Hmm */
 	} else if (bitmap_empty(btmp, IDA_BITMAP_BITS)) {
 		kfree(bitmap);
-		radix_tree_iter_delete(&ida->ida_rt, &iter, slot);
+		xas_store(xa, &xas, NULL);
+	} else {
+		xas_set_tag(xa, &xas, XA_FREE_TAG);
 	}
+	xa_unlock_irqrestore(xa, flags);
 	return;
  err:
+	xa_unlock_irqrestore(xa, flags);
 	WARN(1, "ida_remove called for id=%d which is not allocated.\n", id);
 }
 EXPORT_SYMBOL(ida_remove);
 
 /**
- * ida_destroy - Free the contents of an ida
+ * ida_destroy() - Free the contents of an ida
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
+	struct xa_state xas;
+	unsigned long flags;
+	struct ida_bitmap *bitmap;
 
-	radix_tree_for_each_slot(slot, &ida->ida_rt, &iter, 0) {
-		struct ida_bitmap *bitmap = rcu_dereference_raw(*slot);
-		if (!radix_tree_exception(bitmap))
+	xas_init(&xas, 0);
+	xa_lock_irqsave(&ida->idxa, flags);
+	xas_for_each(&ida->idxa, &xas, bitmap, ~0UL) {
+		if (!xa_is_exceptional(bitmap))
 			kfree(bitmap);
-		radix_tree_iter_delete(&ida->ida_rt, &iter, slot);
+		xas_store(&ida->idxa, &xas, NULL);
 	}
+	xa_unlock_irqrestore(&ida->idxa, flags);
 }
 EXPORT_SYMBOL(ida_destroy);
 
 /**
- * ida_simple_get - get a new id.
+ * ida_simple_get() - get a new id.
  * @ida: the (initialized) ida.
  * @start: the minimum id (inclusive, < 0x8000000)
  * @end: the maximum id (exclusive, < 0x8000000 or 0)
@@ -416,18 +540,12 @@ EXPORT_SYMBOL(ida_destroy);
  *
  * Allocates an id in the range start <= id < end, or returns -ENOSPC.
  * On memory allocation failure, returns -ENOMEM.
- *
- * Compared to ida_get_new_above() this function does its own locking, and
- * should be used unless there are special requirements.
- *
- * Use ida_simple_remove() to get rid of an id.
  */
 int ida_simple_get(struct ida *ida, unsigned int start, unsigned int end,
 		   gfp_t gfp_mask)
 {
 	int ret, id;
 	unsigned int max;
-	unsigned long flags;
 
 	BUG_ON((int)start < 0);
 	BUG_ON((int)end < 0);
@@ -440,10 +558,6 @@ int ida_simple_get(struct ida *ida, unsigned int start, unsigned int end,
 	}
 
 again:
-	if (!ida_pre_get(ida, gfp_mask))
-		return -ENOMEM;
-
-	spin_lock_irqsave(&simple_ida_lock, flags);
 	ret = ida_get_new_above(ida, start, &id);
 	if (!ret) {
 		if (id > max) {
@@ -453,32 +567,13 @@ int ida_simple_get(struct ida *ida, unsigned int start, unsigned int end,
 			ret = id;
 		}
 	}
-	spin_unlock_irqrestore(&simple_ida_lock, flags);
 
-	if (unlikely(ret == -EAGAIN))
+	if (unlikely(ret == -EAGAIN)) {
+		if (!ida_pre_get(ida, gfp_mask))
+			return -ENOMEM;
 		goto again;
+	}
 
 	return ret;
 }
 EXPORT_SYMBOL(ida_simple_get);
-
-/**
- * ida_simple_remove - remove an allocated id.
- * @ida: the (initialized) ida.
- * @id: the id returned by ida_simple_get.
- *
- * Use to release an id allocated with ida_simple_get().
- *
- * Compared to ida_remove() this function does its own locking, and should be
- * used unless there are special requirements.
- */
-void ida_simple_remove(struct ida *ida, unsigned int id)
-{
-	unsigned long flags;
-
-	BUG_ON((int)id < 0);
-	spin_lock_irqsave(&simple_ida_lock, flags);
-	ida_remove(ida, id);
-	spin_unlock_irqrestore(&simple_ida_lock, flags);
-}
-EXPORT_SYMBOL(ida_simple_remove);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 9c0fa4df736b..8d2563097133 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -269,13 +269,6 @@ static inline unsigned long node_maxindex(const struct radix_tree_node *node)
 	return shift_maxindex(node->shift);
 }
 
-static unsigned long next_index(unsigned long index,
-				const struct radix_tree_node *node,
-				unsigned long offset)
-{
-	return (index & ~node_maxindex(node)) + (offset << node->shift);
-}
-
 #ifndef __KERNEL__
 static void dump_node(struct radix_tree_node *node, unsigned long index)
 {
@@ -319,54 +312,6 @@ static void radix_tree_dump(struct radix_tree_root *root)
 		return;
 	dump_node(entry_to_node(root->rnode), 0);
 }
-
-static void dump_ida_node(void *entry, unsigned long index)
-{
-	unsigned long i;
-
-	if (!entry)
-		return;
-
-	if (radix_tree_is_internal_node(entry)) {
-		struct radix_tree_node *node = entry_to_node(entry);
-
-		pr_debug("ida node: %p offset %d indices %lu-%lu parent %p free %lx shift %d count %d\n",
-			node, node->offset, index * IDA_BITMAP_BITS,
-			((index | node_maxindex(node)) + 1) *
-				IDA_BITMAP_BITS - 1,
-			node->parent, node->tags[0][0], node->shift,
-			node->count);
-		for (i = 0; i < RADIX_TREE_MAP_SIZE; i++)
-			dump_ida_node(node->slots[i],
-					index | (i << node->shift));
-	} else if (radix_tree_exceptional_entry(entry)) {
-		pr_debug("ida excp: %p offset %d indices %lu-%lu data %lx\n",
-				entry, (int)(index & RADIX_TREE_MAP_MASK),
-				index * IDA_BITMAP_BITS,
-				index * IDA_BITMAP_BITS + BITS_PER_LONG -
-					RADIX_TREE_EXCEPTIONAL_SHIFT,
-				(unsigned long)entry >>
-					RADIX_TREE_EXCEPTIONAL_SHIFT);
-	} else {
-		struct ida_bitmap *bitmap = entry;
-
-		pr_debug("ida btmp: %p offset %d indices %lu-%lu data", bitmap,
-				(int)(index & RADIX_TREE_MAP_MASK),
-				index * IDA_BITMAP_BITS,
-				(index + 1) * IDA_BITMAP_BITS - 1);
-		for (i = 0; i < IDA_BITMAP_LONGS; i++)
-			pr_cont(" %lx", bitmap->bitmap[i]);
-		pr_cont("\n");
-	}
-}
-
-static void ida_dump(struct ida *ida)
-{
-	struct radix_tree_root *root = &ida->ida_rt;
-	pr_debug("ida: %p node %p free %d\n", ida, root->rnode,
-				root->gfp_mask >> ROOT_TAG_SHIFT);
-	dump_ida_node(root->rnode, 0);
-}
 #endif
 
 /*
@@ -629,7 +574,7 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 		maxshift += RADIX_TREE_MAP_SHIFT;
 
 	entry = rcu_dereference_raw(root->rnode);
-	if (!entry && (!is_idr(root) || root_tag_get(root, IDR_FREE)))
+	if (!entry && (!is_idr(root) || root_tag_get(root, XA_FREE_TAG)))
 		goto out;
 
 	do {
@@ -639,10 +584,10 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 			return -ENOMEM;
 
 		if (is_idr(root)) {
-			all_tag_set(node, IDR_FREE);
-			if (!root_tag_get(root, IDR_FREE)) {
-				tag_clear(node, IDR_FREE, 0);
-				root_tag_set(root, IDR_FREE);
+			all_tag_set(node, XA_FREE_TAG);
+			if (!root_tag_get(root, XA_FREE_TAG)) {
+				tag_clear(node, XA_FREE_TAG, 0);
+				root_tag_set(root, XA_FREE_TAG);
 			}
 		} else {
 			/* Propagate the aggregated tag info to the new child */
@@ -714,8 +659,8 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
 		 * one (root->rnode) as far as dependent read barriers go.
 		 */
 		root->rnode = (void __rcu *)child;
-		if (is_idr(root) && !tag_get(node, IDR_FREE, 0))
-			root_tag_clear(root, IDR_FREE);
+		if (is_idr(root) && !tag_get(node, XA_FREE_TAG, 0))
+			root_tag_clear(root, XA_FREE_TAG);
 
 		/*
 		 * We have a dilemma here. The node's slot[0] must not be
@@ -1147,7 +1092,7 @@ static bool node_tag_get(const struct radix_tree_root *root,
 /*
  * IDR users want to be able to store NULL in the tree, so if the slot isn't
  * free, don't adjust the count, even if it's transitioning between NULL and
- * non-NULL.  For the IDA, we mark slots as being IDR_FREE while they still
+ * non-NULL.  For the IDA, we mark slots as being XA_FREE_TAG while they still
  * have empty bits, but it only stores NULL in slots when they're being
  * deleted.
  */
@@ -1157,7 +1102,7 @@ static int calculate_count(struct radix_tree_root *root,
 {
 	if (is_idr(root)) {
 		unsigned offset = get_slot_offset(node, slot);
-		bool free = node_tag_get(root, node, IDR_FREE, offset);
+		bool free = node_tag_get(root, node, XA_FREE_TAG, offset);
 		if (!free)
 			return 0;
 		if (!old)
@@ -1994,7 +1939,7 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
 	int tag;
 
 	if (is_idr(root))
-		node_tag_set(root, node, IDR_FREE, offset);
+		node_tag_set(root, node, XA_FREE_TAG, offset);
 	else
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 			node_tag_clear(root, node, tag, offset);
@@ -2041,7 +1986,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 	void *entry;
 
 	entry = __radix_tree_lookup(root, index, &node, &slot);
-	if (!entry && (!is_idr(root) || node_tag_get(root, node, IDR_FREE,
+	if (!entry && (!is_idr(root) || node_tag_get(root, node, XA_FREE_TAG,
 						get_slot_offset(node, slot))))
 		return NULL;
 
@@ -2136,98 +2081,6 @@ int ida_pre_get(struct ida *ida, gfp_t gfp)
 }
 EXPORT_SYMBOL(ida_pre_get);
 
-void __rcu **idr_get_free(struct radix_tree_root *root,
-			struct radix_tree_iter *iter, gfp_t gfp, int end)
-{
-	struct radix_tree_node *node = NULL, *child;
-	void __rcu **slot = (void __rcu **)&root->rnode;
-	unsigned long maxindex, start = iter->next_index;
-	unsigned long max = end > 0 ? end - 1 : INT_MAX;
-	unsigned int shift, offset = 0;
-
- grow:
-	shift = radix_tree_load_root(root, &child, &maxindex);
-	if (!radix_tree_tagged(root, IDR_FREE))
-		start = max(start, maxindex + 1);
-	if (start > max)
-		return ERR_PTR(-ENOSPC);
-
-	if (start > maxindex) {
-		int error = radix_tree_extend(root, gfp, start, shift);
-		if (error < 0)
-			return ERR_PTR(error);
-		shift = error;
-		child = rcu_dereference_raw(root->rnode);
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
-			all_tag_set(child, IDR_FREE);
-			rcu_assign_pointer(*slot, node_to_entry(child));
-			if (node)
-				node->count++;
-		} else if (!radix_tree_is_internal_node(child))
-			break;
-
-		node = entry_to_node(child);
-		offset = radix_tree_descend(node, &child, start);
-		if (!tag_get(node, IDR_FREE, offset)) {
-			offset = radix_tree_find_next_bit(node, IDR_FREE,
-							offset + 1);
-			start = next_index(start, node, offset);
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
-	set_iter_tags(iter, node, offset, IDR_FREE);
-
-	return slot;
-}
-
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
-	struct radix_tree_node *node = rcu_dereference_raw(idr->idr_rt.rnode);
-	if (radix_tree_is_internal_node(node))
-		radix_tree_free_nodes(node);
-	idr->idr_rt.rnode = NULL;
-	root_tag_set(&idr->idr_rt, IDR_FREE);
-}
-EXPORT_SYMBOL(idr_destroy);
-
 static void
 radix_tree_node_ctor(void *arg)
 {
diff --git a/tools/include/asm/bug.h b/tools/include/asm/bug.h
index 4790f047a89c..4eabf5597682 100644
--- a/tools/include/asm/bug.h
+++ b/tools/include/asm/bug.h
@@ -41,4 +41,8 @@
 	unlikely(__ret_warn_once);		\
 })
 
+#define VM_WARN_ON_ONCE WARN_ON_ONCE
+
+#define BUILD_BUG_ON(condition) ((void)sizeof(char[1 - 2*!!(condition)]))
+
 #endif /* _TOOLS_ASM_BUG_H */
diff --git a/tools/include/linux/kernel.h b/tools/include/linux/kernel.h
index 28607db02bd3..b2e4918f2b14 100644
--- a/tools/include/linux/kernel.h
+++ b/tools/include/linux/kernel.h
@@ -4,6 +4,7 @@
 #include <stdarg.h>
 #include <stddef.h>
 #include <assert.h>
+#include <limits.h>
 
 #define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
 
diff --git a/tools/include/linux/spinlock.h b/tools/include/linux/spinlock.h
index 58397dcb19d6..703859ddadb4 100644
--- a/tools/include/linux/spinlock.h
+++ b/tools/include/linux/spinlock.h
@@ -1,5 +1,10 @@
 #define spinlock_t		pthread_mutex_t
-#define DEFINE_SPINLOCK(x)	pthread_mutex_t x = PTHREAD_MUTEX_INITIALIZER;
+#define DEFINE_SPINLOCK(x)	pthread_mutex_t x = PTHREAD_MUTEX_INITIALIZER
+#define __SPIN_LOCK_UNLOCKED(x)	PTHREAD_MUTEX_INITIALIZER
 
+#define spin_lock(x)			pthread_mutex_lock(x)
+#define spin_unlock(x)			pthread_mutex_unlock(x)
+#define spin_lock_irq(x)		pthread_mutex_lock(x)
+#define spin_unlock_irqr(x)		pthread_mutex_unlock(x)
 #define spin_lock_irqsave(x, f)		(void)f, pthread_mutex_lock(x)
 #define spin_unlock_irqrestore(x, f)	(void)f, pthread_mutex_unlock(x)
diff --git a/tools/testing/radix-tree/.gitignore b/tools/testing/radix-tree/.gitignore
index d4706c0ffceb..7db5861132b5 100644
--- a/tools/testing/radix-tree/.gitignore
+++ b/tools/testing/radix-tree/.gitignore
@@ -1,6 +1,6 @@
 generated/map-shift.h
-idr.c
-idr-test
+idr
 main
 multiorder
 radix-tree.c
+xarray
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index f11315bedefc..4d9ce949dc93 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -1,10 +1,10 @@
 
-CFLAGS += -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE -fsanitize=address
+CFLAGS += -I. -I../../include -g -Og -Wall -D_LGPL_SOURCE -fsanitize=address
 LDFLAGS += -lpthread -lurcu
-TARGETS = main idr-test multiorder
-CORE_OFILES := radix-tree.o idr.o linux.o test.o find_bit.o
+TARGETS = main idr-test multiorder xarray
+CORE_OFILES := radix-tree.o idr.o xarray.o linux.o test.o find_bit.o
 OFILES = main.o $(CORE_OFILES) regression1.o regression2.o regression3.o \
-	 tag_check.o multiorder.o idr-test.o iteration_check.o benchmark.o
+	 tag_check.o multiorder.o iteration_check.o benchmark.o
 
 ifndef SHIFT
 	SHIFT=3
@@ -15,14 +15,22 @@ targets: mapshift $(TARGETS)
 main:	$(OFILES)
 	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o main
 
-idr-test: idr-test.o $(CORE_OFILES)
-	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o idr-test
+idr: $(CORE_OFILES)
+	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@
+idr.o: idr.c ../../../lib/idr.c
 
 multiorder: multiorder.o $(CORE_OFILES)
 	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o multiorder
 
+xarray: xarray.o linux.o test.o find_bit.o
+	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@
+xarray.o: ../../../lib/xarray.c
+
+xarray-idr: xarray.o idr-test.o linux.o idr-xarray.o test.o find_bit.o
+	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@
+
 clean:
-	$(RM) $(TARGETS) *.o radix-tree.c idr.c generated/map-shift.h
+	$(RM) $(TARGETS) *.o radix-tree.c generated/map-shift.h
 
 vpath %.c ../../lib
 
@@ -30,18 +38,18 @@ $(OFILES): *.h */*.h generated/map-shift.h \
 	../../include/linux/*.h \
 	../../include/asm/*.h \
 	../../../include/linux/radix-tree.h \
-	../../../include/linux/idr.h
+	../../../include/linux/idr.h \
+	../../../include/linux/xarray.h
 
 radix-tree.c: ../../../lib/radix-tree.c
 	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
 
-idr.c: ../../../lib/idr.c
-	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
-
 .PHONY: mapshift
 
-mapshift:
-	@if ! grep -qw $(SHIFT) generated/map-shift.h; then		\
+mapshift: generated/map-shift.h
+
+generated/map-shift.h:
+	@if ! grep -sqw $(SHIFT) generated/map-shift.h; then		\
 		echo "#define RADIX_TREE_MAP_SHIFT $(SHIFT)" >		\
 				generated/map-shift.h;			\
 	fi
diff --git a/tools/testing/radix-tree/idr-test.c b/tools/testing/radix-tree/idr.c
similarity index 91%
rename from tools/testing/radix-tree/idr-test.c
rename to tools/testing/radix-tree/idr.c
index a26098c6123d..8965217f689c 100644
--- a/tools/testing/radix-tree/idr-test.c
+++ b/tools/testing/radix-tree/idr.c
@@ -11,15 +11,19 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
  */
+#include "../../../lib/idr.c"
+
 #include <linux/bitmap.h>
 #include <linux/idr.h>
 #include <linux/slab.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
 
+#define _TEST_H_NO_DEFINE_PRELOAD
 #include "test.h"
 
-#define DUMMY_PTR	((void *)0x12)
+//#define DUMMY_PTR	((void *)0x12)
+#define DUMMY_PTR	xa_mk_exceptional(10)
 
 int item_idr_free(int id, void *p, void *data)
 {
@@ -42,9 +46,10 @@ void idr_alloc_test(void)
 {
 	unsigned long i;
 	DEFINE_IDR(idr);
+	int cursor = 0;
 
-	assert(idr_alloc_cyclic(&idr, DUMMY_PTR, 0, 0x4000, GFP_KERNEL) == 0);
-	assert(idr_alloc_cyclic(&idr, DUMMY_PTR, 0x3ffd, 0x4000, GFP_KERNEL) == 0x3ffd);
+	assert(idr_alloc_cyclic(&idr, &cursor, DUMMY_PTR, 0, 0x4000, GFP_KERNEL) == 0);
+	assert(idr_alloc_cyclic(&idr, &cursor, DUMMY_PTR, 0x3ffd, 0x4000, GFP_KERNEL) == 0x3ffd);
 	idr_remove(&idr, 0x3ffd);
 	idr_remove(&idr, 0);
 
@@ -57,7 +62,7 @@ void idr_alloc_test(void)
 		else
 			item = item_create(i - 0x3fff, 0);
 
-		id = idr_alloc_cyclic(&idr, item, 1, 0x4000, GFP_KERNEL);
+		id = idr_alloc_cyclic(&idr, &cursor, item, 1, 0x4000, GFP_KERNEL);
 		assert(id == item->index);
 	}
 
@@ -83,8 +88,10 @@ void idr_replace_test(void)
  */
 void idr_null_test(void)
 {
-	int i;
 	DEFINE_IDR(idr);
+	void *entry;
+	unsigned long bits = 0;
+	int i;
 
 	assert(idr_is_empty(&idr));
 
@@ -95,6 +102,8 @@ void idr_null_test(void)
 
 	assert(idr_alloc(&idr, NULL, 0, 0, GFP_KERNEL) == 0);
 	assert(!idr_is_empty(&idr));
+	assert(idr_find(&idr, 0) == NULL);
+	assert(idr_find(&idr, 1) == NULL);
 	idr_destroy(&idr);
 	assert(idr_is_empty(&idr));
 
@@ -110,6 +119,10 @@ void idr_null_test(void)
 	assert(idr_alloc(&idr, NULL, 0, 0, GFP_KERNEL) == 5);
 	idr_remove(&idr, 5);
 
+	idr_for_each_entry(&idr, entry, i)
+		bits |= (1UL << i);
+	assert(bits == 0x8);
+
 	for (i = 0; i < 9; i++) {
 		idr_remove(&idr, i);
 		assert(!idr_is_empty(&idr));
@@ -163,7 +176,7 @@ void idr_checks(void)
 		assert(idr_alloc(&idr, item, 0, 20000, GFP_KERNEL) == i);
 	}
 
-	assert(idr_alloc(&idr, DUMMY_PTR, 5, 30, GFP_KERNEL) < 0);
+	assert(idr_alloc(&idr, DUMMY_PTR, 5, 30, GFP_KERNEL) == -ENOSPC);
 
 	for (i = 0; i < 5000; i++)
 		item_idr_remove(&idr, i);
@@ -172,7 +185,6 @@ void idr_checks(void)
 
 	idr_for_each(&idr, item_idr_free, &idr);
 	idr_destroy(&idr);
-
 	assert(idr_is_empty(&idr));
 
 	idr_remove(&idr, 3);
@@ -295,16 +307,17 @@ void ida_check_conv(void)
 	for (i = 0; i < 1000000; i++) {
 		int err = ida_get_new(&ida, &id);
 		if (err == -EAGAIN) {
-			assert((i % IDA_BITMAP_BITS) == (BITS_PER_LONG - 2));
+			assert((i % IDA_BITMAP_BITS) == (BITS_PER_LONG - 1));
 			assert(ida_pre_get(&ida, GFP_KERNEL));
 			err = ida_get_new(&ida, &id);
 		} else {
-			assert((i % IDA_BITMAP_BITS) != (BITS_PER_LONG - 2));
+			assert((i % IDA_BITMAP_BITS) != (BITS_PER_LONG - 1));
 		}
 		assert(!err);
 		assert(id == i);
 	}
 	ida_destroy(&ida);
+	assert(ida_is_empty(&ida));
 }
 
 /*
@@ -432,13 +445,17 @@ void ida_checks(void)
 	radix_tree_cpu_dead(1);
 }
 
-int __weak main(void)
+int main(void)
 {
+	test_verbose = 2;
+	rcu_init();
+	xarray_init();
 	radix_tree_init();
 	idr_checks();
 	ida_checks();
 	rcu_barrier();
 	if (nr_allocated)
 		printf("nr_allocated = %d\n", nr_allocated);
+	fflush(stdout);
 	return 0;
 }
diff --git a/tools/testing/radix-tree/linux.c b/tools/testing/radix-tree/linux.c
index cf48c8473f48..e7ecff9cfa10 100644
--- a/tools/testing/radix-tree/linux.c
+++ b/tools/testing/radix-tree/linux.c
@@ -28,7 +28,7 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, int flags)
 {
 	struct radix_tree_node *node;
 
-	if (flags & __GFP_NOWARN)
+	if (!(flags & __GFP_DIRECT_RECLAIM))
 		return NULL;
 
 	pthread_mutex_lock(&cachep->lock);
diff --git a/tools/testing/radix-tree/linux/radix-tree.h b/tools/testing/radix-tree/linux/radix-tree.h
index bf1bb231f9b5..e9f1b859f45e 100644
--- a/tools/testing/radix-tree/linux/radix-tree.h
+++ b/tools/testing/radix-tree/linux/radix-tree.h
@@ -5,7 +5,6 @@
 #include "../../../../include/linux/radix-tree.h"
 
 extern int kmalloc_verbose;
-extern int test_verbose;
 
 static inline void trace_call_rcu(struct rcu_head *head,
 		void (*func)(struct rcu_head *head))
@@ -16,10 +15,6 @@ static inline void trace_call_rcu(struct rcu_head *head,
 	call_rcu(head, func);
 }
 
-#define printv(verbosity_level, fmt, ...) \
-	if(test_verbose >= verbosity_level) \
-		printf(fmt, ##__VA_ARGS__)
-
 #undef call_rcu
 #define call_rcu(x, y) trace_call_rcu(x, y)
 
diff --git a/tools/testing/radix-tree/linux/rcupdate.h b/tools/testing/radix-tree/linux/rcupdate.h
index f7129ea2a899..733952ddb01b 100644
--- a/tools/testing/radix-tree/linux/rcupdate.h
+++ b/tools/testing/radix-tree/linux/rcupdate.h
@@ -5,5 +5,7 @@
 
 #define rcu_dereference_raw(p) rcu_dereference(p)
 #define rcu_dereference_protected(p, cond) rcu_dereference(p)
+#define rcu_dereference_check(p, cond) rcu_dereference(p)
+#define RCU_INIT_POINTER(p, v)	p = v
 
 #endif
diff --git a/tools/testing/radix-tree/linux/xarray.h b/tools/testing/radix-tree/linux/xarray.h
new file mode 100644
index 000000000000..6b4a24916434
--- /dev/null
+++ b/tools/testing/radix-tree/linux/xarray.h
@@ -0,0 +1 @@
+#include "../../../include/linux/xarray.h"
diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index 1a257d738a1e..293d59e130e1 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -8,25 +8,26 @@
 #include "test.h"
 
 struct item *
-item_tag_set(struct radix_tree_root *root, unsigned long index, int tag)
+item_tag_set(struct xarray *xa, unsigned long index, int tag)
 {
-	return radix_tree_tag_set(root, index, tag);
+	return xa_set_tag(xa, index, tag);
 }
 
 struct item *
-item_tag_clear(struct radix_tree_root *root, unsigned long index, int tag)
+item_tag_clear(struct xarray *xa, unsigned long index, int tag)
 {
-	return radix_tree_tag_clear(root, index, tag);
+	return xa_clear_tag(xa, index, tag);
 }
 
-int item_tag_get(struct radix_tree_root *root, unsigned long index, int tag)
+int item_tag_get(struct xarray *xa, unsigned long index, int tag)
 {
-	return radix_tree_tag_get(root, index, tag);
+	return xa_get_tag(xa, index, tag);
 }
 
-int __item_insert(struct radix_tree_root *root, struct item *item)
+int __item_insert(struct xarray *xa, struct item *item)
 {
-	return __radix_tree_insert(root, item->index, item->order, item);
+	assert(!item->order);
+	return xa_replace(xa, item->index, item, NULL, GFP_KERNEL) == NULL;
 }
 
 struct item *item_create(unsigned long index, unsigned int order)
@@ -38,33 +39,33 @@ struct item *item_create(unsigned long index, unsigned int order)
 	return ret;
 }
 
-int item_insert_order(struct radix_tree_root *root, unsigned long index,
+int item_insert_order(struct xarray *xa, unsigned long index,
 			unsigned order)
 {
 	struct item *item = item_create(index, order);
-	int err = __item_insert(root, item);
+	int err = __item_insert(xa, item);
 	if (err)
 		free(item);
 	return err;
 }
 
-int item_insert(struct radix_tree_root *root, unsigned long index)
+int item_insert(struct xarray *xa, unsigned long index)
 {
-	return item_insert_order(root, index, 0);
+	return item_insert_order(xa, index, 0);
 }
 
 void item_sanity(struct item *item, unsigned long index)
 {
 	unsigned long mask;
-	assert(!radix_tree_is_internal_node(item));
+	assert(!xa_is_internal(item));
 	assert(item->order < BITS_PER_LONG);
 	mask = (1UL << item->order) - 1;
 	assert((item->index | mask) == (index | mask));
 }
 
-int item_delete(struct radix_tree_root *root, unsigned long index)
+int item_delete(struct xarray *xa, unsigned long index)
 {
-	struct item *item = radix_tree_delete(root, index);
+	struct item *item = xa_store(xa, index, NULL, GFP_NOWAIT);
 
 	if (item) {
 		item_sanity(item, index);
@@ -74,32 +75,33 @@ int item_delete(struct radix_tree_root *root, unsigned long index)
 	return 0;
 }
 
-void item_check_present(struct radix_tree_root *root, unsigned long index)
+void item_check_present(struct xarray *xa, unsigned long index)
 {
 	struct item *item;
 
-	item = radix_tree_lookup(root, index);
+	item = xa_load(xa, index);
 	assert(item != NULL);
 	item_sanity(item, index);
 }
 
-struct item *item_lookup(struct radix_tree_root *root, unsigned long index)
+struct item *item_lookup(struct xarray *xa, unsigned long index)
 {
-	return radix_tree_lookup(root, index);
+	return xa_load(xa, index);
 }
 
-void item_check_absent(struct radix_tree_root *root, unsigned long index)
+void item_check_absent(struct xarray *xa, unsigned long index)
 {
 	struct item *item;
 
-	item = radix_tree_lookup(root, index);
+	item = xa_load(xa, index);
 	assert(item == NULL);
 }
 
+#if 0
 /*
  * Scan only the passed (start, start+nr] for present items
  */
-void item_gang_check_present(struct radix_tree_root *root,
+void item_gang_check_present(struct xarray *xa,
 			unsigned long start, unsigned long nr,
 			int chunk, int hop)
 {
@@ -126,7 +128,7 @@ void item_gang_check_present(struct radix_tree_root *root,
 /*
  * Scan the entire tree, only expecting present items (start, start+nr]
  */
-void item_full_scan(struct radix_tree_root *root, unsigned long start,
+void item_full_scan(struct xarray *xa, unsigned long start,
 			unsigned long nr, int chunk)
 {
 	struct item *items[chunk];
@@ -156,7 +158,7 @@ void item_full_scan(struct radix_tree_root *root, unsigned long start,
 }
 
 /* Use the same pattern as tag_pages_for_writeback() in mm/page-writeback.c */
-int tag_tagged_items(struct radix_tree_root *root, pthread_mutex_t *lock,
+int tag_tagged_items(struct xarray *xa, pthread_mutex_t *lock,
 			unsigned long start, unsigned long end, unsigned batch,
 			unsigned iftag, unsigned thentag)
 {
@@ -190,7 +192,7 @@ int tag_tagged_items(struct radix_tree_root *root, pthread_mutex_t *lock,
 }
 
 /* Use the same pattern as find_swap_entry() in mm/shmem.c */
-unsigned long find_item(struct radix_tree_root *root, void *item)
+unsigned long find_item(struct xarray *xa, void *item)
 {
 	struct radix_tree_iter iter;
 	void **slot;
@@ -259,7 +261,7 @@ static int verify_node(struct radix_tree_node *slot, unsigned int tag,
 	return 0;
 }
 
-void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag)
+void verify_tag_consistency(struct xarray *xa, unsigned int tag)
 {
 	struct radix_tree_node *node = root->rnode;
 	if (!radix_tree_is_internal_node(node))
@@ -267,7 +269,7 @@ void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag)
 	verify_node(node, tag, !!root_tag_get(root, tag));
 }
 
-void item_kill_tree(struct radix_tree_root *root)
+void item_kill_tree(struct xarray *xa)
 {
 	struct radix_tree_iter iter;
 	void **slot;
@@ -294,7 +296,7 @@ void item_kill_tree(struct radix_tree_root *root)
 	assert(root->rnode == NULL);
 }
 
-void tree_verify_min_height(struct radix_tree_root *root, int maxindex)
+void tree_verify_min_height(struct xarray *xa, int maxindex)
 {
 	unsigned shift;
 	struct radix_tree_node *node = root->rnode;
@@ -312,3 +314,4 @@ void tree_verify_min_height(struct radix_tree_root *root, int maxindex)
 	else
 		assert(maxindex > 0);
 }
+#endif
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index b30e11d9d271..fa9d95086215 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -1,3 +1,6 @@
+#define XA_ADVANCED
+
+#include <linux/xarray.h>
 #include <linux/gfp.h>
 #include <linux/types.h>
 #include <linux/radix-tree.h>
@@ -9,26 +12,26 @@ struct item {
 };
 
 struct item *item_create(unsigned long index, unsigned int order);
-int __item_insert(struct radix_tree_root *root, struct item *item);
-int item_insert(struct radix_tree_root *root, unsigned long index);
-int item_insert_order(struct radix_tree_root *root, unsigned long index,
+int __item_insert(struct xarray *root, struct item *item);
+int item_insert(struct xarray *root, unsigned long index);
+int item_insert_order(struct xarray *root, unsigned long index,
 			unsigned order);
-int item_delete(struct radix_tree_root *root, unsigned long index);
-struct item *item_lookup(struct radix_tree_root *root, unsigned long index);
+int item_delete(struct xarray *root, unsigned long index);
+struct item *item_lookup(struct xarray *root, unsigned long index);
 
-void item_check_present(struct radix_tree_root *root, unsigned long index);
-void item_check_absent(struct radix_tree_root *root, unsigned long index);
-void item_gang_check_present(struct radix_tree_root *root,
+void item_check_present(struct xarray *root, unsigned long index);
+void item_check_absent(struct xarray *root, unsigned long index);
+void item_gang_check_present(struct xarray *root,
 			unsigned long start, unsigned long nr,
 			int chunk, int hop);
-void item_full_scan(struct radix_tree_root *root, unsigned long start,
+void item_full_scan(struct xarray *root, unsigned long start,
 			unsigned long nr, int chunk);
-void item_kill_tree(struct radix_tree_root *root);
+void item_kill_tree(struct xarray *root);
 
-int tag_tagged_items(struct radix_tree_root *, pthread_mutex_t *,
+int tag_tagged_items(struct xarray *, pthread_mutex_t *,
 			unsigned long start, unsigned long end, unsigned batch,
 			unsigned iftag, unsigned thentag);
-unsigned long find_item(struct radix_tree_root *, void *item);
+unsigned long find_item(struct xarray *, void *item);
 
 void tag_check(void);
 void multiorder_checks(void);
@@ -38,24 +41,31 @@ void idr_checks(void);
 void ida_checks(void);
 
 struct item *
-item_tag_set(struct radix_tree_root *root, unsigned long index, int tag);
+item_tag_set(struct xarray *root, unsigned long index, int tag);
 struct item *
-item_tag_clear(struct radix_tree_root *root, unsigned long index, int tag);
-int item_tag_get(struct radix_tree_root *root, unsigned long index, int tag);
-void tree_verify_min_height(struct radix_tree_root *root, int maxindex);
-void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag);
+item_tag_clear(struct xarray *root, unsigned long index, int tag);
+int item_tag_get(struct xarray *root, unsigned long index, int tag);
+void tree_verify_min_height(struct xarray *root, int maxindex);
+void verify_tag_consistency(struct xarray *root, unsigned int tag);
 
 extern int nr_allocated;
+extern int test_verbose;
+
+#define printv(verbosity_level, fmt, ...) \
+	if (test_verbose >= verbosity_level) \
+		printf(fmt, ##__VA_ARGS__)
 
 /* Normally private parts of lib/radix-tree.c */
 struct radix_tree_node *entry_to_node(void *ptr);
-void radix_tree_dump(struct radix_tree_root *root);
-int root_tag_get(struct radix_tree_root *root, unsigned int tag);
+void radix_tree_dump(struct xarray *root);
+int root_tag_get(struct xarray *root, unsigned int tag);
 unsigned long node_maxindex(struct radix_tree_node *);
 unsigned long shift_maxindex(unsigned int shift);
 int radix_tree_cpu_dead(unsigned int cpu);
+#ifndef _TEST_H_NO_DEFINE_PRELOAD
 struct radix_tree_preload {
 	unsigned nr;
 	struct radix_tree_node *nodes;
 };
 extern struct radix_tree_preload radix_tree_preloads;
+#endif
diff --git a/tools/testing/radix-tree/xarray.c b/tools/testing/radix-tree/xarray.c
new file mode 100644
index 000000000000..9a9156840d1d
--- /dev/null
+++ b/tools/testing/radix-tree/xarray.c
@@ -0,0 +1,241 @@
+#include <assert.h>
+#include <stdio.h>
+
+#define XA_DEBUG
+#include "../../../lib/xarray.c"
+
+#include "test.h"
+
+void xa_dump_entry(void *entry, unsigned long index)
+{
+	if (!entry)
+		return;
+
+	if (xa_is_exceptional(entry))
+		printf("%lu: exceptional %#lx\n", index,
+				xa_exceptional_value(entry));
+	else if (!xa_is_internal(entry))
+		printf("%lu: %p\n", index, entry);
+	else if (xa_is_node(entry)) {
+		unsigned long i;
+		struct xa_node *node = xa_node(entry);
+		printf("node %p %s %d parent %p shift %d count %d "
+			"exceptional %d tags %lx %lx %lx indices %lu-%lu\n",
+			node, node->parent ? "offset" : "max", node->offset,
+			node->parent, node->shift, node->count,
+			node->exceptional,
+			node->tags[0][0], node->tags[1][0], node->tags[2][0],
+			index, index |
+			(((unsigned long)XA_CHUNK_SIZE << node->shift) - 1));
+		for (i = 0; i < XA_CHUNK_SIZE; i++)
+			xa_dump_entry(node->slots[i],
+					index + (i << node->shift));
+	} else if (xa_is_retry(entry))
+		printf("%lu: retry (%ld)\n", index, xa_internal_value(entry));
+	else if (xa_is_sibling(entry))
+		printf("%lu: sibling (%ld)\n", index, xa_sibling_offset(entry));
+	else if (xa_is_cousin(entry))
+		printf("%lu: cousin (%ld)\n", index, xa_cousin_offset(entry));
+	else if (xa_is_idr_null(entry))
+		printf("%lu: IDR NULL (%ld)\n", index,
+						xa_internal_value(entry));
+	else
+		printf("%lu: UNKNOWN ENTRY (%p)\n", index, entry);
+}
+
+void xa_dump(struct xarray *xa)
+{
+	printf("xarray: %p %x %p\n", xa, xa->xa_flags, xa->xa_head);
+	xa_dump_entry(xa->xa_head, 0);
+}
+
+#define FOUR	(void *)4
+#define EIGHT	(void *)8
+
+void xas_walk_test(struct xarray *xa)
+{
+	struct xa_state xas;
+
+	xas_init(&xas, 0);
+//	assert(xas_load(xa, &xas) == NULL);
+}
+
+void xas_store_test(struct xarray *xa, unsigned long index)
+{
+	struct xa_state xas;
+	int err;
+	void *curr;
+
+	xas_init(&xas, index);
+	assert(!err);
+	do {
+		xa_lock(xa);
+		curr = xas_create(xa, &xas);
+		xa_unlock(xa);
+	} while (xas_nomem(&xas, GFP_KERNEL));
+	assert(curr == NULL);
+	curr = xas_store(xa, &xas, FOUR);
+	assert(curr == NULL);
+	if (index == 0)
+		assert(xa->xa_head == FOUR);
+	curr = xas_store(xa, &xas, NULL);
+	assert(curr == FOUR);
+	xas_destroy(&xas);
+	assert(xa_empty(xa));
+}
+
+static void multiorder_check(struct xarray *xa, unsigned long index, int order)
+{
+	struct xa_state xas;
+	unsigned long i;
+	unsigned long min = index & ~((1UL << order) - 1);
+	unsigned long max = min + (1UL << order);
+	void *curr, *entry = xa_mk_exceptional(index);
+
+	printv(2, "Multiorder index %ld, order %d\n", index, order);
+
+	xas_init_order(&xas, index, order);
+	do {
+		xa_lock(xa);
+		curr = xas_store(xa, &xas, entry);
+		xa_unlock(xa);
+	} while (xas_nomem(&xas, GFP_KERNEL));
+
+	assert(curr == NULL);
+	xas_destroy(&xas);
+
+	for (i = 0; i < min; i++)
+		assert(xa_load(xa, i) == NULL);
+	for (i = min; i < max; i++)
+		assert(xa_load(xa, i) == entry);
+	for (i = max; i < 2 * max; i++)
+		assert(xa_load(xa, i) == NULL);
+
+	xa_lock(xa);
+	assert(xas_store(xa, &xas, NULL) == entry);
+	xa_unlock(xa);
+
+	assert(xa_empty(xa));
+}
+
+void xas_tests(struct xarray *xa)
+{
+	int i;
+
+	assert(xa_empty(xa));
+	xas_walk_test(xa);
+	xas_store_test(xa, 0);
+	xas_store_test(xa, 1);
+
+	for (i = 0; i < 20; i++) {
+		multiorder_check(xa, 200, i);
+		multiorder_check(xa, 0, i);
+		multiorder_check(xa, (1UL << i) + 1, i);
+	}
+}
+
+void xa_get_test(struct xarray *xa)
+{
+	struct item *buf[10];
+	int i;
+
+	xa_store(xa, 0, item_create(0, 0), GFP_KERNEL);
+	xa_store(xa, 1, item_create(1, 0), GFP_KERNEL);
+	xa_store(xa, 7, item_create(7, 0), GFP_KERNEL);
+	xa_store(xa, 1UL << 63, item_create(1UL << 63, 0), GFP_KERNEL);
+
+	assert(xa_get_entries(xa, 0, (void **)buf, 10) == 4);
+	assert(buf[0]->index == 0);
+	assert(buf[1]->index == 1);
+	assert(buf[2]->index == 7);
+	assert(buf[3]->index == 1UL << 63);
+
+	for (i = 0; i < 4; i++)
+		kfree(xa_store(xa, buf[i]->index, NULL, GFP_KERNEL));
+	assert(xa_empty(xa));
+}
+
+void xa_tag_test(struct xarray *xa)
+{
+	struct item *buf[10];
+	int i;
+
+	assert(xa_store(xa, 0, item_create(0, 0), GFP_KERNEL) == NULL);
+	buf[9] = xa_set_tag(xa, 0, XA_TAG_2);
+	assert(buf[9]->index == 0);
+	assert(xa_get_tag(xa, 0, XA_TAG_2));
+	assert(xa_set_tag(xa, 1, XA_TAG_2) == NULL);
+	assert(!xa_get_tag(xa, 1, XA_TAG_2));
+	assert(!xa_get_tag(xa, 64, XA_TAG_2));
+	assert(!xa_get_tag(xa, 0, XA_TAG_1));
+
+	assert(xa_store(xa, 1, item_create(1, 0), GFP_KERNEL) == NULL);
+	assert(xa_store(xa, 7, item_create(7, 0), GFP_KERNEL) == NULL);
+	assert(xa_store(xa, 1UL << 63, item_create(1UL << 63, 0), GFP_KERNEL)
+			== NULL);
+	buf[9] = xa_set_tag(xa, 1, XA_TAG_1);
+	assert(buf[9]->index == 1);
+	buf[9] = xa_set_tag(xa, 7, XA_TAG_1);
+	assert(buf[9]->index == 7);
+
+	assert(xa_get_tagged(xa, 0, (void **)buf, 10, XA_TAG_1) == 2);
+	assert(buf[0]->index == 1);
+	assert(buf[1]->index == 7);
+
+	assert(!xa_get_tag(xa, 0, XA_TAG_1));
+	assert(xa_get_tag(xa, 7, XA_TAG_1));
+	assert(xa_set_tag(xa, 6, XA_TAG_1) == NULL);
+	printf("The next line should be a warning\n");
+	assert(xa_set_tag(xa, 7, 5) == ERR_PTR(-EINVAL));
+	assert(xa_clear_tag(xa, 7, 5) == ERR_PTR(-EINVAL));
+	assert(!xa_get_tag(xa, 7, 5));
+	printf("If there was no warning before this line, that is a bug\n");
+	assert(!xa_get_tag(xa, 7, XA_TAG_0));
+	assert(xa_clear_tag(xa, 7, XA_TAG_1) == buf[1]);
+	assert(!xa_get_tag(xa, 7, XA_TAG_1));
+	assert(!xa_get_tag(xa, 7, 5));
+
+	for (i = 0; i < 2; i++)
+		kfree(xa_store(xa, buf[i]->index, NULL, GFP_KERNEL));
+	assert(xa_get_entries(xa, 0, (void **)buf, 10) == 2);
+	for (i = 0; i < 2; i++)
+		kfree(xa_store(xa, buf[i]->index, NULL, GFP_KERNEL));
+	assert(xa_empty(xa));
+}
+
+void xa_tests(struct xarray *xa)
+{
+	assert(xa_load(xa, 0) == NULL);
+	assert(xa_load(xa, 1) == NULL);
+	assert(xa_load(xa, 2) == NULL);
+	assert(xa_load(xa, ~0) == NULL);
+	assert(xa_store(xa, 0, FOUR, GFP_KERNEL) == NULL);
+	assert(xa_store(xa, 0, EIGHT, GFP_KERNEL) == FOUR);
+	assert(xa_replace(xa, 0, NULL, FOUR, GFP_KERNEL) == EIGHT);
+	assert(xa_replace(xa, 0, NULL, FOUR, GFP_KERNEL) == EIGHT);
+	assert(xa_replace(xa, 0, NULL, EIGHT, GFP_KERNEL) == EIGHT);
+	assert(xa_load(xa, 0) == NULL);
+	assert(xa_load(xa, 1) == NULL);
+	assert(xa_store(xa, 1, FOUR, GFP_KERNEL) == NULL);
+	assert(xa_store(xa, 1, EIGHT, GFP_KERNEL) == FOUR);
+	assert(xa_store(xa, 1, NULL, GFP_KERNEL) == EIGHT);
+	assert(xa_empty(xa));
+
+	xa_get_test(xa);
+	xa_tag_test(xa);
+}
+
+int __weak main(int argc, char **argv)
+{
+	DEFINE_XARRAY(array);
+	test_verbose = 2;
+
+	rcu_init();
+	xarray_init();
+
+	xas_tests(&array);
+	xa_tests(&array);
+
+	rcu_barrier();
+	return 0;
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

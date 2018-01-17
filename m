Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D60328024A
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:22:38 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v25so15057179pfg.14
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:22:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x3si4178467pln.340.2018.01.17.12.22.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:22:35 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 19/99] idr: Convert to XArray
Date: Wed, 17 Jan 2018 12:20:43 -0800
Message-Id: <20180117202203.19756-20-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The IDR distinguishes between unallocated entries (read as NULL) and
entries where the user has chosen to store NULL.  The radix tree was
modified to consider NULL entries which had tag 0 _clear_ as being
allocated, but it added a lot of complexity.

Instead, the XArray has a 'zero entry', which the normal API will treat
as NULL, but is distinct from NULL when using the advanced API.  The IDR
code converts between NULL and zero entries.

The idr_for_each_entry_ul() iterator becomes an alias for xa_for_each(),
so we drop the idr_get_next_ul() function as it has no users.

The exported IDR API was a weird mix of GPL-only and general symbols;
I converted them all to GPL as there was no way to use the IDR API
without being GPL.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 Documentation/core-api/xarray.rst   |   6 +
 include/linux/idr.h                 | 156 ++++++++++++-------
 include/linux/xarray.h              |  29 +++-
 lib/idr.c                           | 298 ++++++++++++++++++++++--------------
 lib/radix-tree.c                    |  77 +++++-----
 lib/xarray.c                        |  32 ++++
 tools/testing/radix-tree/idr-test.c |  34 ++++
 7 files changed, 419 insertions(+), 213 deletions(-)

diff --git a/Documentation/core-api/xarray.rst b/Documentation/core-api/xarray.rst
index 0172c7d9e6ea..1dea1c522506 100644
--- a/Documentation/core-api/xarray.rst
+++ b/Documentation/core-api/xarray.rst
@@ -284,6 +284,12 @@ to :c:func:`xas_retry`, and retry the operation if it returns ``true``.
        this RCU period.  You should restart the lookup from the head of the
        array.
 
+   * - Zero
+     - :c:func:`xa_is_zero`
+     - Zero entries appear as ``NULL`` through the Normal API, but occupy an
+       entry in the XArray which can be tagged or otherwise used to reserve
+       the index.
+
 Other internal entries may be added in the future.  As far as possible, they
 will be handled by :c:func:`xas_retry`.
 
diff --git a/include/linux/idr.h b/include/linux/idr.h
index 11eea38b9629..9064ae5f0abc 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -9,35 +9,35 @@
  * tables.
  */
 
-#ifndef __IDR_H__
-#define __IDR_H__
+#ifndef _LINUX_IDR_H
+#define _LINUX_IDR_H
 
 #include <linux/radix-tree.h>
 #include <linux/gfp.h>
 #include <linux/percpu.h>
-#include <linux/bug.h>
+#include <linux/xarray.h>
 
 struct idr {
-	struct radix_tree_root	idr_rt;
-	unsigned int		idr_next;
+	struct xarray	idr_xa;
+	unsigned int	idr_next;
 };
 
-/*
- * The IDR API does not expose the tagging functionality of the radix tree
- * to users.  Use tag 0 to track whether a node has free space below it.
- */
-#define IDR_FREE	0
-
-/* Set the IDR flag and the IDR_FREE tag */
-#define IDR_RT_MARKER	(ROOT_IS_IDR | (__force gfp_t)			\
-					(1 << (ROOT_TAG_SHIFT + IDR_FREE)))
+#define IDR_INIT_FLAGS	(XA_FLAGS_TRACK_FREE | XA_FLAGS_LOCK_IRQ |	\
+			 XA_FLAGS_TAG(XA_FREE_TAG))
 
 #define IDR_INIT(name)							\
 {									\
-	.idr_rt = RADIX_TREE_INIT(name, IDR_RT_MARKER)			\
+	.idr_xa = XARRAY_INIT_FLAGS(name.idr_xa, IDR_INIT_FLAGS),	\
+	.idr_next = 0,							\
 }
 #define DEFINE_IDR(name)	struct idr name = IDR_INIT(name)
 
+static inline void idr_init(struct idr *idr)
+{
+	xa_init_flags(&idr->idr_xa, IDR_INIT_FLAGS);
+	idr->idr_next = 0;
+}
+
 /**
  * idr_get_cursor - Return the current position of the cyclic allocator
  * @idr: idr handle
@@ -66,62 +66,83 @@ static inline void idr_set_cursor(struct idr *idr, unsigned int val)
 
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
+#define idr_lock(idr)		xa_lock(&(idr)->idr_xa)
+#define idr_unlock(idr)		xa_unlock(&(idr)->idr_xa)
+#define idr_lock_bh(idr)	xa_lock_bh(&(idr)->idr_xa)
+#define idr_unlock_bh(idr)	xa_unlock_bh(&(idr)->idr_xa)
+#define idr_lock_irq(idr)	xa_lock_irq(&(idr)->idr_xa)
+#define idr_unlock_irq(idr)	xa_unlock_irq(&(idr)->idr_xa)
+#define idr_lock_irqsave(idr, flags) \
+				xa_lock_irqsave(&(idr)->idr_xa, flags)
+#define idr_unlock_irqrestore(idr, flags) \
+				xa_unlock_irqrestore(&(idr)->idr_xa, flags)
+
+void idr_preload(gfp_t);
 
 int idr_alloc(struct idr *, void *, int start, int end, gfp_t);
 int __must_check idr_alloc_ul(struct idr *, void *, unsigned long *nextid,
 			unsigned long max, gfp_t);
 int idr_alloc_cyclic(struct idr *, void *entry, int start, int end, gfp_t);
-int idr_for_each(const struct idr *,
+void *idr_remove(struct idr *, unsigned long id);
+void *idr_replace(struct idr *, void *, unsigned long id);
+int idr_for_each(struct idr *,
 		 int (*fn)(int id, void *p, void *data), void *data);
 void *idr_get_next(struct idr *, int *nextid);
-void *idr_get_next_ul(struct idr *, unsigned long *nextid);
-void *idr_replace(struct idr *, void *, unsigned long id);
-void idr_destroy(struct idr *);
 
+#ifdef CONFIG_64BIT
+int __must_check idr_alloc_u32(struct idr *, void *, unsigned int *nextid,
+			unsigned int max, gfp_t);
+#else /* !CONFIG_64BIT */
 static inline int __must_check idr_alloc_u32(struct idr *idr, void *ptr,
-				u32 *nextid, unsigned long max, gfp_t gfp)
-{
-	unsigned long tmp = *nextid;
-	int ret = idr_alloc_ul(idr, ptr, &tmp, max, gfp);
-	*nextid = tmp;
-	return ret;
-}
-
-static inline void *idr_remove(struct idr *idr, unsigned long id)
+		unsigned int *nextid, unsigned int max, gfp_t gfp)
 {
-	return radix_tree_delete_item(&idr->idr_rt, id, NULL);
+	return idr_alloc_ul(idr, ptr, (unsigned long *)nextid, max, gfp);
 }
+#endif
 
-static inline void idr_init(struct idr *idr)
+/**
+ * idr_is_empty() - Determine if there are no entries in the IDR
+ * @idr: IDR handle.
+ *
+ * Return: %true if there are no entries in the IDR.
+ */
+static inline bool idr_is_empty(const struct idr *idr)
 {
-	INIT_RADIX_TREE(&idr->idr_rt, IDR_RT_MARKER);
-	idr->idr_next = 0;
+	return xa_empty(&idr->idr_xa);
 }
 
-static inline bool idr_is_empty(const struct idr *idr)
+/**
+ * idr_destroy() - Free all internal memory used by an IDR.
+ * @idr: IDR handle.
+ *
+ * When you have finished using an IDR, you can free all the memory used
+ * for the IDR data structure by calling this function.  If you also
+ * wish to free the objects referenced by the IDR, you can use idr_for_each()
+ * or idr_for_each_entry() to do that first.
+ */
+static inline void idr_destroy(struct idr *idr)
 {
-	return radix_tree_empty(&idr->idr_rt) &&
-		radix_tree_tagged(&idr->idr_rt, IDR_FREE);
+	xa_destroy(&idr->idr_xa);
 }
 
 /**
- * idr_preload_end - end preload section started with idr_preload()
+ * idr_preload_end() - end preload section started with idr_preload()
  *
  * Each idr_preload() should be matched with an invocation of this
  * function.  See idr_preload() for details.
@@ -132,7 +153,7 @@ static inline void idr_preload_end(void)
 }
 
 /**
- * idr_find - return pointer for given id
+ * idr_find() - return pointer for given id
  * @idr: idr handle
  * @id: lookup key
  *
@@ -140,14 +161,35 @@ static inline void idr_preload_end(void)
  * return indicates that @id is not valid or you passed %NULL in
  * idr_get_new().
  *
- * This function can be called under rcu_read_lock(), given that the leaf
- * pointers lifetimes are correctly managed.
+ * This function is protected by the RCU read lock.  If you want to ensure
+ * that it does not race with a call to idr_remove(), perhaps because you
+ * need to establish a refcount on the object, you can use idr_lock() and
+ * idr_unlock() to prevent simultaneous modification.
  */
-static inline void *idr_find(const struct idr *idr, unsigned long id)
+static inline void *idr_find(struct idr *idr, unsigned long id)
 {
-	return radix_tree_lookup(&idr->idr_rt, id);
+	return xa_load(&idr->idr_xa, id);
 }
 
+/**
+ * idr_for_each_entry_ul() - Iterate over the entries in an IDR.
+ * @idr: IDR handle.
+ * @entry: Pointer to each entry in turn.
+ * @id: ID of each entry.
+ *
+ * Initialise @id to the lowest ID before using this iterator.
+ * In the body of the loop, @entry will point to the object stored in the
+ * IDR.  After the loop has finished normally, @entry will be %NULL, which
+ * is a convenient way to distinguish between a 'break' exit from the loop
+ * and normal termination.
+ *
+ * The control elements of this loop protect themselves with the RCU read
+ * lock, which is dropped before invoking the body.  You may sleep unless
+ * your own locking prevents that.
+ */
+#define idr_for_each_entry_ul(idr, entry, id)			\
+	xa_for_each(&(idr)->idr_xa, entry, id, ULONG_MAX, XA_PRESENT)
+
 /**
  * idr_for_each_entry - iterate over an idr's elements of a given type
  * @idr:     idr handle
@@ -160,8 +202,6 @@ static inline void *idr_find(const struct idr *idr, unsigned long id)
  */
 #define idr_for_each_entry(idr, entry, id)			\
 	for (id = 0; ((entry) = idr_get_next(idr, &(id))) != NULL; ++id)
-#define idr_for_each_entry_ul(idr, entry, id)			\
-	for (id = 0; ((entry) = idr_get_next_ul(idr, &(id))) != NULL; ++id)
 
 /**
  * idr_for_each_entry_continue - continue iteration over an idr's elements of a given type
@@ -196,7 +236,7 @@ struct ida {
 };
 
 #define IDA_INIT(name)	{						\
-	.ida_rt = RADIX_TREE_INIT(name, IDR_RT_MARKER | GFP_NOWAIT),	\
+	.ida_rt = RADIX_TREE_INIT(name, IDR_INIT_FLAGS | GFP_NOWAIT),	\
 }
 #define DEFINE_IDA(name)	struct ida name = IDA_INIT(name)
 
@@ -211,7 +251,7 @@ void ida_simple_remove(struct ida *ida, unsigned int id);
 
 static inline void ida_init(struct ida *ida)
 {
-	INIT_RADIX_TREE(&ida->ida_rt, IDR_RT_MARKER | GFP_NOWAIT);
+	INIT_RADIX_TREE(&ida->ida_rt, IDR_INIT_FLAGS | GFP_NOWAIT);
 }
 
 /**
@@ -230,4 +270,4 @@ static inline bool ida_is_empty(const struct ida *ida)
 {
 	return radix_tree_empty(&ida->ida_rt);
 }
-#endif /* __IDR_H__ */
+#endif /* _LINUX_IDR_H */
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index ca6af6dd42c4..6f59f1f60205 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -32,7 +32,8 @@
  * The following internal entries have a special meaning:
  *
  * 0-62: Sibling entries
- * 256: Retry entry
+ * 256: Zero entry
+ * 257: Retry entry
  *
  * Errors are also represented as internal entries, but use the negative
  * space (-4094 to -2).  They're never stored in the slots array; only
@@ -192,6 +193,7 @@ typedef unsigned __bitwise xa_tag_t;
 #define XA_TAG_2		((__force xa_tag_t)2U)
 #define XA_PRESENT		((__force xa_tag_t)8U)
 #define XA_TAG_MAX		XA_TAG_2
+#define XA_FREE_TAG		XA_TAG_0
 
 enum xa_lock_type {
 	XA_LOCK_IRQ = 1,
@@ -204,6 +206,7 @@ enum xa_lock_type {
  */
 #define XA_FLAGS_LOCK_IRQ	((__force gfp_t)XA_LOCK_IRQ)
 #define XA_FLAGS_LOCK_BH	((__force gfp_t)XA_LOCK_BH)
+#define XA_FLAGS_TRACK_FREE	((__force gfp_t)4U)
 #define XA_FLAGS_TAG(tag)	((__force gfp_t)((1U << __GFP_BITS_SHIFT) << \
 						(__force unsigned)(tag)))
 
@@ -555,7 +558,19 @@ static inline bool xa_is_sibling(const void *entry)
 		(entry < xa_mk_sibling(XA_CHUNK_SIZE - 1));
 }
 
-#define XA_RETRY_ENTRY		xa_mk_internal(256)
+#define XA_ZERO_ENTRY		xa_mk_internal(256)
+#define XA_RETRY_ENTRY		xa_mk_internal(257)
+
+/**
+ * xa_is_zero() - Is the entry a zero entry?
+ * @entry: Entry retrieved from the XArray
+ *
+ * Return: %true if the entry is a zero entry.
+ */
+static inline bool xa_is_zero(const void *entry)
+{
+	return unlikely(entry == XA_ZERO_ENTRY);
+}
 
 /**
  * xa_is_retry() - Is the entry a retry entry?
@@ -717,18 +732,20 @@ static inline bool xas_top(struct xa_node *node)
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
+ * a retry entry or a zero entry.  This function sets up the @xas to restart
+ * the walk from the head of the array if needed.
  *
  * Return: true if the operation needs to be retried.
  */
 static inline bool xas_retry(struct xa_state *xas, const void *entry)
 {
+	if (xa_is_zero(entry))
+		return true;
 	if (!xa_is_retry(entry))
 		return false;
 	xas->xa_node = XAS_RESTART;
diff --git a/lib/idr.c b/lib/idr.c
index b9aa08e198a2..379eaa8cb75b 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -1,3 +1,10 @@
+/* SPDX-License-Identifier: GPL-2.0+ */
+/*
+ * IDR implementation
+ * Copyright (c) 2017 Microsoft Corporation
+ * Author: Matthew Wilcox <mawilcox@microsoft.com>
+ */
+
 #include <linux/bitmap.h>
 #include <linux/export.h>
 #include <linux/idr.h>
@@ -8,67 +15,121 @@
 DEFINE_PER_CPU(struct ida_bitmap *, ida_bitmap);
 static DEFINE_SPINLOCK(simple_ida_lock);
 
+/* In radix-tree.c temporarily */
+extern bool idr_nomem(struct xa_state *, gfp_t);
+
 /**
- * idr_alloc_ul() - allocate a large ID
- * @idr: idr handle
- * @ptr: pointer to be associated with the new ID
- * @nextid: Pointer to minimum ID to allocate
- * @max: the maximum ID (inclusive)
- * @gfp: memory allocation flags
+ * idr_alloc_ul() - Allocate a large ID.
+ * @idr: IDR handle.
+ * @ptr: Pointer to be associated with the new ID.
+ * @nextid: Pointer to minimum ID to allocate.
+ * @max: The maximum ID (inclusive).
+ * @gfp: Memory allocation flags.
  *
  * Allocates an unused ID in the range [*nextid, end] and stores it in
  * @nextid.  Note that @max differs from the @end parameter to idr_alloc().
  *
- * Simultaneous modifications to the @idr are not allowed and should be
- * prevented by the user, usually with a lock.  idr_alloc_ul() may be called
- * concurrently with read-only accesses to the @idr, such as idr_find() and
- * idr_for_each_entry().
+ * The IDR uses its own spinlock to protect against simultaneous
+ * modification.  @nextid is assigned to before @ptr is stored in the IDR;
+ * if @nextid points into the object referenced by @ptr, it will not be
+ * possible for a simultaneous lookup to see the wrong value in @nextid.
  *
- * Return: 0 on success or a negative errno on failure (ENOMEM or ENOSPC)
+ * Return: 0 on success or a negative errno on failure (ENOMEM or ENOSPC).
  */
 int idr_alloc_ul(struct idr *idr, void *ptr, unsigned long *nextid,
 			unsigned long max, gfp_t gfp)
 {
-	struct radix_tree_iter iter;
-	void __rcu **slot;
+	XA_STATE(xas, &idr->idr_xa, *nextid);
+	unsigned long flags;
 
-	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
+	if (WARN_ON_ONCE(xa_is_internal(ptr)))
 		return -EINVAL;
+	if (!ptr)
+		ptr = XA_ZERO_ENTRY;
+
+	do {
+		xas_lock_irqsave(&xas, flags);
+		xas_find_tag(&xas, max, XA_FREE_TAG);
+		if (xas.xa_index > max)
+			xas_set_err(&xas, -ENOSPC);
+		else
+			*nextid = xas.xa_index;
+		xas_store(&xas, ptr);
+		xas_clear_tag(&xas, XA_FREE_TAG);
+		xas_unlock_irqrestore(&xas, flags);
+	} while (idr_nomem(&xas, gfp));
+
+	return xas_error(&xas);
+}
+EXPORT_SYMBOL_GPL(idr_alloc_ul);
 
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
+/**
+ * idr_alloc_u32() - Allocate an ID.
+ * @idr: IDR handle.
+ * @ptr: Pointer to be associated with the new ID.
+ * @nextid: Pointer to minimum ID to allocate.
+ * @max: The maximum ID (inclusive).
+ * @gfp: Memory allocation flags.
+ *
+ * Allocates an unused ID in the range [*nextid, end] and stores it in
+ * @nextid.  Note that @max differs from the @end parameter to idr_alloc().
+ *
+ * The IDR uses its own spinlock to protect against simultaneous
+ * modification.  @nextid is assigned to before @ptr is stored in the IDR;
+ * if @nextid points into the object referenced by @ptr, it will not be
+ * possible for a simultaneous lookup to see the wrong value in @nextid.
+ *
+ * Return: 0 on success or a negative errno on failure (ENOMEM or ENOSPC).
+ */
+#ifdef CONFIG_64BIT
+int idr_alloc_u32(struct idr *idr, void *ptr, unsigned int *nextid,
+			unsigned int max, gfp_t gfp)
+{
+	XA_STATE(xas, &idr->idr_xa, *nextid);
+	unsigned long flags;
 
-	*nextid = iter.index;
-	return 0;
+	if (WARN_ON_ONCE(xa_is_internal(ptr)))
+		return -EINVAL;
+	if (!ptr)
+		ptr = XA_ZERO_ENTRY;
+
+	do {
+		xas_lock_irqsave(&xas, flags);
+		xas_find_tag(&xas, max, XA_FREE_TAG);
+		if (xas.xa_index > max)
+			xas_set_err(&xas, -ENOSPC);
+		else
+			*nextid = xas.xa_index;
+		xas_store(&xas, ptr);
+		xas_clear_tag(&xas, XA_FREE_TAG);
+		xas_unlock_irqrestore(&xas, flags);
+	} while (idr_nomem(&xas, gfp));
+
+	return xas_error(&xas);
 }
-EXPORT_SYMBOL_GPL(idr_alloc_ul);
+EXPORT_SYMBOL_GPL(idr_alloc_u32);
+#endif
 
 /**
- * idr_alloc - allocate an id
- * @idr: idr handle
- * @ptr: pointer to be associated with the new id
- * @start: the minimum id (inclusive)
- * @end: the maximum id (exclusive)
- * @gfp: memory allocation flags
+ * idr_alloc() - Allocate an ID.
+ * @idr: IDR handle.
+ * @ptr: Pointer to be associated with the new ID.
+ * @start: The minimum id (inclusive).
+ * @end: The maximum id (exclusive).
+ * @gfp: Memory allocation flags.
+ *
+ * Allocates an unused ID >= start and < end.
  *
- * Allocates an unused ID in the range [start, end).  Returns -ENOSPC
- * if there are no unused IDs in that range.
+ * If @end is <= 0, it is treated as %INT_MAX + 1.  This is to always
+ * allow using @start + N as @end as long as N is <= %INT_MAX.  This
+ * differs from the @max parameter to idr_alloc_ul() and idr_alloc_u32().
  *
- * Note that @end is treated as max when <= 0.  This is to always allow
- * using @start + N as @end as long as N is inside integer range.
+ * The IDR uses its own spinlock to protect against simultaneous
+ * modification.  The @ptr is visible to other simultaneous readers
+ * like idr_find() before this function returns.
  *
- * Simultaneous modifications to the @idr are not allowed and should be
- * prevented by the user, usually with a lock.  idr_alloc() may be called
- * concurrently with read-only accesses to the @idr, such as idr_find() and
- * idr_for_each_entry().
+ * Return: The newly allocated ID on success.  -ENOMEM for a memory
+ * allocation failure.  -ENOSPC if there are no free IDs in the range.
  */
 int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
 {
@@ -88,16 +149,22 @@ int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
 EXPORT_SYMBOL_GPL(idr_alloc);
 
 /**
- * idr_alloc_cyclic - allocate new idr entry in a cyclical fashion
- * @idr: idr handle
- * @ptr: pointer to be associated with the new id
- * @start: the minimum id (inclusive)
- * @end: the maximum id (exclusive)
- * @gfp: memory allocation flags
- *
- * Allocates an ID larger than the last ID allocated if one is available.
- * If not, it will attempt to allocate the smallest ID that is larger or
- * equal to @start.
+ * idr_alloc_cyclic - Allocate an ID cyclically.
+ * @idr: IDR handle.
+ * @ptr: Pointer to be associated with the new ID.
+ * @start: The minimum id (inclusive).
+ * @end: The maximum id (exclusive).
+ * @gfp: Memory allocation flags.
+ *
+ * Allocates an unused ID >= @start and < @end.  It will start searching
+ * after the last ID allocated and wrap back around to @start.
+ *
+ * The IDR uses its own spinlock to protect against simultaneous
+ * modification.  The @ptr is visible to other simultaneous readers
+ * like idr_find() before this function returns.
+ *
+ * Return: The newly allocated ID on success.  -ENOMEM for a memory
+ * allocation failure.  -ENOSPC if there are no free IDs in the range.
  */
 int idr_alloc_cyclic(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
 {
@@ -119,88 +186,91 @@ int idr_alloc_cyclic(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
 	idr->idr_next = id + 1U;
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
  *
- * The callback function will be called for each entry in @idr, passing
- * the id, the pointer and the data pointer passed to this function.
+ * The callback function will be called for each non-NULL pointer in
+ * @idr, passing the id, the pointer and @data.  No internal locks are
+ * held while @fn is called, so @fn may sleep unless otherwise prevented
+ * by your own locking.
  *
  * If @fn returns anything other than %0, the iteration stops and that
  * value is returned from this function.
  *
- * idr_for_each() can be called concurrently with idr_alloc() and
- * idr_remove() if protected by RCU.  Newly added entries may not be
- * seen and deleted entries may be seen, but adding and removing entries
- * will not cause other entries to be skipped, nor spurious ones to be seen.
+ * idr_for_each() protects itself with the RCU read lock.  Newly added
+ * entries may not be seen and deleted entries may be seen, but adding
+ * and removing entries will not cause other entries to be skipped, nor
+ * spurious ones to be seen.
+ *
+ * Return: The value returned by the last call to @fn.
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
+	xa_for_each(&idr->idr_xa, p, i, INT_MAX, XA_PRESENT) {
+		int ret = fn(i, p, data);
 		if (ret)
 			return ret;
 	}
 
 	return 0;
 }
-EXPORT_SYMBOL(idr_for_each);
+EXPORT_SYMBOL_GPL(idr_for_each);
 
 /**
- * idr_get_next - Find next populated entry
+ * idr_get_next() - Find next populated entry
  * @idr: idr handle
- * @nextid: Pointer to lowest possible ID to return
+ * @id: Pointer to lowest possible ID to return
  *
  * Returns the next populated entry in the tree with an ID greater than
  * or equal to the value pointed to by @nextid.  On exit, @nextid is updated
  * to the ID of the found value.  To use in a loop, the value pointed to by
  * nextid must be incremented by the user.
+ *
+ * This function protects itself with the RCU read lock, so may return a
+ * stale entry or may skip a newly added entry unless synchronised with
+ * a lock.
  */
-void *idr_get_next(struct idr *idr, int *nextid)
+void *idr_get_next(struct idr *idr, int *id)
 {
-	struct radix_tree_iter iter;
-	void __rcu **slot;
-
-	slot = radix_tree_iter_find(&idr->idr_rt, &iter, *nextid);
-	if (!slot)
-		return NULL;
+	unsigned long index = *id;
+	void *entry = xa_find(&idr->idr_xa, &index, INT_MAX, XA_PRESENT);
 
-	*nextid = iter.index;
-	return rcu_dereference_raw(*slot);
+	*id = index;
+	return entry;
 }
-EXPORT_SYMBOL(idr_get_next);
+EXPORT_SYMBOL_GPL(idr_get_next);
 
 /**
- * idr_get_next_ul - Find next populated entry
- * @idr: idr handle
- * @nextid: Pointer to lowest possible ID to return
+ * idr_remove() - Remove an item from the IDR.
+ * @idr: IDR handle.
+ * @id: Object ID.
  *
- * Returns the next populated entry in the tree with an ID greater than
- * or equal to the value pointed to by @nextid.  On exit, @nextid is updated
- * to the ID of the found value.  To use in a loop, the value pointed to by
- * nextid must be incremented by the user.
+ * Once this function returns, the ID is available for allocation again.
+ * This function protects itself with the IDR lock.
+ *
+ * Return: The pointer associated with this ID.
  */
-void *idr_get_next_ul(struct idr *idr, unsigned long *nextid)
+void *idr_remove(struct idr *idr, unsigned long id)
 {
-	struct radix_tree_iter iter;
-	void __rcu **slot;
+	unsigned long flags;
+	void *entry;
 
-	slot = radix_tree_iter_find(&idr->idr_rt, &iter, *nextid);
-	if (!slot)
-		return NULL;
+	xa_lock_irqsave(&idr->idr_xa, flags);
+	entry = __xa_erase(&idr->idr_xa, id);
+	xa_unlock_irqrestore(&idr->idr_xa, flags);
 
-	*nextid = iter.index;
-	return rcu_dereference_raw(*slot);
+	return entry;
 }
-EXPORT_SYMBOL(idr_get_next_ul);
+EXPORT_SYMBOL_GPL(idr_remove);
 
 /**
  * idr_replace - replace pointer for given id
@@ -209,31 +279,35 @@ EXPORT_SYMBOL(idr_get_next_ul);
  * @id: Lookup key
  *
  * Replace the pointer registered with an ID and return the old value.
- * This function can be called under the RCU read lock concurrently with
- * idr_alloc() and idr_remove() (as long as the ID being removed is not
- * the one being replaced!).
+ * This function protects itself with a spinlock.
  *
  * Returns: the old value on success.  %-ENOENT indicates that @id was not
  * found.  %-EINVAL indicates that @id or @ptr were not valid.
  */
 void *idr_replace(struct idr *idr, void *ptr, unsigned long id)
 {
-	struct radix_tree_node *node;
-	void __rcu **slot = NULL;
-	void *entry;
+	XA_STATE(xas, &idr->idr_xa, id);
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
+		ptr = XA_ZERO_ENTRY;
+
+	xas_lock_irqsave(&xas, flags);
+	curr = xas_load(&xas);
+	if (curr)
+		xas_store(&xas, ptr);
+	else
+		curr = ERR_PTR(-ENOENT);
+	xas_unlock_irqrestore(&xas, flags);
+
+	if (xa_is_zero(curr))
+		return NULL;
+	return curr;
 }
-EXPORT_SYMBOL(idr_replace);
+EXPORT_SYMBOL_GPL(idr_replace);
 
 /**
  * DOC: IDA description
@@ -264,7 +338,7 @@ EXPORT_SYMBOL(idr_replace);
  * Developer's notes:
  *
  * The IDA uses the functionality provided by the IDR & radix tree to store
- * bitmaps in each entry.  The IDR_FREE tag means there is at least one bit
+ * bitmaps in each entry.  The XA_FREE_TAG tag means there is at least one bit
  * free, unlike the IDR where it means at least one entry is free.
  *
  * I considered telling the radix tree that each slot is an order-10 node
@@ -370,7 +444,7 @@ int ida_get_new_above(struct ida *ida, int start, int *id)
 			__set_bit(bit, bitmap->bitmap);
 			if (bitmap_full(bitmap->bitmap, IDA_BITMAP_BITS))
 				radix_tree_iter_tag_clear(root, &iter,
-								IDR_FREE);
+								XA_FREE_TAG);
 		} else {
 			new += bit;
 			if (new < 0)
@@ -426,7 +500,7 @@ void ida_remove(struct ida *ida, int id)
 		goto err;
 
 	__clear_bit(offset, btmp);
-	radix_tree_iter_tag_set(&ida->ida_rt, &iter, IDR_FREE);
+	radix_tree_iter_tag_set(&ida->ida_rt, &iter, XA_FREE_TAG);
 	if (xa_is_value(bitmap)) {
 		if (xa_to_value(rcu_dereference_raw(*slot)) == 0)
 			radix_tree_iter_delete(&ida->ida_rt, &iter, slot);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index a0fdea68ce9c..75e02cb78ada 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -529,6 +529,30 @@ int radix_tree_maybe_preload_order(gfp_t gfp_mask, int order)
 	return __radix_tree_preload(gfp_mask, nr_nodes);
 }
 
+/* Once the IDR users abandon the preload API, we can use xas_nomem */
+bool idr_nomem(struct xa_state *xas, gfp_t gfp)
+{
+	if (xas->xa_node != XA_ERROR(-ENOMEM)) {
+		xas_destroy(xas);
+		return false;
+	}
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
@@ -562,7 +586,7 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
 		maxshift += RADIX_TREE_MAP_SHIFT;
 
 	entry = rcu_dereference_raw(root->xa_head);
-	if (!entry && (!is_idr(root) || root_tag_get(root, IDR_FREE)))
+	if (!entry && (!is_idr(root) || root_tag_get(root, XA_FREE_TAG)))
 		goto out;
 
 	do {
@@ -572,10 +596,10 @@ static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp,
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
@@ -646,8 +670,8 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root,
 		 * one (root->xa_head) as far as dependent read barriers go.
 		 */
 		root->xa_head = (void __rcu *)child;
-		if (is_idr(root) && !tag_get(node, IDR_FREE, 0))
-			root_tag_clear(root, IDR_FREE);
+		if (is_idr(root) && !tag_get(node, XA_FREE_TAG, 0))
+			root_tag_clear(root, XA_FREE_TAG);
 
 		/*
 		 * We have a dilemma here. The node's slot[0] must not be
@@ -1074,7 +1098,7 @@ static bool node_tag_get(const struct radix_tree_root *root,
 /*
  * IDR users want to be able to store NULL in the tree, so if the slot isn't
  * free, don't adjust the count, even if it's transitioning between NULL and
- * non-NULL.  For the IDA, we mark slots as being IDR_FREE while they still
+ * non-NULL.  For the IDA, we mark slots as being XA_FREE_TAG while they still
  * have empty bits, but it only stores NULL in slots when they're being
  * deleted.
  */
@@ -1084,7 +1108,7 @@ static int calculate_count(struct radix_tree_root *root,
 {
 	if (is_idr(root)) {
 		unsigned offset = get_slot_offset(node, slot);
-		bool free = node_tag_get(root, node, IDR_FREE, offset);
+		bool free = node_tag_get(root, node, XA_FREE_TAG, offset);
 		if (!free)
 			return 0;
 		if (!old)
@@ -1915,7 +1939,7 @@ static bool __radix_tree_delete(struct radix_tree_root *root,
 	int tag;
 
 	if (is_idr(root))
-		node_tag_set(root, node, IDR_FREE, offset);
+		node_tag_set(root, node, XA_FREE_TAG, offset);
 	else
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 			node_tag_clear(root, node, tag, offset);
@@ -1963,7 +1987,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 	void *entry;
 
 	entry = __radix_tree_lookup(root, index, &node, &slot);
-	if (!entry && (!is_idr(root) || node_tag_get(root, node, IDR_FREE,
+	if (!entry && (!is_idr(root) || node_tag_get(root, node, XA_FREE_TAG,
 						get_slot_offset(node, slot))))
 		return NULL;
 
@@ -2070,7 +2094,7 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 
  grow:
 	shift = radix_tree_load_root(root, &child, &maxindex);
-	if (!radix_tree_tagged(root, IDR_FREE))
+	if (!radix_tree_tagged(root, XA_FREE_TAG))
 		start = max(start, maxindex + 1);
 	if (start > max)
 		return ERR_PTR(-ENOSPC);
@@ -2091,7 +2115,7 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 							offset, 0, 0);
 			if (!child)
 				return ERR_PTR(-ENOMEM);
-			all_tag_set(child, IDR_FREE);
+			all_tag_set(child, XA_FREE_TAG);
 			rcu_assign_pointer(*slot, node_to_entry(child));
 			if (node)
 				node->count++;
@@ -2100,8 +2124,8 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 
 		node = entry_to_node(child);
 		offset = radix_tree_descend(node, &child, start);
-		if (!tag_get(node, IDR_FREE, offset)) {
-			offset = radix_tree_find_next_bit(node, IDR_FREE,
+		if (!tag_get(node, XA_FREE_TAG, offset)) {
+			offset = radix_tree_find_next_bit(node, XA_FREE_TAG,
 							offset + 1);
 			start = next_index(start, node, offset);
 			if (start > max)
@@ -2125,32 +2149,11 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
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
index c044373d6893..ace309cc9253 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -46,6 +46,11 @@ static inline unsigned int xa_lock_type(const struct xarray *xa)
 	return (__force unsigned int)xa->xa_flags & 3;
 }
 
+static inline bool xa_track_free(const struct xarray *xa)
+{
+	return xa->xa_flags & XA_FLAGS_TRACK_FREE;
+}
+
 static inline void xa_tag_set(struct xarray *xa, xa_tag_t tag)
 {
 	if (!(xa->xa_flags & XA_FLAGS_TAG(tag)))
@@ -81,6 +86,11 @@ static inline bool node_any_tag(struct xa_node *node, xa_tag_t tag)
 	return !bitmap_empty(node->tags[(__force unsigned)tag], XA_CHUNK_SIZE);
 }
 
+static inline void node_tag_all(struct xa_node *node, xa_tag_t tag)
+{
+	bitmap_fill(node->tags[(__force unsigned)tag], XA_CHUNK_SIZE);
+}
+
 #define tag_inc(tag) do { \
 	tag = (__force xa_tag_t)((__force unsigned)(tag) + 1); \
 } while (0)
@@ -390,6 +400,8 @@ static void xas_shrink(struct xa_state *xas)
 		xas->xa_node = XAS_BOUNDS;
 
 		RCU_INIT_POINTER(xa->xa_head, entry);
+		if (xa_track_free(xa) && !node_get_tag(node, 0, XA_FREE_TAG))
+			xa_tag_clear(xa, XA_FREE_TAG);
 
 		node->count = 0;
 		node->nr_values = 0;
@@ -522,6 +534,14 @@ static int xas_expand(struct xa_state *xas, void *head)
 		RCU_INIT_POINTER(node->slots[0], head);
 
 		/* Propagate the aggregated tag info to the new child */
+		if (xa_track_free(xa)) {
+			node_tag_all(node, XA_FREE_TAG);
+			if (!xa_tagged(xa, XA_FREE_TAG)) {
+				node_clear_tag(node, 0, XA_FREE_TAG);
+				xa_tag_set(xa, XA_FREE_TAG);
+			}
+			tag_inc(tag);
+		}
 		for (;;) {
 			if (xa_tagged(xa, tag))
 				node_set_tag(node, 0, tag);
@@ -598,6 +618,8 @@ void *xas_create(struct xa_state *xas)
 			node = xas_alloc(xas, shift);
 			if (!node)
 				break;
+			if (xa_track_free(xa))
+				node_tag_all(node, XA_FREE_TAG);
 			rcu_assign_pointer(*slot, xa_mk_node(node));
 		} else if (xa_is_node(entry)) {
 			node = xa_to_node(entry);
@@ -815,6 +837,10 @@ void xas_init_tags(const struct xa_state *xas)
 {
 	xa_tag_t tag = 0;
 
+	if (xa_track_free(xas->xa)) {
+		xas_set_tag(xas, XA_FREE_TAG);
+		tag_inc(tag);
+	}
 	for (;;) {
 		xas_clear_tag(xas, tag);
 		if (tag == XA_TAG_MAX)
@@ -1125,6 +1151,8 @@ void *xa_load(struct xarray *xa, unsigned long index)
 	rcu_read_lock();
 	do {
 		entry = xas_load(&xas);
+		if (xa_is_zero(entry))
+			entry = NULL;
 	} while (xas_retry(&xas, entry));
 	rcu_read_unlock();
 
@@ -1134,6 +1162,8 @@ EXPORT_SYMBOL(xa_load);
 
 static void *xas_result(struct xa_state *xas, void *curr)
 {
+	if (xa_is_zero(curr))
+		return NULL;
 	XA_NODE_BUG_ON(xas->xa_node, xa_is_internal(curr));
 	if (xas_error(xas))
 		curr = xas->xa_node;
@@ -1626,6 +1656,8 @@ void xa_dump_entry(const void *entry, unsigned long index, unsigned long shift)
 		pr_cont("retry (%ld)\n", xa_to_internal(entry));
 	else if (xa_is_sibling(entry))
 		pr_cont("sibling (slot %ld)\n", xa_to_sibling(entry));
+	else if (xa_is_zero(entry))
+		pr_cont("zero (%ld)\n", xa_to_internal(entry));
 	else
 		pr_cont("UNKNOWN ENTRY (%px)\n", entry);
 }
diff --git a/tools/testing/radix-tree/idr-test.c b/tools/testing/radix-tree/idr-test.c
index 7499319e85f8..9701db3b7683 100644
--- a/tools/testing/radix-tree/idr-test.c
+++ b/tools/testing/radix-tree/idr-test.c
@@ -177,6 +177,31 @@ void idr_get_next_test(void)
 	idr_destroy(&idr);
 }
 
+void idr_shrink_test(struct idr *idr)
+{
+	assert(idr_alloc(idr, NULL, 1, 2, GFP_KERNEL) == 1);
+	assert(idr_alloc(idr, NULL, 5000, 5001, GFP_KERNEL) == 5000);
+	idr_remove(idr, 5000);
+	idr_remove(idr, 1);
+	assert(idr_is_empty(idr));
+}
+
+/*
+ * Check that growing the IDR works properly.
+ */
+void idr_alloc_far(struct idr *idr, unsigned long end)
+{
+	int i;
+
+	for (i = 1; i < end; i++)
+		assert(idr_alloc(idr, idr, i, i + 1, GFP_KERNEL) == i);
+
+	for (i = 1; i <= end; i++) {
+		assert(idr_alloc(idr, idr, 1, 0, GFP_KERNEL) == end);
+		idr_remove(idr, end);
+	}
+}
+
 void idr_checks(void)
 {
 	unsigned long i;
@@ -227,6 +252,13 @@ void idr_checks(void)
 	idr_null_test();
 	idr_nowait_test();
 	idr_get_next_test();
+	idr_shrink_test(&idr);
+	idr_destroy(&idr);
+
+	for (i = 2; i < 18; i++) {
+		idr_alloc_far(&idr, 1UL << i);
+		idr_destroy(&idr);
+	}
 }
 
 /*
@@ -505,7 +537,9 @@ void ida_thread_tests(void)
 int __weak main(void)
 {
 	radix_tree_init();
+	printv(0, "starting IDR checks\n");
 	idr_checks();
+	printv(0, "starting IDA checks\n");
 	ida_checks();
 	ida_thread_tests();
 	radix_tree_cpu_dead(1);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

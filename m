Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B62EA6B038B
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 22:28:51 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g2so172567001pge.7
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 19:28:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w28si7332034pfl.201.2017.03.17.19.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 19:28:47 -0700 (PDT)
Date: Fri, 17 Mar 2017 19:28:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: XArray version 2
Message-ID: <20170318022846.GH4033@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Here's version 2 of the XArray patch.

Compared to version 1, I fixed a lot of bugs.  0day has finally stopped
whinging about the various things I've done wrong, so I have some level
of confidence in it.

You can get a git tree here if you're interested.  I rebase occasionally.
http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray-2017-03-11

I've started converting the page cache from the radix tree to the XArray.
It's a big job, but it's found some problems I had to address.  I was
hoping to do the conversion as a big bang, but I now think that's too
big a job.  I probably need to convert things over one step at a time.
If you look at the git tree link above, you can see the first step
towards that in "Abstract away the page cache lock".

You can take a look at my current conversion efforts in
http://www.infradead.org/~willy/linux/pagecache-rewrite-2017-03-17.diff
I'll tease you with the diffstat:
 39 files changed, 682 insertions(+), 1015 deletions(-)
DAX is in progress.  khugepaged.c is also in progress.

One of the things I've been focusing on recently is performance.
I'm trying to make sure that the xarray iterators do as well as the radix
tree iterators.  Working on the page cache has helped with that because
that's the most performance sensitive user.  I think things should be
a bit quicker, particularly on large files where we may be looking at
a very deep radix tree.

Changes since v1:

 - There is now an xa_init() to initialise dynamically allocated xarrays.
 - Removed 'const' from much of the API.  lockdep basically makes it
   impossible to mark these things as const.
 - Removed the #ifdef XA_ADVANCED guard.  Everybody gets the whole API now.
 - Changed the representation of errors in the xa_state to make it easier
   for the iterators to bug out to their helper routines.
 - Combined xa_is_retry() and xas_retry() into one function.  Before:
	if (xa_is_retry(entry)) {
		xas_retry(&xas);
		continue;
	}
   After:
	if (xas_is_retry(&xas, entry))
		continue;
   That saves two lines of precious vertical space
 - Figured out how to remove xas_delete_node() from the API.  Use the
   ability to store a NULL into a multientry slot to delete a node instead.
 - Renamed xarray_init() to init_xarray().  It was confusing whether
   xa_init() or xarray_init() initialised an individual xarray or the
   entire xarray subsystem

commit 9e8d487b470907735e4d6082dd6b2125b3b1c673
Author: Matthew Wilcox <mawilcox@microsoft.com>
Date:   Tue Feb 28 12:51:54 2017 -0500

    Add XArray
    
    The xarray is an array of 2^BITS_PER_LONG pointers which handles its own
    locking and memory allocation.  It is intended to replace the radix tree.
    
    Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
new file mode 100644
index 0000000..43cdedc
--- /dev/null
+++ b/include/linux/xarray.h
@@ -0,0 +1,823 @@
+#ifndef _LINUX_XARRAY_H
+#define _LINUX_XARRAY_H
+/*
+ * eXtensible Arrays
+ * Copyright (c) 2017 Microsoft Corporation
+ * Author: Matthew Wilcox <mawilcox@microsoft.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+/**
+ * An eXtensible Array is an array of pointers indexed by an unsigned
+ * long.  The xarray takes care of its own locking, using an irqsafe
+ * spinlock for operations that modify the array and RCU for operations
+ * which only read from the array.
+ *
+ * The xarray can store exceptional entries as well as pointers.
+ * Exceptional entries have a value between 0 and 2^(BITS_PER_LONG - 1).
+ * You cannot store arbitrary unsigned longs in the xarray as some
+ * values are reserved for internal use.  It is better to avoid storing
+ * IS_ERR() pointers in the array as it is hard to distinguish between
+ * xa_store() having failed to allocate memory, and a previously successful
+ * store of the entry ERR_PTR(-ENOMEM) in the array.
+ *
+ * A freshly initialised xarray is full of NULL pointers.  You can set
+ * the entry at any index by calling xa_store(), and get the value by
+ * calling xa_load().  There is no difference between an entry which has
+ * never been stored to and an entry which has most recently had NULL stored
+ * to it.  You can conditionally update the value of an entry by calling
+ * xa_replace().  Each entry which isn't NULL can be tagged with up to three
+ * bits of extra information, accessed through xa_get_tag(), xa_set_tag() and
+ * xa_clear_tag().  You can copy batches of entries out of the array by
+ * calling xa_get_entries() or xa_get_tagged().  You can iterate over present
+ * entries in the array by calling xa_find(), xa_next() or xa_for_each().
+ *
+ * There are two levels of API provided.  Normal and Advanced.
+ * The advanced API has sharp edges and you can easily corrupt an xarray.
+ */
+
+#include <linux/bug.h>
+#include <linux/compiler.h>
+#include <linux/kernel.h>
+#include <linux/rcupdate.h>
+#include <linux/spinlock.h>
+
+/**
+ * struct xarray - The anchor of the XArray
+ * @xa_lock: Lock protecting writes to the array.
+ * @xa_flags: Internal XArray flags.
+ * @xa_head: The first pointer in the array.
+ *
+ * If all of the pointers in the array are NULL, @xa_head is a NULL pointer.
+ * If the only non-NULL pointer in the array is at index 0, @xa_head is that
+ * pointer.  If any other pointer in the array is non-NULL, @xa_head points
+ * to an @xa_node.
+ */
+struct xarray {
+	spinlock_t xa_lock;
+	unsigned int xa_flags;
+	void __rcu *xa_head;
+};
+
+#define __XARRAY_INIT(name, flags) {				\
+	.xa_lock = __SPIN_LOCK_UNLOCKED(name.xa_lock),		\
+	.xa_flags = flags,					\
+	.xa_head = NULL,					\
+}
+
+#define XARRAY_INIT(name) __XARRAY_INIT(name, 0)
+#define XARRAY_FREE_INIT(name) __XARRAY_INIT(name, XA_FLAG_TRACK_FREE | 1)
+
+#define DEFINE_XARRAY(name) struct xarray name = XARRAY_INIT(name)
+
+static inline void __xarray_init(struct xarray *xa, const char *name,
+		unsigned int flags)
+{
+	spin_lock_init(&xa->xa_lock);
+	xa->xa_flags = flags;
+	xa->xa_head = NULL;
+}
+#define xa_init(xa)	__xarray_init(xa, #xa ".xa_lock", 0)
+
+/*
+ * The low three bits of the flag field are used for storing the tags.
+ *
+ * The TRACK_FREE flag indicates that the XA_FREE_TAG tag is used to track
+ * free entries in the xarray.  If you set this flag, only tags 1 & 2
+ * are available for you to use.
+ */
+#define XA_FLAG_TRACK_FREE	(1 << 3)
+
+void *xa_load(struct xarray *, unsigned long index);
+void *xa_store(struct xarray *, unsigned long index, void *entry, gfp_t);
+void *xa_replace(struct xarray *, unsigned long index,
+		void *entry, void *old, gfp_t);
+
+typedef unsigned __bitwise xa_tag_t;
+#define XA_TAG_0	((__force xa_tag_t)0U)
+#define XA_TAG_1	((__force xa_tag_t)1U)
+#define XA_TAG_2	((__force xa_tag_t)2U)
+
+#define XA_TAG_MAX	XA_TAG_2
+#define XA_FREE_TAG	XA_TAG_0
+
+/*
+ * The vast majority of users have a constant tag, so the compiler can
+ * optimise this away.
+ */
+static inline bool xa_bad_tag(xa_tag_t tag)
+{
+	return (WARN_ON_ONCE((__force unsigned)tag >
+				(__force unsigned)XA_TAG_MAX));
+}
+
+/**
+ * xa_tagged() - Inquire whether any entry in this array has a tag set
+ * @xa: Array
+ * @tag: Tag value
+ *
+ * Return: True if any entry has this tag set, false if no entry does.
+ */
+static inline bool xa_tagged(const struct xarray *xa, xa_tag_t tag)
+{
+	if (xa_bad_tag(tag))
+		return false;
+	return xa->xa_flags & (1 << (__force unsigned)tag);
+}
+
+bool __xa_get_tag(struct xarray *, unsigned long index, xa_tag_t);
+void *__xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
+void *__xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
+
+#define xa_get_tag(xa, index, tag) \
+	(!xa_bad_tag(tag) && __xa_get_tag(xa, index, tag))
+#define xa_set_tag(xa, index, tag) \
+	(xa_bad_tag(tag) ? ERR_PTR(-EINVAL) : __xa_set_tag(xa, index, tag))
+#define xa_clear_tag(xa, index, tag) \
+	(xa_bad_tag(tag) ? ERR_PTR(-EINVAL) : __xa_clear_tag(xa, index, tag))
+
+int xa_get_entries(struct xarray *, unsigned long start, void **dst,
+		unsigned int n);
+int xa_get_tagged(struct xarray *, unsigned long start, void **dst,
+		unsigned int n, xa_tag_t);
+
+/**
+ * xa_empty() - Determine if an array has any present entries
+ * @xa: Array
+ *
+ * Return: True if the array has no entries in it.
+ */
+static inline bool xa_empty(const struct xarray *xa)
+{
+	return xa->xa_head == NULL;
+}
+
+void *xa_find(struct xarray *xa, unsigned long *index, unsigned long max);
+void *xa_next(struct xarray *xa, unsigned long *index, unsigned long max);
+
+/**
+ * xa_for_each() - Iterate over a portion of an array
+ * @xa: Array
+ * @entry: Pointer retrieved from array
+ * @index: Index of pointer retrieved from the array
+ * @max: Maximum index to retrieve from array
+ *
+ * Initialise @index to the minimum index you want to retrieve from
+ * the array.  During the iteration, @entry will have the value of the
+ * pointer stored in @xa at @index.  The iteration will skip all NULL
+ * pointers in the array.  You may modify @index during the
+ * iteration if you want to skip indices.  It is safe to modify the
+ * array during the iteration.  At the end of the iteration, @entry will
+ * be set to NULL and @index will have a value less than or equal to max.
+ *
+ * xa_for_each() is O(n.log(n)) while xas_for_each() is O(n).  You have
+ * to handle your own locking with xas_for_each(), and if you have to unlock
+ * after each iteration, it will also end up being O(n.log(n)).
+ */
+#define xa_for_each(xa, entry, index, max) \
+	for (entry = xa_find(xa, &index, max); entry; \
+	     entry = xa_next(xa, &index, max))
+
+/**
+ * xa_mk_exceptional() - Create an exceptional entry
+ * @v: value to store in exceptional entry
+ */
+static inline void *xa_mk_exceptional(unsigned long v)
+{
+	WARN_ON(v > LONG_MAX);
+	return (void *)((v << 1) | 1);
+}
+
+/**
+ * xa_exceptional_value() - Get value stored in an exceptional entry
+ * @entry: Value stored in xarray
+ */
+static inline unsigned long xa_exceptional_value(void *entry)
+{
+	return (unsigned long)entry >> 1;
+}
+
+/**
+ * xa_is_exceptional() - Determine if an entry is exceptional
+ * @entry: Value stored in xarray
+ *
+ * Return: True if the entry is exceptional
+ */
+static inline bool xa_is_exceptional(void *entry)
+{
+	return (unsigned long)entry & 1;
+}
+
+/* Everything below here is the Advanced API.  Proceed with caution. */
+
+#ifdef XA_DEBUG
+#define XA_BUG_ON(x) BUG_ON(x)
+#else
+#define XA_BUG_ON(x)
+#endif
+
+/* XXX: unused */
+typedef unsigned __bitwise xa_tags_t;
+
+#define xa_trylock(xa)		spin_trylock(&(xa)->xa_lock)
+#define xa_lock(xa)		spin_lock(&(xa)->xa_lock)
+#define xa_unlock(xa)		spin_unlock(&(xa)->xa_lock)
+#define xa_lock_irq(xa)		spin_lock_irq(&(xa)->xa_lock)
+#define xa_unlock_irq(xa)	spin_unlock_irq(&(xa)->xa_lock)
+#define xa_lock_irqsave(xa, flags) \
+				spin_lock_irqsave(&(xa)->xa_lock, flags)
+#define xa_unlock_irqrestore(xa, flags) \
+				spin_unlock_irqrestore(&(xa)->xa_lock, flags)
+
+/*
+ * The xarray is constructed out of a set of 'chunks' of pointers.  Choosing
+ * the best chunk size requires some tradeoffs.  A power of two recommends
+ * itself so that we can arrange the chunks into a tree and navigate based
+ * purely on shifts and masks.  Generally, the larger the better; as the
+ * number of slots per level of the tree increases, the less tall the tree
+ * needs to be.  But that needs to be balanced against the memory consumption
+ * of each node.  On a 64-bit system, xa_node is currently 576 bytes, and we
+ * get 7 of them per 4kB page.  If we doubled the number of slots per node,
+ * we'd get only 3 nodes per 4kB page.
+ */
+#define XA_CHUNK_SHIFT		6
+#define XA_CHUNK_SIZE		(1 << XA_CHUNK_SHIFT)
+#define XA_CHUNK_MASK		(XA_CHUNK_SIZE - 1)
+#define XA_MAX_TAGS		3
+#define XA_TAG_LONGS 		(XA_CHUNK_SIZE / BITS_PER_LONG)
+#define XA_PREALLOC_COUNT	((BITS_PER_LONG / XA_CHUNK_SHIFT) * 2 + 1)
+
+/**
+ * struct xa_node - A node in the xarray
+ * @offset: This chunk's offset in its parent's slots array.
+ * @max: The number of slots in this node (head node only).
+ * @shift: The number of bits represented by each entry in the slots array.
+ * @count: The number of non-empty slots.
+ * @exceptional: The number of slots deemed 'exceptional'.
+ * @parent: NULL for the head node, otherwise the node closer to the head.
+ * @array: The xarray this node belongs to.
+ * @private_list: A list head for the use of the array user (very advanced)
+ * @rcu_head: Used to delay freeing nodes
+ * @tags: Bitmap of additional information about each slot
+ * @slots: Array of entries
+ *
+ * The xarray is constructed out of nodes which are arranged into a tree-like
+ * structure.  The node does not know the indices of the entries contained
+ * within it; that is inferred by its position in the tree.  At each level,
+ * we use the next XA_CHUNK_SHIFT bits of the index to determine which entry
+ * to look at in the slots array.
+ */
+struct xa_node {
+	union {
+		unsigned char offset;
+		unsigned char max;
+	};
+	unsigned char shift;
+	unsigned char count;
+	unsigned char exceptional;
+	struct xa_node __rcu *parent;
+	struct xarray *array;
+	union {
+		struct list_head private_list;
+		struct rcu_head rcu_head;
+	};
+	unsigned long tags[XA_MAX_TAGS][XA_TAG_LONGS];
+	void __rcu *slots[XA_CHUNK_SIZE];
+};
+
+/*
+ * Entries in the xa_node slots array have three possible types:
+ * 1. Kernel pointers.  These have the bottom two bits clear.
+ * 2. Exceptional entries.  These have the bottom bit set.
+ * 3. Internal entries.  These have the bottom two bits equal to 10b.
+ *
+ * Internal entries can only be observed if you're using the advanced
+ * API; the normal API will not expose them to the user.
+ *
+ * There are six subtypes of internal entries:
+ * 3a. Node entry.  This entry points to a node closer to the edge.
+ * 3b. Retry entry.  This indicates that the entry you're looking for is
+ *     in the array, but it's been moved to a different node.  Retry your
+ *     lookup from the head of the array.
+ * 3c. Sibling entry.  This indicates that the entry you're looking for
+ *     is stored in a different slot in the same node.
+ * 3d. Cousin entry.  This indicates that the entry you're looking for
+ *     is stored in a slot in a different node. (not yet implemented)
+ * 3e. IDR NULL entry.  The IDR distinguishes between allocated NULL pointers
+ *     and free entries.  The easiest way to support this in the xarray is to
+ *     substitute an internal entry for the NULL pointer.
+ * 3f. Walk End entry.  This entry is never found in the array.  It is
+ *     returned by iteration functions to signal that the iteration has
+ *     finished.
+ *
+ * The head of the array never contains a retry, sibling or cousin entry;
+ * these entries can only be found in array nodes.
+ */
+
+static inline void *xa_mk_internal(unsigned long v)
+{
+	return (void *)((v << 2) | 2);
+}
+
+static inline unsigned long xa_internal_value(void *entry)
+{
+	return (unsigned long)entry >> 2;
+}
+
+static inline bool xa_is_internal(void *entry)
+{
+	return ((unsigned long)entry & 3) == 2;
+}
+
+static inline void *xa_mk_node(struct xa_node *node)
+{
+	return (void *)((unsigned long)node | 2);
+}
+
+static inline struct xa_node *xa_node(void *entry)
+{
+	return (struct xa_node *)((unsigned long)entry & ~3UL);
+}
+
+static inline bool xa_is_node(void *entry)
+{
+	return xa_is_internal(entry) && (unsigned long)entry > 4096;
+}
+
+static inline void *xa_mk_sibling(unsigned int offset)
+{
+	return xa_mk_internal(offset);
+}
+
+static inline unsigned long xa_sibling_offset(void *entry)
+{
+	return xa_internal_value(entry);
+}
+
+static inline bool xa_is_sibling(void *entry)
+{
+	return xa_is_internal(entry) && xa_sibling_offset(entry) < 256;
+}
+
+static inline void *xa_mk_cousin(unsigned long offset)
+{
+	return xa_mk_internal(offset + 256);
+}
+
+static inline unsigned long xa_cousin_offset(void *entry)
+{
+	return xa_internal_value(entry) - 256;
+}
+
+static inline bool xa_is_cousin(void *entry)
+{
+	return xa_is_internal(entry) && xa_cousin_offset(entry) < 256;
+}
+
+static inline bool xa_is_relative(void *entry)
+{
+	return xa_is_internal(entry) && xa_internal_value(entry) < 512;
+}
+
+/*
+ * Values 0-255 are reserved for sibling entries (0-62 actually used)
+ * Values 256-511 are reserved for cousin entries (0-62, 64 actually used)
+ * 515-1023 are available for use before we start packing siblings & cousins
+ * closer together.
+ */
+#define XA_IDR_NULL		xa_mk_internal(512)
+#define XA_RETRY_ENTRY		xa_mk_internal(513)
+#define XA_WALK_END		xa_mk_internal(514)
+
+static inline bool xa_is_idr_null(void *entry)
+{
+	return entry == XA_IDR_NULL;
+}
+
+/* When we're iterating, we want to skip siblings, cousins and NULLs */
+static inline bool xa_is_skip(void *entry)
+{
+	return unlikely(!entry ||
+			(xa_is_internal(entry) && entry < XA_RETRY_ENTRY));
+}
+
+static inline bool xa_is_retry(void *entry)
+{
+	return unlikely(entry == XA_RETRY_ENTRY);
+}
+
+static inline bool xa_track_free(struct xarray *xa)
+{
+	return xa->xa_flags & XA_FLAG_TRACK_FREE;
+}
+
+static inline void *xa_head(struct xarray *xa)
+{
+	return rcu_dereference_check(xa->xa_head,
+					lockdep_is_held(&xa->xa_lock));
+}
+
+static inline void *xa_head_locked(struct xarray *xa)
+{
+	return rcu_dereference_protected(xa->xa_head,
+					lockdep_is_held(&xa->xa_lock));
+}
+
+static inline void *xa_entry(struct xarray *xa,
+		const struct xa_node *node, unsigned int offset)
+{
+	XA_BUG_ON(offset >= XA_CHUNK_SIZE);
+	return rcu_dereference_check(node->slots[offset],
+					lockdep_is_held(&xa->xa_lock));
+}
+
+static inline void *xa_entry_locked(struct xarray *xa,
+		const struct xa_node *node, unsigned int offset)
+{
+	XA_BUG_ON(offset >= XA_CHUNK_SIZE);
+	return rcu_dereference_protected(node->slots[offset],
+					lockdep_is_held(&xa->xa_lock));
+}
+
+static inline struct xa_node *xa_parent(struct xarray *xa,
+		const struct xa_node *node)
+{
+	return rcu_dereference_check(node->parent,
+					lockdep_is_held(&xa->xa_lock));
+}
+
+static inline struct xa_node *xa_parent_locked(struct xarray *xa,
+		const struct xa_node *node)
+{
+	return rcu_dereference_protected(node->parent,
+					lockdep_is_held(&xa->xa_lock));
+}
+
+static inline void *xa_deref_locked(struct xarray *xa, void __rcu **slot)
+{
+	return rcu_dereference_protected(*slot, lockdep_is_held(&xa->xa_lock));
+}
+
+typedef void (*xa_update_node_t)(struct xa_node *);
+
+/**
+ * xa_state - XArray operation state
+ * @xa_index: The index which this operation is currently about.
+ * @xa_shift: The shift of the node containing the entry we're interested in.
+ * @xa_slots: The number of slots occupied by that entry in that node.
+ * @xa_flags: Flags, see below
+ * @xa_offset: This entry's offset within the chunk of slots.
+ * @xa_node: The node containing this entry, or NULL if the entry is at
+ *	     xa_head, or XA_WALK_RESTART to start walking through the array
+ *	     from the head, or an IS_ERR pointer if an error occurred.
+ * @xa_alloc: One preallocated node.
+ * @xa_count: Number of entries added/deleted so far during this operation.
+ * @xa_exceptional: Number of exceptional entries added/deleted.
+ * @xa_update: Callback when updating a node.
+ *
+ * Some of this state may seem redundant, but some of it is input state and
+ * some is output state.  For example, xa_shift is not equal to xa_node->shift
+ * until we have walked through the array to the correct xa_node.
+ */
+struct xa_state {
+	unsigned long xa_index;
+	unsigned char xa_shift;
+	unsigned char xa_slots;
+	unsigned char xa_offset;
+	unsigned char xa_flags;
+	struct xa_node *xa_node;
+	struct xa_node *xa_alloc;
+	long xa_count;
+	long xa_exceptional;
+	xa_update_node_t xa_update;
+};
+
+/*
+ * XAS_FLAG_LOOKUP - Find this index.  If clear, it means we're searching for
+ * the next index.  This only makes a difference if we see a multislot entry;
+ * if set, we move backwards to return the entry.  If clear, we move forwards
+ * and find the next entry.
+ */
+#define XAS_FLAG_LOOKUP	1
+
+/*
+ * These are not array entries.  They are found only in xas->xa_node.
+ * Once we set an error, we have to drop the xa_lock to remedy it, so we
+ * must restart the walk from the head of the xarray.
+ */
+#define XAS_ERROR(errno)	((struct xa_node *)((errno << 1) | 1))
+#define XA_WALK_RESTART		XAS_ERROR(0)
+
+/* Special -- error-or-restart */
+static inline bool xas_special(const struct xa_state *xas)
+{
+	return (unsigned long)xas->xa_node & 1;
+}
+
+static inline int xas_error(const struct xa_state *xas)
+{
+	unsigned long v = (unsigned long)xas->xa_node;
+	return (v & 1) ? -(v >> 1) : 0;
+}
+
+static inline void xas_set_err(struct xa_state *xas, unsigned long err)
+{
+	XA_BUG_ON(err > MAX_ERRNO);
+	xas->xa_node = XAS_ERROR(err);
+}
+
+static inline bool xas_restart(const struct xa_state *xas)
+{
+	return unlikely(xas->xa_node == XA_WALK_RESTART);
+}
+
+static inline bool xas_retry(struct xa_state *xas, void *entry)
+{
+	if (!xa_is_retry(entry))
+		return false;
+	xas->xa_flags |= XAS_FLAG_LOOKUP;
+	xas->xa_node = XA_WALK_RESTART;
+	return true;
+}
+
+static inline void xas_pause(struct xa_state *xas)
+{
+	xas->xa_node = XA_WALK_RESTART;
+}
+
+static inline void xas_jump(struct xa_state *xas, unsigned long index)
+{
+	xas->xa_index = index;
+	xas->xa_flags |= XAS_FLAG_LOOKUP;
+	xas->xa_node = XA_WALK_RESTART;
+}
+
+void xas_init_range(struct xa_state *, unsigned long index,
+		unsigned char shift, unsigned char slots);
+void xas_destroy(struct xa_state *);
+bool xas_nomem(struct xa_state *, gfp_t);
+
+void *xas_load(struct xarray *, struct xa_state *);
+void *xas_store(struct xarray *, struct xa_state *, void *entry);
+void *xas_create(struct xarray *, struct xa_state *);
+int xas_split(struct xarray *, struct xa_state *, unsigned int order);
+
+bool xas_get_tag(const struct xarray *, const struct xa_state *, xa_tag_t);
+void xas_set_tag(struct xarray *, const struct xa_state *, xa_tag_t);
+void xas_clear_tag(struct xarray *, const struct xa_state *, xa_tag_t);
+void xas_init_tags(struct xarray *, const struct xa_state *);
+void *xas_find_tag(struct xarray *, struct xa_state *, unsigned long max,
+		xa_tag_t);
+
+void *xas_next_entry(struct xarray *, struct xa_state *, unsigned long max);
+void *__xas_next_slot(struct xarray *, struct xa_state *, unsigned long max);
+void *__xas_prev_slot(struct xarray *, struct xa_state *, unsigned long min);
+void *__xas_store(struct xarray *, struct xa_state *, void *entry);
+void *__xas_split(struct xarray *, struct xa_state *, void *entry);
+
+/*
+ * xas_init() - Set up xarray operation state
+ * @xas: Array operation state.
+ * @index: Target of the operation.
+ */
+static inline void xas_init(struct xa_state *xas, unsigned long index)
+{
+	xas_init_range(xas, index, 0, 1);
+}
+
+/**
+ * xas_init_order() - Set up xarray operation state for a multislot entry
+ * @xas: Array operation state.
+ * @index: Target of the operation.
+ * @order: Entry occupies 2^@order indices.
+ */
+static inline void xas_init_order(struct xa_state *xas, unsigned long index,
+		unsigned int order)
+{
+	unsigned char shift = order - (order % XA_CHUNK_SHIFT);
+	unsigned char slots = 1 << (order % XA_CHUNK_SHIFT);
+
+	index = ((index >> shift) & ~(slots - 1UL)) << shift;
+	xas_init_range(xas, index, shift, slots);
+}
+
+static inline void *xas_next(struct xarray *xa, struct xa_state *xas,
+		unsigned long max)
+{
+	struct xa_node *node = xas->xa_node;
+	void *entry;
+
+	if (unlikely(!node || (unsigned long)node & 1) || node->shift)
+		return xas_next_entry(xa, xas, max);
+
+	do {
+		xas->xa_index++;
+		if (unlikely(xas->xa_index > max))
+			return XA_WALK_END;
+		if (unlikely(++xas->xa_offset == XA_CHUNK_SIZE))
+			return xas_next_entry(xa, xas, max);
+		entry = xa_entry(xa, node, xas->xa_offset);
+	} while (xa_is_skip(entry));
+
+	return entry;
+}
+
+/* FIXME: optimise for 32-bit machines as well */
+static inline unsigned int xas_chunk_tag(const struct xa_state *xas,
+		xa_tag_t tag)
+{
+	unsigned long *addr = xas->xa_node->tags[(__force unsigned)tag];
+
+	if (xas->xa_offset >= XA_CHUNK_SIZE)
+		return XA_CHUNK_SIZE;
+	if (XA_CHUNK_SIZE == BITS_PER_LONG) {
+		unsigned long data = *addr & (~0UL << xas->xa_offset);
+		if (data)
+			return __ffs(data);
+		return XA_CHUNK_SIZE;
+	}
+
+	return find_next_bit(addr, XA_CHUNK_SIZE, xas->xa_offset);
+}
+
+static inline void *xas_next_tag(struct xarray *xa, struct xa_state *xas,
+		unsigned long max, xa_tag_t tag)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset;
+
+	if (unlikely(!node || (unsigned long)node & 1))
+		return xas_find_tag(xa, xas, max, tag);
+
+	xas->xa_offset++;
+	xas->xa_index = (xas->xa_index | ((1UL << node->shift) - 1)) + 1;
+	if (unlikely(xas->xa_index > max))
+		return XA_WALK_END;
+	offset = xas_chunk_tag(xas, tag);
+	if (offset == XA_CHUNK_SIZE)
+		return xas_find_tag(xa, xas, max, tag);
+	if (offset != xas->xa_offset) {
+		xas->xa_index += (offset - xas->xa_offset) << node->shift;
+		xas->xa_offset = offset;
+		if (unlikely(xas->xa_index > max))
+			return XA_WALK_END;
+	}
+
+	return xa_entry(xa, node, offset);
+}
+
+static inline void *xas_next_slot(struct xarray *xa, struct xa_state *xas,
+		unsigned long max)
+{
+	struct xa_node *node = xas->xa_node;
+
+	if (unlikely(!node || (unsigned long)node & 1) || node->shift)
+		return __xas_next_slot(xa, xas, max);
+
+	xas->xa_index++;
+	if (unlikely(xas->xa_index > max))
+		return XA_WALK_END;
+	if (unlikely(++xas->xa_offset == XA_CHUNK_SIZE))
+		return __xas_next_slot(xa, xas, max);
+	return xa_entry(xa, node, xas->xa_offset);
+}
+
+static inline void *xas_prev_slot(struct xarray *xa, struct xa_state *xas,
+		unsigned long min)
+{
+	struct xa_node *node = xas->xa_node;
+
+	if (unlikely(!node || (unsigned long)node & 1) || node->shift)
+		return __xas_prev_slot(xa, xas, min);
+
+	xas->xa_index--;
+	if (unlikely(xas->xa_index < min))
+		return XA_WALK_END;
+	if (unlikely(xas->xa_offset == 0))
+		return __xas_prev_slot(xa, xas, min);
+	xas->xa_offset--;
+	return xa_entry(xa, node, xas->xa_offset);
+}
+
+/**
+ * xas_for_each() - Iterate over all present entries in this range
+ * @xa: Array
+ * @xas: Array operation state
+ * @entry: Pointer to use for iteration
+ * @max: Highest index to return
+ *
+ * The loop body will be invoked for each entry present in the xarray
+ * between the current xas position and @max.  @entry will be set to
+ * the entry retrieved from the xarray.  It is safe to delete entries
+ * from the array in the loop body.
+ */
+#define xas_for_each(xa, xas, entry, max) \
+	for (entry = xas_next(xa, xas, max); \
+	     entry != XA_WALK_END; \
+	     entry = xas_next(xa, xas, max))
+
+/**
+ * xas_for_each_slot() - Iterate over all slots in this range
+ * @xa: Array
+ * @xas: Array operation state
+ * @entry: Pointer to use for iteration
+ * @max: Highest index to return
+ *
+ * The loop body will be executed for each allocated slot in the xarray
+ * between the current xas position and @max.  @entry will be set to
+ * the entry retrieved from the xarray.  It is safe to delete entries
+ * from the array in the loop body.
+ */
+#define xas_for_each_slot(xa, xas, entry, max) \
+	for (entry = xas_next_slot(xa, xas, max); \
+	     entry != XA_WALK_END; \
+	     entry = xas_next_slot(xa, xas, max))
+
+/**
+ * xas_for_each_tag() - Iterate over all tagged entries in this range
+ * @xa: Array
+ * @xas: Array operation state
+ * @entry: Pointer to use for iteration
+ * @max: Highest index to return
+ *
+ * The loop body will be executed for each tagged entry in the xarray
+ * between the current xas position and @max.  @entry will be set to
+ * the entry retrieved from the xarray.  It is safe to delete entries
+ * from the array in the loop body.
+ */
+#define xas_for_each_tag(xa, xas, entry, max, tag) \
+	for (entry = xas_next_tag(xa, xas, max, tag); \
+	     entry != XA_WALK_END; \
+	     entry = xas_next_tag(xa, xas, max, tag))
+
+/**
+ * xas_for_each_slot_rev() - Iterate over all slots in this range backwards
+ * @xa: Array
+ * @xas: Array operation state
+ * @entry: Pointer to use for iteration
+ * @min: Lowest index to return
+ *
+ * The loop body will be executed for each allocated slot in the xarray
+ * between the current xas position and @min.  @entry will be set to
+ * the entry retrieved from the xarray.  It is safe to delete entries
+ * from the array in the loop body.
+ */
+#define xas_for_each_slot_rev(xa, xas, entry, min) \
+	for (entry = xas_prev_slot(xa, xas, min); \
+	     entry != XA_WALK_END; \
+	     entry = xas_prev_slot(xa, xas, min))
+
+/**
+ * xas_store_for_each() - Iterate over all entries, then replace them
+ * @xa: Array
+ * @xas: Array operation state
+ * @entry: Pointer to use for iteration
+ * @index: Index to store new entry at
+ * @order: Order of new entry
+ * @new: New entry
+ *
+ * The loop body will be executed for each entry present in the range
+ * specified by @index and @order.  After all entries have been processed,
+ * the @new entry will be atomically stored in the xarray.
+ * RCU readers may temporarily see retry entries.  If you break out of the
+ * loop, no modifications will have been made to the xarray.
+ */
+#define xas_store_for_each(xa, xas, entry, new) \
+	for (entry = __xas_store(xa, xas, new); \
+	     entry != XA_WALK_END; \
+	     entry = __xas_store(xa, xas, new))
+
+/**
+ * xas_split_for_each() - Create new entries to replace a multislot entry
+ * @xa: Array
+ * @xas: Array operation state
+ * @entry: Pointer to use for iteration
+ *
+ * The loop body will be executed for each new entry present in the range
+ * specified by @index and @order.  The loop will see the index of the new
+ * entry in @xas->xa_index.  It should call xas_store() to set up each new
+ * entry.  After the loop has successfully terminated, the new entries will
+ * be atomically stored in the xarray.  RCU readers may temporarily see
+ * retry entries.  If you break out of the loop, no modifications will have
+ * been made to the xarray and the temporary memory allocation will be freed
+ * by xas_destroy().
+ */
+#define xas_split_for_each(xa, xas, entry) \
+	for (entry = __xas_split(xa, xas, entry); \
+	     entry != XA_WALK_END; \
+	     entry = __xas_split(xa, xas, entry))
+
+/* Really advanced. */
+extern struct kmem_cache *xa_node_cache;
+
+extern void init_xarray(void);
+#endif /* _LINUX_XARRAY_H */
diff --git a/lib/Makefile b/lib/Makefile
index 320ac46a..ab3c590 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -17,7 +17,7 @@ KCOV_INSTRUMENT_debugobjects.o := n
 KCOV_INSTRUMENT_dynamic_debug.o := n
 
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
-	 rbtree.o radix-tree.o dump_stack.o timerqueue.o\
+	 xarray.o rbtree.o radix-tree.o dump_stack.o timerqueue.o\
 	 idr.o int_sqrt.o extable.o \
 	 sha1.o chacha20.o md5.o irq_regs.o argv_split.o \
 	 flex_proportions.o ratelimit.o show_mem.o \
@@ -27,6 +27,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
 
 CFLAGS_radix-tree.o += -DCONFIG_SPARSE_RCU_POINTER
 CFLAGS_idr.o += -DCONFIG_SPARSE_RCU_POINTER
+CFLAGS_xarray.o += -DCONFIG_SPARSE_RCU_POINTER
 
 lib-$(CONFIG_MMU) += ioremap.o
 lib-$(CONFIG_SMP) += cpumask.o
diff --git a/lib/xarray.c b/lib/xarray.c
new file mode 100644
index 0000000..01f7972
--- /dev/null
+++ b/lib/xarray.c
@@ -0,0 +1,1343 @@
+#include <linux/bitmap.h>
+#include <linux/bitops.h>
+#include <linux/export.h>
+#include <linux/gfp.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/rcupdate.h>
+#include <linux/slab.h>
+#include <linux/xarray.h>
+
+#ifdef XA_DEBUG
+#define XA_BUG_ON(x) BUG_ON(x)
+#else
+#define XA_BUG_ON(x)
+#endif
+
+/*
+ * Coding conventions in this file:
+ *
+ * @xa is used to refer to the entire xarray.
+ * @xas is the 'xarray operation state'.  It may be either a pointer to
+ * an xa_state, or an xa_state stored on the stack.  This is an unfortunate
+ * ambiguity.
+ * @index is the index of the entry being operated on
+ * @tag is an xa_tag_t; a small number indicating one of the tag bits.
+ * @node refers to an xa_node; usually the primary one being operated on by
+ * this function.
+ * @offset is the index into the slots array inside an xa_node.
+ * @parent refers to the @xa_node closer to the head than @node.
+ * @entry refers to something stored in a slot in the xarray
+ */
+#define inc_tag(tag) do { \
+	tag = (__force xa_tag_t)((__force unsigned)(tag) + 1); \
+} while (0)
+
+static inline void xa_tag_set(struct xarray *xa, xa_tag_t tag)
+{
+	if (!(xa->xa_flags & (1 << (__force unsigned)tag)))
+		xa->xa_flags |= (1 << (__force unsigned)tag);
+}
+
+static inline void xa_tag_clear(struct xarray *xa, xa_tag_t tag)
+{
+	if (xa->xa_flags & (1 << (__force unsigned)tag))
+		xa->xa_flags &= ~(1 << (__force unsigned)tag);
+}
+
+static inline bool tag_get(const struct xa_node *node, unsigned int offset,
+		xa_tag_t tag)
+{
+	return test_bit(offset, node->tags[(__force unsigned)tag]);
+}
+
+static inline void tag_set(struct xa_node *node, unsigned int offset,
+		xa_tag_t tag)
+{
+	__set_bit(offset, node->tags[(__force unsigned)tag]);
+}
+
+static inline void tag_clear(struct xa_node *node, unsigned int offset,
+		xa_tag_t tag)
+{
+	__clear_bit(offset, node->tags[(__force unsigned)tag]);
+}
+
+static inline void tag_set_all(struct xa_node *node, xa_tag_t tag)
+{
+	bitmap_fill(node->tags[(__force unsigned)tag], XA_CHUNK_SIZE);
+}
+
+static inline bool tag_any_set(struct xa_node *node, xa_tag_t tag)
+{
+	return !bitmap_empty(node->tags[(__force unsigned)tag], XA_CHUNK_SIZE);
+}
+
+/*
+ * Use this to calculate the maximum index that will need to be created
+ * in order to add the entry described by @xas.  Because we cannot store a
+ * multiple-slot entry at index 0, the calculation is a little more complex
+ * than you might expect.
+ */
+static unsigned long xas_max(struct xa_state *xas)
+{
+	unsigned long mask, max = xas->xa_index;
+
+	if (xas->xa_shift || xas->xa_slots > 1) {
+		mask = ((xas->xa_slots << xas->xa_shift) - 1);
+		max |= mask;
+		if (mask == max)
+			max++;
+	}
+	return max;
+}
+
+static unsigned long set_index(struct xa_node *node, unsigned int offset,
+		unsigned long index)
+{
+	unsigned long mask = ((unsigned long)XA_CHUNK_SIZE << node->shift) - 1;
+
+	return (index & ~mask) + ((unsigned long)offset << node->shift);
+}
+
+/* XXX: kill? */
+static unsigned int node_offset(struct xa_node *node, unsigned long index)
+{
+	return (index >> node->shift) & XA_CHUNK_MASK;
+}
+
+static unsigned long xas_offset(struct xa_state *xas)
+{
+	return (xas->xa_index >> xas->xa_node->shift) & XA_CHUNK_MASK;
+}
+
+/* Returns true if @head can contain @index */
+static bool xa_bounds(unsigned long index, void *head)
+{
+	struct xa_node *node;
+	unsigned int max;
+
+	if (!xa_is_node(head))
+		return index == 0;
+	node = xa_node(head);
+	max = node->max;
+	if (max == 0)
+		max = 63;
+	return (index >> node->shift) <= max;
+}
+
+/*
+ * (re)starts a walk.  If we've already walked the @xas to the correct
+ * slot, or somewhere on the path to the correct slot, returns the entry.
+ * If we're in an error state, returns NULL.  If we're in a retry state,
+ * returns XA_WALK_END if the index is outside the current limits of the
+ * xarray.  If we're looking for a multiorder entry that is larger than
+ * the current size of the array, set xa_node to NULL and return the current
+ * head of the array.  Otherwise, set xa_node to the node stored in the head
+ * of the array, xa_offset to the position within that node to look for the
+ * next level of this index, and return the entry stored in the head of the
+ * array.
+ */
+static void *xas_start(struct xarray *xa, struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_node;
+	void *entry;
+	unsigned long offset;
+
+	if (!xas_restart(xas)) {
+		if (xas_error(xas))
+			return NULL;
+		else if (node)
+			return xa_entry(xa, xas->xa_node, xas->xa_offset);
+		else
+			return xa_head(xa);
+	}
+
+	entry = xa_head(xa);
+	if (!xa_is_node(entry)) {
+		if (xas->xa_index)
+			return XA_WALK_END;
+		xas->xa_node = NULL;
+		return entry;
+	}
+
+	node = xa_node(entry);
+	if (xas->xa_shift > node->shift) {
+		xas->xa_node = NULL;
+		return entry;
+	}
+
+	offset = xas->xa_index >> node->shift;
+	if (offset > XA_CHUNK_MASK)
+		return XA_WALK_END;
+
+	xas->xa_node = node;
+	xas->xa_offset = offset;
+	return entry;
+}
+
+/**
+ * xas_init_range() - Initialise xarray operation state for a multislot entry
+ * @xas: Array operation state.
+ * @index: Eventual target of the operation.
+ * @shift: Shift of the node this will occupy
+ * @slots: Number of slots in that node to occupy
+ */
+void xas_init_range(struct xa_state *xas, unsigned long index,
+		unsigned char shift, unsigned char slots)
+{
+	xas->xa_index = index;
+	xas->xa_shift = shift;
+	xas->xa_slots = slots;
+	xas->xa_offset = 0;
+	xas->xa_flags = XAS_FLAG_LOOKUP;
+	xas->xa_node = XA_WALK_RESTART;
+	xas->xa_alloc = NULL;
+	xas->xa_count = 0;
+	xas->xa_exceptional = 0;
+	xas->xa_update = NULL;
+}
+EXPORT_SYMBOL_GPL(xas_init_range);
+
+struct kmem_cache *xa_node_cache;
+
+static void xa_node_ctor(void *p)
+{
+	struct xa_node *node = p;
+
+	memset(&node->tags, 0, sizeof(node->tags));
+	memset(&node->slots, 0, sizeof(node->slots));
+	INIT_LIST_HEAD(&node->private_list);
+}
+
+static void xa_node_rcu_free(struct rcu_head *head)
+{
+	struct xa_node *node = container_of(head, struct xa_node, rcu_head);
+
+	xa_node_ctor(node);
+	kmem_cache_free(xa_node_cache, node);
+}
+
+static void xa_node_free(struct xa_node *node)
+{
+	call_rcu(&node->rcu_head, xa_node_rcu_free);
+}
+
+/**
+ * xas_destroy() - Dispose of any resources used during the xarray operation
+ * @xas: Array operation state.
+ *
+ * If the operation only involved read accesses to the XArray or modifying
+ * existing data in the XArray, there is no need to call this function
+ * (eg xa_set_tag()).  However, if you may have allocated memory (for
+ * example by calling xas_nomem()), then call this function.
+ *
+ * This function does not reinitialise the state, so you may continue to
+ * call xas_error(), and you would want to call xas_init() before reusing
+ * this structure.  It only releases any resources.
+ */
+void xas_destroy(struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_alloc;
+
+	if (!node)
+		return;
+#if 0
+	while (node->count)
+		kmem_cache_free(xa_node_cache, node->slots[node->count - 1]);
+#endif
+	kmem_cache_free(xa_node_cache, node);
+	xas->xa_alloc = NULL;
+}
+EXPORT_SYMBOL_GPL(xas_destroy);
+
+/**
+ * xas_nomem() - Allocate memory if needed
+ * @xas: Array operation state.
+ * @gfp: Memory allocation flags
+ *
+ * If we need to add new nodes to the xarray, we try to allocate memory
+ * with GFP_NOWAIT while holding the lock, which will usually succeed.
+ * If it fails, @xas is flagged as needing memory to continue.  The caller
+ * should drop the lock and call xas_nomem().  If xas_nomem() succeeds,
+ * the caller should retry the operation.
+ *
+ * Forward progress is guaranteed as one node is allocated here and is
+ * available to the memory allocators.
+ *
+ * Return: true if memory was needed, and was successfully allocated.
+ */
+bool xas_nomem(struct xa_state *xas, gfp_t gfp)
+{
+	if (xas->xa_node != XAS_ERROR(ENOMEM))
+		return false;
+	xas->xa_alloc = kmem_cache_alloc(xa_node_cache, gfp);
+	if (!xas->xa_alloc)
+		return false;
+	xas->xa_node = XA_WALK_RESTART;
+	return true;
+}
+EXPORT_SYMBOL_GPL(xas_nomem);
+
+static void *xas_alloc(struct xarray *xa, struct xa_state *xas,
+		unsigned int shift)
+{
+	struct xa_node *parent = xas->xa_node;
+	struct xa_node *node = xas->xa_alloc;
+
+	if (xas_error(xas))
+		return NULL;
+
+	if (node) {
+		xas->xa_alloc = NULL;
+	} else {
+		node = kmem_cache_alloc(xa_node_cache,
+					GFP_NOWAIT | __GFP_NOWARN);
+		if (!node) {
+			xas_set_err(xas, ENOMEM);
+			return NULL;
+		}
+	}
+
+	if (xas->xa_node) {
+		node->offset = xas->xa_offset;
+		parent->count++;
+		XA_BUG_ON(parent->count > XA_CHUNK_SIZE);
+	} else {
+		node->max = XA_CHUNK_MASK;
+	}
+	XA_BUG_ON(shift > BITS_PER_LONG);
+	node->shift = shift;
+	node->count = 0;
+	node->exceptional = 0;
+	RCU_INIT_POINTER(node->parent, xas->xa_node);
+	node->array = xa;
+
+	return node;
+}
+
+#if 0
+static void *xas_find_cousin(const struct xarray *xa, struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset = xas->xa_offset;
+	void *entry;
+
+	while (offset == 0) {
+		offset = node->offset;
+		node = xa_parent(xa, node);
+		XA_BUG_ON(!node);
+	}
+
+	offset--;
+
+	for (;;) {
+		entry = xa_entry(xa, node, offset);
+
+		if (xa_is_sibling(entry)) {
+			offset = xa_sibling_offset(entry);
+			entry = xa_entry(xa, node, offset);
+		}
+
+		if (!xa_is_node(entry))
+			break;
+		node = xa_node(entry);
+		offset = XA_CHUNK_SIZE - 1;
+	}
+
+	xas->xa_node = node;
+	xas->xa_offset = offset;
+	return entry;
+}
+	} else if (unlikely(xa_cousin_entry(entry))) {
+		return xas_find_cousin(xa, xas);
+#endif
+
+static void *xas_descend(struct xarray *xa, struct xa_state *xas,
+		struct xa_node *node)
+{
+	unsigned int offset = node_offset(node, xas->xa_index);
+	void *entry = xa_entry(xa, node, offset);
+
+	if (xa_is_sibling(entry)) {
+		offset = xa_sibling_offset(entry);
+		entry = xa_entry(xa, node, offset);
+	}
+
+	xas->xa_node = node;
+	xas->xa_offset = offset;
+	return entry;
+}
+
+/**
+ * xas_get_tag() - Returns the state of this tag
+ * @xa: Array
+ * @xas: Array operation state.
+ * @tag: Tag value
+ *
+ * Return: true if the tag is set, false if the tag is clear or @xas
+ * is in an error state.
+ */
+bool xas_get_tag(const struct xarray *xa, const struct xa_state *xas,
+		xa_tag_t tag)
+{
+	if (xas_special(xas))
+		return false;
+	if (!xas->xa_node)
+		return xa_tagged(xa, tag);
+	return tag_get(xas->xa_node, xas->xa_offset, tag);
+}
+EXPORT_SYMBOL_GPL(xas_get_tag);
+
+/**
+ * xas_set_tag() - Sets the tag on this entry and its parents
+ * @xa: Array
+ * @xas: Array operation state.
+ * @tag: Tag value
+ *
+ * Sets the specified tag on this entry, and walks up the tree setting it
+ * on all the ancestor entries.  Does nothing if @xas has not been walked to
+ * an entry, or is in an error state.
+ */
+void xas_set_tag(struct xarray *xa, const struct xa_state *xas, xa_tag_t tag)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset = xas->xa_offset;
+
+	if (xas_special(xas))
+		return;
+
+	while (node) {
+		if (tag_get(node, offset, tag))
+			return;
+		tag_set(node, offset, tag);
+		offset = node->offset;
+		node = xa_parent(xa, node);
+	}
+
+	if (!xa_tagged(xa, tag))
+		xa_tag_set(xa, tag);
+}
+EXPORT_SYMBOL_GPL(xas_set_tag);
+
+/**
+ * xas_clear_tag() - Clears the tag on this entry and its parents
+ * @xa: Array
+ * @xas: Array operation state.
+ * @tag: Tag value
+ *
+ * Clears the specified tag on this entry, and walks back to the head
+ * attempting to clear it on all the ancestor entries.  A tag may only be
+ * cleared on an ancestor entry if none of its children have that tag set.
+ */
+void xas_clear_tag(struct xarray *xa, const struct xa_state *xas, xa_tag_t tag)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset = xas->xa_offset;
+
+	if (xas_special(xas))
+		return;
+
+	while (node) {
+		if (!tag_get(node, offset, tag))
+			return;
+		tag_clear(node, offset, tag);
+		if (tag_any_set(node, tag))
+			return;
+
+		offset = node->offset;
+		node = xa_parent(xa, node);
+	}
+
+	if (xa_tagged(xa, tag))
+		xa_tag_clear(xa, tag);
+}
+EXPORT_SYMBOL_GPL(xas_clear_tag);
+
+/**
+ * xas_init_tags() - Initialise all tags for the entry
+ * @xa: Array
+ * @xas: Array operations state.
+ *
+ * Initialise all tags for the entry specified by @xas.  If we're tracking
+ * free entries with a tag, we need to set it on all entries.  All other
+ * tags are cleared.
+ *
+ * This implementation is not as efficient as it could be; we may walk
+ * up the tree multiple times.
+ */
+void xas_init_tags(struct xarray *xa, const struct xa_state *xas)
+{
+	xa_tag_t tag = 0;
+
+	if (xa_track_free(xa)) {
+		xas_set_tag(xa, xas, XA_FREE_TAG);
+		inc_tag(tag);
+	}
+	for (;;) {
+		xas_clear_tag(xa, xas, tag);
+		if (tag == XA_TAG_MAX)
+			break;
+		inc_tag(tag);
+	}
+}
+EXPORT_SYMBOL_GPL(xas_init_tags);
+
+/**
+ * xas_load() - Find the entry for the index
+ * @xa: Array.
+ * @xas: Array operation state.
+ *
+ * If the @xas is in an error state, returns NULL
+ * If it is in the RESTART_WALK state, will return XA_WALK_END if the
+ * xa_index cannot be contained in the current xarray without expanding it.
+ * If there is no entry for the index, the walk may stop at a level in the
+ * tree higher than the entry, or even at the root.
+ *
+ * Return: An entry in the tree that is not a sibling or node entry.  May be
+ * a NULL pointer, a user pointer, exceptional entry, retry entry, or an
+ * IDR_NULL.
+ */
+void *xas_load(struct xarray *xa, struct xa_state *xas)
+{
+	void *entry;
+
+	if (xas_error(xas))
+		return NULL;
+
+	entry = xas_start(xa, xas);
+	while (xa_is_node(entry)) {
+		struct xa_node *node = xa_node(entry);
+
+		if (xas->xa_shift > node->shift)
+			break;
+		entry = xas_descend(xa, xas, node);
+	}
+	return entry;
+}
+EXPORT_SYMBOL_GPL(xas_load);
+
+static void xas_shrink(struct xarray *xa, const struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_node;
+
+	for (;;) {
+		void *entry;
+
+		XA_BUG_ON(node->count > XA_CHUNK_SIZE);
+		if (node->count != 1)
+			break;
+		entry = xa_entry_locked(xa, node, 0);
+		if (!entry)
+			break;
+		if (!xa_is_node(entry) && node->shift)
+			break;
+
+		RCU_INIT_POINTER(xa->xa_head, entry);
+		if (xa_track_free(xa) && !tag_get(node, 0, XA_FREE_TAG))
+			xa_tag_clear(xa, XA_FREE_TAG);
+
+		node->count = 0;
+		node->exceptional = 0;
+		if (xa_is_node(entry))
+			RCU_INIT_POINTER(node->slots[0], XA_RETRY_ENTRY);
+		VM_WARN_ON_ONCE(!list_empty(&node->private_list));
+		xa_node_free(node);
+		if (!xa_is_node(entry))
+			break;
+		node = xa_node(entry);
+		if (xas->xa_update)
+			xas->xa_update(node);
+	}
+}
+
+/*
+ * xas_delete_node() - Attempt to delete an xa_node
+ * @xa: Array
+ * @xas: Array operation state.
+ *
+ * Attempts to delete the @xas->xa_node.  This will fail if xa->node has
+ * a non-zero reference count.
+ */
+static void xas_delete_node(struct xarray *xa, struct xa_state *xas)
+{
+	struct xa_node *node = xas->xa_node;
+
+	for (;;) {
+		struct xa_node *parent;
+
+		XA_BUG_ON(node->count > XA_CHUNK_SIZE);
+		if (node->count)
+			break;
+
+		parent = xa_parent_locked(xa, node);
+		VM_WARN_ON_ONCE(!list_empty(&node->private_list));
+		xas->xa_node = parent;
+		xas->xa_offset = node->offset;
+		xa_node_free(node);
+
+		if (!parent) {
+			xa->xa_head = NULL;
+			xas->xa_node = XA_WALK_RESTART;
+			return;
+		}
+
+		parent->slots[xas->xa_offset] = NULL;
+		parent->count--;
+		XA_BUG_ON(parent->count > XA_CHUNK_SIZE);
+		node = parent;
+		if (xas->xa_update)
+			xas->xa_update(node);
+	}
+
+	if (!node->parent)
+		xas_shrink(xa, xas);
+}
+
+/**
+ * xas_free_nodes() - Free this node and all nodes that it references
+ * @xa: Array
+ * @xas: Array operation state.
+ * @top: Node to free
+ *
+ * This node has been removed from the tree.  We must now free it and all
+ * of its subnodes.  There may be RCU walkers with references into the tree,
+ * so we must replace all entries with retry markers.
+ */
+static void xas_free_nodes(struct xarray *xa, struct xa_state *xas,
+		struct xa_node *top)
+{
+	unsigned int offset = 0;
+	struct xa_node *node = top;
+
+	for (;;) {
+		void *entry = xa_entry_locked(xa, node, offset);
+
+		if (xa_is_node(entry)) {
+			node = xa_node(entry);
+			offset = 0;
+			continue;
+		}
+		if (entry) {
+			RCU_INIT_POINTER(node->slots[offset], XA_RETRY_ENTRY);
+			if (xa_is_exceptional(entry))
+				xas->xa_exceptional--;
+			xas->xa_count--;
+		}
+		offset++;
+		while (offset == XA_CHUNK_SIZE) {
+			struct xa_node *parent = xa_parent_locked(xa, node);
+
+			offset = node->offset + 1;
+			node->count = 0;
+			node->exceptional = 0;
+			if (xas->xa_update)
+				xas->xa_update(node);
+			VM_WARN_ON_ONCE(!list_empty(&node->private_list));
+			xa_node_free(node);
+			if (node == top)
+				return;
+			node = parent;
+		}
+	}
+}
+
+/*
+ * xas_expand adds nodes to the head of the tree until it has reached
+ * sufficient height to be able to contain @xas->xa_index
+ */
+static int xas_expand(struct xarray *xa, struct xa_state *xas, void *head)
+{
+	struct xa_node *node = NULL;
+	unsigned int shift = 0;
+	unsigned long max = xas_max(xas);
+
+	if (!head) {
+		if (max == 0)
+			return 0;
+		while ((max >> shift) >= XA_CHUNK_SIZE)
+			shift += XA_CHUNK_SHIFT;
+		return shift + XA_CHUNK_SHIFT;
+	} else if (xa_is_node(head)) {
+		node = xa_node(head);
+		shift = node->shift + XA_CHUNK_SHIFT;
+	}
+	xas->xa_node = NULL;
+
+	while (!xa_bounds(max, head)) {
+		xa_tag_t tag = 0;
+
+		XA_BUG_ON(shift > BITS_PER_LONG);
+		node = xas_alloc(xa, xas, shift);
+		if (!node)
+			return -ENOMEM;
+
+		node->count = 1;
+		if (xa_is_exceptional(head))
+			node->exceptional = 1;
+		RCU_INIT_POINTER(node->slots[0], head);
+
+		/* Propagate the aggregated tag info to the new child */
+		if (xa_track_free(xa)) {
+			tag_set_all(node, XA_FREE_TAG);
+			if (!xa_tagged(xa, XA_FREE_TAG)) {
+				tag_clear(node, 0, XA_FREE_TAG);
+				xa_tag_set(xa, XA_FREE_TAG);
+			}
+			inc_tag(tag);
+		}
+		for (;;) {
+			if (xa_tagged(xa, tag))
+				tag_set(node, 0, tag);
+			if (tag == XA_TAG_MAX)
+				break;
+			inc_tag(tag);
+		}
+
+		/*
+		 * Now that the new node is fully initialised, we can add
+		 * it to the tree
+		 */
+		if (xa_is_node(head)) {
+			xa_node(head)->offset = 0;
+			rcu_assign_pointer(xa_node(head)->parent, node);
+		}
+		head = xa_mk_node(node);
+		rcu_assign_pointer(xa->xa_head, head);
+
+		shift += XA_CHUNK_SHIFT;
+	}
+
+	xas->xa_node = node;
+	return shift;
+}
+
+/**
+ * xas_create() - Create a slot to store an entry in.
+ * @xa: Array
+ * @xas: Array operation state.
+ *
+ * Most users will not need to call this function directly, as it is called
+ * by xas_store().  It is useful for doing conditional store operations
+ * (see the xa_replace() implementation for an example).
+ *
+ * Return: If the slot already existed, returns the contents of this slot.
+ * If the slot was newly created, returns NULL.  If it failed to create the
+ * slot, returns NULL and indicates the error in @xas.
+ */
+void *xas_create(struct xarray *xa, struct xa_state *xas)
+{
+	void *entry;
+	void __rcu **slot;
+	struct xa_node *node = xas->xa_node;
+	int shift;
+	unsigned int order = xas->xa_shift;
+
+	if (node == XA_WALK_RESTART) {
+		entry = xa_head_locked(xa);
+		xas->xa_node = NULL;
+		shift = xas_expand(xa, xas, entry);
+		if (shift < 0)
+			return NULL;
+		entry = xa_head_locked(xa);
+		slot = &xa->xa_head;
+	} else if (xas_error(xas)) {
+		return NULL;
+	} else if (node) {
+		unsigned int offset = xas->xa_offset;
+
+		shift = node->shift;
+		entry = xa_entry_locked(xa, node, offset);
+		slot = &node->slots[offset];
+	} else {
+		shift = 0;
+		entry = xa_head_locked(xa);
+		slot = &xa->xa_head;
+	}
+
+	while (shift > order) {
+		shift -= XA_CHUNK_SHIFT;
+		if (!entry) {
+			node = xas_alloc(xa, xas, shift);
+			if (!node)
+				break;
+			if (xa_track_free(xa))
+				tag_set_all(node, XA_FREE_TAG);
+			rcu_assign_pointer(*slot, xa_mk_node(node));
+		} else if (xa_is_node(entry)) {
+			node = xa_node(entry);
+		} else {
+			break;
+		}
+		entry = xas_descend(xa, xas, node);
+		slot = &node->slots[xas->xa_offset];
+	}
+
+	return entry;
+}
+EXPORT_SYMBOL_GPL(xas_create);
+
+/* FIXME: mishandles counts if you have something like
+ * exceptional, sibling, NULL, normal and store something
+ * over the top of all four.  write a testcase for it, then fix it.
+ */
+static void handle_sibling_slots(struct xarray *xa, struct xa_state *xas,
+		void *entry, int *countp, int *exceptionalp)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset = xas->xa_offset;
+	unsigned int slots = xas->xa_slots;
+	void *sibling = entry ? xa_mk_sibling(offset) : NULL;
+
+	while (++offset < XA_CHUNK_SIZE) {
+		void *next = xa_entry(xa, node, offset);
+
+		if (--slots)
+			RCU_INIT_POINTER(node->slots[offset], sibling);
+		else if (!xa_is_sibling(next))
+			break;
+
+		if (xa_is_node(next))
+			xas_free_nodes(xa, xas, xa_node(next));
+		*countp += !next - !entry;
+		*exceptionalp += !xa_is_exceptional(next) -
+				 !xa_is_exceptional(entry);
+	}
+}
+
+/**
+ * xas_store() - Store this entry in the array
+ * @xa: Array
+ * @xas: Array operation state.
+ * @entry: New entry
+ *
+ * Return: The old value at this index.
+ */
+void *xas_store(struct xarray *xa, struct xa_state *xas, void *entry)
+{
+	struct xa_node *node;
+	int count, exceptional;
+	void *curr;
+
+	if (entry)
+		curr = xas_create(xa, xas);
+	else
+		curr = xas_load(xa, xas);
+	if (xas_special(xas))
+		return NULL;
+
+	node = xas->xa_node;
+	if (node)
+		rcu_assign_pointer(node->slots[xas->xa_offset], entry);
+	else
+		rcu_assign_pointer(xa->xa_head, entry);
+	if (!entry)
+		xas_init_tags(xa, xas);
+	else if (xa_track_free(xa))
+		xas_clear_tag(xa, xas, XA_FREE_TAG);
+
+	exceptional = !xa_is_exceptional(curr) - !xa_is_exceptional(entry);
+	count = !curr - !entry;
+	if (xa_is_node(curr))
+		xas_free_nodes(xa, xas, xa_node(curr));
+	if (node)
+		handle_sibling_slots(xa, xas, entry, &count, &exceptional);
+
+	if (!xa_is_internal(entry)) {
+		xas->xa_count += count;
+		xas->xa_exceptional += exceptional;
+	}
+	if (node) {
+		node->count += count;
+		XA_BUG_ON(node->count > XA_CHUNK_SIZE);
+		node->exceptional += exceptional;
+		XA_BUG_ON(node->exceptional > XA_CHUNK_SIZE);
+		if ((count || exceptional) && xas->xa_update)
+			xas->xa_update(node);
+		if (count < 0)
+			xas_delete_node(xa, xas);
+	}
+
+	return curr;
+}
+EXPORT_SYMBOL_GPL(xas_store);
+
+/*
+ * xas_next_entry() - Helper for other tree walking functions
+ *
+ * As a helper, this function has a lot of rough edges.  On entry,
+ * xas->xa_index may not lay within xas->xa_node (which is why we
+ * start by walking back up the tree if it isn't).  There are a lot
+ * of different reasons we may have been called, so we have to fumble
+ * around a bit to find out what we're doing.
+ */
+void *xas_next_entry(struct xarray *xa, struct xa_state *xas, unsigned long max)
+{
+	bool lookup = xas->xa_flags & XAS_FLAG_LOOKUP;
+
+	if (xas_error(xas))
+		return XA_WALK_END;
+
+	xas->xa_flags &= ~XAS_FLAG_LOOKUP;
+	if (!lookup && xas->xa_offset < XA_CHUNK_SIZE && xas->xa_node &&
+			!((unsigned long)xas->xa_node & 1)) {
+		xas->xa_index |= (1UL << xas->xa_node->shift) - 1;
+		xas->xa_index++;
+		xas->xa_offset++;
+	}
+
+	while (xas->xa_node && (xas->xa_index <= max)) {
+		void *entry;
+
+		if (unlikely(xas->xa_offset == XA_CHUNK_SIZE)) {
+			xas->xa_offset = xas->xa_node->offset + 1;
+			xas->xa_node = xa_parent(xa, xas->xa_node);
+			continue;
+		}
+		entry = xas_load(xa, xas);
+
+		if (xa_is_node(entry)) {
+			xas->xa_node = xa_node(entry);
+			xas->xa_offset = xas_offset(xas);
+			continue;
+		} else if (lookup && xa_is_sibling(entry)) {
+			xas->xa_offset = xa_sibling_offset(entry);
+			entry = xa_entry(xa, xas->xa_node, xas->xa_offset);
+			return entry;
+		} else if (!xa_is_skip(entry))
+			return entry;
+
+		if (xas->xa_node <= XA_WALK_RESTART)
+			break;
+		xas->xa_offset++;
+		xas->xa_index += 1UL << xas->xa_node->shift;
+	}
+
+	return XA_WALK_END;
+}
+EXPORT_SYMBOL_GPL(xas_next_entry);
+
+/**
+ * xas_find_tag() - Search the xarray for a tagged entry
+ * @xa: Array
+ * @xas: Array operation state.
+ * @max: Maximum value to return
+ * @tag: Tag number to search for
+ *
+ * Finds the first tagged entry at or after the index in @xas
+ * tag set and is less than or equal to @max.
+ *
+ * Return: The entry, if found, otherwise XA_WALK_END.
+ */
+void *xas_find_tag(struct xarray *xa, struct xa_state *xas,
+		unsigned long max, xa_tag_t tag)
+{
+	void *entry = XA_WALK_END;
+	int offset;
+
+	if (xas_error(xas) || xas->xa_index > max)
+		return entry;
+
+	if (xas_restart(xas)) {
+		struct xa_node *node;
+		unsigned long offset;
+
+		entry = xa_head(xa);
+		if (!xa_tagged(xa, tag)) {
+			if (xa_is_node(entry))
+				xas->xa_index = XA_CHUNK_SIZE <<
+						xa_node(entry)->shift;
+			else if (xas->xa_index < 1)
+				xas->xa_index = 1;
+			return XA_WALK_END;
+		}
+		if (!xa_is_node(entry)) {
+			if (xas->xa_index)
+				return XA_WALK_END;
+			xas->xa_node = NULL;
+			return entry;
+		}
+		node = xa_node(entry);
+		offset = xas->xa_index >> node->shift;
+		if (offset > XA_CHUNK_MASK)
+			return XA_WALK_END;
+		xas->xa_node = node;
+		xas->xa_offset = offset;
+		entry = XA_WALK_END;
+	}
+
+	while (xas->xa_node) {
+		offset = xas_chunk_tag(xas, tag);
+		if (offset != xas->xa_offset) {
+			unsigned long index = set_index(xas->xa_node, offset,
+								xas->xa_index);
+			if (!index || index > max) {
+				xas->xa_index = max + 1;
+				break;
+			}
+			xas->xa_index = index;
+			xas->xa_offset = offset;
+		}
+
+		if (unlikely(xas->xa_offset == XA_CHUNK_SIZE)) {
+			xas->xa_offset = xas->xa_node->offset + 1;
+			xas->xa_node = xa_parent(xa, xas->xa_node);
+			continue;
+		}
+
+		entry = xa_entry(xa, xas->xa_node, offset);
+		if (!xa_is_node(entry))
+			break;
+		xas->xa_node = xa_node(entry);
+		xas->xa_offset = xas_offset(xas);
+		entry = XA_WALK_END;
+	}
+
+	if (entry == XA_WALK_END)
+		xas->xa_node = XA_WALK_RESTART;
+	return entry;
+}
+EXPORT_SYMBOL_GPL(xas_find_tag);
+
+/**
+ * xa_load() - Load the entry from the array
+ * @xa: Array
+ * @index: index in array
+ *
+ * Return: The entry at @index in @xa.
+ */
+void *xa_load(struct xarray *xa, unsigned long index)
+{
+	struct xa_state xas;
+	void *entry;
+
+	xas_init(&xas, index);
+	rcu_read_lock();
+	entry = xas_start(xa, &xas);
+	while (xa_is_node(entry)) {
+		entry = xas_descend(xa, &xas, xa_node(entry));
+		if (xa_is_retry(entry))
+			entry = xas_start(xa, &xas);
+	}
+	rcu_read_unlock();
+
+	if (entry == XA_WALK_END)
+		entry = NULL;
+	return entry;
+}
+EXPORT_SYMBOL(xa_load);
+
+/**
+ * xa_store() - Store this entry in the array
+ * @xa: Array
+ * @index: index in array
+ * @entry: New entry
+ * @gfp: Allocation flags
+ *
+ * Stores almost always succeed.  The notable exceptions:
+ *  - Attempted to store a reserved pointer value (-EINVAL)
+ *  - Ran out of memory trying to allocate new nodes (-ENOMEM)
+ *
+ * Storing into an existing multislot entry updates the value of every index.
+ *
+ * Return: The old value at this index or ERR_PTR() if an error happened
+ */
+void *xa_store(struct xarray *xa, unsigned long index, void *entry, gfp_t gfp)
+{
+	struct xa_state xas;
+	unsigned long flags;
+	void *curr;
+
+	if (WARN_ON_ONCE(xa_is_internal(entry)))
+		return ERR_PTR(-EINVAL);
+
+	xas_init(&xas, index);
+	do {
+		xa_lock_irqsave(xa, flags);
+		curr = xas_store(xa, &xas, entry);
+		xa_unlock_irqrestore(xa, flags);
+	} while (xas_nomem(&xas, gfp));
+	xas_destroy(&xas);
+
+	if (xas_error(&xas))
+		curr = xas.xa_node;
+	return curr;
+}
+EXPORT_SYMBOL(xa_store);
+
+/**
+ * xa_replace() - Conditionally replace this entry in the array
+ * @xa: Array
+ * @index: index in array
+ * @entry: New value to place in array
+ * @old: Old value to test against
+ * @gfp: Allocation flags
+ *
+ * If the entry at @index is the same as @old, replace it with @entry.
+ * If the return value is equal to @old, then the exchange was successful.
+ *
+ * Return: The old value at this index or ERR_PTR() if an error happened
+ */
+void *xa_replace(struct xarray *xa, unsigned long index,
+		void *entry, void *old, gfp_t gfp)
+{
+	struct xa_state xas;
+	unsigned long flags;
+	void *curr;
+
+	if (WARN_ON_ONCE(xa_is_internal(entry)))
+		return ERR_PTR(-EINVAL);
+
+	xas_init(&xas, index);
+	do {
+		xa_lock_irqsave(xa, flags);
+		curr = xas_create(xa, &xas);
+		if (curr == old)
+			xas_store(xa, &xas, entry);
+		xa_unlock_irqrestore(xa, flags);
+	} while (xas_nomem(&xas, gfp));
+	xas_destroy(&xas);
+
+	if (xas_error(&xas))
+		curr = xas.xa_node;
+	return curr;
+}
+EXPORT_SYMBOL(xa_replace);
+
+/**
+ * xa_get_tag() - Inquire whether this tag is set on this entry
+ * @xa: Array
+ * @index: Index of entry
+ * @tag: Tag value
+ *
+ * This function is protected by the RCU read lock, so the result may be
+ * out of date by the time it returns.  If you need the result to be stable,
+ * use a lock.
+ *
+ * Return: True if the entry at @index has this tag set, false if it doesn't.
+ */
+bool __xa_get_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	struct xa_state xas;
+	void *entry;
+
+	xas_init(&xas, index);
+	rcu_read_lock();
+	entry = xas_start(xa, &xas);
+	while (xas_get_tag(xa, &xas, tag)) {
+		if (!xa_is_node(entry))
+			goto found;
+		entry = xas_descend(xa, &xas, xa_node(entry));
+	}
+	rcu_read_unlock();
+	return false;
+found:
+	rcu_read_unlock();
+	return true;
+}
+EXPORT_SYMBOL(__xa_get_tag);
+
+/**
+ * xa_set_tag() - Set this tag on this entry.
+ * @xa: Array
+ * @index: Index of entry
+ * @tag: Tag value
+ *
+ * Attempting to set a tag on a NULL entry does not succeed.
+ *
+ * Return: The entry at this index or ERR_PTR() if an error occurs.
+ */
+void *__xa_set_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	struct xa_state xas;
+	unsigned long flags;
+	void *entry;
+
+	xas_init(&xas, index);
+	xa_lock_irqsave(xa, flags);
+	entry = xas_load(xa, &xas);
+	if (entry == XA_WALK_END)
+		entry = NULL;
+	if (entry)
+		xas_set_tag(xa, &xas, tag);
+	xa_unlock_irqrestore(xa, flags);
+
+	return entry;
+}
+EXPORT_SYMBOL(__xa_set_tag);
+
+/**
+ * xa_clear_tag() - Clear this tag on this entry.
+ * @xa: Array
+ * @index: Index of entry
+ * @tag: Tag value
+ *
+ * Clearing a tag on an entry which doesn't exist always succeeds
+ *
+ * Return: The entry at this index or ERR_PTR() if an error occurs.
+ */
+void *__xa_clear_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	struct xa_state xas;
+	unsigned long flags;
+	void *entry;
+
+	xas_init(&xas, index);
+	xa_lock_irqsave(xa, flags);
+	entry = xas_load(xa, &xas);
+	if (entry == XA_WALK_END)
+		entry = NULL;
+	if (entry)
+		xas_clear_tag(xa, &xas, tag);
+	xa_unlock_irqrestore(xa, flags);
+
+	return entry;
+}
+EXPORT_SYMBOL(__xa_clear_tag);
+
+/**
+ * xa_find() - Search the xarray for a present entry
+ * @xa: Array
+ * @indexp: Pointer to an index
+ * @max: Maximum value to return
+ *
+ * Finds the entry in the xarray with the lowest index that is between
+ * *@indexp and max, inclusive.  If an entry is found, updates @indexp to
+ * be the index of the pointer.  This function is protected by the RCU read
+ * lock, so it may not find all entries if called in a loop.
+ *
+ * Return: The pointer, if found, otherwise NULL.
+ */
+void *xa_find(struct xarray *xa, unsigned long *indexp, unsigned long max)
+{
+	struct xa_state xas;
+	void *entry;
+
+	xas_init(&xas, *indexp);
+
+	rcu_read_lock();
+	do {
+		entry = xas_next(xa, &xas, max);
+		xas_retry(&xas, entry);
+		if (entry == XA_WALK_END)
+			entry = NULL;
+	} while (xa_is_internal(entry));
+	rcu_read_unlock();
+
+	if (entry)
+		*indexp = xas.xa_index;
+	return entry;
+}
+EXPORT_SYMBOL(xa_find);
+
+/**
+ * xa_next() - Search the xarray for the next present entry
+ * @xa: Array
+ * @indexp: Pointer to an index
+ * @max: Maximum value to return
+ *
+ * Finds the entry in the xarray with the lowest index that is above
+ * *@indexp and not greater than max.  If an entry is found, updates
+ * @indexp to be the index of the pointer.
+ *
+ * Return: The pointer, if found, otherwise NULL.
+ */
+void *xa_next(struct xarray *xa, unsigned long *indexp, unsigned long max)
+{
+	struct xa_state xas;
+	void *entry;
+
+	xas_init(&xas, *indexp + 1);
+	xas.xa_flags &= ~XAS_FLAG_LOOKUP;
+
+	rcu_read_lock();
+	do {
+		entry = xas_next(xa, &xas, max);
+		xas_retry(&xas, entry);
+		if (entry == XA_WALK_END)
+			entry = NULL;
+	} while (xa_is_internal(entry));
+	rcu_read_unlock();
+
+	if (entry)
+		*indexp = xas.xa_index;
+	return entry;
+}
+EXPORT_SYMBOL(xa_next);
+
+/**
+ * xa_get_entries() - Copy entries from the xarray into a normal array
+ * @xa: The source XArray to copy from
+ * @dst: The buffer to copy pointers into
+ * @start: The first index in the XArray eligible to be copied from
+ * @n: The maximum number of entries to copy
+ *
+ * Return: The number of entries copied.
+ */
+int xa_get_entries(struct xarray *xa, unsigned long start, void **dst,
+		unsigned int n)
+{
+	struct xa_state xas;
+	void *entry;
+	unsigned int i = 0;
+
+	if (!n)
+		return 0;
+
+	xas_init(&xas, start);
+	rcu_read_lock();
+	xas_for_each(xa, &xas, entry, ~0UL) {
+		if (xas_retry(&xas, entry))
+			continue;
+		dst[i++] = entry;
+		if (i == n)
+			break;
+	}
+	rcu_read_unlock();
+
+	return i;
+}
+EXPORT_SYMBOL(xa_get_entries);
+
+/**
+ * xa_get_tagged() - Copy tagged entries from the xarray into a normal array
+ * @xa: The source XArray to copy from
+ * @dst: The buffer to copy pointers into
+ * @start: The first index in the XArray eligible to be copied from
+ * @n: The maximum number of entries to copy
+ *
+ * Return: The number of entries copied.
+ */
+int xa_get_tagged(struct xarray *xa, unsigned long start, void **dst,
+		unsigned int n, xa_tag_t tag)
+{
+	struct xa_state xas;
+	void *entry;
+	unsigned int i = 0;
+
+	if (!n)
+		return 0;
+
+	xas_init(&xas, start);
+	rcu_read_lock();
+	xas_for_each_tag(xa, &xas, entry, ~0UL, tag) {
+		if (xas_retry(&xas, entry))
+			continue;
+		dst[i++] = entry;
+		if (i == n)
+			break;
+	}
+	rcu_read_unlock();
+
+	return i;
+}
+EXPORT_SYMBOL(xa_get_tagged);
+
+void __init init_xarray(void)
+{
+	xa_node_cache = kmem_cache_create("xa_node",
+				sizeof(struct xa_node), 0,
+				SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
+				xa_node_ctor);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

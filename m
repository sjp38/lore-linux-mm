Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 159E36B000E
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:06:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j25-v6so9228862pfi.9
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:06:46 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c10-v6si29798252pgq.616.2018.06.11.07.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:06:43 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 09/72] xarray: Add XArray tags
Date: Mon, 11 Jun 2018 07:05:36 -0700
Message-Id: <20180611140639.17215-10-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

XArray tags are slightly more strongly typed than the radix tree tags,
but occupy the same bits.  This commit adds the basic get/set/clear
operations.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/xarray.h                        |  47 ++++
 lib/xarray.c                                  | 237 ++++++++++++++++++
 tools/include/asm-generic/bitops.h            |   1 +
 tools/include/asm-generic/bitops/atomic.h     |   9 -
 tools/include/asm-generic/bitops/non-atomic.h | 109 ++++++++
 tools/include/linux/spinlock.h                |   6 +
 6 files changed, 400 insertions(+), 9 deletions(-)
 create mode 100644 tools/include/asm-generic/bitops/non-atomic.h

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 099fc36177b9..f712baba956e 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -11,6 +11,7 @@
 
 #include <linux/bug.h>
 #include <linux/compiler.h>
+#include <linux/gfp.h>
 #include <linux/kconfig.h>
 #include <linux/kernel.h>
 #include <linux/rcupdate.h>
@@ -149,6 +150,20 @@ static inline int xa_err(void *entry)
 	return 0;
 }
 
+typedef unsigned __bitwise xa_tag_t;
+#define XA_TAG_0		((__force xa_tag_t)0U)
+#define XA_TAG_1		((__force xa_tag_t)1U)
+#define XA_TAG_2		((__force xa_tag_t)2U)
+#define XA_PRESENT		((__force xa_tag_t)8U)
+#define XA_TAG_MAX		XA_TAG_2
+
+/*
+ * Values for xa_flags.  The radix tree stores its GFP flags in the xa_flags,
+ * and we remain compatible with that.
+ */
+#define XA_FLAGS_TAG(tag)	((__force gfp_t)((1U << __GFP_BITS_SHIFT) << \
+						(__force unsigned)(tag)))
+
 /**
  * struct xarray - The anchor of the XArray.
  * @xa_lock: Lock that protects the contents of the XArray.
@@ -195,6 +210,9 @@ struct xarray {
 
 void xa_init_flags(struct xarray *, gfp_t flags);
 void *xa_load(struct xarray *, unsigned long index);
+bool xa_get_tag(struct xarray *, unsigned long index, xa_tag_t);
+void xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
+void xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
 
 /**
  * xa_init() - Initialise an empty XArray.
@@ -209,6 +227,19 @@ static inline void xa_init(struct xarray *xa)
 	xa_init_flags(xa, 0);
 }
 
+/**
+ * xa_tagged() - Inquire whether any entry in this array has a tag set
+ * @xa: Array
+ * @tag: Tag value
+ *
+ * Context: Any context.
+ * Return: %true if any entry has this tag set.
+ */
+static inline bool xa_tagged(const struct xarray *xa, xa_tag_t tag)
+{
+	return xa->xa_flags & XA_FLAGS_TAG(tag);
+}
+
 #define xa_trylock(xa)		spin_trylock(&(xa)->xa_lock)
 #define xa_lock(xa)		spin_lock(&(xa)->xa_lock)
 #define xa_unlock(xa)		spin_unlock(&(xa)->xa_lock)
@@ -221,6 +252,12 @@ static inline void xa_init(struct xarray *xa)
 #define xa_unlock_irqrestore(xa, flags) \
 				spin_unlock_irqrestore(&(xa)->xa_lock, flags)
 
+/*
+ * Versions of the normal API which require the caller to hold the xa_lock.
+ */
+void __xa_set_tag(struct xarray *, unsigned long index, xa_tag_t);
+void __xa_clear_tag(struct xarray *, unsigned long index, xa_tag_t);
+
 /* Everything below here is the Advanced API.  Proceed with caution. */
 
 /*
@@ -514,6 +551,12 @@ static inline bool xas_valid(const struct xa_state *xas)
 	return !xas_invalid(xas);
 }
 
+/* True if the pointer is something other than a node */
+static inline bool xas_not_node(struct xa_node *node)
+{
+	return ((unsigned long)node & 3) || !node;
+}
+
 /**
  * xas_reset() - Reset an XArray operation state.
  * @xas: XArray operation state.
@@ -551,6 +594,10 @@ static inline bool xas_retry(struct xa_state *xas, const void *entry)
 
 void *xas_load(struct xa_state *);
 
+bool xas_get_tag(const struct xa_state *, xa_tag_t);
+void xas_set_tag(const struct xa_state *, xa_tag_t);
+void xas_clear_tag(const struct xa_state *, xa_tag_t);
+
 /**
  * xas_reload() - Refetch an entry from the xarray.
  * @xas: XArray operation state.
diff --git a/lib/xarray.c b/lib/xarray.c
index 600550e78a11..2d6f509ff498 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -5,6 +5,7 @@
  * Author: Matthew Wilcox <mawilcox@microsoft.com>
  */
 
+#include <linux/bitmap.h>
 #include <linux/export.h>
 #include <linux/xarray.h>
 
@@ -24,6 +25,57 @@
  * @entry refers to something stored in a slot in the xarray
  */
 
+static inline struct xa_node *xa_parent(struct xarray *xa,
+					const struct xa_node *node)
+{
+	return rcu_dereference_check(node->parent,
+						lockdep_is_held(&xa->xa_lock));
+}
+
+static inline struct xa_node *xa_parent_locked(struct xarray *xa,
+					const struct xa_node *node)
+{
+	return rcu_dereference_protected(node->parent,
+						lockdep_is_held(&xa->xa_lock));
+}
+
+static inline void xa_tag_set(struct xarray *xa, xa_tag_t tag)
+{
+	if (!(xa->xa_flags & XA_FLAGS_TAG(tag)))
+		xa->xa_flags |= XA_FLAGS_TAG(tag);
+}
+
+static inline void xa_tag_clear(struct xarray *xa, xa_tag_t tag)
+{
+	if (xa->xa_flags & XA_FLAGS_TAG(tag))
+		xa->xa_flags &= ~(XA_FLAGS_TAG(tag));
+}
+
+static inline bool node_get_tag(const struct xa_node *node, unsigned int offset,
+				xa_tag_t tag)
+{
+	return test_bit(offset, node->tags[(__force unsigned)tag]);
+}
+
+/* returns true if the bit was set */
+static inline bool node_set_tag(struct xa_node *node, unsigned int offset,
+				xa_tag_t tag)
+{
+	return __test_and_set_bit(offset, node->tags[(__force unsigned)tag]);
+}
+
+/* returns true if the bit was set */
+static inline bool node_clear_tag(struct xa_node *node, unsigned int offset,
+				xa_tag_t tag)
+{
+	return __test_and_clear_bit(offset, node->tags[(__force unsigned)tag]);
+}
+
+static inline bool node_any_tag(struct xa_node *node, xa_tag_t tag)
+{
+	return !bitmap_empty(node->tags[(__force unsigned)tag], XA_CHUNK_SIZE);
+}
+
 /* extracts the offset within this node from the index */
 static unsigned int get_offset(unsigned long index, struct xa_node *node)
 {
@@ -119,6 +171,85 @@ void *xas_load(struct xa_state *xas)
 }
 EXPORT_SYMBOL_GPL(xas_load);
 
+/**
+ * xas_get_tag() - Returns the state of this tag.
+ * @xas: XArray operation state.
+ * @tag: Tag number.
+ *
+ * Return: true if the tag is set, false if the tag is clear or @xas
+ * is in an error state.
+ */
+bool xas_get_tag(const struct xa_state *xas, xa_tag_t tag)
+{
+	if (xas_invalid(xas))
+		return false;
+	if (!xas->xa_node)
+		return xa_tagged(xas->xa, tag);
+	return node_get_tag(xas->xa_node, xas->xa_offset, tag);
+}
+EXPORT_SYMBOL_GPL(xas_get_tag);
+
+/**
+ * xas_set_tag() - Sets the tag on this entry and its parents.
+ * @xas: XArray operation state.
+ * @tag: Tag number.
+ *
+ * Sets the specified tag on this entry, and walks up the tree setting it
+ * on all the ancestor entries.  Does nothing if @xas has not been walked to
+ * an entry, or is in an error state.
+ */
+void xas_set_tag(const struct xa_state *xas, xa_tag_t tag)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset = xas->xa_offset;
+
+	if (xas_invalid(xas))
+		return;
+
+	while (node) {
+		if (node_set_tag(node, offset, tag))
+			return;
+		offset = node->offset;
+		node = xa_parent_locked(xas->xa, node);
+	}
+
+	if (!xa_tagged(xas->xa, tag))
+		xa_tag_set(xas->xa, tag);
+}
+EXPORT_SYMBOL_GPL(xas_set_tag);
+
+/**
+ * xas_clear_tag() - Clears the tag on this entry and its parents.
+ * @xas: XArray operation state.
+ * @tag: Tag number.
+ *
+ * Clears the specified tag on this entry, and walks back to the head
+ * attempting to clear it on all the ancestor entries.  Does nothing if
+ * @xas has not been walked to an entry, or is in an error state.
+ */
+void xas_clear_tag(const struct xa_state *xas, xa_tag_t tag)
+{
+	struct xa_node *node = xas->xa_node;
+	unsigned int offset = xas->xa_offset;
+
+	if (xas_invalid(xas))
+		return;
+
+	while (node) {
+		if (!node_clear_tag(node, offset, tag))
+			return;
+		if (node_any_tag(node, tag))
+			return;
+
+		offset = node->offset;
+		node = xa_parent_locked(xas->xa, node);
+	}
+
+	if (xa_tagged(xas->xa, tag))
+		xa_tag_clear(xas->xa, tag);
+}
+EXPORT_SYMBOL_GPL(xas_clear_tag);
+
 /**
  * xa_init_flags() - Initialise an empty XArray with flags.
  * @xa: XArray.
@@ -161,6 +292,112 @@ void *xa_load(struct xarray *xa, unsigned long index)
 }
 EXPORT_SYMBOL(xa_load);
 
+/**
+ * __xa_set_tag() - Set this tag on this entry while locked.
+ * @xa: XArray.
+ * @index: Index of entry.
+ * @tag: Tag number.
+ *
+ * Attempting to set a tag on a NULL entry does not succeed.
+ *
+ * Context: Any context.  Expects xa_lock to be held on entry.
+ */
+void __xa_set_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	XA_STATE(xas, xa, index);
+	void *entry = xas_load(&xas);
+
+	if (entry)
+		xas_set_tag(&xas, tag);
+}
+EXPORT_SYMBOL_GPL(__xa_set_tag);
+
+/**
+ * __xa_clear_tag() - Clear this tag on this entry while locked.
+ * @xa: XArray.
+ * @index: Index of entry.
+ * @tag: Tag number.
+ *
+ * Context: Any context.  Expects xa_lock to be held on entry.
+ */
+void __xa_clear_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	XA_STATE(xas, xa, index);
+	void *entry = xas_load(&xas);
+
+	if (entry)
+		xas_clear_tag(&xas, tag);
+}
+EXPORT_SYMBOL_GPL(__xa_clear_tag);
+
+/**
+ * xa_get_tag() - Inquire whether this tag is set on this entry.
+ * @xa: XArray.
+ * @index: Index of entry.
+ * @tag: Tag number.
+ *
+ * This function uses the RCU read lock, so the result may be out of date
+ * by the time it returns.  If you need the result to be stable, use a lock.
+ *
+ * Context: Any context.  Takes and releases the RCU lock.
+ * Return: True if the entry at @index has this tag set, false if it doesn't.
+ */
+bool xa_get_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	XA_STATE(xas, xa, index);
+	void *entry;
+
+	rcu_read_lock();
+	entry = xas_start(&xas);
+	while (xas_get_tag(&xas, tag)) {
+		if (!xa_is_node(entry))
+			goto found;
+		entry = xas_descend(&xas, xa_to_node(entry));
+	}
+	rcu_read_unlock();
+	return false;
+ found:
+	rcu_read_unlock();
+	return true;
+}
+EXPORT_SYMBOL(xa_get_tag);
+
+/**
+ * xa_set_tag() - Set this tag on this entry.
+ * @xa: XArray.
+ * @index: Index of entry.
+ * @tag: Tag number.
+ *
+ * Attempting to set a tag on a NULL entry does not succeed.
+ *
+ * Context: Process context.  Takes and releases the xa_lock.
+ */
+void xa_set_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	xa_lock(xa);
+	__xa_set_tag(xa, index, tag);
+	xa_unlock(xa);
+}
+EXPORT_SYMBOL(xa_set_tag);
+
+/**
+ * xa_clear_tag() - Clear this tag on this entry.
+ * @xa: XArray.
+ * @index: Index of entry.
+ * @tag: Tag number.
+ *
+ * Clearing a tag always succeeds.
+ *
+ * Context: Process context.  Takes and releases the xa_lock.
+ */
+void xa_clear_tag(struct xarray *xa, unsigned long index, xa_tag_t tag)
+{
+	xa_lock(xa);
+	__xa_clear_tag(xa, index, tag);
+	xa_unlock(xa);
+}
+EXPORT_SYMBOL(xa_clear_tag);
+
 #ifdef XA_DEBUG
 void xa_dump_node(const struct xa_node *node)
 {
diff --git a/tools/include/asm-generic/bitops.h b/tools/include/asm-generic/bitops.h
index 9bce3b56b5e7..5d2ab38965cc 100644
--- a/tools/include/asm-generic/bitops.h
+++ b/tools/include/asm-generic/bitops.h
@@ -27,5 +27,6 @@
 #include <asm-generic/bitops/hweight.h>
 
 #include <asm-generic/bitops/atomic.h>
+#include <asm-generic/bitops/non-atomic.h>
 
 #endif /* __TOOLS_ASM_GENERIC_BITOPS_H */
diff --git a/tools/include/asm-generic/bitops/atomic.h b/tools/include/asm-generic/bitops/atomic.h
index 21c41ccd1266..2f6ea28764a7 100644
--- a/tools/include/asm-generic/bitops/atomic.h
+++ b/tools/include/asm-generic/bitops/atomic.h
@@ -15,13 +15,4 @@ static inline void clear_bit(int nr, unsigned long *addr)
 	addr[nr / __BITS_PER_LONG] &= ~(1UL << (nr % __BITS_PER_LONG));
 }
 
-static __always_inline int test_bit(unsigned int nr, const unsigned long *addr)
-{
-	return ((1UL << (nr % __BITS_PER_LONG)) &
-		(((unsigned long *)addr)[nr / __BITS_PER_LONG])) != 0;
-}
-
-#define __set_bit(nr, addr)	set_bit(nr, addr)
-#define __clear_bit(nr, addr)	clear_bit(nr, addr)
-
 #endif /* _TOOLS_LINUX_ASM_GENERIC_BITOPS_ATOMIC_H_ */
diff --git a/tools/include/asm-generic/bitops/non-atomic.h b/tools/include/asm-generic/bitops/non-atomic.h
new file mode 100644
index 000000000000..7e10c4b50c5d
--- /dev/null
+++ b/tools/include/asm-generic/bitops/non-atomic.h
@@ -0,0 +1,109 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _ASM_GENERIC_BITOPS_NON_ATOMIC_H_
+#define _ASM_GENERIC_BITOPS_NON_ATOMIC_H_
+
+#include <asm/types.h>
+
+/**
+ * __set_bit - Set a bit in memory
+ * @nr: the bit to set
+ * @addr: the address to start counting from
+ *
+ * Unlike set_bit(), this function is non-atomic and may be reordered.
+ * If it's called on the same region of memory simultaneously, the effect
+ * may be that only one operation succeeds.
+ */
+static inline void __set_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+
+	*p  |= mask;
+}
+
+static inline void __clear_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+
+	*p &= ~mask;
+}
+
+/**
+ * __change_bit - Toggle a bit in memory
+ * @nr: the bit to change
+ * @addr: the address to start counting from
+ *
+ * Unlike change_bit(), this function is non-atomic and may be reordered.
+ * If it's called on the same region of memory simultaneously, the effect
+ * may be that only one operation succeeds.
+ */
+static inline void __change_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+
+	*p ^= mask;
+}
+
+/**
+ * __test_and_set_bit - Set a bit and return its old value
+ * @nr: Bit to set
+ * @addr: Address to count from
+ *
+ * This operation is non-atomic and can be reordered.
+ * If two examples of this operation race, one can appear to succeed
+ * but actually fail.  You must protect multiple accesses with a lock.
+ */
+static inline int __test_and_set_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old | mask;
+	return (old & mask) != 0;
+}
+
+/**
+ * __test_and_clear_bit - Clear a bit and return its old value
+ * @nr: Bit to clear
+ * @addr: Address to count from
+ *
+ * This operation is non-atomic and can be reordered.
+ * If two examples of this operation race, one can appear to succeed
+ * but actually fail.  You must protect multiple accesses with a lock.
+ */
+static inline int __test_and_clear_bit(int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old & ~mask;
+	return (old & mask) != 0;
+}
+
+/* WARNING: non atomic and it can be reordered! */
+static inline int __test_and_change_bit(int nr,
+					    volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old ^ mask;
+	return (old & mask) != 0;
+}
+
+/**
+ * test_bit - Determine whether a bit is set
+ * @nr: bit number to test
+ * @addr: Address to start counting from
+ */
+static inline int test_bit(int nr, const volatile unsigned long *addr)
+{
+	return 1UL & (addr[BIT_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
+}
+
+#endif /* _ASM_GENERIC_BITOPS_NON_ATOMIC_H_ */
diff --git a/tools/include/linux/spinlock.h b/tools/include/linux/spinlock.h
index 4ec4d2cbe27a..622266b197d0 100644
--- a/tools/include/linux/spinlock.h
+++ b/tools/include/linux/spinlock.h
@@ -10,6 +10,12 @@
 #define __SPIN_LOCK_UNLOCKED(x)	(pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER
 #define spin_lock_init(x)	pthread_mutex_init(x, NULL)
 
+#define spin_lock(x)			pthread_mutex_lock(x)
+#define spin_unlock(x)			pthread_mutex_unlock(x)
+#define spin_lock_bh(x)			pthread_mutex_lock(x)
+#define spin_unlock_bh(x)		pthread_mutex_unlock(x)
+#define spin_lock_irq(x)		pthread_mutex_lock(x)
+#define spin_unlock_irq(x)		pthread_mutex_unlock(x)
 #define spin_lock_irqsave(x, f)		(void)f, pthread_mutex_lock(x)
 #define spin_unlock_irqrestore(x, f)	(void)f, pthread_mutex_unlock(x)
 
-- 
2.17.1

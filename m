Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 123226B030E
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:35:22 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id l8so77198049iti.6
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:35:22 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id e90si254982ioi.142.2016.11.16.14.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:35:19 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 29/29] Reimplement IDR and IDA using the radix tree
Date: Wed, 16 Nov 2016 16:17:00 -0800
Message-Id: <1479341856-30320-36-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@infradead.org>

The IDR is very similar to the radix tree.  It has some functionality
that the radix tree did not have (alloc next free, cyclic allocation,
a callback-based for_each, destroy tree), which is readily implementable
on top of the radix tree.  A few small changes were needed in order to
use a tag to represent nodes with free space below them.

The IDA is reimplemented as a client of the newly enhanced radix tree.
As in the current implementation, it uses a bitmap at the last level of
the tree.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/idr.h                     |  132 ++--
 include/linux/radix-tree.h              |    5 +-
 init/main.c                             |    3 +-
 lib/idr.c                               | 1075 -------------------------------
 lib/radix-tree.c                        |  624 ++++++++++++++++--
 tools/testing/radix-tree/Makefile       |    5 +-
 tools/testing/radix-tree/idr.c          |  148 +++++
 tools/testing/radix-tree/linux/idr.h    |    1 +
 tools/testing/radix-tree/linux/kernel.h |    2 +
 tools/testing/radix-tree/main.c         |    6 +
 tools/testing/radix-tree/test.h         |    2 +
 11 files changed, 791 insertions(+), 1212 deletions(-)
 create mode 100644 tools/testing/radix-tree/idr.c
 create mode 100644 tools/testing/radix-tree/linux/idr.h

diff --git a/include/linux/idr.h b/include/linux/idr.h
index 3c01b89..0035799 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -12,47 +12,22 @@
 #ifndef __IDR_H__
 #define __IDR_H__
 
-#include <linux/types.h>
-#include <linux/bitops.h>
-#include <linux/init.h>
-#include <linux/rcupdate.h>
-
-/*
- * Using 6 bits at each layer allows us to allocate 7 layers out of each page.
- * 8 bits only gave us 3 layers out of every pair of pages, which is less
- * efficient except for trees with a largest element between 192-255 inclusive.
- */
-#define IDR_BITS 6
-#define IDR_SIZE (1 << IDR_BITS)
-#define IDR_MASK ((1 << IDR_BITS)-1)
-
-struct idr_layer {
-	int			prefix;	/* the ID prefix of this idr_layer */
-	int			layer;	/* distance from leaf */
-	struct idr_layer __rcu	*ary[1<<IDR_BITS];
-	int			count;	/* When zero, we can release it */
-	union {
-		/* A zero bit means "space here" */
-		DECLARE_BITMAP(bitmap, IDR_SIZE);
-		struct rcu_head		rcu_head;
-	};
-};
+#include <linux/radix-tree.h>
+#include <linux/gfp.h>
 
 struct idr {
-	struct idr_layer __rcu	*hint;	/* the last layer allocated from */
-	struct idr_layer __rcu	*top;
-	int			layers;	/* only valid w/o concurrent changes */
-	int			cur;	/* current pos for cyclic allocation */
-	spinlock_t		lock;
-	int			id_free_cnt;
-	struct idr_layer	*id_free;
+	struct radix_tree_root	idr_rt;
+	unsigned int		idr_next;
 };
 
-#define IDR_INIT(name)							\
+/* Set the IDR flag and the IDR_FREE tag */
+#define IDR_RT_MARKER		((__force gfp_t)(3 << __GFP_BITS_SHIFT))
+
+#define IDR_INIT							\
 {									\
-	.lock			= __SPIN_LOCK_UNLOCKED(name.lock),	\
+	.idr_rt = RADIX_TREE_INIT(IDR_RT_MARKER)			\
 }
-#define DEFINE_IDR(name)	struct idr name = IDR_INIT(name)
+#define DEFINE_IDR(name)	struct idr name = IDR_INIT
 
 /**
  * idr_get_cursor - Return the current position of the cyclic allocator
@@ -64,7 +39,7 @@ struct idr {
  */
 static inline unsigned int idr_get_cursor(struct idr *idr)
 {
-	return READ_ONCE(idr->cur);
+	return READ_ONCE(idr->idr_next);
 }
 
 /**
@@ -77,7 +52,7 @@ static inline unsigned int idr_get_cursor(struct idr *idr)
  */
 static inline void idr_set_cursor(struct idr *idr, unsigned int val)
 {
-	WRITE_ONCE(idr->cur, val);
+	WRITE_ONCE(idr->idr_next, val);
 }
 
 /**
@@ -97,22 +72,30 @@ static inline void idr_set_cursor(struct idr *idr, unsigned int val)
  * period).
  */
 
-/*
- * This is what we export.
- */
-
-void *idr_find_slowpath(struct idr *idp, int id);
 void idr_preload(gfp_t gfp_mask);
-int idr_alloc(struct idr *idp, void *ptr, int start, int end, gfp_t gfp_mask);
-int idr_alloc_cyclic(struct idr *idr, void *ptr, int start, int end, gfp_t gfp_mask);
-int idr_for_each(struct idr *idp,
+int idr_alloc(struct idr *, void *, int start, int end, gfp_t gfp_mask);
+int idr_alloc_cyclic(struct idr *, void *, int start, int end, gfp_t gfp_mask);
+int idr_for_each(struct idr *,
 		 int (*fn)(int id, void *p, void *data), void *data);
-void *idr_get_next(struct idr *idp, int *nextid);
-void *idr_replace(struct idr *idp, void *ptr, int id);
-void idr_remove(struct idr *idp, int id);
-void idr_destroy(struct idr *idp);
-void idr_init(struct idr *idp);
-bool idr_is_empty(struct idr *idp);
+void *idr_get_next(struct idr *, int *nextid);
+void *idr_replace(struct idr *, void *, int id);
+void idr_destroy(struct idr *);
+
+static inline void idr_remove(struct idr *idp, int id)
+{
+	radix_tree_delete(&idp->idr_rt, id);
+}
+
+static inline void idr_init(struct idr *idp)
+{
+	memset(idp, 0, sizeof(*idp));
+	idp->idr_rt.gfp_mask = IDR_RT_MARKER;
+}
+
+static inline bool idr_is_empty(struct idr *idp)
+{
+	return radix_tree_empty(&idp->idr_rt);
+}
 
 /**
  * idr_preload_end - end preload section started with idr_preload()
@@ -139,17 +122,12 @@ static inline void idr_preload_end(void)
  */
 static inline void *idr_find(struct idr *idr, int id)
 {
-	struct idr_layer *hint = rcu_dereference_raw(idr->hint);
-
-	if (hint && (id & ~IDR_MASK) == hint->prefix)
-		return rcu_dereference_raw(hint->ary[id & IDR_MASK]);
-
-	return idr_find_slowpath(idr, id);
+	return radix_tree_lookup(&idr->idr_rt, id);
 }
 
 /**
  * idr_for_each_entry - iterate over an idr's elements of a given type
- * @idp:     idr handle
+ * @idr:     idr handle
  * @entry:   the type * to use as cursor
  * @id:      id entry's key
  *
@@ -157,57 +135,58 @@ static inline void *idr_find(struct idr *idr, int id)
  * after normal terminatinon @entry is left with the value NULL.  This
  * is convenient for a "not found" value.
  */
-#define idr_for_each_entry(idp, entry, id)			\
-	for (id = 0; ((entry) = idr_get_next(idp, &(id))) != NULL; ++id)
+#define idr_for_each_entry(idr, entry, id)			\
+	for (id = 0; ((entry) = idr_get_next(idr, &(id))) != NULL; ++id)
 
 /**
- * idr_for_each_entry - continue iteration over an idr's elements of a given type
- * @idp:     idr handle
+ * idr_for_each_entry_continue - continue iteration over an idr's elements of a given type
+ * @idr:     idr handle
  * @entry:   the type * to use as cursor
  * @id:      id entry's key
  *
  * Continue to iterate over list of given type, continuing after
  * the current position.
  */
-#define idr_for_each_entry_continue(idp, entry, id)			\
-	for ((entry) = idr_get_next((idp), &(id));			\
+#define idr_for_each_entry_continue(idr, entry, id)			\
+	for ((entry) = idr_get_next((idr), &(id));			\
 	     entry;							\
-	     ++id, (entry) = idr_get_next((idp), &(id)))
+	     ++id, (entry) = idr_get_next((idr), &(id)))
 
 /*
  * IDA - IDR based id allocator, use when translation from id to
  * pointer isn't necessary.
- *
- * IDA_BITMAP_LONGS is calculated to be one less to accommodate
- * ida_bitmap->nr_busy so that the whole struct fits in 128 bytes.
  */
 #define IDA_CHUNK_SIZE		128	/* 128 bytes per chunk */
-#define IDA_BITMAP_LONGS	(IDA_CHUNK_SIZE / sizeof(long) - 1)
+#define IDA_BITMAP_LONGS	(IDA_CHUNK_SIZE / sizeof(long))
 #define IDA_BITMAP_BITS 	(IDA_BITMAP_LONGS * sizeof(long) * 8)
 
 struct ida_bitmap {
-	long			nr_busy;
 	unsigned long		bitmap[IDA_BITMAP_LONGS];
 };
 
 struct ida {
-	struct idr		idr;
+	struct radix_tree_root	ida_rt;
 	struct ida_bitmap	*free_bitmap;
 };
 
-#define IDA_INIT(name)		{ .idr = IDR_INIT((name).idr), .free_bitmap = NULL, }
-#define DEFINE_IDA(name)	struct ida name = IDA_INIT(name)
+#define IDA_INIT		{ .ida_rt = RADIX_TREE_INIT(IDR_RT_MARKER), }
+#define DEFINE_IDA(name)	struct ida name = IDA_INIT
 
 int ida_pre_get(struct ida *ida, gfp_t gfp_mask);
 int ida_get_new_above(struct ida *ida, int starting_id, int *p_id);
 void ida_remove(struct ida *ida, int id);
 void ida_destroy(struct ida *ida);
-void ida_init(struct ida *ida);
 
 int ida_simple_get(struct ida *ida, unsigned int start, unsigned int end,
 		   gfp_t gfp_mask);
 void ida_simple_remove(struct ida *ida, unsigned int id);
 
+static inline void ida_init(struct ida *ida)
+{
+	memset(ida, 0, sizeof(*ida));
+	ida->ida_rt.gfp_mask = IDR_RT_MARKER;
+}
+
 /**
  * ida_get_new - allocate new ID
  * @ida:	idr handle
@@ -222,9 +201,6 @@ static inline int ida_get_new(struct ida *ida, int *p_id)
 
 static inline bool ida_is_empty(struct ida *ida)
 {
-	return idr_is_empty(&ida->idr);
+	return radix_tree_empty(&ida->ida_rt);
 }
-
-void __init idr_init_cache(void);
-
 #endif /* __IDR_H__ */
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index ca4eea1..6483c73c 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -98,7 +98,10 @@ struct radix_tree_node {
 	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
 };
 
-/* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
+/* The top bits of gfp_mask are used to store the root tags and the IDR flag */
+#define ROOT_IS_IDR	(1 << __GFP_BITS_SHIFT)
+#define ROOT_TAG_SHIFT	(__GFP_BITS_SHIFT + 1)
+
 struct radix_tree_root {
 	gfp_t			gfp_mask;
 	struct radix_tree_node	__rcu *rnode;
diff --git a/init/main.c b/init/main.c
index 2858be7..2757b84 100644
--- a/init/main.c
+++ b/init/main.c
@@ -550,14 +550,13 @@ asmlinkage __visible void __init start_kernel(void)
 	if (WARN(!irqs_disabled(),
 		 "Interrupts were enabled *very* early, fixing it\n"))
 		local_irq_disable();
-	idr_init_cache();
+	radix_tree_init();
 	rcu_init();
 
 	/* trace_printk() and trace points may be used after this */
 	trace_init();
 
 	context_tracking_init();
-	radix_tree_init();
 	/* init some links before init_ISA_irqs() */
 	early_irq_init();
 	init_IRQ();
diff --git a/lib/idr.c b/lib/idr.c
index 6098336..3c88abb7 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -1,1068 +1,8 @@
-/*
- * 2002-10-18  written by Jim Houston jim.houston@ccur.com
- *	Copyright (C) 2002 by Concurrent Computer Corporation
- *	Distributed under the GNU GPL license version 2.
- *
- * Modified by George Anzinger to reuse immediately and to use
- * find bit instructions.  Also removed _irq on spinlocks.
- *
- * Modified by Nadia Derbey to make it RCU safe.
- *
- * Small id to pointer translation service.
- *
- * It uses a radix tree like structure as a sparse array indexed
- * by the id to obtain the pointer.  The bitmap makes allocating
- * a new id quick.
- *
- * You call it to allocate an id (an int) an associate with that id a
- * pointer or what ever, we treat it as a (void *).  You can pass this
- * id to a user for him to pass back at a later time.  You then pass
- * that id to this code and it returns your pointer.
- */
-
-#ifndef TEST                        // to test in user space...
-#include <linux/slab.h>
-#include <linux/init.h>
-#include <linux/export.h>
-#endif
-#include <linux/err.h>
-#include <linux/string.h>
 #include <linux/idr.h>
 #include <linux/spinlock.h>
-#include <linux/percpu.h>
-
-#define MAX_IDR_SHIFT		(sizeof(int) * 8 - 1)
-#define MAX_IDR_BIT		(1U << MAX_IDR_SHIFT)
-
-/* Leave the possibility of an incomplete final layer */
-#define MAX_IDR_LEVEL ((MAX_IDR_SHIFT + IDR_BITS - 1) / IDR_BITS)
-
-/* Number of id_layer structs to leave in free list */
-#define MAX_IDR_FREE (MAX_IDR_LEVEL * 2)
 
-static struct kmem_cache *idr_layer_cache;
-static DEFINE_PER_CPU(struct idr_layer *, idr_preload_head);
-static DEFINE_PER_CPU(int, idr_preload_cnt);
 static DEFINE_SPINLOCK(simple_ida_lock);
 
-/* the maximum ID which can be allocated given idr->layers */
-static int idr_max(int layers)
-{
-	int bits = min_t(int, layers * IDR_BITS, MAX_IDR_SHIFT);
-
-	return (1 << bits) - 1;
-}
-
-/*
- * Prefix mask for an idr_layer at @layer.  For layer 0, the prefix mask is
- * all bits except for the lower IDR_BITS.  For layer 1, 2 * IDR_BITS, and
- * so on.
- */
-static int idr_layer_prefix_mask(int layer)
-{
-	return ~idr_max(layer + 1);
-}
-
-static struct idr_layer *get_from_free_list(struct idr *idp)
-{
-	struct idr_layer *p;
-	unsigned long flags;
-
-	spin_lock_irqsave(&idp->lock, flags);
-	if ((p = idp->id_free)) {
-		idp->id_free = p->ary[0];
-		idp->id_free_cnt--;
-		p->ary[0] = NULL;
-	}
-	spin_unlock_irqrestore(&idp->lock, flags);
-	return(p);
-}
-
-/**
- * idr_layer_alloc - allocate a new idr_layer
- * @gfp_mask: allocation mask
- * @layer_idr: optional idr to allocate from
- *
- * If @layer_idr is %NULL, directly allocate one using @gfp_mask or fetch
- * one from the per-cpu preload buffer.  If @layer_idr is not %NULL, fetch
- * an idr_layer from @idr->id_free.
- *
- * @layer_idr is to maintain backward compatibility with the old alloc
- * interface - idr_pre_get() and idr_get_new*() - and will be removed
- * together with per-pool preload buffer.
- */
-static struct idr_layer *idr_layer_alloc(gfp_t gfp_mask, struct idr *layer_idr)
-{
-	struct idr_layer *new;
-
-	/* this is the old path, bypass to get_from_free_list() */
-	if (layer_idr)
-		return get_from_free_list(layer_idr);
-
-	/*
-	 * Try to allocate directly from kmem_cache.  We want to try this
-	 * before preload buffer; otherwise, non-preloading idr_alloc()
-	 * users will end up taking advantage of preloading ones.  As the
-	 * following is allowed to fail for preloaded cases, suppress
-	 * warning this time.
-	 */
-	new = kmem_cache_zalloc(idr_layer_cache, gfp_mask | __GFP_NOWARN);
-	if (new)
-		return new;
-
-	/*
-	 * Try to fetch one from the per-cpu preload buffer if in process
-	 * context.  See idr_preload() for details.
-	 */
-	if (!in_interrupt()) {
-		preempt_disable();
-		new = __this_cpu_read(idr_preload_head);
-		if (new) {
-			__this_cpu_write(idr_preload_head, new->ary[0]);
-			__this_cpu_dec(idr_preload_cnt);
-			new->ary[0] = NULL;
-		}
-		preempt_enable();
-		if (new)
-			return new;
-	}
-
-	/*
-	 * Both failed.  Try kmem_cache again w/o adding __GFP_NOWARN so
-	 * that memory allocation failure warning is printed as intended.
-	 */
-	return kmem_cache_zalloc(idr_layer_cache, gfp_mask);
-}
-
-static void idr_layer_rcu_free(struct rcu_head *head)
-{
-	struct idr_layer *layer;
-
-	layer = container_of(head, struct idr_layer, rcu_head);
-	kmem_cache_free(idr_layer_cache, layer);
-}
-
-static inline void free_layer(struct idr *idr, struct idr_layer *p)
-{
-	if (idr->hint == p)
-		RCU_INIT_POINTER(idr->hint, NULL);
-	call_rcu(&p->rcu_head, idr_layer_rcu_free);
-}
-
-/* only called when idp->lock is held */
-static void __move_to_free_list(struct idr *idp, struct idr_layer *p)
-{
-	p->ary[0] = idp->id_free;
-	idp->id_free = p;
-	idp->id_free_cnt++;
-}
-
-static void move_to_free_list(struct idr *idp, struct idr_layer *p)
-{
-	unsigned long flags;
-
-	/*
-	 * Depends on the return element being zeroed.
-	 */
-	spin_lock_irqsave(&idp->lock, flags);
-	__move_to_free_list(idp, p);
-	spin_unlock_irqrestore(&idp->lock, flags);
-}
-
-static void idr_mark_full(struct idr_layer **pa, int id)
-{
-	struct idr_layer *p = pa[0];
-	int l = 0;
-
-	__set_bit(id & IDR_MASK, p->bitmap);
-	/*
-	 * If this layer is full mark the bit in the layer above to
-	 * show that this part of the radix tree is full.  This may
-	 * complete the layer above and require walking up the radix
-	 * tree.
-	 */
-	while (bitmap_full(p->bitmap, IDR_SIZE)) {
-		if (!(p = pa[++l]))
-			break;
-		id = id >> IDR_BITS;
-		__set_bit((id & IDR_MASK), p->bitmap);
-	}
-}
-
-static int __idr_pre_get(struct idr *idp, gfp_t gfp_mask)
-{
-	while (idp->id_free_cnt < MAX_IDR_FREE) {
-		struct idr_layer *new;
-		new = kmem_cache_zalloc(idr_layer_cache, gfp_mask);
-		if (new == NULL)
-			return (0);
-		move_to_free_list(idp, new);
-	}
-	return 1;
-}
-
-/**
- * sub_alloc - try to allocate an id without growing the tree depth
- * @idp: idr handle
- * @starting_id: id to start search at
- * @pa: idr_layer[MAX_IDR_LEVEL] used as backtrack buffer
- * @gfp_mask: allocation mask for idr_layer_alloc()
- * @layer_idr: optional idr passed to idr_layer_alloc()
- *
- * Allocate an id in range [@starting_id, INT_MAX] from @idp without
- * growing its depth.  Returns
- *
- *  the allocated id >= 0 if successful,
- *  -EAGAIN if the tree needs to grow for allocation to succeed,
- *  -ENOSPC if the id space is exhausted,
- *  -ENOMEM if more idr_layers need to be allocated.
- */
-static int sub_alloc(struct idr *idp, int *starting_id, struct idr_layer **pa,
-		     gfp_t gfp_mask, struct idr *layer_idr)
-{
-	int n, m, sh;
-	struct idr_layer *p, *new;
-	int l, id, oid;
-
-	id = *starting_id;
- restart:
-	p = idp->top;
-	l = idp->layers;
-	pa[l--] = NULL;
-	while (1) {
-		/*
-		 * We run around this while until we reach the leaf node...
-		 */
-		n = (id >> (IDR_BITS*l)) & IDR_MASK;
-		m = find_next_zero_bit(p->bitmap, IDR_SIZE, n);
-		if (m == IDR_SIZE) {
-			/* no space available go back to previous layer. */
-			l++;
-			oid = id;
-			id = (id | ((1 << (IDR_BITS * l)) - 1)) + 1;
-
-			/* if already at the top layer, we need to grow */
-			if (id > idr_max(idp->layers)) {
-				*starting_id = id;
-				return -EAGAIN;
-			}
-			p = pa[l];
-			BUG_ON(!p);
-
-			/* If we need to go up one layer, continue the
-			 * loop; otherwise, restart from the top.
-			 */
-			sh = IDR_BITS * (l + 1);
-			if (oid >> sh == id >> sh)
-				continue;
-			else
-				goto restart;
-		}
-		if (m != n) {
-			sh = IDR_BITS*l;
-			id = ((id >> sh) ^ n ^ m) << sh;
-		}
-		if ((id >= MAX_IDR_BIT) || (id < 0))
-			return -ENOSPC;
-		if (l == 0)
-			break;
-		/*
-		 * Create the layer below if it is missing.
-		 */
-		if (!p->ary[m]) {
-			new = idr_layer_alloc(gfp_mask, layer_idr);
-			if (!new)
-				return -ENOMEM;
-			new->layer = l-1;
-			new->prefix = id & idr_layer_prefix_mask(new->layer);
-			rcu_assign_pointer(p->ary[m], new);
-			p->count++;
-		}
-		pa[l--] = p;
-		p = p->ary[m];
-	}
-
-	pa[l] = p;
-	return id;
-}
-
-static int idr_get_empty_slot(struct idr *idp, int starting_id,
-			      struct idr_layer **pa, gfp_t gfp_mask,
-			      struct idr *layer_idr)
-{
-	struct idr_layer *p, *new;
-	int layers, v, id;
-	unsigned long flags;
-
-	id = starting_id;
-build_up:
-	p = idp->top;
-	layers = idp->layers;
-	if (unlikely(!p)) {
-		if (!(p = idr_layer_alloc(gfp_mask, layer_idr)))
-			return -ENOMEM;
-		p->layer = 0;
-		layers = 1;
-	}
-	/*
-	 * Add a new layer to the top of the tree if the requested
-	 * id is larger than the currently allocated space.
-	 */
-	while (id > idr_max(layers)) {
-		layers++;
-		if (!p->count) {
-			/* special case: if the tree is currently empty,
-			 * then we grow the tree by moving the top node
-			 * upwards.
-			 */
-			p->layer++;
-			WARN_ON_ONCE(p->prefix);
-			continue;
-		}
-		if (!(new = idr_layer_alloc(gfp_mask, layer_idr))) {
-			/*
-			 * The allocation failed.  If we built part of
-			 * the structure tear it down.
-			 */
-			spin_lock_irqsave(&idp->lock, flags);
-			for (new = p; p && p != idp->top; new = p) {
-				p = p->ary[0];
-				new->ary[0] = NULL;
-				new->count = 0;
-				bitmap_clear(new->bitmap, 0, IDR_SIZE);
-				__move_to_free_list(idp, new);
-			}
-			spin_unlock_irqrestore(&idp->lock, flags);
-			return -ENOMEM;
-		}
-		new->ary[0] = p;
-		new->count = 1;
-		new->layer = layers-1;
-		new->prefix = id & idr_layer_prefix_mask(new->layer);
-		if (bitmap_full(p->bitmap, IDR_SIZE))
-			__set_bit(0, new->bitmap);
-		p = new;
-	}
-	rcu_assign_pointer(idp->top, p);
-	idp->layers = layers;
-	v = sub_alloc(idp, &id, pa, gfp_mask, layer_idr);
-	if (v == -EAGAIN)
-		goto build_up;
-	return(v);
-}
-
-/*
- * @id and @pa are from a successful allocation from idr_get_empty_slot().
- * Install the user pointer @ptr and mark the slot full.
- */
-static void idr_fill_slot(struct idr *idr, void *ptr, int id,
-			  struct idr_layer **pa)
-{
-	/* update hint used for lookup, cleared from free_layer() */
-	rcu_assign_pointer(idr->hint, pa[0]);
-
-	rcu_assign_pointer(pa[0]->ary[id & IDR_MASK], (struct idr_layer *)ptr);
-	pa[0]->count++;
-	idr_mark_full(pa, id);
-}
-
-
-/**
- * idr_preload - preload for idr_alloc()
- * @gfp_mask: allocation mask to use for preloading
- *
- * Preload per-cpu layer buffer for idr_alloc().  Can only be used from
- * process context and each idr_preload() invocation should be matched with
- * idr_preload_end().  Note that preemption is disabled while preloaded.
- *
- * The first idr_alloc() in the preloaded section can be treated as if it
- * were invoked with @gfp_mask used for preloading.  This allows using more
- * permissive allocation masks for idrs protected by spinlocks.
- *
- * For example, if idr_alloc() below fails, the failure can be treated as
- * if idr_alloc() were called with GFP_KERNEL rather than GFP_NOWAIT.
- *
- *	idr_preload(GFP_KERNEL);
- *	spin_lock(lock);
- *
- *	id = idr_alloc(idr, ptr, start, end, GFP_NOWAIT);
- *
- *	spin_unlock(lock);
- *	idr_preload_end();
- *	if (id < 0)
- *		error;
- */
-void idr_preload(gfp_t gfp_mask)
-{
-	/*
-	 * Consuming preload buffer from non-process context breaks preload
-	 * allocation guarantee.  Disallow usage from those contexts.
-	 */
-	WARN_ON_ONCE(in_interrupt());
-	might_sleep_if(gfpflags_allow_blocking(gfp_mask));
-
-	preempt_disable();
-
-	/*
-	 * idr_alloc() is likely to succeed w/o full idr_layer buffer and
-	 * return value from idr_alloc() needs to be checked for failure
-	 * anyway.  Silently give up if allocation fails.  The caller can
-	 * treat failures from idr_alloc() as if idr_alloc() were called
-	 * with @gfp_mask which should be enough.
-	 */
-	while (__this_cpu_read(idr_preload_cnt) < MAX_IDR_FREE) {
-		struct idr_layer *new;
-
-		preempt_enable();
-		new = kmem_cache_zalloc(idr_layer_cache, gfp_mask);
-		preempt_disable();
-		if (!new)
-			break;
-
-		/* link the new one to per-cpu preload list */
-		new->ary[0] = __this_cpu_read(idr_preload_head);
-		__this_cpu_write(idr_preload_head, new);
-		__this_cpu_inc(idr_preload_cnt);
-	}
-}
-EXPORT_SYMBOL(idr_preload);
-
-/**
- * idr_alloc - allocate new idr entry
- * @idr: the (initialized) idr
- * @ptr: pointer to be associated with the new id
- * @start: the minimum id (inclusive)
- * @end: the maximum id (exclusive, <= 0 for max)
- * @gfp_mask: memory allocation flags
- *
- * Allocate an id in [start, end) and associate it with @ptr.  If no ID is
- * available in the specified range, returns -ENOSPC.  On memory allocation
- * failure, returns -ENOMEM.
- *
- * Note that @end is treated as max when <= 0.  This is to always allow
- * using @start + N as @end as long as N is inside integer range.
- *
- * The user is responsible for exclusively synchronizing all operations
- * which may modify @idr.  However, read-only accesses such as idr_find()
- * or iteration can be performed under RCU read lock provided the user
- * destroys @ptr in RCU-safe way after removal from idr.
- */
-int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp_mask)
-{
-	int max = end > 0 ? end - 1 : INT_MAX;	/* inclusive upper limit */
-	struct idr_layer *pa[MAX_IDR_LEVEL + 1];
-	int id;
-
-	might_sleep_if(gfpflags_allow_blocking(gfp_mask));
-
-	/* sanity checks */
-	if (WARN_ON_ONCE(start < 0))
-		return -EINVAL;
-	if (unlikely(max < start))
-		return -ENOSPC;
-
-	/* allocate id */
-	id = idr_get_empty_slot(idr, start, pa, gfp_mask, NULL);
-	if (unlikely(id < 0))
-		return id;
-	if (unlikely(id > max))
-		return -ENOSPC;
-
-	idr_fill_slot(idr, ptr, id, pa);
-	return id;
-}
-EXPORT_SYMBOL_GPL(idr_alloc);
-
-/**
- * idr_alloc_cyclic - allocate new idr entry in a cyclical fashion
- * @idr: the (initialized) idr
- * @ptr: pointer to be associated with the new id
- * @start: the minimum id (inclusive)
- * @end: the maximum id (exclusive, <= 0 for max)
- * @gfp_mask: memory allocation flags
- *
- * Essentially the same as idr_alloc, but prefers to allocate progressively
- * higher ids if it can. If the "cur" counter wraps, then it will start again
- * at the "start" end of the range and allocate one that has already been used.
- */
-int idr_alloc_cyclic(struct idr *idr, void *ptr, int start, int end,
-			gfp_t gfp_mask)
-{
-	int id;
-
-	id = idr_alloc(idr, ptr, max(start, idr->cur), end, gfp_mask);
-	if (id == -ENOSPC)
-		id = idr_alloc(idr, ptr, start, end, gfp_mask);
-
-	if (likely(id >= 0))
-		idr->cur = id + 1;
-	return id;
-}
-EXPORT_SYMBOL(idr_alloc_cyclic);
-
-static void idr_remove_warning(int id)
-{
-	WARN(1, "idr_remove called for id=%d which is not allocated.\n", id);
-}
-
-static void sub_remove(struct idr *idp, int shift, int id)
-{
-	struct idr_layer *p = idp->top;
-	struct idr_layer **pa[MAX_IDR_LEVEL + 1];
-	struct idr_layer ***paa = &pa[0];
-	struct idr_layer *to_free;
-	int n;
-
-	*paa = NULL;
-	*++paa = &idp->top;
-
-	while ((shift > 0) && p) {
-		n = (id >> shift) & IDR_MASK;
-		__clear_bit(n, p->bitmap);
-		*++paa = &p->ary[n];
-		p = p->ary[n];
-		shift -= IDR_BITS;
-	}
-	n = id & IDR_MASK;
-	if (likely(p != NULL && test_bit(n, p->bitmap))) {
-		__clear_bit(n, p->bitmap);
-		RCU_INIT_POINTER(p->ary[n], NULL);
-		to_free = NULL;
-		while(*paa && ! --((**paa)->count)){
-			if (to_free)
-				free_layer(idp, to_free);
-			to_free = **paa;
-			**paa-- = NULL;
-		}
-		if (!*paa)
-			idp->layers = 0;
-		if (to_free)
-			free_layer(idp, to_free);
-	} else
-		idr_remove_warning(id);
-}
-
-/**
- * idr_remove - remove the given id and free its slot
- * @idp: idr handle
- * @id: unique key
- */
-void idr_remove(struct idr *idp, int id)
-{
-	struct idr_layer *p;
-	struct idr_layer *to_free;
-
-	if (id < 0)
-		return;
-
-	if (id > idr_max(idp->layers)) {
-		idr_remove_warning(id);
-		return;
-	}
-
-	sub_remove(idp, (idp->layers - 1) * IDR_BITS, id);
-	if (idp->top && idp->top->count == 1 && (idp->layers > 1) &&
-	    idp->top->ary[0]) {
-		/*
-		 * Single child at leftmost slot: we can shrink the tree.
-		 * This level is not needed anymore since when layers are
-		 * inserted, they are inserted at the top of the existing
-		 * tree.
-		 */
-		to_free = idp->top;
-		p = idp->top->ary[0];
-		rcu_assign_pointer(idp->top, p);
-		--idp->layers;
-		to_free->count = 0;
-		bitmap_clear(to_free->bitmap, 0, IDR_SIZE);
-		free_layer(idp, to_free);
-	}
-}
-EXPORT_SYMBOL(idr_remove);
-
-static void __idr_remove_all(struct idr *idp)
-{
-	int n, id, max;
-	int bt_mask;
-	struct idr_layer *p;
-	struct idr_layer *pa[MAX_IDR_LEVEL + 1];
-	struct idr_layer **paa = &pa[0];
-
-	n = idp->layers * IDR_BITS;
-	*paa = idp->top;
-	RCU_INIT_POINTER(idp->top, NULL);
-	max = idr_max(idp->layers);
-
-	id = 0;
-	while (id >= 0 && id <= max) {
-		p = *paa;
-		while (n > IDR_BITS && p) {
-			n -= IDR_BITS;
-			p = p->ary[(id >> n) & IDR_MASK];
-			*++paa = p;
-		}
-
-		bt_mask = id;
-		id += 1 << n;
-		/* Get the highest bit that the above add changed from 0->1. */
-		while (n < fls(id ^ bt_mask)) {
-			if (*paa)
-				free_layer(idp, *paa);
-			n += IDR_BITS;
-			--paa;
-		}
-	}
-	idp->layers = 0;
-}
-
-/**
- * idr_destroy - release all cached layers within an idr tree
- * @idp: idr handle
- *
- * Free all id mappings and all idp_layers.  After this function, @idp is
- * completely unused and can be freed / recycled.  The caller is
- * responsible for ensuring that no one else accesses @idp during or after
- * idr_destroy().
- *
- * A typical clean-up sequence for objects stored in an idr tree will use
- * idr_for_each() to free all objects, if necessary, then idr_destroy() to
- * free up the id mappings and cached idr_layers.
- */
-void idr_destroy(struct idr *idp)
-{
-	__idr_remove_all(idp);
-
-	while (idp->id_free_cnt) {
-		struct idr_layer *p = get_from_free_list(idp);
-		kmem_cache_free(idr_layer_cache, p);
-	}
-}
-EXPORT_SYMBOL(idr_destroy);
-
-void *idr_find_slowpath(struct idr *idp, int id)
-{
-	int n;
-	struct idr_layer *p;
-
-	if (id < 0)
-		return NULL;
-
-	p = rcu_dereference_raw(idp->top);
-	if (!p)
-		return NULL;
-	n = (p->layer+1) * IDR_BITS;
-
-	if (id > idr_max(p->layer + 1))
-		return NULL;
-	BUG_ON(n == 0);
-
-	while (n > 0 && p) {
-		n -= IDR_BITS;
-		BUG_ON(n != p->layer*IDR_BITS);
-		p = rcu_dereference_raw(p->ary[(id >> n) & IDR_MASK]);
-	}
-	return((void *)p);
-}
-EXPORT_SYMBOL(idr_find_slowpath);
-
-/**
- * idr_for_each - iterate through all stored pointers
- * @idp: idr handle
- * @fn: function to be called for each pointer
- * @data: data passed back to callback function
- *
- * Iterate over the pointers registered with the given idr.  The
- * callback function will be called for each pointer currently
- * registered, passing the id, the pointer and the data pointer passed
- * to this function.  It is not safe to modify the idr tree while in
- * the callback, so functions such as idr_get_new and idr_remove are
- * not allowed.
- *
- * We check the return of @fn each time. If it returns anything other
- * than %0, we break out and return that value.
- *
- * The caller must serialize idr_for_each() vs idr_get_new() and idr_remove().
- */
-int idr_for_each(struct idr *idp,
-		 int (*fn)(int id, void *p, void *data), void *data)
-{
-	int n, id, max, error = 0;
-	struct idr_layer *p;
-	struct idr_layer *pa[MAX_IDR_LEVEL + 1];
-	struct idr_layer **paa = &pa[0];
-
-	n = idp->layers * IDR_BITS;
-	*paa = rcu_dereference_raw(idp->top);
-	max = idr_max(idp->layers);
-
-	id = 0;
-	while (id >= 0 && id <= max) {
-		p = *paa;
-		while (n > 0 && p) {
-			n -= IDR_BITS;
-			p = rcu_dereference_raw(p->ary[(id >> n) & IDR_MASK]);
-			*++paa = p;
-		}
-
-		if (p) {
-			error = fn(id, (void *)p, data);
-			if (error)
-				break;
-		}
-
-		id += 1 << n;
-		while (n < fls(id)) {
-			n += IDR_BITS;
-			--paa;
-		}
-	}
-
-	return error;
-}
-EXPORT_SYMBOL(idr_for_each);
-
-/**
- * idr_get_next - lookup next object of id to given id.
- * @idp: idr handle
- * @nextidp:  pointer to lookup key
- *
- * Returns pointer to registered object with id, which is next number to
- * given id. After being looked up, *@nextidp will be updated for the next
- * iteration.
- *
- * This function can be called under rcu_read_lock(), given that the leaf
- * pointers lifetimes are correctly managed.
- */
-void *idr_get_next(struct idr *idp, int *nextidp)
-{
-	struct idr_layer *p, *pa[MAX_IDR_LEVEL + 1];
-	struct idr_layer **paa = &pa[0];
-	int id = *nextidp;
-	int n, max;
-
-	/* find first ent */
-	p = *paa = rcu_dereference_raw(idp->top);
-	if (!p)
-		return NULL;
-	n = (p->layer + 1) * IDR_BITS;
-	max = idr_max(p->layer + 1);
-
-	while (id >= 0 && id <= max) {
-		p = *paa;
-		while (n > 0 && p) {
-			n -= IDR_BITS;
-			p = rcu_dereference_raw(p->ary[(id >> n) & IDR_MASK]);
-			*++paa = p;
-		}
-
-		if (p) {
-			*nextidp = id;
-			return p;
-		}
-
-		/*
-		 * Proceed to the next layer at the current level.  Unlike
-		 * idr_for_each(), @id isn't guaranteed to be aligned to
-		 * layer boundary at this point and adding 1 << n may
-		 * incorrectly skip IDs.  Make sure we jump to the
-		 * beginning of the next layer using round_up().
-		 */
-		id = round_up(id + 1, 1 << n);
-		while (n < fls(id)) {
-			n += IDR_BITS;
-			--paa;
-		}
-	}
-	return NULL;
-}
-EXPORT_SYMBOL(idr_get_next);
-
-
-/**
- * idr_replace - replace pointer for given id
- * @idp: idr handle
- * @ptr: pointer you want associated with the id
- * @id: lookup key
- *
- * Replace the pointer registered with an id and return the old value.
- * A %-ENOENT return indicates that @id was not found.
- * A %-EINVAL return indicates that @id was not within valid constraints.
- *
- * The caller must serialize with writers.
- */
-void *idr_replace(struct idr *idp, void *ptr, int id)
-{
-	int n;
-	struct idr_layer *p, *old_p;
-
-	if (id < 0)
-		return ERR_PTR(-EINVAL);
-
-	p = idp->top;
-	if (!p)
-		return ERR_PTR(-ENOENT);
-
-	if (id > idr_max(p->layer + 1))
-		return ERR_PTR(-ENOENT);
-
-	n = p->layer * IDR_BITS;
-	while ((n > 0) && p) {
-		p = p->ary[(id >> n) & IDR_MASK];
-		n -= IDR_BITS;
-	}
-
-	n = id & IDR_MASK;
-	if (unlikely(p == NULL || !test_bit(n, p->bitmap)))
-		return ERR_PTR(-ENOENT);
-
-	old_p = p->ary[n];
-	rcu_assign_pointer(p->ary[n], ptr);
-
-	return old_p;
-}
-EXPORT_SYMBOL(idr_replace);
-
-void __init idr_init_cache(void)
-{
-	idr_layer_cache = kmem_cache_create("idr_layer_cache",
-				sizeof(struct idr_layer), 0, SLAB_PANIC, NULL);
-}
-
-/**
- * idr_init - initialize idr handle
- * @idp:	idr handle
- *
- * This function is use to set up the handle (@idp) that you will pass
- * to the rest of the functions.
- */
-void idr_init(struct idr *idp)
-{
-	memset(idp, 0, sizeof(struct idr));
-	spin_lock_init(&idp->lock);
-}
-EXPORT_SYMBOL(idr_init);
-
-static int idr_has_entry(int id, void *p, void *data)
-{
-	return 1;
-}
-
-bool idr_is_empty(struct idr *idp)
-{
-	return !idr_for_each(idp, idr_has_entry, NULL);
-}
-EXPORT_SYMBOL(idr_is_empty);
-
-/**
- * DOC: IDA description
- * IDA - IDR based ID allocator
- *
- * This is id allocator without id -> pointer translation.  Memory
- * usage is much lower than full blown idr because each id only
- * occupies a bit.  ida uses a custom leaf node which contains
- * IDA_BITMAP_BITS slots.
- *
- * 2007-04-25  written by Tejun Heo <htejun@gmail.com>
- */
-
-static void free_bitmap(struct ida *ida, struct ida_bitmap *bitmap)
-{
-	unsigned long flags;
-
-	if (!ida->free_bitmap) {
-		spin_lock_irqsave(&ida->idr.lock, flags);
-		if (!ida->free_bitmap) {
-			ida->free_bitmap = bitmap;
-			bitmap = NULL;
-		}
-		spin_unlock_irqrestore(&ida->idr.lock, flags);
-	}
-
-	kfree(bitmap);
-}
-
-/**
- * ida_pre_get - reserve resources for ida allocation
- * @ida:	ida handle
- * @gfp_mask:	memory allocation flag
- *
- * This function should be called prior to locking and calling the
- * following function.  It preallocates enough memory to satisfy the
- * worst possible allocation.
- *
- * If the system is REALLY out of memory this function returns %0,
- * otherwise %1.
- */
-int ida_pre_get(struct ida *ida, gfp_t gfp_mask)
-{
-	/* allocate idr_layers */
-	if (!__idr_pre_get(&ida->idr, gfp_mask))
-		return 0;
-
-	/* allocate free_bitmap */
-	if (!ida->free_bitmap) {
-		struct ida_bitmap *bitmap;
-
-		bitmap = kmalloc(sizeof(struct ida_bitmap), gfp_mask);
-		if (!bitmap)
-			return 0;
-
-		free_bitmap(ida, bitmap);
-	}
-
-	return 1;
-}
-EXPORT_SYMBOL(ida_pre_get);
-
-/**
- * ida_get_new_above - allocate new ID above or equal to a start id
- * @ida:	ida handle
- * @starting_id: id to start search at
- * @p_id:	pointer to the allocated handle
- *
- * Allocate new ID above or equal to @starting_id.  It should be called
- * with any required locks.
- *
- * If memory is required, it will return %-EAGAIN, you should unlock
- * and go back to the ida_pre_get() call.  If the ida is full, it will
- * return %-ENOSPC.
- *
- * @p_id returns a value in the range @starting_id ... %0x7fffffff.
- */
-int ida_get_new_above(struct ida *ida, int starting_id, int *p_id)
-{
-	struct idr_layer *pa[MAX_IDR_LEVEL + 1];
-	struct ida_bitmap *bitmap;
-	unsigned long flags;
-	int idr_id = starting_id / IDA_BITMAP_BITS;
-	int offset = starting_id % IDA_BITMAP_BITS;
-	int t, id;
-
- restart:
-	/* get vacant slot */
-	t = idr_get_empty_slot(&ida->idr, idr_id, pa, 0, &ida->idr);
-	if (t < 0)
-		return t == -ENOMEM ? -EAGAIN : t;
-
-	if (t * IDA_BITMAP_BITS >= MAX_IDR_BIT)
-		return -ENOSPC;
-
-	if (t != idr_id)
-		offset = 0;
-	idr_id = t;
-
-	/* if bitmap isn't there, create a new one */
-	bitmap = (void *)pa[0]->ary[idr_id & IDR_MASK];
-	if (!bitmap) {
-		spin_lock_irqsave(&ida->idr.lock, flags);
-		bitmap = ida->free_bitmap;
-		ida->free_bitmap = NULL;
-		spin_unlock_irqrestore(&ida->idr.lock, flags);
-
-		if (!bitmap)
-			return -EAGAIN;
-
-		memset(bitmap, 0, sizeof(struct ida_bitmap));
-		rcu_assign_pointer(pa[0]->ary[idr_id & IDR_MASK],
-				(void *)bitmap);
-		pa[0]->count++;
-	}
-
-	/* lookup for empty slot */
-	t = find_next_zero_bit(bitmap->bitmap, IDA_BITMAP_BITS, offset);
-	if (t == IDA_BITMAP_BITS) {
-		/* no empty slot after offset, continue to the next chunk */
-		idr_id++;
-		offset = 0;
-		goto restart;
-	}
-
-	id = idr_id * IDA_BITMAP_BITS + t;
-	if (id >= MAX_IDR_BIT)
-		return -ENOSPC;
-
-	__set_bit(t, bitmap->bitmap);
-	if (++bitmap->nr_busy == IDA_BITMAP_BITS)
-		idr_mark_full(pa, idr_id);
-
-	*p_id = id;
-
-	/* Each leaf node can handle nearly a thousand slots and the
-	 * whole idea of ida is to have small memory foot print.
-	 * Throw away extra resources one by one after each successful
-	 * allocation.
-	 */
-	if (ida->idr.id_free_cnt || ida->free_bitmap) {
-		struct idr_layer *p = get_from_free_list(&ida->idr);
-		if (p)
-			kmem_cache_free(idr_layer_cache, p);
-	}
-
-	return 0;
-}
-EXPORT_SYMBOL(ida_get_new_above);
-
-/**
- * ida_remove - remove the given ID
- * @ida:	ida handle
- * @id:		ID to free
- */
-void ida_remove(struct ida *ida, int id)
-{
-	struct idr_layer *p = ida->idr.top;
-	int shift = (ida->idr.layers - 1) * IDR_BITS;
-	int idr_id = id / IDA_BITMAP_BITS;
-	int offset = id % IDA_BITMAP_BITS;
-	int n;
-	struct ida_bitmap *bitmap;
-
-	if (idr_id > idr_max(ida->idr.layers))
-		goto err;
-
-	/* clear full bits while looking up the leaf idr_layer */
-	while ((shift > 0) && p) {
-		n = (idr_id >> shift) & IDR_MASK;
-		__clear_bit(n, p->bitmap);
-		p = p->ary[n];
-		shift -= IDR_BITS;
-	}
-
-	if (p == NULL)
-		goto err;
-
-	n = idr_id & IDR_MASK;
-	__clear_bit(n, p->bitmap);
-
-	bitmap = (void *)p->ary[n];
-	if (!bitmap || !test_bit(offset, bitmap->bitmap))
-		goto err;
-
-	/* update bitmap and remove it if empty */
-	__clear_bit(offset, bitmap->bitmap);
-	if (--bitmap->nr_busy == 0) {
-		__set_bit(n, p->bitmap);	/* to please idr_remove() */
-		idr_remove(&ida->idr, idr_id);
-		free_bitmap(ida, bitmap);
-	}
-
-	return;
-
- err:
-	WARN(1, "ida_remove called for id=%d which is not allocated.\n", id);
-}
-EXPORT_SYMBOL(ida_remove);
-
-/**
- * ida_destroy - release all cached layers within an ida tree
- * @ida:		ida handle
- */
-void ida_destroy(struct ida *ida)
-{
-	idr_destroy(&ida->idr);
-	kfree(ida->free_bitmap);
-}
-EXPORT_SYMBOL(ida_destroy);
-
 /**
  * ida_simple_get - get a new id.
  * @ida: the (initialized) ida.
@@ -1130,18 +70,3 @@ void ida_simple_remove(struct ida *ida, unsigned int id)
 	spin_unlock_irqrestore(&simple_ida_lock, flags);
 }
 EXPORT_SYMBOL(ida_simple_remove);
-
-/**
- * ida_init - initialize ida handle
- * @ida:	ida handle
- *
- * This function is use to set up the handle (@ida) that you will pass
- * to the rest of the functions.
- */
-void ida_init(struct ida *ida)
-{
-	memset(ida, 0, sizeof(struct ida));
-	idr_init(&ida->idr);
-
-}
-EXPORT_SYMBOL(ida_init);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index e063ca2..3160de3 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -24,19 +24,20 @@
 
 #include <linux/bitmap.h>
 #include <linux/bitops.h>
+#include <linux/cpu.h>
 #include <linux/errno.h>
+#include <linux/export.h>
+#include <linux/idr.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
-#include <linux/export.h>
-#include <linux/radix-tree.h>
-#include <linux/percpu.h>
-#include <linux/slab.h>
 #include <linux/kmemleak.h>
 #include <linux/notifier.h>
-#include <linux/cpu.h>
-#include <linux/string.h>
-#include <linux/rcupdate.h>
+#include <linux/percpu.h>
 #include <linux/preempt.h>		/* in_interrupt() */
+#include <linux/radix-tree.h>
+#include <linux/rcupdate.h>
+#include <linux/slab.h>
+#include <linux/string.h>
 
 
 /* Number of nodes in fully populated tree of given height */
@@ -61,6 +62,15 @@ static struct kmem_cache *radix_tree_node_cachep;
 #define RADIX_TREE_PRELOAD_SIZE (RADIX_TREE_MAX_PATH * 2 - 1)
 
 /*
+ * The IDR does not have to be as high since it can only store a 31-bit integer
+ * at its maximum height
+ */
+#define IDR_INDEX_BITS		(8 /* CHAR_BIT */ * sizeof(int) - 1)
+#define IDR_MAX_PATH		(DIV_ROUND_UP(IDR_INDEX_BITS, \
+						RADIX_TREE_MAP_SHIFT))
+#define IDR_PRELOAD_SIZE	(IDR_MAX_PATH * 2 - 1)
+
+/*
  * Per-cpu pool of preloaded nodes
  */
 struct radix_tree_preload {
@@ -148,27 +158,38 @@ static inline int tag_get(struct radix_tree_node *node, unsigned int tag,
 
 static inline void root_tag_set(struct radix_tree_root *root, unsigned int tag)
 {
-	root->gfp_mask |= (__force gfp_t)(1 << (tag + __GFP_BITS_SHIFT));
+	root->gfp_mask |= (__force gfp_t)(1 << (tag + ROOT_TAG_SHIFT));
 }
 
 static inline void root_tag_clear(struct radix_tree_root *root, unsigned tag)
 {
-	root->gfp_mask &= (__force gfp_t)~(1 << (tag + __GFP_BITS_SHIFT));
+	root->gfp_mask &= (__force gfp_t)~(1 << (tag + ROOT_TAG_SHIFT));
 }
 
 static inline void root_tag_clear_all(struct radix_tree_root *root)
 {
-	root->gfp_mask &= __GFP_BITS_MASK;
+	root->gfp_mask &= (1 << ROOT_TAG_SHIFT) - 1;
 }
 
 static inline int root_tag_get(struct radix_tree_root *root, unsigned int tag)
 {
-	return (__force int)root->gfp_mask & (1 << (tag + __GFP_BITS_SHIFT));
+	return (__force int)root->gfp_mask & (1 << (tag + ROOT_TAG_SHIFT));
 }
 
 static inline unsigned root_tags_get(struct radix_tree_root *root)
 {
-	return (__force unsigned)root->gfp_mask >> __GFP_BITS_SHIFT;
+	return (__force unsigned)root->gfp_mask >> ROOT_TAG_SHIFT;
+}
+
+/*
+ * IDRs do not expose the tagging functionality of the radix tree to their
+ * users.  Reuse tag 0 to track whether a node has free space below it.
+ */
+#define IDR_FREE	0
+
+static inline bool is_idr(struct radix_tree_root *root)
+{
+	return (__force unsigned)root->gfp_mask & ROOT_IS_IDR;
 }
 
 /*
@@ -238,6 +259,13 @@ static inline unsigned long node_maxindex(struct radix_tree_node *node)
 	return shift_maxindex(node->shift);
 }
 
+static unsigned long next_index(unsigned long index,
+				struct radix_tree_node *node,
+				unsigned long offset)
+{
+	return (index & ~node_maxindex(node)) + (offset << node->shift);
+}
+
 #ifndef __KERNEL__
 static void dump_node(struct radix_tree_node *node, unsigned long index)
 {
@@ -276,11 +304,47 @@ static void radix_tree_dump(struct radix_tree_root *root)
 {
 	pr_debug("radix root: %p rnode %p tags %x\n",
 			root, root->rnode,
-			root->gfp_mask >> __GFP_BITS_SHIFT);
+			root->gfp_mask >> ROOT_TAG_SHIFT);
 	if (!radix_tree_is_internal_node(root->rnode))
 		return;
 	dump_node(entry_to_node(root->rnode), 0);
 }
+
+static void dump_ida_node(void *entry, unsigned long index)
+{
+	unsigned long i;
+
+	if (!entry)
+		return;
+
+	if (radix_tree_is_internal_node(entry)) {
+		struct radix_tree_node *node = entry_to_node(entry);
+
+		pr_debug("ida node: %p offset %d indices %lu-%lu parent %p free %lx shift %d count %d\n",
+			node, node->offset, index, index | node_maxindex(node),
+			node->parent, node->tags[0][0], node->shift,
+			node->count);
+		for (i = 0; i < RADIX_TREE_MAP_SIZE; i++)
+			dump_ida_node(node->slots[i],
+					index | (i << node->shift));
+	} else {
+		struct ida_bitmap *bitmap = entry;
+
+		pr_debug("ida btmp: %p index %lu data", bitmap, index);
+		for (i = 0; i < IDA_BITMAP_LONGS; i++)
+			pr_cont(" %lx", bitmap->bitmap[i]);
+		pr_cont("\n");
+	}
+}
+
+static void ida_dump(struct ida *ida)
+{
+	struct radix_tree_root *root = &ida->ida_rt;
+	pr_debug("ida: %p %p free %d bitmap %p\n", ida, root->rnode,
+				root->gfp_mask >> ROOT_TAG_SHIFT,
+				ida->free_bitmap);
+	dump_ida_node(root->rnode, 0);
+}
 #endif
 
 /*
@@ -288,10 +352,9 @@ static void radix_tree_dump(struct radix_tree_root *root)
  * that the caller has pinned this thread of control to the current CPU.
  */
 static struct radix_tree_node *
-radix_tree_node_alloc(struct radix_tree_root *root)
+radix_tree_node_alloc(gfp_t gfp_mask)
 {
 	struct radix_tree_node *ret = NULL;
-	gfp_t gfp_mask = root_gfp_mask(root);
 
 	/*
 	 * Preload code isn't irq safe and it doesn't make sense to use
@@ -521,7 +584,7 @@ static unsigned radix_tree_load_root(struct radix_tree_root *root,
 /*
  *	Extend a radix tree so it can store key @index.
  */
-static int radix_tree_extend(struct radix_tree_root *root,
+static int radix_tree_extend(struct radix_tree_root *root, gfp_t gfp_mask,
 				unsigned long index, unsigned int shift)
 {
 	struct radix_tree_node *slot;
@@ -538,15 +601,22 @@ static int radix_tree_extend(struct radix_tree_root *root,
 		goto out;
 
 	do {
-		struct radix_tree_node *node = radix_tree_node_alloc(root);
+		struct radix_tree_node *node = radix_tree_node_alloc(gfp_mask);
 
 		if (!node)
 			return -ENOMEM;
 
-		/* Propagate the aggregated tag info into the new root */
-		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
-			if (root_tag_get(root, tag))
-				tag_set(node, tag, 0);
+		if (is_idr(root)) {
+			all_tag_set(node, IDR_FREE);
+			if (!root_tag_get(root, IDR_FREE))
+				tag_clear(node, IDR_FREE, 0);
+			root_tag_set(root, IDR_FREE);
+		} else {
+			/* Propagate the aggregated tag info to the new child */
+			for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
+				if (root_tag_get(root, tag))
+					tag_set(node, tag, 0);
+			}
 		}
 
 		BUG_ON(shift > BITS_PER_LONG);
@@ -565,26 +635,9 @@ static int radix_tree_extend(struct radix_tree_root *root,
 	return maxshift + RADIX_TREE_MAP_SHIFT;
 }
 
-/**
- *	__radix_tree_create	-	create a slot in a radix tree
- *	@root:		radix tree root
- *	@index:		index key
- *	@order:		index occupies 2^order aligned slots
- *	@nodep:		returns node
- *	@slotp:		returns slot
- *
- *	Create, if necessary, and return the node and slot for an item
- *	at position @index in the radix tree @root.
- *
- *	Until there is more than one item in the tree, no nodes are
- *	allocated and @root->rnode is used as a direct slot instead of
- *	pointing to a node, in which case *@nodep will be NULL.
- *
- *	Returns -ENOMEM, or 0 for success.
- */
-int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
-			unsigned order, struct radix_tree_node **nodep,
-			void ***slotp)
+static int _radix_tree_create(struct radix_tree_root *root, gfp_t gfp_mask,
+			unsigned long index, unsigned int order,
+			struct radix_tree_node **nodep, void ***slotp)
 {
 	struct radix_tree_node *node = NULL, *child;
 	void **slot = (void **)&root->rnode;
@@ -598,7 +651,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 	if (order > 0 && max == ((1UL << order) - 1))
 		max++;
 	if (max > maxindex) {
-		int error = radix_tree_extend(root, max, shift);
+		int error = radix_tree_extend(root, gfp_mask, max, shift);
 		if (error < 0)
 			return error;
 		shift = error;
@@ -609,7 +662,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 		shift -= RADIX_TREE_MAP_SHIFT;
 		if (child == NULL) {
 			/* Have to add a child node.  */
-			child = radix_tree_node_alloc(root);
+			child = radix_tree_node_alloc(gfp_mask);
 			if (!child)
 				return -ENOMEM;
 			child->shift = shift;
@@ -635,7 +688,6 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 	return 0;
 }
 
-#ifdef CONFIG_RADIX_TREE_MULTIORDER
 /*
  * Free any nodes below this node.  The tree is presumed to not need
  * shrinking, and any user data in the tree is presumed to not need a
@@ -670,6 +722,7 @@ static void radix_tree_free_nodes(struct radix_tree_node *node)
 	}
 }
 
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
 static inline int insert_entries(struct radix_tree_node *node, void **slot,
 				void *ptr, unsigned order, bool replace)
 {
@@ -741,6 +794,31 @@ static inline int insert_entries(struct radix_tree_node *node, void **slot,
 #endif
 
 /**
+ *	__radix_tree_create	-	create a slot in a radix tree
+ *	@root:		radix tree root
+ *	@index:		index key
+ *	@order:		index occupies 2^order aligned slots
+ *	@nodep:		returns node
+ *	@slotp:		returns slot
+ *
+ *	Create, if necessary, and return the node and slot for an item
+ *	at position @index in the radix tree @root.
+ *
+ *	Until there is more than one item in the tree, no nodes are
+ *	allocated and @root->rnode is used as a direct slot instead of
+ *	pointing to a node, in which case *@nodep will be NULL.
+ *
+ *	Returns -ENOMEM, or 0 for success.
+ */
+int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
+			unsigned order, struct radix_tree_node **nodep,
+			void ***slotp)
+{
+	return _radix_tree_create(root, root_gfp_mask(root), index, order,
+					nodep, slotp);
+}
+
+/**
  *	__radix_tree_insert    -    insert into a radix tree
  *	@root:		radix tree root
  *	@index:		index key
@@ -891,6 +969,7 @@ int radix_tree_split(struct radix_tree_root *root, unsigned long index,
 	void **slot;
 	unsigned int offset, end;
 	unsigned n, tag, tags = 0;
+	gfp_t gfp = root_gfp_mask(root);
 
 	if (!__radix_tree_lookup(root, index, &parent, &slot))
 		return -ENOENT;
@@ -926,7 +1005,7 @@ int radix_tree_split(struct radix_tree_root *root, unsigned long index,
 
 	for (;;) {
 		if (node->shift > order) {
-			child = radix_tree_node_alloc(root);
+			child = radix_tree_node_alloc(gfp);
 			if (!child)
 				goto nomem;
 			child->shift = node->shift - RADIX_TREE_MAP_SHIFT;
@@ -1571,6 +1650,8 @@ static inline bool radix_tree_shrink(struct radix_tree_root *root)
 		 * one (root->rnode) as far as dependent read barriers go.
 		 */
 		root->rnode = child;
+		if (is_idr(root) && !tag_get(node, IDR_FREE, 0))
+			root_tag_clear(root, IDR_FREE);
 
 		/*
 		 * We have a dilemma here. The node's slot[0] must not be
@@ -1630,7 +1711,12 @@ bool __radix_tree_delete_node(struct radix_tree_root *root,
 			parent->slots[node->offset] = NULL;
 			parent->count--;
 		} else {
-			root_tag_clear_all(root);
+			/*
+			 * Shouldn't the tags already have all been cleared
+			 * by the caller?
+			 */
+			if (!is_idr(root))
+				root_tag_clear_all(root);
 			root->rnode = NULL;
 		}
 
@@ -1643,6 +1729,17 @@ bool __radix_tree_delete_node(struct radix_tree_root *root,
 	return deleted;
 }
 
+static void radix_tree_iter_delete(struct radix_tree_root *root,
+					struct radix_tree_iter *iter)
+{
+	unsigned offset = (iter->index >> iter->shift) & RADIX_TREE_MAP_MASK;
+	struct radix_tree_node *node = iter->node;
+
+	node->slots[offset] = NULL;
+	node->count--;
+	__radix_tree_delete_node(root, node);
+}
+
 static inline void delete_sibling_entries(struct radix_tree_node *node,
 					void *ptr, unsigned offset)
 {
@@ -1665,7 +1762,7 @@ static inline void delete_sibling_entries(struct radix_tree_node *node,
  *
  *	Remove @item at @index from the radix tree rooted at @root.
  *
- *	Returns the address of the deleted item, or NULL if it was not present
+ *	Returns the value of the deleted item, or NULL if it was not present
  *	or the entry at the given @index was not @item.
  */
 void *radix_tree_delete_item(struct radix_tree_root *root,
@@ -1685,16 +1782,21 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 		return NULL;
 
 	if (!node) {
-		root_tag_clear_all(root);
+		if (is_idr(root))
+			root_tag_set(root, IDR_FREE);
+		else
+			root_tag_clear_all(root);
 		root->rnode = NULL;
 		return entry;
 	}
 
 	offset = get_slot_offset(node, slot);
 
-	/* Clear all tags associated with the item to be deleted.  */
-	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
-		node_tag_clear(root, node, tag, offset);
+	if (is_idr(root))
+		node_tag_set(root, node, IDR_FREE, offset);
+	else
+		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
+			node_tag_clear(root, node, tag, offset);
 
 	delete_sibling_entries(node, node_to_entry(slot), offset);
 	node->slots[offset] = NULL;
@@ -1713,7 +1815,7 @@ EXPORT_SYMBOL(radix_tree_delete_item);
  *
  *	Remove the item at @index from the radix tree rooted at @root.
  *
- *	Returns the address of the deleted item, or NULL if it was not present.
+ *	Returns the value of the deleted item, or NULL if it was not present.
  */
 void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 {
@@ -1730,8 +1832,7 @@ void radix_tree_clear_tags(struct radix_tree_root *root,
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 			node_tag_clear(root, node, tag, offset);
 	} else {
-		/* Clear root node tags */
-		root->gfp_mask &= __GFP_BITS_MASK;
+		root_tag_clear_all(root);
 	}
 }
 
@@ -1746,6 +1847,421 @@ int radix_tree_tagged(struct radix_tree_root *root, unsigned int tag)
 }
 EXPORT_SYMBOL(radix_tree_tagged);
 
+/**
+ * idr_preload - preload for idr_alloc()
+ * @gfp_mask: allocation mask to use for preloading
+ *
+ * Preallocate memory to use for the next call to idr_alloc().  This function
+ * returns with preemption disabled.  It will be enabled by idr_preload_end().
+ */
+void idr_preload(gfp_t gfp_mask)
+{
+	__radix_tree_preload(gfp_mask, IDR_PRELOAD_SIZE);
+}
+EXPORT_SYMBOL(idr_preload);
+
+static int __idr_get_empty(struct radix_tree_root *root, gfp_t gfp,
+				unsigned long start, int end,
+				struct radix_tree_node **nodep, void ***slotp)
+{
+	struct radix_tree_node *node = NULL, *child;
+	void **slot = (void **)&root->rnode;
+	unsigned long maxindex;
+	unsigned long max = end > 0 ? end - 1 : INT_MAX;
+	unsigned int shift, offset = 0;
+
+ grow:
+	shift = radix_tree_load_root(root, &child, &maxindex);
+	if (!radix_tree_tagged(root, IDR_FREE))
+		start = max(start, maxindex + 1);
+	if (start > max)
+		return -ENOSPC;
+
+	if (start > maxindex) {
+		int error = radix_tree_extend(root, gfp, start, shift);
+		if (error < 0)
+			return error;
+		shift = error;
+		child = root->rnode;
+	}
+
+	while (shift) {
+		shift -= RADIX_TREE_MAP_SHIFT;
+		if (child == NULL) {
+			/* Have to add a child node.  */
+			child = radix_tree_node_alloc(gfp);
+			if (!child)
+				return -ENOMEM;
+			child->shift = shift;
+			child->offset = offset;
+			child->parent = node;
+			all_tag_set(child, IDR_FREE);
+			rcu_assign_pointer(*slot, node_to_entry(child));
+			if (node)
+				node->count++;
+		} else if (!radix_tree_is_internal_node(child))
+			break;
+
+		node = entry_to_node(child);
+		offset = radix_tree_descend(node, &child, start);
+		if (!tag_get(node, IDR_FREE, offset)) {
+			offset = radix_tree_find_next_bit(node, IDR_FREE,
+							offset + 1);
+			start = next_index(start, node, offset);
+			if (start > max)
+				return -ENOSPC;
+			while (offset == RADIX_TREE_MAP_SIZE) {
+				offset = node->offset + 1;
+				node = node->parent;
+				if (!node)
+					goto grow;
+				shift = node->shift;
+			}
+			child = node->slots[offset];
+		}
+		slot = &node->slots[offset];
+	}
+
+	*nodep = node;
+	*slotp = slot;
+	return start;
+}
+
+/**
+ * idr_alloc - allocate an id
+ * @idr: idr handle
+ * @ptr: pointer to be associated with the new id
+ * @start: the minimum id (inclusive)
+ * @end: the maximum id (exclusive)
+ * @gfp: memory allocation flags
+ *
+ * Allocates an unused ID in the range [start, end).  Returns -ENOSPC
+ * if there are no unused IDs in that range.
+ */
+int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
+{
+	struct radix_tree_node *node;
+	void **slot;
+	int id;
+
+	if (WARN_ON_ONCE(start < 0))
+		return -EINVAL;
+
+	id = __idr_get_empty(&idr->idr_rt, gfp, start, end, &node, &slot);
+	if (id < 0)
+		return id;
+
+	BUG_ON(radix_tree_is_internal_node(ptr));
+
+	rcu_assign_pointer(*slot, ptr);
+	if (node)
+		node->count++;
+	node_tag_clear(&idr->idr_rt, node, IDR_FREE,
+						get_slot_offset(node, slot));
+	return id;
+}
+EXPORT_SYMBOL(idr_alloc);
+
+/**
+ * idr_alloc_cyclic - allocate new idr entry in a cyclical fashion
+ * @idr: idr handle
+ * @ptr: pointer to be associated with the new id
+ * @start: the minimum id (inclusive)
+ * @end: the maximum id (exclusive)
+ * @gfp: memory allocation flags
+ *
+ * Allocates an ID larger than the last ID allocated if one is available.
+ * If not, it will attempt to allocate the smallest ID that is larger or
+ * equal to @start.
+ */
+int idr_alloc_cyclic(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
+{
+	int id, curr = idr->idr_next;
+
+	if (curr < start)
+		curr = start;
+
+	id = idr_alloc(idr, ptr, curr, end, gfp);
+	if ((id == -ENOSPC) && (curr > start))
+		id = idr_alloc(idr, ptr, start, curr, gfp);
+
+	if (id >= 0)
+		idr->idr_next = id + 1U;
+
+	return id;
+}
+EXPORT_SYMBOL(idr_alloc_cyclic);
+
+/**
+ * idr_for_each - iterate through all stored pointers
+ * @idr: idr handle
+ * @fn: function to be called for each pointer
+ * @data: data passed to callback function
+ *
+ * The callback function will be called for each entry in @idr, passing
+ * the id, the pointer and the data pointer passed to this function.
+ *
+ * If @fn returns anything other than %0, the iteration stops and that
+ * value is returned from this function.
+ *
+ * idr_for_each() can be called concurrently with idr_get_new() and
+ * idr_remove() if protected by RCU.  Newly added entries may not be
+ * seen and deleted entries may be seen, but adding and removing entries
+ * will not cause other entries to be skipped, nor spurious ones to be seen.
+ */
+int idr_for_each(struct idr *idr,
+		int (*fn)(int id, void *p, void *data), void *data)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+
+	radix_tree_for_each_slot(slot, &idr->idr_rt, &iter, 0) {
+		int ret = fn(iter.index, *slot, data);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(idr_for_each);
+
+/**
+ * idr_get_next - Find next populated entry
+ * @idr: idr handle
+ * @nextid: Pointer to lowest possible ID to return
+ *
+ * Returns the next populated entry in the tree with an ID greater than
+ * or equal to the value pointed to by @nextid.  On exit, @nextid is updated
+ * to the ID of the found value.  To use in a loop, the value pointed to by
+ * nextid must be incremented by the user.
+ */
+void *idr_get_next(struct idr *idr, int *nextid)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+
+	radix_tree_for_each_slot(slot, &idr->idr_rt, &iter, *nextid) {
+		*nextid = iter.index;
+		return *slot;
+	}
+
+	return NULL;
+}
+EXPORT_SYMBOL(idr_get_next);
+
+/**
+ * idr_replace - replace pointer for given id
+ * @idr: idr handle
+ * @ptr: New pointer to associate with the ID
+ * @id: Lookup key
+ *
+ * Replace the pointer registered with an id and return the old value.
+ * A %-ENOENT return indicates that @id was not found.
+ * A %-EINVAL return indicates that @id was not within valid constraints.
+ *
+ * This function can be called under the RCU read lock concurrently with
+ * idr_remove().
+ */
+void *idr_replace(struct idr *idr, void *ptr, int id)
+{
+	void **slot;
+	void *entry;
+
+	if (id < 0)
+		return ERR_PTR(-EINVAL);
+	if (!ptr || radix_tree_is_internal_node(ptr))
+		return ERR_PTR(-EINVAL);
+
+	entry = __radix_tree_lookup(&idr->idr_rt, id, NULL, &slot);
+
+	if (!entry)
+		return ERR_PTR(-ENOENT);
+
+	radix_tree_replace_slot(slot, ptr);
+
+	return entry;
+}
+EXPORT_SYMBOL(idr_replace);
+
+/**
+ * idr_destroy - release all internal memory from an IDR
+ * @idr: idr handle
+ *
+ * After this function is called, the IDR is empty, and may be reused or
+ * the data structure containing it may be freed.
+ *
+ * A typical clean-up sequence for objects stored in an idr tree will use
+ * idr_for_each() to free all objects, if necessary, then idr_destroy() to
+ * free the memory used to keep track of those objects.
+ */
+void idr_destroy(struct idr *idr)
+{
+	struct radix_tree_node **slot = &idr->idr_rt.rnode;
+	if (radix_tree_is_internal_node(*slot))
+		radix_tree_free_nodes(*slot);
+	*slot = NULL;
+	root_tag_set(&idr->idr_rt, IDR_FREE);
+}
+EXPORT_SYMBOL(idr_destroy);
+
+/**
+ * ida_pre_get - reserve resources for ida allocation
+ * @ida: ida handle
+ * @gfp: memory allocation flags
+ *
+ * This function should be called before calling ida_get_new_above().  If it
+ * is unable to allocate memory, it will return %0.  On success, it returns %1.
+ */
+int ida_pre_get(struct ida *ida, gfp_t gfp)
+{
+	struct ida_bitmap *bitmap;
+
+	idr_preload(gfp);
+	idr_preload_end();
+
+	if (!ida->free_bitmap) {
+		bitmap = kmalloc(sizeof(struct ida_bitmap), gfp);
+		if (!bitmap)
+			return 0;
+		bitmap = xchg(&ida->free_bitmap, bitmap);
+		kfree(bitmap);
+	}
+
+	return 1;
+}
+EXPORT_SYMBOL(ida_pre_get);
+
+/**
+ * ida_get_new_above - allocate new ID above or equal to a start id
+ * @ida: ida handle
+ * @starting_id: id to start search at
+ * @p_id: pointer to the allocated handle
+ *
+ * Allocate new ID above or equal to @starting_id.  It should be called
+ * with any required locks.
+ *
+ * If memory is required, it will return %-EAGAIN, you should unlock
+ * and go back to the ida_pre_get() call.  If the ida is full, it will
+ * return %-ENOSPC.
+ *
+ * @p_id returns a value in the range @starting_id ... %0x7fffffff.
+ */
+int ida_get_new_above(struct ida *ida, int start, int *id)
+{
+	struct radix_tree_root *root = &ida->ida_rt;
+	void **slot = (void **)&root->rnode;
+	struct radix_tree_node *node;
+	struct ida_bitmap *bitmap = NULL;
+	unsigned long index;
+	unsigned bit, offset = 0;
+
+	index = start / IDA_BITMAP_BITS;
+	bit = start % IDA_BITMAP_BITS;
+
+ restart:
+	index = __idr_get_empty(root, GFP_ATOMIC, index, INT_MAX, &node, &slot);
+	if (index > INT_MAX)
+		return index;
+
+	index *= IDA_BITMAP_BITS;
+	if (index > INT_MAX)
+		return -ENOSPC;
+
+	if (index > start)
+		bit = 0;
+	offset = get_slot_offset(node, slot);
+
+	bitmap = *slot;
+	if (bitmap) {
+		bit = find_next_zero_bit(bitmap->bitmap, IDA_BITMAP_BITS, bit);
+		index += bit;
+		if (index > INT_MAX)
+			return -ENOSPC;
+		if (bit == IDA_BITMAP_BITS) {
+			index /= IDA_BITMAP_BITS;
+			goto restart;
+		}
+		__set_bit(bit, bitmap->bitmap);
+		if (bitmap_full(bitmap->bitmap, IDA_BITMAP_BITS))
+			node_tag_clear(root, node, IDR_FREE, offset);
+		bitmap = xchg(&ida->free_bitmap, NULL);
+		kfree(bitmap);
+	} else {
+		index += bit;
+		bitmap = xchg(&ida->free_bitmap, NULL);
+		if (!bitmap)
+			return -EAGAIN;
+		memset(bitmap, 0, sizeof(*bitmap));
+		__set_bit(bit, bitmap->bitmap);
+		rcu_assign_pointer(*slot, bitmap);
+		if (node)
+			node->count++;
+	}
+
+	*id = index;
+	return 0;
+}
+EXPORT_SYMBOL(ida_get_new_above);
+
+/**
+ * ida_remove - Free the given ID
+ * @ida: ida handle
+ * @id: ID to free
+ *
+ * This function should not be called at the same time as ida_get_new_above().
+ */
+void ida_remove(struct ida *ida, int id)
+{
+	unsigned long index = id / IDA_BITMAP_BITS;
+	unsigned offset = id % IDA_BITMAP_BITS;
+	struct ida_bitmap *bitmap;
+	struct radix_tree_node *node;
+	void **slot;
+
+	bitmap = __radix_tree_lookup(&ida->ida_rt, index, &node, &slot);
+	if (!bitmap || !test_bit(offset, bitmap->bitmap))
+		goto err;
+
+	__clear_bit(offset, bitmap->bitmap);
+	node_tag_set(&ida->ida_rt, node, IDR_FREE, get_slot_offset(node, slot));
+	if (bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)) {
+		*slot = NULL;
+		kfree(bitmap);
+		if (node) {
+			node->count--;
+			__radix_tree_delete_node(&ida->ida_rt, node);
+		}
+	}
+	return;
+ err:
+	WARN(1, "ida_remove called for id=%d which is not allocated.\n", id);
+}
+EXPORT_SYMBOL(ida_remove);
+
+/**
+ * ida_destroy - Free the contents of an ida
+ * @ida: ida handle
+ *
+ * Calling this function releases all resources associated with an IDA.  When
+ * this call returns, the IDA is empty and can be reused or freed.  The caller
+ * should not allow ida_remove() or ida_get_new_above() to be called at the
+ * same time.
+ */
+void ida_destroy(struct ida *ida)
+{
+	struct radix_tree_iter iter;
+	void **slot;
+
+	radix_tree_for_each_slot(slot, &ida->ida_rt, &iter, 0) {
+		struct ida_bitmap *bitmap = *slot;
+		kfree(bitmap);
+		radix_tree_iter_delete(&ida->ida_rt, &iter);
+	}
+
+	kfree(ida->free_bitmap);
+}
+EXPORT_SYMBOL(ida_destroy);
+
 static void
 radix_tree_node_ctor(void *arg)
 {
diff --git a/tools/testing/radix-tree/Makefile b/tools/testing/radix-tree/Makefile
index 3635e4d..5a616a3 100644
--- a/tools/testing/radix-tree/Makefile
+++ b/tools/testing/radix-tree/Makefile
@@ -3,7 +3,7 @@ CFLAGS += -I. -I../../include -g -O2 -Wall -D_LGPL_SOURCE
 LDFLAGS += -lpthread -lurcu
 TARGETS = main
 OFILES = main.o radix-tree.o linux.o test.o tag_check.o find_next_bit.o \
-	 regression1.o regression2.o regression3.o multiorder.o \
+	 regression1.o regression2.o regression3.o multiorder.o idr.o \
 	 iteration_check.o benchmark.o
 
 ifdef BENCHMARK
@@ -23,7 +23,8 @@ find_next_bit.o: ../../lib/find_bit.c
 
 $(OFILES): *.h */*.h \
 	../../include/linux/*.h \
-	../../../include/linux/radix-tree.h
+	../../../include/linux/radix-tree.h \
+	../../../include/linux/idr.h
 
 radix-tree.c: ../../../lib/radix-tree.c
 	sed -e 's/^static //' -e 's/__always_inline //' -e 's/inline //' < $< > $@
diff --git a/tools/testing/radix-tree/idr.c b/tools/testing/radix-tree/idr.c
new file mode 100644
index 0000000..0f9e7b1
--- /dev/null
+++ b/tools/testing/radix-tree/idr.c
@@ -0,0 +1,148 @@
+/*
+ * idr.c: Test the IDR API
+ * Copyright (c) 2016 Matthew Wilcox <willy@infradead.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+#include <linux/idr.h>
+#include <linux/slab.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+
+#include "test.h"
+
+#define DUMMY_PTR	((void *)0x12)
+
+int item_idr_free(int id, void *p, void *data)
+{
+	struct item *item = p;
+	assert(item->index == id);
+	idr_remove(data, id);
+	free(p);
+
+	return 0;
+}
+
+void item_idr_remove(struct idr *idr, int id)
+{
+	struct item *item = idr_find(idr, id);
+	assert(item->index == id);
+	idr_remove(idr, id);
+	free(item);
+}
+
+void idr_alloc_test(void)
+{
+	unsigned long i;
+	DEFINE_IDR(idr);
+
+	assert(idr_alloc_cyclic(&idr, DUMMY_PTR, 0, 0x4000, GFP_KERNEL) == 0);
+	assert(idr_alloc_cyclic(&idr, DUMMY_PTR, 0x3ffd, 0x4000, GFP_KERNEL) == 0x3ffd);
+	idr_remove(&idr, 0x3ffd);
+	idr_remove(&idr, 0);
+
+	for (i = 0x3ffe; i < 0x4003; i++) {
+		int id;
+		struct item *item;
+
+		if (i < 0x4000)
+			item = item_create(i);
+		else
+			item = item_create(i - 0x3fff);
+
+		id = idr_alloc_cyclic(&idr, item, 1, 0x4000, GFP_KERNEL);
+		assert(id == item->index);
+	}
+
+	idr_for_each(&idr, item_idr_free, &idr);
+}
+
+void idr_checks(void)
+{
+	unsigned long i;
+	DEFINE_IDR(idr);
+
+	for (i = 0; i < 10000; i++) {
+		struct item *item = item_create(i);
+		assert(idr_alloc(&idr, item, 0, 20000, GFP_KERNEL) == i);
+	}
+
+	assert(idr_alloc(&idr, DUMMY_PTR, 5, 30, GFP_KERNEL) < 0);
+
+	for (i = 0; i < 5000; i++)
+		item_idr_remove(&idr, i);
+
+	idr_for_each(&idr, item_idr_free, &idr);
+
+	assert(idr_is_empty(&idr));
+
+	for (i = INT_MAX - 3UL; i < INT_MAX + 1UL; i++) {
+		struct item *item = item_create(i);
+		assert(idr_alloc(&idr, item, i, i + 10, GFP_KERNEL) == i);
+	}
+	assert(idr_alloc(&idr, DUMMY_PTR, i - 2, i, GFP_KERNEL) == -ENOSPC);
+
+	idr_destroy(&idr);
+	idr_destroy(&idr);
+
+	assert(idr_is_empty(&idr));
+
+	for (i = 1; i < 10000; i++) {
+		struct item *item = item_create(i);
+		assert(idr_alloc(&idr, item, 1, 20000, GFP_KERNEL) == i);
+	}
+
+	idr_destroy(&idr);
+
+	idr_alloc_test();
+}
+
+void ida_checks(void)
+{
+	DEFINE_IDA(ida);
+
+	unsigned long i;
+	int id;
+
+	for (i = 0; i < 10000; i++) {
+		ida_pre_get(&ida, GFP_KERNEL);
+		ida_get_new(&ida, &id);
+		assert(id == i);
+	}
+
+	ida_remove(&ida, 20);
+	ida_remove(&ida, 21);
+	for (i = 0; i < 3; i++) {
+		ida_pre_get(&ida, GFP_KERNEL);
+		ida_get_new(&ida, &id);
+		if (i == 2)
+			assert(id == 10000);
+	}
+
+	for (i = 0; i < 5000; i++)
+		ida_remove(&ida, i);
+
+	ida_pre_get(&ida, GFP_KERNEL);
+	ida_get_new_above(&ida, 5000, &id);
+	assert(id == 10001);
+
+	ida_destroy(&ida);
+
+	assert(ida_is_empty(&ida));
+
+	ida_pre_get(&ida, GFP_KERNEL);
+	ida_get_new_above(&ida, 1, &id);
+	assert(id == 1);
+
+	ida_remove(&ida, id);
+	ida_destroy(&ida);
+
+	radix_tree_callback(NULL, CPU_DEAD, NULL);
+}
diff --git a/tools/testing/radix-tree/linux/idr.h b/tools/testing/radix-tree/linux/idr.h
new file mode 100644
index 0000000..4e342f2
--- /dev/null
+++ b/tools/testing/radix-tree/linux/idr.h
@@ -0,0 +1 @@
+#include "../../../../include/linux/idr.h"
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index 9b43b49..7d214e9 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -30,6 +30,7 @@
 #define __force
 #define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
 #define pr_debug printk
+#define pr_cont printk
 
 #define smp_rmb()	barrier()
 #define smp_wmb()	barrier()
@@ -41,6 +42,7 @@
 	const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
 	(type *)( (char *)__mptr - offsetof(type, member) );})
 #define min(a, b) ((a) < (b) ? (a) : (b))
+#define max(a, b) ((a) < (b) ? (b) : (a))
 
 #define cond_resched()	sched_yield()
 
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 7d14812..e267d5f 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -3,6 +3,7 @@
 #include <unistd.h>
 #include <time.h>
 #include <assert.h>
+#include <limits.h>
 
 #include <linux/slab.h>
 #include <linux/radix-tree.h>
@@ -314,6 +315,11 @@ static void single_thread_tests(bool long_run)
 	rcu_barrier();
 	printf("after dynamic_height_check: %d allocated, preempt %d\n",
 		nr_allocated, preempt_count);
+	idr_checks();
+	ida_checks();
+	rcu_barrier();
+	printf("after idr_checks: %d allocated, preempt %d\n",
+		nr_allocated, preempt_count);
 	big_gang_check(long_run);
 	rcu_barrier();
 	printf("after big_gang_check: %d allocated, preempt %d\n",
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 1faf0a3..4baec38 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -36,6 +36,8 @@ void tag_check(void);
 void multiorder_checks(void);
 void iteration_test(void);
 void benchmark(void);
+void idr_checks(void);
+void ida_checks(void);
 
 struct item *
 item_tag_set(struct radix_tree_root *root, unsigned long index, int tag);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

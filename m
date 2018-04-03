Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id EDC896B0003
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 16:51:27 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 1-v6so11245888plv.6
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 13:51:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g4si2455421pgv.371.2018.04.03.13.51.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Apr 2018 13:51:25 -0700 (PDT)
Date: Tue, 3 Apr 2018 13:51:17 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v10 43/62] memfd: Convert shmem_tag_pins to XArray
Message-ID: <20180403205117.GA30145@bombadil.infradead.org>
References: <20180330034245.10462-1-willy@infradead.org>
 <20180330034245.10462-44-willy@infradead.org>
 <39ea3393-c3d7-07c3-a072-344f3a65cef3@oracle.com>
 <20180331021111.GB13332@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180331021111.GB13332@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>

On Fri, Mar 30, 2018 at 07:11:11PM -0700, Matthew Wilcox wrote:
> On Fri, Mar 30, 2018 at 05:05:05PM -0700, Mike Kravetz wrote:
> > On 03/29/2018 08:42 PM, Matthew Wilcox wrote:
> > > Simplify the locking by taking the spinlock while we walk the tree on
> > > the assumption that many acquires and releases of the lock will be
> > > worse than holding the lock for a (potentially) long time.
> > 
> > I see this change made in several of the patches and do not have a
> > specific issue with it.  As part of the XArray implementation you
> > have XA_CHECK_SCHED = 4096.   So, we drop locks and do a cond_resched
> > after XA_CHECK_SCHED iterations.  Just curious how you came up with
> > that number.  Apologies in advance if this was discussed in a previous
> > round of reviews.
> 
> It comes from two places, the current implementations of
> tag_pages_for_writeback() and find_swap_entry().  I have no idea if it's
> the optimal number for anybody, but it's the only number that anyone
> was using.  I'll have no problem if somebody suggests we tweak the number
> in the future.

I thought about this some more.  One of the principles behind the xarray
rewrite was to make it easier to use than the radix tree.  Even this
interface succeeds at that; compare:

-       radix_tree_for_each_slot(slot, root, &iter, 0) {
-               if (*slot == item) {
-                       found = iter.index;
+       xas_for_each(&xas, entry, ULONG_MAX) {
+               if (xas_retry(&xas, entry))
+                       continue;
+               if (entry == item)
                        break;
-               }
                checked++;
-               if ((checked % 4096) != 0)
+               if ((checked % XA_CHECK_SCHED) != 0)
                        continue;
-               slot = radix_tree_iter_resume(slot, &iter);
+               xas_pause(&xas);
                cond_resched_rcu();
        }

But it's not *great*.  It doesn't succeed in capturing all the necessary
state in the xa_state so that the user doesn't have to worry about this.
It's subtle and relatively easy to get wrong.  And, as you say, why this
magic number?

I came up with this, which does capture everything necessary in the
xa_state -- just one bit which tells the xa_state whether we're in an
iteration with interrupts disabled.  If that bit is set, iterations
pause at the end of every second-level group of the tree.  That's every
4096 _indices_ (as opposed to every 4096 _processed entries_), but those
should be close to each other in dense trees.

I don't love the name of the function (xas_long_iter_irq()), but I'm
expecting somebody else will have a better name.  I did notice that
shmem_tag_pins() was only called from shmem_wait_for_pins(), so it
doesn't need its own XA_STATE; we can just pass in the xa_state pointer.

I rather like the outcome in the callers; the loops are reduced to doing
the thing that the loops are supposed to do instead of having this silly
tail on them that handles bookkeeping.

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index eac04922eba2..7ac25c402e19 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -842,6 +842,31 @@ static inline void xas_set_order(struct xa_state *xas, unsigned long index,
 #endif
 }
 
+#define XAS_FLAG_PAUSE	(1 << 7)
+
+/**
+ * xas_long_iter_irq() - Mark XArray operation state as being used for a long
+ * iteration.
+ * @xas: XArray operation state.
+ *
+ * If you are about to start an iteration over a potentially large array
+ * with the xa_lock held and interrupts off, call this function to have
+ * the iteration pause itself at opportune moments and check whether other
+ * threads need to run.
+ *
+ * If your iteration uses the rcu lock or the xa_lock without interrupts
+ * disabled, you can use cond_resched_rcu() or cond_resched_lock() at the
+ * end of each loop.  There is no cond_resched_lock_irq() (because most
+ * of the ways which notify a thread that a higher-priority thread wants
+ * to run depend on interrupts being enabled).
+ *
+ * Context: Process context.
+ */
+static inline void xas_long_iter_irq(struct xa_state *xas)
+{
+	xas->xa_flags |= XAS_FLAG_PAUSE;
+}
+
 /**
  * xas_set_update() - Set up XArray operation state for a callback.
  * @xas: XArray operation state.
diff --git a/lib/xarray.c b/lib/xarray.c
index 653ab0555673..9328e7b7ac85 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -948,6 +948,18 @@ void *__xas_next(struct xa_state *xas)
 }
 EXPORT_SYMBOL_GPL(__xas_next);
 
+static
+void *xas_find_restart(struct xa_state *xas, unsigned long max, xa_tag_t tag)
+{
+	xas_unlock_irq(xas);
+	cond_resched();
+	xas_reset(xas);
+	xas_lock_irq(xas);
+	if (tag == XA_PRESENT)
+		return xas_find(xas, max);
+	return xas_find_tag(xas, max, tag);
+}
+
 /**
  * xas_find() - Find the next present entry in the XArray.
  * @xas: XArray operation state.
@@ -984,6 +996,9 @@ void *xas_find(struct xa_state *xas, unsigned long max)
 
 	while (xas->xa_node && (xas->xa_index <= max)) {
 		if (unlikely(xas->xa_offset == XA_CHUNK_SIZE)) {
+			if ((xas->xa_flags & XAS_FLAG_PAUSE) &&
+					xas->xa_node->shift)
+				return xas_find_restart(xas, max, XA_PRESENT);
 			xas->xa_offset = xas->xa_node->offset + 1;
 			xas->xa_node = xa_parent(xas->xa, xas->xa_node);
 			continue;
@@ -1056,6 +1071,9 @@ void *xas_find_tag(struct xa_state *xas, unsigned long max, xa_tag_t tag)
 
 	while (xas->xa_index <= max) {
 		if (unlikely(xas->xa_offset == XA_CHUNK_SIZE)) {
+			if ((xas->xa_flags & XAS_FLAG_PAUSE) &&
+					xas->xa_node->shift)
+				return xas_find_restart(xas, max, tag);
 			xas->xa_offset = xas->xa_node->offset + 1;
 			xas->xa_node = xa_parent(xas->xa, xas->xa_node);
 			if (!xas->xa_node)
diff --git a/mm/memfd.c b/mm/memfd.c
index 0e0835e63af2..7eb703651a73 100644
--- a/mm/memfd.c
+++ b/mm/memfd.c
@@ -27,30 +27,20 @@
 #define SHMEM_TAG_PINNED        PAGECACHE_TAG_TOWRITE
 #define LAST_SCAN               4       /* about 150ms max */
 
-static void shmem_tag_pins(struct address_space *mapping)
+static void shmem_tag_pins(struct xa_state *xas)
 {
-	XA_STATE(xas, &mapping->i_pages, 0);
 	struct page *page;
-	unsigned int tagged = 0;
 
 	lru_add_drain();
 
-	xas_lock_irq(&xas);
-	xas_for_each(&xas, page, ULONG_MAX) {
+	xas_lock_irq(xas);
+	xas_for_each(xas, page, ULONG_MAX) {
 		if (xa_is_value(page))
 			continue;
 		if (page_count(page) - page_mapcount(page) > 1)
-			xas_set_tag(&xas, SHMEM_TAG_PINNED);
-
-		if (++tagged % XA_CHECK_SCHED)
-			continue;
-
-		xas_pause(&xas);
-		xas_unlock_irq(&xas);
-		cond_resched();
-		xas_lock_irq(&xas);
+			xas_set_tag(xas, SHMEM_TAG_PINNED);
 	}
-	xas_unlock_irq(&xas);
+	xas_unlock_irq(xas);
 }
 
 /*
@@ -68,12 +58,11 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 	struct page *page;
 	int error, scan;
 
-	shmem_tag_pins(mapping);
+	xas_long_iter_irq(&xas);
+	shmem_tag_pins(&xas);
 
 	error = 0;
 	for (scan = 0; scan <= LAST_SCAN; scan++) {
-		unsigned int tagged = 0;
-
 		if (!xas_tagged(&xas, SHMEM_TAG_PINNED))
 			break;
 
@@ -101,13 +90,6 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 			}
 			if (clear)
 				xas_clear_tag(&xas, SHMEM_TAG_PINNED);
-			if (++tagged % XA_CHECK_SCHED)
-				continue;
-
-			xas_pause(&xas);
-			xas_unlock_irq(&xas);
-			cond_resched();
-			xas_lock_irq(&xas);
 		}
 		xas_unlock_irq(&xas);
 	}
diff --git a/tools/testing/radix-tree/linux.c b/tools/testing/radix-tree/linux.c
index 44a0d1ad4408..22421ad63559 100644
--- a/tools/testing/radix-tree/linux.c
+++ b/tools/testing/radix-tree/linux.c
@@ -16,6 +16,12 @@ int nr_allocated;
 int preempt_count;
 int kmalloc_verbose;
 int test_verbose;
+int resched_count;
+
+void cond_resched(void)
+{
+	resched_count++;
+}
 
 struct kmem_cache {
 	pthread_mutex_t lock;
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index 9fa1828dde5e..57e16a2554f6 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -25,4 +25,6 @@
 #define local_irq_disable()	rcu_read_lock()
 #define local_irq_enable()	rcu_read_unlock()
 
+extern void cond_resched(void);
+
 #endif /* _KERNEL_H */
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index f97cacd1422d..730d91849d8f 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -54,6 +54,7 @@ void tree_verify_min_height(struct radix_tree_root *root, int maxindex);
 void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag);
 
 extern int nr_allocated;
+extern int resched_count;
 
 /* Normally private parts of lib/radix-tree.c */
 struct radix_tree_node *entry_to_node(void *ptr);
diff --git a/tools/testing/radix-tree/xarray-test.c b/tools/testing/radix-tree/xarray-test.c
index f8909eb09cbc..3a70ad1734cf 100644
--- a/tools/testing/radix-tree/xarray-test.c
+++ b/tools/testing/radix-tree/xarray-test.c
@@ -183,6 +183,48 @@ void check_xas_pause(struct xarray *xa)
 	assert(seen == 2);
 }
 
+void check_xas_set_pause(struct xarray *xa)
+{
+	XA_STATE(xas, xa, 0);
+	void *entry;
+	unsigned i = 0;
+	int count = resched_count;
+
+	BUG_ON(!xa_empty(xa));
+
+	xa_store(xa, 4095, xa_mk_value(4095), GFP_KERNEL);
+	xa_store(xa, 4096, xa_mk_value(4096), GFP_KERNEL);
+
+	xas_lock_irq(&xas);
+	xas_for_each(&xas, entry, ULONG_MAX) {
+		if (i == 0)
+			BUG_ON(entry != xa_mk_value(4095));
+		else if (i == 1)
+			BUG_ON(entry != xa_mk_value(4096));
+		i++;
+	}
+	xas_unlock_irq(&xas);
+	BUG_ON(resched_count != count);
+	BUG_ON(i != 2);
+	BUG_ON(entry != NULL);
+
+	xas_set(&xas, 0);
+	i = 0;
+	xas_long_iter_irq(&xas);
+	xas_lock_irq(&xas);
+	xas_for_each(&xas, entry, ULONG_MAX) {
+		if (i == 0)
+			BUG_ON(entry != xa_mk_value(4095));
+		else if (i == 1)
+			BUG_ON(entry != xa_mk_value(4096));
+		i++;
+	}
+	xas_unlock_irq(&xas);
+	BUG_ON(i != 2);
+	BUG_ON(entry != NULL);
+	BUG_ON(resched_count == count);
+}
+
 void check_xas_retry(struct xarray *xa)
 {
 	XA_STATE(xas, xa, 0);
@@ -553,6 +595,9 @@ void xarray_checks(void)
 	check_xas_pause(&array);
 	item_kill_tree(&array);
 
+	check_xas_set_pause(&array);
+	item_kill_tree(&array);
+
 	check_xa_load(&array);
 	item_kill_tree(&array);
 

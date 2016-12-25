Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 54B946B0253
	for <linux-mm@kvack.org>; Sat, 24 Dec 2016 22:00:56 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a190so552987983pgc.0
        for <linux-mm@kvack.org>; Sat, 24 Dec 2016 19:00:56 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 1si39015061plp.216.2016.12.24.19.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Dec 2016 19:00:55 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id g1so5272181pgn.0
        for <linux-mm@kvack.org>; Sat, 24 Dec 2016 19:00:55 -0800 (PST)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH 2/2] mm: add PageWaiters indicating tasks are waiting for a page bit
Date: Sun, 25 Dec 2016 13:00:30 +1000
Message-Id: <20161225030030.23219-3-npiggin@gmail.com>
In-Reply-To: <20161225030030.23219-1-npiggin@gmail.com>
References: <20161225030030.23219-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>

Add a new page flag, PageWaiters, to indicate the page waitqueue has
tasks waiting. This can be tested rather than testing waitqueue_active
which requires another cacheline load.

This bit is always set when the page has tasks on page_waitqueue(page),
and is set and cleared under the waitqueue lock. It may be set when
there are no tasks on the waitqueue, which will cause a harmless extra
wakeup check that will clears the bit.

The generic bit-waitqueue infrastructure is no longer used for pages.
Instead, waitqueues are used directly with a custom key type. The
generic code was not flexible enough to have PageWaiters manipulation
under the waitqueue lock (which simplifies concurrency).

This improves the performance of page lock intensive microbenchmarks by
2-3%.

Putting two bits in the same word opens the opportunity to remove the
memory barrier between clearing the lock bit and testing the waiters
bit, after some work on the arch primitives (e.g., ensuring memory
operand widths match and cover both bits).

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 include/linux/mm.h             |   2 +
 include/linux/page-flags.h     |   9 ++
 include/linux/pagemap.h        |  23 +++---
 include/linux/writeback.h      |   1 -
 include/trace/events/mmflags.h |   1 +
 init/main.c                    |   3 +-
 mm/filemap.c                   | 181 +++++++++++++++++++++++++++++++++--------
 mm/internal.h                  |   2 +
 mm/swap.c                      |   2 +
 9 files changed, 174 insertions(+), 50 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4424784ac374..fe6b4036664a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1758,6 +1758,8 @@ static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 	return ptl;
 }
 
+extern void __init pagecache_init(void);
+
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index a57c909a15e4..c56b39890a41 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -73,6 +73,7 @@
  */
 enum pageflags {
 	PG_locked,		/* Page is locked. Don't touch. */
+	PG_waiters,		/* Page has waiters, check its waitqueue */
 	PG_error,
 	PG_referenced,
 	PG_uptodate,
@@ -169,6 +170,9 @@ static __always_inline int PageCompound(struct page *page)
  *     for compound page all operations related to the page flag applied to
  *     head page.
  *
+ * PF_ONLY_HEAD:
+ *     for compound page, callers only ever operate on the head page.
+ *
  * PF_NO_TAIL:
  *     modifications of the page flag must be done on small or head pages,
  *     checks can be done on tail pages too.
@@ -178,6 +182,9 @@ static __always_inline int PageCompound(struct page *page)
  */
 #define PF_ANY(page, enforce)	page
 #define PF_HEAD(page, enforce)	compound_head(page)
+#define PF_ONLY_HEAD(page, enforce) ({					\
+		VM_BUG_ON_PGFLAGS(PageTail(page), page);		\
+		page;})
 #define PF_NO_TAIL(page, enforce) ({					\
 		VM_BUG_ON_PGFLAGS(enforce && PageTail(page), page);	\
 		compound_head(page);})
@@ -255,6 +262,7 @@ static inline int TestClearPage##uname(struct page *page) { return 0; }
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
 __PAGEFLAG(Locked, locked, PF_NO_TAIL)
+PAGEFLAG(Waiters, waiters, PF_ONLY_HEAD) __CLEARPAGEFLAG(Waiters, waiters, PF_ONLY_HEAD)
 PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
 PAGEFLAG(Referenced, referenced, PF_HEAD)
 	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
@@ -743,6 +751,7 @@ static inline int page_has_private(struct page *page)
 
 #undef PF_ANY
 #undef PF_HEAD
+#undef PF_ONLY_HEAD
 #undef PF_NO_TAIL
 #undef PF_NO_COMPOUND
 #endif /* !__GENERATING_BOUNDS_H */
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 7dbe9148b2f8..d7f25f754d60 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -486,22 +486,14 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
  * and for filesystems which need to wait on PG_private.
  */
 extern void wait_on_page_bit(struct page *page, int bit_nr);
-
 extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
-extern int wait_on_page_bit_killable_timeout(struct page *page,
-					     int bit_nr, unsigned long timeout);
-
-static inline int wait_on_page_locked_killable(struct page *page)
-{
-	if (!PageLocked(page))
-		return 0;
-	return wait_on_page_bit_killable(compound_head(page), PG_locked);
-}
+extern void wake_up_page_bit(struct page *page, int bit_nr);
 
-extern wait_queue_head_t *page_waitqueue(struct page *page);
 static inline void wake_up_page(struct page *page, int bit)
 {
-	__wake_up_bit(page_waitqueue(page), &page->flags, bit);
+	if (!PageWaiters(page))
+		return;
+	wake_up_page_bit(page, bit);
 }
 
 /* 
@@ -517,6 +509,13 @@ static inline void wait_on_page_locked(struct page *page)
 		wait_on_page_bit(compound_head(page), PG_locked);
 }
 
+static inline int wait_on_page_locked_killable(struct page *page)
+{
+	if (!PageLocked(page))
+		return 0;
+	return wait_on_page_bit_killable(compound_head(page), PG_locked);
+}
+
 /* 
  * Wait for a page to complete writeback
  */
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index c78f9f0920b5..5527d910ba3d 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -375,7 +375,6 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
 unsigned long wb_calc_thresh(struct bdi_writeback *wb, unsigned long thresh);
 
 void wb_update_bandwidth(struct bdi_writeback *wb, unsigned long start_time);
-void page_writeback_init(void);
 void balance_dirty_pages_ratelimited(struct address_space *mapping);
 bool wb_over_bg_thresh(struct bdi_writeback *wb);
 
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 30c2adbdebe8..9e687ca9a307 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -81,6 +81,7 @@
 
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
+	{1UL << PG_waiters,		"waiters"	},		\
 	{1UL << PG_error,		"error"		},		\
 	{1UL << PG_referenced,		"referenced"	},		\
 	{1UL << PG_uptodate,		"uptodate"	},		\
diff --git a/init/main.c b/init/main.c
index c81c9fa21bc7..b0c9d6facef9 100644
--- a/init/main.c
+++ b/init/main.c
@@ -647,9 +647,8 @@ asmlinkage __visible void __init start_kernel(void)
 	security_init();
 	dbg_late_init();
 	vfs_caches_init();
+	pagecache_init();
 	signals_init();
-	/* rootfs populating might need page-writeback */
-	page_writeback_init();
 	proc_root_init();
 	nsfs_init();
 	cpuset_init();
diff --git a/mm/filemap.c b/mm/filemap.c
index 32be3c8f3a11..82f26cde830c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -739,45 +739,159 @@ EXPORT_SYMBOL(__page_cache_alloc);
  * at a cost of "thundering herd" phenomena during rare hash
  * collisions.
  */
-wait_queue_head_t *page_waitqueue(struct page *page)
+#define PAGE_WAIT_TABLE_BITS 8
+#define PAGE_WAIT_TABLE_SIZE (1 << PAGE_WAIT_TABLE_BITS)
+static wait_queue_head_t page_wait_table[PAGE_WAIT_TABLE_SIZE] __cacheline_aligned;
+
+static wait_queue_head_t *page_waitqueue(struct page *page)
 {
-	return bit_waitqueue(page, 0);
+	return &page_wait_table[hash_ptr(page, PAGE_WAIT_TABLE_BITS)];
 }
-EXPORT_SYMBOL(page_waitqueue);
 
-void wait_on_page_bit(struct page *page, int bit_nr)
+void __init pagecache_init(void)
 {
-	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
+	int i;
 
-	if (test_bit(bit_nr, &page->flags))
-		__wait_on_bit(page_waitqueue(page), &wait, bit_wait_io,
-							TASK_UNINTERRUPTIBLE);
+	for (i = 0; i < PAGE_WAIT_TABLE_SIZE; i++)
+		init_waitqueue_head(&page_wait_table[i]);
+
+	page_writeback_init();
 }
-EXPORT_SYMBOL(wait_on_page_bit);
 
-int wait_on_page_bit_killable(struct page *page, int bit_nr)
+struct wait_page_key {
+	struct page *page;
+	int bit_nr;
+	int page_match;
+};
+
+struct wait_page_queue {
+	struct page *page;
+	int bit_nr;
+	wait_queue_t wait;
+};
+
+static int wake_page_function(wait_queue_t *wait, unsigned mode, int sync, void *arg)
 {
-	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
+	struct wait_page_key *key = arg;
+	struct wait_page_queue *wait_page
+		= container_of(wait, struct wait_page_queue, wait);
+
+	if (wait_page->page != key->page)
+	       return 0;
+	key->page_match = 1;
 
-	if (!test_bit(bit_nr, &page->flags))
+	if (wait_page->bit_nr != key->bit_nr)
+		return 0;
+	if (test_bit(key->bit_nr, &key->page->flags))
 		return 0;
 
-	return __wait_on_bit(page_waitqueue(page), &wait,
-			     bit_wait_io, TASK_KILLABLE);
+	return autoremove_wake_function(wait, mode, sync, key);
 }
 
-int wait_on_page_bit_killable_timeout(struct page *page,
-				       int bit_nr, unsigned long timeout)
+void wake_up_page_bit(struct page *page, int bit_nr)
 {
-	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
+	wait_queue_head_t *q = page_waitqueue(page);
+	struct wait_page_key key;
+	unsigned long flags;
 
-	wait.key.timeout = jiffies + timeout;
-	if (!test_bit(bit_nr, &page->flags))
-		return 0;
-	return __wait_on_bit(page_waitqueue(page), &wait,
-			     bit_wait_io_timeout, TASK_KILLABLE);
+	key.page = page;
+	key.bit_nr = bit_nr;
+	key.page_match = 0;
+
+	spin_lock_irqsave(&q->lock, flags);
+	__wake_up_locked_key(q, TASK_NORMAL, &key);
+	/*
+	 * It is possible for other pages to have collided on the waitqueue
+	 * hash, so in that case check for a page match. That prevents a long-
+	 * term waiter
+	 *
+	 * It is still possible to miss a case here, when we woke page waiters
+	 * and removed them from the waitqueue, but there are still other
+	 * page waiters.
+	 */
+	if (!waitqueue_active(q) || !key.page_match) {
+		ClearPageWaiters(page);
+		/*
+		 * It's possible to miss clearing Waiters here, when we woke
+		 * our page waiters, but the hashed waitqueue has waiters for
+		 * other pages on it.
+		 *
+		 * That's okay, it's a rare case. The next waker will clear it.
+		 */
+	}
+	spin_unlock_irqrestore(&q->lock, flags);
+}
+EXPORT_SYMBOL(wake_up_page_bit);
+
+static inline int wait_on_page_bit_common(wait_queue_head_t *q,
+		struct page *page, int bit_nr, int state, bool lock)
+{
+	struct wait_page_queue wait_page;
+	wait_queue_t *wait = &wait_page.wait;
+	int ret = 0;
+
+	init_wait(wait);
+	wait->func = wake_page_function;
+	wait_page.page = page;
+	wait_page.bit_nr = bit_nr;
+
+	for (;;) {
+		spin_lock_irq(&q->lock);
+
+		if (likely(list_empty(&wait->task_list))) {
+			if (lock)
+				__add_wait_queue_tail_exclusive(q, wait);
+			else
+				__add_wait_queue(q, wait);
+			SetPageWaiters(page);
+		}
+
+		set_current_state(state);
+
+		spin_unlock_irq(&q->lock);
+
+		if (likely(test_bit(bit_nr, &page->flags))) {
+			io_schedule();
+			if (unlikely(signal_pending_state(state, current))) {
+				ret = -EINTR;
+				break;
+			}
+		}
+
+		if (lock) {
+			if (!test_and_set_bit_lock(bit_nr, &page->flags))
+				break;
+		} else {
+			if (!test_bit(bit_nr, &page->flags))
+				break;
+		}
+	}
+
+	finish_wait(q, wait);
+
+	/*
+	 * A signal could leave PageWaiters set. Clearing it here if
+	 * !waitqueue_active would be possible (by open-coding finish_wait),
+	 * but still fail to catch it in the case of wait hash collision. We
+	 * already can fail to clear wait hash collision cases, so don't
+	 * bother with signals either.
+	 */
+
+	return ret;
+}
+
+void wait_on_page_bit(struct page *page, int bit_nr)
+{
+	wait_queue_head_t *q = page_waitqueue(page);
+	wait_on_page_bit_common(q, page, bit_nr, TASK_UNINTERRUPTIBLE, false);
+}
+EXPORT_SYMBOL(wait_on_page_bit);
+
+int wait_on_page_bit_killable(struct page *page, int bit_nr)
+{
+	wait_queue_head_t *q = page_waitqueue(page);
+	return wait_on_page_bit_common(q, page, bit_nr, TASK_KILLABLE, false);
 }
-EXPORT_SYMBOL_GPL(wait_on_page_bit_killable_timeout);
 
 /**
  * add_page_wait_queue - Add an arbitrary waiter to a page's wait queue
@@ -793,6 +907,7 @@ void add_page_wait_queue(struct page *page, wait_queue_t *waiter)
 
 	spin_lock_irqsave(&q->lock, flags);
 	__add_wait_queue(q, waiter);
+	SetPageWaiters(page);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 EXPORT_SYMBOL_GPL(add_page_wait_queue);
@@ -874,23 +989,19 @@ EXPORT_SYMBOL_GPL(page_endio);
  * __lock_page - get a lock on the page, assuming we need to sleep to get it
  * @page: the page to lock
  */
-void __lock_page(struct page *page)
+void __lock_page(struct page *__page)
 {
-	struct page *page_head = compound_head(page);
-	DEFINE_WAIT_BIT(wait, &page_head->flags, PG_locked);
-
-	__wait_on_bit_lock(page_waitqueue(page_head), &wait, bit_wait_io,
-							TASK_UNINTERRUPTIBLE);
+	struct page *page = compound_head(__page);
+	wait_queue_head_t *q = page_waitqueue(page);
+	wait_on_page_bit_common(q, page, PG_locked, TASK_UNINTERRUPTIBLE, true);
 }
 EXPORT_SYMBOL(__lock_page);
 
-int __lock_page_killable(struct page *page)
+int __lock_page_killable(struct page *__page)
 {
-	struct page *page_head = compound_head(page);
-	DEFINE_WAIT_BIT(wait, &page_head->flags, PG_locked);
-
-	return __wait_on_bit_lock(page_waitqueue(page_head), &wait,
-					bit_wait_io, TASK_KILLABLE);
+	struct page *page = compound_head(__page);
+	wait_queue_head_t *q = page_waitqueue(page);
+	return wait_on_page_bit_common(q, page, PG_locked, TASK_KILLABLE, true);
 }
 EXPORT_SYMBOL_GPL(__lock_page_killable);
 
diff --git a/mm/internal.h b/mm/internal.h
index 44d68895a9b9..7aa2ea0a8623 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -36,6 +36,8 @@
 /* Do not use these with a slab allocator */
 #define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
 
+void page_writeback_init(void);
+
 int do_swap_page(struct vm_fault *vmf);
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
diff --git a/mm/swap.c b/mm/swap.c
index 4dcf852e1e6d..844baedd2429 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -69,6 +69,7 @@ static void __page_cache_release(struct page *page)
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		spin_unlock_irqrestore(zone_lru_lock(zone), flags);
 	}
+	__ClearPageWaiters(page);
 	mem_cgroup_uncharge(page);
 }
 
@@ -784,6 +785,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 
 		/* Clear Active bit in case of parallel mark_page_accessed */
 		__ClearPageActive(page);
+		__ClearPageWaiters(page);
 
 		list_add(&page->lru, &pages_to_free);
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

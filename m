Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3066B02BC
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 03:04:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i88so2015154pfk.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 00:04:16 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id r70si1272096pfd.203.2016.11.02.00.04.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 00:04:15 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id n85so909318pfi.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 00:04:15 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH 2/2] mm: add PageWaiters bit to indicate waitqueue should be checked
Date: Wed,  2 Nov 2016 18:03:46 +1100
Message-Id: <20161102070346.12489-3-npiggin@gmail.com>
In-Reply-To: <20161102070346.12489-1-npiggin@gmail.com>
References: <20161102070346.12489-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>

Add a new page flag, PageWaiters. This bit is always set when the
page has waiters on page_waitqueue(page), within the same synchronization
scope as waitqueue_active(page) (i.e., it is manipulated under waitqueue
lock). It may be set in some cases where that condition is not true
(e.g., some scenarios of hash collisions or signals waking page waiters).

This bit can be used to avoid the costly waitqueue_active test for most
cases where the page has no waiters (the hashed address effectively adds
another line of cache footprint for most page operations). In cases where
the bit is set when the page has no waiters, the slower wakeup path will
end up clearing up the bit.

The generic bit-waitqueue infrastructure is no longer used for pages, and
instead waitqueues are used directly with a custom key type. The generic
code was not flexible enough to do PageWaiters manipulation under waitqueue
lock, or always allow danging bits to be cleared when no waiters for this
page on the waitqueue.

The upshot is that the page wait is much more flexible now, and could be
easily extended to wait on other properties of the page (by carrying that
data in the wait key).

This improves the performance of a streaming write into a preallocated
tmpfs file by 2.2% on a POWER8 system with 64K pages (which is pretty
significant if there is only a single unlock_page per 64K of copy_from_user).

Idea seems to have been around for a while, https://lwn.net/Articles/233391/

---
 include/linux/page-flags.h     |   2 +
 include/linux/pagemap.h        |  23 +++---
 include/trace/events/mmflags.h |   1 +
 mm/filemap.c                   | 157 ++++++++++++++++++++++++++++++++---------
 mm/swap.c                      |   2 +
 5 files changed, 138 insertions(+), 47 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 58d30b8..da40a1d 100644
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
@@ -255,6 +256,7 @@ static inline int TestClearPage##uname(struct page *page) { return 0; }
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
 __PAGEFLAG(Locked, locked, PF_NO_TAIL)
+PAGEFLAG(Waiters, waiters, PF_NO_COMPOUND) __CLEARPAGEFLAG(Waiters, waiters, PF_NO_COMPOUND)
 PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
 PAGEFLAG(Referenced, referenced, PF_HEAD)
 	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index dd15d39..97f2d0b 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -477,22 +477,14 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
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
@@ -508,6 +500,13 @@ static inline void wait_on_page_locked(struct page *page)
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
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 30c2adb..9e687ca 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -81,6 +81,7 @@
 
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
+	{1UL << PG_waiters,		"waiters"	},		\
 	{1UL << PG_error,		"error"		},		\
 	{1UL << PG_referenced,		"referenced"	},		\
 	{1UL << PG_uptodate,		"uptodate"	},		\
diff --git a/mm/filemap.c b/mm/filemap.c
index c7fe2f1..1ea42c1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -788,45 +788,135 @@ EXPORT_SYMBOL(__page_cache_alloc);
  * at a cost of "thundering herd" phenomena during rare hash
  * collisions.
  */
-wait_queue_head_t *page_waitqueue(struct page *page)
+static wait_queue_head_t *page_waitqueue(struct page *page)
 {
 	return bit_waitqueue(page, 0);
 }
-EXPORT_SYMBOL(page_waitqueue);
 
-void wait_on_page_bit(struct page *page, int bit_nr)
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
 
-	if (test_bit(bit_nr, &page->flags))
-		__wait_on_bit(page_waitqueue(page), &wait, bit_wait_io,
-							TASK_UNINTERRUPTIBLE);
+	if (wait_page->bit_nr != key->bit_nr)
+		return 0;
+	if (test_bit(key->bit_nr, &key->page->flags))
+		return 0;
+
+	return autoremove_wake_function(wait, mode, sync, key);
 }
-EXPORT_SYMBOL(wait_on_page_bit);
 
-int wait_on_page_bit_killable(struct page *page, int bit_nr)
+void wake_up_page_bit(struct page *page, int bit_nr)
 {
-	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
+	wait_queue_head_t *q = page_waitqueue(page);
+	struct wait_page_key key;
+	unsigned long flags;
 
-	if (!test_bit(bit_nr, &page->flags))
-		return 0;
+	key.page = page;
+	key.bit_nr = bit_nr;
+	key.page_match = 0;
 
-	return __wait_on_bit(page_waitqueue(page), &wait,
-			     bit_wait_io, TASK_KILLABLE);
+	spin_lock_irqsave(&q->lock, flags);
+	__wake_up_locked_key(q, TASK_NORMAL, &key);
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
 }
+EXPORT_SYMBOL(wake_up_page_bit);
 
-int wait_on_page_bit_killable_timeout(struct page *page,
-				       int bit_nr, unsigned long timeout)
+static inline int wait_on_page_bit_common(wait_queue_head_t *q,
+		struct page *page, int bit_nr, int state, bool lock)
 {
-	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
+	struct wait_page_queue wait_page;
+	wait_queue_t *wait = &wait_page.wait;
+	int ret = 0;
 
-	wait.key.timeout = jiffies + timeout;
-	if (!test_bit(bit_nr, &page->flags))
-		return 0;
-	return __wait_on_bit(page_waitqueue(page), &wait,
-			     bit_wait_io_timeout, TASK_KILLABLE);
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
+	 * !waitqueue_active would be possible, but still fail to catch it in
+	 * the case of wait hash collision. We already can fail to clear wait
+	 * hash collision cases, so don't bother with signals either.
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
@@ -842,6 +932,7 @@ void add_page_wait_queue(struct page *page, wait_queue_t *waiter)
 
 	spin_lock_irqsave(&q->lock, flags);
 	__add_wait_queue(q, waiter);
+	SetPageWaiters(page);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 EXPORT_SYMBOL_GPL(add_page_wait_queue);
@@ -923,23 +1014,19 @@ EXPORT_SYMBOL_GPL(page_endio);
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
 
diff --git a/mm/swap.c b/mm/swap.c
index 4dcf852..844baed 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

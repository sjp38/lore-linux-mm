Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 889C26B0276
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 07:56:48 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id rf5so19239816pab.3
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 04:56:48 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id yw4si6294534pab.235.2016.10.27.04.56.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 04:56:47 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id n85so2492192pfi.3
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 04:56:47 -0700 (PDT)
Date: Thu, 27 Oct 2016 22:56:35 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161027225635.4d2236fd@roar.ozlabs.ibm.com>
In-Reply-To: <20161027080852.GC3568@worktop.programming.kicks-ass.net>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
	<CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
	<CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
	<CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
	<20161026203158.GD2699@techsingularity.net>
	<CA+55aFy21NqcYTeLVVz4x4kfQ7A+o4HEv7srone6ppKAjCwn7g@mail.gmail.com>
	<20161026220339.GE2699@techsingularity.net>
	<CA+55aFwgZ6rUL2-KD7A38xEkALJcvk8foT2TBjLrvy8caj7k9w@mail.gmail.com>
	<20161026230726.GF2699@techsingularity.net>
	<20161027080852.GC3568@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, 27 Oct 2016 10:08:52 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Oct 27, 2016 at 12:07:26AM +0100, Mel Gorman wrote:
> > > but I consider PeterZ's
> > > patch the fix to that, so I wouldn't worry about it.
> > >   
> > 
> > Agreed. Peter, do you plan to finish that patch?  
> 
> I was waiting for you guys to hash out the 32bit issue. But if we're now
> OK with having this for 64bit only, I can certainly look at doing a new
> version.
> 
> I'll have to look at fixing Alpha's bitops for that first though,
> because as is that patch relies on atomics to the same word not needing
> ordering, but placing the contended/waiters bit in the high word for
> 64bit only sorta breaks that.

I got mine working too. Haven't removed the bitops barrier (that's
for another day), or sorted the page flags in this one. But the core
code is there.

It's a bit more intrusive than your patch, but I like the end result
better. It just stops using the generic bit waiter code completely
and uses its own keys. Ends up being making things easier, and we
could wait for other page details too if that was ever required.

It uses the same wait bit logic for all page waiters.
It keeps PageWaiters manipulation entirely under waitqueue lock, so no
additional data races beyond existing unlocked waitqueue_active tests.
And it checks to clear the waiter bit when no waiters for that page are
in the queue, so hash collisions with long waiters don't end up dragging
us into the slowpath always.

Also didn't uninline unlock_page yet. Still causes some text expansion,
but we should revisit that.

Thanks,
Nick

---
 include/linux/page-flags.h     |   2 +
 include/linux/pagemap.h        |  23 +++---
 include/trace/events/mmflags.h |   1 +
 mm/filemap.c                   | 157 ++++++++++++++++++++++++++++++++---------
 mm/swap.c                      |   2 +
 5 files changed, 138 insertions(+), 47 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 74e4dda..8059c04 100644
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
@@ -253,6 +254,7 @@ static inline int TestClearPage##uname(struct page *page) { return 0; }
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
index 5a81ab4..7ac8c0a 100644
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
index 849f459..cab1f87 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -788,47 +788,137 @@ EXPORT_SYMBOL(__page_cache_alloc);
  * at a cost of "thundering herd" phenomena during rare hash
  * collisions.
  */
-wait_queue_head_t *page_waitqueue(struct page *page)
+static wait_queue_head_t *page_waitqueue(struct page *page)
 {
 	const struct zone *zone = page_zone(page);
 
 	return &zone->wait_table[hash_ptr(page, zone->wait_table_bits)];
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
@@ -844,6 +934,7 @@ void add_page_wait_queue(struct page *page, wait_queue_t *waiter)
 
 	spin_lock_irqsave(&q->lock, flags);
 	__add_wait_queue(q, waiter);
+	SetPageWaiters(page);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 EXPORT_SYMBOL_GPL(add_page_wait_queue);
@@ -925,23 +1016,19 @@ EXPORT_SYMBOL_GPL(page_endio);
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 54B6D6B0297
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:34:35 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e20so38107910itc.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:34:35 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id g17si13672744ita.7.2016.09.27.07.34.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 07:34:34 -0700 (PDT)
Date: Tue, 27 Sep 2016 16:34:26 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160927143426.GP2794@worktop>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160927083104.GC2838@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Tue, Sep 27, 2016 at 09:31:04AM +0100, Mel Gorman wrote:
> page_waitqueue() has been a hazard for years. I think the last attempt to
> fix it was back in 2014 http://www.spinics.net/lists/linux-mm/msg73207.html
> 
> The patch is heavily derived from work by Nick Piggin who noticed the years
> before that. I think that was the last version I posted and the changelog
> includes profile data. I don't have an exact reference why it was rejected
> but a consistent piece of feedback was that it was very complex for the
> level of impact it had.

Right, I never really liked that patch. In any case, the below seems to
boot, although the lock_page_wait() thing did get my brain in a bit of a
twist. Doing explicit loops with PG_contended inside wq->lock would be
more obvious but results in much more code.

We could muck about with PG_contended naming/placement if any of this
shows benefit.

It does boot on my x86_64 and builds a kernel, so it must be perfect ;-)

---
 include/linux/page-flags.h     |  2 ++
 include/linux/pagemap.h        | 21 +++++++++----
 include/linux/wait.h           |  2 +-
 include/trace/events/mmflags.h |  1 +
 kernel/sched/wait.c            | 17 ++++++----
 mm/filemap.c                   | 71 ++++++++++++++++++++++++++++++++++++------
 6 files changed, 92 insertions(+), 22 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 74e4dda..0ed3900 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -73,6 +73,7 @@
  */
 enum pageflags {
 	PG_locked,		/* Page is locked. Don't touch. */
+	PG_contended,		/* Page lock is contended. */
 	PG_error,
 	PG_referenced,
 	PG_uptodate,
@@ -253,6 +254,7 @@ static inline int TestClearPage##uname(struct page *page) { return 0; }
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
 __PAGEFLAG(Locked, locked, PF_NO_TAIL)
+PAGEFLAG(Contended, contended, PF_NO_TAIL)
 PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
 PAGEFLAG(Referenced, referenced, PF_HEAD)
 	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 66a1260..3b38a96 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -417,7 +417,7 @@ extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
 extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 				unsigned int flags);
-extern void unlock_page(struct page *page);
+extern void __unlock_page(struct page *page);
 
 static inline int trylock_page(struct page *page)
 {
@@ -448,6 +448,16 @@ static inline int lock_page_killable(struct page *page)
 	return 0;
 }
 
+static inline void unlock_page(struct page *page)
+{
+	page = compound_head(page);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	clear_bit_unlock(PG_locked, &page->flags);
+	smp_mb__after_atomic();
+	if (PageContended(page))
+		__unlock_page(page);
+}
+
 /*
  * lock_page_or_retry - Lock the page, unless this would block and the
  * caller indicated that it can handle a retry.
@@ -472,11 +482,11 @@ extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
 extern int wait_on_page_bit_killable_timeout(struct page *page,
 					     int bit_nr, unsigned long timeout);
 
+extern int wait_on_page_lock(struct page *page, int mode);
+
 static inline int wait_on_page_locked_killable(struct page *page)
 {
-	if (!PageLocked(page))
-		return 0;
-	return wait_on_page_bit_killable(compound_head(page), PG_locked);
+	return wait_on_page_lock(page, TASK_KILLABLE);
 }
 
 extern wait_queue_head_t *page_waitqueue(struct page *page);
@@ -494,8 +504,7 @@ static inline void wake_up_page(struct page *page, int bit)
  */
 static inline void wait_on_page_locked(struct page *page)
 {
-	if (PageLocked(page))
-		wait_on_page_bit(compound_head(page), PG_locked);
+	wait_on_page_lock(page, TASK_UNINTERRUPTIBLE);
 }
 
 /* 
diff --git a/include/linux/wait.h b/include/linux/wait.h
index c3ff74d..524cd54 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -198,7 +198,7 @@ __remove_wait_queue(wait_queue_head_t *head, wait_queue_t *old)
 
 typedef int wait_bit_action_f(struct wait_bit_key *, int mode);
 void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
-void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key);
+int __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key);
 void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
 void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 5a81ab4..18b8398 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -81,6 +81,7 @@
 
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
+	{1UL << PG_contended,		"contended"	},		\
 	{1UL << PG_error,		"error"		},		\
 	{1UL << PG_referenced,		"referenced"	},		\
 	{1UL << PG_uptodate,		"uptodate"	},		\
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index f15d6b6..46dcc42 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -62,18 +62,23 @@ EXPORT_SYMBOL(remove_wait_queue);
  * started to run but is not in state TASK_RUNNING. try_to_wake_up() returns
  * zero in this (rare) case, and we handle it by continuing to scan the queue.
  */
-static void __wake_up_common(wait_queue_head_t *q, unsigned int mode,
+static int __wake_up_common(wait_queue_head_t *q, unsigned int mode,
 			int nr_exclusive, int wake_flags, void *key)
 {
 	wait_queue_t *curr, *next;
+	int woken = 0;
 
 	list_for_each_entry_safe(curr, next, &q->task_list, task_list) {
 		unsigned flags = curr->flags;
 
-		if (curr->func(curr, mode, wake_flags, key) &&
-				(flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
-			break;
+		if (curr->func(curr, mode, wake_flags, key)) {
+			woken++;
+			if ((flags & WQ_FLAG_EXCLUSIVE) && !--nr_exclusive)
+				break;
+		}
 	}
+
+	return woken;
 }
 
 /**
@@ -106,9 +111,9 @@ void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr)
 }
 EXPORT_SYMBOL_GPL(__wake_up_locked);
 
-void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key)
+int __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key)
 {
-	__wake_up_common(q, mode, 1, 0, key);
+	return __wake_up_common(q, mode, 1, 0, key);
 }
 EXPORT_SYMBOL_GPL(__wake_up_locked_key);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 8a287df..d3e3203 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -847,15 +847,18 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
  * The mb is necessary to enforce ordering between the clear_bit and the read
  * of the waitqueue (to avoid SMP races with a parallel wait_on_page_locked()).
  */
-void unlock_page(struct page *page)
+void __unlock_page(struct page *page)
 {
-	page = compound_head(page);
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	clear_bit_unlock(PG_locked, &page->flags);
-	smp_mb__after_atomic();
-	wake_up_page(page, PG_locked);
+	struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(&page->flags, PG_locked);
+	wait_queue_head_t *wq = page_waitqueue(page);
+	unsigned long flags;
+
+	spin_lock_irqsave(&wq->lock, flags);
+	if (!__wake_up_locked_key(wq, TASK_NORMAL, &key))
+		ClearPageContended(page);
+	spin_unlock_irqrestore(&wq->lock, flags);
 }
-EXPORT_SYMBOL(unlock_page);
+EXPORT_SYMBOL(__unlock_page);
 
 /**
  * end_page_writeback - end writeback against a page
@@ -908,6 +911,44 @@ void page_endio(struct page *page, bool is_write, int err)
 }
 EXPORT_SYMBOL_GPL(page_endio);
 
+static int lock_page_wait(struct wait_bit_key *word, int mode)
+{
+	struct page *page = container_of(word->flags, struct page, flags);
+
+	/*
+	 * Set PG_contended now that we're enqueued on the waitqueue, this
+	 * way we cannot race against ClearPageContended in wakeup.
+	 */
+	if (!PageContended(page)) {
+		SetPageContended(page);
+
+		/*
+		 * If we set PG_contended, we must order against any later list
+		 * addition and/or a later PG_lock load.
+		 *
+		 *  [unlock]			[wait]
+		 *
+		 *  clear PG_locked		set PG_contended
+		 *  test  PG_contended		test-and-set PG_locked
+		 *
+		 * and
+		 *
+		 *  [unlock]			[wait]
+		 *
+		 *  test PG_contended		set PG_contended
+		 *  wakeup			add
+		 *  clear PG_contended		sleep
+		 *
+		 * In either case we must not reorder nor sleep before
+		 * PG_contended is visible.
+		 */
+		smp_mb__after_atomic();
+		return 0;
+	}
+
+	return bit_wait_io(word, mode);
+}
+
 /**
  * __lock_page - get a lock on the page, assuming we need to sleep to get it
  * @page: the page to lock
@@ -917,7 +958,7 @@ void __lock_page(struct page *page)
 	struct page *page_head = compound_head(page);
 	DEFINE_WAIT_BIT(wait, &page_head->flags, PG_locked);
 
-	__wait_on_bit_lock(page_waitqueue(page_head), &wait, bit_wait_io,
+	__wait_on_bit_lock(page_waitqueue(page_head), &wait, lock_page_wait,
 							TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(__lock_page);
@@ -928,10 +969,22 @@ int __lock_page_killable(struct page *page)
 	DEFINE_WAIT_BIT(wait, &page_head->flags, PG_locked);
 
 	return __wait_on_bit_lock(page_waitqueue(page_head), &wait,
-					bit_wait_io, TASK_KILLABLE);
+					lock_page_wait, TASK_KILLABLE);
 }
 EXPORT_SYMBOL_GPL(__lock_page_killable);
 
+int wait_on_page_lock(struct page *page, int mode)
+{
+	struct page __always_unused *__page = (page = compound_head(page));
+	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+
+	if (!PageLocked(page))
+		return 0;
+
+	return __wait_on_bit(page_waitqueue(page), &wait, lock_page_wait, mode);
+}
+EXPORT_SYMBOL(wait_on_page_lock);
+
 /*
  * Return values:
  * 1 - page is locked; mmap_sem is still held.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

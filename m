Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5017C6B0275
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 04:09:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n85so5482639pfi.4
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 01:09:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 1si6573237pgx.287.2016.10.27.01.08.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 01:08:59 -0700 (PDT)
Date: Thu, 27 Oct 2016 10:08:52 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161027080852.GC3568@worktop.programming.kicks-ass.net>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <20161026203158.GD2699@techsingularity.net>
 <CA+55aFy21NqcYTeLVVz4x4kfQ7A+o4HEv7srone6ppKAjCwn7g@mail.gmail.com>
 <20161026220339.GE2699@techsingularity.net>
 <CA+55aFwgZ6rUL2-KD7A38xEkALJcvk8foT2TBjLrvy8caj7k9w@mail.gmail.com>
 <20161026230726.GF2699@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161026230726.GF2699@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, Oct 27, 2016 at 12:07:26AM +0100, Mel Gorman wrote:
> > but I consider PeterZ's
> > patch the fix to that, so I wouldn't worry about it.
> > 
> 
> Agreed. Peter, do you plan to finish that patch?

I was waiting for you guys to hash out the 32bit issue. But if we're now
OK with having this for 64bit only, I can certainly look at doing a new
version.

I'll have to look at fixing Alpha's bitops for that first though,
because as is that patch relies on atomics to the same word not needing
ordering, but placing the contended/waiters bit in the high word for
64bit only sorta breaks that.

Hurm, we could of course play games with the layout, the 64bit only
flags don't _have_ to be at the end.

Something like so could work I suppose, but then there's a slight
regression in the page_unlock() path, where we now do an unconditional
spinlock; iow. we loose the unlocked waitqueue_active() test.

We could re-instate this with an #ifndef CONFIG_NUMA I suppose.. not
pretty though.

Also did the s/contended/waiters/ rename per popular request.

---
 include/linux/page-flags.h     |   19 ++++++++
 include/linux/pagemap.h        |   25 ++++++++--
 include/trace/events/mmflags.h |    7 +++
 mm/filemap.c                   |   94 +++++++++++++++++++++++++++++++++++++----
 4 files changed, 130 insertions(+), 15 deletions(-)

--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -73,6 +73,14 @@
  */
 enum pageflags {
 	PG_locked,		/* Page is locked. Don't touch. */
+#ifdef CONFIG_NUMA
+	/*
+	 * This bit must end up in the same word as PG_locked (or any other bit
+	 * we're waiting on), as per all architectures their bitop
+	 * implementations.
+	 */
+	PG_waiters,		/* The hashed waitqueue has waiters */
+#endif
 	PG_error,
 	PG_referenced,
 	PG_uptodate,
@@ -231,6 +239,9 @@ static __always_inline int TestClearPage
 #define TESTPAGEFLAG_FALSE(uname)					\
 static inline int Page##uname(const struct page *page) { return 0; }
 
+#define TESTPAGEFLAG_TRUE(uname)					\
+static inline int Page##uname(const struct page *page) { return 1; }
+
 #define SETPAGEFLAG_NOOP(uname)						\
 static inline void SetPage##uname(struct page *page) {  }
 
@@ -249,10 +260,18 @@ static inline int TestClearPage##uname(s
 #define PAGEFLAG_FALSE(uname) TESTPAGEFLAG_FALSE(uname)			\
 	SETPAGEFLAG_NOOP(uname) CLEARPAGEFLAG_NOOP(uname)
 
+#define PAGEFLAG_TRUE(uname) TESTPAGEFLAG_TRUE(uname)			\
+	SETPAGEFLAG_NOOP(uname) CLEARPAGEFLAG_NOOP(uname)
+
 #define TESTSCFLAG_FALSE(uname)						\
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
 
 __PAGEFLAG(Locked, locked, PF_NO_TAIL)
+#ifdef CONFIG_NUMA
+PAGEFLAG(Waiters, waiters, PF_NO_TAIL)
+#else
+PAGEFLAG_TRUE(Waiters);
+#endif
 PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUND)
 PAGEFLAG(Referenced, referenced, PF_HEAD)
 	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -427,7 +427,7 @@ extern void __lock_page(struct page *pag
 extern int __lock_page_killable(struct page *page);
 extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 				unsigned int flags);
-extern void unlock_page(struct page *page);
+extern void __unlock_page(struct page *page);
 
 static inline int trylock_page(struct page *page)
 {
@@ -458,6 +458,20 @@ static inline int lock_page_killable(str
 	return 0;
 }
 
+static inline void unlock_page(struct page *page)
+{
+	page = compound_head(page);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	clear_bit_unlock(PG_locked, &page->flags);
+	/*
+	 * Since PG_locked and PG_waiters are in the same word, Program-Order
+	 * ensures the load of PG_waiters must not observe a value earlier
+	 * than our clear_bit() store.
+	 */
+	if (PageWaiters(page))
+		__unlock_page(page);
+}
+
 /*
  * lock_page_or_retry - Lock the page, unless this would block and the
  * caller indicated that it can handle a retry.
@@ -482,11 +496,11 @@ extern int wait_on_page_bit_killable(str
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
@@ -504,8 +518,7 @@ static inline void wake_up_page(struct p
  */
 static inline void wait_on_page_locked(struct page *page)
 {
-	if (PageLocked(page))
-		wait_on_page_bit(compound_head(page), PG_locked);
+	wait_on_page_lock(page, TASK_UNINTERRUPTIBLE);
 }
 
 /* 
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -55,6 +55,12 @@
 	__def_gfpflag_names						\
 	) : "none"
 
+#ifdef CONFIG_NUMA
+#define IF_HAVE_PG_WAITERS(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_WAITERS(flag,string)
+#endif
+
 #ifdef CONFIG_MMU
 #define IF_HAVE_PG_MLOCK(flag,string) ,{1UL << flag, string}
 #else
@@ -81,6 +87,7 @@
 
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
+IF_HAVE_PG_WAITERS(PG_waiters,		"waiters"	)		\
 	{1UL << PG_error,		"error"		},		\
 	{1UL << PG_referenced,		"referenced"	},		\
 	{1UL << PG_uptodate,		"uptodate"	},		\
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -860,15 +860,30 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
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
+	wait_queue_head_t *wq = page_waitqueue(page);
+	unsigned long flags;
+
+	spin_lock_irqsave(&wq->lock, flags);
+	if (waitqueue_active(wq)) {
+		struct wait_bit_key key =
+			__WAIT_BIT_KEY_INITIALIZER(&page->flags, PG_locked);
+
+		__wake_up_locked_key(wq, TASK_NORMAL, &key);
+	} else {
+		/*
+		 * We need to do ClearPageWaiters() under wq->lock such that
+		 * we serialize against prepare_to_wait() adding waiters and
+		 * setting task_struct::state.
+		 *
+		 * See lock_page_wait().
+		 */
+		ClearPageWaiters(page);
+	}
+	spin_unlock_irqrestore(&wq->lock, flags);
 }
-EXPORT_SYMBOL(unlock_page);
+EXPORT_SYMBOL(__unlock_page);
 
 /**
  * end_page_writeback - end writeback against a page
@@ -921,6 +936,55 @@ void page_endio(struct page *page, bool
 }
 EXPORT_SYMBOL_GPL(page_endio);
 
+static int lock_page_wait(struct wait_bit_key *word, int mode)
+{
+	struct page *page = container_of(word->flags, struct page, flags);
+
+	/*
+	 * We cannot go sleep without having PG_waiters set. This would mean
+	 * nobody would issue a wakeup and we'd be stuck.
+	 */
+	if (!PageWaiters(page)) {
+
+		/*
+		 * There are two orderings of importance:
+		 *
+		 * 1)
+		 *
+		 *  [unlock]			[wait]
+		 *
+		 *  clear PG_locked		set PG_waiters
+		 *  test  PG_waiters		test (and-set) PG_locked
+		 *
+		 * Since these are in the same word, and the clear/set
+		 * operation are atomic, they are ordered against one another.
+		 * Program-Order further constraints a CPU from speculating the
+		 * later load to not be earlier than the RmW. So this doesn't
+		 * need an explicit barrier. Also see unlock_page().
+		 *
+		 * 2)
+		 *
+		 *  [unlock]			[wait]
+		 *
+		 *  LOCK wq->lock		LOCK wq->lock
+		 *    __wake_up_locked ||	  list-add
+		 *    clear PG_waiters		set_current_state()
+		 *  UNLOCK wq->lock		UNLOCK wq->lock
+		 *				set PG_waiters
+		 *
+		 * Since we're added to the waitqueue, we cannot get
+		 * PG_waiters cleared without also getting TASK_RUNNING set,
+		 * which will then void the schedule() call and we'll loop.
+		 * Here wq->lock is sufficient ordering. See __unlock_page().
+		 */
+		SetPageWaiters(page);
+
+		return 0;
+	}
+
+	return bit_wait_io(word, mode);
+}
+
 /**
  * __lock_page - get a lock on the page, assuming we need to sleep to get it
  * @page: the page to lock
@@ -930,7 +994,7 @@ void __lock_page(struct page *page)
 	struct page *page_head = compound_head(page);
 	DEFINE_WAIT_BIT(wait, &page_head->flags, PG_locked);
 
-	__wait_on_bit_lock(page_waitqueue(page_head), &wait, bit_wait_io,
+	__wait_on_bit_lock(page_waitqueue(page_head), &wait, lock_page_wait,
 							TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(__lock_page);
@@ -941,10 +1005,22 @@ int __lock_page_killable(struct page *pa
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

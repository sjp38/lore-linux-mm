Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 776E36B0389
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 03:32:48 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so307865354pfb.6
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 00:32:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id y32si9069475plh.229.2016.12.21.00.32.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 00:32:47 -0800 (PST)
Date: Wed, 21 Dec 2016 09:32:47 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Message-ID: <20161221083247.GW3174@twins.programming.kicks-ass.net>
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
 <CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
 <156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
 <CA+55aFxVzes5Jt-hC9BLVSb99x6K-_WkLO-_JTvCjhf5wuK_4w@mail.gmail.com>
 <CA+55aFwy6+ya_E8N3DFbrq2XjbDs8LWe=W_qW8awimbxw26bJw@mail.gmail.com>
 <20161221080931.GQ3124@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161221080931.GQ3124@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Wed, Dec 21, 2016 at 09:09:31AM +0100, Peter Zijlstra wrote:
> On Tue, Dec 20, 2016 at 10:02:46AM -0800, Linus Torvalds wrote:
> > On Tue, Dec 20, 2016 at 9:31 AM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:
> > >
> > > I'll go back and try to see why the page flag contention patch didn't
> > > get applied.
> > 
> > Ahh, a combination of warring patches by Nick and PeterZ, and worry
> > about the page flag bits.
> 
> I think Nick actually had a patch freeing up a pageflag, although Hugh
> had a comment on that.
> 
> That said, I'm not a huge fan of his waiters patch, I'm still not sure
> why he wants to write another whole wait loop, but whatever. Whichever
> you prefer I suppose.

FWIW, here's mine.. compiles and boots on a NUMA x86_64 machine.

---
Subject: mm: Avoid slow path for unlock_page()
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 27 Oct 2016 10:08:52 +0200

Currently we uncontidionally look up the page waitqueue and issue the
wakeup for unlock_page(), even though there might not be anybody
waiting.

Use another pageflag (PG_waiters) to keep track of the waitqueue state
such that we can avoid the work when there are in fact no waiters
queued.

Currently guarded by CONFIG_NUMA, which is not strictly correct as
I've been told there actually are 32bit architectures that have NUMA.
Ideally Nick manages to reclaim a pageflag and we can make this
unconditional.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
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
@@ -436,7 +436,7 @@ extern void __lock_page(struct page *pag
 extern int __lock_page_killable(struct page *page);
 extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 				unsigned int flags);
-extern void unlock_page(struct page *page);
+extern void __unlock_page(struct page *page);
 
 static inline int trylock_page(struct page *page)
 {
@@ -467,6 +467,20 @@ static inline int lock_page_killable(str
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
@@ -491,11 +505,11 @@ extern int wait_on_page_bit_killable(str
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
@@ -513,8 +527,7 @@ static inline void wake_up_page(struct p
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
+#define IF_HAVE_PG_WAITERS(flag,string) {1UL << flag, string},
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
@@ -809,15 +809,30 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
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
@@ -870,6 +885,55 @@ void page_endio(struct page *page, bool
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
@@ -879,7 +943,7 @@ void __lock_page(struct page *page)
 	struct page *page_head = compound_head(page);
 	DEFINE_WAIT_BIT(wait, &page_head->flags, PG_locked);
 
-	__wait_on_bit_lock(page_waitqueue(page_head), &wait, bit_wait_io,
+	__wait_on_bit_lock(page_waitqueue(page_head), &wait, lock_page_wait,
 							TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(__lock_page);
@@ -890,10 +954,22 @@ int __lock_page_killable(struct page *pa
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

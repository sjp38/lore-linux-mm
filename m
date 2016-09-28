Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5E86B0293
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 07:11:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 2so21448741pfs.1
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 04:11:20 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id fg13si8060251pac.126.2016.09.28.04.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 04:11:19 -0700 (PDT)
Date: Wed, 28 Sep 2016 13:11:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160928111115.GS5016@twins.programming.kicks-ass.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160927143426.GP2794@worktop>
 <20160928104500.GC3903@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160928104500.GC3903@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Sep 28, 2016 at 11:45:00AM +0100, Mel Gorman wrote:

> tldr: Other than 32-bit vs 64-bit, I could not find anything obviously wrong.

Thanks, meanwhile I redid the patch based on the feedback from Nick and
Linus.

I know I ignored the 32bit issue, I figured we'd first see if it helps
at all before mucking about with that.

In any case, I don't mind doing a PG_waiters and also using it for the
PG_writeback thing. Just wasn't what I was thinking of when doing that
patch.

Re the naming of __unlock_page(), its the slow path continuation of
unlock_page(). But I'm not too bothered if people want to change the
name.

So the below boots and builds a kernel and must be equally perfect, then
again x86 has no-op smp_mb__{before,after}_atomic() so the lack of
barriers will not affect anything much. PowerPC, ARM and MIPS (among
others) will want testing.

---
 include/linux/page-flags.h     |  2 ++
 include/linux/pagemap.h        | 25 +++++++++----
 include/trace/events/mmflags.h |  1 +
 mm/filemap.c                   | 80 +++++++++++++++++++++++++++++++++++++-----
 4 files changed, 93 insertions(+), 15 deletions(-)

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
index 66a1260..c8b8651 100644
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
@@ -448,6 +448,20 @@ static inline int lock_page_killable(struct page *page)
 	return 0;
 }
 
+static inline void unlock_page(struct page *page)
+{
+	page = compound_head(page);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	clear_bit_unlock(PG_locked, &page->flags);
+	/*
+	 * Since PG_locked and PG_contended are in the same word, Program-Order
+	 * ensures the load of PG_contended must not observe a value earlier
+	 * than our clear_bit() store. See lock_page_wait().
+	 */
+	if (PageContended(page))
+		__unlock_page(page);
+}
+
 /*
  * lock_page_or_retry - Lock the page, unless this would block and the
  * caller indicated that it can handle a retry.
@@ -472,11 +486,11 @@ extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
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
@@ -494,8 +508,7 @@ static inline void wake_up_page(struct page *page, int bit)
  */
 static inline void wait_on_page_locked(struct page *page)
 {
-	if (PageLocked(page))
-		wait_on_page_bit(compound_head(page), PG_locked);
+	wait_on_page_lock(page, TASK_UNINTERRUPTIBLE);
 }
 
 /* 
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
diff --git a/mm/filemap.c b/mm/filemap.c
index 8a287df..79aab60 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -847,15 +847,17 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
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
+
+	if (waitqueue_active(wq))
+		__wake_up(wq, TASK_NORMAL, 1, &key);
+	else
+		ClearPageContended(page);
 }
-EXPORT_SYMBOL(unlock_page);
+EXPORT_SYMBOL(__unlock_page);
 
 /**
  * end_page_writeback - end writeback against a page
@@ -908,6 +910,54 @@ void page_endio(struct page *page, bool is_write, int err)
 }
 EXPORT_SYMBOL_GPL(page_endio);
 
+static int lock_page_wait(struct wait_bit_key *word, int mode)
+{
+	struct page *page = container_of(word->flags, struct page, flags);
+
+	/*
+	 * We cannot go sleep without having PG_contended set. This would mean
+	 * nobody would issue a wakeup and we'd be stuck.
+	 */
+	if (!PageContended(page)) {
+		SetPageContended(page);
+
+		/*
+		 * There are two orderings of importance:
+		 *
+		 * 1)
+		 *
+		 *  [unlock]			[wait]
+		 *
+		 *  clear PG_locked		set PG_contended
+		 *  test  PG_contended		test (and-set) PG_locked
+		 *
+		 * Since these are on the same word, and the clear/set
+		 * operation are atomic, they are ordered against one another.
+		 * Program-Order further constraints a CPU from speculating the
+		 * later load to not be earlier than the RmW. So this doesn't
+		 * need an explicit barrier. Also see unlock_page().
+		 *
+		 * 2)
+		 *
+		 *  [unlock]			[wait]
+		 *
+		 *  test PG_contended		set PG_contended
+		 *  wakeup/remove		add
+		 *  clear PG_contended		trylock
+		 *				sleep
+		 *
+		 * In this case however, we must ensure PG_contended is set
+		 * before we add ourselves to the list, such that unlock() must
+		 * either see PG_contended or we see its clear.
+		 */
+		smp_mb__after_atomic();
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
@@ -917,7 +967,7 @@ void __lock_page(struct page *page)
 	struct page *page_head = compound_head(page);
 	DEFINE_WAIT_BIT(wait, &page_head->flags, PG_locked);
 
-	__wait_on_bit_lock(page_waitqueue(page_head), &wait, bit_wait_io,
+	__wait_on_bit_lock(page_waitqueue(page_head), &wait, lock_page_wait,
 							TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(__lock_page);
@@ -928,10 +978,22 @@ int __lock_page_killable(struct page *page)
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

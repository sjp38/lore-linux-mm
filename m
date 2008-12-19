Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3906B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 02:27:04 -0500 (EST)
Date: Fri, 19 Dec 2008 08:29:09 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch] unlock_page speedup
Message-ID: <20081219072909.GC26419@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Here is another one (background: lmbench lat_mmap primarily MAP_SHARED fault
benchmark has regressed quite a bit since anybody last cared to look, I'm
trying to find some improvements).

OK, so one thing we do is lock the page in the page fault path to cover some
nasty races... This patch gets back another 2% (453.12us to 442.9us), by
speeding up unlock_page by using an extra bit to signal contention. This
actually helps powerpc far more than x86, but I'm glad to see x86 still
has a nice win from avoiding the function call and hash cacheline lookup.

lat_mmap profile goes from looking like this (after the mnt_want_write patches)
CPU: AMD64 family10, speed 2000 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit mask of 0x00 (No unit mask) count 10000
samples  %        symbol name
254150   14.5889  __do_fault
163003    9.3568  unmap_vmas
110232    6.3276  mark_page_accessed
77864     4.4696  __up_read
75864     4.3548  page_waitqueue     <<<<
69984     4.0173  handle_mm_fault
66945     3.8428  do_page_fault
66457     3.8148  retint_swapgs
65413     3.7549  shmem_getpage
62904     3.6109  file_update_time
61430     3.5262  set_page_dirty
53425     3.0667  unlock_page        <<<<

To this:
3119      0.1430  unlock_page
0         0.0000  page_waitqueue

--
Introduce a new page flag, PG_waiters, to signal there are processes waiting on
PG_lock; and use it to avoid memory barriers and waitqueue hash lookup in the
unlock_page fastpath.


---
 include/linux/page-flags.h |    4 +-
 include/linux/pagemap.h    |    7 ++-
 kernel/wait.c              |    3 -
 mm/filemap.c               |   89 ++++++++++++++++++++++++++++++++++++---------
 4 files changed, 81 insertions(+), 22 deletions(-)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -71,6 +71,7 @@
  */
 enum pageflags {
 	PG_locked,		/* Page is locked. Don't touch. */
+	PG_waiters,		/* Page has PG_locked waiters. */
 	PG_error,
 	PG_referenced,
 	PG_uptodate,
@@ -181,6 +182,7 @@ static inline int TestClearPage##uname(s
 struct page;	/* forward declaration */
 
 TESTPAGEFLAG(Locked, locked)
+PAGEFLAG(Waiters, waiters)
 PAGEFLAG(Error, error)
 PAGEFLAG(Referenced, referenced) TESTCLEARFLAG(Referenced, referenced)
 PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
@@ -373,7 +375,7 @@ static inline void __ClearPageTail(struc
 #endif
 
 #define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
-			 1 << PG_buddy | 1 << PG_writeback | \
+			 1 << PG_waiters | 1 << PG_buddy | 1 << PG_writeback | \
 			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active | \
 			 __PG_UNEVICTABLE | __PG_MLOCKED)
 
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -189,7 +189,7 @@ static inline int page_cache_add_specula
 	if (unlikely(!atomic_add_unless(&page->_count, count, 0)))
 		return 0;
 #endif
-	VM_BUG_ON(PageCompound(page) && page != compound_head(page));
+	VM_BUG_ON(PageTail(page));
 
 	return 1;
 }
@@ -353,6 +353,7 @@ static inline void lock_page_nosync(stru
  * Never use this directly!
  */
 extern void wait_on_page_bit(struct page *page, int bit_nr);
+extern void __wait_on_page_locked(struct page *page);
 
 /* 
  * Wait for a page to be unlocked.
@@ -363,8 +364,9 @@ extern void wait_on_page_bit(struct page
  */
 static inline void wait_on_page_locked(struct page *page)
 {
+	might_sleep();
 	if (PageLocked(page))
-		wait_on_page_bit(page, PG_locked);
+		__wait_on_page_locked(page);
 }
 
 /* 
@@ -372,6 +374,7 @@ static inline void wait_on_page_locked(s
  */
 static inline void wait_on_page_writeback(struct page *page)
 {
+	might_sleep();
 	if (PageWriteback(page))
 		wait_on_page_bit(page, PG_writeback);
 }
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -180,6 +180,7 @@ static int sync_page(void *word)
 	if (mapping && mapping->a_ops && mapping->a_ops->sync_page)
 		mapping->a_ops->sync_page(page);
 	io_schedule();
+
 	return 0;
 }
 
@@ -526,12 +527,6 @@ struct page *__page_cache_alloc(gfp_t gf
 EXPORT_SYMBOL(__page_cache_alloc);
 #endif
 
-static int __sleep_on_page_lock(void *word)
-{
-	io_schedule();
-	return 0;
-}
-
 /*
  * In order to wait for pages to become available there must be
  * waitqueues associated with pages. By using a hash table of
@@ -564,6 +559,22 @@ void wait_on_page_bit(struct page *page,
 }
 EXPORT_SYMBOL(wait_on_page_bit);
 
+/*
+ * If PageWaiters was found to be set at unlock time, __wake_page_waiters
+ * should be called to actually perform the wakeup of waiters.
+ */
+static void __wake_page_waiters(struct page *page)
+{
+	ClearPageWaiters(page);
+	/*
+	 * The smp_mb() is necessary to enforce ordering between the clear_bit
+	 * and the read of the waitqueue (to avoid SMP races with a parallel
+	 * __wait_on_page_locked()).
+	 */
+	smp_mb__after_clear_bit();
+	wake_up_page(page, PG_locked);
+}
+
 /**
  * unlock_page - unlock a locked page
  * @page: the page
@@ -580,8 +591,8 @@ void unlock_page(struct page *page)
 {
 	VM_BUG_ON(!PageLocked(page));
 	clear_bit_unlock(PG_locked, &page->flags);
-	smp_mb__after_clear_bit();
-	wake_up_page(page, PG_locked);
+	if (unlikely(PageWaiters(page)))
+		__wake_page_waiters(page);
 }
 EXPORT_SYMBOL(unlock_page);
 
@@ -611,22 +622,59 @@ EXPORT_SYMBOL(end_page_writeback);
  * chances are that on the second loop, the block layer's plug list is empty,
  * so sync_page() will then return in state TASK_UNINTERRUPTIBLE.
  */
-void __lock_page(struct page *page)
+void  __lock_page(struct page *page)
 {
+	wait_queue_head_t *wq = page_waitqueue(page);
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
-	__wait_on_bit_lock(page_waitqueue(page), &wait, sync_page,
-							TASK_UNINTERRUPTIBLE);
+	do {
+		prepare_to_wait(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
+		SetPageWaiters(page);
+		if (likely(PageLocked(page)))
+			sync_page(page);
+	} while (!trylock_page(page));
+	finish_wait(wq, &wait.wait);
 }
 EXPORT_SYMBOL(__lock_page);
 
-int __lock_page_killable(struct page *page)
+int  __lock_page_killable(struct page *page)
+{
+	wait_queue_head_t *wq = page_waitqueue(page);
+	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+	int err = 0;
+
+	do {
+		prepare_to_wait(wq, &wait.wait, TASK_KILLABLE);
+		SetPageWaiters(page);
+		if (likely(PageLocked(page))) {
+			err = sync_page_killable(page);
+			if (err)
+				break;
+		}
+	} while (!trylock_page(page));
+	finish_wait(wq, &wait.wait);
+
+	return err;
+}
+
+void  __wait_on_page_locked(struct page *page)
 {
+	wait_queue_head_t *wq = page_waitqueue(page);
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
-	return __wait_on_bit_lock(page_waitqueue(page), &wait,
-					sync_page_killable, TASK_KILLABLE);
+	do {
+		prepare_to_wait(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
+		SetPageWaiters(page);
+		if (likely(PageLocked(page)))
+			sync_page(page);
+	} while (PageLocked(page));
+	finish_wait(wq, &wait.wait);
+
+	/* Clean up a potentially dangling PG_waiters */
+	if (unlikely(PageWaiters(page)))
+		__wake_page_waiters(page);
 }
+EXPORT_SYMBOL(__wait_on_page_locked);
 
 /**
  * __lock_page_nosync - get a lock on the page, without calling sync_page()
@@ -635,11 +683,18 @@ int __lock_page_killable(struct page *pa
  * Variant of lock_page that does not require the caller to hold a reference
  * on the page's mapping.
  */
-void __lock_page_nosync(struct page *page)
+void  __lock_page_nosync(struct page *page)
 {
+	wait_queue_head_t *wq = page_waitqueue(page);
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
-	__wait_on_bit_lock(page_waitqueue(page), &wait, __sleep_on_page_lock,
-							TASK_UNINTERRUPTIBLE);
+
+	do {
+		prepare_to_wait(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
+		SetPageWaiters(page);
+		if (likely(PageLocked(page)))
+			io_schedule();
+	} while (!trylock_page(page));
+	finish_wait(wq, &wait.wait);
 }
 
 /**
Index: linux-2.6/kernel/wait.c
===================================================================
--- linux-2.6.orig/kernel/wait.c
+++ linux-2.6/kernel/wait.c
@@ -134,8 +134,7 @@ int wake_bit_function(wait_queue_t *wait
 		= container_of(wait, struct wait_bit_queue, wait);
 
 	if (wait_bit->key.flags != key->flags ||
-			wait_bit->key.bit_nr != key->bit_nr ||
-			test_bit(key->bit_nr, key->flags))
+			wait_bit->key.bit_nr != key->bit_nr)
 		return 0;
 	else
 		return autoremove_wake_function(wait, mode, sync, key);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

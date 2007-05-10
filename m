Date: Thu, 10 May 2007 05:37:36 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] optimise unlock_page
Message-ID: <20070510033736.GA19196@wotan.suse.de>
References: <20070508113709.GA19294@wotan.suse.de> <20070508114003.GB19294@wotan.suse.de> <1178659827.14928.85.camel@localhost.localdomain> <20070508224124.GD20174@wotan.suse.de> <20070508225012.GF20174@wotan.suse.de> <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 09, 2007 at 08:33:15PM +0100, Hugh Dickins wrote:
> 
> Not good enough, I'm afraid.  It looks like Ben's right and you need
> a count - and counts in the page struct are a lot harder to add than
> page flags.
> 
> I've now played around with the hangs on my three 4CPU machines
> (all of them in io_schedule below __lock_page, waiting on pages
> which were neither PG_locked nor PG_waiters when I looked).
> 
> Seeing Ben's mail, I thought the answer would be just to remove
> the "_exclusive" from your three prepare_to_wait_exclusive()s.
> That helped, but it didn't eliminate the hangs.
> 
> After fiddling around with different ideas for some while, I came
> to realize that the ClearPageWaiters (in very misleadingly named
> __unlock_page) is hopeless.  It's just so easy for it to clear the
> PG_waiters that a third task relies upon for wakeup (and which
> cannot loop around to set it again, because it simply won't be
> woken by unlock_page/__unlock_page without it already being set).

OK, I found a simple bug after pulling out my hair for a while :)
With this, a 4-way system survives a couple of concurrent make -j250s
quite nicely (wheras they eventually locked up before).

The problem is that the bit wakeup function did not go through with
the wakeup if it found the bit (ie. PG_locked) set. This meant that
waiters would not get a chance to reset PG_waiters.

However you probably weren't referring to that particular problem
when you imagined the need for a full count, or the slippery 3rd
task... I wasn't able to derive any such problems with the basic
logic, so if there was a bug there, it would still be unfixed in this
patch.
---

Speed up unlock_page by introducing a new page flag to signal that there are
page waitqueue waiters for PG_locked. This means a memory barrier and a random
waitqueue hash cacheline load can be avoided in the fastpath when there is no
contention.

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2007-05-10 10:22:05.000000000 +1000
+++ linux-2.6/include/linux/page-flags.h	2007-05-10 10:22:06.000000000 +1000
@@ -91,6 +91,8 @@
 #define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
+#define PG_waiters		20	/* Page has PG_locked waiters */
+
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
 
@@ -113,6 +115,10 @@
 #define SetPageLocked(page)		\
 		set_bit(PG_locked, &(page)->flags)
 
+#define PageWaiters(page)	test_bit(PG_waiters, &(page)->flags)
+#define SetPageWaiters(page)	set_bit(PG_waiters, &(page)->flags)
+#define ClearPageWaiters(page)	clear_bit(PG_waiters, &(page)->flags)
+
 #define PageError(page)		test_bit(PG_error, &(page)->flags)
 #define SetPageError(page)	set_bit(PG_error, &(page)->flags)
 #define ClearPageError(page)	clear_bit(PG_error, &(page)->flags)
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2007-05-10 10:22:05.000000000 +1000
+++ linux-2.6/include/linux/pagemap.h	2007-05-10 10:22:06.000000000 +1000
@@ -133,7 +133,8 @@
 
 extern void FASTCALL(__lock_page(struct page *page));
 extern void FASTCALL(__lock_page_nosync(struct page *page));
-extern void FASTCALL(unlock_page(struct page *page));
+extern void FASTCALL(__wait_on_page_locked(struct page *page));
+extern void FASTCALL(__unlock_page(struct page *page));
 
 static inline int trylock_page(struct page *page)
 {
@@ -160,7 +161,15 @@
 	if (!trylock_page(page))
 		__lock_page_nosync(page);
 }
-	
+
+static inline void unlock_page(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page));
+	clear_bit_unlock(PG_locked, &page->flags);
+	if (unlikely(PageWaiters(page)))
+		__unlock_page(page);
+}
+
 /*
  * This is exported only for wait_on_page_locked/wait_on_page_writeback.
  * Never use this directly!
@@ -176,8 +185,9 @@
  */
 static inline void wait_on_page_locked(struct page *page)
 {
+	might_sleep();
 	if (PageLocked(page))
-		wait_on_page_bit(page, PG_locked);
+		__wait_on_page_locked(page);
 }
 
 /* 
@@ -185,6 +195,7 @@
  */
 static inline void wait_on_page_writeback(struct page *page)
 {
+	might_sleep();
 	if (PageWriteback(page))
 		wait_on_page_bit(page, PG_writeback);
 }
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2007-05-10 10:22:05.000000000 +1000
+++ linux-2.6/mm/filemap.c	2007-05-10 11:03:10.000000000 +1000
@@ -165,10 +165,12 @@
 	mapping = page_mapping(page);
 	if (mapping && mapping->a_ops && mapping->a_ops->sync_page)
 		mapping->a_ops->sync_page(page);
-	io_schedule();
+	if (io_schedule_timeout(20*HZ) == 0)
+		printk("page->flags = %lx\n", page->flags);
 	return 0;
 }
 
+
 /**
  * __filemap_fdatawrite_range - start writeback on mapping dirty pages in range
  * @mapping:	address space structure to write
@@ -478,12 +480,6 @@
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
@@ -516,26 +512,23 @@
 }
 EXPORT_SYMBOL(wait_on_page_bit);
 
-/**
- * unlock_page - unlock a locked page
- * @page: the page
- *
- * Unlocks the page and wakes up sleepers in ___wait_on_page_locked().
- * Also wakes sleepers in wait_on_page_writeback() because the wakeup
- * mechananism between PageLocked pages and PageWriteback pages is shared.
- * But that's OK - sleepers in wait_on_page_writeback() just go back to sleep.
- *
- * The mb is necessary to enforce ordering between the clear_bit and the read
- * of the waitqueue (to avoid SMP races with a parallel wait_on_page_locked()).
+/*
+ * If PageWaiters was found to be set at unlock-time, __unlock_page should
+ * be called to actually perform the wakeups of waiters.
  */
-void fastcall unlock_page(struct page *page)
+void fastcall __unlock_page(struct page *page)
 {
-	VM_BUG_ON(!PageLocked(page));
-	clear_bit_unlock(PG_locked, &page->flags);
+	ClearPageWaiters(page);
+ 	/*
+	 * The mb is necessary to enforce ordering between the clear_bit and
+	 * the read of the waitqueue (to avoid SMP races with a parallel
+	 * wait_on_page_locked()
+	 */
 	smp_mb__after_clear_bit();
+
 	wake_up_page(page, PG_locked);
 }
-EXPORT_SYMBOL(unlock_page);
+EXPORT_SYMBOL(__unlock_page);
 
 /**
  * end_page_writeback - end writeback against a page
@@ -563,10 +556,16 @@
  */
 void fastcall __lock_page(struct page *page)
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
 
@@ -576,10 +575,41 @@
  */
 void fastcall __lock_page_nosync(struct page *page)
 {
+	wait_queue_head_t *wq = page_waitqueue(page);
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
-	__wait_on_bit_lock(page_waitqueue(page), &wait, __sleep_on_page_lock,
-							TASK_UNINTERRUPTIBLE);
+
+	do {
+		prepare_to_wait(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
+		SetPageWaiters(page);
+		if (likely(PageLocked(page))) {
+			if (io_schedule_timeout(20*HZ) == 0)
+				printk("page->flags = %lx\n", page->flags);
+		}
+	} while (!trylock_page(page));
+	finish_wait(wq, &wait.wait);
+}
+
+void fastcall __wait_on_page_locked(struct page *page)
+{
+	wait_queue_head_t *wq = page_waitqueue(page);
+	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+
+	do {
+		prepare_to_wait(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
+		SetPageWaiters(page);
+		if (likely(PageLocked(page)))
+			sync_page(page);
+	} while (PageLocked(page));
+	finish_wait(wq, &wait.wait);
+
+	/*
+	 * Could skip this, but that would leave PG_waiters dangling
+	 * for random pages. This keeps it tidy.
+	 */
+	if (unlikely(PageWaiters(page)))
+		__unlock_page(page);
 }
+EXPORT_SYMBOL(__wait_on_page_locked);
 
 /**
  * find_get_page - find and get a page reference
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-05-10 10:21:32.000000000 +1000
+++ linux-2.6/mm/page_alloc.c	2007-05-10 10:22:06.000000000 +1000
@@ -203,7 +203,8 @@
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
-			1 << PG_buddy );
+			1 << PG_buddy |
+			1 << PG_waiters );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
@@ -438,7 +439,8 @@
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy |
+			1 << PG_waiters ))))
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
@@ -588,7 +590,8 @@
 			1 << PG_swapcache |
 			1 << PG_writeback |
 			1 << PG_reserved |
-			1 << PG_buddy ))))
+			1 << PG_buddy |
+			1 << PG_waiters ))))
 		bad_page(page);
 
 	/*
Index: linux-2.6/kernel/wait.c
===================================================================
--- linux-2.6.orig/kernel/wait.c	2007-05-10 11:06:43.000000000 +1000
+++ linux-2.6/kernel/wait.c	2007-05-10 11:17:25.000000000 +1000
@@ -144,8 +144,7 @@
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

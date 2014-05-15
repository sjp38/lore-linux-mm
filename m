Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7146B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 06:48:16 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so514964eek.40
        for <linux-mm@kvack.org>; Thu, 15 May 2014 03:48:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r44si3846940eeo.274.2014.05.15.03.48.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 03:48:14 -0700 (PDT)
Date: Thu, 15 May 2014 11:48:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue lookups
 in unlock_page fastpath v4
Message-ID: <20140515104808.GF23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140514192945.GA10830@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

Changelog since v3
o Correct handling of exclusive waits

This patch introduces a new page flag for 64-bit capable machines,
PG_waiters, to signal there are processes waiting on PG_lock and uses it to
avoid memory barriers and waitqueue hash lookup in the unlock_page fastpath.

This adds a few branches to the fast path but avoids bouncing a dirty
cache line between CPUs. 32-bit machines always take the slow path but the
primary motivation for this patch is large machines so I do not think that
is a concern.

The test case used to evaulate this is a simple dd of a large file done
multiple times with the file deleted on each iterations. The size of
the file is 1/10th physical memory to avoid dirty page balancing. In the
async case it will be possible that the workload completes without even
hitting the disk and will have variable results but highlight the impact
of mark_page_accessed for async IO. The sync results are expected to be
more stable. The exception is tmpfs where the normal case is for the "IO"
to not hit the disk.

The test machine was single socket and UMA to avoid any scheduling or
NUMA artifacts. Throughput and wall times are presented for sync IO, only
wall times are shown for async as the granularity reported by dd and the
variability is unsuitable for comparison. As async results were variable
do to writback timings, I'm only reporting the maximum figures. The sync
results were stable enough to make the mean and stddev uninteresting.

The performance results are reported based on a run with no profiling.
Profile data is based on a separate run with oprofile running. The
kernels being compared are "accessed-v2" which is the patch series up
to this patch where as lockpage-v2 includes this patch.

async dd
                                   3.15.0-rc3            3.15.0-rc3
                                  accessed-v3           lockpage-v3
ext3   Max      elapsed     11.5900 (  0.00%)     11.0000 (  5.09%)
ext4   Max      elapsed     13.3400 (  0.00%)     13.4300 ( -0.67%)
tmpfs  Max      elapsed      0.4900 (  0.00%)      0.4800 (  2.04%)
btrfs  Max      elapsed     12.7800 (  0.00%)     13.8200 ( -8.14%)
xfs    Max      elapsed      2.0900 (  0.00%)      2.1100 ( -0.96%)

The xfs gain is the hardest to explain, it consistent manages to miss the
worst cases. In the other cases, the results are variable due to the async
nature of the test but the min and max figures are consistently better.

     samples percentage
ext3   90049     1.0238  vmlinux-3.15.0-rc4-accessed-v3 __wake_up_bit
ext3   61716     0.7017  vmlinux-3.15.0-rc4-accessed-v3 page_waitqueue
ext3   47529     0.5404  vmlinux-3.15.0-rc4-accessed-v3 unlock_page
ext3   23833     0.2710  vmlinux-3.15.0-rc4-accessed-v3 mark_page_accessed
ext3    9543     0.1085  vmlinux-3.15.0-rc4-accessed-v3 wake_up_bit
ext3    5036     0.0573  vmlinux-3.15.0-rc4-accessed-v3 init_page_accessed
ext3     369     0.0042  vmlinux-3.15.0-rc4-accessed-v3 __lock_page
ext3       1    1.1e-05  vmlinux-3.15.0-rc4-accessed-v3 lock_page
ext3   37376     0.4233  vmlinux-3.15.0-rc4-waitqueue-v3 unlock_page
ext3   11856     0.1343  vmlinux-3.15.0-rc4-waitqueue-v3 __wake_up_bit
ext3   11096     0.1257  vmlinux-3.15.0-rc4-waitqueue-v3 wake_up_bit
ext3     107     0.0012  vmlinux-3.15.0-rc4-waitqueue-v3 page_waitqueue
ext3      34    3.9e-04  vmlinux-3.15.0-rc4-waitqueue-v3 __lock_page
ext3       4    4.5e-05  vmlinux-3.15.0-rc4-waitqueue-v3 lock_page

There is a similar story told for each of the filesystems -- much less
time spend in page_waitqueue and __wake_up_bit due to the fact that they
now rarely need to be called. Note that for workloads that contend heavily
on the page lock that unlock_page will *increase* in cost as it has to
clear PG_waiters so while the typical case should be much faster, the worst
case costs are now higher.

The Intel vm-scalability tests tell a similar story. The ones measured here
are broadly based on dd of files 10 times the size of memory with one dd per
CPU in the system

                                              3.15.0-rc3            3.15.0-rc3
                                             accessed-v3           lockpage-v3
ext3  lru-file-readonce    elapsed      3.6300 (  0.00%)      3.6300 (  0.00%)
ext3 lru-file-readtwice    elapsed      6.0800 (  0.00%)      6.0700 (  0.16%)
ext4  lru-file-readonce    elapsed      3.7300 (  0.00%)      3.5400 (  5.09%)
ext4 lru-file-readtwice    elapsed      6.2400 (  0.00%)      6.0100 (  3.69%)
btrfs lru-file-readonce    elapsed      5.0100 (  0.00%)      4.9300 (  1.60%)
btrfslru-file-readtwice    elapsed      7.5800 (  0.00%)      7.6300 ( -0.66%)
xfs   lru-file-readonce    elapsed      3.7000 (  0.00%)      3.6400 (  1.62%)
xfs  lru-file-readtwice    elapsed      6.2400 (  0.00%)      5.8600 (  6.09%)

In most cases the time to read the file is slightly lowered. Unlike the
previous test there is no impact on mark_page_accessed as the pages are
already resident for this test and there is no opportunity to mark the
pages accessed without using atomic operations. Instead the profiles show
a reduction in the time spent in page_waitqueue.

This is similarly reflected in the time taken to mmap a range of pages.
These are the results for xfs only but the other filesystems tell a
similar story.

                       3.15.0-rc3            3.15.0-rc3
                      accessed-v2           lockpage-v2
Procs 107M     567.0000 (  0.00%)    542.0000 (  4.41%)
Procs 214M    1075.0000 (  0.00%)   1041.0000 (  3.16%)
Procs 322M    1918.0000 (  0.00%)   1522.0000 ( 20.65%)
Procs 429M    2063.0000 (  0.00%)   1950.0000 (  5.48%)
Procs 536M    2566.0000 (  0.00%)   2506.0000 (  2.34%)
Procs 644M    2920.0000 (  0.00%)   2804.0000 (  3.97%)
Procs 751M    3366.0000 (  0.00%)   3260.0000 (  3.15%)
Procs 859M    3800.0000 (  0.00%)   3672.0000 (  3.37%)
Procs 966M    4291.0000 (  0.00%)   4236.0000 (  1.28%)
Procs 1073M   4923.0000 (  0.00%)   4815.0000 (  2.19%)
Procs 1181M   5223.0000 (  0.00%)   5075.0000 (  2.83%)
Procs 1288M   5576.0000 (  0.00%)   5419.0000 (  2.82%)
Procs 1395M   5855.0000 (  0.00%)   5636.0000 (  3.74%)
Procs 1503M   6049.0000 (  0.00%)   5862.0000 (  3.09%)
Procs 1610M   6454.0000 (  0.00%)   6137.0000 (  4.91%)
Procs 1717M   6806.0000 (  0.00%)   6474.0000 (  4.88%)
Procs 1825M   7377.0000 (  0.00%)   6979.0000 (  5.40%)
Procs 1932M   7633.0000 (  0.00%)   7396.0000 (  3.10%)
Procs 2040M   8137.0000 (  0.00%)   7769.0000 (  4.52%)
Procs 2147M   8617.0000 (  0.00%)   8205.0000 (  4.78%)

         samples percentage
xfs        67544     1.1655  vmlinux-3.15.0-rc4-accessed-v3 unlock_page
xfs        49888     0.8609  vmlinux-3.15.0-rc4-accessed-v3 __wake_up_bit
xfs         1747     0.0301  vmlinux-3.15.0-rc4-accessed-v3 block_page_mkwrite
xfs         1578     0.0272  vmlinux-3.15.0-rc4-accessed-v3 wake_up_bit
xfs            2    3.5e-05  vmlinux-3.15.0-rc4-accessed-v3 lock_page
xfs        83010     1.3447  vmlinux-3.15.0-rc4-waitqueue-v3 unlock_page
xfs         2354     0.0381  vmlinux-3.15.0-rc4-waitqueue-v3 __wake_up_bit
xfs         2064     0.0334  vmlinux-3.15.0-rc4-waitqueue-v3 wake_up_bit
xfs           26    4.2e-04  vmlinux-3.15.0-rc4-waitqueue-v3 page_waitqueue
xfs            3    4.9e-05  vmlinux-3.15.0-rc4-waitqueue-v3 lock_page
xfs            2    3.2e-05  vmlinux-3.15.0-rc4-waitqueue-v3 __lock_page

[jack@suse.cz: Fix add_page_wait_queue]
[mhocko@suse.cz: Use sleep_on_page_killable in __wait_on_page_locked_killable]
[steiner@sgi.com: Do not update struct page unnecessarily]
Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/page-flags.h |  18 +++++
 include/linux/pagemap.h    |   6 +-
 mm/filemap.c               | 172 ++++++++++++++++++++++++++++++++++++++++-----
 mm/page_alloc.c            |   1 +
 mm/swap.c                  |  10 +++
 mm/vmscan.c                |   3 +
 6 files changed, 190 insertions(+), 20 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 7baf0fe..b697e4f 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -87,6 +87,7 @@ enum pageflags {
 	PG_private_2,		/* If pagecache, has fs aux data */
 	PG_writeback,		/* Page is under writeback */
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
+	PG_waiters,		/* Page has PG_locked waiters. */
 	PG_head,		/* A head page */
 	PG_tail,		/* A tail page */
 #else
@@ -213,6 +214,22 @@ PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
 __PAGEFLAG(SlobFree, slob_free)
 
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+PAGEFLAG(Waiters, waiters) __CLEARPAGEFLAG(Waiters, waiters)
+	TESTCLEARFLAG(Waiters, waiters)
+#define __PG_WAITERS		(1 << PG_waiters)
+#else
+/* Always fallback to slow path on 32-bit */
+static inline bool PageWaiters(struct page *page)
+{
+	return true;
+}
+static inline void __ClearPageWaiters(struct page *page) {}
+static inline void ClearPageWaiters(struct page *page) {}
+static inline void SetPageWaiters(struct page *page) {}
+#define __PG_WAITERS		0
+#endif /* CONFIG_PAGEFLAGS_EXTENDED */
+
 /*
  * Private page markings that may be used by the filesystem that owns the page
  * for its own purposes.
@@ -509,6 +526,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
 	 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
 	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
+	 __PG_WAITERS | \
 	 __PG_COMPOUND_LOCK)
 
 /*
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index c74f8bb..2124a83 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -513,13 +513,15 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
  * Never use this directly!
  */
 extern void wait_on_page_bit(struct page *page, int bit_nr);
+extern void __wait_on_page_locked(struct page *page);
 
 extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
+extern int __wait_on_page_locked_killable(struct page *page);
 
 static inline int wait_on_page_locked_killable(struct page *page)
 {
 	if (PageLocked(page))
-		return wait_on_page_bit_killable(page, PG_locked);
+		return __wait_on_page_locked_killable(page);
 	return 0;
 }
 
@@ -533,7 +535,7 @@ static inline int wait_on_page_locked_killable(struct page *page)
 static inline void wait_on_page_locked(struct page *page)
 {
 	if (PageLocked(page))
-		wait_on_page_bit(page, PG_locked);
+		__wait_on_page_locked(page);
 }
 
 /* 
diff --git a/mm/filemap.c b/mm/filemap.c
index bec4b9b..5034ca7 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -241,15 +241,22 @@ void delete_from_page_cache(struct page *page)
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
-static int sleep_on_page(void *word)
+static int sleep_on_page(struct page *page)
 {
-	io_schedule();
+	/*
+	 * A racing unlock can miss that the waitqueue is active and clear the
+	 * waiters again. Only sleep if PageWaiters is still set and timeout
+	 * to recheck as races can still occur.
+	 */
+	if (PageWaiters(page))
+		io_schedule_timeout(HZ);
+
 	return 0;
 }
 
-static int sleep_on_page_killable(void *word)
+static int sleep_on_page_killable(struct page *page)
 {
-	sleep_on_page(word);
+	sleep_on_page(page);
 	return fatal_signal_pending(current) ? -EINTR : 0;
 }
 
@@ -682,30 +689,87 @@ static wait_queue_head_t *page_waitqueue(struct page *page)
 	return &zone->wait_table[hash_ptr(page, zone->wait_table_bits)];
 }
 
-static inline void wake_up_page(struct page *page, int bit)
+static inline wait_queue_head_t *clear_page_waiters(struct page *page)
 {
-	__wake_up_bit(page_waitqueue(page), &page->flags, bit);
+	wait_queue_head_t *wqh = NULL;
+
+	if (!PageWaiters(page))
+		return NULL;
+
+	/*
+	 * Prepare to clear PG_waiters if the waitqueue is no longer
+	 * active. Note that there is no guarantee that a page with no
+	 * waiters will get cleared as there may be unrelated pages
+	 * sleeping on the same page wait queue. Accurate detection
+	 * would require a counter. In the event of a collision, the
+	 * waiter bit will dangle and lookups will be required until
+	 * the page is unlocked without collisions. The bit will need to
+	 * be cleared before freeing to avoid triggering debug checks.
+	 *
+	 * Furthermore, this can race with processes about to sleep on
+	 * the same page if it adds itself to the waitqueue just after
+	 * this check. The timeout in sleep_on_page prevents the race
+	 * being a terminal one. In effect, the uncontended and non-race
+	 * cases are faster in exchange for occasional worst case of the
+	 * timeout saving us.
+	 */
+	wqh = page_waitqueue(page);
+	if (!waitqueue_active(wqh))
+		ClearPageWaiters(page);
+
+	return wqh;
+}
+
+/* Returns true if the page is locked */
+static inline bool prepare_wait_bit(struct page *page, wait_queue_head_t *wqh,
+			wait_queue_t *wq, int state, int bit_nr, bool exclusive)
+{
+
+	/* Set PG_waiters so a racing unlock_page will check the waitiqueue */
+	if (!PageWaiters(page))
+		SetPageWaiters(page);
+
+	if (exclusive)
+		prepare_to_wait_exclusive(wqh, wq, state);
+	else
+		prepare_to_wait(wqh, wq, state);
+	return test_bit(bit_nr, &page->flags);
 }
 
 void wait_on_page_bit(struct page *page, int bit_nr)
 {
+	wait_queue_head_t *wqh;
 	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
 
-	if (test_bit(bit_nr, &page->flags))
-		__wait_on_bit(page_waitqueue(page), &wait, sleep_on_page,
-							TASK_UNINTERRUPTIBLE);
+	if (!test_bit(bit_nr, &page->flags))
+		return;
+	wqh = page_waitqueue(page);
+
+	do {
+		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_KILLABLE, bit_nr, false))
+			sleep_on_page_killable(page);
+	} while (test_bit(bit_nr, &page->flags));
+	finish_wait(wqh, &wait.wait);
 }
 EXPORT_SYMBOL(wait_on_page_bit);
 
 int wait_on_page_bit_killable(struct page *page, int bit_nr)
 {
+	wait_queue_head_t *wqh;
 	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
+	int ret = 0;
 
 	if (!test_bit(bit_nr, &page->flags))
 		return 0;
+	wqh = page_waitqueue(page);
+
+	do {
+		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_KILLABLE, bit_nr, false))
+			ret = sleep_on_page_killable(page);
+	} while (!ret && test_bit(bit_nr, &page->flags));
+	finish_wait(wqh, &wait.wait);
 
-	return __wait_on_bit(page_waitqueue(page), &wait,
-			     sleep_on_page_killable, TASK_KILLABLE);
+	return ret;
 }
 
 /**
@@ -721,6 +785,8 @@ void add_page_wait_queue(struct page *page, wait_queue_t *waiter)
 	unsigned long flags;
 
 	spin_lock_irqsave(&q->lock, flags);
+	if (!PageWaiters(page))
+		SetPageWaiters(page);
 	__add_wait_queue(q, waiter);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
@@ -740,10 +806,29 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
  */
 void unlock_page(struct page *page)
 {
+	wait_queue_head_t *wqh = clear_page_waiters(page);
+
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
-	clear_bit_unlock(PG_locked, &page->flags);
+
+	/*
+	 * clear_bit_unlock is not necessary in this case as there is no
+	 * need to strongly order the clearing of PG_waiters and PG_locked.
+	 * The smp_mb__after_atomic() barrier is still required for RELEASE
+	 * semantics as there is no guarantee that a wakeup will take place
+	 */
+	clear_bit(PG_locked, &page->flags);
 	smp_mb__after_atomic();
-	wake_up_page(page, PG_locked);
+
+	/*
+	 * Wake the queue if waiters were detected. Ordinarily this wakeup
+	 * would be unconditional to catch races between the lock bit being
+	 * set and a new process joining the queue. However, that would
+	 * require the waitqueue to be looked up every time. Instead we
+	 * optimse for the uncontended and non-race case and recover using
+	 * a timeout in sleep_on_page.
+	 */
+	if (wqh)
+		__wake_up_bit(wqh, &page->flags, PG_locked);
 }
 EXPORT_SYMBOL(unlock_page);
 
@@ -753,14 +838,18 @@ EXPORT_SYMBOL(unlock_page);
  */
 void end_page_writeback(struct page *page)
 {
+	wait_queue_head_t *wqh;
 	if (TestClearPageReclaim(page))
 		rotate_reclaimable_page(page);
 
 	if (!test_clear_page_writeback(page))
 		BUG();
 
+	wqh = clear_page_waiters(page);
 	smp_mb__after_atomic();
-	wake_up_page(page, PG_writeback);
+
+	if (wqh)
+		__wake_up_bit(wqh, &page->flags, PG_writeback);
 }
 EXPORT_SYMBOL(end_page_writeback);
 
@@ -795,22 +884,69 @@ EXPORT_SYMBOL_GPL(page_endio);
  */
 void __lock_page(struct page *page)
 {
+	wait_queue_head_t *wqh = page_waitqueue(page);
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
-	__wait_on_bit_lock(page_waitqueue(page), &wait, sleep_on_page,
-							TASK_UNINTERRUPTIBLE);
+	do {
+		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_UNINTERRUPTIBLE, PG_locked, true))
+			sleep_on_page(page);
+	} while (!trylock_page(page));
+
+	finish_wait(wqh, &wait.wait);
 }
 EXPORT_SYMBOL(__lock_page);
 
 int __lock_page_killable(struct page *page)
 {
+	wait_queue_head_t *wqh = page_waitqueue(page);
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+	int ret = 0;
+
+	do {
+		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_KILLABLE, PG_locked, true))
+			ret = sleep_on_page_killable(page);
+	} while (!ret && !trylock_page(page));
 
-	return __wait_on_bit_lock(page_waitqueue(page), &wait,
-					sleep_on_page_killable, TASK_KILLABLE);
+	if (!ret)
+		finish_wait(wqh, &wait.wait);
+	else
+		abort_exclusive_wait(wqh, &wait.wait, TASK_KILLABLE, &wait.key);
+
+	return ret;
 }
 EXPORT_SYMBOL_GPL(__lock_page_killable);
 
+int  __wait_on_page_locked_killable(struct page *page)
+{
+	int ret = 0;
+	wait_queue_head_t *wqh = page_waitqueue(page);
+	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+
+	do {
+		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_KILLABLE, PG_locked, false))
+			ret = sleep_on_page_killable(page);
+	} while (!ret && PageLocked(page));
+
+	finish_wait(wqh, &wait.wait);
+
+	return ret;
+}
+EXPORT_SYMBOL(__wait_on_page_locked_killable);
+
+void  __wait_on_page_locked(struct page *page)
+{
+	wait_queue_head_t *wqh = page_waitqueue(page);
+	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+
+	do {
+		if (prepare_wait_bit(page, wqh, &wait.wait, TASK_UNINTERRUPTIBLE, PG_locked, false))
+			sleep_on_page(page);
+	} while (PageLocked(page));
+
+	finish_wait(wqh, &wait.wait);
+}
+EXPORT_SYMBOL(__wait_on_page_locked);
+
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 			 unsigned int flags)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 606eecf..0959b09 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6604,6 +6604,7 @@ static const struct trace_print_flags pageflag_names[] = {
 	{1UL << PG_private_2,		"private_2"	},
 	{1UL << PG_writeback,		"writeback"	},
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
+	{1UL << PG_waiters,		"waiters"	},
 	{1UL << PG_head,		"head"		},
 	{1UL << PG_tail,		"tail"		},
 #else
diff --git a/mm/swap.c b/mm/swap.c
index 9e8e347..bf9bd4c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -67,6 +67,10 @@ static void __page_cache_release(struct page *page)
 static void __put_single_page(struct page *page)
 {
 	__page_cache_release(page);
+
+	/* Clear dangling waiters from collisions on page_waitqueue */
+	__ClearPageWaiters(page);
+
 	free_hot_cold_page(page, false);
 }
 
@@ -916,6 +920,12 @@ void release_pages(struct page **pages, int nr, bool cold)
 		/* Clear Active bit in case of parallel mark_page_accessed */
 		__ClearPageActive(page);
 
+		/*
+		 * Clear waiters bit that may still be set due to a collision
+		 * on page_waitqueue
+		 */
+		__ClearPageWaiters(page);
+
 		list_add(&page->lru, &pages_to_free);
 	}
 	if (zone)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7f85041..e409cbc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1096,6 +1096,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * waiting on the page lock, because there are no references.
 		 */
 		__clear_page_locked(page);
+		__ClearPageWaiters(page);
 free_it:
 		nr_reclaimed++;
 
@@ -1427,6 +1428,7 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
+			__ClearPageWaiters(page);
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
@@ -1650,6 +1652,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
+			__ClearPageWaiters(page);
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

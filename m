Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 52B056B0035
	for <linux-mm@kvack.org>; Wed, 21 May 2014 08:15:08 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d49so1481808eek.15
        for <linux-mm@kvack.org>; Wed, 21 May 2014 05:15:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t44si8363479eel.0.2014.05.21.05.15.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 05:15:06 -0700 (PDT)
Date: Wed, 21 May 2014 13:15:01 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue lookups
 in unlock_page fastpath v5
Message-ID: <20140521121501.GT23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

Andrew had suggested dropping v4 of the patch entirely as the numbers were
marginal and the complexity was high. However, even on a relatively small
machine running simple workloads the overhead of page_waitqueue and wakeup
functions is around 5% of system CPU time. That's quite high for basic
operations so I felt it was worth another shot. The performance figures
are better with this version than they were for v4 and overall the patch
should be more comprehensible.

Changelog since v4
o Remove dependency on io_schedule_timeout
o Push waiting logic down into waitqueue

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
                                 3.15.0-rc5            3.15.0-rc5
                                      mmotm           lockpage-v5
btrfs Max      ddtime      0.5863 (  0.00%)      0.5621 (  4.14%)
ext3  Max      ddtime      1.4870 (  0.00%)      1.4609 (  1.76%)
ext4  Max      ddtime      1.0440 (  0.00%)      1.0376 (  0.61%)
tmpfs Max      ddtime      0.3541 (  0.00%)      0.3486 (  1.54%)
xfs   Max      ddtime      0.4995 (  0.00%)      0.4834 (  3.21%)

A separate run with profiles showed this

     samples percentage
ext3  225851    2.3180  vmlinux-3.15.0-rc5-mmotm       test_clear_page_writeback
ext3  106848    1.0966  vmlinux-3.15.0-rc5-mmotm       __wake_up_bit
ext3   71849    0.7374  vmlinux-3.15.0-rc5-mmotm       page_waitqueue
ext3   40319    0.4138  vmlinux-3.15.0-rc5-mmotm       unlock_page
ext3   26243    0.2693  vmlinux-3.15.0-rc5-mmotm       end_page_writeback
ext3  178777    1.7774  vmlinux-3.15.0-rc5-lockpage-v5 test_clear_page_writeback
ext3   67702    0.6731  vmlinux-3.15.0-rc5-lockpage-v5 unlock_page
ext3   22357    0.2223  vmlinux-3.15.0-rc5-lockpage-v5 end_page_writeback
ext3   11131    0.1107  vmlinux-3.15.0-rc5-lockpage-v5 __wake_up_bit
ext3    6360    0.0632  vmlinux-3.15.0-rc5-lockpage-v5 __wake_up_page_bit
ext3    1660    0.0165  vmlinux-3.15.0-rc5-lockpage-v5 page_waitqueue

The profiles show a clear reduction in waitqueue and wakeup functions. The
cost of unlock_page is higher as it's checking PageWaiters but it is offset
by reduced numbers of calls to page_waitqueue and _wake_up_bit. There is a
similar story told for each of the filesystems.  Note that for workloads
that contend heavily on the page lock that unlock_page may increase in
cost as it has to clear PG_waiters so while the typical case should be
much faster, the worst case costs are now higher.

This is also reflected in the time taken to mmap a range of pages.
These are the results for xfs only but the other filesystems tell a
similar story.

                       3.15.0-rc5            3.15.0-rc5
                            mmotm           lockpage-v5
Procs 107M     423.0000 (  0.00%)    409.0000 (  3.31%)
Procs 214M     847.0000 (  0.00%)    823.0000 (  2.83%)
Procs 322M    1296.0000 (  0.00%)   1232.0000 (  4.94%)
Procs 429M    1692.0000 (  0.00%)   1644.0000 (  2.84%)
Procs 536M    2137.0000 (  0.00%)   2057.0000 (  3.74%)
Procs 644M    2542.0000 (  0.00%)   2472.0000 (  2.75%)
Procs 751M    2953.0000 (  0.00%)   2872.0000 (  2.74%)
Procs 859M    3360.0000 (  0.00%)   3310.0000 (  1.49%)
Procs 966M    3770.0000 (  0.00%)   3724.0000 (  1.22%)
Procs 1073M   4220.0000 (  0.00%)   4114.0000 (  2.51%)
Procs 1181M   4638.0000 (  0.00%)   4546.0000 (  1.98%)
Procs 1288M   5038.0000 (  0.00%)   4940.0000 (  1.95%)
Procs 1395M   5481.0000 (  0.00%)   5431.0000 (  0.91%)
Procs 1503M   5940.0000 (  0.00%)   5832.0000 (  1.82%)
Procs 1610M   6316.0000 (  0.00%)   6204.0000 (  1.77%)
Procs 1717M   6749.0000 (  0.00%)   6799.0000 ( -0.74%)
Procs 1825M   7323.0000 (  0.00%)   7082.0000 (  3.29%)
Procs 1932M   7694.0000 (  0.00%)   7452.0000 (  3.15%)
Procs 2040M   8079.0000 (  0.00%)   7927.0000 (  1.88%)
Procs 2147M   8495.0000 (  0.00%)   8360.0000 (  1.59%)

   samples percentage
xfs  78334    1.3089  vmlinux-3.15.0-rc5-mmotm          page_waitqueue
xfs  55910    0.9342  vmlinux-3.15.0-rc5-mmotm          unlock_page
xfs  45120    0.7539  vmlinux-3.15.0-rc5-mmotm          __wake_up_bit
xfs  41414    0.6920  vmlinux-3.15.0-rc5-mmotm          test_clear_page_writeback
xfs   4823    0.0806  vmlinux-3.15.0-rc5-mmotm          end_page_writeback
xfs 100864    1.7063  vmlinux-3.15.0-rc5-lockpage-v5    unlock_page
xfs  52547    0.8889  vmlinux-3.15.0-rc5-lockpage-v5    test_clear_page_writeback
xfs   5031    0.0851  vmlinux-3.15.0-rc5-lockpage-v5    end_page_writeback
xfs   1938    0.0328  vmlinux-3.15.0-rc5-lockpage-v5    __wake_up_bit
xfs      9   1.5e-04  vmlinux-3.15.0-rc5-lockpage-v5    __wake_up_page_bit
xfs      7   1.2e-04  vmlinux-3.15.0-rc5-lockpage-v5    page_waitqueue

[jack@suse.cz: Fix add_page_wait_queue]
[mhocko@suse.cz: Use sleep_on_page_killable in __wait_on_page_locked_killable]
[steiner@sgi.com: Do not update struct page unnecessarily]
Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/page-flags.h | 18 +++++++++
 include/linux/wait.h       |  6 +++
 kernel/sched/wait.c        | 94 +++++++++++++++++++++++++++++++++++++++-------
 mm/filemap.c               | 25 ++++++------
 mm/page_alloc.c            |  1 +
 mm/swap.c                  | 10 +++++
 mm/vmscan.c                |  3 ++
 7 files changed, 132 insertions(+), 25 deletions(-)

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
diff --git a/include/linux/wait.h b/include/linux/wait.h
index bd68819..5dda464 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -147,8 +147,13 @@ void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr, void *k
 void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
 void __wake_up_bit(wait_queue_head_t *, void *, int);
+void __wake_up_page_bit(wait_queue_head_t *, struct page *page, void *, int);
 int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*)(void *), unsigned);
+int __wait_on_page_bit(wait_queue_head_t *, struct wait_bit_queue *,
+				struct page *page, int (*)(void *), unsigned);
 int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, int (*)(void *), unsigned);
+int __wait_on_page_bit_lock(wait_queue_head_t *, struct wait_bit_queue *,
+				struct page *page, int (*)(void *), unsigned);
 void wake_up_bit(void *, int);
 void wake_up_atomic_t(atomic_t *);
 int out_of_line_wait_on_bit(void *, int, int (*)(void *), unsigned);
@@ -822,6 +827,7 @@ void prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait, int state);
 void prepare_to_wait_exclusive(wait_queue_head_t *q, wait_queue_t *wait, int state);
 long prepare_to_wait_event(wait_queue_head_t *q, wait_queue_t *wait, int state);
 void finish_wait(wait_queue_head_t *q, wait_queue_t *wait);
+void finish_wait_page(wait_queue_head_t *q, wait_queue_t *wait, struct page *page);
 void abort_exclusive_wait(wait_queue_head_t *q, wait_queue_t *wait, unsigned int mode, void *key);
 int autoremove_wake_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
 int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 0ffa20a..f829e73 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -167,31 +167,39 @@ EXPORT_SYMBOL_GPL(__wake_up_sync);	/* For internal use only */
  * stops them from bleeding out - it would still allow subsequent
  * loads to move into the critical region).
  */
-void
-prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait, int state)
+static inline void
+__prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait,
+			struct page *page, int state, bool exclusive)
 {
 	unsigned long flags;
 
-	wait->flags &= ~WQ_FLAG_EXCLUSIVE;
 	spin_lock_irqsave(&q->lock, flags);
-	if (list_empty(&wait->task_list))
-		__add_wait_queue(q, wait);
+	if (page && !PageWaiters(page))
+		SetPageWaiters(page);
+	if (list_empty(&wait->task_list)) {
+		if (exclusive) {
+			wait->flags |= WQ_FLAG_EXCLUSIVE;
+			__add_wait_queue_tail(q, wait);
+		} else {
+			wait->flags &= ~WQ_FLAG_EXCLUSIVE;
+			__add_wait_queue(q, wait);
+		}
+	}
 	set_current_state(state);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
+
+void
+prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait, int state)
+{
+	return __prepare_to_wait(q, wait, NULL, state, false);
+}
 EXPORT_SYMBOL(prepare_to_wait);
 
 void
 prepare_to_wait_exclusive(wait_queue_head_t *q, wait_queue_t *wait, int state)
 {
-	unsigned long flags;
-
-	wait->flags |= WQ_FLAG_EXCLUSIVE;
-	spin_lock_irqsave(&q->lock, flags);
-	if (list_empty(&wait->task_list))
-		__add_wait_queue_tail(q, wait);
-	set_current_state(state);
-	spin_unlock_irqrestore(&q->lock, flags);
+	return __prepare_to_wait(q, wait, NULL, state, true);
 }
 EXPORT_SYMBOL(prepare_to_wait_exclusive);
 
@@ -228,7 +236,8 @@ EXPORT_SYMBOL(prepare_to_wait_event);
  * the wait descriptor from the given waitqueue if still
  * queued.
  */
-void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
+static inline void __finish_wait(wait_queue_head_t *q, wait_queue_t *wait,
+			struct page *page)
 {
 	unsigned long flags;
 
@@ -249,9 +258,16 @@ void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
 	if (!list_empty_careful(&wait->task_list)) {
 		spin_lock_irqsave(&q->lock, flags);
 		list_del_init(&wait->task_list);
+		if (page && !waitqueue_active(q))
+			ClearPageWaiters(page);
 		spin_unlock_irqrestore(&q->lock, flags);
 	}
 }
+
+void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
+{
+	return __finish_wait(q, wait, NULL);
+}
 EXPORT_SYMBOL(finish_wait);
 
 /**
@@ -331,6 +347,22 @@ __wait_on_bit(wait_queue_head_t *wq, struct wait_bit_queue *q,
 	finish_wait(wq, &q->wait);
 	return ret;
 }
+
+int __sched
+__wait_on_page_bit(wait_queue_head_t *wq, struct wait_bit_queue *q,
+			struct page *page,
+			int (*action)(void *), unsigned mode)
+{
+	int ret = 0;
+
+	do {
+		__prepare_to_wait(wq, &q->wait, page, mode, false);
+		if (test_bit(q->key.bit_nr, q->key.flags))
+			ret = (*action)(q->key.flags);
+	} while (test_bit(q->key.bit_nr, q->key.flags) && !ret);
+	__finish_wait(wq, &q->wait, page);
+	return ret;
+}
 EXPORT_SYMBOL(__wait_on_bit);
 
 int __sched out_of_line_wait_on_bit(void *word, int bit,
@@ -344,6 +376,27 @@ int __sched out_of_line_wait_on_bit(void *word, int bit,
 EXPORT_SYMBOL(out_of_line_wait_on_bit);
 
 int __sched
+__wait_on_page_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
+			struct page *page,
+			int (*action)(void *), unsigned mode)
+{
+	do {
+		int ret;
+
+		__prepare_to_wait(wq, &q->wait, page, mode, true);
+		if (!test_bit(q->key.bit_nr, q->key.flags))
+			continue;
+		ret = action(q->key.flags);
+		if (!ret)
+			continue;
+		abort_exclusive_wait(wq, &q->wait, mode, &q->key);
+		return ret;
+	} while (test_and_set_bit(q->key.bit_nr, q->key.flags));
+	__finish_wait(wq, &q->wait, page);
+	return 0;
+}
+
+int __sched
 __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
 			int (*action)(void *), unsigned mode)
 {
@@ -374,6 +427,19 @@ int __sched out_of_line_wait_on_bit_lock(void *word, int bit,
 }
 EXPORT_SYMBOL(out_of_line_wait_on_bit_lock);
 
+void __wake_up_page_bit(wait_queue_head_t *wqh, struct page *page, void *word, int bit)
+{
+	struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(word, bit);
+	unsigned long flags;
+
+	spin_lock_irqsave(&wqh->lock, flags);
+	if (waitqueue_active(wqh))
+		__wake_up_common(wqh, TASK_NORMAL, 1, 0, &key);
+	else
+		ClearPageWaiters(page);
+	spin_unlock_irqrestore(&wqh->lock, flags);
+}
+
 void __wake_up_bit(wait_queue_head_t *wq, void *word, int bit)
 {
 	struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(word, bit);
diff --git a/mm/filemap.c b/mm/filemap.c
index 263cffe..07633a4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -682,9 +682,9 @@ static wait_queue_head_t *page_waitqueue(struct page *page)
 	return &zone->wait_table[hash_ptr(page, zone->wait_table_bits)];
 }
 
-static inline void wake_up_page(struct page *page, int bit)
+static inline void wake_up_page(struct page *page, int bit_nr)
 {
-	__wake_up_bit(page_waitqueue(page), &page->flags, bit);
+	__wake_up_page_bit(page_waitqueue(page), page, &page->flags, bit_nr);
 }
 
 void wait_on_page_bit(struct page *page, int bit_nr)
@@ -692,8 +692,8 @@ void wait_on_page_bit(struct page *page, int bit_nr)
 	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
 
 	if (test_bit(bit_nr, &page->flags))
-		__wait_on_bit(page_waitqueue(page), &wait, sleep_on_page,
-							TASK_UNINTERRUPTIBLE);
+		__wait_on_page_bit(page_waitqueue(page), &wait, page,
+					sleep_on_page, TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(wait_on_page_bit);
 
@@ -704,7 +704,7 @@ int wait_on_page_bit_killable(struct page *page, int bit_nr)
 	if (!test_bit(bit_nr, &page->flags))
 		return 0;
 
-	return __wait_on_bit(page_waitqueue(page), &wait,
+	return __wait_on_page_bit(page_waitqueue(page), &wait, page,
 			     sleep_on_page_killable, TASK_KILLABLE);
 }
 
@@ -743,7 +743,8 @@ void unlock_page(struct page *page)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	clear_bit_unlock(PG_locked, &page->flags);
 	smp_mb__after_atomic();
-	wake_up_page(page, PG_locked);
+	if (unlikely(PageWaiters(page)))
+		wake_up_page(page, PG_locked);
 }
 EXPORT_SYMBOL(unlock_page);
 
@@ -769,7 +770,8 @@ void end_page_writeback(struct page *page)
 		BUG();
 
 	smp_mb__after_atomic();
-	wake_up_page(page, PG_writeback);
+	if (unlikely(PageWaiters(page)))
+		wake_up_page(page, PG_writeback);
 }
 EXPORT_SYMBOL(end_page_writeback);
 
@@ -806,8 +808,8 @@ void __lock_page(struct page *page)
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
-	__wait_on_bit_lock(page_waitqueue(page), &wait, sleep_on_page,
-							TASK_UNINTERRUPTIBLE);
+	__wait_on_page_bit_lock(page_waitqueue(page), &wait, page,
+					sleep_on_page, TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(__lock_page);
 
@@ -815,9 +817,10 @@ int __lock_page_killable(struct page *page)
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
-	return __wait_on_bit_lock(page_waitqueue(page), &wait,
-					sleep_on_page_killable, TASK_KILLABLE);
+	return __wait_on_page_bit_lock(page_waitqueue(page), &wait, page,
+					sleep_on_page, TASK_KILLABLE);
 }
+
 EXPORT_SYMBOL_GPL(__lock_page_killable);
 
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cd1f005..ebb947d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6603,6 +6603,7 @@ static const struct trace_print_flags pageflag_names[] = {
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

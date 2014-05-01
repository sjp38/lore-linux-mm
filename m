Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 68DDE6B0070
	for <linux-mm@kvack.org>; Thu,  1 May 2014 04:45:09 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e51so2074701eek.30
        for <linux-mm@kvack.org>; Thu, 01 May 2014 01:45:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i49si33513386eem.162.2014.05.01.01.45.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 01:45:08 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/17] mm: filemap: Avoid unnecessary barries and waitqueue lookup in unlock_page fastpath
Date: Thu,  1 May 2014 09:44:48 +0100
Message-Id: <1398933888-4940-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-1-git-send-email-mgorman@suse.de>
References: <1398933888-4940-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>

From: Nick Piggin <npiggin@suse.de>

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
                             accessed-v2           lockpage-v2
ext3   Max elapsed     12.9200 (  0.00%)     12.6700 (  1.93%)
ext4   Max elapsed     13.4000 (  0.00%)     13.3800 (  0.15%)
tmpfs  Max elapsed      0.4900 (  0.00%)      0.4800 (  2.04%)
btrfs  Max elapsed     12.8200 (  0.00%)     12.8200 (  0.00%)
Max      elapsed        2.0000 (  0.00%)      2.1100 ( -5.50%)

By and large it was an improvement. xfs was a shame but FWIW in this
case the stddev for xfs is quite high and this result is well within
the noise. For clarity here are the full set of xfs results

                            3.15.0-rc3            3.15.0-rc3
                        accessed-v2          lockpage-v2
Min      elapsed      0.5700 (  0.00%)      0.5400 (  5.26%)
Mean     elapsed      1.1157 (  0.00%)      1.1460 ( -2.72%)
TrimMean elapsed      1.1386 (  0.00%)      1.1757 ( -3.26%)
Stddev   elapsed      0.3653 (  0.00%)      0.4202 (-15.02%)
Max      elapsed      2.0000 (  0.00%)      2.1100 ( -5.50%)

The mean figures are well within the stddev. Still not a very happy
result but not enough to get upset about either.

     samples percentage
ext3   62312     0.6586  vmlinux-3.15.0-rc3-accessed-v2r33 page_waitqueue
ext3   46530     0.4918  vmlinux-3.15.0-rc3-accessed-v2r33 unlock_page
ext3    6447     0.0915  vmlinux-3.15.0-rc3-lockpage-v2r33 page_waitqueue
ext3   48619     0.6900  vmlinux-3.15.0-rc3-lockpage-v2r33 unlock_page
ext4  112692    1.5815   vmlinux-3.15.0-rc3-accessed-v2r33 page_waitqueue
ext4   80699     1.1325  vmlinux-3.15.0-rc3-accessed-v2r33 unlock_page
ext4   11461     0.1587  vmlinux-3.15.0-rc3-lockpage-v2r33 page_waitqueue
ext4  127146     1.7605  vmlinux-3.15.0-rc3-lockpage-v2r33 unlock_page
tmpfs  17599     1.4799  vmlinux-3.15.0-rc3-accessed-v2r33 page_waitqueue
tmpfs  13838     1.1636  vmlinux-3.15.0-rc3-accessed-v2r33 unlock_page
tmpfs      4    2.3e-04  vmlinux-3.15.0-rc3-lockpage-v2r33 page_waitqueue
tmpfs  29061     1.6878  vmlinux-3.15.0-rc3-lockpage-v2r33 unlock_page
btrfs  6762      0.0883  vmlinux-3.15.0-rc3-lockpage-v2r33 page_waitqueue
btrfs  72237     0.9428  vmlinux-3.15.0-rc3-lockpage-v2r33 unlock_page
btrfs  63208     0.8140  vmlinux-3.15.0-rc3-accessed-v2r33 page_waitqueue
btrfs  56963     0.7335  vmlinux-3.15.0-rc3-accessed-v2r33 unlock_page
xfs    32350     0.9279  vmlinux-3.15.0-rc3-accessed-v2r33 page_waitqueue
xfs    25115     0.7204  vmlinux-3.15.0-rc3-accessed-v2r33 unlock_page
xfs     1981     0.0718  vmlinux-3.15.0-rc3-lockpage-v2r33 page_waitqueue
xfs    31085     1.1269  vmlinux-3.15.0-rc3-lockpage-v2r33 unlock_page

In all cases note the large reduction in the time spent in page_waitqueue
as the page flag allows the cost to be avoided. In most cases, the time
spend in unlock_page is also decreased.

sync dd

ext3   Max    tput    116.0000 (  0.00%)    115.0000 ( -0.86%)
ext3   Max elapsed     15.3100 (  0.00%)     15.2600 (  0.33%)
ext4   Max    tput    120.0000 (  0.00%)    123.0000 (  2.50%)
ext4   Max elapsed     14.7300 (  0.00%)     14.7300 (  0.00%)
tmpfs  Max    tput   5324.8000 (  0.00%)   5324.8000 (  0.00%)
tmpfs  Max elapsed      0.4900 (  0.00%)      0.4800 (  2.04%)
btrfs  Max    tput    128.0000 (  0.00%)    128.0000 (  0.00%)
btrfs  Max elapsed     13.5000 (  0.00%)     13.6200 ( -0.89%)
xfs    Max    tput    122.0000 (  0.00%)    123.0000 (  0.82%)
xfs    Max elapsed     14.4500 (  0.00%)     14.6500 ( -1.38%)

Not a universal win in terms of headline performance but system CPU usage
is reduced and the profiles do show that less time is spent looking up
waitqueues so how much this benefits will depend on the machine used and
the exact workload.

The Intel vm-scalability tests tell a similar story. The ones measured here
are broadly based on dd of files 10 times the size of memory with one dd per
CPU in the system

                                               3.15.0-rc3            3.15.0-rc3
                                              accessed-v2           lockpage-v2
ext3   lru-file-readonce    elapsed      3.7100 (  0.00%)      3.5500 (  4.31%)
ext3   lru-file-readtwice   elapsed      6.0000 (  0.00%)      6.1300 ( -2.17%)
ext3   lru-file-ddspread    elapsed      8.7800 (  0.00%)      8.4700 (  3.53%)
ext4   lru-file-readonce    elapsed      3.6700 (  0.00%)      3.5700 (  2.72%)
ext4   lru-file-readtwice   elapsed      6.5200 (  0.00%)      6.1600 (  5.52%)
ext4   lru-file-ddspread    elapsed      9.2800 (  0.00%)      9.2400 (  0.43%)
btrfs  lru-file-readonce    elapsed      5.0200 (  0.00%)      4.9700 (  1.00%)
btrfs  lru-file-readtwice   elapsed      7.6100 (  0.00%)      7.5500 (  0.79%)
btrfs  lru-file-ddspread    elapsed     10.7900 (  0.00%)     10.7400 (  0.46%)
xfs    lru-file-readonce    elapsed      3.6700 (  0.00%)      3.6400 (  0.82%)
xfs    lru-file-readtwice   elapsed      5.9300 (  0.00%)      6.0100 ( -1.35%)
xfs    lru-file-ddspread    elapsed      9.0500 (  0.00%)      8.9700 (  0.88%)

In most cases the time to read the file is lowered. Unlike the previous test
there is no impact on mark_page_accessed as the pages are already resident for
this test and there is no opportunity to mark the pages accessed without using
atomic operations. Instead the profiles show a reduction in the time spent in
page_waitqueue. This is the profile data for lru-file-readonce only.

     samples percentage
ext3   13447     0.5236  vmlinux-3.15.0-rc3-accessed-v2r33 page_waitqueue
ext3    9763     0.3801  vmlinux-3.15.0-rc3-accessed-v2r33 unlock_page
ext3       3    1.2e-04  vmlinux-3.15.0-rc3-lockpage-v2r33 page_waitqueue
ext3   13840     0.5550  vmlinux-3.15.0-rc3-lockpage-v2r33 unlock_page
ext4   15976     0.5951  vmlinux-3.15.0-rc3-accessed-v2r33 page_waitqueue
ext4    9920     0.3695  vmlinux-3.15.0-rc3-accessed-v2r33 unlock_page
ext4       5    2.0e-04  vmlinux-3.15.0-rc3-lockpage-v2r33 page_waitqueue
ext4   13963     0.5542  vmlinux-3.15.0-rc3-lockpage-v2r33 unlock_page
btrfs  13447     0.3720  vmlinux-3.15.0-rc3-accessed-v2r33 page_waitqueue
btrfs   8349     0.2310  vmlinux-3.15.0-rc3-accessed-v2r33 unlock_page
btrfs      7    2.0e-04  vmlinux-3.15.0-rc3-lockpage-v2r33 page_waitqueue
btrfs  12583     0.3549  vmlinux-3.15.0-rc3-lockpage-v2r33 unlock_page
xfs    13028     0.5234  vmlinux-3.15.0-rc3-accessed-v2r33 page_waitqueue
xfs     9698     0.3896  vmlinux-3.15.0-rc3-accessed-v2r33 unlock_page
xfs        5    2.0e-04  vmlinux-3.15.0-rc3-lockpage-v2r33 page_waitqueue
xfs    15269     0.6215  vmlinux-3.15.0-rc3-lockpage-v2r33 unlock_page

The time spent in unlock_page is similar as the lock bit still has to
be cleared but the time spent in page_waitqueue is virtually eliminated.

This is similarly reflected in the time taken to mmap a range of pages.
These are the results for xfs only but the other filesystems tell a
similar story.

                       3.15.0-rc3            3.15.0-rc3
                      accessed-v2           lockpage-v2
Procs 107M     533.0000 (  0.00%)    539.0000 ( -1.13%)
Procs 214M    1093.0000 (  0.00%)   1045.0000 (  4.39%)
Procs 322M    1572.0000 (  0.00%)   1334.0000 ( 15.14%)
Procs 429M    2012.0000 (  0.00%)   1998.0000 (  0.70%)
Procs 536M    2517.0000 (  0.00%)   3052.0000 (-21.26%)
Procs 644M    2916.0000 (  0.00%)   2856.0000 (  2.06%)
Procs 751M    3472.0000 (  0.00%)   3284.0000 (  5.41%)
Procs 859M    3810.0000 (  0.00%)   3854.0000 ( -1.15%)
Procs 966M    4411.0000 (  0.00%)   4296.0000 (  2.61%)
Procs 1073M   4923.0000 (  0.00%)   4791.0000 (  2.68%)
Procs 1181M   5237.0000 (  0.00%)   5169.0000 (  1.30%)
Procs 1288M   5587.0000 (  0.00%)   5494.0000 (  1.66%)
Procs 1395M   5771.0000 (  0.00%)   5790.0000 ( -0.33%)
Procs 1503M   6149.0000 (  0.00%)   5950.0000 (  3.24%)
Procs 1610M   6479.0000 (  0.00%)   6239.0000 (  3.70%)
Procs 1717M   6860.0000 (  0.00%)   6702.0000 (  2.30%)
Procs 1825M   7292.0000 (  0.00%)   7108.0000 (  2.52%)
Procs 1932M   7673.0000 (  0.00%)   7541.0000 (  1.72%)
Procs 2040M   8146.0000 (  0.00%)   7919.0000 (  2.79%)
Procs 2147M   8692.0000 (  0.00%)   8355.0000 (  3.88%)

         samples percentage
xfs        90552     1.4634  vmlinux-3.15.0-rc3-accessed-v2r33 page_waitqueue
xfs        71598     1.1571  vmlinux-3.15.0-rc3-accessed-v2r33 unlock_page
xfs         2773     0.0447  vmlinux-3.15.0-rc3-lockpage-v2r33 page_waitqueue
xfs       110399     1.7796  vmlinux-3.15.0-rc3-lockpage-v2r33 unlock_page

[jack@suse.cz: Fix add_page_wait_queue]
[mhocko@suse.cz: Use sleep_on_page_killable in __wait_on_page_locked_killable]
[steiner@sgi.com: Do not update struct page unnecessarily]
Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/page-flags.h | 16 +++++++++
 include/linux/pagemap.h    |  6 ++--
 kernel/sched/wait.c        |  3 +-
 mm/filemap.c               | 90 ++++++++++++++++++++++++++++++++++++++++++----
 mm/page_alloc.c            |  1 +
 5 files changed, 106 insertions(+), 10 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 2093eb7..4c52d42 100644
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
@@ -213,6 +214,20 @@ PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
 __PAGEFLAG(SlobFree, slob_free)
 
+#ifdef CONFIG_PAGEFLAGS_EXTENDED
+PAGEFLAG(Waiters, waiters)
+#define __PG_WAITERS		(1 << PG_waiters)
+#else
+/* Always fallback to slow path on 32-bit */
+static inline bool PageWaiters(struct page *page)
+{
+	return true;
+}
+static inline void ClearPageWaiters(struct page *page) {}
+static inline void SetPageWaiters(struct page *page) {}
+#define __PG_WAITERS		0
+#endif /* CONFIG_PAGEFLAGS_EXTENDED */
+
 /*
  * Private page markings that may be used by the filesystem that owns the page
  * for its own purposes.
@@ -506,6 +521,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
 	 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
 	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
+	 __PG_WAITERS | \
 	 __PG_COMPOUND_LOCK)
 
 /*
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e5ffaa0..2ec2d78 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -485,13 +485,15 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
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
 
@@ -505,7 +507,7 @@ static inline int wait_on_page_locked_killable(struct page *page)
 static inline void wait_on_page_locked(struct page *page)
 {
 	if (PageLocked(page))
-		wait_on_page_bit(page, PG_locked);
+		__wait_on_page_locked(page);
 }
 
 /* 
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 7d50f79..fb83fe0 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -304,8 +304,7 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *arg)
 		= container_of(wait, struct wait_bit_queue, wait);
 
 	if (wait_bit->key.flags != key->flags ||
-			wait_bit->key.bit_nr != key->bit_nr ||
-			test_bit(key->bit_nr, key->flags))
+			wait_bit->key.bit_nr != key->bit_nr)
 		return 0;
 	else
 		return autoremove_wake_function(wait, mode, sync, key);
diff --git a/mm/filemap.c b/mm/filemap.c
index c60ed0f..93e4385 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -720,10 +720,23 @@ void add_page_wait_queue(struct page *page, wait_queue_t *waiter)
 
 	spin_lock_irqsave(&q->lock, flags);
 	__add_wait_queue(q, waiter);
+	if (!PageWaiters(page))
+		SetPageWaiters(page);
 	spin_unlock_irqrestore(&q->lock, flags);
 }
 EXPORT_SYMBOL_GPL(add_page_wait_queue);
 
+/*
+ * If PageWaiters was found to be set at unlock time, __wake_page_waiters
+ * should be called to actually perform the wakeup of waiters.
+ */
+static inline void __wake_page_waiters(struct page *page)
+{
+	ClearPageWaiters(page);
+	smp_mb__after_clear_bit();
+	wake_up_page(page, PG_locked);
+}
+
 /**
  * unlock_page - unlock a locked page
  * @page: the page
@@ -740,8 +753,8 @@ void unlock_page(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	clear_bit_unlock(PG_locked, &page->flags);
-	smp_mb__after_clear_bit();
-	wake_up_page(page, PG_locked);
+	if (unlikely(PageWaiters(page)))
+		__wake_page_waiters(page);
 }
 EXPORT_SYMBOL(unlock_page);
 
@@ -768,22 +781,87 @@ EXPORT_SYMBOL(end_page_writeback);
  */
 void __lock_page(struct page *page)
 {
+	wait_queue_head_t *wq = page_waitqueue(page);
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
 
-	__wait_on_bit_lock(page_waitqueue(page), &wait, sleep_on_page,
-							TASK_UNINTERRUPTIBLE);
+	do {
+		prepare_to_wait(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
+		if (!PageWaiters(page))
+			SetPageWaiters(page);
+		if (likely(PageLocked(page)))
+			sleep_on_page(page);
+	} while (!trylock_page(page));
+	finish_wait(wq, &wait.wait);
 }
 EXPORT_SYMBOL(__lock_page);
 
 int __lock_page_killable(struct page *page)
 {
+	wait_queue_head_t *wq = page_waitqueue(page);
 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+	int err = 0;
+
+	do {
+		prepare_to_wait(wq, &wait.wait, TASK_KILLABLE);
+		if (!PageWaiters(page))
+			SetPageWaiters(page);
+		if (likely(PageLocked(page))) {
+			err = sleep_on_page_killable(page);
+			if (err)
+				break;
+		}
+	} while (!trylock_page(page));
+	finish_wait(wq, &wait.wait);
 
-	return __wait_on_bit_lock(page_waitqueue(page), &wait,
-					sleep_on_page_killable, TASK_KILLABLE);
+	return err;
 }
 EXPORT_SYMBOL_GPL(__lock_page_killable);
 
+int  __wait_on_page_locked_killable(struct page *page)
+{
+	int ret = 0;
+	wait_queue_head_t *wq = page_waitqueue(page);
+	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+
+	if (!test_bit(PG_locked, &page->flags))
+		return 0;
+	do {
+		prepare_to_wait(wq, &wait.wait, TASK_KILLABLE);
+		if (!PageWaiters(page))
+			SetPageWaiters(page);
+		if (likely(PageLocked(page)))
+			ret = sleep_on_page_killable(page);
+		finish_wait(wq, &wait.wait);
+	} while (PageLocked(page) && !ret);
+
+	/* Clean up a potentially dangling PG_waiters */
+	if (unlikely(PageWaiters(page)))
+		__wake_page_waiters(page);
+
+	return ret;
+}
+EXPORT_SYMBOL(__wait_on_page_locked_killable);
+
+void  __wait_on_page_locked(struct page *page)
+{
+	wait_queue_head_t *wq = page_waitqueue(page);
+	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+
+	do {
+		prepare_to_wait(wq, &wait.wait, TASK_UNINTERRUPTIBLE);
+		if (!PageWaiters(page))
+			SetPageWaiters(page);
+		if (likely(PageLocked(page)))
+			sleep_on_page(page);
+	} while (PageLocked(page));
+	finish_wait(wq, &wait.wait);
+
+	/* Clean up a potentially dangling PG_waiters */
+	if (unlikely(PageWaiters(page)))
+		__wake_page_waiters(page);
+}
+EXPORT_SYMBOL(__wait_on_page_locked);
+
 int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 			 unsigned int flags)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 94c5d06..0e0e9f7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6533,6 +6533,7 @@ static const struct trace_print_flags pageflag_names[] = {
 	{1UL << PG_private_2,		"private_2"	},
 	{1UL << PG_writeback,		"writeback"	},
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
+	{1UL << PG_waiters,		"waiters"	},
 	{1UL << PG_head,		"head"		},
 	{1UL << PG_tail,		"tail"		},
 #else
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

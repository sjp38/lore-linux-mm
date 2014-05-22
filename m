Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id C36206B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 20:07:22 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so2009218eek.6
        for <linux-mm@kvack.org>; Wed, 21 May 2014 17:07:22 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e43si11808290eeh.14.2014.05.21.17.07.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 17:07:21 -0700 (PDT)
Date: Thu, 22 May 2014 01:07:15 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v5
Message-ID: <20140522000715.GA23991@suse.de>
References: <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
 <20140521121501.GT23991@suse.de>
 <20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
 <20140521213354.GL2485@laptop.programming.kicks-ass.net>
 <20140521145000.f130f8779f7641d0d8afcace@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140521145000.f130f8779f7641d0d8afcace@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Wed, May 21, 2014 at 02:50:00PM -0700, Andrew Morton wrote:
> On Wed, 21 May 2014 23:33:54 +0200 Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Wed, May 21, 2014 at 02:26:22PM -0700, Andrew Morton wrote:
> > > > +static inline void
> > > > +__prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait,
> > > > +			struct page *page, int state, bool exclusive)
> > > 
> > > Putting MM stuff into core waitqueue code is rather bad.  I really
> > > don't know how I'm going to explain this to my family.
> > 
> > Right, so we could avoid all that and make the functions in mm/filemap.c
> > rather large and opencode a bunch of wait.c stuff.
> > 
> 
> The world won't end if we do it Mel's way and it's probably the most
> efficient.  But ugh.  This stuff does raise the "it had better be a
> useful patch" bar.
> 
> > Which is pretty much what I initially pseudo proposed.
> 
> Alternative solution is not to merge the patch ;)
> 

While true, the overhead of the page_waitqueue lookups and unnecessary
wakeups sucks even on small machines. Not only does it hit us during simple
operations like dd to a file but we would hit it during page reclaim as
well which is trylock_page/unlock_page intensive

> > > > +		__ClearPageWaiters(page);
> > > 
> > > We're freeing the page - if someone is still waiting on it then we have
> > > a huge bug?  It's the mysterious collision thing again I hope?
> > 
> > Yeah, so we only clear that bit when at 'unlock' we find there are no
> > more pending waiters, so if the last unlock still had a waiter, we'll
> > leave the bit set.
> 
> Confused.  If the last unlock had a waiter, that waiter will get woken
> up so there are no waiters any more, so the last unlock clears the flag.
> 
> um, how do we determine that there are no more waiters?  By looking at
> the waitqueue.  But that waitqueue is hashed, so it may contain waiters
> for other pages so we're screwed?  But we could just go and wake up the
> other-page waiters anyway and still clear PG_waiters?
> 
> um2, we're using exclusive waitqueues so we can't (or don't) wake all
> waiters, so we're screwed again?
> 
> (This process is proving to be a hard way of writing Mel's changelog btw).
> 
> If I'm still on track here, what happens if we switch to wake-all so we
> can avoid the dangling flag?  I doubt if there are many collisions on
> that hash table?
> 
> If there *are* a lot of collisions, I bet it's because a great pile of
> threads are all waiting on the same page.  If they're trying to lock
> that page then wake-all is bad.  But if they're just waiting for IO
> completion (probable) then it's OK.
> 
> I'll stop now.

Rather than putting details in the changelog, here is an updated version
that hopefully improves the commentary to the point where it's actually
clear. 

---8<---
From: Nick Piggin <npiggin@suse.de>
Subject: [PATCH] mm: filemap: Avoid unnecessary barriers and waitqueue lookups in unlock_page fastpath v6

Changelog since v5
o __always_inline where appropriate	(peterz)
o Documentation				(akpm)

Changelog since v4
o Remove dependency on io_schedule_timeout
o Push waiting logic down into waitqueue

This patch introduces a new page flag for 64-bit capable machines,
PG_waiters, to signal there are processes waiting on PG_lock or PG_writeback
and uses it to avoid memory barriers and waitqueue hash lookup in the
unlock_page fastpath.

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

The profiles show a clear reduction in waitqueue and wakeup functions. Note
that end_page_writeback costs the same as the savings there are due
to reduced calls to __wake_up_bit and page_waitqueue so there is no
obvious direct savings. The cost of unlock_page is higher as it's checking
PageWaiters but it is offset by reduced numbers of calls to page_waitqueue
and _wake_up_bit. There is a similar story told for each of the filesystems.
Note that for workloads that contend heavily on the page lock that
unlock_page may increase in cost as it has to clear PG_waiters so while
the typical case should be much faster, the worst case costs are now higher.

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
 include/linux/page-flags.h |  18 ++++++
 include/linux/wait.h       |   8 +++
 kernel/sched/wait.c        | 137 ++++++++++++++++++++++++++++++++++-----------
 mm/filemap.c               |  25 +++++----
 mm/page_alloc.c            |   1 +
 mm/swap.c                  |  12 ++++
 mm/vmscan.c                |   7 +++
 7 files changed, 165 insertions(+), 43 deletions(-)

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
index bd68819..9226724 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -141,14 +141,21 @@ __remove_wait_queue(wait_queue_head_t *head, wait_queue_t *old)
 	list_del(&old->task_list);
 }
 
+struct page;
+
 void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
 void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key);
 void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
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
@@ -822,6 +829,7 @@ void prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait, int state);
 void prepare_to_wait_exclusive(wait_queue_head_t *q, wait_queue_t *wait, int state);
 long prepare_to_wait_event(wait_queue_head_t *q, wait_queue_t *wait, int state);
 void finish_wait(wait_queue_head_t *q, wait_queue_t *wait);
+void finish_wait_page(wait_queue_head_t *q, wait_queue_t *wait, struct page *page);
 void abort_exclusive_wait(wait_queue_head_t *q, wait_queue_t *wait, unsigned int mode, void *key);
 int autoremove_wake_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
 int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
index 0ffa20a..bd0495a92 100644
--- a/kernel/sched/wait.c
+++ b/kernel/sched/wait.c
@@ -167,31 +167,47 @@ EXPORT_SYMBOL_GPL(__wake_up_sync);	/* For internal use only */
  * stops them from bleeding out - it would still allow subsequent
  * loads to move into the critical region).
  */
-void
-prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait, int state)
+static __always_inline void
+__prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait,
+			struct page *page, int state, bool exclusive)
 {
 	unsigned long flags;
 
-	wait->flags &= ~WQ_FLAG_EXCLUSIVE;
 	spin_lock_irqsave(&q->lock, flags);
-	if (list_empty(&wait->task_list))
-		__add_wait_queue(q, wait);
+
+	/*
+	 * pages are hashed on a waitqueue that is expensive to lookup.
+	 * __wait_on_page_bit and __wait_on_page_bit_lock pass in a page
+	 * to set PG_waiters here. A PageWaiters() can then be used at
+	 * unlock time or when writeback completes to detect if there
+	 * are any potential waiters that justify a lookup.
+	 */
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
 
@@ -219,16 +235,8 @@ long prepare_to_wait_event(wait_queue_head_t *q, wait_queue_t *wait, int state)
 }
 EXPORT_SYMBOL(prepare_to_wait_event);
 
-/**
- * finish_wait - clean up after waiting in a queue
- * @q: waitqueue waited on
- * @wait: wait descriptor
- *
- * Sets current thread back to running state and removes
- * the wait descriptor from the given waitqueue if still
- * queued.
- */
-void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
+static __always_inline void __finish_wait(wait_queue_head_t *q,
+			wait_queue_t *wait, struct page *page)
 {
 	unsigned long flags;
 
@@ -249,9 +257,33 @@ void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
 	if (!list_empty_careful(&wait->task_list)) {
 		spin_lock_irqsave(&q->lock, flags);
 		list_del_init(&wait->task_list);
+
+		/*
+		 * Clear PG_waiters if the waitqueue is no longer active. There
+		 * is no guarantee that a page with no waiters will get cleared
+		 * as there may be unrelated pages hashed to sleep on the same
+		 * queue. Accurate detection would require a counter but
+		 * collisions are expected to be rare.
+		 */
+		if (page && !waitqueue_active(q))
+			ClearPageWaiters(page);
 		spin_unlock_irqrestore(&q->lock, flags);
 	}
 }
+
+/**
+ * finish_wait - clean up after waiting in a queue
+ * @q: waitqueue waited on
+ * @wait: wait descriptor
+ *
+ * Sets current thread back to running state and removes
+ * the wait descriptor from the given waitqueue if still
+ * queued.
+ */
+void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
+{
+	return __finish_wait(q, wait, NULL);
+}
 EXPORT_SYMBOL(finish_wait);
 
 /**
@@ -313,24 +345,39 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *arg)
 EXPORT_SYMBOL(wake_bit_function);
 
 /*
- * To allow interruptible waiting and asynchronous (i.e. nonblocking)
- * waiting, the actions of __wait_on_bit() and __wait_on_bit_lock() are
- * permitted return codes. Nonzero return codes halt waiting and return.
+ * waits on a bit to be cleared (see wait_on_bit in wait.h for details.
+ * A page is optionally provided when used to wait on the PG_locked or
+ * PG_writeback bit. By setting PG_waiters a lookup of the waitqueue
+ * can be avoided during unlock_page or end_page_writeback.
  */
 int __sched
-__wait_on_bit(wait_queue_head_t *wq, struct wait_bit_queue *q,
+__wait_on_page_bit(wait_queue_head_t *wq, struct wait_bit_queue *q,
+			struct page *page,
 			int (*action)(void *), unsigned mode)
 {
 	int ret = 0;
 
 	do {
-		prepare_to_wait(wq, &q->wait, mode);
+		__prepare_to_wait(wq, &q->wait, page, mode, false);
 		if (test_bit(q->key.bit_nr, q->key.flags))
 			ret = (*action)(q->key.flags);
 	} while (test_bit(q->key.bit_nr, q->key.flags) && !ret);
-	finish_wait(wq, &q->wait);
+	__finish_wait(wq, &q->wait, page);
 	return ret;
 }
+
+/*
+ * To allow interruptible waiting and asynchronous (i.e. nonblocking)
+ * waiting, the actions of __wait_on_bit() and __wait_on_bit_lock() are
+ * permitted return codes. Nonzero return codes halt waiting and return.
+ */
+int __sched
+__wait_on_bit(wait_queue_head_t *wq, struct wait_bit_queue *q,
+			int (*action)(void *), unsigned mode)
+{
+	return __wait_on_page_bit(wq, q, NULL, action, mode);
+}
+
 EXPORT_SYMBOL(__wait_on_bit);
 
 int __sched out_of_line_wait_on_bit(void *word, int bit,
@@ -344,13 +391,14 @@ int __sched out_of_line_wait_on_bit(void *word, int bit,
 EXPORT_SYMBOL(out_of_line_wait_on_bit);
 
 int __sched
-__wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
+__wait_on_page_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
+			struct page *page,
 			int (*action)(void *), unsigned mode)
 {
 	do {
 		int ret;
 
-		prepare_to_wait_exclusive(wq, &q->wait, mode);
+		__prepare_to_wait(wq, &q->wait, page, mode, true);
 		if (!test_bit(q->key.bit_nr, q->key.flags))
 			continue;
 		ret = action(q->key.flags);
@@ -359,9 +407,16 @@ __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
 		abort_exclusive_wait(wq, &q->wait, mode, &q->key);
 		return ret;
 	} while (test_and_set_bit(q->key.bit_nr, q->key.flags));
-	finish_wait(wq, &q->wait);
+	__finish_wait(wq, &q->wait, page);
 	return 0;
 }
+
+int __sched
+__wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
+			int (*action)(void *), unsigned mode)
+{
+	return __wait_on_page_bit_lock(wq, q, NULL, action, mode);
+}
 EXPORT_SYMBOL(__wait_on_bit_lock);
 
 int __sched out_of_line_wait_on_bit_lock(void *word, int bit,
@@ -374,6 +429,24 @@ int __sched out_of_line_wait_on_bit_lock(void *word, int bit,
 }
 EXPORT_SYMBOL(out_of_line_wait_on_bit_lock);
 
+void __wake_up_page_bit(wait_queue_head_t *wqh, struct page *page, void *word, int bit)
+{
+	struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(word, bit);
+	unsigned long flags;
+
+	/*
+	 * Unlike __wake_up_bit it is necessary to check waitqueue_active to be
+	 * checked under the wqh->lock to avoid races with parallel additions
+	 * to the waitqueue. Otherwise races could result in lost wakeups
+	 */
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
index 9e8e347..1581dbf 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -67,6 +67,10 @@ static void __page_cache_release(struct page *page)
 static void __put_single_page(struct page *page)
 {
 	__page_cache_release(page);
+
+	/* See release_pages on why this clear may be necessary */
+	__ClearPageWaiters(page);
+
 	free_hot_cold_page(page, false);
 }
 
@@ -916,6 +920,14 @@ void release_pages(struct page **pages, int nr, bool cold)
 		/* Clear Active bit in case of parallel mark_page_accessed */
 		__ClearPageActive(page);
 
+		/*
+		 * pages are hashed on a waitqueue so there may be collisions.
+		 * When waiters are woken the waitqueue is checked but
+		 * unrelated pages on the queue can leave the bit set. Clear
+		 * it here if that happens.
+		 */
+		__ClearPageWaiters(page);
+
 		list_add(&page->lru, &pages_to_free);
 	}
 	if (zone)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7f85041..d7a4969 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1096,6 +1096,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * waiting on the page lock, because there are no references.
 		 */
 		__clear_page_locked(page);
+
+		/* See release_pages on why this clear may be necessary */
+		__ClearPageWaiters(page);
 free_it:
 		nr_reclaimed++;
 
@@ -1427,6 +1430,8 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
+			/* See release_pages on why this clear may be necessary */
+			__ClearPageWaiters(page);
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {
@@ -1650,6 +1655,8 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
+			/* See release_pages on why this clear may be necessary */
+			__ClearPageWaiters(page);
 			del_page_from_lru_list(page, lruvec, lru);
 
 			if (unlikely(PageCompound(page))) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

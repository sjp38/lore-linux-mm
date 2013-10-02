Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id DBF226B0044
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 18:39:16 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so1559580pbc.9
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 15:39:16 -0700 (PDT)
Subject: [PATCH v8 9/9] rwsem: reduce spinlock contention in wakeup code
 path
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1380748401.git.tim.c.chen@linux.intel.com>
References: <cover.1380748401.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 02 Oct 2013 15:38:46 -0700
Message-ID: <1380753526.11046.91.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Jason Low <jason.low2@hp.com>, Waiman Long <Waiman.Long@hp.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

With the 3.12-rc2 kernel, there is sizable spinlock contention on
the rwsem wakeup code path when running AIM7's high_systime workload
on a 8-socket 80-core DL980 (HT off) as reported by perf:

  7.64%   reaim  [kernel.kallsyms]   [k] _raw_spin_lock_irqsave
             |--41.77%-- rwsem_wake
  1.61%   reaim  [kernel.kallsyms]   [k] _raw_spin_lock_irq
             |--92.37%-- rwsem_down_write_failed

That was 4.7% of recorded CPU cycles.

On a large NUMA machine, it is entirely possible that a fairly large
number of threads are queuing up in the ticket spinlock queue to do
the wakeup operation. In fact, only one will be needed.  This patch
tries to reduce spinlock contention by doing just that.

A new wakeup field is added to the rwsem structure. This field is
set on entry to rwsem_wake() and __rwsem_do_wake() to mark that a
thread is pending to do the wakeup call. It is cleared on exit from
those functions. There is no size increase in 64-bit systems and a
4 bytes size increase in 32-bit systems.

By checking if the wakeup flag is set, a thread can exit rwsem_wake()
immediately if another thread is pending to do the wakeup instead of
waiting to get the spinlock and find out that nothing need to be done.

The setting of the wakeup flag may not be visible on all processors in
some architectures. However, this won't affect program correctness. The
clearing of the wakeup flag before spin_unlock and other barrier-type
atomic instructions will ensure that it is visible to all processors.

With this patch alone, the performance improvement on jobs per minute
(JPM) of an sample run of the high_systime workload (at 1500 users)
on DL980 was as follows:

HT	JPM w/o patch	JPM with patch	% Change
--	-------------	--------------	--------
off	   148265	   170896	 +15.3%
on	   140078	   159319	 +13.7%

The new perf profile (HT off) was as follows:

  2.96%   reaim  [kernel.kallsyms]   [k] _raw_spin_lock_irqsave
             |--0.94%-- rwsem_wake
  1.00%   reaim  [kernel.kallsyms]   [k] _raw_spin_lock_irq
             |--88.70%-- rwsem_down_write_failed

Together with the rest of rwsem patches in the series, the JPM number
(HT off) jumps to 195041 which is 32% better.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 include/linux/rwsem.h |    2 ++
 lib/rwsem.c           |   29 +++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index aba7920..29314d3 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -26,6 +26,7 @@ struct mcs_spinlock;
 struct rw_semaphore {
 	long			count;
 	raw_spinlock_t		wait_lock;
+	int			wakeup;	/* Waking-up in progress flag */
 	struct list_head	wait_list;
 	struct task_struct	*owner; /* write owner */
 	struct mcs_spinlock	*mcs_lock;
@@ -61,6 +62,7 @@ static inline int rwsem_is_locked(struct rw_semaphore *sem)
 #define __RWSEM_INITIALIZER(name)			\
 	{ RWSEM_UNLOCKED_VALUE,				\
 	  __RAW_SPIN_LOCK_UNLOCKED(name.wait_lock),	\
+	  0,						\
 	  LIST_HEAD_INIT((name).wait_list),		\
 	  NULL,						\
 	  NULL						\
diff --git a/lib/rwsem.c b/lib/rwsem.c
index cc3b33e..1adee01 100644
--- a/lib/rwsem.c
+++ b/lib/rwsem.c
@@ -27,6 +27,7 @@ void __init_rwsem(struct rw_semaphore *sem, const char *name,
 	lockdep_init_map(&sem->dep_map, name, key, 0);
 #endif
 	sem->count = RWSEM_UNLOCKED_VALUE;
+	sem->wakeup = 0;
 	raw_spin_lock_init(&sem->wait_lock);
 	INIT_LIST_HEAD(&sem->wait_list);
 	sem->owner = NULL;
@@ -70,6 +71,7 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 	struct list_head *next;
 	long woken, loop, adjustment;
 
+	sem->wakeup = 1;	/* Waking up in progress */
 	waiter = list_entry(sem->wait_list.next, struct rwsem_waiter, list);
 	if (waiter->type == RWSEM_WAITING_FOR_WRITE) {
 		if (wake_type == RWSEM_WAKE_ANY)
@@ -79,6 +81,7 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 			 * will block as they will notice the queued writer.
 			 */
 			wake_up_process(waiter->task);
+		sem->wakeup = 0;	/* Wakeup done */
 		return sem;
 	}
 
@@ -87,6 +90,7 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 	 * so we can bail out early if a writer stole the lock.
 	 */
 	adjustment = 0;
+	sem->wakeup = 0;
 	if (wake_type != RWSEM_WAKE_READ_OWNED) {
 		adjustment = RWSEM_ACTIVE_READ_BIAS;
 		while (1) {
@@ -426,11 +430,36 @@ struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem)
 {
 	unsigned long flags;
 
+	if (sem->wakeup)
+		return sem;	/* Waking up in progress already */
+	/*
+	 * Optimistically set the wakeup flag to indicate that the current
+	 * thread is going to wakeup the sleeping waiters so that the
+	 * following threads don't need to wait for doing the wakeup call.
+	 * It is perfectly fine if another thread clears the flag. It just
+	 * leads to one more thread waiting to call __rwsem_do_wake().
+	 *
+	 * Writer lock stealing is not an issue for writers which are
+	 * unconditionally woken up. The woken writer is synchronized with
+	 * the waker via the spinlock. So the writer can't start doing
+	 * anything before the spinlock is released. For readers, the
+	 * situation is more complicated. The write lock stealer or the
+	 * woken readers are not synchronized with the waker. So they may
+	 * finish before the waker clears the wakeup flag. To prevent this
+	 * situation, the wakeup flag is cleared before the atomic update
+	 * of the count which also acts as a barrier.
+	 *
+	 * The spin_unlock() call at the end will force the just-cleared
+	 * wakeup flag to be visible to all the processors.
+	 */
+	sem->wakeup = 1;
 	raw_spin_lock_irqsave(&sem->wait_lock, flags);
 
 	/* do nothing if list empty */
 	if (!list_empty(&sem->wait_list))
 		sem = __rwsem_do_wake(sem, RWSEM_WAKE_ANY);
+	else
+		sem->wakeup = 0;	/* Make sure wakeup flag is cleared */
 
 	raw_spin_unlock_irqrestore(&sem->wait_lock, flags);
 
-- 
1.7.4.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

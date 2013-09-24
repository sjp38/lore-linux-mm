Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C1FBD6B003A
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 18:23:06 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so5638836pab.27
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 15:23:06 -0700 (PDT)
Subject: [PATCH v5 6/6] rwsem: do optimistic spinning for writer lock
 acquisition
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1380057198.git.tim.c.chen@linux.intel.com>
References: <cover.1380057198.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 24 Sep 2013 15:22:53 -0700
Message-ID: <1380061373.3467.55.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

We want to add optimistic spinning to rwsems because
the writer rwsem does not perform as well as mutexes. Tim noticed that
for exim (mail server) workloads, when reverting commit 4fc3f1d6 and
Davidlohr noticed it when converting the i_mmap_mutex to a rwsem in some
aim7 workloads. We've noticed that the biggest difference
is when we fail to acquire a mutex in the fastpath, optimistic spinning
comes in to play and we can avoid a large amount of unnecessary sleeping
and overhead of moving tasks in and out of wait queue.

Allowing optimistic spinning before putting the writer on the wait queue
reduces wait queue contention and provided greater chance for the rwsem
to get acquired. With these changes, rwsem is on par with mutex.

Reviewed-by: Peter Zijlstra <peterz@infradead.org>
Reviewed-by: Peter Hurley <peter@hurleysoftware.com>
Reviewed-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 include/linux/rwsem.h |    8 ++-
 kernel/rwsem.c        |   19 +++++-
 lib/rwsem.c           |  193 +++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 201 insertions(+), 19 deletions(-)

diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index 0616ffe..4dfc6ae 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -29,6 +29,8 @@ struct rw_semaphore {
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 	struct lockdep_map	dep_map;
 #endif
+	struct task_struct	*owner;
+	void			*spin_mlock;
 };
 
 extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
@@ -58,8 +60,10 @@ static inline int rwsem_is_locked(struct rw_semaphore *sem)
 #define __RWSEM_INITIALIZER(name)			\
 	{ RWSEM_UNLOCKED_VALUE,				\
 	  __RAW_SPIN_LOCK_UNLOCKED(name.wait_lock),	\
-	  LIST_HEAD_INIT((name).wait_list)		\
-	  __RWSEM_DEP_MAP_INIT(name) }
+	  LIST_HEAD_INIT((name).wait_list),		\
+	  __RWSEM_DEP_MAP_INIT(name)			\
+	  NULL,						\
+	  NULL }
 
 #define DECLARE_RWSEM(name) \
 	struct rw_semaphore name = __RWSEM_INITIALIZER(name)
diff --git a/kernel/rwsem.c b/kernel/rwsem.c
index cfff143..d74d1c9 100644
--- a/kernel/rwsem.c
+++ b/kernel/rwsem.c
@@ -12,6 +12,16 @@
 
 #include <linux/atomic.h>
 
+static inline void rwsem_set_owner(struct rw_semaphore *sem)
+{
+	sem->owner = current;
+}
+
+static inline void rwsem_clear_owner(struct rw_semaphore *sem)
+{
+	sem->owner = NULL;
+}
+
 /*
  * lock for reading
  */
@@ -48,6 +58,7 @@ void __sched down_write(struct rw_semaphore *sem)
 	rwsem_acquire(&sem->dep_map, 0, 0, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
+	rwsem_set_owner(sem);
 }
 
 EXPORT_SYMBOL(down_write);
@@ -59,8 +70,10 @@ int down_write_trylock(struct rw_semaphore *sem)
 {
 	int ret = __down_write_trylock(sem);
 
-	if (ret == 1)
+	if (ret == 1) {
 		rwsem_acquire(&sem->dep_map, 0, 1, _RET_IP_);
+		rwsem_set_owner(sem);
+	}
 	return ret;
 }
 
@@ -86,6 +99,7 @@ void up_write(struct rw_semaphore *sem)
 	rwsem_release(&sem->dep_map, 1, _RET_IP_);
 
 	__up_write(sem);
+	rwsem_clear_owner(sem);
 }
 
 EXPORT_SYMBOL(up_write);
@@ -100,6 +114,7 @@ void downgrade_write(struct rw_semaphore *sem)
 	 * dependency.
 	 */
 	__downgrade_write(sem);
+	rwsem_clear_owner(sem);
 }
 
 EXPORT_SYMBOL(downgrade_write);
@@ -122,6 +137,7 @@ void _down_write_nest_lock(struct rw_semaphore *sem, struct lockdep_map *nest)
 	rwsem_acquire_nest(&sem->dep_map, 0, 0, nest, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
+	rwsem_set_owner(sem);
 }
 
 EXPORT_SYMBOL(_down_write_nest_lock);
@@ -141,6 +157,7 @@ void down_write_nested(struct rw_semaphore *sem, int subclass)
 	rwsem_acquire(&sem->dep_map, subclass, 0, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
+	rwsem_set_owner(sem);
 }
 
 EXPORT_SYMBOL(down_write_nested);
diff --git a/lib/rwsem.c b/lib/rwsem.c
index 1d6e6e8..1752ec9 100644
--- a/lib/rwsem.c
+++ b/lib/rwsem.c
@@ -10,6 +10,8 @@
 #include <linux/sched.h>
 #include <linux/init.h>
 #include <linux/export.h>
+#include <linux/sched/rt.h>
+#include <linux/mcslock.h>
 
 /*
  * Initialize an rwsem:
@@ -27,6 +29,8 @@ void __init_rwsem(struct rw_semaphore *sem, const char *name,
 	sem->count = RWSEM_UNLOCKED_VALUE;
 	raw_spin_lock_init(&sem->wait_lock);
 	INIT_LIST_HEAD(&sem->wait_list);
+	sem->owner = NULL;
+	sem->spin_mlock = NULL;
 }
 
 EXPORT_SYMBOL(__init_rwsem);
@@ -194,14 +198,177 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 	return sem;
 }
 
+static inline int rwsem_try_write_lock(long count, struct rw_semaphore *sem)
+{
+	if (!(count & RWSEM_ACTIVE_MASK)) {
+		/* Try acquiring the write lock. */
+		if (sem->count == RWSEM_WAITING_BIAS &&
+		    cmpxchg(&sem->count, RWSEM_WAITING_BIAS,
+			    RWSEM_ACTIVE_WRITE_BIAS) == RWSEM_WAITING_BIAS) {
+			if (!list_is_singular(&sem->wait_list))
+				rwsem_atomic_update(RWSEM_WAITING_BIAS, sem);
+			return 1;
+		}
+	}
+	return 0;
+}
+
+static inline int rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
+{
+	long count;
+
+	count = ACCESS_ONCE(sem->count);
+retry:
+	if (count == RWSEM_WAITING_BIAS) {
+		count = cmpxchg(&sem->count, RWSEM_WAITING_BIAS,
+			    RWSEM_ACTIVE_WRITE_BIAS + RWSEM_WAITING_BIAS);
+		/* allow write lock stealing, try acquiring the write lock. */
+		if (count == RWSEM_WAITING_BIAS)
+			goto acquired;
+		else if (count == 0)
+			goto retry;
+	} else if (count == 0) {
+		count = cmpxchg(&sem->count, 0,
+			    RWSEM_ACTIVE_WRITE_BIAS);
+		if (count == 0)
+			goto acquired;
+		else if (count == RWSEM_WAITING_BIAS)
+			goto retry;
+	}
+	return 0;
+
+acquired:
+	return 1;
+}
+
+
+static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
+{
+	int retval;
+	struct task_struct *owner;
+
+	rcu_read_lock();
+	owner = ACCESS_ONCE(sem->owner);
+
+	/* Spin only if active writer running */
+	if (owner)
+		retval = owner->on_cpu;
+	else
+		retval = false;
+
+	rcu_read_unlock();
+	/*
+	 * if lock->owner is not set, the sem owner may have just acquired
+	 * it and not set the owner yet, or the sem has been released, or
+	 * reader active.
+	 */
+	return retval;
+}
+
+static inline bool owner_running(struct rw_semaphore *lock,
+				struct task_struct *owner)
+{
+	if (lock->owner != owner)
+		return false;
+
+	/*
+	 * Ensure we emit the owner->on_cpu, dereference _after_ checking
+	 * lock->owner still matches owner, if that fails, owner might
+	 * point to free()d memory, if it still matches, the rcu_read_lock()
+	 * ensures the memory stays valid.
+	 */
+	barrier();
+
+	return owner->on_cpu;
+}
+
+static noinline
+int rwsem_spin_on_owner(struct rw_semaphore *lock, struct task_struct *owner)
+{
+	rcu_read_lock();
+	while (owner_running(lock, owner)) {
+		if (need_resched())
+			break;
+
+		arch_mutex_cpu_relax();
+	}
+	rcu_read_unlock();
+
+	/*
+	 * We break out the loop above on need_resched() or when the
+	 * owner changed, which is a sign for heavy contention. Return
+	 * success only when lock->owner is NULL.
+	 */
+	return lock->owner == NULL;
+}
+
+#define MLOCK(rwsem)    ((struct mcs_spin_node **)&((rwsem)->spin_mlock))
+
+int rwsem_optimistic_spin(struct rw_semaphore *sem)
+{
+	struct	task_struct	*owner;
+	int	ret = 0;
+
+	/* sem->wait_lock should not be held when doing optimistic spinning */
+	if (!rwsem_can_spin_on_owner(sem))
+		return ret;
+
+	preempt_disable();
+	for (;;) {
+		struct mcs_spin_node node;
+
+		mcs_spin_lock(MLOCK(sem), &node);
+		owner = ACCESS_ONCE(sem->owner);
+		if (owner && !rwsem_spin_on_owner(sem, owner)) {
+			mcs_spin_unlock(MLOCK(sem), &node);
+			break;
+		}
+
+		/* wait_lock will be acquired if write_lock is obtained */
+		if (rwsem_try_write_lock_unqueued(sem)) {
+			mcs_spin_unlock(MLOCK(sem), &node);
+			ret = 1;
+			break;
+		}
+		mcs_spin_unlock(MLOCK(sem), &node);
+
+		/*
+		 * When there's no owner, we might have preempted between the
+		 * owner acquiring the lock and setting the owner field. If
+		 * we're an RT task that will live-lock because we won't let
+		 * the owner complete.
+		 */
+		if (!owner && (need_resched() || rt_task(current)))
+			break;
+
+		/*
+		 * The cpu_relax() call is a compiler barrier which forces
+		 * everything in this loop to be re-loaded. We don't need
+		 * memory barriers as we'll eventually observe the right
+		 * values at the cost of a few extra spins.
+		 */
+		arch_mutex_cpu_relax();
+
+	}
+
+	preempt_enable();
+	return ret;
+}
+
 /*
  * wait until we successfully acquire the write lock
  */
 struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
 {
-	long count, adjustment = -RWSEM_ACTIVE_WRITE_BIAS;
+	long count;
 	struct rwsem_waiter waiter;
 	struct task_struct *tsk = current;
+	bool waiting = true;
+
+	count = rwsem_atomic_update(-RWSEM_ACTIVE_WRITE_BIAS, sem);
+	/* do optimistic spinning */
+	if (rwsem_optimistic_spin(sem))
+		goto done;
 
 	/* set up my own style of waitqueue */
 	waiter.task = tsk;
@@ -209,33 +376,26 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
 
 	raw_spin_lock_irq(&sem->wait_lock);
 	if (list_empty(&sem->wait_list))
-		adjustment += RWSEM_WAITING_BIAS;
+		waiting = false;
 	list_add_tail(&waiter.list, &sem->wait_list);
 
 	/* we're now waiting on the lock, but no longer actively locking */
-	count = rwsem_atomic_update(adjustment, sem);
+	if (waiting)
+		count = ACCESS_ONCE(sem->count);
+	else
+		count = rwsem_atomic_update(RWSEM_WAITING_BIAS, sem);
 
 	/* If there were already threads queued before us and there are no
 	 * active writers, the lock must be read owned; so we try to wake
 	 * any read locks that were queued ahead of us. */
-	if (count > RWSEM_WAITING_BIAS &&
-	    adjustment == -RWSEM_ACTIVE_WRITE_BIAS)
+	if ((count > RWSEM_WAITING_BIAS) && waiting)
 		sem = __rwsem_do_wake(sem, RWSEM_WAKE_READERS);
 
 	/* wait until we successfully acquire the lock */
 	set_task_state(tsk, TASK_UNINTERRUPTIBLE);
 	while (true) {
-		if (!(count & RWSEM_ACTIVE_MASK)) {
-			/* Try acquiring the write lock. */
-			count = RWSEM_ACTIVE_WRITE_BIAS;
-			if (!list_is_singular(&sem->wait_list))
-				count += RWSEM_WAITING_BIAS;
-
-			if (sem->count == RWSEM_WAITING_BIAS &&
-			    cmpxchg(&sem->count, RWSEM_WAITING_BIAS, count) ==
-							RWSEM_WAITING_BIAS)
-				break;
-		}
+		if (rwsem_try_write_lock(count, sem))
+			break;
 
 		raw_spin_unlock_irq(&sem->wait_lock);
 
@@ -250,6 +410,7 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
 
 	list_del(&waiter.list);
 	raw_spin_unlock_irq(&sem->wait_lock);
+done:
 	tsk->state = TASK_RUNNING;
 
 	return sem;
-- 
1.7.4.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

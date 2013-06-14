Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 8E6836B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 12:09:58 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
References: <1371165333.27102.568.camel@schen9-DESK>
	 <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 14 Jun 2013 09:09:57 -0700
Message-ID: <1371226197.27102.594.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Added copy to mailing list which I forgot in my previous reply:

On Thu, 2013-06-13 at 16:43 -0700, Davidlohr Bueso wrote:
> On Thu, 2013-06-13 at 16:15 -0700, Tim Chen wrote:
> > Ingo,
> > 
> > At the time of switching the anon-vma tree's lock from mutex to 
> > rw-sem (commit 5a505085), we encountered regressions for fork heavy workload. 
> > A lot of optimizations to rw-sem (e.g. lock stealing) helped to 
> > mitigate the problem.  I tried an experiment on the 3.10-rc4 kernel 
> > to compare the performance of rw-sem to one that uses mutex. I saw 
> > a 8% regression in throughput for rw-sem vs a mutex implementation in
> > 3.10-rc4.
> 
> Funny, just yesterday I was discussing this issue with Michel. While I
> didn't measure the anon-vma mutex->rwem conversion, I did convert the
> i_mmap_mutex to a rwsem and noticed a performance regression on a few
> aim7 workloads on a 8 socket, 80 core box, when keeping all writers,
> which should perform very similarly to a mutex. While some of these
> workloads recovered when I shared the lock among readers (similar to
> anon-vma), it left me wondering.
> 
> > For the experiments, I used the exim mail server workload in 
> > the MOSBENCH test suite on 4 socket (westmere) and a 4 socket 
> > (ivy bridge) with the number of clients sending mail equal 
> > to number of cores.  The mail server will
> > fork off a process to handle an incoming mail and put it into mail
> > spool. The lock protecting the anon-vma tree is stressed due to
> > heavy forking. On both machines, I saw that the mutex implementation 
> > has 8% more throughput.  I've pinned the cpu frequency to maximum
> > in the experiments.
> 
> I got some similar -8% throughput on high_systime and shared.
> 

That's interesting. Another perspective on rwsem vs mutex.

> > 
> > I've tried two separate tweaks to the rw-sem on 3.10-rc4.  I've tested 
> > each tweak individually.
> > 
> > 1) Add an owner field when a writer holds the lock and introduce 
> > optimistic spinning when an active writer is holding the semaphore.  
> > It reduced the context switching by 30% to a level very close to the
> > mutex implementation.  However, I did not see any throughput improvement
> > of exim.
> 
> I was hoping that the lack of spin on owner was the main difference with
> rwsems and am/was in the middle of implementing it. Could you send your
> patch so I can give it a try on my workloads?
> 
> Note that there have been a few recent (3.10) changes to mutexes that
> give a nice performance boost, specially on large systems, most
> noticeably:
> 
> commit 2bd2c92c (mutex: Make more scalable by doing less atomic
> operations)
> 
> commit 0dc8c730 (mutex: Queue mutex spinners with MCS lock to reduce
> cacheline contention)
> 
> It might be worth looking into doing something similar to commit
> 0dc8c730, in addition to the optimistic spinning.

Okay.  Here's my ugly experimental hack with some code lifted from optimistic spin 
within mutex.  I've thought about doing the MCS lock thing but decided 
to keep the first try on the optimistic spinning simple.

Matthew and I have also discussed possibly introducing some 
limited spinning for writer when semaphore is held by read.  
His idea was to have readers as well as writers set ->owner.  
Writers, as now, unconditionally clear owner.  Readers clear 
owner if sem->owner == current.  Writers spin on ->owner if ->owner 
is non-NULL and still active. That gives us a reasonable chance 
to spin since we'll be spinning on
the most recent acquirer of the lock.

Tim

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index 0616ffe..331f5f0 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -29,6 +29,7 @@ struct rw_semaphore {
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
        struct lockdep_map      dep_map;
 #endif
+       struct task_struct      *owner;
 };
 
 extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
diff --git a/kernel/rwsem.c b/kernel/rwsem.c
index cfff143..916747f 100644
--- a/kernel/rwsem.c
+++ b/kernel/rwsem.c
@@ -12,6 +12,16 @@
 
 #include <linux/atomic.h>
 
+static inline void rwsem_set_owner(struct rw_semaphore *sem)
+{
+       sem->owner = current;
+}
+
+static inline void rwsem_clear_owner(struct rw_semaphore *sem)
+{
+       sem->owner = NULL;
+}
+
 /*
  * lock for reading
  */
@@ -48,6 +58,7 @@ void __sched down_write(struct rw_semaphore *sem)
        rwsem_acquire(&sem->dep_map, 0, 0, _RET_IP_);
 
        LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
+       rwsem_set_owner(sem);   
 }
 
 EXPORT_SYMBOL(down_write);
@@ -59,8 +70,10 @@ int down_write_trylock(struct rw_semaphore *sem)
 {
        int ret = __down_write_trylock(sem);
 
-       if (ret == 1)
+       if (ret == 1) {
                rwsem_acquire(&sem->dep_map, 0, 1, _RET_IP_);
+               rwsem_set_owner(sem);   
+       }
        return ret;
 }
 
@@ -86,6 +99,7 @@ void up_write(struct rw_semaphore *sem)
        rwsem_release(&sem->dep_map, 1, _RET_IP_);
 
        __up_write(sem);
+       rwsem_clear_owner(sem); 
 }
 
 EXPORT_SYMBOL(up_write);
@@ -100,6 +114,7 @@ void downgrade_write(struct rw_semaphore *sem)
         * dependency.
         */
        __downgrade_write(sem);
+       rwsem_clear_owner(sem); 
 }
 
 EXPORT_SYMBOL(downgrade_write);
@@ -122,6 +137,7 @@ void _down_write_nest_lock(struct rw_semaphore *sem, struct lockdep_map *nest)
        rwsem_acquire_nest(&sem->dep_map, 0, 0, nest, _RET_IP_);
 
        LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
+       rwsem_set_owner(sem);   
 }
 
 EXPORT_SYMBOL(_down_write_nest_lock);
@@ -141,6 +157,7 @@ void down_write_nested(struct rw_semaphore *sem, int subclass)
        rwsem_acquire(&sem->dep_map, subclass, 0, _RET_IP_);
 
        LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
+       rwsem_set_owner(sem);   
 }
 
 EXPORT_SYMBOL(down_write_nested);
diff --git a/lib/rwsem-spinlock.c b/lib/rwsem-spinlock.c
index 9be8a91..9d3edd5 100644
--- a/lib/rwsem-spinlock.c
+++ b/lib/rwsem-spinlock.c
@@ -49,6 +49,7 @@ void __init_rwsem(struct rw_semaphore *sem, const char *name,
        sem->activity = 0;
        raw_spin_lock_init(&sem->wait_lock);
        INIT_LIST_HEAD(&sem->wait_list);
+       sem->owner = NULL;
 }
 EXPORT_SYMBOL(__init_rwsem);
 
diff --git a/lib/rwsem.c b/lib/rwsem.c
index 19c5fa9..4dbd022 100644
--- a/lib/rwsem.c
+++ b/lib/rwsem.c
@@ -8,6 +8,7 @@
  */
 #include <linux/rwsem.h>
 #include <linux/sched.h>
+#include <linux/sched/rt.h>
 #include <linux/init.h>
 #include <linux/export.h>
 
@@ -27,6 +28,7 @@ void __init_rwsem(struct rw_semaphore *sem, const char *name,
        sem->count = RWSEM_UNLOCKED_VALUE;
        raw_spin_lock_init(&sem->wait_lock);
        INIT_LIST_HEAD(&sem->wait_list);
+       sem->owner = NULL;
 }
 
 EXPORT_SYMBOL(__init_rwsem);
@@ -187,12 +189,126 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
        return sem;
 }
 
+static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
+{
+        int retval = true;
+
+       /* Spin only if active writer running */
+       if (!sem->owner)
+               return false;
+
+        rcu_read_lock();
+        if (sem->owner)
+                retval = sem->owner->on_cpu;
+        rcu_read_unlock();
+        /*
+         * if lock->owner is not set, the sem owner may have just acquired
+         * it and not set the owner yet, or the sem has been released, or
+         * reader active.
+         */
+        return retval;
+}
+
+static inline bool owner_running(struct rw_semaphore *lock, struct task_struct *owner)
+{
+        if (lock->owner != owner)
+                return false;
+
+        /*
+         * Ensure we emit the owner->on_cpu, dereference _after_ checking
+         * lock->owner still matches owner, if that fails, owner might
+         * point to free()d memory, if it still matches, the rcu_read_lock()
+         * ensures the memory stays valid.
+         */
+        barrier();
+
+        return owner->on_cpu;
+}
+
+static noinline
+int rwsem_spin_on_owner(struct rw_semaphore *lock, struct task_struct *owner)
+{
+        rcu_read_lock();
+        while (owner_running(lock, owner)) {
+                if (need_resched())
+                        break;
+
+                arch_mutex_cpu_relax();
+        }
+        rcu_read_unlock();
+
+        /*
+         * We break out the loop above on need_resched() and when the
+         * owner changed, which is a sign for heavy contention. Return
+         * success only when lock->owner is NULL.
+         */
+        return lock->owner == NULL;
+}
+
+
+static inline int rwsem_try_write_lock(long count, bool need_lock, struct rw_semaphore *sem)
+{
+       if (!(count & RWSEM_ACTIVE_MASK)) {
+               /* Try acquiring the write lock. */
+               if (sem->count == RWSEM_WAITING_BIAS &&
+                   cmpxchg(&sem->count, RWSEM_WAITING_BIAS,
+                           RWSEM_ACTIVE_WRITE_BIAS) == RWSEM_WAITING_BIAS) {
+                       if (need_lock)
+                               raw_spin_lock_irq(&sem->wait_lock);
+                       if (!list_is_singular(&sem->wait_list))
+                               rwsem_atomic_update(RWSEM_WAITING_BIAS, sem);
+                       return 1;
+               }
+       }
+       return 0;
+}
+
+int rwsem_optimistic_spin(struct rw_semaphore *sem)
+{
+       struct  task_struct     *owner;
+
+       /* sem->wait_lock should not be held when attempting optimistic spinning */
+       if (!rwsem_can_spin_on_owner(sem))
+               return 0;
+
+       for (;;) {
+               owner = ACCESS_ONCE(sem->owner);
+               if (owner && !rwsem_spin_on_owner(sem, owner))
+                       break;
+
+               /* wait_lock will be acquired if write_lock is obtained */
+               if (rwsem_try_write_lock(sem->count, true, sem))
+                       return 1;
+
+               /*
+                 * When there's no owner, we might have preempted between the
+                 * owner acquiring the lock and setting the owner field. If
+                 * we're an RT task that will live-lock because we won't let
+                 * the owner complete.
+                 */
+                if (!owner && (need_resched() || rt_task(current)))
+                        break;
+
+                /*
+                 * The cpu_relax() call is a compiler barrier which forces
+                 * everything in this loop to be re-loaded. We don't need
+                 * memory barriers as we'll eventually observe the right
+                 * values at the cost of a few extra spins.
+                 */
+                arch_mutex_cpu_relax();
+
+       }       
+
+       return 0;
+}
+
 /*
  * wait until we successfully acquire the write lock
  */
 struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
 {
        long count, adjustment = -RWSEM_ACTIVE_WRITE_BIAS;
+       bool try_optimistic_spin = true;
        struct rwsem_waiter waiter;
        struct task_struct *tsk = current;
 
@@ -218,20 +334,16 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
        /* wait until we successfully acquire the lock */
        set_task_state(tsk, TASK_UNINTERRUPTIBLE);
        while (true) {
-               if (!(count & RWSEM_ACTIVE_MASK)) {
-                       /* Try acquiring the write lock. */
-                       count = RWSEM_ACTIVE_WRITE_BIAS;
-                       if (!list_is_singular(&sem->wait_list))
-                               count += RWSEM_WAITING_BIAS;
-
-                       if (sem->count == RWSEM_WAITING_BIAS &&
-                           cmpxchg(&sem->count, RWSEM_WAITING_BIAS, count) ==
-                                                       RWSEM_WAITING_BIAS)
-                               break;
-               }
+               if (rwsem_try_write_lock(count, false, sem))
+                       break;
 
                raw_spin_unlock_irq(&sem->wait_lock);
 
+               /* do some optimistic spinning */
+               if (try_optimistic_spin && rwsem_optimistic_spin(sem))
+                       break;
+
+               try_optimistic_spin = false;
                /* Block until there are no active lockers. */
                do {
                        schedule();




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id BFF506B0032
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 05:50:53 -0400 (EDT)
Message-ID: <51BD8A77.2080201@intel.com>
Date: Sun, 16 Jun 2013 17:50:47 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: Performance regression from switching lock to rw-sem for anon-vma
 tree
References: <1371165333.27102.568.camel@schen9-DESK> <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1371167015.1754.14.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alex Shi <alex.shi@intel.com>

On 06/14/2013 07:43 AM, Davidlohr Bueso wrote:
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

It is a good tunning for large machine. I just following what the commit 
0dc8c730 done, give a RFC patch here. I tried it on my NHM EP machine. seems no
clear help on aim7. but maybe it is helpful on large machine.  :)


diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
index bb1e2cd..240729a 100644
--- a/include/asm-generic/rwsem.h
+++ b/include/asm-generic/rwsem.h
@@ -70,11 +70,11 @@ static inline void __down_write(struct rw_semaphore *sem)
 
 static inline int __down_write_trylock(struct rw_semaphore *sem)
 {
-	long tmp;
+	if (unlikely(&sem->count != RWSEM_UNLOCKED_VALUE))
+		return 0;
 
-	tmp = cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
-		      RWSEM_ACTIVE_WRITE_BIAS);
-	return tmp == RWSEM_UNLOCKED_VALUE;
+	return cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
+		      RWSEM_ACTIVE_WRITE_BIAS) == RWSEM_UNLOCKED_VALUE;
 }
 
 /*
diff --git a/lib/rwsem.c b/lib/rwsem.c
index 19c5fa9..9e54e20 100644
--- a/lib/rwsem.c
+++ b/lib/rwsem.c
@@ -64,7 +64,7 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 	struct rwsem_waiter *waiter;
 	struct task_struct *tsk;
 	struct list_head *next;
-	long oldcount, woken, loop, adjustment;
+	long woken, loop, adjustment;
 
 	waiter = list_entry(sem->wait_list.next, struct rwsem_waiter, list);
 	if (waiter->type == RWSEM_WAITING_FOR_WRITE) {
@@ -75,7 +75,7 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 			 * will block as they will notice the queued writer.
 			 */
 			wake_up_process(waiter->task);
-		goto out;
+		return sem;
 	}
 
 	/* Writers might steal the lock before we grant it to the next reader.
@@ -85,15 +85,28 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 	adjustment = 0;
 	if (wake_type != RWSEM_WAKE_READ_OWNED) {
 		adjustment = RWSEM_ACTIVE_READ_BIAS;
- try_reader_grant:
-		oldcount = rwsem_atomic_update(adjustment, sem) - adjustment;
-		if (unlikely(oldcount < RWSEM_WAITING_BIAS)) {
-			/* A writer stole the lock. Undo our reader grant. */
+		while (1) {
+			long oldcount;
+
+			/* A writer stole the lock. */
+			if (unlikely(sem->count & RWSEM_ACTIVE_MASK))
+				return sem;
+
+			if (unlikely(sem->count < RWSEM_WAITING_BIAS)) {
+				cpu_relax();
+				continue;
+			}
+
+			oldcount = rwsem_atomic_update(adjustment, sem)
+								- adjustment;
+			if (likely(oldcount >= RWSEM_WAITING_BIAS))
+				break;
+
+			 /* A writer stole the lock.  Undo our reader grant. */
 			if (rwsem_atomic_update(-adjustment, sem) &
 						RWSEM_ACTIVE_MASK)
-				goto out;
+				return sem;
 			/* Last active locker left. Retry waking readers. */
-			goto try_reader_grant;
 		}
 	}
 
@@ -136,7 +149,6 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 	sem->wait_list.next = next;
 	next->prev = &sem->wait_list;
 
- out:
 	return sem;
 }
 
-- 
Thanks
    Alex


-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

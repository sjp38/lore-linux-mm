Message-Id: <20080926173313.465757651@twins.programming.kicks-ass.net>
Date: Fri, 26 Sep 2008 19:32:21 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 2/4] futex: reduce mmap_sem usage
References: <20080926173219.885155151@twins.programming.kicks-ass.net>
Content-Disposition: inline; filename=futex-reduce-mmap_sem.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

now that we rely on get_user_pages() for the shared key handling
move all the mmap_sem stuff closely around the slow paths.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/futex.c |   83 ++-------------------------------------------------------
 1 file changed, 4 insertions(+), 79 deletions(-)

Index: linux-2.6/kernel/futex.c
===================================================================
--- linux-2.6.orig/kernel/futex.c
+++ linux-2.6/kernel/futex.c
@@ -123,24 +123,6 @@ struct futex_hash_bucket {
 static struct futex_hash_bucket futex_queues[1<<FUTEX_HASHBITS];
 
 /*
- * Take mm->mmap_sem, when futex is shared
- */
-static inline void futex_lock_mm(struct rw_semaphore *fshared)
-{
-	if (fshared)
-		down_read(fshared);
-}
-
-/*
- * Release mm->mmap_sem, when the futex is shared
- */
-static inline void futex_unlock_mm(struct rw_semaphore *fshared)
-{
-	if (fshared)
-		up_read(fshared);
-}
-
-/*
  * We hash on the keys returned from get_futex_key (see below).
  */
 static struct futex_hash_bucket *hash_futex(union futex_key *key)
@@ -250,7 +232,9 @@ static int get_futex_key(u32 __user *uad
 	}
 
 again:
+	down_read(&mm->mmap_sem);
 	err = get_user_pages(current, mm, address, 1, 0, 0, &page, NULL);
+	up_read(&mm->mmap_sem);
 	if (err < 0)
 		return err;
 
@@ -327,8 +311,7 @@ static int futex_handle_fault(unsigned l
 	if (attempt > 2)
 		return ret;
 
-	if (!fshared)
-		down_read(&mm->mmap_sem);
+	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, address);
 	if (vma && address >= vma->vm_start &&
 	    (vma->vm_flags & VM_WRITE)) {
@@ -348,8 +331,7 @@ static int futex_handle_fault(unsigned l
 				current->min_flt++;
 		}
 	}
-	if (!fshared)
-		up_read(&mm->mmap_sem);
+	up_read(&mm->mmap_sem);
 	return ret;
 }
 
@@ -719,8 +701,6 @@ static int futex_wake(u32 __user *uaddr,
 	if (!bitset)
 		return -EINVAL;
 
-	futex_lock_mm(fshared);
-
 	ret = get_futex_key(uaddr, fshared, &key);
 	if (unlikely(ret != 0))
 		goto out;
@@ -749,7 +729,6 @@ static int futex_wake(u32 __user *uaddr,
 	spin_unlock(&hb->lock);
 out:
 	put_futex_key(fshared, &key);
-	futex_unlock_mm(fshared);
 	return ret;
 }
 
@@ -769,8 +748,6 @@ futex_wake_op(u32 __user *uaddr1, struct
 	int ret, op_ret, attempt = 0;
 
 retryfull:
-	futex_lock_mm(fshared);
-
 	ret = get_futex_key(uaddr1, fshared, &key1);
 	if (unlikely(ret != 0))
 		goto out;
@@ -821,12 +798,6 @@ retry:
 			goto retry;
 		}
 
-		/*
-		 * If we would have faulted, release mmap_sem,
-		 * fault it in and start all over again.
-		 */
-		futex_unlock_mm(fshared);
-
 		ret = get_user(dummy, uaddr2);
 		if (ret)
 			return ret;
@@ -864,7 +835,6 @@ retry:
 out:
 	put_futex_key(fshared, &key2);
 	put_futex_key(fshared, &key1);
-	futex_unlock_mm(fshared);
 
 	return ret;
 }
@@ -884,8 +854,6 @@ static int futex_requeue(u32 __user *uad
 	int ret, drop_count = 0;
 
  retry:
-	futex_lock_mm(fshared);
-
 	ret = get_futex_key(uaddr1, fshared, &key1);
 	if (unlikely(ret != 0))
 		goto out;
@@ -908,12 +876,6 @@ static int futex_requeue(u32 __user *uad
 			if (hb1 != hb2)
 				spin_unlock(&hb2->lock);
 
-			/*
-			 * If we would have faulted, release mmap_sem, fault
-			 * it in and start all over again.
-			 */
-			futex_unlock_mm(fshared);
-
 			ret = get_user(curval, uaddr1);
 
 			if (!ret)
@@ -967,7 +929,6 @@ out_unlock:
 out:
 	put_futex_key(fshared, &key2);
 	put_futex_key(fshared, &key1);
-	futex_unlock_mm(fshared);
 	return ret;
 }
 
@@ -1211,8 +1172,6 @@ static int futex_wait(u32 __user *uaddr,
 	q.pi_state = NULL;
 	q.bitset = bitset;
  retry:
-	futex_lock_mm(fshared);
-
 	q.key = FUTEX_KEY_INIT;
 	ret = get_futex_key(uaddr, fshared, &q.key);
 	if (unlikely(ret != 0))
@@ -1245,12 +1204,6 @@ static int futex_wait(u32 __user *uaddr,
 	if (unlikely(ret)) {
 		queue_unlock(&q, hb);
 
-		/*
-		 * If we would have faulted, release mmap_sem, fault it in and
-		 * start all over again.
-		 */
-		futex_unlock_mm(fshared);
-
 		ret = get_user(uval, uaddr);
 
 		if (!ret)
@@ -1265,12 +1218,6 @@ static int futex_wait(u32 __user *uaddr,
 	queue_me(&q, hb);
 
 	/*
-	 * Now the futex is queued and we have checked the data, we
-	 * don't want to hold mmap_sem while we sleep.
-	 */
-	futex_unlock_mm(fshared);
-
-	/*
 	 * There might have been scheduling since the queue_me(), as we
 	 * cannot hold a spinlock across the get_user() in case it
 	 * faults, and we cannot just set TASK_INTERRUPTIBLE state when
@@ -1354,7 +1301,6 @@ static int futex_wait(u32 __user *uaddr,
 
  out_release_sem:
 	put_futex_key(fshared, &q.key);
-	futex_unlock_mm(fshared);
 	return ret;
 }
 
@@ -1403,8 +1349,6 @@ static int futex_lock_pi(u32 __user *uad
 
 	q.pi_state = NULL;
  retry:
-	futex_lock_mm(fshared);
-
 	q.key = FUTEX_KEY_INIT;
 	ret = get_futex_key(uaddr, fshared, &q.key);
 	if (unlikely(ret != 0))
@@ -1494,7 +1438,6 @@ static int futex_lock_pi(u32 __user *uad
 			 * exit to complete.
 			 */
 			queue_unlock(&q, hb);
-			futex_unlock_mm(fshared);
 			cond_resched();
 			goto retry;
 
@@ -1526,12 +1469,6 @@ static int futex_lock_pi(u32 __user *uad
 	 */
 	queue_me(&q, hb);
 
-	/*
-	 * Now the futex is queued and we have checked the data, we
-	 * don't want to hold mmap_sem while we sleep.
-	 */
-	futex_unlock_mm(fshared);
-
 	WARN_ON(!q.pi_state);
 	/*
 	 * Block on the PI mutex:
@@ -1544,7 +1481,6 @@ static int futex_lock_pi(u32 __user *uad
 		ret = ret ? 0 : -EWOULDBLOCK;
 	}
 
-	futex_lock_mm(fshared);
 	spin_lock(q.lock_ptr);
 
 	if (!ret) {
@@ -1610,7 +1546,6 @@ static int futex_lock_pi(u32 __user *uad
 
 	/* Unqueue and drop the lock */
 	unqueue_me_pi(&q);
-	futex_unlock_mm(fshared);
 
 	if (to)
 		destroy_hrtimer_on_stack(&to->timer);
@@ -1621,7 +1556,6 @@ static int futex_lock_pi(u32 __user *uad
 
  out_release_sem:
 	put_futex_key(fshared, &q.key);
-	futex_unlock_mm(fshared);
 	if (to)
 		destroy_hrtimer_on_stack(&to->timer);
 	return ret;
@@ -1645,8 +1579,6 @@ static int futex_lock_pi(u32 __user *uad
 		goto retry_unlocked;
 	}
 
-	futex_unlock_mm(fshared);
-
 	ret = get_user(uval, uaddr);
 	if (!ret && (uval != -EFAULT))
 		goto retry;
@@ -1678,10 +1610,6 @@ retry:
 	 */
 	if ((uval & FUTEX_TID_MASK) != task_pid_vnr(current))
 		return -EPERM;
-	/*
-	 * First take all the futex related locks:
-	 */
-	futex_lock_mm(fshared);
 
 	ret = get_futex_key(uaddr, fshared, &key);
 	if (unlikely(ret != 0))
@@ -1741,7 +1669,6 @@ out_unlock:
 	spin_unlock(&hb->lock);
 out:
 	put_futex_key(fshared, &key);
-	futex_unlock_mm(fshared);
 
 	return ret;
 
@@ -1765,8 +1692,6 @@ pi_faulted:
 		goto retry_unlocked;
 	}
 
-	futex_unlock_mm(fshared);
-
 	ret = get_user(uval, uaddr);
 	if (!ret && (uval != -EFAULT))
 		goto retry;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC PATCH 2/2] futex: use fast_gup()
Date: Fri, 04 Apr 2008 21:33:34 +0200
Message-ID: <20080404193817.830004000@chello.nl>
References: <20080404193332.348493000@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760818AbYDDTji@vger.kernel.org>
Content-Disposition: inline; filename=futex-fast_gup.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Nick Piggin <nickpiggin@yahoo.com.au>, Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

now that we rely on get_user_pages()/put_page() for the shared key handling
swhitch to fast_gup() and remove all the mmap_sem stuff.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/futex.c |   86 +--------------------------------------------------------
 1 file changed, 3 insertions(+), 83 deletions(-)

Index: linux-2.6/kernel/futex.c
===================================================================
--- linux-2.6.orig/kernel/futex.c
+++ linux-2.6/kernel/futex.c
@@ -129,24 +129,6 @@ static struct vfsmount *futex_mnt;
 int futex_performance_hack;
 
 /*
- * Take mm->mmap_sem, when futex is shared
- */
-static inline void futex_lock_mm(struct rw_semaphore *fshared)
-{
-	if (fshared && !futex_performance_hack)
-		down_read(fshared);
-}
-
-/*
- * Release mm->mmap_sem, when the futex is shared
- */
-static inline void futex_unlock_mm(struct rw_semaphore *fshared)
-{
-	if (fshared && !futex_performance_hack)
-		up_read(fshared);
-}
-
-/*
  * We hash on the keys returned from get_futex_key (see below).
  */
 static struct futex_hash_bucket *hash_futex(union futex_key *key)
@@ -217,7 +199,7 @@ static int get_futex_key(u32 __user *uad
 		return 0;
 	}
 
-	err = get_user_pages(current, mm, address, 1, 0, 0, &page, NULL);
+	err = fast_gup(address, 1, 0, &page);
 	if (err < 0)
 		return err;
 
@@ -312,8 +294,7 @@ static int futex_handle_fault(unsigned l
 	if (attempt > 2)
 		return ret;
 
-	if (!fshared)
-		down_read(&mm->mmap_sem);
+	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, address);
 	if (vma && address >= vma->vm_start &&
 	    (vma->vm_flags & VM_WRITE)) {
@@ -333,8 +314,7 @@ static int futex_handle_fault(unsigned l
 				current->min_flt++;
 		}
 	}
-	if (!fshared)
-		up_read(&mm->mmap_sem);
+	up_read(&mm->mmap_sem);
 	return ret;
 }
 
@@ -702,8 +682,6 @@ static int futex_wake(u32 __user *uaddr,
 	union futex_key key = FUTEX_KEY_INIT;
 	int ret;
 
-	futex_lock_mm(fshared);
-
 	ret = get_futex_key(uaddr, fshared, &key);
 	if (unlikely(ret != 0))
 		goto out;
@@ -727,7 +705,6 @@ static int futex_wake(u32 __user *uaddr,
 	spin_unlock(&hb->lock);
 out:
 	put_futex_key(fshared, &key);
-	futex_unlock_mm(fshared);
 	return ret;
 }
 
@@ -747,8 +724,6 @@ futex_wake_op(u32 __user *uaddr1, struct
 	int ret, op_ret, attempt = 0;
 
 retryfull:
-	futex_lock_mm(fshared);
-
 	ret = get_futex_key(uaddr1, fshared, &key1);
 	if (unlikely(ret != 0))
 		goto out;
@@ -799,12 +774,6 @@ retry:
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
@@ -842,7 +811,6 @@ retry:
 out:
 	put_futex_key(fshared, &key2);
 	put_futex_key(fshared, &key1);
-	futex_unlock_mm(fshared);
 
 	return ret;
 }
@@ -862,8 +830,6 @@ static int futex_requeue(u32 __user *uad
 	int ret, drop_count = 0;
 
  retry:
-	futex_lock_mm(fshared);
-
 	ret = get_futex_key(uaddr1, fshared, &key1);
 	if (unlikely(ret != 0))
 		goto out;
@@ -886,12 +852,6 @@ static int futex_requeue(u32 __user *uad
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
@@ -949,7 +909,6 @@ out_unlock:
 out:
 	put_futex_key(fshared, &key2);
 	put_futex_key(fshared, &key1);
-	futex_unlock_mm(fshared);
 	return ret;
 }
 
@@ -1154,8 +1113,6 @@ static int futex_wait(u32 __user *uaddr,
 
 	q.pi_state = NULL;
  retry:
-	futex_lock_mm(fshared);
-
 	q.key = FUTEX_KEY_INIT;
 	ret = get_futex_key(uaddr, fshared, &q.key);
 	if (unlikely(ret != 0))
@@ -1188,12 +1145,6 @@ static int futex_wait(u32 __user *uaddr,
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
@@ -1208,12 +1159,6 @@ static int futex_wait(u32 __user *uaddr,
 	__queue_me(&q, hb);
 
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
@@ -1297,7 +1242,6 @@ static int futex_wait(u32 __user *uaddr,
 
  out_release_sem:
 	put_futex_key(fshared, &q.key);
-	futex_unlock_mm(fshared);
 	return ret;
 }
 
@@ -1344,8 +1288,6 @@ static int futex_lock_pi(u32 __user *uad
 
 	q.pi_state = NULL;
  retry:
-	futex_lock_mm(fshared);
-
 	q.key = FUTEX_KEY_INIT;
 	ret = get_futex_key(uaddr, fshared, &q.key);
 	if (unlikely(ret != 0))
@@ -1435,7 +1377,6 @@ static int futex_lock_pi(u32 __user *uad
 			 * exit to complete.
 			 */
 			queue_unlock(&q, hb);
-			futex_unlock_mm(fshared);
 			cond_resched();
 			goto retry;
 
@@ -1467,12 +1408,6 @@ static int futex_lock_pi(u32 __user *uad
 	 */
 	__queue_me(&q, hb);
 
-	/*
-	 * Now the futex is queued and we have checked the data, we
-	 * don't want to hold mmap_sem while we sleep.
-	 */
-	futex_unlock_mm(fshared);
-
 	WARN_ON(!q.pi_state);
 	/*
 	 * Block on the PI mutex:
@@ -1485,7 +1420,6 @@ static int futex_lock_pi(u32 __user *uad
 		ret = ret ? 0 : -EWOULDBLOCK;
 	}
 
-	futex_lock_mm(fshared);
 	spin_lock(q.lock_ptr);
 
 	if (!ret) {
@@ -1553,7 +1487,6 @@ static int futex_lock_pi(u32 __user *uad
 
 	/* Unqueue and drop the lock */
 	unqueue_me_pi(&q);
-	futex_unlock_mm(fshared);
 
 	return ret != -EINTR ? ret : -ERESTARTNOINTR;
 
@@ -1562,7 +1495,6 @@ static int futex_lock_pi(u32 __user *uad
 
  out_release_sem:
 	put_futex_key(fshared, &q.key);
-	futex_unlock_mm(fshared);
 	return ret;
 
  uaddr_faulted:
@@ -1584,8 +1516,6 @@ static int futex_lock_pi(u32 __user *uad
 		goto retry_unlocked;
 	}
 
-	futex_unlock_mm(fshared);
-
 	ret = get_user(uval, uaddr);
 	if (!ret && (uval != -EFAULT))
 		goto retry;
@@ -1615,10 +1545,6 @@ retry:
 	 */
 	if ((uval & FUTEX_TID_MASK) != task_pid_vnr(current))
 		return -EPERM;
-	/*
-	 * First take all the futex related locks:
-	 */
-	futex_lock_mm(fshared);
 
 	ret = get_futex_key(uaddr, fshared, &key);
 	if (unlikely(ret != 0))
@@ -1678,7 +1604,6 @@ out_unlock:
 	spin_unlock(&hb->lock);
 out:
 	put_futex_key(fshared, &key);
-	futex_unlock_mm(fshared);
 
 	return ret;
 
@@ -1702,8 +1627,6 @@ pi_faulted:
 		goto retry_unlocked;
 	}
 
-	futex_unlock_mm(fshared);
-
 	ret = get_user(uval, uaddr);
 	if (!ret && (uval != -EFAULT))
 		goto retry;
@@ -1797,12 +1720,10 @@ static int futex_fd(u32 __user *uaddr, i
 	q->pi_state = NULL;
 
 	fshared = &current->mm->mmap_sem;
-	down_read(fshared);
 	q->key = FUTEX_KEY_INIT;
 	err = get_futex_key(uaddr, fshared, &q->key);
 
 	if (unlikely(err != 0)) {
-		up_read(fshared);
 		kfree(q);
 		goto error;
 	}
@@ -1815,7 +1736,6 @@ static int futex_fd(u32 __user *uaddr, i
 
 	queue_me(q, ret, filp);
 	put_futex_key(fshared, &q->key);
-	up_read(fshared);
 
 	/* Now we map fd to filp, so userspace can access it */
 	fd_install(ret, filp);

--

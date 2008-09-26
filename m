Message-Id: <20080926173313.580404379@twins.programming.kicks-ass.net>
Date: Fri, 26 Sep 2008 19:32:23 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 4/4] futex: cleanup fshared
References: <20080926173219.885155151@twins.programming.kicks-ass.net>
Content-Disposition: inline; filename=futex-cleanup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

fshared doesn't need to be a rw_sem pointer anymore, so clean that up.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 kernel/futex.c |   48 +++++++++++++++++++-----------------------------
 1 file changed, 19 insertions(+), 29 deletions(-)

Index: linux-2.6/kernel/futex.c
===================================================================
--- linux-2.6.orig/kernel/futex.c
+++ linux-2.6/kernel/futex.c
@@ -200,8 +200,7 @@ static void drop_futex_key_refs(union fu
  * For other futexes, it points to &current->mm->mmap_sem and
  * caller must have taken the reader lock. but NOT any spinlocks.
  */
-static int get_futex_key(u32 __user *uaddr, struct rw_semaphore *fshared,
-			 union futex_key *key)
+static int get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key)
 {
 	unsigned long address = (unsigned long)uaddr;
 	struct mm_struct *mm = current->mm;
@@ -268,7 +267,7 @@ again:
 }
 
 static inline
-void put_futex_key(struct rw_semaphore *fshared, union futex_key *key)
+void put_futex_key(int fshared, union futex_key *key)
 {
 	drop_futex_key_refs(key);
 }
@@ -297,10 +296,8 @@ static int get_futex_value_locked(u32 *d
 
 /*
  * Fault handling.
- * if fshared is non NULL, current->mm->mmap_sem is already held
  */
-static int futex_handle_fault(unsigned long address,
-			      struct rw_semaphore *fshared, int attempt)
+static int futex_handle_fault(unsigned long address, int attempt)
 {
 	struct vm_area_struct * vma;
 	struct mm_struct *mm = current->mm;
@@ -687,8 +684,7 @@ double_lock_hb(struct futex_hash_bucket 
  * Wake up all waiters hashed on the physical page that is mapped
  * to this virtual address:
  */
-static int futex_wake(u32 __user *uaddr, struct rw_semaphore *fshared,
-		      int nr_wake, u32 bitset)
+static int futex_wake(u32 __user *uaddr, int fshared, int nr_wake, u32 bitset)
 {
 	struct futex_hash_bucket *hb;
 	struct futex_q *this, *next;
@@ -735,8 +731,7 @@ out:
  * to this virtual address:
  */
 static int
-futex_wake_op(u32 __user *uaddr1, struct rw_semaphore *fshared,
-	      u32 __user *uaddr2,
+futex_wake_op(u32 __user *uaddr1, int fshared, u32 __user *uaddr2,
 	      int nr_wake, int nr_wake2, int op)
 {
 	union futex_key key1 = FUTEX_KEY_INIT, key2 = FUTEX_KEY_INIT;
@@ -790,7 +785,7 @@ retry:
 		 */
 		if (attempt++) {
 			ret = futex_handle_fault((unsigned long)uaddr2,
-						 fshared, attempt);
+						 attempt);
 			if (ret)
 				goto out;
 			goto retry;
@@ -841,8 +836,7 @@ out:
  * Requeue all waiters hashed on one physical page to another
  * physical page.
  */
-static int futex_requeue(u32 __user *uaddr1, struct rw_semaphore *fshared,
-			 u32 __user *uaddr2,
+static int futex_requeue(u32 __user *uaddr1, int fshared, u32 __user *uaddr2,
 			 int nr_wake, int nr_requeue, u32 *cmpval)
 {
 	union futex_key key1 = FUTEX_KEY_INIT, key2 = FUTEX_KEY_INIT;
@@ -1048,8 +1042,7 @@ static void unqueue_me_pi(struct futex_q
  * private futexes.
  */
 static int fixup_pi_state_owner(u32 __user *uaddr, struct futex_q *q,
-				struct task_struct *newowner,
-				struct rw_semaphore *fshared)
+				struct task_struct *newowner, int fshared)
 {
 	u32 newtid = task_pid_vnr(newowner) | FUTEX_WAITERS;
 	struct futex_pi_state *pi_state = q->pi_state;
@@ -1128,7 +1121,7 @@ retry:
 handle_fault:
 	spin_unlock(q->lock_ptr);
 
-	ret = futex_handle_fault((unsigned long)uaddr, fshared, attempt++);
+	ret = futex_handle_fault((unsigned long)uaddr, attempt++);
 
 	spin_lock(q->lock_ptr);
 
@@ -1152,7 +1145,7 @@ handle_fault:
 
 static long futex_wait_restart(struct restart_block *restart);
 
-static int futex_wait(u32 __user *uaddr, struct rw_semaphore *fshared,
+static int futex_wait(u32 __user *uaddr, int fshared,
 		      u32 val, ktime_t *abs_time, u32 bitset)
 {
 	struct task_struct *curr = current;
@@ -1306,13 +1299,13 @@ static int futex_wait(u32 __user *uaddr,
 static long futex_wait_restart(struct restart_block *restart)
 {
 	u32 __user *uaddr = (u32 __user *)restart->futex.uaddr;
-	struct rw_semaphore *fshared = NULL;
+	int fshared = 0;
 	ktime_t t;
 
 	t.tv64 = restart->futex.time;
 	restart->fn = do_no_restart_syscall;
 	if (restart->futex.flags & FLAGS_SHARED)
-		fshared = &current->mm->mmap_sem;
+		fshared = 1;
 	return (long)futex_wait(uaddr, fshared, restart->futex.val, &t,
 				restart->futex.bitset);
 }
@@ -1324,7 +1317,7 @@ static long futex_wait_restart(struct re
  * if there are waiters then it will block, it does PI, etc. (Due to
  * races the kernel might see a 0 value of the futex too.)
  */
-static int futex_lock_pi(u32 __user *uaddr, struct rw_semaphore *fshared,
+static int futex_lock_pi(u32 __user *uaddr, int fshared,
 			 int detect, ktime_t *time, int trylock)
 {
 	struct hrtimer_sleeper timeout, *to = NULL;
@@ -1570,8 +1563,7 @@ static int futex_lock_pi(u32 __user *uad
 	queue_unlock(&q, hb);
 
 	if (attempt++) {
-		ret = futex_handle_fault((unsigned long)uaddr, fshared,
-					 attempt);
+		ret = futex_handle_fault((unsigned long)uaddr, attempt);
 		if (ret)
 			goto out_release_sem;
 		goto retry_unlocked;
@@ -1591,7 +1583,7 @@ static int futex_lock_pi(u32 __user *uad
  * This is the in-kernel slowpath: we look up the PI state (if any),
  * and do the rt-mutex unlock.
  */
-static int futex_unlock_pi(u32 __user *uaddr, struct rw_semaphore *fshared)
+static int futex_unlock_pi(u32 __user *uaddr, int fshared)
 {
 	struct futex_hash_bucket *hb;
 	struct futex_q *this, *next;
@@ -1682,8 +1674,7 @@ pi_faulted:
 	spin_unlock(&hb->lock);
 
 	if (attempt++) {
-		ret = futex_handle_fault((unsigned long)uaddr, fshared,
-					 attempt);
+		ret = futex_handle_fault((unsigned long)uaddr, attempt);
 		if (ret)
 			goto out;
 		uval = 0;
@@ -1815,8 +1806,7 @@ retry:
 		 * PI futexes happens in exit_pi_state():
 		 */
 		if (!pi && (uval & FUTEX_WAITERS))
-			futex_wake(uaddr, &curr->mm->mmap_sem, 1,
-				   FUTEX_BITSET_MATCH_ANY);
+			futex_wake(uaddr, 1, 1, FUTEX_BITSET_MATCH_ANY);
 	}
 	return 0;
 }
@@ -1912,10 +1902,10 @@ long do_futex(u32 __user *uaddr, int op,
 {
 	int ret = -ENOSYS;
 	int cmd = op & FUTEX_CMD_MASK;
-	struct rw_semaphore *fshared = NULL;
+	int fshared = 0;
 
 	if (!(op & FUTEX_PRIVATE_FLAG))
-		fshared = &current->mm->mmap_sem;
+		fshared = 1;
 
 	switch (cmd) {
 	case FUTEX_WAIT:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

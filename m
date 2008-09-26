Message-Id: <20080926173313.417047063@twins.programming.kicks-ass.net>
Date: Fri, 26 Sep 2008 19:32:20 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 1/4] futex: rely on get_user_pages() for shared futexes
References: <20080926173219.885155151@twins.programming.kicks-ass.net>
Content-Disposition: inline; filename=futex-gup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On the way of getting rid of the mmap_sem requirement for shared futexes,
start by relying on get_user_pages().

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/futex.h |    2 
 kernel/futex.c        |  162 ++++++++++++++++++++++++--------------------------
 2 files changed, 82 insertions(+), 82 deletions(-)

Index: linux-2.6/kernel/futex.c
===================================================================
--- linux-2.6.orig/kernel/futex.c
+++ linux-2.6/kernel/futex.c
@@ -161,6 +161,45 @@ static inline int match_futex(union fute
 		&& key1->both.offset == key2->both.offset);
 }
 
+/*
+ * Take a reference to the resource addressed by a key.
+ * Can be called while holding spinlocks.
+ *
+ */
+static void get_futex_key_refs(union futex_key *key)
+{
+	if (!key->both.ptr)
+		return;
+
+	switch (key->both.offset & (FUT_OFF_INODE|FUT_OFF_MMSHARED)) {
+	case FUT_OFF_INODE:
+		atomic_inc(&key->shared.inode->i_count);
+		break;
+	case FUT_OFF_MMSHARED:
+		atomic_inc(&key->private.mm->mm_count);
+		break;
+	}
+}
+
+/*
+ * Drop a reference to the resource addressed by a key.
+ * The hash bucket spinlock must not be held.
+ */
+static void drop_futex_key_refs(union futex_key *key)
+{
+	if (!key->both.ptr)
+		return;
+
+	switch (key->both.offset & (FUT_OFF_INODE|FUT_OFF_MMSHARED)) {
+	case FUT_OFF_INODE:
+		iput(key->shared.inode);
+		break;
+	case FUT_OFF_MMSHARED:
+		mmdrop(key->private.mm);
+		break;
+	}
+}
+
 /**
  * get_futex_key - Get parameters which are the keys for a futex.
  * @uaddr: virtual address of the futex
@@ -184,7 +223,6 @@ static int get_futex_key(u32 __user *uad
 {
 	unsigned long address = (unsigned long)uaddr;
 	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
 	struct page *page;
 	int err;
 
@@ -210,98 +248,47 @@ static int get_futex_key(u32 __user *uad
 		key->private.address = address;
 		return 0;
 	}
-	/*
-	 * The futex is hashed differently depending on whether
-	 * it's in a shared or private mapping.  So check vma first.
-	 */
-	vma = find_extend_vma(mm, address);
-	if (unlikely(!vma))
-		return -EFAULT;
 
-	/*
-	 * Permissions.
-	 */
-	if (unlikely((vma->vm_flags & (VM_IO|VM_READ)) != VM_READ))
-		return (vma->vm_flags & VM_IO) ? -EPERM : -EACCES;
+again:
+	err = get_user_pages(current, mm, address, 1, 0, 0, &page, NULL);
+	if (err < 0)
+		return err;
+
+	lock_page(page);
+	if (!page->mapping) {
+		unlock_page(page);
+		put_page(page);
+		goto again;
+	}
 
 	/*
 	 * Private mappings are handled in a simple way.
 	 *
 	 * NOTE: When userspace waits on a MAP_SHARED mapping, even if
 	 * it's a read-only handle, it's expected that futexes attach to
-	 * the object not the particular process.  Therefore we use
-	 * VM_MAYSHARE here, not VM_SHARED which is restricted to shared
-	 * mappings of _writable_ handles.
+	 * the object not the particular process.
 	 */
-	if (likely(!(vma->vm_flags & VM_MAYSHARE))) {
-		key->both.offset |= FUT_OFF_MMSHARED; /* reference taken on mm */
+	if (PageAnon(page)) {
+		key->both.offset |= FUT_OFF_MMSHARED; /* ref taken on mm */
 		key->private.mm = mm;
 		key->private.address = address;
-		return 0;
-	}
-
-	/*
-	 * Linear file mappings are also simple.
-	 */
-	key->shared.inode = vma->vm_file->f_path.dentry->d_inode;
-	key->both.offset |= FUT_OFF_INODE; /* inode-based key. */
-	if (likely(!(vma->vm_flags & VM_NONLINEAR))) {
-		key->shared.pgoff = (((address - vma->vm_start) >> PAGE_SHIFT)
-				     + vma->vm_pgoff);
-		return 0;
+	} else {
+		key->both.offset |= FUT_OFF_INODE; /* inode-based key */
+		key->shared.inode = page->mapping->host;
+		key->shared.pgoff = page->index;
 	}
 
-	/*
-	 * We could walk the page table to read the non-linear
-	 * pte, and get the page index without fetching the page
-	 * from swap.  But that's a lot of code to duplicate here
-	 * for a rare case, so we simply fetch the page.
-	 */
-	err = get_user_pages(current, mm, address, 1, 0, 0, &page, NULL);
-	if (err >= 0) {
-		key->shared.pgoff =
-			page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
-		put_page(page);
-		return 0;
-	}
-	return err;
-}
+	get_futex_key_refs(key);
 
-/*
- * Take a reference to the resource addressed by a key.
- * Can be called while holding spinlocks.
- *
- */
-static void get_futex_key_refs(union futex_key *key)
-{
-	if (key->both.ptr == NULL)
-		return;
-	switch (key->both.offset & (FUT_OFF_INODE|FUT_OFF_MMSHARED)) {
-		case FUT_OFF_INODE:
-			atomic_inc(&key->shared.inode->i_count);
-			break;
-		case FUT_OFF_MMSHARED:
-			atomic_inc(&key->private.mm->mm_count);
-			break;
-	}
+	unlock_page(page);
+	put_page(page);
+	return 0;
 }
 
-/*
- * Drop a reference to the resource addressed by a key.
- * The hash bucket spinlock must not be held.
- */
-static void drop_futex_key_refs(union futex_key *key)
+static inline
+void put_futex_key(struct rw_semaphore *fshared, union futex_key *key)
 {
-	if (!key->both.ptr)
-		return;
-	switch (key->both.offset & (FUT_OFF_INODE|FUT_OFF_MMSHARED)) {
-		case FUT_OFF_INODE:
-			iput(key->shared.inode);
-			break;
-		case FUT_OFF_MMSHARED:
-			mmdrop(key->private.mm);
-			break;
-	}
+	drop_futex_key_refs(key);
 }
 
 static u32 cmpxchg_futex_value_locked(u32 __user *uaddr, u32 uval, u32 newval)
@@ -385,6 +372,7 @@ static int refill_pi_state_cache(void)
 	/* pi_mutex gets initialized later */
 	pi_state->owner = NULL;
 	atomic_set(&pi_state->refcount, 1);
+	pi_state->key = FUTEX_KEY_INIT;
 
 	current->pi_state_cache = pi_state;
 
@@ -462,7 +450,7 @@ void exit_pi_state_list(struct task_stru
 	struct list_head *next, *head = &curr->pi_state_list;
 	struct futex_pi_state *pi_state;
 	struct futex_hash_bucket *hb;
-	union futex_key key;
+	union futex_key key = FUTEX_KEY_INIT;
 
 	if (!futex_cmpxchg_enabled)
 		return;
@@ -725,7 +713,7 @@ static int futex_wake(u32 __user *uaddr,
 	struct futex_hash_bucket *hb;
 	struct futex_q *this, *next;
 	struct plist_head *head;
-	union futex_key key;
+	union futex_key key = FUTEX_KEY_INIT;
 	int ret;
 
 	if (!bitset)
@@ -760,6 +748,7 @@ static int futex_wake(u32 __user *uaddr,
 
 	spin_unlock(&hb->lock);
 out:
+	put_futex_key(fshared, &key);
 	futex_unlock_mm(fshared);
 	return ret;
 }
@@ -773,7 +762,7 @@ futex_wake_op(u32 __user *uaddr1, struct
 	      u32 __user *uaddr2,
 	      int nr_wake, int nr_wake2, int op)
 {
-	union futex_key key1, key2;
+	union futex_key key1 = FUTEX_KEY_INIT, key2 = FUTEX_KEY_INIT;
 	struct futex_hash_bucket *hb1, *hb2;
 	struct plist_head *head;
 	struct futex_q *this, *next;
@@ -873,6 +862,8 @@ retry:
 	if (hb1 != hb2)
 		spin_unlock(&hb2->lock);
 out:
+	put_futex_key(fshared, &key2);
+	put_futex_key(fshared, &key1);
 	futex_unlock_mm(fshared);
 
 	return ret;
@@ -886,7 +877,7 @@ static int futex_requeue(u32 __user *uad
 			 u32 __user *uaddr2,
 			 int nr_wake, int nr_requeue, u32 *cmpval)
 {
-	union futex_key key1, key2;
+	union futex_key key1 = FUTEX_KEY_INIT, key2 = FUTEX_KEY_INIT;
 	struct futex_hash_bucket *hb1, *hb2;
 	struct plist_head *head1;
 	struct futex_q *this, *next;
@@ -974,6 +965,8 @@ out_unlock:
 		drop_futex_key_refs(&key1);
 
 out:
+	put_futex_key(fshared, &key2);
+	put_futex_key(fshared, &key1);
 	futex_unlock_mm(fshared);
 	return ret;
 }
@@ -1220,6 +1213,7 @@ static int futex_wait(u32 __user *uaddr,
  retry:
 	futex_lock_mm(fshared);
 
+	q.key = FUTEX_KEY_INIT;
 	ret = get_futex_key(uaddr, fshared, &q.key);
 	if (unlikely(ret != 0))
 		goto out_release_sem;
@@ -1359,6 +1353,7 @@ static int futex_wait(u32 __user *uaddr,
 	queue_unlock(&q, hb);
 
  out_release_sem:
+	put_futex_key(fshared, &q.key);
 	futex_unlock_mm(fshared);
 	return ret;
 }
@@ -1410,6 +1405,7 @@ static int futex_lock_pi(u32 __user *uad
  retry:
 	futex_lock_mm(fshared);
 
+	q.key = FUTEX_KEY_INIT;
 	ret = get_futex_key(uaddr, fshared, &q.key);
 	if (unlikely(ret != 0))
 		goto out_release_sem;
@@ -1624,6 +1620,7 @@ static int futex_lock_pi(u32 __user *uad
 	queue_unlock(&q, hb);
 
  out_release_sem:
+	put_futex_key(fshared, &q.key);
 	futex_unlock_mm(fshared);
 	if (to)
 		destroy_hrtimer_on_stack(&to->timer);
@@ -1670,7 +1667,7 @@ static int futex_unlock_pi(u32 __user *u
 	struct futex_q *this, *next;
 	u32 uval;
 	struct plist_head *head;
-	union futex_key key;
+	union futex_key key = FUTEX_KEY_INIT;
 	int ret, attempt = 0;
 
 retry:
@@ -1743,6 +1740,7 @@ retry_unlocked:
 out_unlock:
 	spin_unlock(&hb->lock);
 out:
+	put_futex_key(fshared, &key);
 	futex_unlock_mm(fshared);
 
 	return ret;
Index: linux-2.6/include/linux/futex.h
===================================================================
--- linux-2.6.orig/include/linux/futex.h
+++ linux-2.6/include/linux/futex.h
@@ -164,6 +164,8 @@ union futex_key {
 	} both;
 };
 
+#define FUTEX_KEY_INIT (union futex_key) { .both = { .ptr = NULL } }
+
 #ifdef CONFIG_FUTEX
 extern void exit_robust_list(struct task_struct *curr);
 extern void exit_pi_state_list(struct task_struct *curr);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

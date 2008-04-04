From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC PATCH 1/2] futex: rely on get_user_pages() for shared futexes
Date: Fri, 04 Apr 2008 21:33:33 +0200
Message-ID: <20080404193817.574188000@chello.nl>
References: <20080404193332.348493000@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760323AbYDDTjF@vger.kernel.org>
Content-Disposition: inline; filename=futex-gup.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Nick Piggin <nickpiggin@yahoo.com.au>, Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On the way of getting rid of the mmap_sem requirement for shared futexes,
start by relying on get_user_pages().

This requires we get the page associated with the key, and put the page when
we're done with it.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/futex.h |   12 ++--
 kernel/futex.c        |  122 ++++++++++++++++++++------------------------------
 2 files changed, 55 insertions(+), 79 deletions(-)

Index: linux-2.6/include/linux/futex.h
===================================================================
--- linux-2.6.orig/include/linux/futex.h
+++ linux-2.6/include/linux/futex.h
@@ -124,18 +124,14 @@ handle_futex_death(u32 __user *uaddr, st
  *  00 : Private process futex (PTHREAD_PROCESS_PRIVATE)
  *       (no reference on an inode or mm)
  *  01 : Shared futex (PTHREAD_PROCESS_SHARED)
- *	mapped on a file (reference on the underlying inode)
- *  10 : Shared futex (PTHREAD_PROCESS_SHARED)
- *       (but private mapping on an mm, and reference taken on it)
-*/
+ */
 
-#define FUT_OFF_INODE    1 /* We set bit 0 if key has a reference on inode */
-#define FUT_OFF_MMSHARED 2 /* We set bit 1 if key has a reference on mm */
+#define FUT_OFF_PAGE     1
 
 union futex_key {
 	struct {
 		unsigned long pgoff;
-		struct inode *inode;
+		struct page *page;
 		int offset;
 	} shared;
 	struct {
@@ -150,6 +146,8 @@ union futex_key {
 	} both;
 };
 
+#define FUTEX_KEY_INIT (union futex_key) { .both = { .ptr = NULL } }
+
 #ifdef CONFIG_FUTEX
 extern void exit_robust_list(struct task_struct *curr);
 extern void exit_pi_state_list(struct task_struct *curr);
Index: linux-2.6/kernel/futex.c
===================================================================
--- linux-2.6.orig/kernel/futex.c
+++ linux-2.6/kernel/futex.c
@@ -190,7 +190,6 @@ static int get_futex_key(u32 __user *uad
 {
 	unsigned long address = (unsigned long)uaddr;
 	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
 	struct page *page;
 	int err;
 
@@ -202,6 +201,9 @@ static int get_futex_key(u32 __user *uad
 		return -EINVAL;
 	address -= key->both.offset;
 
+	if (unlikely(!access_ok(VERIFY_WRITE, uaddr, sizeof(u32))))
+		return -EFAULT;
+
 	/*
 	 * PROCESS_PRIVATE futexes are fast.
 	 * As the mm cannot disappear under us and the 'key' only needs
@@ -210,67 +212,37 @@ static int get_futex_key(u32 __user *uad
 	 *        but access_ok() should be faster than find_vma()
 	 */
 	if (!fshared) {
-		if (unlikely(!access_ok(VERIFY_WRITE, uaddr, sizeof(u32))))
-			return -EFAULT;
 		key->private.mm = mm;
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
+	err = get_user_pages(current, mm, address, 1, 0, 0, &page, NULL);
+	if (err < 0)
+		return err;
+
+	key->shared.page = page;
+	key->both.offset |= FUT_OFF_PAGE;
 
 	/*
-	 * Private mappings are handled in a simple way.
-	 *
-	 * NOTE: When userspace waits on a MAP_SHARED mapping, even if
-	 * it's a read-only handle, it's expected that futexes attach to
-	 * the object not the particular process.  Therefore we use
-	 * VM_MAYSHARE here, not VM_SHARED which is restricted to shared
-	 * mappings of _writable_ handles.
+	 * doesn't really matter anyway, as we'll end up finding the
+	 * same page again
 	 */
-	if (likely(!(vma->vm_flags & VM_MAYSHARE))) {
-		key->both.offset |= FUT_OFF_MMSHARED; /* reference taken on mm */
-		key->private.mm = mm;
+	if (PageAnon(page))
 		key->private.address = address;
-		return 0;
-	}
+	else
+		key->shared.pgoff = page->index;
 
-	/*
-	 * Linear file mappings are also simple.
-	 */
-	key->shared.inode = vma->vm_file->f_path.dentry->d_inode;
-	key->both.offset |= FUT_OFF_INODE; /* inode-based key. */
-	if (likely(!(vma->vm_flags & VM_NONLINEAR))) {
-		key->shared.pgoff = (((address - vma->vm_start) >> PAGE_SHIFT)
-				     + vma->vm_pgoff);
-		return 0;
-	}
+	return 0;
+}
 
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
+static void put_futex_key(struct rw_semaphore *fshared, union futex_key *key)
+{
+	if (!key->both.ptr)
+		return;
+
+	if (key->both.offset & FUT_OFF_PAGE)
+		put_page(key->shared.page);
 }
 
 /*
@@ -280,16 +252,13 @@ static int get_futex_key(u32 __user *uad
  */
 static void get_futex_key_refs(union futex_key *key)
 {
-	if (key->both.ptr == 0)
+	if (!key->both.ptr)
 		return;
-	switch (key->both.offset & (FUT_OFF_INODE|FUT_OFF_MMSHARED)) {
-		case FUT_OFF_INODE:
-			atomic_inc(&key->shared.inode->i_count);
-			break;
-		case FUT_OFF_MMSHARED:
-			atomic_inc(&key->private.mm->mm_count);
-			break;
-	}
+
+	if (key->both.offset & FUT_OFF_PAGE)
+		get_page(key->shared.page);
+	else
+		atomic_inc(&key->private.mm->mm_count);
 }
 
 /*
@@ -300,14 +269,11 @@ static void drop_futex_key_refs(union fu
 {
 	if (!key->both.ptr)
 		return;
-	switch (key->both.offset & (FUT_OFF_INODE|FUT_OFF_MMSHARED)) {
-		case FUT_OFF_INODE:
-			iput(key->shared.inode);
-			break;
-		case FUT_OFF_MMSHARED:
-			mmdrop(key->private.mm);
-			break;
-	}
+
+	if (key->both.offset & FUT_OFF_PAGE)
+		put_page(key->shared.page);
+	else
+		mmdrop(key->private.mm);
 }
 
 static u32 cmpxchg_futex_value_locked(u32 __user *uaddr, u32 uval, u32 newval)
@@ -733,7 +699,7 @@ static int futex_wake(u32 __user *uaddr,
 	struct futex_hash_bucket *hb;
 	struct futex_q *this, *next;
 	struct plist_head *head;
-	union futex_key key;
+	union futex_key key = FUTEX_KEY_INIT;
 	int ret;
 
 	futex_lock_mm(fshared);
@@ -760,6 +726,7 @@ static int futex_wake(u32 __user *uaddr,
 
 	spin_unlock(&hb->lock);
 out:
+	put_futex_key(fshared, &key);
 	futex_unlock_mm(fshared);
 	return ret;
 }
@@ -773,7 +740,7 @@ futex_wake_op(u32 __user *uaddr1, struct
 	      u32 __user *uaddr2,
 	      int nr_wake, int nr_wake2, int op)
 {
-	union futex_key key1, key2;
+	union futex_key key1 = FUTEX_KEY_INIT, key2 = FUTEX_KEY_INIT;
 	struct futex_hash_bucket *hb1, *hb2;
 	struct plist_head *head;
 	struct futex_q *this, *next;
@@ -873,6 +840,8 @@ retry:
 	if (hb1 != hb2)
 		spin_unlock(&hb2->lock);
 out:
+	put_futex_key(fshared, &key2);
+	put_futex_key(fshared, &key1);
 	futex_unlock_mm(fshared);
 
 	return ret;
@@ -886,7 +855,7 @@ static int futex_requeue(u32 __user *uad
 			 u32 __user *uaddr2,
 			 int nr_wake, int nr_requeue, u32 *cmpval)
 {
-	union futex_key key1, key2;
+	union futex_key key1 = FUTEX_KEY_INIT, key2 = FUTEX_KEY_INIT;
 	struct futex_hash_bucket *hb1, *hb2;
 	struct plist_head *head1;
 	struct futex_q *this, *next;
@@ -978,6 +947,8 @@ out_unlock:
 		drop_futex_key_refs(&key1);
 
 out:
+	put_futex_key(fshared, &key2);
+	put_futex_key(fshared, &key1);
 	futex_unlock_mm(fshared);
 	return ret;
 }
@@ -1185,6 +1156,7 @@ static int futex_wait(u32 __user *uaddr,
  retry:
 	futex_lock_mm(fshared);
 
+	q.key = FUTEX_KEY_INIT;
 	ret = get_futex_key(uaddr, fshared, &q.key);
 	if (unlikely(ret != 0))
 		goto out_release_sem;
@@ -1324,6 +1296,7 @@ static int futex_wait(u32 __user *uaddr,
 	queue_unlock(&q, hb);
 
  out_release_sem:
+	put_futex_key(fshared, &q.key);
 	futex_unlock_mm(fshared);
 	return ret;
 }
@@ -1373,6 +1346,7 @@ static int futex_lock_pi(u32 __user *uad
  retry:
 	futex_lock_mm(fshared);
 
+	q.key = FUTEX_KEY_INIT;
 	ret = get_futex_key(uaddr, fshared, &q.key);
 	if (unlikely(ret != 0))
 		goto out_release_sem;
@@ -1587,6 +1561,7 @@ static int futex_lock_pi(u32 __user *uad
 	queue_unlock(&q, hb);
 
  out_release_sem:
+	put_futex_key(fshared, &q.key);
 	futex_unlock_mm(fshared);
 	return ret;
 
@@ -1629,7 +1604,7 @@ static int futex_unlock_pi(u32 __user *u
 	struct futex_q *this, *next;
 	u32 uval;
 	struct plist_head *head;
-	union futex_key key;
+	union futex_key key = FUTEX_KEY_INIT;
 	int ret, attempt = 0;
 
 retry:
@@ -1702,6 +1677,7 @@ retry_unlocked:
 out_unlock:
 	spin_unlock(&hb->lock);
 out:
+	put_futex_key(fshared, &key);
 	futex_unlock_mm(fshared);
 
 	return ret;
@@ -1822,6 +1798,7 @@ static int futex_fd(u32 __user *uaddr, i
 
 	fshared = &current->mm->mmap_sem;
 	down_read(fshared);
+	q->key = FUTEX_KEY_INIT;
 	err = get_futex_key(uaddr, fshared, &q->key);
 
 	if (unlikely(err != 0)) {
@@ -1837,6 +1814,7 @@ static int futex_fd(u32 __user *uaddr, i
 	filp->private_data = q;
 
 	queue_me(q, ret, filp);
+	put_futex_key(fshared, &q->key);
 	up_read(fshared);
 
 	/* Now we map fd to filp, so userspace can access it */

--

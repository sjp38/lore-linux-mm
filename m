Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 2 of 3] mm_take_all_locks
Message-Id: <167f154fa536c2c70c9d.1214440018@duo.random>
In-Reply-To: <patchbomb.1214440016@duo.random>
Date: Thu, 26 Jun 2008 02:26:58 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
From: Andrea Arcangeli <andrea@qumranet.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm@vger.kernel.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Izik Eidus <izike@qumranet.com>Anthony Liguori <aliguori@us.ibm.com>, Rik van Riel <riel@redhat.com>
Cc: andrea@qumranet.com
List-ID: <linux-mm.kvack.org>

mm_take_all_locks holds off reclaim from an entire mm_struct. This allows mmu
notifiers to register into the mm at any time with the guarantee that no mmu
operation is in progress on the mm.

This operation locks against the VM for all pte/vma/mm related operations that
could ever happen on a certain mm. This includes vmtruncate, try_to_unmap, and
all page faults.

The caller must take the mmap_sem in write mode before calling
mm_take_all_locks(). The caller isn't allowed to release the mmap_sem until
mm_drop_all_locks() returns.

mmap_sem in write mode is required in order to block all operations that could
modify pagetables and free pages without need of altering the vma layout (for
example populate_range() with nonlinear vmas). It's also needed in write mode
to avoid new anon_vmas to be associated with existing vmas.

A single task can't take more than one mm_take_all_locks() in a row or it would
deadlock.

mm_take_all_locks() and mm_drop_all_locks are expensive operations
that may have to take thousand of locks.

mm_take_all_locks() can fail if it's interrupted by signals.

When mmu_notifier_register returns, we must be sure that the driver is notified
if some task is in the middle of a vmtruncate for the 'mm' where the mmu
notifier was registered (mmu_notifier_invalidate_range_start/end is run around
the vmtruncation but mmu_notifier_register can run after
mmu_notifier_invalidate_range_start and before
mmu_notifier_invalidate_range_end). Same problem for rmap paths. And we've to
remove page pinning to avoid replicating the tlb_gather logic inside KVM (and
GRU doesn't work well with page pinning regardless of needing tlb_gather), so
without mm_take_all_locks when vmtruncate frees the page, kvm would have no way
to notice that it mapped into sptes a page that is going into the freelist
without a chance of any further mmu_notifier notification.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
---

diff -r 5e8c41d283cc -r 167f154fa536 include/linux/mm.h
--- a/include/linux/mm.h	Wed Jun 25 03:34:11 2008 +0200
+++ b/include/linux/mm.h	Wed Jun 25 03:34:14 2008 +0200
@@ -1068,6 +1068,9 @@ extern struct vm_area_struct *copy_vma(s
 	unsigned long addr, unsigned long len, pgoff_t pgoff);
 extern void exit_mmap(struct mm_struct *);
 
+extern int mm_take_all_locks(struct mm_struct *mm);
+extern void mm_drop_all_locks(struct mm_struct *mm);
+
 #ifdef CONFIG_PROC_FS
 /* From fs/proc/base.c. callers must _not_ hold the mm's exe_file_lock */
 extern void added_exe_file_vma(struct mm_struct *mm);
diff -r 5e8c41d283cc -r 167f154fa536 include/linux/pagemap.h
--- a/include/linux/pagemap.h	Wed Jun 25 03:34:11 2008 +0200
+++ b/include/linux/pagemap.h	Wed Jun 25 03:34:14 2008 +0200
@@ -19,6 +19,7 @@
  */
 #define	AS_EIO		(__GFP_BITS_SHIFT + 0)	/* IO error on async write */
 #define AS_ENOSPC	(__GFP_BITS_SHIFT + 1)	/* ENOSPC on async write */
+#define AS_MM_ALL_LOCKS	(__GFP_BITS_SHIFT + 2)	/* under mm_take_all_locks() */
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
 {
diff -r 5e8c41d283cc -r 167f154fa536 include/linux/rmap.h
--- a/include/linux/rmap.h	Wed Jun 25 03:34:11 2008 +0200
+++ b/include/linux/rmap.h	Wed Jun 25 03:34:14 2008 +0200
@@ -26,6 +26,14 @@
  */
 struct anon_vma {
 	spinlock_t lock;	/* Serialize access to vma list */
+	/*
+	 * NOTE: the LSB of the head.next is set by
+	 * mm_take_all_locks() _after_ taking the above lock. So the
+	 * head must only be read/written after taking the above lock
+	 * to be sure to see a valid next pointer. The LSB bit itself
+	 * is serialized by a system wide lock only visible to
+	 * mm_take_all_locks() (mm_all_locks_mutex).
+	 */
 	struct list_head head;	/* List of private "related" vmas */
 };
 
diff -r 5e8c41d283cc -r 167f154fa536 mm/mmap.c
--- a/mm/mmap.c	Wed Jun 25 03:34:11 2008 +0200
+++ b/mm/mmap.c	Wed Jun 25 03:34:14 2008 +0200
@@ -2261,3 +2261,161 @@ int install_special_mapping(struct mm_st
 
 	return 0;
 }
+
+static DEFINE_MUTEX(mm_all_locks_mutex);
+
+static void vm_lock_anon_vma(struct anon_vma *anon_vma)
+{
+	if (!test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+		/*
+		 * The LSB of head.next can't change from under us
+		 * because we hold the mm_all_locks_mutex.
+		 */
+		spin_lock(&anon_vma->lock);
+		/*
+		 * We can safely modify head.next after taking the
+		 * anon_vma->lock. If some other vma in this mm shares
+		 * the same anon_vma we won't take it again.
+		 *
+		 * No need of atomic instructions here, head.next
+		 * can't change from under us thanks to the
+		 * anon_vma->lock.
+		 */
+		if (__test_and_set_bit(0, (unsigned long *)
+				       &anon_vma->head.next))
+			BUG();
+	}
+}
+
+static void vm_lock_mapping(struct address_space *mapping)
+{
+	if (!test_bit(AS_MM_ALL_LOCKS, &mapping->flags)) {
+		/*
+		 * AS_MM_ALL_LOCKS can't change from under us because
+		 * we hold the mm_all_locks_mutex.
+		 *
+		 * Operations on ->flags have to be atomic because
+		 * even if AS_MM_ALL_LOCKS is stable thanks to the
+		 * mm_all_locks_mutex, there may be other cpus
+		 * changing other bitflags in parallel to us.
+		 */
+		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
+			BUG();
+		spin_lock(&mapping->i_mmap_lock);
+	}
+}
+
+/*
+ * This operation locks against the VM for all pte/vma/mm related
+ * operations that could ever happen on a certain mm. This includes
+ * vmtruncate, try_to_unmap, and all page faults.
+ *
+ * The caller must take the mmap_sem in write mode before calling
+ * mm_take_all_locks(). The caller isn't allowed to release the
+ * mmap_sem until mm_drop_all_locks() returns.
+ *
+ * mmap_sem in write mode is required in order to block all operations
+ * that could modify pagetables and free pages without need of
+ * altering the vma layout (for example populate_range() with
+ * nonlinear vmas). It's also needed in write mode to avoid new
+ * anon_vmas to be associated with existing vmas.
+ *
+ * A single task can't take more than one mm_take_all_locks() in a row
+ * or it would deadlock.
+ *
+ * The LSB in anon_vma->head.next and the AS_MM_ALL_LOCKS bitflag in
+ * mapping->flags avoid to take the same lock twice, if more than one
+ * vma in this mm is backed by the same anon_vma or address_space.
+ *
+ * We can take all the locks in random order because the VM code
+ * taking i_mmap_lock or anon_vma->lock outside the mmap_sem never
+ * takes more than one of them in a row. Secondly we're protected
+ * against a concurrent mm_take_all_locks() by the mm_all_locks_mutex.
+ *
+ * mm_take_all_locks() and mm_drop_all_locks are expensive operations
+ * that may have to take thousand of locks.
+ *
+ * mm_take_all_locks() can fail if it's interrupted by signals.
+ */
+int mm_take_all_locks(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+	int ret = -EINTR;
+
+	BUG_ON(down_read_trylock(&mm->mmap_sem));
+
+	mutex_lock(&mm_all_locks_mutex);
+
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (signal_pending(current))
+			goto out_unlock;
+                if (vma->anon_vma)
+                        vm_lock_anon_vma(vma->anon_vma);
+                if (vma->vm_file && vma->vm_file->f_mapping)
+                        vm_lock_mapping(vma->vm_file->f_mapping);
+	}
+	ret = 0;
+
+out_unlock:
+	if (ret)
+		mm_drop_all_locks(mm);
+
+	return ret;
+}
+
+static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
+{
+	if (test_bit(0, (unsigned long *) &anon_vma->head.next)) {
+		/*
+		 * The LSB of head.next can't change to 0 from under
+		 * us because we hold the mm_all_locks_mutex.
+		 *
+		 * We must however clear the bitflag before unlocking
+		 * the vma so the users using the anon_vma->head will
+		 * never see our bitflag.
+		 *
+		 * No need of atomic instructions here, head.next
+		 * can't change from under us until we release the
+		 * anon_vma->lock.
+		 */
+		if (!__test_and_clear_bit(0, (unsigned long *)
+					  &anon_vma->head.next))
+			BUG();
+		spin_unlock(&anon_vma->lock);
+	}
+}
+
+static void vm_unlock_mapping(struct address_space *mapping)
+{
+	if (test_bit(AS_MM_ALL_LOCKS, &mapping->flags)) {
+		/*
+		 * AS_MM_ALL_LOCKS can't change to 0 from under us
+		 * because we hold the mm_all_locks_mutex.
+		 */
+		spin_unlock(&mapping->i_mmap_lock);
+		if (!test_and_clear_bit(AS_MM_ALL_LOCKS,
+					&mapping->flags))
+			BUG();
+	}
+}
+
+/*
+ * The mmap_sem cannot be released by the caller until
+ * mm_drop_all_locks() returns.
+ */
+void mm_drop_all_locks(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+
+	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
+
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (vma->anon_vma)
+			vm_unlock_anon_vma(vma->anon_vma);
+		if (vma->vm_file && vma->vm_file->f_mapping)
+			vm_unlock_mapping(vma->vm_file->f_mapping);
+	}
+
+	mutex_unlock(&mm_all_locks_mutex);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

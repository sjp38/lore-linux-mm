Date: Tue, 6 May 2008 19:53:57 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: mmu notifier v15 -> v16 diff
Message-ID: <20080506175357.GB12593@duo.random>
References: <patchbomb.1209740703@duo.random> <1489529e7b53d3f2dab8.1209740704@duo.random> <20080505162113.GA18761@sgi.com> <20080505171434.GF8470@duo.random> <20080505172506.GA9247@sgi.com> <20080505183405.GI8470@duo.random> <20080505194625.GA17734@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080505194625.GA17734@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello everyone,

This is to allow GRU code to call __mmu_notifier_register inside the
mmap_sem (write mode is required as documented in the patch).

It also removes the requirement to implement ->release as it's not
guaranteed all users will really need it.

I didn't integrate the search function as we can sort that out after
2.6.26 is out and it wasn't entirely obvious it's really needed, as
the driver should be able to track if a mmu notifier is registered in
the container.

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -29,10 +29,25 @@ struct mmu_notifier_ops {
 	/*
 	 * Called either by mmu_notifier_unregister or when the mm is
 	 * being destroyed by exit_mmap, always before all pages are
-	 * freed. It's mandatory to implement this method. This can
-	 * run concurrently with other mmu notifier methods and it
+	 * freed. This can run concurrently with other mmu notifier
+	 * methods (the ones invoked outside the mm context) and it
 	 * should tear down all secondary mmu mappings and freeze the
-	 * secondary mmu.
+	 * secondary mmu. If this method isn't implemented you've to
+	 * be sure that nothing could possibly write to the pages
+	 * through the secondary mmu by the time the last thread with
+	 * tsk->mm == mm exits.
+	 *
+	 * As side note: the pages freed after ->release returns could
+	 * be immediately reallocated by the gart at an alias physical
+	 * address with a different cache model, so if ->release isn't
+	 * implemented because all _software_ driven memory accesses
+	 * through the secondary mmu are terminated by the time the
+	 * last thread of this mm quits, you've also to be sure that
+	 * speculative _hardware_ operations can't allocate dirty
+	 * cachelines in the cpu that could not be snooped and made
+	 * coherent with the other read and write operations happening
+	 * through the gart alias address, so leading to memory
+	 * corruption.
 	 */
 	void (*release)(struct mmu_notifier *mn,
 			struct mm_struct *mm);
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2340,13 +2340,20 @@ static inline void __mm_unlock(spinlock_
 /*
  * This operation locks against the VM for all pte/vma/mm related
  * operations that could ever happen on a certain mm. This includes
- * vmtruncate, try_to_unmap, and all page faults. The holder
- * must not hold any mm related lock. A single task can't take more
- * than one mm_lock in a row or it would deadlock.
+ * vmtruncate, try_to_unmap, and all page faults.
  *
- * The mmap_sem must be taken in write mode to block all operations
- * that could modify pagetables and free pages without altering the
- * vma layout (for example populate_range() with nonlinear vmas).
+ * The caller must take the mmap_sem in read or write mode before
+ * calling mm_lock(). The caller isn't allowed to release the mmap_sem
+ * until mm_unlock() returns.
+ *
+ * While mm_lock() itself won't strictly require the mmap_sem in write
+ * mode to be safe, in order to block all operations that could modify
+ * pagetables and free pages without need of altering the vma layout
+ * (for example populate_range() with nonlinear vmas) the mmap_sem
+ * must be taken in write mode by the caller.
+ *
+ * A single task can't take more than one mm_lock in a row or it would
+ * deadlock.
  *
  * The sorting is needed to avoid lock inversion deadlocks if two
  * tasks run mm_lock at the same time on different mm that happen to
@@ -2377,17 +2384,13 @@ int mm_lock(struct mm_struct *mm, struct
 {
 	spinlock_t **anon_vma_locks, **i_mmap_locks;
 
-	down_write(&mm->mmap_sem);
 	if (mm->map_count) {
 		anon_vma_locks = vmalloc(sizeof(spinlock_t *) * mm->map_count);
-		if (unlikely(!anon_vma_locks)) {
-			up_write(&mm->mmap_sem);
+		if (unlikely(!anon_vma_locks))
 			return -ENOMEM;
-		}
 
 		i_mmap_locks = vmalloc(sizeof(spinlock_t *) * mm->map_count);
 		if (unlikely(!i_mmap_locks)) {
-			up_write(&mm->mmap_sem);
 			vfree(anon_vma_locks);
 			return -ENOMEM;
 		}
@@ -2426,10 +2429,12 @@ static void mm_unlock_vfree(spinlock_t *
 /*
  * mm_unlock doesn't require any memory allocation and it won't fail.
  *
+ * The mmap_sem cannot be released until mm_unlock returns.
+ *
  * All memory has been previously allocated by mm_lock and it'll be
  * all freed before returning. Only after mm_unlock returns, the
  * caller is allowed to free and forget the mm_lock_data structure.
- * 
+ *
  * mm_unlock runs in O(N) where N is the max number of VMAs in the
  * mm. The max number of vmas is defined in
  * /proc/sys/vm/max_map_count.
@@ -2444,5 +2449,4 @@ void mm_unlock(struct mm_struct *mm, str
 			mm_unlock_vfree(data->i_mmap_locks,
 					data->nr_i_mmap_locks);
 	}
-	up_write(&mm->mmap_sem);
 }
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -59,7 +59,8 @@ void __mmu_notifier_release(struct mm_st
 		 * from establishing any more sptes before all the
 		 * pages in the mm are freed.
 		 */
-		mn->ops->release(mn, mm);
+		if (mn->ops->release)
+			mn->ops->release(mn, mm);
 		srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 		spin_lock(&mm->mmu_notifier_mm->lock);
 	}
@@ -144,20 +145,9 @@ void __mmu_notifier_invalidate_range_end
 	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 }
 
-/*
- * Must not hold mmap_sem nor any other VM related lock when calling
- * this registration function. Must also ensure mm_users can't go down
- * to zero while this runs to avoid races with mmu_notifier_release,
- * so mm has to be current->mm or the mm should be pinned safely such
- * as with get_task_mm(). If the mm is not current->mm, the mm_users
- * pin should be released by calling mmput after mmu_notifier_register
- * returns. mmu_notifier_unregister must be always called to
- * unregister the notifier. mm_count is automatically pinned to allow
- * mmu_notifier_unregister to safely run at any time later, before or
- * after exit_mmap. ->release will always be called before exit_mmap
- * frees the pages.
- */
-int mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+static int do_mmu_notifier_register(struct mmu_notifier *mn,
+				    struct mm_struct *mm,
+				    int take_mmap_sem)
 {
 	struct mm_lock_data data;
 	struct mmu_notifier_mm * mmu_notifier_mm;
@@ -174,6 +164,8 @@ int mmu_notifier_register(struct mmu_not
 	if (unlikely(ret))
 		goto out_kfree;
 
+	if (take_mmap_sem)
+		down_write(&mm->mmap_sem);
 	ret = mm_lock(mm, &data);
 	if (unlikely(ret))
 		goto out_cleanup;
@@ -200,6 +192,8 @@ int mmu_notifier_register(struct mmu_not
 
 	mm_unlock(mm, &data);
 out_cleanup:
+	if (take_mmap_sem)
+		up_write(&mm->mmap_sem);
 	if (mmu_notifier_mm)
 		cleanup_srcu_struct(&mmu_notifier_mm->srcu);
 out_kfree:
@@ -209,7 +203,35 @@ out:
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 	return ret;
 }
+
+/*
+ * Must not hold mmap_sem nor any other VM related lock when calling
+ * this registration function. Must also ensure mm_users can't go down
+ * to zero while this runs to avoid races with mmu_notifier_release,
+ * so mm has to be current->mm or the mm should be pinned safely such
+ * as with get_task_mm(). If the mm is not current->mm, the mm_users
+ * pin should be released by calling mmput after mmu_notifier_register
+ * returns. mmu_notifier_unregister must be always called to
+ * unregister the notifier. mm_count is automatically pinned to allow
+ * mmu_notifier_unregister to safely run at any time later, before or
+ * after exit_mmap. ->release will always be called before exit_mmap
+ * frees the pages.
+ */
+int mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	return do_mmu_notifier_register(mn, mm, 1);
+}
 EXPORT_SYMBOL_GPL(mmu_notifier_register);
+
+/*
+ * Same as mmu_notifier_register but here the caller must hold the
+ * mmap_sem in write mode.
+ */
+int __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	return do_mmu_notifier_register(mn, mm, 0);
+}
+EXPORT_SYMBOL_GPL(__mmu_notifier_register);
 
 /* this is called after the last mmu_notifier_unregister() returned */
 void __mmu_notifier_mm_destroy(struct mm_struct *mm)
@@ -251,7 +273,8 @@ void mmu_notifier_unregister(struct mmu_
 		 * guarantee ->release is called before freeing the
 		 * pages.
 		 */
-		mn->ops->release(mn, mm);
+		if (mn->ops->release)
+			mn->ops->release(mn, mm);
 		srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 	} else
 		spin_unlock(&mm->mmu_notifier_mm->lock);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -148,6 +148,8 @@ static inline int mm_has_notifiers(struc
 
 extern int mmu_notifier_register(struct mmu_notifier *mn,
 				 struct mm_struct *mm);
+extern int __mmu_notifier_register(struct mmu_notifier *mn,
+				   struct mm_struct *mm);
 extern void mmu_notifier_unregister(struct mmu_notifier *mn,
 				    struct mm_struct *mm);
 extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

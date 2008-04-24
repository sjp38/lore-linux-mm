Date: Thu, 24 Apr 2008 19:41:45 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080424174145.GM24536@duo.random>
References: <ea87c15371b1bd49380c.1208872277@duo.random> <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com> <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com> <20080423002848.GA32618@sgi.com> <20080423163713.GC24536@duo.random> <20080423221928.GV24536@duo.random> <20080424064753.GH24536@duo.random> <20080424095112.GC30298@sgi.com> <20080424153943.GJ24536@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080424153943.GJ24536@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 24, 2008 at 05:39:43PM +0200, Andrea Arcangeli wrote:
> There's at least one small issue I noticed so far, that while _release
> don't need to care about _register, but _unregister definitely need to
> care about _register. I've to take the mmap_sem in addition or in

In the end the best is to use the spinlock around those
list_add/list_del they all run in O(1) with the hlist and they take a
few asm insn. This also avoids to take the mmap_sem in exit_mmap, at
exit_mmap time nobody should need to use mmap_sem anymore, it might
work but this looks cleaner. The lock is dynamically allocated only
when the notifiers are registered, so the few bytes taken by it aren't
relevant.

A full new update will some become visible here:

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.25/mmu-notifier-v14-pre3/

Please have a close look again. Your help is extremely appreciated and
very helpful as usual! Thanks a lot.

diff -urN xxx/include/linux/mmu_notifier.h xx/include/linux/mmu_notifier.h
--- xxx/include/linux/mmu_notifier.h	2008-04-24 19:41:15.000000000 +0200
+++ xx/include/linux/mmu_notifier.h	2008-04-24 19:38:37.000000000 +0200
@@ -15,7 +15,7 @@
 	struct hlist_head list;
 	struct srcu_struct srcu;
 	/* to serialize mmu_notifier_unregister against mmu_notifier_release */
-	spinlock_t unregister_lock;
+	spinlock_t lock;
 };
 
 struct mmu_notifier_ops {
diff -urN xxx/mm/memory.c xx/mm/memory.c
--- xxx/mm/memory.c	2008-04-24 19:41:15.000000000 +0200
+++ xx/mm/memory.c	2008-04-24 19:38:37.000000000 +0200
@@ -605,16 +605,13 @@
 	 * readonly mappings. The tradeoff is that copy_page_range is more
 	 * efficient than faulting.
 	 */
-	ret = 0;
 	if (!(vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
 		if (!vma->anon_vma)
-			goto out;
+			return 0;
 	}
 
-	if (unlikely(is_vm_hugetlb_page(vma))) {
-		ret = copy_hugetlb_page_range(dst_mm, src_mm, vma);
-		goto out;
-	}
+	if (is_vm_hugetlb_page(vma))
+		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
 	if (is_cow_mapping(vma->vm_flags))
 		mmu_notifier_invalidate_range_start(src_mm, addr, end);
@@ -636,7 +633,6 @@
 	if (is_cow_mapping(vma->vm_flags))
 		mmu_notifier_invalidate_range_end(src_mm,
 						  vma->vm_start, end);
-out:
 	return ret;
 }
 
diff -urN xxx/mm/mmap.c xx/mm/mmap.c
--- xxx/mm/mmap.c	2008-04-24 19:41:15.000000000 +0200
+++ xx/mm/mmap.c	2008-04-24 19:38:37.000000000 +0200
@@ -2381,7 +2381,7 @@
 		if (data->nr_anon_vma_locks)
 			mm_unlock_vfree(data->anon_vma_locks,
 					data->nr_anon_vma_locks);
-		if (data->i_mmap_locks)
+		if (data->nr_i_mmap_locks)
 			mm_unlock_vfree(data->i_mmap_locks,
 					data->nr_i_mmap_locks);
 	}
diff -urN xxx/mm/mmu_notifier.c xx/mm/mmu_notifier.c
--- xxx/mm/mmu_notifier.c	2008-04-24 19:41:15.000000000 +0200
+++ xx/mm/mmu_notifier.c	2008-04-24 19:31:23.000000000 +0200
@@ -24,22 +24,16 @@
  * zero). All other tasks of this mm already quit so they can't invoke
  * mmu notifiers anymore. This can run concurrently only against
  * mmu_notifier_unregister and it serializes against it with the
- * unregister_lock in addition to RCU. struct mmu_notifier_mm can't go
- * away from under us as the exit_mmap holds a mm_count pin itself.
- *
- * The ->release method can't allow the module to be unloaded, the
- * module can only be unloaded after mmu_notifier_unregister run. This
- * is because the release method has to run the ret instruction to
- * return back here, and so it can't allow the ret instruction to be
- * freed.
+ * mmu_notifier_mm->lock in addition to RCU. struct mmu_notifier_mm
+ * can't go away from under us as exit_mmap holds a mm_count pin
+ * itself.
  */
 void __mmu_notifier_release(struct mm_struct *mm)
 {
 	struct mmu_notifier *mn;
 	int srcu;
 
-	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
-	spin_lock(&mm->mmu_notifier_mm->unregister_lock);
+	spin_lock(&mm->mmu_notifier_mm->lock);
 	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
 		mn = hlist_entry(mm->mmu_notifier_mm->list.first,
 				 struct mmu_notifier,
@@ -52,23 +46,28 @@
 		 */
 		hlist_del_init(&mn->hlist);
 		/*
+		 * SRCU here will block mmu_notifier_unregister until
+		 * ->release returns.
+		 */
+		srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
+		spin_unlock(&mm->mmu_notifier_mm->lock);
+		/*
 		 * if ->release runs before mmu_notifier_unregister it
 		 * must be handled as it's the only way for the driver
-		 * to flush all existing sptes before the pages in the
-		 * mm are freed.
+		 * to flush all existing sptes and stop the driver
+		 * from establishing any more sptes before all the
+		 * pages in the mm are freed.
 		 */
-		spin_unlock(&mm->mmu_notifier_mm->unregister_lock);
-		/* SRCU will block mmu_notifier_unregister */
 		mn->ops->release(mn, mm);
-		spin_lock(&mm->mmu_notifier_mm->unregister_lock);
+		srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+		spin_lock(&mm->mmu_notifier_mm->lock);
 	}
-	spin_unlock(&mm->mmu_notifier_mm->unregister_lock);
-	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	/*
-	 * Wait ->release if mmu_notifier_unregister run list_del_rcu.
-	 * srcu can't go away from under us because one mm_count is
-	 * hold by exit_mmap.
+	 * Wait ->release if mmu_notifier_unregister is running it.
+	 * The mmu_notifier_mm can't go away from under us because one
+	 * mm_count is hold by exit_mmap.
 	 */
 	synchronize_srcu(&mm->mmu_notifier_mm->srcu);
 }
@@ -177,11 +176,19 @@
 			goto out_unlock;
 		}
 		INIT_HLIST_HEAD(&mm->mmu_notifier_mm->list);
-		spin_lock_init(&mm->mmu_notifier_mm->unregister_lock);
+		spin_lock_init(&mm->mmu_notifier_mm->lock);
 	}
 	atomic_inc(&mm->mm_count);
 
+	/*
+	 * Serialize the update against mmu_notifier_unregister. A
+	 * side note: mmu_notifier_release can't run concurrently with
+	 * us because we hold the mm_users pin (either implicitly as
+	 * current->mm or explicitly with get_task_mm() or similar).
+	 */
+	spin_lock(&mm->mmu_notifier_mm->lock);
 	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier_mm->list);
+	spin_unlock(&mm->mmu_notifier_mm->lock);
 out_unlock:
 	mm_unlock(mm, &data);
 out:
@@ -215,23 +222,32 @@
 
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);
 
-	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
-	spin_lock(&mm->mmu_notifier_mm->unregister_lock);
+	spin_lock(&mm->mmu_notifier_mm->lock);
 	if (!hlist_unhashed(&mn->hlist)) {
 		hlist_del_rcu(&mn->hlist);
 		before_release = 1;
 	}
-	spin_unlock(&mm->mmu_notifier_mm->unregister_lock);
 	if (before_release)
 		/*
+		 * SRCU here will force exit_mmap to wait ->release to finish
+		 * before freeing the pages.
+		 */
+		srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
+	spin_unlock(&mm->mmu_notifier_mm->lock);
+	if (before_release) {
+		/*
 		 * exit_mmap will block in mmu_notifier_release to
 		 * guarantee ->release is called before freeing the
 		 * pages.
 		 */
 		mn->ops->release(mn, mm);
-	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+		srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+	}
 
-	/* wait any running method to finish, including ->release */
+	/*
+	 * Wait any running method to finish, of course including
+	 * ->release if it was run by mmu_notifier_relase instead of us.
+	 */
 	synchronize_srcu(&mm->mmu_notifier_mm->srcu);
 
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

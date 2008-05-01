Date: Thu, 1 May 2008 20:12:56 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: mmu notifier-core v14->v15 diff for review
Message-ID: <20080501181256.GK8150@duo.random>
References: <20080426164511.GJ9514@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080426164511.GJ9514@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>, Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>, Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello everyone,

this is the v14 to v15 difference to the mmu-notifier-core patch. This
is just for review of the difference, I'll post full v15 soon, please
review the diff in the meantime. Lots of those cleanups are thanks to
Andrew review on mmu-notifier-core in v14. He also spotted the
GFP_KERNEL allocation under spin_lock where DEBUG_SPINLOCK_SLEEP
failed to catch it until I enabled PREEMPT (GFP_KERNEL there was
perfectly safe with all patchset applied but not ok if only
mmu-notifier-core was applied). As usual that bug couldn't hurt
anybody unless the mmu notifiers were armed.

I also wrote a proper changelog to the mmu-notifier-core patch that I
will append before the v14->v15 diff:

Subject: mmu-notifier-core

With KVM/GFP/XPMEM there isn't just the primary CPU MMU pointing to
pages. There are secondary MMUs (with secondary sptes and secondary
tlbs) too. sptes in the kvm case are shadow pagetables, but when I say
spte in mmu-notifier context, I mean "secondary pte". In GRU case
there's no actual secondary pte and there's only a secondary tlb
because the GRU secondary MMU has no knowledge about sptes and every
secondary tlb miss event in the MMU always generates a page fault that
has to be resolved by the CPU (this is not the case of KVM where the a
secondary tlb miss will walk sptes in hardware and it will refill the
secondary tlb transparently to software if the corresponding spte is
present). The same way zap_page_range has to invalidate the pte before
freeing the page, the spte (and secondary tlb) must also be
invalidated before any page is freed and reused.

Currently we take a page_count pin on every page mapped by sptes, but
that means the pages can't be swapped whenever they're mapped by any
spte because they're part of the guest working set. Furthermore a spte
unmap event can immediately lead to a page to be freed when the pin is
released (so requiring the same complex and relatively slow tlb_gather
smp safe logic we have in zap_page_range and that can be avoided
completely if the spte unmap event doesn't require an unpin of the
page previously mapped in the secondary MMU).

The mmu notifiers allow kvm/GRU/XPMEM to attach to the tsk->mm and
know when the VM is swapping or freeing or doing anything on the
primary MMU so that the secondary MMU code can drop sptes before the
pages are freed, avoiding all page pinning and allowing 100% reliable
swapping of guest physical address space. Furthermore it avoids the
code that teardown the mappings of the secondary MMU, to implement a
logic like tlb_gather in zap_page_range that would require many IPI to
flush other cpu tlbs, for each fixed number of spte unmapped.

To make an example: if what happens on the primary MMU is a protection
downgrade (from writeable to wrprotect) the secondary MMU mappings
will be invalidated, and the next secondary-mmu-page-fault will call
get_user_pages and trigger a do_wp_page through get_user_pages if it
called get_user_pages with write=1, and it'll re-establishing an
updated spte or secondary-tlb-mapping on the copied page. Or it will
setup a readonly spte or readonly tlb mapping if it's a guest-read, if
it calls get_user_pages with write=0. This is just an example.

This allows to map any page pointed by any pte (and in turn visible in
the primary CPU MMU), into a secondary MMU (be it a pure tlb like GRU,
or an full MMU with both sptes and secondary-tlb like the
shadow-pagetable layer with kvm), or a remote DMA in software like
XPMEM (hence needing of schedule in XPMEM code to send the invalidate
to the remote node, while no need to schedule in kvm/gru as it's an
immediate event like invalidating primary-mmu pte).

At least for KVM without this patch it's impossible to swap guests
reliably. And having this feature and removing the page pin allows
several other optimizations that simplify life considerably.

Dependencies:

1) Introduces list_del_init_rcu and documents it (fixes a comment for
   list_del_rcu too)

2) mm_lock() to register the mmu notifier when the whole VM isn't
   doing anything with "mm". This allows mmu notifier users to keep
   track if the VM is in the middle of the invalidate_range_begin/end
   critical section with an atomic counter incraese in range_begin and
   decreased in range_end. No secondary MMU page fault is allowed to
   map any spte or secondary tlb reference, while the VM is in the
   middle of range_begin/end as any page returned by get_user_pages in
   that critical section could later immediately be freed without any
   further ->invalidate_page notification (invalidate_range_begin/end
   works on ranges and ->invalidate_page isn't called immediately
   before freeing the page). To stop all page freeing and pagetable
   overwrites the mmap_sem must be taken in write mode and all other
   anon_vma/i_mmap locks must be taken in virtual address order. The
   order is critical to avoid mm_lock(mm1) and mm_lock(mm2) running
   concurrently to trigger lock inversion deadlocks.

3) It'd be a waste to add branches in the VM if nobody could possibly
   run KVM/GRU/XPMEM on the kernel, so mmu notifiers will only enabled
   if CONFIG_KVM=m/y. In the current kernel kvm won't yet take
   advantage of mmu notifiers, but this already allows to compile a
   KVM external module against a kernel with mmu notifiers enabled and
   from the next pull from kvm.git we'll start using them. And
   GRU/XPMEM will also be able to continue the development by enabling
   KVM=m in their config, until they submit all GRU/XPMEM GPLv2 code
   to the mainline kernel. Then they can also enable MMU_NOTIFIERS in
   the same way KVM does it (even if KVM=n). This guarantees nobody
   selects MMU_NOTIFIER=y if KVM and GRU and XPMEM are all =n.

The mmu_notifier_register call can fail because mm_lock may not
allocate the required vmalloc space. See the comment on top of
mm_lock() implementation for the worst case memory requirements.
Because mmu_notifier_reigster is used when a driver startup, a failure
can be gracefully handled. Here an example of the change applied to
kvm to register the mmu notifiers. Usually when a driver startups
other allocations are required anyway and -ENOMEM failure paths exists
already.

 struct  kvm *kvm_arch_create_vm(void)
 {
        struct kvm *kvm = kzalloc(sizeof(struct kvm), GFP_KERNEL);
+       int err;

        if (!kvm)
                return ERR_PTR(-ENOMEM);

        INIT_LIST_HEAD(&kvm->arch.active_mmu_pages);

+       kvm->arch.mmu_notifier.ops = &kvm_mmu_notifier_ops;
+       err = mmu_notifier_register(&kvm->arch.mmu_notifier, current->mm);
+       if (err) {
+               kfree(kvm);
+               return ERR_PTR(err);
+       }
+
        return kvm;
 }

mmu_notifier_unregister returns void and it's reliable.

diff --git a/arch/x86/kvm/Kconfig b/arch/x86/kvm/Kconfig
--- a/arch/x86/kvm/Kconfig
+++ b/arch/x86/kvm/Kconfig
@@ -21,6 +21,7 @@ config KVM
 	tristate "Kernel-based Virtual Machine (KVM) support"
 	depends on HAVE_KVM
 	select PREEMPT_NOTIFIERS
+	select MMU_NOTIFIER
 	select ANON_INODES
 	---help---
 	  Support hosting fully virtualized guest machines using hardware
diff --git a/include/linux/list.h b/include/linux/list.h
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -739,7 +739,7 @@ static inline void hlist_del(struct hlis
  * or hlist_del_rcu(), running on this same list.
  * However, it is perfectly legal to run concurrently with
  * the _rcu list-traversal primitives, such as
- * hlist_for_each_entry().
+ * hlist_for_each_entry_rcu().
  */
 static inline void hlist_del_rcu(struct hlist_node *n)
 {
@@ -755,6 +755,26 @@ static inline void hlist_del_init(struct
 	}
 }
 
+/**
+ * hlist_del_init_rcu - deletes entry from hash list with re-initialization
+ * @n: the element to delete from the hash list.
+ *
+ * Note: list_unhashed() on entry does return true after this. It is
+ * useful for RCU based read lockfree traversal if the writer side
+ * must know if the list entry is still hashed or already unhashed.
+ *
+ * In particular, it means that we can not poison the forward pointers
+ * that may still be used for walking the hash list and we can only
+ * zero the pprev pointer so list_unhashed() will return true after
+ * this.
+ *
+ * The caller must take whatever precautions are necessary (such as
+ * holding appropriate locks) to avoid racing with another
+ * list-mutation primitive, such as hlist_add_head_rcu() or
+ * hlist_del_rcu(), running on this same list.  However, it is
+ * perfectly legal to run concurrently with the _rcu list-traversal
+ * primitives, such as hlist_for_each_entry_rcu().
+ */
 static inline void hlist_del_init_rcu(struct hlist_node *n)
 {
 	if (!hlist_unhashed(n)) {
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1050,18 +1050,6 @@ extern int install_special_mapping(struc
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
-/*
- * mm_lock will take mmap_sem writably (to prevent all modifications
- * and scanning of vmas) and then also takes the mapping locks for
- * each of the vma to lockout any scans of pagetables of this address
- * space. This can be used to effectively holding off reclaim from the
- * address space.
- *
- * mm_lock can fail if there is not enough memory to store a pointer
- * array to all vmas.
- *
- * mm_lock and mm_unlock are expensive operations that may take a long time.
- */
 struct mm_lock_data {
 	spinlock_t **i_mmap_locks;
 	spinlock_t **anon_vma_locks;
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -4,17 +4,24 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/mm_types.h>
+#include <linux/srcu.h>
 
 struct mmu_notifier;
 struct mmu_notifier_ops;
 
 #ifdef CONFIG_MMU_NOTIFIER
-#include <linux/srcu.h>
 
+/*
+ * The mmu notifier_mm structure is allocated and installed in
+ * mm->mmu_notifier_mm inside the mm_lock() protected critical section
+ * and it's released only when mm_count reaches zero in mmdrop().
+ */
 struct mmu_notifier_mm {
+	/* all mmu notifiers registerd in this mm are queued in this list */
 	struct hlist_head list;
+	/* srcu structure for this mm */
 	struct srcu_struct srcu;
-	/* to serialize mmu_notifier_unregister against mmu_notifier_release */
+	/* to serialize the list modifications and hlist_unhashed */
 	spinlock_t lock;
 };
 
@@ -23,8 +30,8 @@ struct mmu_notifier_ops {
 	 * Called either by mmu_notifier_unregister or when the mm is
 	 * being destroyed by exit_mmap, always before all pages are
 	 * freed. It's mandatory to implement this method. This can
-	 * run concurrently to other mmu notifier methods and it
-	 * should teardown all secondary mmu mappings and freeze the
+	 * run concurrently with other mmu notifier methods and it
+	 * should tear down all secondary mmu mappings and freeze the
 	 * secondary mmu.
 	 */
 	void (*release)(struct mmu_notifier *mn,
@@ -43,9 +50,10 @@ struct mmu_notifier_ops {
 
 	/*
 	 * Before this is invoked any secondary MMU is still ok to
-	 * read/write to the page previously pointed by the Linux pte
-	 * because the old page hasn't been freed yet.  If required
-	 * set_page_dirty has to be called internally to this method.
+	 * read/write to the page previously pointed to by the Linux
+	 * pte because the page hasn't been freed yet and it won't be
+	 * freed until this returns. If required set_page_dirty has to
+	 * be called internally to this method.
 	 */
 	void (*invalidate_page)(struct mmu_notifier *mn,
 				struct mm_struct *mm,
@@ -53,20 +61,18 @@ struct mmu_notifier_ops {
 
 	/*
 	 * invalidate_range_start() and invalidate_range_end() must be
-	 * paired and are called only when the mmap_sem is held and/or
-	 * the semaphores protecting the reverse maps. Both functions
+	 * paired and are called only when the mmap_sem and/or the
+	 * locks protecting the reverse maps are held. Both functions
 	 * may sleep. The subsystem must guarantee that no additional
-	 * references to the pages in the range established between
-	 * the call to invalidate_range_start() and the matching call
-	 * to invalidate_range_end().
+	 * references are taken to the pages in the range established
+	 * between the call to invalidate_range_start() and the
+	 * matching call to invalidate_range_end().
 	 *
-	 * Invalidation of multiple concurrent ranges may be permitted
-	 * by the driver or the driver may exclude other invalidation
-	 * from proceeding by blocking on new invalidate_range_start()
-	 * callback that overlap invalidates that are already in
-	 * progress. Either way the establishment of sptes to the
-	 * range can only be allowed if all invalidate_range_stop()
-	 * function have been called.
+	 * Invalidation of multiple concurrent ranges may be
+	 * optionally permitted by the driver. Either way the
+	 * establishment of sptes is forbidden in the range passed to
+	 * invalidate_range_begin/end for the whole duration of the
+	 * invalidate_range_begin/end critical section.
 	 *
 	 * invalidate_range_start() is called when all pages in the
 	 * range are still mapped and have at least a refcount of one.
@@ -187,6 +193,14 @@ static inline void mmu_notifier_mm_destr
 		__mmu_notifier_mm_destroy(mm);
 }
 
+/*
+ * These two macros will sometime replace ptep_clear_flush.
+ * ptep_clear_flush is impleemnted as macro itself, so this also is
+ * implemented as a macro until ptep_clear_flush will converted to an
+ * inline function, to diminish the risk of compilation failure. The
+ * invalidate_page method over time can be moved outside the PT lock
+ * and these two macros can be later removed.
+ */
 #define ptep_clear_flush_notify(__vma, __address, __ptep)		\
 ({									\
 	pte_t __pte;							\
diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -193,7 +193,3 @@ config VIRT_TO_BUS
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
-
-config MMU_NOTIFIER
-	def_bool y
-	bool "MMU notifier, for paging KVM/RDMA"
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -613,6 +613,12 @@ int copy_page_range(struct mm_struct *ds
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
+	/*
+	 * We need to invalidate the secondary MMU mappings only when
+	 * there could be a permission downgrade on the ptes of the
+	 * parent mm. And a permission downgrade will only happen if
+	 * is_cow_mapping() returns true.
+	 */
 	if (is_cow_mapping(vma->vm_flags))
 		mmu_notifier_invalidate_range_start(src_mm, addr, end);
 
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2329,7 +2329,36 @@ static inline void __mm_unlock(spinlock_
  * operations that could ever happen on a certain mm. This includes
  * vmtruncate, try_to_unmap, and all page faults. The holder
  * must not hold any mm related lock. A single task can't take more
- * than one mm lock in a row or it would deadlock.
+ * than one mm_lock in a row or it would deadlock.
+ *
+ * The mmap_sem must be taken in write mode to block all operations
+ * that could modify pagetables and free pages without altering the
+ * vma layout (for example populate_range() with nonlinear vmas).
+ *
+ * The sorting is needed to avoid lock inversion deadlocks if two
+ * tasks run mm_lock at the same time on different mm that happen to
+ * share some anon_vmas/inodes but mapped in different order.
+ *
+ * mm_lock and mm_unlock are expensive operations that may have to
+ * take thousand of locks. Thanks to sort() the complexity is
+ * O(N*log(N)) where N is the number of VMAs in the mm. The max number
+ * of vmas is defined in /proc/sys/vm/max_map_count.
+ *
+ * mm_lock() can fail if memory allocation fails. The worst case
+ * vmalloc allocation required is 2*max_map_count*sizeof(spinlock *),
+ * so around 1Mbyte, but in practice it'll be much less because
+ * normally there won't be max_map_count vmas allocated in the task
+ * that runs mm_lock().
+ *
+ * The vmalloc memory allocated by mm_lock is stored in the
+ * mm_lock_data structure that must be allocated by the caller and it
+ * must be later passed to mm_unlock that will free it after using it.
+ * Allocating the mm_lock_data structure on the stack is fine because
+ * it's only a couple of bytes in size.
+ *
+ * If mm_lock() returns -ENOMEM no memory has been allocated and the
+ * mm_lock_data structure can be freed immediately, and mm_unlock must
+ * not be called.
  */
 int mm_lock(struct mm_struct *mm, struct mm_lock_data *data)
 {
@@ -2350,6 +2379,13 @@ int mm_lock(struct mm_struct *mm, struct
 			return -ENOMEM;
 		}
 
+		/*
+		 * When mm_lock_sort_anon_vma/i_mmap returns zero it
+		 * means there's no lock to take and so we can free
+		 * the array here without waiting mm_unlock. mm_unlock
+		 * will do nothing if nr_i_mmap/anon_vma_locks is
+		 * zero.
+		 */
 		data->nr_anon_vma_locks = mm_lock_sort_anon_vma(mm, anon_vma_locks);
 		data->nr_i_mmap_locks = mm_lock_sort_i_mmap(mm, i_mmap_locks);
 
@@ -2374,7 +2410,17 @@ static void mm_unlock_vfree(spinlock_t *
 	vfree(locks);
 }
 
-/* avoid memory allocations for mm_unlock to prevent deadlock */
+/*
+ * mm_unlock doesn't require any memory allocation and it won't fail.
+ *
+ * All memory has been previously allocated by mm_lock and it'll be
+ * all freed before returning. Only after mm_unlock returns, the
+ * caller is allowed to free and forget the mm_lock_data structure.
+ * 
+ * mm_unlock runs in O(N) where N is the max number of VMAs in the
+ * mm. The max number of vmas is defined in
+ * /proc/sys/vm/max_map_count.
+ */
 void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data)
 {
 	if (mm->map_count) {
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -21,12 +21,12 @@
  * This function can't run concurrently against mmu_notifier_register
  * because mm->mm_users > 0 during mmu_notifier_register and exit_mmap
  * runs with mm_users == 0. Other tasks may still invoke mmu notifiers
- * in parallel despite there's no task using this mm anymore, through
- * the vmas outside of the exit_mmap context, like with
+ * in parallel despite there being no task using this mm any more,
+ * through the vmas outside of the exit_mmap context, such as with
  * vmtruncate. This serializes against mmu_notifier_unregister with
  * the mmu_notifier_mm->lock in addition to SRCU and it serializes
  * against the other mmu notifiers with SRCU. struct mmu_notifier_mm
- * can't go away from under us as exit_mmap holds a mm_count pin
+ * can't go away from under us as exit_mmap holds an mm_count pin
  * itself.
  */
 void __mmu_notifier_release(struct mm_struct *mm)
@@ -41,7 +41,7 @@ void __mmu_notifier_release(struct mm_st
 				 hlist);
 		/*
 		 * We arrived before mmu_notifier_unregister so
-		 * mmu_notifier_unregister will do nothing else than
+		 * mmu_notifier_unregister will do nothing other than
 		 * to wait ->release to finish and
 		 * mmu_notifier_unregister to return.
 		 */
@@ -66,7 +66,11 @@ void __mmu_notifier_release(struct mm_st
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	/*
-	 * Wait ->release if mmu_notifier_unregister is running it.
+	 * synchronize_srcu here prevents mmu_notifier_release to
+	 * return to exit_mmap (which would proceed freeing all pages
+	 * in the mm) until the ->release method returns, if it was
+	 * invoked by mmu_notifier_unregister.
+	 *
 	 * The mmu_notifier_mm can't go away from under us because one
 	 * mm_count is hold by exit_mmap.
 	 */
@@ -144,8 +148,9 @@ void __mmu_notifier_invalidate_range_end
  * Must not hold mmap_sem nor any other VM related lock when calling
  * this registration function. Must also ensure mm_users can't go down
  * to zero while this runs to avoid races with mmu_notifier_release,
- * so mm has to be current->mm or the mm should be pinned safely like
- * with get_task_mm(). mmput can be called after mmu_notifier_register
+ * so mm has to be current->mm or the mm should be pinned safely such
+ * as with get_task_mm(). If the mm is not current->mm, the mm_users
+ * pin should be released by calling mmput after mmu_notifier_register
  * returns. mmu_notifier_unregister must be always called to
  * unregister the notifier. mm_count is automatically pinned to allow
  * mmu_notifier_unregister to safely run at any time later, before or
@@ -155,29 +160,29 @@ int mmu_notifier_register(struct mmu_not
 int mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	struct mm_lock_data data;
+	struct mmu_notifier_mm * mmu_notifier_mm;
 	int ret;
 
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
+	ret = -ENOMEM;
+	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
+	if (unlikely(!mmu_notifier_mm))
+		goto out;
+
+	ret = init_srcu_struct(&mmu_notifier_mm->srcu);
+	if (unlikely(ret))
+		goto out_kfree;
+
 	ret = mm_lock(mm, &data);
 	if (unlikely(ret))
-		goto out;
+		goto out_cleanup;
 
 	if (!mm_has_notifiers(mm)) {
-		mm->mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm),
-					      GFP_KERNEL);
-		ret = -ENOMEM;
-		if (unlikely(!mm_has_notifiers(mm)))
-			goto out_unlock;
-
-		ret = init_srcu_struct(&mm->mmu_notifier_mm->srcu);
-		if (unlikely(ret)) {
-			kfree(mm->mmu_notifier_mm);
-			mmu_notifier_mm_init(mm);
-			goto out_unlock;
-		}
-		INIT_HLIST_HEAD(&mm->mmu_notifier_mm->list);
-		spin_lock_init(&mm->mmu_notifier_mm->lock);
+		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
+		spin_lock_init(&mmu_notifier_mm->lock);
+		mm->mmu_notifier_mm = mmu_notifier_mm;
+		mmu_notifier_mm = NULL;
 	}
 	atomic_inc(&mm->mm_count);
 
@@ -192,8 +197,14 @@ int mmu_notifier_register(struct mmu_not
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
-out_unlock:
+
 	mm_unlock(mm, &data);
+out_cleanup:
+	if (mmu_notifier_mm)
+		cleanup_srcu_struct(&mmu_notifier_mm->srcu);
+out_kfree:
+	/* kfree() does nothing if mmu_notifier_mm is NULL */
+	kfree(mmu_notifier_mm);
 out:
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

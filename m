Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 01 of 11] mmu-notifier-core
Message-Id: <1489529e7b53d3f2dab8.1209740704@duo.random>
In-Reply-To: <patchbomb.1209740703@duo.random>
Date: Fri, 02 May 2008 17:05:04 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1209740175 -7200
# Node ID 1489529e7b53d3f2dab8431372aa4850ec821caa
# Parent  5026689a3bc323a26d33ad882c34c4c9c9a3ecd8
mmu-notifier-core

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

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

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
@@ -747,7 +747,7 @@ static inline void hlist_del(struct hlis
  * or hlist_del_rcu(), running on this same list.
  * However, it is perfectly legal to run concurrently with
  * the _rcu list-traversal primitives, such as
- * hlist_for_each_entry().
+ * hlist_for_each_entry_rcu().
  */
 static inline void hlist_del_rcu(struct hlist_node *n)
 {
@@ -760,6 +760,34 @@ static inline void hlist_del_init(struct
 	if (!hlist_unhashed(n)) {
 		__hlist_del(n);
 		INIT_HLIST_NODE(n);
+	}
+}
+
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
+static inline void hlist_del_init_rcu(struct hlist_node *n)
+{
+	if (!hlist_unhashed(n)) {
+		__hlist_del(n);
+		n->pprev = NULL;
 	}
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1084,6 +1084,15 @@ extern int install_special_mapping(struc
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
+struct mm_lock_data {
+	spinlock_t **i_mmap_locks;
+	spinlock_t **anon_vma_locks;
+	size_t nr_i_mmap_locks;
+	size_t nr_anon_vma_locks;
+};
+extern int mm_lock(struct mm_struct *mm, struct mm_lock_data *data);
+extern void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data);
+
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -10,6 +10,7 @@
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
 #include <linux/completion.h>
+#include <linux/cpumask.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -19,6 +20,7 @@
 #define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_ARCH + AT_VECTOR_SIZE_BASE + 1))
 
 struct address_space;
+struct mmu_notifier_mm;
 
 #if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
 typedef atomic_long_t mm_counter_t;
@@ -235,6 +237,9 @@ struct mm_struct {
 	struct file *exe_file;
 	unsigned long num_exe_file_vmas;
 #endif
+#ifdef CONFIG_MMU_NOTIFIER
+	struct mmu_notifier_mm *mmu_notifier_mm;
+#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
new file mode 100644
--- /dev/null
+++ b/include/linux/mmu_notifier.h
@@ -0,0 +1,265 @@
+#ifndef _LINUX_MMU_NOTIFIER_H
+#define _LINUX_MMU_NOTIFIER_H
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/mm_types.h>
+#include <linux/srcu.h>
+
+struct mmu_notifier;
+struct mmu_notifier_ops;
+
+#ifdef CONFIG_MMU_NOTIFIER
+
+/*
+ * The mmu notifier_mm structure is allocated and installed in
+ * mm->mmu_notifier_mm inside the mm_lock() protected critical section
+ * and it's released only when mm_count reaches zero in mmdrop().
+ */
+struct mmu_notifier_mm {
+	/* all mmu notifiers registerd in this mm are queued in this list */
+	struct hlist_head list;
+	/* srcu structure for this mm */
+	struct srcu_struct srcu;
+	/* to serialize the list modifications and hlist_unhashed */
+	spinlock_t lock;
+};
+
+struct mmu_notifier_ops {
+	/*
+	 * Called either by mmu_notifier_unregister or when the mm is
+	 * being destroyed by exit_mmap, always before all pages are
+	 * freed. It's mandatory to implement this method. This can
+	 * run concurrently with other mmu notifier methods and it
+	 * should tear down all secondary mmu mappings and freeze the
+	 * secondary mmu.
+	 */
+	void (*release)(struct mmu_notifier *mn,
+			struct mm_struct *mm);
+
+	/*
+	 * clear_flush_young is called after the VM is
+	 * test-and-clearing the young/accessed bitflag in the
+	 * pte. This way the VM will provide proper aging to the
+	 * accesses to the page through the secondary MMUs and not
+	 * only to the ones through the Linux pte.
+	 */
+	int (*clear_flush_young)(struct mmu_notifier *mn,
+				 struct mm_struct *mm,
+				 unsigned long address);
+
+	/*
+	 * Before this is invoked any secondary MMU is still ok to
+	 * read/write to the page previously pointed to by the Linux
+	 * pte because the page hasn't been freed yet and it won't be
+	 * freed until this returns. If required set_page_dirty has to
+	 * be called internally to this method.
+	 */
+	void (*invalidate_page)(struct mmu_notifier *mn,
+				struct mm_struct *mm,
+				unsigned long address);
+
+	/*
+	 * invalidate_range_start() and invalidate_range_end() must be
+	 * paired and are called only when the mmap_sem and/or the
+	 * locks protecting the reverse maps are held. Both functions
+	 * may sleep. The subsystem must guarantee that no additional
+	 * references are taken to the pages in the range established
+	 * between the call to invalidate_range_start() and the
+	 * matching call to invalidate_range_end().
+	 *
+	 * Invalidation of multiple concurrent ranges may be
+	 * optionally permitted by the driver. Either way the
+	 * establishment of sptes is forbidden in the range passed to
+	 * invalidate_range_begin/end for the whole duration of the
+	 * invalidate_range_begin/end critical section.
+	 *
+	 * invalidate_range_start() is called when all pages in the
+	 * range are still mapped and have at least a refcount of one.
+	 *
+	 * invalidate_range_end() is called when all pages in the
+	 * range have been unmapped and the pages have been freed by
+	 * the VM.
+	 *
+	 * The VM will remove the page table entries and potentially
+	 * the page between invalidate_range_start() and
+	 * invalidate_range_end(). If the page must not be freed
+	 * because of pending I/O or other circumstances then the
+	 * invalidate_range_start() callback (or the initial mapping
+	 * by the driver) must make sure that the refcount is kept
+	 * elevated.
+	 *
+	 * If the driver increases the refcount when the pages are
+	 * initially mapped into an address space then either
+	 * invalidate_range_start() or invalidate_range_end() may
+	 * decrease the refcount. If the refcount is decreased on
+	 * invalidate_range_start() then the VM can free pages as page
+	 * table entries are removed.  If the refcount is only
+	 * droppped on invalidate_range_end() then the driver itself
+	 * will drop the last refcount but it must take care to flush
+	 * any secondary tlb before doing the final free on the
+	 * page. Pages will no longer be referenced by the linux
+	 * address space but may still be referenced by sptes until
+	 * the last refcount is dropped.
+	 */
+	void (*invalidate_range_start)(struct mmu_notifier *mn,
+				       struct mm_struct *mm,
+				       unsigned long start, unsigned long end);
+	void (*invalidate_range_end)(struct mmu_notifier *mn,
+				     struct mm_struct *mm,
+				     unsigned long start, unsigned long end);
+};
+
+/*
+ * The notifier chains are protected by mmap_sem and/or the reverse map
+ * semaphores. Notifier chains are only changed when all reverse maps and
+ * the mmap_sem locks are taken.
+ *
+ * Therefore notifier chains can only be traversed when either
+ *
+ * 1. mmap_sem is held.
+ * 2. One of the reverse map locks is held (i_mmap_sem or anon_vma->sem).
+ * 3. No other concurrent thread can access the list (release)
+ */
+struct mmu_notifier {
+	struct hlist_node hlist;
+	const struct mmu_notifier_ops *ops;
+};
+
+static inline int mm_has_notifiers(struct mm_struct *mm)
+{
+	return unlikely(mm->mmu_notifier_mm);
+}
+
+extern int mmu_notifier_register(struct mmu_notifier *mn,
+				 struct mm_struct *mm);
+extern void mmu_notifier_unregister(struct mmu_notifier *mn,
+				    struct mm_struct *mm);
+extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);
+extern void __mmu_notifier_release(struct mm_struct *mm);
+extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
+					  unsigned long address);
+extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address);
+extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+				  unsigned long start, unsigned long end);
+extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end);
+
+
+static inline void mmu_notifier_release(struct mm_struct *mm)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_release(mm);
+}
+
+static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
+					  unsigned long address)
+{
+	if (mm_has_notifiers(mm))
+		return __mmu_notifier_clear_flush_young(mm, address);
+	return 0;
+}
+
+static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_page(mm, address);
+}
+
+static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range_start(mm, start, end);
+}
+
+static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range_end(mm, start, end);
+}
+
+static inline void mmu_notifier_mm_init(struct mm_struct *mm)
+{
+	mm->mmu_notifier_mm = NULL;
+}
+
+static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_mm_destroy(mm);
+}
+
+/*
+ * These two macros will sometime replace ptep_clear_flush.
+ * ptep_clear_flush is impleemnted as macro itself, so this also is
+ * implemented as a macro until ptep_clear_flush will converted to an
+ * inline function, to diminish the risk of compilation failure. The
+ * invalidate_page method over time can be moved outside the PT lock
+ * and these two macros can be later removed.
+ */
+#define ptep_clear_flush_notify(__vma, __address, __ptep)		\
+({									\
+	pte_t __pte;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	__pte = ptep_clear_flush(___vma, ___address, __ptep);		\
+	mmu_notifier_invalidate_page(___vma->vm_mm, ___address);	\
+	__pte;								\
+})
+
+#define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
+({									\
+	int __young;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	__young = ptep_clear_flush_young(___vma, ___address, __ptep);	\
+	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
+						  ___address);		\
+	__young;							\
+})
+
+#else /* CONFIG_MMU_NOTIFIER */
+
+static inline void mmu_notifier_release(struct mm_struct *mm)
+{
+}
+
+static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
+					  unsigned long address)
+{
+	return 0;
+}
+
+static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address)
+{
+}
+
+static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+}
+
+static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+}
+
+static inline void mmu_notifier_mm_init(struct mm_struct *mm)
+{
+}
+
+static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
+{
+}
+
+#define ptep_clear_flush_young_notify ptep_clear_flush_young
+#define ptep_clear_flush_notify ptep_clear_flush
+
+#endif /* CONFIG_MMU_NOTIFIER */
+
+#endif /* _LINUX_MMU_NOTIFIER_H */
diff --git a/include/linux/srcu.h b/include/linux/srcu.h
--- a/include/linux/srcu.h
+++ b/include/linux/srcu.h
@@ -27,6 +27,8 @@
 #ifndef _LINUX_SRCU_H
 #define _LINUX_SRCU_H
 
+#include <linux/mutex.h>
+
 struct srcu_struct_array {
 	int c[2];
 };
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -53,6 +53,7 @@
 #include <linux/tty.h>
 #include <linux/proc_fs.h>
 #include <linux/blkdev.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -385,6 +386,7 @@ static struct mm_struct * mm_init(struct
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
+		mmu_notifier_mm_init(mm);
 		return mm;
 	}
 
@@ -417,6 +419,7 @@ void __mmdrop(struct mm_struct *mm)
 	BUG_ON(mm == &init_mm);
 	mm_free_pgd(mm);
 	destroy_context(mm);
+	mmu_notifier_mm_destroy(mm);
 	free_mm(mm);
 }
 EXPORT_SYMBOL_GPL(__mmdrop);
diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -205,3 +205,6 @@ config VIRT_TO_BUS
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config MMU_NOTIFIER
+	bool
diff --git a/mm/Makefile b/mm/Makefile
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -33,4 +33,5 @@ obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -188,7 +188,7 @@ __xip_unmap (struct address_space * mapp
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
-			pteval = ptep_clear_flush(vma, address, pte);
+			pteval = ptep_clear_flush_notify(vma, address, pte);
 			page_remove_rmap(page, vma);
 			dec_mm_counter(mm, file_rss);
 			BUG_ON(pte_dirty(pteval));
diff --git a/mm/fremap.c b/mm/fremap.c
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -214,7 +215,9 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
+	mmu_notifier_invalidate_range_start(mm, start, start + size);
 	err = populate_range(mm, vma, start, size, pgoff);
+	mmu_notifier_invalidate_range_end(mm, start, start + size);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (unlikely(has_write_lock)) {
 			downgrade_write(&mm->mmap_sem);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -823,6 +824,7 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(start & ~HPAGE_MASK);
 	BUG_ON(end & ~HPAGE_MASK);
 
+	mmu_notifier_invalidate_range_start(mm, start, end);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += HPAGE_SIZE) {
 		ptep = huge_pte_offset(mm, address);
@@ -843,6 +845,7 @@ void __unmap_hugepage_range(struct vm_ar
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -51,6 +51,7 @@
 #include <linux/init.h>
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -632,6 +633,7 @@ int copy_page_range(struct mm_struct *ds
 	unsigned long next;
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
+	int ret;
 
 	/*
 	 * Don't copy ptes where a page fault will fill them correctly.
@@ -647,17 +649,33 @@ int copy_page_range(struct mm_struct *ds
 	if (is_vm_hugetlb_page(vma))
 		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
 
+	/*
+	 * We need to invalidate the secondary MMU mappings only when
+	 * there could be a permission downgrade on the ptes of the
+	 * parent mm. And a permission downgrade will only happen if
+	 * is_cow_mapping() returns true.
+	 */
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier_invalidate_range_start(src_mm, addr, end);
+
+	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(src_pgd))
 			continue;
-		if (copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-						vma, addr, next))
-			return -ENOMEM;
+		if (unlikely(copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
+					    vma, addr, next))) {
+			ret = -ENOMEM;
+			break;
+		}
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
-	return 0;
+
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier_invalidate_range_end(src_mm,
+						  vma->vm_start, end);
+	return ret;
 }
 
 static unsigned long zap_pte_range(struct mmu_gather *tlb,
@@ -861,7 +879,9 @@ unsigned long unmap_vmas(struct mmu_gath
 	unsigned long start = start_addr;
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	int fullmm = (*tlbp)->fullmm;
+	struct mm_struct *mm = vma->vm_mm;
 
+	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
 
@@ -912,6 +932,7 @@ unsigned long unmap_vmas(struct mmu_gath
 		}
 	}
 out:
+	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
 	return start;	/* which is now the end (or restart) address */
 }
 
@@ -1541,10 +1562,11 @@ int apply_to_page_range(struct mm_struct
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long end = addr + size;
+	unsigned long start = addr, end = addr + size;
 	int err;
 
 	BUG_ON(addr >= end);
+	mmu_notifier_invalidate_range_start(mm, start, end);
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1552,6 +1574,7 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
@@ -1753,7 +1776,7 @@ gotten:
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush(vma, address, page_table);
+		ptep_clear_flush_notify(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		lru_cache_add_active(new_page);
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -26,6 +26,9 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/vmalloc.h>
+#include <linux/sort.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2048,6 +2051,7 @@ void exit_mmap(struct mm_struct *mm)
 
 	/* mm's last user has gone, and its about to be pulled down */
 	arch_exit_mmap(mm);
+	mmu_notifier_release(mm);
 
 	lru_add_drain();
 	flush_cache_mm(mm);
@@ -2255,3 +2259,190 @@ int install_special_mapping(struct mm_st
 
 	return 0;
 }
+
+static int mm_lock_cmp(const void *a, const void *b)
+{
+	unsigned long _a = (unsigned long)*(spinlock_t **)a;
+	unsigned long _b = (unsigned long)*(spinlock_t **)b;
+
+	cond_resched();
+	if (_a < _b)
+		return -1;
+	if (_a > _b)
+		return 1;
+	return 0;
+}
+
+static unsigned long mm_lock_sort(struct mm_struct *mm, spinlock_t **locks,
+				  int anon)
+{
+	struct vm_area_struct *vma;
+	size_t i = 0;
+
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (anon) {
+			if (vma->anon_vma)
+				locks[i++] = &vma->anon_vma->lock;
+		} else {
+			if (vma->vm_file && vma->vm_file->f_mapping)
+				locks[i++] = &vma->vm_file->f_mapping->i_mmap_lock;
+		}
+	}
+
+	if (!i)
+		goto out;
+
+	sort(locks, i, sizeof(spinlock_t *), mm_lock_cmp, NULL);
+
+out:
+	return i;
+}
+
+static inline unsigned long mm_lock_sort_anon_vma(struct mm_struct *mm,
+						  spinlock_t **locks)
+{
+	return mm_lock_sort(mm, locks, 1);
+}
+
+static inline unsigned long mm_lock_sort_i_mmap(struct mm_struct *mm,
+						spinlock_t **locks)
+{
+	return mm_lock_sort(mm, locks, 0);
+}
+
+static void mm_lock_unlock(spinlock_t **locks, size_t nr, int lock)
+{
+	spinlock_t *last = NULL;
+	size_t i;
+
+	for (i = 0; i < nr; i++)
+		/*  Multiple vmas may use the same lock. */
+		if (locks[i] != last) {
+			BUG_ON((unsigned long) last > (unsigned long) locks[i]);
+			last = locks[i];
+			if (lock)
+				spin_lock(last);
+			else
+				spin_unlock(last);
+		}
+}
+
+static inline void __mm_lock(spinlock_t **locks, size_t nr)
+{
+	mm_lock_unlock(locks, nr, 1);
+}
+
+static inline void __mm_unlock(spinlock_t **locks, size_t nr)
+{
+	mm_lock_unlock(locks, nr, 0);
+}
+
+/*
+ * This operation locks against the VM for all pte/vma/mm related
+ * operations that could ever happen on a certain mm. This includes
+ * vmtruncate, try_to_unmap, and all page faults. The holder
+ * must not hold any mm related lock. A single task can't take more
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
+ * vmalloc allocation required is 2*max_map_count*sizeof(spinlock_t *),
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
+ */
+int mm_lock(struct mm_struct *mm, struct mm_lock_data *data)
+{
+	spinlock_t **anon_vma_locks, **i_mmap_locks;
+
+	down_write(&mm->mmap_sem);
+	if (mm->map_count) {
+		anon_vma_locks = vmalloc(sizeof(spinlock_t *) * mm->map_count);
+		if (unlikely(!anon_vma_locks)) {
+			up_write(&mm->mmap_sem);
+			return -ENOMEM;
+		}
+
+		i_mmap_locks = vmalloc(sizeof(spinlock_t *) * mm->map_count);
+		if (unlikely(!i_mmap_locks)) {
+			up_write(&mm->mmap_sem);
+			vfree(anon_vma_locks);
+			return -ENOMEM;
+		}
+
+		/*
+		 * When mm_lock_sort_anon_vma/i_mmap returns zero it
+		 * means there's no lock to take and so we can free
+		 * the array here without waiting mm_unlock. mm_unlock
+		 * will do nothing if nr_i_mmap/anon_vma_locks is
+		 * zero.
+		 */
+		data->nr_anon_vma_locks = mm_lock_sort_anon_vma(mm, anon_vma_locks);
+		data->nr_i_mmap_locks = mm_lock_sort_i_mmap(mm, i_mmap_locks);
+
+		if (data->nr_anon_vma_locks) {
+			__mm_lock(anon_vma_locks, data->nr_anon_vma_locks);
+			data->anon_vma_locks = anon_vma_locks;
+		} else
+			vfree(anon_vma_locks);
+
+		if (data->nr_i_mmap_locks) {
+			__mm_lock(i_mmap_locks, data->nr_i_mmap_locks);
+			data->i_mmap_locks = i_mmap_locks;
+		} else
+			vfree(i_mmap_locks);
+	}
+	return 0;
+}
+
+static void mm_unlock_vfree(spinlock_t **locks, size_t nr)
+{
+	__mm_unlock(locks, nr);
+	vfree(locks);
+}
+
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
+void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data)
+{
+	if (mm->map_count) {
+		if (data->nr_anon_vma_locks)
+			mm_unlock_vfree(data->anon_vma_locks,
+					data->nr_anon_vma_locks);
+		if (data->nr_i_mmap_locks)
+			mm_unlock_vfree(data->i_mmap_locks,
+					data->nr_i_mmap_locks);
+	}
+	up_write(&mm->mmap_sem);
+}
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
new file mode 100644
--- /dev/null
+++ b/mm/mmu_notifier.c
@@ -0,0 +1,269 @@
+/*
+ *  linux/mm/mmu_notifier.c
+ *
+ *  Copyright (C) 2008  Qumranet, Inc.
+ *  Copyright (C) 2008  SGI
+ *             Christoph Lameter <clameter@sgi.com>
+ *
+ *  This work is licensed under the terms of the GNU GPL, version 2. See
+ *  the COPYING file in the top-level directory.
+ */
+
+#include <linux/mmu_notifier.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/err.h>
+#include <linux/srcu.h>
+#include <linux/rcupdate.h>
+#include <linux/sched.h>
+
+/*
+ * This function can't run concurrently against mmu_notifier_register
+ * because mm->mm_users > 0 during mmu_notifier_register and exit_mmap
+ * runs with mm_users == 0. Other tasks may still invoke mmu notifiers
+ * in parallel despite there being no task using this mm any more,
+ * through the vmas outside of the exit_mmap context, such as with
+ * vmtruncate. This serializes against mmu_notifier_unregister with
+ * the mmu_notifier_mm->lock in addition to SRCU and it serializes
+ * against the other mmu notifiers with SRCU. struct mmu_notifier_mm
+ * can't go away from under us as exit_mmap holds an mm_count pin
+ * itself.
+ */
+void __mmu_notifier_release(struct mm_struct *mm)
+{
+	struct mmu_notifier *mn;
+	int srcu;
+
+	spin_lock(&mm->mmu_notifier_mm->lock);
+	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
+		mn = hlist_entry(mm->mmu_notifier_mm->list.first,
+				 struct mmu_notifier,
+				 hlist);
+		/*
+		 * We arrived before mmu_notifier_unregister so
+		 * mmu_notifier_unregister will do nothing other than
+		 * to wait ->release to finish and
+		 * mmu_notifier_unregister to return.
+		 */
+		hlist_del_init_rcu(&mn->hlist);
+		/*
+		 * SRCU here will block mmu_notifier_unregister until
+		 * ->release returns.
+		 */
+		srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
+		spin_unlock(&mm->mmu_notifier_mm->lock);
+		/*
+		 * if ->release runs before mmu_notifier_unregister it
+		 * must be handled as it's the only way for the driver
+		 * to flush all existing sptes and stop the driver
+		 * from establishing any more sptes before all the
+		 * pages in the mm are freed.
+		 */
+		mn->ops->release(mn, mm);
+		srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+		spin_lock(&mm->mmu_notifier_mm->lock);
+	}
+	spin_unlock(&mm->mmu_notifier_mm->lock);
+
+	/*
+	 * synchronize_srcu here prevents mmu_notifier_release to
+	 * return to exit_mmap (which would proceed freeing all pages
+	 * in the mm) until the ->release method returns, if it was
+	 * invoked by mmu_notifier_unregister.
+	 *
+	 * The mmu_notifier_mm can't go away from under us because one
+	 * mm_count is hold by exit_mmap.
+	 */
+	synchronize_srcu(&mm->mmu_notifier_mm->srcu);
+}
+
+/*
+ * If no young bitflag is supported by the hardware, ->clear_flush_young can
+ * unmap the address and return 1 or 0 depending if the mapping previously
+ * existed or not.
+ */
+int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
+					unsigned long address)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+	int young = 0, srcu;
+
+	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->clear_flush_young)
+			young |= mn->ops->clear_flush_young(mn, mm, address);
+	}
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+
+	return young;
+}
+
+void __mmu_notifier_invalidate_page(struct mm_struct *mm,
+					  unsigned long address)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+	int srcu;
+
+	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->invalidate_page)
+			mn->ops->invalidate_page(mn, mm, address);
+	}
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+}
+
+void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+	int srcu;
+
+	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->invalidate_range_start)
+			mn->ops->invalidate_range_start(mn, mm, start, end);
+	}
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+}
+
+void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+				  unsigned long start, unsigned long end)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+	int srcu;
+
+	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->invalidate_range_end)
+			mn->ops->invalidate_range_end(mn, mm, start, end);
+	}
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+}
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
+	struct mm_lock_data data;
+	struct mmu_notifier_mm * mmu_notifier_mm;
+	int ret;
+
+	BUG_ON(atomic_read(&mm->mm_users) <= 0);
+
+	ret = -ENOMEM;
+	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
+	if (unlikely(!mmu_notifier_mm))
+		goto out;
+
+	ret = init_srcu_struct(&mmu_notifier_mm->srcu);
+	if (unlikely(ret))
+		goto out_kfree;
+
+	ret = mm_lock(mm, &data);
+	if (unlikely(ret))
+		goto out_cleanup;
+
+	if (!mm_has_notifiers(mm)) {
+		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
+		spin_lock_init(&mmu_notifier_mm->lock);
+		mm->mmu_notifier_mm = mmu_notifier_mm;
+		mmu_notifier_mm = NULL;
+	}
+	atomic_inc(&mm->mm_count);
+
+	/*
+	 * Serialize the update against mmu_notifier_unregister. A
+	 * side note: mmu_notifier_release can't run concurrently with
+	 * us because we hold the mm_users pin (either implicitly as
+	 * current->mm or explicitly with get_task_mm() or similar).
+	 * We can't race against any other mmu notifiers either thanks
+	 * to mm_lock().
+	 */
+	spin_lock(&mm->mmu_notifier_mm->lock);
+	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
+	spin_unlock(&mm->mmu_notifier_mm->lock);
+
+	mm_unlock(mm, &data);
+out_cleanup:
+	if (mmu_notifier_mm)
+		cleanup_srcu_struct(&mmu_notifier_mm->srcu);
+out_kfree:
+	/* kfree() does nothing if mmu_notifier_mm is NULL */
+	kfree(mmu_notifier_mm);
+out:
+	BUG_ON(atomic_read(&mm->mm_users) <= 0);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_register);
+
+/* this is called after the last mmu_notifier_unregister() returned */
+void __mmu_notifier_mm_destroy(struct mm_struct *mm)
+{
+	BUG_ON(!hlist_empty(&mm->mmu_notifier_mm->list));
+	cleanup_srcu_struct(&mm->mmu_notifier_mm->srcu);
+	kfree(mm->mmu_notifier_mm);
+	mm->mmu_notifier_mm = LIST_POISON1; /* debug */
+}
+
+/*
+ * This releases the mm_count pin automatically and frees the mm
+ * structure if it was the last user of it. It serializes against
+ * running mmu notifiers with SRCU and against mmu_notifier_unregister
+ * with the unregister lock + SRCU. All sptes must be dropped before
+ * calling mmu_notifier_unregister. ->release or any other notifier
+ * method may be invoked concurrently with mmu_notifier_unregister,
+ * and only after mmu_notifier_unregister returned we're guaranteed
+ * that ->release or any other method can't run anymore.
+ */
+void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	BUG_ON(atomic_read(&mm->mm_count) <= 0);
+
+	spin_lock(&mm->mmu_notifier_mm->lock);
+	if (!hlist_unhashed(&mn->hlist)) {
+		int srcu;
+
+		hlist_del_rcu(&mn->hlist);
+
+		/*
+		 * SRCU here will force exit_mmap to wait ->release to finish
+		 * before freeing the pages.
+		 */
+		srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
+		spin_unlock(&mm->mmu_notifier_mm->lock);
+		/*
+		 * exit_mmap will block in mmu_notifier_release to
+		 * guarantee ->release is called before freeing the
+		 * pages.
+		 */
+		mn->ops->release(mn, mm);
+		srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+	} else
+		spin_unlock(&mm->mmu_notifier_mm->lock);
+
+	/*
+	 * Wait any running method to finish, of course including
+	 * ->release if it was run by mmu_notifier_relase instead of us.
+	 */
+	synchronize_srcu(&mm->mmu_notifier_mm->srcu);
+
+	BUG_ON(atomic_read(&mm->mm_count) <= 0);
+
+	mmdrop(mm);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
diff --git a/mm/mprotect.c b/mm/mprotect.c
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -21,6 +21,7 @@
 #include <linux/syscalls.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/mmu_notifier.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -198,10 +199,12 @@ success:
 		dirty_accountable = 1;
 	}
 
+	mmu_notifier_invalidate_range_start(mm, start, end);
 	if (is_vm_hugetlb_page(vma))
 		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
 	else
 		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
 	return 0;
diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -18,6 +18,7 @@
 #include <linux/highmem.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -74,7 +75,11 @@ static void move_ptes(struct vm_area_str
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *old_pte, *new_pte, pte;
 	spinlock_t *old_ptl, *new_ptl;
+	unsigned long old_start;
 
+	old_start = old_addr;
+	mmu_notifier_invalidate_range_start(vma->vm_mm,
+					    old_start, old_end);
 	if (vma->vm_file) {
 		/*
 		 * Subtle point from Rajesh Venkatasubramanian: before
@@ -116,6 +121,7 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
+	mmu_notifier_invalidate_range_end(vma->vm_mm, old_start, old_end);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -49,6 +49,7 @@
 #include <linux/module.h>
 #include <linux/kallsyms.h>
 #include <linux/memcontrol.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/tlbflush.h>
 
@@ -287,7 +288,7 @@ static int page_referenced_one(struct pa
 	if (vma->vm_flags & VM_LOCKED) {
 		referenced++;
 		*mapcount = 1;	/* break early from loop */
-	} else if (ptep_clear_flush_young(vma, address, pte))
+	} else if (ptep_clear_flush_young_notify(vma, address, pte))
 		referenced++;
 
 	/* Pretend the page is referenced if the task has the
@@ -457,7 +458,7 @@ static int page_mkclean_one(struct page 
 		pte_t entry;
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		entry = ptep_clear_flush(vma, address, pte);
+		entry = ptep_clear_flush_notify(vma, address, pte);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -717,14 +718,14 @@ static int try_to_unmap_one(struct page 
 	 * skipped over this mm) then we should reactivate it.
 	 */
 	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young(vma, address, pte)))) {
+			(ptep_clear_flush_young_notify(vma, address, pte)))) {
 		ret = SWAP_FAIL;
 		goto out_unmap;
 	}
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush(vma, address, pte);
+	pteval = ptep_clear_flush_notify(vma, address, pte);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
@@ -849,12 +850,12 @@ static void try_to_unmap_cluster(unsigne
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
 
-		if (ptep_clear_flush_young(vma, address, pte))
+		if (ptep_clear_flush_young_notify(vma, address, pte))
 			continue;
 
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		pteval = ptep_clear_flush(vma, address, pte);
+		pteval = ptep_clear_flush_notify(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

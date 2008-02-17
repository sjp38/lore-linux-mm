Date: Sun, 17 Feb 2008 04:01:20 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
Message-ID: <20080217030120.GO11732@v2.random>
References: <20080215064859.384203497@sgi.com> <20080215064932.371510599@sgi.com> <20080215193719.262c03a1.akpm@linux-foundation.org> <Pine.LNX.4.64.0802161103101.25573@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802161103101.25573@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Sat, Feb 16, 2008 at 11:21:07AM -0800, Christoph Lameter wrote:
> On Fri, 15 Feb 2008, Andrew Morton wrote:
> 
> > What is the status of getting infiniband to use this facility?
> 
> Well we are talking about this it seems.

It seems the IB folks think allowing RDMA over virtual memory is not
interesting, their argument seem to be that RDMA is only interesting
on RAM (and they seem not interested in allowing RDMA over a ram+swap
backed _virtual_ memory allocation). They've just to decide if
ram+swap allocation for RDMA is useful or not.

> > How important is this feature to KVM?
> 
> Andrea can answer this.

I think I already did in separate email.

> > That sucks big time.  What do we need to do to make get the callback
> > functions called in non-atomic context?

I sure agree given I also asked to drop the lock param and enforce the
invalidate_range_* to always be called in non atomic context.

> We would have to drop the inode_mmap_lock. Could be done with some minor 
> work.

The invalidate may be deferred after releasing the lock, the lock may
not have to be dropped to cleanup the API (and make xpmem life easier).

> That is one implementation (XPmem does that). The other is to simply stop 
> all references when any invalidate_range is in progress (KVM and GRU do 
> that).

KVM doesn't stop new references. It doesn't need to because it holds a
reference on the page (GRU doesn't). KVM can invalidate the spte and
flush the tlb only after the linux pte has been cleared and after the
page has been released by the VM (because the page doesn't go in the
freelist and it remains pinned for a little while, until the spte is
dropped too inside invalidate_range_end). GRU has to invalidate
_before_ the linux pte is cleared so it has to stop new references
from being established in the invalidate_range_start/end critical
section.

> Andrea put this in to check the reference status of a page. It functions 
> like the accessed bit.

In short each pte can have some spte associated to it. So whenever we
do a ptep_clear_flush protected by the PT lock, we also have to run
invalidate_page that will internally invoke a sort-of
sptep_clear_flush protected by a kvm->mmu_lock (equivalent of
page_table_lock/PT-lock). sptes just like ptes maps virtual addresses
to physical addresses, so you can read/write to RAM either through a
pte or through a spte.

Just like it would be insane to have any requirement that
ptep_clear_flush has to run in not-atomic context (forcing a
conversion of the PT lock to a mutex), it's also weird require the
invalidate_page/age_page to run in atomic context.

All troubles start with the xpmem requirements of having to schedule
in its equivalent of the sptep_clear_flush because it's not a
gigaherz-in-cpu thing but a gigabit thing where the network stack is
involved with its own software linux driven skb memory allocations,
schedules waiting for network I/O, etc... Imagine ptes allocated in a
remote node, no surprise its brings a new set of problems (assuming it
can work reliably during oom given its memory requirements in the
try_to_unmap path, no page can ever be freed until the skbs have been
allocated and sent and allocated again to receive the ack).

Furthermore xpmem doesn't associate any pte to a spte, it associates a
page_t to certain remote references, or it would be in trouble with
invalidate_page that corresponds to ptep_clear_flush on a virtual
address that exists thanks to the anon_vma/i_mmap lock held (and not
thanks to the mmap_sem like in all invalidate_range calls).

Christoph's patch is a mix of two entirely separated features. KVM can
live with V7 just fine, but it's a lot more than what is needed by KVM.

I don't think that invalidate_page/age_page must be allowed to sleep
because invalidate_range also can sleep. You've to just ask yourself
if the VM locks shall remain spinlocks, for the VM own good (not for
the mmu notifiers good). It'd be bad to make the VM underperform with
mutex protecting tiny critical sections to please some mmu notifier
user. But if they're spinlocks, then clearly invalidate_page/age_page
based on virtual addresses can't sleep or the virtual address wouldn't
make sense anymore by the time the spinlock is released.

> > This function looks like it was tossed in at the last minute.  It's
> > mysterious, undocumented, poorly commented, poorly named.  A better name
> > would be one which has some correlation with the return value.
> > 
> > Because anyone who looks at some code which does
> > 
> > 	if (mmu_notifier_age_page(mm, address))
> > 		...
> > 
> > has to go and reverse-engineer the implementation of
> > mmu_notifier_age_page() to work out under which circumstances the "..."
> > will be executed.  But this should be apparent just from reading the callee
> > implementation.
> > 
> > This function *really* does need some documentation.  What does it *mean*
> > when the ->age_page() from some of the notifiers returned "1" and the
> > ->age_page() from some other notifiers returned zero?  Dunno.
> 
> Andrea: Could you provide some more detail here?

age_page is simply the ptep_clear_flush_young equivalent for
sptes. It's meant to provide aging to the pages mapped by secondary
mmus. Its return value is the same one of ptep_clear_flush_young but
it represents the sptes associated with the pte,
ptep_clear_flush_young instead only takes care of the pte itself.

For KVM the below would be all that is needed, the fact
invalidate_range can sleep and invalidate_page/age_page can't, is
because their users are very different. With my approach the mmu
notifiers callback are always protected by the PT lock (just like
ptep_clear_flush and the other pte+tlb manglings) and they're called
after the pte is cleared and before the VM reference on the page has
been dropped. That makes it safe for GRU too, so for my initial
approach _none_ of the callbacks was allowed to sleep, and that was a
feature that allows GRU not to block its tlb miss interrupt with any
further locking (the PT-lock taken by follow_page automatically
serialized the GRU interrupt against the MMU notifiers and the linux
page fault). For KVM the invalidate_pages of my patch is converted to
invalidate_range_end because it doesn't matter for KVM if it's called
after the PT lock has been dropped. In the try_to_unmap case
invalidate_page is called by atomic context in Christoph's patch too,
because a virtual address and in turn a pte and in turn certain sptes,
can only exist thanks to the spinlocks taken by the VM. Changing the
VM to make mmu notifiers sleepable in the try_to_unmap path sounds bad
to me, especially given not even xpmem needs this.

You can see how everything looks simpler and more symmetric by
assuming the secondary mmu-references are established and dropped like
ptes, like in the KVM case where infact sptes are a pure cpu thing
exact like the ptes. XPMEM adds the requirement that sptes are infact
remote entities that are mangled by a message passing protocol over
the network, it's the same as ptep_clear_flush being required to
schedule and send skbs to be successful and allowing try_to_unmap to
do its work. Same problem. No wonder patch gets more complicated then.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -46,6 +46,7 @@
 	__young = ptep_test_and_clear_young(__vma, __address, __ptep);	\
 	if (__young)							\
 		flush_tlb_page(__vma, __address);			\
+	__young |= mmu_notifier_age_page((__vma)->vm_mm, __address);	\
 	__young;							\
 })
 #endif
@@ -86,6 +87,7 @@ do {									\
 	pte_t __pte;							\
 	__pte = ptep_get_and_clear((__vma)->vm_mm, __address, __ptep);	\
 	flush_tlb_page(__vma, __address);				\
+	mmu_notifier(invalidate_page, (__vma)->vm_mm, __address);	\
 	__pte;								\
 })
 #endif
diff --git a/include/asm-s390/pgtable.h b/include/asm-s390/pgtable.h
--- a/include/asm-s390/pgtable.h
+++ b/include/asm-s390/pgtable.h
@@ -712,6 +712,7 @@ static inline pte_t ptep_clear_flush(str
 {
 	pte_t pte = *ptep;
 	ptep_invalidate(address, ptep);
+	mmu_notifier(invalidate_page, vma->vm_mm, address);
 	return pte;
 }
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -10,6 +10,7 @@
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
 #include <linux/completion.h>
+#include <linux/mmu_notifier.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -219,6 +220,8 @@ struct mm_struct {
 	/* aio bits */
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
+
+	struct mmu_notifier_head mmu_notifier; /* MMU notifier list */
 };
 
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
new file mode 100644
--- /dev/null
+++ b/include/linux/mmu_notifier.h
@@ -0,0 +1,132 @@
+#ifndef _LINUX_MMU_NOTIFIER_H
+#define _LINUX_MMU_NOTIFIER_H
+
+#include <linux/list.h>
+#include <linux/spinlock.h>
+
+struct mmu_notifier;
+
+struct mmu_notifier_ops {
+	/*
+	 * Called when nobody can register any more notifier in the mm
+	 * and after the "mn" notifier has been disarmed already.
+	 */
+	void (*release)(struct mmu_notifier *mn,
+			struct mm_struct *mm);
+
+	/*
+	 * invalidate_page[s] is called in atomic context
+	 * after any pte has been updated and before
+	 * dropping the PT lock required to update any Linux pte.
+	 * Once the PT lock will be released the pte will have its
+	 * final value to export through the secondary MMU.
+	 * Before this is invoked any secondary MMU is still ok
+	 * to read/write to the page previously pointed by the
+	 * Linux pte because the old page hasn't been freed yet.
+	 * If required set_page_dirty has to be called internally
+	 * to this method.
+	 */
+	void (*invalidate_page)(struct mmu_notifier *mn,
+				struct mm_struct *mm,
+				unsigned long address);
+	void (*invalidate_pages)(struct mmu_notifier *mn,
+				 struct mm_struct *mm,
+				 unsigned long start, unsigned long end);
+
+	/*
+	 * Age page is called in atomic context inside the PT lock
+	 * right after the VM is test-and-clearing the young/accessed
+	 * bitflag in the pte. This way the VM will provide proper aging
+	 * to the accesses to the page through the secondary MMUs
+	 * and not only to the ones through the Linux pte.
+	 */
+	int (*age_page)(struct mmu_notifier *mn,
+			struct mm_struct *mm,
+			unsigned long address);
+};
+
+struct mmu_notifier {
+	struct hlist_node hlist;
+	const struct mmu_notifier_ops *ops;
+};
+
+#ifdef CONFIG_MMU_NOTIFIER
+
+struct mmu_notifier_head {
+	struct hlist_head head;
+	spinlock_t lock;
+};
+
+#include <linux/mm_types.h>
+
+/*
+ * RCU is used to traverse the list. A quiescent period needs to pass
+ * before the notifier is guaranteed to be visible to all threads.
+ */
+extern void mmu_notifier_register(struct mmu_notifier *mn,
+				  struct mm_struct *mm);
+/*
+ * RCU is used to traverse the list. A quiescent period needs to pass
+ * before the "struct mmu_notifier" can be freed. Alternatively it
+ * can be synchronously freed inside ->release when the list can't
+ * change anymore and nobody could possibly walk it.
+ */
+extern void mmu_notifier_unregister(struct mmu_notifier *mn,
+				    struct mm_struct *mm);
+extern void mmu_notifier_release(struct mm_struct *mm);
+extern int mmu_notifier_age_page(struct mm_struct *mm,
+				 unsigned long address);
+
+static inline void mmu_notifier_head_init(struct mmu_notifier_head *mnh)
+{
+	INIT_HLIST_HEAD(&mnh->head);
+	spin_lock_init(&mnh->lock);
+}
+
+#define mmu_notifier(function, mm, args...)				\
+	do {								\
+		struct mmu_notifier *__mn;				\
+		struct hlist_node *__n;					\
+									\
+		if (unlikely(!hlist_empty(&(mm)->mmu_notifier.head))) { \
+			rcu_read_lock();				\
+			hlist_for_each_entry_rcu(__mn, __n,		\
+						 &(mm)->mmu_notifier.head, \
+						 hlist)			\
+				if (__mn->ops->function)		\
+					__mn->ops->function(__mn,	\
+							    mm,		\
+							    args);	\
+			rcu_read_unlock();				\
+		}							\
+	} while (0)
+
+#else /* CONFIG_MMU_NOTIFIER */
+
+struct mmu_notifier_head {};
+
+#define mmu_notifier_register(mn, mm) do {} while(0)
+#define mmu_notifier_unregister(mn, mm) do {} while (0)
+#define mmu_notifier_release(mm) do {} while (0)
+#define mmu_notifier_age_page(mm, address) ({ 0; })
+#define mmu_notifier_head_init(mmh) do {} while (0)
+
+/*
+ * Notifiers that use the parameters that they were passed so that the
+ * compiler does not complain about unused variables but does proper
+ * parameter checks even if !CONFIG_MMU_NOTIFIER.
+ * Macros generate no code.
+ */
+#define mmu_notifier(function, mm, args...)			       \
+	do {							       \
+		if (0) {					       \
+			struct mmu_notifier *__mn;		       \
+								       \
+			__mn = (struct mmu_notifier *)(0x00ff);	       \
+			__mn->ops->function(__mn, mm, args);	       \
+		};						       \
+	} while (0)
+
+#endif /* CONFIG_MMU_NOTIFIER */
+
+#endif /* _LINUX_MMU_NOTIFIER_H */
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -360,6 +360,7 @@ static struct mm_struct * mm_init(struct
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
+		mmu_notifier_head_init(&mm->mmu_notifier);
 		return mm;
 	}
 	free_mm(mm);
diff --git a/mm/Kconfig b/mm/Kconfig
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -193,3 +193,7 @@ config VIRT_TO_BUS
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config MMU_NOTIFIER
+	def_bool y
+	bool "MMU notifier, for paging KVM/RDMA"
diff --git a/mm/Makefile b/mm/Makefile
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -30,4 +30,5 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
+obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -756,6 +756,7 @@ void __unmap_hugepage_range(struct vm_ar
 		if (pte_none(pte))
 			continue;
 
+		mmu_notifier(invalidate_page, mm, address);
 		page = pte_page(pte);
 		if (pte_dirty(pte))
 			set_page_dirty(page);
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -494,6 +494,7 @@ static int copy_pte_range(struct mm_stru
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
 	int rss[2];
+	unsigned long start;
 
 again:
 	rss[1] = rss[0] = 0;
@@ -505,6 +506,7 @@ again:
 	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
 	arch_enter_lazy_mmu_mode();
 
+	start = addr;
 	do {
 		/*
 		 * We are holding two locks at this point - either of them
@@ -525,6 +527,8 @@ again:
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
 	arch_leave_lazy_mmu_mode();
+	if (is_cow_mapping(vma->vm_flags))
+		mmu_notifier(invalidate_pages, vma->vm_mm, start, addr);
 	spin_unlock(src_ptl);
 	pte_unmap_nested(src_pte - 1);
 	add_mm_rss(dst_mm, rss[0], rss[1]);
@@ -660,6 +664,7 @@ static unsigned long zap_pte_range(struc
 			}
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
+			mmu_notifier(invalidate_page, mm, addr);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 			if (unlikely(!page))
 				continue;
@@ -1248,6 +1253,7 @@ static int remap_pte_range(struct mm_str
 {
 	pte_t *pte;
 	spinlock_t *ptl;
+	unsigned long start = addr;
 
 	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)
@@ -1259,6 +1265,7 @@ static int remap_pte_range(struct mm_str
 		pfn++;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
+	mmu_notifier(invalidate_pages, mm, start, addr);
 	pte_unmap_unlock(pte - 1, ptl);
 	return 0;
 }
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2044,6 +2044,7 @@ void exit_mmap(struct mm_struct *mm)
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
+	mmu_notifier_release(mm);
 
 	/*
 	 * Walk the list again, actually closing and freeing it,
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
new file mode 100644
--- /dev/null
+++ b/mm/mmu_notifier.c
@@ -0,0 +1,73 @@
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
+#include <linux/rcupdate.h>
+
+/*
+ * No synchronization. This function can only be called when only a single
+ * process remains that performs teardown.
+ */
+void mmu_notifier_release(struct mm_struct *mm)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n, *tmp;
+
+	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
+		hlist_for_each_entry_safe(mn, n, tmp,
+					  &mm->mmu_notifier.head, hlist) {
+			hlist_del(&mn->hlist);
+			if (mn->ops->release)
+				mn->ops->release(mn, mm);
+		}
+	}
+}
+
+/*
+ * If no young bitflag is supported by the hardware, ->age_page can
+ * unmap the address and return 1 or 0 depending if the mapping previously
+ * existed or not.
+ */
+int mmu_notifier_age_page(struct mm_struct *mm, unsigned long address)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+	int young = 0;
+
+	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
+		rcu_read_lock();
+		hlist_for_each_entry_rcu(mn, n,
+					 &mm->mmu_notifier.head, hlist) {
+			if (mn->ops->age_page)
+				young |= mn->ops->age_page(mn, mm, address);
+		}
+		rcu_read_unlock();
+	}
+
+	return young;
+}
+
+void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	spin_lock(&mm->mmu_notifier.lock);
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier.head);
+	spin_unlock(&mm->mmu_notifier.lock);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_register);
+
+void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	spin_lock(&mm->mmu_notifier.lock);
+	hlist_del_rcu(&mn->hlist);
+	spin_unlock(&mm->mmu_notifier.lock);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
diff --git a/mm/mprotect.c b/mm/mprotect.c
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -32,6 +32,7 @@ static void change_pte_range(struct mm_s
 {
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
+	unsigned long start = addr;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -71,6 +72,7 @@ static void change_pte_range(struct mm_s
 
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
+	mmu_notifier(invalidate_pages, mm, start, addr);
 	pte_unmap_unlock(pte - 1, ptl);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

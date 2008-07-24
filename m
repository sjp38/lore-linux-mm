Date: Thu, 24 Jul 2008 16:39:49 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: MMU notifiers review and some proposals
Message-ID: <20080724143949.GB12897@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, andrea@qumranet.com, steiner@sgi.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi,

I think everybody is hoping to have a workable mmu notifier scheme
merged in 2.6.27 (myself included). However I do have some concerns
about the implementation proposed (in -mm).

I apologise for this late review, before anybody gets too upset,
most of my concerns have been raised before, but I'd like to state
my case again and involving everyone.

So my concerns.

Firstly, mm_take_all_locks I dislike. Although it isn't too complex
and quite well contained, it unfortunately somewhat ties our hands a
bit when it comes to changing the fastpath locking. For exmple, it
might make it difficult to remove the locks from rmap walks now (not
that there aren't plenty of other difficulties, but as an example).

I also think we should be cautious to make this slowpath so horribly
slow. For KVM it's fine, but perhaps for GRU we'd actually want to
register quite a lot of notifiers, unregister them, and perhaps even
do per-vma registrations if we don't want to slow down other memory
management operations too much (eg. if it is otherwise just some
regular processes just doing accelerated things with GRU).

I think it is possible to come up with a pretty good implementation
that replaces mm_take_all_locks with something faster and using less
locks, I haven't quite got a detailed sketch yet, but if anyone is
interested, let me know.

However, I think the whole reason for take_all_locks is to support
the invalidate_range_begin/invalidate_range_end callbacks. I think
these are slightly odd because they introduce a 2nd design of TLB
shootdown scheme to the kernel: presently we downgrade pte
permissions, and then shootdown TLBs, and then free any pages;
the range callbacks first prevent new TLBs being set up, then shoot
down existing TLBs, then downgrade ptes, then free pages.

That's not to say this style will not work, but I prefer to keep
to our existing scheme. Obviously it is better proven, and also
it is good to have fewer if possible.

What are the pros of the new scheme? Well performance AFAIKS.
Large unmappings may not fit in the TLB gather API (and some
sites do not use TLB gather at all), but with the
invalidate_range_begin/invalidate_range_end we can still flush
the entire range in 1 call.

I would counter that our existing CPU flushing has held up fairly
well, and it can also be pretty expensive if it has to do lots of
IPIs. I don't have a problem with trying to maximise performance,
but I really feel this is one place where I'd prefer to see
numbers first.

One functional con of the invalidate_range_begin/invalidate_range_end
style I see is that the implementations hold off new TLB insertions
by incrementing a counter to hold them off. So actually poor
parallelism or starvation could become an issue with multiple
threads.


So anyway, I've attached a patch switching mmu notifiers to the
our traditional style of TLB invalidation, and attempted to
convert KVM and GRU to use it. Also keep in mind that after this
the mm_take_all_locks patches should not be needed. Unfortunately
I was not able to actually test this (but testing typically would not
find the rally subtle problems easily anyway)

---
 drivers/misc/sgi-gru/grufault.c    |  145 ++++---------------------------------
 drivers/misc/sgi-gru/grutables.h   |    1 
 drivers/misc/sgi-gru/grutlbpurge.c |   37 +--------
 include/linux/kvm_host.h           |   10 --
 include/linux/mmu_notifier.h       |   97 ++----------------------
 mm/fremap.c                        |    4 -
 mm/hugetlb.c                       |    3 
 mm/memory.c                        |   18 ++--
 mm/mmap.c                          |    2 
 mm/mmu_notifier.c                  |   43 +---------
 mm/mprotect.c                      |    3 
 mm/mremap.c                        |    4 -
 virt/kvm/kvm_main.c                |   65 +---------------
 13 files changed, 61 insertions(+), 371 deletions(-)

Index: linux-2.6/include/linux/mmu_notifier.h
===================================================================
--- linux-2.6.orig/include/linux/mmu_notifier.h
+++ linux-2.6/include/linux/mmu_notifier.h
@@ -65,60 +65,12 @@ struct mmu_notifier_ops {
 	 * Before this is invoked any secondary MMU is still ok to
 	 * read/write to the page previously pointed to by the Linux
 	 * pte because the page hasn't been freed yet and it won't be
-	 * freed until this returns. If required set_page_dirty has to
-	 * be called internally to this method.
+	 * freed until this returns. Also, importantly the address can't
+	 * be repopulated with some other page, so all MMUs retain a
+	 * coherent view of memory. If required set_page_dirty has to
+	 * be called internally to this method. Not optional.
 	 */
-	void (*invalidate_page)(struct mmu_notifier *mn,
-				struct mm_struct *mm,
-				unsigned long address);
-
-	/*
-	 * invalidate_range_start() and invalidate_range_end() must be
-	 * paired and are called only when the mmap_sem and/or the
-	 * locks protecting the reverse maps are held. The subsystem
-	 * must guarantee that no additional references are taken to
-	 * the pages in the range established between the call to
-	 * invalidate_range_start() and the matching call to
-	 * invalidate_range_end().
-	 *
-	 * Invalidation of multiple concurrent ranges may be
-	 * optionally permitted by the driver. Either way the
-	 * establishment of sptes is forbidden in the range passed to
-	 * invalidate_range_begin/end for the whole duration of the
-	 * invalidate_range_begin/end critical section.
-	 *
-	 * invalidate_range_start() is called when all pages in the
-	 * range are still mapped and have at least a refcount of one.
-	 *
-	 * invalidate_range_end() is called when all pages in the
-	 * range have been unmapped and the pages have been freed by
-	 * the VM.
-	 *
-	 * The VM will remove the page table entries and potentially
-	 * the page between invalidate_range_start() and
-	 * invalidate_range_end(). If the page must not be freed
-	 * because of pending I/O or other circumstances then the
-	 * invalidate_range_start() callback (or the initial mapping
-	 * by the driver) must make sure that the refcount is kept
-	 * elevated.
-	 *
-	 * If the driver increases the refcount when the pages are
-	 * initially mapped into an address space then either
-	 * invalidate_range_start() or invalidate_range_end() may
-	 * decrease the refcount. If the refcount is decreased on
-	 * invalidate_range_start() then the VM can free pages as page
-	 * table entries are removed.  If the refcount is only
-	 * droppped on invalidate_range_end() then the driver itself
-	 * will drop the last refcount but it must take care to flush
-	 * any secondary tlb before doing the final free on the
-	 * page. Pages will no longer be referenced by the linux
-	 * address space but may still be referenced by sptes until
-	 * the last refcount is dropped.
-	 */
-	void (*invalidate_range_start)(struct mmu_notifier *mn,
-				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end);
-	void (*invalidate_range_end)(struct mmu_notifier *mn,
+	void (*invalidate_range)(struct mmu_notifier *mn,
 				     struct mm_struct *mm,
 				     unsigned long start, unsigned long end);
 };
@@ -154,11 +106,7 @@ extern void __mmu_notifier_mm_destroy(st
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long address);
-extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address);
-extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end);
-extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
@@ -175,25 +123,11 @@ static inline int mmu_notifier_clear_flu
 	return 0;
 }
 
-static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
-{
-	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_page(mm, address);
-}
-
-static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
+static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, start, end);
-}
-
-static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
-{
-	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_end(mm, start, end);
+		__mmu_notifier_invalidate_range(mm, start, end);
 }
 
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
@@ -221,7 +155,8 @@ static inline void mmu_notifier_mm_destr
 	struct vm_area_struct *___vma = __vma;				\
 	unsigned long ___address = __address;				\
 	__pte = ptep_clear_flush(___vma, ___address, __ptep);		\
-	mmu_notifier_invalidate_page(___vma->vm_mm, ___address);	\
+	mmu_notifier_invalidate_range(___vma->vm_mm, ___address,	\
+					____address + PAGE_SIZE);	\
 	__pte;								\
 })
 
@@ -248,17 +183,7 @@ static inline int mmu_notifier_clear_flu
 	return 0;
 }
 
-static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
-{
-}
-
-static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
-{
-}
-
-static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
 }
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c
+++ linux-2.6/mm/fremap.c
@@ -32,7 +32,7 @@ static void zap_pte(struct mm_struct *mm
 		struct page *page;
 
 		flush_cache_page(vma, addr, pte_pfn(pte));
-		pte = ptep_clear_flush(vma, addr, ptep);
+		pte = ptep_clear_flush_notify(vma, addr, ptep);
 		page = vm_normal_page(vma, addr, pte);
 		if (page) {
 			if (pte_dirty(pte))
@@ -226,9 +226,7 @@ asmlinkage long sys_remap_file_pages(uns
 		vma->vm_flags = saved_flags;
 	}
 
-	mmu_notifier_invalidate_range_start(mm, start, start + size);
 	err = populate_range(mm, vma, start, size, pgoff);
-	mmu_notifier_invalidate_range_end(mm, start, start + size);
 	if (!err && !(flags & MAP_NONBLOCK)) {
 		if (vma->vm_flags & VM_LOCKED) {
 			/*
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -1683,7 +1683,6 @@ void __unmap_hugepage_range(struct vm_ar
 	BUG_ON(start & ~huge_page_mask(h));
 	BUG_ON(end & ~huge_page_mask(h));
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address);
@@ -1725,7 +1724,7 @@ void __unmap_hugepage_range(struct vm_ar
 	}
 	spin_unlock(&mm->page_table_lock);
 	flush_tlb_range(vma, start, end);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	mmu_notifier_invalidate_range(mm, start, end);
 	list_for_each_entry_safe(page, tmp, &page_list, lru) {
 		list_del(&page->lru);
 		put_page(page);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -677,9 +677,6 @@ int copy_page_range(struct mm_struct *ds
 	 * parent mm. And a permission downgrade will only happen if
 	 * is_cow_mapping() returns true.
 	 */
-	if (is_cow_mapping(vma->vm_flags))
-		mmu_notifier_invalidate_range_start(src_mm, addr, end);
-
 	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
 	src_pgd = pgd_offset(src_mm, addr);
@@ -695,8 +692,8 @@ int copy_page_range(struct mm_struct *ds
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
 	if (is_cow_mapping(vma->vm_flags))
-		mmu_notifier_invalidate_range_end(src_mm,
-						  vma->vm_start, end);
+		mmu_notifier_invalidate_range(src_mm, vma->vm_start, end);
+
 	return ret;
 }
 
@@ -903,7 +900,6 @@ unsigned long unmap_vmas(struct mmu_gath
 	int fullmm = (*tlbp)->fullmm;
 	struct mm_struct *mm = vma->vm_mm;
 
-	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
 		unsigned long end;
 
@@ -951,6 +947,7 @@ unsigned long unmap_vmas(struct mmu_gath
 				break;
 			}
 
+			mmu_notifier_invalidate_range(mm, tlb_start, start);
 			tlb_finish_mmu(*tlbp, tlb_start, start);
 
 			if (need_resched() ||
@@ -968,7 +965,6 @@ unsigned long unmap_vmas(struct mmu_gath
 		}
 	}
 out:
-	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
 	return start;	/* which is now the end (or restart) address */
 }
 
@@ -991,8 +987,10 @@ unsigned long zap_page_range(struct vm_a
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
 	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
-	if (tlb)
+	if (tlb) {
+		mmu_notifier_invalidate_range(mm, address, end);
 		tlb_finish_mmu(tlb, address, end);
+	}
 	return end;
 }
 EXPORT_SYMBOL_GPL(zap_page_range);
@@ -1668,7 +1666,6 @@ int apply_to_page_range(struct mm_struct
 	int err;
 
 	BUG_ON(addr >= end);
-	mmu_notifier_invalidate_range_start(mm, start, end);
 	pgd = pgd_offset(mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1676,7 +1673,8 @@ int apply_to_page_range(struct mm_struct
 		if (err)
 			break;
 	} while (pgd++, addr = next, addr != end);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	mmu_notifier_invalidate_range(mm, start, end);
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -1794,6 +1794,7 @@ static void unmap_region(struct mm_struc
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
+	mmu_notifier_invalidate_range(mm, start, end);
 	tlb_finish_mmu(tlb, start, end);
 }
 
@@ -2123,6 +2124,7 @@ void exit_mmap(struct mm_struct *mm)
 	vm_unacct_memory(nr_accounted);
 	memrlimit_cgroup_uncharge_as(mm, mm->total_vm);
 	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
+	mmu_notifier_invalidate_range(mm, 0, end);
 	tlb_finish_mmu(tlb, 0, end);
 
 	/*
Index: linux-2.6/mm/mmu_notifier.c
===================================================================
--- linux-2.6.orig/mm/mmu_notifier.c
+++ linux-2.6/mm/mmu_notifier.c
@@ -99,45 +99,15 @@ int __mmu_notifier_clear_flush_young(str
 	return young;
 }
 
-void __mmu_notifier_invalidate_page(struct mm_struct *mm,
-					  unsigned long address)
-{
-	struct mmu_notifier *mn;
-	struct hlist_node *n;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
-		if (mn->ops->invalidate_page)
-			mn->ops->invalidate_page(mn, mm, address);
-	}
-	rcu_read_unlock();
-}
-
-void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
-{
-	struct mmu_notifier *mn;
-	struct hlist_node *n;
-
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
-		if (mn->ops->invalidate_range_start)
-			mn->ops->invalidate_range_start(mn, mm, start, end);
-	}
-	rcu_read_unlock();
-}
-
-void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
+void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
-		if (mn->ops->invalidate_range_end)
-			mn->ops->invalidate_range_end(mn, mm, start, end);
-	}
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist)
+		mn->ops->invalidate_range(mn, mm, start, end);
 	rcu_read_unlock();
 }
 
@@ -148,6 +118,8 @@ static int do_mmu_notifier_register(stru
 	struct mmu_notifier_mm *mmu_notifier_mm;
 	int ret;
 
+	BUG_ON(!mn->ops);
+	BUG_ON(!mn->ops->invalidate_range);
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
 	ret = -ENOMEM;
@@ -157,9 +129,6 @@ static int do_mmu_notifier_register(stru
 
 	if (take_mmap_sem)
 		down_write(&mm->mmap_sem);
-	ret = mm_take_all_locks(mm);
-	if (unlikely(ret))
-		goto out_cleanup;
 
 	if (!mm_has_notifiers(mm)) {
 		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
@@ -181,8 +150,6 @@ static int do_mmu_notifier_register(stru
 	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
-	mm_drop_all_locks(mm);
-out_cleanup:
 	if (take_mmap_sem)
 		up_write(&mm->mmap_sem);
 	/* kfree() does nothing if mmu_notifier_mm is NULL */
Index: linux-2.6/mm/mprotect.c
===================================================================
--- linux-2.6.orig/mm/mprotect.c
+++ linux-2.6/mm/mprotect.c
@@ -204,12 +204,11 @@ success:
 		dirty_accountable = 1;
 	}
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
 	if (is_vm_hugetlb_page(vma))
 		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
 	else
 		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	mmu_notifier_invalidate_range(mm, start, end);
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
 	return 0;
Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c
+++ linux-2.6/mm/mremap.c
@@ -81,8 +81,6 @@ static void move_ptes(struct vm_area_str
 	unsigned long old_start;
 
 	old_start = old_addr;
-	mmu_notifier_invalidate_range_start(vma->vm_mm,
-					    old_start, old_end);
 	if (vma->vm_file) {
 		/*
 		 * Subtle point from Rajesh Venkatasubramanian: before
@@ -124,7 +122,7 @@ static void move_ptes(struct vm_area_str
 	pte_unmap_unlock(old_pte - 1, old_ptl);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
-	mmu_notifier_invalidate_range_end(vma->vm_mm, old_start, old_end);
+	mmu_notifier_invalidate_range(vma->vm_mm, old_start, old_end);
 }
 
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
Index: linux-2.6/virt/kvm/kvm_main.c
===================================================================
--- linux-2.6.orig/virt/kvm/kvm_main.c
+++ linux-2.6/virt/kvm/kvm_main.c
@@ -192,13 +192,15 @@ static inline struct kvm *mmu_notifier_t
 	return container_of(mn, struct kvm, mmu_notifier);
 }
 
-static void kvm_mmu_notifier_invalidate_page(struct mmu_notifier *mn,
-					     struct mm_struct *mm,
-					     unsigned long address)
+static void kvm_mmu_notifier_invalidate_range(struct mmu_notifier *mn,
+						    struct mm_struct *mm,
+						    unsigned long start,
+						    unsigned long end)
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
-	int need_tlb_flush;
+	int need_tlb_flush = 0;
 
+	spin_lock(&kvm->mmu_lock);
 	/*
 	 * When ->invalidate_page runs, the linux pte has been zapped
 	 * already but the page is still allocated until
@@ -217,32 +219,7 @@ static void kvm_mmu_notifier_invalidate_
 	 * pte after kvm_unmap_hva returned, without noticing the page
 	 * is going to be freed.
 	 */
-	spin_lock(&kvm->mmu_lock);
 	kvm->mmu_notifier_seq++;
-	need_tlb_flush = kvm_unmap_hva(kvm, address);
-	spin_unlock(&kvm->mmu_lock);
-
-	/* we've to flush the tlb before the pages can be freed */
-	if (need_tlb_flush)
-		kvm_flush_remote_tlbs(kvm);
-
-}
-
-static void kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
-						    struct mm_struct *mm,
-						    unsigned long start,
-						    unsigned long end)
-{
-	struct kvm *kvm = mmu_notifier_to_kvm(mn);
-	int need_tlb_flush = 0;
-
-	spin_lock(&kvm->mmu_lock);
-	/*
-	 * The count increase must become visible at unlock time as no
-	 * spte can be established without taking the mmu_lock and
-	 * count is also read inside the mmu_lock critical section.
-	 */
-	kvm->mmu_notifier_count++;
 	for (; start < end; start += PAGE_SIZE)
 		need_tlb_flush |= kvm_unmap_hva(kvm, start);
 	spin_unlock(&kvm->mmu_lock);
@@ -252,32 +229,6 @@ static void kvm_mmu_notifier_invalidate_
 		kvm_flush_remote_tlbs(kvm);
 }
 
-static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
-						  struct mm_struct *mm,
-						  unsigned long start,
-						  unsigned long end)
-{
-	struct kvm *kvm = mmu_notifier_to_kvm(mn);
-
-	spin_lock(&kvm->mmu_lock);
-	/*
-	 * This sequence increase will notify the kvm page fault that
-	 * the page that is going to be mapped in the spte could have
-	 * been freed.
-	 */
-	kvm->mmu_notifier_seq++;
-	/*
-	 * The above sequence increase must be visible before the
-	 * below count decrease but both values are read by the kvm
-	 * page fault under mmu_lock spinlock so we don't need to add
-	 * a smb_wmb() here in between the two.
-	 */
-	kvm->mmu_notifier_count--;
-	spin_unlock(&kvm->mmu_lock);
-
-	BUG_ON(kvm->mmu_notifier_count < 0);
-}
-
 static int kvm_mmu_notifier_clear_flush_young(struct mmu_notifier *mn,
 					      struct mm_struct *mm,
 					      unsigned long address)
@@ -296,9 +247,7 @@ static int kvm_mmu_notifier_clear_flush_
 }
 
 static const struct mmu_notifier_ops kvm_mmu_notifier_ops = {
-	.invalidate_page	= kvm_mmu_notifier_invalidate_page,
-	.invalidate_range_start	= kvm_mmu_notifier_invalidate_range_start,
-	.invalidate_range_end	= kvm_mmu_notifier_invalidate_range_end,
+	.invalidate_range	= kvm_mmu_notifier_invalidate_range,
 	.clear_flush_young	= kvm_mmu_notifier_clear_flush_young,
 };
 #endif /* CONFIG_MMU_NOTIFIER && KVM_ARCH_WANT_MMU_NOTIFIER */
Index: linux-2.6/drivers/misc/sgi-gru/grufault.c
===================================================================
--- linux-2.6.orig/drivers/misc/sgi-gru/grufault.c
+++ linux-2.6/drivers/misc/sgi-gru/grufault.c
@@ -195,74 +195,29 @@ static void get_clear_fault_map(struct g
  * 		< 0 - error code
  * 		  1 - (atomic only) try again in non-atomic context
  */
-static int non_atomic_pte_lookup(struct vm_area_struct *vma,
-				 unsigned long vaddr, int write,
+static int non_atomic_pte_lookup(unsigned long vaddr, int write,
 				 unsigned long *paddr, int *pageshift)
 {
 	struct page *page;
+	int ret;
 
 	/* ZZZ Need to handle HUGE pages */
-	if (is_vm_hugetlb_page(vma))
-		return -EFAULT;
 	*pageshift = PAGE_SHIFT;
-	if (get_user_pages
-	    (current, current->mm, vaddr, 1, write, 0, &page, NULL) <= 0)
+	ret = get_user_pages(current, current->mm, vaddr, 1, write, 0,
+						&page, NULL);
+	if (ret < 0)
+		return ret;
+	if (ret == 0)
 		return -EFAULT;
+	if (PageCompound(page)) { /* hugepage */
+		put_page(page);
+		return -EFAULT;
+	}
+
 	*paddr = page_to_phys(page);
 	put_page(page);
-	return 0;
-}
-
-/*
- *
- * atomic_pte_lookup
- *
- * Convert a user virtual address to a physical address
- * Only supports Intel large pages (2MB only) on x86_64.
- *	ZZZ - hugepage support is incomplete
- */
-static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
-	int write, unsigned long *paddr, int *pageshift)
-{
-	pgd_t *pgdp;
-	pmd_t *pmdp;
-	pud_t *pudp;
-	pte_t pte;
-
-	WARN_ON(irqs_disabled());		/* ZZZ debug */
-
-	local_irq_disable();
-	pgdp = pgd_offset(vma->vm_mm, vaddr);
-	if (unlikely(pgd_none(*pgdp)))
-		goto err;
-
-	pudp = pud_offset(pgdp, vaddr);
-	if (unlikely(pud_none(*pudp)))
-		goto err;
-
-	pmdp = pmd_offset(pudp, vaddr);
-	if (unlikely(pmd_none(*pmdp)))
-		goto err;
-#ifdef CONFIG_X86_64
-	if (unlikely(pmd_large(*pmdp)))
-		pte = *(pte_t *) pmdp;
-	else
-#endif
-		pte = *pte_offset_kernel(pmdp, vaddr);
-
-	local_irq_enable();
-
-	if (unlikely(!pte_present(pte) ||
-		     (write && (!pte_write(pte) || !pte_dirty(pte)))))
-		return 1;
 
-	*paddr = pte_pfn(pte) << PAGE_SHIFT;
-	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
 	return 0;
-
-err:
-	local_irq_enable();
-	return 1;
 }
 
 /*
@@ -279,9 +234,7 @@ static int gru_try_dropin(struct gru_thr
 			  struct gru_tlb_fault_handle *tfh,
 			  unsigned long __user *cb)
 {
-	struct mm_struct *mm = gts->ts_mm;
-	struct vm_area_struct *vma;
-	int pageshift, asid, write, ret;
+	int pageshift, asid, write;
 	unsigned long paddr, gpa, vaddr;
 
 	/*
@@ -298,7 +251,7 @@ static int gru_try_dropin(struct gru_thr
 	 */
 	if (tfh->state == TFHSTATE_IDLE)
 		goto failidle;
-	if (tfh->state == TFHSTATE_MISS_FMM && cb)
+	if (tfh->state == TFHSTATE_MISS_FMM)
 		goto failfmm;
 
 	write = (tfh->cause & TFHCAUSE_TLB_MOD) != 0;
@@ -307,31 +260,9 @@ static int gru_try_dropin(struct gru_thr
 	if (asid == 0)
 		goto failnoasid;
 
-	rmb();	/* TFH must be cache resident before reading ms_range_active */
-
-	/*
-	 * TFH is cache resident - at least briefly. Fail the dropin
-	 * if a range invalidate is active.
-	 */
-	if (atomic_read(&gts->ts_gms->ms_range_active))
-		goto failactive;
-
-	vma = find_vma(mm, vaddr);
-	if (!vma)
+	if (non_atomic_pte_lookup(vaddr, write, &paddr, &pageshift))
 		goto failinval;
 
-	/*
-	 * Atomic lookup is faster & usually works even if called in non-atomic
-	 * context.
-	 */
-	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &pageshift);
-	if (ret) {
-		if (!cb)
-			goto failupm;
-		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr,
-					  &pageshift))
-			goto failinval;
-	}
 	if (is_gru_paddr(paddr))
 		goto failinval;
 
@@ -351,19 +282,9 @@ failnoasid:
 	/* No asid (delayed unload). */
 	STAT(tlb_dropin_fail_no_asid);
 	gru_dbg(grudev, "FAILED no_asid tfh: 0x%p, vaddr 0x%lx\n", tfh, vaddr);
-	if (!cb)
-		tfh_user_polling_mode(tfh);
-	else
-		gru_flush_cache(tfh);
+	gru_flush_cache(tfh);
 	return -EAGAIN;
 
-failupm:
-	/* Atomic failure switch CBR to UPM */
-	tfh_user_polling_mode(tfh);
-	STAT(tlb_dropin_fail_upm);
-	gru_dbg(grudev, "FAILED upm tfh: 0x%p, vaddr 0x%lx\n", tfh, vaddr);
-	return 1;
-
 failfmm:
 	/* FMM state on UPM call */
 	STAT(tlb_dropin_fail_fmm);
@@ -373,8 +294,7 @@ failfmm:
 failidle:
 	/* TFH was idle  - no miss pending */
 	gru_flush_cache(tfh);
-	if (cb)
-		gru_flush_cache(cb);
+	gru_flush_cache(cb);
 	STAT(tlb_dropin_fail_idle);
 	gru_dbg(grudev, "FAILED idle tfh: 0x%p, state %d\n", tfh, tfh->state);
 	return 0;
@@ -385,17 +305,6 @@ failinval:
 	STAT(tlb_dropin_fail_invalid);
 	gru_dbg(grudev, "FAILED inval tfh: 0x%p, vaddr 0x%lx\n", tfh, vaddr);
 	return -EFAULT;
-
-failactive:
-	/* Range invalidate active. Switch to UPM iff atomic */
-	if (!cb)
-		tfh_user_polling_mode(tfh);
-	else
-		gru_flush_cache(tfh);
-	STAT(tlb_dropin_fail_range_active);
-	gru_dbg(grudev, "FAILED range active: tfh 0x%p, vaddr 0x%lx\n",
-		tfh, vaddr);
-	return 1;
 }
 
 /*
@@ -408,9 +317,8 @@ irqreturn_t gru_intr(int irq, void *dev_
 {
 	struct gru_state *gru;
 	struct gru_tlb_fault_map map;
-	struct gru_thread_state *gts;
 	struct gru_tlb_fault_handle *tfh = NULL;
-	int cbrnum, ctxnum;
+	int cbrnum;
 
 	STAT(intr);
 
@@ -434,19 +342,7 @@ irqreturn_t gru_intr(int irq, void *dev_
 		 * The gts cannot change until a TFH start/writestart command
 		 * is issued.
 		 */
-		ctxnum = tfh->ctxnum;
-		gts = gru->gs_gts[ctxnum];
-
-		/*
-		 * This is running in interrupt context. Trylock the mmap_sem.
-		 * If it fails, retry the fault in user context.
-		 */
-		if (down_read_trylock(&gts->ts_mm->mmap_sem)) {
-			gru_try_dropin(gts, tfh, NULL);
-			up_read(&gts->ts_mm->mmap_sem);
-		} else {
-			tfh_user_polling_mode(tfh);
-		}
+		tfh_user_polling_mode(tfh);
 	}
 	return IRQ_HANDLED;
 }
@@ -456,12 +352,9 @@ static int gru_user_dropin(struct gru_th
 			   struct gru_tlb_fault_handle *tfh,
 			   unsigned long __user *cb)
 {
-	struct gru_mm_struct *gms = gts->ts_gms;
 	int ret;
 
 	while (1) {
-		wait_event(gms->ms_wait_queue,
-			   atomic_read(&gms->ms_range_active) == 0);
 		prefetchw(tfh);	/* Helps on hdw, required for emulator */
 		ret = gru_try_dropin(gts, tfh, cb);
 		if (ret <= 0)
Index: linux-2.6/drivers/misc/sgi-gru/grutables.h
===================================================================
--- linux-2.6.orig/drivers/misc/sgi-gru/grutables.h
+++ linux-2.6/drivers/misc/sgi-gru/grutables.h
@@ -244,7 +244,6 @@ struct gru_mm_struct {
 	struct mmu_notifier	ms_notifier;
 	atomic_t		ms_refcnt;
 	spinlock_t		ms_asid_lock;	/* protects ASID assignment */
-	atomic_t		ms_range_active;/* num range_invals active */
 	char			ms_released;
 	wait_queue_head_t	ms_wait_queue;
 	DECLARE_BITMAP(ms_asidmap, GRU_MAX_GRUS);
Index: linux-2.6/drivers/misc/sgi-gru/grutlbpurge.c
===================================================================
--- linux-2.6.orig/drivers/misc/sgi-gru/grutlbpurge.c
+++ linux-2.6/drivers/misc/sgi-gru/grutlbpurge.c
@@ -221,41 +221,16 @@ void gru_flush_all_tlb(struct gru_state 
 /*
  * MMUOPS notifier callout functions
  */
-static void gru_invalidate_range_start(struct mmu_notifier *mn,
-				       struct mm_struct *mm,
-				       unsigned long start, unsigned long end)
+static void gru_invalidate_range(struct mmu_notifier *mn, struct mm_struct *mm,
+				unsigned long start, unsigned long end)
 {
 	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
 						 ms_notifier);
 
-	STAT(mmu_invalidate_range);
-	atomic_inc(&gms->ms_range_active);
-	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx, act %d\n", gms,
-		start, end, atomic_read(&gms->ms_range_active));
-	gru_flush_tlb_range(gms, start, end - start);
-}
-
-static void gru_invalidate_range_end(struct mmu_notifier *mn,
-				     struct mm_struct *mm, unsigned long start,
-				     unsigned long end)
-{
-	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
-						 ms_notifier);
 
-	atomic_dec(&gms->ms_range_active);
-	wake_up_all(&gms->ms_wait_queue);
+	STAT(mmu_invalidate_range);
 	gru_dbg(grudev, "gms %p, start 0x%lx, end 0x%lx\n", gms, start, end);
-}
-
-static void gru_invalidate_page(struct mmu_notifier *mn, struct mm_struct *mm,
-				unsigned long address)
-{
-	struct gru_mm_struct *gms = container_of(mn, struct gru_mm_struct,
-						 ms_notifier);
-
-	STAT(mmu_invalidate_page);
-	gru_flush_tlb_range(gms, address, PAGE_SIZE);
-	gru_dbg(grudev, "gms %p, address 0x%lx\n", gms, address);
+	gru_flush_tlb_range(gms, start, end - start);
 }
 
 static void gru_release(struct mmu_notifier *mn, struct mm_struct *mm)
@@ -269,9 +244,7 @@ static void gru_release(struct mmu_notif
 
 
 static const struct mmu_notifier_ops gru_mmuops = {
-	.invalidate_page	= gru_invalidate_page,
-	.invalidate_range_start	= gru_invalidate_range_start,
-	.invalidate_range_end	= gru_invalidate_range_end,
+	.invalidate_range	= gru_invalidate_range,
 	.release		= gru_release,
 };
 
Index: linux-2.6/include/linux/kvm_host.h
===================================================================
--- linux-2.6.orig/include/linux/kvm_host.h
+++ linux-2.6/include/linux/kvm_host.h
@@ -125,7 +125,6 @@ struct kvm {
 #ifdef KVM_ARCH_WANT_MMU_NOTIFIER
 	struct mmu_notifier mmu_notifier;
 	unsigned long mmu_notifier_seq;
-	long mmu_notifier_count;
 #endif
 };
 
@@ -360,15 +359,6 @@ int kvm_trace_ioctl(unsigned int ioctl, 
 #ifdef KVM_ARCH_WANT_MMU_NOTIFIER
 static inline int mmu_notifier_retry(struct kvm_vcpu *vcpu, unsigned long mmu_seq)
 {
-	if (unlikely(vcpu->kvm->mmu_notifier_count))
-		return 1;
-	/*
-	 * Both reads happen under the mmu_lock and both values are
-	 * modified under mmu_lock, so there's no need of smb_rmb()
-	 * here in between, otherwise mmu_notifier_count should be
-	 * read before mmu_notifier_seq, see
-	 * mmu_notifier_invalidate_range_end write side.
-	 */
 	if (vcpu->kvm->mmu_notifier_seq != mmu_seq)
 		return 1;
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

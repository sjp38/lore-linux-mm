Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 134AF440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 02:07:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 77so8043979wrb.11
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 23:07:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si3465597wrq.16.2017.07.12.23.07.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 23:07:08 -0700 (PDT)
Date: Thu, 13 Jul 2017 07:07:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170713060706.o2cuko5y6irxwnww@suse.de>
References: <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Wed, Jul 12, 2017 at 04:27:23PM -0700, Nadav Amit wrote:
> > If reclaim is first, it'll take the PTL, set batched while a racing
> > mprotect/munmap/etc spins. On release, the racing mprotect/munmmap
> > immediately calls flush_tlb_batched_pending() before proceeding as normal,
> > finding pte_none with the TLB flushed.
> 
> This is the scenario I regarded in my example. Notice that when the first
> flush_tlb_batched_pending is called, CPU0 and CPU1 hold different page-table
> locks - allowing them to run concurrently. As a result
> flush_tlb_batched_pending is executed before the PTE was cleared and
> mm->tlb_flush_batched is cleared. Later, after CPU0 runs ptep_get_and_clear
> mm->tlb_flush_batched remains clear, and CPU1 can use the stale PTE.
> 

If they hold different PTL locks, it means that reclaim and and the parallel
munmap/mprotect/madvise/mremap operation are operating on different regions
of an mm or separate mm's and the race should not apply or at the very
least is equivalent to not batching the flushes. For multiple parallel
operations, munmap/mprotect/mremap are serialised by mmap_sem so there
is only one risky operation at a time. For multiple madvise, there is a
small window when a page is accessible after madvise returns but it is an
advisory call so it's primarily a data integrity concern and the TLB is
flushed before the page is either freed or IO starts on the reclaim side.

> > If the mprotect/munmap/etc is first, it'll take the PTL, observe that
> > pte_present and handle the flushing itself while reclaim potentially
> > spins. When reclaim acquires the lock, it'll still set set tlb_flush_batched.
> > 
> > As it's PTL that is taken for that field, it is possible for the accesses
> > to be re-ordered but only in the case where a race is not occurring.
> > I'll think some more about whether barriers are necessary but concluded
> > they weren't needed in this instance. Doing the setting/clear+flush under
> > the PTL, the protection is similar to normal page table operations that
> > do not batch the flush.
> > 
> >> One more question, please: how does elevated page count or even locking the
> >> page help (as you mention in regard to uprobes and ksm)? Yes, the page will
> >> not be reclaimed, but IIUC try_to_unmap is called before the reference count
> >> is frozen, and the page lock is dropped on each iteration of the loop in
> >> shrink_page_list. In this case, it seems to me that uprobes or ksm may still
> >> not flush the TLB.
> > 
> > If page lock is held then reclaim skips the page entirely and uprobe,
> > ksm and cow holds the page lock for pages that potentially be observed
> > by reclaim.  That is the primary protection for those paths.
> 
> It is really hard, at least for me, to track this synchronization scheme, as
> each path is protected in different means. I still don???t understand why it
> is true, since the loop in shrink_page_list calls __ClearPageLocked(page) on
> each iteration, before the actual flush takes place.
> 

At teh point of __ClearPageLocked, reclaim was holding the page lock and
reached the point where there cannot be any other references to it and
is definitely cleaned. Any hypothetical TLB entry that exists at this
point is for read-only which would trap if a write was attempted and the
TLB is flushed before the page is freed so there is no possibility the
page is reallocated and the TLB entry now points to unrelated data.

> Actually, I think that based on Andy???s patches there is a relatively
> reasonable solution.

On top of Andy's work, the patch currently is below. Andy, is that roughly
what you had in mind? I didn't think the comments in flush_tlb_func_common
needed updating.

I would have test results but the test against the tip tree without the patch
failed overnight with what looks like filesystem corruption that happened
*after* tests completed and it was untarring and building the next kernel to
test with the patch applied. I'm not sure why yet or how reproducible it is.

---8<---
mm, mprotect: Flush TLB if potentially racing with a parallel reclaim leaving stale TLB entries

Nadav Amit identified a theoritical race between page reclaim and mprotect
due to TLB flushes being batched outside of the PTL being held. He described
the race as follows

        CPU0                            CPU1
        ----                            ----
                                        user accesses memory using RW PTE
                                        [PTE now cached in TLB]
        try_to_unmap_one()
        ==> ptep_get_and_clear()
        ==> set_tlb_ubc_flush_pending()
                                        mprotect(addr, PROT_READ)
                                        ==> change_pte_range()
                                        ==> [ PTE non-present - no flush ]

                                        user writes using cached RW PTE
        ...

        try_to_unmap_flush()

The same type of race exists for reads when protecting for PROT_NONE and
also exists for operations that can leave an old TLB entry behind such as
munmap, mremap and madvise.

For some operations like mprotect, it's not a data integrity issue but it
is a correctness issue. For munmap, it's potentially a data integrity issue
although the race is massive as an munmap, mmap and return to userspace must
all complete between the window when reclaim drops the PTL and flushes the
TLB. However, it's theoritically possible so handle this issue by flushing
the mm if reclaim is potentially currently batching TLB flushes.

Other instances where a flush is required for a present pte should be
ok as either the page lock is held preventing parallel reclaim or a
page reference count is elevated preventing a parallel free leading to
corruption. In the case of page_mkclean there isn't an obvious path that
userspace could take advantage of without using the operations that are
guarded by this patch. Other users such as gup as a race with reclaim
looks just at PTEs. huge page variants should be ok as they don't race
with reclaim.  mincore only looks at PTEs. userfault also should be ok as
if a parallel reclaim takes place, it will either fault the page back in
or read some of the data before the flush occurs triggering a fault.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: stable@vger.kernel.org # v4.4+

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 6397275008db..1ad93cf26826 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -325,6 +325,7 @@ static inline void arch_tlbbatch_add_mm(struct arch_tlbflush_unmap_batch *batch,
 }
 
 extern void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch);
+extern void arch_tlbbatch_flush_one_mm(struct mm_struct *mm);
 
 #ifndef CONFIG_PARAVIRT
 #define flush_tlb_others(mask, info)	\
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 2c1b8881e9d3..a72975a517a1 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -455,6 +455,39 @@ void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
 	put_cpu();
 }
 
+/*
+ * Ensure that any arch_tlbbatch_add_mm calls on this mm are up to date when
+ * this returns. Using the current mm tlb_gen means the TLB will be up to date
+ * with respect to the tlb_gen set at arch_tlbbatch_add_mm. If a flush has
+ * happened since then the IPIs will still be sent but the actual flush is
+ * avoided. Unfortunately the IPIs are necessary as the per-cpu context
+ * tlb_gens cannot be safely accessed.
+ */
+void arch_tlbbatch_flush_one_mm(struct mm_struct *mm)
+{
+	int cpu;
+	struct flush_tlb_info info = {
+		.mm = mm,
+		.new_tlb_gen = atomic64_read(&mm->context.tlb_gen),
+		.start = 0,
+		.end = TLB_FLUSH_ALL,
+	};
+
+	cpu = get_cpu();
+
+	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm)) {
+		VM_WARN_ON(irqs_disabled());
+		local_irq_disable();
+		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
+		local_irq_enable();
+	}
+
+	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
+		flush_tlb_others(mm_cpumask(mm), &info);
+
+	put_cpu();
+}
+
 static ssize_t tlbflush_read_file(struct file *file, char __user *user_buf,
 			     size_t count, loff_t *ppos)
 {
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 45cdb27791a3..ab8f7e11c160 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -495,6 +495,10 @@ struct mm_struct {
 	 */
 	bool tlb_flush_pending;
 #endif
+#ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
+	/* See flush_tlb_batched_pending() */
+	bool tlb_flush_batched;
+#endif
 	struct uprobes_state uprobes_state;
 #ifdef CONFIG_HUGETLB_PAGE
 	atomic_long_t hugetlb_usage;
diff --git a/mm/internal.h b/mm/internal.h
index 0e4f558412fb..9c8a2bfb975c 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -498,6 +498,7 @@ extern struct workqueue_struct *mm_percpu_wq;
 #ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
 void try_to_unmap_flush(void);
 void try_to_unmap_flush_dirty(void);
+void flush_tlb_batched_pending(struct mm_struct *mm);
 #else
 static inline void try_to_unmap_flush(void)
 {
@@ -505,7 +506,9 @@ static inline void try_to_unmap_flush(void)
 static inline void try_to_unmap_flush_dirty(void)
 {
 }
-
+static inline void flush_tlb_batched_pending(struct mm_struct *mm)
+{
+}
 #endif /* CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH */
 
 extern const struct trace_print_flags pageflag_names[];
diff --git a/mm/madvise.c b/mm/madvise.c
index 25b78ee4fc2c..75d2cffbe61d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -320,6 +320,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 
 	tlb_remove_check_page_size_change(tlb, PAGE_SIZE);
 	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	flush_tlb_batched_pending(mm);
 	arch_enter_lazy_mmu_mode();
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
 		ptent = *pte;
diff --git a/mm/memory.c b/mm/memory.c
index bb11c474857e..b0c3d1556a94 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1197,6 +1197,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	init_rss_vec(rss);
 	start_pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	pte = start_pte;
+	flush_tlb_batched_pending(mm);
 	arch_enter_lazy_mmu_mode();
 	do {
 		pte_t ptent = *pte;
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 8edd0d576254..f42749e6bf4e 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -66,6 +66,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	    atomic_read(&vma->vm_mm->mm_users) == 1)
 		target_node = numa_node_id();
 
+	flush_tlb_batched_pending(vma->vm_mm);
 	arch_enter_lazy_mmu_mode();
 	do {
 		oldpte = *pte;
diff --git a/mm/mremap.c b/mm/mremap.c
index cd8a1b199ef9..6e3d857458de 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -152,6 +152,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	new_ptl = pte_lockptr(mm, new_pmd);
 	if (new_ptl != old_ptl)
 		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
+	flush_tlb_batched_pending(vma->vm_mm);
 	arch_enter_lazy_mmu_mode();
 
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
diff --git a/mm/rmap.c b/mm/rmap.c
index 130c238fe384..7c5c8ef583fa 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -603,6 +603,7 @@ static void set_tlb_ubc_flush_pending(struct mm_struct *mm, bool writable)
 
 	arch_tlbbatch_add_mm(&tlb_ubc->arch, mm);
 	tlb_ubc->flush_required = true;
+	mm->tlb_flush_batched = true;
 
 	/*
 	 * If the PTE was dirty then it's best to assume it's writable. The
@@ -631,6 +632,29 @@ static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
 
 	return should_defer;
 }
+
+/*
+ * Reclaim unmaps pages under the PTL but does not flush the TLB prior to
+ * releasing the PTL if TLB flushes are batched. It's possible a parallel
+ * operation such as mprotect or munmap to race between reclaim unmapping
+ * the page and flushing the page If this race occurs, it potentially allows
+ * access to data via a stale TLB entry. Tracking all mm's that have TLB
+ * batching in flight would be expensive during reclaim so instead track
+ * whether TLB batching occured in the past and if so then do a flush here
+ * if required. This will cost one additional flush per reclaim cycle paid
+ * by the first operation at risk such as mprotect and mumap.
+ *
+ * This must be called under the PTL so that accesses to tlb_flush_batched
+ * that is potentially a "reclaim vs mprotect/munmap/etc" race will
+ * synchronise via the PTL.
+ */
+void flush_tlb_batched_pending(struct mm_struct *mm)
+{
+	if (mm->tlb_flush_batched) {
+		arch_tlbbatch_flush_one_mm(mm);
+		mm->tlb_flush_batched = false;
+	}
+}
 #else
 static void set_tlb_ubc_flush_pending(struct mm_struct *mm, bool writable)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

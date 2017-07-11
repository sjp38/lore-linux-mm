Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 769D16810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 17:52:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 23so1171912wry.4
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:52:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m63si392447wme.38.2017.07.11.14.52.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 14:52:43 -0700 (PDT)
Date: Tue, 11 Jul 2017 22:52:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170711215240.tdpmwmgwcuerjj3o@suse.de>
References: <20170711064149.bg63nvi54ycynxw4@suse.de>
 <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170711200923.gyaxfjzz3tpvreuq@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 09:09:23PM +0100, Mel Gorman wrote:
> On Tue, Jul 11, 2017 at 08:18:23PM +0100, Mel Gorman wrote:
> > I don't think we should be particularly clever about this and instead just
> > flush the full mm if there is a risk of a parallel batching of flushing is
> > in progress resulting in a stale TLB entry being used. I think tracking mms
> > that are currently batching would end up being costly in terms of memory,
> > fairly complex, or both. Something like this?
> > 
> 
> mremap and madvise(DONTNEED) would also need to flush. Memory policies are
> fine as a move_pages call that hits the race will simply fail to migrate
> a page that is being freed and once migration starts, it'll be flushed so
> a stale access has no further risk. copy_page_range should also be ok as
> the old mm is flushed and the new mm cannot have entries yet.
> 

Adding those results in

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

Other instances where a flush is required for a present pte should be ok
as either page reference counts are elevated preventing parallel reclaim
or in the case of page_mkclean there isn't an obvious path that userspace
could take advantage of without using the operations that are guarded by
this patch. Other users such as gup as a race with reclaim looks just at
PTEs. huge page variants should be ok as they don't race with reclaim.
mincore only looks at PTEs. userfault also should be ok as if a parallel
reclaim takes place, it will either fault the page back in or read some
of the data before the flush occurs triggering a fault.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: stable@vger.kernel.org # v4.4+
---
 include/linux/mm_types.h |  4 ++++
 mm/internal.h            |  5 ++++-
 mm/madvise.c             |  1 +
 mm/memory.c              |  1 +
 mm/mprotect.c            |  3 +++
 mm/mremap.c              |  1 +
 mm/rmap.c                | 24 +++++++++++++++++++++++-
 7 files changed, 37 insertions(+), 2 deletions(-)

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
index 0e4f558412fb..bf835a5a9854 100644
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
+static inline void mm_tlb_flush_batched(struct mm_struct *mm)
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
index 8edd0d576254..27135b91a4b4 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -61,6 +61,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 	if (!pte)
 		return 0;
 
+	/* Guard against parallel reclaim batching a TLB flush without PTL */
+	flush_tlb_batched_pending(vma->vm_mm);
+
 	/* Get target node for single threaded private VMAs */
 	if (prot_numa && !(vma->vm_flags & VM_SHARED) &&
 	    atomic_read(&vma->vm_mm->mm_users) == 1)
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
index d405f0e0ee96..5a3e4ff9c4a0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -637,12 +637,34 @@ static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
 		return false;
 
 	/* If remote CPUs need to be flushed then defer batch the flush */
-	if (cpumask_any_but(mm_cpumask(mm), get_cpu()) < nr_cpu_ids)
+	if (cpumask_any_but(mm_cpumask(mm), get_cpu()) < nr_cpu_ids) {
 		should_defer = true;
+		mm->tlb_flush_batched = true;
+	}
 	put_cpu();
 
 	return should_defer;
 }
+
+/*
+ * Reclaim unmaps pages under the PTL but does not flush the TLB prior to
+ * releasing the PTL if TLB flushes are batched. It's possible a parallel
+ * operation such as mprotect or munmap to race between reclaim unmapping
+ * the page and flushing the page If this race occurs, it potentially allows
+ * access to data via a stale TLB entry. Tracking all mm's that have TLB
+ * batching pending would be expensive during reclaim so instead track
+ * whether TLB batching occured in the past and if so then do a full mmi
+ * flush here. This will cost one additional flush per reclaim cycle paid
+ * by the first operation at risk such as mprotect and mumap. This assumes
+ * it's called under the PTL to synchronise access to mm->tlb_flush_batched.
+ */
+void flush_tlb_batched_pending(struct mm_struct *mm)
+{
+	if (mm->tlb_flush_batched) {
+		flush_tlb_mm(mm);
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

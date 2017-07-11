Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A70306810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:18:27 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u110so358256wrb.14
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 12:18:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v143si124226wmd.52.2017.07.11.12.18.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 12:18:25 -0700 (PDT)
Date: Tue, 11 Jul 2017 20:18:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170711191823.qthrmdgqcd3rygjk@suse.de>
References: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
 <20170711064149.bg63nvi54ycynxw4@suse.de>
 <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 10:23:50AM -0700, Andrew Lutomirski wrote:
> On Tue, Jul 11, 2017 at 8:53 AM, Mel Gorman <mgorman@suse.de> wrote:
> > On Tue, Jul 11, 2017 at 07:58:04AM -0700, Andrew Lutomirski wrote:
> >> On Tue, Jul 11, 2017 at 6:20 AM, Mel Gorman <mgorman@suse.de> wrote:
> >> > +
> >> > +/*
> >> > + * This is called after an mprotect update that altered no pages. Batched
> >> > + * unmap releases the PTL before a flush occurs leaving a window where
> >> > + * an mprotect that reduces access rights can still access the page after
> >> > + * mprotect returns via a stale TLB entry. Avoid this possibility by flushing
> >> > + * the local TLB if mprotect updates no pages so that the the caller of
> >> > + * mprotect always gets expected behaviour. It's overkill and unnecessary to
> >> > + * flush all TLBs as a separate thread accessing the data that raced with
> >> > + * both reclaim and mprotect as there is no risk of data corruption and
> >> > + * the exact timing of a parallel thread seeing a protection update without
> >> > + * any serialisation on the application side is always uncertain.
> >> > + */
> >> > +void batched_unmap_protection_update(void)
> >> > +{
> >> > +       count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> >> > +       local_flush_tlb();
> >> > +       trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
> >> > +}
> >> > +
> >>
> >> What about remote CPUs?  You could get migrated right after mprotect()
> >> or the inconsistency could be observed on another CPU.
> >
> > If it's migrated then it has also context switched so the TLB entry will
> > be read for the first time.
> 
> I don't think this is true.  On current kernels, if the other CPU is
> running a thread in the same process, then there won't be a flush if
> we migrate there. 

True although that would also be covered if a flush happening unconditionally
on mprotect (and arguably munmap) if a batched TLB flush took place in the
past. It's heavier than it needs to be but it would be trivial to track
and only incur a cost if reclaim touched any pages belonging to the process
in the past so a relatively rare operation in the normal case. It could be
forced by continually keeping a system under memory pressure while looping
around mprotect but the worst-case would be similar costs to never batching
the flushing at all.

> In -tip, slated for 4.13, if the other CPU is lazy
> and is using the current process's page tables, it won't flush if we
> migrate there and it's not stale (as determined by the real flush
> APIs, not local_tlb_flush()).  With PCID, the kernel will aggressively
> try to avoid the flush no matter what.
> 

I agree that PCID means that flushing needs to be more agressive and there
is not much point working on two solutions and assume PCID is merged.

> > If the entry is inconsistent for another CPU
> > accessing the data then it'll potentially successfully access a page that
> > was just mprotected but this is similar to simply racing with the call
> > to mprotect itself. The timing isn't exact, nor does it need to be.
> 
> Thread A:
> mprotect(..., PROT_READ);
> pthread_mutex_unlock();
> 
> Thread B:
> pthread_mutex_lock();
> write to the mprotected address;
> 
> I think it's unlikely that this exact scenario will affect a
> conventional C program, but I can see various GC systems and sandboxes
> being very surprised.
> 

Maybe. The window is massively wide as the mprotect, unlock, remote wakeup
and write all need to complete between the unmap releasing the PTL and
the flush taking place. Still, it is theoritically possible.

> 
> >> I also really
> >> don't like bypassing arch code like this.  The implementation of
> >> flush_tlb_mm_range() in tip:x86/mm (and slated for this merge window!)
> >> is *very* different from what's there now, and it is not written in
> >> the expectation that some generic code might call local_tlb_flush()
> >> and expect any kind of coherency at all.
> >>
> >
> > Assuming that gets merged first then the most straight-forward approach
> > would be to setup a arch_tlbflush_unmap_batch with just the local CPU set
> > in the mask or something similar.
> 
> With what semantics?
> 

I'm dropping this idea because the more I think about it, the more I think
that a more general flush is needed if TLB batching was used in the past.
We could keep active track of mm's with flushes pending but it would be
fairly complex, cost in terms of keeping track of mm's needing flushing
and ultimately might be more expensive than just flushing immediately.

If it's actually unfixable then, even though it's theoritical given the
massive amount of activity that has to happen in a very short window, there
would be no choice but to remove the TLB batching entirely which would be
very unfortunate given that IPIs during reclaim will be very high once again.

> >> Would a better fix perhaps be to find a way to figure out whether a
> >> batched flush is pending on the mm in question and flush it out if you
> >> do any optimizations based on assuming that the TLB is in any respect
> >> consistent with the page tables?  With the changes in -tip, x86 could,
> >> in principle, supply a function to sync up its TLB state.  That would
> >> require cross-CPU poking at state or an inconditional IPI (that might
> >> end up not flushing anything), but either is doable.
> >
> > It's potentially doable if a field like tlb_flush_pending was added
> > to mm_struct that is set when batching starts. I don't think there is
> > a logical place where it can be cleared as when the TLB gets flushed by
> > reclaim, it can't rmap again to clear the flag. What would happen is that
> > the first mprotect after any batching happened at any point in the past
> > would have to unconditionally flush the TLB and then clear the flag. That
> > would be a relatively minor hit and cover all the possibilities and should
> > work unmodified with or without your series applied.
> >
> > Would that be preferable to you?
> 
> I'm not sure I understand it well enough to know whether I like it.
> I'm imagining an API that says "I'm about to rely on TLBs being
> coherent for this mm -- make it so". 

I don't think we should be particularly clever about this and instead just
flush the full mm if there is a risk of a parallel batching of flushing is
in progress resulting in a stale TLB entry being used. I think tracking mms
that are currently batching would end up being costly in terms of memory,
fairly complex, or both. Something like this?

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
diff --git a/mm/rmap.c b/mm/rmap.c
index d405f0e0ee96..52633a124a4e 100644
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
+ * Reclaim batches unmaps pages under the PTL but does not flush the TLB
+ * TLB prior to releasing the PTL. It's possible a parallel mprotect or
+ * munmap can race between reclaim unmapping the page and flushing the
+ * page. If this race occurs, it potentially allows access to data via
+ * a stale TLB entry. Tracking all mm's that have TLB batching pending
+ * would be expensive during reclaim so instead track whether TLB batching
+ * occured in the past and if so then do a full mm flush here. This will
+ * cost one additional flush per reclaim cycle paid by the first munmap or
+ * mprotect. This assumes it's called under the PTL to synchronise access
+ * to mm->tlb_flush_batched.
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

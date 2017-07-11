Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D34846B0500
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 09:20:26 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x23so31789193wrb.6
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 06:20:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k12si10080439wrc.386.2017.07.11.06.20.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 06:20:25 -0700 (PDT)
Date: Tue, 11 Jul 2017 14:20:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
References: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
 <20170711064149.bg63nvi54ycynxw4@suse.de>
 <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de>
 <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 03:40:02AM -0700, Nadav Amit wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> 
> >>> That is the same to a race whereby there is no batching mechanism and the
> >>> racing operation happens between a pte clear and a flush as ptep_clear_flush
> >>> is not atomic. All that differs is that the race window is a different size.
> >>> The application on CPU1 is buggy in that it may or may not succeed the write
> >>> but it is buggy regardless of whether a batching mechanism is used or not.
> >> 
> >> Thanks for your quick and detailed response, but I fail to see how it can
> >> happen without batching. Indeed, the PTE clear and flush are not ???atomic???,
> >> but without batching they are both performed under the page table lock
> >> (which is acquired in page_vma_mapped_walk and released in
> >> page_vma_mapped_walk_done). Since the lock is taken, other cores should not
> >> be able to inspect/modify the PTE. Relevant functions, e.g., zap_pte_range
> >> and change_pte_range, acquire the lock before accessing the PTEs.
> > 
> > I was primarily thinking in terms of memory corruption or data loss.
> > However, we are still protected although it's not particularly obvious why.
> > 
> > On the reclaim side, we are either reclaiming clean pages (which ignore
> > the accessed bit) or normal reclaim. If it's clean pages then any parallel
> > write must update the dirty bit at minimum. If it's normal reclaim then
> > the accessed bit is checked and if cleared in try_to_unmap_one, it uses a
> > ptep_clear_flush_young_notify so the TLB gets flushed. We don't reclaim
> > the page in either as part of page_referenced or try_to_unmap_one but
> > clearing the accessed bit flushes the TLB.
> 
> Wait. Are you looking at the x86 arch function? The TLB is not flushed when
> the access bit is cleared:
> 
> int ptep_clear_flush_young(struct vm_area_struct *vma,
>                            unsigned long address, pte_t *ptep)
> {
>         /*
>          * On x86 CPUs, clearing the accessed bit without a TLB flush
>          * doesn't cause data corruption. [ It could cause incorrect
>          * page aging and the (mistaken) reclaim of hot pages, but the
>          * chance of that should be relatively low. ]
>          *                 
>          * So as a performance optimization don't flush the TLB when
>          * clearing the accessed bit, it will eventually be flushed by
>          * a context switch or a VM operation anyway. [ In the rare
>          * event of it not getting flushed for a long time the delay
>          * shouldn't really matter because there's no real memory
>          * pressure for swapout to react to. ]
>          */
>         return ptep_test_and_clear_young(vma, address, ptep);
> }
> 

I forgot this detail, thanks for correcting me.

> > 
> > On the mprotect side then, as the page was first accessed, clearing the
> > accessed bit incurs a TLB flush on the reclaim side before the second write.
> > That means any TLB entry that exists cannot have the accessed bit set so
> > a second write needs to update it.
> > 
> > While it's not clearly documented, I checked with hardware engineers
> > at the time that an update of the accessed or dirty bit even with a TLB
> > entry will check the underlying page tables and trap if it's not present
> > and the subsequent fault will then fail on sigsegv if the VMA protections
> > no longer allow the write.
> > 
> > So, on one side if ignoring the accessed bit during reclaim, the pages
> > are clean so any access will set the dirty bit and trap if unmapped in
> > parallel. On the other side, the accessed bit if set cleared the TLB and
> > if not set, then the hardware needs to update and again will trap if
> > unmapped in parallel.
> 
> 
> Yet, even regardless to the TLB flush it seems there is still a possible
> race:
> 
> CPU0				CPU1
> ----				----
> ptep_clear_flush_young_notify
> ==> PTE.A==0
> 				access PTE
> 				==> PTE.A=1
> prep_get_and_clear
> 				change mapping (and PTE)
> 				Use stale TLB entry

So I think you're right and this is a potential race. The first access can
be a read or a write as it's a problem if the mprotect call restricts
access.

> > If this guarantee from hardware was every shown to be wrong or another
> > architecture wanted to add batching without the same guarantee then mprotect
> > would need to do a local_flush_tlb if no pages were updated by the mprotect
> > but right now, this should not be necessary.
> > 
> >> Can you please explain why you consider the application to be buggy?
> > 
> > I considered it a bit dumb to mprotect for READ/NONE and then try writing
> > the same mapping. However, it will behave as expected.
> 
> I don???t think that this is the only scenario. For example, the application
> may create a new memory mapping of a different file using mmap at the same
> memory address that was used before, just as that memory is reclaimed.

That requires the existing mapping to be unmapped which will flush the
TLB and parallel mmap/munmap serialises on mmap_sem. The race appears to
be specific to mprotect which avoids the TLB flush if no pages were updated.

> The
> application can (inadvertently) cause such a scenario by using MAP_FIXED.
> But even without MAP_FIXED, running mmap->munmap->mmap can reuse the same
> virtual address.
> 

With flushes in between.

> > Such applications are safe due to how the accessed bit is handled by the
> > software (flushes TLB if clearing young) and hardware (traps if updating
> > the accessed or dirty bit and the underlying PTE was unmapped even if
> > there is a TLB entry).
> 
> I don???t think it is so. And I also think there are many additional
> potentially problematic scenarios.
> 

I believe it's specific to mprotect but can be handled by flushing the
local TLB when mprotect updates no pages. Something like this;

---8<---
mm, mprotect: Flush the local TLB if mprotect potentially raced with a parallel reclaim

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

The same type of race exists for reads when protecting for PROT_NONE.
This is not a data integrity issue as the TLB is always flushed before any
IO is queued or a page is freed but it is a correctness issue as a process
restricting access with mprotect() may still be able to access the data
after the syscall returns due to a stale TLB entry. Handle this issue by
flushing the local TLB if reclaim is potentially batching TLB flushes and
mprotect altered no pages.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: stable@vger.kernel.org # v4.4+
---
 mm/internal.h |  5 ++++-
 mm/mprotect.c | 12 ++++++++++--
 mm/rmap.c     | 20 ++++++++++++++++++++
 3 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 0e4f558412fb..9b7d1a597816 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -498,6 +498,7 @@ extern struct workqueue_struct *mm_percpu_wq;
 #ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
 void try_to_unmap_flush(void);
 void try_to_unmap_flush_dirty(void);
+void batched_unmap_protection_update(void);
 #else
 static inline void try_to_unmap_flush(void)
 {
@@ -505,7 +506,9 @@ static inline void try_to_unmap_flush(void)
 static inline void try_to_unmap_flush_dirty(void)
 {
 }
-
+static inline void batched_unmap_protection_update()
+{
+}
 #endif /* CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH */
 
 extern const struct trace_print_flags pageflag_names[];
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 8edd0d576254..3de353d4b5fb 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -254,9 +254,17 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 				 dirty_accountable, prot_numa);
 	} while (pgd++, addr = next, addr != end);
 
-	/* Only flush the TLB if we actually modified any entries: */
-	if (pages)
+	/*
+	 * Only flush all TLBs if we actually modified any entries. If no
+	 * pages are modified, then call batched_unmap_protection_update
+	 * if the context is a mprotect() syscall.
+	 */
+	if (pages) {
 		flush_tlb_range(vma, start, end);
+	} else {
+		if (!prot_numa)
+			batched_unmap_protection_update();
+	}
 	clear_tlb_flush_pending(mm);
 
 	return pages;
diff --git a/mm/rmap.c b/mm/rmap.c
index d405f0e0ee96..02cb035e4ce6 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -643,6 +643,26 @@ static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
 
 	return should_defer;
 }
+
+/*
+ * This is called after an mprotect update that altered no pages. Batched
+ * unmap releases the PTL before a flush occurs leaving a window where
+ * an mprotect that reduces access rights can still access the page after
+ * mprotect returns via a stale TLB entry. Avoid this possibility by flushing
+ * the local TLB if mprotect updates no pages so that the the caller of
+ * mprotect always gets expected behaviour. It's overkill and unnecessary to
+ * flush all TLBs as a separate thread accessing the data that raced with
+ * both reclaim and mprotect as there is no risk of data corruption and
+ * the exact timing of a parallel thread seeing a protection update without
+ * any serialisation on the application side is always uncertain.
+ */
+void batched_unmap_protection_update(void)
+{
+	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
+	local_flush_tlb();
+	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
+}
+
 #else
 static void set_tlb_ubc_flush_pending(struct mm_struct *mm, bool writable)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

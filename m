Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0A56B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 11:55:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 23so15520312wry.4
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 08:55:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t29si12413594wra.201.2017.07.17.08.55.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 08:55:25 -0700 (PDT)
Date: Mon, 17 Jul 2017 16:55:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm, mprotect: Flush TLB if potentially racing with a
 parallel reclaim leaving stale TLB entries
Message-ID: <20170717155523.emckq2esjro6hf3z@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

For some operations like mprotect, it's not necessarily a data integrity
issue but it is a correctness issue as there is a window where an mprotect
that limits access still allows access. For munmap, it's potentially a data
integrity issue although the race is massive as an munmap, mmap and return to
userspace must all complete between the window when reclaim drops the PTL and
flushes the TLB. However, it's theoritically possible so handle this issue
by flushing the mm if reclaim is potentially currently batching TLB flushes.

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

Note that a variant of this patch was acked by Andy Lutomirski but this
was for the x86 parts on top of his PCID work which didn't make the 4.13
merge window as expected. His ack is dropped from this version and there
will be a follow-on patch on top of PCID that will include his ack.

Reported-by: Nadav Amit <nadav.amit@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: stable@vger.kernel.org # v4.4+
---
 include/linux/mm_types.h |  4 ++++
 mm/internal.h            |  5 ++++-
 mm/madvise.c             |  1 +
 mm/memory.c              |  1 +
 mm/mprotect.c            |  1 +
 mm/mremap.c              |  1 +
 mm/rmap.c                | 36 ++++++++++++++++++++++++++++++++++++
 7 files changed, 48 insertions(+), 1 deletion(-)

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
index d405f0e0ee96..c0e64b7b0daf 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -617,6 +617,13 @@ static void set_tlb_ubc_flush_pending(struct mm_struct *mm, bool writable)
 	tlb_ubc->flush_required = true;
 
 	/*
+	 * Ensure compiler does not re-order the setting ot tlb_flush_batched
+	 * before the PTE is cleared.
+	 */
+	barrier();
+	mm->tlb_flush_batched = true;
+
+	/*
 	 * If the PTE was dirty then it's best to assume it's writable. The
 	 * caller must use try_to_unmap_flush_dirty() or try_to_unmap_flush()
 	 * before the page is queued for IO.
@@ -643,6 +650,35 @@ static bool should_defer_flush(struct mm_struct *mm, enum ttu_flags flags)
 
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
+		flush_tlb_mm(mm);
+
+		/*
+		 * Do not allow the compiler to re-order the clearing of
+		 * tlb_flush_batched before the tlb is flushed.
+		 */
+		barrier();
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id CE9306B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 08:43:52 -0500 (EST)
Received: by wggy19 with SMTP id y19so40041561wgg.10
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 05:43:52 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si23840109wiy.111.2015.03.03.05.43.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 05:43:51 -0800 (PST)
Date: Tue, 3 Mar 2015 13:43:46 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [regression v4.0-rc1] mm: IPIs from TLB flushes causing
 significant performance degradation.
Message-ID: <20150303134346.GO3087@suse.de>
References: <20150302010413.GP4251@dastard>
 <CA+55aFzGFvVGD_8Y=jTkYwgmYgZnW0p0Fjf7OHFPRcL6Mz4HOw@mail.gmail.com>
 <20150303014733.GL18360@dastard>
 <CA+55aFw+7V9DfxBA2_DhMNrEQOkvdwjFFga5Y67-a6yVeAz+NQ@mail.gmail.com>
 <CA+55aFw+fb=Fh4M2wA4dVskgqN7PhZRGZS6JTMx4Rb1Qn++oaA@mail.gmail.com>
 <20150303052004.GM18360@dastard>
 <CA+55aFyczb5asoTwhzaJr1JdRi1epg1A6cFJgnzMMZj6U0gFWA@mail.gmail.com>
 <20150303113437.GR4251@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150303113437.GR4251@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Matt B <jackdachef@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs@oss.sgi.com

On Tue, Mar 03, 2015 at 10:34:37PM +1100, Dave Chinner wrote:
> On Mon, Mar 02, 2015 at 10:56:14PM -0800, Linus Torvalds wrote:
> > On Mon, Mar 2, 2015 at 9:20 PM, Dave Chinner <david@fromorbit.com> wrote:
> > >>
> > >> But are those migrate-page calls really common enough to make these
> > >> things happen often enough on the same pages for this all to matter?
> > >
> > > It's looking like that's a possibility.
> > 
> > Hmm. Looking closer, commit 10c1045f28e8 already should have
> > re-introduced the "pte was already NUMA" case.
> > 
> > So that's not it either, afaik. Plus your numbers seem to say that
> > it's really "migrate_pages()" that is done more. So it feels like the
> > numa balancing isn't working right.
> 
> So that should show up in the vmstats, right? Oh, and there's a
> tracepoint in migrate_pages, too. Same 6x10s samples in phase 3:
> 

The stats indicate both more updates and more faults. Can you try this
please? It's against 4.0-rc1.

---8<---
mm: numa: Reduce amount of IPI traffic due to automatic NUMA balancing

Dave Chinner reported the following on https://lkml.org/lkml/2015/3/1/226

   Across the board the 4.0-rc1 numbers are much slower, and the
   degradation is far worse when using the large memory footprint
   configs. Perf points straight at the cause - this is from 4.0-rc1
   on the "-o bhash=101073" config:

   -   56.07%    56.07%  [kernel]            [k] default_send_IPI_mask_sequence_phys
      - default_send_IPI_mask_sequence_phys
         - 99.99% physflat_send_IPI_mask
            - 99.37% native_send_call_func_ipi
                 smp_call_function_many
               - native_flush_tlb_others
                  - 99.85% flush_tlb_page
                       ptep_clear_flush
                       try_to_unmap_one
                       rmap_walk
                       try_to_unmap
                       migrate_pages
                       migrate_misplaced_page
                     - handle_mm_fault
                        - 99.73% __do_page_fault
                             trace_do_page_fault
                             do_async_page_fault
                           + async_page_fault
              0.63% native_send_call_func_single_ipi
                 generic_exec_single
                 smp_call_function_single

This was bisected to commit 4d94246699 ("mm: convert p[te|md]_mknonnuma
and remaining page table manipulations") but I expect the full issue is
related series up to and including that patch.

There are two important changes that might be relevant here. The first is
marking huge PMDs to trap a hinting fault potentially sends an IPI to flush
TLBs. This did not show up in Dave's report and it almost certainly is not
a factor but it would affect IPI counts for other users. The second is that
the PTE protection update now clears the PTE leaving a window where parallel
faults can be trapped resulting in more overhead from faults. Higher faults,
even if correct can result in higher scan rates indirectly and may explain
what Dave is saying.

This is not signed off or tested.
---
 mm/huge_memory.c | 11 +++++++++--
 mm/mprotect.c    | 17 +++++++++++++++--
 2 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fc00c8cb5a82..7fc4732c77d7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1494,8 +1494,15 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		}
 
 		if (!prot_numa || !pmd_protnone(*pmd)) {
-			ret = 1;
-			entry = pmdp_get_and_clear_notify(mm, addr, pmd);
+			/*
+			 * NUMA hinting update can avoid a clear and flush as
+			 * it is not a functional correctness issue if access
+			 * occurs after the update
+			 */
+			if (prot_numa)
+				entry = *pmd;
+			else
+				entry = pmdp_get_and_clear_notify(mm, addr, pmd);
 			entry = pmd_modify(entry, newprot);
 			ret = HPAGE_PMD_NR;
 			set_pmd_at(mm, addr, pmd, entry);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 44727811bf4c..1efd03ffa0d8 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -77,19 +77,32 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			pte_t ptent;
 
 			/*
-			 * Avoid trapping faults against the zero or KSM
-			 * pages. See similar comment in change_huge_pmd.
+			 * prot_numa does not clear the pte during protection
+			 * update as asynchronous hardware updates are not
+			 * a concern but unnecessary faults while the PTE is
+			 * cleared is overhead.
 			 */
 			if (prot_numa) {
 				struct page *page;
 
 				page = vm_normal_page(vma, addr, oldpte);
+
+				/*
+				 * Avoid trapping faults against the zero or KSM
+				 * pages. See similar comment in change_huge_pmd.
+				 */
 				if (!page || PageKsm(page))
 					continue;
 
 				/* Avoid TLB flush if possible */
 				if (pte_protnone(oldpte))
 					continue;
+
+				ptent = *pte;
+				ptent = pte_modify(ptent, newprot);
+				set_pte_at(mm, addr, pte, ptent);
+				pages++;
+				continue;
 			}
 
 			ptent = ptep_modify_prot_start(mm, addr, pte);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

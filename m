Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D57BD6B02A9
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 21:32:05 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d6-v6so251658plo.15
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 18:32:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bc12-v6sor5436556plb.85.2018.07.02.18.32.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 18:32:04 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH] mm: allow arch to supply p??_free_tlb functions
Date: Tue,  3 Jul 2018 11:31:31 +1000
Message-Id: <20180703013131.2807-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-mm <linux-mm@kvack.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-arch <linux-arch@vger.kernel.org>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <nadav.amit@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

The mmu_gather APIs keep track of the invalidated address range
including the span covered by invalidated page table pages. Ranges
covered by page tables but not ptes (and therefore no TLBs) still need
to be invalidated because some architectures (x86) can cache
intermediate page table entries, and invalidate those with normal TLB
invalidation instructions to be almost-backward-compatible.

Architectures which don't cache intermediate page table entries, or
which invalidate these caches separately from TLB invalidation, do not
require TLB invalidation range expanded over page tables.

Allow architectures to supply their own p??_free_tlb functions, which
can avoid the __tlb_adjust_range.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
Just wanted your ack/nack on this approach, I just tidied the patch
and re-did the changelog. We left off with you wondering if overriding
__tlb_adjust_range for page tables would be the better option, but I
couldn't see any real benefit over this way. Actually I think this is
cleaner, powerpc will simply switch the name of its function from
__pte_free_tlb to pte_free_tlb to take over the tlb management for it.

And is this something that you'd merge at this point of the cycle, so
that arch changes for next window won't include generic code changes or
have cross tree dependencies?

Thanks,
Nick

 include/asm-generic/tlb.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index faddde44de8c..3063125197ad 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -265,33 +265,41 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
  * For now w.r.t page table cache, mark the range_size as PAGE_SIZE
  */
 
+#ifndef pte_free_tlb
 #define pte_free_tlb(tlb, ptep, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__pte_free_tlb(tlb, ptep, address);		\
 	} while (0)
+#endif
 
+#ifndef pmd_free_tlb
 #define pmd_free_tlb(tlb, pmdp, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
 		__pmd_free_tlb(tlb, pmdp, address);		\
 	} while (0)
+#endif
 
 #ifndef __ARCH_HAS_4LEVEL_HACK
+#ifndef pud_free_tlb
 #define pud_free_tlb(tlb, pudp, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__pud_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
+#endif
 
 #ifndef __ARCH_HAS_5LEVEL_HACK
+#ifndef p4d_free_tlb
 #define p4d_free_tlb(tlb, pudp, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
 		__p4d_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
+#endif
 
 #define tlb_migrate_finish(mm) do {} while (0)
 
-- 
2.17.0
